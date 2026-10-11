"""r6 (referee): exploratory evidence on open question Q1 (can the K(n) in Thm 3.8 be dropped?).

Thm 3.8 builds, for each horizon n, a random function G_n with
    max_f  E_{x|f}[-log2 G_n(D_n)] - E_{x|f}[L_P^{(n)}]  =: V_n  <= 0      (non-peeking Delta),
and pays K(n) to name the horizon.  A horizon-free version needs ONE G that is good at every horizon.
Here, on small worlds (X = {0,1,2}, Y = {0,1}, horizons 1..4), we compute
    V_joint := min_G max_{n <= 4} max_f [ E_{x|f}[-log2 G(D_n)] - E_{x|f}[L_P^{(n)}] ]
and compare with max_n V_n.  V_joint > max_n V_n means the horizon-specific minimax random functions are
incompatible; V_joint > 0 would mean that no single random function matches P at every horizon with
additive constant 0 (it says nothing about a constant O(1) bound).  Certified brackets as in r2
(fictitious play upper bound; EM + Frank-Wolfe lower bound).
Seed 606.  Output: r6_horizon_free.out.
"""
import itertools, math
import numpy as np

SEED = 606
rng = np.random.default_rng(SEED)
LN2 = math.log(2)
X = (0, 1, 2); Y = (0, 1); NMAX = 4
F = list(itertools.product(Y, repeat=len(X)))
H = {k: list(itertools.product(itertools.product(X, Y), repeat=k)) for k in range(NMAX + 1)}


def cons(h):
    D = set(h)
    return np.array([all(g[x] == y for x, y in D) for g in F], dtype=float)


def rows_for(Delta, P, n):
    rows = []
    for f in F:
        probs, A, ELP = [], [], 0.0
        for xs in itertools.product(X, repeat=n):
            h = tuple((x, f[x]) for x in xs)
            p = 1.0
            for i, x in enumerate(xs):
                p *= Delta[h[:i]][x]
            if p == 0:
                continue
            lp = 0.0
            for i, (x, y) in enumerate(h):
                lp += -math.log2(P[(h[:i], x)][y])
            probs.append(p); A.append(cons(h)); ELP += p * lp
        rows.append((np.array(probs), np.array(A), ELP))
    return rows


def phi(rows, G):
    return np.array([np.dot(pr, -np.log2(np.maximum(A @ G, 1e-300))) - e for pr, A, e in rows])


def best_response(rows, pi, iters):
    wts = np.concatenate([pi[k] * rows[k][0] for k in range(len(rows))])
    A = np.vstack([r[1] for r in rows])
    keep = wts > 0
    wts, A = wts[keep], A[keep]
    tot = wts.sum()
    G = np.ones(A.shape[1]) / A.shape[1]
    for _ in range(iters):
        G = G * (A.T @ (wts / (A @ G))) / tot
    r = A @ G
    gap = (((A.T @ (wts / r)) / tot).max() - 1.0) * tot / LN2
    return G, np.dot(wts, -np.log2(r)) - gap


def bracket(rows, T=500, eta=0.4):
    k = len(rows)
    ELPs = np.array([r[2] for r in rows])
    logw = np.zeros(k); Gs = []; pis = []
    for t in range(T):
        pi = np.exp(logw - logw.max()); pi /= pi.sum()
        G, _ = best_response(rows, pi, 150)
        Gs.append(G); pis.append(pi)
        logw += eta * phi(rows, G)
    Gbar = np.mean(Gs, axis=0); pibar = np.mean(pis, axis=0)
    _, lb = best_response(rows, pibar, 4000)
    return lb - np.dot(pibar, ELPs), phi(rows, Gbar).max()


def rand_Delta():
    return {h: rng.dirichlet(np.ones(len(X)) * 0.6) for k in range(NMAX) for h in H[k]}


def rand_P(sharp=0.6):
    return {(h, x): rng.dirichlet(np.ones(len(Y)) * sharp) for k in range(NMAX) for h in H[k] for x in X}


def copy_P(q):
    P = {}
    for k in range(NMAX):
        for h in H[k]:
            for x in X:
                if k == 0:
                    P[(h, x)] = np.array([0.5, 0.5])
                else:
                    P[(h, x)] = np.array([q if y == h[-1][1] else 1 - q for y in Y])
    return P


def switch_P(q):
    """predicts like 'copy the last label' at even times and 'flip the last label' at odd times"""
    P = {}
    for k in range(NMAX):
        for h in H[k]:
            for x in X:
                if k == 0:
                    P[(h, x)] = np.array([0.5, 0.5])
                else:
                    target = h[-1][1] if k % 2 == 0 else 1 - h[-1][1]
                    P[(h, x)] = np.array([q if y == target else 1 - q for y in Y])
    return P


def main():
    lines = []
    worst_joint = -math.inf
    worst_excess = -math.inf
    cases = []
    for inst in range(3):
        D = rand_Delta()
        cases += [(f"inst {inst} random P", D, rand_P()), (f"inst {inst} copy P q=0.95", D, copy_P(0.95)),
                  (f"inst {inst} switch P q=0.95", D, switch_P(0.95))]
    for name, D, P in cases:
        per = [rows_for(D, P, n) for n in range(1, NMAX + 1)]
        Vn = [bracket(r) for r in per]
        joint_rows = [row for r in per for row in r]
        lo, up = bracket(joint_rows)
        maxVn_up = max(v[1] for v in Vn)
        maxVn_lo = max(v[0] for v in Vn)
        worst_joint = max(worst_joint, lo)
        worst_excess = max(worst_excess, lo - maxVn_up)
        lines.append(f"{name:26s}: V_n brackets " + ", ".join(f"[{a:+.3f},{b:+.3f}]" for a, b in Vn)
                     + f" | V_joint in [{lo:+.4f}, {up:+.4f}]")
    lines.append(f"largest certified lower bound on V_joint: {worst_joint:+.4f}; largest certified (V_joint - max_n V_n): "
                 f"{worst_excess:+.4f}")
    lines.append("Interpretation: a positive certified lower bound on V_joint - max_n V_n means the horizon-specific minimax "
                 "random functions are incompatible: one G for all horizons must pay a positive constant.  It says nothing "
                 "about whether that constant must grow with n (see r7).")
    for l in lines:
        print(l)


if __name__ == "__main__":
    main()
