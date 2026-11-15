#!/usr/bin/env python3
"""Numerical checks for Theorem R2 and for the lower bound of Section 3 (K coins).

Class: theta in {-1,+1}^K, P_theta(1|i) = 1/2 + theta_i*delta for inputs i = 1..K.
Scaffold: L = m*K calls, input i asked m times (inputs do not depend on answers).
A run is described by the K counts of ones, so run laws are products of binomials.

(1) G(N) = TV(Bin(N,1/2+delta), Bin(N,1/2-delta)) against the bound delta*sqrt(N/2)
    of Lemma 3.4a (valid for odd N >= 3 with (N-1)*delta^2 <= 1/4).
(2) Protocol R on this scaffold (each round asks a uniformly random input): exact
    whole-run H2 and TV of the deployed mixture, averaged over training data, against
        E H2 <= 2 L K ln2 / n   and   E TV <= 2 sqrt(L K ln2 / n).
(3) Growth in L at fixed n and K: E TV grows like sqrt(L) until it saturates.
(4) Protocol R on an adaptive scaffold (a walk down a binary tree) with a small class:
    the same chain  E H2 <= 4 E sigma <= 2 L K ln2 / n.
Only numpy is needed.
"""
import math
import itertools
import numpy as np

rng = np.random.default_rng(7)
LN2 = math.log(2)


def binom_pmf(N, p):
    k = np.arange(N + 1)
    logc = np.array([math.lgamma(N + 1) - math.lgamma(i + 1) - math.lgamma(N - i + 1) for i in k])
    with np.errstate(divide="ignore"):
        lp = logc + k * math.log(p) + (N - k) * math.log(1 - p)
    return np.exp(lp)


def G(N, delta):
    a, b = binom_pmf(N, 0.5 + delta), binom_pmf(N, 0.5 - delta)
    return 0.5 * float(np.abs(a - b).sum())


def product_tv_h2(ps, qs, m):
    """TV and H2 between prod_i Bin(m, ps[i]) and prod_i Bin(m, qs[i]) (exact).
    Equal to TV and H2 of the run laws, since the counts are sufficient."""
    K = len(ps)
    bc = 1.0
    for p, q in zip(ps, qs):
        bc *= (math.sqrt(p * q) + math.sqrt((1 - p) * (1 - q))) ** m
    A = [binom_pmf(m, p) for p in ps]
    Bm = [binom_pmf(m, q) for q in qs]
    P = A[0]; Q = Bm[0]
    for i in range(1, K):
        P = np.multiply.outer(P, A[i]); Q = np.multiply.outer(Q, Bm[i])
    return 0.5 * float(np.abs(P - Q).sum()), 1.0 - bc


def protocol_R(K, m, delta, n, reps, theta=None):
    """Uniform prior on {-1,1}^K; round t asks a uniformly random input (this is
    Protocol R for the scaffold, whose inputs do not depend on the answers) and the
    mixture frozen at a uniformly random round T is deployed.  Returns the averages of
    H2(Q_M, Q_theta), TV(Q_M, Q_theta) and of 4*sigma, sigma = E_{Q_M} sum_j H2_j."""
    if theta is None:
        theta = np.ones(K)
    L = m * K
    ptrue = 0.5 + theta * delta
    lr = math.log((0.5 + delta) / (0.5 - delta))
    tv_sum = h2_sum = sig_sum = 0.0
    for _ in range(reps):
        T = rng.integers(1, n + 1)                  # deployed round: data of rounds < T
        xs = rng.integers(0, K, size=T - 1)
        ys = rng.random(T - 1) < ptrue[xs]
        s = np.zeros(K)
        np.add.at(s, xs, np.where(ys, 1.0, -1.0))    # (#ones - #zeros) at each input
        post_plus = 1.0 / (1.0 + np.exp(-lr * s))    # posterior prob of theta_i = +1
        pm = 0.5 + delta * (2 * post_plus - 1)       # mixture M(1|i)
        tv, h2 = product_tv_h2(pm, ptrue, m)
        hj = 1 - (np.sqrt(pm * ptrue) + np.sqrt((1 - pm) * (1 - ptrue)))
        tv_sum += tv; h2_sum += h2; sig_sum += m * hj.sum()
    return h2_sum / reps, tv_sum / reps, 4 * sig_sum / reps


def adaptive_tree(depth, n_hyp, n, reps, seed=3):
    """An adaptive scaffold: a walk down a binary tree of the given depth.  The input of
    call j is the current node (a function of the earlier answers), the answer in {0,1}
    selects the child; L = depth.  Class: n_hyp samplers with random biases at the nodes
    and random weights; the human is hypothesis 0.  Protocol R is simulated; for the
    mixture of the deployed round the run law is computed exactly (2^depth paths).
    Returns averages of H2(Q_M, Q_P), 4*sigma (sigma = E_{Q_M} sum_j H2(M,P)(x_j)), TV,
    and K."""
    g = np.random.default_rng(seed)
    n_nodes = 2 ** depth - 1
    bias = g.uniform(0.15, 0.85, size=(n_hyp, n_nodes))      # P_h(1 | node)
    bias[1] = np.clip(bias[0] + g.normal(0, 0.05, n_nodes), 0.05, 0.95)   # a close rival
    w = g.dirichlet(np.ones(n_hyp))
    K = math.log2(1 / w[0])

    def run_law(b):
        """law over the 2^depth paths of the walk with node biases b"""
        probs = np.ones(1); nodes = np.zeros(1, dtype=int)
        for _ in range(depth):
            p1 = b[nodes]
            probs = np.concatenate([probs * (1 - p1), probs * p1])
            nodes = np.concatenate([2 * nodes + 1, 2 * nodes + 2])
        return probs

    def sigma(bm, bp):
        """E over the walk with biases bm of the sum of per-call H2 between bm and bp"""
        tot = 0.0
        probs = np.ones(1); nodes = np.zeros(1, dtype=int)
        for _ in range(depth):
            p1 = bm[nodes]; q1 = bp[nodes]
            h = 1 - (np.sqrt(p1 * q1) + np.sqrt((1 - p1) * (1 - q1)))
            tot += float(np.sum(probs * h))
            probs = np.concatenate([probs * (1 - p1), probs * p1])
            nodes = np.concatenate([2 * nodes + 1, 2 * nodes + 2])
        return tot

    qP = run_law(bias[0])
    h2s = tvs = sigs = 0.0
    for _ in range(reps):
        T = int(g.integers(1, n + 1))
        logw = np.log(w).copy()
        for t in range(1, T):                    # rounds before the deployed one
            post = np.exp(logw - logw.max()); post /= post.sum()
            bm = post @ bias                     # mixture M(1|node)
            node = 0; J = int(g.integers(1, depth + 1))
            for j in range(1, depth + 1):        # run of the mixture, stop at call J
                if j == J:
                    y = g.random() < bias[0, node]            # the human's answer
                    logw += np.log(np.where(y, bias[:, node], 1 - bias[:, node]))
                    break
                a = g.random() < bm[node]
                node = 2 * node + 1 + int(a)
        post = np.exp(logw - logw.max()); post /= post.sum()
        bm = post @ bias
        qM = run_law(bm)
        h2s += 1 - float(np.sum(np.sqrt(qM * qP)))
        tvs += 0.5 * float(np.abs(qM - qP).sum())
        sigs += sigma(bm, bias[0])
    return h2s / reps, 4 * sigs / reps, tvs / reps, K


if __name__ == "__main__":
    print("(1) G(N) against delta*sqrt(N/2), odd N with N*delta^2 <= 1/4")
    worst = 10.0
    for N in [3, 5, 9, 25, 101, 401, 1601]:
        for frac in [0.05, 0.3, 1.0]:
            delta = math.sqrt(frac / (4 * N))
            g = G(N, delta)
            worst = min(worst, g / (delta * math.sqrt(N / 2)))
            if frac == 1.0:
                print(f"    N={N:5d} delta={delta:.4f}: G={g:.4f}  delta*sqrt(N/2)={delta * math.sqrt(N / 2):.4f}")
    print(f"    smallest ratio G / (delta sqrt(N/2)) over the cases tried: {worst:.4f} (must be >= 1)")

    print("(2) Protocol R, exact run laws; columns: K m L n delta | E H2, 4E sigma, bound 2LK ln2/n | E TV, bound 2 sqrt(LK ln2/n)")
    for K, m, n in [(1, 20, 400), (2, 10, 400), (3, 8, 600), (3, 8, 2400), (2, 30, 2400)]:
        L = K * m
        for c in [0.5, 1.0, 2.0]:
            delta = min(0.45, c * math.sqrt(K / n))
            h2, tv, sig4 = protocol_R(K, m, delta, n, reps=600)
            print(f"    K={K} m={m:2d} L={L:3d} n={n:5d} delta={delta:.4f} | "
                  f"{h2:.4f} {sig4:.4f} {2 * L * K * LN2 / n:.4f} | {tv:.4f} {2 * math.sqrt(L * K * LN2 / n):.4f}")

    print("(3) growth in L at fixed K=2, n=800, delta = sqrt(K/n): E TV / sqrt(L)")
    K, n = 2, 800
    delta = math.sqrt(K / n)
    for m in [1, 2, 4, 8, 16, 32, 64]:
        L = K * m
        h2, tv, _ = protocol_R(K, m, delta, n, reps=600)
        print(f"    L={L:4d}: E TV={tv:.4f}  E TV/sqrt(L)={tv / math.sqrt(L):.4f}  E H2/L={h2 / L:.5f}")

    print("(4) adaptive scaffold (walk down a binary tree, L = depth), class of 6 samplers, Protocol R")
    print("    L n | K | E H2, 4E sigma, bound 2LK ln2/n | E TV, bound 2 sqrt(LK ln2/n)")
    for depth, n in [(4, 50), (4, 400), (6, 400), (6, 3200)]:
        h2, sig4, tv, Kb = adaptive_tree(depth, 6, n, reps=300)
        print(f"    L={depth} n={n:5d} | K={Kb:.2f} | {h2:.5f} {sig4:.5f} {2 * depth * Kb * LN2 / n:.5f} | "
              f"{tv:.4f} {min(1.0, 2 * math.sqrt(depth * Kb * LN2 / n)):.4f}")
