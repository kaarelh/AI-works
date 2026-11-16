#!/usr/bin/env python3
"""Numerical checks for Lemma L4 (one-sided subadditivity of squared Hellinger distance).

Convention: H2(p, q) = 1 - sum_x sqrt(p(x) q(x)).

Checks
  (a) the one-step inequality  E[U(Lam*rho)] <= U(Lam) + 4*(1 - E[rho])  for
      U(x) = (2-x)_+^2 / 2, on random (Lam, law of rho) with E[rho^2] <= 1;
  (b) the exact identity  H2(P,Q) = E_P[ sum_i Lam_{i-1} h_i ]  and the bound
      H2(P,Q) <= 4 E_P[sum_i h_i]  on random trees (sequential experiments with
      arbitrary dependence on the past), with the largest ratio found;
  (c) a hill-climbing search for a large ratio H2 / E_P[sum h] on small trees;
  (d) the two-stage example with ratio -> (2+sqrt 2)/2;
  (e) the lattice random-walk example (closed form and exact dynamic programme),
      with ratio -> 2.0996...
Only numpy is needed.
"""
import itertools
import math
import numpy as np

rng = np.random.default_rng(20261114)


def H2(p, q):
    return 1.0 - float(np.sum(np.sqrt(p * q)))


# ---------------------------------------------------------------- (a)
def U(x):
    return 0.5 * np.maximum(2.0 - x, 0.0) ** 2


def check_one_step(trials=200000):
    worst = -np.inf
    for _ in range(trials):
        k = rng.integers(2, 6)
        # random pair (p, q) on k points, q possibly with mass outside supp p
        p = rng.dirichlet(np.ones(k) * rng.choice([0.2, 1.0, 5.0]))
        q = rng.dirichlet(np.ones(k) * rng.choice([0.2, 1.0, 5.0]))
        if rng.random() < 0.3:          # make some q-mass singular to p
            j = rng.integers(k)
            p = p.copy(); p[j] = 0.0; p = p / p.sum()
        if rng.random() < 0.3:          # make some p-mass singular to q
            j = rng.integers(k)
            q = q.copy(); q[j] = 0.0; q = q / q.sum()
        mask = p > 0
        rho = np.zeros(k); rho[mask] = np.sqrt(q[mask] / p[mask])
        Erho = float(np.sum(p * rho))            # = 1 - H2(p,q)
        Erho2 = float(np.sum(p * rho ** 2))      # <= 1
        assert Erho2 <= 1 + 1e-12
        Lam = float(np.exp(rng.uniform(-3, 3)))
        lhs = float(np.sum(p * U(Lam * rho)))
        rhs = float(U(Lam)) + 4.0 * (1.0 - Erho)
        worst = max(worst, lhs - rhs)
    return worst


# ---------------------------------------------------------------- (b), (c)
def random_kernel(k, style):
    a = {0: 0.15, 1: 1.0, 2: 8.0}[style]
    v = rng.dirichlet(np.ones(k) * a)
    if rng.random() < 0.15:
        j = rng.integers(k)
        v = v.copy(); v[j] = 0.0
        if v.sum() == 0:
            v[(j + 1) % k] = 1.0
        v = v / v.sum()
    return v


class Tree:
    """Sequential experiment of depth n on alphabet {0..k-1}: for every history
    (a tuple of length < n) a pair of laws (p, q) on the next symbol."""

    def __init__(self, n, k, style=None):
        self.n, self.k = n, k
        self.P, self.Q = {}, {}
        for d in range(n):
            for hist in itertools.product(range(k), repeat=d):
                s = rng.integers(3) if style is None else style
                self.P[hist] = random_kernel(k, s)
                if rng.random() < 0.3:
                    self.Q[hist] = self.P[hist].copy()      # identical kernels
                else:
                    self.Q[hist] = random_kernel(k, rng.integers(3))

    def evaluate(self):
        """Return H2(P,Q), E_P sum h, E_P sum Lam_{i-1} h_i, E_Q sum h."""
        n, k = self.n, self.k
        bc = 0.0
        sigP = 0.0
        sigQ = 0.0
        ident = 0.0
        # enumerate histories with their P- and Q-probabilities
        level = {(): (1.0, 1.0)}
        for d in range(n):
            nxt = {}
            for hist, (pp, qq) in level.items():
                p, q = self.P[hist], self.Q[hist]
                h = H2(p, q)
                sigP += pp * h
                sigQ += qq * h
                ident += math.sqrt(pp * qq) * h     # E_P[Lam h] = sum sqrt(P Q) h
                for a in range(k):
                    nxt[hist + (a,)] = (pp * p[a], qq * q[a])
            level = nxt
        for hist, (pp, qq) in level.items():
            bc += math.sqrt(pp * qq)
        return 1.0 - bc, sigP, ident, sigQ


def check_trees(trials=4000):
    worst_ratio = 0.0
    worst_ident = 0.0
    worst_sym = -np.inf
    for _ in range(trials):
        n = int(rng.integers(1, 5))
        k = int(rng.integers(2, 4))
        t = Tree(n, k)
        h2, sigP, ident, sigQ = t.evaluate()
        worst_ident = max(worst_ident, abs(h2 - ident))
        worst_sym = max(worst_sym, h2 - 0.5 * (sigP + sigQ))
        if sigP > 1e-12:
            worst_ratio = max(worst_ratio, h2 / sigP)
        assert h2 <= 4.0 * sigP + 1e-12
    return worst_ratio, worst_ident, worst_sym


def hill_climb(n=3, k=2, iters=20000, restarts=6):
    """Local search for trees with a large ratio H2/E_P sum h (binary alphabet)."""
    best_overall = 0.0
    for _ in range(restarts):
        t = Tree(n, k, style=1)
        h2, sigP, _, _ = t.evaluate()
        best = h2 / sigP if sigP > 0 else 0.0
        keys = list(t.P.keys())
        for it in range(iters):
            hist = keys[rng.integers(len(keys))]
            which = t.P if rng.random() < 0.5 else t.Q
            old = which[hist].copy()
            step = 10 ** rng.uniform(-3, -0.3)
            new = np.clip(old + rng.normal(0, step, size=k), 0.0, None)
            if new.sum() <= 0:
                continue
            which[hist] = new / new.sum()
            h2, sigP, _, _ = t.evaluate()
            r = h2 / sigP if sigP > 1e-14 else 0.0
            if r >= best:
                best = r
            else:
                which[hist] = old
        best_overall = max(best_overall, best)
    return best_overall


# ---------------------------------------------------------------- (d)
def two_stage(eps, s):
    """X1 in {0,1}: P(X1=1)=eps, Q(X1=1)=s^2 eps. If X1=1 the second kernels are
    mutually singular (h=1); if X1=0 they coincide."""
    a, b = eps, s * s * eps
    h1 = 1 - math.sqrt((1 - a) * (1 - b)) - math.sqrt(a * b)
    h2 = h1 + math.sqrt(a * b) * 1.0
    sig = h1 + a * 1.0
    return h2, sig


# ---------------------------------------------------------------- (e)
def lattice_closed_form(u, m):
    """Lam walks on {u^k}: up (factor u) w.p. 1/(1+u^2), down w.p. u^2/(1+u^2)
    under P; under Q the probabilities are u^2/(1+u^2) and 1/(1+u^2).
    Start at k=0, stop at k=-1; at k=m make one mutually singular step (h=1)."""
    pi_up = (u * u - 1) / (u ** (2 * m + 2) - 1)
    h = (u - 1) ** 2 / (1 + u * u)
    Etau = ((1 - pi_up) - m * pi_up) * (1 + u * u) / (u * u - 1)
    sig = h * Etau + pi_up
    h2 = 1 - (1 - pi_up) / u
    return h2, sig


def lattice_dp(u, m, nsteps):
    """Same strategy truncated after nsteps steps (then both laws coincide):
    exact H2 and E_P sum h by forward dynamic programming."""
    pu = 1 / (1 + u * u)
    qu = u * u / (1 + u * u)
    h = 1 - (math.sqrt(pu * qu) + math.sqrt((1 - pu) * (1 - qu)))
    # state k in {-1,...,m}; index k+1; keep P-mass and Q-mass
    P = np.zeros(m + 2); Q = np.zeros(m + 2)
    P[1] = 1.0; Q[1] = 1.0
    sig = 0.0
    bc_done = 0.0           # Bhattacharyya mass of finished paths
    for _ in range(nsteps):
        # interior states 0..m-1 take a random-walk step
        Pi, Qi = P[1:m + 1].copy(), Q[1:m + 1].copy()
        sig += h * Pi.sum()
        Pn = np.zeros(m + 2); Qn = np.zeros(m + 2)
        Pn[2:m + 2] += Pi * pu; Pn[0:m] += Pi * (1 - pu)
        Qn[2:m + 2] += Qi * qu; Qn[0:m] += Qi * (1 - qu)
        # mass arriving at k=-1 stops: contributes sqrt(P Q) pathwise.  Along a
        # lattice path the ratio Q/P depends only on the end point, so
        # sum over paths of sqrt(P Q) = sqrt(P_tot Q_tot) for each arrival time
        bc_done += math.sqrt(Pn[0] * Qn[0])
        # mass arriving at k=m makes the singular step: h=1, contributes 0 to BC
        sig += Pn[m + 1] * 1.0
        Pn[0] = 0.0; Qn[0] = 0.0; Pn[m + 1] = 0.0; Qn[m + 1] = 0.0
        P, Q = Pn, Qn
    # truncated: remaining interior mass stops with identical continuation
    bc_done += float(np.sum(np.sqrt(P[1:m + 1] * Q[1:m + 1])))
    return 1 - bc_done, sig


if __name__ == "__main__":
    print("(a) one-step inequality, max of lhs - rhs over 200000 random cases:",
          f"{check_one_step():.3e}  (must be <= 0 up to rounding)")
    wr, wi, ws = check_trees()
    print("(b) random trees: max ratio H2/E_P[sum h] =", f"{wr:.4f}",
          "; max |H2 - E_P sum Lam h| =", f"{wi:.2e}",
          "; max of H2 - (E_P sum h + E_Q sum h)/2 =", f"{ws:.2e}")
    print("(c) hill-climbing, depth 2, binary: best ratio",
          f"{hill_climb(n=2, k=2, iters=6000, restarts=4):.4f}")
    print("    hill-climbing, depth 3, binary: best ratio",
          f"{hill_climb(n=3, k=2, iters=12000, restarts=4):.4f}")
    print("    hill-climbing, depth 4, binary: best ratio",
          f"{hill_climb(n=4, k=2, iters=20000, restarts=3):.4f}")
    s = 1 + math.sqrt(2)
    print("(d) two-stage example, s = 1+sqrt2, limit (2+sqrt2)/2 =",
          f"{(2 + math.sqrt(2)) / 2:.6f}")
    for eps in [1e-1, 1e-2, 1e-3, 1e-5]:
        h2, sig = two_stage(eps, s)
        print(f"    eps={eps:g}: H2={h2:.6e}, E_P sum h={sig:.6e}, ratio={h2 / sig:.6f}")
    print("(e) lattice example, closed form; b = u^m")
    for u, m in [(1.2, 8), (1.1, 16), (1.05, 31), (1.02, 77), (1.01, 153), (1.001, 1530)]:
        h2, sig = lattice_closed_form(u, m)
        print(f"    u={u}, m={m}, b={u ** m:.3f}: H2={h2:.6f}, sigma={sig:.6f}, ratio={h2 / sig:.5f}")
    b = 4.6
    print("    continuous limit 2(b^2+1)/(b^2+3-2 ln b) at b=4.6:",
          f"{2 * (b * b + 1) / (b * b + 3 - 2 * math.log(b)):.5f}")
    bs = np.linspace(2, 10, 8001)
    vals = 2 * (bs ** 2 + 1) / (bs ** 2 + 3 - 2 * np.log(bs))
    print("    maximum over b of the continuous limit:", f"{vals.max():.5f}",
          "at b =", f"{bs[vals.argmax()]:.3f}")
    print("    exact dynamic programme for the truncated strategy (u=1.05, m=31):")
    for nsteps in [10, 100, 1000, 10000, 100000]:
        h2, sig = lattice_dp(1.05, 31, nsteps)
        print(f"      horizon {nsteps + 1:>6}: H2={h2:.6f}, sigma={sig:.6f}, ratio={h2 / sig:.5f}")
