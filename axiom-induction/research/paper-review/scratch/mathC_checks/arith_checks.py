# Independent arithmetic checks of numbers quoted in sections pa / experiments (and their appendices).
import math
from math import lgamma, log2, log
L = log2(23)
print("== Prop pa:lower: log2(10)+11*beta, log2(10)+9*beta:", round(log2(10)+11*L,2), round(log2(10)+9*L,2))
print("   citation in a 9-axiom theory (writes P(x)):", round(log2(10)+log2(9)+2*L,2), " 11 axioms:", round(log2(10)+log2(11)+2*L,2))
print("   template priors |Ind|=16,|CVI|=18,|LNP|=19:", [round(L*k,1) for k in (16,18,19)])
print("== Rem pa:usage break-even:", round(880.4/1468.0,3), round(1692.1/2234.1,3), " decodable:", round(945.1/1551.2,3), round(1792.3/2341.8,3))
print("   log2(11/9) =", round(log2(11/9),3), "; 0.29/646.4 =", 0.29/646.4, " 0.29/1468 =", 0.29/1468)
print("   using Prop pa:lower's lower bounds instead (44, 53 bits):", 0.29/44, 0.29/53)
print("== Prop pa:must(b): beta*(7+13) =", round(L*7,1), "+", round(L*13,1), "=", round(L*20,1), "; one theorem of size 17:", round(17*L,1), "> 72?", 17*L>72)
def spare(n,K,beta_tau=15):
    exact = beta_tau - (lgamma((K+1)/2)-lgamma(K/2)+lgamma(n+K/2)-lgamma(n+(K+1)/2))/log(2)
    asym = beta_tau + 0.5*log2(n) + (lgamma(K/2)-lgamma((K+1)/2))/log(2)
    return exact, asym
print("== Prop pa:spare (K=8, 15 prior bits): n=10,1000,3000 exact/asym:", [tuple(round(x,2) for x in spare(n,8)) for n in (10,1000,3000)])
print("== Ex pa:narrow slope (9-8)/2-3*(9-1)/2 =", (9-8)/2-3*(9-1)/2, "; crossover log2 n =", round(log2(3000)+174.6/11.5,2))
print("== Ex pa:skel slope (164-8)/2-19*(9-1)/2 =", (164-8)/2-19*(9-1)/2, "; 119-template theory: (119-8)/2-19*4 =", (119-8)/2-19*4)
print("== Rem pa:merge slope (3-13)/2 =", (3-13)/2, "; crossover n =", "%.2e" % (3000*2**(76.7/5)))
print("== Rem pa:occam(c) root split |F|=7: (7-9)/2 =", (7-9)/2, "; crossover log2 n ~", round(log2(3000)+768.3/1,0))
# Euler polynomial
def isprime(m):
    if m<2: return False
    i=2
    while i*i<=m:
        if m%i==0: return False
        i+=1
    return True
bad=[k for k in range(0,200) if not isprime(k*k+k+41)]
print("== Ex pa:euler: first composite k:", bad[:8])
for rho in (0.9,0.97):
    tot=sum((1-rho)*rho**k for k in range(0,4000) if not isprime(k*k+k+41))
    print("   rho=%.2f: unconditioned mass of false k = %.4f; KL of schema (bits/datum) ~ %.4f" % (rho, tot, -log2(1-tot)))
print("   |datum(k)| = 27+3(3(k+1)+45); template size 27+3*48 =", 27+3*48)
print("== E4(A) exact (1-u)^t*:", [round((1-u)**t,5) for u,t in ((0.05,150),(0.01,680),(0.5,10),(0.1,47),(0.2,17))])
ex=[0.00046,0.00108,0.00098,0.00707,0.02252]; bd=[0.01,0.05,0.01,0.1,0.2]
print("   bound/exact ratios:", [round(b/e,1) for b,e in zip(bd,ex)])
print("== E5(b) per-datum gain 3-log2 5 =", round(3-log2(5),3), "; E5(c) L_inf mean cost on round robin over i: (i+1)/2")
a,s,m=31.56,30.02,28.41
w=[2**-a,2**-a,2**-s,2**-m,2**-m]
print("== E6 prior share of A_xy,A_yx among the five closed-guard forms:", round(sum(w[:2])/sum(w),4), " shares:", [round(x/sum(w),3) for x in w])
print("== E7 log2(78/2) =", round(log2(78/2),2), "; log2(1+287)-log2(78) =", round(log2(288/78),2))
print("== E8 marginal rates 1024->4096:", round((817.04-196.52)/3072,4), round((299.59-72.05)/3072,4), "; totals/4096:", round(817.04/4096,4), round(299.59/4096,4))
print("   E8 slopes 256->4096:", round((-12.98+7.27)/4,3), round((-12.86+6.82)/4,3))
print("== E2 frag-complete slope 64->512 from table:", round((716.3-703.6)/3,2), "; nested spare:", round((89.2-88.5)/3,3))
print("== thm:sound:shrink threshold exponent for 8 components: (m-1)/2 =", (8-1)/2)
