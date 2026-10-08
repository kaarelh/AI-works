GPT-6 (Codex) — 2026-09-13

# Evidence concerning the late cost-gap exponent

The previous $10^{74}$ answer assumed $C(F)-C_{\min}\propto F^{-1}$, where $F$ is cumulative effective research. There is no general theoretical or empirical reason to privilege that exponent. A positive ceiling does not determine when marginal returns become $10^{-120}$.

## Mechanisms and what they establish

**Interacting design components.** McNerney et al. derive $p=1/(\gamma d^*)$, where $\gamma$ describes the near-zero density of candidate component costs and $d^*$ is a bottleneck measure of design interactions. Uniform candidate costs give $\gamma=1$; $p=1$ then requires effective independence. Their examples include $p=1/2$ and $1/4$. Reinterpreting the reducible cost as excess above a positive floor preserves this logic, but that reinterpretation is ours. The paper's experience-curve comparison is not a measurement of the future universal AI cost-gap exponent. [Original paper, equations 5–7](https://arxiv.org/pdf/0907.0036).

**Fixed random search in a continuous landscape.** If a smooth objective has a nondegenerate quadratic minimum in $d$ dimensions, the volume within cost-gap $\epsilon$ is proportional to $\epsilon^{d/2}$. A sampler with fixed, nonzero local density therefore reaches best gap $\sim F^{-2/d}$ after a number of attempts proportional to $F$. Thus $p=1$ corresponds to two effective dimensions, $p=1/2$ to four, and $p=0.1$ to twenty. This is an elementary volume/extreme-value derivation; a fixed-search proof and discussion appear in [Rudolph, pages 4–5](https://ls11-www.cs.tu-dortmund.de/people/rudolph/publications/papers/ecj1.4.pdf).

**Adaptive search.** The same geometry does not force that exponent when search concentrates around promising regions. Random Pursuit has geometric convergence on strongly convex problems and an $O(1/F)$ guarantee for general smooth convex objectives, assuming suitable line searches. These are upper bounds in specified optimization problems, not an AI research production law. The comparison demonstrates that intelligence and landscape structure matter as much as the dimensionality of blind search. [Stich, Müller and Gärtner, section 5](https://arxiv.org/pdf/1111.0194).

**Discrete search.** A fixed finite set with an accessible optimum can yield an exponentially declining probability of not yet finding it, or exact cessation once found. However, finiteness alone does not imply feasibility. $10^{120}\approx2^{399}$ only permits one attempt per candidate for roughly 399 binary choices before accounting for evaluation cost. Effective feedback increases the available attempts, but even a large polynomial-sized multiplier only adds its binary logarithm to that count. Hutter's provably near-fastest universal procedure explicitly has overhead exponential in proof/program lengths; its asymptotic theorem is not a finite cosmic-budget guarantee. [Hutter, time analysis](https://hutter1.net/ai/pfastprg.pdf).

## Aggregation can favor slower tails

This section is our deduction, not an empirical result. If residual inefficiency is a sum of components $\sum_i a_i F^{-p_i}$, the smallest positive $p_i$ with nonzero amplitude eventually dominates. A single-component $p=1$ extrapolation misses this selection toward difficult residual bottlenecks. Conversely, architectural redesign could remove bottlenecks, so this is not an inevitability.

A continuum of exponents with a nonzero weight density at zero gives

$$\int_0^\infty w(p)F^{-p}\,dp\sim\frac{w(0)}{\ln F}.$$

With a finite ceiling and constant asymptotic conversion between raw and effective research, this yields $k(x)\propto1/[x(\ln x)^2]$. Stopping then has the scale $N/(\ln N)^2$, up to dimensionful normalization and other coefficients, rather than $\sqrt N$. The illustrative unit-coefficient value is around $10^{115}$ at $N=10^{120}$. No empirical measurement supports that coefficient or the continuum approximation; it is a counterexample to "finite ceiling means early stop".

## Exact normalization under the common multiplier

Normalize initial execution cost and initial efficiency to one. Let

$$C(F)=c+(1-c)(1+F/F_0)^{-p},\qquad \alpha=1/C,\qquad \frac{dF}{dx}=\alpha,$$

where $c=1/\alpha_{\max}$. Imposing $k(0)=k_0$ fixes

$$F_0=\frac{p(1-c)}{k_0}.$$

Put $z=1+F/F_0$. The exact raw research and marginal gain are

$$x=F_0\left[c(z-1)+(1-c)\frac{z^{1-p}-1}{1-p}\right],\qquad p\ne1,$$

$$x=F_0[c(z-1)+(1-c)\ln z],\qquad p=1,$$

$$k(x)=\frac{k_0z^{-p-1}}{[c+(1-c)z^{-p}]^2}.$$

In the regime where the floor dominates both cost and the raw-effort integral, $x\sim cF$ and

$$k(x)\sim p^{p+1}(1-c)^{p+1}c^{p-1}k_0^{-p}x^{-p-1}.$$

If additionally $x_*\ll N$, the optimal stop is

$$x_*\sim p(1-c)N^{1/(p+1)}k_0^{-p/(p+1)}c^{(p-1)/(p+1)}.$$

Writing $L=\log_{10}\alpha_{\max}$, $N=10^{120}$, and $k_0=10^{-27.5}$ gives

$$\log_{10}x_*\sim\frac{120+27.5p+(1-p)L}{1+p}+\log_{10}[p(1-10^{-L})].$$

The special cancellation of $L$ occurs only at $p=1$. It makes $10^{73.75}$ look more identified than the general model is. For $p<1$, the ceiling height strongly affects the stopping scale; with a high enough ceiling saturation may not be reached before the budget is exhausted. Use the exact expressions, not the asymptotic formula, in that case. For $p>1$ and very small $c$, the initial effort integral can also dominate for a long time even after the floor dominates instantaneous cost.

For illustration only, $L=10$ gives the asymptotic logarithmic stopping scales approximately 118.8 at $p=0.1$, 110.6 at $p=0.2$, 101.4 at $p=1/3$, 92.2 at $p=0.5$, 73.75 at $p=1$, and 55.3 at $p=2$. Exact numerical validation is advisable near the budget and initial-transient boundaries.

## Subjective inference

There is stronger justification for a **broad mixture of tail mechanisms** than for one smooth exponent. Conditional on a sustained power-law cost gap, moderate design interactions make $p<1$ at least as plausible as $p=1$. Adaptive search supplies meaningful weight to faster convergence, including geometric convergence. Bottlenecks and changing accessible algorithm spaces supply meaningful weight to $p\ll1$, logarithmic convergence, or failure to approach the asymptotic regime within the budget.

If a numerical conditional prior is needed for sensitivity calculations, a log-scale median around $p=0.5$ with a deliberately broad range, roughly $0.05$–$5$, is a defensible **elicitation**, not an estimate from data. These limits are not confidence bounds. The exact median has little evidential authority; using $0.3$, $0.5$, or $1$ should be shown as separate prior choices. A mixture should additionally reserve weight outside the power-law family, particularly fast/discrete saturation and extremely slow convergence. We should not infer the mixture weights from the number of papers or the number of existing fits.

The direction of revision supported by this investigation is: weaken confidence in $10^{74}$, allow substantial mass at much later stopping even conditional on a ceiling, and expose both the ceiling-height and bottleneck assumptions. The investigation does not by itself identify a unique all-things-considered posterior median.
