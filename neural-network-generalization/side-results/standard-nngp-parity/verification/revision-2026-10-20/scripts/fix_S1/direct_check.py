# Direct evaluation, at fixed d, of the inequalities that the proof of Theorem 6.1 (Regime II) actually uses,
# with the actual (r, k*, u, B_r, J) in place of the uniform bounds (L4)-(L9).
# Conditional on a value of A = A_{1/8} (not known; A >= 1 is the most favourable case allowed by the proof).
# Kernel enters only through gamma = gamma(sigma1) and c_1 (L = 2: c_1 = c_1(sigma1^2)).
import sys
from mpmath import mp, mpf, log, sqrt, exp, pi, e, ceil, floor, loggamma, nstr

C1 = {0.2: 0.9991409577, 0.3: 0.9965207801, 0.5: 0.9841671669, 1.0: 0.9304699236,
      2.0: 0.8376671521, 3.0: 0.7843346384, 8.0: 0.6977184742}

def setup(log10d):
    mp.dps = int(max(50, log10d + 40))
    g = {}
    g['ct'] = sqrt(2*pi)*(exp(-1) - mpf(7)/20); g['c2'] = g['ct']**2
    g['C0'] = 2 + 2/g['c2']
    g['eps'] = 1/(64*(2 + 8/g['c2']))
    g['cs'] = mpf('1e-3')
    return g

def logbinom(n, k):
    return loggamma(n + 1) - loggamma(k + 1) - loggamma(n - k + 1)

def logD(d, r):
    # log sum_{q<=r} binom(d,q) = log binom(d,r) + log S
    S = mpf(1); T = mpf(1); i = 0
    while i < r:
        T = T*(r - i)/(d - r + 1 + i)
        S += T; i += 1
        if T < mpf(10)**(-40): break
    return logbinom(d, r) + log(S)

def coer_size(d, r, A):
    lD = logD(d, r)
    return log(A) + lD + log(log(2) + lD)   # log(A D_r log(2 D_r))

def largest_odd_r(d, A, logn, rmax):
    # largest odd r in [1, rmax] with coer_size <= logn (monotone in r); None if r=1 fails
    if coer_size(d, 1, A) > logn: return None
    lo, hi = 0, (int(rmax) - 1)//2      # r = 2k+1
    while lo < hi:
        mid = (lo + hi + 1)//2
        if coer_size(d, 2*mid + 1, A) <= logn: lo = mid
        else: hi = mid - 1
    return 2*lo + 1

def check_r(d, r, A, s, g, logn_max):
    D = d + 1
    gm = 1/(6*(1 + pi/(2*mpf(s)))**4); c1 = mpf(C1[s])
    eps, c2, cs = g['eps'], g['c2'], g['cs']
    Lam = 2*log(4) + 2*(r + 2)*log(e*d/(r + 2))
    Lamp = (r + 2)*log(e*D/(r + 2)) + (r + 1)/2*log(1/gm) + log(1/c1)
    B = 32*((e - 1)*A*Lam + Lamp) + A*Lam
    rhat = mpf('1.25')*(r + 2)/d
    kst = int(ceil(log(A*Lam/eps)/(2*log(1/rhat))))
    kst = max(kst, 0)
    u = r + 2*kst
    logRbar = log(8*B/c2) + kst*log(1 + 4/gm)
    J = max(1, int(ceil(log(32) + logRbar)))
    res = {}
    res['r<=d/64,r+2<=(d+1)/3'] = (r <= d/64) and (r + 2 <= (d + 1)/3)
    res['growth (u+2)/(D-u-1)<=rhat'] = (kst == 0) or ((u + 2)/(D - u - 1) <= rhat)
    # direct tail check: sup n with r(n)=r is < A D_{r+2} log(2 D_{r+2}) and <= n_max
    logn_sup = min(coer_size(d, r + 2, A), logn_max)
    tail = logn_sup - logbinom(D, u + 2) - log(eps)          # need < 0
    res['n/binom(D,u+2)<eps'] = tail < 0
    res['u+1<=D/2'] = (u + 1 <= D/2)
    res['J<=e^2 u'] = J <= e**2*u
    abfr = e*sqrt(J*u/(pi*d))
    res['e sqrt(Ju/(pi d))<=1/16'] = abfr <= mpf(1)/16
    cher = exp(-J*d/(8*e**2*u))/2
    res['Chernoff<=1/64'] = cher <= mpf(1)/64
    ok = all(res.values())
    return ok, res, dict(k=kst, u=u, J=J, Ju_d=J*u/d, abfr=abfr, cher=cher, tail=tail,
                         J_over_e2u=J/(e**2*u), growth=(u + 2)/(D - u - 1)/rhat if kst > 0 else 0)

def run(log10d, A, s, ngrid=300):
    g = setup(log10d)
    d = floor(mpf(10)**mpf(log10d))
    x = log(d)
    t = floor(sqrt(d)/5)
    logn0 = logbinom(d, t) - log(23*g['C0'])
    logn_max = g['cs']*d*log(x)/x
    if logn_max <= logn0:
        return dict(nonempty=False, log10d=log10d, ratio=float(logn_max/logn0))
    rmax = floor(d/64)
    r_lo = largest_odd_r(d, A, logn0, rmax)        # r(n) at the bottom of Regime II is >= this
    r_hi = largest_odd_r(d, A, logn_max, rmax)
    rs = set([r_lo, r_hi])
    span = r_hi - r_lo
    if span <= 2*4000:
        rs.update(range(int(r_lo), int(r_hi) + 1, 2))
    else:
        for i in range(ngrid + 1):
            rr = int(floor(exp(log(r_lo) + (log(r_hi) - log(r_lo))*mpf(i)/ngrid)))
            if rr % 2 == 0: rr += 1
            rr = min(max(rr, int(r_lo)), int(r_hi))
            rs.add(rr)
            if rr + 2 <= r_hi: rs.add(rr + 2)
    allok = True; worst = {}
    agg = dict(Ju_d=mpf(0), J_over_e2u=mpf(0), cher=mpf(0), tail=mpf(-10**9), growth=mpf(0))
    kset = set(); Jset = set(); fails = []
    for r in sorted(rs):
        ok, res, info = check_r(d, mpf(r), A, s, g, logn_max)
        kset.add(info['k']); Jset.add(info['J'])
        for k in agg: agg[k] = max(agg[k], info[k])
        if not ok:
            allok = False; fails.append((r, [k for k, v in res.items() if not v]))
    return dict(nonempty=True, log10d=log10d, ratio=float(logn_max/logn0), t=int(t), r_lo=int(r_lo), r_hi=int(r_hi),
                n_r=len(rs), ok=allok, kmin=min(kset), kmax=max(kset), Jmin=min(Jset), Jmax=max(Jset),
                max_Ju_d=float(agg['Ju_d']), max_J_over_e2u=float(agg['J_over_e2u']), max_cher=float(agg['cher']),
                max_tail=float(agg['tail']), max_growth=float(agg['growth']), fails=fails[:5],
                rhi_over_d_logd=float(mpf(r_hi)*x/d))

if __name__ == '__main__':
    sig = float(sys.argv[1]); A = float(sys.argv[2])
    grid = [float(v) for v in sys.argv[3].split(',')]
    thr = float(pi/(256*e**2))
    print(f"sigma1={sig} A={A}  (threshold for J u/d: pi/(256 e^2) = {thr:.5e})")
    for l10 in grid:
        out = run(l10, A, sig)
        if not out['nonempty']:
            print(f"  log10 d={l10}: Regime II empty (log n_max/log n_0 = {out['ratio']:.3f})"); continue
        print(f"  log10 d={l10}: ratio={out['ratio']:.3f} t={out['t']} r in [{out['r_lo']},{out['r_hi']}] ({out['n_r']} r checked) "
              f"r_hi log d/d={out['rhi_over_d_logd']:.3e} k*={out['kmin']}..{out['kmax']} J={out['Jmin']}..{out['Jmax']} "
              f"max Ju/d={out['max_Ju_d']:.3e} max J/(e^2u)={out['max_J_over_e2u']:.2e} max Chernoff={out['max_cher']:.1e} "
              f"max log(n/(eps binom))={out['max_tail']:.1f} max growth ratio={out['max_growth']:.3f}  ALL OK={out['ok']} {out['fails']}")
        sys.stdout.flush()
