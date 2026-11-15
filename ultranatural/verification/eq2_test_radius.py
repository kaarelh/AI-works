"""Referee, second pass: the unary table of Section 6.1 with exact integers, for all m <= 8 and
two search ranges (the first pass ran the second range only to m = 7 and printed ">1e9" for
squaring at m = 7, 8).  Also the test radius of doubling against 2^(m-2) + 1.

Usage: python3 eq2_test_radius.py          (about 3 minutes)
"""
import sys

sys.dont_write_bytecode = True
from eq_test_radius import tau_shortcut_unary  # noqa: E402

UN = {
    "successor": lambda a: a + 1,
    "identity": lambda a: a,
    "x+2": lambda a: a + 2,
    "predecessor": lambda a: max(a - 1, 0),
    "parity": lambda a: a % 2,
    "min(x+1, 3)": lambda a: min(a + 1, 3),
    "successor, but 0 at 4": lambda a: 0 if a == 4 else a + 1,
    "double": lambda a: 2 * a,
    "square": lambda a: a * a,
}
res = {}
for R in (12, 16):
    print(f"unary f, 2 variables searched in 0..{R}: tau(m) for m = 2..8 (exact integers)")
    for name, g in UN.items():
        tau, wit = tau_shortcut_unary(g, 8, R)
        res[(name, R)] = tau[2:9]
        print(f"   {name:22s} " + " ".join(str(v) for v in tau[2:9]))
        sys.stdout.flush()
same = all(res[(name, 12)] == res[(name, 16)] for name in UN)
print(f"the two ranges give the same table: {same}")
print(f"square: 2^(2^(m-2)) + 1 for m = 2..8: {res[('square', 12)] == [2 ** (2 ** (m - 2)) + 1 for m in range(2, 9)]}")
print(f"double: 2^(m-2) + 1 for m = 2..8: {res[('double', 12)] == [2 ** (m - 2) + 1 for m in range(2, 9)]}")
