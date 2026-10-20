"""Constants of the typical-sample sign-only theorem (Theorem 6.13) with the Lean coercivity budget.

The proof of the theorem (paper, Section 6.5) takes its coercivity input from the Lean theorem
`parity_squared_coercivity_probability` (lean/NeuralGeneralization/ParitySquaredSampling.lean):
if 64 r <= d and
    B(d, r, n) = 2^76 D_r (log(8 n) + ceil(log2 D_r) + 1) <= n,     D_r = sum_{q<=r} binom(d, q),
then n iid uniform points satisfy the squared coercivity event with probability >= 15/16.
The adaptive cutoff is the largest odd r with B(d, r, n) <= n, and the proof uses
    n / binom(D, r+2) < 2^77 Lambda_r,   Lambda_r = 120 + 7 (r+2) log(e d/(r+2)).
All constants of the theorem are therefore explicit.  This script evaluates them; it is a numerical
check of explicit inequalities, not part of any proof.

Part 1. The crossover d_x where n_max(d) = n_0(d); Regime II of the proof is empty below it.
Part 2. For L = 2 and seven first-layer gains, the conditions (L1)-(L8) of Section 6.5, scanned in
        log d with step 0.05.  For each condition we report the last scanned log d at which it
        fails; above it the condition holds at every scanned point.  Above log d = 690 only (L8b),
        the product condition J_d r_d <= pi/(256 e^2), is evaluated: it is the only condition that
        fails there, and every other condition holds with a margin that grows with d.
        At sigma_1 = 1 the part also prints J_d / log d at a few d; T_d, its leading term
        (1/2) log(1 + 4/eta) log d / log log d and the two logarithms that separate them, at
        d = 10^176 (paper, after Lemma 6.15); and the last scanned log d at which (L8b) fails for
        the A_{1/8} route of Remark 6.16 with the hypothetical value A_{1/8} = 1 (paper, Remark
        6.17(2)).  In that route A_{1/8} replaces 2^77 in B_* and T_d.
Part 3. A direct evaluation, at grid dimensions, of the inequalities that Regime II actually uses,
        with the actual cutoff r(n), k*, u = r + 2k*, B_r and J of the proof in place of the
        uniform bounds of (L1)-(L8): an admissible r exists at n_0(d); 64 r <= d and
        r + 2 <= (d+1)/3; (u+2)/(D-u-1) <= 1.25 (r+2)/d; n/binom(D, u+2) < epsilon_0 for the
        largest n with this cutoff; u + 1 <= D/2; J <= e^2 u; e sqrt(J u/(pi d)) <= 1/16; and
        exp(-J d/(8 e^2 u))/2 <= 1/64.  For each grid d all odd r between r(n_0(d)) and
        r(n_max(d)) are checked if there are at most 4000 of them, otherwise 601 log-spaced values
        of r and their successors.  Numerical observation at grid points only.

Kernel inputs: eta(sigma_1) = 1/(6 (1 + pi/(2 sigma_1))^4) (Lemma 6.3) and, for L = 2,
c_1 = c_1(sigma_1^2) = sigma_1^2 (E sech^2(sigma_1 G))^2 / E tanh^2(sigma_1 G), by numerical
quadrature.  Requirements: Python 3 with mpmath.  Output: s1_constants.txt.
"""
import sys
from mpmath import mp, mpf, log, sqrt, exp, pi, e, ceil, floor, loggamma, quad, sech, tanh
from mpmath import inf as mpinf

mp.dps = 60
CT = sqrt(2*pi)*(exp(-1) - mpf(7)/20)           # c_theta
C2 = CT**2
C0 = 2 + 2/C2                                     # Theorem 3.2
EPS0 = 1/(64*(2 + 8/C2))                          # epsilon_0
CS = mpf('1e-3')                                  # c_*
A77 = mpf(2)**77
LOG2_76 = 76*log(2)
BSTAR = 32*((e - 1)*A77 + 1) + A77
SIGMAS = [8.0, 3.0, 2.0, 1.0, 0.5, 0.3, 0.2]


def c1_tanh(sigma):
    """c_1(sigma^2) = sigma^2 (E sech^2(sigma G))^2 / E tanh^2(sigma G) for tanh, by quadrature."""
    with mp.workdps(30):
        s = mpf(sigma)
        phi = lambda x: exp(-x*x/2)/sqrt(2*pi)
        pts = [-mpinf, -1, -mpf('0.1'), 0, mpf('0.1'), 1, mpinf]
        a = quad(lambda x: sech(s*x)**2*phi(x), pts)
        v = quad(lambda x: tanh(s*x)**2*phi(x), pts)
        return s*s*a*a/v


def eta(sigma):
    return 1/(6*(1 + pi/(2*mpf(sigma)))**4)


def logbinom(n, k):
    return loggamma(n + 1) - loggamma(k + 1) - loggamma(n - k + 1)


def logD(d, r):
    """log D_r = log sum_{q<=r} binom(d, q), for r < d/2 (geometric tail of the ratios)."""
    S = mpf(1); T = mpf(1); i = 0
    while i < r:
        T = T*(r - i)/(d - r + 1 + i)
        S += T; i += 1
        if T < mpf(10)**(-45):
            break
    return logbinom(d, r) + log(S)


def logB(d, r, logx):
    """log of the Lean budget B(d, r, x) at log x = logx."""
    lD = logD(d, r)
    ell = ceil(lD/log(2)) + 1                     # ceil(log2 D_r) + 1
    return LOG2_76 + lD + log(log(8) + logx + ell)


def log_threshold(d, r):
    """log N_r, where N_r >= 1 solves B(d, r, N_r) = N_r: r is admissible exactly for n >= N_r."""
    lD = logD(d, r)
    ell = ceil(lD/log(2)) + 1
    y = LOG2_76 + lD
    for _ in range(200):
        y_new = LOG2_76 + lD + log(log(8) + y + ell)
        if abs(y_new - y) < mpf(10)**(-30):
            break
        y = y_new
    return y_new


def largest_odd_r(d, logn, rmax):
    """Largest odd r <= rmax with B(d, r, n) <= n (monotone in r); None if r = 1 fails."""
    if logB(d, 1, logn) > logn:
        return None
    lo, hi = 0, (int(rmax) - 1)//2               # r = 2k+1
    while lo < hi:
        mid = (lo + hi + 1)//2
        if logB(d, 2*mid + 1, logn) <= logn:
            lo = mid
        else:
            hi = mid - 1
    return 2*lo + 1


def Lam(d, r):
    return 120 + 7*(r + 2)*log(e*d/(r + 2))


def Lamp(d, r, g, c1):
    return (r + 2)*log(e*(d + 1)/(r + 2)) + (r + 1)/2*log(1/g) + log(1/c1)


def Jd_rd(x, g):
    """J_d and r_d of Section 6.5 at x = log d."""
    Td = log(1 + 4/g)*(1 + (x + log(A77/EPS0))/(2*log(x/(mpf('1.3')*CS))))
    Jd = x + 1 + log(256*BSTAR/C2) + Td
    rd = mpf('1.1')*(CS/x + 2*exp(-x))
    return Jd, rd


def Jd_rd_route(x, g, A):
    """J_d and r_d at x = log d for the A_{1/8} route of Remark 6.16: A in place of 2^77 in B_*
    and T_d (r_d does not change)."""
    bstar = 32*((e - 1)*A + 1) + A
    Td = log(1 + 4/g)*(1 + (x + log(A/EPS0))/(2*log(x/(mpf('1.3')*CS))))
    Jd = x + 1 + log(256*bstar/C2) + Td
    rd = mpf('1.1')*(CS/x + 2*exp(-x))
    return Jd, rd


# ---------------------------------------------------------------- part 1: crossover
def logn0(d):
    t = floor(sqrt(d)/5)
    return logbinom(d, t) - log(23*C0)


def logn_max(d):
    x = log(d)
    return CS*d*log(x)/x


def crossover():
    lo, hi = mpf(8), mpf(9)
    for _ in range(80):
        m = (lo + hi)/2
        d = floor(mpf(10)**m)
        if logn_max(d) < logn0(d):
            lo = m
        else:
            hi = m
    return mpf(10)**hi


# ---------------------------------------------------------------- part 2: conditions (L1)-(L8)
def conditions_common(x):
    """(L1)-(L5) and (L7), which do not involve the gains.  Precision grows with d, since
    log binom(d, t) is a small difference of log-Gamma values."""
    with mp.workdps(int(max(60, x/log(10) + 40))):
        d = floor(exp(x))
        t = floor(sqrt(d)/5); kd = ceil(log(d))
        out = {}
        ln0 = logn0(d)
        out['L1'] = (t >= 4) and (ln0 >= 0) and (logB(d, t - 3, ln0) <= ln0)
        out['L2'] = (CS*d/log(d) + 2 <= min(d/64, (d + 1)/3)) and (ceil(CS*d/log(d)) <= d/e)
        out['L3'] = 2*kd <= mpf('0.1')*(t - 2)
        out['L4'] = mpf('1.1')*(CS*d/log(d) + 2) <= mpf('0.1')*d
        out['L5'] = (mpf('1.25')*(CS/log(d) + 2/d) <= mpf('1.3')*CS/log(d)) and \
            (log(log(d)/(mpf('1.3')*CS)) >= 1)
        out['L7'] = A77/EPS0 <= d
        return out


def conditions_gain(x, g, c1):
    """(L6) and (L8), which involve eta = eta(sigma_1) and c_1."""
    with mp.workdps(int(max(60, x/log(10) + 40))):
        d = floor(exp(x))
        t = floor(sqrt(d)/5)
        out = {}
        # (L6): both left sides increase in r; evaluate at the largest odd r < c_* d / log d
        r = floor(CS*d/log(d))
        if r % 2 == 0:
            r -= 1
        if r >= CS*d/log(d):
            r -= 2
        out['L6'] = True if r < 1 else (Lam(d, r) <= d and Lamp(d, r, g, c1) <= d)
        Jd, rd = Jd_rd(log(d), g)
        out['L8a'] = Jd <= e**2*(t - 4)
        out['L8b'] = Jd*rd <= pi/(256*e**2)
        out['L8c'] = rd <= 1/(8*e**2*log(32))
        return out


XGRID = [mpf(8) + mpf('0.05')*i for i in range(int((690 - 8)/0.05) + 1)]   # log d in [8, 690]


def scan_common():
    last_fail = {}
    for x in XGRID:
        for k, v in conditions_common(x).items():
            if not v:
                last_fail[k] = x
    return last_fail


def scan(sig, xmax=3000):
    """Last scanned log d at which each gain-dependent condition fails; above log d = 690 only
    (L8b), which involves log d alone, is evaluated."""
    g = eta(sig); c1 = c1_tanh(sig)
    last_fail = {}
    thr = pi/(256*e**2)
    for x in XGRID:
        for k, v in conditions_gain(x, g, c1).items():
            if not v:
                last_fail[k] = x
    x = XGRID[-1] + mpf('0.05')
    while x <= xmax:
        Jd, rd = Jd_rd(x, g)
        if not Jd*rd <= thr:
            last_fail['L8b'] = x
        x += mpf('0.05')
    return last_fail


# ---------------------------------------------------------------- part 3: direct check
def check_r(d, r, g, c1, logn_sup):
    D = d + 1
    B = 32*((e - 1)*A77*Lam(d, r) + Lamp(d, r, g, c1)) + A77*Lam(d, r)
    rhat = mpf('1.25')*(r + 2)/d
    kst = max(0, int(ceil(log(A77*Lam(d, r)/EPS0)/(2*log(1/rhat)))))
    u = r + 2*kst
    logRbar = log(8*B/C2) + kst*log(1 + 4/g)
    J = max(1, int(ceil(log(32) + logRbar)))
    res = {}
    res['64r<=d, r+2<=(d+1)/3'] = (64*r <= d) and (r + 2 <= (d + 1)/3)
    res['growth (u+2)/(D-u-1)<=rhat'] = (kst == 0) or ((u + 2)/(D - u - 1) <= rhat)
    tail = logn_sup - logbinom(D, u + 2) - log(EPS0)      # need < 0
    res['n/binom(D,u+2)<eps0'] = tail < 0
    res['u+1<=D/2'] = (u + 1 <= D/2)
    res['J<=e^2 u'] = J <= e**2*u
    res['e sqrt(Ju/(pi d))<=1/16'] = e*sqrt(J*u/(pi*d)) <= mpf(1)/16
    res['Chernoff<=1/64'] = exp(-J*d/(8*e**2*u))/2 <= mpf(1)/64
    return all(res.values()), res, dict(k=kst, J=J, Ju_d=J*u/d, tail=tail)


def direct(log10d, sig, ngrid=600):
    mp.dps = int(max(60, log10d + 40))
    g = eta(sig); c1 = c1_tanh(sig)
    d = floor(mpf(10)**mpf(log10d))
    ln0 = logn0(d); lnm = logn_max(d)
    if lnm <= ln0:
        mp.dps = 60
        return dict(nonempty=False, ratio=float(lnm/ln0))
    rmax = floor(d/64)
    r_lo = largest_odd_r(d, ln0, rmax)
    r_hi = largest_odd_r(d, lnm, rmax)
    if r_lo is None:
        mp.dps = 60
        return dict(nonempty=True, ok=False, ratio=float(lnm/ln0), note='no admissible r at n_0')
    rs = {r_lo, r_hi}
    if (r_hi - r_lo)//2 <= 4000:
        rs.update(range(int(r_lo), int(r_hi) + 1, 2))
    else:
        for i in range(ngrid + 1):
            rr = int(floor(exp(log(r_lo) + (log(r_hi) - log(r_lo))*mpf(i)/ngrid)))
            if rr % 2 == 0:
                rr += 1
            rr = min(max(rr, int(r_lo)), int(r_hi))
            rs.add(rr)
            if rr + 2 <= r_hi:
                rs.add(rr + 2)
    allok = True; fails = []
    maxJu = mpf(0); maxtail = mpf(-10)**9; ks = set(); Js = set()
    for r in sorted(rs):
        logn_sup = min(log_threshold(d, r + 2), lnm)
        ok, res, info = check_r(d, mpf(r), g, c1, logn_sup)
        ks.add(info['k']); Js.add(info['J'])
        maxJu = max(maxJu, info['Ju_d']); maxtail = max(maxtail, info['tail'])
        if not ok:
            allok = False
            fails.append((r, [k for k, v in res.items() if not v]))
    out = dict(nonempty=True, ok=allok, ratio=float(lnm/ln0), t=int(floor(sqrt(d)/5)),
               r_lo=int(r_lo), r_hi=int(r_hi), n_r=len(rs), kmin=min(ks), kmax=max(ks),
               Jmin=min(Js), Jmax=max(Js), maxJu=float(maxJu), maxtail=float(maxtail),
               fails=fails[:3], nfail=len(fails))
    mp.dps = 60
    return out


def fmt(k):
    """Integers below 10^9 in full, larger ones in scientific notation."""
    return str(k) if k < 10**9 else mp.nstr(mpf(k), 6)


GRID = [8.42, 8.5, 9, 9.5, 10, 11, 12, 14, 16, 18, 20, 25, 30, 35, 40, 45, 50, 55, 60, 70, 80,
        100, 120, 140, 160, 180, 200, 250, 300]


def main(parts):
    print(f"c_theta = {mp.nstr(CT, 6)}, C_0 = {mp.nstr(C0, 6)}, epsilon_0 = {mp.nstr(EPS0, 6)}, "
          f"2^77/epsilon_0 = {mp.nstr(A77/EPS0, 5)}, pi/(256 e^2) = {mp.nstr(pi/(256*e**2), 6)}")
    print(f"B_* = 32((e-1) 2^77 + 1) + 2^77 = {mp.nstr(BSTAR, 5)};  log(256 B_*/c_theta^2) = "
          f"{mp.nstr(log(256*BSTAR/C2), 5)};  log(2^77/epsilon_0) = {mp.nstr(log(A77/EPS0), 5)};  "
          f"log 2^77 = {mp.nstr(log(A77), 5)}")
    if 1 in parts:
        print("\nPart 1: crossover")
        dx = crossover()
        print(f"  n_max(d) = n_0(d) at d_x = {mp.nstr(dx, 4)} (log10 d_x = {mp.nstr(log(dx, 10), 4)})")
        for l10 in [8, 9, 10]:
            d = mpf(10)**l10
            print(f"  log n_max / log n_0 at d = 1e{l10}: {mp.nstr(logn_max(d)/logn0(d), 3)}")
        sys.stdout.flush()
    if 2 in parts:
        print("\nPart 2: conditions (L1)-(L8), L = 2; last scanned log d at which each fails")
        lc = scan_common()
        print("  conditions without gains: " + ', '.join(f"{k}:{float(v):.2f}" for k, v in
                                                      sorted(lc.items(), key=lambda kv: kv[1])))
        common = max([float(v) for v in lc.values()] + [0.0])
        print(f"     => (L1)-(L5) and (L7) hold at every scanned log d > {common:.2f} "
              f"(log10 d > {common/float(log(10)):.2f}), up to log d = 690")
        for sig in SIGMAS:
            lf = scan(sig)
            items = sorted(lf.items(), key=lambda kv: kv[1])
            s_items = ', '.join(f"{k}:{float(v):.2f}" for k, v in items)
            other = max([float(v) for k, v in lf.items() if k != 'L8b'] + [0.0])
            xb = lf.get('L8b')
            print(f"  sigma1={sig}: eta={mp.nstr(eta(sig), 4)}, c_1={mp.nstr(c1_tanh(sig), 10)}; {s_items}")
            print(f"     => (L8b) holds for scanned log d > {float(xb):.2f} (log10 d > "
                  f"{float(xb/log(10)):.2f}); (L6), (L8a), (L8c) for log d > {other:.2f}")
            sys.stdout.flush()
        g = eta(1.0)
        for l10 in [58, 100, 150, 175, 176, 177, 200, 300]:
            x = mpf(l10)*log(10)
            Jd, rd = Jd_rd(x, g)
            allowed = pi/(256*e**2)/rd/x
            print(f"  sigma1=1, d=1e{l10}: J_d={float(Jd):.2f}, J_d/log d={float(Jd/x):.4f} "
                  f"(allowed {float(allowed):.4f}), J_d r_d={float(Jd*rd):.5e}")
        x = mpf(176)*log(10)
        Td = log(1 + 4/g)*(1 + (x + log(A77/EPS0))/(2*log(x/(mpf('1.3')*CS))))
        lead = log(1 + 4/g)*x/(2*log(x))
        print(f"  sigma1=1, d=1e176: T_d={float(Td):.2f}; leading term (1/2) log(1+4/eta) log d/log log d"
              f"={float(lead):.2f}; log(1/(1.3 c_*))={float(-log(mpf('1.3')*CS)):.3f}, "
              f"log log d={float(log(x)):.3f}")
        thr = pi/(256*e**2)
        last = None
        x = XGRID[0]
        while x <= 3000:
            Jd, rd = Jd_rd_route(x, g, mpf(1))
            if not Jd*rd <= thr:
                last = x
            x += mpf('0.05')
        print(f"  A_(1/8) route of Remark 6.16 with A_(1/8)=1 in place of 2^77, sigma1=1: (L8b) holds for "
              f"scanned log d > {float(last):.2f} (log10 d > {float(last/log(10)):.2f})")
        sys.stdout.flush()
    if 3 in parts:
        print("\nPart 3: direct evaluation of the inequalities of Regime II at grid dimensions, L = 2")
        print(f"  (requirement on J u/d: pi/(256 e^2) = {float(pi/(256*e**2)):.5e})")
        for sig in [3.0, 1.0, 0.3]:
            print(f"  sigma1={sig}")
            for l10 in GRID:
                out = direct(l10, sig)
                if not out['nonempty']:
                    print(f"    log10 d={l10}: Regime II empty (log n_max/log n_0 = {out['ratio']:.3f})")
                elif 'note' in out:
                    print(f"    log10 d={l10}: {out['note']}  ALL OK=False")
                else:
                    print(f"    log10 d={l10}: r in [{fmt(out['r_lo'])}, {fmt(out['r_hi'])}] ({out['n_r']} r checked), "
                          f"t={fmt(out['t'])}, k*={out['kmin']}..{out['kmax']}, J={out['Jmin']}..{out['Jmax']}, "
                          f"max Ju/d={out['maxJu']:.3e}, max log(n/(eps0 binom(D,u+2)))={out['maxtail']:.1f}  "
                          f"ALL OK={out['ok']}" + (f"  ({out['nfail']} r fail; e.g. {out['fails']})"
                                                   if not out['ok'] else ''))
                sys.stdout.flush()


if __name__ == '__main__':
    parts = [int(p) for p in sys.argv[1].split(',')] if len(sys.argv) > 1 else [1, 2, 3]
    main(parts)
