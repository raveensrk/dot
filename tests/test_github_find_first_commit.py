import contextlib
import importlib.machinery
import importlib.util
import io
import json
from pathlib import Path
import unittest
from unittest.mock import patch
from urllib.error import HTTPError, URLError


PATH = Path(__file__).resolve().parents[1] / "script" / ",github_find_first_commit"
LOADER = importlib.machinery.SourceFileLoader("first_commit", str(PATH))
SPEC = importlib.util.spec_from_loader(LOADER.name, LOADER)
APP = importlib.util.module_from_spec(SPEC)
LOADER.exec_module(APP)
SHA = "a" * 40


def response(data, link=""):
    stream = io.StringIO(json.dumps(data))
    stream.headers = {"Link": link}
    return stream


class FirstCommitTest(unittest.TestCase):
    def test_report_includes_api_url_and_creation_date(self):
        with patch.object(APP, "urlopen", side_effect=[
            response([{"sha": SHA}]), response({"created_at": "2025-12-06T15:00:00Z"}),
        ]) as request, contextlib.redirect_stdout(io.StringIO()) as output:
            self.assertEqual(APP.main(["https://github.com/a/b/commit/abc"]), 0)
        self.assertEqual(output.getvalue(), (
            f"https://github.com/a/b/commit/{SHA}\n"
            "https://api.github.com/repos/a/b\n"
            "Created at: 2025-12-06T15:00:00Z\n"
        ))
        self.assertEqual(request.call_args.args[0].full_url, "https://api.github.com/repos/a/b")

    def test_invalid_metadata_produces_no_partial_report(self):
        for data in ({}, [], {"created_at": None}, {"created_at": "bad"}):
            with patch.object(APP, "urlopen", side_effect=[response([{"sha": SHA}]), response(data)]):
                with contextlib.redirect_stdout(io.StringIO()) as output, contextlib.redirect_stderr(io.StringIO()):
                    self.assertEqual(APP.main(["a/b"]), 1)
                self.assertEqual(output.getvalue(), "")

    def test_last_page_without_walking_intermediate_pages(self):
        link = '<https://api.github.com/repos/a/b/commits?per_page=1&page=900>; rel="last"'
        with patch.object(APP, "urlopen", side_effect=[
            response([{"sha": "b" * 40}], link), response([{"sha": SHA}]),
        ]) as request:
            self.assertEqual(APP.first("a/b"), f"https://github.com/a/b/commit/{SHA}")
        self.assertEqual(request.call_count, 2)
        self.assertIn("page=900", request.call_args.args[0].full_url)
        self.assertEqual(request.call_args.kwargs["timeout"], 20)

    def test_single_commit_needs_one_request(self):
        with patch.object(APP, "urlopen", return_value=response([{"sha": SHA}])) as request:
            self.assertTrue(APP.first("a/b").endswith(SHA))
        request.assert_called_once()

    def test_input_forms(self):
        for value in ("a/b", "a/b.git", "https://github.com/a/b/", "https://github.com/a/b/commit/abc"):
            self.assertEqual(APP.repository(value), "a/b")

    def test_invalid_input_never_requests_network(self):
        for value in ("https://evil.com/a/b", "a", "a/b/c", "a/.."):
            with self.subTest(value=value), patch.object(APP, "urlopen") as request:
                with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit) as error:
                    APP.main([value])
                self.assertEqual(error.exception.code, 2)
                request.assert_not_called()

    def test_help_never_requests_network(self):
        for args in ([], ["help"], ["-h"], ["--help"]):
            with patch.object(APP, "urlopen") as request, contextlib.redirect_stdout(io.StringIO()):
                try:
                    self.assertEqual(APP.main(args), 0)
                except SystemExit as error:
                    self.assertEqual(error.code, 0)
                request.assert_not_called()

    def test_api_and_network_errors(self):
        errors = [HTTPError("url", code, "error", {}, None) for code in (401, 403, 404, 409, 429, 500)]
        errors.append(URLError("offline"))
        for error in errors:
            with self.subTest(error=error), patch.object(APP, "urlopen", side_effect=error):
                output = io.StringIO()
                with contextlib.redirect_stderr(output), contextlib.redirect_stdout(io.StringIO()) as stdout:
                    self.assertEqual(APP.main(["a/b"]), 1)
                self.assertTrue(output.getvalue())
                self.assertEqual(stdout.getvalue(), "")

    def test_empty_and_invalid_responses(self):
        for data in ([], [{"sha": "bad"}], {"message": "error"}):
            with patch.object(APP, "urlopen", return_value=response(data)):
                with self.assertRaises(ValueError):
                    APP.first("a/b")

    def test_token_and_untrusted_pagination(self):
        link = '<https://evil.com/steal>; rel="last"'
        with patch.dict(APP.os.environ, {"GH_TOKEN": "secret"}):
            with patch.object(APP, "urlopen", return_value=response([{"sha": SHA}], link)) as request:
                with self.assertRaises(ValueError):
                    APP.first("a/b")
        request.assert_called_once()
        self.assertEqual(request.call_args.args[0].get_header("Authorization"), "Bearer secret")


if __name__ == "__main__":
    unittest.main()
