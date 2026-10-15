"""q3 (referee, second run): independent checks for notes Sec. 3 (model-vs-randomness split).

(A) Lemma 3.2 hashing, with my own GF(2^q) arithmetic: for every set of N <= 3 distinct inputs and every
    labelling, Pr_s[phi_s extends D] == nu(D) exactly; also the number of DISTINCT functions phi_s
    (seed collisions matter for the proof's sum over seeds, see referee report).
(B) Lemma 3.1 (Ville) under an ADAPTIVE, adversarial input rule: the next input is the one where the
    Bayes mixture xi's predictive deviates most from nu.  Empirical P[sup_N log2(xi/nu) >= m] vs 2^-m.
(C) Theorems 3-4 in an explicit Kraft-coded product class on X = N:
      samplers   nu_theta(1|x) = theta_{x mod 2}, theta on the grid {1..15}/16       (length 1 + 8 bits)
      fill-ins   lookup table of the first L labels, then 0                         (length 2 + gamma(L+1) + L)
      partial memorisers  sampler + table of the first L labels                      (length 2 + 8 + gamma(L+1) + L)
    Data: inputs 0,1,2,... (distinct), labels from theta* = (3/16, 11/16).
    Checks at lambda in {1, 1.5, 2, 4} and N up to 300:
      Thm 4(i)   l(MAP) <= (lambda k + m*)/(lambda-1)  and  -log nu_MAP(D) <= -log nu(D) + lambda k
      Thm 4(ii)  posterior mass on lengths > L  <= 2^{lambda k + m* - (lambda-1) L}
      Thm 4(iii) posterior mass on consistent fill-ins <= 2^{lambda k + lambda m* - (lambda-1)(-log nu(D))}
      Thm 3(iii) at lambda=1: odds(fill-ins : sampler program) <= 2^{k + m*}
    with m* the running sup of log2(xi_x(D_N)/nu(D_N)) over the run.
Seeded: numpy default_rng(777). Output: q3_split.out
"""
import itertools
from math import log2, ceil, inf
import numpy as np

rng = np.random.default_rng(777)
out = []
P = lambda *a: out.append(" ".join(str(x) for x in a))

# ------------------------------------------------------------------ (A)
P("=" * 78)
P("(A) Lemma 3.2 hashing: exactness and seed collisions")
def gf_mul(a, b, q, mod):
    r = 0
    while b:
        if b & 1: r ^= a
        b >>= 1; a <<= 1
        if a >> q: a ^= mod
    return r
def gf_pow(a, e, q, mod):
    r = 1
    for _ in range(e): r = gf_mul(r, a, q, mod)
    return r
for (n, r, q, mod) in [(3, 2, 3, 0b1011), (3, 3, 3, 0b1011), (2, 4, 4, 0b10011), (3, 4, 4, 0b10011)]:
    X = list(range(2**n))                       # iota(x) = x, injective into GF(2^q)
    sigma = rng.integers(0, 2, size=(2**n, 2**r))   # sampler: label = sigma[x, b]
    nu1 = sigma.mean(1)                          # nu(1|x), dyadic with r bits
    worst = 0.0; checked = 0; ndistinct = {}
    for N in [1, 2, 3]:
        seeds = list(itertools.product(range(2**q), repeat=N))
        # precompute phi_s on all of X
        phis = []
        for s in seeds:
            hv = []
            for x in X:
                acc = 0
                for j, sj in enumerate(s):
                    acc ^= gf_mul(sj, gf_pow(x, j, q, mod), q, mod)
                hv.append(sigma[x, acc & (2**r - 1)])   # 'first r bits' taken as low r bits
            phis.append(tuple(hv))
        ndistinct[N] = (len(set(phis)), len(seeds))
        phis = np.array(phis)
        for xs in itertools.combinations(X, N):
            for ys in itertools.product([0, 1], repeat=N):
                emp = np.mean(np.all(phis[:, list(xs)] == np.array(ys), axis=1))
                th = np.prod([nu1[x] if y == 1 else 1 - nu1[x] for x, y in zip(xs, ys)])
                worst = max(worst, abs(emp - th)); checked += 1
    P(f"  n={n} r={r} GF(2^{q}): {checked} (D) cases, max |Pr_s - nu(D)| = {worst:.1e}; "
      f"distinct functions / seeds by N: {ndistinct}")

# ------------------------------------------------------------------ (B)
P("=" * 78)
P("(B) Ville under an adaptive adversarial input rule")
# hypotheses: product Bernoulli rates on 4 input classes (x mod 4), grid {1..7}/8, uniform weights
grid = np.arange(1, 8)/8
H = np.array(list(itertools.product(grid, repeat=2)))      # rates for classes (x mod 2) -> 49 hypotheses
w = np.ones(len(H))/len(H)
theta_true = np.array([0.5, 0.5])                           # nu: a fair coin (not in the grid's corner)
runs, Nmax = 4000, 60
sups = np.zeros(runs)
for rr in range(runs):
    logw = np.log2(w).copy(); lognu = 0.0; best = -inf
    used = set(); nxt = 0
    for t in range(Nmax):
        post = 2.0**(logw - logw.max()); post /= post.sum()
        # adversary: choose class where |xi(1|x) - nu(1|x)| is largest
        pred = post @ H                                     # xi(1|class)
        cls = int(np.argmax(np.abs(pred - theta_true)))
        y = int(rng.uniform() < theta_true[cls])
        logw += np.log2(H[:, cls] if y == 1 else 1 - H[:, cls])
        lognu += log2(theta_true[cls] if y == 1 else 1 - theta_true[cls])
        lx = logw.max() + log2(np.sum(2.0**(logw - logw.max())))
        best = max(best, lx - lognu)
    sups[rr] = best
for mm in [1, 2, 3, 4, 6]:
    P(f"  m={mm}: empirical P[sup >= m] = {np.mean(sups >= mm):.4f}  <=  2^-m = {2.0**-mm:.4f}")

# ------------------------------------------------------------------ (C)
P("=" * 78)
P("(C) Theorems 3-4 in an explicit Kraft-coded product class")
grid16 = np.arange(1, 16)/16
samplers = [(a, b) for a in grid16 for b in grid16]         # 225 samplers, code: '0' + 8 bits (index < 256)
LEN_S = 1 + 8
def gamma_len(n): return 2*int(np.floor(np.log2(n))) + 1         # Elias gamma code length for n >= 1
def len_fill(L): return 2 + gamma_len(L + 1) + L                # '10' + gamma(L+1) + table
def len_pm(L): return 2 + 8 + gamma_len(L + 1) + L             # '11' + sampler + gamma(L+1) + table
# Kraft check (prefix-free lengths; sum over all codewords incl. 2^L tables)
kraft = len(samplers)*2.0**-LEN_S + sum(2.0**(L - len_fill(L)) for L in range(0, 2000)) \
        + len(samplers)*sum(2.0**(L - len_pm(L)) for L in range(0, 2000))
P(f"  Kraft sum of the class (truncated at L<2000) = {kraft:.4f} (must be <= 1)")
th_star = (3/16, 11/16); k = LEN_S
TH = np.array(samplers)
istar = [i for i, t in enumerate(samplers) if t == th_star][0]
def lse(v):
    v = np.asarray(v, dtype=float); mx = v.max()
    return mx + log2(np.sum(2.0**(v - mx)))
viol = {"i_len": 0, "i_loss": 0, "ii": 0, "iii": 0, "t3": 0}; checks = 0; maps_equiv = 0; maps_total = 0
EXTRA = 400
for run in range(30):
    Nmax = 300
    xs_all = np.arange(Nmax); p1 = np.where(xs_all % 2 == 0, th_star[0], th_star[1])
    ys_all = (rng.uniform(size=Nmax) < p1).astype(int)
    # per-sampler per-input log-lik, cumulative
    P1 = np.where((xs_all % 2 == 0)[None, :], TH[:, :1], TH[:, 1:2])        # (225, Nmax)
    LL = np.where(ys_all[None, :] == 1, np.log2(P1), np.log2(1 - P1))
    cum = np.concatenate([np.zeros((len(samplers), 1)), np.cumsum(LL, axis=1)], axis=1)   # (225, Nmax+1)
    lens_pm_small = np.array([len_pm(L) for L in range(0, Nmax + 1)])
    def pieces(N, lam):
        """log2 of 2^{-lam len} * lik for every program class; returns dict of arrays (logweight, length, loglik)."""
        sl = cum[:, N]
        S = (-lam*LEN_S + sl, np.full(len(samplers), LEN_S), sl)
        Ls = np.arange(N, N + EXTRA)
        fl = np.array([len_fill(L) for L in Ls])
        F = (-lam*fl + (Ls - N), fl, np.zeros(len(Ls)))                      # aggregated over 2^{L-N} tables
        # partial memorisers with L <= N: table on first L, sampler on the rest
        llpm = sl[:, None] - cum[:, :N + 1]                                    # (225, N+1)
        lpm = lens_pm_small[:N + 1][None, :].repeat(len(samplers), 0)
        PMs = (-lam*lpm + llpm, lpm, llpm)
        # partial memorisers with L > N: aggregated over samplers (225) and 2^{L-N} tables
        Lb = np.arange(N + 1, N + EXTRA)
        lb = np.array([len_pm(L) for L in Lb])
        PMb = (-lam*lb + (Lb - N) + log2(len(samplers)), lb, np.zeros(len(Lb)))
        return S, F, PMs, PMb
    mstar = -inf; lnus = {}
    for N in range(1, Nmax + 1):
        S, F, PMs, PMb = pieces(N, 1.0)
        lxi = lse(np.concatenate([S[0], F[0], PMs[0].ravel(), PMb[0]]))
        lnu = cum[istar, N]; lnus[N] = lnu
        mstar = max(mstar, lxi - lnu)
    for N in range(25, Nmax + 1, 25):
        lnu = lnus[N]
        for lam in [1.0, 1.5, 2.0, 4.0]:
            S, F, PMs, PMb = pieces(N, lam)
            # individual programs: samplers, shortest fill-in (single table, L = N), pms with L <= N
            J = np.concatenate([-S[0], [lam*len_fill(N)], -PMs[0].ravel()])
            LEN = np.concatenate([S[1], [len_fill(N)], PMs[1].ravel()])
            LLK = np.concatenate([S[2], [0.0], PMs[2].ravel()])
            KIND = np.concatenate([np.arange(len(samplers)), [-1], np.full(PMs[0].size, -2)])
            Jmin = J.min(); maps = np.where(J <= Jmin + 1e-9)[0]
            lZ = lse(np.concatenate([S[0], F[0], PMs[0].ravel(), PMb[0]]))
            for t in maps:
                checks += 1; maps_total += 1
                if lam > 1 and LEN[t] > (lam*k + mstar)/(lam - 1) + 1e-9: viol["i_len"] += 1
                if -LLK[t] > -lnu + lam*k + 1e-9: viol["i_loss"] += 1
                if KIND[t] == istar: maps_equiv += 1
            if lam > 1:
                for Lcut in [20, 40, 80, 160]:
                    parts = [S[0][S[1] > Lcut], F[0][F[1] > Lcut], PMs[0][PMs[1] > Lcut], PMb[0][PMb[1] > Lcut]]
                    sel = np.concatenate(parts)
                    if len(sel):
                        if lse(sel) - lZ > lam*k + mstar - (lam - 1)*Lcut + 1e-9: viol["ii"] += 1
                if lse(F[0]) - lZ > lam*k + lam*mstar - (lam - 1)*(-lnu) + 1e-9: viol["iii"] += 1
            else:
                if lse(F[0]) - (-LEN_S + lnu) > k + mstar + 1e-9: viol["t3"] += 1
P(f"  30 runs, N in 25..300 step 25, lambda in {{1,1.5,2,4}}: {checks} MAP checks; violations: {viol}")
P(f"  MAPs equal to the true sampler theta*: {maps_equiv}/{maps_total} (informational; grid neighbours are not nu-equivalent)")

open(__file__.replace(".py", ".out"), "w").write("\n".join(out) + "\n")
print("\n".join(out))
