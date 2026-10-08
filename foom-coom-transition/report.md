Standalone post draft | Evidence through 2 October 2026

# The foom-coom transition

Suppose a being[^being] can spend compute in two ways.[^single-player] It can improve how efficiently it thinks and acts, making future computation more useful. Or it can use compute for what it ultimately values: having a good time, running beings with worthwhile lives, creating art, or making discoveries.

Call the first activity **fooming** and the second **cooming**. In the toy model below, an optimal policy does all its fooming first, then all its cooming. The question this post addresses is when to switch. Improvement can remain possible after it has stopped being worth the compute.

The answer depends on the last, hardest improvements. A power law can keep research worthwhile almost until the universe runs out of compute; other laws imply a much earlier switch. The subjective forecast below is much less secure than the stopping rule.

## The stopping rule

Assume a fixed remaining budget of $N$ raw FLOPs: floating-point operations, counted before any algorithmic efficiency gain. Research includes researcher cognition and computational experiments. One nondecreasing multiplier $a$, normalized to 1 today, improves research and cooming equally. There is no discounting, and value is linear in effective compute devoted to cooming. Cooming neither improves research nor creates more compute; research performed by beings it runs counts as fooming.

**Claim 1: Foom first, then coom.** Moving any cooming after the remaining research leaves that research unchanged and lets the cooming benefit from the final, highest multiplier. Thus there is an optimal policy with a single switch. If $x$ FLOPs go into research, the payoff is

$$U(x)=a(x)(N-x).$$

Define research's marginal log multiplier gain as $k(x)=d\ln a/dx$.

**Claim 2: If the optimal switch is in the first half of the budget, its marginal return threshold is of order $1/N$ per FLOP.** Differentiating the payoff gives, at a smooth interior optimum,

$$k(x_*)=\frac{1}{N-x_*}.$$

For $x_*\leq N/2$, this lies between $1/N$ and $2/N$. One more FLOP of research costs one FLOP of cooming but improves every FLOP still available for cooming. The question is when research efficiency drops through that threshold. For the smooth laws used below, the crossing gives the global optimum; a known breakthrough beyond a plateau can make the first crossing premature. At a hard cap, the marginal return jumps across the threshold.

For illustration, take $N=10^{120}$, inspired by [cosmological computation bounds](https://arxiv.org/html/astro-ph/0404510). This is a stipulated budget, not a measured endowment of future GPU FLOPs; Appendix G explains its provenance.

When little of the budget has been spent, the threshold is approximately $k=10^{-120}$ per FLOP: a multiplicative gain of about $1+10^{-120}$ per additional raw FLOP. The rest of the post estimates when returns reach this level. The stopping point is a compute expenditure, not a calendar date.

[^being]: It could be an AI, a human, humanity, or a whole world of AIs.

[^single-player]: This is a single-player world: there are no outside beings whose independent research it can benefit from. A civilization can contain many researchers, but all their research draws on the same compute budget.

<!-- pagebreak -->

## Why power laws keep research worthwhile

Consider a persistent power law in cumulative raw research:

$$a(x)=(1+k_0x/q)^q.$$

Here $k_0$ is today's marginal return and $q$ controls how strongly efficiency grows with research. When $k_0N$ is large, the optimum is

$$x_*\approx\frac{q}{1+q}N.$$

For $q=1$, spend approximately half the budget improving yourself. Even $q=0.1$ implies spending about 9%. An answer near $10^{120}$ is largely built into indefinite power-law growth. Accumulating more historical observations consistent with that law does not independently validate its remote extrapolation.

A finite ceiling on algorithmic efficiency still leaves open how much research is needed to approach it. Suppose today's return is $k_0=10^{-29}$ per FLOP and the maximum possible multiplier is $H=10^{12}$. Different ways of approaching that same ceiling give:

| Assumed approach to the ceiling | Optimal research FLOPs |
|---|---:|
| Exponentially shrinking execution-cost gap | $10^{29}$ |
| Power-decaying cost gap, exponent 1 | $10^{74.5}$ |
| Power-decaying cost gap, exponent 0.5 | $10^{93.4}$ |
| Power-decaying cost gap, exponent 0.25 | $10^{108.4}$ |

The cost gap is the remaining difference between the compute cost of a unit of effective work and its minimum possible cost. Here it shrinks with **effective research**, including the improvement of the researcher itself. Appendix A gives the equations. These are conditional calculations, not four empirical forecasts. Their extraordinary spread comes from the assumed behavior near the ceiling.

## What the evidence buys us

For calibration, I use present-day AI software progress as the closest available empirical foothold. Order-one annual log efficiency gains, divided by roughly $10^{29}$ **machine FLOPs/year used for AI R&D**, suggest $k_0$ around $10^{-29}$. This budget includes training and other computational experiments, evaluations, and research-directed AI inference; ordinary customer serving is excluded. It is estimated from hardware capacity and an assumed research share, without a measured split between experiments and AI researchers thinking. Human research thought is estimated separately at about $2\times10^{26}$ FLOP-equivalents/year under the central assumptions. The calibration therefore charges experiment compute to research; it is not a measured return per FLOP of researcher cognition alone.

Three more detailed analyses illustrate why the distant tail is harder to fit. In a controlled pretraining experiment, apparent saturation depends on which published measurements and evaluation metric are used. In the NanoGPT speedrun, an older curve fit suggested a 170-second training floor; later accepted records reached about 40 seconds. In six agent optimization trajectories, functions fitted through USD 1,000 often predicted later returns poorly. [Pretraining experiment](https://www.dwarkesh.com/p/pretraining-progress-is-mostly-data); [NanoGPT records](https://github.com/KellerJordan/modded-nanogpt/blob/4ea6b937337a4889b8cfe3f38a93d120048d8f71/README.md); [agent expenditure study](https://metr.org/blog/2026-07-21-expenditure-horizon/).

These results show both local exhaustion and ways around apparent limits. They do not identify which pattern survives another 91 orders of decline in marginal returns.

<!-- pagebreak -->

## Takeoff speed is a different question

The [AI 2027 takeoff forecast](https://ai-2027.com/research/takeoff-forecast) estimates time between capability milestones using elicited research requirements and AI research speedups. Reproducing its calculation gives roughly a year from superhuman coder to superintelligence. It does not specify when all further research becomes uneconomic.

[Forethought's software-explosion model](https://www.forethought.org/research/how-quick-and-big-would-a-software-intelligence-explosion-be) includes a decline in research returns as a ceiling approaches. Extending that rule smoothly to extreme precision can produce a very slow power tail. A toy translation gives a stop near $10^{114}$ FLOPs, while extending a finite-step version to a terminal cap gives about $10^{54}$. Neither is Forethought's forecast for this problem. They expose how much the unmeasured last part of the curve matters.

Human brains also fail to settle the question. An efficient brain demonstrates an attainable implementation, not the minimum compute any possible algorithm needs. Training efficiency, inference efficiency, research ability and the value of arbitrary thought are different quantities. Forethought explicitly allows gains beyond human learning efficiency; its numerical headrooms are judgments, not measured universal bounds.

## A subjective forecast

My working median is approximately **$5\times10^{117}$ research FLOPs**, or order **$10^{118}$**. That is about **0.5%** of the stipulated budget. The middle 50% of the distribution spans roughly **$10^{80}$ to $2\times10^{119}$**. I assign about **20%** to stopping by $10^{60}$, **46%** to spending at least 1% of the budget, and **32%** to spending at least 10%.

Those numbers come from an explicit mixture of possible improvement laws. They are subjective probabilities, not an empirical confidence interval. I give substantial weight both to persistent hard improvements and to finite completion or much faster convergence. The empirical evidence informs those possibilities without measuring their probabilities.

One consequential judgment is headroom. In finite-ceiling scenarios, I draw $\log_{10}H$ uniformly from 6 to 60, implying median headroom $10^{33}$. That is an intentionally broad assumption about the toy's universal multiplier; no cited study estimates it. Restricting the upper limit to $10^{16}$ gives a median stop around $10^{110}$. Different weights on completion and persistence move the median from about $10^{90}$ to $10^{119}$. Appendix F makes these choices explicit.

Finally, this is a distribution over optimal stopping points **if the improvement law were known**. It is not a recommendation to commit the median amount of compute in advance. Under uncertainty, research can reveal that a bottleneck is removable, that a promising route is exhausted, or that new opportunities exist. Choosing an adaptive policy requires a model of that learning.

The most useful empirical question is therefore how research changes the opportunities available to the next, better researcher. A plateau for today's optimizer is weak evidence for a plateau for its successors; continued historical progress is weak evidence for an indefinitely persistent power law. Those are the alternatives that drive the transition.

<!-- pagebreak -->

## The distribution on a computational scale

![Cumulative probability of the foom-coom transition, with Earth, Sun and Milky Way mass-equivalent operation budgets at two temperatures.](foom-coom-distribution.png)

**How to read the plot.** Height is the probability of having switched by the expenditure on the horizontal axis. The solid curve is the working distribution above; dashed curves change the weights on completion and persistence as specified in Appendix F. The lower panel enlarges the last ten orders of magnitude. The steep feature near the median comes from a narrow scenario family, not evidence for a precisely known stopping point.

**What the astronomical markers mean.** They assume complete conversion of a resource's rest energy into usable work, ideal erasure at the indicated temperature, and one erased bit per counted operation. For the Sun, that gives about $7\times10^{69}$ operations at today's cosmic background temperature, or $8\times10^{99}$ near the far-future de Sitter temperature. Mass alone therefore does not define a computation budget. These are conditional reference scales, not measured FLOP capacities; Appendix H gives the calculation, sources and limitations.

Under the far-future convention, about 29% of this distribution stops before an Earth-mass budget, 31% before a solar-mass budget, and 38% before the budget of the Milky Way's stars. These comparisons retain the model's total endowment $N=10^{120}$; they do not recalculate the optimal switch for a civilization confined to one of those smaller resources.

<!-- pagebreak -->

## Appendix A. Accounting for recursive improvement

Let $F$ denote cumulative effective research in units of what today's algorithms could accomplish. The common multiplier gives $dF/dx=a$. Define execution cost $C(F)=1/a(F)$. Then

$$x(F)=\int_0^F C(u)\,du,\qquad k=\frac{d\ln a}{dx}=\frac{da}{dF}=-\frac{C'(F)}{C(F)^2}.$$

This distinction matters: a power law in raw FLOPs is a different claim from a power law in effective research. Applying another recursive multiplier to a law already expressed in cumulative raw input would double-count the feedback.

Conversely, any positive nondecreasing raw path $a(x)$ is compatible with the shared-multiplier accounting. Define $F(x)=\int_0^x a(u)\,du$ and invert it. The substantive question is which research-production law to believe, rather than which coordinate is intrinsically legitimate.

The power cost-gap examples use $f=1/H$, $z=1+F/F_0$ and

$$C=f+(1-f)z^{-p},\qquad F_0=p(1-f)/k_0.$$

The choice of $F_0$ matches the same initial return in every scenario. Heterogeneous laws sum weighted gaps with a shared $F_0$, again chosen to match $k_0$. Integration gives $x=F_0[f(z-1)+(1-f)I_p(z)]$, where $I_p(z)=(z^{1-p}-1)/(1-p)$ and $I_1(z)=\ln z$. Returns satisfy $k=k_0z^{-p-1}/C^2$. Solving $x+1/k=N$ gives the table in the main text.

When the floor dominates both cost and the research integral, with $x_*\ll N$,

$$x_*\sim p(1-f)N^{1/(1+p)}k_0^{-p/(1+p)}f^{(p-1)/(1+p)}.$$

Thus more headroom postpones stopping for $p<1$, accelerates it for $p>1$, and cancels for $p=1$. More efficient research can exhaust even a larger set of improvements sooner in raw FLOPs. Exact solutions are needed outside this asymptotic regime.

Other scenarios use $C=f+(1-f)e^{-F/S}$ with $S=(1-f)/k_0$, or an exponential **efficiency** gap $a(F)=H-(H-1)e^{-F/S}$ with $S=(H-1)/k_0$. The latter is logistic in raw input. At $H=10^{12}$, these stop near $10^{29}$ and $10^{31.38}$ respectively: even the variable called “exponentially converging” matters.

A hard-cap scenario sets $a(x)=\min\{H,(1+k_0x/q)^q\}$. Its optimum is the smaller of the cap-reaching cost and the uncapped optimum:

$$x_* = \min\left\{\frac{q}{k_0}(H^{1/q}-1),\frac{q}{1+q}(N-k_0^{-1})\right\}.$$

Log-convex cost laws make $G=x+1/k$ nondecreasing; strictness gives a unique crossing and global optimum. Hard caps require evaluating the kink. Arbitrary laws with delayed breakthroughs need a global comparison: the first marginal crossing need not be the optimal stopping point.

<!-- pagebreak -->

## Appendix B. What theory does and does not imply

Blind independent sampling near a nondegenerate quadratic optimum in $d$ dimensions gives best error of order $n^{-2/d}$. That supplies one reason for a power law. It assumes a fixed proposal distribution and fixed evaluation cost, neither of which need survive an improvement in the researcher.

Adaptive optimization can concentrate the search. Suitable strongly convex objectives admit geometric convergence under specified oracle assumptions; noisy or less structured problems have polynomial lower bounds. These are conditional mechanisms, not competing universal theorems about intelligence. [Random Pursuit analysis](https://arxiv.org/abs/1111.0194); [stochastic optimization lower bounds](https://arxiv.org/abs/1009.0571).

An interacting-design model likewise derives slow improvement from complexity under a particular local redesign process. That supports the possibility of persistent bottlenecks, but does not establish that a smarter researcher must retain the same process or architecture. Universal algorithm-search results also retain strong provability conditions and potentially enormous overheads. [McNerney et al.](https://arxiv.org/abs/0907.0036); [Hutter's near-optimal search theorem](https://hutter1.net/ai/pfastprg.pdf).

**Many components do not automatically imply an arbitrarily slow tail.** For cost-gap components with exponents $p_i$ and weights $w_i$, marginal contributions contain the factor $p_iw_i\exp(-p_i\ln z)$. A sufficiently tiny exponent behaves almost like a fixed cost floor and contributes little derivative. The smallest exponent dominates only when its amplitude and crossover permit it.

A continuous spectrum with nonzero cost weight near zero exponent can produce logarithmically declining cost. That is a claim about opportunities that actually coexist in a world, not merely uncertainty about the exponent of one opportunity. The 5% continuous-hierarchy branch in Appendix F makes the stronger within-world assumption explicitly.

**A finite history cannot identify unrestricted continuations.** Consider an observed prefix ending at $x=10^{30}$, with $a=11$ there and initial slope $10^{-29}$. One can extend it with a plateau, a later jump to the same ceiling $H=10^6$, and a final plateau. Placing the jump appropriately yields global optima near $10^{31}$, $10^{60}$, $10^{100}$ or $9\times10^{119}$, while preserving the entire prefix and shared feedback. Narrow smooth rises can replace jumps. These examples establish nonidentification; they do not assert that every continuation is equally plausible.

Even finite headroom supplies weak bounds. Comparing the optimum with immediate consumption gives $x_*/N\leq1-1/H$. If $k$ is nonincreasing, integration gives the stronger result

$$\frac{x_*}{N}\leq\frac{\ln H}{1+\ln H}.$$

At $H=10^{12}$ this still permits about 96.5% of the budget. A finite ceiling alone cannot establish an early transition. The missing information concerns the shape and persistence of the remaining opportunities.

<!-- pagebreak -->

## Appendix C. Calibrating current returns

The starting estimate uses $k_0=s/R$, with $R$ the aggregate machine compute assigned to AI R&D: experimental training, evaluations and research-directed inference, excluding ordinary customer serving. This does not separately estimate inference performed by AI researchers; the experiment-versus-thinking split is unmeasured. The infrastructure calculation uses 6.147 million H100-equivalent units across five laboratories at end-2025, 1.979 petaflop/s dense 8-bit peak per unit, 25% realized utilization, 50% research allocation, and a factor of 1.3 for other laboratories. The last three are assumptions. They give approximately $6.24\times10^{28}$ annualized end-2025 research FLOPs; assuming 3.4-fold annual capacity growth gives $1.47\times10^{29}$ by mid-September 2026. [Epoch's capacity methodology](https://epoch.ai/data/ai-chip-users-documentation/methodology).

Order-one annual log growth $s$ then suggests $k_0\approx10^{-29}$. A separate accounting of 30,000 human researchers, 2,000 hours/year and $10^{15}$ brain-FLOP-equivalent/s gives $2.16\times10^{26}$ equivalents/year: about 0.2% of the rounded machine budget. These categories are not assumed to be similar in size. Brain equivalence is highly uncertain, and the human term can be substantial under higher estimates. [Brain-compute assessment](https://coefficientgiving.org/research/how-much-computational-power-does-it-take-to-match-the-human-brain/).

This is a whole-research-process normalization. Human thought, AI inference and experiments can be complementary inputs; their accounting totals do not identify their separate marginal contributions. A cognition-only model would need a different denominator and a model of experiment inputs. The common multiplier does not itself make these costs equal or interchangeable.

The numerical prior is $\log_{10}k_0\sim\mathcal{N}(-29,1.25^2)$, approximately a 90% range of $10^{-31}$ to $10^{-27}$. It represents judgment about calibration and transfer, rather than a regression confidence interval.

Reanalyses of public efficiency datasets provide local checks:

| Series analyzed | Result | What is missing for this model |
|---|---|---|
| ImageNet, six 2012-2019 observations | 44.9-fold endpoint gain; log gain 0.530/year | Complete research inputs and long-run curvature |
| Language models, 245 evaluations from 144 papers | Scaling-surface log gain 0.933/year | A stable universal output unit and autonomous-research transfer |
| GPQA open-frontier inference prices | Hardware-adjusted log gain 1.312/year | Prices are not FLOPs or discovery effort |
| AIME open-frontier inference prices | Hardware-adjusted log gain 1.360/year | Same limitation; correlated offerings |
| Stockfish, 258 matched observations | Simple power exponent 0.925; shifted-power exponent 1.669 | Cumulative tests are not total research FLOPs |

Sources for the first, second and fifth rows are the [ImageNet efficiency dataset](https://raw.githubusercontent.com/openai/ai-and-efficiency/master/efficiency_sota.csv), [language-model study and code](https://github.com/epoch-research/lm-algorithmic-progress), and [Stockfish research-returns study](https://arxiv.org/html/2405.10494v1).

Price fits regress log price on score controls and date, adjust hardware at 1.49-fold/year, and resample model clusters after date cleaning. The language-model estimate refits a scaling surface. Correlated specifications are sensitivity checks; prices remain imperfect compute proxies. [Inference paper and data](https://arxiv.org/abs/2511.23455).

If research flow and efficiency grow exponentially at rates $g_R$ and $s$, a further bridge gives $q\approx s/g_R$. Taking $g_R=\ln3.4$ implies $q\approx0.37$ from joint pretraining gains and 1.07-1.11 from GPQA/AIME. Persistent raw power laws would then imply optima of 27%-53% of $N$. This proxy and its indefinite continuation are assumptions.

<!-- pagebreak -->

## Appendix D. Empirical tests of curve shape

**Controlled pretraining vintages.** The public release of Patel and Han's experiment contains seven recipe-vintage multipliers, seven corpus-vintage multipliers and 50 checkpoint records. The recipes and corpora are assigned 2019-2025 vintages; measurements were released in September 2026. Recipe comparisons hold data fixed and corpus comparisons hold the recipe fixed. Checkpoint compute is approximately $10^{19}$ nominal FLOPs. [Experiment](https://www.dwarkesh.com/p/pretraining-progress-is-mostly-data); [immutable numerical release](https://huggingface.co/j23h67/compute-multipliers-checkpoints/tree/d92bd43970d5fb20a2c987025ae5892343bdb2db).

Let $t$ be vintage minus 2019 and $m(t)$ the reported multiplier. Fits anchor $m(0)=1$ and minimize squared errors in $\ln m$ for three laws:

$$\ln m=st;\qquad \ln m=p\ln(1+t/\tau);\qquad m=[f+(1-f)e^{-st}]^{-1}.$$

Training on vintages through 2023 and predicting 2024-2025 gives the errors below. This is retrospective ordered validation, not a prospective forecast. A second fit excludes only measurements the authors flag as crossings extrapolated beyond measured compute.

| Axis and selection | Full-fit $s$/year | Holdout log RMSE: exponential | Shifted power | Cost floor |
|---|---:|---:|---:|---:|
| Recipe, all | 0.0964 | 0.0940 | 0.2485 | 0.2987 |
| Recipe, omit extrapolated NeoX | 0.1180 | 0.3462 | 0.0492 | 0.0378 |
| Corpus, all | 0.2372 | 0.9567 | 0.9567 | 0.9567 |
| Corpus, omit extrapolated Pile | 0.2675 | 0.4986 | 0.7916 | 0.8778 |

All-observation full-sample floors approach zero. Excluding NeoX produces a recipe ceiling near 1.75-fold, while excluding Pile does not similarly support corpus saturation. The exponent here describes vintage time, not effective research. Shared reference curves prevent treating printed marginal intervals as independent errors.

There is an unresolved source discrepancy: the article reports 2019-2025 recipe/corpus gains of 3.7/12, while the released card reports 1.82/5.39. Both retain a joint annual factor of 1.57. These fits use the explicit released tables. Separate conditional axes must not be multiplied into a purported joint multiplier. The full 1,397-run crossing pipeline was unavailable, so this analysis does not replicate the entire training campaign.

The checkpoint audit reduces 50 rows to 45 distinct cell/seed combinations, averaging repeated pack-size variants first. Nominal $6ND$ agrees with run records, but their fuller FLOP formula is 1.166-1.589 times larger. On equal-seed means, 2025 versus 2023 corpora improve OLMES while worsening mixed-domain negative log likelihood by 0.1403 nats. Thus even a controlled experiment does not establish one task-independent efficiency trend.

These data measure the cost of executing selected recipes. They do not measure the research spent discovering those recipes, which is the denominator needed for the toy model.

<!-- pagebreak -->

## Appendix D, continued. Frontiers and agent budgets

**NanoGPT speedrun.** The analysis freezes 92 numbered records plus two retimings from one benchmark track. A timing-rule change requires starting the primary series in May 2025. All 65 linked later pull requests were date-audited: 62 acceptance dates differ from the record-table dates. Sorting by accepted date, collapsing same-day records and retaining the running minimum gives 46 frontier points. [Frozen record table](https://github.com/KellerJordan/modded-nanogpt/blob/4ea6b937337a4889b8cfe3f38a93d120048d8f71/README.md).

The outcome is timed training seconds on eight H100s at a prescribed FineWeb loss target. Fits minimize squared log-cost errors for $C=B e^{-rt}$, $C=B(1+t/\tau)^{-p}$ and $C=c+A e^{-rt}$. Training cutoffs in December 2025, March 2026 and June 2026 give later-period exponential log RMSEs of 0.213, 0.149 and 0.211. Alternatives approach the exponential limit, with holdout errors within 0.00011. Full-fit $r=0.924$/year implies 2.52-fold annual efficiency improvement. Selected timing, sampling and endpoint sensitivities span 0.85-1.01/year.

An older 19-record fit produces a 169.59-second floor and log RMSE 0.0956. Later records reach 39.9 seconds despite stricter timing. Conversely, the modern sample fits a 19.95-second floor nearly as well as zero. Both results caution against interpreting a fitted asymptote as a physical limit.

Architecture, kernels, context and model size can change. Review queues create bursts in acceptance dates. Failed research attempts are missing. GPU-seconds are neither actual FLOPs nor discovery effort, and efficient training need not imply equally efficient inference or research.

**Agent spending.** Six revalidated optimization trajectories were digitized from METR's July 2026 figure because no raw numerical trajectory release was found. The input is API plus GPU expenditure; the output is benchmark training-runtime improvement. Fits use 16 samples per log-dollar decade from USD 100 onward, train through USD 1,000 and predict the later observed budgets. These are samples of six dependent curves, not 166 independent experiments. [Primary study and figures](https://metr.org/blog/2026-07-21-expenditure-horizon/).

| Curve | Mean later-budget RMSE, percentage points |
|---|---:|
| Hold last observation | 0.212 |
| Logarithmic gain | 0.226 |
| Linear gain | 0.302 |
| Exponential or hyperbolic ceiling | 0.302 |
| Flexible power gain | 35.999 |

The persistence-versus-logarithmic ranking reverses under an alternate grid. Early ceiling fits approach linear limits, while a flexible power fit can catastrophically extrapolate a late step. The null GPT 5 run is retained. Two-pixel uncertainty is small relative to the largest prediction failures, but source experimental uncertainty cannot be recovered from pixels.

These trajectories are closer to research input versus output than calendar trends are. They still do not measure a universal multiplier, and exhaustion by a fixed agent does not establish exhaustion by an improving sequence of agents. The speedrun and agent experiments share a benchmark domain and should not be counted as independent task domains.

<!-- pagebreak -->

## Appendix E. What takeoff models constrain

**AI 2027.** The original model assigns human-only research requirements and AI R&D speedups to successive capability milestones. Within a phase requiring $h$ human-years, speedup rises exponentially from $v_0$ to $v_1$. Its continuous duration is

$$\Delta t=h\frac{v_0^{-1}-v_1^{-1}}{\ln(v_1/v_0)}.$$

A one-million-draw reproduction gives a median of 1.043 calendar years from superhuman coder to superintelligence, close to the published headline. Evaluating median inputs instead gives 0.813 years. The uncertain research requirements are elicited; fixed milestone speedups are 5, 25, 250 and 2,000. A 1,000-year cap per phase censors the implementation's extreme calendar tail. It is not an efficiency ceiling. [Pinned simulation](https://github.com/uvafan/timelines-takeoff-ai-2027/blob/2085376a178d709ec9c1461f5eef59e543751cd7/takeoff/forecasting_takeoff.py); [parameters](https://github.com/uvafan/timelines-takeoff-ai-2027/blob/2085376a178d709ec9c1461f5eef59e543751cd7/takeoff/params.yaml).

**AI Futures Model.** Its August 2026 version was inspected at a September 9 code snapshot. Central Q2 configurations calibrate software-stock returns near 3.14 and research-taste elasticities from 0.285 to 0.362. The simplified taste-feedback criterion compares that elasticity with the difficulty exponent, approximately 0.318; configurations fall on both sides. These are calibration outputs conditional on assumed historical progress, reconstructed inputs and elicited parameters. The model caps research taste while retaining software progress and includes training lag. [Pinned public code](https://github.com/AI-Futures-Project/aifm-public/tree/1c40ecdb246c25980515441a66571931c5604e11).

“Research taste” concerns how valuable a researcher's chosen experiments are. It need not multiply consumption, or remove a fixed experiment-compute bottleneck. Substituting an R&D speedup directly for the common $a$ therefore changes the interpretation.

For example, identifying software progress with $a(F)=(1+F/F_0)^r$, where $F_0=r/k_0$, gives

$$k(x)=\frac{k_0}{1+[(1-r)/r]k_0x}.$$

For $0<r<1$, the optimum is approximately $rN$. For $r>1$, the unlimited law diverges at $r/[(r-1)k_0]$. That is a failure of the unlimited continuation, not a prediction of physical infinity or a stopping point. A further regime must be specified.

The near-term models usefully ask how strongly better researchers accelerate progress. They do not identify what happens to the very last valuable improvement. A fast takeoff and an early research stop can coexist, as can a fast takeoff followed by an extremely long period of economically worthwhile refinements.

<!-- pagebreak -->

## Appendix E, continued. A Forethought-style taper

Forethought separates cognitive labor, experimental compute and software in parallel-labor-equivalent units. Its headroom and return parameters include substantial judgment. Replicating its near-term simulation reproduces reported event probabilities to about a percentage point; that does not validate an extension to cosmic research budgets. [Software-explosion model](https://www.forethought.org/research/how-quick-and-big-would-a-software-intelligence-explosion-be).

The following is an independent mathematical translation. Set $y=\ln a$, $L=\ln H$ and $r(y)=r_0(1-y/L)$. Identifying the software coordinate with $a$ and holding raw throughput fixed, integrate $d\ln k/dy=p(1-1/r(y))$ to obtain

$$k(y)=k_0e^{py}(1-y/L)^\nu,\qquad \nu=pL/r_0.$$

For $\nu>1$, the ultimate cost-gap exponent is $1/(\nu-1)$. A linear taper in research returns therefore imposes a power tail. This assumption concerns how the ceiling is approached, not just its height.

A central source parameter corresponds to eleven years of normal overall progress. Four annual software doublings divided by a 0.5 software share gives eight doublings per such year: $H=256^{11}\approx10^{26.49}$ in the source's labor units. At $p=0.3$ and $r_0=1.2$, the implied gap exponent is 0.0702. The continuous toy extension stops around $10^{114.14}$ FLOPs.

| Extension to a terminal ceiling | $\log_{10}x_*$ |
|---|---:|
| One full doubling per step, then cap | 54.42 |
| Ten subdivisions per doubling | 68.62 |
| One hundred subdivisions | 82.87 |
| One thousand subdivisions | 97.12 |
| Continuous extension | 114.14 |

These are structural stress tests, not competing Forethought forecasts. The large difference shows why a numerical stopping convention innocuous for near-term plots cannot be assumed to identify the remote tail. The direct coordinate mapping is itself an extra assumption; the source's elasticity includes fixed experiment bottlenecks absent from the common-multiplier toy model.

**Brains and headroom.** Forethought's proposed gains beyond human learning are not measured independent factors. Its brain-undertraining notebook assumes $10^{14}$ putative parameters and $10^{24}$ lifetime FLOP-equivalents, then optimizes a language-model loss law at equal loss. Independent reproduction gives about 28,850-fold cheaper training, primarily by replacing the assumed huge undertrained network with a much smaller model. [Notebook](https://colab.research.google.com/drive/1kpl6B9MHkYUwLSSleOk02pAnpSGxE25H); [physical-limits discussion](https://www.forethought.org/research/how-far-can-ai-progress-before-hitting-effective-physical-limits).

The optimization is valid for the specified analogy. The analogy does not establish that synapses are transformer parameters, that sensory experience is equivalent to tokens, or that equal predicted language-model loss represents equal cognitive value. It cannot bound universal useful thought per FLOP. Nor should hardware gains per joule be counted again inside $a$ after the budget has already been stipulated in raw FLOPs.

<!-- pagebreak -->

## Appendix F. The subjective distribution

The forecast uses a mixture of known-law optima. Its probabilities describe which mathematical continuation might approximate future research; they are not a likelihood-based posterior. The numerical choices were specified before calculating pooled quantiles.

| Family | Weight | Conditional parameters |
|---|---:|---|
| Single power cost gap | 25% | $p$ lognormal, median 0.5, log SD $\ln3$ |
| Persistent heterogeneous gaps | 20% | Fast $p$ log-uniform 0.5-2; slow 0.03-0.3; slow cost weight log-uniform $10^{-12}$-$10^{-2}$ |
| Rapid or finite completion | 20% | Equal thirds: exponential cost gap, exponential efficiency gap, capped raw power |
| Smooth return taper | 10% | $r_0$ log-uniform 0.4-3.6; elasticity $p$ log-uniform 0.3-1 |
| Continuous slow hierarchy | 5% | Uniform within-world cost weights over $0<p<1$ |
| Effectively uncapped raw power | 20% | $q$ lognormal, median 0.7, log SD 0.6 |

All finite-ceiling branches use $\log_{10}H$ uniform on 6-60. All use $\log_{10}k_0$ normal with mean -29 and SD 1.25. The capped raw-power branch uses the same $q$ distribution as the uncapped branch. Parameters are independent within branches except where the law imposes a relation. The continuous hierarchy integrates the power cost gaps in Appendix A over exponent; its initial slope is normalized to $k_0$.

The empirical input is strongest for the order of magnitude of $k_0$ and much weaker for a temporary raw exponent near the 0.37-1.11 bridges. Neither the exponent's persistence nor the mixture weights are measured. The effective cost-gap and taper parameters are deliberately broad assumptions.

The motivation for substantial persistent-return mass is that useful research can expose new questions and harder opportunities, while local plateau fits demonstrably fail. The motivation for completion mass is that adaptive redesign can remove a bottleneck, and no theorem guarantees an endless sequence of valuable residual gains. Those considerations justify uncertainty; they do not determine the numerical weights.

The headroom prior is especially consequential. Its median is $10^{33}$, which is a judgment about a highly abstract common multiplier, not a biological or empirical estimate. Even its millionfold lower bound is a judgment. Allowing $H=10^1$-$10^{60}$ gives median stop exponent 117.50 and 43.9% probability above 1% of $N$, compared with 117.68 and 45.9% centrally. Allowing only $10^1$-$10^{16}$ gives 107.06 and 24.6%.

A finite cap is not necessarily reached: 17.1% of capped-power draws remain below it at their optimal switch. Those draws are retained. In the taper branch, larger headroom also lowers the implied terminal gap exponent. Holding that exponent fixed when varying headroom is a different, separately evaluated sensitivity.

These branches are proxies, not an exhaustive classification of future science. Their mathematical overlap should not be mistaken for several independent pieces of evidence supporting the same outcome.

<!-- pagebreak -->

## Appendix F, continued. Results and sensitivity

The computation uses 1,024 scrambled Sobol draws per explicit subfamily and exact remaining-budget stopping conditions. The three completion subfamilies split their parent weight equally. Across three headroom ranges, 24,576 scenario evaluations approximate integrals over the specified prior; they are not 24,576 empirical observations.

| Assumptions | Median $\log_{10}x_*$ | Probability $x_*\geq0.01N$ |
|---|---:|---:|
| Central mixture, $H=10^6$-$10^{60}$ | 117.68 | 45.9% |
| Same weights, $H=10^6$-$10^{16}$ | 109.73 | 26.9% |
| Same weights, $H=10^6$-$10^{120}$ | 118.66 | 55.8% |
| More completion, central headroom | 89.57 | 28.4% |
| More persistence, central headroom | 118.54 | 53.8% |
| Remove guaranteed slow residual from heterogeneous branch | 99.48 | 31.0% |

In table order from Appendix F, the more-completion weights are 25/10/45/5/5/10%; the more-persistence weights are 20/25/5/15/10/25%. The last sensitivity retains each heterogeneous draw's fast component, removes only its slow residual, and recalibrates to the same $k_0$. It tests the consequence of assuming such a residual always survives; it does not establish that residuals are absent.

The central 5th-95th percentile range is $10^{29.36}$-$10^{119.71}$; the middle 50% is $10^{80.10}$-$10^{119.25}$. The narrow continuous-hierarchy branch pins extra decimals of the median. Removing it and renormalizing gives median exponent 117.43 and 48.3% probability above 1% of $N$. The late result is not solely an artifact of that branch, but the decimal precision is not scientifically meaningful.

**Known-law optima versus decisions under uncertainty.** If the law is unknown and a fixed allocation must be chosen now, the objective is

$$(N-x)\mathbb{E}[a(x)].$$

An interior optimum therefore depends on $\mathbb{E}[ak]/\mathbb{E}[a]$, not the mean or median of individual-law stopping points. Very productive rare worlds can matter disproportionately. An adaptive policy additionally conditions on discoveries and failures. The scenario distribution supplies neither the observation model nor that policy.

The most informative further experiments would record complete research expenditure, including failed attempts, and compare successive generations of researchers on stable output targets. Do stronger researchers merely reach the same ceiling faster, bypass it, or uncover new bottlenecks? That distinction could inform a model of persistence and replacement. Fitting another smooth curve to a short selected record frontier cannot supply the same information.

Numerical checks used alternative equations and up to 100-digit arithmetic for representative new families, agreeing within $1.4\times10^{-12}$ in $\log_{10}x_*$. This verifies calculations conditional on the laws; it does not validate the laws. The analysis and its code were prepared with Codex assistance. All probabilities should be read as explicit modeling judgments.

<!-- pagebreak -->

## Appendix G. Why use a budget of $10^{120}$?

There are two related but different physical claims behind this familiar scale.

Seth Lloyd's [“Computational Capacity of the Universe,” Physical Review Letters 88, 237901 (2002)](https://doi.org/10.1103/PhysRevLett.88.237901) estimates an upper bound of order $10^{120}$ elementary operations in the observable universe over its history up to the present. Its [preprint](https://arxiv.org/abs/quant-ph/0110141) appeared in 2001. This is not an estimate of how many future floating-point instructions can be executed.

Krauss and Starkman's [“Universal Limits on Computation” (2004), equation (8)](https://arxiv.org/html/astro-ph/0404510) gives approximately $1.35\times10^{120}$ future processed bits under idealized de Sitter energy-harvesting and thermal-noise assumptions. [Wei Dai's 2014 LessWrong discussion](https://www.lesswrong.com/posts/BNbxueXEcm6dCkDuk/is-the-potential-astronomical-waste-in-our-universe-too) uses approximately $10^{120}$ operations and links to that paper.

The toy model borrows this order of magnitude and stipulates a raw-FLOP budget. Elementary physical operations, information-processing bits, GPU arithmetic and valuable cognitive work are not interchangeable units. Converting between them would require further physical and computational assumptions. The model also ignores when resources become accessible and what fraction can be captured.

Using a different $N$ changes the stopping calculation. For an indefinitely persistent raw power law, $x_*$ remains approximately a fixed fraction of $N$. For a floor-dominated effective cost gap with exponent $p$, the asymptotic dependence is $x_*\propto N^{1/(1+p)}$. Thus the cosmic number sets a scale, while the research law determines how that scale enters the answer.

The conclusions here concern a stipulated finite budget and one shared algorithmic multiplier. They do not establish a physical limit on intelligence, a date for superintelligence, or a forecast of how a real civilization will allocate its resources.

<!-- pagebreak -->

## Appendix H. Turning astronomical masses into reference budgets

The figure uses an ideal thermodynamic calculation. If a mass $M$ supplies usable work $W=\eta Mc^2$, erasing an initially unknown bit into a bath at temperature $T$ requires at least $k_BT\ln2$. Thus the ideal erasure budget is

$$B_{\rm erase}=\frac{\eta Mc^2}{k_BT\ln2}.$$

This is also a negentropy accounting: one bit of entropy disposal is $k_B\ln2$, and work $W$ can supply entropy disposal $W/T$. The figure sets $\eta=1$, an optimistic normalization that assumes access to all rest energy as work. Actual extraction, storage, hardware and heat disposal impose additional constraints. [Experimental test of Landauer's principle](https://doi.org/10.1038/nature10872).

Two temperatures illustrate the dependence. Today's cosmic background is about 2.725 K. If dark energy remains a cosmological constant, the asymptotic de Sitter temperature is $T_\infty=\hbar H_\infty/(2\pi k_B)$, where $H_\infty=H_0\sqrt{\Omega_\Lambda}$. Using $H_0=67.4$ km/s/Mpc and $\Omega_\Lambda=0.685$ gives $T_\infty\approx2.20\times10^{-30}$ K. This cold limit additionally assumes patient resource storage and ideal operation arbitrarily close to the bath temperature. [CMB measurement](https://arxiv.org/abs/0911.1955); [Planck cosmological parameters](https://arxiv.org/abs/1807.06209); [Gibbons-Hawking temperature](https://doi.org/10.1103/PhysRevD.15.2738).

| Resource | Mass in kg | Erasures at 2.725 K | Erasures at $T_\infty$ |
|---|---:|---:|---:|
| One kilogram | 1 | $3.45\times10^{39}$ | $4.27\times10^{69}$ |
| Earth | $5.97\times10^{24}$ | $2.06\times10^{64}$ | $2.55\times10^{94}$ |
| Sun | $1.99\times10^{30}$ | $6.85\times10^{69}$ | $8.50\times10^{99}$ |
| Milky Way stars | $1.08\times10^{41}$ | $3.72\times10^{80}$ | $4.61\times10^{110}$ |

Earth and Sun masses come from [NASA's Earth](https://nssdc.gsfc.nasa.gov/planetary/factsheet/earthfact.html) and [Sun fact sheets](https://nssdc.gsfc.nasa.gov/planetary/factsheet/sunfact.html). The galactic marker uses [McMillan's estimate](https://arxiv.org/abs/1608.00971) of $5.43\times10^{10}$ solar masses in stars; it does not count dark matter as usable fuel.

To place these budgets on the toy's axis, the plot assumes one erased bit per operation. If an operation erases $b$ bits, its reference budget is $B_{\rm erase}/b$: multiply the plotted budgets by $\eta/b$. For example, 1% usable work shifts every mass marker two decades left. There is no fixed physical conversion from erasures to FLOPs. [Reversible computation](https://www.cs.princeton.edu/courses/archive/fall04/cos576/papers/bennett73.html) can perform logical steps without one bit of erasure per step, so Landauer's bound alone does not bound all logical operations this way.

A black hole provides another entropy scale, but not a unique operation allowance per kilogram outside it. A Schwarzschild hole has entropy $S_{\rm BH}/(k_B\ln2)\approx1.5\times10^{77}(M/M_\odot)^2$ bits. That describes a final black-hole state; equating it to useful computation requires an extraction and entropy-disposal process. An existing hole used as a sink introduces its own mass and temperature. The figure therefore uses explicit work and bath assumptions. [Hawking's black-hole thermodynamics](https://doi.org/10.1007/BF02345020).
