import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "script"))
import opencode_usage


class FormatZenTest(unittest.TestCase):
    def test_console_unit_is_microcents_per_dollar(self):
        # opencode console: 100,000,000 microcents = $1, so Go's $10/month is 1e9.
        self.assertEqual(opencode_usage.MICROCENTS_PER_DOLLAR, 100_000_000)

    def test_microcents_to_dollars(self):
        self.assertEqual(opencode_usage.format_zen("100000000"), "$1.00")
        self.assertEqual(opencode_usage.format_zen("1000000000"), "$10.00")
        self.assertEqual(opencode_usage.format_zen("249027531"), "$2.49")

    def test_missing_balance(self):
        self.assertEqual(opencode_usage.format_zen(None), "$0.00")
        self.assertEqual(opencode_usage.format_zen("0"), "$0.00")


if __name__ == "__main__":
    unittest.main()
