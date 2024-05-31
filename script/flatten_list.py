#!/usr/bin/env python
"""
This module will flatten a give list
"""
import unittest


def flatten_list(thing: list[any]) -> list[any]:
    """
    Args:
        thing: list of lists

    Returns:
    Flattened list
    """
    out = []
    for item in thing:
        if isinstance(item, list):
            # print('This is a list', item)
            for it in item:
                out.append(it)
        else:
            # print('This is not a list', item)
            out.append(item)
    flat = []
    for item in out:
        if isinstance(item, list):
            flat.extend(flatten_list(item))
            # print(item)
        else:
            flat.append(item)
    return flat


class TestFlattenList(unittest.TestCase):
    """
    Tests for flatten_list
    """

    def test_flatten_list(self):
        """
        Test flatten_list
        """
        a = [1, 2, 3, ["a", "b", "c"], ["X", ["XA", ["XB"]]], 5, 6, ["D"]]
        b = [1, 2, 3, "a", "b", "c", "X", "XA", "XB", 5, 6, "D"]
        flat_a = flatten_list(a)
        self.assertEqual(b, flat_a)


if __name__ == "__main__":
    unittest.main()
