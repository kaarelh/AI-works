"""Independent replication of AI2027 takeoff equations; no remote calls.

Run with python research_oct2026/takeoff/reproduce_original.py
Only this file's own folder receives outputs. Parameters transcribed from the
pinned public code under sources/original_code, not estimated from observations.
"""
from pathlib import Path
import ast
import json
import math
import numpy as np
from scipy.stats import norm

ROOT = Path(__file__).resolve().parent
SEED = 20261002
N = 1_000_000
rng = np.random.default_rng(SEED)


def lognormal(z, low, high):
    mu = math.log(low * high) / 2
    sigma = math.log(high / low) / (2 * norm.ppf(.9))
    return np.exp(mu + sigma * z)


def phase_years(human_years, start, end):
    """Exact integral of dh/dt = start*(end/start)**(h/human_years)."""
    return human_years * (1/start - 1/end) / math.log(end/start)


def quantiles(a):
    return dict(zip(['p10','p25','p50','p75','p90','p99'],
                    map(float, np.quantile(a,[.1,.25,.5,.75,.9,.99]))))


def main():
    z = rng.multivariate_normal([0.,0.], [[1.,.8],[.8,1.]], size=N)
    amr_sar = lognormal(z[:,0], 1.,25.)
    sc_sar = lognormal(z[:,1], 1.5,10.)
    sc_sar[rng.random(N)<.15] = 0.
    jumps = lognormal(rng.normal(size=N), .3,7.5)
    sar_stock = 10 + amr_sar
    siar_stock = sar_stock * (sar_stock/10)**2
    sar_siar = siar_stock - sar_stock
    # Keep log-domain for the extreme lognormal-of-lognormal ASI tail.
    log_stock_ratio = jumps * np.log(siar_stock/sar_stock)
    with np.errstate(over='ignore'):
        siar_asi = siar_stock * np.expm1(log_stock_ratio)
    phase = np.stack([phase_years(sc_sar,5,25),
                      phase_years(sar_siar,25,250),
                      phase_years(siar_asi,250,2000)],axis=1)
    # Upstream has hard-coded day Euler steps and a 1,000-year per-phase cap.
    capped = np.minimum(phase,1000)
    source = ROOT/'sources/original_code/takeoff/forecasting_takeoff.py'
    tree = ast.parse(source.read_text())
    fn = next(n for n in tree.body if isinstance(n,ast.FunctionDef) and n.name=='run_phase_simulation')
    scope = {}
    exec(compile(ast.Module(body=[fn],type_ignores=[]),str(source),'exec'),scope)
    euler = scope['run_phase_simulation']
    checks=[]
    for h,s,e in [(4,5,25),(18.75,25,250),(80.15625,250,2000),(.01,5,25),(1000,25,250)]:
        exact=phase_years(h,s,e)*365
        actual=euler(h*365,s,e)
        checks.append(dict(human_years=h,start=s,end=e,continuous_days=exact,upstream_days=actual,
                           difference_days=actual-exact))
        assert actual>=exact
        assert actual-exact < 8
    out={
      'scope':'Replication of the stated probability model and exact continuous interpolation, not a newly fitted forecast.',
      'commit':'2085376a178d709ec9c1461f5eef59e543751cd7',
      'seed':SEED,'draws':N,
      'upstream_correlation':'0.8 correlation of underlying normal variates; zero atom assigned independently',
      'unused_parameter':'time_gaps correlation 0.7 affects unused ASI-to-WS draw, not used SC/SAR/SIAR/ASI chain',
      'human_only_years':dict(zip(['SC_SAR','SAR_SIAR','SIAR_ASI'],map(quantiles,[sc_sar,sar_siar,siar_asi]))),
      'calendar_phase_years':dict(zip(['SC_SAR','SAR_SIAR','SIAR_ASI'],map(quantiles,phase.T))),
      'calendar_cumulative_years':dict(zip(['SC_SAR','SC_SIAR','SC_ASI'],map(quantiles,np.cumsum(phase,axis=1).T))),
      'calendar_cumulative_years_with_upstream_cap':dict(zip(['SC_SAR','SC_SIAR','SC_ASI'],map(quantiles,np.cumsum(capped,axis=1).T))),
      'phase_cap_probabilities':dict(zip(['SC_SAR','SAR_SIAR','SIAR_ASI'],map(float,np.mean(phase>=1000,axis=0)))),
      'euler_checks':checks,
      'calibration_arithmetic':{
        'r_from_5x_value_gain_10_to_15_stock':math.log(5)/math.log(1.5),
        'r_from_5x_value_gain_10_to_20_stock':math.log(5)/math.log(2),
        'experiment_compute_elasticity_from_0p4_at_0p1':math.log(.4)/math.log(.1),
        'serial_uplift_at_30_with_constant_elasticity':30**(1-math.log(.4)/math.log(.1)),
        'all_input_medians_human_gaps':[math.sqrt(15),18.75,33.75*(2.25**1.5-1)],
        'all_input_medians_calendar_total':phase_years(math.sqrt(15),5,25)+phase_years(18.75,25,250)+phase_years(33.75*(2.25**1.5-1),250,2000)
      },
      'not_present_in_upstream':['raw research FLOPs','universal output multiplier','optimization against remaining consumption budget','asymptotic algorithmic ceiling function']
    }
    (ROOT/'original_replication.json').write_text(json.dumps(out,indent=2)+'\n')
    print(json.dumps(out,indent=2))


if __name__=='__main__':
    main()
