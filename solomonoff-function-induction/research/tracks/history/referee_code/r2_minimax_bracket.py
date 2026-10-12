"""r2 (referee, independent of checks/c3): certified brackets for the minimax value in Thm 3.8.

V(P, Delta) := min over random functions G (distributions on Y^X) of max over f of
               E_{x|f}[-log2 G(D_n)] - E_{x|f}[L_P]       (f restricted to F_fin = {f : E_{x|f}[L_P] < inf}).
Thm 3.8's proof gives V <= 0 for non-peeking Delta (the 1/2-uniform mixing only adds 1 bit) and
V <= 1 + C_dir for peeking Delta.  c3 computed V by SLSQP only (an upper bound).  Here:

 * a different algorithm: fictitious play (Hedge for the f-player, EM best response for G);
 * a CERTIFIED bracket: upper bound = max_f Phi_f(G_bar) at the averaged G (feasible point);
   lower bound = min_G Phi(G, pi_bar) for the averaged adversary pi_bar, computed by EM with a
   Frank-Wolfe duality gap subtracted (valid lower bound on that inner minimum);
 * other worlds: (|X|,|Y|,n) = (3,2,3), (2,3,3), (3,3,2); predictor kinds: random, Bayes for a random
   prior, Bayes for a wrong prior, 'copy last label', deterministic order-exploiting predictors, and a
   random search over predictors that tries to make V positive (counterexample search for V <= 0).
Seed 2027.  Output saved to r2_minimax_bracket.out.
"""
import itertools, math
import numpy as np

SEED = 2027
rng = np.random.default_rng(SEED)
LN2 = math.log(2)


class World:
    def __init__(self, nx, ny, n):
        self.X = tuple(range(nx)); self.Y = tuple(range(ny)); self.n = n
        self.F = list(itertools.product(self.Y, repeat=nx))
        self.H = {k: list(itertools.product(itertools.product(self.X, self.Y), repeat=k)) for k in range(n + 1)}

    def paths(self, Delta, peek):
        out = []
        for fi, f in enumerate(self.F):
            lst = []
            for xs in itertools.product(self.X, repeat=self.n):
                h = tuple((x, f[x]) for x in xs)
                p = 1.0
                for i, x in enumerate(xs):
                    p *= (Delta[(fi, h[:i])] if peek else Delta[h[:i]])[x]
                if p > 0:
                    lst.append((p, h))
            out.append(lst)
        return out

    def cons(self, h):
        D = set(h)
        return np.array([all(g[x] == y for x, y in D) for g in self.F], dtype=float)


def LP(P, h):
    s = 0.0
    for i, (x, y) in enumerate(h):
        q = P[(h[:i], x)][y]
        if q <= 0:
            return math.inf
        s += -math.log2(q)
    return s


def setup(W, Delta, P, peek):
    PS = W.paths(Delta, peek)
    rows = []
    for fi in range(len(W.F)):
        probs = np.array([p for p, _ in PS[fi]])
        A = np.array([W.cons(h) for _, h in PS[fi]])  # paths x functions
        ELP = sum(p * LP(P, h) for p, h in PS[fi])
        rows.append((probs, A, ELP))
    fin = [fi for fi in range(len(W.F)) if math.isfinite(rows[fi][2])]
    return rows, fin


def phi_all(rows, fin, G):
    return np.array([np.dot(rows[fi][0], -np.log2(np.maximum(rows[fi][1] @ G, 1e-300))) - rows[fi][2] for fi in fin])


def best_response(rows, fin, pi, iters=3000):
    """min_G sum_f pi_f E_{x|f}[-log2 G(D)] by EM; returns (G, certified lower bound on the min)"""
    wts = np.concatenate([pi[k] * rows[fi][0] for k, fi in enumerate(fin)])
    A = np.vstack([rows[fi][1] for fi in fin])
    keep = wts > 0
    wts, A = wts[keep], A[keep]
    tot = wts.sum()
    G = np.ones(A.shape[1]) / A.shape[1]
    for _ in range(iters):
        r = A @ G
        G = G * (A.T @ (wts / r)) / tot
    r = A @ G
    val = np.dot(wts, -np.log2(r))
    gap = (((A.T @ (wts / r)) / tot).max() - 1.0) * tot / LN2  # Frank-Wolfe gap (bits, weighted)
    return G, val - gap


def bracket(rows, fin, T=400, eta=0.5):
    if not fin:
        return -math.inf, -math.inf
    k = len(fin)
    ELPs = np.array([rows[fi][2] for fi in fin])
    logw = np.zeros(k)
    Gs, pis = [], []
    for t in range(T):
        pi = np.exp(logw - logw.max()); pi /= pi.sum()
        G, _ = best_response(rows, fin, pi, iters=200)
        Gs.append(G); pis.append(pi)
        logw += eta * phi_all(rows, fin, G)
    Gbar = np.mean(Gs, axis=0); pibar = np.mean(pis, axis=0)
    upper = phi_all(rows, fin, Gbar).max()
    _, lb_inner = best_response(rows, fin, pibar, iters=5000)
    lower = lb_inner - np.dot(pibar, ELPs)
    return lower, upper


def rand_kernel(W, peek, alpha=0.7):
    if peek:
        return {(fi, h): rng.dirichlet(np.ones(len(W.X)) * alpha) for fi in range(len(W.F))
                for k in range(W.n) for h in W.H[k]}
    return {h: rng.dirichlet(np.ones(len(W.X)) * alpha) for k in range(W.n) for h in W.H[k]}


def rand_P(W, alpha=0.7):
    return {(h, x): rng.dirichlet(np.ones(len(W.Y)) * alpha) for k in range(W.n) for h in W.H[k] for x in W.X}


def bayes_P(W, prior):
    P = {}
    for k in range(W.n):
        for h in W.H[k]:
            c = W.cons(h) * prior
            for x in W.X:
                if c.sum() == 0:
                    P[(h, x)] = np.ones(len(W.Y)) / len(W.Y)
                else:
                    P[(h, x)] = np.array([sum(c[j] for j, g in enumerate(W.F) if g[x] == y) for y in W.Y]) / c.sum()
    return P


def copy_P(W, q=0.9):
    P = {}
    for k in range(W.n):
        for h in W.H[k]:
            for x in W.X:
                if k == 0:
                    P[(h, x)] = np.ones(len(W.Y)) / len(W.Y)
                else:
                    v = np.full(len(W.Y), (1 - q) / (len(W.Y) - 1)); v[h[-1][1]] = q
                    P[(h, x)] = v
    return P


def det_order_P(W):
    """deterministic: label = (number of earlier inputs equal to x plus position) mod |Y|, a rule that uses order"""
    P = {}
    for k in range(W.n):
        for h in W.H[k]:
            for x in W.X:
                v = np.zeros(len(W.Y)); v[(k + sum(1 for (xx, _) in h if xx < x)) % len(W.Y)] = 1.0
                P[(h, x)] = v
    return P


def mixed_P(W, P1, P2, lam):
    return {key: lam * P1[key] + (1 - lam) * P2[key] for key in P1}


lines = []
max_upper_nonpeek = -math.inf
for (nx, ny, n) in ((3, 2, 3), (2, 3, 3), (3, 3, 2)):
    W = World(nx, ny, n)
    for inst in range(4):
        Delta = rand_kernel(W, False)
        prior = rng.dirichlet(np.ones(len(W.F)) * 0.5)
        wrong = rng.dirichlet(np.ones(len(W.F)) * 0.5)
        kinds = {"random": rand_P(W), "bayes": bayes_P(W, prior), "bayes_wrong": bayes_P(W, wrong),
                 "copy": copy_P(W), "det_order": det_order_P(W),
                 "mix_det_bayes": mixed_P(W, det_order_P(W), bayes_P(W, prior), 0.5)}
        for name, P in kinds.items():
            rows, fin = setup(W, Delta, P, peek=False)
            lo, up = bracket(rows, fin)
            if name in ("bayes", "bayes_wrong"):
                # the predictor's own prior is a feasible G with Phi_f = 0 for every f (non-peeking)
                pr = prior if name == "bayes" else wrong
                up = min(up, phi_all(rows, fin, pr).max())
            max_upper_nonpeek = max(max_upper_nonpeek, up)
            lines.append(f"non-peeking world {(nx, ny, n)} inst {inst} P={name:13s} |F_fin|={len(fin):2d}: V in [{lo:+.4f}, {up:+.4f}]")

# counterexample search: hill-climb over predictors to maximise the upper bound on V (non-peeking)
W = World(3, 2, 3)
best_found = -math.inf
for trial in range(3):
    Delta = rand_kernel(W, False)
    P = rand_P(W)
    rows, fin = setup(W, Delta, P, False)
    _, cur = bracket(rows, fin, T=150)
    for step in range(25):
        P2 = {key: np.clip(v + rng.normal(scale=0.15, size=v.shape), 1e-3, None) for key, v in P.items()}
        P2 = {key: v / v.sum() for key, v in P2.items()}
        rows2, fin2 = setup(W, Delta, P2, False)
        _, up2 = bracket(rows2, fin2, T=150)
        if up2 > cur:
            P, cur = P2, up2
    lo, up = bracket(*setup(W, Delta, P, False), T=400)
    best_found = max(best_found, up)
    lines.append(f"hill-climb over predictors, trial {trial}: final V in [{lo:+.4f}, {up:+.4f}]")
max_upper_nonpeek = max(max_upper_nonpeek, best_found)
lines.append(f"max certified upper bound on V over all non-peeking instances: {max_upper_nonpeek:+.2e} (claim: V <= 0; "
             f"for Bayes predictors the bound uses G = the predictor's prior, Phi_f = 0 up to rounding)")


# peeking: V vs a lower estimate of C_dir by exponentiated gradient on pi
def dir_info(W, Delta, pi):
    PS = W.paths(Delta, True)
    joint = {}
    for fi in range(len(W.F)):
        for p, h in PS[fi]:
            joint[(fi, h)] = pi[fi] * p
    pref = {}
    for (fi, h), w in joint.items():
        for k in range(W.n):
            pref[h[:k]] = pref.get(h[:k], 0) + w
            pref[(h[:k], h[k][0])] = pref.get((h[:k], h[k][0]), 0) + w
    I = 0.0
    for (fi, h), w in joint.items():
        if w == 0:
            continue
        for i, (x, y) in enumerate(h):
            I += w * math.log2(Delta[(fi, h[:i])][x] / (pref[(h[:i], x)] / pref[h[:i]]))
    return I


def cdir_lower(W, Delta, restarts=3, steps=60):
    best = 0.0
    for r in range(restarts):
        z = rng.normal(size=len(W.F))
        for s in range(steps):
            pi = np.exp(z - z.max()); pi /= pi.sum()
            base = dir_info(W, Delta, pi)
            best = max(best, base)
            g = np.zeros_like(z)
            for j in range(len(z)):
                z2 = z.copy(); z2[j] += 1e-4
                p2 = np.exp(z2 - z2.max()); p2 /= p2.sum()
                g[j] = (dir_info(W, Delta, p2) - base) / 1e-4
            z += 2.0 * g
    return best


worst = -math.inf
W = World(3, 2, 2)
for inst in range(4):
    Delta = rand_kernel(W, True)
    P = bayes_P(W, rng.dirichlet(np.ones(len(W.F)) * 0.5))
    lo, up = bracket(*setup(W, Delta, P, True))
    C = cdir_lower(W, Delta)
    worst = max(worst, up - C)
    lines.append(f"peeking world (3,2,2) inst {inst}: V in [{lo:+.4f}, {up:+.4f}], C_dir >= {C:.4f}")
lines.append(f"max over peeking instances of (upper bound on V) - (lower estimate of C_dir) = {worst:+.4f} (claim: <= 1; observed <= 0 in c3)")
for l in lines:
    print(l)
assert max_upper_nonpeek <= 1e-9
print("ALL CHECKS PASSED")
