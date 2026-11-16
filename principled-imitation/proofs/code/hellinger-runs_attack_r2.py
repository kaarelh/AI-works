#!/usr/bin/env python3
"""Adversarial exact check of Theorem R1 and Theorem 3.1 (R2) of research/prove-b/hellinger-runs.md.

Protocol R is evaluated EXACTLY: the data after t rounds are a vector of counts of the pairs (x,y);
from data D the next pair is (x,y) with probability d_M(x) P(y|x) / L, where d_M is the visit measure
of the run answered by the mixture M = M_D, and nothing is asked with the remaining probability.
All expectations over the data and over the uniformly chosen round T are computed by a forward
recursion over the count vectors; all run laws by enumeration of the scaffold's tree.

A random search with hill climbing over the class (samplers and weights), the scaffold (random
adaptive trees with stops) and the law of the top-level input tries to push each of these ratios above 1:

  r1  = sum_t E[ E_{Q_M(t)} sum_j KL(P||M(t))(x_j) ] / (L K ln2)                (Theorem R1)
  r2  = E H2(Q_M(T), Q_P) / (2 L K ln2 / n)                                    (Theorem 3.1(a))
  r3  = E TV(Q_M(T), Q_P) / (2 sqrt(L K ln2 / n))                              (Theorem 3.1(b))
  r4  = E Q_M(T)(Z) / (4 L K ln2 / n),  Z = runs of Q_P-probability zero       (Theorem 3.1(c))
 and, for the two sharper statements proposed in the attack report,
  r3n = E TV / (s + sqrt(s^2 + 2 s)),  s = L K ln2 / (2n)                      (must be <= 1)
  r4n = E Q_M(T)(Z) / (L K ln2 / n)                                            (must be <= 1)

Run:  python3 hellinger-runs_attack_r2.py          (about 4 minutes)
"""
import math, time, itertools
import numpy as np

rng = np.random.default_rng(1511)
LN2 = math.log(2.0)

# ---------------------------------------------------------------- scaffold as a tree
class Scaffold:
    """nodes: (omega, history) with an input; next(omega, history) drawn at random with stops."""
    def __init__(self, L, nx, ny, nom, pstop, adaptive=True, same_input=False):
        self.L, self.nx, self.ny, self.nom = L, nx, ny, nom
        self.nodes = []        # (omega, x, parent_index, answer_from_parent)
        self.leaves = []       # (omega, node_path) ; node_path = list of (node_index, answer)
        self.leaf_paths = []
        for om in range(nom):
            self._grow(om, [], -1, None, pstop, adaptive, same_input, level_inputs=[int(rng.integers(nx)) for _ in range(L)])
    def _grow(self, om, path, parent, ans, pstop, adaptive, same_input, level_inputs):
        depth = len(path)
        stop = depth >= self.L or (depth > 0 and rng.random() < pstop)
        if stop:
            self.leaf_paths.append((om, list(path)))
            return
        if same_input: x = 0
        elif adaptive: x = int(rng.integers(self.nx))
        else:          x = level_inputs[depth]
        idx = len(self.nodes); self.nodes.append((om, x))
        for y in range(self.ny):
            # non-adaptive scaffolds must also stop at the same depth for all histories: pstop=0 is used then
            self._grow(om, path + [(idx, y)], idx, y, pstop, adaptive, same_input, level_inputs)

    def laws(self, S, mu0):
        """S: array (nx, ny).  returns leaf probabilities (run law) and the visit measure d_S(x)."""
        q = np.empty(len(self.leaf_paths)); d = np.zeros(self.nx)
        reach = {}
        for li, (om, path) in enumerate(self.leaf_paths):
            pr = mu0[om]
            for (idx, y) in path:
                if idx not in reach:
                    reach[idx] = pr
                pr *= S[self.nodes[idx][1], y]
            q[li] = pr
        for idx, pr in reach.items():
            d[self.nodes[idx][1]] += pr
        return q, d

def kl_rows(P, M):
    with np.errstate(divide='ignore', invalid='ignore'):
        t = np.where(P > 0, P * (np.log(P) - np.log(M)), 0.0)
    return t.sum(1)

# ---------------------------------------------------------------- exact Protocol R
def evaluate(nu, w, sc, mu0, n):
    """nu: (H, nx, ny), w: (H,) with sum <= 1, human = index 0.  returns the six ratios."""
    H, nx, ny = nu.shape; L = sc.L
    P = nu[0]; K = math.log2(1.0 / w[0])
    qP, dP = sc.laws(P, mu0)
    states = {tuple([0] * (nx * ny)): 1.0}
    cache = {}
    tot_A = tot_H2 = tot_TV = tot_Z = 0.0
    lognu = np.log(np.maximum(nu, 1e-300)); zero = (nu <= 0)
    for t in range(1, n + 1):
        new = {}
        for D, pD in states.items():
            if D not in cache:
                c = np.array(D, dtype=float).reshape(nx, ny)
                ll = (c[None] * lognu).sum((1, 2)); ll[(zero & (c[None] > 0)).any((1, 2))] = -np.inf
                post = w * np.exp(ll - ll.max()); post = post / post.sum()
                M = (post[:, None, None] * nu).sum(0)
                qM, dM = sc.laws(M, mu0)
                A = float((dM * kl_rows(P, M)).sum())
                H2 = 1.0 - float(np.sqrt(qM * qP).sum())
                TV = 0.5 * float(np.abs(qM - qP).sum())
                Z = float(qM[qP <= 0].sum())
                cache[D] = (A, H2, TV, Z, dM)
            A, H2, TV, Z, dM = cache[D]
            tot_A += pD * A; tot_H2 += pD * H2; tot_TV += pD * TV; tot_Z += pD * Z
            stay = pD
            for x in range(nx):
                if dM[x] <= 0: continue
                for y in range(ny):
                    pr = pD * dM[x] * P[x, y] / L
                    if pr <= 0: continue
                    D2 = list(D); D2[x * ny + y] += 1; D2 = tuple(D2)
                    new[D2] = new.get(D2, 0.0) + pr; stay -= pr
            if stay > 1e-15:
                new[D] = new.get(D, 0.0) + stay
        states = new
    LK = L * K * LN2
    s = LK / (2 * n)
    r1 = tot_A / LK
    r2 = (tot_H2 / n) / (2 * LK / n)
    r3 = (tot_TV / n) / (2 * math.sqrt(LK / n))
    r4 = (tot_Z / n) / (4 * LK / n)
    r3n = (tot_TV / n) / min(1.0, s + math.sqrt(s * s + 2 * s))
    r4n = (tot_Z / n) / (LK / n)
    return np.array([r1, r2, r3, r4, r3n, r4n])

# ---------------------------------------------------------------- random instances and hill climbing
def random_instance(kind):
    L = int(rng.integers(1, 4)); nx = int(rng.integers(1, 4)); ny = 2; nom = int(rng.integers(1, 3))
    H = int(rng.integers(2, 5))
    if kind == 'same':
        sc = Scaffold(L, 1, ny, 1, 0.0, same_input=True); nx = 1
    elif kind == 'fixed':
        sc = Scaffold(L, nx, ny, nom, 0.0, adaptive=False)
    else:
        sc = Scaffold(L, nx, ny, nom, pstop=float(rng.choice([0.0, 0.3, 0.6])))
    style = rng.choice(['smooth', 'det', 'mixed', 'sparse'])
    nu = rng.dirichlet(np.ones(ny) * (0.3 if style != 'smooth' else 2.0), size=(H, nx))
    if style == 'det':
        nu = np.eye(ny)[rng.integers(ny, size=(H, nx))].astype(float)
    if style == 'sparse':
        nu = np.where(rng.random(nu.shape) < 0.3, 0.0, nu) + 1e-12 * 0
        nu = np.where(nu.sum(2, keepdims=True) > 0, nu, 1.0); nu = nu / nu.sum(2, keepdims=True)
    if style == 'mixed':
        det = np.eye(ny)[rng.integers(ny, size=(H, nx))].astype(float)
        mask = rng.random((H, nx, 1)) < 0.5
        nu = np.where(mask, det, nu)
    w = rng.dirichlet(np.ones(H) * 0.7) * float(rng.choice([1.0, 1.0, 0.5]))
    w = np.maximum(w, 1e-6)
    mu0 = rng.dirichlet(np.ones(sc.nom))
    return nu, w, sc, mu0

def valid(nu, w):
    return (nu >= 0).all() and (w > 0).all() and w.sum() <= 1 + 1e-12

def perturb(nu, w, mu0, scale):
    nu2 = np.abs(nu + scale * rng.normal(size=nu.shape) * (rng.random(nu.shape) < 0.5))
    nu2 = np.where(nu2.sum(2, keepdims=True) > 0, nu2, 1.0); nu2 = nu2 / nu2.sum(2, keepdims=True)
    tot = w.sum()
    w2 = np.abs(w * np.exp(scale * 3 * rng.normal(size=w.shape))); w2 = np.maximum(w2 / w2.sum() * tot, 1e-9)
    m2 = np.abs(mu0 + scale * rng.normal(size=mu0.shape)); m2 = m2 / m2.sum()
    return nu2, w2, m2

def climb(index, kind, n, iters=150):
    nu, w, sc, mu0 = random_instance(kind)
    best = evaluate(nu, w, sc, mu0, n)
    for it in range(iters):
        nu2, w2, m2 = perturb(nu, w, mu0, scale=0.3 * (1 - it / iters) + 0.02)
        r = evaluate(nu2, w2, sc, m2, n)
        if r[index] > best[index]:
            best, nu, w, mu0 = r, nu2, w2, m2
    return best, (nu, w, sc, mu0)

if __name__ == '__main__':
    t0 = time.time()
    names = ['r1 (R1)', 'r2 (3.1a, H2)', 'r3 (3.1b, TV)', 'r4 (3.1c, null events)', 'r3n (new TV bound)', 'r4n (new null-event bound)']
    # 1. plain random instances
    worst = np.zeros(6); cnt = 0
    for rep in range(1500):
        kind = rng.choice(['adaptive', 'adaptive', 'fixed', 'same'])
        n = int(rng.integers(1, 7))
        nu, w, sc, mu0 = random_instance(kind)
        r = evaluate(nu, w, sc, mu0, n); worst = np.maximum(worst, r); cnt += 1
    print("1. %d random instances (L <= 3, |X| <= 3, |Y| = 2, <= 4 hypotheses, n <= 6), exact expectations; largest ratios:" % cnt)
    for nm, v in zip(names, worst): print("     %-28s %.4f %s" % (nm, v, "VIOLATION" if v > 1 + 1e-9 else ""))
    # 2. hill climbing on each ratio
    print("2. hill climbing (random perturbations, 150 steps per start), largest ratio reached for each target:")
    for index in range(6):
        top = 0.0; arg = None
        for start in range(14):
            kind = ['adaptive', 'adaptive', 'fixed', 'same'][start % 4]
            n = [1, 2, 3, 5][start % 4] if index != 0 else [2, 4, 6, 6][start % 4]
            best, inst = climb(index, kind, n)
            if best[index] > top: top, arg = best[index], (kind, n, inst[2].L, inst[0].shape, math.log2(1 / inst[1][0]))
        print("     %-28s %.4f  (scaffold %s, n = %d, L = %d, class %s, K = %.3f) %s" % (names[index], top, arg[0], arg[1], arg[2], arg[3], arg[4],
              "VIOLATION" if top > 1 + 1e-9 else ""))
    # 3. the simplest tight family for r4n: a function f and one alternative that differs at the single input, L calls at it
    print("3. family: X = {x}, P = point mass at 0, alternative = point mass at 1, weights (w, 1-w), L calls at x:")
    for L in [1, 3]:
        for wP in [0.5, 0.1, 0.01]:
            for n in [1, 4]:
                sc = Scaffold(L, 1, 2, 1, 0.0, same_input=True)
                nu = np.array([[[1.0, 0.0]], [[0.0, 1.0]]]); w = np.array([wP, 1 - wP])
                r = evaluate(nu, w, sc, np.array([1.0]), n)
                print("     L=%d w(P)=%.2f n=%d: r1=%.4f r2=%.4f r3=%.4f r4=%.4f r3n=%.4f r4n=%.4f" % ((L, wP, n) + tuple(r)))
    print("time %.0f s" % (time.time() - t0))
