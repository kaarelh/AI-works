# Noise-free variant of N_1: does it work if Step 1 keeps the trim budget e_i = floor((abar_i+Delta)N_1) (abar_i=0)?
# One tag (K=1), schema with one metavariable x (c=2), root(x) uniform on 2 roots => rho=1/2, pi=1, beta=1, lambda=1/2.
from math import comb, log, ceil, floor
for delta in [0.05,0.01,0.001]:
    lam=0.5; c=2; K=1
    N1=ceil(log(c*K/delta)/lam)
    Delta=(0.5*1-0)/2          # Delta_i computed with abar=0
    e=floor(Delta*N1)
    # trimmed verifier identifies sigma iff both root-classes have > e samples (robust genericity, v=1)
    p_fail_trim=sum(comb(N1,k) for k in range(N1+1) if k<=e or N1-k<=e)/2**N1
    p_fail_untrim=2/2**N1   # all samples share a root
    print(f'delta={delta}: N1={N1}, e={e}, Pr[fail | e as written]={p_fail_trim:.4g}, Pr[fail | e=0]={p_fail_untrim:.3g}')
