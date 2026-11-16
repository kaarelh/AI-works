#!/usr/bin/env python3
"""Numerical checks for Section 4 (Theorem A and the per-call mixture).

(1) Theorem A on the K-coin scaffold (K coins, each asked m times per run):
    (1/N) sum_t E KL(Q_P || Qhat_t) against K ln2 / N, with exact run laws.
(2) A three-hypothesis example in which E KL(Q_P || Qhat_t) is not monotone in t.
(3) Example 4.6 (the per-call mixture fails Theorem A): exact formulas.
(4) Example 4.8 (adaptive scaffold, stochastic human, frozen per-call mixture):
    cumulative expected per-call KL along human runs; two hypotheses (exact sums), and
    B alternatives with K = 1 bit (exact expectations on a grid of t).
Only numpy is needed.
"""
import math
import itertools
import numpy as np

rng = np.random.default_rng(11)
LN2 = math.log(2)


def binom_pmf(N, p):
    k = np.arange(N + 1)
    logc = np.array([math.lgamma(N + 1) - math.lgamma(i + 1) - math.lgamma(N - i + 1) for i in k])
    return np.exp(logc + k * math.log(p) + (N - k) * math.log(1 - p))


# ------------------------------------------------------------------ (1)
def theorem_A_coins(K, m, delta, N, reps):
    """Hypotheses theta in {-1,1}^K with uniform weights, truth all +1.  A run is the
    vector of K counts (sufficient).  Returns two estimates of
        (1/N) sum_{t<=N} E KL(Q_P || Qhat_t),
    Qhat_t the posterior mixture of run laws given t-1 runs:
    (a) the average of the exact conditional divergences KL(Q_P || Qhat_t) (noisy);
    (b) the average of ln(w_N(P)/w(P)) / N, which has the same expectation, because
        sum_t ln(Q_P(tau_t)/Qhat_t(tau_t)) = ln(w_N(P)/w(P)) on every path."""
    thetas = np.array(list(itertools.product([1, -1], repeat=K)))      # truth = row 0
    pm = {+1: binom_pmf(m, 0.5 + delta), -1: binom_pmf(m, 0.5 - delta)}
    laws = []
    for th in thetas:
        P = pm[th[0]]
        for i in range(1, K):
            P = np.multiply.outer(P, pm[th[i]])
        laws.append(P)
    flat = np.array(laws).reshape(len(thetas), -1)
    logflat = np.log(flat)
    truth = flat[0]
    tot_a = tot_b = 0.0
    for _ in range(reps):
        logw = np.zeros(len(thetas))              # uniform prior, log posterior weights
        runs = rng.choice(flat.shape[1], size=N, p=truth)
        acc = 0.0
        for t in range(N):
            w = np.exp(logw - logw.max()); w /= w.sum()
            mix = w @ flat
            acc += float(np.sum(truth * (logflat[0] - np.log(mix))))
            logw += logflat[:, runs[t]]
        w = np.exp(logw - logw.max()); w /= w.sum()
        tot_a += acc / N
        tot_b += (math.log(w[0]) + K * LN2) / N
    return tot_a / reps, tot_b / reps


def theorem_A_one_coin_exact(m, delta, N):
    """K = 1: exact value of sum_{t<=N} E KL(Q_P || Qhat_t) by enumeration."""
    Pp, Pm = binom_pmf(m, 0.5 + delta), binom_pmf(m, 0.5 - delta)
    lr = math.log((0.5 + delta) / (0.5 - delta))
    tot = 0.0
    for t in range(N):
        n = m * t
        pc = binom_pmf(n, 0.5 + delta) if n > 0 else np.array([1.0])
        for c in range(n + 1):
            wp = 1 / (1 + math.exp(-(2 * c - n) * lr))
            mix = wp * Pp + (1 - wp) * Pm
            tot += pc[c] * float(np.sum(Pp * (np.log(Pp) - np.log(mix))))
    return tot


# ------------------------------------------------------------------ (2)
def nonmonotone():
    """One binary observation per run.  Truth Bern(1/2) with prior weight 0.01,
    A = Bern(0.4) with weight 0.89, B = Bern(0.99) with weight 0.10."""
    hyp = np.array([0.5, 0.4, 0.99]); w0 = np.array([0.01, 0.89, 0.10])
    out = []
    for t in range(0, 6):                          # t observed runs
        ekl = 0.0
        for ones in range(t + 1):
            pr = math.comb(t, ones) * 0.5 ** t
            w = w0 * hyp ** ones * (1 - hyp) ** (t - ones); w /= w.sum()
            q = float(w @ hyp)
            ekl += pr * (0.5 * math.log(0.5 / q) + 0.5 * math.log(0.5 / (1 - q)))
        out.append(ekl)
    return out


# ------------------------------------------------------------------ (3)
def occupancy(B, N):
    """Law of the number of distinct values among N uniform draws from B values."""
    p = np.zeros(min(B, N) + 2); p[0] = 1.0
    for _ in range(N):
        q = np.zeros_like(p)
        v = np.arange(len(p))
        q += p * (v / B)
        q[1:] += p[:-1] * (1 - v[:-1] / B)
        p = q
    return p


def example_46(B, N, L):
    """z uniform on [B]; L calls at inputs (z,1..L); f = 0; g_b = 1 on (b,.), 0 elsewhere;
    w(f) = 1/2, w(g_b) = 1/(2B).  After N human runs with v distinct z:
    posterior weight of each surviving g_b is 1/(2B - v).
    Returns E TV and E KL for the frozen per-call mixture and for one posterior draw per
    run (both exact, expectation over v)."""
    pv = occupancy(B, N)
    tv_pc = kl_pc = tv_pr = kl_pr = 0.0
    for v, pr in enumerate(pv):
        if pr == 0 or v > B:
            continue
        w = 1.0 / (2 * B - v)
        frac = (B - v) / B
        tv_pc += pr * frac * (1 - (1 - w) ** L)
        kl_pc += pr * frac * L * (-math.log(1 - w))
        tv_pr += pr * frac * w
        kl_pr += pr * frac * (-math.log(1 - w))
    return tv_pc, kl_pc, tv_pr, kl_pr


# ------------------------------------------------------------------ (4)
def example_48_two(p, eta, N):
    """Two hypotheses, L = 2.  Call 1 at x0; if the answer is 1, call 2 at x1.
    Human: P(1|x0) = p, P(.|x1) = point mass at 1.  Alternative nu: nu(1|x0) = 0,
    nu(.|x1) = point mass at 0.  Weights 1-eta and eta.
    Returns (sum over t <= N of the expected per-call KL along a human run for the frozen
    per-call mixture, the same for the mixture of run laws, K ln 2)."""
    o = eta / (1 - eta)
    frozen = coherent = 0.0
    for t in range(1, N + 1):
        u = (1 - p) ** (t - 1)                   # probability that nu is still alive
        if u == 0.0:
            break
        om = o / (o + u)                         # its posterior weight when alive
        lost = math.log1p(o / u)                 # = ln(1/(1-om))
        k1 = (1 - p) * math.log((1 - p) / (1 - p + p * om)) + p * lost
        coherent += u * k1
        frozen += u * (k1 + p * lost)
    return frozen, coherent, math.log(1 / (1 - eta))


def example_48_many(B, p, n_grid=160):
    """B alternatives of weight 1/(2B), human weight 1/2 (K = 1 bit), L = 2.
    Call 1 at x0 with answers in {0} u [B]; answer i in [B] leads to call 2 at x_i.
    Human: P(i|x0) = p/B, P(0|x0) = 1-p, P(.|x_i) = point mass at 1.
    nu_i: nu_i(i|x0) = 0, nu_i(0|x0) = 1-p+p/B, nu_i(.|x_i) = point mass at 0, else as P.
    Exact expectation (binomial law of the number n0 of runs with answer 0, occupancy law
    of the number v of visited branches) of the second-call loss
        kl2_t = (B-v)(p/B) ln(1/(1-om_t)),  om_t = r^n0 / (B + (B-v) r^n0),
    which is the excess of the frozen per-call mixture over the mixture of run laws;
    summed over t by the trapezoid rule on a logarithmic grid of t."""
    r = (1 - p + p / B) / (1 - p)
    tmax = int(6 * B * math.log(B) / p) + 10
    ts = np.unique(np.round(np.exp(np.linspace(0, math.log(tmax), n_grid))).astype(int))
    bmax = tmax
    # occupancy law occ[b, v] for b = 0..bmax
    occ = np.zeros((bmax + 1, B + 1)); occ[0, 0] = 1.0
    v = np.arange(B + 1)
    for b in range(1, bmax + 1):
        occ[b] = occ[b - 1] * (v / B)
        occ[b, 1:] += occ[b - 1, :-1] * (1 - v[:-1] / B)
    vals = []
    for t in ts:
        nprev = t - 1
        bs = np.arange(nprev + 1)                    # number of branch runs
        logpb = np.array([math.lgamma(nprev + 1) - math.lgamma(k + 1) - math.lgamma(nprev - k + 1)
                          for k in bs]) + bs * math.log(p) + (nprev - bs) * math.log(1 - p)
        pb = np.exp(logpb)
        keep = pb > 1e-16
        bs, pb = bs[keep], pb[keep]
        n0 = nprev - bs
        lr = r ** n0.astype(float)                   # shape (nb,)
        alive = (B - v)[None, :]                     # shape (1, B+1)
        om = lr[:, None] / (B + alive * lr[:, None])
        with np.errstate(divide="ignore", invalid="ignore"):
            loss = np.where(alive > 0, alive * (p / B) * (-np.log1p(-om)), 0.0)
        vals.append(float(np.sum(pb[:, None] * occ[bs] * loss)))
    vals = np.array(vals)
    # sum over integer t by integrating the piecewise-linear interpolation
    total = float(np.sum((vals[1:] + vals[:-1]) / 2 * np.diff(ts))) + vals[0]
    return total, tmax


if __name__ == "__main__":
    print("(1) Theorem A, K coins: average over t<=N of E KL(Q_P||Qhat_t), bound K ln2/N")
    print("    exact, K=1, m=5, delta=0.1, N=50: sum_t E KL =",
          f"{theorem_A_one_coin_exact(5, 0.1, 50):.5f}", " (K ln2 =", f"{LN2:.5f})")
    print("    Monte Carlo (2000 data sets): estimate (a), estimate (b), bound K ln2/N")
    for K, m, delta, N in [(1, 5, 0.1, 50), (2, 5, 0.1, 50), (3, 4, 0.1, 100), (3, 4, 0.05, 100), (3, 4, 0.3, 100)]:
        va, vb = theorem_A_coins(K, m, delta, N, reps=2000)
        print(f"    K={K} m={m} delta={delta} N={N}: (a) {va:.5f}  (b) {vb:.5f}  bound {K * LN2 / N:.5f}")

    print("(2) expected KL of the posterior mixture after t runs, t = 0..5 (not monotone):")
    print("    ", " ".join(f"{x:.5f}" for x in nonmonotone()))

    print("(3) Example 4.6: per-call mixture against one posterior draw per run; K = 1 bit")
    print("    B, N, L | E TV per-call, E TV per-run, Theorem A bound sqrt(ln2/(2N)) | E KL per-call, E KL per-run, ln2/N")
    for B, N, L in [(200, 100, 7), (200, 100, 50), (200, 100, 400), (2000, 1000, 160), (2000, 1000, 4000), (20000, 10000, 500)]:
        tv_pc, kl_pc, tv_pr, kl_pr = example_46(B, N, L)
        print(f"    B={B:6d} N={N:6d} L={L:5d} | {tv_pc:.5f} {tv_pr:.6f} {math.sqrt(LN2 / (2 * N)):.5f} | "
              f"{kl_pc:.6f} {kl_pr:.7f} {LN2 / N:.6f}")

    print("(4) Example 4.8, two hypotheses, L = 2: cumulative expected per-call KL along human runs")
    print("    eta, p, N | frozen per-call mixture | mixture of run laws | K ln2 | (1-p) o ln(1/o) | frozen/(L K ln2)")
    for eta in [1e-1, 1e-2, 1e-4, 1e-8]:
        p = 0.01
        N = int(60 / p)
        fr, co, kln2 = example_48_two(p, eta, N)
        o = eta / (1 - eta)
        print(f"    eta={eta:g} p={p} N={N}: frozen={fr:.4e}  coherent={co:.4e}  K ln2={kln2:.4e}  "
              f"(1-p) o ln(1/o)={(1 - p) * o * math.log(1 / o):.4e}  ratio={fr / (2 * kln2):.3f}")
    print("    many alternatives, K = 1 bit, L = 2, p = 1/2 (exact expectation):")
    print("    B | excess of the frozen per-call mixture, summed over t <= 6 B ln B / p | (ln B)/2 | L K ln2 = 1.386")
    for B in [4, 16, 64, 256]:
        tot, tmax = example_48_many(B, 0.5)
        print(f"    B={B:4d} (t <= {tmax}): excess={tot:.4f}   (ln B)/2={math.log(B) / 2:.4f}")
