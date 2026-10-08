"""Reproduce growth ratios and translate published Jones fits to the toy budget.

Inputs: authors' archived source tables/notebooks; retrieved 2026-09-11.
No calendar-time series is treated as measured cumulative research FLOPs.
The k0 calibration is supplied by the user's original toy model.
"""
import csv
import json
import math
from datetime import datetime
from pathlib import Path

import numpy as np
from scipy.stats import linregress, theilslopes

HERE = Path(__file__).resolve().parent
N = 1e120
K0 = 10**-27.5
SOURCES = {
    "2024": "https://arxiv.org/html/2405.10494v1#S5.T7",
    "2025": "https://epoch.ai/gradient-updates/the-software-intelligence-explosion-debate-needs-experiments",
    "2025_code": "https://github.com/parkerwhitfill/epoch_RRD/blob/main/code/bayesian.ipynb",
    "2025_growth_code": "https://github.com/parkerwhitfill/epoch_RRD/blob/main/code/steady_state.py",
}
# beta and lambda arrays are [q05, q50, q95]; r is [q05,q25,q50,q75,q95].
PUBLISHED = [
    (2024,"Computer vision",[.224,.985,4.050],[.290,1.410,6.021],[.821,1.243,1.437,1.597,2.420],1.45),
    (2024,"Atari RL",[.212,1.023,3.914],[.266,1.482,6.650],[.459,1.103,1.583,2.014,3.673],1.66),
    (2024,"SAT",[.139,.648,2.891],[.387,2.143,11.312],[1.279,2.642,3.542,4.230,6.897],4.17),
    (2024,"Linear programming",[.254,1.290,4.953],[.222,1.259,5.772],[.245,.681,1.077,1.508,3.095],1.51),
    (2025,"Computer vision",[.245,1.038,4.259],[.269,1.302,5.571],[.727,1.095,1.262,1.393,2.094],1.2638),
    (2025,"Atari RL",[.250,1.165,4.362],[.241,1.299,5.581],[.380,.868,1.201,1.497,2.708],1.2357),
    (2025,"NLP",[.187,.835,3.637],[.322,1.586,7.148],[1.069,1.627,1.892,2.099,3.212],1.8964),
]

def toy(b):
    """k(x)=1/(1/k0+b*x); fixed raw throughput, full recursive benefit.

    Results labelled derivative threshold; exact single-FLOP multiplier differs
    by a relative O(k) at the crossing, negligible at reported precision.
    """
    if b > 0:
        stop=(N-1/K0)/(1+b)
        return dict(b=b,status="finite optimum",stop_flops=stop,
                    stop_fraction=stop/N,threshold_flops=(1e120-1/K0)/b,
                    threshold_within_budget=b>=1,
                    gain_at_stop_in_units_1e_minus_120=N/(N-stop),
                    divergence_flops=None)
    if b == 0:
        return dict(b=b,status="constant gain; spend until remaining budget equals 1/k0",stop_flops=N-1/K0,
                    stop_fraction=1.,threshold_flops=None,
                    remaining_at_stop=1/K0,divergence_flops=None)
    xs=-1/(K0*b)
    if xs < N:
        return dict(b=b,status="finite-compute singularity; no finite optimum",stop_flops=None,
                    stop_fraction=None,threshold_flops=None,divergence_flops=xs)
    raise ValueError("Tiny negative b branch not used in these empirical inputs")

def probability_bounds(qs, threshold=1):
    levels=[.05,.25,.5,.75,.95]
    lower=0.;upper=1.
    for p,q in zip(levels,qs):
        if q < threshold: lower=p
        elif q > threshold:
            upper=p;break
    return [lower,upper]

def growth_fit(x,y,method):
    x=np.array(x,float);y=np.log(np.array(y,float))
    if method=="OLS":
        res=linregress(x,y)
        return dict(slope=float(res.slope),se=float(res.stderr),r2=float(res.rvalue**2),n=len(x))
    if method=="endpoint":
        return dict(slope=float((y[-1]-y[0])/(x[-1]-x[0])),n=len(x))
    return dict(slope=float(theilslopes(y,x).slope),n=len(x))

def main():
    rows=[]
    for year,name,beta,lam,r,naive in PUBLISHED:
        rows.append(dict(year=year,domain=name,beta_quantiles=beta,lambda_quantiles=lam,r_quantiles=r,
            source=SOURCES[str(year)],
            joint_posterior_available=False,
            prob_beta_gt_lambda_bounds=probability_bounds(r),
            jones_plugin_from_separate_medians=toy(beta[1]-lam[1]),
            cumulative_effort_surrogate_from_median_r=toy(1/r[2]-1),
            cumulative_effort_surrogate_from_naive_r=toy(1/naive-1),
            note="Difference of marginal medians is a plug-in sensitivity, not the posterior median difference. r= lambda/beta is not a cumulative-effort exponent without an extra closure."))
    # Refit actual source CSV inputs. Only 2022-2025 historical estimates included;
    # the source file also contains forecast values for 2026 onward, excluded.
    with (HERE/'sources/data/openai_rd_spend_flops.csv').open() as f:
        compute=[r for r in csv.DictReader(f) if 2022<=int(r['year'])<=2025]
    with (HERE/'sources/data/ai_companies/ai_companies_staff_reports.csv').open() as f:
        staff=[r for r in csv.DictReader(f) if r['Company']=='OpenAI' and r['Date']>='2022-01-01']
    dates=[datetime.fromisoformat(r['Date']) for r in staff]
    time=[d.year+(d.timetuple().tm_yday-1)/365.25 for d in dates]
    heads=[float(r['Staff count']) for r in staff]
    years=[int(r['year']) for r in compute]
    flops=[float(r['estimated_total_flops']) for r in compute]
    growth=[]
    for method in ['OLS','endpoint','Theil-Sen']:
        labor=growth_fit(time,heads,method);capital=growth_fit(years,flops,method)
        for eps in [.59,.67,.75]:
            denom=eps*capital['slope']+(1-eps)*labor['slope']
            r=math.log(3)/denom
            growth.append(dict(method=method,epsilon_K=eps,g_A=math.log(3),labor_fit=labor,compute_fit=capital,
                r=r,source=SOURCES['2025_growth_code'],
                jones_b="not identified: beta and lambda are not separately identified",
                cumulative_effort_full_feedback=toy(1/r-1),
                cumulative_effort_cognitive_only_feedback=toy(1/r-(1-eps))))
    rounded_r=1.1/(.67*1.3+.33*.85)
    rng=np.random.default_rng(20260911)
    gL=growth[1]['labor_fit'];gK=growth[1]['compute_fit'];ndraw=200000
    Ldraw=rng.normal(gL['slope'],gL['se'],ndraw)
    Kdraw=rng.normal(gK['slope'],gK['se'],ndraw)
    share=rng.triangular(.59,.67,.75,ndraw)
    # Match the source's assumed 90% 2x--5x/year numerator range. Its
    # simulation center ln(sqrt(10)) differs from the displayed point ln(3).
    from scipy.special import ndtri
    adraw=rng.normal((math.log(2)+math.log(5))/2,(math.log(5)-math.log(2))/(2*ndtri(.95)),ndraw)
    rdraw=adraw/(share*Kdraw+(1-share)*Ldraw)
    valid=rdraw>0;finite=valid&(rdraw<1)
    growth_uncertainty=dict(draws=ndraw,seed=20260911,
        method="Author-assumed Gaussian growth uncertainties plus triangular compute share; not a calibrated posterior over the universal toy law",
        r_quantiles=np.quantile(rdraw,[.025,.05,.5,.95,.975]).tolist(),
        probability_finite_stop_under_cumulative_surrogate=float(finite.mean()),
        probability_singularity_under_cumulative_surrogate=float((rdraw>1).mean()),
        probability_nonpositive_r=float((rdraw<=0).mean()),
        conditional_finite_stop_fraction_quantiles=np.quantile(rdraw[finite],[.05,.5,.95]).tolist())
    result=dict(N=N,k0=K0,published=rows,growth_refits=growth,
        growth_uncertainty=growth_uncertainty,
        original_rounded_growth_ratio=dict(r=rounded_r,full_feedback_surrogate=toy(1/rounded_r-1)),
        input_staff=[dict(date=d.strftime('%Y-%m-%d'),count=h) for d,h in zip(dates,heads)],
        input_compute=[dict(year=y,flops=f) for y,f in zip(years,flops)],
        sources=SOURCES)
    (HERE/'published_results.json').write_text(json.dumps(result,indent=2)+'\n')
    print('Published domain plug-ins:')
    for r in rows:
        print(r['year'],r['domain'],r['jones_plugin_from_separate_medians'],r['prob_beta_gt_lambda_bounds'])
    print('\nGrowth refits:')
    for r in growth:
        print(r['method'],r['epsilon_K'],'r',r['r'],'gL',r['labor_fit']['slope'],'gK',r['compute_fit']['slope'],'stop',r['cumulative_effort_full_feedback']['stop_flops'],'cognitive-only',r['cumulative_effort_cognitive_only_feedback']['stop_flops'])

if __name__=='__main__':main()
