"""The randomised imitator: a tilt of a base sampler (property-online.md, Section 7.4).

In round t the imitator announces a kernel q_t(.|x); the expected increment of a test B is
gbar_t(B) = (q_t b_B)(x_t) - b_B(x_t, y_t) and Sbar_n(B) is the sum of the gbar_t(B).

(A) Tilt driven by exponential weights (Theorem 7.6). q_t(y|x) proportional to R_t(y|x) exp(-Lam_t(x, y)) with
        Lam_t(x, y) = beta sinh(eta) sum_B omega_t(B) b_B(x, y),
        omega_t(B) = pi(B) sinh(eta Sbar_{t-1}(B)) / sum_B' pi(B') cosh(eta Sbar_{t-1}(B')).
    Checked on every path and at every round:
      (i)   |Sbar_n(B)| <= (ln(2/pi(B)) + n eta^2/2 + (1/beta) sum_t ln(1/R_t(y_t|x_t))) / eta;
      (iii) KL(q_t || R_t)(x) <= beta sinh(eta), and
            KL(P || q_t)(x) <= 2 KL(P || R_t)(x) + (beta sinh(eta))^2          (all x).
    Checked on average over repetitions (answers drawn from P):
      (ii)  for each B, E|Sbar_n(B)| <= (ln(2/pi(B)) + n eta^2/2
            + (1/beta) E sum_t KL(P || R_t)(x_t)) / eta   (both expectations estimated).
    Bases: 'uniform'; 'wrong' (a fixed kernel different from the human); 'bayes' (the Bayes
    mixture of a class of 8 kernels that contains the human, trained on the asked pairs).

(B) Tilt driven by gradient steps (Theorem 7.8). lam_{t+1}(B) = lam_t(B) + gamma pi(B) gbar_t(B), q_t proportional
    to R_t exp(-sum_B lam_t(B) b_B). Checked on every path: the identity
      sum_B pi(B) Sbar_n(B)^2 = sum_t sum_B pi(B) gbar_t(B)^2
              + (2/gamma) sum_t [ln(q_t(y_t|x_t)/R_t(y_t|x_t)) - KL(q_t || R_t)(x_t)].

Usage: python3 property-online_tilt.py
"""
import math

import numpy as np


def kl(p, q):
    m = p > 0
    return float(np.sum(p[m] * np.log(p[m] / q[m])))


def make(rng, K, nx, ny):
    tests = (rng.random((K, nx, ny)) < 0.35).astype(float)
    w = 2.0 ** -np.arange(1, K + 1)
    PI = w / w.sum()
    P = rng.dirichlet(np.ones(ny) * 0.7, size=nx)
    wrong = rng.dirichlet(np.ones(ny) * 0.7, size=nx)
    cls = [P] + [rng.dirichlet(np.ones(ny) * 0.7, size=nx) for _ in range(7)]
    return tests, PI, P, wrong, np.stack(cls)


def base_kernel(kind, P, wrong, cls, logw):
    if kind == "uniform":
        return np.full_like(P, 1.0 / P.shape[1])
    if kind == "wrong":
        return wrong
    w = np.exp(logw - logw.max())
    w /= w.sum()
    return np.tensordot(w, cls, axes=1)


def entropic(rng, tests, PI, P, wrong, cls, kind, n, eta, beta):
    K, nx, ny = tests.shape
    Sbar = np.zeros(K)
    logw = np.log(np.full(len(cls), 1.0 / len(cls)))
    ll = 0.0      # sum of ln(1/R_t(y_t|x_t))
    kls = 0.0     # sum of KL(P || R_t)(x_t)
    ok_i = ok_iii = True
    for t in range(1, n + 1):
        R = base_kernel(kind, P, wrong, cls, logw)
        Phi = np.sum(PI * np.cosh(eta * Sbar))
        omega = PI * np.sinh(eta * Sbar) / Phi
        Lam = beta * math.sinh(eta) * np.tensordot(omega, tests, axes=1)      # [x, y]
        q = R * np.exp(-Lam)
        q /= q.sum(axis=1, keepdims=True)
        for x in range(nx):                                                  # (iii) at every x
            if kl(q[x], R[x]) > beta * math.sinh(eta) + 1e-12:
                ok_iii = False
            if kl(P[x], q[x]) > 2 * kl(P[x], R[x]) + (beta * math.sinh(eta)) ** 2 + 1e-12:
                ok_iii = False
        x = int(rng.integers(nx))
        y = int(rng.choice(ny, p=P[x]))
        gbar = tests[:, x, :] @ q[x] - tests[:, x, y]
        Sbar = Sbar + gbar
        ll += math.log(1.0 / R[x, y])
        kls += kl(P[x], R[x])
        if np.any(np.abs(Sbar) > (np.log(2 / PI) + t * eta ** 2 / 2 + ll / beta) / eta + 1e-9):
            ok_i = False
        logw = logw + np.log(cls[:, x, y])
    return Sbar, ll, kls, ok_i, ok_iii


def euclid(rng, tests, PI, P, R, n, gamma):
    K, nx, ny = tests.shape
    Sbar = np.zeros(K)
    lam = np.zeros(K)
    rhs = 0.0
    for t in range(n):
        Lam = np.tensordot(lam, tests, axes=1)
        q = R * np.exp(-Lam)
        q /= q.sum(axis=1, keepdims=True)
        x = int(rng.integers(nx))
        y = int(rng.choice(ny, p=P[x]))
        gbar = tests[:, x, :] @ q[x] - tests[:, x, y]
        rhs += np.sum(PI * gbar ** 2) + (2 / gamma) * (math.log(q[x, y] / R[x, y]) - kl(q[x], R[x]))
        Sbar += gbar
        lam += gamma * PI * gbar
    return float(np.sum(PI * Sbar ** 2)), rhs


if __name__ == "__main__":
    rng = np.random.default_rng(5)
    K, nx, ny, n, reps = 12, 6, 5, 2000, 40
    tests, PI, P, wrong, cls = make(rng, K, nx, ny)
    eta = 1 / math.sqrt(n)
    print(f"(A) exponential-weights tilt (Theorem 7.6): {K} tests (weights 2^-k normalised), |X| = {nx}, |Y| = {ny}, n = {n}, "
          f"eta = 1/sqrt(n), {reps} repetitions")
    print(f"{'base':>8} {'beta':>8} {'(i) holds':>10} {'(iii) holds':>12} "
          f"{'max_B E|Sbar_n(B)| / bound (ii)':>32} {'mean sum KL(P||R_t)':>20} {'max_B E|Sbar_n|/sqrt(n)':>24}")
    for kind in ("uniform", "wrong", "bayes"):
        for beta in (1.0, 2 * math.log(ny) * n / 10, 2 * math.log(ny) * n):
            allS, alll, allk, oki, okiii = [], [], [], True, True
            for _ in range(reps):
                Sbar, ll, kls, a, b = entropic(rng, tests, PI, P, wrong, cls, kind, n, eta, beta)
                allS.append(np.abs(Sbar))
                alll.append(ll)
                allk.append(kls)
                oki &= a
                okiii &= b
            ES = np.mean(allS, axis=0)
            bound_ii = (np.log(2 / PI) + n * eta ** 2 / 2 + np.mean(allk) / beta) / eta
            print(f"{kind:>8} {beta:8.1f} {str(oki):>10} {str(okiii):>12} {np.max(ES / bound_ii):32.3f} "
                  f"{np.mean(allk):20.2f} {np.max(ES) / math.sqrt(n):24.3f}")
    print()
    print("(B) gradient tilt: both sides of the identity of Theorem 7.8 on single paths")
    for kind, R in (("uniform", np.full_like(P, 1.0 / ny)), ("wrong", wrong), ("human", P)):
        for gamma in (0.05, 1.0):
            lhs, rhs = euclid(rng, tests, PI, P, R, n, gamma)
            print(f"  base {kind:>8}, gamma = {gamma:4.2f}:  sum_B pi(B) Sbar_n(B)^2 = {lhs:12.6f}   right side = {rhs:12.6f}"
                  f"   (n = {n})")
