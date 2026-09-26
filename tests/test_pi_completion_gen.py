import importlib.machinery
import importlib.util
import pathlib
import unittest


def setUpModule():
    global gen
    p = pathlib.Path(__file__).parent.parent / "script" / "pi-completion-gen"
    spec = importlib.util.spec_from_loader(
        "pi_completion_gen",
        importlib.machinery.SourceFileLoader("pi_completion_gen", str(p)),
    )
    gen = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(gen)


MAIN_HELP = """pi - AI coding assistant

Usage:
  pi [options] [--] [@files...] [messages...]
  pi install <source> [-l]     Install extension source and add to settings
  pi auth <command>            Print credentials or check provider readiness
  pi <command> --help          Show help

Options:
  --print, -p                    Non-interactive mode
  --no-session                   Don't save session
  --thinking <level>             Set thinking level
"""

INSTALL_HELP = """Usage:
  pi install <source> [-l] [--approve|--no-approve]

Install a package and add it to settings.

Options:
  -l, --local       Install project-locally (.pi/settings.json)
  -a, --approve     Trust project-local files for this command
"""

AUTH_HELP = """Usage:
  pi auth print-api-key [--provider <provider>] [--model <model>]
  pi auth check [--json] [--no-refresh]

Auth commands require at least one of --provider or --model.
"""


class TestParseHelp(unittest.TestCase):
    def test_main_flags_subs_nested(self):
        flags, subs, nested = gen.parse_help(MAIN_HELP)
        self.assertIn("--print", flags)
        self.assertIn("-p", flags)
        self.assertIn("--thinking", flags)
        self.assertEqual(subs, ["install", "auth"])
        self.assertNotIn("auth", nested)  # nested comes from `pi auth --help`

    def test_nested_from_sub_help(self):
        _, _, nested = gen.parse_help(AUTH_HELP)
        self.assertEqual(nested.get("auth"), ["print-api-key", "check"])

    def test_no_usage_examples_leak_into_nested(self):
        _, _, nested = gen.parse_help(MAIN_HELP)
        self.assertNotIn("install", nested)  # from 'npm:@foo/bar' style tokens

    def test_usage_bracket_flags(self):
        self.assertEqual(gen.flags_from_usage(AUTH_HELP),
                         ["--provider", "--model", "--json", "--no-refresh"])

    def test_flags_from_options_block(self):
        flags, _, _ = gen.parse_help(INSTALL_HELP)
        self.assertIn("-l", flags)
        self.assertIn("--local", flags)
        self.assertIn("--approve", flags)

    def test_min_threshold_rejects_garbage(self):
        flags, subs, _ = gen.parse_help("garbage\n")
        self.assertLess(len(flags), gen.MIN_FLAGS)
        self.assertLess(len(subs), gen.MIN_SUBS)


if __name__ == "__main__":
    unittest.main()
