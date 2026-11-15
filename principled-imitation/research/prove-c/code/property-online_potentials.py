"""Checks of the one-step inequalities behind the balancing rules (property-online.md, Section 1).

A "balancing potential" is a function u >= 0 of the sequence g_1, ..., g_t of one test's
increments, with a slope c that depends on g_1, ..., g_{t-1} only, such that

    u(g_1..g_t) <= u(g_1..g_{t-1}) + g_t * c(g_1..g_{t-1})        (*)

for every admissible g_t. Each potential below depends on the past only through
S = g_1 + ... + g_{t-1}, the number v of non-zero increments, and (for E1) the time t.
The script evaluates the gap  RHS - LHS  of (*) on grids and reports its minimum, which must be
>= 0 (up to rounding), and for the exact identities its maximum absolute value, which must be 0.

  E1  u = cosh(eta S_t) / cosh(eta)^t                      (the lead's rule; g in [-1, 1])
  E2  u = cosh(eta S_t) exp(-v_t eta^2 / 2)                (g in [-1, 1], v counts g != 0)
  E3  u = cosh(eta S_t) / cosh(eta)^{v_t}                  (g in {-1, 0, 1}; identity)
  E4  u = 2^{v_t - 1} 1[|S_t| = v_t] (1 if v_t = 0)        (g in {-1, 0, 1}; identity)
  E6  u = G_{v_t}(S_t), G_v(s) = (v+1)^{-1/2} exp(s^2 / (2 (v+1)))   (g in [-1, 1])
  E7  u = (prod(1 + eta g_s) + prod(1 - eta g_s)) / 2      (g in [-1, 1]; identity)

It also checks, by numerical integration, the representation
    G_v(s) = int exp(eta s - v eta^2 / 2) N(0, 1)(d eta),
and the elementary inequalities used in the text.

Usage: python3 property-online_potentials.py
"""
import itertools
import math

import numpy as np
from scipy import integrate


def G(v, s):
    return (v + 1.0) ** -0.5 * np.exp(s * s / (2.0 * (v + 1.0)))


def slope_G(v, s):
    """Slope of the normal-mixture potential in a state with sum s and v non-zero increments."""
    return 0.5 * (G(v + 1, s + 1.0) - G(v + 1, s - 1.0))


def check_E1():
    worst = np.inf
    for eta in (0.01, 0.1, 0.5, 1.0, 2.0):
        for S in np.linspace(-30, 30, 241):
            for g in np.linspace(-1, 1, 81):
                lhs = math.cosh(eta * (S + g))
                rhs = math.cosh(eta) * math.cosh(eta * S) + g * math.sinh(eta) * math.sinh(eta * S)
                worst = min(worst, (rhs - lhs) / max(1.0, abs(rhs)))
    return worst


def check_E2():
    worst = np.inf
    for eta in (0.01, 0.1, 0.5, 1.0, 2.0):
        for v in (0, 1, 5, 50):
            for S in np.linspace(-v, v, 4 * v + 1) if v else [0.0]:
                for g in np.linspace(-1, 1, 81):
                    if g == 0:
                        continue
                    lhs = math.cosh(eta * (S + g)) * math.exp(-(v + 1) * eta ** 2 / 2)
                    c = math.exp(-(v + 1) * eta ** 2 / 2) * math.sinh(eta) * math.sinh(eta * S)
                    rhs = math.cosh(eta * S) * math.exp(-v * eta ** 2 / 2) + g * c
                    worst = min(worst, (rhs - lhs) / max(1.0, abs(rhs)))
    return worst


def check_E3():
    worst = 0.0
    for eta in (0.01, 0.1, 0.5, 1.0, 3.0):
        for v in range(0, 30):
            for S in range(-v, v + 1, 2):
                for g in (-1, 1):
                    lhs = math.cosh(eta * (S + g)) / math.cosh(eta) ** (v + 1)
                    c = math.tanh(eta) * math.sinh(eta * S) / math.cosh(eta) ** v
                    rhs = math.cosh(eta * S) / math.cosh(eta) ** v + g * c
                    worst = max(worst, abs(rhs - lhs) / max(1.0, abs(rhs)))
    return worst


def U_inf(S, v):
    if v == 0:
        return 1.0
    return 2.0 ** (v - 1) if abs(S) == v else 0.0


def slope_inf(S, v):
    if v >= 1 and abs(S) == v:
        return math.copysign(1.0, S) * 2.0 ** (v - 1)
    return 0.0


def check_E4():
    """All sequences in {-1, 0, 1}^t for t <= 9: identity u_t = u_{t-1} + g_t c_{t-1}."""
    worst = 0.0
    for t in range(1, 10):
        for seq in itertools.product((-1, 0, 1), repeat=t):
            S = sum(seq[:-1])
            v = sum(1 for g in seq[:-1] if g)
            g = seq[-1]
            lhs = U_inf(S + g, v + (g != 0))
            rhs = U_inf(S, v) + g * slope_inf(S, v)
            worst = max(worst, abs(lhs - rhs))
    return worst


def check_E6():
    worst = np.inf
    for v in list(range(0, 40)) + [100, 1000, 10000]:
        smax = min(v, 60 + 6 * math.sqrt(v + 1))
        for S in np.linspace(-smax, smax, 401):
            for g in np.linspace(-1, 1, 41):
                if g == 0:
                    continue
                lhs = G(v + 1, S + g)
                rhs = G(v, S) + g * slope_G(v, S)
                worst = min(worst, (rhs - lhs) / max(1.0, abs(rhs)))
    return worst


def check_E6_integral():
    worst = 0.0
    for v in (0, 1, 3, 10):
        for s in (-4.0, -1.0, 0.0, 0.5, 2.0, 7.0):
            f = lambda e: math.exp(e * s - (v + 1) * e * e / 2) / math.sqrt(2 * math.pi)
            val, _ = integrate.quad(f, -60, 60, epsabs=0, epsrel=1e-12, limit=400)
            worst = max(worst, abs(val - G(v, s)) / G(v, s))
    return worst


def check_E7():
    rng = np.random.default_rng(0)
    worst = 0.0
    for _ in range(2000):
        eta = rng.uniform(0.01, 0.99)
        t = rng.integers(1, 30)
        g = rng.uniform(-1, 1, size=t)
        up, um = np.prod(1 + eta * g[:-1]), np.prod(1 - eta * g[:-1])
        c = eta * (up - um) / 2
        lhs = (np.prod(1 + eta * g) + np.prod(1 - eta * g)) / 2
        rhs = (up + um) / 2 + g[-1] * c
        worst = max(worst, abs(lhs - rhs) / max(1.0, abs(rhs)))
    return worst


def check_elementary():
    out = {}
    e = np.linspace(-20, 20, 40001)
    out["min of exp(eta^2/2) - cosh(eta)"] = float(np.min(np.exp(e * e / 2) - np.cosh(e)))
    u = np.linspace(-0.5, 5, 55001)
    out["min of ln(1+u) - (u - u^2) on [-1/2, 5]"] = float(np.min(np.log1p(u) - (u - u * u)))
    x = np.linspace(0, 1, 10001)
    out["min of 1 - (1 - 1/e) x - exp(-x) on [0, 1]"] = float(np.min(1 - (1 - math.exp(-1)) * x - np.exp(-x)))
    return out


if __name__ == "__main__":
    print("E1 (cosh, clock t), g in [-1,1]:        min relative gap RHS-LHS =", f"{check_E1():.3e}")
    print("E2 (cosh, clock v, exp(-v eta^2/2)):    min relative gap RHS-LHS =", f"{check_E2():.3e}")
    print("E3 (cosh/cosh(eta)^v), g in {-1,1}:     max |RHS-LHS| (identity) =", f"{check_E3():.3e}")
    print("E4 (halving), all sequences, t <= 9:    max |RHS-LHS| (identity) =", f"{check_E4():.3e}")
    print("E6 (normal mixture G_v), g in [-1,1]:   min relative gap RHS-LHS =", f"{check_E6():.3e}")
    print("E6 integral representation of G_v:      max relative error       =", f"{check_E6_integral():.3e}")
    print("E7 (products), g in [-1,1]:             max |RHS-LHS| (identity) =", f"{check_E7():.3e}")
    for k, val in check_elementary().items():
        print(f"{k}: {val:.3e}")
