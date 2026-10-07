# A2: coupon-collector rate for motive-annotated induction, with concrete constants.
from common import *
import math, random
delta = 0.01
roots = {'eq': .6, 'imp': .2, 'all': .1, 'other': .1}
roots_split = {'eq': .6, 'imp': .2, 'all': .1, 'not': .02, 'and': .02, 'or': .02, 'lt': .02, 'ex': .02}
def best_split(p):
    vals = list(p.values()); best = 0
    for mask in range(1 << len(vals)):
        s = sum(v for i, v in enumerate(vals) if mask >> i & 1); best = max(best, min(s, 1 - s))
    return best
for q in (1.0, 0.95):
    print(f'=== x fixed (v=3: P,A,B), non-vacuity rate q={q} ===')
    v = 3; c = 2 * v + v * (v - 1) // 2
    rhoP = best_split(roots); rho = min(rhoP, q)
    print(f' c = 2v + C(v,2) = {c};  rho_P = rho_A = rho_B = {rhoP:.2f} (split {{eq}} | rest);  r_PA = r_PB = r_AB = q = {q};  rho = {rho}')
    Nthm = math.ceil(math.log(c / delta) / rho)
    print(f' Thm imitation:coupon (k=1, pi=1): N >= ln(c/delta)/rho = {math.log(c/delta)/rho:.3f}  ->  N = {Nthm}')
    # refined union bound: the three (R) events coincide (roots of P, A, B are equal), the three (D) events coincide
    Nref = next(N for N in range(1, 500) if 2 * (1 - rhoP) ** N + (1 - q) ** N <= delta)
    print(f' refined union bound 2(1-rho_P)^N + (1-q)^N <= delta: N = {Nref}')
    for name, p in (('other = one symbol', roots), ('other = 5 symbols', roots_split)):
        exact = lambda N: 1 - (1 - sum(pp ** N for pp in p.values())) * (1 - (1 - q) ** N)
        Nex = next(N for N in range(1, 500) if exact(N) <= delta)
        print(f' exact failure prob (independent root/vacuity, {name}): smallest N with P(fail) <= {delta}: {Nex}  (P(fail) at N-1: {exact(Nex-1):.5f}, at N: {exact(Nex):.5f})')
    print(f' necessity (Thm coupon, lower bound): P(fail) >= 0.6^N, so N >= ln(1/delta)/ln(1/0.6) = {math.log(1/delta)/math.log(1/0.6):.3f}')

# ---- simulation with the T1 lgg ----
rng = random.Random(7)
def sample_root(p):
    r = rng.random(); acc = 0
    for kname, pp in p.items():
        acc += pp
        if r < acc: return kname
    return kname
def draw_fixed(q):
    rt = sample_root(roots_split)
    return rand_motive_with_root(rng, rt, x, nonvacuous=(rng.random() < q))
print('\n=== simulation, x fixed, other = 5 symbols (T1 lgg on Sub-encoded instances) ===')
p = roots_split
for q in (1.0, 0.95):
    for N in (4, 6, 8, 9, 10, 12):
        T = 3000; succ = 0
        for _ in range(T):
            D = [ind(draw_fixed(q)) for _ in range(N)]
            succ += equiv(lgg_list(D), SIGMA_X)
        ex = 1 - (1 - sum(pp ** N for pp in p.values())) * (1 - (1 - q) ** N)
        print(f' q={q} N={N:2d}: empirical P(fail) = {1-succ/T:.4f}   exact formula = {ex:.4f}')

# ---- x a metavariable ----
print('\n=== x a metavariable (v=4: P,X,A,B), induction variable n 70%, x 20%, k 10%; q = 1 ===')
varp = {'n': .7, 'x': .2, 'k': .1}
v = 4; c = 2 * v + v * (v - 1) // 2
rhoX = best_split(varp); rho = min(best_split(roots), rhoX, 1.0)
print(f' c = {c}; rho_X = {rhoX:.2f}; rho = {rho:.2f}; r_XP etc = 1 (a variable never equals a formula)')
Nthm = math.ceil(math.log(c / delta) / rho)
print(f' Thm coupon: N >= ln(c/delta)/rho = {math.log(c/delta)/rho:.3f} -> N = {Nthm}')
exact = lambda N: 1 - (1 - sum(pp ** N for pp in roots_split.values())) * (1 - sum(pp ** N for pp in varp.values()))
Nex = next(N for N in range(1, 500) if exact(N) <= delta)
print(f' exact (independent root/variable): N = {Nex} (P(fail) at N-1 = {exact(Nex-1):.5f}, at N = {exact(Nex):.5f})')
def draw_meta():
    vn = sample_root(varp); vv = C(vn)
    return rand_motive_with_root(rng, sample_root(roots_split), vv, True, vars_=(vn, 'y')), vv
for N in (8, 12, 14, 16):
    T = 2000; succ = 0
    for _ in range(T):
        D = [ind(*draw_meta()) for _ in range(N)]
        succ += equiv(lgg_list(D), SIGMA_M)
    print(f' N={N:2d}: empirical P(fail) = {1-succ/T:.4f}   exact formula = {exact(N):.4f}')
# induction is a fraction pi of all tagged steps
for pi in (0.05, 0.01):
    print(f' if induction is {pi:.0%} of all tagged steps (x fixed, Thm coupon, k=1 term only): N_total >= {math.log(9/delta)/(pi*0.4):.0f}')
