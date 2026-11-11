"""Checker, part B and C.
B: for every d up to the stated thresholds, c*K_lb/n >= beta_n (exact, integral form) at n = 2^d,
   so that no a in (0,1], t > 0, delta in (0,1) gives e > 0 there (as claimed in E §6 and §7 item 9).
   Also: the first-positive e values just past each threshold, at higher precision.
C: do other sample sizes n = lambda*2^d (lambda != 1) give e > 0 at d below the n = 2^d thresholds?
   This bears on the unqualified wording in E §0 Answers (1) ("Theorem 5.2 certifies no excess at
   any d <= 172") and §0 row 7 ("at no d <= 172").
"""
import sys
sys.path.insert(0, '.')
from mpmath import mp, mpf, sqrt, log, exp
from indep_excess import beta_lam, beta_n_int, consts, e_thm52, e_schedule

mp.dps = 60

print('Part B: c*K_lb/n >= beta_n (exact) at n = 2^d')
for H, th, thr in [(2, '0.55', 172), (2, '0.6', 80), (3, '0.36', 293)]:
    ok_upto = None
    margins = []
    for d in range(1, thr + 2):
        M = mpf(2) ** d
        n = M
        c = n ** (1 - mpf(th))
        _, Klb = consts(d, n, mpf(1), H)
        bn = beta_n_int(n, M)
        lhs = c * Klb / n
        if lhs >= bn:
            ok_upto = d
            margins.append((d, float(lhs - bn)))
        else:
            break
    print(f' H={H} theta={th}: holds for every d <= {ok_upto} (first failure at d={d}); '
          f'margin at d={ok_upto}: {margins[-1][1]:.4f}; min margin over d<= {ok_upto}: {min(m for _, m in margins):.4f}')
    for dd in (thr + 1, thr + 2):
        print(f'   schedule e at d={dd}: {float(e_schedule(dd, H, th)):.3e}')

print('\nPart C: best certified e over lambda (n = round(lambda 2^d)), a on a log grid, t = 1e-6, delta = 0.01,')
print('        beta_n >= beta(lambda) - n/M^2 (A Lemma 4.3(c)); first d at which some lambda gives e > 0')
import math
lams = [mpf(10) ** (k / mpf(20)) for k in range(-80, 21)]   # 1e-4 .. 10
agrid = [mpf(10) ** (-k / mpf(4)) for k in range(0, 4 * 40)]  # 1 .. 1e-40


def best_e(d, H, th, lndel=log(100)):
    M = mpf(2) ** d
    best = (mpf(0), None, None)
    for lam in lams:
        n = mpf(round(float(lam * M))) if d < 900 else lam * M
        if n < 1:
            continue
        lam_ = n / M
        c = n ** (1 - mpf(th))
        bn = beta_lam(lam_) - n / M ** 2
        for a in agrid:
            e = e_thm52(d, n, H, c, a, mpf('1e-6'), lndel, bn)
            if e > best[0]:
                best = (e, lam_, a)
    return best

for H, th, thr in [(2, '0.55', 172), (2, '0.6', 80), (3, '0.36', 293)]:
    first = None
    for d in range(max(2, thr - 60), thr + 1):
        e, lam_, a = best_e(d, H, th)
        if e > 0:
            first = (d, e, lam_, a)
            break
    if first:
        d, e, lam_, a = first
        print(f' H={H} theta={th}: first d with some lambda giving e>0 (delta=0.01): d={d}, e={float(e):.3e}, '
              f'lambda={float(lam_):.3g}, a={float(a):.2e}  (n=2^d threshold: first positive at d={thr+1})')
        e2, l2, a2 = best_e(thr, H, th)
        print(f'   at d={thr}: best e={float(e2):.3e} at lambda={float(l2) if l2 else None}')
    else:
        print(f' H={H} theta={th}: no lambda gives e>0 for d in [{max(2, thr-60)},{thr}]')
