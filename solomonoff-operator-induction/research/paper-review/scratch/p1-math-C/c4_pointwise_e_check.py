"""p1-math-C check 4 (this reviewer's own code): the semimeasure-convention error e(x*) has the same pointwise
bound as e_norm(x*), contrary to ood.tex line 134 ("there is no pointwise bound on e(x*)").

Argument (re-derived for this review): given the finite labelling f of B, let M'(f) draw a hypothesis h from nu's
prior, run h on all points of B in parallel, and output the remaining point as soon as |B|-1 points of B have
halted with f's label.  M' outputs x only if h is correct on B\\{x}, and it does output x* whenever h is correct on
A=B\\{x*} and not correct at x* (wrong or undefined).  Its output law is a discrete semimeasure, lsc uniformly in f,
so P[M'(f)=x*] <= 2^{-K(x*|f)+c}, and e(x*) = (nu(f|_A)-nu(f))/nu(f|_A) <= 2^{L_nu(f)-K(x*|f)+c}.

This script checks the only non-standard step, P[M'(f)=x] >= nu(f|_{B\\x}) - nu(f) for all x and
sum_x P[M'(f)=x] <= nu(empty), by exact computation on random finite mixtures of partial functions with random
halting times (repeated labels and a non-binary label set included).  Seed 7; deterministic.
Usage: python3 -I c4_pointwise_e_check.py"""
import random
random.seed(7)
INF = float("inf")
worst_lower, worst_total, max_ratio = INF, -INF, 0.0
for trial in range(3000):
    nB = random.randint(1, 6)
    B = list(range(nB))
    Y = [0, 1, 2]
    f = {x: random.choice(Y) for x in B}
    hyps = []
    for _ in range(random.randint(1, 12)):
        pu, pw = random.random()*0.6, random.random()*0.4
        h = {}
        for x in B:
            r = random.random()
            if r < pu: h[x] = (None, INF)
            elif r < pu+pw: h[x] = (random.choice([y for y in Y if y != f[x]]), random.random())
            else: h[x] = (f[x], random.random())
        hyps.append((random.random(), h))
    tot = sum(w for w, _ in hyps)
    hyps = [(w/tot*random.uniform(0.5, 1.0), h) for w, h in hyps]   # sub-probability prior
    nu_empty = sum(w for w, _ in hyps)
    def nu(D): return sum(w for w, h in hyps if all(h[x][0] == y for x, y in D.items()))
    out = {x: 0.0 for x in B}
    for w, h in hyps:
        correct = sorted((h[x][1], x) for x in B if h[x][0] == f[x])
        if len(correct) >= nB - 1:
            first = [x for _, x in correct[:nB-1]]
            rest = [x for x in B if x not in first]
            out[rest[0]] += w
    nf = nu(f)
    for x in B:
        worst_lower = min(worst_lower, out[x] - (nu({z: f[z] for z in B if z != x}) - nf))
        nA = nu({z: f[z] for z in B if z != x})
        den = sum(nu({**{z: f[z] for z in B if z != x}, x: y}) for y in Y)
        if nA > 0 and den > 0:
            e = 1 - nf/nA; en = 1 - nf/den
            if en > 1e-12: max_ratio = max(max_ratio, e/en)
    worst_total = max(worst_total, sum(out.values()) - nu_empty)
print(f"3000 random finite mixtures, |B| in 1..6, |Y|=3")
print(f"min_x P[M'=x] - (nu(f|B\\x)-nu(f)) = {worst_lower:.3e}   (>= 0 expected)")
print(f"max sum_x P[M'=x] - nu(empty)     = {worst_total:.3e}   (<= 0 expected)")
print(f"max e(x*)/e_norm(x*) observed      = {max_ratio:.1f}   (the bound on e is not implied by the one on e_norm)")
