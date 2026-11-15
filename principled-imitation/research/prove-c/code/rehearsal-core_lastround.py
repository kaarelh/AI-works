#!/usr/bin/env python3
"""Proposition 6.2 of rehearsal-core.md.  The 'hedger' example: the last round of
Protocol R is worse than a uniformly random round by a factor of order L (KL form of
Theorem R1).  Exact forward recursion over the posterior states; no sampling.

Inputs c (clock), r (routing), b (trap); answers are bits; L calls, no STOP.
z = 0 (prob 1-p): all calls at c.   z = 1 (prob p): call 1 at r; calls 2..L at b
if the answer at r was 1, at c otherwise.
Human f: f(c)=0, f(r)=1, f(b)=0.
h: h(c)=0, h(r)=1, h(b)=1.      g: g(0|c)=exp(-kappa), g(r)=0, g(b)=1.
Unnormalised prior weights: g: 1, h: eta, f: eta*phi.
"""
import math
import numpy as np

def lse(*a):
    m = max(a)
    return m + math.log(sum(math.exp(x - m) for x in a))

def run(Lc, n, a, ln_eta, ln_phi, verbose=True):
    p = a * Lc / n
    kappa = (math.log(2) - ln_eta) / n           # exp(-kappa n) = eta/2
    lw_h, lw_f = ln_eta, ln_eta + ln_phi
    lnW = lse(0.0, lw_h, lw_f)
    bound = Lc * (lnW - lw_f)                    # L ln(1/w(f)) = L K ln 2
    # state A_m: g, h, f alive and m questions at c so far (m = 0..n); B: g dead; C: only f.
    def stateA(m):
        lg = -kappa * m
        ltot = lse(lg, lw_h, lw_f)
        M1r = math.exp(lse(lw_h, lw_f) - ltot)                  # M(1|r)
        kc = ltot - lse(lg - kappa, lw_h, lw_f)                 # -ln M(0|c)
        kr = ltot - lse(lw_h, lw_f)                             # -ln M(1|r)
        kb = ltot - lw_f                                        # -ln M(0|b)
        lam = (1 - p) * Lc * kc + p * (kr + M1r * (Lc - 1) * kb + (1 - M1r) * (Lc - 1) * kc)
        return M1r, lam
    tabA = [stateA(m) for m in range(n + 2)]
    M1 = np.array([t[0] for t in tabA]); lamA = np.array([t[1] for t in tabA])
    kbB = lse(lw_h, lw_f) - lw_f
    lamB = p * (Lc - 1) * kbB                    # g dead: M exact at c and r, wrong at b
    PA = np.zeros(n + 2); PA[0] = 1.0; PB = 0.0; PC = 0.0
    ELam = []
    for t in range(1, n + 2):
        ELam.append(float(PA @ lamA) + PB * lamB)
        if t == n + 1:
            break
        toB = PA * p / Lc                                        # question at r kills g
        toC = PA * p * (Lc - 1) / Lc * M1                        # question at b kills g and h
        stay = PA - toB - toC                                    # question at c: one tick
        PC += toC.sum() + PB * p * (Lc - 1) / Lc
        PB = PB * (1 - p * (Lc - 1) / Lc) + toB.sum()
        PA = np.concatenate(([0.0], stay[:-1]))
    avg = sum(ELam[:n]) / n
    last = ELam[n]
    if verbose:
        print(f"L={Lc} n={n} a={a} ln(1/eta)={-ln_eta:.0f} ln(1/phi)={-ln_phi:.0f}: "
              f"avg_t E Lambda(M^(t)) = {avg:.5g} <= L K ln2 / n = {bound / n:.5g};  "
              f"E Lambda(M^(n+1)) = {last:.5g};  ratio last/bound = {last / (bound / n):.3f}")
    return avg, last, bound / n

if __name__ == "__main__":
    print("-- parameters of Proposition 6.2: a = 1/3, eta = 2 exp(-8L), phi = exp(-80L) --")
    for Lc in (5, 10, 20, 40):
        run(Lc, 4000, 1 / 3, math.log(2) - 8 * Lc, -80.0 * Lc)
    run(20, 20000, 1 / 3, math.log(2) - 8 * 20, -80.0 * 20)
    print("-- lower bound proved in Proposition 6.2 for these parameters: "
          "E Lambda(M^(n+1)) >= (1 - a - a ln(3 + 2 phi)/8) * p * (2/3) * (L-1) * ln(1/phi) --")
    for Lc in (5, 10, 20, 40):
        n, a = 4000, 1 / 3
        ln_eta, ln_phi = math.log(2) - 8 * Lc, -80.0 * Lc
        lnK = lse(0.0, ln_eta, ln_eta + ln_phi) - (ln_eta + ln_phi)          # K ln 2
        low = (1 - a - a * math.log(3 + 2 * math.exp(ln_phi)) / 8) * (a * Lc / n) * (2 / 3) * (Lc - 1) * (-ln_phi)
        print(f"L={Lc}, n={n}: proved E Lambda(M^(n+1)) >= {low:.5g};  proved ratio to L K ln2/n >= {low / (Lc * lnK / n):.3f}"
              f" = {low / (Lc * lnK / n) / (Lc - 1):.4f} (L-1)")
    print("-- other parameters (not covered by the proof): a = 1 --")
    for Lc in (5, 10, 20, 40):
        run(Lc, 4000, 1.0, math.log(2) - 8 * Lc, -80.0 * Lc)
