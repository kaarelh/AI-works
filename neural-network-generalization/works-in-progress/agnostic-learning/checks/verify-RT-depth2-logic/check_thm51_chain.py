"""Checks for Theorem 5.1 of redteam.md (depth two, cube example).

(1) bracket: min_t [alpha t^2 + (1-t)^2] = alpha/(1+alpha) at t = 1/(1+alpha)   (sympy)
(2) R(t g) <= (1-t)^2 G + n(t a + a^2/4) for |g - r| <= a/2, r = ybar 1_T  (random + adversarial e)
(3) decomposition (1.1), Lemma 1.2(a), Lemma 1.2(b) on random f (including f built to saturate the hypothesis)
(4) Lemma 1.3 conditional moments: E[Q|x] = Sigma_1, Var(Q|x) <= 2s, E[G|x] = s, Var(G|x) <= 2s, Var V = 2n(n-1)/M
(5) gamma(lambda), its maximiser, and the first d at which the explicit c=1 bound is positive
"""
import math
import numpy as np
import sympy as sp

rng = np.random.default_rng(11)

# (1) bracket
t, al = sp.symbols('t alpha', positive=True)
f = al*t**2 + (1-t)**2
tstar = sp.solve(sp.diff(f, t), t)[0]
print("(1) argmin t* =", sp.simplify(tstar), "; min value =", sp.simplify(f.subs(t, tstar)),
      "; 1 - 1/(1+alpha) =", sp.simplify(1 - 1/(1+al)))
assert sp.simplify(f.subs(t, tstar) - al/(1+al)) == 0

def sample_stats(M, n):
    idx = rng.integers(0, M, size=n); y = rng.choice([-1.0, 1.0], size=n)
    k = np.bincount(idx, minlength=M).astype(float); S = np.bincount(idx, weights=y, minlength=M)
    T = k > 0; ybar = np.zeros(M); ybar[T] = S[T]/k[T]
    return idx, y, k, S, T, ybar

# (2) residual of t g
worst = -1e9
for trial in range(2000):
    d = rng.integers(3, 10); M = 2**d; n = int(math.ceil(rng.uniform(0.3, 2.0)*M))
    idx, y, k, S, T, ybar = sample_stats(M, n)
    G = float(np.sum(k[T]*ybar[T]**2))
    a = rng.uniform(1e-3, 1.0); tt = rng.uniform(0, 1)
    if trial % 2 == 0:
        e = rng.uniform(-a/2, a/2, size=M)
    else:  # adversarial: push t g away from ybar
        e = -(a/2)*np.sign(ybar + 1e-12)
    g = ybar*T + e
    R = float(np.sum(k[T]*(tt*g[T] - ybar[T])**2))
    rhs = (1-tt)**2*G + n*(tt*a + a*a/4)
    worst = max(worst, R - rhs)
print("(2) max over 2000 trials of R(tg) - [(1-t)^2 G + n(ta+a^2/4)] =", worst, "(<= 0 required)")

# (3) Lemma 1.2
bad = 0
for trial in range(3000):
    d = rng.integers(2, 9); M = 2**d; n = int(math.ceil(rng.uniform(0.2, 3.0)*M))
    idx, y, k, S, T, ybar = sample_stats(M, n)
    Q = float(np.sum(ybar[T]**2)); G = float(np.sum(k[T]*ybar[T]**2)); V = float(np.sum(S**2))
    Wd = float(np.sum((y - ybar[idx])**2))
    if trial % 3 == 0:
        fx = rng.normal(size=M)*rng.uniform(0, 2)
    elif trial % 3 == 1:
        fx = rng.uniform(0, 1)*ybar + rng.normal(size=M)*0.1
    else:
        fx = np.clip(rng.uniform(0, 1.5)*ybar + rng.normal(size=M)*0.05, -1, 1)
    R = float(np.sum(k[T]*(fx[T]-ybar[T])**2))
    total = float(np.sum((fx[idx]-y)**2))
    if abs(total - (R + Wd)) > 1e-8: bad += 1
    lhs = float(np.sum(fx**2))/M
    if lhs < max(0.0, math.sqrt(Q)-math.sqrt(R))**2/M - 1e-12: bad += 1
    # (b): pick theta, E0 so that the hypothesis R <= (1-theta)G + E0 holds with equality-ish
    if G > 0 and V > 0:
        th = rng.uniform(0, 1); E0 = max(0.0, R - (1-th)*G) + rng.uniform(0, 1)
        if lhs < max(0.0, th*G - E0)**2/(4*M*V) - 1e-12: bad += 1
print("(3) Lemma 1.2 violations in 3000 trials:", bad)

# (4) Lemma 1.3 conditional moments (fix inputs, resample labels)
d = 8; M = 2**d; n = M
idx = rng.integers(0, M, size=n)
k = np.bincount(idx, minlength=M).astype(float); T = k > 0; s = int(T.sum())
Sigma1 = float(np.sum(1/k[T]))
reps = 40000
Qs = np.empty(reps); Gs = np.empty(reps)
for r_ in range(reps):
    y = rng.choice([-1.0, 1.0], size=n)
    S = np.bincount(idx, weights=y, minlength=M)
    Qs[r_] = np.sum(S[T]**2/k[T]**2); Gs[r_] = np.sum(S[T]**2/k[T])
exactVarQ = float(np.sum((2*k[T]**2-2*k[T])/k[T]**4)); exactVarG = float(np.sum((2*k[T]**2-2*k[T])/k[T]**2))
print(f"(4) E[Q|x]: MC {Qs.mean():.3f} vs Sigma_1 {Sigma1:.3f}; Var(Q|x): MC {Qs.var():.3f} vs exact {exactVarQ:.3f} <= 2s={2*s}")
print(f"    E[G|x]: MC {Gs.mean():.3f} vs s {s}; Var(G|x): MC {Gs.var():.3f} vs exact {exactVarG:.3f} <= 2s={2*s}")
Vs = np.empty(reps)
for r_ in range(reps):
    idx2 = rng.integers(0, M, size=n); y = rng.choice([-1.0, 1.0], size=n)
    S = np.bincount(idx2, weights=y, minlength=M); Vs[r_] = np.sum(S**2)
print(f"    E V: MC {Vs.mean():.2f} vs n {n}; Var V: MC {Vs.var():.2f} vs 2n(n-1)/M {2*n*(n-1)/M:.2f}")

# (5) gamma and explicit thresholds
gam = lambda l: (1-math.exp(-l))**2/(4*l)
from scipy import optimize
res = optimize.minimize_scalar(lambda l: -gam(l), bounds=(0.05, 6), method='bounded')
print(f"(5) gamma(1) = {gam(1):.5f}; argmax {res.x:.4f}, max {-res.fun:.5f}")
FD = lambda d: 1 + (d+1)*(d+2)**2
for c in [1.0, 4.0]:
    first = None
    for d in range(5, 80):
        M = 2.0**d; G = (1-math.exp(-1))*M; V = M
        th = 1/(18*d*c+1); E0 = c*(d*FD(d)+1) + 2
        if th*G - E0 > 0:
            first = d; break
    print(f"    c={c}: explicit bound first positive at d={first} (asymptotic regime: needs M >> c^2 d^5)")
for d in [30, 35, 40]:
    n = 2**d; M = 2**d
    print(f"    width threshold 72 d n^3 ln(2M)+2 at d={d}: {72*d*n**3*math.log(2*M)+2:.3e}")
