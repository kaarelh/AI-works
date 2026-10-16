"""Referee A check: the Mars-pool posterior with the law-text prior removed (uniform prior over the five forms,
uniform prior on each form's element box), i.e. a presentation-free 'semantic' prior over the hand-picked model
families.  Input: the Occam factors C_F(delta) of notes.md §4.4 (c4 table A2), typed in below.  Deterministic;
writes ra3_semantic_prior.out.  Posterior share of F is 2^-C_F / sum_G 2^-C_G over the compatible forms."""
import os
HERE = os.path.dirname(os.path.abspath(__file__))
forms = ["circle", "eccentric", "equant", "vicarious", "ellipse"]
C = {  # delta (arcmin): Occam factors in bits, None = incompatible (notes §4.4 table)
    720: [20.93, 20.24, 21.20, 22.77, 21.18], 120: [None, 31.17, 31.70, 33.34, 31.63],
    60: [None, 36.34, 35.88, 37.93, 35.68], 30: [None, 45.38, 40.35, 42.83, 39.65],
    20: [None, None, 43.63, 45.77, 42.01], 12: [None, None, 49.49, 49.56, 45.01],
    9: [None, None, 57.34, 51.78, 46.81], 6: [None, None, None, 54.98, 49.21],
    4: [None, None, None, 58.56, 51.86], 3: [None, None, None, 61.53, 53.88],
    2: [None, None, None, 67.56, 57.41], 1.6: [None, None, None, 74.54, 59.93],
    1.3: [None, None, None, None, 63.81]}
lines = ["# uniform prior over forms; shares by delta", "%7s " % "delta'" + " ".join("%10s" % f for f in forms) + "   MAP   margin(bits)"]
for d, row in C.items():
    w = [2.0 ** (-c) if c is not None else 0.0 for c in row]
    s = sum(w)
    sh = [x / s for x in w]
    order = sorted([(c, f) for c, f in zip(row, forms) if c is not None])
    margin = order[1][0] - order[0][0] if len(order) > 1 else float("inf")
    lines.append("%7s " % d + " ".join("%10.3g" % x for x in sh) + "   %-9s %.2f" % (order[0][1], margin))
print("\n".join(lines))
open(os.path.join(HERE, "ra3_semantic_prior.out"), "w").write("\n".join(lines) + "\n")
