r"""c1 (reviewer p1-math-C): the 'no pointwise bound on e(x*)' sentence of ood.tex (after prop:ood:labelled).

Claim checked.  ood.tex says: "The mass undefined at x* is not lsc, so there is no pointwise bound on e(x*)".
Counter-argument (written out in review-p1-math-C.md, issue C-01): the semimeasure-convention error
    e(x*) = (nu(f|_A) - nu(f)) / nu(f|_A)
is bounded pointwise by 2^{L_nu(f) - K(x*|f) + c}, by the sampler M'(f):
    draw a hypothesis h from nu's prior (a program for W, a tape for M_F); run h on all of B in parallel;
    as soon as |B|-1 points of B have halted WITH THE CORRECT LABEL, output the remaining point.
Every hypothesis that is correct on A = B \ {x*} and NOT correct at x* (wrong OR undefined there) makes M'
output x*.  So P[M' outputs x*] >= nu(f|_A) - nu(f).  M' is a fixed probabilistic machine with input f, its
output law is a discrete semimeasure, lsc uniformly in f, so the conditional coding theorem gives
P[M' outputs x*] <= 2^{-K(x*|f)+c}.  Hence e(x*) <= 2^{-K(x*|f)+c} / nu(f|_A) <= 2^{L_nu(f)-K(x*|f)+c}.

This script checks the combinatorial part on random FINITE mixtures (lsc / coding theorem cannot be tested
numerically): for every x in B, P[M' outputs x] >= nu(f|_{B\x}) - nu(f), and sum_x P[M' outputs x] <= nu(empty).
It also reports how much larger e(x*) can be than e_norm(x*) (so the bound on e is not implied by the one on
e_norm).  Hypotheses are partial functions on B with random halting times; 'shared-randomness' hypotheses are
represented by expanding a random tape into its finitely many outcomes (each a partial function with a weight).
Seeded; deterministic output.
"""
import itertools
import random

random.seed(20261012)

INF = float("inf")


def random_hypothesis(B, f, p_undef, p_wrong):
    """A partial function on B with halting times: dict x -> (label or None, time)."""
    h = {}
    for x in B:
        r = random.random()
        if r < p_undef:
            h[x] = (None, INF)
        elif r < p_undef + p_wrong:
            h[x] = (1 - f[x], random.random())
        else:
            h[x] = (f[x], random.random())
    return h


def mprime_output(h, B, f):
    """Output of M' on hypothesis h: the point left after |B|-1 correct halts, or None."""
    events = sorted((t, x) for x, (y, t) in h.items() if y is not None and t < INF)
    correct = set()
    for t, x in events:
        if h[x][0] == f[x]:
            correct.add(x)
            if len(correct) == len(B) - 1:
                rest = [z for z in B if z not in correct]
                return rest[0]
    return None


def consistent(h, D):
    return all(h[x][0] == y for x, y in D.items())


def run_trial(nB, nh):
    B = list(range(nB))
    f = {x: random.randint(0, 1) for x in B}
    hyps = []
    # deterministic partial programs with Kraft-like weights
    for _ in range(nh):
        w = 2.0 ** (-random.randint(1, 12))
        hyps.append((w, random_hypothesis(B, f, p_undef=random.choice([0.0, 0.1, 0.4]),
                                          p_wrong=random.choice([0.0, 0.05, 0.3]))))
    # 'shared randomness' machines: one weight split over several tape outcomes
    for _ in range(nh // 3):
        w = 2.0 ** (-random.randint(1, 10))
        k = random.randint(2, 6)
        for _ in range(k):
            hyps.append((w / k, random_hypothesis(B, f, 0.2, 0.2)))
    total = sum(w for w, _ in hyps)
    hyps = [(w / total * 0.9, h) for w, h in hyps]  # nu(empty) = 0.9 <= 1

    nu = lambda D: sum(w for w, h in hyps if consistent(h, D))
    nu_empty = sum(w for w, _ in hyps)
    nu_f = nu(f)
    out = {x: 0.0 for x in B}
    for w, h in hyps:
        o = mprime_output(h, B, f)
        if o is not None:
            out[o] += w
    worst_slack = INF
    max_ratio = 0.0
    for x in B:
        A = {z: f[z] for z in B if z != x}
        nuA = nu(A)
        lhs = nuA - nu_f  # mass correct on A, not correct at x (wrong or undefined)
        worst_slack = min(worst_slack, out[x] - lhs)
        if nuA > 0:
            e = lhs / nuA
            wrong = sum(nu({**A, x: y}) for y in (0, 1) if y != f[x])
            defined = sum(nu({**A, x: y}) for y in (0, 1))
            e_norm = wrong / defined if defined > 0 else 1.0
            if e_norm > 0:
                max_ratio = max(max_ratio, e / e_norm)
    return worst_slack, sum(out.values()) - nu_empty, max_ratio


def main():
    lines = []
    trials = 0
    min_slack = INF
    max_sum_excess = -INF
    max_ratio = 0.0
    for nB in (2, 3, 4, 5, 6):
        for _ in range(400):
            s, ex, r = run_trial(nB, nh=30)
            trials += 1
            min_slack = min(min_slack, s)
            max_sum_excess = max(max_sum_excess, ex)
            max_ratio = max(max_ratio, r)
    lines.append(f"trials: {trials} random finite mixtures, |B| in 2..6")
    lines.append(f"min over trials and x of P[M' outputs x] - (nu(f|B\\x) - nu(f)): {min_slack:.3e}  (>= 0 expected)")
    lines.append(f"max over trials of sum_x P[M' outputs x] - nu(empty): {max_sum_excess:.3e}  (<= 0 expected)")
    lines.append(f"max observed e(x*)/e_norm(x*): {max_ratio:.1f}  (undefined mass can dominate)")
    ok = min_slack >= -1e-12 and max_sum_excess <= 1e-12
    lines.append("RESULT: " + ("combinatorial step of the pointwise bound on e(x*) holds in all trials" if ok else "FAILED"))
    txt = "\n".join(lines)
    print(txt)
    with open(__file__.replace(".py", ".out.txt"), "w") as fh:
        fh.write(txt + "\n")


if __name__ == "__main__":
    main()
