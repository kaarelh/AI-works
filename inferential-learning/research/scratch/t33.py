from math import log2, log
# 1. the inequality used in Thm 3.3 proof: 1-log2(1+2^{1-t}) >= 1-2^{1-t} for t>=1 ?
for t in [1,2,3,4,6,8]:
    u=2**(1-t)
    print(t, "exact lower bound 1-log2(1+u)=%.4f"%(1-log2(1+u)), " claimed 1-u=%.4f"%(1-u), " correct 1-u/ln2=%.4f"%(1-u/log(2)))
# 2. counterexample to identification bullet 2: one region, m=1, pi=1, d=40, hypothesis h_q = f_a with confidence q
d=40; pi=1.0
for q in [0.74,0.745,0.749]:
    shat=2*q-1; R=-log2(q)
    for kappa in [10,100,1000]:
        c=1e-6/(kappa+100)
        Kq = d+2*log2(d)+kappa+20   # generous upper bound on K(h_q): a literal + overhead + q
        J = c*Kq + pi*R
        eta = J                      # J <= Phi + eta trivially since Phi >= 0
        Delta0 = c*((2*log2(d)+2*log2(1)+4+kappa)+kappa) + pi*2**(1-d/4)
        Delta = 2*Delta0+eta
        condA = pi > c*d + Delta + pi*2**(1-d/4)
        condB = pi > 2*Delta + 16*c
        print(f"q={q} kappa={kappa}: shat={shat:.3f} R={R:.4f} Delta={Delta:.4f} condA={condA} condB={condB} -> theorem claims shat>=1/2: {'VIOLATED' if condA and condB and shat<0.5 else 'ok'}")
