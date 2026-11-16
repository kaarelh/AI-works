"""Referee's check of Lemma 1.4 of research/prove-c/property-online.md (balancing potentials).

Independent of the prover's script: high-precision arithmetic (mpmath, 60 digits), random points
and the edges of the ranges. For each potential (u, c) the one-step condition

    u(gamma g) <= u(gamma) + g c(gamma)                                   (1.1)

is checked in the form  gap := u(gamma) + g c(gamma) - u(gamma g) >= 0  (relative to u(gamma)).
Also checked: inequality (1.3); cosh(eta) <= exp(eta^2/2); the integral representation (1.4);
the bounds C_k on the slopes that the proof of Lemma 1.4 states; that the slope of the normal
mixture has the sign of s; the elementary inequalities used in Propositions 3.8, 6.6 and
Theorem 6.3; the constants quoted in the file.

Usage: python3 property-online_check_potentials.py
"""
import itertools
import math
import random

import mpmath as mp

mp.mp.dps = 60
rnd = random.Random(20261115)


def G(v, s):
    return (v + 1) ** mp.mpf(-0.5) * mp.exp(mp.mpf(s) ** 2 / (2 * (v + 1)))


def cN(s, v):
    return (G(v + 1, s + 1) - G(v + 1, s - 1)) / 2


def rand_history(kmax, grid):
    """A random history with entries in [-1, 1] (grid=False) or {-1, 0, 1} (grid=True)."""
    k = rnd.randint(0, kmax)
    if grid:
        return [rnd.choice([-1, 0, 1]) for _ in range(k)]
    out = []
    for _ in range(k):
        r = rnd.random()
        out.append(0 if r < 0.2 else (rnd.choice([-1, 1]) if r < 0.4 else mp.mpf(rnd.uniform(-1, 1))))
    return out


def stats(gam):
    s = sum(gam, mp.mpf(0))
    v = sum(1 for g in gam if g != 0)
    return s, v, len(gam)


def pure_sign(gam):
    signs = {1 if g > 0 else -1 for g in gam if g != 0}
    if len(signs) == 0:
        return 0, True
    if len(signs) == 1:
        return signs.pop(), True
    return 0, False


# ---- the potentials of Lemma 1.4 -------------------------------------------------------------
def pot_a(eta):
    def u(gam):
        s, v, k = stats(gam)
        return mp.cosh(eta * s) / mp.cosh(eta) ** k

    def c(gam):
        s, v, k = stats(gam)
        return mp.tanh(eta) * mp.sinh(eta * s) / mp.cosh(eta) ** k
    return u, c


def pot_b(eta):
    def u(gam):
        s, v, k = stats(gam)
        return mp.cosh(eta * s) * mp.exp(-v * eta ** 2 / 2)

    def c(gam):
        s, v, k = stats(gam)
        return mp.exp(-(v + 1) * eta ** 2 / 2) * mp.sinh(eta) * mp.sinh(eta * s)
    return u, c


def pot_b2(eta):
    def u(gam):
        s, v, k = stats(gam)
        return mp.cosh(eta * s) / mp.cosh(eta) ** v

    def c(gam):
        s, v, k = stats(gam)
        return mp.tanh(eta) * mp.sinh(eta * s) / mp.cosh(eta) ** v
    return u, c


def pot_c():
    def u(gam):
        s, v, k = stats(gam)
        return G(v, s)

    def c(gam):
        s, v, k = stats(gam)
        return cN(s, v)
    return u, c


def pot_d():
    def u(gam):
        s, v, k = stats(gam)
        sg, pure = pure_sign(gam)
        if v == 0:
            return mp.mpf(1)
        return mp.mpf(2) ** (v - 1) if pure else mp.mpf(0)

    def c(gam):
        s, v, k = stats(gam)
        sg, pure = pure_sign(gam)
        return sg * mp.mpf(2) ** (v - 1) if (v >= 1 and pure) else mp.mpf(0)
    return u, c


def pot_e(eta):
    def prods(gam):
        a = b = mp.mpf(1)
        for g in gam:
            a *= 1 + eta * g
            b *= 1 - eta * g
        return a, b

    def u(gam):
        a, b = prods(gam)
        return (a + b) / 2

    def c(gam):
        a, b = prods(gam)
        return eta * (a - b) / 2
    return u, c


def check(name, pot, grid, trials, kmax=12, identity=False, g_values=None):
    u, c = pot
    worst = mp.inf
    worst_abs = mp.mpf(0)
    for _ in range(trials):
        gam = rand_history(kmax, grid)
        if g_values is not None:
            gs = g_values
        elif grid:
            gs = [-1, 0, 1]
        else:
            gs = [-1, 0, 1, mp.mpf(rnd.uniform(-1, 1)), mp.mpf(10) ** (-rnd.randint(1, 30)),
                  -mp.mpf(10) ** (-rnd.randint(1, 30))]
        for g in gs:
            lhs = u(gam + [g])
            rhs = u(gam) + g * c(gam)
            gap = (rhs - lhs) / max(u(gam), mp.mpf(10) ** -50)
            worst = min(worst, gap)
            worst_abs = max(worst_abs, abs(gap))
            assert u(gam + [g]) >= 0
    if identity:
        print(f"{name:<58} max |relative gap| = {mp.nstr(worst_abs, 3)}   (identity: must be 0)")
        assert worst_abs < mp.mpf(10) ** -45
    else:
        print(f"{name:<58} min relative gap  = {mp.nstr(worst, 3)}   (must be >= 0)")
        assert worst > -mp.mpf(10) ** -45


if __name__ == "__main__":
    print("== (1.1) for the potentials of Lemma 1.4; 60-digit arithmetic ==")
    for eta in [mp.mpf("0.01"), mp.mpf("0.3"), mp.mpf(1), mp.mpf(3), mp.mpf(8)]:
        check(f"(a) cosh, clock k, eta = {mp.nstr(eta, 3)}, G = [-1,1]", pot_a(eta), False, 400)
        check(f"(b) cosh, clock v (exp), eta = {mp.nstr(eta, 3)}, G = [-1,1]", pot_b(eta), False, 400)
        check(f"(b) cosh/cosh(eta)^v, eta = {mp.nstr(eta, 3)}, G = {{-1,0,1}}", pot_b2(eta), True, 400,
              identity=True)
    check("(c) normal mixture, G = [-1,1]", pot_c(), False, 3000, kmax=40)
    check("(c) normal mixture, G = {-1,0,1}", pot_c(), True, 3000, kmax=60)
    check("(d) halving, G = {-1,0,1}", pot_d(), True, 3000, identity=True)
    for eta in [mp.mpf("0.001"), mp.mpf("0.25"), mp.mpf("0.5"), mp.mpf("0.999")]:
        check(f"(e) products, eta = {mp.nstr(eta, 3)}, G = [-1,1]", pot_e(eta), False, 400, identity=True)

    # (b), second form: the file claims it on {-1,0,1} only. It is a balancing potential on [-1,1] as
    # well (divide (1.3) by cosh(eta)^(v+1)); checked here as an inequality.
    for eta in [mp.mpf("0.01"), mp.mpf("0.3"), mp.mpf(1), mp.mpf(3)]:
        check(f"(b) cosh/cosh(eta)^v, eta = {mp.nstr(eta, 3)}, G = [-1,1] (not claimed)", pot_b2(eta), False, 400)

    # halving: exhaustive over all sequences of length <= 10
    u, c = pot_d()
    bad = 0
    for k in range(0, 10):
        for gam in itertools.product([-1, 0, 1], repeat=k):
            gam = list(gam)
            for g in (-1, 0, 1):
                if u(gam + [g]) != u(gam) + g * c(gam):
                    bad += 1
    print(f"(d) halving, all sequences of length <= 9 and all g: violations of the identity = {bad}")
    assert bad == 0

    print("\n== (1.3), cosh <= exp, and the integral representation (1.4) ==")
    worst = mp.inf
    for _ in range(20000):
        eta = mp.mpf(rnd.uniform(-6, 6))
        S = mp.mpf(rnd.uniform(-30, 30))
        g = mp.mpf(rnd.choice([-1, 1, rnd.uniform(-1, 1)]))
        gap = mp.cosh(eta) * mp.cosh(eta * S) + g * mp.sinh(eta) * mp.sinh(eta * S) - mp.cosh(eta * (S + g))
        worst = min(worst, gap / mp.cosh(eta * S))
        assert mp.cosh(eta) <= mp.exp(eta ** 2 / 2)
    print("(1.3): min relative gap =", mp.nstr(worst, 3))
    assert worst > -mp.mpf(10) ** -40
    worst = 0
    for v in [0, 1, 2, 5, 17, 100]:
        for s in [0, 0.5, -1, 3, 7.25, -12]:
            val = mp.quad(lambda e: mp.cosh(e * s) * mp.exp(-v * e * e / 2) * mp.npdf(e), [-mp.inf, 0, mp.inf])
            worst = max(worst, abs(val / G(v, s) - 1))
            # the slope as an integral
            sl = mp.quad(lambda e: mp.exp(-(v + 1) * e * e / 2) * mp.sinh(e) * mp.sinh(e * s) * mp.npdf(e),
                         [-mp.inf, 0, mp.inf])
            worst = max(worst, abs(sl - cN(s, v)) / (abs(cN(s, v)) + 1))
    print("(1.4) and the slope of (c) as an integral: max relative error =", mp.nstr(worst, 3))
    assert worst < mp.mpf(10) ** -15

    print("\n== bounds C_k on the slopes (proof of Lemma 1.4) ==")
    ok = True
    for k in range(0, 9):
        for gam in itertools.product([-1, 0, 1], repeat=k):
            gam = list(gam)
            eta = mp.mpf("0.7")
            ok &= abs(pot_a(eta)[1](gam)) <= mp.sinh(eta * k) + mp.mpf(10) ** -50
            ok &= abs(pot_b(eta)[1](gam)) <= mp.sinh(eta) * mp.sinh(eta * k) + mp.mpf(10) ** -50
            ok &= abs(pot_c()[1](gam)) <= mp.exp(mp.mpf(k + 1) / 2)
            ok &= abs(pot_d()[1](gam)) <= mp.mpf(2) ** (k - 1)
            ok &= abs(pot_e(eta)[1](gam)) <= (1 + eta) ** k
    print("C_k <= sinh(eta k), sinh(eta) sinh(eta k), e^((k+1)/2), 2^(k-1), (1+eta)^k on all histories of length <= 8:", ok)
    assert ok

    print("\n== the slope of the normal mixture has the sign of s, and vanishes at s = 0 ==")
    ok = all((cN(s, v) > 0) == (s > 0) and (cN(-s, v) < 0) == (s > 0) for v in range(0, 50)
             for s in [mp.mpf(j) / 4 for j in range(1, 200)])
    ok &= all(cN(0, v) == 0 for v in range(0, 50))
    print("sign(c^N(s, v)) = sign(s):", ok)
    assert ok

    print("\n== elementary inequalities used elsewhere ==")
    w1 = min(mp.log(1 + u) - (u - u * u) for u in [mp.mpf(j) / 1000 for j in range(-500, 5001)])
    w2 = min(1 - (1 - mp.exp(-1)) * x - mp.exp(-x) for x in [mp.mpf(j) / 1000 for j in range(0, 1001)])
    w3 = min(1 + u + (mp.e / 2) * u * u - mp.exp(u) for u in [mp.mpf(j) / 1000 for j in range(-1000, 1001)])
    w4 = min((mp.e - 2) * u * u - (mp.exp(u) - 1 - u) for u in [mp.mpf(j) / 1000 for j in range(-1000, 1001)])
    print("min of ln(1+u) - (u - u^2) on [-1/2, 5]            :", mp.nstr(w1, 3))
    print("min of 1 - (1-1/e)x - exp(-x) on [0, 1]            :", mp.nstr(w2, 3))
    print("min of 1 + u + (e/2)u^2 - exp(u) on [-1, 1]        :", mp.nstr(w3, 3))
    print("min of (e-2)u^2 - (exp(u) - 1 - u) on [-1, 1]      :", mp.nstr(w4, 3))
    assert min(w1, w2, w3, w4) >= -mp.mpf(10) ** -50

    print("\n== constants quoted in the file ==")
    print("ln 2 + 1/2                         =", mp.nstr(mp.log(2) + mp.mpf(1) / 2, 6), "  (file: 1.19)")
    print("2 ln 2                             =", mp.nstr(2 * mp.log(2), 6), "  (file: 1.39)")
    print("e/(e-1)                            =", mp.nstr(mp.e / (mp.e - 1), 6), "  (file: < 1.582)")
    print("sqrt 2 - 1, 1/(sqrt 3 + 1)         =", mp.nstr(mp.sqrt(2) - 1, 6), mp.nstr(1 / (mp.sqrt(3) + 1), 6),
          "  (file: sqrt 2 - 1 and 0.36)")
    print("sinh(1)^2                          =", mp.nstr(mp.sinh(1) ** 2, 6), "  (file: < 1.39)")
    print("1/ln 2                             =", mp.nstr(1 / mp.log(2), 6), "  (file: 1.44)")
    print("0.9^7                              =", mp.nstr(mp.mpf("0.9") ** 7, 6), "  (file: 0.478)")
    # crossing point of Theorem 2.1 (eta = 1/sqrt n) and (3.2) at n = 10^6
    n = mp.mpf(10) ** 6
    f = lambda lam: (n + 1) * (2 * lam + mp.log(n + 1)) - n * (lam + mp.log(2) + mp.mpf(1) / 2) ** 2
    lam0 = mp.findroot(f, 3)
    print("crossing of (3.2) and Theorem 2.1 at n = 10^6: Lambda =", mp.nstr(lam0, 6), " pi =",
          mp.nstr(mp.exp(-lam0), 4), "  (file: (3.2) is the larger bound only for pi(B) > 0.036)")
    for mu0, label in [(mp.mpf("0.5"), "Example 6.5"), (mp.mpf("0.0821"), "Section 9.9")]:
        C = (2 / mu0) * (1 + mp.e * mp.log(8 * mp.e / mu0 ** 2))
        print(f"C(mu0) for mu0 = {mp.nstr(mu0, 4)} ({label}) = {mp.nstr(C, 6)}")
    # Corollary 3.2(b): the largest integer N with N^2 <= (N+1)(2 Lambda + ln(N+1)), against the stated bound
    worst = mp.inf
    for j in range(0, 4001):
        lam = mp.mpf(j) / 20
        N = 0
        while (N + 1) ** 2 <= (N + 2) * (2 * lam + mp.log(N + 2)):
            N += 1
        bound = 2 * lam + mp.log(2 * lam + 4) + 2
        worst = min(worst, bound - N)
    print("Corollary 3.2(b): min over Lambda in [0, 200] of (stated bound) - (largest N allowed by (3.1)) =",
          mp.nstr(worst, 4), " (must be >= 0)")
    assert worst >= 0
    # Example 2.3: floor(n/2) >= (1/2) sqrt(n) ln n for all n, so the cap floor(n/2) never bites
    ok = all(n // 2 >= 0.5 * math.sqrt(n) * math.log(n) for n in range(1, 200001))
    print("floor(n/2) >= (1/2) sqrt(n) ln(n) for all n = 1..200000:", ok)
    print("all checks passed")
