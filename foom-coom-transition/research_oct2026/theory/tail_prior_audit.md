# Audit of the slow-residual prior and adaptive stopping

GPT-6 (Codex), 2 October 2026. This is a theoretical audit, not an empirical fit. All new calculations use $N=10^{120}$ raw FLOPs and $k_0=10^{-29}$ per raw FLOP. Existing files were read without alteration. Numerical examples reuse the exact shared-feedback solver in `forecast_revision/math_model.py`; the reproducibility block below does not write files.

## Finding

The previous median near $10^{110}$ is a consequence of explicit assumptions about persistent slow opportunities. The mathematics supports those opportunities as possibilities, but does not support their numerical prior weight. In particular, “the slowest exponent eventually dominates” does not imply “the smallest imaginable exponent controls this finite budget.” At fixed amplitude and a finite research horizon, a sufficiently small exponent describes almost no accessible improvement. It becomes an additional effective floor.

The audit finds no numerical error in the previous mixture calculation. Its main vulnerability is inferential: the prior grants durable slow opportunities much more structure than the empirical evidence establishes. This warrants withdrawing any claim that $10^{110}$ is an empirically identified improvement over other central estimates. It does **not** establish a new preferred median, or justify reverting to the privileged $p=1$ answer.

## 1. What the previous prior actually asserts

The central weights in `forecast_revision/forecast_prior.json` are 25% single power gap, 35% fast plus slow gaps, 10% exponential convergence, 10% continuous slow gaps, and 20% scale-free behavior within the budget. Calibration revision preserves these weights and tail draws.

The heterogeneous family is not simply uncertainty about whether a residual exists. Every world in that family has one, with exponent log-uniform on 0.03–0.3 and current reducible-cost amplitude log-uniform on $10^{-12}$–$10^{-2}$. About 52.3% of these residual exponents are below 0.1, contributing about 18.3% of the entire prior. Another 10% of the prior has a deterministic continuous hierarchy reaching all the way toward zero exponent; another 20% has persistent scale-free gains. Thus 65% is assigned to these three explicitly persistent families. Family membership alone does not force a particular stopping threshold, but it explains why the late tail has substantial mass before any observations are introduced.

These are disclosed modeling judgments, not a coding defect. The problem is treating “heterogeneity exists” as evidence for this particular cost-weighted distribution of difficulties, their amplitudes, their survival through architectural change, and their common research timescale. None of those follow from heterogeneity alone.

A relevant primary model uses random changes to clusters of interacting components; design complexity can slow improvement and create bottlenecks. It supports one mechanism for difficult residuals, not an empirical prior for permanent AI bottlenecks. [McNerney et al., *The Role of Design Complexity in Technology Improvement*](https://arxiv.org/abs/0907.0036). Adaptive random pursuit instead exploits information from previous trials and has convergence guarantees on specified convex problems with suitable line-search access. This shows why random-candidate difficulty cannot by itself determine the research tail. [Stich, Müller and Gärtner, *Optimization of Convex Functions with Random Pursuit*](https://arxiv.org/abs/1111.0194).

## 2. Finite-budget dominance depends on derivatives and amplitudes

Use the previous exact family, preserving the common multiplier:

\[
C(F)=a(F)^{-1}=f+\sum_i w_i z^{-p_i},\quad
z=1+F/F_0,\quad f=H^{-1},\quad \sum_iw_i=1-f,
\]

\[
\frac{dF}{dx}=\frac1C,\qquad F_0=\frac{\sum_i p_iw_i}{k_0}.
\]

Writing $t=\ln z$, the exact marginal proportional return is

\[
k(F)=\frac{e^{-t}}{F_0 C(F)^2}
\sum_i p_iw_i e^{-p_i t}.
\]

The component controlling the derivative maximizes $p_iw_i e^{-p_i t}$, not merely $w_i e^{-p_i t}$. For a slow component $s$ and a faster component $f\!a$, derivative dominance requires

\[
t>\frac{\ln[p_{f\!a}w_{f\!a}/(p_sw_s)]}{p_{f\!a}-p_s},
\]

when the numerator is positive. Cost dominance has the analogous condition without the factors $p_i$. Neither dominance condition alone establishes profitable research: total $k$, remaining budget, and attainable efficiency still matter.

The relevant horizon is finite. If $a\le H$, then $F\le HN$, hence

\[
t\le \ln(1+HN/F_0).
\]

For a fast bulk component with $F_0\simeq10^{29}$ and $H=10^{12}$, this upper bound is about 237, not an infinite asymptotic limit. The accessible log range is sufficient to make small components consequential, but also sufficient to check whether an alleged asymptotic crossover is accessible.

When the floor dominates cost and cumulative spending, and the slow component dominates the derivative,

\[
k(x)\simeq p_sw_sF_0^{p_s}f^{p_s-1}x^{-1-p_s},
\]

so, if $x_*\ll N$,

\[
x_*\simeq
\left[Np_sw_sF_0^{p_s}f^{p_s-1}\right]^{1/(1+p_s)}.
\]

The amplitude, exponent, floor, and timescale all enter. The phrase “arbitrarily tiny nonzero components eventually matter” omits this finite-budget test.

### The $p\to0$ limit is not maximally late research

Hold a fast component, its timescale, and a residual weight $w_s$ fixed. If $p_st\ll1$, the slow component is approximately constant: $w_s e^{-p_st}\simeq w_s$. After fast improvements have decayed, set $C_b=f+w_s$. Then approximately

\[
k_s(x)\simeq\frac{q}{x},\qquad
q=\frac{p_sw_s}{C_b},\qquad
\frac{x_*}{N}\simeq\frac{q}{1+q}.
\]

Thus its candidate stopping scale decreases to zero as $p_s\to0$; eventually the fast component sets the actual stop. At $p_s=0$ exactly, the residual is an additional constant floor and contributes no derivative. The limits “research budget tends to infinity” and “exponent tends to zero” do not commute.

Exact examples with fast exponent 1, $H=10^6$, and slow amplitude $10^{-7}$ of current reducible cost:

| Slow exponent | \(\log_{10}x_*\) | Interpretation |
|---:|---:|---|
| 0.3 | 96.444 | Floor regime; moderate tail |
| 0.1 | 109.364 | Slow derivative strongly matters |
| 0.03 | 114.725 | Later stop |
| 0.003 | 116.175 | Near the largest stop among these examples |
| \(10^{-8}\) | 110.959 | Residual almost constant; derivative shrinking |
| \(10^{-20}\) | 98.959 | Still weaker accessible improvement |
| \(10^{-40}\) | 78.959 | Barely extends the fast tail |
| \(10^{-60}\) | 74.500 | Fast component controls stopping |

For 0.3 and 0.1, the floor asymptote agrees with the exact root to better than $10^{-9}$ in log10 FLOPs; for 0.03, the discrepancy is about $7.2\times10^{-5}$. These checks support the interpretation rather than introducing fitted evidence.

The single-gap family has a related qualification. In its unsaturated, zero-floor approximation with $0<p<1$, exact shared feedback gives

\[
a(x)=\left[1+\frac{(1-p)k_0x}{p}\right]^{p/(1-p)},
\qquad x_*=p(N-k_0^{-1}).
\]

Even there, sending $p\to0$ sends the research fraction to zero. Moreover, matching $k_0$ forces $F_0=p(1-f)/k_0$ to shrink with $p$. At fantastically small $p$, this becomes an arbitrarily narrow initial-return feature, eventually narrower than one FLOP; interpreting it as a physical mechanism would be inappropriate. A small exponent is not a coordinate-independent measure of “very persistent gains.”

## 3. A continuous hierarchy is a within-world assumption

The continuum law has

\[
g(t)=\int_0^1e^{-pt}\,dp\sim t^{-1}.
\]

Its existence means that one realized world contains cost-weighted opportunities across all these exponents. It is not the same operation as assigning a uniform prior to the unknown exponent of one realized world. In general,

\[
\operatorname*{argmax}_x U(x;\mathbb E[C])
\ne \mathbb E[\operatorname*{argmax}_x U(x;C)],
\]

and neither expression is an adaptive Bayesian policy. Since $a=1/C$, even averaging execution costs and averaging utility are different operations.

More generally, if the actual within-world weight density satisfies $w(p)\sim A p^{\nu-1}$ near zero, Laplace asymptotics give

\[
g(t)\sim A\Gamma(\nu)t^{-\nu},\qquad
-g'(t)\sim A\Gamma(\nu+1)t^{-\nu-1}.
\]

The derivative receives its main contribution from an exponent range of order $1/t$, not from the very smallest imaginable exponent. With $t\simeq210$, exponents around a few thousandths are relevant to the uniform continuum. The assumptions $A>0$, no effective lower cutoff, and sufficient weight in that band drive the result.

For a finite collection of $M$ independently drawn exponents with CDF $G$,

\[
\Pr(p_{\min}\le\epsilon)=1-[1-G(\epsilon)]^M.
\]

If $G(\epsilon)\sim c\epsilon^\nu$, a smooth continuum approximation around the active band needs many relevant components: roughly $Mc/t^\nu\gg1$, plus suitable amplitudes. That is a new substantive assumption. It does not follow just from saying that “many parts of intelligence remain improvable.”

For illustration, equally weighted midpoint exponents $p_i=(i+1/2)/M$ approximate the uniform continuum. They give the following exact shared-feedback stops at $H=10^{12}$:

| Number of components \(M\) | Smallest exponent | \(\log_{10}x_*\) |
|---:|---:|---:|
| 1 | 0.5 | 93.366 |
| 2 | 0.25 | 108.217 |
| 5 | 0.1 | 118.974 |
| 10 | 0.05 | 118.699 |
| 30 | 0.0167 | 118.223 |
| 100 | 0.005 | 117.805 |
| 300 | 0.00167 | 117.694 |
| 1000 | 0.0005 | 117.679 |
| Continuous | Infimum 0 | 117.677 |

This table also prevents an overcorrection: replacing the continuum with finitely many components does **not** invariably make stopping earlier. Some finite spectra produce a larger research fraction. The robust criticism is that the spectrum must be justified, not that every finite model saturates quickly.

### A difficulty parametrization can remove density at zero

As a mathematical illustration, suppose component exponent $p=1/d$, where $d$ denotes difficulty. A cost-weighted difficulty distribution with power-law upper tail $\Pr(d>D)\propto D^{-\nu}$ induces exponent weight near zero proportional to $p^{\nu-1}$, and therefore a logarithmic research tail. Thus the continuous hierarchy can be interpreted as a particular heavy-tailed difficulty spectrum.

An exponential difficulty density instead gives $w(p)\propto p^{-2}\exp[-1/(d_0p)]$, strongly suppressing tiny exponents. Its large-$t$ cost gap has leading exponential factor $\exp[-2\sqrt{t/d_0}]$, from minimizing $d/d_0+t/d$. A bounded $d$ gives a strictly positive minimum exponent. These are rival model judgments; none is selected by the mere existence of interactions. A prior that is simple in $p$ can be highly informative in difficulty, and vice versa.

## 4. Further hidden assumptions in the current parametrization

**Common onset scale.** More general mixtures have

\[
C(F)=f+\sum_iw_i(1+F/F_i)^{-p_i},\qquad
k_0=\sum_i\frac{p_iw_i}{F_i}.
\]

The one observed initial slope supplies one constraint. It does not identify all $F_i$. The old mixture sets every $F_i=F_0$, which ties presently negligible opportunities to the same effective-research clock as the current bulk gains. Different accessibility costs, discovery thresholds, or prerequisites can produce very different finite-budget behavior while preserving $k_0$.

**Persistence through redesign.** A component can disappear when a superior architecture replaces it, or become irrelevant when the task mix changes. Permanent additive gaps assume these events do not eliminate the slow derivative. A survival or reset mechanism should modify the existing residual model, not merely be placed alongside it under an additional family name. Whether redesign tends to remove hard residuals or introduces harder new ones is an unresolved model judgment.

**Mixture bookkeeping.** Several named mechanisms can express overlapping beliefs. Assigning independent-looking family labels does not generate independent evidence, and allocating probability by counting mechanisms can give undue weight to whichever side has more verbal variants. The old authors already flag the weights as subjective; the improved report should preserve that qualification in its headline conclusion.

## 5. Discrete opportunities invalidate a purely local stopping rule

The smooth condition $k(x)=1/(N-x)$ is a first-order condition. It identifies the global maximum in the prior's log-convex cost families, as proved in its mathematical appendix. It is not a universal stopping theorem.

Suppose current efficiency is $a$, remaining raw budget is $n$, and a known breakthrough arrives after spending an additional $Δ$ raw FLOPs, multiplying efficiency by $B>1$, with no further opportunities. Research is worthwhile exactly when

\[
aB(n-Δ)>an
\quad\Longleftrightarrow\quad
Δ<n(1-B^{-1}).
\]

The local derivative can be zero throughout the approach. Nevertheless, crossing the plateau is globally optimal. Smoothing the jump does not remove this distinction if the intervening gains remain negligible. For a known finite sequence of breakthroughs, compare all attainable $a_j(N-x_j)$, rather than stopping at the first local crossing.

For uncertain success probability $q$ after a committed research project of cost $Δ$, with no other information, the corresponding expected-utility condition is

\[
Δ<n\frac{q(B-1)}{1+q(B-1)}.
\]

Both formulas preserve the common multiplier: research advances effective effort at the current $a$, and the breakthrough increases the efficiency of both actions. They do not assert an empirical breakthrough distribution.

### Learning from failures: a concrete adaptive counterexample

Consider one possible breakthrough of known size $B$. Conditional on unknown raw success rate $λ$, its waiting time is exponential. Until success the multiplier is constant; after success it becomes $B$ times larger and research ends. A hazard per effective FLOP gives the same model during this stage after multiplying by the current $a$.

Let $λ\sim\mathrm{Gamma}(α,β)$, using a rate parameter $β$. After spending $x$ without success,

\[
h(x)=\frac{α}{β+x},\qquad
S(x)=\left(\frac{β}{β+x}\right)^{α}.
\]

Here $S$ is the predictive survival probability and $h$ the posterior hazard. For a policy that stops at success or a timeout $T$, normalized expected consumption is

\[
V(T)=\int_0^T S(t)h(t)B(N-t)\,dt+S(T)(N-T).
\]

Differentiating gives

\[
V'(T)=S(T)[h(T)(B-1)(N-T)-1].
\]

The bracket decreases with $T$, so its unique crossing gives the optimal causal timeout within this one-opportunity model. Set the **initial expected** marginal return $h(0)(B-1)=k_0$. Then

\[
β=\frac{α(B-1)}{k_0},\qquad
T_* =\frac{α(B-1)}{1+α(B-1)}(N-k_0^{-1}).
\]

The realized research spending is $X=\min(\tau,T_*)$, with an atom $S(T_*)$ at timeout. Its median is the smaller of $T_*$ and $β(2^{1/α}-1)$. For $B=2$:

| Gamma shape \(α\) | \(\log_{10}T_*\) | Probability of reaching timeout | \(\log_{10}\mathrm{median}(X)\) |
|---:|---:|---:|---:|
| 1 | 119.699 | \(2.0\times10^{-91}\) | 29.000 |
| 0.1 | 118.959 | \(8.0\times10^{-10}\) | 31.010 |
| 0.01 | 117.996 | 0.123 | 57.103 |
| 0.003 | 117.476 | 0.533 | 117.476 |

These priors have the same initial expected return and the same twofold ceiling. Their causal realized stopping distributions range from very early to almost budget scale because the distribution of discoverability and what failure teaches differ. The shape choices are illustrative judgments, not evidence for these probabilities.

There is a calibration limitation: before a discrete jump, the realized path's derivative is zero. Matching the **expected** infinitesimal gain is not automatically equivalent to matching the historical path derivative used for $k_0$. The example establishes decision-theoretic nonidentification, not a new empirical estimate.

It is also different from a clairvoyant calculation in which the exact future success time $τ$ is known from the outset. Knowing the probability law is not knowing its realized random outcomes. A forecast should say whether it predicts a deterministic known-law optimum, a clairvoyant path optimum, or a causal adaptive policy's realized spending.

## 6. Recommended distributional changes and limits

1. Retain slow residuals as a serious possibility, but remove the claim that they earn the previous 35% plus 10% weights from heterogeneity alone. Treat those numbers as elicited assumptions requiring justification.
2. Replace a guaranteed permanent residual with an explicit existence indicator, amplitude, onset scale, difficulty spectrum or finite component count, and probability of surviving redesign. Include outcomes where the apparent residual becomes an effective floor, is completed, or is bypassed. Dependence among these parameters should follow the proposed mechanism.
3. Keep the continuum as a stress case unless there is a defended cost-weighted difficulty spectrum populated around $p\sim1/\ln(F/F_0)$. It is not a neutral way to encode exponent uncertainty. Finite approximations and cutoff sensitivity should accompany it.
4. Report the distribution of the raw elasticity $b(x)=xk(x)$, accessible remaining gain, and opportunity success probabilities at several research scales. These finite-horizon quantities are closer to the economic stopping question than an asymptotic exponent. At a smooth optimum $x/N=b/(1+b)$; this identity is exact but does not itself identify $b$.
5. Preserve the distinction between law uncertainty and adaptive decisions. A median over deterministic laws cannot be sold as the budget an agent should commit now, and an expected smooth trajectory cannot substitute for the stopping distribution of a discrete discovery process.

Theory supplies no justified numerical reweighting that turns these corrections into a unique replacement median. It strengthens a broad mechanism-based sensitivity analysis and weakens confidence in the old central quantile. Both early completion near the initial research scale and persistent research near the budget remain compatible with the framework. Finite headroom does not select between them; neither does a statement that brain efficiency is or is not close to an optimum.

## Reproduction

Run the following with `python`. It imports the existing solver read-only and prints the numerical tables. It neither fits data nor alters previous outputs.

```python
import sys, math
sys.dont_write_bytecode = True
sys.path.insert(0, 'forecast_revision')
from math_model import CeilingModel, ContinuumCeilingModel

for p in [.3, .1, .03, .003, 1e-8, 1e-20, 1e-40, 1e-60]:
    m = CeilingModel([1, p], 6, [1-1e-7, 1e-7], log10_k0=-29)
    r = m.solve(scan=False)
    print('residual', p, r['log10_optimal_x'])

for M in [1, 2, 5, 10, 30, 100, 300, 1000]:
    p = [(i + .5)/M for i in range(M)]
    r = CeilingModel(p, 12, log10_k0=-29).solve(scan=False)
    print('finite spectrum', M, min(p), r['log10_optimal_x'])
print('continuum', ContinuumCeilingModel(12, log10_k0=-29)
      .solve(scan=False)['log10_optimal_x'])

N, k0, B = 1e120, 1e-29, 2
for alpha in [1, .1, .01, .003]:
    beta = alpha*(B-1)/k0
    timeout = alpha*(B-1)/(1+alpha*(B-1))*(N-1/k0)
    survival = math.exp(alpha*(math.log(beta)-math.log(beta+timeout)))
    logmedian = min(math.log10(timeout),
                    math.log10(beta)+math.log10(math.expm1(math.log(2)/alpha)))
    print('adaptive', alpha, math.log10(timeout), survival, logmedian)
```
