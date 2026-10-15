"""rB6 (referee B): notes.md Section 5 under i.i.d. inputs on Paper 2's countable X = {0,1}^*.

On a countable X every input law mu is atomic, so the (iid) scheme of notes.md Section 5 ("i.i.d. from a
non-atomic law on X") is empty for Paper 2's X.  The two natural readings with repeats differ:
  frozen  : one label per distinct input (Paper 2's data sets);
  fresh   : a new label at every query (the per-query object of ../iid/notes.md).
This script computes, exactly (binomial sums), a three-program instance with an INFINITE-support mu:
  X indexed by x = 0, 1, 2, ...;  mu(x) = 2^-(x+1);  nu(1|x) = 1/2 for x != x0 = 2, nu(1|x0) = 1/8.
  pi1 = fair coin (length 2); pi* = coin except Bern(1/8) at x0 (length 12; the only program
  mu-a.e. equal to nu); pi2 = coin except label 0 surely at x0 (length 11).  Kraft sum < 1.
and reports P[pi* is a lambda-MAP] and E sqrt(Lambda_n(pi1)) (Lemma 5.1) under both readings.
Deterministic.
"""
import math
import numpy as np
from scipy.stats import binom

X0, MU0 = 2, 2.0 ** -3
P1 = 1 / 8
L_COIN, L_STAR, L_PI2 = 2, 12, 11


def hel(p, q):
    return 1 - math.sqrt(p * q) - math.sqrt((1 - p) * (1 - q))


def frozen(n, lam):
    """P[pi* is a lambda-MAP], frozen labels; also E sqrt(Lambda_n(pi1))."""
    seen = 1 - (1 - MU0) ** n
    # if x0 unseen, pi1 and pi* have the same fit; pi1 is shorter
    # if seen with label y0: fits differ only at x0
    prob = 0.0
    for y0, py in ((1, P1), (0, 1 - P1)):
        L_star = -math.log2(P1 if y0 == 1 else 1 - P1)
        L_coin = 1.0
        L_pi2 = 0.0 if y0 == 0 else math.inf
        J = {"coin": lam * L_COIN + L_coin, "star": lam * L_STAR + L_star, "pi2": lam * L_PI2 + L_pi2}
        if J["star"] <= min(J.values()) + 1e-12:
            prob += py
    prob *= seen
    a0 = 1 - hel(P1, 0.5)
    e_sqrt = (1 - seen) + seen * a0
    return prob, e_sqrt


def fresh(n, lam):
    """P[pi* is a lambda-MAP], fresh labels at every query (exact double binomial sum, vectorised in k;
    terms with binomial pmf below 1e-300 are dropped)."""
    prob = 0.0
    for m in range(0, n + 1):  # queries at x0
        pm = binom.pmf(m, n, MU0)
        if pm < 1e-300:
            continue
        k = np.arange(m + 1)
        pk = binom.pmf(k, m, P1)
        L_star = -(k * math.log2(P1) + (m - k) * math.log2(1 - P1))
        L_coin = float(m)
        L_pi2 = np.where(k == 0, 0.0, np.inf)
        Js = lam * L_STAR + L_star
        best = np.minimum(np.minimum(lam * L_COIN + L_coin, Js), lam * L_PI2 + L_pi2)
        prob += pm * float(pk[Js <= best + 1e-12].sum())
    hel_mu = MU0 * hel(P1, 0.5)
    return prob, (1 - hel_mu) ** n


def main():
    print("rB6: i.i.d. inputs on a countable X (atomic mu), frozen versus fresh labels (referee B)")
    print(f"  mu(x) = 2^-(x+1), x0 = {X0}, mu(x0) = {MU0}; nu(1|x0) = {P1}; Hel_mu(pi1) = {MU0 * hel(P1, 0.5):.5f}")
    print(f"  lengths: coin {L_COIN}, pi* {L_STAR} (unique mu-a.e. equivalent program), pi2 {L_PI2}")
    for lam in (1.0, 1.5, 2.0, 4.0):
        for n in (10, 100, 1000, 5000):
            pf, ef = frozen(n, lam)
            pr, er = fresh(n, lam)
            print(f"  lambda={lam:<4g} n={n:5d}: P[pi* is a lambda-MAP]  frozen {pf:.4f}  fresh {pr:.4f}   |  "
                  f"E sqrt(Lambda_n(coin)): frozen {ef:.4f}, fresh {er:.3e}, Lemma 5.1 bound (1-Hel_mu)^n = {er:.3e}")
    print("  Frozen labels: E sqrt(Lambda_n) tends to 1 - Hel(nu(.|x0), coin) = "
          f"{1 - hel(P1, 0.5):.4f} > 0, so Lemma 5.1's bound (1 - Hel_mu)^n fails for frozen data with repeats,")
    print("  and the lambda-MAP is the coin for every n and every lambda >= 1: Cor 5.7(c) fails in the frozen reading.")
    print("  Fresh labels: the per-query likelihood satisfies Lemma 5.1 with equality and pi* is eventually the MAP.")


if __name__ == "__main__":
    main()
