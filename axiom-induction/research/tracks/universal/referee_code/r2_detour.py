"""Referee check r2: the Remark after Prop U3 and open problem 1 of notes.md.

Calculus C_and = {cite (p_c), forall-elim (c), and-intro (a), and-elim (e, side L/R with prob 1/2)}, where
and-intro and and-elim accept QUANTIFIED formulas (outside the hypotheses of U3).  phi = 0+x=x (atomic),
numeral term law, theories {forall x phi} and {sigma_phi}.  B is empty, so P^0 = 0 and U3's inequality would
read P_forall(phi(t)) <= c * P_sigma(phi(t)).  The notes conjecture that detours "cannot" make it fail.

Analytic claim (derived in referee.md, "spine" decomposition): every successful derivation has a root spine that
is a Dyck word in (and-elim, and-intro) steps followed by a base node (cite, elim, or a top-level and-intro).
With x = e*a*Z_T and D(x) = (1 - sqrt(1-4x))/(2x) (Catalan generating function),
   Z_T = D_T * (p_c + c*P_U + a*Z_T^2),   P_U = D_T*p_c for {forall x phi}, 0 for {sigma_phi},
   P_forall(phi(t)) = c * D_forall^2 * p_c * Q(t),   P_sigma(phi(t)) = D_sigma * p_c * Q(t).
So the per-instance ratio is R = c * D_forall^2 / D_sigma, which exceeds c whenever a, e > 0.

Checks: (1) the analytic forms against an independent Monte Carlo sampler of the grammar;
(2) R > c (U3's factor fails) and R < 1 (the direction of Thm B survives) on a parameter grid, both for the
unnormalised and the normalised (L1-norm) likelihood.  Seeded.  Output: r2_detour.out"""
import math
import random
from collections import Counter

OUT = []


def say(s=''):
    print(s)
    OUT.append(s)


def D(x):
    if x == 0:
        return 1.0
    assert 4 * x <= 1 + 1e-12, x
    return (1 - math.sqrt(max(0.0, 1 - 4 * x))) / (2 * x)


def analytic(pc, c, a, e, theory):
    Z = 0.0
    for _ in range(100000):
        d = D(e * a * Z)
        PU = d * pc if theory == 'forall' else 0.0
        Zn = d * (pc + c * PU + a * Z * Z)
        if abs(Zn - Z) < 1e-15:
            break
        Z = Zn
    d = D(e * a * Z)
    PU = d * pc if theory == 'forall' else 0.0
    PI = c * d * PU if theory == 'forall' else d * pc
    return Z, d, PI


q = 0.5


def qsample(rng):
    k = 0
    while rng.random() < q:
        k += 1
    return k


def sample(theory, pc, c, a, e, rng, budget):
    """formulas: ('ALL',) for forall x phi; ('I', k) for 0+S^k0 = S^k0; ('AND', A, B).
    Returns a formula or None (failure).  budget: list with remaining node count (truncation)."""
    budget[0] -= 1
    if budget[0] < 0:
        raise OverflowError
    u = rng.random()
    if u < pc:
        return ('ALL',) if theory == 'forall' else ('I', qsample(rng))
    if u < pc + c:
        p = sample(theory, pc, c, a, e, rng, budget)
        if p is None or p[0] != 'ALL':
            return None
        return ('I', qsample(rng))
    if u < pc + c + a:
        l = sample(theory, pc, c, a, e, rng, budget)
        if l is None:
            return None
        r = sample(theory, pc, c, a, e, rng, budget)
        if r is None:
            return None
        return ('AND', l, r)
    p = sample(theory, pc, c, a, e, rng, budget)
    if p is None or p[0] != 'AND':
        return None
    return p[1] if rng.random() < 0.5 else p[2]


def mc(theory, pc, c, a, e, N, seed):
    rng = random.Random(seed)
    succ = inst = trunc = 0
    ks = Counter()
    for _ in range(N):
        try:
            f = sample(theory, pc, c, a, e, rng, [5000])
        except OverflowError:
            trunc += 1
            continue
        if f is None:
            continue
        succ += 1
        if f[0] == 'I':
            inst += 1
            ks[f[1]] += 1
    return succ / N, inst / N, trunc, ks


def main():
    import sys
    sys.setrecursionlimit(20000)
    say('r2_detour: calculus {cite, forall-elim, and-intro, and-elim} with and-rules on quantified formulas')
    say('(1) analytic spine formulas against Monte Carlo (N = 400000 derivations per theory)')
    for (pc, c, a, e) in [(0.3, 0.3, 0.2, 0.2), (0.35, 0.15, 0.25, 0.25), (0.4, 0.4, 0.1, 0.1)]:
        say('  p_c=%.2f c=%.2f a=%.2f e=%.2f (mean offspring %.2f)' % (pc, c, a, e, c + e + 2 * a))
        res = {}
        for th in ['forall', 'sigma']:
            Z, d, PI = analytic(pc, c, a, e, th)
            N = 400000
            zf, pif, tr, ks = mc(th, pc, c, a, e, N, 11 if th == 'forall' else 12)
            zz = (zf - Z) / math.sqrt(Z * (1 - Z) / N)
            zi = (pif - PI) / math.sqrt(PI * (1 - PI) / N)
            # instance term law should be Q within instances
            n_i = sum(ks.values())
            chi = sum((ks[k] - n_i * (1 - q) * q ** k) ** 2 / (n_i * (1 - q) * q ** k) for k in range(6))
            say('    %-6s Z: exact %.5f MC %.5f (z %+.2f) | P(instance): exact %.5f MC %.5f (z %+.2f) | D = %.5f | '
                'truncated %d | chi2(6 cells, instance term law = Q) %.1f' % (th, Z, zf, zz, PI, pif, zi, d, tr, chi))
            res[th] = (Z, d, PI)
        R = res['forall'][2] / res['sigma'][2]
        Rn = R * res['sigma'][0] / res['forall'][0]
        say('    per-instance ratio P_forall/P_sigma: R = %.5f  (c = %.2f; U3 would need R <= c);  '
            'normalised R_norm = %.5f' % (R, c, Rn))
    say('')
    say('(2) grid over (p_c, c, a, e), step 0.025, all positive, sum 1')
    best_R = (0, None)
    best_excess = (0, None)
    best_Rn = (0, None)
    n = 0
    viol_c = 0
    s = 0.025
    steps = int(round(1 / s))
    for i in range(1, steps):
        for j in range(1, steps - i):
            for k in range(1, steps - i - j):
                l = steps - i - j - k
                if l < 1:
                    continue
                pc, c, a, e = i * s, j * s, k * s, l * s
                Zf, df, PIf = analytic(pc, c, a, e, 'forall')
                Zs, ds, PIs = analytic(pc, c, a, e, 'sigma')
                R = PIf / PIs
                Rn = R * Zs / Zf
                n += 1
                if R > c + 1e-12:
                    viol_c += 1
                if R > best_R[0]:
                    best_R = (R, (pc, c, a, e))
                if R / c > best_excess[0]:
                    best_excess = (R / c, (pc, c, a, e))
                if Rn > best_Rn[0]:
                    best_Rn = (Rn, (pc, c, a, e))
    say('  %d parameter points; R > c (U3 factor fails) at %d of them' % (n, viol_c))
    say('  max R = %.4f at (p_c, c, a, e) = %s   [R < 1: direction of Thm B survives]' % best_R)
    say('  max R/c = %.4f at %s' % best_excess)
    say('  max normalised ratio R_norm = %.4f at %s' % best_Rn)
    say('')
    pc, c, a, e = 0.35, 0.15, 0.25, 0.25
    N = 2000000
    say('(3) direct Monte Carlo test of R > c at (p_c, c, a, e) = (%.2f, %.2f, %.2f, %.2f), N = %d per theory'
        % (pc, c, a, e, N))
    _, pf, _, _ = mc('forall', pc, c, a, e, N, 31)
    _, ps, _, _ = mc('sigma', pc, c, a, e, N, 32)
    Rmc = pf / ps
    se = Rmc * math.sqrt((1 - pf) / (pf * N) + (1 - ps) / (ps * N))
    say('    MC ratio of instance masses R = %.5f +- %.5f; analytic %.5f; c = %.2f; (R - c)/se = %.1f'
        % (Rmc, se, analytic(pc, c, a, e, 'forall')[2] / analytic(pc, c, a, e, 'sigma')[2], c, (Rmc - c) / se))
    open('r2_detour.out', 'w').write('\n'.join(OUT) + '\n')


if __name__ == '__main__':
    main()
