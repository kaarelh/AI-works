"""ra1: independent checks for referee report A on research/tracks/imitation/robust/notes.md.
Does not import the author's scripts.  Seeded: numpy default_rng(101) in (B), default_rng(102) in (D);
(A), (C) and (E) are deterministic (exact arithmetic or closed forms).

(A) Coin-flipping human, explicit class of r4(B) recomputed from scratch, in POPULATION: the J_c-minimiser over a
    grid of c.  Purpose: Corollary 4.7(a) says Theorem 4.6 (i)-(v) hold for EVERY c > 2^-m; check what is actually
    selected for c > 2^-m, in particular above the human's left steepness s_-.
(B) Model-coupling confounding (referee Proposition R1).  Feature case with W = X = {0,1}^m, a human whose response
    f(w) XOR b depends on the SAME cells that drive its coin; f uniformly random, beta a uniformly random set of
    s0 = p 2^m cells.  Data: y = T(w) := f(w) XOR beta(w).  In an explicit prefix class: (i) the table program D(T)
    is shorter than every human-type program and has risk 0, so the human is never a J_c-minimiser, at any c;
    (ii) the right line of slope 2^-m at the human's point needs an offset ~ H(p) * l_H over the whole class;
    (iii) for every beta' with |beta'| = s0 the human-type program H(T XOR beta', p) has exactly the human's risk
    and length: C(2^m, s0) distinct "humans with fresh coins" explain the data equally well.
(C) Shortest copy versus a padded human program: the statement "pi beats every copy of the human" of Proposition
    4.9(b) fails when a copy shorter than pi_H exists (explicit points).
(D) The in-context learner of r5 is P_H-equivalent on the run: cumulative Hellinger gap and cumulative KL of the
    Bayes mixture U against the hidden-Markov human along single trajectories stay bounded (Theorem 2.2(4) /
    thm:split:private(iv) applies), while a memoryless sampler's gap grows linearly.
(E) Remark 3.4: the exact probability that some exception program e_j is a lambda-MAP per query (inclusion-exclusion
    in exact rational arithmetic) against the record's union bound 10((9/10 + 1/640)^n - (9/10)^n).
"""
from fractions import Fraction
from math import comb, floor, lgamma, log, log2, ceil
import numpy as np

LN2 = log(2.0)


def H2(p):
    return 0.0 if p <= 0 or p >= 1 else -p * log2(p) - (1 - p) * log2(1 - p)


def ce(p, q):
    """cross-entropy (bits) of Bern(p) data under prediction Bern(q); inf if q puts 0 on a positive-mass label."""
    out = 0.0
    if p > 0:
        out += float("inf") if q <= 0 else -p * log2(q)
    if p < 1:
        out += float("inf") if q >= 1 else -(1 - p) * log2(1 - q)
    return out


def elias_gamma(t):
    return 2 * floor(log2(t + 1)) + 1


def lc(n, k):
    return (lgamma(n + 1) - lgamma(k + 1) - lgamma(n - k + 1)) / LN2


# ------------------------------------------------------------------------------------------------ (A)
print("(A) Coin-flipping human, 16 cells, |S| = 2 (p = 1/8), explicit class of r4(B), population minimisers")
NC, SN = 16, 2
p = SN / NC
Q = [j / 8 for j in range(8)]
progs = [("fair coin", 2, 1.0, False)]                     # (name, length, risk, is_copy)
for q in Q:
    progs.append((f"H(q={q:.3f})", 5, ce(p, q), q == p))
for t in range(1, SN + 1):                                 # aliens: t cells of S declared 'always 1'
    pt = (SN - t) / (NC - t)
    best = min((1 - t / NC) * ce(pt, q) for q in Q)
    progs.append((f"alien t={t}", 5 + elias_gamma(t) + ceil(lc(NC, t)), best, False))
lH, RH = 5, H2(p)
s_plus = max((RH - r) / (l - lH) for (_, l, r, _) in progs if l > lH and r < RH)
s_minus = min((r - RH) / (lH - l) for (_, l, r, _) in progs if l < lH)
print(f"  human: l = {lH}, R = H(1/8) = {RH:.4f};  2^-m = {1/NC:.4f};  window (s_plus, s_minus) = ({s_plus:.4f}, {s_minus:.4f})")
for c in (0.03, 0.05, 0.06, 0.0625, 0.07, 0.10, 0.15, 0.16, 0.25, 0.5, 1.0):
    J = [(c * l + r, nm, l, r, cp) for (nm, l, r, cp) in progs]
    Jmin = min(j[0] for j in J)
    mins = [j for j in J if j[0] <= Jmin + 1e-12]
    txt = "; ".join(f"{nm} (l={l}, R={r:.4f}, copy={cp})" for (_, nm, l, r, cp) in mins)
    flag = "c > 2^-m" if c > 1 / NC else "c <= 2^-m"
    print(f"  c = {c:6.4f} [{flag:9s}]: argmin J_c = {txt};  R(argmin) - H(rho) = {mins[0][3] - RH:+.4f}")

# ------------------------------------------------------------------------------------------------ (B)
print("\n(B) Model-coupling confounding: human y = f(w) XOR b, coin b = beta(w); f random, |beta| = s0")
rng = np.random.default_rng(101)
m, s0 = 10, 64
N = 2 ** m
p = s0 / N
f = rng.integers(0, 2, N).astype(np.int8)
beta = np.zeros(N, np.int8)
beta[rng.choice(N, s0, replace=False)] = 1
T = f ^ beta
RH = H2(p)
# explicit prefix class: 2-bit tag + fields.  00 coin; 01 table f' + 6-bit rate q in {j/64}; 10 table T' (deterministic);
# 11 table f' + rate q + Elias-gamma(t) + index of a t-subset of cells declared 'flip with probability 1'.
l_coin, l_H, l_D = 2, 2 + N + 6, 2 + N


def risk_human_type(fp, q):                  # population risk of 'f' XOR Bern(q)' on data y = T(w), w uniform
    dis = float(np.mean(fp != T))
    return ce(dis, q)


R_H = risk_human_type(f, p)
R_D = 0.0
print(f"  m = {m}, s0 = {s0}, p = {p}; H(p) = {RH:.6f}; R(H(f, p)) = {R_H:.6f}; l_H = {l_H}, l_D(T) = {l_D}, R(D(T)) = {R_D}")
print(f"  D(T) is shorter than the human by {l_H - l_D} bits and has risk 0: J_c(D(T)) < J_c(H(f,p)) for every c > 0:")
for c in (1e-6, 2.0 ** -m, 1e-2, 1.0, 100.0):
    print(f"    c = {c:9.3e}: J_c(human) - J_c(D(T)) = {c * (l_H - l_D) + R_H - R_D:.6f}")
# offset of a right line of slope 2^-m at the human's point, over the whole explicit class: max 2^m (R_H - R) - (l - l_H)
off_D = N * (R_H - R_D) - (l_D - l_H)
print(f"  offset needed by a slope-2^-m right line at the human's point (attained by D(T)): {off_D:.2f} bits"
      f" = {off_D / l_H:.4f} * l_H  (H(p) = {RH:.4f});  the record's machine-free offset |B| log2(2^m+1) + 2 log2(m+1)"
      f" = {2 * log2(N + 1) + 2 * log2(m + 1):.2f}")
# twin humans: f' = T XOR beta' for any beta' of type p
print(f"  human-type programs H(T XOR beta', p) with |beta'| = s0: there are C({N},{s0}) = 2^{lc(N, s0):.2f} of them;")
for k in range(5):
    bp = np.zeros(N, np.int8)
    bp[rng.choice(N, s0, replace=False)] = 1
    fp = T ^ bp
    print(f"    beta' #{k}: R(H(T^beta', p)) - H(p) = {risk_human_type(fp, p) - RH:+.2e};  length = {l_H};"
          f"  kernel differs from the true human's at {int(np.sum(fp != f))} of {N} cells")
print(f"  all have the same data law; their kernels are pairwise different, so for every procedure the average over"
      f" these worlds of P[copy the world's human] is <= 2^-{lc(N, s0):.1f}")

# ------------------------------------------------------------------------------------------------ (C)
print("\n(C) Shortest copy pi' versus a padded human program pi_H (points (length, risk)); R_H = 0.5")
RH = 0.5
KEY0 = "pi' (shortest copy)"
pts = {KEY0: (10, RH), "pi_H (padded copy)": (20, RH), "alien pi": (30, RH - 1.0 * 0.5)}
la, ra = pts["alien pi"]
r_vs_H = (RH - ra) / (la - 20)
r_vs_0 = (RH - ra) / (la - 10)
print(f"  rate of the alien relative to pi_H: {r_vs_H:.4f}; relative to pi': {r_vs_0:.4f}")
cp = 0.5 * (r_vs_H + r_vs_0)
J = {k: cp * l + r for k, (l, r) in pts.items()}
print(f"  at c' = {cp:.4f} (< rate vs pi_H): " + ", ".join(f"J({k}) = {v:.4f}" for k, v in J.items()))
print(f"  the alien beats pi_H: {J['alien pi'] < J['pi_H (padded copy)']}; the alien beats the shortest copy:"
      f" {J['alien pi'] < J[KEY0]}")

# ------------------------------------------------------------------------------------------------ (D)
print("\n(D) In-context learner (r5's setting): cumulative Hellinger gap and KL against the hidden-Markov human")
rng = np.random.default_rng(102)
G = np.arange(1, 16) / 16.0
T0, T1, ST = np.meshgrid(G, G, G, indexing="ij")
TH0, TH1, STAY = T0.ravel(), T1.ravel(), ST.ravel()
NF = len(TH0)
true = (3 / 16, 13 / 16, 15 / 16)
i_true = int(np.flatnonzero((TH0 == true[0]) & (TH1 == true[1]) & (STAY == true[2]))[0])
logw = np.full(NF, -12.0)                                    # log2 prior weights 2^-12 (sum 0.824)


def trajectory(n):
    s = int(rng.random() < 0.5)
    y = np.empty(n, np.int8)
    for i in range(n):
        y[i] = rng.random() < (true[1] if s else true[0])
        if rng.random() >= true[2]:
            s = 1 - s
    return y


def hel(a, b):                                               # 1 - sum sqrt, binary laws given by P(1)
    return 1.0 - np.sqrt(a * b) - np.sqrt((1 - a) * (1 - b))


def kl(a, b):
    return a * log2(a / b) + (1 - a) * log2((1 - a) / (1 - b))


checks = (10, 100, 500, 1000, 2000, 4000)
for run in range(3):
    y = trajectory(4000)
    alpha = np.full((NF, 2), 0.5)                            # filter P(s_t | y_<t) per member
    lw = logw.copy()                                          # log2 posterior weights (unnormalised)
    cumH = cumK = cumHm = 0.0
    nh = np.zeros(2)                                          # counts for a memoryless KT sampler (contrast)
    rows = []
    for i in range(len(y)):
        pred = alpha[:, 0] * TH0 + alpha[:, 1] * TH1          # P_theta(y_i = 1 | y_<i)
        wn = np.exp2(lw - lw.max())
        pU = float((wn * pred).sum() / wn.sum())
        pH = float(pred[i_true])
        pM = (nh[1] + 0.5) / (nh.sum() + 1.0)
        cumH += hel(pH, pU)
        cumK += kl(pH, pU)
        cumHm += hel(pH, pM)
        yi = y[i]
        like = np.where(yi == 1, pred, 1 - pred)
        lw += np.log2(like)
        e0 = np.where(yi == 1, TH0, 1 - TH0)
        e1 = np.where(yi == 1, TH1, 1 - TH1)
        a0, a1 = alpha[:, 0] * e0, alpha[:, 1] * e1
        z = a0 + a1
        a0, a1 = a0 / z, a1 / z
        alpha = np.stack([a0 * STAY + a1 * (1 - STAY), a1 * STAY + a0 * (1 - STAY)], axis=1)
        nh[yi] += 1
        if i + 1 in checks:
            rows.append(f"n={i+1}: sumHel(U)={cumH:.3f}, sumKL(U)={cumK:.2f} bits, sumHel(memoryless KT)={cumHm:.1f}")
    print(f"  run {run}: " + "; ".join(rows))
print("  (E sum KL <= log2(1/w) = 12 bits for the mixture; its Hellinger sum is bounded, so U is P_H-equivalent on the run)")

# ------------------------------------------------------------------------------------------------ (E)
print("\n(E) Remark 3.4: exact P_n[some e_j is a 1.2-MAP] per query, against the record's union bound")
a1, a0 = Fraction(1, 640), Fraction(63, 640)                 # per query: 'at j, label 1' and 'at j, label 0'


def p_all(k, n):
    """P[for each of k fixed cells j: at least one query at j, and every query at j labelled 1]."""
    tot = Fraction(0)
    for u in range(k + 1):                                   # u cells with no 'label 1' query (inclusion-exclusion)
        tot += (-1) ** u * comb(k, u) * (1 - k * a0 - u * a1) ** n
    return tot


for n in (10, 50, 100, 200):
    exact = sum((-1) ** (k + 1) * comb(10, k) * p_all(k, n) for k in range(1, 11))
    ub = 10 * ((Fraction(9, 10) + a1) ** n - Fraction(9, 10) ** n)
    print(f"  n={n:4d}: exact = {float(exact):.4e}, union bound = {float(ub):.4e}, ratio = {float(exact / ub):.6f}")
