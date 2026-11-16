"""Proposition 6.6: in rehearsal the books of the quadratic rule stay bounded when the human's
rates are interior (property-online.md, Section 6.5).

Setting: L = 1; the question is uniform on a set of nx questions; the human answers from a
kernel P with full support; K set tests with weights pi (sum 1). Quadratic rule: answer x with
a minimiser of sum_B pi(B) S(B) 1[(x, y) in B].

  m_x(S) = sum_B pi(B) S(B) (P b_B)(x) - min_y sum_B pi(B) S(B) b_B(x, y)   >= 0
  interior condition (I):  E_x m_x(S) >= mu0 * ||S||_pi  for all S,  ||S||_pi^2 = sum_B pi(B) S(B)^2.

The script estimates mu0 from above by minimising E_x m_x(S)/||S||_pi over 200000 random
directions and the coordinate directions (the true mu0 is at most the estimate, and the bound
C(mu0) = (2/mu0)(1 + e ln(8e/mu0^2)) of the proposition decreases in mu0, so the bound printed
is not larger than the true one). It then runs rehearsal and reports the mean of ||S_n||_pi
over 300 repetitions at several n, for the quadratic rule (covered by the proposition) and for
Rule N (not covered; for comparison), together with the mean of max_B |S_n(B)|.

Usage: python3 property-online_interior.py
"""
import math

import numpy as np


def G(v, s):
    return (v + 1.0) ** -0.5 * np.exp(s * s / (2.0 * (v + 1.0)))


def estimate_mu0(tests, PI, P, rng, trials=200000):
    K, nx, ny = tests.shape
    rate = np.einsum("kxy,xy->kx", tests, P)              # (P b_B)(x)
    dirs = np.concatenate([rng.standard_normal((trials, K)), np.eye(K), -np.eye(K)])
    best = np.inf
    for chunk in np.array_split(dirs, 40):
        w = chunk * PI[None, :]                            # pi(B) S(B)
        mean_h = w @ rate                                   # [dir, x]
        mins = np.einsum("dk,kxy->dxy", w, tests).min(axis=2)
        m = (mean_h - mins).mean(axis=1)                    # E_x m_x(S), x uniform
        norm = np.sqrt((chunk ** 2 * PI[None, :]).sum(axis=1))
        best = min(best, float(np.min(m / norm)))
    return best


def run(rule, tests, PI, P, n, checkpoints, rng):
    K, nx, ny = tests.shape
    S = np.zeros(K)
    V = np.zeros(K)
    out = {}
    for t in range(1, n + 1):
        c = S if rule == "quad" else 0.5 * (G(V + 1, S + 1.0) - G(V + 1, S - 1.0))
        x = int(rng.integers(nx))
        a = int(np.argmin((PI * c) @ tests[:, x, :]))
        y = int(rng.choice(ny, p=P[x]))
        g = tests[:, x, a] - tests[:, x, y]
        S, V = S + g, V + (g != 0)
        if t in checkpoints:
            out[t] = (math.sqrt(np.sum(PI * S * S)), float(np.max(np.abs(S))))
    return out


if __name__ == "__main__":
    rng = np.random.default_rng(9)
    K, nx, ny = 6, 8, 4
    tests = (rng.random((K, nx, ny)) < 0.4).astype(float)
    PI = np.full(K, 1.0 / K)
    P = rng.dirichlet(np.ones(ny) * 3.0, size=nx)
    mu0 = estimate_mu0(tests, PI, P, rng)
    C = (2 / mu0) * (1 + math.e * math.log(8 * math.e / mu0 ** 2))
    print(f"{K} tests of weight 1/{K}, {nx} questions, {ny} answers; estimated mu0 = {mu0:.4f}; "
          f"C(mu0) = {C:.1f}")
    checkpoints = (100, 1000, 10000)
    reps = 300
    for rule in ("quad", "N"):
        acc = {t: [] for t in checkpoints}
        for _ in range(reps):
            for t, v in run(rule, tests, PI, P, max(checkpoints), checkpoints, rng).items():
                acc[t].append(v)
        print(f"rule {rule}:")
        for t in checkpoints:
            a = np.array(acc[t])
            print(f"    n = {t:6d}:  mean ||S_n||_pi = {a[:, 0].mean():6.3f},  mean max_B |S_n(B)| = {a[:, 1].mean():6.3f},"
                  f"  mean max_B |S_n(B)| / n = {a[:, 1].mean() / t:.5f}")
