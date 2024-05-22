#!/usr/bin/env python3
"""
Unittests for lib directory
"""
import unittest
from run_simulation import run_simulation

class TestClass(unittest.TestCase):
    """
    Test class
    """

    def test_run_simulation(self):
        """
        check if run_simulation works
        """
        run_simulation("./defines.sv", [], "Test defines")



if __name__ == "__main__":
    unittest.main()
