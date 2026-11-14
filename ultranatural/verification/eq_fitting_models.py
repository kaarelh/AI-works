"""Referee: of the sets that `eq_unary 12 18` counts as fitting a target at 0, 1, 2, how many
have the target itself as a standard model?  Such a set is consistent outright (no proof bound
involved) and every value the bounded prover derived from it is true of the target.

Reads the dump of `eq_unary 12 18 dump` (lines starting with D).  Own evaluator.

Usage: python3 eq_fitting_models.py DUMP.txt
"""
import sys

TARGETS = {
    "successor": lambda x: x + 1,
    "identity": lambda x: x,
    "x+2": lambda x: x + 2,
    "constant 1": lambda x: 1,
    "predecessor": lambda x: max(x - 1, 0),
    "double": lambda x: 2 * x,
    "[x > 0]": lambda x: int(x > 0),
    "min(x+1, 2)": lambda x: min(x + 1, 2),
    "successor, but 0 at 0": lambda x: 0 if x == 0 else x + 1,
}
R = 40


def run(word, v, g):
    for ch in reversed(word):
        v = v + 1 if ch == "S" else g(v)
    return v


def true_of(ident, g):
    lhs, rhs = ident.split("=")
    (u, a), (v, b) = (lhs[:-1], lhs[-1]), (rhs[:-1], rhs[-1])
    xs = range(R) if "x" in (a, b) else [0]
    ys = range(R) if "y" in (a, b) else [0]
    for x in xs:
        for y in ys:
            val = {"0": 0, "x": x, "y": y}
            if run(u, val[a], g) != run(v, val[b], g):
                return False
    return True


sets = []
for line in open(sys.argv[1]):
    if line.startswith("D "):
        head, prof, ids = line[2:].split("|")
        sets.append((float(head.split()[0]), tuple(int(t) for t in prof.split()), ids.split()))
print(f"{len(sets)} sets determine f at 0, 1, 2 within the bound")
for name, g in TARGETS.items():
    fit = [s for s in sets if all(s[1][i] == g(i) for i in range(3))]
    M = sum(s[0] for s in fit)
    good = [s for s in fit if all(true_of(e, g) for e in s[2])]
    bad = [s for s in fit if s not in good]
    wrong = [s for s in bad if any(s[1][i] not in (-1, g(i)) for i in range(8))]
    print(f"{name:22s}: {len(fit):5d} fitting sets, weight {M:.4e}; with the target as a standard model: {len(good):5d} "
          f"(weight share {sum(s[0] for s in good) / M:.6f}); others: {len(bad)}, of which {len(wrong)} prove a wrong value on 0..7")
    for s in bad[:3]:
        print(f"        e.g. {' '.join(s[2])}  proves {list(s[1])}")
