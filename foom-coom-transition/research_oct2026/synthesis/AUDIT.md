# Independent audit of the October synthesis

Audited 2 October 2026. Scope: `prior.json`, `forecast.py`, `taper_model.py`, and the saved `results.json`/`draws.csv`. The audit did not edit those files or retune the prior. The numerical results below are reproduced by `audit_synthesis.py` and recorded in `audit_results.json`.

**Conclusion:** I found no material mathematical, numerical, or mixture-weighting error in the forecast as currently specified. Its precision is limited by the chosen prior and the unobserved long-run law, not numerical solution error. It is a distribution over optimal stopping points conditional on each law being known, not an empirical posterior or an optimal policy under learning.

## Shared multiplier and global optimum

Write \(a(x)\) for the common efficiency multiplier, \(F\) for effective research, and \(x\) for raw research spending. The model consistently uses

\[
\frac{dF}{dx}=a,\qquad k=\frac{d\ln a}{dx}=\frac{da}{dF},\qquad U(x)=a(x)(N-x).
\]

Thus the smooth interior economic stopping equation is \(x+1/k=N\). It is not generally the literal threshold \(k=1/N\), especially when research uses an appreciable fraction of the budget. Moving consumption after research is consistent with the assumed absence of discounting or calendar constraints.

For the continuous taper, let \(y=\ln a\), \(L=\ln H\), and \(r(y)=r_0(1-y/L)\). The proposed equation and its integral are consistent:

\[
\frac{d\ln k}{dy}=p(1-1/r),\qquad
k(y)=k_0e^{py}(1-y/L)^{pL/r_0}.
\]

Since \(dy/dx=k\), the derivative of the economic root function is

\[
\frac{d}{dx}(x+1/k)=1-p+p/r(y)>0
\]

throughout the **specified support \(0<p\leq1\)**. Initial research is profitable, and this function eventually exceeds \(N\); the stationary point is therefore the unique global maximum. Early growth of \(k\) is possible when \(r>1\) and does not invalidate this proof. The taper class accepts arbitrary positive \(p\), however; future use with \(p>1\) should check globality separately or restrict the class explicitly.

The exponential-efficiency branch is logistic in raw spending:

\[
a(x)=\frac{H}{1+(H-1)e^{-rx}},\qquad r=k_0H/(H-1).
\]

Equivalently, \(a(F)=H-(H-1)e^{-rF/H}\). It therefore respects shared feedback and is a distinct law from exponential decline of effective cost. Its \(k=r(1-a/H)\) decreases, ensuring a unique maximum.

For capped raw power, \(a(x)=\min\{H,(1+k_0x/q)^q\}\), the unconstrained maximum and the first cap point are

\[
x_{\rm free}=\frac{q}{1+q}(N-1/k_0),\qquad
x_{\rm cap}=\frac q{k_0}(H^{1/q}-1).
\]

The optimum is exactly \(\min(x_{\rm free},x_{\rm cap})\). At a binding cap the objective has a kink, so the smooth marginal stopping equality need not hold. The implementation correctly uses the cap point instead. The open-ended branch uses the same unconstrained formula.

The inherited effective-cost families have positive, decreasing, strictly log-convex cost functions. For these, \(x+1/k=x+C^2/(-C')\) increases strictly; their globality proof remains applicable to mixtures and the continuous mixture.

## Independent numerical checks

I replaced the taper solver's floating-point quadrature with a **100-digit Decimal positive series**, rather than reusing its integrator. With \(u=-\ln(1-y/L)\), \(b=pL\), and \(\nu=b/r_0\), the independently evaluated integral was

\[
x(u)=\frac L{k_0}e^{-b}\sum_{n=0}^{\infty}\frac{b^n}{n!}
\frac{e^{(\nu-1-n)u}-1}{\nu-1-n},
\]

where the fraction is \(u\) if its denominator vanishes. All terms are positive. I located the optimum by Decimal bisection. Four cases cover low headroom with \(\nu\) close to one, a central taper, and large headroom with two very different root coordinates. Three logistic cases were separately solved using \(v+1+e^v/(H-1)=rN\), where \(v=rx\). Three saved capped-power draws include both cap optima and an interior optimum.

| Check | Number of cases | Largest absolute error in \(\log_{10}x_*\) |
|---|---:|---:|
| Continuous taper | 4 | \(1.37\times10^{-12}\) |
| Exponential efficiency | 3 | \(7.11\times10^{-15}\) |
| Capped raw power | 3 | Below displayed double precision |

Representative independent taper values are \(10^{41.35549}\) for \((\log_{10}H,r_0,p)=(6,3.6,0.3)\), \(10^{105.78436}\) for \((11,1.2,0.3)\), and \(10^{118.79899}\) for \((60,1.2,1)\), all with \(k_0=10^{-29}\). These very different answers arise from the law and parameters, not unstable evaluation.

I verified the prior hash and all **24,576 saved draws**: 1,024 draws per explicit subfamily at each of three headroom ranges. The rapid branch has three equally populated subfamilies, so its per-row weighting implements the stated one-third conditional weights. Every scenario's weights sum to one. Independent reconstruction of the median and the two budget-fraction probabilities agrees for all nine combinations of headroom and family weights.

## Interpretation and sensitivity

1. **This is a subjective prior propagation.** Local empirical slopes motivate starting calibration and plausible near-term elasticities, but do not provide likelihood evidence for keeping any particular tail across another 90 orders of research spending. The weights, headroom distribution, and independence assumptions are judgments. The branches are a useful approximation, not an exhaustive partition of possible futures.

2. **The headroom unit matters.** Here \(H\) multiplies all effective research and consumption. Benchmark training efficiency, inference efficiency, and parallel research labor equivalents are different quantities. Directly inserting a source's headroom number without a declared mapping would be an error. The present prior explicitly labels its \(10^6\)–\(10^{60}\) range as an elicited toy-model range.

3. **The continuum pins the reported median locally.** The central median \(\log_{10}x_*=117.6753\) falls inside the unusually narrow continuum branch, whose own median is 117.6773. That narrowness follows from placing positive weight arbitrarily close to exponent zero, not precise empirical knowledge. Dropping the 5% continuum branch and renormalizing all other weights gives a median of **117.4293**, probability **48.27%** of spending at least 1% of \(N\), and **33.52%** of spending at least 10% of \(N\). This does not overturn a rounded \(10^{118}\) central headline, but shows why the precise pooled median should not receive special significance. Removing the guaranteed slow component in the heterogeneous branch has a much larger effect, as the main sensitivity output already shows.

4. **“Rapid completion” is a family label, not a spending bound.** Its capped-power subfamily can continue until a substantial fraction of \(N\) when the cap is high or the power is small. Report actual spending bins rather than equating its 20% weight with a 20% probability of an early stop.

5. **The current configuration is reproducible, but not entirely data-driven in software either.** `forecast.py` reads and hashes `prior.json`, while several distribution parameters and the equal rapid subfamily split are repeated as literals in the script. They agree in this audited version. A future change to the JSON alone will not necessarily change the calculation. Future revisions should either derive those literals from the specification or explicitly audit both files again.

6. **The answer remains conditional on the model.** These are additional raw FLOPs, not dates. A median of known-law optima is neither the spending point maximizing expected utility before learning nor the stopping policy of an agent who can learn which law applies. Calendar bottlenecks and heterogeneous capabilities would require a different model.

Reproduce from the project root:

```sh
empirical_methods/.venv/bin/python research_oct2026/synthesis/audit_synthesis.py
```
