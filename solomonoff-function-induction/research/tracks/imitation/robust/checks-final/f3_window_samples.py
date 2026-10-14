"""[Revision copy of checks/r3_*.py for notes-final.md: identical except that every code length
ceil(log2 C(N, t)) is computed exactly in integers (function clc), fixing the floating-point bug B9 of
referee B; docstring typos corrected.]

r3: from samples, in the explicit toy class of r2 (notes Proposition 4.2, Corollary 4.8, Proposition 4.9(b)).
Seeded: numpy default_rng(3).  du = 6, m = 10, s0 = 64 (p = 1/16): population window (9.50e-4, 5.52e-2) (r2(A)).

Per-query data: inputs (z, w) i.i.d. uniform, labels y = f_a(w) XOR 1_S(z) (environment-driven coins).
The lambda-MAP over the whole explicit class (coin; H(a',q) for all 64 parities a' and 64 rates q; S-cell aliens
A(a',q,T) for every parity, rate and cell set T) is computed exactly at each checkpoint:
for fixed (a', T) the best rate is a grid minimisation, and for fixed (a', t = |T|) the best T is the t
"eligible" cells (all samples disagree with f_a') with the most samples.  (A cell with an agreeing sample in T
gives infinite loss; an unsampled cell in T only adds length.)

Schedules: fixed lambda = 2 and 8; lambda = sqrt(n); lambda = c n with c = 4.9e-4 (below the window),
c = 7.2e-3 (geometric middle of the window) and c = 0.1 (above the window).
lambda = sqrt(n) keeps the human while sqrt(n)*Delta > n*H(p) (Delta = 355 bits for the full memoriser), i.e. up to
n ~ (Delta/H(p))^2 = 1.1e6, and then switches (Proposition 4.2: every lambda_n = o(n) eventually selects an alien).
Classes of the MAP: human = H(a, p); H(a,q) = right parity, other rate; alien(t) = right parity with t memorised
cells; wrong = any program with a wrong parity; coin.
"""
from math import comb, lgamma, log, log2, floor, ceil
import numpy as np

rng = np.random.default_rng(3)
du, m, s0 = 6, 10, 64
N, NW = 2 ** m, 2 ** du
p = s0 / N
Q = np.arange(64) / 64.0
LN2 = log(2.0)
lH = 2 + du + 6


def lc(n, k):
    return (lgamma(n + 1) - lgamma(k + 1) - lgamma(n - k + 1)) / LN2


def clc(n, k):
    """Exact ceil(log2 C(n, k)) in integers (revision fix of referee B's B9: ceil of the float lc
    is one bit too long when C(n, k) is a power of two)."""
    return (comb(n, k) - 1).bit_length()


LEN_A = np.array([lH + 2 * floor(log2(t + 1)) + 1 + clc(N, t) for t in range(N + 1)], float)
LEN_A[0] = lH                                    # t = 0 is the human-type program itself (shorter code)
W = np.arange(NW)
PAR = np.array([[bin(a & w).count("1") & 1 for w in W] for a in range(NW)], np.int8)   # f_a(w)
with np.errstate(divide="ignore"):
    L1Q, L0Q = -np.log2(Q), -np.log2(1 - Q)       # cost of a disagreement / agreement under rate q


def best_fit(Dt, A):
    """min over q in Q of Dt*log(1/q) + A*log(1/(1-q)), vectorised over Dt (array); q = 0 allowed iff Dt = 0."""
    Dt = np.asarray(Dt, float)[:, None]
    with np.errstate(invalid="ignore"):
        v = Dt * L1Q[None, :] + A * L0Q[None, :]
    v = np.where(np.isnan(v), 0.0, v)            # 0 * inf (q = 0, Dt = 0) := 0
    j = np.argmin(v, axis=1)
    return v[np.arange(len(j)), j], Q[j]


def map_at(Cz, lam_list, a_true):
    """Cz: (N, NW) counts.  Returns, for each lambda, (class, t, q, parity)."""
    n = Cz.sum()
    k = Cz.sum(axis=1)                                            # samples per cell
    best = [(np.inf, None)] * len(lam_list)
    out = [None] * len(lam_list)
    cand = [("coin", 0, None, None, 2.0, float(n))]
    yflip = BETA[:, None] ^ PAR[a_true][None, :]                  # y(z,w) XOR ... : label = f_a(w) ^ beta(z)
    for ap in range(NW):
        dis_zw = (yflip ^ PAR[ap][None, :]).astype(bool)          # sample at (z,w) disagrees with f_ap
        dis = (Cz * dis_zw).sum(axis=1)                           # disagreements per cell
        D = dis.sum()
        elig = (dis == k) & (k >= 1)
        ks = np.sort(k[elig])[::-1]
        cumk = np.r_[0, np.cumsum(ks)]
        Fv, Fq = best_fit(D - cumk, n - D)
        T = len(cumk)
        cand.append((ap, T, Fv, Fq, None, None))
    for li, lam in enumerate(lam_list):
        bJ, bdesc = 2 * lam + n, ("coin", 0, None, None)
        for c in cand[1:]:
            ap, T, Fv, Fq, _, _ = c
            J = lam * LEN_A[:T] + Fv
            t = int(np.argmin(J))
            if J[t] < bJ - 1e-9:
                bJ, bdesc = J[t], (ap, t, Fq[t])
        out[li] = bdesc
    return out


def classify(desc, a_true):
    if desc[0] == "coin":
        return "coin"
    ap, t, q = desc
    if ap != a_true:
        return "wrong"
    if t == 0:
        return "human" if abs(q - p) < 1e-12 else f"H(q={q:.3f})"
    return f"alien(t={t})"


RUNS = 10
CHECK = [100, 300, 1000, 3000, 10000, 30000, 100000, 300000, 1000000, 3000000, 10000000]
NMAX = CHECK[-1]
SCHED = [("lam=2", lambda n: 2.0), ("lam=8", lambda n: 8.0), ("lam=sqrt(n)", lambda n: n ** 0.5),
         ("c=4.9e-4", lambda n: 4.9e-4 * n), ("c=7.2e-3", lambda n: 7.2e-3 * n), ("c=0.1", lambda n: 0.1 * n)]
res = {name: {n: [] for n in CHECK} for name, _ in SCHED}
for r in range(RUNS):
    a_true = int(rng.integers(1, NW))
    S = rng.choice(N, size=s0, replace=False)
    BETA = np.zeros(N, np.int8)
    BETA[S] = 1
    z = rng.integers(0, N, NMAX).astype(np.int32)
    w = rng.integers(0, NW, NMAX).astype(np.int32)
    Cz = np.zeros((N, NW), np.int64)
    prev = 0
    for n in CHECK:
        np.add.at(Cz, (z[prev:n], w[prev:n]), 1)
        prev = n
        lams = [f(n) for _, f in SCHED]
        outs = map_at(Cz, lams, a_true)
        for (name, _), d in zip(SCHED, outs):
            res[name][n].append(classify(d, a_true))

print(f"du={du}, m={m}, s0={s0}, p={p}; population window (s_plus, s_minus) = (9.50e-4, 5.52e-2) (r2(A)).")
print(f"{RUNS} runs; each cell lists the MAP classes over the runs (count x class).\n")
for name, _ in SCHED:
    print(f"schedule {name}:")
    for n in CHECK:
        vals, cnts = np.unique(res[name][n], return_counts=True)
        order = np.argsort(-cnts)
        txt = ", ".join(f"{cnts[i]}x {vals[i]}" for i in order)
        print(f"  n={n:8d}: {txt}")
    print()
