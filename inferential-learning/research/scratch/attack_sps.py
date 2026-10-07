import sys, io, contextlib
sys.path.insert(0, '/home/user/AI-works/inferential-learning/research/theory/T3-checks')
with contextlib.redirect_stdout(io.StringIO()):
    import sps_checker as S
import sympy as sp, numpy as np
a, I0, r, phi, alpha, L = S.a, S.I0, S.r, S.phi, S.alpha, S.L
thin = a*I0/2*sp.sin(phi/2)/r
H = S.honest
tests = {
 'tol = nan': {**H, 'tol': float('nan')},
 'r_max = nan': {**H, 'domain': dict(r_min_over_a=20.0, r_max_over_a=float('nan'), sigma_min=0.5)},
 'sigma_min = nan': {**H, 'domain': dict(r_min_over_a=20.0, r_max_over_a=34.0, sigma_min=float('nan'))},
 'r_min = nan': {**H, 'domain': dict(r_min_over_a=float('nan'), r_max_over_a=34.0, sigma_min=0.5)},
 'answer uses L (allowed set includes L)': {**H, 'answer': thin*L/L},
 'answer thin*(1+0*L)': {**H, 'answer': thin + 0*L},
 'answer with Abs sin': {**H, 'answer': a*I0/2*sp.Abs(sp.sin(phi/2))/r},
 'empty bridges list': {**H, 'bridges': []},
 'answer thin*(sin(alpha)**2+cos(alpha)**2)': {**H, 'answer': thin*(sp.sin(alpha)**2+sp.cos(alpha)**2)},
 'answer thin*(1+Heaviside(phi-7))': {**H, 'answer': thin*(1+sp.Heaviside(phi-7))},
 'answer thin*sign(phi)': {**H, 'answer': thin*sp.sign(phi)},
 'answer thin*sqrt(r**2)/r': {**H, 'answer': thin*sp.sqrt(r**2)/r},
 'answer thin*exp(log(r))/r': {**H, 'answer': thin*sp.exp(sp.log(r))/r},
 'answer thin * (phi/phi)**(1)': {**H, 'answer': thin*sp.Float('1.0000000000000000001', 30)},
 'answer thin * Float(1.0)': {**H, 'answer': thin*1.0},
 'answer thin*cos(2*pi*floor(phi/(2*pi)))': {**H, 'answer': thin*sp.cos(2*sp.pi*sp.floor(phi/(2*sp.pi)))},
 'widened reading alpha in [20,70]': {**H, 'reading': {alpha: (np.radians(20), np.radians(70))}},
 'sigma_min=1e-9': {**H, 'domain': dict(r_min_over_a=20.0, r_max_over_a=34.0, sigma_min=1e-9)},
 'r_max < r_min': {**H, 'domain': dict(r_min_over_a=30.0, r_max_over_a=25.0, sigma_min=0.5)},
 'tol = inf': {**H, 'tol': float('inf')},
}
for name, sps in tests.items():
    try:
        ok, rep = S.check(sps)
        print(f'{name}: {"ACCEPT" if ok else "REJECT"} | {rep[-1][:110]}')
    except Exception as e:
        print(f'{name}: EXCEPTION {type(e).__name__}: {e}')
