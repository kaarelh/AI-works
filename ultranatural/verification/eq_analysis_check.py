"""Referee: the two tables of Section 6.2 of equational.md recomputed from the saved profile
table results/eq_unary_cap12_L18.txt with the referee's own few lines (not eq_unary_analyze.py).

Usage: python3 eq_analysis_check.py [TABLE]
"""
import sys

path = sys.argv[1] if len(sys.argv) > 1 else "../results/eq_unary_cap12_L18.txt"
rows = []
for line in open(path):
    if line[0] in "#D":
        continue
    a, b, c, d = line.rstrip("\n").split("|")
    rows.append((tuple(map(int, a.split())), float(b), int(c), d.strip()))


def split(g, n, x):
    fit = [r for r in rows if all(r[0][i] == g(i) for i in range(n))]
    M = sum(r[1] for r in fit)
    if M == 0:
        return 0.0, None, None, None, None
    right = sum(r[1] for r in fit if r[0][x] == g(x)) / M
    wrong = sum(r[1] for r in fit if r[0][x] not in (-1, g(x))) / M
    dev = [r for r in fit if any(r[0][i] not in (-1, g(i)) for i in range(8))]
    least = min(dev, key=lambda r: r[2]) if dev else None
    return M, right, wrong, 1 - right - wrong, least


print(f"table: {path}")
print("successor after n values, far input 7:  n | weight of fitting | right | wrong | undetermined | a least deviating fitting set")
for n in range(4):
    M, r, w, u, least = split(lambda x: x + 1, n, 7)
    print(f"   {n} | {M:.4g} | {r:.5f} | {w:.2e} | {u:.2e} | {(str(least[2]) + ' ' + least[3]) if least else 'none'}")
T = {
    "identity": lambda x: x, "constant 1": lambda x: 1, "x+2": lambda x: x + 2, "predecessor": lambda x: max(x - 1, 0),
    "[x > 0]": lambda x: int(x > 0), "successor, but 0 at 0": lambda x: 0 if x == 0 else x + 1, "double": lambda x: 2 * x,
    "min(x+1, 2)": lambda x: min(x + 1, 2), "parity": lambda x: x % 2, "successor, but 0 at 3": lambda x: 0 if x == 3 else x + 1,
    "square": lambda x: x * x,
}
print("other targets after the values at 0, 1, 2, far input 7:  weight | right | wrong | undetermined | least set proving all of 0..7 right")
for name, g in T.items():
    M, r, w, u, _ = split(g, 3, 7)
    full = [q for q in rows if all(q[0][i] == g(i) for i in range(8))]
    best = min(full, key=lambda q: q[2]) if full else None
    cells = f"{M:.3g} | {r:.5f} | {w:.1e} | {u:.1e}" if M else "0 (no fitting set)"
    print(f"   {name:22s} | {cells} | {(str(best[2]) + ' ' + best[3]) if best else 'none'}")
s3 = split(lambda x: x + 1, 3, 7)[0]
e0 = split(T["successor, but 0 at 0"], 3, 7)[0]
print(f"ratio of fitting weights, successor / successor-but-0-at-0, after three values: {s3 / e0:.0f}")
print(f"with no data: share of the weight on sets that prove nothing about f(7): {sum(r[1] for r in rows if r[0][7] == -1) / sum(r[1] for r in rows):.4f}")
