"""Probability estimates of A.md, checked independently.
(a) Lemma 4.3(a,b): E Q = M beta_n and P[Q <= M beta_n - u] <= exp(-u^2/(2n)) (Monte Carlo, fair labels).
(b) Corollary 4.6: E Q_eta >= v0 M beta_n and P[Q_eta <= E Q_eta - u] <= exp(-u^2/(32 n)) for a heteroscedastic law.
(c) Lemma 6.4(b): exact P(no atom carries both labels) = E[2^{S-n}] (S = #distinct inputs) by an occupancy DP,
    against exp(-n2 mu1/(4M)) + exp(-mu1^2/(2 n1)), and the simplified form exp(-0.039 n(n-1)/M)+exp(-0.19 n1).
(d) Proposition 6.1: Q = n deterministically without replacement (fair labels).
"""
import math
import numpy as np
import mpmath as mp

rng = np.random.default_rng(12345)

def beta_n(n, M):
    mp.mp.dps = 30
    p = mp.mpf(1) / M
    return float(sum(mp.binomial(n, k) * p ** k * (1 - p) ** (n - k) / k for k in range(1, min(n, 150) + 1)))

print("(a) Q tail, fair labels")
for d, lam, reps in [(6, 1.0, 200000), (8, 1.0, 100000), (10, 1.5, 40000)]:
    M = 2 ** d; n = int(lam * M)
    x = rng.integers(0, M, size=(reps, n)); y = rng.choice([-1.0, 1.0], size=(reps, n))
    off = (np.arange(reps) * M)[:, None]
    k = np.bincount((x + off).ravel(), minlength=reps * M).reshape(reps, M)
    S = np.bincount((x + off).ravel(), weights=y.ravel(), minlength=reps * M).reshape(reps, M)
    with np.errstate(invalid="ignore", divide="ignore"):
        Q = np.where(k > 0, (S / np.maximum(k, 1)) ** 2, 0.0).sum(1)
    bn = beta_n(n, M)
    print(f"  d={d} n={n}: mean Q={Q.mean():.3f} vs M beta_n={M*bn:.3f} (MC s.e. {Q.std()/math.sqrt(reps):.3f})")
    for u in [0.5, 1.0, 1.5, 2.0, 3.0]:
        uu = u * math.sqrt(n)
        emp = float(np.mean(Q <= M * bn - uu)); bnd = math.exp(-uu ** 2 / (2 * n))
        print(f"    u={u:.1f} sqrt(n): empirical {emp:.2e} <= bound {bnd:.2e}: {emp <= bnd}")

print("(b) Q_eta, heteroscedastic +-1 labels, eta(x) in [-1/2,1/2], V = 1-eta^2 >= v0 = 3/4")
d = 8; M = 2 ** d; n = M; reps = 100000
eta = rng.uniform(-0.5, 0.5, size=M); v0 = 0.75
x = rng.integers(0, M, size=(reps, n))
y = np.where(rng.uniform(size=(reps, n)) < (1 + eta[x]) / 2, 1.0, -1.0)
off = (np.arange(reps) * M)[:, None]
k = np.bincount((x + off).ravel(), minlength=reps * M).reshape(reps, M)
S = np.bincount((x + off).ravel(), weights=y.ravel(), minlength=reps * M).reshape(reps, M)
Qe = np.where(k > 0, (S / np.maximum(k, 1) - eta[None, :]) ** 2, 0.0).sum(1)
bn = beta_n(n, M)
print(f"  mean Q_eta={Qe.mean():.3f} >= v0 M beta_n={v0*M*bn:.3f}: {Qe.mean() >= v0*M*bn}")
for u in [0.5, 1.0, 2.0]:
    uu = u * math.sqrt(n)
    emp = float(np.mean(Qe <= Qe.mean() - uu)); bnd = math.exp(-uu ** 2 / (32 * n))
    print(f"    u={u:.1f} sqrt(n): empirical {emp:.2e} <= McDiarmid {bnd:.2e}: {emp <= bnd}")

print("(c) Lemma 6.4(b): exact P(no conflict) = E[2^{S-n}] via occupancy DP")
def p_noconf(M, n):
    mp.mp.dps = 50
    # dist of S after i draws
    dist = {0: mp.mpf(1)}
    for i in range(n):
        new = {}
        for j, pr in dist.items():
            new[j] = new.get(j, 0) + pr * mp.mpf(j) / M
            new[j + 1] = new.get(j + 1, 0) + pr * mp.mpf(M - j) / M
        dist = new
    return sum(pr * mp.mpf(2) ** (j - n) for j, pr in dist.items())
prev = None
for M, n in [(256, 2), (256, 16), (256, 32), (256, 256), (1024, 64), (1024, 256), (1024, 1024), (4096, 128),
             (4096, 409), (4096, 4096), (4096, 8192)]:
    ex = p_noconf(M, n)
    n1 = n // 2; n2 = n - n1; mu1 = M * (1 - (1 - 1 / M) ** n1)
    bnd = math.exp(-n2 * mu1 / (4 * M)) + math.exp(-mu1 ** 2 / (2 * n1))
    simp = math.exp(-0.039 * n * (n - 1) / M) + math.exp(-0.19 * n1) if n <= 2 * M else float("nan")
    print(f"  M={M:5d} n={n:5d}: exact={mp.nstr(ex, 4):>10s}  bound={bnd:.3e}  simplified={simp:.3e}  "
          f"exact<=bound:{ex <= bnd}  bound<=simplified:{(bnd <= simp) if n <= 2*M else 'n/a'}")
# monotonicity in n at fixed M
M = 512
vals = [p_noconf(M, n) for n in range(1, 120)]
print("  nonincreasing in n at M=512, n<120:", all(vals[i + 1] <= vals[i] for i in range(len(vals) - 1)))
# lambda-scale exponents
for lam in [0.5, 1.0, 1.5, 3.0]:
    print(f"  lambda={lam}: exponent constants (lam/8)(1-e^-lam/2)={lam/8*(1-math.exp(-lam/2)):.4f}, "
          f"(1-e^-lam/2)^2/lam={(1-math.exp(-lam/2))**2/lam:.4f}")

print("(d) without replacement, fair labels: Q = n exactly (ybar_x = y_i, ybar^2 = 1) -- trivial, checked:")
d = 6; M = 2 ** d; n = 40
perm = rng.permutation(M)[:n]; yy = rng.choice([-1.0, 1.0], size=n)
k = np.bincount(perm, minlength=M); S = np.bincount(perm, weights=yy, minlength=M)
print("  Q =", float(np.sum((S[k > 0] / k[k > 0]) ** 2)), " n =", n)
