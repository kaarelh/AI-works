"""Independent evaluation of the explicit lower bound underline-Psi_d of Corollary 5.2 (RT-depth2.fixed.md section 4):
  uPsi_tri = ( sqrt(beta_d - h_d) - sqrt((1-th)(p_d + h_d) + c(dF_d+1)/M + th*lam'*a) )_+^2
  uPsi_cor = ( th (p_d - h_d - lam' a) - c(dF_d+1)/M )_+^2 / (4 (lam' + h_d/2))
with h_d = 2 n^{2/3}/M, th = 1/(18 d c + 1), lam' = n/M, n = ceil(lam M).
beta_d, p_d computed from Bin(n,1/M) via a log-product pmf (independent of the authors' recursion)."""
import mpmath as mp
mp.mp.dps = 60

def FD(d): return 1 + (d + 1) * (d + 2)**2

_cache = {}
def stats(d, lam=1):
    key = (d, lam)
    if key in _cache: return _cache[key]
    M = mp.mpf(2)**d; n = mp.ceil(mp.mpf(lam) * M); p = 1 / M
    logq = mp.log1p(-p)
    s = mp.mpf(0); p0 = mp.e**(n * logq)
    for k in range(1, 300):
        if k > n: break
        # log C(n,k) p^k = sum_{j<k} [log((n-j)/M) - log(j+1)]  (no cancellation between huge numbers)
        lp = mp.fsum(mp.log((n - j) / M) - mp.log(j + 1) for j in range(k)) + (n - k) * logq
        t = mp.e**lp
        s += t / k
        if t < mp.mpf(10)**-50 and k > 10: break
    out = (M, n, s, 1 - p0)
    _cache[key] = out
    return out

def ubound(d, c, a, lam=1):
    M, n, bd, pd = stats(d, lam)
    c = mp.mpf(c); a = mp.mpf(a)
    h = 2 * n**(mp.mpf(2)/3) / M; lp = n / M
    th = 1 / (18 * d * c + 1)
    A = bd - h
    Bv = (1 - th) * (pd + h) + c * (d * FD(d) + 1) / M + th * lp * a
    tri = (max(mp.sqrt(A) - mp.sqrt(Bv), 0) if A > 0 else mp.mpf(0))**2
    cor = max(th * (pd - h - lp * a) - c * (d * FD(d) + 1) / M, 0)**2 / (4 * (lp + h / 2))
    return tri, cor, th

def gam(l=1):
    l = mp.mpf(l); return (1 - mp.e**(-l))**2 / (4 * l)

if __name__ == '__main__':
    g1 = gam(1)
    print("(1) c = 1, lambda = 1, a = 1/n")
    first_pos = None; first2 = None; best = (0, 0); fails = []; minratio = (None, mp.inf)
    for d in range(1, 1001):
        M, n, _, _ = stats(d)
        tri, cor, th = ubound(d, 1, 1 / n)
        v = max(tri, cor)
        if tri > 0: print("   tri-branch positive at d=%d (unexpected)" % d)
        if v > 0 and first_pos is None: first_pos = d
        e2 = 2 * g1 * th**2 / 3
        if v >= e2 and first2 is None: first2 = d
        if d >= 33 and v < e2: fails.append(d)
        if v > best[1]: best = (d, v)
        if d >= 33 and v / (g1 * th**2) < minratio[1]: minratio = (d, v / (g1 * th**2))
        if d in (29, 30, 32, 33, 34, 35, 36, 60, 1000):
            print("   d=%4d bound %.4e  gamma th^2 %.4e  ratio %.4f" % (d, float(v), float(g1 * th**2), float(v / (g1 * th**2))))
    print("   first positive d = %s; first d with bound >= 2 eps_d = %s; failures in [33,1000]: %s" % (first_pos, first2, fails))
    print("   max bound d=%d value %.4e; min ratio over [33,1000]: d=%d %.6f" % (best[0], float(best[1]), minratio[0], float(minratio[1])))

    print("\n(2) small-c table, lambda = 1, max(tri, cor)")
    for lab, cf, af in [("1/d", lambda d: mp.mpf(1)/d, 'n'), ("0.05/d", lambda d: mp.mpf('0.05')/d, 'n'),
                        ("1/d^2", lambda d: mp.mpf(1)/d**2, 'n'), ("1/d^3", lambda d: mp.mpf(1)/d**3, 'n'),
                        ("1/d^3,a=1/d", lambda d: mp.mpf(1)/d**3, 'd')]:
        row = []
        for d in (30, 60, 200):
            M, n, _, _ = stats(d)
            a = 1 / n if af == 'n' else mp.mpf(1) / d
            tri, cor, th = ubound(d, cf(d), a)
            row.append("%.4f(%s)" % (float(max(tri, cor)), "tri" if tri >= cor else "cor"))
        print("   c=%-12s %s" % (lab, "  ".join(row)))

    print("\n(3) widths N0(a) = ceil(72 d n ln(2M)/a^2)+1 at d=30")
    d = 30; M, n, _, _ = stats(d)
    N0n = mp.ceil(72 * d * n * mp.log(2 * M) * n**2) + 1
    N0d = mp.ceil(72 * d * n * mp.log(2 * M) * d**2) + 1
    print("   N0(1/n) = %.3e, N0(1/d) = %.3e = %.3e n" % (float(N0n), float(N0d), float(N0d / n)))

    print("\n(4) Cor 5.2(i): ratio uPsi/(gamma th^2) for c = d^k (a = 1/d), shows the (1-o(1)) and where it is >= 2/3")
    for k in (0, 1, 2, 3):
        row = []; first = None
        for d in range(20, 401):
            M, n, _, _ = stats(d)
            tri, cor, th = ubound(d, mp.mpf(d)**k, mp.mpf(1) / d)
            r = max(tri, cor) / (g1 * th**2)
            if r >= mp.mpf(2)/3 and first is None: first = d
            if d in (40, 60, 100, 200, 400): row.append("d=%d:%.4f" % (d, float(r)))
        print("   k=%d first d with ratio>=2/3: %s; %s" % (k, first, "  ".join(row)))
