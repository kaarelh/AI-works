"""rb5 (referee B): in-context learners and latent state (notes Remark 2.4, Proposition 5.1, Proposition 5.2,
Remark 5.4, Section 6.1 item 1).  Seeded: numpy default_rng(505) (A), (506) (B), (507) (C).

(A) An i.i.d. human with PRIVATE per-query coins and a history-aware class.  x uniform on {0,1,2,3}; the human
    answers y ~ Bern(theta*(x)), theta* = (1/8, 3/8, 5/8, 7/8), fresh coins at every query.  Family: all product
    kernels theta in {1/8, ..., 7/8}^4 (2401 members): program = 8-bit family prefix + 12-bit index, l = 20.
    Learner U: the Bayes mixture sum_theta 2^-12 P_theta, a chronological predictor (posterior predictive),
    l = 10.  Coin l = 2.  Proposition 5.2's bound J(U) - J(theta*) <= lambda(10 - 20) + 12 holds for every data,
    so at lambda = 2 the human's program is never a lambda-MAP although the coins are private per query.  The
    same class without U (a product class) selects theta* eventually (Theorem A).  This tests the reading of
    Section 6.1 item 1 ('[the learner] is not a single hypothesis when randomness is private to each query').
(B) A hidden-Markov human on ONE trajectory, in a finite class WITHOUT a dominating member (notes Remark 5.4(3),
    open): 343 HMMs (theta_0, theta_1, stay in {1/8..7/8}^3; l = 20), memoryless Bern(q) (q in {j/16}; l = 12),
    coin (l = 2); lambda = 2.  Human theta* = (1/8, 7/8, 7/8).  Does the lambda-MAP settle on theta* or its
    mirror image?  Evidence only, 10 runs to n = 20000.
(C) Proposition 5.1 (Ville on single HMM trajectories), with the sharper bound M_0 2^-j (M_0 = Kraft sum):
    the class of (B) plus the mixture U over the 343 HMMs (l = 10), 4000 runs of n = 300.
"""
import numpy as np

# ---------------------------------------------------------------- (A)
print("(A) i.i.d. human with private coins; history-aware class with a Bayes-mixture learner; lambda = 2")
rng = np.random.default_rng(505)
G = np.arange(1, 8) / 8.0
th_star = np.array([1, 3, 5, 7]) / 8.0
L_TH, L_U, L_COIN, IDX = 20, 10, 2, 12
kraft = 7 ** 4 * 2.0 ** -L_TH + 2.0 ** -L_U + 2.0 ** -L_COIN
print(f"  Kraft sum = {kraft:.5f}; bound on J(U) - J(theta*) at lambda = 2: 2*(10-20) + 12 = -8 at every n")
ck = np.array([10, 30, 100, 300, 1000, 3000, 10000, 30000, 100000])
lam = 2.0
worst = -np.inf
maps_with, maps_without = [], []
for r in range(20):
    x = rng.integers(0, 4, ck[-1])
    y = (rng.random(ck[-1]) < th_star[x]).astype(int)
    row_w, row_wo = [], []
    for n in ck:
        k1 = np.array([np.sum((x[:n] == j) & (y[:n] == 1)) for j in range(4)])
        k0 = np.array([np.sum((x[:n] == j) & (y[:n] == 0)) for j in range(4)])
        ll = k1[:, None] * np.log2(G)[None, :] + k0[:, None] * np.log2(1 - G)[None, :]   # (4 inputs, 7 values)
        lstar = sum(ll[j, int(round(th_star[j] * 8)) - 1] for j in range(4))
        best_member = ll.max(axis=1).sum()                                        # best product member
        mx = ll.max(axis=1, keepdims=True)
        lU = -IDX + float((mx[:, 0] + np.log2(np.exp2(ll - mx).sum(axis=1))).sum())   # mixture factorises
        JU, Jstar, Jbest, Jc = lam * L_U - lU, lam * L_TH - lstar, lam * L_TH - best_member, lam * L_COIN + n
        worst = max(worst, JU - Jstar)
        nm = ["U", "member", "coin"][int(np.argmin([JU, Jbest, Jc]))]
        if nm == "member":
            nm = "theta*" if abs(Jbest - Jstar) < 1e-9 else "other member"
        row_w.append(nm)
        nm2 = ["member", "coin"][int(np.argmin([Jbest, Jc]))]
        if nm2 == "member":
            nm2 = "theta*" if abs(Jbest - Jstar) < 1e-9 else "other member"
        row_wo.append(nm2)
    maps_with.append(row_w)
    maps_without.append(row_wo)
print(f"  max over 20 runs and all checkpoints of J(U) - J(theta*) = {worst:.2f} (must be <= -8)")
for name, mp in (("with the learner U", maps_with), ("product class (no U)", maps_without)):
    mp = np.array(mp)
    print(f"  {name}: MAP at n = " + "; ".join(
        f"{n}: " + ",".join(f"{v}x{c}" for v, c in zip(*np.unique(mp[:, i], return_counts=True)))
        for i, n in enumerate(ck) if n in (100, 1000, 10000, 100000)))

# ---------------------------------------------------------------- HMM helpers
GH = np.arange(1, 8) / 8.0
T0, T1, ST = np.meshgrid(GH, GH, GH, indexing="ij")
TH0, TH1, STAY = T0.ravel(), T1.ravel(), ST.ravel()
NF = len(TH0)
true = (1 / 8, 7 / 8, 7 / 8)
i_true = int(np.flatnonzero((TH0 == true[0]) & (TH1 == true[1]) & (STAY == true[2]))[0])
i_mir = int(np.flatnonzero((TH0 == true[1]) & (TH1 == true[0]) & (STAY == true[2]))[0])


def sample_hmm(rng, n, runs):
    s = (rng.random(runs) < 0.5).astype(int)
    y = np.empty((runs, n), np.int8)
    for i in range(n):
        p1 = np.where(s == 1, true[1], true[0])
        y[:, i] = rng.random(runs) < p1
        flip = rng.random(runs) >= true[2]
        s = np.where(flip, 1 - s, s)
    return y


def forward_logs(y):
    """y: (runs, n).  Returns per-step log2 predictive probabilities for all NF members: (NF, runs, n)."""
    runs, n = y.shape
    a0 = np.full((NF, runs), 0.5)
    a1 = np.full((NF, runs), 0.5)
    out = np.empty((NF, runs, n))
    t0, t1, st = TH0[:, None], TH1[:, None], STAY[:, None]
    for i in range(n):
        yi = y[None, :, i]
        e0 = np.where(yi == 1, t0, 1 - t0)
        e1 = np.where(yi == 1, t1, 1 - t1)
        j0, j1 = a0 * e0, a1 * e1
        pr = j0 + j1
        out[:, :, i] = np.log2(pr)
        f0, f1 = j0 / pr, j1 / pr
        a0, a1 = f0 * st + f1 * (1 - st), f1 * st + f0 * (1 - st)
    return out


# ---------------------------------------------------------------- (B)
print("\n(B) one trajectory, finite HMM class without a dominating member, lambda = 2 (10 runs, n up to 20000)")
rng = np.random.default_rng(506)
QB = np.arange(1, 16) / 16.0
nB = 20000
y = sample_hmm(rng, nB, 10)
lp = np.cumsum(forward_logs(y), axis=2)                         # (NF, runs, n)
ckB = [100, 300, 1000, 3000, 10000, 20000]
for r in range(10):
    row = []
    for n in ckB:
        Jm = 2 * 20 - lp[:, r, n - 1]
        k1 = int(y[r, :n].sum())
        JB = (2 * 12 - (k1 * np.log2(QB) + (n - k1) * np.log2(1 - QB))).min()
        JC = 2 * 2 + n
        j = int(np.argmin(Jm))
        best = min(Jm[j], JB, JC)
        if best == JC:
            row.append("coin")
        elif best == JB:
            row.append("Bern")
        elif j in (i_true, i_mir):
            row.append("theta*")
        else:
            row.append(f"({TH0[j]:.3f},{TH1[j]:.3f},{STAY[j]:.3f})")
    print(f"  run {r}: MAP at n = {ckB}: {row}")
del lp

# ---------------------------------------------------------------- (C)
print("\n(C) Ville tail on single HMM trajectories: 4000 runs of n = 300; class = (B) + mixture U (l = 10)")
rng = np.random.default_rng(507)
runs, nC = 4000, 300
L_M = 20
kr = NF * 2.0 ** -L_M + 2.0 ** -10 + len(QB) * 2.0 ** -12 + 2.0 ** -2
dstar = np.empty(runs)
for b0 in range(0, runs, 500):                                  # batches of 500 runs (memory)
    y = sample_hmm(rng, nC, 500)
    lp = np.cumsum(forward_logs(y), axis=2)                     # (NF, 500, n)
    lH = lp[i_true]
    mx = lp.max(axis=0)
    lU = mx + np.log2(np.exp2(lp - mx[None]).sum(axis=0)) - 9  # uniform weights 2^-9 (343 <= 512)
    k1 = np.cumsum(y, axis=1)
    kk = np.arange(1, nC + 1)[None, :]
    lB = k1[None] * np.log2(QB)[:, None, None] + (kk - k1)[None] * np.log2(1 - QB)[:, None, None]
    allt = np.concatenate([lp - L_M, (lU - 10)[None], lB - 12, (-kk - 2.0 + 0 * lH)[None]], axis=0)
    m2 = allt.max(axis=0)
    logxi = m2 + np.log2(np.exp2(allt - m2[None]).sum(axis=0))
    dstar[b0:b0 + 500] = np.maximum(0, (logxi - lH).max(axis=1))
    del lp, allt
print(f"  Kraft sum M_0 = {kr:.5f}")
for j in (0.5, 1, 2, 3, 4, 6):
    print(f"  P_emp[delta* >= {j}] = {np.mean(dstar >= j):.4f}  (s.e. {np.sqrt(np.mean(dstar >= j) * (1 - np.mean(dstar >= j)) / runs):.4f})"
          f"   M_0 2^-j = {kr * 2.0 ** -j:.4f}   2^-j = {2.0 ** -j:.4f}")
