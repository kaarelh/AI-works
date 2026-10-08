# Takeoff models, headroom, and the distant stopping threshold

Research snapshot: **2 October 2026**. This contribution reads the prior report and its forecast, calibration, and empirical-methods revisions. It changes none of those files. Numerical results below use `N=10^120` and `k0=10^-29` unless otherwise stated.

**The new literature does not establish a low human-brain ceiling or an empirically identified cosmic stopping distribution.** It does supply useful calibrations of nearby feedback and explicit saturation assumptions. Reproducing those assumptions shows why the far tail remains decisive: one Forethought-inspired common-multiplier extension stops around `10^114.14` research FLOPs, while a finite-step terminal convention built from the same near-term model stops around `10^54.42`. Neither is the authors' forecast for this toy problem.

## Findings to carry into the revised forecast

1. **Do not use human brains as a hard universal ceiling.** The brain comparison is a reference point in learning efficiency. The sources explicitly posit further headroom beyond it. A reproduced scaling-law analogy yields roughly 4.46 orders of training-compute savings relative to one assumed brain-like parameter/data configuration, but does not measure a brain's algorithm or prove a universal upper bound.
2. **Separate headroom coordinates.** Training efficiency, inference efficiency, research taste, parallel-labor-equivalent software, and physical operations per joule are different quantities. Mapping one of them onto the common multiplier `a` is a substantive assumption.
3. **The latest AI Futures Model caps research taste, not software efficiency.** Its software research-production equation remains a power law in accumulated research effort. The central calibrated return to this stock is about 3.14. Identifying that software power law directly with the user's common multiplier gives a finite-input singularity, so a further saturation model is indispensable.
4. **A source's smooth saturation rule can generate a very slow tail.** The effective cost-gap exponent of the median continuous Forethought-inspired extension is about 0.0702. This follows from an assumed taper of research returns; it is not a newly measured empirical exponent.
5. **The previous `10^110` median remains a scenario-weight judgment.** These sources justify revising its supporting discussion and stress-testing headroom and tail priors. They do not provide likelihood ratios with which to replace those priors by a well-identified posterior.

## Original AI 2027: what the replication establishes

The original forecast uses milestone research requirements and AI R&D speedups to estimate calendar time from a superhuman coder to superintelligence. I independently reproduced its probability model with one million draws and integrated the within-phase speedup analytically. The resulting SC→ASI median is **1.043 years**, consistent with its roughly one-year headline. The source's 1,000-year cap per phase censors its extreme calendar tail. No part of that cap is an estimate of an ultimate efficiency ceiling. See the [original-method appendix](ORIGINAL_AI2027.md), [replication output](original_replication.json), and [primary forecast](https://ai-2027.com/research/takeoff-forecast).

The critical transferable question is whether better research capability yields more efficient research, and at what elasticity. The milestone speedups themselves cannot be substituted for `a`: they include experiment bottlenecks and changes in the quality and organization of labor. The code contains no consumption objective or `10^-120` stopping condition.

## Latest AI Futures Model: different defaults imply different feedback judgments

The public site identifies its model as the August 2026 revision. The repository snapshot used here is `1c40ecdb246c25980515441a66571931c5604e11`, dated 9 September 2026. Reproducing the authors' central Q2 configurations gives:

| Central configuration | Software-stock return `r` | Difficulty exponent `β=1/r` | Taste elasticity `m` | `m/β` |
|---|---:|---:|---:|---:|
| Daniel | 3.14465 | 0.31800 | 0.36157 | 1.1370 |
| Eli | 3.13775 | 0.31870 | 0.28452 | 0.8927 |
| Brendan | 3.14326 | 0.31814 | 0.35017 | 1.1007 |

The idealized taste-only accelerating-feedback condition is `m>β`. The configurations straddle this boundary. These numbers are model calibration outputs conditioned on assumed historical software progress, reconstructed research inputs, and elicited taste parameters. They are not direct regressions of autonomous researchers' universal efficiency against FLOPs. The [current-model audit](aifm_current/REPORT.md) documents exact equations, calibration inputs, parameter status, source lines, and discrepancies between Python defaults, frontend presets, and forecast configurations. [Public source code](https://github.com/AI-Futures-Project/aifm-public).

A cap on taste means that experiments eventually stop becoming more valuable through that channel; it does not imply that software discoveries or all useful algorithms stop improving. The latest code also incorporates training lag. Its idealized singularity threshold survives in a simplified asymptotic analysis, but the old lag-free doubling-ratio diagnostic is not the matching ratio for the newer dynamics. This is material for interpreting near-term takeoff outputs; it still provides no empirical terminal law for `a`.

## Forethought: quantitative reproduction and the tail extension

The quick/big software-explosion simulation separates cognitive labor from experimental compute, samples research returns and remaining software headroom, and updates successive doubling times. A 50,000-draw replication reproduces the published near-term event probabilities to roughly a percentage point. The source reports large **upward capability-equivalent** training headroom beyond human learning; its software coordinate is expressed in parallel-labor equivalents. The detailed source audit, including material through September 2026, is in [Forethought methods and replication](forethought/REPORT.md). [Primary study](https://www.forethought.org/research/how-quick-and-big-would-a-software-intelligence-explosion-be).

Here is the new mathematical sensitivity, explicitly outside the source's forecast scope. Let `S` be its software coordinate and `D` a doubling time. Take the continuous extension

\[
\frac{d\ln D}{d\ln S}=p\left(\frac1{r(S)}-1\right),\qquad
r(S)=r_0\left(1-\frac{\ln S}{\ln H}\right).
\]

With constant raw compute throughput, an explicit identification `S=a`, and normalization to `k0`, this gives

\[
k(a)=k_0a^p\left(1-\frac{\ln a}{\ln H}\right)^\nu,
\qquad \nu=\frac{p\ln H}{r_0}.
\]

Near the ceiling, the remaining gap shrinks as a power of raw or effective research when `ν>1`, with cost-gap exponent `1/(ν−1)`. For the central assumptions `p=.3`, `r0=1.2`, and headroom equivalent to eleven years of normal **overall AI progress**, the code uses **`H=256^11≈10^26.49`** in labor-equivalent units. The conversion assumes four historical software doublings per year and a one-half software share, hence 88 software doublings. This gives `ν=15.2492` and cost-gap exponent `0.07018`.

| Declared toy extension | `log10 x*` |
|---|---:|
| Continuous rule, equating labor-equivalent `S` with `a` | 114.143 |
| Power reparameterization to training-efficiency units, reanchored to the same `k0` | 113.761 |
| Heuristic common improvement of both labor and experiments, preserving the assumed difficulty schedule | 113.622 |
| Literal finite-doubling recurrence with a terminal ceiling | 54.421 |
| Same recurrence, ten subdivisions per doubling | 68.623 |
| Same recurrence, one hundred subdivisions per doubling | 82.867 |
| Same recurrence, one thousand subdivisions per doubling | 97.116 |

The finite-step entries extend the source past its near-term display horizon and optimize a piecewise exponential toy trajectory. They are numerical/structural stress tests, not observations. The gradual movement toward the continuous result shows that a finite-step terminal convention leaves a consequential unresolved tail. The continuous result is also conditional: `p` originally includes fixed experiment bottlenecks, so its direct transport is not licensed by the user's common-multiplier assumption.

The source-range continuous scenarios extend from near `10^55` to a material fraction of the budget. One example stops at 9.53% of `N`; the `k=1/N` crossing would instead occur after about 10.5%. All reported optima use `k=1/(N−x)` exactly. Numerical integration was checked against an independent positive-term series.

Recent updates refine bottlenecks and distinguish shrinking doubling times from shrinking generation times. They do not empirically identify a residual return 91 orders below today's. In particular, [Ord's August 28 dynamics paper](https://www.forethought.org/research/the-dynamics-of-intelligence-explosions) makes the distinction between superexponential calendar growth and finite-time blow-up explicit. A minimum generation duration can limit calendar acceleration without proving that cumulative raw-FLOP research has ceased to be worthwhile.

The [September 28 AI R&D automation paper](https://arxiv.org/abs/2609.36054) uses the illustrative production law `dA/dt=A^(1−β)E^λ` and averages earlier subfield estimates to `λ=1.40`, `β=1.01`. Under `E∝A`, the growth rate rises by `2^0.39=1.3104` per doubling; nine doublings starting from a 4.5-month doubling time take about 17.33 months. Its supplementary discussion flags the unresolved conversion from scalar efficiency to capabilities and confounding from growing experimental compute. It supplies no new terminal law. In a purely assumed common-multiplier transport with the starting slope reanchored to `k0`, those unlimited exponents would yield a singularity at `1/(.39 k0)≈2.56×10^29` raw FLOPs. That again identifies the need for a saturation extension, not a finite optimum.

## What the brain comparison does and does not show

The [independent brain audit](brain_audit/REPORT.md) reproduces the public undertraining notebook and checks its interpretation. It assumes `10^14` brain parameters and `10^24` lifetime FLOP-equivalents, maps them into a language-model loss law, and optimizes parameter count and data at the same predicted loss. The optimum reduces training compute by about **28,850×**, primarily by replacing the assumed huge undertrained network with a much smaller model. This is a scaling analogy; brain synapses are not demonstrated to be transformer parameters and sensory experience is not demonstrated to be training tokens.

That exercise concerns learning at matched loss. It does not measure a common multiplier on arbitrary inference, creative research, or valuable consumption. Biological limitations such as connectivity, sample exposure, copying, communication, and exact weight sharing provide plausible mechanisms for improvement. Their gains overlap, depend on the task, and do not form a measured independent product. Thermodynamic hardware bounds concern physical operations and require another conversion before being applied to FLOPs or useful thought.

The defensible implication is that a narrow ceiling near human efficiency is unsupported. It is equally unjustified to treat a large list of possible improvements as a precise universal ceiling or as evidence of an indefinitely continuing power law.

## Consequences for the stopping forecast

The [toy-model appendix](TOY_TRANSFER.md) solves a 30-row headroom/tail grid and constructs laws with **identical initial slope and identical final headroom**. At `H=10^12`, exponential marginal decline stops around `10^32.76` FLOPs, while a slowly declining integrable power marginal can stop around `10^118.53`. These constructions obey `dF/dx=a` without importing an experiment bottleneck. Independent calculations in the brain audit agree with these examples.

I recommend carrying the continuous Forethought-inspired taper as a named sensitivity scenario, and withdrawing any claim that the old `10–10^12` headroom prior was imposed by human-brain efficiency. I do **not** recommend assigning the `10^114.14` result a special evidential weight simply because its taper appears in an existing takeoff model. The new work makes that taper more transparent; it does not validate it over cosmic research inputs.

A better forecast presentation should state the probability judgment over tail families separately from the evidence for current productivity and nearby feedback. It should retain conditional results rather than average superficially similar takeoff estimates. The principal uncertainty remains the approach to saturation, including discovery of new kinds of improvement, rather than the precise contemporary normalization.

## Reproducibility and provenance

Start with [REPRODUCE.md](REPRODUCE.md). Source copies, repository commits, hashes, exact parameter files, scripts, and machine-readable outputs are all under this folder. The separate appendices document which calculations were run and which outputs are analytic or judgmental. No source provides an empirical posterior for the toy model's stopping allocation, and no new mixture weights were estimated in this contribution.
