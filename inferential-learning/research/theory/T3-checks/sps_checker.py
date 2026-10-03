"""Mini Structured-Physics-Solution checker for the chair-leg problem (T3 section 6).
Not a general system: it hard-codes one top model and two bridge schemas, to show what the checks are
and how an adversarial SPS gets rejected. SymPy stands in for a proof kernel (flagged in the text).

Trusted base: (i) the problem specification (formal reading spec: given symbols, free completion
parameters with ranges, conventions); (ii) the top model M_top (vertical specular cylinder, point sun,
geometric optics) and its exact illuminance theorem E_top = I0 a c/(2 s + a c), c = sin(psi/2), proved in
leg_exact.py; (iii) the bridge catalogue: thin-leg bound B_TL(eps, sig), point-sun bound B_PS(Delta, sig)."""
import numpy as np, sympy as sp

a, r, phi, I0, I, alpha, L = sp.symbols('a r phi I0 I alpha L', positive=True)
SPEC = dict(given={a, I0, L}, point={r, phi}, free={alpha: (np.radians(30), np.radians(60))},
            conventions={"specular", "reflectance=1", "geometric_optics", "leg_vertical", "lit_full_height",
                         "incoherent_addition"}, dims={a: 'L', r: 'L', L: 'L', I0: 'E', I: 'E', phi: '1', alpha: '1'},
            target_dim='E', sun_radius=4.65e-3, L_over_a=60.0)
def B_TL(eps, sig):
    m = np.arcsin(eps)/2
    lo, hi = 1 - m/sig, (1 + m/sig)/(np.sqrt(1 - eps**2) - eps/2)
    return max(hi - 1, 1 - lo)
def composite(eps, sig, alpha_min, ds):
    D = np.arcsin(np.sin(ds)/np.sin(alpha_min)); s2 = sig - D/2; m = np.arcsin(eps)/2
    lo, hi = 1 - m/s2, (1 + m/s2)/(np.sqrt(1 - eps**2) - eps/2)
    return max((1 + D/(2*sig))*hi - 1, 1 - (1 - D/(2*sig))*lo)

def dim_of(expr):
    """dimension of a product of powers of spec symbols; dimensionless functions (sin, cos of angles) and numbers skipped"""
    out = {}
    for f in sp.Mul.make_args(sp.factor(expr)):
        base, ex = f.as_base_exp()
        if base.is_number: continue
        if isinstance(base, sp.Function):
            if all(SPEC['dims'].get(x) == '1' for x in base.free_symbols): continue
            return None
        d = SPEC['dims'].get(base)
        if d is None: return None
        if d != '1': out[d] = out.get(d, 0) + ex
    return {k: v for k, v in out.items() if v != 0}

def check(sps):
    rep = []; ok = True
    def fail(msg): nonlocal ok; ok = False; rep.append("REJECT: " + msg)
    # C0 reading containment: the solver's reading must not narrow the spec (free params keep their ranges)
    for p, rng_ in SPEC['free'].items():
        if sps['reading'].get(p) != rng_: fail(f"reading narrows free completion parameter {p} (J-layer unless spec is formal)")
    # C1 answer type: allowed symbols and dimension
    ans = sps['answer']; allowed = SPEC['given'] | SPEC['point'] | set(SPEC['free'])
    if not ans.free_symbols <= allowed: fail(f"answer uses symbols outside the 'express in terms of' list: {ans.free_symbols - allowed}")
    d = dim_of(ans)
    if d != {'E': 1}: fail(f"dimension {d} != {SPEC['target_dim']}")
    # C2 no silent imports
    extra = set(sps['conventions']) - SPEC['conventions']
    if extra: fail(f"silent/undeclared imports {extra}")
    # C3 completion invariance over free parameters (supervaluation): oscillation of ans relative to the top-model value
    thin = a*I0/2*sp.sin(phi/2)/r
    ratio = sp.simplify(ans/thin)
    if ratio.free_symbols & set(SPEC['free']):
        lo_, hi_ = SPEC['free'][alpha]
        f = sp.lambdify(alpha, ratio.subs({}), 'numpy'); vals = f(np.linspace(lo_, hi_, 101))
        osc = (np.max(vals) - np.min(vals))/2
        if osc > sps['tol']: fail(f"answer not completion-invariant: half-oscillation over alpha = {osc:.3f} > tol")
    elif sp.simplify(ratio - 1) != 0:
        fail(f"answer differs from the certified leading-order form by factor {ratio}")
    # C4 bridges: side conditions evaluated at the PARENT's values (domain declared at the root)
    for b in sps['bridges']:
        if b['evaluated_in'] != 'parent': fail(f"bridge {b['name']}: side condition evaluated in child context ({b['note']})"); continue
    r_min, sig_min = sps['domain']['r_min_over_a'], sps['domain']['sigma_min']
    amin = SPEC['free'][alpha][0]
    r_max = SPEC['L_over_a']*np.tan(amin - SPEC['sun_radius'])
    if sps['domain']['r_max_over_a'] > r_max + 1e-9: fail(f"domain exceeds the lit disk for some admissible alpha (r_max <= {r_max:.2f} a)")
    bound = composite(1/r_min, sig_min, amin, SPEC['sun_radius'])   # worst corner: B increasing in eps, decreasing in sigma
    if bound > sps['tol']: fail(f"bridge budget {bound:.4f} > tolerance {sps['tol']}")
    if ok: rep.append(f"ACCEPT: |E_true/answer - 1| <= {bound:.4f} on r in [{r_min}a, {sps['domain']['r_max_over_a']}a], sin(phi/2) >= {sig_min}, all alpha in spec")
    return ok, rep

honest = dict(reading={alpha: SPEC['free'][alpha]}, answer=a*I0/2*sp.sin(phi/2)/r, conventions=["specular", "reflectance=1", "geometric_optics"],
              bridges=[dict(name="thin-leg", evaluated_in="parent", note=""), dict(name="point-sun", evaluated_in="parent", note="")],
              domain=dict(r_min_over_a=25.0, r_max_over_a=10.0*0 + 10.9, sigma_min=0.6), tol=0.05)
# L = 60a, alpha_min = 30 deg: every admissible completion lights the disk r <= 60 tan(30 deg - 0.27 deg) a = 34.3 a.
honest['domain'] = dict(r_min_over_a=20.0, r_max_over_a=34.0, sigma_min=0.5); honest['tol'] = 0.10
variants = {
  "honest (L=60a, r in [20a,34a], sin(phi/2)>=0.5, 10%)": honest,
  "V1 overclaims domain (r >= 5a)": {**honest, 'domain': dict(r_min_over_a=5.0, r_max_over_a=34.0, sigma_min=0.5)},
  "V2 side condition in child (a:=0 there)": {**honest, 'bridges': [dict(name="thin-leg", evaluated_in="child", note="eps evaluated as 0 in the a=0 context")]},
  "V3 alpha-dependent answer (I instead of I0)": {**honest, 'answer': a*I0/(2*sp.cos(alpha))*sp.sin(phi/2)/r},
  "V4 narrows reading alpha=45deg": {**honest, 'reading': {alpha: (np.radians(45), np.radians(45))}},
  "V5 silent import (diffuse correction)": {**honest, 'conventions': honest['conventions'] + ["lambertian_fraction=0.1"]},
}
variants['V0 same SPS, 5% tolerance'] = {**honest, 'tol': 0.05}
for name, sps in variants.items():
    ok, rep = check(sps); print(f"{name}:"); [print("    " + x) for x in rep]
