"""a2 (review, math A): independent re-simulation of Example sound:constant (model Ex 4.9).
Truth T* = {0+0=0, (Sz)+0=Sz}, Dir(1/2,1/2) weights; competitor T' = {z+0=z}; root law of Q (0.5, 0.5-eps, eps/2, eps/2).
Only the root counts (n1 = #{0+0=0}, n2 = #{S-rooted}) matter:
  ln P_T'(D) - ln P^Dir_T*(D) = n1 ln .5 + n2 ln(.5-eps) - ln KT(n1, n2)   (the Q(t') factors cancel).
Accept q iff pi_n(T*) <= delta (prior 1/2 each).  Every n <= NMAX is checked.  Seeded; writes a2_example49.out."""
import math
import numpy as np
from scipy.special import gammaln

rng = np.random.default_rng(49)
out = []
def p(s):
    print(s); out.append(s)

NMAX = 400000
R = 300
delta = 0.01
thr_const = math.log((1 - delta) / delta)
n = np.arange(1, NMAX + 1)
dn = 0.5 * 0.02 * (1 / (math.e * math.pi)) / (n + 1)          # Thm 4.8 threshold, pi(T*) = 1/2, delta' = 0.02
thr_shrink = np.log((1 - dn) / dn)

def run(eps, w1):
    x = rng.random(NMAX) < w1                      # True: datum 0+0=0
    n1 = np.cumsum(x); n2 = n - n1
    lkt = gammaln(n1 + .5) + gammaln(n2 + .5) - 2 * gammaln(.5) - gammaln(n + 1)
    lr = n1 * math.log(.5) + n2 * math.log(.5 - eps) - lkt
    i1 = np.argmax(lr >= thr_const) if np.any(lr >= thr_const) else -1
    i3 = np.argmax(lr >= thr_shrink) if np.any(lr >= thr_shrink) else -1
    return i1, i3

for eps in (1e-5, 1e-6):
    w1 = 0.5 / (1 - eps)
    acc1 = []; acc3 = 0
    for _ in range(R):
        i1, i3 = run(eps, w1)
        acc1.append(i1); acc3 += (i3 >= 0)
    a1 = np.array(acc1)
    hit = a1 >= 0
    p(f"eps={eps:g}: B1 fixed w*, constant delta: P(accept by n<={NMAX}) = {hit.mean():.3f}; median first n = {np.median(a1[hit])+1:.0f}")
    p(f"eps={eps:g}: B3 fixed w*, shrinking delta_n: P(accept) = {acc3/R:.3f}")
    acc2 = 0
    for _ in range(R):
        w = rng.beta(.5, .5)
        i1, _ = run(eps, w)
        acc2 += (i1 >= 0)
    p(f"eps={eps:g}: B2 w* ~ Beta(1/2,1/2), constant delta: P(accept by n<={NMAX}) = {acc2/R:.3f} (bound 0.02)")

# where does the crossing window close?  max over n of 0.5 ln n + 0.5 ln(pi/2) - n eps
for eps in (1e-3, 1e-4, 1e-5, 1e-6):
    nstar = 1 / (2 * eps)
    p(f"eps={eps:g}: max_n [0.5 ln n + 0.5 ln(pi/2) - n eps] = {0.5*math.log(nstar)+0.5*math.log(math.pi/2)-0.5:.3f} vs ln 99 = {math.log(99):.3f}")

open(__file__.replace('.py', '.out'), 'w').write("\n".join(out) + "\n")
