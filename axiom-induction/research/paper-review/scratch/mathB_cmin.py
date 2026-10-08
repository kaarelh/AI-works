"""Independent checks (review B) for C_min results of Section univ: Split_k, Both0, H_all KL (Prop U16(b)),
spare slot I_n (Prop univ:both), Prop B2 limit h(w*), Prop U12(b) numbers, the Catalan detour fixed point,
and Thm U8 numbers (Laplace and dyadic).  No track code imported."""
import math
import numpy as np
from scipy.optimize import minimize
from scipy.integrate import quad
import mathB_chains as ch


def kl_sentence_class():
    c, q = 0.3, 0.5
    out = []
    Hall = ch.theory_law([('all', 0, 1.0)], c, 0.0, 0.0, q)
    out.append(('H_all', ch.KL_closed(Hall, q), math.log((1 + c) / c)))
    for k in range(1, 5):
        def f(x):
            ex = np.exp(x - x.max()); w = ex / ex.sum()
            ax = [('sent', j, w[j]) for j in range(k)] + [('all', k, w[k])]
            return ch.KL_closed(ch.theory_law(ax, c, 0.0, 0.0, q), q)
        best = min((minimize(f, np.random.default_rng(t).normal(size=k + 1), method='Nelder-Mead',
                             options={'xatol': 1e-10, 'fatol': 1e-13, 'maxiter': 6000}) for t in range(3)), key=lambda r: r.fun)
        out.append((f'Split_{k}', best.fun, q ** k * math.log((1 + c) / c)))
    def fb(w):
        w = float(np.clip(w, 0, 1))
        return ch.KL_closed(ch.theory_law([('sent', 0, w), ('all', 0, 1 - w)], c, 0.0, 0.0, q), q)
    ws = np.linspace(0, 1, 20001)
    vals = [fb(w) for w in ws[::50]]
    i = int(np.argmin(vals)); w0 = ws[::50][i]
    r = minimize(lambda x: fb(x[0]), [w0], method='Nelder-Mead', options={'xatol': 1e-12, 'fatol': 1e-14})
    out.append(('Both0', r.fun, q * math.log((1 + q * c) / (q * c))))
    for name, a, b in out:
        print(f'  {name:8s} numeric {a:.6f}  predicted {b:.6f}')


def spare_slot():
    c = 0.3
    for n in [10, 100, 1000, 100000]:
        I, _ = quad(lambda w: ((1 - w * (1 - c)) / (1 + w * c)) ** n, 0, 1, limit=500, points=[1e-6, 1e-4, 1e-2])
        print(f'  n={n}: n I_n = {n * I:.5f}  bounds [{n / (n + 1):.5f}, {1 / (1 - c):.5f}]')


def prop_b2():
    c = 0.3
    h = lambda v: c / (c + v * (1 - c)) ** 2
    thr = math.sqrt(c) / (1 + math.sqrt(c))
    print('  threshold sqrt(c)/(1+sqrt(c)) =', round(thr, 4), ' h(thr) =', round(h(thr), 12))
    # direct BF from the definitions (not the change of variables), deterministic counts n_phi = w* n
    for ws in [0.1, 0.3, 0.5, 0.8]:
        n = 20000; nphi = int(round(ws * n)); npsi = n - nphi
        we = lambda w: w * c / (1 - w + w * c)
        lf = lambda w: nphi * math.log(max(we(w), 1e-300)) + npsi * math.log(max(1 - we(w), 1e-300))
        ls = lambda w: nphi * math.log(max(w, 1e-300)) + npsi * math.log(max(1 - w, 1e-300))
        grid = np.linspace(1e-9, 1 - 1e-9, 400001)
        a = np.array([lf(w) for w in grid]); b = np.array([ls(w) for w in grid])
        m = max(a.max(), b.max())
        BF = np.trapezoid(np.exp(a - m), grid) / np.trapezoid(np.exp(b - m), grid)
        print(f'  w*={ws}: BF (n=2e4, direct quadrature) = {BF:.4f}, h(w*) = {h(ws):.4f}')


def u12b():
    c, L = 0.3, 3
    SB = sum(c ** k for k in range(L + 2))
    for w in [0.05, 0.2, 0.5, 0.9]:
        p_both = (1 - w + w * c) / (1 + w * c)
        p_B = ((1 - w) + w * c ** (L + 1)) / (w * SB + 1 - w)
        print(f'  w={w}: per-instance log ratio {math.log(p_both / p_B):.3f}')
    Kc = sum(c ** k for k in range(L + 1))
    print('  ln(1+c+..+c^L) =', round(math.log(Kc), 4))
    # exact identity: r_B(w) = r_both(K w)
    rb = lambda w: (1 - w * (1 - c)) / (1 + w * c)
    rB = lambda w: ((1 - w) + w * c ** (L + 1)) / (w * SB + 1 - w)
    print('  max |r_B(w) - r_both(K w)| on grid:', max(abs(rB(w) - rb(Kc * w)) for w in np.linspace(0, 1, 1001)))
    for n in [1, 3, 10]:
        a, _ = quad(lambda w: rb(w) ** n, 0, 1); b, _ = quad(lambda w: rB(w) ** n, 0, 1)
        print(f'  n={n}: log BF(both:B) = {math.log(a / b):.4f}')


def detour():
    pc, c, a, e = 0.35, 0.15, 0.25, 0.25
    D = lambda x: (1 - math.sqrt(1 - 4 * x)) / (2 * x) if x > 0 else 1.0
    def fixed(forall):
        Z = 0.0
        for _ in range(100000):
            d = D(e * a * Z)
            PU = pc * d if forall else 0.0
            Zn = d * (pc + c * PU + a * Z * Z)
            if abs(Zn - Z) < 1e-15:
                break
            Z = Zn
        return Z, D(e * a * Z)
    Zf, Df = fixed(True); Zs, Ds = fixed(False)
    R = c * Df ** 2 / Ds
    print(f'  Z_forall={Zf:.5f} D_forall={Df:.5f}  Z_sigma={Zs:.5f} D_sigma={Ds:.5f}  R={R:.5f}  (paper: 1.03160, 1.02636, 0.15553)')


def detour_mc(N=300000, seed=7):
    """Monte Carlo of C_and with an explicit formula sampler (formulas as tuples).
    Returns P(conclusion is an instance phi(t)) for each theory."""
    pc, c, a, e = 0.35, 0.15, 0.25, 0.25
    rng = np.random.default_rng(seed)
    q = 0.5
    def term():
        return ('num', int(rng.geometric(1 - q)) - 1)
    def gen(theory, depth=0):
        if depth > 400:
            raise RecursionError
        u = rng.random()
        if u < pc:
            if theory == 'forall':
                return ('all',)
            return ('inst', term()[1])
        u -= pc
        if u < c:
            p = gen(theory, depth + 1)
            if p is None or p[0] != 'all':
                return None
            return ('inst', term()[1])
        u -= c
        if u < a:
            l = gen(theory, depth + 1)
            if l is None:
                return None
            r = gen(theory, depth + 1)
            if r is None:
                return None
            return ('and', l, r)
        p = gen(theory, depth + 1)
        if p is None or p[0] != 'and':
            return None
        return p[1] if rng.random() < 0.5 else p[2]
    res = {}
    import sys
    sys.setrecursionlimit(10000)
    for th in ['forall', 'sigma']:
        hits = 0; trunc = 0
        for _ in range(N):
            try:
                s = gen(th)
            except RecursionError:
                trunc += 1; continue
            if s is not None and s[0] == 'inst':
                hits += 1
        p = hits / N
        res[th] = (p, math.sqrt(p * (1 - p) / N), trunc)
    pf, sf, tf = res['forall']; ps, ss, ts = res['sigma']
    R = pf / ps
    se = R * math.sqrt((sf / pf) ** 2 + (ss / ps) ** 2)
    print(f'  MC (N={N} per theory): P_forall(inst)={pf:.5f}  P_sigma(inst)={ps:.5f}  R={R:.5f} +- {se:.5f}  truncated {tf},{ts}')


def confirm_numbers():
    pi0 = 0.01
    s = 0.0
    for n in range(0, 10 ** 6):
        num = (1 - pi0) / ((n + 1) * (n + 2))
        den = pi0 + (1 - pi0) / (n + 1)
        s += num / den
    print(f'  Laplace + point mass: sum_n (1 - M(I|D_n)) = {s:.4f}  <= ln 100 = {math.log(100):.4f}')
    n = 1e50
    Wn = sum((1 - pi0) / (j * (j + 1)) * math.exp(n * math.log1p(-2.0 ** -j)) for j in range(1, 2000))
    print(f'  dyadic at n=1e50: 1 - pi_n(G) = {Wn / (pi0 + Wn):.4f}')


if __name__ == '__main__':
    print('Sentence-only class KL (C_min, c=0.3, q=1/2):'); kl_sentence_class()
    print('Spare slot I_n:'); spare_slot()
    print('Prop B2:'); prop_b2()
    print('Prop U12(b):'); u12b()
    print('Detour fixed point:'); detour()
    detour_mc()
    print('Thm U8 numbers:'); confirm_numbers()
