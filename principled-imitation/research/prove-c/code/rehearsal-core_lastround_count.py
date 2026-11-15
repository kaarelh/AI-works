#!/usr/bin/env python3
"""Proposition 6.3 of rehearsal-core.md: for a deterministic human the last round of
Protocol R can have more unfaithful calls, in expectation, than L K ln2 / n by a factor
of order sqrt(L).  Exact forward recursion over the posterior states; no sampling.

Inputs: c (clock), r (routing), b_1..b_N (traps).  Answers are bits.  L calls, no STOP.
z = 0 (prob 1-p): all calls at c.   z = i in 1..N (prob p/N each): call 1 at r;
calls 2..L at b_i if the answer at r was 1, at c otherwise.
Human f: f(c) = 0, f(r) = 1, f(b_i) = 0.
Class: for S a subset of {1..N}:
  h_S: h_S(c) = 0, h_S(r) = 1, h_S(b_i) = 1[i in S]            weight eta 2^-N /(1+eta)
  g_S: g_S(0|c) = exp(-kappa), g_S(r) = 0, g_S(b_i) = 1[i in S]  weight 2^-N /(1+eta)
f = h_emptyset.  K ln 2 = N ln 2 + ln(1 + 1/eta).

Posterior state at the start of a round: (the g-family is alive or dead, c = number of
trap questions so far, with multiplicity).  Every round asks exactly one question, so on
an alive path the number of clock questions before round t is k = t - 1 - c.  The set of
asked traps enters beta only through the fraction of unasked traps, whose conditional
expectation given c is (1 - 1/N)^c, because each trap question falls on a uniformly
chosen trap independently of everything else.
"""
import math
import sys
import numpy as np


def run(L, n, lam, N, a=1.0 / 3.0, verbose=True):
    p = a * L / n
    kappa = (lam + 1.0) / n
    cmax = int(40 * N + 200)                    # (1-1/N)^c < e^-40 beyond this: dropped mass counts 0
    cs = np.arange(cmax + 1)
    unasked = (1.0 - 1.0 / N) ** cs             # E[fraction of unasked traps | c trap questions]
    alive = np.zeros(cmax + 1); alive[0] = 1.0
    dead = np.zeros(cmax + 1)
    lnK = N * math.log(2) + math.log1p(math.exp(lam))      # K ln 2
    bound = L * lnK / n
    decay = 1.0 - math.exp(-kappa)
    sum_beta = 0.0
    last = None
    dropped = 0.0
    for t in range(1, n + 2):
        k = (t - 1) - cs                         # clock questions so far on an alive path
        valid = k >= 0
        kk = np.where(valid, k, 0)
        s = 1.0 / (1.0 + np.exp(lam - kappa * kk))          # 1 - G = M(1|r)
        G = 1.0 - s
        beta_alive = (1 - p) * L * G * decay + p * (G + G * (L - 1) * G * decay
                                                    + s * (L - 1) * 0.5 * unasked)
        beta_dead = p * (L - 1) * 0.5 * unasked
        eb = float(alive @ beta_alive + dead @ beta_dead)
        if t <= n:
            sum_beta += eb
        else:
            last = eb
            break
        # one round
        to_dead = alive * (p / L)
        to_trap = alive * (p * s * (L - 1) / L)
        stay = alive - to_dead - to_trap
        new_alive = stay.copy()
        new_alive[1:] += to_trap[:-1]
        dropped += to_trap[-1]
        dtrap = dead * (p * (L - 1) / L)
        new_dead = dead - dtrap + to_dead
        new_dead[1:] += dtrap[:-1]
        dropped += dtrap[-1]
        alive, dead = new_alive, new_dead
    avg = sum_beta / n
    # the lower bound proved in Proposition 6.3
    s1 = 1.0 / (1.0 + math.exp(-1.0))
    abar = a * L * math.log(1 + math.e) / (lam + 1.0)
    proved = (a * L * (L - 1) / (2.0 * n)) * (s1 * (math.exp(-a) * (1 - a * a / n) - abar / N) - kappa * abar / 4)
    if verbose:
        print(f"L={L} n={n} N={N} lambda={lam:.3f} K={lnK / math.log(2):.1f} bits: "
              f"sum_t<=n E beta = {sum_beta:.4g} <= L K ln2 = {L * lnK:.4g};  "
              f"avg = {avg:.4g};  bound L K ln2/n = {bound:.4g};  "
              f"E beta(M^(n+1)) = {last:.4g} (proved >= {proved:.4g});  "
              f"ratio last/bound = {last / bound:.3f} = {last / bound / math.sqrt(L):.4f} sqrt(L);  "
              f"proved ratio >= {proved / bound:.3f};  dropped mass {dropped:.1e}")
    return avg, last, bound, proved


if __name__ == "__main__":
    print("-- parameters of Proposition 6.3: a = 1/3, lambda + 1 = 1.1272 sqrt(L), N = ceil(1.6262 sqrt(L)), n = 100 L --")
    Ls = [100, 400, 1600, 6400]
    if len(sys.argv) > 1 and sys.argv[1] == "big":
        Ls.append(25600)
    for L in Ls:
        lam = 1.1272 * math.sqrt(L) - 1.0
        N = math.ceil(1.6262 * math.sqrt(L))
        run(L, 100 * L, lam, N)
    print("-- the same with n = 20 L --")
    for L in Ls:
        lam = 1.1272 * math.sqrt(L) - 1.0
        N = math.ceil(1.6262 * math.sqrt(L))
        run(L, 20 * L, lam, N)
    print("-- other parameters (numerical search by hand, not covered by the stated constant): a = 1/2 --")
    for L in Ls:
        lam = 1.0 * math.sqrt(L) - 1.0
        N = math.ceil(1.3 * math.sqrt(L))
        run(L, 100 * L, lam, N, a=0.5)
