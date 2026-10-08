"""Theory diagnostics only; no empirical fitting and no posterior calibration.
Run from any directory with python -B this_file.
All outputs stay beside this file. Prior modules are read without bytecode writes.
"""
from pathlib import Path
import csv
import hashlib
import json
import math
import sys
sys.dont_write_bytecode = True
import numpy as np
from scipy.optimize import brentq

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[1]
sys.path.insert(0, str(ROOT / 'forecast_revision'))
from math_model import CeilingModel, ExponentialCeilingModel, ContinuumCeilingModel

N = 1e120
K = 1e-29
LN10 = math.log(10)


def logadd(x, y):
    return float(np.logaddexp(x, y))


def efficiency_exponential(logH):
    """a(F)=H-(H-1)e^(-F/S), S=(H-1)/k0; exact raw law logistic."""
    lh = logH * LN10
    lm = lh + math.log1p(-math.exp(-lh))
    lr = math.log(K) + lh - lm
    def state(t):
        lx = math.log(t) - lr
        lk = lr + lm - t - logadd(0, lm-t)
        la = lh - logadd(0, lm-t)
        return lx, lk, la
    t = brentq(lambda t: logadd(state(t)[0], -state(t)[1])-math.log(N), 1e-10, 2000)
    lx, lk, la = state(t)
    return dict(log10_x=lx/LN10, log10_a=la/LN10,
                residual=logadd(lx,-lk)-math.log(N), coordinate=t)


def capped_power(logH, q=1):
    # Compute log(T_H) without materializing H^(1/q).
    u = logH * LN10 / q
    lcap = math.log(q/K) + (u + math.log1p(-math.exp(-u)))
    lfree = math.log(q/(q+1)) + math.log(N-1/K)
    lx = min(lcap, lfree)
    la = min(logH*LN10, q*math.log1p(K*math.exp(lx)/q))
    return dict(log10_x=lx/LN10, log10_a=la/LN10, cap_binds=lcap<lfree)


def weighted_quantiles(xs, ws):
    order = np.argsort(xs)
    xs = np.array(xs)[order]
    ws = np.array(ws)[order]
    keep = ws > 0
    xs, ws = xs[keep], ws[keep]
    cs = np.cumsum(ws)/sum(ws)
    return np.interp([.05,.25,.5,.75,.95], cs, xs).tolist()


def summarize(rows, weights):
    counts = {f:sum(r['family']==f for r in rows) for f in weights}
    xs = [r['x'] for r in rows]
    ws = [weights[r['family']]/counts[r['family']] for r in rows]
    return dict(quantiles_log10_x_05_25_50_75_95=weighted_quantiles(xs,ws),
                probability_x_ge_1pct_N=sum(w for x,w in zip(xs,ws) if x>=118))


def main():
    power = []
    for h in [3,12,30,60,120]:
        for p in [.03,.1,.25,.5,1,2]:
            r = CeilingModel(p,h,log10_k0=-29).solve(scan=False)
            power.append(dict(p=p, log10_H=h, log10_x=r['log10_optimal_x'],
                              log10_a=r['log10_a_at_optimum'], residual=r['economic_root_log_residual']))
    rival = []
    for h in [3,12,60,120]:
        for label, cls in [('exponential_cost_effective',ExponentialCeilingModel),
                           ('uniform_exponent_continuum',ContinuumCeilingModel)]:
            r = cls(h,log10_k0=-29).solve(scan=False)
            rival.append(dict(law=label, log10_H=h, log10_x=r['log10_optimal_x'],
                              log10_a=r['log10_a_at_optimum'], residual=r['economic_root_log_residual']))
        rival.append(dict(law='exponential_efficiency_effective', log10_H=h, **efficiency_exponential(h)))
        rival.append(dict(law='capped_raw_power_q1',log10_H=h,**capped_power(h)))
    # Reweight saved prior predictive draws, without fitting any observations.
    source = ROOT/'calibration_revision/calibration_draws.csv'
    rows = []
    with source.open() as f:
        for row in csv.DictReader(f):
            if row['calibration'] == 'fixed_-29':
                rows.append(dict(family=row['family'],x=float(row['log10_x_stop']), original=row))
    assert len(rows)==5120
    weights = dict(single_power_gap=.25, heterogeneous_gaps=.35, rapid_ceiling=.1,
                   continuous_slow_gaps=.1,scale_free_within_budget=.2)
    baseline = summarize(rows,weights)
    fast_substitution = []
    for row in rows:
        r = row['original']
        if row['family']=='heterogeneous_gaps':
            replacement=CeilingModel(float(r['p_fast']),float(r['log10_H']),log10_k0=-29).solve(scan=False)
            fast_substitution.append(dict(row,x=replacement['log10_optimal_x']))
        else:
            fast_substitution.append(row)
    # Continuum retained. This isolates the guaranteed slow component alone.
    replacement_result=summarize(fast_substitution,weights)
    family_summaries={f:summarize(rows,{g:float(g==f) for g in weights}) for f in weights}
    # A reset means this particular mechanism ceases to be valid; we intentionally
    # do not invent a post-reset law or treat weighted survivors as a full forecast.
    reset=[]
    for hazard in [0,.001,.01,.03,.1]:
        masses={f:0. for f in ['heterogeneous_gaps','continuous_slow_gaps']}
        late={f:0. for f in masses}
        for r in rows:
            f=r['family']
            if f not in masses: continue
            D=math.log1p(10**(r['x']-29))/LN10
            w=weights[f]/1024*math.exp(-hazard*D)
            masses[f]+=w
            if r['x']>=118: late[f]+=w
        reset.append(dict(hazard_per_raw_input_decade=hazard,unconditional_no_reset_mass=masses,
                          unconditional_no_reset_mass_x_ge_1pct_N=late,
                          note='Missing mass needs a post-reset model; not an updated full stopping distribution.'))
    # Hard ceiling alone gives weak bounds. Monotone-k bound is additional.
    headroom=[dict(H=h,general_fraction_bound=1-1/h,
                   monotone_k_fraction_bound=math.log(h)/(1+math.log(h))) for h in [2,10,1e6,1e12]]
    # Exact finite-prefix construction: a=1+Kx up to X, then constant until a jump.
    X=1e30; aX=1+K*X; prefix_best=aX*(N-X)
    future=[]
    for T in [1e31,1e60,1e100,1e119,9e119]:
        H=1e6
        assert H*(N-T)>prefix_best
        # F(T)=integral_0^T a(u)du, showing the shared-feedback realization.
        FT=X+K*X*X/2+aX*(T-X)
        future.append(dict(log10_T=math.log10(T),H=H,log10_F_at_breakthrough=math.log10(FT),
                           utility_jump_over_prefix=H*(N-T)/prefix_best))
    out=dict(date='2026-10-02',status='Theoretical counterexamples and prior sensitivity; not a fitted forecast.',
             log10_N=120,log10_k0=-29,power_gap_scenarios=power,rival_laws=rival,
             old_prior_baseline_fixed_k0=baseline,guaranteed_slow_component_removed_only=replacement_result,
             original_family_summaries=family_summaries,reset_survival_diagnostics=reset,
             ceiling_bounds=headroom,identical_prefix_counterexamples=dict(X=X,aX=aX,scenarios=future),
             input_sha256={str(source.relative_to(ROOT)):hashlib.sha256(source.read_bytes()).hexdigest(),
                           'forecast_revision/math_model.py':hashlib.sha256((ROOT/'forecast_revision/math_model.py').read_bytes()).hexdigest()},
             checks={})
    residuals=[abs(r['residual']) for r in power+rival if 'residual' in r]
    assert max(residuals)<1e-8
    # Independent analytic p=1 check, in the regime f dominates the effort integral.
    p1=next(r for r in power if r['p']==1 and r['log10_H']==12)
    assert abs(p1['log10_x']-74.5)<1e-8
    assert abs(capped_power(12)['log10_x']-41)<1e-8
    # Verify the effective-feedback logistic solution on a moderate parameter case.
    H=7.; k=.04; S=(H-1)/k
    errors=[]
    for F in [1.,10.,100.]:
        step=1e-4
        def ax(F):
            a=H-(H-1)*math.exp(-F/S)
            x=S/H*math.log(H*math.exp(F/S)-(H-1))
            return a,x
        a,x=ax(F); ap,xp=ax(F+step); am,xm=ax(F-step)
        errors.append(abs((xp-xm)/(2*step)-1/a))
        # d ln a/dx= da/dF for shared feedback.
        errors.append(abs((math.log(ap)-math.log(am))/(xp-xm)-(H-1)/S*math.exp(-F/S)))
    assert max(errors)<1e-8
    out['checks']=dict(max_economic_log_root_residual=max(residuals),
                       max_logistic_feedback_absolute_error=max(errors),
                       identical_prefix_global_optimum_checks=True)
    (BASE/'theory_results.json').write_text(json.dumps(out,indent=2)+'\n')
    with (BASE/'rival_stopping_scenarios.csv').open('w',newline='') as f:
        writer=csv.DictWriter(f,fieldnames=['law','p','log10_H','log10_x','log10_a'],extrasaction='ignore')
        writer.writeheader()
        for row in power:
            writer.writerow(dict(row,law='power_cost_gap_effective'))
        for row in rival:
            writer.writerow(row)
    print(json.dumps({k:out[k] for k in ['old_prior_baseline_fixed_k0','guaranteed_slow_component_removed_only','reset_survival_diagnostics','checks']},indent=2))

if __name__=='__main__':
    main()
