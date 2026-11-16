#!/usr/bin/env python3
"""
Attack on Proposition 5.5 of research/prove-c/rehearsal-core.md (a new round at every
call is not covered by R1): the ladder, computed EXACTLY for L = 2, 3, 4 (no sampling).

State of the rehearsal after t rounds: for every rung j either "not yet learned" or
the round in which it was learned.  N_j = number of rounds t <= n at whose start rung
j was not learned = (round in which j was learned), or n if never.

Checked:
 (a)  u(Mbar) <= (L/n) sum_t u(M^(t))  on every path;
 (b1) E u(Mbar) >= (1-p)^2 (L^3/(2n) - L^6/n^2)      for n >= L^2;
 (b2) E u(M^(T)) <= min(ln(1/p), 1) L^2/n;
 (b3) for n >= 4 L^3:  E u(Mbar) >= (1-p)^2 L/4 * E u(M^(T))  and
      E u(Mbar) >= (1-p)^2 L/(4 ln(1/p)) * (L ln(1/w(f))/n).
"""
import math
from collections import defaultdict

def ladder(L, n, p):
    # state: tuple of length L, entry 0 = not learned, else the round in which it was learned
    states = {tuple([0]*L): 1.0}
    done = defaultdict(float)         # states with every rung learned (absorbing; u(M^(t)) = 0 from then on)
    sum_u = 0.0                       # sum over t of E u(M^(t))
    for t in range(1, n+1):
        new = defaultdict(float)
        for st, pr in states.items():
            unl = [j for j in range(L) if st[j] == 0]
            u = len(unl)
            sum_u += pr*(1.0-p**u)
            stay = 1.0
            for rank, j in enumerate(unl):
                pj = (1.0/L)*p**rank
                st2 = list(st); st2[j] = t
                if u == 1:
                    done[tuple(st2)] += pr*pj
                else:
                    new[tuple(st2)] += pr*pj
                stay -= pj
            new[st] += pr*stay
        states = new
    for st, pr in done.items():
        states[st] = states.get(st, 0.0)+pr
    E_bar = 0.0; worst_path = -1e9
    for st, pr in states.items():
        N = [st[j] if st[j] > 0 else n for j in range(L)]
        prod = 1.0
        for j in range(L):
            prod *= 1.0-(1.0-p)*N[j]/n
        ubar = 1.0-prod
        E_bar += pr*ubar
        # sum_t u(M^(t)) on this path: u_t = number of rungs with N_j >= t
        s = 0.0
        srt = sorted(N)
        prev = 0
        for i, v in enumerate(srt):
            s += (v-prev)*(1.0-p**(L-i)); prev = v
        worst_path = max(worst_path, ubar-(L/n)*s)
    return E_bar, sum_u/n, worst_path

def main():
    for L in [2, 3, 4]:
        for p in [0.5, 0.9, 0.1]:
            ns = sorted(set([L*L, 2*L*L, L**3, 4*L**3, 8*L**3] + ([40*L**3] if L <= 2 else [])))
            for n in ns:
                if L == 4 and n > 32: continue
                Ebar, ET, wp = ladder(L, n, p)
                lb = (1-p)**2*(L**3/(2*n)-L**6/n**2)
                ub = min(math.log(1/p), 1.0)*L*L/n
                bound_R1 = L*L*math.log(1/p)/n
                line = (f"L={L} p={p} n={n:5d}: E u(Mbar) = {Ebar:.5f} >= {lb:9.5f}: {Ebar >= lb-1e-12};  "
                        f"E u(M^(T)) = {ET:.5f} <= {ub:.5f}: {ET <= ub+1e-12};  max over paths of u(Mbar) - (L/n) sum_t u(M^(t)) = {wp:.2e}")
                if n >= 4*L**3:
                    c1 = Ebar/ET/((1-p)**2*L/4); c2 = Ebar/bound_R1/((1-p)**2*L/(4*math.log(1/p)))
                    line += f";  [n >= 4L^3] ratios to the two claimed factors: {c1:.2f}, {c2:.2f} (need >= 1);  Mbar/M^(T) = {Ebar/ET:.2f}"
                print(line)

if __name__ == '__main__':
    main()
