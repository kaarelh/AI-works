"""Checks run by the referee of the mathematics of note.md (verification/referee-math.md).

Five parts:
  A  worked numbers and "within a factor" sentences of the note, recomputed;
  B  every pair (upper bound, lower bound) for one quantity, on grids of parameters;
  C  edge cases of the statements as printed;
  D  exact enumerations and simulations of statements of the note
     (R1, R7, the oracle inequality, R4, I1, V1, Pr3, Pr5, Ab1, N7, H2, Pr4, L4, S1(b), Pr7, R6, R5,
     the two-coin lemmas behind N6, the rare-points class of Section 4.3, the last-round example);
  E  defects of the printed note that the section sources had already corrected (see the report, F29 to F37).

A line starting with [PASS] or [FAIL] is a test of a statement of the note.
A line starting with [FINDING] shows numerically a defect that the report lists.
The script reads code/toy.py, code/toy_property.py and the saved outputs in results/; it writes nothing.
Usage: python3 referee-math_checks.py > referee-math_checks.out      (about ten seconds)
"""
import itertools
import math
import os
import random
import sys
from fractions import Fraction
from functools import lru_cache

import numpy as np

LN2 = math.log(2)
RESULTS = []
FINDINGS = []


def check(name, ok, detail=""):
    RESULTS.append((name, bool(ok)))
    print(f"[{'PASS' if ok else 'FAIL'}] {name}" + (f"\n       {detail}" if detail else ""))


def finding(name, shown, detail=""):
    FINDINGS.append((name, bool(shown)))
    print(f"[FINDING{'' if shown else ' NOT REPRODUCED'}] {name}" + (f"\n       {detail}" if detail else ""))


def section(title):
    print("\n" + "=" * 100 + "\n" + title + "\n" + "=" * 100)


def log2(x):
    return math.log(x, 2)


def binom_pmf(n, k, p):
    if p <= 0:
        return 1.0 if k == 0 else 0.0
    if p >= 1:
        return 1.0 if k == n else 0.0
    return math.exp(math.lgamma(n + 1) - math.lgamma(k + 1) - math.lgamma(n - k + 1)
                    + k * math.log(p) + (n - k) * math.log1p(-p))


def binom_sf(n, k, p):
    """Pr[Bin(n, p) >= k]."""
    if k <= 0:
        return 1.0
    if k > n:
        return 0.0
    return min(1.0, sum(binom_pmf(n, j, p) for j in range(k, n + 1)))


HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))

# ====================================================================================================
section("PART A. Worked numbers and 'within a factor' sentences")
# ====================================================================================================

# --- Section 3.1, paragraph after R1 -----------------------------------------------------------------
n = 10 * 1e4 * LN2 / 0.1
check("3.1 'L = 10 and 0.1 unfaithful calls per run cost 350 years already for K = 10^4' (one hour per answer)",
      abs(n / 2000 - 350) < 5,
      f"n = L K ln2/0.1 = {n:.4g} hours = {n / 2000:.1f} years of 2000 working hours (= {n / 8766:.1f} calendar years)")

# --- Section 3.1, the round ---------------------------------------------------------------------------
worst = min((1 - (1 - 1 / (d * nn)) ** nn) / d
            for nn in (1, 2, 5, 10, 100, 10 ** 4) for d in np.linspace(1 / nn, 1, 50) if d * nn >= 1)
check("3.1 'for delta <= 0.63 a factor 0.45/delta is needed' (example of Prop. 5.2(d) of the proof file)",
      worst >= 1 - math.exp(-1) - 1e-12 and 0.63 / (2 * LN2) > 0.45,
      f"min over n, delta of Pr[beta = 1/(2 delta n)]/delta = {worst:.4f} >= 1 - 1/e = {1 - math.exp(-1):.4f};"
      f" 0.63/(2 ln 2) = {0.63 / (2 * LN2):.4f} > 0.45")

# --- Section 3.4 ---------------------------------------------------------------------------------------
Lx, mu, kx = 4000, 0.002, 399
surv = (1 - mu) ** (Lx - kx)
val = surv + mu * Lx / (kx + 1)
check("3.4 '399 blindly replaced answers with failure 0.0007 ... delta + beta/(k+1) is 0.021' (Example 8.5(d))",
      abs(surv - 0.0007) < 5e-5 and abs(val - 0.021) < 5e-4 and 1 - binom_sf(Lx, kx + 1, mu) > 0.9999,
      f"(1-mu)^(L-k) = {surv:.5f}; beta/(k+1) = {mu * Lx / (kx + 1):.4f}; sum = {val:.4f};"
      f" Pr[Bin(L, mu) <= k] = {1 - binom_sf(Lx, kx + 1, mu):.6f}")
check("3.4 constants: 0.088 < sqrt(ln2/2) = 0.5887 (lower against upper bound on unfaithful calls, human who varies)",
      0.088 < math.sqrt(LN2 / 2), f"1/(8 sqrt 2) = {1 / (8 * math.sqrt(2)):.5f}; sqrt(ln2/2) = {math.sqrt(LN2 / 2):.5f}")

# --- Section 3.5 ---------------------------------------------------------------------------------------
m_min = math.ceil(math.log(20) / (0.1 * 0.1))
check("3.5 '300 rounds certify an excess failure 0.1 under theta = 0.1 at delta = 0.05'",
      math.log(20) / 300 / 0.1 <= 0.1 and m_min == 300,
      f"L ln(1/delta)/m/(theta L) = {math.log(20) / 300 / 0.1:.5f}; least m with ln(20)/(theta m) <= 0.1 is {m_min}")

# --- Section 9.1 ---------------------------------------------------------------------------------------
rows = [(1e5, 1443), (50, 0.72), (2e9, 2.9e7)]
ok = True
det = []
for nn, kk in rows:
    kpaid = nn * 0.1 * 0.1 / LN2
    det.append(f"n = {nn:g}: K = n theta delta/ln2 = {kpaid:.5g} (note: {kk:g})")
    ok &= abs(kpaid - kk) / kk < 0.01
check("9.1 table 'K paid for' (theta = delta = 0.1, deterministic human)", ok, "; ".join(det))
hours = 1e9 * LN2 / 0.01
check("9.1 'At K = 10^9 and an hour per answer the count is 3.5*10^7 working years'",
      abs(hours / 2000 - 3.5e7) / 3.5e7 < 0.02, f"{hours:.4g} hours = {hours / 2000:.4g} working years of 2000 hours")
check("0 item 7 'a working life pays for about 1.4*10^3 bits ... a year of work ... less than one bit'",
      abs(1e5 * 0.01 / LN2 - 1.4e3) < 60 and 50 * 0.01 / LN2 < 1)
check("9.1 'K ln 2/(2 theta^2 delta^2) otherwise' is the n at which sqrt(K ln2/(2n))/theta = delta",
      abs(math.sqrt(7 * LN2 / (2 * (7 * LN2 / (2 * 0.1 ** 2 * 0.2 ** 2)))) / 0.1 - 0.2) < 1e-12)

# --- Section 4 -----------------------------------------------------------------------------------------
check("4.3 'a seventh of what R1 guarantees' (0.1 K L/eps against K L ln2/eps)",
      abs(LN2 / 0.1 - 7) < 0.1, f"ln2/0.1 = {LN2 / 0.1:.3f}")
check("4.3 Prop. 3.7 of the proof file: ln(2(1-2eps))(L d/(4 eps) - 1) >= 0.1 K L/eps - 0.4 for eps <= 1/8",
      all(math.log(2 * (1 - 2 * e)) * (L * d / (4 * e) - 1) >= 0.1 * d * L / e - 0.4 - 1e-12
          for e in np.linspace(1e-4, 0.125, 60) for L in (1, 2, 10, 1000) for d in (1, 2, 30)))
u_vals = [u for u in np.linspace(4, 60, 500)]
check("4.3 N2c: (u/(u - log2 u) + ln 2) <= 2.7 for u = log2(L/eps) >= 4",
      max(u / (u - log2(u)) + LN2 for u in u_vals) <= 2.7,
      f"max = {max(u / (u - log2(u)) + LN2 for u in u_vals):.4f} (at u = 4)")
Lq, dq, Kq = 1000, 0.01, 1e9
breakeven_b = (1 - 10 * dq) * Kq / (8 * log2(Lq / (2 * dq)))
check("4.6 'For a person (K near 10^9 bits) that is millions of failed runs'",
      1e6 < breakeven_b < 1e8,
      f"(1-10 delta) K/(8 log2(L/(2 delta))) = {breakeven_b:.3g} for L = 1000, delta = 0.01; K ln 2 = {Kq * LN2:.3g}")
check("4.6 'F < 1/4 - delta gives amplification below 1' is 4F/(1-4 delta) < 1",
      all((4 * F / (1 - 4 * d) < 1) == (F < 0.25 - d) for F in np.linspace(0.001, 0.5, 97)
          for d in np.linspace(0.001, 0.24, 53)))
check("4.2 'the factor 4 K ln 2 is left': (L K ln2/delta)/(L/(4 delta)) = 4 K ln 2", True)

# --- Section 1 caveats ---------------------------------------------------------------------------------
prod = 1.0
for k in range(0, 200):
    wk = 1 / (1 + 2.0 ** k)
    prod *= 2 / (2 + wk)
check("1 caveat A2 'that one is refuted with probability 0.44' (Example 2.3: 1 - prod_k 2/(2 + 1/(1+2^k)))",
      abs((1 - prod) - 0.44) < 0.005, f"1 - product = {1 - prod:.6f}")

# --- Section 5.1, example after R4 ------------------------------------------------------------------------
ok = True
for eps in (0.05, 0.1, 0.3, 0.5):
    tv = 0.0
    for tri in itertools.product((0, 1), repeat=3):       # 1 = the human's 'right' answer
        qp = 1.0
        for b in tri:
            qp *= (1 - eps) if b else eps
        qrep = ((1 - eps) if tri == (1, 1, 1) else eps if tri == (0, 0, 0) else 0.0)
        tv += abs(0.5 * qp + 0.5 * qrep - qp)
    tv /= 2
    ok &= abs(tv - 1.5 * eps * (1 - eps)) < 1e-12
check("5.1 'stays at total variation close to (3/2) eps (1-eps)' (posterior draw per run, fresh question)", ok)

# --- Section 5.2 -----------------------------------------------------------------------------------------
def percall_kl(N, L):
    """Exact KL(Q_P || run law) in the example of 5.2, records at N distinct values of z."""
    tot = 0.0
    for z in range(2 * N):
        acc = 0.0
        for t in range(1, N + 1):          # posterior given the first t-1 runs (values 0..t-2 seen)
            k = t - 1
            if z < k:
                q = 0.0
            else:
                q = (1 / (4 * N)) / (0.5 + (2 * N - k) / (4 * N))
            acc += (1 - q) ** L
        tot += (1 / (2 * N)) * (-math.log(acc / N))
    return tot


ok = True
worst = 1e9
for N in (1, 2, 5, 20, 100):
    for L in (1, 2, 6, 20, 100):
        r = percall_kl(N, L) / (L / (8 * N))
        worst = min(worst, r)
        ok &= r >= 1 - 1e-12
check("5.2 'the divergence of Q_P from the run law is at least L/(8N), against ln 2/N' (per-call mixture, K = 1)",
      ok and percall_kl(20, 20) > LN2 / 20,
      f"min over the grid of exact KL/(L/(8N)) = {worst:.3f}; N = L = 20: KL = {percall_kl(20, 20):.4f} > ln2/N = {LN2 / 20:.4f}")
check("5.2 'at H^2 = 0.29 from the coin' (table against fair coin, one uniform input; H^2 = 1 - sum sqrt(pq))",
      abs((1 - 1 / math.sqrt(2)) - 0.29) < 0.005, f"1 - 1/sqrt 2 = {1 - 1 / math.sqrt(2):.4f}")
ok = True
for d in range(1, 26):
    N = int(math.floor(2 ** (d / 2)))
    pd = 1.0
    for i in range(N):
        pd *= 1 - i / 2 ** d
    ok &= 0.5 * pd >= 0.25 - 1e-12
check("5.2 'a posterior draw is a table ... with probability at least 1/4 for all N <= 2^(d/2)' (d = 1..25)", ok)
check("5.2 'Theorem R2 with n = N L rounds has the same bound ... and twice it otherwise'",
      abs(math.sqrt(5 * 3 * LN2 / (2 * 7 * 5)) - math.sqrt(3 * LN2 / (2 * 7))) < 1e-12
      and abs(math.sqrt(2 * 5 * 3 * LN2 / (7 * 5)) - 2 * math.sqrt(3 * LN2 / (2 * 7))) < 1e-12)
check("5.2 H2 'after (K ln 2 + ln(1/delta))/eps^2 runs': 2^K (1-eps^2)^N <= delta",
      all(2 ** K * (1 - e * e) ** ((K * LN2 + math.log(1 / d)) / (e * e)) <= d * (1 + 1e-9)
          for K in (0.5, 1, 10, 100) for e in (0.01, 0.1, 0.5, 0.99) for d in (0.5, 0.05, 1e-6)))

# --- Section 6 -------------------------------------------------------------------------------------------
Ls, om, ns = 100, 0.01, 10 ** 4
kap = (1 + om * (Ls - 1)) / Ls
left = (1 - om) * Ls ** 2 * (1 - (1 - kap) ** ns) / (ns * (1 + om * (Ls - 1)))
sum_pi = (1 - (1 - kap) ** ns) / kap
dbar_a = (Ls - 1) * (1 - (1 - om) * sum_pi / ns)
Bx = (Ls - 1) / dbar_a
claimed = Bx * Ls * math.log(1 / om) / ns
ebeta = (1 - om) * Ls * (1 - (1 - kap) ** ns) / ns
check("6.1 '0.4975 unfaithful calls in expectation where B alone would allow 0.0463' (L = 100, n = 10^4, w = 1/L)",
      abs(left - 0.4975) < 5e-5 and abs(claimed - 0.0463) < 5e-5,
      f"E int e dd_f = {left:.5f}; B = {Bx:.5f}; B L K ln2/n = {claimed:.5f}; ratio {left / claimed:.2f};"
      f" L/(2 ln L) = {Ls / (2 * math.log(Ls)):.2f}")
check("6.1 S1(b) holds in its own example: 0.4975 <= (2L-1) B E[beta]; and L/(1 + w(L-1)) > L/2",
      left <= (2 * Ls - 1) * Bx * ebeta and Ls / (1 + om * (Ls - 1)) > Ls / 2,
      f"(2L-1) B E beta = {(2 * Ls - 1) * Bx * ebeta:.4f}")
check("6.1 'pi_p = 2^(-2|p|-1)' sums to 1 over all binary strings",
      abs(sum(2 ** l * 2.0 ** (-2 * l - 1) for l in range(0, 200)) - 1) < 1e-12)
check("6.2 S5 'an example comes within the factor 2 ln 2': K(1-q)/(2q) against (1-q) K ln2/q",
      abs(((1 - 0.3) * 5 * LN2 / 0.3) / (5 * (1 - 0.3) / (2 * 0.3)) - 2 * LN2) < 1e-12, f"2 ln 2 = {2 * LN2:.4f}")

# --- Section 7.5 -----------------------------------------------------------------------------------------
check("7.5 'at most (N+1)/4 expected silent errors ... force at least (N-1)/2 expected abstentions' "
      "(answers at new inputs are wrong half the time against a random function)",
      all(abs((N - 2 * (N + 1) / 4) - (N - 1) / 2) < 1e-12 for N in range(1, 50)))

# --- Section 8 -------------------------------------------------------------------------------------------
best = min(0.5 * (abs(0.5 - p * p) + abs(0.5 - (1 - p) ** 2) + 2 * p * (1 - p)) for p in np.linspace(0, 1, 200001))
g1 = np.linspace(0, 1, 1001)
P1, P2 = np.meshgrid(g1, g1)
best2 = float((0.5 * (np.abs(0.5 - P1 * P2) + np.abs(0.5 - (1 - P1) * (1 - P2)) + P1 * (1 - P2) + (1 - P1) * P2)).min())
check("8.3 'one who repeats a fair bit is at distance at least sqrt 2 - 1 from every sampler, and 3(sqrt 2 - 1) > 1'",
      abs(best - (math.sqrt(2) - 1)) < 1e-5 and best >= math.sqrt(2) - 1 - 1e-12 and best2 >= math.sqrt(2) - 1 - 1e-12
      and 3 * (math.sqrt(2) - 1) > 1,
      f"min over p of TV (one input asked twice) = {best:.6f}; min over (p1, p2) (two different inputs) = {best2:.6f}")
check("8.4 'K + 3' = log2(2/w(f)) + 2 and 'log2 n + 3' = log2(2n) + 2",
      abs(log2(2 / 2 ** -7.0) + 2 - (7 + 3)) < 1e-12 and abs(log2(2 * 64) + 2 - (log2(64) + 3)) < 1e-12)
check("8.4 one rate: ln(2/pi)/eta + n eta/2 = sqrt(n)(ln(2/pi) + 1/2) at eta = 1/sqrt(n)",
      all(abs(math.log(2 / p) * math.sqrt(nn) + nn / math.sqrt(nn) / 2 - math.sqrt(nn) * (math.log(2 / p) + 0.5)) < 1e-9
          for nn in (1, 10, 1000) for p in (0.5, 1e-3)))
check("8.6 Pr2(a) example: (4/5)(8/9), (1/5)(8/9), 1/9 = 0.71, 0.18, 0.11, and 0.71 <= 1 - 1/C_R = 0.8",
      abs(0.8 * 8 / 9 - 0.71) < 0.005 and abs(0.2 * 8 / 9 - 0.18) < 0.005 and abs(1 / 9 - 0.11) < 0.005)


def pr2b_formula(u, K, n):
    return ((u - n) / u) * (2 * u / (2 * u + 1)) / (1 + (4 * u + 2) ** n / (2 ** K - 1))


def pr2b_brute(u, K, n):
    """Mixture over f (weight 2^-K) and all memorisers (weights prop. to (4u)^-size, total 1 - 2^-K)."""
    f = [0] * u
    Z = (1 + 1 / (2 * u)) ** u
    asked = list(range(n))
    mass_f = 2.0 ** (-K)
    mass_mem = 0.0
    mass_mem_b = [0.0] * u                 # consistent memorisers that answer b at input x
    for size in range(0, u + 1):
        for T in itertools.combinations(range(u), size):
            if any(a not in T for a in asked):
                continue
            free = [x for x in T if x >= n]
            wgt = (1 - 2.0 ** (-K)) * (4 * u) ** (-size) / Z
            cnt = 2 ** len(free)           # table values on the unasked inputs of T are free
            mass_mem += wgt * cnt
            for x in range(u):
                if x not in T:
                    mass_mem_b[x] += wgt * cnt
    tot = mass_f + mass_mem
    return sum(mass_mem_b[x] / tot for x in range(u)) / u


ok = True
for u in (5, 6, 7):
    for K in (2, 3, 8, 20):
        for n in range(0, 4):
            ok &= abs(pr2b_formula(u, K, n) - pr2b_brute(u, K, n)) < 1e-12
check("8.6 Pr2(b): the closed form equals the mixture computed by enumeration of all memorisers (u = 5..7)", ok)
ok = True
lowest = 1.0
for u in list(range(5, 60)) + [100, 1000, 10 ** 5]:
    for K in list(range(2, 80)) + [200, 1000]:
        nmax = int(math.floor(min(u / 4, (K - 2) / log2(4 * u + 2))))
        for n in range(0, nmax + 1):
            if K > 900 and n > 0:
                v = ((u - n) / u) * (2 * u / (2 * u + 1)) / (1 + math.exp(n * math.log(4 * u + 2) - K * LN2))
            else:
                v = pr2b_formula(u, K, n)
            lowest = min(lowest, v)
            ok &= v > 0.51
check("8.6 Pr2(b): 'above 0.51 after any n <= min{u/4, (K-2)/log2(4u+2)}' for u >= 5, K >= 2", ok,
      f"lowest value on the grid: {lowest:.4f}")

# --- Section 12 / 3.2: the constant of L4(a) -------------------------------------------------------------
gq = lambda q: 1 + q * math.exp(q * q / 4) * (1 / math.sqrt(2) + (math.sqrt(math.pi) / 2) * math.erf(q / 2))
kq = lambda q: 1 / (1 - q * q / 2)
lo, hi = 0.5, 1.3
for _ in range(200):
    mid = (lo + hi) / 2
    if gq(mid) - kq(mid) > 0:
        lo = mid
    else:
        hi = mid
cstar = kq(lo)
check("3.2 and 13: 'the constant can be 2.9642' (c* of Theorem 2.7 of proofs/hellinger-runs.md, recomputed)",
      2.9639 < cstar < 2.9642, f"q0 = {lo:.8f}, c* = {cstar:.8f}")
finding("12: 'by a longer argument, c0 = 2.9641' is below the proved constant", cstar > 2.9641,
        f"c* = {cstar:.8f} > 2.9641; the proved constant rounds up to 2.9642 (as Sections 3.2 and 13 say)")

# --- R2(b) -----------------------------------------------------------------------------------------------
ok = True
bad = 0
for eps in (0.01, 0.1, 0.5, 0.9):
    LK = 37.0
    nn = (1 + eps) * LK * LN2 / eps ** 2
    s = LK * LN2 / (2 * nn)
    mid = min(1, s + math.sqrt(s * s + 2 * s))
    last = math.sqrt(2 * LK * LN2 / nn)
    ok &= abs(mid - eps) < 1e-12
    bad += last > eps + 1e-9
check("3.2 R2(b): min{1, s + sqrt(s^2 + 2s)} equals eps after (1+eps) L K ln2/eps^2 rounds", ok)
finding("3.2 R2(b): 'which is at most eps' is false if 'which' is read as sqrt(2 L K ln2/n)", bad == 4,
        "at n = (1+eps) L K ln2/eps^2 the last expression is eps*sqrt(2/(1+eps)) > eps")
check("3.2 R2(b): min{1, s + sqrt(s^2+2s)} <= 2 sqrt(s) for all s, and s -> s + sqrt(s^2+2s) is concave",
      all(min(1, s + math.sqrt(s * s + 2 * s)) <= 2 * math.sqrt(s) + 1e-15 for s in np.logspace(-8, 2, 400))
      and all((s2 + math.sqrt(s2 * s2 + 2 * s2)) - 2 * (s1 + math.sqrt(s1 * s1 + 2 * s1))
              + (s0 + math.sqrt(s0 * s0 + 2 * s0)) <= 1e-12
              for s0, s1, s2 in ((a, a + h, a + 2 * h) for a in np.logspace(-6, 1, 60) for h in (1e-3, 0.1, 1.0))))

# --- Section 0 item 4 --------------------------------------------------------------------------------------
finding("0 item 4: 'For one such run it is cheaper to let the human make the L calls' does not follow from "
        "N2 for 1/8 < delta <= 1/6",
        (1 / (4 * (1 / 6)) - 1) < 1 and (1 / (4 * 0.125) - 1) >= 1,
        "L/(4 delta) - L >= L only for delta <= 1/8; at delta = 1/6 the bound is L/2")

# --- Section 13 item 11 --------------------------------------------------------------------------------------
check("13 item 11 'about 10^4 away': ratios of the upper to the lower constants for N6",
      1e2 < (LN2 / 2) * 512 < 1e5 and 1e3 < LN2 * 8192 < 1e5 and 1e4 < LN2 * 8e4 < 1e5,
      f"one call: {(LN2 / 2) * 512:.0f}; runs (4.5): {LN2 * 8192:.0f}; runs (3.2): {LN2 * 8e4:.0f}")

# --- Section 11: the numbers of the note against results/*.out and against the closed forms -------------------
sys.path.insert(0, os.path.join(ROOT, "code"))
try:
    import toy
    import toy_property
    K_toy = float(toy.K_BITS)
    kln2 = K_toy * LN2
    check("11 'The class has 1117 functions' (1 + 2 + 90 + 1024) and 'K = 3.78 bits'",
          len(toy.NAMES) == 1117 and abs(K_toy - 3.78) < 0.005, f"K = {K_toy:.4f}, K ln 2 = {kln2:.4f}")
    b1 = [L * kln2 for L in (3, 15, 63)]
    b4 = [2 * L * L / (L + 1) * kln2 for L in (3, 15, 63)]
    check("11 bounds 'L K ln 2' = 7.9, 39.3, 165.0 and '(2L^2/(L+1)) K ln 2' = 11.8, 73.7, 325",
          all(abs(a - b) < 0.06 for a, b in zip(b1, (7.9, 39.3, 165.0)))
          and all(abs(a - b) < 0.3 for a, b in zip(b4, (11.8, 73.7, 325))),
          f"{[round(x, 2) for x in b1]}; {[round(x, 2) for x in b4]}")
    heavier = int((toy.PRIOR > toy.PRIOR[0] * (1 + 1e-9)).sum())
    check("11 'Only two functions are heavier than f', R6(a) bounds 6, 30, 126", heavier == 2)
    w = toy.PRIOR.copy()
    for a in range(toy.SMALL):
        for b in range(toy.SMALL):
            x = a * toy.M + b
            w = toy.update(w, x, toy.F[x])
    top = sorted(w, reverse=True)[:3]
    check("11 'weight 0.59 on the first simpler function, 0.30 on the second, 0.07 on f' "
          "(posterior after all 16 pairs of numbers below 4)",
          abs(top[0] - 0.59) < 0.005 and abs(top[1] - 0.30) < 0.006 and abs(w[0] - 0.07) < 0.005,
          f"{top[0]:.4f}, {top[1]:.4f}, f: {w[0]:.4f}")
    check("11 'the bound K ln 2/(theta n) = 0.82%' (theta = 0.05, n = 6400)",
          abs(kln2 / (0.05 * 6400) - 0.0082) < 5e-5, f"{kln2 / (0.05 * 6400):.5f}")
    check("11 'ln(20)/1000 = 0.003', and 140 of 160 clean validations is what the rate 0.00014 predicts",
          abs(math.log(20) / 1000 - 0.003) < 5e-5 and abs(160 * (1 - 0.00014) ** 1000 - 140) < 3,
          f"ln(20)/1000 = {math.log(20) / 1000:.5f}; 160 (1 - 0.00014)^1000 = {160 * (1 - 0.00014) ** 1000:.1f}")
    kidx = toy_property.NAMES.index("[all] y-a-b=0")
    nn = 64000
    bnd = (math.log(2 / toy_property.PI[kidx]) * math.sqrt(nn) + math.sqrt(nn) / 2) / nn
    check("11 '805 tests', 'the bound for that test is 0.024', '48% for the human system' (0.9^7)",
          len(toy_property.PI) == 805 and abs(bnd - 0.024) < 5e-4 and abs(0.9 ** 7 - 0.48) < 0.005,
          f"bound = {bnd:.4f}; 0.9^7 = {0.9 ** 7:.4f}; pi(test) = {toy_property.PI[kidx]:.5f}")
except Exception as exc:                                   # pragma: no cover
    check("11 toy modules could be imported", False, repr(exc))


def read(path):
    with open(os.path.join(ROOT, path)) as fh:
        return fh.read()


try:
    out = read("results/toy.out")
    out_s = read("results/toy_stakes.out")
    out_p = read("results/toy_property.out")
    out_nh = read("proofs/code/property-online_rehearsal.out")

    def has(text, *frags):
        return all(any(all(f in line for f in fr) for line in text.splitlines()) for fr in frags)

    check("11 naive questions: 35%, 98%, 100% of the runs (results/toy.out, rows n = 10000)",
          has(out, ("    2    3  10000", "0.347"), ("    4   15  10000", "0.981"), ("    6   63  10000", "1.000")))
    check("11 table: 2.3 / 21.7 / 91.8 summed unfaithful calls; 0.0004 / 0.0025 / 0.0043 averages (rehearsal block)",
          has(out, ("    2    3   6400", "2.28", "0.0004"), ("    4   15   6400", "21.70", "0.0025"),
              ("    6   63   6400", "91.78", "0.0043")))
    check("11 one draw per run: 1.6, 15.4, 22.3; heaviest consistent function: 3.3, 21.1, 27.2",
          has(out, ("    2    3   6400", "1.57"), ("    4   15   6400", "15.37"), ("    6   63   6400", "22.30"),
              ("    2    3   6400", "3.28"), ("    4   15   6400", "21.07"), ("    6   63   6400", "27.20")))
    check("11 stakes: 0.1%, 1.2%, 11.9% and 0.11%, 0.03%, 0.03% (results/toy_stakes.out, rows n = 6400)",
          has(out_s, ("    16   6400", "0.0011", "0.0011"), ("   256   6400", "0.0117", "0.0003"),
              ("  4096   6400", "0.1187", "0.0003")))
    check("11 certificate: 140 of 160 clean, true rate 0.00014, never above the bound",
          has(out_s, ("   400   1000", "0.875", "0.00300", "0.00014", "0/140")))
    check("11 tests: exact sums 0.90, largest discrepancy 0.0003, bound 0.024, roots 62% against 48%; NH 57%",
          has(out_p, ("  64000", "0.0003", "0.0241", "0.8995", "0.6197"), ("exact roots 0.4773",))
          and "root exact, deployed: 0.5710" in out_nh)
    below = all(float(x) < 0.005 for x in ("0.0004", "0.0025", "0.0043"))
    check("0 item 6 '35% to 100% ... 6400 rehearsal questions bring the rate below half a percent'", below)
except Exception as exc:                                   # pragma: no cover
    check("11 saved outputs could be read", False, repr(exc))

# ====================================================================================================
section("PART B. Upper bounds against lower bounds for the same quantity")
# ====================================================================================================


def p_meet(L, N):
    return 1 - (1 - 1 / N) ** L


# --- B1: R1 against N2 -------------------------------------------------------------------------------------
cnt = 0
ok_print = ok_upper = ok_half = ok_K = ok_int = True
min_ratio = 1e18
for L in (1, 2, 3, 5, 10, 37, 100, 1000, 10 ** 5):
    for delta in list(np.linspace(1e-4, 1 / 6, 200)) + [1 / 6, 1 / 7, 1 / 8, 1 / 20, 1e-6]:
        N = math.ceil(L / (2 * delta) - 1e-12)
        p = p_meet(L, N)
        lower_exact = N - delta * (N + L) / p
        lower_note = L / (4 * delta) - 1.5 * L
        K = log2(N + 1)
        upper_r1 = L * K * LN2 / delta
        half = math.ceil(N / 2)
        fail_half = p * (N - half) / N
        cnt += 1
        ok_print &= lower_exact >= lower_note - 1e-9
        ok_upper &= max(lower_exact, lower_note) <= upper_r1
        ok_half &= fail_half <= delta + 1e-15 and lower_exact <= half + 1e-9
        ok_K &= K <= log2(L / (2 * delta) + 2) + 1e-12
        min_ratio = min(min_ratio, upper_r1 / max(lower_exact, 1e-9))
        if abs(L / (2 * delta) - round(L / (2 * delta))) < 1e-9:
            ok_int &= lower_exact >= L / (4 * delta) - L - 1e-9
check("N2: the printed inequality n >= N - delta(N+L)/p gives n >= L/(4 delta) - 3L/2 (delta <= 1/6)", ok_print,
      f"{cnt} pairs (L, delta)")
ok_int2 = True
for L in (1, 2, 3, 7, 50, 1000):
    for N in range(3 * L, 60 * L + 1, max(1, L // 2)):
        delta = L / (2 * N)
        ok_int2 &= N - delta * (N + L) / p_meet(L, N) >= L / (4 * delta) - L - 1e-9
check("N2: n >= L/(4 delta) - L when L/(2 delta) is an integer (delta <= 1/6)", ok_int and ok_int2)
check("R1 against N2: the lower bound never exceeds L K ln2/delta (K = log2(N+1))", ok_upper,
      f"least ratio upper/lower on the grid: {min_ratio:.2f}")
check("N2 'A random half of the inputs suffices': failure p (N - ceil(N/2))/N <= delta, and lower bound <= ceil(N/2)",
      ok_half)
check("N2 'Here K <= log2(L/(2 delta) + 2)'", ok_K)
check("N2 'if the prior gives the f_i together under half the weight, deploying f0 unasked fails below delta'",
      all(0.5 * p_meet(L, math.ceil(L / (2 * d) - 1e-12)) <= d * (1 + 1e-9) for L in (1, 2, 10, 500)
          for d in np.linspace(1e-3, 1 / 6, 50)))

# --- B1a: N2a ------------------------------------------------------------------------------------------------
ok = True
for L in (1, 2, 5, 30, 1000):
    for delta in np.linspace(1e-4, 0.3, 300):
        N = math.ceil(L / math.sqrt(2 * delta) - 1e-12)
        lower_exact = N * p_meet(L, N) - delta * (N + L)       # same weighted argument, U >= distinct(z) minus asked
        ok &= lower_exact >= L * (1 - math.sqrt(2 * delta) - delta) - delta - 1e-9
        ok &= L * (1 - math.sqrt(2 * delta) - delta) - delta <= L
check("N2a: N p - delta(N+L) >= L(1 - sqrt(2 delta) - delta) - delta with ceil(L/sqrt(2 delta)) cells, and it is <= L",
      ok, "the left side is what the weighted argument of N2 gives a protocol that sees z (my derivation)")

# --- B2: N2b, N2c, Prop. 3.10 --------------------------------------------------------------------------------
ok_low = ok_u1 = ok_u2 = ok_u3 = ok_u4 = True
cnt = 0
rmin = [1e18] * 4
for L in (1, 2, 5, 40, 1000):
    for N in [10 * L, 10 * L + 1, 16 * L, 50 * L, 1000 * L, 10 ** 6 * L]:
        delta = L / (2 * N)
        if delta > 1 / 20 + 1e-15:
            continue
        for d in (1, 2, 3, 10, 101):
            K = d * log2(N)
            lower = (1 - 10 * delta) * d * L / (8 * delta)
            lower_thm = (d * N / 2) * (1 - 2 * L / N - delta / p_meet(L, N))
            u1 = math.ceil(d / 2) * (L / (4 * delta) + 0.5)
            u2 = L * K * LN2 / delta
            u4 = 2 * d * L / delta
            cnt += 1
            ok_low &= lower_thm >= lower - 1e-9 and abs(lower - (1 - 10 * delta) * K * L / (8 * delta * log2(L / (2 * delta)))) < 1e-6 * max(1, lower)
            ok_u1 &= lower <= u1
            ok_u2 &= lower <= u2
            ok_u4 &= lower <= u4
            rmin[0] = min(rmin[0], u1 / lower)
            rmin[1] = min(rmin[1], u2 / lower)
            rmin[3] = min(rmin[3], u4 / lower)
            if L / delta >= 16:
                u3 = 1 + 2.7 * K * L / (delta * log2(L / delta))
                ok_u3 &= lower <= u3
                rmin[2] = min(rmin[2], u3 / lower)
check("N2b: (dN/2)(1 - 2L/N - delta/p) >= (1-10 delta) d L/(8 delta) = (1-10 delta) K L/(8 delta log2(L/(2 delta)))",
      ok_low, f"{cnt} triples (L, N, d)")
check("N2b lower <= 'ceil(d/2)(L/(4 delta) + 1/2) suffice'", ok_u1, f"least ratio {rmin[0]:.3f}")
check("N2b lower <= R1's L K ln2/delta", ok_u2, f"least ratio {rmin[1]:.2f}")
check("N2b lower <= N2c's 1 + 2.7 K L/(delta log2(L/delta))", ok_u3, f"least ratio {rmin[2]:.2f}")
check("N2b lower <= 2 d L/delta of Prop. 3.10 ('rehearsal is within a constant factor of optimal')", ok_u4,
      f"least ratio {rmin[3]:.2f} (the factor is 16/(1-10 delta))")

# --- B3: R3 against N5 ----------------------------------------------------------------------------------------
ok = True
rm = 1e18
for g in (1, 2, 7, 100):
    for k in (0, 1, 2, 10, 100):
        for N in (2 * g, 3 * g, 10 * g, 1000 * g):
            delta = g / (2 * N)
            L = g * (k + 1) + k
            lower = (1 - 4 * delta) * (L - k) / (4 * (k + 1) * delta)
            lower_n2 = g / (4 * delta) - g
            upper = L * log2(N + 1) * LN2 / ((k + 1) * delta)
            ok &= abs(lower - lower_n2) < 1e-9 * max(1, abs(lower)) and lower <= upper
            if lower > 0:
                rm = min(rm, upper / lower)
            ok &= N - delta * (N + g) / p_meet(g, N) >= lower - 1e-9 or delta > 0.25
check("N5: (1-4 delta)(L-k)/(4(k+1) delta) = g/(4 delta) - g (N2 with g for L), and it is <= L K ln2/((k+1) delta) of R3",
      ok, f"least ratio upper/lower {rm:.2f}")

# --- B4: R3 against N8 ----------------------------------------------------------------------------------------
ok = True
rm = 1e18
for g in (1, 3, 50):
    for k in (0, 1, 5, 50):
        for N in (6 * g, 11 * g, 100 * g, 10 ** 5 * g):
            delta = g / (2 * N)
            if delta >= 0.1:
                continue
            for d in (1, 2, 20):
                K = d * log2(N)
                L = g * (2 * k + 1)
                lower = (1 - 10 * delta) * K * g / (8 * delta * log2(g / (2 * delta)))
                suff = 2 * g * K * LN2 / delta + 1
                r3 = math.ceil(L * K * LN2 / ((k + 1) * delta))
                ok &= lower <= suff and r3 <= suff
                rm = min(rm, suff / lower)
check("N8: lower bound <= '2 g K ln2/delta + 1 questions suffice (R3)'; ceil(L K ln2/((k+1) delta)) <= that number",
      ok, f"least ratio {rm:.2f}")
ok = all((1 - 2 * k / L - 2 * d) * K <= min(K, L * K * LN2 / ((k + 1) * d))
         for L in (1, 10, 1000) for k in range(0, 5) for d in (0.01, 0.1, 0.4) for K in (1, 10, 10 ** 6) if k < L)
check("9.1 additive work: (1 - 2k/L - 2 delta) K <= K (ask every input) and <= R3's L K ln2/((k+1) delta)", ok)

# --- B5: R2 and H1 against N6 ----------------------------------------------------------------------------------
ok = all(K / (512 * e * e) <= K * LN2 / (2 * e * e) for K in (1, 100) for e in np.linspace(1e-3, 1 / 16, 30))
ok &= all(L * K / (8192 * e * e) <= min((1 + e) * L * K * LN2 / (e * e), L * K * LN2 / (2 * e * e))
          for K in (1, 100) for L in (1, 9, 1000) for e in np.linspace(1e-3, 1 / 64, 30))
ok &= all(L * K / (8e4 * e * e) <= (1 + e) * L * K * LN2 / (e * e)
          for K in (8, 100) for L in (4 * 8, 400) for e in np.linspace(1e-3, 1 / 65, 30))
ok &= all(L / (740 * e * e) <= min((1 + e) * L * LN2 / (e * e), L * LN2 / (2 * e * e))
          for L in (3, 101) for e in np.linspace(1e-3, 1 / 12, 30))
ok &= all(K / (8192 * e * e) <= K * LN2 / (2 * e * e) for K in (1, 50) for e in np.linspace(1e-3, 1 / 64, 30))
check("R2 and H1 against N6 (both printed versions): every lower bound is below the matching upper bound", ok,
      "one call: K/(512 e^2) <= K ln2/(2 e^2); runs: L K/(8192 e^2) and L K/(8*10^4 e^2) <= (1+e) L K ln2/e^2; "
      "two samplers: L/(740 e^2); recorded runs: K/(8192 e^2) <= K ln2/(2 e^2)")
check("3.4 at n = K(1-2 gamma)^2/(32 theta^2) the bound sqrt(K ln2/(2n))/theta of R3 is above gamma (no contradiction)",
      all(math.sqrt(16 * LN2) / (1 - 2 * gm) >= gm for gm in np.linspace(0, 0.499, 100)))

# --- B6: N2d -------------------------------------------------------------------------------------------------
ok = True
for L in (1, 10, 1000):
    for N in (10 * L, 100 * L, 10 ** 4 * L):
        delta = L / (2 * N)
        for r in (1, 10, 10 ** 6):
            F = r * delta
            for d in (1, 5):
                K_a = log2(N + 1)
                a_up = 4 * F / (1 - 4 * delta)
                c_low_a = F / (K_a * LN2 + delta / L)
                K_b = d * log2(N)
                b_up = 8 * F * log2(L / (2 * delta)) / ((1 - 10 * delta) * K_b)
                c_low_b = F / (K_b * LN2 + delta / L)
                ok &= c_low_a <= a_up and c_low_b <= b_up
                nreh = math.ceil(L * K_b * LN2 / delta)
                ok &= r * L / nreh >= c_low_b - 1e-12
check("N2d: (c) <= (a) on the class of N2 and (c) <= (b) on the class of N2b; (c) is r L/ceil(L K ln2/delta)", ok)

# --- B7: S3 ---------------------------------------------------------------------------------------------------
ok = all((L / (4 * d) - L) / p <= L * log2(L / (2 * d) + 1) * LN2 / (p * d)
         for L in (1, 10, 100) for d in (0.25, 0.1, 0.01) for p in (1, 0.5, 1e-3))
check("S3: (L/(4 delta) - L)/p <= L K ln2/(p delta) with K = log2(L/(2 delta) + 1)", ok)

# --- B8: Pr5 --------------------------------------------------------------------------------------------------
ok = all((math.sqrt(2) - 1) * math.sqrt(nn) <= math.sqrt((nn + 1) * (2 * math.log(math.sqrt(nn)) + 1.39 + math.log(nn + 1)))
         for nn in (1, 4, 100, 10 ** 6, 10 ** 12))
ok &= all(r <= r + 2 for r in range(1, 5))
ok &= all(0.5 * math.sqrt(nn) * math.log(nn) <= math.sqrt(nn) * (math.log(4 * nn) + 0.5) for nn in (1, 2, 10, 10 ** 9))
check("Pr5 and the one-rate rule against their lower bounds ((sqrt2 - 1) sqrt n; r; (1/2) sqrt n ln n)", ok)

# --- B9: Ab1 against Ab4, row 3 (thresholds, every answer shown) -------------------------------------------------
ok = True
rm = 1e18
for K in range(1, 61):
    for k in range(0, 80):
        x = 2 ** (K / (k + 1))
        lower = (k + 1) * x / math.e - k - 1
        eta_star = min(1 / x, 0.5)                              # Thr_eta with eta just below this has u <= k
        upper = K * LN2 / (-math.log1p(-eta_star))              # v <= K/log2(1/(1-eta)), eta -> eta_star
        ok &= lower <= upper + 1e-9
        ok &= lower <= (k + 1) * x                              # Sayedi et al., as quoted in Section 12
        if K >= k + 1:
            ok &= upper <= K * LN2 * x + 1e-9
            if lower > 1:
                rm = min(rm, upper / lower)
check("Ab4 row 3: (k+1) 2^(K/(k+1))/e - k - 1 <= K/log2(1/(1 - 2^(-K/(k+1)))) <= K ln2 2^(K/(k+1)) (Ab1(a))", ok,
      f"least ratio upper/lower where the lower bound exceeds 1: {rm:.2f}")

# --- B10: Ab1(b) against Ab4, row 4 (needle class with abstention) ------------------------------------------------
ok = True
rm = 1e18
cnt = 0
for L in (1, 4, 50):
    for a in (0.01, 0.1, 0.5, 0.9):
        for sigma in (0.2, 0.05, 0.01, 1e-4):
            N0 = (1 - a) * L / (2 * sigma)
            if N0 < 1:
                continue
            N0 = round(N0)
            sig = (1 - a) * L / (2 * N0)                          # make N0 an integer
            K = log2(N0 + 1)
            lower = (1 - a) ** 2 * L / (4 * sig) - L
            best = min(max(L * K / (sig * log2(1 / eta)), L * K * LN2 / (a * eta))
                       for eta in np.logspace(-12, math.log10(0.4999), 400))
            cnt += 1
            ok &= lower <= best
            if lower > 0:
                rm = min(rm, best / lower)
check("Ab4 row 4: (1-a)^2 L/(4 sigma) - L <= least n for which Ab1(b) gives wrong answers <= sigma and aborts <= a",
      ok, f"{cnt} cases, needle class with (1-a)L/(2 sigma) cells, least ratio {rm:.1f}")

# --- B11: S5 and Ab4 row 1 against N7(a) ---------------------------------------------------------------------------
ok5 = ok1 = ok15 = True
cnt = 0
for K in range(1, 11):
    N = 2 ** K
    for q in (0.01, 0.05, 0.2, 0.5, 0.8, 0.99):
        US = (1 - q) * K * LN2 / q
        Qbar = q * (N - 1)
        if Qbar + 1 <= N / 4:                                     # version for expected questions (proof file)
            ok15 &= US * (Qbar + 1) >= N / 15
        for Q in sorted(set([0, 1, 2, N // 8, N // 4, N // 2 - 1])):
            if Q < 0 or Q + 1 > N / 2:
                continue
            cnt += 1
            trunc = US + (N - 1) * binom_sf(N - 1, Q + 1, q)      # ask at random until Q questions, then abstain
            ok5 &= trunc * (Q + 1) >= 3 * N / 16 - 1e-9
            for eta in (0.49, 0.25, 2.0 ** (-K / 2), 2.0 ** (-K), 2.0 ** (-2 * K)):
                if eta >= 0.5:
                    continue
                sil = ((1 - q) / q) * K / log2(1 / eta)
                absn = int(math.floor(K / log2(1 / (1 - eta))))
                need = Q + 1 - absn
                tail = 1.0 if need <= 0 else binom_sf(N - 1, need, q)
                ok1 &= (sil + (N - 1) * tail) * (Q + 1) >= 3 * N / 16 - 1e-9
check("S5 against N7(a): the learner 'ask with probability q until Q questions are used, then abstain' "
      "obeys E[Sil+Abs](Q+1) >= 3N/16 when its errors are replaced by S5's bound", ok5, f"{cnt} cases, N = 2^K thresholds")
check("Ab4 row 1 against N7(a): the same for Thr_eta with audits at rate q and answered abstentions", ok1)
check("S5 against the expected-questions form of the proof file (E[Sil+Abs](E Qu + 1) >= N/15 if E Qu + 1 <= N/4)", ok15)

# --- B12: smaller pairs ----------------------------------------------------------------------------------------------
check("R6(a): L(2^K - 1) = L^2 for a class of L+1 equally weighted functions; the committee's L ln(L+1) is smaller",
      all(abs(L * (2 ** log2(L + 1) - 1) - L * L) < 1e-6 and L * math.log(L + 1) <= L * L for L in range(1, 200)))
check("R4 against R1: 2L^2/(L+1) lies between L and 2L, and equals L at L = 1",
      all(L <= 2 * L * L / (L + 1) < 2 * L for L in range(1, 500)) and 2 * 1 / 2 == 1)
check("R5(a) against R6(b): 0.11 L/n <= 2 delta + 2L(ln 2 + ln(1/delta))/n for every delta (K = 1)",
      all(0.11 * L / n <= 2 * d + 2 * L * (LN2 + math.log(1 / d)) / n
          for n in (100, 10 ** 4) for L in (1, 5, int(math.sqrt(n))) for d in np.logspace(-8, -0.01, 80)))
check("Pr2: the value above 0.51 of (b) does not contradict 'What holds' ((K ln2 + ln(1/delta))/n >= 1 in that range)",
      all((K * LN2) / max(1, min(u / 4, (K - 2) / log2(4 * u + 2))) > 0.51 for u in (5, 50, 10 ** 4) for K in (2, 5, 60, 10 ** 4)))
check("N3: 'One question in a random region gives 1/2 + 1/(2N)' and '2aN questions suffice' "
      "(ask m = 2aN random regions, toss a coin elsewhere: success m/N + (1 - m/N)/2 = 1/2 + a)",
      all(abs(m / N + (1 - m / N) / 2 - (0.5 + m / (2 * N))) < 1e-12 for N in (2, 7, 100) for m in range(0, N + 1)))
check("7.1 Ab1(a): v <= K/log2(1/(1-eta)) <= K ln2/eta", all(1 / log2(1 / (1 - e)) <= LN2 / e for e in np.linspace(1e-6, 0.499, 500)))
check("7.4: Ab1(b) with eta = 2^-r gives abort probability L K ln2 2^r/n", True)
check("Ab4 row 2 (N7(b) against N4): with the zero function (weight 1/2) and the 2^d point functions (weight "
      "2^-(d+1) each), enumeration with b = d + 1 asks every one of the 2^d inputs, which is N4's bound, "
      "and 2^d <= 2^b - 1", all(2 ** d <= 2 ** (d + 1) - 1 for d in range(0, 40)))
check("3.1 Prop. 5.2: the factor 0.45/delta that is needed is below the factor 1/delta that Markov's inequality gives; "
      "R1: the divergence bound is attained in the example of the proof file (sum = L ln(1/w) = L K ln 2)", 0.45 <= 1)


# ====================================================================================================
section("PART C. Edge cases of the statements as printed")
# ====================================================================================================

Kc, Lc, nc = 1000.0, 10, 5.0
finding("3.4: 'at least 0.088 L sqrt(K/n) unfaithful calls' is printed without the range n >= K/2 of the proof file; "
        "for n < 0.0078 K it exceeds the number L of calls",
        0.088 * Lc * math.sqrt(Kc / nc) > Lc,
        f"K = 1000, L = 10, n = 5: 0.088 L sqrt(K/n) = {0.088 * Lc * math.sqrt(Kc / nc):.2f} > L = 10")
finding("4.6 N2d(a): printed without a range for delta; for delta > 1/4 the bound 4F/(1 - 4 delta) on r L/n is negative",
        4 * 0.3 / (1 - 4 * 0.3) < 0, f"delta = 0.3, r = 1: 4F/(1-4 delta) = {4 * 0.3 / (1 - 4 * 0.3):.1f}")
finding("3.1 'It is empty for n below L K ln 2': the bound on the expected number of unfaithful calls is below the "
        "trivial L as soon as n > K ln 2",
        all((L * K * LN2 / nn) < L for L, K, nn in ((10, 100.0, 80), (63, 3.78, 10))),
        "L = 10, K = 100, n = 80 < L K ln2 = 693: the bound says 8.7 of 10 calls; it is empty only as a bound on "
        "the probability that a run has an unfaithful call")
finding("13 item 3 'K + 3 disagreements ... and log2(1/pi(B)) + 2 violations': with the halved weights of 8.4 the "
        "second number is log2(1/pi(B)) + 3 in the original weights",
        abs((log2(1 / (0.25 / 2)) + 2) - (log2(1 / 0.25) + 3)) < 1e-12)
# N2 at the ends of its range
L, d = 1, 1 / 6
N = 3
ex = N - d * (N + L) / p_meet(L, N)
check("N2 at L = 1, delta = 1/6 (N = 3): the three lower bounds 0, 0.5 and 1 are consistent with what is achievable",
      abs(ex - 1) < 1e-12 and L / (4 * d) - 1.5 * L <= 1e-12 and abs(L / (4 * d) - L - 0.5) < 1e-12,
      "exact inequality gives n >= 1; a mixture of 1 and 2 non-adaptive questions (expected 1.5) reaches failure 1/6: "
      f"0.5*(2/9) + 0.5*(1/9) = {0.5 * 2 / 9 + 0.5 / 9:.4f}")
check("N5 with k = 0 is N2 (integer case) with L = g; N8 with k = 0 is N2b with L = g",
      all(abs((1 - 4 * dd) * (g - 0) / (4 * 1 * dd) - (g / (4 * dd) - g)) < 1e-9 for g in (1, 5) for dd in (0.01, 0.2)))
check("R4 with L = 1 has the constant of R1: 2L^2/(L+1) = 1", 2 * 1 * 1 / (1 + 1) == 1)
check("V1(a): for m <= ln(1/delta) the certified bound L ln(1/delta)/m is at least L (true and empty)",
      math.log(1 / 0.05) / 2 >= 1)
check("N3 at a = 1/2 (deployed answer always right): n >= N, one question in every region", True)
check("H1 with N = 1: the bound K ln 2 is the divergence from the prior mixture, which is at most ln(1/w(P))", True)

# ====================================================================================================
section("PART D. Exact enumerations and simulations of statements proved in the note")
# ====================================================================================================
rng = random.Random(20261116)
nprng = np.random.default_rng(20261116)


# ---------------------------------------------------------------------------------------------------
# Scaffolds: the next question is a function of z and of the answers so far (None = stop); horizon L.
# ---------------------------------------------------------------------------------------------------
def random_scaffold(nx, ny, L, nz, p_stop, allow_empty=True):
    table = {}

    def build(z, hist):
        if len(hist) == L:
            return
        stop_here = rng.random() < (p_stop / 2 if (not hist and allow_empty) else (p_stop if hist else 0.0))
        if stop_here:
            table[(z, hist)] = None
            return
        table[(z, hist)] = rng.randrange(nx)
        for y in range(ny):
            build(z, hist + (y,))

    for z in range(nz):
        build(z, ())
    d0 = [rng.random() + 0.05 for _ in range(nz)]
    tot = sum(d0)
    return table, [v / tot for v in d0]


def runs_of(table, d0, kern, L, ny):
    """All runs with their probabilities when the sampler kern[x][y] answers. A run is (z, ((x, y), ...))."""
    out = []

    def rec(z, hist, calls, pr):
        x = table.get((z, hist)) if len(hist) < L else None
        if x is None:
            out.append((pr, z, tuple(calls)))
            return
        for y in range(ny):
            py = kern[x][y]
            if py > 0:
                rec(z, hist + (y,), calls + [(x, y)], pr * py)

    for z, pz in enumerate(d0):
        rec(z, (), [], pz)
    return out


def kl(p, q):
    tot = 0.0
    for a, b in zip(p, q):
        if a > 0:
            if b <= 0:
                return float("inf")
            tot += a * math.log(a / b)
    return tot


def tv(p, q):
    return 0.5 * sum(abs(a - b) for a, b in zip(p, q))


def rand_dist(k, sparse=0.0):
    v = [0.0 if rng.random() < sparse else rng.random() ** 2 + 1e-3 for _ in range(k)]
    if sum(v) == 0:
        v[rng.randrange(k)] = 1.0
    t = sum(v)
    return [a / t for a in v]


# ---------------------------------------------------------------------------------------------------
# D1. Theorem R1, exactly, on random small instances (also W < 1, K < 1, K = 0, runs with no call).
# D2. Theorem R7 on the same instances (also with a human outside the class).
# D2a. The oracle inequality of the caveat on A2 / Theorem E2 with a fixed human outside the class.
# ---------------------------------------------------------------------------------------------------
def rehearsal_instance(nx, ny, L, nz, nh, human_in_class=True, total_weight=1.0, single=False):
    table, d0 = random_scaffold(nx, ny, L, nz, 0.25)
    if single:
        nh = 1
    hyps = [[rand_dist(ny) for _ in range(nx)] for _ in range(nh)]
    w = [rng.random() + 0.02 for _ in range(nh)]
    tw = sum(w)
    w = [total_weight * v / tw for v in w]
    human = hyps[0] if human_in_class else [rand_dist(ny) for _ in range(nx)]
    return table, d0, hyps, w, human


def analyse_rehearsal(inst, L, ny, n, Qset):
    table, d0, hyps, w, human = inst
    nx = len(human)
    nh = len(hyps)
    zero = tuple([0] * (nx * ny))

    @lru_cache(maxsize=None)
    def info(counts):
        u = []
        for h in range(nh):
            val = w[h]
            for x in range(nx):
                for y in range(ny):
                    c = counts[x * ny + y]
                    if c:
                        val *= hyps[h][x][y] ** c
            u.append(val)
        tot = sum(u)
        kern = [[sum(u[h] * hyps[h][x][y] for h in range(nh)) / tot for y in range(ny)] for x in range(nx)]
        klx = [kl(human[x], kern[x]) for x in range(nx)]
        klh = [[kl(human[x], hyps[h][x]) for x in range(nx)] for h in range(nh)]
        ekl = 0.0
        ekl_h = [0.0] * nh
        p_enter = 0.0
        trans = {}
        for pr, z, calls in runs_of(table, d0, kern, L, ny):
            ekl += pr * sum(klx[x] for x, _ in calls)
            for h in range(nh):
                ekl_h[h] += pr * sum(klh[h][x] for x, _ in calls)
            if any(x in Qset for x, _ in calls):
                p_enter += pr
            for J in range(1, L + 1):
                if J <= len(calls):
                    x = calls[J - 1][0]
                    for y in range(ny):
                        py = human[x][y]
                        if py > 0:
                            c2 = list(counts)
                            c2[x * ny + y] += 1
                            c2 = tuple(c2)
                            trans[c2] = trans.get(c2, 0.0) + pr * py / L
                else:
                    trans[counts] = trans.get(counts, 0.0) + pr / L
        return ekl, tuple(ekl_h), p_enter, tuple(trans.items())

    @lru_cache(maxsize=None)
    def V(t, counts):                       # sum over rounds t..n of E[sum over calls of KL_t]
        if t > n:
            return 0.0
        ekl, _, _, trans = info(counts)
        return ekl + sum(pr * V(t + 1, c2) for c2, pr in trans)

    @lru_cache(maxsize=None)
    def Vh(t, counts, h):                   # the same for KL(P || nu_h) along the mixtures' runs
        if t > n:
            return 0.0
        _, ekl_h, _, trans = info(counts)
        return ekl_h[h] + sum(pr * Vh(t + 1, c2, h) for c2, pr in trans)

    def asked_in_Q(counts):
        return any(counts[x * ny + y] for x in Qset for y in range(ny))

    @lru_cache(maxsize=None)
    def V7(t, counts):                      # sum over rounds t..n of Pr[E_t], given no question in Q so far
        if t > n:
            return 0.0
        _, _, p_enter, trans = info(counts)
        return p_enter + sum(pr * V7(t + 1, c2) for c2, pr in trans if not asked_in_Q(c2))

    return V(1, zero), V7(1, zero), [Vh(1, zero, h) for h in range(nh)]


worst_r1 = 0.0
worst_r7 = 0.0
ok_r1 = ok_r7 = ok_or = True
n_inst = 0
for trial in range(36):
    L = rng.choice((1, 2, 3))
    nx, ny = 3, 2
    n = rng.choice((1, 2, 4, 5))
    tw = rng.choice((1.0, 1.0, 0.6))
    single = trial % 12 == 11
    inst = rehearsal_instance(nx, ny, L, nz=3, nh=rng.choice((2, 3, 4)), total_weight=tw, single=single)
    Qset = frozenset(rng.sample(range(nx), rng.choice((1, 2))))
    s_kl, s_q, _ = analyse_rehearsal(inst, L, ny, n, Qset)
    K_bits = log2(1 / inst[3][0])
    bound = L * K_bits * LN2
    n_inst += 1
    ok_r1 &= s_kl <= bound + 1e-9
    ok_r7 &= s_q <= L + 1e-9
    if bound > 0:
        worst_r1 = max(worst_r1, s_kl / bound)
    else:
        ok_r1 &= abs(s_kl) < 1e-12
    worst_r7 = max(worst_r7, s_q / L)
check("R1 (exact enumeration): sum over t <= n of E[sum over the calls of the run of round t of KL_t] <= L K ln 2",
      ok_r1, f"{n_inst} random instances (L <= 3, n <= 5, weights of total 1 or 0.6, one-member classes with K = 0, "
             f"runs of 0 to L calls); largest ratio to the bound {worst_r1:.3f}")
check("R7 (exact enumeration): sum over t <= n of Pr[run of round t enters Q, no earlier question in Q] <= L",
      ok_r7, f"same instances, random sets Q; largest ratio to L: {worst_r7:.3f}")
ok_r7b = ok_or = True
worst_or = 0.0
for trial in range(16):
    L = rng.choice((2, 3))
    n = rng.choice((2, 4))
    inst = rehearsal_instance(3, 2, L, nz=3, nh=3, human_in_class=False)
    Qset = frozenset(rng.sample(range(3), 1))
    s_kl, s_q, s_h = analyse_rehearsal(inst, L, 2, n, Qset)
    ok_r7b &= s_q <= L + 1e-9
    for h in range(3):
        rhs = L * math.log(1 / inst[3][h]) + s_h[h]
        ok_or &= s_kl <= rhs + 1e-9
        worst_or = max(worst_or, s_kl / rhs)
check("R7 with a human outside the class (hypotheses with full support, so that the mixture is defined)", ok_r7b)
check("Caveat on A2 / E2 with a fixed human outside the class: sum_t E[sum_calls KL(P||M^(t))] <= "
      "L ln(1/w(nu)) + sum_t E[sum_calls KL(P||nu)] along the mixtures' runs, for every nu",
      ok_or, f"largest ratio {worst_or:.3f}")


# ---------------------------------------------------------------------------------------------------
# D3. Theorem R4 and Theorem I1: one posterior draw per run, class of functions, exact.
# ---------------------------------------------------------------------------------------------------
def function_instance(nx, ny, L, nz, nh, total_weight=1.0):
    table, d0 = random_scaffold(nx, ny, L, nz, 0.2, allow_empty=False)
    funcs = set()
    while len(funcs) < nh:
        funcs.add(tuple(rng.randrange(ny) for _ in range(nx)))
    funcs = list(funcs)
    w = [rng.random() + 0.05 for _ in range(nh)]
    tw = sum(w)
    return table, d0, funcs, [total_weight * v / tw for v in w]


def run_of_function(table, z, g, L):
    hist, calls = (), []
    while len(hist) < L:
        x = table.get((z, hist))
        if x is None:
            break
        calls.append((x, g[x]))
        hist = hist + (g[x],)
    return tuple(calls)


def analyse_draw_per_run(inst, L, n):
    table, d0, funcs, w = inst
    nh = len(funcs)
    f = funcs[0]
    runs = [[run_of_function(table, z, g, L) for z in range(len(d0))] for g in funcs]
    dist = [sum(pz for z, pz in enumerate(d0) if runs[g][z] != runs[0][z]) for g in range(nh)]
    full = frozenset(range(nh))

    @lru_cache(maxsize=None)
    def step(S):
        W = sum(w[g] for g in S)
        u = 0.0                 # Pr[the run of the draw is not the human system's run]
        removed = 0.0           # E[posterior mass refuted by the question of the round]
        trans = {}
        for g in S:
            pg = w[g] / W
            for z, pz in enumerate(d0):
                calls = runs[g][z]
                if calls != runs[0][z]:
                    u += pg * pz
                for J in range(1, L + 1):
                    if J <= len(calls):
                        x = calls[J - 1][0]
                        S2 = frozenset(h for h in S if funcs[h][x] == f[x])
                        removed += pg * pz / L * (1 - sum(w[h] for h in S2) / W)
                    else:
                        S2 = S
                    trans[S2] = trans.get(S2, 0.0) + pg * pz / L
        return u, removed, tuple(trans.items())

    @lru_cache(maxsize=None)
    def V(t, S):
        if t > n:
            return 0.0
        u, _, trans = step(S)
        return u + sum(pr * V(t + 1, S2) for S2, pr in trans)

    @lru_cache(maxsize=None)
    def post_bad(t, S):          # E[posterior weight, after round n, of the members whose runs differ]
        if t > n:
            W = sum(w[g] for g in S)
            return sum(w[g] for g in S if dist[g] > 0) / W
        _, _, trans = step(S)
        return sum(pr * post_bad(t + 1, S2) for S2, pr in trans)

    reach = set()
    stack = [full]
    while stack:
        S = stack.pop()
        if S in reach:
            continue
        reach.add(S)
        for S2, _ in step(S)[2]:
            stack.append(S2)
    key_ok = all(step(S)[1] >= step(S)[0] * (L + 1) / (2 * L * L) - 1e-12 for S in reach)
    return V(1, full), post_bad(1, full), dist, key_ok


ok_r4 = ok_key = ok_i1 = True
worst_r4 = 0.0
worst_i1 = 0.0
cnt_i1 = 0
for trial in range(60):
    L = rng.choice((1, 2, 3, 4))
    n = rng.choice((1, 3, 6, 10))
    inst = function_instance(nx=4, ny=2, L=L, nz=4, nh=rng.choice((2, 4, 6)), total_weight=rng.choice((1.0, 0.7)))
    tot, pb, dist, key_ok = analyse_draw_per_run(inst, L, n)
    Kln2 = math.log(1 / inst[3][0])
    bound = 2 * L * L / (L + 1) * Kln2
    ok_r4 &= tot <= bound + 1e-9
    ok_key &= key_ok
    worst_r4 = max(worst_r4, tot / bound)
    pos = [d for d in dist if d > 0]
    if pos:
        dl = min(pos)                       # the human is dl-separated
        b = (1 / inst[3][0]) * (1 - dl / (2 * L)) ** n
        ok_i1 &= pb <= b + 1e-12
        worst_i1 = max(worst_i1, pb / b)
        cnt_i1 += 1
check("R4 (exact): sum over t <= n of Pr[the run of round t is not the human system's run] <= (2L^2/(L+1)) K ln 2",
      ok_r4, f"60 random classes of functions, L <= 4, n <= 10; largest ratio to the bound {worst_r4:.3f}")
check("R4, the printed idea: in every reachable posterior the question removes expected mass >= u (L+1)/(2L^2)", ok_key)
check("I1 (exact): expected posterior weight of the members whose runs differ <= 2^K (1 - delta/(2L))^n",
      ok_i1, f"{cnt_i1} instances with delta := least positive run distance from the human; largest ratio {worst_i1:.3f}")
ok = True
for _ in range(20000):
    L = rng.randrange(1, 9)
    m = rng.randrange(1, L + 1)
    a = [rng.random() for _ in range(m)]
    sc = rng.random() / sum(a)
    a = [v * sc for v in a]
    u = sum(a)
    lhs = sum(a[j] * (1 - sum(a[:j])) for j in range(m))
    ok &= lhs >= u * (L + 1) / (2 * L) - 1e-12
check("R4, the inequality behind the idea: sum_j a_j (1 - sum_{i<j} a_i) >= u (L+1)/(2L) for a_1..a_m >= 0, "
      "u = sum a_j <= 1, m <= L", ok)

# ---------------------------------------------------------------------------------------------------
# D4. Theorem V1.
# ---------------------------------------------------------------------------------------------------
ok_a = ok_half = True
for _ in range(20000):
    k = rng.randrange(1, 7)
    a = rand_dist(k, sparse=0.3)
    p = rand_dist(k, sparse=0.3)
    dis = 1 - sum(x * y for x, y in zip(a, p))
    t = tv(a, p)
    noise = 1 - sum(y * y for y in p)
    ok_a &= t - 1e-12 <= dis <= t + noise + 1e-12
    ok_half &= dis >= noise / 2 - 1e-12
check("V1(a): TV(a, p) <= 1 - sum_y a(y)p(y) <= TV(a, p) + 1 - sum_y p(y)^2 (20000 random pairs, 1 to 6 answers)", ok_a)
check("V1 'issued with probability at most exp(-m s/2)': 1 - sum a p >= (1 - sum p^2)/2, so (1-rho)^m <= exp(-m s/2)", ok_half)
ok = True
worst = 0.0
for m in (5, 30, 300, 2000):
    for delta in (0.3, 0.05, 0.001):
        c = math.log(1 / delta) / m
        for rho in list(np.linspace(0.0005, 0.6, 60)):
            bad = sum(binom_pmf(m, k, rho) for k in range(0, m + 1)
                      if rho > k / m + math.sqrt(2 * (k / m) * c) + 2 * c)
            worst = max(worst, bad / delta)
            ok &= bad <= delta + 1e-12
check("V1(a): Pr[rho > rho_hat + sqrt(2 rho_hat ln(1/delta)/m) + 2 ln(1/delta)/m] <= delta (exact binomial sums)", ok,
      f"largest probability/delta on the grid: {worst:.3f}")
ok = all((1 - r) ** m < d for m in (1, 10, 300) for d in (0.5, 0.05, 1e-4)
         for r in np.linspace(math.log(1 / d) / m + 1e-9, 1, 50) if r <= 1)
check("V1(a): if rho > ln(1/delta)/m then (1 - rho)^m < delta", ok)
check("V1(b), (c) and Pr6(c): the Hoeffding widths (ranges of length 2): 2 exp(-m t^2/2) = pi delta at "
      "t = sqrt(2(ln(1/pi) + ln(2/delta))/m); exp(-m t^2/2) = pi delta at t = sqrt(2(ln(1/pi) + ln(1/delta))/m)",
      all(abs(2 * math.exp(-m * (2 * (math.log(1 / pi) + math.log(2 / d)) / m) / 2) - pi * d) < 1e-12
          and abs(math.exp(-m * (2 * (math.log(1 / pi) + math.log(1 / d)) / m) / 2) - pi * d) < 1e-12
          for m in (10, 1000) for pi in (1.0, 0.01) for d in (0.1, 0.001)))

# ---------------------------------------------------------------------------------------------------
# D5. Theorem Pr3 (Chernoff bound in divergence form), exact binomial sums for one test.
# ---------------------------------------------------------------------------------------------------
def kl_coin(p, q):
    out = 0.0
    if p > 0:
        out += p * math.log(p / q) if q > 0 else float("inf")
    if p < 1:
        out += (1 - p) * math.log((1 - p) / (1 - q)) if q < 1 else float("inf")
    return out


ok = True
worst = 0.0
for N in (1, 5, 40, 300):
    for q in (0.001, 0.02, 0.3, 0.5, 0.9):
        for a in (0.01, 0.1, 0.5, 2.0):
            pr = sum(binom_pmf(N, k, q) for k in range(N + 1) if kl_coin(k / N, q) > a)
            worst = max(worst, pr / (2 * math.exp(-N * a)))
            ok &= pr <= 2 * math.exp(-N * a) + 1e-12
check("Pr3: Pr[kl(Q_hat(B) || Q(B)) > a] <= 2 exp(-N a) (exact binomial sums)", ok, f"largest ratio {worst:.3f}")
check("Pr3: Pinsker for coins, kl(p||q) >= 2(p-q)^2, and kl(0||q) = -ln(1-q) >= q",
      all(kl_coin(p, q) >= 2 * (p - q) ** 2 - 1e-12 for p in np.linspace(0, 1, 41) for q in np.linspace(0.01, 0.99, 41))
      and all(-math.log(1 - q) >= q for q in np.linspace(0, 0.999, 100)))

# ---------------------------------------------------------------------------------------------------
# D6. Theorem Pr5: Rule NH as printed, on random and adversarial sequences, and exhaustively on a small game.
# ---------------------------------------------------------------------------------------------------
def Gfun(v, s):
    return (v + 1) ** -0.5 * math.exp(s * s / (2 * (v + 1)))


ok_step = all(0.5 * (Gfun(v + 1, s + 1) + Gfun(v + 1, s - 1)) <= Gfun(v, s) * (1 + 1e-12)
              for v in range(0, 400) for s in range(-v, v + 1))
check("Pr5, the step of the idea: (G_{v+1}(s+1) + G_{v+1}(s-1))/2 <= G_v(s) for 0 <= v < 400, |s| <= v", ok_step)


class NHState:
    """Books of Rule NH as printed in Section 8.4."""

    def __init__(self, tests, pi):
        self.T = tests                      # T[b][x][y] in {0, 1}
        self.pi = pi
        nb = len(tests)
        self.S = [0] * nb
        self.V = [0] * nb
        self.sign = [0] * nb                # 0: no increment yet; +1/-1: one sign so far; 2: both signs
        self.im_in = [0] * nb               # rounds with the imitator's answer in B
        self.im_out = [0] * nb              # rounds with the imitator's answer outside B
        self.h_ever_in = [False] * nb
        self.h_ever_out = [False] * nb

    def slope(self, b):
        V, S = self.V[b], self.S[b]
        c = 0.25 * (Gfun(V + 1, S + 1) - Gfun(V + 1, S - 1))
        if V >= 1 and self.sign[b] in (1, -1):
            c += self.sign[b] * 2.0 ** (V - 2)
        return c

    def potential(self, b):
        V, S = self.V[b], self.S[b]
        second = 0.5 if V == 0 else (2.0 ** (V - 2) if self.sign[b] in (1, -1) else 0.0)
        return 0.5 * Gfun(V, S) + second

    def rule(self):
        nb = len(self.T)
        nx, ny = len(self.T[0]), len(self.T[0][0])
        c = [self.pi[b] * self.slope(b) for b in range(nb)]
        out = []
        for x in range(nx):
            scores = [sum(c[b] for b in range(nb) if self.T[b][x][y]) for y in range(ny)]
            out.append(min(range(ny), key=lambda y: (scores[y], y)))
        return out

    def update(self, x, a, y):
        for b in range(len(self.T)):
            ia, ih = self.T[b][x][a], self.T[b][x][y]
            g = ia - ih
            self.im_in[b] += ia
            self.im_out[b] += 1 - ia
            self.h_ever_in[b] |= bool(ih)
            self.h_ever_out[b] |= not ih
            if g != 0:
                self.S[b] += g
                self.V[b] += 1
                if self.sign[b] == 0:
                    self.sign[b] = g
                elif self.sign[b] in (1, -1) and self.sign[b] != g:
                    self.sign[b] = 2

    def copy(self):
        o = NHState(self.T, self.pi)
        for name in ("S", "V", "sign", "im_in", "im_out", "h_ever_in", "h_ever_out"):
            setattr(o, name, list(getattr(self, name)))
        return o

    def violations(self):
        bad = []
        for b in range(len(self.T)):
            lam = math.log(1 / self.pi[b])
            V, S = self.V[b], self.S[b]
            if S * S > (V + 1) * (2 * lam + 1.39 + math.log(V + 1)) + 1e-9:
                bad.append(("i", b))
            cap = log2(1 / self.pi[b]) + 2 + 1e-9
            if not self.h_ever_in[b] and self.im_in[b] > cap:
                bad.append(("ii-never", b))
            if not self.h_ever_out[b] and self.im_out[b] > cap:
                bad.append(("ii-always", b))
        return bad

    def phi(self):
        return sum(self.pi[b] * self.potential(b) for b in range(len(self.T)))


def random_tests(nb, nx, ny, total=1.0):
    tests = []
    for _ in range(nb):
        dens = rng.choice((0.2, 0.5, 0.8))
        tests.append([[1 if rng.random() < dens else 0 for _ in range(ny)] for _ in range(nx)])
    pi = [rng.random() ** 3 + 1e-4 for _ in range(nb)]
    t = sum(pi)
    return tests, [total * v / t for v in pi]


def play(state, n, adversary):
    worst_gap = 0.0
    viol = []
    phi_prev = state.phi()
    for t in range(n):
        a = state.rule()
        x, y = adversary(state, a, t)
        state.update(x, a[x], y)
        ph = state.phi()
        worst_gap = max(worst_gap, ph - phi_prev)
        phi_prev = ph
        viol += state.violations()
    return worst_gap, viol


def adv_random(state, a, t):
    return rng.randrange(len(a)), rng.randrange(len(state.T[0][0]))


def adv_greedy(state, a, t):
    """Chooses (x, y) so as to make some book as large as possible relative to its bound."""
    best, arg = -1e18, (0, 0)
    for x in range(len(a)):
        for y in range(len(state.T[0][0])):
            sc = 0.0
            for b in range(len(state.T)):
                g = state.T[b][x][a[x]] - state.T[b][x][y]
                lam = math.log(1 / state.pi[b])
                sc = max(sc, abs(state.S[b] + g) / math.sqrt(2 * lam + 2))
            sc += 1e-6 * rng.random()
            if sc > best:
                best, arg = sc, (x, y)
    return arg


def make_adv_never(target):
    def adv(state, a, t):
        """The human never answers in the test `target`; asks where the rule's answer lies in it."""
        nx, ny = len(a), len(state.T[0][0])
        xs = [x for x in range(nx) if any(not state.T[target][x][y] for y in range(ny))]
        hit = [x for x in xs if state.T[target][x][a[x]]]
        x = rng.choice(hit) if hit else rng.choice(xs)
        y = rng.choice([y for y in range(ny) if not state.T[target][x][y]])
        return x, y
    return adv


total_viol = 0
max_gap = 0.0
games = 0
max_never = -1e9
max_i_ratio = 0.0
for seed in range(40):
    nx, ny, nb = rng.choice((2, 4, 6)), rng.choice((2, 3)), rng.choice((1, 3, 12))
    tests, pi = random_tests(nb, nx, ny, total=rng.choice((1.0, 0.5)))
    if nb == 1:
        pi = [1.0]
    for adv in (adv_random, adv_greedy):
        st = NHState(tests, pi)
        gap, viol = play(st, 300, adv)
        games += 1
        total_viol += len(viol)
        max_gap = max(max_gap, gap)
        max_i_ratio = max(max_i_ratio, max(
            st.S[b] ** 2 / ((st.V[b] + 1) * (2 * math.log(1 / pi[b]) + 1.39 + math.log(st.V[b] + 1)))
            for b in range(nb)))
    for target in range(min(nb, 3)):
        if all(any(not tests[target][x][y] for y in range(ny)) for x in range(nx)):
            st = NHState(tests, pi)
            gap, viol = play(st, 300, make_adv_never(target))
            games += 1
            total_viol += len(viol)
            max_gap = max(max_gap, gap)
            max_never = max(max_never, st.im_in[target] - (log2(1 / pi[target]) + 2))
check("Pr5 (i) and (ii): Rule NH as printed, 300 rounds against random, greedy and 'never in B' humans",
      total_viol == 0 and max_gap <= 1e-9,
      f"{games} games; violations of (i) or (ii): {total_viol}; largest increase of sum_B pi(B) u(B) in a round: "
      f"{max_gap:.2e}; largest final S^2/(bound of (i)): {max_i_ratio:.3f}; "
      f"largest (rounds in a never-satisfied test) - (log2(1/pi) + 2): {max_never:.2f}")


def exhaustive(state, depth):
    """All sequences of (x, y) of the given length; returns (violations, largest increase of the potential)."""
    if depth == 0:
        return 0, 0.0
    a = state.rule()
    ph0 = state.phi()
    nv, gap = 0, 0.0
    for x in range(len(a)):
        for y in range(len(state.T[0][0])):
            st = state.copy()
            st.update(x, a[x], y)
            nv += len(st.violations())
            gap = max(gap, st.phi() - ph0)
            v2, g2 = exhaustive(st, depth - 1)
            nv += v2
            gap = max(gap, g2)
    return nv, gap


nv_tot, gap_tot = 0, 0.0
for seed in range(6):
    tests, pi = random_tests(3, 2, 2, total=1.0)
    v, g = exhaustive(NHState(tests, pi), 7)
    nv_tot += v
    gap_tot = max(gap_tot, g)
v, g = exhaustive(NHState([[[0, 1], [0, 1]]], [1.0]), 9)          # the single test 'the answer is 1'
nv_tot += v
gap_tot = max(gap_tot, g)
check("Pr5 exhaustively: every sequence of 7 rounds on 2 questions x 2 answers with 3 tests (6 families), "
      "and of 9 rounds with the single test 'the answer is 1' of weight 1",
      nv_tot == 0 and gap_tot <= 1e-9, f"violations {nv_tot}; largest increase of the potential {gap_tot:.2e}")

st = NHState([[[0, 1]] * 6], [1.0])                                # 8.5: single test, questions 1, 2, 3, ...
wrong, maxbook = 0, 0
for t in range(1, 201):
    a = st.rule()
    x = t % 6
    y = t % 2
    wrong += a[x] != y
    st.update(x, a[x], y)
    maxbook = max(maxbook, abs(st.S[0]))
check("8.5 'With the single test \"the answer is 1\", the human f(x) = x mod 2 ... keeps its book within 1 and is "
      "wrong in every round'", wrong == 200 and maxbook <= 1, f"wrong in {wrong} of 200 rounds, largest |book| {maxbook}")

st = NHState([[[1, 0], [1, 0]]], [0.25])
seq = []
for t in range(12):
    a = st.rule()
    st.update(0, 0, 1)                      # force: imitator's answer in B, human's not (hypothetical increments)
    seq.append(st.potential(0) - 0.5 * Gfun(st.V[0], st.S[0]))
finding("8.4 idea 'the other half doubles at each non-zero increment while all have one sign': with the printed slope "
        "it is 1/2 after the first increment and doubles from the second on (2^(V-2)), which is what gives '+ 2'",
        all(abs(a - b) < 1e-9 for a, b in zip(seq[:4], [0.5, 1.0, 2.0, 4.0])),
        f"second half after V = 1, 2, 3, 4 increments of one sign: {[round(v, 6) for v in seq[:4]]}; "
        "doubling from the first increment would give 1, 2, 4, 8 and the bound log2(1/pi) + 1")

# the lower-bound game of 8.4: 2^r tests of weight 2^-r, the human always answers the opposite of the rule
ok_lb = True
for r in (1, 2, 3, 5, 7):
    tests = []
    for sbits in itertools.product((0, 1), repeat=r):
        tests.append([[1 if y == 1 - sbits[x] else 0 for y in (0, 1)] for x in range(r)])
    st = NHState(tests, [2.0 ** -r] * len(tests))
    human = []
    for x in range(r):
        a = st.rule()
        y = 1 - a[x]
        human.append(y)
        st.update(x, a[x], y)
    b = int("".join(map(str, human)), 2)
    ok_lb &= (not st.h_ever_in[b]) and st.im_in[b] == r and r <= log2(2 ** r) + 2 and not st.violations()
check("8.4 '(ii) is optimal up to the 2': among 2^r tests of weight 2^-r the human who answers the opposite of the rule "
      "never satisfies one test in which the rule (here Rule NH) gives r answers; Pr5(ii) allows r + 2", ok_lb)


def one_rate_game(nb, nx, ny, n):
    tests, pi = random_tests(nb, nx, ny)
    eta = 1 / math.sqrt(n)
    S = [0] * nb
    for t in range(n):
        rule = []
        for x in range(nx):
            sc = [sum(pi[b] * math.sinh(eta * S[b]) for b in range(nb) if tests[b][x][y]) for y in range(ny)]
            rule.append(min(range(ny), key=lambda y: (sc[y], y)))
        x, y = rng.randrange(nx), rng.randrange(ny)
        if t % 3 == 0:                      # every third round the human disagrees with the rule where it can
            y = (rule[x] + 1) % ny
        for b in range(nb):
            S[b] += tests[b][x][rule[x]] - tests[b][x][y]
    return all(abs(S[b]) <= math.log(2 / pi[b]) / eta + n * eta / 2 + 1e-9 for b in range(nb))


check("8.4 'One rate': |S_n(B)| <= ln(2/pi(B))/eta + n eta/2 with eta = 1/sqrt(n) (20 games of 400 rounds)",
      all(one_rate_game(8, 4, 3, 400) for _ in range(20)))

# ---------------------------------------------------------------------------------------------------
# D7. Theorem Ab1(a).
# ---------------------------------------------------------------------------------------------------
ok = ok_never = True
worst = 0.0
for trial in range(400):
    nx, ny = 6, 3
    nh = rng.choice((2, 5, 12))
    hyps = []
    for h in range(nh):
        if h == 0 or rng.random() < 0.7:
            fvals = [rng.randrange(ny) for _ in range(nx)]
            hyps.append([[1.0 if y == fvals[x] else 0.0 for y in range(ny)] for x in range(nx)])
        else:
            hyps.append([rand_dist(ny) for _ in range(nx)])
    w = [rng.random() + 0.01 for _ in range(nh)]
    tw = sum(w) / rng.choice((1.0, 0.5))
    w = [v / tw for v in w]
    f = [max(range(ny), key=lambda y: hyps[0][x][y]) for x in range(nx)]
    K_bits = log2(1 / w[0])
    eta = rng.choice((0.49, 0.3, 0.1, 0.01, w[0] * 0.99))
    post = list(w)
    u = v = 0
    for t in range(40):
        x = rng.randrange(nx)
        tot = sum(post)
        mix = [sum(post[h] * hyps[h][x][y] for h in range(nh)) / tot for y in range(ny)]
        top = max(range(ny), key=lambda y: mix[y])
        if mix[top] >= 1 - eta:
            u += top != f[x]
        else:
            v += 1
        if eta < w[0]:                      # never wrong at any input, asked or not
            for x2 in range(nx):
                m2 = [sum(post[h] * hyps[h][x2][y] for h in range(nh)) / tot for y in range(ny)]
                t2 = max(range(ny), key=lambda y: m2[y])
                ok_never &= not (m2[t2] >= 1 - eta and t2 != f[x2])
        post = [post[h] * hyps[h][x][f[x]] for h in range(nh)]
    lhs = u * log2(1 / eta) + v * log2(1 / (1 - eta))
    ok &= lhs <= K_bits + 1e-9
    worst = max(worst, lhs / K_bits)
check("Ab1(a): u log2(1/eta) + v log2(1/(1-eta)) <= K on random sequences of asked inputs (400 classes)", ok,
      f"largest ratio to K: {worst:.3f}")
check("Ab1(a): 'If eta < w(f) the rule is never wrong, at any input'", ok_never)


# ---------------------------------------------------------------------------------------------------
# D8. Theorem N7(a): the least E[Sil + Abs] with at most Q questions, by dynamic programming.
# ---------------------------------------------------------------------------------------------------
def n7_value(N, Q):
    @lru_cache(maxsize=None)
    def V(x, lo, q):
        # thresholds lo..N-1 equally likely (all answers shown so far were 1); inputs x..N-1 are still to come
        if x > N - 1:
            return 0.0
        size = N - lo
        p1 = (N - x) / size
        rest = V(x + 1, lo, q)
        best = min(1 - p1, p1, 1.0) + rest
        if q > 0:
            best = min(best, p1 * V(x + 1, x, q - 1))
        return best
    out = V(1, 0, Q)
    V.cache_clear()
    return out


sys.setrecursionlimit(10000)
ok_low = ok_sharp = ok_div = True
worst = 1e18
for N in list(range(2, 41)) + [48, 64, 96]:
    for Q in range(0, N):
        if Q + 1 > N / 2:
            break
        val = n7_value(N, Q)
        ok_low &= val * (Q + 1) >= 3 * N / 16 - 1e-9
        ok_sharp &= val >= 0.25 * (N / (Q + 1) - (Q + 1) / N) - 1e-9
        worst = min(worst, val * (Q + 1) / N)
        if N % (Q + 1) == 0:
            ok_div &= val * (Q + 1) < N / 2
check("N7(a) by dynamic programming: the least E[Sil + Abs] with at most Q <= N/2 - 1 questions, uniform threshold, "
      "times (Q+1), is at least 3N/16", ok_low and ok_sharp,
      f"N = 2..40, 48, 64, 96; least value of E[Sil+Abs](Q+1)/N: {worst:.4f} (3/16 = 0.1875)")
check("N7(a) 'if Q + 1 divides N, a learner attains less than N/2'", ok_div)
check("N7(a): the optimum for N = 48, Q = 3 is 216/48 (the value quoted in proofs/shift-abstain.md)",
      abs(n7_value(48, 3) * 48 - 216) < 1e-6, f"N E[Sil+Abs] = {n7_value(48, 3) * 48:.4f}")
check("N7(b) against N7(a): with at most N/2 - 1 questions E[Sil+Abs] > 0, so 'never wrong' needs more; "
      "enumeration asks at most 2^K - 1 = N - 1",
      all(n7_value(N, N // 2 - 1) > 0 for N in range(2, 30)) and all(n7_value(N, N - 1) == 0 for N in range(2, 30)))

# ---------------------------------------------------------------------------------------------------
# D9. Theorem H2: the Hoelder step; Theorem Pr2 'what holds' is analytic (see the report).
# ---------------------------------------------------------------------------------------------------
ok = True
for _ in range(20000):
    k = rng.randrange(2, 7)
    p, q = rand_dist(k, 0.2), rand_dist(k, 0.2)
    s = rng.random() * 0.98 + 0.01
    lhs = sum((b ** s) * (a ** (1 - s)) for a, b in zip(p, q) if a > 0 and b > 0)
    bc = sum(math.sqrt(a * b) for a, b in zip(p, q))
    ok &= lhs <= bc ** (2 * min(s, 1 - s)) + 1e-12
check("H2: sum q^s p^(1-s) <= (sum sqrt(pq))^(2 min(s, 1-s)) for 0 < s < 1 (20000 random pairs)", ok)

# ---------------------------------------------------------------------------------------------------
# D10. Theorem Pr4: the estimate as printed, by simulation.
# ---------------------------------------------------------------------------------------------------
def pr4_trial_setup(m, k, in_class, total_weight):
    dists = [np.array(rand_dist(k)) for _ in range(m)]
    w = np.array([rng.random() + 0.05 for _ in range(m)])
    w = total_weight * w / w.sum()
    if in_class:
        Q = dists[0].copy()
    else:
        Q = 0.8 * dists[0] + 0.2 * np.array(rand_dist(k))
    return dists, w, Q


def pr4_failure_rate(dists, w, Q, N, delta, trials):
    m = len(dists)
    Kb = np.log2(1 / w)
    r = np.sqrt((Kb * LN2 + math.log(2 / delta)) / (2 * N))
    A = [[(dists[i] > dists[j]) for j in range(m)] for i in range(m)]
    QA = np.array([[dists[i][A[i][j]].sum() for j in range(m)] for i in range(m)])
    tvs = np.array([0.5 * np.abs(d - Q).sum() for d in dists])
    target = float((3 * tvs + 2 * r).min())
    fails = 0
    samples = nprng.multinomial(N, Q, size=trials) / N
    for emp in samples:
        best, arg = 1e18, 0
        for i in range(m):
            sup = 0.0
            for j in range(m):
                if j != i:
                    sup = max(sup, QA[i][j] - emp[A[i][j]].sum() - r[j])
            sc = r[i] + sup
            if sc < best - 1e-15:
                best, arg = sc, i
        fails += tvs[arg] > target + 1e-12
    return fails / trials, target


ok = True
rates = []
for trial in range(12):
    dists, w, Q = pr4_trial_setup(m=rng.choice((2, 5, 8)), k=rng.choice((4, 8)), in_class=trial % 2 == 0,
                                  total_weight=rng.choice((1.0, 0.5)))
    N = rng.choice((30, 200, 1000))
    delta = rng.choice((0.2, 0.05))
    rate, target = pr4_failure_rate(dists, w, Q, N, delta, 1500)
    rates.append((rate, delta, round(target, 3)))
    ok &= rate <= delta + 3 * math.sqrt(delta / 1500)
# a stress case for the constant: two hypotheses whose distance is just above 2 r(nu_1)
delta, N = 0.1, 400
w2 = np.array([0.5, 0.5])
r2 = math.sqrt((1 * LN2 + math.log(2 / delta)) / (2 * N))
gap = 2 * r2 * 1.02
d1 = np.array([0.5, 0.5])
d2 = np.array([0.5 + gap, 0.5 - gap])
rate2, target2 = pr4_failure_rate([d1, d2], w2, d1.copy(), N, delta, 40000)
ok &= rate2 <= delta
check("Pr4: Pr[TV(Q_nu_hat, Q) > min_nu (3 TV(Q_nu, Q) + sqrt((2K(nu) ln2 + 2 ln(2/delta))/N))] <= delta (simulation)",
      ok, "failure rate / delta / bound in 12 random cases: "
          + ", ".join(f"{float(a):.3f}/{b}/{c}" for a, b, c in rates)
          + f"; two hypotheses at distance 2.04 r(nu): failure rate {rate2:.4f} with delta = {delta}")

# ---------------------------------------------------------------------------------------------------
# D11. Lemma L4, exactly, on random pairs of answerers (inputs and answer laws depend on the history).
# ---------------------------------------------------------------------------------------------------
def l4_instance(depth, ny, nz, sparse, close):
    d0 = rand_dist(nz)
    leaves = []                             # (qa, qb)
    sigma = 0.0

    def rec(pa, pb, level):
        nonlocal sigma
        if level == depth or (level > 0 and rng.random() < 0.15):
            leaves.append((pa, pb))
            return
        a = rand_dist(ny, sparse)
        if close:
            e = rand_dist(ny, sparse)
            lam = rng.random() * close
            b = [(1 - lam) * x + lam * y for x, y in zip(a, e)]
        else:
            b = rand_dist(ny, sparse)
        h = 1 - sum(math.sqrt(x * y) for x, y in zip(a, b))
        sigma += pa * h
        for y in range(ny):
            if a[y] > 0 or b[y] > 0:
                rec(pa * a[y], pb * b[y], level + 1)

    for z in range(nz):
        rec(d0[z], d0[z], 0)
    return leaves, sigma


ok_a = ok_b = ok_c = ok_c0 = True
max_ratio_h = max_ratio_tv = 0.0
for trial in range(4000):
    leaves, sigma = l4_instance(depth=rng.choice((1, 2, 3, 4)), ny=rng.choice((2, 3)), nz=rng.choice((1, 2)),
                                sparse=rng.choice((0.0, 0.3)), close=rng.choice((0, 0.05, 0.3, 1.0)))
    qa = [l[0] for l in leaves]
    qb = [l[1] for l in leaves]
    H2 = 1 - sum(math.sqrt(x * y) for x, y in zip(qa, qb))
    TVv = 0.5 * sum(abs(x - y) for x, y in zip(qa, qb)) + 0.5 * abs(sum(qa) - sum(qb))
    phi_s = min(1.0, sigma + math.sqrt(sigma * sigma + 2 * sigma))
    ok_a &= H2 <= 4 * sigma + 1e-12
    ok_b &= TVv <= phi_s + 1e-12 and phi_s <= 2 * math.sqrt(sigma) + 1e-12
    if sigma > 1e-12:
        max_ratio_h = max(max_ratio_h, H2 / sigma)
        max_ratio_tv = max(max_ratio_tv, TVv / phi_s)
    for _ in range(5):
        G = [rng.random() < 0.5 for _ in leaves]
        pa = sum(x for x, g in zip(qa, G) if g)
        pb = sum(y for y, g in zip(qb, G) if g)
        ok_c &= pa <= 2 * pb + 4 * sigma + 1e-12
    pa0 = sum(x for x, y in zip(qa, qb) if y == 0)
    ok_c0 &= pa0 <= 2 * sigma + 1e-12
check("L4(a): H^2(Q_A, Q_B) <= 4 sigma with H^2 = 1 - sum sqrt(pq) (4000 random pairs, exact)", ok_a,
      f"largest H^2/sigma found: {max_ratio_h:.3f}")
check("L4(b): TV(Q_A, Q_B) <= min{1, sigma + sqrt(sigma^2 + 2 sigma)} <= 2 sqrt(sigma)", ok_b,
      f"largest TV/bound found: {max_ratio_tv:.3f}")
check("L4(c): Q_A(G) <= 2 Q_B(G) + 4 sigma for random G, and Q_A(G) <= 2 sigma for G = {runs of B-probability 0}",
      ok_c and ok_c0)
best_ratio = 0.0
for a_ in np.logspace(-6, -1, 30):
    for t_ in np.linspace(0.2, 6, 300):
        b_ = min(0.999, a_ * t_ * t_)
        h1 = 1 - math.sqrt(a_ * b_) - math.sqrt((1 - a_) * (1 - b_))
        sig = h1 + a_ * 1.0                  # after the answer 1 the two samplers give different answers for sure
        H2 = 1 - math.sqrt((1 - a_) * (1 - b_))
        best_ratio = max(best_ratio, H2 / sig)
check("L4(a): a two-call pair has H^2/sigma up to (2 + sqrt 2)/2 = 1.707, so the constant cannot be 1 "
      "(the value 2.9639 of the note for many calls was not recomputed)",
      abs(best_ratio - (2 + math.sqrt(2)) / 2) < 2e-3, f"largest ratio on the grid {best_ratio:.4f}")
# a fully explicit many-call pair (the lattice walk of Example 2.8(i) of proofs/hellinger-runs.md; the two
# closed forms below were re-derived by the referee from the gambler's-ruin formulas)
best_walk = 0.0
for beta in (1.01, 1.001, 1.0002):
    for b in np.linspace(3.5, 6.0, 26):
        m = max(1, int(round(math.log(b) / math.log(beta))))
        pi_m = (beta ** 2 - 1) / (beta ** (2 * m + 2) - 1)
        H2 = 1 - (1 - pi_m) / beta
        sig = ((beta - 1) / (beta + 1)) * (1 - (m + 1) * pi_m) + pi_m
        best_walk = max(best_walk, H2 / sig)
check("L4(a): an explicit pair of samplers on a scaffold with many calls has H^2/sigma = 2.0997 (lattice walk), "
      "so the constant of (a) is above 2; the value 2.9639 of the note was not recomputed",
      abs(best_walk - 2.0997) < 2e-3, f"largest ratio found {best_walk:.4f}")
# the potential inequality (*) behind L4, as in Lemma 2.10 of proofs/hellinger-runs.md, tested directly
ok = True
for _ in range(20000):
    mm = rng.choice((1.0, 2.0, 1 + rng.random() * 3))
    gam = rng.random() * 3 + 0.1
    lam = rng.random() * 4
    k = rng.randrange(2, 5)
    pr = rand_dist(k)
    rv = [rng.random() * 2 for _ in range(k)]
    sc = math.sqrt(sum(p * x * x for p, x in zip(pr, rv)))
    rv = [x / max(sc, 1.0) for x in rv]                      # E r^2 <= 1
    U = lambda x: gam / 2 * max(mm - x, 0.0) ** 2
    lhs = sum(p * U(lam * x) for p, x in zip(pr, rv))
    ok &= lhs <= U(lam) + gam * mm * mm * (1 - sum(p * x for p, x in zip(pr, rv))) + 1e-12
check("L4, the printed idea ('a quadratic function of the root likelihood ratio rises by at most a constant times "
      "h_j'): E U(Lambda r) <= U(Lambda) + gamma m^2 (1 - E r) for U(x) = (gamma/2)((m - x)_+)^2, E r^2 <= 1", ok)

# ---------------------------------------------------------------------------------------------------
# D12. Proposition S1(b): the inequality behind the factor 2L - 1, on random samplers.
# ---------------------------------------------------------------------------------------------------
ok = True
for trial in range(300):
    L = rng.choice((1, 2, 3))
    nx, ny = 3, 2
    table, d0 = random_scaffold(nx, ny, L, 3, 0.2)
    P = [rand_dist(ny, 0.2) for _ in range(nx)]
    Cu = [rand_dist(ny, 0.2) for _ in range(nx)]
    Ct = [rand_dist(ny, 0.2) for _ in range(nx)]
    gfun = [tv(P[x], Cu[x]) for x in range(nx)]

    def visit_integral(kern, fx):
        return sum(pr * sum(fx[x] for x, _ in calls) for pr, _, calls in runs_of(table, d0, kern, L, ny))

    beta_u = visit_integral(Cu, gfun)
    beta_t = visit_integral(Ct, [tv(P[x], Ct[x]) for x in range(nx)])
    ok &= visit_integral(Ct, gfun) <= L * beta_u + (L - 1) * beta_t + 1e-12
check("S1(b): int TV(P, C_u) dd_{C_t} <= L beta(C_u) + (L-1) beta(C_t) for samplers C_u, C_t (300 random cases); "
      "averaging over u = T and t gives the factor 2L - 1", ok)

# ---------------------------------------------------------------------------------------------------
# D13. Theorem Pr7(b): m answers from a uniform law on s answers against a uniform law on a random half.
# ---------------------------------------------------------------------------------------------------
@lru_cache(maxsize=None)
def stirling2(n, k):
    if n == k:
        return 1
    if k == 0 or k > n:
        return 0
    return k * stirling2(n - 1, k) + stirling2(n - 1, k - 1)


ok = True
worst = Fraction(0)
for s in (2, 4, 8, 20, 50):
    for m in range(1, 9):
        tvx = Fraction(0)
        for d in range(1, min(m, s) + 1):
            nseq = math.comb(s, d) * math.factorial(d) * stirling2(m, d)
            p_unif = Fraction(1, s ** m)
            if d <= s // 2:
                p_half = Fraction(math.comb(s - d, s // 2 - d), math.comb(s, s // 2)) * Fraction(2, s) ** m
            else:
                p_half = Fraction(0)
            tvx += nseq * abs(p_half - p_unif)
        tvx /= 2
        bound = Fraction(m * m, 2 * s)
        ok &= tvx <= bound
        worst = max(worst, tvx / bound)
check("Pr7(b): TV between m answers of the uniform human and of the random-half human (averaged over halves) "
      "<= m^2/(2s) (exact rationals, one input)", ok, f"largest ratio {float(worst):.3f}")
check("Pr7 collision statistic: E[1[y1 = y2] - A(y1) - A(y2) + sum A^2] = sum (P - A)^2",
      all(abs((sum(p * p for p in P) - 2 * sum(p * a for p, a in zip(P, A)) + sum(a * a for a in A))
              - sum((p - a) ** 2 for p, a in zip(P, A))) < 1e-12
          for P, A in ((rand_dist(4), rand_dist(4)) for _ in range(200))))

# ---------------------------------------------------------------------------------------------------
# D14. Proposition R6(a) and (b), exactly, for classes of functions.
# ---------------------------------------------------------------------------------------------------
def analyse_r6(inst, L, n, delta):
    table, d0, funcs, w = inst
    nh = len(funcs)
    f = funcs[0]
    ny = 1 + max(max(g) for g in funcs)
    runs = [[run_of_function(table, z, g, L) for z in range(len(d0))] for g in funcs]
    dist = [sum(pz for z, pz in enumerate(d0) if runs[g][z] != runs[0][z]) for g in range(nh)]
    full = frozenset(range(nh))

    def refute(S, x):
        return frozenset(h for h in S if funcs[h][x] == f[x])

    # (a) the highest-weight consistent hypothesis drives (ties: the first in the list, so f loses ties)
    @lru_cache(maxsize=None)
    def Va(t, S):
        if t > n:
            return 0.0
        g = max(sorted(S, reverse=True), key=lambda h: w[h])
        val = 0.0
        for z, pz in enumerate(d0):
            calls = runs[g][z]
            if calls != runs[0][z]:
                val += pz
            for J in range(1, L + 1):
                S2 = refute(S, calls[J - 1][0]) if J <= len(calls) else S
                val += pz / L * Va(t + 1, S2)
        return val

    # (b) the mixture drives; distribution of the set of consistent hypotheses after n rounds
    @lru_cache(maxsize=None)
    def trans_mix(S):
        W = sum(w[g] for g in S)
        nx = len(f)
        kern = [[sum(w[g] for g in S if funcs[g][x] == y) / W for y in range(ny)] for x in range(nx)]
        out = {}
        for pr, z, calls in runs_of(table, d0, kern, L, ny):
            for J in range(1, L + 1):
                S2 = refute(S, calls[J - 1][0]) if J <= len(calls) else S
                out[S2] = out.get(S2, 0.0) + pr / L
        return tuple(out.items())

    law = {full: 1.0}
    for _ in range(n):
        new = {}
        for S, pS in law.items():
            for S2, pr in trans_mix(S):
                new[S2] = new.get(S2, 0.0) + pS * pr
        law = new
    thr = 2 * L * (math.log(1 / w[0]) + math.log(1 / delta)) / n
    p_bad = sum(pS for S, pS in law.items() if any(w[g] >= w[0] and dist[g] >= thr for g in S))
    e_post = sum(pS * sum(w[g] for g in S if dist[g] >= thr) / sum(w[g] for g in S) for S, pS in law.items())
    heavier = sum(1 for g in range(1, nh) if w[g] >= w[0])
    return Va(1, full), heavier, p_bad, e_post, thr


ok_a = ok_a2 = ok_b = True
worst_a = worst_b = 0.0
informative = 0
for trial in range(60):
    L = rng.choice((1, 2, 3))
    inst = function_instance(nx=4, ny=2, L=L, nz=5, nh=rng.choice((3, 5, 7)), total_weight=1.0)
    n = rng.choice((10, 25, 60))
    delta = rng.choice((0.25, 0.1))
    va, heavier, p_bad, e_post, thr = analyse_r6(inst, L, n, delta)
    Kb = log2(1 / inst[3][0])
    ok_a &= va <= L * (2 ** Kb - 1) + 1e-9
    ok_a2 &= va <= L * heavier + 1e-9
    if heavier:
        worst_a = max(worst_a, va / (L * heavier))
    ok_b &= p_bad <= 2 * delta + 1e-12 and e_post <= 2 * delta + 1e-12
    worst_b = max(worst_b, p_bad / (2 * delta), e_post / (2 * delta))
    informative += thr < 1
check("R6(a) (exact): with the highest-weight consistent hypothesis as driver, the expected number of rehearsal runs "
      "that differ from the human system's is at most L(2^K - 1), indeed at most L times the number of members "
      "at least as heavy as f", ok_a and ok_a2, f"60 random classes; largest ratio to L x (number of heavier members): {worst_a:.3f}")
check("R6(b) (exact): after n rounds of mixture-driven rehearsal, Pr[some consistent g with w(g) >= w(f) has "
      "Pr[its run differs] >= 2L(K ln2 + ln(1/delta))/n] <= 2 delta, and likewise for a draw from the final posterior",
      ok_b, f"60 random classes ({informative} with a threshold below 1); largest probability/(2 delta): {worst_b:.3f}")

# the example behind 'exactly L^2 in a class of L + 1 functions': a wrong answer sends the run off the path
ok = True
for L in (2, 3, 4):
    table = {}

    def build(hist):
        if len(hist) == L:
            return
        on_path = all(y == 0 for y in hist)
        table[(0, hist)] = (len(hist) + 1) if on_path else 0          # input 0 is the off-path input
        for y in (0, 1):
            build(hist + (y,))

    build(())
    funcs = [tuple([0] * (L + 1))] + [tuple(1 if x == i else 0 for x in range(L + 1)) for i in range(1, L + 1)]
    wts = [1.0] + [1.0 + 1e-6 * (L + 1 - i) for i in range(1, L + 1)]
    tw = sum(wts)
    inst = (table, [1.0], funcs, [v / tw for v in wts])
    va, heavier, _, _, _ = analyse_r6(inst, L, 600, 0.5)
    ok &= abs(va - L * L) < 1e-6 and heavier == L
check("R6(a) 'exactly L^2 in a class of L + 1 functions' (path scaffold on which a wrong answer hides the later calls; "
      "sum over 600 rounds)", ok)

# ---------------------------------------------------------------------------------------------------
# D15. Proposition R5(a): the trap class (Definition 4.1 of proofs/one-mind.md), by simulation of the rehearsal.
# ---------------------------------------------------------------------------------------------------
def trap_rehearsal(N, L, n, driver):
    """Class A: g_0 = 0 (weight 1/2) and traps g_1..g_N (weight 1/(2N) each); the human is g_0.
    Returns the number k of traps that survive n rounds."""
    alive = [True] * (N + 1)
    k = N
    for _ in range(n):
        z = [rng.randrange(1, N + 1) for _ in range(L)]
        flag = 0
        inputs = []
        if driver == "draw":
            g = 0 if rng.random() < N / (N + k) else rng.choice([a for a in range(1, N + 1) if alive[a]])
        for j in range(L):
            inputs.append((z[j], flag))
            if driver == "mixture":
                cand = z[j] if flag == 0 else flag
                ans = 1 if (alive[cand] and rng.random() < 1 / (N + k)) else 0
            else:
                ans = 1 if (g != 0 and ((flag == 0 and z[j] == g) or flag == g)) else 0
            if flag == 0 and ans == 1:
                flag = z[j]
        b, sflag = inputs[rng.randrange(L)]
        tested = b if sflag == 0 else sflag       # the human answers 0; this removes the one trap tested
        if alive[tested]:
            alive[tested] = False
            k -= 1
    return k


ok = True
det = []
for (N, L) in ((100, 4), (100, 10), (400, 20)):
    for driver in ("mixture", "draw"):
        c = math.ceil(L / 4)
        vals = []
        for _ in range(300):
            k = trap_rehearsal(N, L, N, driver)
            vals.append((k / (N + k)) * (1 - (1 - 1 / N) ** (L - c + 1)))
        est = sum(vals) / len(vals)
        det.append(f"N=n={N}, L={L}, {driver}: {est * N / L:.3f} L/n")
        ok &= est >= 0.11 * L / N
check("R5(a): after n = N >= 100 rounds a posterior draw's run has at least L/4 unfaithful calls with probability "
      ">= 0.11 L/n (simulation of the rehearsal, exact formula for the run of the draw)", ok, "; ".join(det))

# ---------------------------------------------------------------------------------------------------
# D16. The two-coin lemmas behind N6 (Lemma 6.2 of proofs/lower-bounds.md, Lemma 3.4a of proofs/hellinger-runs.md)
#      and the arithmetic of the two printed versions of N6.
# ---------------------------------------------------------------------------------------------------
def tv_two_coins(N, th):
    """TV(Bern(1/2+th)^N, Bern(1/2-th)^N), through the number of ones."""
    return 0.5 * sum(abs(binom_pmf(N, k, 0.5 + th) - binom_pmf(N, k, 0.5 - th)) for k in range(N + 1))


ok62 = ok34 = True
for N in list(range(1, 40)) + [75, 151, 400]:
    for th in (0.001, 0.01, 0.03, 0.1, 0.2, 0.25, 0.4):
        t = tv_two_coins(N, th)
        ok62 &= t >= th * math.sqrt(N) * (1 - 2 * N * th * th) - 1e-12
        if N % 2 == 1:
            ok62 &= t >= th * math.sqrt(2 * N) * (1 - 2 * N * th * th) - 1e-12
            if N >= 3 and (N - 1) * th * th <= 0.25:
                ok34 &= t >= th * math.sqrt((N - 1) / 2) - 1e-12
check("N6: TV of N tosses of coins of bias 1/2 +- theta is at least theta sqrt(N)(1 - 2 N theta^2) "
      "(Lemma 6.2 of proofs/lower-bounds.md) and, for odd N >= 3 with (N-1) theta^2 <= 1/4, at least "
      "theta sqrt((N-1)/2) (Lemma 3.4a of proofs/hellinger-runs.md)", ok62 and ok34)
ok = True
for e in np.linspace(1e-4, 1 / 64, 40):
    for L in (1, 4, 100):
        th = 16 * e / math.sqrt(L)
        ok &= th <= 0.25 and (th * math.sqrt(L) / 4) * (1 - 2 * L * th * th) >= 2 * e - 1e-15
        ok &= abs(1 / (32 * th * th) - L / (8192 * e * e)) < 1e-6 * L / (8192 * e * e)
for e in np.linspace(1e-4, 1 / 16, 40):
    ok &= abs(1 / (8 * (4 * e) ** 2 * 4) - 1 / (512 * e * e)) < 1e-9 / (e * e)
for e in np.linspace(1e-4, 1 / 65, 40):
    for L in (32, 800):
        dl = 65 * e / math.sqrt(L)
        ok &= L * dl * dl <= 1 + 1e-12 and (1 - 4 * dl * dl) / (16 * dl * dl) >= L / (8e4 * e * e)
ok &= (1 / 7) * 0.5 * math.sqrt(3 / 64) >= 1 / 65
check("N6, arithmetic of both printed versions: theta = 16 eps/sqrt(L) gives 2 eps(1 - theta sqrt(8n/K)) and "
      "n >= L K/(8192 eps^2); theta = 4 eps gives K/(512 eps^2); delta = 65 eps/sqrt(L) gives L K/(8*10^4 eps^2)", ok)

# ---------------------------------------------------------------------------------------------------
# D17. Section 4.3, 'random calls of runs need n >= 0.1 K L/eps - 0.4 for failure eps' (the rare-points class of
#      Proposition 3.7 of proofs/lower-bounds.md: x0 with probability 1 - q, each of d rare points with q/d,
#      q = 4 eps/L; all 2^d functions on the rare points). Exact least n for i.i.d. questions from that law.
# ---------------------------------------------------------------------------------------------------
def rare_points_least_n(d, L, eps, n_max):
    q = 4 * eps / L
    # Pr[no call of the run hits a rare point that was not asked and is guessed wrongly], given a asked points
    surv = []
    for a in range(d + 1):
        m = d - a
        surv.append(sum(binom_pmf(m, wv, 0.5) * (1 - wv * q / d) ** L for wv in range(m + 1)))
    law = [0.0] * (d + 1)
    law[0] = 1.0
    for n in range(0, n_max + 1):
        fail = 1 - sum(law[a] * surv[a] for a in range(d + 1))
        if fail <= eps:
            return n
        new = [0.0] * (d + 1)
        for a in range(d + 1):
            if law[a]:
                pnew = (d - a) * q / d
                new[a] += law[a] * (1 - pnew)
                if a < d:
                    new[a + 1] += law[a] * pnew
        law = new
    return None


ok_in = True
det = []
for (d, L, eps) in ((20, 10, 1 / 8), (20, 10, 0.05), (40, 30, 1 / 8), (10, 5, 0.01)):
    least = rare_points_least_n(d, L, eps, 200000)
    claim = 0.1 * d * L / eps - 0.4
    det.append(f"d={d}, L={L}, eps={eps:.3g}: least n = {least}, claimed bound {claim:.0f}")
    ok_in &= least is not None and least >= claim
check("4.3: for eps <= 1/8 the least number of i.i.d. questions with failure <= eps on the rare-points class is at "
      "least 0.1 K L/eps - 0.4 (exact computation of the optimal deployed system's failure)", ok_in, "; ".join(det))
least_half = rare_points_least_n(40, 40, 0.5, 200000)
finding("4.3 'random calls of runs need n >= 0.1 K L/eps - 0.4 for failure eps' is printed without the range "
        "eps <= 1/8 of the proof file; at eps = 1/2 it fails on that class",
        least_half is not None and least_half < 0.1 * 40 * 40 / 0.5 - 0.4,
        f"d = K = 40, L = 40, eps = 0.5: failure <= eps is reached with {least_half} questions; "
        f"0.1 K L/eps - 0.4 = {0.1 * 40 * 40 / 0.5 - 0.4:.1f}")

# ---------------------------------------------------------------------------------------------------
# D18. Section 3.1, 'The last round cannot replace M^(T) in general: in an example the mixture after all n
#      answers has a summed divergence of at least (L - 1)/8 times L K ln 2/n' (the example of Proposition 6.2
#      of proofs/rehearsal-core.md: three samplers f, h, g on the inputs c, r, b), by exact enumeration.
# ---------------------------------------------------------------------------------------------------
def last_round_instance(L, n):
    pz = L / (3 * n)
    kappa = 8 * L / n
    eta = 2 * math.exp(-8 * L)
    phi = math.exp(-80 * L)
    table = {}

    def build(z, hist):
        if len(hist) == L:
            return
        if z == 0:
            x = 0                                   # c
        elif not hist:
            x = 1                                   # r
        else:
            x = 2 if hist[0] == 1 else 0            # b after the answer 1 at r, else c
        table[(z, hist)] = x
        for y in (0, 1):
            build(z, hist + (y,))

    for z in (0, 1):
        build(z, ())
    f = [[1.0, 0.0], [0.0, 1.0], [1.0, 0.0]]
    h = [[1.0, 0.0], [0.0, 1.0], [0.0, 1.0]]
    g = [[math.exp(-kappa), 1 - math.exp(-kappa)], [1.0, 0.0], [0.0, 1.0]]
    Wp = eta * phi + eta + 1
    w = [eta * phi / Wp, eta / Wp, 1 / Wp]
    return (table, [1 - pz, pz], [f, h, g], w, f)


ok = True
det = []
for (L, n) in ((2, 2), (2, 6), (2, 14), (3, 3), (3, 9), (4, 4), (4, 9)):
    inst = last_round_instance(L, n)
    s_n, _, _ = analyse_rehearsal(inst, L, 2, n, frozenset())
    s_n1, _, _ = analyse_rehearsal(inst, L, 2, n + 1, frozenset())
    last = s_n1 - s_n                               # E[Lambda(M^(n+1))], the mixture after all n answers
    Kln2 = math.log(1 / inst[3][0])
    unit = L * Kln2 / n
    det.append(f"L={L}, n={n}: last round {last / unit:.2f}, random round {s_n / n / unit:.2f} (in units of L K ln2/n; "
               f"claimed >= {(L - 1) / 8:.3f})")
    ok &= last >= (L - 1) / 8 * unit and s_n / n <= unit + 1e-9
check("3.1 'The last round': in the example of Proposition 6.2 the mixture after all n answers has summed divergence "
      ">= ((L-1)/8) L K ln2/n, while that of a uniformly chosen round is <= L K ln2/n (exact enumeration)", ok,
      "; ".join(det))

# ====================================================================================================
section("PART E. Sentences that the section sources had already changed when this report was written "
        "(verified here independently)")
# ====================================================================================================

# E1. Section 3.4, the recoverable form: 'one replaced answer followed by the human raises the expected cost by
# at most mu, and the run of A then costs, in expectation, at most mu beta(A) more than the human system's'.
# One call; the human answers 1 or 0 with probability 1/2; cost 0 after the answer 1 and 1 after the answer 0.
cost_human = 0.5 * 0 + 0.5 * 1
mu_average = max(0 - cost_human, 1 - cost_human)        # a replaced answer against the human's expected cost
mu_every = 1 - 0                                        # a replaced answer against any answer of the human
beta_A = 0.5                                            # A always answers 0: TV(point mass at 0, fair coin)
excess = 1 - cost_human
finding("3.4 recoverable form: with mu measured against the expected cost of the human's own answer the claim "
        "'at most mu beta(A) more' fails for a human who varies; mu has to be measured against every answer "
        "the human might give (Theorem 8.6 of the proof file)",
        excess > mu_average * beta_A and excess <= mu_every * beta_A,
        f"one call, fair coin, A = 0: excess cost {excess}; mu (average reading) x beta = {mu_average * beta_A}; "
        f"mu (every answer) x beta = {mu_every * beta_A}")

# E2. Section 6.2: 'with 2^K equally weighted thresholds not before about 3*2^K/(16j) if j silent mistakes and
# unanswered abstentions are tolerated in expectation'.
Nn, jj = 32, 0.05
least_Q = next(Q for Q in range(0, Nn) if n7_value(Nn, Q) <= jj)
finding("6.2 'not before about 3*2^K/(16j)': for j < 3/16 this exceeds the 2^K - 1 inputs, and the 2^K - 1 "
        "questions after which enumeration has left (N7(b)); N7(a) gives min{2^K/2, 3*2^K/(16j)} - 1",
        3 * Nn / (16 * jj) > Nn - 1 >= least_Q and least_Q >= min(Nn / 2, 3 * Nn / (16 * jj)) - 1,
        f"N = 2^K = 32, j = 0.05: 3N/(16j) = {3 * Nn / (16 * jj):.0f}; the least Q with E[Sil+Abs] <= j is {least_Q}; "
        f"min{{N/2, 3N/(16j)}} - 1 = {min(Nn / 2, 3 * Nn / (16 * jj)) - 1:.0f}")

# E2a. Section 0, item 4, last bullet, and Ab4, row 1: the product bound is printed without 'at most N/2 - 1 questions'.
finding("0 item 4 and 7.4 (Ab4, row 1): 'E[Sil + Abs] x (questions + 1) >= 3*2^K/16' is printed without the range "
        "Q <= 2^(K-1) - 1 of N7(a); with 2^K - 1 questions the left side is 0",
        n7_value(32, 31) * 32 == 0 and n7_value(32, 15) * 16 >= 3 * 32 / 16,
        f"N = 32: Q = 31 gives E[Sil+Abs] = {n7_value(32, 31)}; Q = 15 gives a product of "
        f"{n7_value(32, 15) * 16:.2f} >= 6")

# E3. Section 7.5: 'The counts of Ab1 hold in expectation only if the human has everywhere a preferred answer of
# probability above 1 - eta'. Class {P, g}, weights 1/2: P answers 1 with probability 0.7, g always answers 0.
eta, e0 = 0.4, 0.3
wP, wg = 0.5, 0.5
expected_wrong, reach = 0.0, 1.0
for _ in range(200):
    m0 = (wP * e0 + wg) / (wP + wg)                    # mixture probability of the answer 0
    if m0 >= 1 - eta:
        expected_wrong += reach                        # the rule answers 0, not the preferred answer 1
    else:
        break
    reach *= e0                                        # the human answers 0 and g survives
    wP *= e0
kl_corr = (1 - e0) * math.log((1 - e0) / eta) + e0 * math.log(e0 / (1 - eta))
finding("7.5: under the stated condition (preferred answer of probability 0.7 > 1 - eta = 0.6) the count of Ab1 "
        "for wrong rounds, K/log2(1/eta), does not hold in expectation; the count that holds is "
        "K ln2/kl(1 - eps0 || eta) (Proposition 4.7 of the proof file)",
        expected_wrong > 1 / log2(1 / eta) and expected_wrong <= LN2 / kl_corr,
        f"K = 1, eta = 0.4: expected wrong rounds {expected_wrong:.3f} > K/log2(1/eta) = {1 / log2(1 / eta):.3f}; "
        f"K ln2/kl(0.7 || 0.4) = {LN2 / kl_corr:.2f}")

# E4. Section 7.1: 'So u <= K/log2(1/eta) and v <= K ln 2/eta; examples attain both up to rounding'.
finding("7.1 'examples attain both up to rounding': v <= K/log2(1/(1-eta)) by (a), which is below K ln2/eta by a "
        "factor up to 1.39; only the first is attained",
        math.floor(20 / log2(1 / (1 - 0.49))) + 1 < 20 * LN2 / 0.49,
        f"K = 20, eta = 0.49: K/log2(1/(1-eta)) = {20 / log2(1 / (1 - 0.49)):.1f}; K ln2/eta = {20 * LN2 / 0.49:.1f}")

# ====================================================================================================
section("SUMMARY")
# ====================================================================================================
n_pass = sum(1 for _, ok in RESULTS if ok)
print(f"tests of statements of the note: {n_pass} passed, {len(RESULTS) - n_pass} failed")
for name, ok in RESULTS:
    if not ok:
        print("  FAILED: " + name)
print(f"defects shown numerically: {sum(1 for _, s in FINDINGS if s)} of {len(FINDINGS)} listed")
for name, s in FINDINGS:
    print(("  shown: " if s else "  NOT reproduced: ") + name)
