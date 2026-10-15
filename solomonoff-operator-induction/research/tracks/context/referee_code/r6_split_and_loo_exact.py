"""r6 (referee): exact (not Monte Carlo) checks of Prop 2.9 (random split identity) and Prop 2.10
(leave-one-out bound) on random laws of random partial functions, and of Thm 2.7's per-sequence bound.

A law nu = mixture of (i) deterministic partial functions (each point undefined w.p. 0.25) and
(ii) product hypotheses with a sub-probability vector per point (mass can leak), on N = 6 points, Y = {0,1,2}.
For 40 random laws and random target labellings f:
  * E_{pi,k}[ -log2 nu(f(x_pi(k)) | x_pi(k), D_{pi,k-1}) ] over ALL 720 orders and all k equals
    (-log2 nu(f)/nu(empty))/N  (Prop 2.9);
  * (1/N) sum_x e_LOO(x) <= (nu(empty) - nu(f)) / (N nu(f))  (Prop 2.10);
  * the semimeasure-convention errors along any order satisfy sum_k -log2(1-e_k) = -log2(nu(f)/nu(empty))
    and sum_k e_k <= ln2 * that (Thm 2.7).
Seeded (seed 6).
"""
import itertools
import math
import numpy as np

rng = np.random.default_rng(6)
N, Ylab = 6, 3
out = []
max_id_err = 0.0
loo_ok = True
t27_ok = True
loo_ratio = []
for trial in range(40):
    nd, npr = 30, 6
    det = rng.integers(0, Ylab, size=(nd, N))
    det[rng.random((nd, N)) < 0.25] = -1
    wd = rng.random(nd)
    prod = rng.dirichlet(np.ones(Ylab + 1), size=(npr, N))[:, :, :Ylab]  # last coordinate = leaked mass
    wp = rng.random(npr)
    Z = wd.sum() + wp.sum()
    wd, wp = wd / Z * 0.95, wp / Z * 0.95  # nu(empty) = 0.95
    f = rng.integers(0, Ylab, size=N)

    def nu(D):
        tot = 0.0
        for h in range(nd):
            if all(det[h, x] == y for x, y in D):
                tot += wd[h]
        for h in range(npr):
            p = wp[h]
            for x, y in D:
                p *= prod[h, x, y]
            tot += p
        return tot

    cache = {}

    def nuS(S):
        key = tuple(sorted(S))
        if key not in cache:
            cache[key] = nu([(x, int(f[x])) for x in key])
        return cache[key]

    nfull = nuS(range(N))
    n0 = nuS([])
    if nfull <= 0:
        continue
    total = -math.log2(nfull / n0)
    acc = 0.0
    cnt = 0
    for perm in itertools.permutations(range(N)):
        S = []
        sl = 0.0
        se = 0.0
        for x in perm:
            p = nuS(S + [x]) / nuS(S)
            acc += -math.log2(p)
            sl += -math.log2(p)
            se += 1 - p
            cnt += 1
            S.append(x)
        t27_ok &= abs(sl - total) < 1e-9 and se <= math.log(2) * total + 1e-12
    max_id_err = max(max_id_err, abs(acc / cnt - total / N))
    eloo = [1 - nfull / nuS([z for z in range(N) if z != x]) for x in range(N)]
    lhs = sum(eloo) / N
    rhs = (n0 - nfull) / (N * nfull)
    loo_ok &= lhs <= rhs + 1e-12
    loo_ratio.append(lhs / rhs)
out.append(f"Prop 2.9: max |E_(pi,k) loss - total/N| over 40 laws (all 720 orders, all k): {max_id_err:.2e}")
out.append(f"Prop 2.10: LOO average <= (nu(empty)-nu(f))/(N nu(f)) in all trials: {loo_ok}; "
           f"ratio lhs/rhs in [{min(loo_ratio):.3f}, {max(loo_ratio):.3f}]")
out.append(f"Thm 2.7: per-order identity and sum e_k <= ln2 * total on every order: {t27_ok}")
txt = "\n".join(out)
print(txt)
with open(__file__.replace(".py", "_output.txt"), "w") as fh:
    fh.write(txt + "\n")
