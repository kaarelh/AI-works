"""Referee: Theorem 3(3) of equational.md on further targets g = c + (sum of the arguments in I).
tau(m) is computed by the shortcut of eq_test_radius.py and compared with the bound of the proof,
max(c,1)(m-1) + 1, and with the stated bound max(c,1) m.

Usage: python3 eq_theorem3_general.py
"""
import sys

sys.dont_write_bytecode = True
from eq_test_radius import tau_shortcut_binary, tau_shortcut_unary

print("binary f, 3 variables searched in 0..5, m = 2..6:   tau(m) / bound of the proof / stated bound")
for name, c, g in (("x + y + 2", 2, lambda a, b: a + b + 2), ("y + 3", 3, lambda a, b: 0 * a + b + 3),
                   ("constant 2", 2, lambda a, b: 0 * a + 0 * b + 2), ("constant 0", 0, lambda a, b: 0 * a + 0 * b)):
    tau, _ = tau_shortcut_binary(g, 3, 6, 5)
    k = max(c, 1)
    print(f"   {name:12s} " + "  ".join(f"{tau[m]}/{k * (m - 1) + 1}/{k * m}" for m in range(2, 7)),
          "  OK" if all(tau[m] <= k * (m - 1) + 1 for m in range(2, 7)) else "  VIOLATION")
print("unary f, 2 variables searched in 0..12, m = 2..8")
for name, c, g in (("x + 3", 3, lambda a: a + 3), ("constant 4", 4, lambda a: 4), ("constant 0", 0, lambda a: 0)):
    tau, _ = tau_shortcut_unary(g, 8, 12)
    k = max(c, 1)
    print(f"   {name:12s} " + "  ".join(f"{tau[m]}/{k * (m - 1) + 1}/{k * m}" for m in range(2, 9)),
          "  OK" if all(tau[m] <= k * (m - 1) + 1 for m in range(2, 9)) else "  VIOLATION")
