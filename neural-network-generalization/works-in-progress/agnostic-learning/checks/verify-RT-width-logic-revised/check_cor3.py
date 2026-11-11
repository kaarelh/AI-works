# Independent check of RT-width.fixed.md, Corollary 3 / (5.1) / (5.2), Remark 5, Remark 8.
# Everything is coded from the definitions in Section 1 of the note, not from the author's script.
import random
import mpmath as mp

mp.mp.dps = 60
random.seed(12345)

def quantities(n, H, d, N, Bbar, delta, c=1):
    n = mp.mpf(n); d = mp.mpf(d); N = mp.mpf(N); Bbar = mp.mpf(Bbar); delta = mp.mpf(delta)
    L = H + 1
    K = n / c + 1
    P = N * (d + 1) + (H - 1) * N**2 + N
    Lam = mp.log(2 + 2 * n * mp.sqrt(K * N) * H * (d + N + 1) * (K + 1) ** (mp.mpf(H) / 2))
    ell = mp.log(4 / delta)
    Dev = 4 * mp.sqrt((P * Lam + ell) / (2 * n))
    Ubar = N * Bbar                     # competitor width bound = learner width N (Corollary 3)
    Estar = d * (d + 1) * Bbar**2 + 2 * (L - 1) * N**2 * Bbar**2
    Exc = c * (Estar + 1) / n + 4 / n + Dev + (Ubar + 1) * mp.sqrt(2 * ell / n) + 2 * (Ubar + 1) ** 2 * ell / (3 * n)
    return dict(K=K, P=P, Lam=Lam, ell=ell, Dev=Dev, Ubar=Ubar, Estar=Estar, Exc=Exc, L=L)

def bound52(n, H, alpha, Bbar, delta):
    n = mp.mpf(n); Bbar = mp.mpf(Bbar); ell = mp.log(4 / mp.mpf(delta)); L = H + 1
    return (5 * mp.sqrt(2) * Bbar * n ** (alpha - mp.mpf(1) / 2) * mp.sqrt(ell)
            + 4 * mp.sqrt((2 * H + 1) * (H + 5)) * n ** (alpha - mp.mpf(1) / 2) * mp.sqrt(mp.log(2 * n))
            + (8 * L - 1) * (1 + ell) * Bbar**2 * n ** (2 * alpha - 1))

# ---------------------------------------------------------------------------
# (1) Exc <= (5.2) on random admissible parameters, including edge cases
worst = mp.mpf(0); worst_case = None
worst_lam = mp.mpf(0); min_lam_low = mp.mpf(10)
count = 0
for trial in range(40000):
    # n from 2 to 1e200 (log-uniform), with extra mass on tiny n
    if trial % 5 == 0:
        n = random.randint(2, 60)
    else:
        n = int(mp.floor(mp.power(10, random.uniform(0.31, 200))))
    alpha = random.choice([0.0, 1e-6, random.uniform(0, 0.5 - 1e-9), 0.5 - 1e-9])
    H = random.randint(1, 10)
    nu = mp.power(n, alpha)
    dmax = int(mp.floor(nu)); Nmax = int(mp.floor(2 * nu))
    if dmax < 1 or Nmax < 1:
        continue
    d = random.choice([1, dmax, max(1, int(random.uniform(1, float(min(dmax, 10**30)))))])
    d = min(d, dmax)
    N = random.choice([1, Nmax, max(1, int(random.uniform(1, float(min(Nmax, 10**30)))))])
    N = min(N, Nmax)
    Bbar = random.choice([1, float(nu), float(mp.power(n, random.uniform(0, 0.6))), random.uniform(1, 1e3)])
    delta = random.choice([1e-12, 1e-3, 0.05, 0.5, 0.999])
    q = quantities(n, H, d, N, Bbar, delta)
    b = bound52(n, H, alpha, Bbar, delta)
    r = q['Exc'] / b
    count += 1
    if r > worst:
        worst = r; worst_case = (n if n < 10**6 else '1e%d' % int(mp.log10(n)), alpha, H, d if d < 10**6 else 'big', N if N < 10**6 else 'big', Bbar, delta)
    lam_ratio = q['Lam'] / ((H + 5) * mp.log(2 * n))
    worst_lam = max(worst_lam, lam_ratio)
    min_lam_low = min(min_lam_low, q['Lam'] / mp.log(2 * n))
print("(1) admissible cases checked:", count)
print("    max Exc/(5.2) = %s  at %s" % (mp.nstr(worst, 6), worst_case))
print("    max Lambda_N/((H+5)ln 2n) = %s   (Corollary 3 step 4 needs <= 1)" % mp.nstr(worst_lam, 6))
print("    min Lambda_N/ln(2n) = %s   (Remark 8 uses Lambda_N >= ln 2n)" % mp.nstr(min_lam_low, 6))

# ---------------------------------------------------------------------------
# (2) Remark 5: n^{2a} <= Ubar+1 <= 3 n^{2a} for N = ceil(n^a), Bbar = n^a
bad = 0
for n in [2, 3, 7, 10, 100, 10**4, 10**9, 10**30]:
    for alpha in [0.01, 0.1, 0.124, 0.2, 0.2499]:
        nu = mp.power(n, alpha); N = mp.ceil(nu); U1 = N * nu + 1
        if not (nu**2 <= U1 <= 3 * nu**2):
            bad += 1
print("(2) Remark 5 sandwich n^{2a} <= Ubar+1 <= 3n^{2a}: violations =", bad)

# ---------------------------------------------------------------------------
# (3) Remark 8: Dev_N >= 4 once N >= sqrt(2n/((H-1) ln 2n)); and Dev_N -> 0 when N(N+d) ln n = o(n)
viol = 0
for n in [10**3, 10**6, 10**9, 10**15]:
    for H in [2, 3, 5]:
        d = int(mp.log(n, 2))
        Nthr = int(mp.ceil(mp.sqrt(2 * n / ((H - 1) * mp.log(2 * n)))))
        q = quantities(n, H, d, Nthr, 0, 0.5)
        if q['Dev'] < 4:
            viol += 1
print("(3) Remark 8 vacuity threshold: cases with Dev_N < 4 at the threshold width =", viol)
print("    cube family, zero competitor, H=2: Dev_N at N = 0.02*sqrt(n/ln n):")
for n in [10**6, 10**9, 10**12, 10**20, 10**40]:
    d = int(mp.log(n, 2)); N = max(1, int(0.02 * mp.sqrt(n / mp.log(n))))
    q = quantities(n, 2, d, N, 0, 0.05)
    print("      n=1e%-3d N=%-14d Dev=%s" % (int(mp.log10(n)), N, mp.nstr(q['Dev'], 4)))
