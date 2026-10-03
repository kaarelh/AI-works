"""Mini Structured-Physics-Solution checker for the chair-leg problem (T3 section 6).
Not a general system: it hard-codes one top model and two bridge schemas, to show what the checks are
and how an adversarial SPS gets rejected. SymPy stands in for a proof kernel (flagged in the text).

Trusted base: (i) the problem specification (formal reading spec: given symbols, free completion
parameters with ranges, conventions); (ii) the top model M_top (vertical specular cylinder, point sun,
geometric optics) and its exact illuminance theorem E_top = I0 a c/(2 s + a c), c = sin(psi/2), proved in
leg_exact.py; (iii) the bridge catalogue: thin-leg bound B_TL(eps, sig), point-sun bound B_PS(Delta, sig).

REVISED AFTER VERIFICATION. A referee showed the first version was unsound: it ACCEPTED
  answer = 2*thin*cos(alpha)**(1/1000)   (true error ~0.5, certified '<= 0.0888'),
  answer = (23/20)*thin*cos(alpha)**(1/50) (true error 0.159 > tol 0.10),
  answer = 1.5*thin*exp(alpha/1000),
  domain r_min = 1.05a, sigma_min = 1, tol 0.7 (bridge hypothesis eps < 2/sqrt5 violated; true error 0.909).
Causes: C1 allowed the free-completion symbol alpha in the answer; C3 checked only the oscillation over
alpha of answer/certified-form, never its offset from 1; C4 never enforced the hypotheses of Props 6.2/6.3.
Fixes: C1 forbids free-completion symbols (the answer type of T3 section 6.1 is a function of (a, I0, r, phi));
C3 requires answer/certified-form == 1 identically (a fuller checker would instead add a rigorously enclosed
offset to the budget); C4 asserts every hypothesis of Props 6.2/6.3 before using their bounds.
V2 and V5 are rejections of SELF-DECLARED violations (the SPS records the context of each side condition
and its imports).  The semantic protection is elsewhere: C4 recomputes every side condition from root data,
so a silent child evaluation cannot change the budget, and C3 rejects any answer that differs from the form
certified from the declared imports (V11: a silent 10% diffuse correction with honest declarations)."""
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
    ans = sps['answer']; allowed = SPEC['given'] | SPEC['point']          # revised: free-completion symbols NOT allowed
    if not ans.free_symbols <= allowed: fail(f"answer uses symbols outside the 'express in terms of' list (a, I0, r, phi): {ans.free_symbols - allowed}")
    d = dim_of(ans)
    if d != {'E': 1}: fail(f"dimension {d} != {SPEC['target_dim']}")
    # C2 no silent imports
    extra = set(sps['conventions']) - SPEC['conventions']
    if extra: fail(f"silent/undeclared imports {extra}")
    # C3 completion invariance over free parameters (supervaluation): oscillation of ans relative to the top-model value
    thin = a*I0/2*sp.sin(phi/2)/r
    ratio = sp.simplify(ans/thin)
    # The top-model quantity is exactly alpha-invariant (Prop 6.1(d), trusted theorem), and the certified form
    # 'thin' is alpha-free; the answer must coincide with it identically (revised: no oscillation-only test).
    if ratio.free_symbols & set(SPEC['free']):
        lo_, hi_ = SPEC['free'][alpha]
        f = sp.lambdify(alpha, ratio, 'numpy'); vals = f(np.linspace(lo_, hi_, 101))
        osc = (np.max(vals) - np.min(vals))/2
        fail(f"answer not completion-invariant (diagnostic: half-oscillation over alpha = {osc:.3f})")
    elif sp.simplify(ratio - 1) != 0:
        fail(f"answer differs from the certified leading-order form by factor {ratio}")
    # C4 bridges: side conditions evaluated at the PARENT's values (domain declared at the root)
    for b in sps['bridges']:
        if b['evaluated_in'] != 'parent': fail(f"bridge {b['name']}: side condition evaluated in child context ({b['note']})"); continue
    r_min, sig_min = sps['domain']['r_min_over_a'], sps['domain']['sigma_min']
    amin, amax = SPEC['free'][alpha]; ds = SPEC['sun_radius']
    r_max = SPEC['L_over_a']*np.tan(amin - ds)
    if sps['domain']['r_max_over_a'] > r_max + 1e-9: fail(f"domain exceeds the lit disk for some admissible alpha (r_max <= {r_max:.2f} a)")
    # revised: hypotheses of Props 6.2/6.3 at the worst corner, all from ROOT data (never from the SPS's own claims)
    hyp_ok = True
    def hyp(cond, msg):
        nonlocal hyp_ok
        if not cond: hyp_ok = False; fail("bridge hypothesis violated: " + msg)
    hyp(r_min <= sps['domain']['r_max_over_a'], "r_min <= r_max")
    hyp(r_min > 1 and 1/r_min < 2/np.sqrt(5), f"eps = a/r_min = {1/r_min:.3f} < 2/sqrt5")
    hyp(0 < sig_min <= 1, "0 < sigma_min <= 1")
    hyp(ds < amin and amax <= np.pi/2, "delta_s < alpha_min and alpha_max <= pi/2")
    if hyp_ok:
        D = np.arcsin(np.sin(ds)/np.sin(amin))
        hyp(sig_min - D/2 > np.arcsin(1/r_min)/2, f"sigma_min - Delta/2 > arcsin(eps)/2 = {np.arcsin(1/r_min)/2:.3f}")
    if hyp_ok:
        bound = composite(1/r_min, sig_min, amin, ds)   # worst corner: increasing in eps, Delta; decreasing in sigma
        if bound > sps['tol']: fail(f"bridge budget {bound:.4f} > tolerance {sps['tol']}")
    if ok: rep.append(f"ACCEPT: |E_true/answer - 1| <= {bound:.4f} on r in [{r_min}a, {sps['domain']['r_max_over_a']}a], sin(phi/2) >= {sig_min}, all alpha in spec")
    return ok, rep

# L = 60a, alpha_min = 30 deg: every admissible completion lights the disk r <= 60 tan(30 deg - 0.27 deg) a = 34.3 a.
honest = dict(reading={alpha: SPEC['free'][alpha]}, answer=a*I0/2*sp.sin(phi/2)/r, conventions=["specular", "reflectance=1", "geometric_optics"],
              bridges=[dict(name="thin-leg", evaluated_in="parent", note=""), dict(name="point-sun", evaluated_in="parent", note="")],
              domain=dict(r_min_over_a=20.0, r_max_over_a=34.0, sigma_min=0.5), tol=0.10)
variants = {
  "honest (L=60a, r in [20a,34a], sin(phi/2)>=0.5, 10%)": honest,
  "V1 overclaims domain (r >= 5a)": {**honest, 'domain': dict(r_min_over_a=5.0, r_max_over_a=34.0, sigma_min=0.5)},
  "V2 side condition in child (a:=0 there)": {**honest, 'bridges': [dict(name="thin-leg", evaluated_in="child", note="eps evaluated as 0 in the a=0 context")]},
  "V3 alpha-dependent answer (I instead of I0)": {**honest, 'answer': a*I0/(2*sp.cos(alpha))*sp.sin(phi/2)/r},
  "V4 narrows reading alpha=45deg": {**honest, 'reading': {alpha: (np.radians(45), np.radians(45))}},
  "V5 silent import (diffuse correction)": {**honest, 'conventions': honest['conventions'] + ["lambertian_fraction=0.1"]},
}
variants['V0 same SPS, 5% tolerance'] = {**honest, 'tol': 0.05}
# added after verification: the referee's attacks on the first version, plus controls
variants['V6 2*thin*cos(alpha)^(1/1000) (accepted by the first version)'] = {**honest, 'answer': 2*a*I0/2*sp.sin(phi/2)/r*sp.cos(alpha)**sp.Rational(1, 1000)}
variants['V7 (23/20)*thin*cos(alpha)^(1/50) (accepted by the first version)'] = {**honest, 'answer': sp.Rational(23, 20)*a*I0/2*sp.sin(phi/2)/r*sp.cos(alpha)**sp.Rational(1, 50)}
variants['V8 1.5*thin*exp(alpha/1000) (accepted by the first version)'] = {**honest, 'answer': sp.Rational(3, 2)*a*I0/2*sp.sin(phi/2)/r*sp.exp(alpha/1000)}
variants['V9 r_min=1.05a, sigma_min=1, tol 0.7 (accepted by the first version)'] = {**honest, 'domain': dict(r_min_over_a=1.05, r_max_over_a=34.0, sigma_min=1.0), 'tol': 0.7}
variants['V10 constant factor 1.09*thin (control)'] = {**honest, 'answer': sp.Rational(109, 100)*a*I0/2*sp.sin(phi/2)/r}
variants['V11 silent 10% diffuse correction, honest declarations'] = {**honest, 'answer': sp.Rational(11, 10)*a*I0/2*sp.sin(phi/2)/r}
for name, sps in variants.items():
    ok, rep = check(sps); print(f"{name}:"); [print("    " + x) for x in rep]
