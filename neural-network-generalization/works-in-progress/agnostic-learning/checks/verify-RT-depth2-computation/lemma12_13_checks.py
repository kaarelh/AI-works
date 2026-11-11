"""Checks of redteam.md Lemma 1.2 (deterministic) and Lemma 1.3 (concentration) as used by Thm 5.1 / Prop 5.3.

Lemma 1.2: (1.1) decomposition; (a) (1/M) sum f^2 >= (sqrt Q - sqrt R(f))_+^2 / M;
           (b) R(f) <= (1-th) G + E0  =>  sum f^2 >= (th G - E0)_+^2/(4 V).
   Tested on random f and on adversarial f (minimizers of sum f^2 subject to R(f) <= B, solved exactly
   by the Lagrange/KKT formula f_x = mu k_x ybar_x/(1+mu k_x)), which is the tightest possible f.
Lemma 1.3: exact moments: Var(S^2) = 2k^2-2k for S a sum of k Rademachers; E[V]=n, Var(V)=2n(n-1)/M;
   E[Q|x] = Sigma_1, Var(Q|x) <= 2n; E[G|x] = s, Var(G|x) <= 2n; McDiarmid bounded-difference constant;
   Monte Carlo frequency of the event vs the claimed lower bound on its probability.
"""
import math, itertools
import numpy as np
from scipy import stats, optimize

rng = np.random.default_rng(7)

# --- Var(S^2) for S = sum of k Rademacher signs: exact enumeration
for kk in range(1, 11):
    vals = np.array([sum(v) for v in itertools.product([-1, 1], repeat=kk)], dtype=float)
    e2 = np.mean(vals ** 2); e4 = np.mean(vals ** 4)
    assert abs(e2 - kk) < 1e-12 and abs((e4 - e2 ** 2) - (2 * kk * kk - 2 * kk)) < 1e-9
print("Var(S^2) = 2k^2 - 2k verified exactly for k = 1..10")

# --- bounded differences of Sigma_1 and s (exhaustive over small counts)
f1 = lambda k: (1.0 / k if k >= 1 else 0.0)
f2 = lambda k: (1.0 if k >= 1 else 0.0)
worst1 = max(abs(f1(a - 1) - f1(a) + f1(b + 1) - f1(b)) for a in range(1, 30) for b in range(0, 30))
worst2 = max(abs(f2(a - 1) - f2(a) + f2(b + 1) - f2(b)) for a in range(1, 30) for b in range(0, 30))
print("bounded-difference constants: Sigma_1 -> %.3f, s -> %.3f (claimed <= 2)" % (worst1, worst2))

def sample_stats(M, n, rng):
    idx = rng.integers(0, M, size=n); ys = rng.choice([-1.0, 1.0], size=n)
    k = np.bincount(idx, minlength=M).astype(float); S = np.bincount(idx, weights=ys, minlength=M)
    seen = k > 0
    ybar = np.zeros(M); ybar[seen] = S[seen] / k[seen]
    Q = float(np.sum(ybar ** 2)); G = float(np.sum(k[seen] * ybar[seen] ** 2)); V = float(np.sum(S ** 2))
    Sig1 = float(np.sum(1.0 / k[seen])); s = int(seen.sum())
    return k, S, ybar, seen, Q, G, V, Sig1, s

# --- Lemma 1.2 (a),(b) on random and adversarial f
def min_sumsq_given_R(k, ybar, seen, B):
    """min sum_T f^2 s.t. sum_T k (f - ybar)^2 <= B  (KKT: f = mu k ybar/(1+mu k))."""
    kk = k[seen]; yb = ybar[seen]
    G = float(np.sum(kk * yb ** 2))
    if B >= G: return 0.0
    def Rmu(mu):
        f = mu * kk * yb / (1 + mu * kk); return float(np.sum(kk * (f - yb) ** 2)) - B
    lo, hi = 0.0, 1.0
    while Rmu(hi) > 0: hi *= 2
    mu = optimize.brentq(Rmu, lo, hi, xtol=1e-14)
    f = mu * kk * yb / (1 + mu * kk)
    return float(np.sum(f ** 2))

viol = 0; tight = []
for trial in range(300):
    d = rng.integers(4, 11); M = 2 ** d; n = int(math.ceil(rng.uniform(0.3, 2.5) * M))
    k, S, ybar, seen, Q, G, V, Sig1, s = sample_stats(M, n, rng)
    th = rng.uniform(0.01, 1.0); E0 = rng.uniform(0, 0.5) * th * G
    B = (1 - th) * G + E0
    best = min_sumsq_given_R(k, ybar, seen, B)          # exact minimum of sum f^2 under the hypothesis of (b)
    lb_b = max(th * G - E0, 0) ** 2 / (4 * V)
    lb_a = max(math.sqrt(Q) - math.sqrt(B), 0) ** 2
    if best < lb_b - 1e-9 or best < lb_a - 1e-9: viol += 1
    tight.append((best, lb_b, lb_a))
print("Lemma 1.2(a),(b): violations in 300 adversarial instances:", viol)
tb = np.array([[t[1] / t[0] if t[0] > 0 else np.nan, t[2] / t[0] if t[0] > 0 else np.nan] for t in tight])
print("   ratio (bound/true min of sum f^2): (b) median %.3f max %.3f ; (a) median %.3f max %.3f" % (
    np.nanmedian(tb[:, 0]), np.nanmax(tb[:, 0]), np.nanmedian(tb[:, 1]), np.nanmax(tb[:, 1])))

# --- Lemma 1.3 moments and event frequency
for d in [10, 12, 14]:
    M = 2 ** d; lam = 1.0; n = int(math.ceil(lam * M))
    kgrid = np.arange(1, 80)
    pmf = stats.binom.pmf(kgrid, n, 1.0 / M)
    beta_d = float(np.sum(pmf / kgrid)); p_d = 1 - (1 - 1.0 / M) ** n
    reps = 400
    Qs, Gs, Vs, S1s, ss, ev, vQx, vGx = [], [], [], [], [], 0, [], []
    for _ in range(reps):
        k, S, ybar, seen, Q, G, V, Sig1, s = sample_stats(M, n, rng)
        Qs.append(Q); Gs.append(G); Vs.append(V); S1s.append(Sig1); ss.append(s)
        kk = k[seen]
        vQx.append(float(np.sum((2 * kk ** 2 - 2 * kk) / kk ** 4))); vGx.append(float(np.sum((2 * kk ** 2 - 2 * kk) / kk ** 2)))
        n23 = n ** (2 / 3)
        if abs(Q - M * beta_d) <= 2 * n23 and abs(G - M * p_d) <= 2 * n23 and abs(V - n) <= n23: ev += 1
    Qs, Gs, Vs, S1s, ss = map(np.array, (Qs, Gs, Vs, S1s, ss))
    claimed = 1 - 4 * math.exp(-n ** (1 / 3) / 2) - (4 + 2 * n / M) * n ** (-1 / 3)
    print("d=%d M=%d n=%d: E Q/M=%.4f (beta_d=%.4f) E G/M=%.4f (p_d=%.4f) E V/n=%.4f; Var V=%.0f vs 2n(n-1)/M=%.0f; "
          "max Var(Q|x)=%.0f, max Var(G|x)=%.0f (<=2n=%d); sd(Sigma1)=%.1f sd(s)=%.1f vs n^{2/3}=%.0f; "
          "event freq=%.3f, claimed lower bound=%.3f" % (
              d, M, n, Qs.mean() / M, beta_d, Gs.mean() / M, p_d, Vs.mean() / n, Vs.var(), 2 * n * (n - 1) / M,
              max(vQx), max(vGx), 2 * n, S1s.std(), ss.std(), n ** (2 / 3), ev / reps, claimed))
