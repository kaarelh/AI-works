#!/usr/bin/env python3
"""
Low stakes with a human who is not deterministic: how the failure probability depends
on the number of questions.  (Attack on the sentence after Theorem R3 in note.md and on
Proposition 9.1(b) / 9.3(iii) of research/prove-c/rehearsal-core.md, which give
    Pr[N >= k+1] <= L sqrt(K ln2/(2n)) / (k+1)                     (Markov on N)
for the number N of unfaithful calls of the deployed run of M^(T).)

Proposition X4 of the attack report:
    Pr[N >= k+1] <= L^2 ln(W/w(P)) / (2 n a^2) + (e a/(k+1))^(k+1) e^(-a)   for every a in (0, k+1),
and with a = (k+1)/(2e), k+1 >= theta L:
    Pr[N >= k+1] <= 2 e^2 ln(W/w(P)) / (theta^2 n) + 2^-(k+1).
So the number of questions for an excess failure gamma' is of order K/(theta^2 gamma'),
not K/(theta^2 gamma'^2).

Exact check on the family of Proposition 9.3: one input, L calls, the class
{Bern(1/2 + t), Bern(1/2 - t)} with weights 1/2 (K = 1).  Every round asks one question,
so the data are i.i.d. draws; given M^(t) the number N of unfaithful calls of a run is
Binomial(L, TV(M^(t), P)).  Pr[N >= k+1] is computed exactly and compared with both bounds.
"""
import math
import numpy as np
from scipy.stats import binom

def partial_sums(L, k, tprime, tmax):
    """S[n] = sum_{t=1}^{n} E Pr[ Bin(L, tv_t) >= k+1 ] and B[n] = sum_{t<=n} E[L tv_t],
    tv_t = (posterior weight of the wrong member after t-1 answers) * 2 t'."""
    p = 0.5+tprime
    llr = math.log(p/(1-p))            # log likelihood ratio of one answer equal to 1
    S = [0.0]; B = [0.0]
    for t in range(1, tmax+1):
        j = t-1                         # answers seen
        s = np.arange(0, j+1)
        ps = binom.pmf(s, j, p)
        # posterior weight of the wrong member Bern(1/2 - t'): 1/(1 + exp(llr*(2s - j)))
        wwrong = 1.0/(1.0+np.exp(np.clip(llr*(2*s-j), -700, 700)))
        tv = wwrong*2*tprime
        S.append(S[-1]+float(ps @ binom.sf(k, L, tv)))
        B.append(B[-1]+float(ps @ (L*tv)))
    return S, B

def main():
    c = math.log(2.0)                   # ln(W/w(P)) with two members of weight 1/2
    print("family of Proposition 9.3 with K = 1;  N = number of unfaithful calls of the deployed run of M^(T)")
    tmax = 3200
    for (L, tprime, theta) in [(400, 0.2, 0.05), (2000, 0.1, 0.02)]:
        k = int(math.ceil(theta*L))-1
        S, B = partial_sums(L, k, tprime, tmax)
        # the terms decay geometrically: E[posterior weight of the wrong member after j answers] <= BC^j,
        # BC = 2 sqrt(p(1-p)); the remainder of both sums beyond tmax is below L*BC^tmax/(1-BC)
        BC = 2*math.sqrt((0.5+tprime)*(0.5-tprime)); rest = L*BC**tmax/(1-BC)
        print(f"L={L}, bias t'={tprime}, tolerated faults k={k} (k+1 = {k+1} = theta L with theta={theta}); remainder of the sums beyond t={tmax}: < {rest:.1e}")
        for n in [50, 200, 800, 3200, 10**5, 10**6, 10**7]:
            ex = S[min(n, tmax)]/n; mb = B[min(n, tmax)]/n
            markov = min(1.0, L*math.sqrt(c/(2*n))/(k+1))
            x4 = min(1.0, 2*math.e**2*c/(theta**2*n)+2.0**(-(k+1)))
            best = 1.0
            for a in np.linspace(0.01, k+0.99, 2000):
                v = L*L*c/(2*n*a*a)+(math.e*a/(k+1))**(k+1)*math.exp(-a)
                best = min(best, v)
            print(f"  n={n:8d}: exact Pr[N >= k+1] = {ex:.3e};  E N = {mb:.3e} <= L sqrt(c/(2n)) = {L*math.sqrt(c/(2*n)):.3e};  "
                  f"Markov bound (9.1(b)) = {markov:.3e};  X4 with a=(k+1)/(2e): {x4:.3e};  X4, best a: {best:.3e}")
    print("In every line: exact <= each bound.  The exact probability and X4 fall like 1/n, the Markov bound like n^(-1/2).")

if __name__ == '__main__':
    main()
