# A6b: why the audit gets only a bag for 'step by 2' when W = Delta_0 truth and only the empty position is designated.
# Finite structures:  Z_N (N odd): S = +1 mod N  -- injective (Q2 holds), 0 is a successor (Q1 fails);
#                     rho_N (N even): 0 -> 1 -> ... -> N-1 -> 1  -- Q1 holds, S not injective (Q2 fails).
# In both, every element is reached from 0 by iterating SS, so every step-by-2 instance (any motive, any
# parameters) is true; genuine induction is true as well.  Closed Delta_0 sentences whose evaluation in N stays
# below N have the same truth value (all values are computed exactly as in N).
from common import *
import itertools, random
def make_struct(kind, N):
    if kind == 'Z':
        S_ = lambda a: (a + 1) % N
        red = lambda v: v % N
    else:  # rho
        S_ = lambda a: a + 1 if a + 1 < N else 1
        red = lambda v: v if v < N else 1 + (v - 1) % (N - 1)
    return dict(N=N, S=S_, add=lambda a, b: red(a + b), mul=lambda a, b: red(a * b))
def evs_t(t, env, M):
    h = t[0]
    if h == '0': return 0
    if len(t) == 1: return env[h]
    if h == 'S': return M['S'](evs_t(t[1], env, M))
    if h == 'add': return M['add'](evs_t(t[1], env, M), evs_t(t[2], env, M))
    if h == 'mul': return M['mul'](evs_t(t[1], env, M), evs_t(t[2], env, M))
def evs(f, env, M):
    h = f[0]
    if h == 'eq': return evs_t(f[1], env, M) == evs_t(f[2], env, M)
    if h == 'lt': return evs_t(f[1], env, M) < evs_t(f[2], env, M)
    if h == 'not': return not evs(f[1], env, M)
    if h == 'and': return evs(f[1], env, M) and evs(f[2], env, M)
    if h == 'or': return evs(f[1], env, M) or evs(f[2], env, M)
    if h == 'imp': return (not evs(f[1], env, M)) or evs(f[2], env, M)
    if h == 'iff': return evs(f[1], env, M) == evs(f[2], env, M)
    if h == 'all': return all(evs(f[2], {**env, f[1][0]: a}, M) for a in range(M['N']))
    if h == 'ex': return any(evs(f[2], {**env, f[1][0]: a}, M) for a in range(M['N']))
def closure_true(f, M):
    fv = sorted(free_vars(f))
    return all(evs(f, dict(zip(fv, vals)), M) for vals in itertools.product(range(M['N']), repeat=len(fv)))
Q1 = ALL(x, NOT(eq(S(x), Z))); Q2 = ALL(x, ALL(y, IMP(eq(S(x), S(y)), eq(x, y))))
U = motives_upto(6, ('x', 'y'), conns=('not', 'and', 'imp'), quants=('all', 'ex'))
rng = random.Random(9); U7 = motives_upto(7, ("x", "y"), conns=("not", "and", "imp"), quants=("all", "ex")); sampleU = U + rng.sample(U7, 1000)
for kind, N in (('Z', 7), ('Z', 9), ('rho', 8), ('rho', 10)):
    M = make_struct(kind, N)
    st2 = all(closure_true(ind2(p)[-1], M) for p in sampleU)
    st1 = all(closure_true(ind(p)[-1], M) for p in sampleU)
    print(f'{kind}_{N}: Q1 {closure_true(Q1, M)}, Q2 {closure_true(Q2, M)}; all {len(sampleU)} sampled step-by-2 instances true: {st2}; '
          f'genuine induction instances true: {st1}')
# Delta_0 mirroring: random closed quantifier-free sentences with small values agree with N
M = make_struct('Z', 101); bad = 0; tot = 0
for p in U:
    if free_vars(p) or any(q in str(p) for q in ("'all'", "'ex'")): continue
    tot += 1
    if evs(p, {}, M) != ev(p, {}): bad += 1
print(f'closed quantifier-free sentences of size <= 6 (values < 101): {tot} checked, disagreements between Z_101 and N: {bad}')
print('conflict structure: {step2,Q1} clean (rho_N model), {step2,Q2} clean (Z_N model), {step2,Q1,Q2} refuted (a6_noise_fallacy.py (4))')
