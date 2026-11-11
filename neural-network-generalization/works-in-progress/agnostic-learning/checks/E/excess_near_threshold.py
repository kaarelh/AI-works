"""Certified excess e of E-finite-prior-scale.md Theorem 5.2 for c = n^{1-theta} with theta slightly above 1/H,
along n = 2^d (lambda = 1): from which d does Theorem 5.2 certify the failure theta > 1/H of the phase diagram (Section 6)?
Added after the scope report (../../verification/E-scope.md, issue 8).  The formulas are typed from the note, not from the
referee's script: K_rob of Proposition 4.4, eta, eps_fs and e of Theorem 5.2, and the schedule of Corollary 5.3
(a_d = (max{c_d,1}/2^d)^{1/3}, t = 1, delta_d = exp(-2^{d/2})).

Part 1. e along Corollary 5.3's schedule at every d = 2..1600, with beta_n replaced by its lower bound beta(1) - n/M^2,
        as in Table 7.1 (Section 7, item 7): the largest d with e = 0, and e at selected d.
Part 2. A bound valid for every accuracy a: since alpha >= 2 + alpha_d and R^2 >= A_max^{2/H},
        K_rob >= K_lb := d(d+1)(2+alpha_d)^2 + (H+1) A_max^{2/H}, so eps_fs >= c K_lb / n for every a and t > 0, while
        the base of e is at most beta_n for every delta.  Where c K_lb / n >= beta_n (computed exactly), e = 0 for every
        choice of a, t and delta.
Part 3. Agreement with the values printed by the scope referee's script (../verify-E-scope/scope_numbers.out, Part 4b).
"""
import os
from mpmath import mp, mpf, sqrt, log, exp, log1p, factorial, nsum, inf

mp.dps = 80
BETA1 = exp(-1) * nsum(lambda k: 1 / (k * factorial(k)), [1, inf])   # beta(1) = E[1/K; K>=1], K ~ Poisson(1)


def k_rob(d, s, a, H):
    """K_rob(d, s, a, H) of Proposition 4.4."""
    d, s, a = mpf(d), mpf(s), mpf(a)
    sbar = mpf(3) ** ((H - 1) / mpf(2)) + mpf(1) / 4
    amax = 2 * sqrt(2 * d * s) * mpf(3) ** ((H - 1) / mpf(2))
    alpha_d = log(4 * sqrt(2 * d)) / 2
    alpha = 2 + max(alpha_d, log(256 * H * sbar / a) / 2)
    R = max(amax ** (mpf(1) / H), sqrt(128 * H**2 * sbar**3 / a), mpf(2))
    return d * (d + 1) * alpha**2 + (H + 1) * R**2


def k_lower(d, s, H):
    """Lower bound on K_rob(d, s, a, H) valid for every a in (0,1]."""
    d, s = mpf(d), mpf(s)
    amax = 2 * sqrt(2 * d * s) * mpf(3) ** ((H - 1) / mpf(2))
    alpha_d = log(4 * sqrt(2 * d)) / 2
    return d * (d + 1) * (2 + alpha_d) ** 2 + (H + 1) * amax ** (mpf(2) / H)


def beta_n_exact(d):
    """beta_n = E[1/K; K>=1] for K ~ Bin(n, 1/M), n = M = 2^d; C(n,k) M^{-k} = prod_{j<k}(1 - j/n) / k!."""
    n = mpf(2) ** d
    s, prod, lq = mpf(0), mpf(1), log1p(-1 / n)
    for k in range(1, 400):
        prod *= 1 - mpf(k - 1) / n
        s += prod / factorial(k) * exp((n - k) * lq) / k
    return s


def e_schedule(d, H, theta):
    """Certified e of Theorem 5.2 at n = M = 2^d, c = n^{1-theta}, a = a_d, t = 1, delta = delta_d (Corollary 5.3)."""
    M = mpf(2) ** d
    n, lam = M, mpf(1)
    c = n ** (1 - mpf(theta))
    a = (max(c, mpf(1)) / M) ** (mpf(1) / 3)
    eta = a**2 + c * (k_rob(d, min(n, M), a, H) + 2) / n
    base = BETA1 - n / M**2 - sqrt(2 * lam * mpf(2) ** (mpf(d) / 2) / M)   # ln(1/delta_d) = 2^{d/2}
    if base <= 0:
        return mpf(0), a
    r = sqrt(base) - sqrt(lam * eta)
    return (r * r if r > 0 else mpf(0)), a


CASES = [(2, '0.55'), (2, '0.6'), (3, '0.36')]
SHOW = [100, 150, 200, 300, 400, 800, 1600]

print(f"beta(1) = {float(BETA1):.6f}")
print("\nPart 1: e along Corollary 5.3's schedule (n = 2^d, a = a_d, t = 1, delta = delta_d)")
last_zero = {}
for H, th in CASES:
    vals = {d: e_schedule(d, H, th)[0] for d in range(2, 1601)}
    lz = max(d for d, e in vals.items() if e == 0)
    last_zero[(H, th)] = lz
    nondecr = all(vals[d + 1] >= vals[d] for d in range(lz, 1600))
    print(f" H={H} theta={th}: e = 0 at every d <= {lz}, e > 0 at every d in [{lz + 1}, 1600],"
          f" nondecreasing there: {nondecr}")
    print("   " + ", ".join(f"d={d}: {float(vals[d]):.4f}" for d in SHOW))

print("\nPart 2: e = 0 for every a, t > 0 and delta, where c K_lb / n >= beta_n (exact)")
for H, th in CASES:
    holds_to = None
    for d in range(2, last_zero[(H, th)] + 2):
        n = mpf(2) ** d
        if n ** (1 - mpf(th)) * k_lower(d, n, H) / n >= beta_n_exact(d):
            holds_to = d
        else:
            break
    print(f" H={H} theta={th}: c K_lb/n >= beta_n at every d <= {holds_to}; first d where it fails: {d}")

print("\nPart 3: comparison with ../verify-E-scope/scope_numbers.out, Part 4b (as printed)")
ref = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'verify-E-scope', 'scope_numbers.out')
rows, inside = [], False
with open(ref) as f:
    for line in f:
        if line.startswith('Part 4b'):
            inside = True
            continue
        parts = line.split()
        if inside and len(parts) == 6 and parts[0].isdigit():
            rows.append((int(parts[0]), parts[1], int(parts[2]), float(parts[3]), float(parts[4])))
maxdiff_e, maxrel_a = 0.0, 0.0
for H, th, d, a_ref, e_ref in rows:
    e, a = e_schedule(d, H, th)
    maxdiff_e = max(maxdiff_e, abs(round(float(e), 4) - e_ref))
    maxrel_a = max(maxrel_a, abs(float(a) - a_ref) / a_ref)
print(f" {len(rows)} rows compared; max |e (rounded to 4 decimals) - printed e| = {maxdiff_e:.1e};"
      f" max relative difference in a_d = {maxrel_a:.1e} (printed to 4 significant digits)")
