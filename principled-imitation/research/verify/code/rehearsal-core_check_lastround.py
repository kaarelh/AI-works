#!/usr/bin/env python3
"""Referee's exact checks of Section 6 (the last round) of research/prove-c/rehearsal-core.md,
written independently of the prover's scripts.  No sampling.

(1) Proposition 6.1(a): a different family from the prover's.  L = 1, the input is uniform on {1..N};
    hypotheses: f = 0 and threshold-like functions g_k (k = 1..N) with g_k(x) = 1[x <= k], weights
    proportional to r^k (so that error rates and weights both vary).  E beta(M^(n+1)) exactly, by the
    law of the smallest input asked ... (see the code), against (ln(W/w(f)) + 1)/n.
(2) Proposition 6.2: the three posterior states (early with t-1 questions at c; r asked; b asked) form a
    Markov chain; E Lambda(M^(n+1)), E beta(M^(n+1)), E u(M^(n+1)) exactly.  Compared with the proved lower
    bound, with the prover's printed values, and with the bound of Proposition 6.4.
(3) Proposition 6.3: forward recursion over (g alive or not, number of questions at traps).  The fraction of
    traps not yet asked is replaced by its conditional expectation (1 - 1/N)^c, which is exact because beta
    and the transition probabilities are affine in it only through ... (the transition probabilities do not
    depend on the set of traps asked, only beta does, and beta is affine in the fraction).
    Compared with (6.1), with the prover's values, and E u(M^(n+1)) with Proposition 6.4.
"""
from math import log, log1p, exp, sqrt, e, ceil
import numpy as np


# ------------------------------------------------------------------ (1)
def check_61a():
    print("== (1) Proposition 6.1(a), L = 1, thresholds: f = 0, g_k = 1[x <= k], x uniform on {1..N} ==")
    ok = True
    for N, r, wf in ((20, 1.0, 1e-3), (50, 0.8, 1e-6), (200, 1.0, 1e-2), (200, 0.97, 1e-9), (30, 1.3, 1e-4)):
        raw = np.array([r ** k for k in range(1, N + 1)])
        wg = (1 - wf) * raw / raw.sum()                  # weights of g_1..g_N, total 1 - wf; W = 1
        C = log(1 / wf)
        worst = 0.0
        for n in (1, 2, 3, 5, 10, 20, 50, 100, 200, 500, 1000, 3000):
            # data = n inputs i.i.d. uniform, all answered 0.  g_k survives iff no asked input <= k,
            # i.e. iff m := min asked input > k.  Posterior given m: weights wf and wg[k] for k < m.
            # Error of the mixture at a fresh x: sum over surviving k >= x of posterior weight.
            # Pr[min > j] = ((N - j)/N)^n.
            tail = np.array([((N - j) / N) ** n for j in range(0, N + 1)])       # Pr[m > j], j = 0..N
            pm = tail[:-1] - tail[1:]                                            # Pr[m = j], j = 1..N
            err = 0.0
            cum = np.concatenate(([0.0], np.cumsum(wg)))                         # cum[j] = sum_{k<=j} wg
            cumk = np.concatenate(([0.0], np.cumsum(wg * np.arange(1, N + 1))))  # sum_{k<=j} k wg[k]
            for m in range(1, N + 1):
                # survivors k = 1..m-1; error = (1/N) sum_x sum_{k>=x, k<m} post_k = (1/N) sum_{k<m} k post_k
                tot = wf + cum[m - 1]
                err += pm[m - 1] * (cumk[m - 1] / tot) / N
            worst = max(worst, n * err)
        good = worst <= C + 1 + 1e-12
        ok &= good
        print(f"N={N} r={r} w(f)={wf:g}: max over n of n * E beta(M^(n+1)) = {worst:.4f} <= ln(W/w(f)) + 1 = {C + 1:.4f}  {'OK' if good else 'FAIL'}")
    return ok


# ------------------------------------------------------------------ (2)
def example_62(L, n):
    p, kappa = L / (3 * n), 8 * L / n
    ln_eta, ln_phi = log(2) - 8 * L, -80.0 * L
    eta, phi = exp(ln_eta), exp(ln_phi)

    def early(k):
        """Functionals of the mixture after k questions at c and none at r or b."""
        # weights g : h : f  =  e^{-kappa k} : eta : eta*phi   (work with logs; phi may underflow to 0)
        lg = -kappa * k
        den = np.logaddexp(lg, ln_eta + log1p(phi))
        G = exp(lg - den)                                   # posterior of g
        ln_psi = ln_eta + log1p(phi) - den                  # ln M(1|r), in logs because psi can be tiny
        psi = exp(ln_psi)
        ln_M0b = ln_eta + ln_phi - den                      # ln M(0|b)
        e_c = G * (1 - exp(-kappa))                         # M(1|c): error at c
        e_r = G                                             # error at r
        e_b = 1 - exp(ln_M0b)                               # error at b
        kl_c, kl_r, kl_b = -log1p(-e_c), -ln_psi, -ln_M0b
        Lam = (1 - p) * L * kl_c + p * (kl_r + psi * (L - 1) * kl_b + (1 - psi) * (L - 1) * kl_c)
        bet = (1 - p) * L * e_c + p * (e_r + psi * (L - 1) * e_b + (1 - psi) * (L - 1) * e_c)
        # probability that the run is unfaithful
        fc = (1 - e_c)
        u = 1 - ((1 - p) * fc ** L + p * psi * (1 - e_b) ** (L - 1))
        return psi, Lam, bet, u

    # the state "r asked, b not asked": g is dead, h : f = 1 : phi
    kl_b_mid = log1p(phi) - ln_phi
    e_b_mid = 1 / (1 + phi)
    Lam_mid = p * (L - 1) * kl_b_mid
    bet_mid = p * (L - 1) * e_b_mid
    u_mid = p * (1 - (1 - e_b_mid) ** (L - 1))
    pe, pmid, pfin = 1.0, 0.0, 0.0
    sumLam = sumBet = 0.0
    for t in range(1, n + 2):
        psi, Lam, bet, u = early(t - 1)
        if t == n + 1:
            ELam = pe * Lam + pmid * Lam_mid
            Ebet = pe * bet + pmid * bet_mid
            Eu = pe * u + pmid * u_mid
            break
        sumLam += pe * Lam + pmid * Lam_mid
        sumBet += pe * bet + pmid * bet_mid
        to_r = p / L
        to_b = p * psi * (L - 1) / L
        mid_to_b = p * (L - 1) / L
        pfin += pe * to_b + pmid * mid_to_b
        pmid = pmid * (1 - mid_to_b) + pe * to_r
        pe = pe * (1 - to_r - to_b)
    Wp = 1 + eta + eta * phi
    Kln2 = 88 * L - log(2) + log(Wp)
    return dict(ELam=ELam, Ebet=Ebet, Eu=Eu, avgLam=sumLam / n, avgBet=sumBet / n, Kln2=Kln2, p_early=pe)


def bound_64(L, n, lnWw):
    B0 = L * lnWw / n
    if 2 * B0 >= 1:
        return None
    return 2 * L * B0 * (1 + log(1 / (2 * B0))) + 2 * B0 + 2 * L / n


def check_62():
    print("== (2) Proposition 6.2 (the hedging hypothesis), exact ==")
    ok = True
    prover = {5: 0.41942, 10: 3.2974, 20: 25.379, 40: 198.8}
    for L, n in ((5, 4000), (10, 4000), (20, 4000), (40, 4000), (2, 2), (2, 50), (7, 7), (30, 30000), (3, 20000), (5, 100000)):
        r = example_62(L, n)
        bound = L * r['Kln2'] / n
        low = (L - 1) / 8 * bound
        good = r['ELam'] >= low and r['avgLam'] <= bound + 1e-12 and r['p_early'] >= 0.6208
        b64 = bound_64(L, n, r['Kln2'])
        s64 = f"; 6.4 bound on E u = {b64:.4g}" if b64 is not None else "; 6.4 not applicable (2 B0 >= 1)"
        if b64 is not None:
            good &= r['Eu'] <= b64
        good &= r['Ebet'] <= 8.4 * L * L / n + 1e-12 and r['Eu'] <= 8.4 * L * L / n + 1e-12
        ok &= good
        pv = f" [prover: {prover[L]}]" if (n == 4000 and L in prover) else ""
        print(f"L={L} n={n}: E Lambda(M^(n+1)) = {r['ELam']:.5g}{pv} >= ((L-1)/8) L K ln2/n = {low:.5g}; ratio to L K ln2/n = {r['ELam'] / bound:.3f}; "
              f"avg_t E Lambda = {r['avgLam']:.5g} <= {bound:.5g}; Pr[round n+1 early] = {r['p_early']:.4f} >= 0.6208; "
              f"E beta(M^(n+1)) = {r['Ebet']:.4g}, E u(M^(n+1)) = {r['Eu']:.4g} (both <= 8.4 L^2/n = {8.4 * L * L / n:.4g}){s64}  {'OK' if good else 'FAIL'}")
    return ok


# ------------------------------------------------------------------ (3)
def example_63(L, n, N, lam, cmax=None):
    p, kappa = L / (3 * n), (lam + 1) / n
    if cmax is None:
        cmax = min(n, L + 400)
    # state before round t: alive[c] = Pr[r not asked so far, c questions at traps]; dead[c] likewise with r asked
    alive = np.zeros(cmax + 1); alive[0] = 1.0
    dead = np.zeros(cmax + 1)
    cs = np.arange(cmax + 1)
    frac = (1 - 1 / N) ** cs                      # E[fraction of traps not asked | c questions at traps]
    dropped = 0.0
    sumBet = 0.0

    def functionals(t):
        # alive, c questions at traps, k = t - 1 - c questions at c
        k = (t - 1) - cs
        k = np.maximum(k, 0)
        # G = e^{-kappa k}/(e^{-kappa k} + e^{-lam});  1 - G = 1/(1 + e^{lam - kappa k})
        oneG = 1 / (1 + np.exp(lam - kappa * k))
        G = 1 - oneG
        e_c = G * (1 - exp(-kappa))
        beta_alive = (1 - p) * L * e_c + p * (G + oneG * (L - 1) * 0.5 * frac + G * (L - 1) * e_c)
        beta_dead = p * (L - 1) * 0.5 * frac      # g dead: no error at c or r; traps not asked are answered 1 w.p. 1/2
        # unfaithful-run probability: the run is faithful iff every answer equals f's
        u_alive = 1 - ((1 - p) * (1 - e_c) ** L + p * oneG * ((1 - frac) + frac * 0.5 ** (L - 1)))
        u_dead = p * frac * (1 - 0.5 ** (L - 1))
        return oneG, beta_alive, beta_dead, u_alive, u_dead

    for t in range(1, n + 2):
        oneG, b_a, b_d, u_a, u_d = functionals(t)
        if t == n + 1:
            Ebet = float(alive @ b_a + dead @ b_d)
            Eu = float(alive @ u_a + dead @ u_d)
            break
        sumBet += float(alive @ b_a + dead @ b_d)
        to_r = p / L
        to_trap_a = p * oneG * (L - 1) / L
        to_trap_d = p * (L - 1) / L
        na = alive * (1 - to_r - to_trap_a)
        mv = alive * to_trap_a
        na[1:] += mv[:-1]; dropped += mv[-1]
        nd = dead * (1 - to_trap_d) + alive * to_r
        mv = dead * to_trap_d
        nd[1:] += mv[:-1]; dropped += mv[-1]
        alive, dead = na, nd
    Kln2 = N * log(2) + lam + log1p(exp(-lam))
    s1 = 1 / (1 + exp(-1))
    abar = L * log(1 + e) / (3 * (lam + 1))
    rhs61 = (L * (L - 1) / (6 * n)) * (s1 * (exp(-1 / 3) * (1 - 1 / (9 * n)) - abar / N) - (lam + 1) * abar / (4 * n))
    return dict(Ebet=Ebet, Eu=Eu, avgBet=sumBet / n, Kln2=Kln2, rhs61=rhs61, dropped=dropped)


def check_63():
    print("== (3) Proposition 6.3 (traps behind a clock), exact up to the truncation of the number of trap questions ==")
    ok = True
    prover = {100: 0.11, 400: 0.3594, 1600: 1.269}
    cases = [(100, 10000, None), (400, 40000, None), (1600, 160000, None), (4, 400, None), (9, 900, None), (16, 320, None), (2, 2, (1, 1.0)), (6, 60, (3, 2.0)), (8, 80, (4, 3.0))]
    for L, n, par in cases:
        if par is None:
            lam = 1.1272 * sqrt(L) - 1
            N = ceil(1.6262 * sqrt(L))
        else:
            N, lam = par
        r = example_63(L, n, N, lam)
        bound = L * r['Kln2'] / n
        good = r['Ebet'] >= r['rhs61'] - 1e-12 and r['avgBet'] <= bound + 1e-12 and r['dropped'] < 1e-12
        note = ""
        if par is None and L >= 4 and n >= 100 * L:
            g2 = r['Ebet'] >= (L - 1) / (40 * sqrt(L)) * bound
            good &= g2
            note = f"; ratio last/bound = {r['Ebet'] / bound:.3f} >= (L-1)/(40 sqrt L) = {(L - 1) / (40 * sqrt(L)):.3f}"
        b64 = bound_64(L, n, r['Kln2'])
        if b64 is not None:
            good &= r['Eu'] <= b64
            note += f"; E u(M^(n+1)) = {r['Eu']:.4g} <= 6.4 bound {b64:.4g}; E u / (L K ln2/n) = {r['Eu'] / bound:.3f}"
        else:
            note += f"; E u(M^(n+1)) = {r['Eu']:.4g}; 6.4 not applicable"
        pv = f" [prover: {prover[L]}]" if (par is None and L in prover and n == 100 * L) else ""
        if par is not None and (L, n) in ((6, 60), (8, 80)):
            pv = " [prover's recursion: 0.11425]" if L == 6 else " [prover's recursion: 0.15572]"
        ok &= good
        print(f"L={L} n={n} N={N} lambda={lam:.3f}: E beta(M^(n+1)) = {r['Ebet']:.5g}{pv} >= (6.1) = {r['rhs61']:.5g}; avg_t E beta = {r['avgBet']:.5g} <= L K ln2/n = {bound:.5g}"
              f"{note}; dropped mass {r['dropped']:.1e}  {'OK' if good else 'FAIL'}")
    return ok


if __name__ == "__main__":
    ok = check_61a()
    ok &= check_62()
    ok &= check_63()
    print()
    print("ALL CHECKS PASSED" if ok else "SOME CHECK FAILED")
