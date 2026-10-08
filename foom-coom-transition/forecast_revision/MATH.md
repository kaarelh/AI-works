GPT-6 (Codex) — 2026-09-13

# Exact shared-multiplier ceiling model

This is a mathematical audit and sensitivity analysis, not an empirical fit or a probability distribution over stopping times.

Let $x$ be raw FLOPs spent on research, $F$ cumulative effective research, $a=\alpha/\alpha_0$ the efficiency multiplier normalized to one today, and $N=10^{120}$ the remaining raw budget. The common multiplier assumption means

$$\frac{dF}{dx}=a(F),\qquad U(x)=a(F(x))(N-x).$$

There is no calendar forecast without a model of physical computing throughput. All stopping quantities here are cumulative raw FLOPs.

For a known smooth law, the marginal condition is

$$k(x)\equiv\frac{d\ln a}{dx}=\frac{1}{N-x}.$$

This is distinct from the exact $k=10^{-120}$ crossing. The two coincide approximately only when the optimal research spending is negligible compared with $N$.

## Single exponent, arbitrary ceiling

Write inverse efficiency, or effective execution cost, as

$$C(F)=\frac1a=f+(1-f)z^{-p},\qquad z=1+F/F_0,\qquad f=H^{-1},$$

where $H>1$ is the eventual multiplier relative to today and $p>0$ describes the approach in effective research. Setting the current marginal return to $k_0=10^{-27.5}$ fixes

$$F_0=\frac{p(1-f)}{k_0}.$$

Exact integration and differentiation give

$$x(z)=F_0\left[f(z-1)+(1-f)I_p(z)\right],$$

$$I_p(z)=\begin{cases}\dfrac{z^{1-p}-1}{1-p},&p\ne1,\\\ln z,&p=1,\end{cases}$$

$$k(z)=\frac{k_0z^{-p-1}}{[f+(1-f)z^{-p}]^2}.$$

Thus the exact economic root is $x(z)+1/k(z)=N$. `math_model.py` solves this in logarithms; it also solves the exact threshold separately. It verifies the raw/effective conversion with numerical derivatives and checks the stationary crossing for every reported example. Single-exponent $k$ is decreasing for $p\le1$, and for $p>1$ can first rise before falling; with $Nk_0\gg1$ there is one economic maximum in this family.

In fact the economic root is the **unique global maximum for all the cost families here**, including mixtures and the continuous mixture. Let derivatives in the following argument be with respect to $F$, write $s=-C'>0$, and define $G=x+1/k=x+C^2/s$. Since $x'=C$,

$$G'=C\left[\frac{CC''}{(C')^2}-1\right].$$

Positive sums and integrals of positive log-convex functions are log convex. Each $(1+F/F_0)^{-p}$ with $p>0$ is strictly log convex; the positive constant floor is log convex; and the sum of a positive floor and a positive exponential is strictly log convex. Consequently $CC''>(C')^2$ in every family here and $G'>0$. Since $G(0)=1/k_0<N$ and $G$ grows beyond $N$, exactly one economic root exists. The sign of $U'(x)$ is the sign of $N-G$, so the objective rises before that root and falls afterwards. This proof makes the optional numerical root scan unnecessary for repeated sampling. It does not establish uniqueness for arbitrary discontinuous breakthrough models outside these families.

### The ceiling asymptote

If the ceiling has been closely approached and the accumulated raw cost is dominated by the final constant-cost regime, then

$$x_*\sim p(1-f)k_0^{-p/(p+1)}N^{1/(p+1)}f^{(p-1)/(p+1)}.$$

Equivalently,

$$\boxed{\log_{10}x_*\approx\frac{120+27.5p+(1-p)\log_{10}H}{p+1}+\log_{10}[p(1-H^{-1})].}$$

For $p=1$, the dependence on headroom cancels:

$$x_*\approx(1-H^{-1})\sqrt{N/k_0}\approx10^{73.75}.$$

The earlier $10^{74}$ answer is therefore mathematically consistent **conditional on this particular inverse-first-power tail**. It does not follow from finite efficiency headroom alone. In this family it is unusually insensitive to headroom precisely at $p=1$.

For $p=1$ the exact simplification is $k=k_0/[fz+1-f]^2$. The omitted contribution to raw spending is approximately $k_0^{-1}\ln(H\sqrt{k_0N})$, negligible for the headrooms in the table. Mathematically, fantastically larger values of $\ln H$ can also invalidate this simplification.

### When the ceiling asymptote is inapplicable

For $p<1$, if

$$H\gg10^{92.5p/(1-p)},$$

the ceiling remains irrelevant around the economic optimum. The zero-floor phase has $a(x)\propto x^{p/(1-p)}$, and the economic optimum is approximately **$x_*=pN$**. A finite ceiling can coexist with spending an order-one fraction of the universe's budget on research.

For $p>1$, if

$$H\gg10^{92.5/(p-1)},$$

the raw cost of reaching the rapid improvement regime dominates the late ceiling term. Then stopping approaches

$$x_*\approx\frac{p}{p-1}\,k_0^{-1},$$

the finite-input singularity location of the zero-floor limit. A strictly positive floor eliminates the singularity, but can leave a very sharp rise near that location. The logarithmic roots retain this transient term exactly.

## Exact numerical sensitivity

Entries are $\log_{10}$ of optimal raw research FLOPs; current $k_0$ and $N$ are identical throughout. Values near $119$ are fractions of the $10^{120}$ budget, not a different raw budget assumption.

| Effective-research tail exponent $p$ | $H=10^3$ | $10^6$ | $10^{12}$ | $10^{30}$ | $10^{60}$ | $10^{120}$ |
|---:|---:|---:|---:|---:|---:|---:|
| 0.10 | 113.045 | 115.500 | 118.992 | 119.000 | 119.000 | 119.000 |
| 0.25 | 102.698 | 104.498 | 108.098 | 118.830 | 119.398 | 119.398 |
| 0.50 | 89.865 | 90.866 | 92.866 | 98.866 | 108.866 | 119.699 |
| 1.00 | 73.750 | 73.750 | 73.750 | 73.750 | 73.750 | 73.750 |
| 2.00 | 57.634 | 56.634 | 54.634 | 48.634 | 38.634 | 27.801 |
| 3.00 | 49.602 | 48.102 | 45.102 | 36.102 | 27.676 | 27.676 |

These numbers should not be averaged or treated as equally plausible scenarios. They expose what assumptions control an attempted forecast.

## Small slow components control very long extrapolations

The same calculation extends to

$$C(F)=f+\sum_iw_i z^{-p_i},\qquad\sum_iw_i=1-f,\qquad F_0=\frac{\sum_i p_iw_i}{k_0}.$$

Then

$$x=F_0\left[f(z-1)+\sum_iw_iI_{p_i}(z)\right],\qquad k=\frac{\sum_i p_iw_i z^{-p_i-1}}{F_0 C^2}.$$

The slowest nonzero exponent dominates the sufficiently late tail; it is not the average exponent. At $H=10^{12}$, mix a $p=1$ component with a $p=0.1$ component while preserving the same current marginal return:

| Current weight of the slow component among improvable cost | $\log_{10}$ optimal FLOPs |
|---:|---:|
| zero | 73.750 |
| $10^{-60}$ | 73.750 |
| $10^{-40}$ | 84.136 |
| $10^{-20}$ | 102.318 |
| $10^{-10}$ | 111.409 |
| $10^{-3}$ | 117.752 |

These tiny components would be effectively unidentifiable from present progress measurements. The examples do not prove such components exist; they show why fitting the dominant present component cannot determine the cosmic tail.

A continuum of positive exponents can be slower still. If weight near $p=0$ behaves as $p^{\nu-1}$, then the remaining cost can fall as $(\ln F)^{-\nu}$. After reaching the ceiling regime this gives marginal returns approximately $1/[x(\ln x)^{\nu+1}]$, up to coefficients. Stopping can remain $N$ divided by powers of its logarithm even though efficiency has a finite ceiling. Conversely, a ceiling approached exponentially can stop much earlier. Finite versus infinite headroom is only one part of the required prior.

## Exact exponential and continuum alternatives

Both additional classes use the same shared feedback and initial calibration. They are alternatives for the shape of execution cost, not fitted observations.

### Exponential approach in effective research

Let $C=f+(1-f)e^{-s}$, $s=F/F_0$, and $F_0=(1-f)/k_0$. Then

$$x=F_0[fs+(1-f)(1-e^{-s})],\qquad k=\frac{k_0e^{-s}}{[f+(1-f)e^{-s}]^2}.$$

For substantial headroom the optimum is very close to $k_0^{-1}=10^{27.5}$. Under common feedback, the zero-floor limit has a finite-input singularity at this location. The positive floor instead produces rapid improvement near that input, followed by vanishing returns. This is different from assuming exponential decay directly in raw-research marginal returns.

### Equal current cost weight over exponents from zero to one

Let

$$g(z)=\int_0^1z^{-p}\,dp=\frac{1-z^{-1}}{\ln z},\qquad C=f+(1-f)g(z),\qquad F_0=\frac{1-f}{2k_0}.$$

For $t=\ln z$,

$$J(t)=\int_0^t\frac{e^u-1}{u}\,du=\operatorname{Ei}(t)-\gamma-\ln t,$$

$$x=F_0[f(e^t-1)+(1-f)J(t)],$$

$$k=\frac{1-f}{F_0}\frac{1-(1+t)e^{-t}}{t^2e^tC^2}.$$

The apparent zero-over-zero expressions at $t=0$ are continuous, and the implementation uses their series. It uses a positive convergent series for small $J$, the exponential integral for moderate $t$, and its logarithmic asymptote for large $t$. Independent positive-integrand quadrature checks agree to $10^{-11}$ in logarithms, and differentiation checks verify both feedback equations.

| Ceiling $H$ | Exponential-cost $\log_{10}x_*$ | Continuum-cost $\log_{10}x_*$ | Continuum attained multiplier |
|---:|---:|---:|---:|
| $10^3$ | 27.58799 | 117.58699 | 175.9 |
| $10^6$ | 27.50010 | 117.67016 | 213.6 |
| $10^{12}$ | 27.50000 | 117.67025 | 213.7 |
| $10^{30}$ | 27.50000 | 117.67025 | 213.7 |

In the continuum examples, the ceiling has not been closely approached. Instead $g\approx1/\ln F$ dominates $f$, effective efficiency grows approximately logarithmically, and raw marginal returns have the form $k\approx1/[x\ln(x/F_0)]$ up to logarithmic corrections. The central stop is approximately $0.00468N$. Once again a finite ceiling by itself does not imply a stop many orders below $N$.

### Numerical API

`CeilingModel(p, log10_H, weights=None)`, `ExponentialCeilingModel(log10_H)`, and `ContinuumCeilingModel(log10_H)` expose `solve(scan=False)` for repeated sampling. Its outputs include `log10_optimal_x`, `log10_exact_threshold_x`, `log10_a_at_optimum`, and the remaining budget implied by the root. The default `scan=True` additionally checks a single stationary crossing on a numerical grid. `state_at_log10_x(log10_x)` gives natural-log values of raw input, marginal return, and cost, including an analytic late-regime inverse for the exponential model. It is suitable for comparing utility across possible fixed raw allocations; that comparison still requires an explicit prior and does not automatically model adaptive learning.

## A forecast distribution is not a spending policy

A distribution over laws induces a distribution of **realized optimal stopping points if the law becomes known**. A median of those points is an intelligible descriptive forecast, but is not generally the Bayes-optimal amount to commit to today.

For a fixed commitment $x$ without further learning, risk-neutral expected utility is

$$\mathbb E[U(x)]=(N-x)\mathbb E[a(x)].$$

Where expectations and derivatives exist, its marginal condition is

$$\frac{\mathbb E[a(x)k(x)]}{\mathbb E[a(x)]}=\frac1{N-x}.$$

The relevant marginal return is efficiency-weighted. A small probability of a law yielding vastly larger multipliers can dominate expected utility; neither the median stopping point nor $\mathbb E[k]$ gives the correct decision. Priors with insufficiently bounded headroom can even make this expectation infinite.

An adaptive policy additionally values learning from research and updates its posterior. It requires a model for what research observations reveal, their costs, and the relationship between local measured returns and remote tails. It will generally be state dependent, rather than a fixed FLOP target. Realized observations can also create option value for continuing despite an unpromising current marginal estimate. None of those likelihoods is identified by the existing empirical fits.

## Implication for revising the previous guess

The previous $10^{74}$ point estimate selected $p=1$ by simplicity. The math checks, but that choice has not earned central-forecast status from the evidence. A better all-things estimate needs an explicit prior over headroom, late-tail exponents or mechanisms, and hidden slow components; it also needs to say whether the requested number is a median realized stopping point or a current expected-utility spending policy. Sensitivity and model ambiguity are necessary outputs, rather than precision to a few powers of ten.
