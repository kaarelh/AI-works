#!/usr/bin/env python3
"""Independent recomputation of four numerical claims of research/prove-b/hellinger-runs.md that the other
attack scripts do not touch.  Written from the text of the file, not from the prover's or the checker's scripts.

 (1) Example 2.8(ii): the drift-and-drop pair of samplers; ratio H2 / E_P sum h for beta = 1.1, 1.01, 1.001
     (the file: 2.82407, 2.94927, 2.96265), computed in two ways: by Theorem 2.1(a) and from the two run laws.
 (2) Example 4.4: E KL(Q_P || Qhat_{t+1}) for t = 0..5 (the file: 0.00321 0.01058 0.02451 0.03794 0.04298 0.03988).
 (3) Lemma 3.4a: G(N, delta) >= delta sqrt(N/2) for odd N >= 3 and (N-1) delta^2 <= 1/4.
 (4) Example 5.4, brute force over all tables for d = 1, 2 and small N: expected posterior mass of the tables
     at lambda = 1 against E[2^-R / (1 + 2^-R)], and at lambda = 2.
 (6) Example 4.8, second half (construction taken from the docstring of example_48_many in the prover's script
     hellinger-runs_thmA.py: B alternatives of weight 1/(2B), human weight 1/2, L = 2, p = 1/2): the excess of the
     frozen per-call mixture over one posterior draw per run, summed over EVERY round t up to the prover's cut-off
     (no quadrature).  The file: 1.82, 2.50, 3.21, 3.92 for B = 4, 16, 64, 256; the check report: 1.786, 2.494, 3.210, 3.916.
 (5) Example 4.8 (two hypotheses, L = 2) with H^2 in place of KL: the sum over t of the expected per-call
     squared Hellinger distances of the frozen per-call mixture along runs of the human system, against
     K ln2 and against o ln(1/o)/2.  (Finding m8 of the attack report: this sum is not bounded by a multiple
     of L K ln2 either.)

Run:  python3 hellinger-runs_attack_misc.py      (about 1 minute)
"""
import math, itertools, time
import numpy as np
from scipy.special import erf
from scipy.optimize import brentq
from scipy.stats import binom

# ------------------------------------------------------------------ (1)
def g(q): return 1 + q * math.exp(q * q / 4) * (1 / math.sqrt(2) + math.sqrt(math.pi) / 2 * erf(q / 2))
def k(q): return 1 / (1 - q * q / 2)
q0 = brentq(lambda q: g(q) - k(q), 1.0, 1.3, xtol=1e-15)
cstar = k(q0); s0 = 1 / cstar

def q_of_s(s):
    if s >= 1: return 0.0
    if s <= s0: return q0
    return brentq(lambda q: 1 / g(q) - s, 1e-14, q0, xtol=1e-15)

def example_28ii(beta, top=1e6):
    # level k has root likelihood ratio beta^k; S drops with prob pi_k, S' with prob pi_k d_k^2; else up
    H2 = sig = 0.0; R = 1.0           # R = S-probability of reaching level k
    Rq = 1.0                          # S'-probability of reaching level k
    bc = 0.0                          # sum over runs of sqrt(Q_S Q_S')  (runs = "drop at level k")
    kk = 0; lam = 1.0
    while lam <= top:
        if kk == 0: d = beta ** (-0.01)
        elif lam < cstar:
            s = lam / cstar; q = q_of_s(s); p = 2 * (1 - s) / q; d = q / p
        else: d = 0.0
        pi = (beta ** 2 - 1) / (beta ** 2 - d ** 2)
        h = 1 - pi * d - (1 - pi) * beta
        H2 += R * lam * h; sig += R * h
        bc += math.sqrt(R * pi * Rq * pi * d * d)
        R *= (1 - pi); Rq *= (1 - pi) * beta ** 2
        lam *= beta; kk += 1
    # truncation: the run stops when the level exceeds top; that run has S-prob R and S'-prob Rq
    bc += math.sqrt(R * Rq)
    return kk, H2, sig, 1 - bc

# ------------------------------------------------------------------ (2)
def example_44():
    th = np.array([0.5, 0.4, 0.99]); w = np.array([0.01, 0.89, 0.10]); out = []
    for t in range(6):
        tot = 0.0
        for ones in range(t + 1):
            pr = binom.pmf(ones, t, 0.5)
            post = w * th ** ones * (1 - th) ** (t - ones); post /= post.sum()
            m = float(post @ th)
            tot += pr * (0.5 * math.log(0.5 / m) + 0.5 * math.log(0.5 / (1 - m)))
        out.append(tot)
    return out

# ------------------------------------------------------------------ (3)
def lemma_34a():
    worst = 1e9
    for N in list(range(3, 400, 2)) + [1001, 5001, 20001]:
        kk = np.arange(N + 1)
        for frac in [0.05, 0.2, 0.5, 0.8, 1.0]:
            delta = frac * math.sqrt(0.25 / (N - 1))
            if delta >= 0.5: continue
            G = 0.5 * np.abs(binom.pmf(kk, N, 0.5 + delta) - binom.pmf(kk, N, 0.5 - delta)).sum()
            worst = min(worst, G / (delta * math.sqrt(N / 2)))
    return worst

# ------------------------------------------------------------------ (4)
def example_54(d, N):
    X = 2 ** d
    ntab = 2 ** X
    tables = [tuple((i >> j) & 1 for j in range(X)) for i in range(ntab)]
    mass1 = mass2 = formula = 0.0
    for zs in itertools.product(range(X), repeat=N):
        R = N - len(set(zs))
        for ys in itertools.product(range(2), repeat=N):
            pr = (1 / X) ** N * 0.5 ** N
            cons = sum(1 for tb in tables if all(tb[z] == y for z, y in zip(zs, ys)))
            # lambda = 1: weights 1/2 for the coin, 2^-(X+1) per table; likelihood 2^-N for the coin, 1 for consistent tables
            a1 = cons * 2.0 ** (-(X + 1)); b1 = 0.5 * 2.0 ** (-N)
            mass1 += pr * a1 / (a1 + b1)
            a2 = cons * 2.0 ** (-2 * (X + 1)); b2 = 0.25 * 2.0 ** (-N)
            mass2 += pr * a2 / (a2 + b2)
        formula += (1 / X) ** N * 2.0 ** (-R) / (1 + 2.0 ** (-R))
    return mass1, formula, mass2

# ------------------------------------------------------------------ (5)
def example_48_hellinger(eta, p, tmax=50000):      # u_t >= 1e-219 for p = 0.01; later terms are below 1e-200
    o = eta / (1 - eta)
    t = np.arange(1, tmax + 1)
    u = (1 - p) ** (t - 1.0)                       # probability that the alternative is alive before round t
    one_minus_om = u / (o + u)                     # 1 - omega_t, computed without cancellation
    m1 = p * one_minus_om                          # M_t(1|x_0) while alive
    h1 = 0.5 * ((math.sqrt(p) - np.sqrt(m1)) ** 2 + (math.sqrt(1 - p) - np.sqrt(1 - m1)) ** 2)
    h2 = 1 - np.sqrt(one_minus_om)                 # H^2(point mass at 1, M_t(.|x_1))
    kl2 = np.log1p(o / u)                          # ln(1/(1 - omega_t))
    kl1 = p * kl2 + (1 - p) * np.log((1 - p) / (1 - m1))
    SH = float((u * (h1 + p * h2)).sum()); SKL = float((u * (kl1 + p * kl2)).sum())
    return SH, SKL, math.log(1 + o), o

# ------------------------------------------------------------------ (6)
def example_48_many_exact(B, p=0.5):
    r = (1 - p + p / B) / (1 - p)
    tmax = int(6 * B * math.log(B) / p) + 10
    v = np.arange(B + 1)
    occ = np.zeros(B + 1); occ[0] = 1.0            # law of the number of visited branches after b branch runs
    occs = [occ.copy()]
    for b in range(1, tmax + 1):
        new = occ * (v / B); new[1:] += occ[:-1] * (1 - v[:-1] / B); occ = new; occs.append(occ.copy())
    occs = np.array(occs)                          # (tmax+1, B+1)
    total = 0.0
    alive = (B - v).astype(float)
    for t in range(1, tmax + 1):
        m = t - 1
        b = np.arange(m + 1)
        pb = binom.pmf(b, m, p)
        keep = pb > 1e-18
        b, pb = b[keep], pb[keep]
        lr = r ** (m - b).astype(float)            # likelihood ratio of an alive alternative against the human
        om = lr[:, None] / (B + alive[None, :] * lr[:, None])
        with np.errstate(invalid='ignore', divide='ignore'):
            loss = np.where(alive[None, :] > 0, alive[None, :] * (p / B) * (-np.log1p(-om)), 0.0)   # no alternative alive: no excess
        total += float((pb[:, None] * occs[b] * loss).sum())
    return total, tmax

if __name__ == '__main__':
    t0 = time.time()
    print("(1) q0 = %.12f, c* = %.12f" % (q0, cstar))
    for beta in [1.1, 1.01, 1.001]:
        kk, H2, sig, H2b = example_28ii(beta)
        print("    beta = %-6g levels = %-6d H2 (Thm 2.1(a)) = %.6e   H2 (from the run laws) = %.6e   E_P sum h = %.6e   ratio = %.5f" % (beta, kk, H2, H2b, sig, H2 / sig))
    print("(2) Example 4.4:", " ".join("%.5f" % v for v in example_44()))
    print("(3) Lemma 3.4a: smallest G(N,delta) / (delta sqrt(N/2)) over the grid = %.4f  (must be >= 1)" % lemma_34a())
    print("(4) Example 5.4, brute force over all tables: d, N | mass of tables at lambda = 1, formula E[2^-R/(1+2^-R)] | at lambda = 2")
    for (d, N) in [(1, 1), (1, 2), (1, 3), (2, 2), (2, 3), (2, 4)]:
        m1, f, m2 = example_54(d, N)
        print("    d=%d N=%d | %.6f  %.6f | %.3e" % (d, N, m1, f, m2))
    print("(5) Example 4.8 with H^2: eta, p | sum_t E sum_j H^2 , its ratio to L K ln2 , o ln(1/o)/2 | the same sum with KL, ratio to L K ln2")
    for eta in [1e-1, 1e-2, 1e-4, 1e-8]:
        SH, SKL, Kln2, o = example_48_hellinger(eta, 0.01)
        print("    eta=%-6g p=0.01 | %.4e  %.3f  %.4e | %.4e  %.3f" % (eta, SH, SH / (2 * Kln2), o * math.log(1 / o) / 2, SKL, SKL / (2 * Kln2)))
    print("(6) Example 4.8, second half, summed over every t: B | excess | (ln B)/2")
    for B in [4, 16, 64]:
        tot, tmax = example_48_many_exact(B)
        print("    B=%-3d (t <= %d): excess = %.4f   (ln B)/2 = %.4f" % (B, tmax, tot, math.log(B) / 2))
    print("time %.0f s" % (time.time() - t0))
