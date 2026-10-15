"""Referee check r4: finite/explicit hypothesis classes in which every quantity of notes Thms 1, 4, 5
and Prop 2.8 can be computed exactly, to search for violations of the stated inequalities.

Class (all lengths satisfy Kraft, total weight < 1):
  * grid samplers nu_{i,j}: P(1|x) = i/16 on even x, j/16 on odd x (i,j = 1..15), length 11;
  * constant samplers P(1|x) = i/16, length 7;
  * fill-ins F_{n,b}: deterministic, output b_x for x < n and 0 for x >= n, length 3 + 2 log2(n+1) + n
    (one program per (n, b), so the class has infinitely many programs; sums over n are truncated
    at N + 400 where the tail is negligible);
  * partial memorisers P_{i,j,n,b}: output b_x for x < n, then sample from nu_{i,j}; length
    11 + 3 + 2 log2(n+1) + n.
Inputs x = 0, 1, 2, ... in order (distinct). Truth nu* = nu_{3,11} (k = 11). Labels fresh from nu*.
For the shared-class comparison (Thm 1, Thm 5) the class is enlarged by U := the self-consistent
Bayes mixture of the whole class, with length l_U, so that (Dom) holds with c_0 = 0.
Checks, for lambda in {1.1, 1.5, 2, 4} and N up to 200, over 40 seeded runs:
  T4(i)   l(MAP) <= (lambda k + m*_N)/(lambda-1), with m*_N = max_{N'<=N} log2(xi_x(D_N')/nu*(D_N'));
          loss sandwich -log nu*(D) - l(MAP) - m* <= -log nu_MAP(D) <= -log nu*(D) + lambda k;
  T4(ii)  posterior mass of {l > L} <= 2^(lambda k + m* - (lambda-1) L) for L in a grid;
  T4(iii) posterior mass of deterministic programs <= 2^(lambda k + lambda m* - (lambda-1)(-log nu*(D)));
  T4(iv)  informational only: is the MAP at N = 200 equal to nu*? (the theorem is asymptotic);
  T1(a)   in the shared class, l(MAP) <= (lambda l_U)/(lambda-1);
  T5(ii)  mass of programs with length >= L <= 2^(-(lambda-1)L + lambda l_U) (c_1 = 0 here).
Seeded: numpy default_rng(13).
"""
from math import log2
import numpy as np

rng = np.random.default_rng(13)
G = 16
NMAX = 200
LAMS = [1.1, 1.5, 2.0, 4.0]


def lse(v):
    v = np.asarray(v, dtype=float)
    mx = np.max(v)
    if mx == -np.inf:
        return -np.inf
    return mx + log2(np.sum(np.exp2(v - mx)))


i_star, j_star = 3, 11
k_star = 11.0
viol = {k: 0 for k in ["T4i_len", "T4i_lo", "T4i_hi", "T4ii", "T4iii", "T4iv(info: final MAP != nu*)", "T1a", "T5ii"]}
checks = {k: 0 for k in viol}
runs = 40
for run in range(runs):
    x = np.arange(NMAX)
    th_star = np.where(x % 2 == 0, i_star / G, j_star / G)
    y = (rng.uniform(size=NMAX) < th_star).astype(int)
    # cumulative counts of ones/zeros on even / odd inputs
    ev = (x % 2 == 0)
    c1e = np.cumsum(y * ev); c0e = np.cumsum((1 - y) * ev)
    c1o = np.cumsum(y * ~ev); c0o = np.cumsum((1 - y) * ~ev)
    th = np.arange(1, G) / G
    lth, l1th = np.log2(th), np.log2(1 - th)
    mstar = -np.inf
    for N in range(1, NMAX + 1):
        e1, e0, o1, o0 = c1e[N - 1], c0e[N - 1], c1o[N - 1], c0o[N - 1]
        # grid samplers: loglik[i, j]
        LLg = (e1 * lth + e0 * l1th)[:, None] + (o1 * lth + o0 * l1th)[None, :]
        LLc = (e1 + o1) * lth + (e0 + o0) * l1th
        lognu = LLg[i_star - 1, j_star - 1]

        # helper: log-likelihood of sampler on inputs n..N-1 (suffix), from counts
        def suffix_counts(nn):
            if nn == 0:
                return e1, e0, o1, o0
            return (e1 - c1e[nn - 1], e0 - c0e[nn - 1], o1 - c1o[nn - 1], o0 - c0o[nn - 1])

        # fill-ins F_{n,b}: consistent iff b = y on x < min(n,N) and y = 0 on n <= x < N
        # (for n < N) -> one consistent program per n < N if tail zeros; for n >= N, 2^{n-N} consistent
        ones_after = np.concatenate([[0], np.cumsum(y[:N][::-1])])[::-1]   # ones_after[n] = #ones in [n, N)
        det_terms = []      # (length, multiplicity log2) for consistent deterministic programs
        for nn in range(0, N):
            if ones_after[nn] == 0:
                det_terms.append((3 + 2 * log2(nn + 1) + nn, 0.0))
        for nn in range(N, N + 400):
            det_terms.append((3 + 2 * log2(nn + 1) + nn, float(nn - N)))
        # partial memorisers P_{i,j,n,b}: b must equal y on x < min(n, N); for n >= N they are fill-ins
        # on the data with multiplicity 2^{n-N} (likelihood 1); for n < N, likelihood = sampler on suffix
        pm_terms = []       # (length, log2 multiplicity, loglik)
        for nn in range(0, N):
            s1e, s0e, s1o, s0o = suffix_counts(nn)
            LL = (s1e * lth + s0e * l1th)[:, None] + (s1o * lth + s0o * l1th)[None, :]
            pm_terms.append((14 + 2 * log2(nn + 1) + nn, LL))
        # mixture xi_x (lambda = 1) for m*
        parts = [lse((LLg - 11).ravel()), lse(LLc - 7)]
        parts.append(lse([-L + mult for (L, mult) in det_terms]))
        parts.append(lse([lse((LL - L).ravel()) for (L, LL) in pm_terms]))
        pm_det = [(14 + 2 * log2(nn + 1) + nn, float(nn - N) + log2((G - 1) ** 2)) for nn in range(N, N + 400)]
        parts.append(lse([-L + mult for (L, mult) in pm_det]))
        logxi = lse(parts)
        mstar = max(mstar, logxi - lognu)

        if N % 20 != 0:
            continue
        for lam in LAMS:
            # objective J = lam*l - loglik; collect (J, l, det?, loglik, is_star)
            cands = []
            for i in range(G - 1):
                for j in range(G - 1):
                    cands.append((lam * 11 - LLg[i, j], 11.0, False, LLg[i, j], (i + 1, j + 1) == (i_star, j_star)))
            for i in range(G - 1):
                cands.append((lam * 7 - LLc[i], 7.0, False, LLc[i], False))
            for (L, mult) in det_terms:
                cands.append((lam * L, L, True, 0.0, False))
            for (L, LL) in pm_terms:
                idx = np.unravel_index(np.argmax(LL), LL.shape)
                cands.append((lam * L - LL[idx], L, False, LL[idx], False))
            Jmin = min(c[0] for c in cands)
            maps = [c for c in cands if c[0] <= Jmin + 1e-9]
            bound_len = (lam * k_star + mstar) / (lam - 1)
            for c in maps:
                checks["T4i_len"] += 1; checks["T4i_lo"] += 1; checks["T4i_hi"] += 1
                if c[1] > bound_len + 1e-9: viol["T4i_len"] += 1
                if -c[3] < -lognu - c[1] - mstar - 1e-9: viol["T4i_lo"] += 1
                if -c[3] > -lognu + lam * k_star + 1e-9: viol["T4i_hi"] += 1
            # power posterior pieces (log2 unnormalised masses)
            w_grid = (LLg - lam * 11).ravel()
            w_const = LLc - lam * 7
            w_det = np.array([-lam * L + mult for (L, mult) in det_terms])
            w_pm = [(L, (LL - lam * L).ravel()) for (L, LL) in pm_terms]
            w_pmdet = np.array([-lam * L + mult for (L, mult) in pm_det])
            logZ = lse([lse(w_grid), lse(w_const), lse(w_det), lse([lse(v) for (_, v) in w_pm]), lse(w_pmdet)])
            # (iii) deterministic mass (fill-ins and partial memorisers with n >= N)
            logdet = lse([lse(w_det), lse(w_pmdet)]) - logZ
            checks["T4iii"] += 1
            if logdet > lam * k_star + lam * mstar - (lam - 1) * (-lognu) + 1e-9: viol["T4iii"] += 1
            # (ii) length tail
            for Lcut in [12, 20, 40, 80, 160]:
                masses = []
                if 11 > Lcut: masses.append(lse(w_grid))
                if 7 > Lcut: masses.append(lse(w_const))
                masses += [w for (L, mult), w in zip(det_terms, w_det) if L > Lcut]
                masses += [lse(v) for (L, v) in w_pm if L > Lcut]
                masses += [w for (L, _), w in zip(pm_det, w_pmdet) if L > Lcut]
                lm = lse(masses) - logZ if masses else -np.inf
                checks["T4ii"] += 1
                if lm > lam * k_star + mstar - (lam - 1) * Lcut + 1e-9: viol["T4ii"] += 1
            # shared class: add U with l_U = 6 (self-consistent mixture of the whole class at lambda=1)
            lU = 6.0
            logU = logxi - log2(1 - 2 ** -lU)          # U = xi / (1 - 2^-lU) solves U = xi + 2^-lU U
            JU = lam * lU - logU
            Jall = min(Jmin, JU)
            mapsS = [c for c in cands if c[0] <= Jall + 1e-9] + ([("U", lU)] if JU <= Jall + 1e-9 else [])
            for c in mapsS:
                checks["T1a"] += 1
                L = c[1]
                if L > lam * lU / (lam - 1) + 1e-9: viol["T1a"] += 1
            logZs = lse([logZ, -lam * lU + logU])
            for Lcut in [12, 20, 40, 80]:
                masses = []
                if 11 >= Lcut: masses.append(lse(w_grid))
                masses += [w for (L, mult), w in zip(det_terms, w_det) if L >= Lcut]
                masses += [lse(v) for (L, v) in w_pm if L >= Lcut]
                masses += [w for (L, _), w in zip(pm_det, w_pmdet) if L >= Lcut]
                lm = lse(masses) - logZs if masses else -np.inf
                checks["T5ii"] += 1
                if lm > -(lam - 1) * Lcut + lam * lU + 1e-9: viol["T5ii"] += 1
            if N == NMAX:
                checks["T4iv(info: final MAP != nu*)"] += 1
                if not all(c[4] for c in maps): viol["T4iv(info: final MAP != nu*)"] += 1
    if run % 50 == 0:
        print(f"  run {run}: m*_final = {mstar:.2f}", flush=True)

print("violations / checks:")
for k in viol:
    print(f"  {k:8s}: {viol[k]} / {checks[k]}")
