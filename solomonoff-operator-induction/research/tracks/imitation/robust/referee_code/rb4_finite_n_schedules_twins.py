"""rb4 (referee B): finite-n selection, boundary schedules, and the scope of 'robustness is blindness'.
(A) exact enumeration (no randomness); (B) seeded numpy default_rng(404); (C) seeded default_rng(405).

Class K (coin-flipping human, feature case, N = 16 cells z uniform, S = {0,1,2} carries coin 1, so p = 3/16):
  coin            y ~ Bern(1/2)                                      l = 2
  H(q)            y ~ Bern(q), q in {j/16 : j = 0..15}               l = 2 + 4 = 6     (the human is H(3/16))
  A(t, q)         y = 1 on a declared set T of t cells (gamma(t) + ceil log2 C(16,t) bits, exact integers),
                  Bern(q) elsewhere                                  l = 6 + gamma(t) + ceil log2 C(16, t)
World W: y = 1_S(z) (environment-driven coins), per-query data.

(A) Exact P_n[the cn-MAP is the human], by enumerating the count vectors of the three S-cells (the other 13
    cells enter only through their total), for c below, inside, at both ends of, and above the population window,
    including c = s_+ exactly (the boundary, not covered by Corollary 4.8).
(B) Proposition 4.9(b) at the boundary: the human H(3/16) against the full memoriser A(3, .) (the rate maximiser),
    schedules lambda_n / n = s_+ + eps_n.  The proof of 4.9(b) covers only lambda_n/n <= c' < s_+ on an infinite
    set.  We simulate (exactly, through the binomial count of coin-1 queries, at 141 log-spaced checkpoints up to
    1e8) eps_n = n^-0.3 (inside the window for all large n, human kept), eps_n = n^-0.9 (inside the window for
    all n >= 51, yet the memoriser wins at about half the late checkpoints), eps_n = 0, and eps_n = -n^-0.9
    (below the window for all n, yet the human wins at about half the late checkpoints): 'lambda_n/n eventually in [s_+, s_-]' is necessary (by recurrence) but not sufficient, and the
    proof as written does not give it.
(C) 'The set of aliens a procedure is robust against is the set of humans it cannot copy' (notes, after
    Proposition 4.9(a); also Section 6.2 item 2).  World W as above; world W_A: the human IS the partial
    memoriser A_1 (y = 1 on cell 0; elsewhere fresh private coins Bern(2/15) per query), which has the same
    marginal rate 3/16.  The procedure Psi_var: if every queried cell's labels are constant, output the
    fresh-coin human with the empirical rate rounded to the grid {j/240}; otherwise output 'y = 1 on the cells
    whose >= 5 labels were all 1, Bern(rate on the rest, rounded to {j/240}) elsewhere'.  Psi_var is robust
    against A_1 in W (it outputs the human) and copies the human of W_A; the two success probabilities are both
    near 1.  The cn-MAP with c inside W's window copies W's human but not W_A's (A_1's rate is below c).
"""
import itertools
from math import comb, log2, floor, lgamma, log, factorial
import numpy as np

NC, S0 = 16, 3
p = S0 / NC
QG = np.arange(0, 16) / 16.0                     # rates j/16, j = 0..15 (4 bits)


def gam(t):
    return 2 * floor(log2(t + 1)) + 1


def clog(n, k):
    c = comb(n, k)
    return (c - 1).bit_length() if c > 1 else 0


def H2(x):
    return 0.0 if x <= 0 or x >= 1 else -x * log2(x) - (1 - x) * log2(1 - x)


L_COIN, L_H = 2, 6
L_A = {t: L_H + gam(t) + clog(NC, t) for t in range(1, S0 + 1)}


def popRisk(t):
    """best population risk of A(t, .) with T inside S, and of H(q)"""
    if t == S0:
        return 0.0
    pt = (S0 - t) / (NC - t)
    return (1 - t / NC) * min(-pt * log2(q) - (1 - pt) * log2(1 - q) for q in QG[1:])


RH = H2(p)
s_plus = max((RH - popRisk(t)) / (L_A[t] - L_H) for t in range(1, S0 + 1))
s_minus = (1 - RH) / (L_H - L_COIN)
print(f"Class K: l(coin) = 2, l(H) = 6, l(A_t) = {L_A}; R_H = H(3/16) = {RH:.4f};"
      f" population window (s_+, s_-) = ({s_plus:.5f}, {s_minus:.5f}); s_+ attained by t ="
      f" {max(range(1, S0 + 1), key=lambda t: (RH - popRisk(t)) / (L_A[t] - L_H))}")

# ---------------------------------------------------------------- (A)
print("\n(A) exact selection probabilities of the cn-MAP (unique MAP; ties reported separately)")
with np.errstate(divide="ignore"):
    A1, A0 = -np.log2(QG), -np.log2(1 - QG)


def fitmat(D, A):
    """D*(-log2 q) + A*(-log2(1-q)) for every q in QG, with 0 * inf := 0; D, A column vectors."""
    with np.errstate(invalid="ignore"):
        v = D * A1[None, :] + A * A0[None, :]
    return np.where(np.isnan(v), 0.0, v)


def tuples(n):
    """all k1 >= k2 >= k3 >= 0 with k1 + k2 + k3 <= n, and the number of their orderings"""
    rows = []
    for k3 in range(0, n // 3 + 1):
        for k2 in range(k3, (n - k3) // 2 + 1):
            k1 = np.arange(k2, n - k2 - k3 + 1)
            rows.append(np.stack([k1, np.full_like(k1, k2), np.full_like(k1, k3)], axis=1))
    K = np.concatenate(rows).astype(np.int64)
    distinct = 1 + (K[:, 0] != K[:, 1]) + (K[:, 1] != K[:, 2])
    mult = np.where(distinct == 3, 6.0, np.where(distinct == 2, 3.0, 1.0))
    return K, mult


def exact(n, lam):
    K, mult = tuples(n)
    sk = K.sum(axis=1)
    rest = n - sk
    lg = np.vectorize(lgamma)
    logp = (lgamma(n + 1) - lg(K + 1).sum(axis=1) - lg(rest + 1) + sk * log(1 / NC) + rest * log((NC - S0) / NC))
    prob = mult * np.exp(logp)
    cum = np.concatenate([np.zeros((len(K), 1), np.int64), np.cumsum(K, axis=1)], axis=1)
    nhit = (K > 0).sum(axis=1)
    cands = {"coin": lam * L_COIN + n * np.ones(len(K))}
    v = fitmat(sk[:, None], rest[:, None])
    jq = np.argmin(v, axis=1)
    cands["human"] = np.where(QG[jq] == p, lam * L_H + v[np.arange(len(K)), jq], np.inf)
    vother = np.where(QG[None, :] == p, np.inf, v)
    cands["H(other q)"] = lam * L_H + vother.min(axis=1)
    for t in range(1, S0 + 1):
        D = (sk - cum[:, t])[:, None]
        vv = fitmat(D, rest[:, None])
        J = lam * L_A[t] + vv.min(axis=1)
        cands[f"A(t={t})"] = np.where(nhit >= t, J, np.inf)
    names = list(cands)
    Jm = np.stack([cands[k] for k in names], axis=1)
    mn = Jm.min(axis=1, keepdims=True)
    at = np.abs(Jm - mn) < 1e-9
    uniq = at.sum(axis=1) == 1
    out = {nm: float(prob[uniq & at[:, i]].sum()) for i, nm in enumerate(names)}
    out["(tie)"] = float(prob[~uniq].sum())
    out["human among MAPs"] = float(prob[at[:, names.index("human")]].sum())
    return out, float(prob.sum())


for c in (0.02, s_plus, 1.05 * s_plus, (s_plus * s_minus) ** 0.5, 0.95 * s_minus, s_minus, 0.12):
    for n in (16, 64, 256, 512):
        out, tot = exact(n, c * n)
        top = sorted(((k, v) for k, v in out.items() if v > 5e-5 and k != "human among MAPs"), key=lambda kv: -kv[1])
        print(f"  c={c:.5f} n={n:4d}: " + ", ".join(f"{k} {v:.4f}" for k, v in top)
              + f"  | human among MAPs {out['human among MAPs']:.4f} (total {tot:.6f})")

# ---------------------------------------------------------------- (B)
print("\n(B) boundary schedules lambda_n = (s_+ + eps_n) n, human vs full memoriser A(3); 400 runs each (seed 404)")
rng = np.random.default_rng(404)
Delta = L_A[S0] - L_H
s_pair = RH / Delta                              # the memoriser's rate (= s_+ here)
a1, a0 = -log2(p), -log2(1 - p)                  # human's loss on coin-1 / coin-0 queries
ck = np.unique(np.round(np.logspace(1, 8, 141)).astype(np.int64))
runs = 400
K = np.zeros((runs, len(ck)), np.int64)
prev = np.zeros(runs, np.int64)
last = 0
for j, n in enumerate(ck):
    prev = prev + rng.binomial(n - last, p, size=runs)
    K[:, j] = prev
    last = n
W = K * a1 + (ck[None, :] - K) * a0 - ck[None, :] * RH          # L_n(H) - n R_H, a centred random walk
for name, eps in (("eps_n = +n^-0.3", ck ** -0.3), ("eps_n = +n^-0.9", ck ** -0.9), ("eps_n = 0", 0.0 * ck),
                  ("eps_n = -n^-0.9", -(ck ** -0.9))):
    lam = (s_pair + eps) * ck
    mem_wins = (lam * Delta - (W + ck * RH)) < 0                   # J(memoriser) < J(human)
    late = ck >= 10 ** 6
    frac_late = mem_wins[:, late].mean()
    some_late = np.mean(mem_wins[:, late].any(axis=1))
    hum_late = np.mean((~mem_wins[:, late]).any(axis=1))
    ins = (lam / ck > s_plus + 1e-15) & (lam / ck < s_minus)
    n0 = next((int(ck[i]) for i in range(len(ck)) if ins[i:].all()), None)
    where = f"inside (s_+, s_-) for all n >= {n0}" if n0 is not None else (
        "AT s_+ for all n" if np.all(np.abs(lam / ck - s_plus) < 1e-15) else "below s_+ for all n")
    print(f"  {name:16s}: lambda_n/n {where};"
          f"  over n in [1e6, 1e8]: P[memoriser beats human] (avg over checkpoints) = {frac_late:.3f};"
          f" fraction of runs where the memoriser wins at some checkpoint = {some_late:.3f};"
          f" where the human wins at some checkpoint = {hum_late:.3f}")

# ---------------------------------------------------------------- (C)
print("\n(C) a procedure robust against the alien A_1 in W that also copies A_1 when A_1 is the human (seed 405)")
rng = np.random.default_rng(405)
G240 = np.arange(241) / 240.0
q_alien = 2 / 15


def psi_var(z, y):
    cnt = np.bincount(z, minlength=NC)
    ones = np.bincount(z, weights=y, minlength=NC)
    seen = cnt > 0
    const = np.all((ones[seen] == 0) | (ones[seen] == cnt[seen]))
    if const:
        r = G240[np.argmin(np.abs(G240 - y.mean()))]
        return ("fresh", r, ())
    T = tuple(int(w) for w in np.flatnonzero((cnt >= 5) & (ones == cnt)))
    off = ~np.isin(z, T)
    r = G240[np.argmin(np.abs(G240 - y[off].mean()))]
    return ("partial", r, T)


def cn_map(z, y, c):
    """cn-MAP over class K, exact: for each t the best T is the t constant-1 cells with the most queries."""
    n = len(z)
    cnt = np.bincount(z, minlength=NC)
    ones = np.bincount(z, weights=y, minlength=NC).astype(int)
    lam = c * n
    best = (lam * L_COIN + n, ("coin",))
    k1 = int(y.sum())
    for q in QG:
        if q == 0 and k1 > 0:
            continue
        J = lam * L_H + (0.0 if q == 0 else -k1 * log2(q) - (n - k1) * log2(1 - q))
        if J < best[0]:
            best = (J, ("H", q))
    elig = np.flatnonzero((ones == cnt) & (cnt > 0))
    order = elig[np.argsort(-cnt[elig], kind="stable")]
    for t in range(1, min(S0, len(order)) + 1):
        T = order[:t]
        nT = int(cnt[T].sum())
        d1, d0 = k1 - nT, n - k1
        for q in QG:
            if q == 0 and d1 > 0:
                continue
            fit = 0.0 if q == 0 else -d1 * log2(q) - d0 * log2(1 - q)
            J = lam * L_A[t] + fit
            if J < best[0]:
                best = (J, ("A", t, tuple(sorted(int(w) for w in T)), q))
    return best[1]


n, R_ = 200000, 200
c_in = (s_plus * s_minus) ** 0.5
res = {"W": [0, 0], "W_A": [0, 0]}
for r in range(R_):
    z = rng.integers(0, NC, n)
    yW = (z < S0).astype(float)                                   # W: coin 1 exactly on S = {0,1,2}
    yA = np.where(z == 0, 1.0, (rng.random(n) < q_alien).astype(float))   # W_A: the human is A_1
    a = psi_var(z, yW)
    res["W"][0] += (a[0] == "fresh" and abs(a[1] - p) < 1e-12)
    b = psi_var(z, yA)
    res["W_A"][0] += (b[0] == "partial" and b[2] == (0,) and abs(b[1] - q_alien) < 1e-12)
    m1 = cn_map(z, yW, c_in)
    res["W"][1] += (m1[0] == "H" and abs(m1[1] - p) < 1e-12)
    if r < 50:                                                   # the cn-MAP in W_A (50 runs suffice)
        m2 = cn_map(z, yA, c_in)
        res["W_A"][1] += (m2[0] == "A" and m2[1] == 1 and m2[2] == (0,))
rate_A1 = (H2(p) - (15 / 16) * H2(q_alien)) / (gam(1) + clog(NC, 1))
print(f"  n = {n}, {R_} runs.  A_1 in W_A: advantage per bit over the fresh-coin human = {rate_A1:.4f}"
      f" < s_+ = {s_plus:.4f} < c = {c_in:.4f}")
print(f"  Psi_var: P_W[copies W's human] = {res['W'][0] / R_:.3f};  P_W_A[copies W_A's human A_1] ="
      f" {res['W_A'][0] / R_:.3f};  sum = {(res['W'][0] + res['W_A'][0]) / R_:.3f} > 1")
print(f"  cn-MAP, c = {c_in:.4f}: P_W[copies W's human] = {res['W'][1] / R_:.3f};"
      f"  P_W_A[copies A_1] = {res['W_A'][1] / 50:.3f} (50 runs)")
print("  So the twin-world bound of Proposition 4.9(a) is specific to the alien with the data law P* (here the full")
print("  memoriser); for other aliens per-query data separate 'environment-driven' from 'private' coins.")
