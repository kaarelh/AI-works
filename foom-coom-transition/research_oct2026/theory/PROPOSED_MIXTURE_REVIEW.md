# Review of the proposed synthesis prior

2 October 2026. This reviews the proposed weights and parameterization before seeing their resulting quantiles. It does not modify any saved prior, select weights to obtain a preferred median, or compute a replacement forecast.

**The proposed mixture is a permissible explicit judgmental forecast, but it does not yet remove the central inferential weakness.** It reduces the guaranteed slow-residual and continuum weights, yet a continuous Forethought-style taper can reintroduce tiny residual exponents through its coupling to headroom. The main fixes are to expose that coupling, avoid treating high minimum headroom as established, and classify the capped raw-growth submodel by what it actually does within the budget.

## Concrete checks on the proposed specification

**The weights sum to one.** The top-level 25/20/20/10/5/20 allocation is coherent as a distribution over mutually exclusive mathematical descriptions of the realized law. The descriptions need not represent physically disjoint causes, but should not be sold as independently supported mechanisms. Exponential cost and exponential efficiency can describe the same underlying adaptive-refinement story in different coordinates. Equal division of the 20% completion branch assigns each 6.67% total probability; that split is a coordinate/form choice, not three pieces of evidence. This can still be used if labeled plainly.

**The headroom change has two directions of unsupported commitment.** Moving the upper limit from 12 to 60 in `log10 H` accommodates the objection to a low universal ceiling. Moving the lower limit from 1 to 6 additionally rules out less than a millionfold headroom in every finite-ceiling world. The user's objection to a low ceiling does not establish that lower bound. If there is separate substantive evidence for it, identify the mapping to the common multiplier; otherwise include a small-headroom sensitivity or retain some probability below `H=10^6`.

Uniform `log10 H` on 6–60 has median headroom `10^33`; the proposed 6–16 and 6–120 sensitivity priors have medians `10^11` and `10^63`. These are substantially different central headroom beliefs, not just removal of implausible extreme draws. This is a legitimate sensitivity, but should be described that way. The results can remain counterintuitive: with a power cost gap, larger headroom accelerates stopping for exponent greater than one and delays it for exponent below one.

**“Rapid completion” becomes an unreliable label for capped raw growth.** For

\[
a(x)=\min\{H,(1+k_0x/q)^q\},
\quad x_H=(q/k_0)(H^{1/q}-1),
\]

the cap is reached before the uncapped optimum only when `x_H < q(N−1/k0)/(1+q)`. Approximately, at `k0 N=10^91`, this requires

\[
\log_{10}H<q\{91-\log_{10}(1+q)\}.
\]

For fixed `q=1`, `H=10^60` gives completion near `10^89` FLOPs; `H=10^120` never binds before the optimum near `N/2`. If `q` is drawn from the same broad raw-power prior, some central-range ceilings also fail to bind. Do not silently condition them out and resample: that changes the joint prior. Retain them, name the branch “finite ceilings with completion laws,” and report the probability that the cap is irrelevant within the budget. Its right tail overlaps the explicit budget-persistent raw-power branch and can raise late probability above the nominal 20%.

**The proposed continuous taper is itself a residual-tail prior.** The local takeoff translation in `research_oct2026/takeoff/forethought/reproduce.py` defines, writing `u=ln a`, `h=ln H`, and using `pi` for the source's parallel-labor exponent to avoid collision with cost-gap `p`,

\[
k(u)=k_0e^{\pi u}(1-u/h)^\nu,
\qquad \nu=\pi h/r_0.
\]

With shared feedback this is a valid law: `da/dF=k(a)`. Its source parameters are not independently measured parameters of universal thought; the mapping is an additional modeling assumption.

Put `epsilon=1-u/h`. Near the ceiling,

\[
\frac{d\epsilon}{dx}\simeq-\frac{k_0H^\pi}{h}\epsilon^\nu.
\]

For `nu>1`, the remaining cost/efficiency gap therefore decays with exponent

\[
p_{\rm gap}=\frac1{\nu-1}=\frac1{\pi\ln H/r_0-1}.
\]

`nu=1` gives exponential approach; `nu<1` gives finite completion. With `pi=.3,r0=1.2`, raising `log10 H` from 12 to 60 changes the implied gap exponent from about .169 to .0298. The new wider headroom prior thus makes this component's tail slower at the same time that it raises its ceiling. At the wide end it resembles the small residual exponents whose weight the revision is reducing elsewhere.

This coupling may be the intended consequence of extrapolating a linear decline in the source's returns ratio over the entire available log headroom. If so, make it explicit and retain it as a conditional scenario. It is not additional empirical evidence that such a decline remains valid to its limiting regime. Include a sensitivity holding `nu` fixed while varying `H`; otherwise the advertised “headroom sensitivity” conflates ceiling height with residual shape. The source's finite-step implementation and a continuous limit need not share the same completion tail.

**Retaining the old single-power prior retains its old judgment.** Its median `.5` and logarithmic SD `ln 3` are compatible with multiple stylized search mechanisms, but theory does not make them a universal estimate. That is acceptable if the report's central number is explicitly an all-things-considered judgment conditional on this elicitation. Do not describe the modification as an empirically updated posterior merely because the calibration and nearby models have been improved.

**The initial calibration's independence is also a choice.** `log10 k0 ~ Normal(-29,1.25)` can remain an explicitly inherited assumption. Drawing it independently of `H`, accessible difficulty, and onset scale is not implied by the one observed current slope. Its independent sampling is adequate for isolating tail sensitivity; additional decimal places in output do not confer evidential precision.

## A cleaner way to express an explicit forecast

No coordinate choice can remove arbitrary commitments when all admissible continuations have the same finite-prefix likelihood. It can make the commitments intelligible and less duplicated. I would distinguish three levels:

1. **Within-budget persistence.** Elicit the probability that useful opportunities remain at successive raw-input milestones, or elicit a few statements about the stopping CDF directly: `P(x*<10^40)`, `P(x*<10^80)`, `P(x*<10^110)`, and `P(x*≥.01N)`, with monotonic consistency. These are transparent forecasting judgments, not independent empirical observations. Scenario models can help assess their consistency. Do not pretend a direct CDF elicitation was derived from the models.
2. **Conditional law and payoff.** In worlds assigned to finite headroom, separately specify headroom `L=ln H`, a remaining-gain profile, and whether refinements can finish or be bypassed. In persistent worlds, specify finite-horizon elasticity or discovery opportunities. A finite bottleneck count, an existence indicator, onset scales, and reset survival can replace a guaranteed slow component. The current paper cannot supply numerical priors for all these latent quantities; a few explicit sensitivity scenarios are better than a high-dimensional falsely precise hierarchy.
3. **Choice of policy target.** Keep the primary distribution over known deterministic-law global optima if that is the chosen question. A realized adaptive forecast needs success/failure observations and a learning model. Calling an exponential mean curve “adaptive” does not supply that model.

A useful shape representation, if one wants to preserve a concrete known-law generator, is the cumulative remaining log gain in raw-input log coordinates. Let

\[
t=\ln(1+k_0x),\qquad g(t)=\ln a(x),\qquad
g(0)=0,\quad g'(0)=1.
\]

Then every nondecreasing `g` defines a common-feedback law through `F(x)=integral a dx`, and

\[
k(x)=k_0e^{-t}g'(t),\qquad
k(x)(N-x)=1\Longleftrightarrow
 g'(t)\{(Nk_0+1)e^{-t}-1\}=1.
\]

A finite headroom is simply `integral_0^infinity g'(t)dt=ln H`. Research persistence, exponential or algebraic decline in a logarithmic coordinate, discrete jumps, and resets can be stated directly in `g'` or its jump measure. This reduces confusion between raw-input and effective-input exponents. It does not make an independent prior over `H`, decay shape, and reset hazard neutral; normalization and their dependence still matter.

For practical synthesis, the proposed mixture can be retained after the clarifications above. Freeze its weights and parameter rules before calculating quantiles, publish its full specification, report conditional-family results, and show the no-forced-slow-residual and taper-shape sensitivities. Call the pooled CDF an explicit working judgment, and keep the likelihood-identification limit alongside it. There is no need to tune the mixture to recover either `10^110` or a deliberately earlier number.
