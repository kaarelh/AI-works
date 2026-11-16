"""Balancing rules on arbitrary sequences: the bounds of property-online.md, Sections 2 and 3.

Game: in round t the imitator fixes a rule a_t: X -> Y; then a question x_t and the human's
answer y_t arrive. For a test B (a set of pairs), g_t(B) = 1[(x_t, a_t(x_t)) in B] - 1[(x_t, y_t) in B],
S_n(B) = sum of g_t(B), V_n(B) = number of rounds with g_t(B) != 0.

Rules (each answers x with a y that minimises sum_B pi(B) * slope_B * 1[(x, y) in B]; ties go to
the least y):
  lead   slope = sinh(eta S)                                   (Theorem Pr5 of the note)
  vclock slope = cosh(eta)^(-V) sinh(eta S)                    (Remark 2.2(3): the same with the clock V)
  N      slope = (G_{V+1}(S+1) - G_{V+1}(S-1)) / 2,  G_v(s) = (v+1)^(-1/2) exp(s^2 / (2(v+1)))
  NH     slope = half the slope of N plus half the slope of the halving potential
  grid   slope = sum_i rho_i exp(-(V+1) eta_i^2 / 2) sinh(eta_i) sinh(eta_i S),
         eta_i = 2^-i, rho_i = 1 / ((i+1)(i+2)), i = 0..39 (the tail of the series is dropped;
         its total weight is 1/41)

Bounds checked at every round t <= n and for every test B:
  lead   |S| <= ln(2/pi)/eta + t eta/2
  vclock |S| <= (ln(2/pi) + V ln cosh eta)/eta
  N      S^2 <= (V+1) (2 ln(1/pi) + ln(V+1))
  NH     S^2 <= (V+1) (2 ln(2/pi) + ln(V+1)),  and  V <= 2 + log2(1/pi) while the test is pure
  grid   |S| <= min_i [ln(2/(pi rho_i))/eta_i + eta_i V/2]

Sequences: (a) a stateless random human on random questions; (b) the human who always gives an
answer different from the imitator's; (c) a human who avoids a random set of pairs.

Usage: python3 property-online_rules.py
"""
import math

import numpy as np

ETAS = 2.0 ** -np.arange(40)
RHOS = 1.0 / ((np.arange(40) + 1.0) * (np.arange(40) + 2.0))


def G(v, s):
    return (v + 1.0) ** -0.5 * np.exp(s * s / (2.0 * (v + 1.0)))


def slopes(rule, S, V, pure, eta):
    if rule == "lead":
        return np.sinh(eta * S)
    if rule == "vclock":
        return np.exp(-V * math.log(math.cosh(eta))) * np.sinh(eta * S)
    cN = 0.5 * (G(V + 1, S + 1.0) - G(V + 1, S - 1.0))
    if rule == "N":
        return cN
    if rule == "NH":
        cH = np.where((V >= 1) & pure, np.sign(S) * 2.0 ** np.minimum(V - 1, 1000), 0.0)
        return 0.5 * cN + 0.5 * cH
    if rule == "grid":
        e = ETAS[None, :]
        return (RHOS[None, :] * np.exp(-(V[:, None] + 1) * e * e / 2) * np.sinh(e)
                * np.sinh(e * S[:, None])).sum(axis=1)
    raise ValueError(rule)


def bound_ok(rule, S, V, pure, PI, eta, t):
    """Returns the largest value of (left side)/(right side) over the tests; must be <= 1."""
    a = np.abs(S)
    if rule == "lead":
        return np.max(a / (np.log(2 / PI) / eta + t * eta / 2))
    if rule == "vclock":
        return np.max(a / ((np.log(2 / PI) + V * math.log(math.cosh(eta))) / eta))
    if rule == "N":
        return np.max(a * a / ((V + 1) * (2 * np.log(1 / PI) + np.log(V + 1.0)) + 1e-300))
    if rule == "NH":
        r1 = np.max(a * a / ((V + 1) * (2 * np.log(2 / PI) + np.log(V + 1.0))))
        r2 = np.max(np.where(pure, V / (2 + np.log2(1 / PI)), 0.0))
        return max(r1, r2)
    if rule == "grid":
        b = (np.log(2 / (PI[:, None] * RHOS[None, :])) / ETAS[None, :] + ETAS[None, :] * V[:, None] / 2).min(axis=1)
        return np.max(a / b)
    raise ValueError(rule)


def play(rule, tests, PI, n, human, rng, eta=None):
    """tests[k, x, y] in {0, 1}. human(t, x, a) returns the human's answer. Returns the largest
    ratio (left side)/(bound) seen over all rounds and tests, and the final S, V."""
    K, nx, ny = tests.shape
    S = np.zeros(K)
    V = np.zeros(K)
    pure = np.ones(K, dtype=bool)          # all non-zero increments so far have one sign
    worst = 0.0
    for t in range(1, n + 1):
        c = slopes(rule, S, V, pure, eta)
        x = int(rng.integers(nx))
        score = (PI * c) @ tests[:, x, :]                    # one number per answer y
        a = int(np.argmin(score))                            # ties: least y
        y = human(t, x, a)
        g = tests[:, x, a] - tests[:, x, y]
        newS = S + g
        pure &= ~((g != 0) & (np.abs(newS) < V + 1))
        S, V = newS, V + (g != 0)
        worst = max(worst, bound_ok(rule, S, V, pure, PI, eta, t))
    return worst, S, V


def family(rng, K, nx, ny, kind):
    tests = (rng.random((K, nx, ny)) < 0.3).astype(float)
    if kind == "geometric":
        w = 2.0 ** -np.arange(1, K + 1)
    else:
        w = np.ones(K)
    return tests, w / w.sum()


if __name__ == "__main__":
    rng = np.random.default_rng(1)
    n = 4000
    print(f"n = {n} rounds; entries: the largest (left side)/(bound) over all rounds and tests (must be <= 1),")
    print("then max_B |S_n(B)| / sqrt(n)\n")
    header = f"{'family':<36}{'human':<12}" + "".join(f"{r:>16}" for r in ("lead", "vclock", "N", "NH", "grid"))
    print(header)
    for (K, nx, ny, kind) in ((30, 12, 4, "uniform"), (200, 40, 6, "uniform"), (40, 12, 4, "geometric")):
        tests, PI = family(rng, K, nx, ny, kind)
        P = rng.dirichlet(np.ones(ny), size=nx)
        avoid = rng.random((nx, ny)) < 0.4
        avoid[:, 0] = False
        Pav = np.where(avoid, 0.0, P)
        Pav /= Pav.sum(axis=1, keepdims=True)
        humans = {
            "random": lambda t, x, a: int(rng.choice(ny, p=P[x])),
            "opposite": lambda t, x, a: (a + 1 + int(rng.integers(ny - 1))) % ny,
            "avoiding": lambda t, x, a: int(rng.choice(ny, p=Pav[x])),
        }
        for hname, h in humans.items():
            row = f"{f'{K} tests ({kind}), |X|={nx}, |Y|={ny}':<36}{hname:<12}"
            for rule in ("lead", "vclock", "N", "NH", "grid"):
                worst, S, V = play(rule, tests, PI, n, h, rng, eta=1 / math.sqrt(n))
                row += f"{worst:8.3f}{np.max(np.abs(S)) / math.sqrt(n):8.3f}"
            print(row)
