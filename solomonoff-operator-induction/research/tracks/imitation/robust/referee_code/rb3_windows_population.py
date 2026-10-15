"""rb3 (referee B): population windows in explicit classes, for the parts of notes Section 4 that the prover
checked only in one class or left open.  Seeded: numpy default_rng(303).  All risks exact (finite sums).

Common class (coin-flipping human, feature case, deterministic world y = beta(w)): the human says y ~ Bern(q) for
q in Q64 = {j/64} (6-bit code); the coin has length 2; the human-type programs length 2 + 6 = 8 (a 2-bit tag);
T-memorisers declare a set T of t cells (gamma(t) + ceil(log2 C(N, t)) bits) carrying y = 1 with probability 1, and
a rate q in Q64 elsewhere: length 2 + 6 + gamma(t) + ceil(log2 C(N, t)).  Lengths use exact integer binomials.

(A) Non-uniform cell masses (notes open question 2, Remark 4.11 second bullet).  N = 1024 cells with masses
    proportional to k^-a (Zipf, a in {0, 0.5, 1, 1.5}), S = s0 = 64 random cells, the human's rate calibrated to
    p = mass(S) (rounded to Q64: the best q in Q64).  For a T-memoriser of size t the best T is the t heaviest
    S-cells.  We report the lower end s_+ of the window (largest alien rate) against 2^-m and against the
    largest mass of an S-cell, and the upper end s_-.
(B) Several environments (Remark 4.12).  E environments, each with 2^m = 256 cells (the environment index is part
    of the input, each environment equally likely), s0 = 16 coin-1 cells per environment.  World W_E: independent
    couplings beta_1..beta_E.  World W'': one coupling beta shared by all environments.  Aliens: per-environment
    memorisers (memorise environment e's coupling, any subset of environments, t cells each: we use the full
    per-environment memoriser of j environments, j = 1..E), and the shared memoriser (one set T of t cells applied
    in every environment).  The claim: in W_E the largest alien rate is about 2^-m/E; in W'' the shared memoriser
    has rate about 2^-m; so c in (2^-m/E, 2^-m) keeps the fresh-coin human in W_E and the coupling in W''.
(C) Partially private coins (Remark 4.11): y = beta(w) XOR b', b' ~ Bern(p') private.  Aliens know T inside S and use
    two rates.  Lower end against 2^-m (H(p_h) - H(p'))/H(s).  Different sizes from the prover's r2(C).
"""
from math import comb, log2, floor, ceil
import numpy as np

rng = np.random.default_rng(303)
np.seterr(over="ignore")                      # sums that contain +inf risks
Q64 = np.arange(65) / 64.0


def gam(t):
    return 2 * floor(log2(t + 1)) + 1


def clog(n, k):                     # ceil(log2 C(n, k)) with exact integers
    c = comb(n, k)
    return (c - 1).bit_length() if c > 1 else 0


def CE(p, q):
    """cross-entropy (bits) of Bern(p) labels under prediction Bern(q), vectorised over q."""
    q = np.asarray(q, float)
    with np.errstate(divide="ignore", invalid="ignore"):
        v = -p * np.log2(q) - (1 - p) * np.log2(1 - q)
    v = np.where((p == 0) & (q == 0), 0.0, v)
    v = np.where((p == 1) & (q == 1), 0.0, v)
    return np.nan_to_num(v, nan=np.inf)


def best_q(p):
    v = CE(p, Q64)
    j = int(np.argmin(v))
    return Q64[j], float(v[j])


def H2(p):
    return 0.0 if p <= 0 or p >= 1 else -p * log2(p) - (1 - p) * log2(1 - p)


print("(A) Non-uniform cell masses, N = 1024, s0 = 64, masses ~ k^-a (random S, 5 draws each)")
N, s0 = 1024, 64
lH, lcoin = 8, 2
print(f"{'a':>4} {'draw':>4} {'p=mass(S)':>9} {'s_plus':>10} {'s+*2^m':>7} {'t*':>4} {'max S-mass':>10}"
      f" {'s+/maxmass':>10} {'s_minus':>8} {'window':>7}")
for a in (0.0, 0.5, 1.0, 1.5):
    mass = np.arange(1, N + 1, dtype=float) ** -a
    mass /= mass.sum()
    for draw in range(5):
        S = rng.choice(N, size=s0, replace=False)
        mS = np.sort(mass[S])[::-1]
        p = mS.sum()
        qh, RH = best_q(p)
        best_rate, tstar = 0.0, None
        for t in range(1, s0 + 1):
            mt = mS[:t].sum()
            rest = (p - mt) / (1 - mt)
            _, ce = best_q(rest)
            R = (1 - mt) * ce
            ex = gam(t) + clog(N, t)
            r = (RH - R) / ex
            if r > best_rate:
                best_rate, tstar = r, t
        s_minus = (1 - RH) / (lH - lcoin)
        print(f"{a:4.1f} {draw:4d} {p:9.4f} {best_rate:10.3e} {best_rate * N:7.3f} {tstar:4d} {mS[0]:10.3e}"
              f" {best_rate / mS[0]:10.4f} {s_minus:8.4f} {str(best_rate < s_minus):>7s}")

print("\n(B) Several environments: 2^m = 256 cells per environment, s0 = 16, p = 1/16")
Nc, s0b = 256, 16
p = s0b / Nc
qh, RH = best_q(p)
lHb = 8
for E in (1, 2, 4, 8):
    Lfull = gam(s0b) + clog(Nc, s0b)               # memorise one environment's coupling
    # W_E: memorising j of E independent couplings: extra j*Lfull (+ gamma(j) + ceil log2 C(E, j) to name them)
    rates_WE = []
    for j in range(1, E + 1):
        ex = j * Lfull + gam(j) + clog(E, j)
        R = (1 - j / E) * RH                       # memorised environments have risk 0
        rates_WE.append((RH - R) / ex)
    # W_E: a shared set T (= S_1, the first environment's coin-1 cells) applied in every environment, with two
    # rates q_in, q_out (6 bits each); exact risk from the drawn couplings S_1..S_E
    Ss = [set(rng.choice(Nc, size=s0b, replace=False).tolist()) for _ in range(E)]
    T = Ss[0]
    ks = [len(T & Se) for Se in Ss]
    best = np.inf
    for qi in Q64[1:]:
        for qo in Q64[:-1]:
            r = np.mean([(s0b / Nc) * CE(k / s0b, qi) + (1 - s0b / Nc) * CE((s0b - k) / (Nc - s0b), qo) for k in ks])
            best = min(best, float(r))
    best_shared_WE = (RH - best) / (gam(s0b) + clog(Nc, s0b) + 12)
    # W'': shared beta; the shared memoriser has risk 0 everywhere
    ex_sh = Lfull
    rate_Wpp = RH / ex_sh
    print(f"  E = {E}: W_E: largest per-environment rate = {max(rates_WE):.3e} = {max(rates_WE) * Nc:.3f} * 2^-m"
          f" (2^-m/E = {1 / (Nc * E):.3e}); best shared-set rate in W_E = {best_shared_WE:.2e};"
          f"  W'': shared memoriser rate = {rate_Wpp:.3e} = {rate_Wpp * Nc:.3f} * 2^-m")
print(f"  human's left steepness (vs the coin) = {(1 - RH) / (lHb - 2):.4f}: above both rates, so for every E the"
      " interval between the two rates separates the worlds")

print("\n(C) Partially private coins: y = beta(w) XOR b', rates from Q1024 (10-bit codes), human length 2 + 10")
Q1024 = np.arange(1025) / 1024.0


def best_q1024(p):
    v = CE(p, Q1024)
    j = int(np.argmin(v))
    return float(v[j])


print(f"{'m':>3} {'s0':>4} {'pp':>7} {'p_h':>7} {'s+*2^m':>7} {'t*':>4} {'ideal*2^m':>9} {'s_-':>7}")
for (m, s0c, pp) in ((8, 16, 1 / 32), (8, 32, 1 / 16), (11, 128, 1 / 64), (11, 256, 1 / 8)):
    Nn = 2 ** m
    s = s0c / Nn
    ph = s * (1 - pp) + (1 - s) * pp
    RH = best_q1024(ph)
    best, tstar = 0.0, None
    ce_in = best_q1024(1 - pp)
    for t in range(1, s0c + 1):
        pout = ((s0c - t) * (1 - pp) + (Nn - s0c) * pp) / (Nn - t)
        R = (t / Nn) * ce_in + (1 - t / Nn) * best_q1024(pout)
        ex = 10 + gam(t) + clog(Nn, t)
        r = (RH - R) / ex
        if r > best:
            best, tstar = r, t
    ideal = (H2(ph) - H2(pp)) / H2(s)
    print(f"{m:3d} {s0c:4d} {pp:7.4f} {ph:7.4f} {best * Nn:7.3f} {tstar:4d} {ideal:9.3f} {(1 - RH) / 10:7.4f}")
