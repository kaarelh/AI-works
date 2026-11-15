"""Referee's comparison of a profile table written by verification/eq_brute.c with one written by
code/eq_unary.c, and the referee's own computation of the beliefs for a target.

Usage: python3 eq_compare_tables.py BRUTE.txt [BRUTE2.txt ...] -- EQ_UNARY.txt
       (several BRUTE files are added up: the parts of a run split over processes)

The two programs print one line per profile "p0 .. p7 | weight | ...".  eq_brute also prints the
number of lists of each size, from which the weight sum of 6^-(size+1) is recomputed here exactly
(as a fraction) and compared with the 12 digits that eq_unary prints.
"""
import sys
from collections import defaultdict
from fractions import Fraction


def read(path, brute):
    rows, head = {}, []
    for line in open(path):
        if line.startswith("#"):
            head.append(line.strip())
            continue
        if line.startswith("D ") or line.startswith("T "):
            if line.startswith("T ") and brute:
                head.append(line.strip())
            continue
        parts = line.rstrip("\n").split("|")
        prof = tuple(int(v) for v in parts[0].split())
        if brute:
            counts = [int(v) for v in parts[5].split()]
            rows[prof] = (counts, int(parts[3]))
        else:
            rows[prof] = (float(parts[1]), int(parts[2]))
    return rows, head


def beliefs(rows, g, n, x):
    """weight of the lists that fit g on 0..n-1, and the split right / wrong / undetermined at x"""
    fit = {p: w for p, (w, _) in rows.items() if all(p[i] == g(i) for i in range(n))}
    M = sum(fit.values())
    right = sum(w for p, w in fit.items() if p[x] == g(x))
    wrong = sum(w for p, w in fit.items() if p[x] not in (-1, g(x)))
    return M, right / M, wrong / M, 1 - (right + wrong) / M


if __name__ == "__main__":
    k = sys.argv.index("--")
    acc = {}
    nlists = 0
    for path in sys.argv[1:k]:
        rows, head = read(path, True)
        for h in head:
            print(h)
        for p, (counts, ms) in rows.items():
            if p not in acc:
                acc[p] = [[0] * len(counts), 10 ** 9]
            acc[p][0] = [a + b for a, b in zip(acc[p][0], counts)]
            acc[p][1] = min(acc[p][1], ms)
            nlists += sum(counts)
    exact = {p: sum(Fraction(c, 6 ** (s + 1)) for s, c in enumerate(counts)) for p, (counts, _) in acc.items()}
    brute = {p: (float(exact[p]), acc[p][1]) for p in acc}
    print(f"brute: {nlists} consistent lists in all; exact weight of the consistent lists = {float(sum(exact.values())):.12g}")
    ref, head = read(sys.argv[k + 1], False)
    for h in head:
        print(h)
    print(f"profiles: brute {len(brute)}, eq_unary {len(ref)}")
    print(f"weight of consistent lists: brute {sum(w for w, _ in brute.values()):.12g}, eq_unary {sum(w for w, _ in ref.values()):.12g}")
    worst, bad = 0.0, []
    for p in sorted(set(brute) | set(ref)):
        a, b = brute.get(p, (0.0, None)), ref.get(p, (0.0, None))
        rel = abs(a[0] - b[0]) / max(a[0], b[0])
        worst = max(worst, rel)
        if float(f"{a[0]:.12g}") != b[0] or a[1] != b[1]:      # eq_unary prints 12 significant digits
            bad.append((p, a, b))
    print(f"largest relative difference of a profile weight: {worst:.3g}; profiles whose weight (to the 12 digits printed by eq_unary) or least size differs: {len(bad)}")
    for p, a, b in bad[:40]:
        print("   ", p, "brute", a, "eq_unary", b)
    succ = lambda x: x + 1
    print("successor, far input 7:   n  weight of fitting  right  wrong  undetermined")
    for name, rows in (("brute", brute), ("eq_unary", ref)):
        for n in range(4):
            M, r, w, u = beliefs(rows, succ, n, 7)
            print(f"   {name:9s} n={n}  {M:.10e}  {r:.8f}  {w:.6e}  {u:.8f}")
