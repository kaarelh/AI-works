"""r5: a human with latent state (notes Section 5: Proposition 5.1, Proposition 5.2, Proposition 5.3).
Seeded: numpy default_rng(5).

The human: a hidden mood s in {0,1}, stationary start (1/2, 1/2), stays with probability 15/16; in mood s it
answers y = 1 with probability theta_s, theta = (3/16, 13/16); fresh private coins at every step.
Family: all HMMs of this form with theta_0, theta_1, stay in {1/16, ..., 15/16} (3375 members), index code 12 bits.
Class (chronological predictors; Kraft sum <= 1):
  pi_theta  "family prefix (8 bits) + index (12 bits)": the HMM theta                  l = 20  (3375 programs)
  pi_U      "family prefix + 2 bits": the Bayes mixture sum_theta 2^-12 P_theta         l = 10  (an in-context
            learner: it infers the human's parameters, and the mood, from the history)
  Bern(q)   memoryless sampler, q in {j/16}                                               l = 12
  coin                                                                                     l = 2
The true human is pi_theta* with theta* = (3/16, 13/16, 15/16); its mirror image (13/16, 3/16, 15/16) has the
same law (label switching), so the class contains two shortest programs for the human's law.

(A) Ville survives: delta* = sup_n log2(xi_n / P_H) over single trajectories has P[delta* >= j] <= 2^-j.
(B) Single trajectory: L(U) <= L(theta) + 12 for every theta and every data, so at lambda = 2,
    J(U) <= 20 + L(theta*) + 12 < 40 + L(theta*) = J(theta*) at every n: the human's program is never selected.
(C) Episodes of T steps (fresh human from its initial state each time; every program, the mixture included,
    restarts at the episode boundary): the mixture pays its regret in every episode, and the lambda-MAP becomes a
    shortest program for the human's episode law (theta* or its mirror image).
"""
import numpy as np

rng = np.random.default_rng(5)
G = np.arange(1, 16) / 16.0
T0, T1, ST = np.meshgrid(G, G, G, indexing="ij")
TH0, TH1, STAY = T0.ravel(), T1.ravel(), ST.ravel()          # 3375 family members
NF = len(TH0)
true = (3 / 16, 13 / 16, 15 / 16)
i_true = int(np.flatnonzero((TH0 == true[0]) & (TH1 == true[1]) & (STAY == true[2]))[0])
i_mirror = int(np.flatnonzero((TH0 == true[1]) & (TH1 == true[0]) & (STAY == true[2]))[0])
L_THETA, L_U, L_BERN, L_COIN = 20, 10, 12, 2
QB = np.arange(1, 16) / 16.0
kraft = NF * 2.0 ** -L_THETA + 2.0 ** -L_U + len(QB) * 2.0 ** -L_BERN + 2.0 ** -L_COIN
print(f"Kraft sum = {kraft:.6f} (must be <= 1); family weight sum = {NF * 2.0**-12:.4f}")
assert kraft <= 1


def sample(n):
    s = int(rng.random() < 0.5)
    y = np.empty(n, np.int8)
    for i in range(n):
        y[i] = rng.random() < (true[1] if s else true[0])
        if rng.random() >= true[2]:
            s = 1 - s
    return y


def forward_all(y):
    """Per-step log2 predictive probabilities for every family member (NF, n), stationary start (1/2, 1/2)."""
    n = len(y)
    a = np.full((NF, 2), 0.5)
    out = np.empty((NF, n))
    for i in range(n):
        e0 = np.where(y[i] == 1, TH0, 1 - TH0)
        e1 = np.where(y[i] == 1, TH1, 1 - TH1)
        joint0, joint1 = a[:, 0] * e0, a[:, 1] * e1
        pred = joint0 + joint1
        out[:, i] = np.log2(pred)
        f0, f1 = joint0 / pred, joint1 / pred
        a = np.stack([f0 * STAY + f1 * (1 - STAY), f1 * STAY + f0 * (1 - STAY)], axis=1)
    return out


def logsumexp2(v, axis=0):
    mx = v.max(axis=axis, keepdims=True)
    return (mx + np.log2(np.exp2(v - mx).sum(axis=axis, keepdims=True))).squeeze(axis)


print("\n(A) Ville deficiency over single trajectories (400 runs, n = 1500)")
runs, n = 400, 1500
dst = np.empty(runs)
for r in range(runs):
    y = sample(n)
    lp = np.cumsum(forward_all(y), axis=1)                    # log2 P_theta(y_{1:k}) for all theta, k
    lH = lp[i_true]
    lU = logsumexp2(lp - 12, axis=0)                         # log2 P_U
    k1 = np.cumsum(y)
    kk = np.arange(1, n + 1)
    lB = k1[None, :] * np.log2(QB)[:, None] + (kk - k1)[None, :] * np.log2(1 - QB)[:, None]
    terms = np.vstack([lp - L_THETA, (lU - L_U)[None, :], lB - L_BERN, (-kk - L_COIN)[None, :]])
    logxi = logsumexp2(terms, axis=0)
    dst[r] = max(0.0, (logxi - lH).max())
for j in (1, 2, 3, 4, 6):
    print(f"  j={j}: P_emp[delta* >= j] = {np.mean(dst >= j):.4f}   2^-j = {2.0**-j:.4f}")

print("\n(B) One trajectory, lambda = 2: J(U) - J(theta*) and the lambda-MAP")
for r in range(3):
    n = 4000
    y = sample(n)
    lp = np.cumsum(forward_all(y), axis=1)
    lU = logsumexp2(lp - 12, axis=0)
    lH = lp[i_true]
    lam = 2.0
    diff = (lam * L_U - lU) - (lam * L_THETA - lH)          # J(U) - J(theta*)
    k1 = np.cumsum(y)
    kk = np.arange(1, n + 1)
    best_member = (lam * L_THETA - lp).min(axis=0)
    JB = (lam * L_BERN - (k1[None, :] * np.log2(QB)[:, None] + (kk - k1)[None, :] * np.log2(1 - QB)[:, None])).min(axis=0)
    JU = lam * L_U - lU
    JC = lam * L_COIN + kk
    winner = np.argmin(np.vstack([JU, best_member, JB, JC]), axis=0)
    names = np.array(["U (in-context learner)", "a family member", "Bern(q)", "coin"])
    print(f"  run {r}: max_n [J(U) - J(theta*)] = {diff.max():.2f} (must be < 0; bound 2*10 + 12 - 2*20 = -8);"
          f" MAP at n = 100, 1000, 4000: {', '.join(names[winner[[99, 999, 3999]]])}")
    print(f"         L(U) - L(theta*) at n = 100, 1000, 4000: "
          f"{(-(lU - lH))[[99, 999, 3999]].round(2).tolist()}  (at most 12 = log2(1/w))")

print("\n(C) Episodes of T = 20 steps, lambda = 2 (every program restarts at each episode boundary)")
T, NE, runs = 20, 3000, 12
switch, map_end = [], []
regret_all = []
for r in range(runs):
    lpe = np.empty((NF, NE))
    ys = np.empty((NE, T), np.int8)
    for e in range(NE):
        ys[e] = sample(T)
    # vectorise over episodes: run the forward pass on all episodes at once per step
    a = np.full((NF, NE, 2), 0.5)
    acc = np.zeros((NF, NE))
    for t in range(T):
        yt = ys[:, t][None, :]
        e0 = np.where(yt == 1, TH0[:, None], 1 - TH0[:, None])
        e1 = np.where(yt == 1, TH1[:, None], 1 - TH1[:, None])
        j0, j1 = a[:, :, 0] * e0, a[:, :, 1] * e1
        pred = j0 + j1
        acc += np.log2(pred)
        f0, f1 = j0 / pred, j1 / pred
        st = STAY[:, None]
        a = np.stack([f0 * st + f1 * (1 - st), f1 * st + f0 * (1 - st)], axis=2)
    lpe = acc                                                  # log2 P_theta(episode e)
    lUe = logsumexp2(lpe - 12, axis=0)                         # mixture restarted each episode
    reg = lpe[i_true] - lUe                                    # per-episode regret of U against the human (>= -12)
    regret_all.append(reg)
    cH = np.cumsum(lpe[i_true])
    cU = np.cumsum(lUe)
    d = (2 * L_U - cU) - (2 * L_THETA - cH)                   # J(U) - J(theta*) after e episodes
    first = int(np.argmax(d > 0)) + 1 if (d > 0).any() else None
    last_neg = int(np.flatnonzero(d <= 0).max()) + 1 if (d <= 0).any() else 0
    switch.append((first, last_neg))
    Jm = 2 * L_THETA - lpe.sum(axis=1)                         # J of every family member after NE episodes
    JU_end = 2 * L_U - cU[-1]
    kB = ys.sum()
    JB_end = (2 * L_BERN - (kB * np.log2(QB) + (NE * T - kB) * np.log2(1 - QB))).min()
    JC_end = 2 * L_COIN + NE * T
    jmin = min(Jm.min(), JU_end, JB_end, JC_end)
    winners = [("theta*" if i == i_true else "mirror(theta*)" if i == i_mirror else
                f"member({TH0[i]:.4f},{TH1[i]:.4f},{STAY[i]:.4f})") for i in np.flatnonzero(Jm <= jmin + 1e-6)]
    if JU_end <= jmin + 1e-6:
        winners.append("U")
    if JB_end <= jmin + 1e-6:
        winners.append("Bern(q)")
    if JC_end <= jmin + 1e-6:
        winners.append("coin")
    map_end.append(" and ".join(winners) + f" (|J(theta*) - J(mirror)| = {abs(Jm[i_true] - Jm[i_mirror]):.1e})")
reg = np.concatenate(regret_all)
print(f"  mean per-episode regret of the restarted mixture against the human: {reg.mean():.4f} bits"
      f" (s.e. {reg.std() / np.sqrt(len(reg)):.4f}); predicted switch after about 20/regret ="
      f" {20 / reg.mean():.0f} episodes")
for r, (first, last) in enumerate(switch):
    print(f"  run {r:2d}: theta* first beats U after {first} episodes, last time U is not beaten: {last};"
          f" lambda-MAPs after {NE} episodes: {map_end[r]}")
