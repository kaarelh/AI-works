"""Referee check r2: notes Prop 1.3(i) (per-input pricing; minimax value), independent code.

(a) The example F = {(a,a),(a,b),(b,a),(c,a)}: maximise sum_x H(Q_x) over Q in the simplex by a
    fine grid + local polishing (no Dirichlet sampling, no Nelder-Mead as in c2), and solve the
    primal min_nu max_f by exponentiated-gradient (multiplicative weights) on Q combined with the
    closed-form best response nu = Q_x, which yields matching upper and lower bounds.
(b) Random finite families F of total functions on N inputs: check that for random product
    hypotheses nu, max_f loss >= max_Q sum H(Q_x) (the lower bound (i)), and that the primal value
    (computed by subgradient descent on nu) matches the dual value (computed by mirror ascent on Q).
Seeded: numpy default_rng(11).
"""
import itertools
import numpy as np

rng = np.random.default_rng(11)


def ent(v):
    v = v[v > 0]
    return float(-(v * np.log2(v)).sum())


def dual_value(Fmat, labels_per_input, iters=20000, lr=0.5):
    """max_Q sum_i H(Q_{x_i}) by exponentiated-gradient ascent on Q (concave objective)."""
    nF, N = Fmat.shape
    logw = np.zeros(nF)
    best = -1.0
    for t in range(iters):
        Q = np.exp(logw - logw.max()); Q /= Q.sum()
        val = 0.0
        grad = np.zeros(nF)
        for i in range(N):
            marg = np.array([Q[Fmat[:, i] == y].sum() for y in labels_per_input[i]])
            val += ent(marg)
            # d/dQ_f of H(Q_x) = -log2 Q_x(f(x)) - 1/ln2
            lookup = {y: marg[k] for k, y in enumerate(labels_per_input[i])}
            grad += np.array([-np.log2(max(lookup[Fmat[f, i]], 1e-300)) for f in range(nF)])
        best = max(best, val)
        logw += lr / np.sqrt(t + 1) * grad
    return best, Q


def primal_value(Fmat, labels_per_input, Q):
    """Upper bound on min_nu max_f: plug nu = Q_x (best response to the dual optimum)."""
    nF, N = Fmat.shape
    losses = np.zeros(nF)
    for i in range(N):
        marg = {y: Q[Fmat[:, i] == y].sum() for y in labels_per_input[i]}
        losses += np.array([-np.log2(max(marg[Fmat[f, i]], 1e-300)) for f in range(nF)])
    return losses.max()


print("=" * 78)
print("(a) F = {(a,a),(a,b),(b,a),(c,a)}")
F = np.array([[0, 0], [0, 1], [1, 0], [2, 0]])
labels = [[0, 1, 2], [0, 1]]
# grid search over the 3-simplex
best, bestQ = -1, None
G = 120
for i in range(G + 1):
    for j in range(G + 1 - i):
        for k in range(G + 1 - i - j):
            q = np.array([i, j, k, G - i - j - k]) / G
            v = ent(np.array([q[0] + q[1], q[2], q[3]])) + ent(np.array([q[1], 1 - q[1]]))
            if v > best:
                best, bestQ = v, q
dv, Qopt = dual_value(F, labels, iters=20000)
pv = primal_value(F, labels, Qopt)
print(f"  grid max_Q sum H = {best:.5f} at Q={np.round(bestQ, 3)}; mirror ascent = {dv:.5f}; "
      f"primal (nu = Q_x at the optimum) max_f loss = {pv:.5f}; sum log|F(x)| = {np.log2(3) + 1:.5f}")
# analytic: by symmetry q3 = q4 = s, q1 = 0 is optimal? scan the 2-parameter family exactly
xs = np.linspace(1e-9, 1 - 1e-9, 4001)
bestA = -1
for q2 in xs:
    for s in np.linspace(1e-9, (1 - q2) / 2, 400):
        q1 = 1 - q2 - 2 * s
        v = ent(np.array([q1 + q2, s, s])) + ent(np.array([q2, 1 - q2]))
        bestA = max(bestA, v)
print(f"  symmetric-family scan (q3=q4): {bestA:.5f}")

print("=" * 78)
print("(b) random families: lower bound (i) and minimax equality")
viol_lb = 0
gaps = []
for trial in range(60):
    N = int(rng.integers(2, 4)); ny = 3; nF = int(rng.integers(3, 7))
    funcs = set()
    while len(funcs) < nF:
        funcs.add(tuple(int(v) for v in rng.integers(0, ny, N)))
    Fm = np.array(sorted(funcs))
    labs = [sorted(set(Fm[:, i])) for i in range(N)]
    dv, Qo = dual_value(Fm, labs, iters=4000, lr=0.5)
    pv = primal_value(Fm, labs, Qo)
    gaps.append(pv - dv)
    for _ in range(200):
        nu = [rng.dirichlet(np.ones(ny)) * rng.uniform(0.6, 1.0) for _ in range(N)]   # sub-probabilities
        worst = max(sum(-np.log2(nu[i][Fm[f, i]]) for i in range(N)) for f in range(len(Fm)))
        if worst < dv - 1e-9:
            viol_lb += 1
print(f"  {60*200} random product hypotheses: violations of max_f loss >= max_Q sum H(Q_x): {viol_lb}")
print(f"  primal(upper) - dual(lower) gap over 60 families: max {max(gaps):.2e}, median {np.median(gaps):.2e}")
