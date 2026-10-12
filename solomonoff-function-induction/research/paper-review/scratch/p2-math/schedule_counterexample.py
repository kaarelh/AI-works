#!/usr/bin/env python3
"""Counterexample to 'every schedule with lambda_n/n -> 0 eventually reproduces the errors' at a fixed instance:
lambda_n = n^0.9 at d=100, m=20, p=2^-10 (kappa=0, delta_S=0, B=30, delta=0.01).
Uses the formulas of thm:teacher:main(ii) and cor:teacher:sampled as printed in the paper (imported from teacher_numbers.py)."""
from math import log2, log, sqrt
src = open(__file__.replace('schedule_counterexample.py', 'teacher_numbers.py')).read().split('def bisect')[0]
exec(src)
for n in (1e23, 1e25, 1e27, 2.0**100):
    c = n**-0.1
    I = Inst(100, 20, 10, B=30)
    eps1 = 10*sqrt(log(2/0.01)/(2*n))
    Lhat = (I.Jg(c) + eps1)/c
    epsn = eps1 + 30*sqrt((Lhat*log(2) + log(2/0.01))/(2*n))
    r = I.ident(c, eps=epsn)
    print(f"n={n:.3g}: c=lambda/n={c:.3e} (2^-m={2.0**-20:.3e}), cond J_g+eps_n<Phi2: {r['ok']}, u>={r['u']:.3f}, e<={r['e']:.3f} (g={r['g']})")
