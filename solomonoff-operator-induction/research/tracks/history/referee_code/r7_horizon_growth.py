"""r7 (referee): follow-up to r6.  Does the excess of the horizon-free minimax value over the
horizon-specific ones grow with the number of horizons?  For random non-peeking Delta and random P on
X = {0,1,2}, Y = {0,1}, compute certified brackets of
    V_joint(N) := min_G max_{n <= N} max_f [E_{x|f}[-log2 G(D_n)] - E_{x|f}[L_P^{(n)}]],   N = 1..6.
(Each single-horizon value V_n is <= 0 by Thm 3.8's minimax step.)  A slowly growing V_joint(N) would be
weak evidence that some horizon-dependent term is needed; a bounded one is weak evidence against.
Small worlds only; this is exploratory and proves nothing about the asymptotic question Q1.
Seed 707.  Output: r7_horizon_growth.out.
"""
import itertools, math
import numpy as np
import r6_horizon_free as base  # reuses the bracket machinery (its own seeded instances are not used)

rng = np.random.default_rng(707)
NMAX = 6
X, Y = base.X, base.Y
H = {k: list(itertools.product(itertools.product(X, Y), repeat=k)) for k in range(NMAX + 1)}

def rand_Delta():
    return {h: rng.dirichlet(np.ones(len(X)) * 0.6) for k in range(NMAX) for h in H[k]}

def rand_P():
    return {(h, x): rng.dirichlet(np.ones(len(Y)) * 0.6) for k in range(NMAX) for h in H[k] for x in X}

for inst in range(3):
    D, P = rand_Delta(), rand_P()
    per = [base.rows_for(D, P, n) for n in range(1, NMAX + 1)]
    out = []
    for N in range(1, NMAX + 1):
        rows = [row for r in per[:N] for row in r]
        lo, up = base.bracket(rows, T=400)
        out.append(f"N={N}: [{lo:+.4f},{up:+.4f}]")
    print(f"inst {inst}: V_joint(N) brackets  " + "  ".join(out))
