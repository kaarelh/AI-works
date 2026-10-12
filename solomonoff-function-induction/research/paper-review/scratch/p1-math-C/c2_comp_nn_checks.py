"""p1-math-C check 2: independent numeric checks of constants in comp.tex / nn.tex / ood.tex / app-*.tex.
Deterministic, standard library + numpy only.  Usage: python3 -I c2_comp_nn_checks.py"""
import math, itertools
import numpy as np
from math import comb, log2, log, ceil

out = []
def say(*a):
    s = " ".join(str(x) for x in a); print(s); out.append(s)

# (1) thm:comp:circuitbayes explicit form: largest L*/(E(d+1)log(2(E+1)(d+2))) over a grid, where L* is the
#     largest fixed point of R(L)=2E[(d+1)(5+2log(2d+4+L))+3].
def Lstar(E, d):
    R = lambda L: 2*E*((d+1)*(5+2*log2(2*d+4+L))+3)
    lo, hi = 0.0, 1.0
    while R(hi) >= hi: hi *= 2
    for _ in range(200):
        mid = (lo+hi)/2
        if R(mid) >= mid: lo = mid
        else: hi = mid
    return lo
best = (0, None)
for E in np.logspace(-3, 5, 161):
    for d in [1, 2, 3, 5, 10, 30, 100, 300, 1000, 3000, 10000]:
        r = Lstar(E, d)/(E*(d+1)*log2(2*(E+1)*(d+2)))
        if r > best[0]: best = (r, (E, d))
say(f"(1) circuit Bayes: max L*/(E(d+1)log(2(E+1)(d+2))) on grid = {best[0]:.3f} at E={best[1][0]:.3g}, d={best[1][1]} (paper: 10.85, <16)")
# bracket values used in the proof
X0 = log2(6)
say(f"    first bracket at X=log6: {12*X0-4*log2(1+X0)-13:.3f} (paper 10.65); max_Y log(1+Y)-Y = {max(log2(1+y)-y for y in np.linspace(0,10,100001)):.4f} (paper uses 0.087)")
say(f"    -4log4.5-4*0.087 = {-4*log2(4.5)-4*0.087:.3f} (paper -9.03)")

# (2) prop:comp:occam: 70*l+531 samples at eps=delta=0.01 with |H_f|<2^{l+1}
worst = max(((math.log(2**(l+1))+math.log(100))/0.01) - (70*l+531) for l in range(1, 2000))
say(f"(2) Occam PAC: max over l of [(ln 2^(l+1)+ln100)/0.01 - (70l+531)] = {worst:.2f} (<=0 means the paper's 70l+531 suffices)")
# constant 5.7 in (b): sum_{n=1}^{N-1}[2ln(n+1)/n + (n+1)^-2] + 1 - [ln^2 N]  (the ln|H| part is separate)
for N in [10, 100, 10**4, 10**6]:
    s = 1 + sum(2*math.log(n+1)/n + (n+1)**-2 for n in range(1, N))
    say(f"    N={N}: const part sum - ln^2 N = {s - math.log(N)**2:.3f} (paper bounds it by 5.7)")

# (3) rem:comp:uniformties: 1 + sum_{k=1}^{d-1} H_{C(d,k)} <= d + d^2 ln 2
def H(m): return sum(1/j for j in range(1, m+1)) if m < 10**6 else math.log(m)+0.5772156649+1/(2*m)
viol = []
for d in range(2, 41):
    lhs = 1 + sum(H(comb(d, k)) for k in range(1, d))
    rhs = d + d*d*math.log(2)
    if lhs > rhs: viol.append(d)
say(f"(3) uniform ties: 1+sum H_C(d,k) <= d+d^2 ln2 violated for d in {viol} (d=2..40)")

# (4) Mobius lemma for d<=4 (exhaustive) and the ladder fact: least-size-consistent = k-conjunctions is c6's job;
#     here only lemma (i),(ii).
def depends(tt, d, j):
    return any(tt[x] != tt[x ^ (1 << j)] for x in range(2**d))
bad = 0
for d in range(1, 5):
    N = 2**d
    for k in range(1, d+1):
        for tt_int in range(2**N):
            tt = [(tt_int >> x) & 1 for x in range(N)]
            if tt[N-1] != 1: continue
            if any(tt[x] for x in range(N) if bin(x).count("1") < k): continue
            dep = [j for j in range(d) if depends(tt, d, j)]
            if len(dep) < k: bad += 1
            if len(dep) == k:
                andS = [int(all((x >> j) & 1 for j in dep)) for x in range(N)]
                if andS != tt: bad += 1
say(f"(4) Mobius lemma exhaustive d<=4: violations = {bad}")

# (5) rem:nn:oddparity(a): Walsh coefficients of Psi(rho(z)) for the bias-free 2-layer ReLU NNGP and NTK, d=7
def psi1(r): r = max(-1, min(1, r)); return (math.sqrt(max(0, 1-r*r)) + r*(math.pi-math.acos(r)))/math.pi
def psi0(r): r = max(-1, min(1, r)); return (math.pi-math.acos(r))/math.pi
d = 7
zs = list(itertools.product([-1, 1], repeat=d))
for name, Psi in [("NNGP", psi1), ("NTK", lambda r: psi1(r)+r*psi0(r))]:
    vals = np.array([Psi(sum(z)/d) for z in zs])
    lam = {}
    for k in range(0, d+1):
        S = list(range(k))
        chi = np.array([np.prod([z[j] for j in S]) if S else 1 for z in zs])
        lam[k] = float(np.mean(vals*chi))
    say(f"(5) {name} d={d}: Lambda_k = " + ", ".join(f"{k}:{lam[k]:.2e}" for k in lam))

# (6) prop:nn:uniform counting identity: fraction = 1/(N_s * 16 (d+1+S)^2)
def Ns(s, d): return math.prod(16*(d+1+j)**2 for j in range(1, s+1))
ok6 = all(abs(math.prod(16*(d+1+j)**2 for j in range(s+1, S)) / Ns(S, d) * Ns(s, d) * 16*(d+1+S)**2 - 1) < 1e-12
          for d in [1, 3, 10] for S in range(2, 12) for s in range(1, S))
say(f"(6) uniform-circuit padding fraction identity holds: {ok6}")

# (7) gadget weight bound: 2^-g N_s/N_{s+g} >= 2^{-g(5+2log(d+1+s+g))}
ok7 = all(-g + log2(Ns(s, d)) - log2(Ns(s+g, d)) >= -g*(5+2*log2(d+1+s+g)) - 1e-9
          for d in [1, 2, 5, 20] for s in range(1, 40) for g in range(1, d+2))
say(f"(7) exception-gadget weight bound holds on grid: {ok7}")

# (8) prop:ood:converse(b): max_delta delta(1-delta)^n <= 1/(n+1)
ok8 = all(max(dl*(1-dl)**n for dl in np.linspace(0, 1, 20001)) <= 1/(n+1)+1e-12 for n in range(1, 200))
say(f"(8) delta(1-delta)^n <= 1/(n+1) for n<200: {ok8}")

# (9) ex:ood:easyhard / hanniexamples: K(ceil(log L)) <= 2 log log L for large L is a statement about prefix codes.
#     Elias-delta length of m=ceil(log L) vs 2 log log L:
def elias_delta(m): return int(log2(m)) + 2*int(log2(int(log2(m))+1)) + 1
for L in [2**8, 2**16, 2**64, 2**1024]:
    m = ceil(log2(L)); say(f"(9) L=2^{int(log2(L))}: Elias-delta(ceil log L)={elias_delta(m)}, 2loglogL={2*log2(log2(L)):.1f}")

# (10) cor:nn:separation: K(chi_S) code length vs k log d, and binom(d,k) vs (d/k)^k
for d, k in [(10, 3), (10, 5), (100, 5), (1000, 10)]:
    say(f"(10) d={d},k={k}: log C(d,k)={log2(comb(d,k)):.1f}, k log d={k*log2(d):.1f}, C(d,k)={comb(d,k)}, (d/k)^k={(d/k)**k:.3g}")

# (11) rem:comp:constant: (2^{n_A}-1)log|Y| with n_A >= n_i = 2^{2^i}
for i in [1, 2, 3]:
    say(f"(11) i={i}: n_i=2^(2^i)={2**(2**i)}; activation term >= 2^{2**(2**i)}-1 ~ 2^(2^(2^i))")
open("c2_comp_nn_checks.out.txt", "w").write("\n".join(out)+"\n")
