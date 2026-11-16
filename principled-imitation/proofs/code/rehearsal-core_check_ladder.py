#!/usr/bin/env python3
"""Referee's exact check of Proposition 5.5 (a new round at every call) of
research/prove-c/rehearsal-core.md.  No sampling (the prover's script simulates the rehearsal).

The ladder: inputs x_1..x_L, the scaffold asks x_j only if all earlier answers were 0, f = 0,
product prior with Pr[h(x_j) = 0] = p.  State of the posterior = the set A of indices asked.

Facts used for an exact computation (each is checked against a brute-force enumeration for small L, n):
  * with u = L - |A|, one new index is added in a round with probability a(u) = (1 - p^u)/(L (1 - p)),
    and never more than one;  beta(M^(t)) = u(M^(t)) = 1 - p^(u_t);
  * for the averaged kernel Mbar = (1/n) sum_t M^(t):  Mbar(1|x_j) = (1 - p) N_j / n with N_j the number of
    rounds t <= n at whose start j was not yet asked; if j is added in round t then N_j = t, and N_j = n if
    it is never added in rounds 1..n-1 ... (see the code: index added in round t <= n-1 has N_j = t; an index
    added in round n or never has N_j = n);
  * u(Mbar) = beta(Mbar) = 1 - prod_j (1 - (1 - p) N_j / n), a product over indices of a function of the
    round in which the index was added; so E[prod] is computed by a forward recursion over (t, u) in which
    the transition "an index is added in round t" carries the factor 1 - (1 - p) t / n.
"""
import itertools
from math import log


def exact(L, p, n):
    """Returns (E[u(Mbar)], E[beta(M^(T))], E[(1/n) sum_t u(M^(t))])."""
    a = [0.0] + [(1 - p ** u) / (L * (1 - p)) for u in range(1, L + 1)]
    # V[u] = sum over histories with u indices outside A of prob * prod over added indices of their factor
    V = [0.0] * (L + 1)
    Pm = [0.0] * (L + 1)          # plain probabilities of u at the start of round t
    V[L] = 1.0
    Pm[L] = 1.0
    sum_beta = 0.0
    for t in range(1, n + 1):
        sum_beta += sum(Pm[u] * (1 - p ** u) for u in range(L + 1))
        # an index added in round t (asked in round t) is outside A at the start of rounds 1..t: N_j = t
        fac = 1 - (1 - p) * t / n
        newV = [0.0] * (L + 1)
        newP = [0.0] * (L + 1)
        for u in range(L + 1):
            if Pm[u] == 0.0 and V[u] == 0.0:
                continue
            newV[u] += V[u] * (1 - a[u])
            newP[u] += Pm[u] * (1 - a[u])
            if u >= 1:
                newV[u - 1] += V[u] * a[u] * fac
                newP[u - 1] += Pm[u] * a[u]
        V, Pm = newV, newP
    # indices never added in rounds 1..n have N_j = n: factor 1 - (1 - p) = p each
    EProd = sum(V[u] * p ** u for u in range(L + 1))
    return 1 - EProd, sum_beta / n


def brute(L, p, n):
    """Brute force for tiny cases: enumerate J_t and the answers of the rehearsal runs."""
    from functools import lru_cache

    def rec(t, A, hist, pr):
        # hist[j] = number of rounds so far at whose start j was outside A
        if t == n:
            prod = 1.0
            for j in range(L):
                prod *= 1 - (1 - p) * hist[j] / n
            return pr * (1 - prod), pr * 0.0
        tot_u = 0.0
        hist2 = tuple(h + (0 if j in A else 1) for j, h in enumerate(hist))
        # run of M^(t): answers 0 w.p. 1 at asked inputs and w.p. p at the others; stops at the first 1
        # enumerate the stopping point s = number of calls made (1..L)
        outside = [j for j in range(L) if j not in A]
        res = 0.0
        # probability that the run reaches call j (0-based): p^(number of outside indices before j)
        for J in range(L):
            reach = p ** sum(1 for i in outside if i < J)
            # question asked at x_J with probability reach / L
            if J in A:
                r1, _ = rec(t + 1, A, hist2, pr * reach / L)
            else:
                r1, _ = rec(t + 1, A | {J}, hist2, pr * reach / L)
            r0, _ = rec(t + 1, A, hist2, pr * (1 - reach) / L)
            res += r1 + r0
        return res, 0.0

    val, _ = rec(0, frozenset(), tuple([0] * L), 1.0)
    return val


def main():
    ok = True
    print("== brute force against the recursion (tiny cases) ==")
    for L, p, n in ((2, 0.5, 5), (3, 0.3, 4), (3, 0.7, 5), (4, 0.5, 4)):
        b = brute(L, p, n)
        e, _ = exact(L, p, n)
        ok &= abs(b - e) < 1e-12
        print(f"L={L} p={p} n={n}: brute force E u(Mbar) = {b:.10f}; recursion = {e:.10f}; equal: {abs(b - e) < 1e-12}")

    print("== Proposition 5.5(b): E u(Mbar) >= (1-p)^2 (L^3/(2n) - L^6/n^2) for n >= L^2;  E beta(M^(T)) <= min(ln(1/p),1) L^2/n ==")
    for p in (0.5, 0.1, 0.9):
        for L in (2, 3, 5, 10, 20, 40):
            for mult in (1, 4, 20):
                n = max(L * L, mult * L ** 3)
                eu, eb = exact(L, p, n)
                low = (1 - p) ** 2 * (L ** 3 / (2 * n) - L ** 6 / n ** 2)
                up = min(log(1 / p), 1.0) * L ** 2 / n
                bound52 = L * L * log(1 / p) / n                 # L ln(1/w(f))/n with ln(1/w(f)) = L ln(1/p)
                upper_a = L * eb                                 # 5.5(a): E u(Mbar) <= L * E[betabar]
                good = eu >= low - 1e-15 and eb <= up + 1e-15 and eu <= upper_a + 1e-15
                ok &= good
                extra = ""
                if mult >= 4:
                    good2 = eu >= (1 - p) ** 2 * L ** 3 / (4 * n) - 1e-15 and eu >= (1 - p) ** 2 * (L / 4) * eb - 1e-15
                    ok &= good2
                    extra = f"; >= (1-p)^2 L^3/(4n): {eu >= (1 - p) ** 2 * L ** 3 / (4 * n)}; ratio to E beta(M^(T)) = {eu / eb:.2f} >= (1-p)^2 L/4 = {(1 - p) ** 2 * L / 4:.2f}"
                print(f"p={p} L={L} n={n}: E u(Mbar) = {eu:.6g} (proved >= {low:.6g}, <= L E betabar = {upper_a:.6g}); "
                      f"E beta(M^(T)) = {eb:.6g} (proved <= {up:.6g}); ratio Mbar / [L ln(1/w(f))/n] = {eu / bound52:.3f}{extra}  {'OK' if good else 'FAIL'}")
    print()
    print("ALL CHECKS PASSED" if ok else "SOME CHECK FAILED")


if __name__ == "__main__":
    main()
