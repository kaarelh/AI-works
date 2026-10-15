"""r8 (referee): Prop 5.3 (normalisation) and Example 6.4 (swap data) of the foundations notes.

(a) Prop 5.3, independently: for 300 seeded random laws of random PARTIAL functions on 3 inputs
    (labels {0,1}) and 300 random laws of random TOTAL functions, compute for every full-domain data
    set the normalised probability in all 6 reveal orders.  Expect: normalised >= semimeasure always;
    order dependence for partial laws; no order dependence for total laws (there normalised = raw).
    Also the notes' 2-input example rho1, recomputed.
(b) Example 6.4: for the swap data D = {(x1,x2),(x2,x1)} with x1 != x2 in {0,1}^n, the shared-
    randomness machine law F(x) = x XOR r (r uniform in {0,1}^n) gives nu(D) = 2^-n exactly, for all
    pairs, n = 2..6.  Hence -log2 M_F(D) <= n + K(n) + O(1): SFI pays about n bits here, which is also
    what any history-aware predictor pays on the first label (it sees only x1).  So Example 6.4
    separates the bound K(D|dom D) from the truth, but it is not a separation between SFI and
    history-aware prediction.

Seed 20261011.  Output: r8_normalisation_and_swap_output.txt
"""
import itertools
import random
from fractions import Fraction as Fr

BOT = None


def cont(law, D):
    return sum(p for pt, p in law.items() if all(pt[x] == y for x, y in D))


def probs(law, order, labels):
    D = []
    semi = Fr(1)
    norm = Fr(1)
    for x in order:
        y = labels[x]
        num = cont(law, D + [(x, y)])
        den = cont(law, D)
        nrm = sum(cont(law, D + [(x, yy)]) for yy in (0, 1))
        if den == 0 or nrm == 0:
            return Fr(0), Fr(0)
        semi *= num / den
        norm *= num / nrm
        D.append((x, y))
    return semi, norm


def random_law(rng, partial):
    vals = (BOT, 0, 1) if partial else (0, 1)
    pts = list(itertools.product(vals, repeat=3))
    w = [rng.randrange(1, 20) for _ in pts]
    tot = sum(w)
    return {pt: Fr(wi, tot) for pt, wi in zip(pts, w)}


def part_a(rng):
    res = {}
    for partial in (True, False):
        dep = 0
        below = 0
        for _ in range(300):
            law = random_law(rng, partial)
            law_dep = False
            for lab in itertools.product((0, 1), repeat=3):
                labels = dict(enumerate(lab))
                ns = []
                for order in itertools.permutations(range(3)):
                    s, nrm = probs(law, order, labels)
                    below += nrm < s
                    ns.append(nrm)
                law_dep |= len(set(ns)) > 1
            dep += law_dep
        res[partial] = (dep, below)
    rho1 = {(0, 0): Fr(1, 4), (0, BOT): Fr(1, 4), (1, 1): Fr(1, 4), (BOT, BOT): Fr(1, 4)}
    ex = [probs(rho1, o, {0: 0, 1: 0}) for o in ((0, 1), (1, 0))]
    return res, ex


def part_b():
    out = []
    for n in range(2, 7):
        N = 2 ** n
        ok = True
        for x1, x2 in itertools.permutations(range(N), 2):
            cnt = sum(1 for r in range(N) if (x1 ^ r) == x2 and (x2 ^ r) == x1)
            ok &= Fr(cnt, N) == Fr(1, N)
        out.append((n, ok))
    return out


def main():
    rng = random.Random(20261011)
    lines = []
    res, ex = part_a(rng)
    lines.append(f"(a) partial laws: {res[True][0]}/300 order-dependent normalised loss; "
                 f"cases normalised < semimeasure: {res[True][1]}")
    lines.append(f"(a) total laws:   {res[False][0]}/300 order-dependent normalised loss; "
                 f"cases normalised < semimeasure: {res[False][1]}")
    lines.append(f"(a) rho1 of Prop 5.3: order (a,b): semi={ex[0][0]}, norm={ex[0][1]}; "
                 f"order (b,a): semi={ex[1][0]}, norm={ex[1][1]}")
    for n, ok in part_b():
        lines.append(f"(b) n={n}: XOR law gives the swap data probability exactly 2^-n for all ordered pairs: {ok}")
    out = "\n".join(lines)
    print(out)
    with open(__file__.replace(".py", "_output.txt"), "w") as f:
        f.write(out + "\n")


if __name__ == "__main__":
    main()
