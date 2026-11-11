"""Scope checks for E-finite-prior-scale.md (adversarial scope referee).

Part 1. Size of the proven positive threshold theta_{L,gamma} (Theorem 2.7) relative to 1/H, to judge
        the summaries "the picture is the same" / "smaller, but positive".
Part 2. Degrees D_T, D_H of the imported mean-field cover (I3) and the gamma = 1 exponent 1/D_H.
Part 3. Width threshold N_*(d, 2^d, a_d, H) of Proposition 4.4 along Corollary 5.3's schedule
        (c = 1, a_d = 2^{-d/3}); its degree log N_* / log n, and the check N_* >= 2^d used in Remark 5.4a.
Part 4. Certified excess e of Theorem 5.2 for c = n^{1-theta}, theta > 1/H, at n = 2^d (lambda = 1),
        with a optimised on a grid, to see from which d the failure "theta > 1/H" of the phase diagram
        (Section 6, Section 0 row 7) is actually certified.  delta = delta_d = exp(-2^{d/2}) as in
        Corollary 5.3, and also delta = 0.01.
All formulas are copied from E Proposition 4.4, Theorem 5.2 and Corollary 5.3; logs are used to avoid overflow.
"""
from mpmath import mp, mpf, log, sqrt, exp
mp.dps = 50

# ---------------- Part 1 ----------------
def theta_Lg(H, g):
    if H == 1:
        return mpf(1)
    L = H + 1
    if g == 1:
        return mpf(1) / (4 + 16 * (L - 2) * 3 ** (L - 2))
    if g >= 2 - mpf(1) / H:
        return mpf(1) / H
    return max((g - 1) / (g * H - 1), (g - 1) / (H * (H - 1) * (2 - g)))

print("Part 1: theta_{L,gamma} and its ratio to the strong-prior threshold 1/H")
print(" H  gamma     theta_{L,gamma}   (1/H)/theta")
for H in [2, 3, 4, 5]:
    for g in [mpf(1), mpf('1.01'), mpf('1.1'), mpf('1.25'), mpf('1.5'), 2 - mpf(1) / H]:
        th = theta_Lg(H, g)
        print(f" {H}  {float(g):6.4f}   {float(th):.6f}        {float((mpf(1)/H)/th):8.1f}")
# fine grid check that theta < 1/H strictly on (1, 2-1/H)
worst = {}
for H in [2, 3, 4, 5, 6]:
    m = mpf(0)
    for k in range(1, 4000):
        g = 1 + (1 - mpf(1) / H) * mpf(k) / 4000
        if g >= 2 - mpf(1) / H:
            break
        m = max(m, theta_Lg(H, g) * H)
    worst[H] = float(m)
print(" max of H*theta_{L,gamma} over a grid of (1, 2-1/H):", worst, "(must be < 1)")

# ---------------- Part 2 ----------------
print("\nPart 2: degrees of the mean-field cover (I3)")
for L in [3, 4, 5, 6]:
    DT = 4 * 3 ** (L - 1)
    DH = 4 + 16 * (L - 2) * 3 ** (L - 2)
    print(f" L={L}: D_T={DT}, D_H={DH}, 1/(D_T+1)={1/(DT+1):.5f}, 1/D_H={1/DH:.5f}, 1/H={1/(L-1):.4f}, ratio (1/H)/(1/D_H)={DH/(L-1):.1f}")

# ---------------- Part 3 ----------------
def consts(d, logs, a, H):
    """Return (log K_rob, log N_*) for s = exp(logs); a is an mpf in (0,1]."""
    d = mpf(d)
    Pimin = mpf(3) ** (-(mpf(H) - 1) / 2)
    Sb = 1 / Pimin + mpf(1) / 4
    logAmax = log(2) + (log(2) + log(d) + logs) / 2 + log(1 / Pimin)   # A_max = 2 sqrt(2 d s) 3^{(H-1)/2}
    ad = log(4 * sqrt(2 * d)) / 2
    alpha = 2 + max(ad, log(256 * H * Sb / a) / 2)
    R2 = max(exp(2 * logAmax / H), 128 * H ** 2 * Sb ** 3 / a, mpf(4))
    K = d * (d + 1) * alpha ** 2 + (H + 1) * R2
    R = sqrt(R2)
    ld = (d + 1) * log(2) + log(8 * H)
    u0 = min(a / (16 * R ** (H - 1)), a / (32 * H ** 2 * Sb))
    Amax2 = exp(2 * logAmax)
    mf = 128 * log(2) * Amax2 * (d + 1) / a ** 2 + 1
    Ns = max(mf, 256 * Amax2 * ld / a ** 2, 512 * H ** 2 * Sb ** 2 * ld / a ** 2, 2 * ld / u0 ** 2)
    return K, Ns

print("\nPart 3: N_*(d, 2^d, a_d, H) at c = 1, a_d = 2^{-d/3} (Corollary 5.3 schedule)")
print(" H    d   log10 n   log10 N_*   log N_*/log n   N_* >= 2^d ?")
for H in [2, 3, 4, 6]:
    for d in [30, 60, 120, 400, 1000]:
        logn = d * log(2)
        a = exp(-logn / 3)
        K, Ns = consts(d, logn, a, H)
        print(f" {H}  {d:4d}   {float(logn/log(10)):7.1f}   {float(log(Ns)/log(10)):9.1f}   {float(log(Ns)/logn):8.3f}        {bool(Ns >= exp(logn))}")

# ---------------- Part 4 ----------------
def beta_poisson(lam):
    s, term = mpf(0), mpf(1)
    for k in range(1, 400):
        term *= lam / k
        s += term / k
    return exp(-lam) * s

def certified_e(d, H, theta, delta_mode):
    """Certified e of Theorem 5.2 at n = M = 2^d, c = n^{1-theta}, t = 1, best a on a log grid."""
    logM = d * log(2)
    lam = mpf(1)
    bn = beta_poisson(lam) - exp(-logM)            # beta_n >= beta(lambda) - n/M^2, n = M
    if delta_mode == 'delta_d':
        log1d = exp(d * log(2) / 2)                # ln(1/delta_d) = 2^{d/2}
    else:
        log1d = log(100)
    dev = sqrt(2 * lam * log1d / exp(logM))
    base = bn - dev
    if base <= 0:
        return mpf(0), None
    best, besta = mpf(0), None
    logc = (1 - theta) * logM
    for k in range(0, 1201):
        a = exp(-mpf(k) / 10)                      # a from 1 down to e^{-120}
        K, _ = consts(d, logM, a, H)
        eps = lam * (a ** 2 + exp(logc - logM) * (K + 2))
        e = sqrt(base) - sqrt(eps)
        e = e * e if e > 0 else mpf(0)
        if e > best:
            best, besta = e, a
    return best, besta

print("\nPart 4: certified excess e of Theorem 5.2 for c = n^{1-theta}, n = 2^d (lambda = 1, beta(1) = 0.4848)")
print(" H  theta    d    e (delta=0.01)   e (delta_d = exp(-2^{d/2}))   a* (delta=0.01)")
for H, thetas in [(2, ['0.55', '0.6', '0.75', '1.0']), (3, ['0.36', '0.4', '0.5'])]:
    for th in thetas:
        theta = mpf(th)
        for d in [30, 50, 100, 200, 400, 800]:
            e1, a1 = certified_e(d, H, theta, '0.01')
            e2, _ = certified_e(d, H, theta, 'delta_d')
            astr = f"{float(a1):.3g}" if a1 is not None else "-"
            print(f" {H}  {th:5s}  {d:4d}    {float(e1):.4f}            {float(e2):.4f}                  {astr}")
# also c = 1 for reference
print(" reference c = 1:")
for H in [2, 3]:
    for d in [30, 40, 60]:
        e1, a1 = certified_e(d, H, mpf(1), '0.01')
        print(f" {H}  c=1    {d:4d}    {float(e1):.4f}")

# Part 4b: the same at Corollary 5.3's own accuracy schedule a_d = (max{c_d,1}/2^d)^{1/3}, delta = delta_d,
# which is the schedule under which Corollary 5.4 / Remark 5.4a are stated.
def e_at_ad(d, H, theta):
    logM = d * log(2)
    lam = mpf(1)
    bn = beta_poisson(lam) - exp(-logM)
    dev = sqrt(2 * lam * exp(d * log(2) / 2) / exp(logM))
    base = bn - dev
    logc = (1 - theta) * logM
    a = exp((max(logc, mpf(0)) - logM) / 3)
    K, Ns = consts(d, logM, a, H)
    eps = lam * (a ** 2 + exp(logc - logM) * (K + 2))
    e = sqrt(base) - sqrt(eps)
    e = e * e if e > 0 else mpf(0)
    return e, a, Ns

print("\nPart 4b: e at Corollary 5.3's schedule a_d, delta_d (n = 2^d, lambda = 1)")
print(" H  theta    d     a_d        e          log10 N_*")
for H, thetas in [(2, ['0.55', '0.6', '0.75', '1.0']), (3, ['0.36', '0.4', '0.5', '1.0'])]:
    for th in thetas:
        for d in [30, 50, 100, 200, 400, 800, 1600]:
            e, a, Ns = e_at_ad(d, H, mpf(th))
            print(f" {H}  {th:5s}  {d:4d}   {float(a):.3e}   {float(e):.4f}     {float(log(Ns)/log(10)):.1f}")
