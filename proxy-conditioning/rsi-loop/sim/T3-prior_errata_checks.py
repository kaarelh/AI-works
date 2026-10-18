"""Errata checks for drafts/T3-prior.md (18 October 2026, after sim/reconciliation.md).

E1. How long a prior of dK bits protects A against a constant-drift rival, by operator:
    tilt / Bayes reading (T3.8a): n* = dK ln2 / D, linear in ln O;
    plain policy gradient on mixture logits (D', sim/README.md section 2):
    n* = F(ln O) / (2 eta Dr), F(L) = e^L - e^-L + 2L, linear in O.
E2. The illustrative drift tolerances of T3.8b, and how they move with Delta_w.
E3. Sensitivity of T3.9 / T3.9' to the failure budget (one off-task generation = failure).
E4. Sensitivity of the self-written-data requirement nu_I/nu_R >= K/delta to the salience code.
E5. T3.5's break-even gap g0 under exponential versus power-law runtime models.
E6. T3.7's compile times: what they depend on.
All numbers are illustrations of structure, not estimates.
"""
import numpy as np
from scipy.optimize import brentq
from scipy.integrate import quad

LN2 = np.log(2.0)


def hdr(s):
    print("\n" + "=" * 72 + "\n" + s + "\n" + "=" * 72)


# ---------------------------------------------------------------- E1
hdr("E1. Protection bought by dK bits of prior: tilt (ln O) versus plain PG on mixture logits (O)")
print("matched rates: eta = 2/beta, so both operators move L at the same speed at L = 0")
print("ratio n*_PG / n*_tilt = F(ln O) / (4 ln O)")
for dK in (5, 10, 20, 40):
    L = dK * LN2
    F = np.exp(L) - np.exp(-L) + 2 * L
    print(f"dK = {dK:3d} bits (ln O = {L:6.2f} nats): ratio = {F / (4 * L):.3g};"
          f"  tilt-equivalent protection = {F / 4:.3g} nats instead of {L:.2f}")
# worked example in sim units: eta = 0.25, Dr from P1 of train_sim
delta = 0.01
u, v = 0.005, 0.0198
Dr = (1 - 2 * delta) * (v - u)
eta = 0.25
for dK in (10, 20):
    L = dK * LN2
    F = np.exp(L) - np.exp(-L) + 2 * L
    print(f"P1 of train_sim, eta = {eta}, Dr = {Dr:.4f}: dK = {dK} bits -> n*_PG = {F / (2 * eta * Dr):.3g},"
          f" n*_tilt(beta = 2/eta) = {(2 / eta) * L / Dr:.3g} episodes")

# ---------------------------------------------------------------- E2
hdr("E2. Drift tolerated by one generation of n = 1e6 episodes, tilt reading: D <= dK ln2 / n")
n = 1e6
for dK in (20, 40, 100, 1000):
    print(f"cap dK = {dK:5d} bits: D <= {dK * LN2 / n:.2e} nats/episode")
print("strict P1 with l(R) = 20..40 bits gives 1.4e-5..2.8e-5; Delta_w(G) = 1000 bits would give 7e-4")

# ---------------------------------------------------------------- E3
hdr("E3. T3.9 failure budget: required bits if an off-task generation is repaired with probability p_rep")
for K, d in ((30, 0.01),):
    for p_rep in (0.0, 0.5, 0.9, 0.99):
        eff = d / (K * (1 - p_rep))   # per-generation tolerated probability of an unrepaired failure
        print(f"K={K}, delta={d}, repair prob p_rep={p_rep:4.2f}: need log2(K(1-p_rep)/delta) = {np.log2(1 / eff):5.2f} bits;"
              f" tolerable off-tolerance conditional mass = {eff / (1 + eff):.2e}"
              f" (acceptable mass >= {100 * (1 - eff / (1 + eff)):.3f}%)")

# ---------------------------------------------------------------- E4
hdr("E4. Self-written data: required nu_I/nu_R if pointer length is e_sal * (-log2 share)")
print("P2 is e_sal = 1 (Shannon code); e_sal is a stand-in for any other monotone salience code")
K, d = 30, 0.01
for e_sal in (0.5, 1.0, 2.0, 4.0):
    print(f"e_sal = {e_sal}: fixed point dK = e_sal log2(nu_I/nu_R); need nu_I/nu_R >= (K/delta)^(1/e_sal)"
          f" = {(K / d) ** (1 / e_sal):,.0f}")

# ---------------------------------------------------------------- E5
hdr("E5. T3.5 break-even gap g0: exponential versus power-law runtime (c_k = 10, o_R = 1%)")
ck, oR = 10.0, 0.01


def Dspd_exp(g, alpha=1.0):
    # E[alpha (d - c_k)^+] over d ~ U[0, c_k + g], minus log2(1 + o_R)
    return alpha * g ** 2 / (2 * (ck + g)) - np.log2(1 + oR)


def Dspd_pow(g, p):
    # t_A = d^p, t_X = c_k^p above c_k: E[p log2(d / c_k); d > c_k] - log2(1 + o_R)
    val, _ = quad(lambda x: p * np.log2(x / ck), ck, ck + g)
    return val / (ck + g) - np.log2(1 + oR)


g0e = brentq(Dspd_exp, 1e-6, 50)
print(f"exponential t = 2^d (alpha = 1): g0 = {g0e:.3f}")
for p in (1, 2, 4):
    g0p = brentq(lambda g: Dspd_pow(g, p), 1e-6, 200)
    print(f"power law t = d^{p}: g0 = {g0p:.3f}")
print("the existence of a break-even is common to these models; its value is not")

# ---------------------------------------------------------------- E6
hdr("E6. T3.7 compile time n = b ln2 / (kappa_t log2(1 + o_C)): depends on kappa_t, o_C, b, not on alpha")
for kt in (0.001, 0.01, 0.1):
    for oC in (0.01, 0.1):
        print(f"kappa_t = {kt:5.3f}, o_C = {oC:4.2f}: b = 10 bits -> n = {10 * LN2 / (kt * np.log2(1 + oC)):,.0f};"
              f" b = 30 bits -> n = {30 * LN2 / (kt * np.log2(1 + oC)):,.0f}")
