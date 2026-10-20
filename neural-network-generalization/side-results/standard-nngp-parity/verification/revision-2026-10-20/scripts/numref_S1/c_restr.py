"""Exhaustive check of Lemma 2.1 (via MILP for small k), Lemma 2.2 (restriction lemma), Cor 2.3."""
import numpy as np, math, itertools, sys
from scipy.optimize import milp, LinearConstraint, Bounds
from scipy.stats import binom

rng = np.random.default_rng(int(sys.argv[1]) if len(sys.argv) > 1 else 0)

def cube(d):
    return 1-2*((np.arange(2**d)[:, None] >> np.arange(d)[None, :]) & 1)  # rows x in {-1,1}^d

def wht(v):
    v = v.astype(float).copy(); n = len(v); h = 1
    while h < n:
        v = v.reshape(-1, 2*h); a = v[:, :h].copy(); b = v[:, h:].copy()
        v[:, :h] = a+b; v[:, h:] = a-b; v = v.reshape(-1); h *= 2
    return v/n   # hat g(U), U encoded as bitmask (bit i -> coordinate i)

def iwht(c):
    return wht(c)*len(c)

popc = lambda d: np.array([bin(i).count('1') for i in range(2**d)])

def beta_ub(j, m):
    if j >= m: return 1.0
    t = (m-j-1)//2
    return 1 - sum(math.comb(m, i) for i in range(t+1))/2**m

def beta_milp(j, k):
    if j >= k: return 1.0
    X = cube(k); pc = popc(k)
    mons = [U for U in range(2**k) if pc[U] <= j]
    chi = np.array([[np.prod(X[x, [i for i in range(k) if U >> i & 1]]) if U else 1 for U in mons] for x in range(2**k)])
    par = np.prod(X, axis=1)
    nm = len(mons); N = 2**k; B = 1e4
    # vars: L coefs (nm, bounded [-50,50]), z (N binary). par*chi L >= 1 - B(1-z)
    A = np.hstack([par[:, None]*chi, -B*np.eye(N)])
    cons = LinearConstraint(A, 1-B, np.inf)
    c = np.concatenate([np.zeros(nm), -np.ones(N)])
    integ = np.concatenate([np.zeros(nm), np.ones(N)])
    bnds = Bounds(np.concatenate([-50*np.ones(nm), np.zeros(N)]), np.concatenate([50*np.ones(nm), np.ones(N)]))
    res = milp(c, constraints=[cons], integrality=integ, bounds=bnds, options={'time_limit': 60})
    return -res.fun/N, res.status

BETA_EXACT = {}
def beta_best(j, m):
    if (j, m) in BETA_EXACT: return BETA_EXACT[(j, m)]
    return beta_ub(j, m)

_CACHE = {}
def rhs_table(d, W2, a, ps):
    """min over j,p of RHS (2.1). W2[w] = sum_{|U|=w} hat h^2, with W2[0] ignored."""
    key = (d, tuple(ps), len(BETA_EXACT))
    if key not in _CACHE:
        ms = np.arange(d+1)
        bet = np.array([[beta_best(j, m) for m in ms] for j in range(d+1)])
        Bm = np.array([bet @ binom.pmf(ms, d, p) for p in ps])           # [p, j]
        Sm = np.array([[[binom.sf(j, w, p) if w >= 1 else 0.0 for w in ms] for j in range(d+1)] for p in ps])  # [p,j,w]
        _CACHE[key] = (Bm, Sm)
    Bm, Sm = _CACHE[key]
    V = Bm + (Sm @ W2)/a**2
    i = np.unravel_index(np.argmin(V), V.shape)
    return V[i], (int(i[1]), float(ps[i[0]]))

def sym_abfr(d, u):
    """degree-u symmetric polynomial in s=#(-1) agreeing with parity on middle u+1 levels."""
    c = d/2
    lv = np.arange(d+1)
    mid = np.argsort(np.abs(lv-c))[:u+1]; mid.sort()
    # roots between consecutive middle levels
    roots = (mid[:-1]+mid[1:])/2
    P = np.ones(d+1)
    for r0 in roots: P *= (lv-r0)
    sgn = np.sign(P[mid[0]])*(-1)**mid[0]   # make sign(P)= parity (-1)^s at mid[0]
    return P*sgn

def gen_h(d, X, pc, f, kind):
    N = 2**d; s = (X < 0).sum(1)
    if kind == 'lowdeg':
        u = rng.integers(1, d); c = rng.normal(size=N)*(pc <= u); c[0] = rng.normal()*rng.choice([0, 1, 5])
        return iwht(c)
    if kind == 'abfr':
        u = rng.integers(1, d); P = sym_abfr(d, u); return P[s]*rng.uniform(0.5, 3) + rng.choice([0, 0.1])*rng.normal(size=N)
    if kind == 'low+high':
        u = rng.integers(1, d); c = rng.normal(size=N)*(pc <= u); c += 0.3*rng.normal(size=N)*(pc > u)*rng.uniform()
        return iwht(c)
    if kind == 'subparity':
        k = rng.integers(1, d+1); S = rng.choice(d, k, replace=False)
        g = np.prod(X[:, S], axis=1)*rng.choice([-1, 1])
        u = rng.integers(0, d+1); c = wht(f*np.maximum(f*g, 0) + 0*g); c *= (pc <= u) | (rng.uniform(size=N) < 0.1)
        return iwht(c)
    if kind == 'fplus':
        lam = rng.uniform(0, 2); c = rng.normal(size=N)*(pc <= rng.integers(1, d)); return lam*f + iwht(c)
    if kind == 'signlow':
        # sign of a low degree poly times parity -> truncated
        u = rng.integers(1, d); c = rng.normal(size=N)*(pc <= u); g = np.sign(iwht(c))
        w = rng.integers(1, d+1); cc = wht(f*g)*(pc <= w); return iwht(cc)
    raise ValueError

def check_lemma(d, nh, ps):
    X = cube(d); f = np.prod(X, axis=1); pc = popc(d)
    kinds = ['lowdeg', 'abfr', 'low+high', 'subparity', 'fplus', 'signlow']
    worst = np.inf; worst_info = None; worst_cor = np.inf; worst_cor_info = None
    for it in range(nh):
        kind = kinds[it % len(kinds)]
        h = gen_h(d, X, pc, f, kind)
        c = wht(h); W2 = np.bincount(pc, weights=c**2, minlength=d+1)
        fh = f*h
        pos = fh[fh > 0]
        if len(pos) == 0: continue
        for a in np.unique(np.quantile(pos, [0.0, 0.1, 0.3, 0.5, 0.8])):
            if a <= 0: continue
            lhs = np.mean(fh >= a - 1e-12*abs(a))
            rhs, arg = rhs_table(d, W2, a, ps)
            if rhs - lhs < worst: worst, worst_info = rhs-lhs, (kind, a, lhs, rhs, arg)
            # corollary 2.3
            u = int(pc[np.abs(c) > 1e-12].max()) if np.any(np.abs(c[1:]) > 1e-12) else 0
            if u >= 1:
                rho = u/d; R = W2[1:].sum()/a**2
                Js = range(1, int(math.floor(math.e**2*u))+1)
                cor = min(0.5+math.e*math.sqrt(J*rho/math.pi)+0.5*math.exp(-J/(8*math.e**2*rho))+R*math.exp(-J) for J in Js)
                if cor - lhs < worst_cor: worst_cor, worst_cor_info = cor-lhs, (kind, u, a, lhs, cor)
    print(f'd={d}: min over h,a of [min_(j,p) RHS(2.1) - LHS] = {worst:.3e}  info={worst_info}')
    print(f'      min over h,a of [Cor2.3 RHS - LHS] = {worst_cor:.3e} info={worst_cor_info}')

def hill_climb(d, iters, ps):
    """local search for h maximizing LHS - min RHS"""
    X = cube(d); f = np.prod(X, axis=1); pc = popc(d); N = 2**d
    s = (X < 0).sum(1)
    best_gap = -np.inf
    for restart in range(4):
        u = rng.integers(1, d)
        c = wht(sym_abfr(d, u)[s]) if restart % 2 == 0 else rng.normal(size=N)*(pc <= u)
        def score(c):
            h = iwht(c); fh = f*h; W2 = np.bincount(pc, weights=c**2, minlength=d+1)
            a = 1.0
            lhs = np.mean(fh >= a)
            rhs, _ = rhs_table(d, W2, a, ps)
            return lhs - rhs
        # rescale so that a=1 is a reasonable threshold
        h = iwht(c); fh = f*h; q = np.quantile(fh[fh > 0], 0.2) if np.any(fh > 0) else 1
        c = c/q
        cur = score(c)
        for it in range(iters):
            c2 = c.copy()
            idx = rng.integers(0, N, size=rng.integers(1, 4))
            c2[idx] += rng.normal(size=len(idx))*0.3*np.abs(c).max()
            if rng.uniform() < 0.3: c2 *= rng.uniform(0.8, 1.25)
            sc = score(c2)
            if sc >= cur: c, cur = c2, sc
        best_gap = max(best_gap, cur)
        print(f'  hill d={d} restart {restart}: best LHS-RHS = {cur:.4e}')
    return best_gap

if __name__ == '__main__':
    print('Lemma 2.1: exact beta by MILP vs ABFR bound')
    for k in range(1, 7):
        for j in range(0, k):
            bm, st = beta_milp(j, k)
            BETA_EXACT[(j, k)] = bm
            ub = beta_ub(j, k); ub2 = 0.5+(j+1)/math.sqrt(2*math.pi*k)
            flag = 'VIOL' if bm > ub+1e-9 or ub > ub2+1e-12 else ''
            print(f'  k={k} j={j}: beta_milp={bm:.5f} (status {st})  ABFR1={ub:.5f}  ABFR2={ub2:.5f} {flag}')
    # second inequality of Lemma 2.1 for large k
    bad = 0; mn = np.inf
    from scipy.stats import binom as _b
    for k in range(1, 3001):
        js = np.arange(0, k); ts = (k-js-1)//2
        ub1 = 1-_b.cdf(ts, k, 0.5); ub2 = 0.5+(js+1)/math.sqrt(2*math.pi*k)
        bad += int(np.sum(ub1 > ub2+1e-12)); mn = min(mn, np.min(ub2-ub1))
        mx = _b.pmf(k//2, k, 0.5)
        if mx > math.sqrt(2/(math.pi*k))+1e-15: bad += 1
    print('Lemma 2.1 second ineq + (B5) violations for k<=3000:', bad, ' min slack', mn)
    ps = np.concatenate([np.linspace(0.02, 1, 50), [1.0]])
    for d, nh in [(8, 300), (10, 240), (12, 120), (14, 30)]:
        check_lemma(d, nh, ps)
    for d in [8, 10]:
        hill_climb(d, 300, np.linspace(0.05, 1, 20))
