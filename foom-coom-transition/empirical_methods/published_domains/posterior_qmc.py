"""Independent small Sobol importance refit of the authors' Feller posterior.

Uses the same 4 independent unit half-Cauchy priors and endpoint observations,
but an exact noncentral-chi-square transition instead of the notebook's finite
gamma sum. These are new numerical estimates, NOT recovered author draws.
"""
import json
from pathlib import Path
import warnings
import numpy as np
from scipy.special import logsumexp, gammaln
from scipy.stats import ncx2, qmc

HERE=Path(__file__).resolve().parent
CASES={
    '2025 Computer vision':(10,120/9*np.log(2),np.cumsum([62,147,390,924,2252,4027,6425,7554,9091,13866])),
    '2025 Atari RL':(5,60/11*np.log(2),np.cumsum([1334,1511,2269,3986,6323,8476])[:5]),
    '2025 NLP':(10,120/8*np.log(2),np.cumsum([96,154,320,636,1058,1381,1654,1982,3408,2654])),
    '2024 Computer vision':(10,120/9*np.log(2),np.array([111,174,505,1446,3564,7821,14147,22062,25758,34543])),
    '2024 Atari RL':(5,60/11*np.log(2),np.array([3233,4123,6932,12536,20041])),
    '2024 SAT':(21,21/2*np.log(2),np.array([147,175,176,229,292,389,387,445,526,484,617,560,606,644,633,709,781,709,609,701,776])),
    '2024 Linear programming':(20,np.log(9),np.array([1557,1628,1808,1805,2079,2315,2393,2979,3486,3560,4097,4459,5021,5443,5556,5965,6247,6065,6134,6201])),
}

def weighted_quantile(values,weights,qs):
    order=np.argsort(values);v=values[order];w=weights[order]
    cum=np.cumsum(w);cum/=cum[-1]
    return np.interp(qs,cum,v).tolist()

def ncx2_centered_logpdf(y,df,nc):
    """Direct Poisson--gamma log mixture centered at its term mode.

    Used only for the handful of moderate-argument Boost NaNs; the width
    retains well beyond 20 standard deviations of the summand distribution.
    """
    x=y/2;z0=nc/2;nu=df/2-1
    root=np.sqrt(nu*nu+4*z0*x)
    mode=max(0,int(2*z0*x/(root+nu) if nu>=0 else (root-nu)/2))
    width=int(30*np.sqrt(mode+1)+100)
    if width>1000000:
        return np.nan
    m=np.arange(max(0,mode-width),mode+width+1,dtype=float)
    return logsumexp(-z0+m*np.log(z0)-gammaln(m+1)-x+(m+nu)*np.log(x)-gammaln(m+nu+1))-np.log(2)

def verify_transition():
    # Check the ncx2 identity against the authors' gamma-series formula.
    errors=[]
    for xt,z0,cbar in [(1.,2.,.5),(4.,3.,1.5),(100.,90.,3.),(.1,.5,.1)]:
        m=np.arange(20000,dtype=float)
        nu=cbar-1
        series=logsumexp(-z0+m*np.log(z0)-gammaln(m+1)-xt+(m+nu)*np.log(xt)-gammaln(m+nu+1))
        closed=np.log(2)+ncx2.logpdf(2*xt,2*cbar,2*z0)
        errors.append(abs(series-closed))
    assert max(errors)<1e-10, errors
    # scipy's logpdf uses a scaled Bessel function that can underflow at
    # large degrees of freedom even close to the distribution's mean.
    # The Boost-backed pdf follows a different implementation. Check its
    # recovered values against a centered Poisson--gamma mixture, retaining
    # the mode even when it lies beyond the source's first 20,000 terms.
    recovered_errors=[]
    for y,df,nc in [(52338.889676795545,52475.40611107649,.02416335589000339),
                    (5472.024043444317,5760.864856707594,51.53786867911565),
                    (525009.8217011407,492339.9264565777,56859.378668488294)]:
        series=ncx2_centered_logpdf(y,df,nc)
        recovered=np.log(ncx2.pdf(y,df,nc))
        assert np.isfinite(recovered)
        recovered_errors.append(abs(series-recovered))
    assert max(recovered_errors)<2e-8,recovered_errors
    return dict(original_kernel_max_abs_log_error=max(errors),
                recovered_large_df_max_abs_log_error=max(recovered_errors))

def run(case,seed,power):
    years,log_a,inputs=CASES[case]
    u=qmc.Sobol(4,scramble=True,seed=seed).random_base2(power)
    lam,beta,sig,h=np.tan(np.pi/2*u).T
    log_rel=np.log(inputs/inputs[0]);gI=log_rel[-1]/(years-1)
    logT=logsumexp(lam[:,None]*log_rel[None,:],axis=1)+np.log(lam*gI/beta)
    logscale=2*np.log(beta)+2*np.log(sig)+logT-np.log(4)
    df=4*h/(sig**2*beta)+2*np.maximum(beta-1,0)/beta
    logy=beta*log_a-logscale; lognc=-logscale
    # Extremely small noncentrality uses the central chi-square limit in log
    # space; this retains high-lambda tails without exp underflow.
    central=np.isfinite(logy)&(logy<650)&(lognc < -50)&np.isfinite(df)
    ok=np.isfinite(logy)&(logy<650)&(lognc<650)&(logy>-650)&(lognc>=-50)&np.isfinite(df)
    logw=np.full(len(u),-np.inf)
    recovered_mask=np.zeros(len(u),dtype=bool)
    pdf_underflow_mask=np.zeros(len(u),dtype=bool)
    pdf_nonfinite_mask=np.zeros(len(u),dtype=bool)
    mixture_recovered_mask=np.zeros(len(u),dtype=bool)
    with warnings.catch_warnings():
        warnings.simplefilter('ignore')
        eligible=np.flatnonzero(ok)
        logdensity=ncx2.logpdf(np.exp(logy[ok]),df[ok],np.exp(lognc[ok]))
        failed=np.flatnonzero(~np.isfinite(logdensity))
        if len(failed):
            inds=eligible[failed]
            fallback=ncx2.pdf(np.exp(logy[inds]),df[inds],np.exp(lognc[inds]))
            positive=np.isfinite(fallback)&(fallback>0)
            logdensity[failed[positive]]=np.log(fallback[positive])
            recovered_mask[inds[positive]]=True
            pdf_underflow_mask[inds[fallback==0]]=True
            pdf_nonfinite_mask[inds[~np.isfinite(fallback)]]=True
            for j in np.flatnonzero(~np.isfinite(fallback)):
                i=inds[j]
                mixture=ncx2_centered_logpdf(np.exp(logy[i]),df[i],np.exp(lognc[i]))
                if np.isfinite(mixture):
                    logdensity[failed[j]]=mixture
                    mixture_recovered_mask[i]=True
        logw[ok]=logdensity+np.log(beta[ok])+(beta[ok]-1)*log_a-logscale[ok]
        nu=df[central]/2
        logw[central]=(nu-1)*logy[central]-np.exp(logy[central])/2-nu*np.log(2)-gammaln(nu)+np.log(beta[central])+(beta[central]-1)*log_a-logscale[central]
    logw[~np.isfinite(logw)]=-np.inf
    w=np.exp(logw-logsumexp(logw));r=lam/beta;b=beta-lam
    sel=b>0
    result=dict(samples=len(u),effective_sample_size=float(1/np.dot(w,w)),seed=seed,
        probability_finite_stop=float(w[sel].sum()),
        beta_quantiles=weighted_quantile(beta,w,[.05,.5,.95]),
        lambda_quantiles=weighted_quantile(lam,w,[.05,.5,.95]),
        r_quantiles=weighted_quantile(r,w,[.05,.25,.5,.75,.95]),
        b_quantiles=weighted_quantile(b,w,[.05,.5,.95]),
        conditional_stop_fraction_quantiles=weighted_quantile(1/(1+b[sel]),w[sel],[.05,.5,.95]),
        conditional_threshold_over_N_quantiles=weighted_quantile(1/b[sel],w[sel],[.05,.5,.95]),
        excluded_prior_draw_fraction=float((~(ok|central)).mean()),
        logpdf_nonfinite_prior_fraction=float(len(failed)/len(u)),
        boost_pdf_recovered_prior_fraction=float(recovered_mask.mean()),
        boost_pdf_recovered_posterior_mass=float(w[recovered_mask].sum()),
        boost_pdf_zero_prior_fraction=float(pdf_underflow_mask.mean()),
        boost_pdf_nonfinite_prior_fraction=float(pdf_nonfinite_mask.mean()),
        mixture_recovered_prior_fraction=float(mixture_recovered_mask.mean()),
        remaining_nonfinite_prior_fraction=float((pdf_nonfinite_mask&~mixture_recovered_mask).mean()),
        central_limit_prior_fraction=float(central.mean()))
    # If Boost correctly rounded a positive density to zero, its unscaled
    # value is at most the smallest positive subnormal. This bounds lost
    # weight for those underflows only; argument exclusions/NaNs are separate.
    jac=np.log(beta)+(beta-1)*log_a-logscale
    logbound=np.log(np.nextafter(0.,1.))+logsumexp(jac[pdf_underflow_mask])-logsumexp(logw)
    result['boost_pdf_zero_posterior_mass_upper_bound_if_correct_underflow']=float(np.exp(logbound))
    return result

if __name__=='__main__':
    print('Transition numerical checks:',verify_transition(),flush=True)
    result={}
    for case in CASES:
        result[case]=[]
        for seed in [47,91]:
            row=run(case,seed,19)
            result[case].append(row)
            print(case,seed,'ESS',round(row['effective_sample_size']),'Pstop',round(row['probability_finite_stop'],4),'r',row['r_quantiles'],'conditional f',row['conditional_stop_fraction_quantiles'],flush=True)
        (HERE/'posterior_qmc_results.json').write_text(json.dumps(result,indent=2)+'\n')
