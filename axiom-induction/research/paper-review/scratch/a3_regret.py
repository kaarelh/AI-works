"""a3 (review, math A): Lemma sound:regret (model Lemma 4.6), checked independently.
R(n,K) := min over count vectors c (sum n) of DirMoment_alpha(c) / prod (c_k/n)^{c_k}.
(b) alpha_k <= 1: R >= Gamma(A)/(e (K-1)! prod Gamma(alpha_k)) (n+1)^{-(K-1)}
(d) symmetric alpha: R <= Gamma(K a)Gamma(a+n)/(Gamma(a)Gamma(K a+n)).
(a) P^Dir(x^n) >= R(n,K) P_{T,w}(x^n), checked exactly on random overlapping components (K=2) by brute force.
Seeded; writes a3_regret.out."""
import itertools, math
import numpy as np
from scipy.special import gammaln

out = []
def p(s):
    print(s); out.append(s)

def lnmom(c, al):
    c = np.asarray(c, float); al = np.asarray(al, float)
    return gammaln(al.sum()) - gammaln(al.sum() + c.sum()) + np.sum(gammaln(al + c) - gammaln(al))

def lnR(n, al):
    K = len(al); best = math.inf
    for c in itertools.product(range(n + 1), repeat=K - 1):
        if sum(c) > n: continue
        cc = list(c) + [n - sum(c)]
        ml = sum(ci * math.log(ci / n) for ci in cc if ci > 0)
        best = min(best, lnmom(cc, al) - ml)
    return best

worst_b = -math.inf; worst_d = -math.inf
for al in ([.3, .3], [.5, .5], [1, 1], [.5, .2], [.5, .5, .5], [1, 1, 1], [.3, .7, 1.0], [.5]*4):
    K = len(al); A = sum(al)
    for n in (1, 2, 5, 10, 30, 80 if K <= 3 else 20):
        r = lnR(n, al)
        lb = gammaln(A) - 1 - math.lgamma(K) - sum(gammaln(a) for a in al) - (K - 1) * math.log(n + 1)
        worst_b = max(worst_b, lb - r)
        if len(set(al)) == 1:
            a = al[0]
            ub = gammaln(K * a) + gammaln(a + n) - gammaln(a) - gammaln(K * a + n)
            worst_d = max(worst_d, r - ub)
p(f"(b): max over cases of [lower bound - ln R] = {worst_b:.4f}  (must be <= 0)")
p(f"(d): max over cases of [ln R - upper bound] = {worst_d:.4f}  (must be <= 0)")

# slopes of exact ln R at alpha = 1/2 (K = 2, 3) and alpha = 0.3 (K = 2)
for al in ([.5, .5], [.3, .3], [1, 1]):
    ns = [64, 256, 1024]
    vals = [lnR(n, al) for n in ns]
    s = np.polyfit(np.log(ns), vals, 1)[0]
    p(f"alpha={al}: ln R at n={ns}: {[round(v,3) for v in vals]}; slope {s:.3f} vs -(K-1)max(1/2,alpha) = {-(len(al)-1)*max(.5, al[0])}")

# (a) brute force on random overlapping components, K = 2, alphabet 3, n <= 8
rng = np.random.default_rng(46)
worst_a = -math.inf
for trial in range(200):
    q = rng.dirichlet(np.ones(3), size=2)
    al = [rng.choice([.3, .5, 1.0]), rng.choice([.3, .5, 1.0])]
    n = int(rng.integers(1, 9))
    x = rng.integers(0, 3, size=n)
    # exact Dirichlet marginal by expanding over labellings
    lp = []
    for lab in itertools.product(range(2), repeat=n):
        c = [lab.count(0), lab.count(1)]
        lp.append(lnmom(c, al) + sum(math.log(q[l][xi]) for l, xi in zip(lab, x)))
    lpd = np.logaddexp.reduce(lp)
    r = lnR(n, al)
    for w in np.linspace(0, 1, 21):
        pw = sum(math.log(w * q[0][xi] + (1 - w) * q[1][xi]) if (w * q[0][xi] + (1 - w) * q[1][xi]) > 0 else -math.inf for xi in x)
        worst_a = max(worst_a, r + pw - lpd)
p(f"(a): max over 200 random cases x 21 weight vectors of [ln R + ln P_w - ln P^Dir] = {worst_a:.2e}  (must be <= 0)")

open(__file__.replace('.py', '.out'), 'w').write("\n".join(out) + "\n")
