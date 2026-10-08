"""c11: soundness under Dirichlet weights (referee issue M1; notes-final Lemma 4.6, Theorems 4.7 and 4.8, Example 4.9).

Part A.  Lemma 4.6(b) (pathwise mixture regret).  For P_{T,w}(x) = sum_tau w_tau q_tau(x) with Dir(alpha) weights,
  alpha_tau <= 1, and every w* in the closed simplex, every sequence x^n:
      ln P_{T,w*}(x^n) - ln P^Dir_T(x^n) <= (K-1) ln(n+1) + 1 + ln((K-1)! prod Gamma(alpha_tau) / Gamma(A)).
  We compute P^Dir_T(x^n) EXACTLY (Bernstein-form dynamic programme, then Dirichlet moments) for K = 2 and K = 3 with
  OVERLAPPING components on a 4-letter alphabet, on sequences drawn from w* (interior and boundary) and on adversarial
  constant sequences, and report the largest value of (regret - bound) (must be <= 0) and of regret - (K-1)/2 ln n.

Part B.  The referee's counterexample (r3), reproduced with independent code: T* = {0+0=0, (Sz)+0=Sz} with Dir(1/2,1/2)
  weights, competitor T' = {z+0=z}; root law of Q: (p0, pS, p+, p*) = (0.5, 0.5-eps, eps/2, eps/2); prior 1/2 each;
  the verifier accepts q (proved by T' only) iff pi_n(T*) <= delta = 0.01.  Data from P_{T*,w*} with
  w* = (p0, pS)/(1-eps).  Only the root counts matter.  We evaluate EVERY n <= N (not a grid).
    B1: fixed w*, constant threshold: acceptance frequency (the fixed-weight Theorem 4.1 analogue would bound it by 0.02).
    B2: w* ~ Dir(1/2,1/2) (Bayes-averaged; Theorem 4.7 bounds it by delta/pi(T*) = 0.02).
    B3: fixed w*, shrinking threshold delta_n = pi(T*) * delta' * c_{2,1/2} / (n+1) with delta' = 0.02 (Theorem 4.8).
"""
import math
import numpy as np
from scipy.special import gammaln, logsumexp

out = []
rng = np.random.default_rng(1111)

# ------------------------------------------------------------------ Part A
def log_dir_marginal_K2(seq, q1, q2, a1, a2):
    """Exact ln of int prod_i (w q1(x_i) + (1-w) q2(x_i)) Beta(w; a1, a2) dw, via Bernstein coefficients."""
    logc = np.array([0.0])                    # coefficient of w^j (1-w)^(m-j), m = data so far
    for x in seq:
        l1, l2 = math.log(q1[x]) if q1[x] > 0 else -np.inf, math.log(q2[x]) if q2[x] > 0 else -np.inf
        new = np.full(len(logc) + 1, -np.inf)
        new[1:] = np.logaddexp(new[1:], logc + l1)
        new[:-1] = np.logaddexp(new[:-1], logc + l2)
        logc = new
    m = len(logc) - 1
    j = np.arange(m + 1)
    mom = gammaln(a1 + j) + gammaln(a2 + m - j) - gammaln(a1 + a2 + m) - (gammaln(a1) + gammaln(a2) - gammaln(a1 + a2))
    return float(logsumexp(logc + mom))


def log_dir_marginal_K3(seq, qs, al):
    """Exact ln of int prod_i sum_k w_k q_k(x_i) Dir(w; al) dw for K = 3; coefficients c[j1, j2] of w1^j1 w2^j2 w3^(m-j1-j2)."""
    n = len(seq)
    logc = np.full((n + 1, n + 1), -np.inf)
    logc[0, 0] = 0.0
    for t, x in enumerate(seq):
        lq = [math.log(q[x]) if q[x] > 0 else -np.inf for q in qs]
        new = np.full((n + 1, n + 1), -np.inf)
        new[1:, :] = np.logaddexp(new[1:, :], logc[:-1, :] + lq[0])
        new[:, 1:] = np.logaddexp(new[:, 1:], logc[:, :-1] + lq[1])
        new = np.logaddexp(new, logc + lq[2])
        logc = new
    j1, j2 = np.meshgrid(np.arange(n + 1), np.arange(n + 1), indexing='ij')
    j3 = n - j1 - j2
    ok = j3 >= 0
    A = sum(al)
    mom = (gammaln(al[0] + j1) + gammaln(al[1] + j2) + gammaln(al[2] + np.where(ok, j3, 0)) - gammaln(A + n)
           - (sum(gammaln(a) for a in al) - gammaln(A)))
    return float(logsumexp(np.where(ok, logc + mom, -np.inf)))


def log_fixed(seq, qs, w):
    return float(sum(math.log(sum(wk * q[x] for wk, q in zip(w, qs))) for x in seq))


def bound(n, al):
    K = len(al)
    return (K - 1) * math.log(n + 1) + 1 + math.lgamma(K) + sum(math.lgamma(a) for a in al) - math.lgamma(sum(al))


# overlapping components on alphabet {0,1,2,3}
QS = [np.array([0.5, 0.3, 0.2, 0.0]), np.array([0.1, 0.2, 0.3, 0.4]), np.array([0.25, 0.25, 0.25, 0.25])]
worst = {}
for K, al in ((2, (0.5, 0.5)), (2, (1.0, 1.0)), (3, (0.5, 0.5, 0.5))):
    qs = QS[:K]
    wstars = ([np.array([0.3, 0.7]), np.array([0.95, 0.05]), np.array([1.0, 0.0]), np.array([0.0, 1.0])] if K == 2 else
              [np.array([0.2, 0.3, 0.5]), np.array([0.9, 0.05, 0.05]), np.array([0.0, 0.0, 1.0]), np.array([0.5, 0.5, 0.0])])
    ns = (10, 100, 1000, 3000) if K == 2 else (10, 50, 150)
    w_gap, w_half = -np.inf, -np.inf
    for ws in wstars:
        p = sum(wk * q for wk, q in zip(ws, qs))
        for n in ns:
            seqs = [rng.choice(4, size=n, p=p) for _ in range(3 if K == 2 else 2)]
            # adversarial: constant sequence at the most likely letter under w*, and at letter 3
            seqs.append(np.full(n, int(np.argmax(p))))
            if p[3] > 0:
                seqs.append(np.full(n, 3))
            for s in seqs:
                ld = log_dir_marginal_K2(s, qs[0], qs[1], *al) if K == 2 else log_dir_marginal_K3(s, qs, al)
                reg = log_fixed(s, qs, ws) - ld
                w_gap = max(w_gap, reg - bound(n, al))
                w_half = max(w_half, reg - (K - 1) / 2 * math.log(n))
    out.append(f"A: K = {K}, alpha = {al}: max over all trials of [regret - Lemma 4.6 bound] = {w_gap:.3f} (must be <= 0); "
               f"max of [regret - (K-1)/2 ln n] = {w_half:.3f}")
# sanity check of the exact K = 2 routine against brute-force quadrature on one sequence
s = rng.choice(4, size=40, p=[0.3, 0.3, 0.2, 0.2])
grid = (np.arange(200000) + 0.5) / 200000
li = np.array([0.0] * len(grid))
for x in s:
    li += np.log(grid * QS[0][x] + (1 - grid) * QS[1][x])
lw = (0.5 - 1) * np.log(grid) + (0.5 - 1) * np.log1p(-grid) - (2 * math.lgamma(0.5) - math.lgamma(1.0))
quad = float(logsumexp(li + lw) + math.log(1 / len(grid)))
out.append(f"A: exactness check, n = 40: Bernstein DP {log_dir_marginal_K2(s, QS[0], QS[1], 0.5, 0.5):.6f} vs midpoint "
           f"quadrature (2e5 points) {quad:.6f}")

# Part A2: R_alpha(n, K) = min_c E_Dir[prod w^c] / prod (c/n)^c exactly (Lemma 4.6(a), (c), (d))
def lnR(n, K, a):
    best = np.inf
    A_ = K * a
    if K == 2:
        j = np.arange(n + 1)
        c = np.stack([j, n - j], axis=1).astype(float)
    else:
        j1, j2 = np.meshgrid(np.arange(n + 1), np.arange(n + 1), indexing='ij')
        ok = j1 + j2 <= n
        c = np.stack([j1[ok], j2[ok], n - j1[ok] - j2[ok]], axis=1).astype(float)
    lm = gammaln(A_) - K * gammaln(a) + np.sum(gammaln(a + c), axis=1) - gammaln(A_ + n)
    with np.errstate(divide='ignore', invalid='ignore'):
        lmax = np.sum(np.where(c > 0, c * np.log(c / n), 0.0), axis=1)
    return float(np.min(lm - lmax))


for K in (2, 3):
    for a in (0.5, 1.0):
        ns_ = [16, 64, 256, 1024] if K == 3 else [16, 256, 4096, 65536]
        vals = [lnR(n, K, a) for n in ns_]
        sl = np.polyfit(np.log(ns_), vals, 1)[0]
        lower = [-(K - 1) * math.log(n + 1) - 1 - math.lgamma(K) - K * math.lgamma(a) + math.lgamma(K * a) for n in ns_]
        ok = all(v >= l - 1e-9 for v, l in zip(vals, lower))
        out.append(f"A2: K = {K}, alpha = {a}: ln R(n, K) at n = {ns_}: " + ", ".join(f"{v:.3f}" for v in vals)
                   + f"; slope vs ln n = {sl:.3f} (Lemma 4.6(c),(d): -(K-1)*max(1/2, alpha) = {-(K - 1) * max(0.5, a):.1f}); "
                   f"above the Lemma 4.6(b) lower bound: {ok}")

# ------------------------------------------------------------------ Part B
def log_dirmult2(n0, n1, a=0.5):
    return gammaln(2 * a) - gammaln(2 * a + n0 + n1) + gammaln(a + n0) + gammaln(a + n1) - 2 * gammaln(a)


delta, pi_star, delta_p = 0.01, 0.5, 0.02
c2 = math.exp(-1) * math.exp(math.lgamma(1.0) - 2 * math.lgamma(0.5))      # c_{2,1/2} = 1/(e*pi)
out.append(f"B: delta = {delta}, pi(T*) = {pi_star}; Theorem 4.7 bound delta/pi(T*) = {delta / pi_star}; "
           f"c_(2,1/2) = 1/(e pi) = {c2:.4f}")
N = 2_000_000
R = 300
CH = 200_000
for eps in (1e-5, 1e-6):
    p0, pS = 0.5, 0.5 - eps
    w0 = p0 / (1 - eps)
    lp0, lpS = math.log(p0), math.log(pS)
    for mode in ('B1 fixed w*, constant delta', 'B2 w* ~ Dir(1/2,1/2), constant delta', 'B3 fixed w*, delta_n shrinking'):
        hits = 0
        for r in range(R):
            w = w0 if not mode.startswith('B2') else rng.beta(0.5, 0.5)
            n0_prev, hit = 0, False
            for start in range(0, N, CH):
                inc = rng.random(CH) < w
                n0 = n0_prev + np.cumsum(inc)
                nn = np.arange(start + 1, start + CH + 1)
                n1 = nn - n0
                lr = n0 * lp0 + n1 * lpS - log_dirmult2(n0, n1)          # ln P_T'(D) - ln P^Dir_T*(D)
                if mode.startswith('B3'):
                    dn = pi_star * delta_p * c2 / (nn + 1)
                    thr = np.log((1 - dn) / dn * pi_star / (1 - pi_star))
                else:
                    thr = math.log((1 - delta) / delta * pi_star / (1 - pi_star))
                if (lr >= thr).any():
                    hit = True
                    break
                n0_prev = int(n0[-1])
            hits += hit
        out.append(f"  eps = {eps:.0e}, {mode:38s}: P(exists n <= {N}: q accepted) = {hits / R:.3f}  ({hits}/{R})")

text = "\n".join(out)
print(text)
open(__file__.replace('.py', '.out'), 'w').write(text + "\n")
