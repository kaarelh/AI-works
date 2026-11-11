"""TUBE probabilities (Lemma 6.4(b), Proposition 6.6(b)), recomputed by an independent exact formula.

Each of n i.i.d. samples picks an atom (prob 1/M) and a label (+1 w.p. p, -1 w.p. q=1-p).  "No atom carries both
labels" has, per atom, the exponential generating function e^{pz/M} + e^{qz/M} - 1, so
   P(no conflict) = n! [z^n] (e^{pz/M} + e^{qz/M} - 1)^M
                  = sum_{a+b+c=M} M!/(a! b! c!) (-1)^c ((a p + b q)/M)^n,
evaluated in exact rational arithmetic.  (At p = 1/2 this collapses to sum_j C(M,j) 2^j (-1)^{M-j} (j/(2M))^n.)"""
from fractions import Fraction as Fr
from math import comb, factorial, exp, floor, log
import random
out = []
def P(*a):
    s = " ".join(str(x) for x in a); print(s); out.append(s)

def p_noconflict(M, n, p):
    p = Fr(p); q = 1 - p; tot = Fr(0)
    for a in range(M+1):
        for b in range(M-a+1):
            c = M - a - b
            mult = factorial(M)//(factorial(a)*factorial(b)*factorial(c))
            tot += mult * (-1)**c * ((a*p + b*q)/M)**n
    return tot

def p_noconflict_half(M, n):
    return sum(comb(M, j) * 2**j * (-1)**(M-j) * Fr(j, 2*M)**n for j in range(M+1))

# brute force sanity check of the formula at tiny sizes
random.seed(1)
for (M, n, p) in ((2, 3, Fr(1, 3)), (3, 4, Fr(1, 2)), (4, 5, Fr(3, 4))):
    from itertools import product
    tot = Fr(0)
    for seq in product(range(M), (1, -1), repeat=n):
        pass
    # enumerate atoms and labels separately
    tot = Fr(0)
    for atoms in product(range(M), repeat=n):
        for labs in product((1, -1), repeat=n):
            ok = True; seen = {}
            for x, y in zip(atoms, labs):
                if seen.get(x, y) != y: ok = False; break
                seen[x] = y
            if ok:
                pr = Fr(1, M**n)
                for y in labs: pr *= (p if y == 1 else 1-p)
                tot += pr
    P(f"brute force M={M} n={n} p={p}: {float(tot):.10f}  formula: {float(p_noconflict(M, n, p)):.10f}  equal: {tot == p_noconflict(M, n, p)}")

P("\nProposition 6.6(b): exact P(no conflict) <= one-atom expression <= 2 exp(-n(1-eta0)/(2M))")
allok = True
for d in (1, 2, 3):
    M = 2**d
    for eta0 in (Fr(1, 4), Fr(1, 2), Fr(9, 10)):
        p = (1 + eta0)/2
        for n in (4, 16, 64, 256):
            ex = p_noconflict(M, n, p)
            one = (1 - (1-p)/M)**n + (1 - p/M)**n - (1 - Fr(1, M))**n
            bd = 2*exp(-n*(1-float(eta0))/(2*M))
            ok = float(ex) <= float(one) <= bd
            allok &= ok
            P(f"  d={d} eta0={float(eta0):.2f} n={n:3d}: exact {float(ex):.4e}  one-atom {float(one):.4e}  bound {bd:.4e}  {ok}")
P("all 36 cases ordered as claimed:", allok)

P("\nLemma 6.4(b) at p=1/2: exact P(no conflict) versus the stated bound")
for (M, n) in ((64, 16), (64, 64), (256, 64), (256, 256), (1024, 256), (1024, 1024)):
    ex = p_noconflict_half(M, n)
    n1 = n//2; n2 = n - n1
    mu1 = M*(1 - (1 - 1/M)**n1)
    bd = exp(-n2*mu1/(4*M)) + exp(-mu1**2/(2*n1))
    simp = exp(-0.039*n*(n-1)/M) + exp(-0.19*n1) if n <= 2*M else float('nan')
    P(f"  M={M:5d} n={n:5d}: exact {float(ex):.3e}   bound {bd:.3e}   simplified {simp:.3e}   exact<=bound<=simplified: {float(ex) <= bd <= simp}")
open(__file__.replace('.py', '.out'), 'w').write("\n".join(out) + "\n")
