GPT-6 (Codex) — 2026-09-12

# Empirical stopping estimates from multiple methods

Companion to [[will fooming be done?]] and [[FLOP law and stopping point — derivation]].

**The additional fits do not identify one stopping scale.** Under an unbounded power law relating efficiency to cumulative raw research compute, most estimates spend a substantial fraction of the $10^{120}$-FLOP budget on fooming. Fitted ceilings instead produce stops as early as $10^{29}$ FLOPs. Several structural recursive fits never reach the diminishing-gain threshold: their extrapolated equations diverge at finite input. The disagreement is chiefly about the extrapolated law and the meaning of research input, not an ordinary error bar on one parameter.

I fitted actual observations, including inference price/performance observations through April 2026, rather than generating artificial data from reported doubling times. I also refitted historical Stockfish and neural-network observations, reran published Bayesian endpoint models, and fitted recent lab research-input growth. The tables retain unfavorable, nonpositive, insufficient-data and unidentified-tail outcomes. Variants using the same observations are sensitivity checks, not independent evidence.

The complete numeric inventory is [all_methods.csv](all_methods.csv), with nested diagnostics in [all_methods.json](all_methods.json). This `empirical_methods` directory contains inputs, scripts, source hashes, method reports and results. The tables below distinguish actual observations from assumptions needed to translate them into raw FLOPs.

## The quantity being predicted

Let $x$ be additional raw FLOPs spent on research, $a(x)=\alpha(x)/\alpha(0)$, and

$$k(x)=\frac{d\ln a}{dx},\qquad k(0)=k_0=10^{-27.5},\qquad N=10^{120}.$$

The one-FLOP multiplier is $\exp[\int_x^{x+1}k(u)du]\simeq1+k(x)$ in the tiny-gain regimes. The optimal transition maximizes $a(x)(N-x)$ and satisfies

$$k(x_*)=\frac{1}{N-x_*}.$$

I report both **the optimal stopping input $x_*$** and **the exact $k=10^{-120}$ crossing $x_{120}$**. They can differ substantially, and the latter can lie beyond the available budget. If almost all FLOPs have already been spent, the economically optimal gain need not be of order $10^{-120}$ at all.

The starting marginal gain $k_0$ is your calibration, not something these datasets independently establish. Test counts, publication counts, lab compute estimates and calendar time do not directly measure all human and AI thought devoted to universal algorithmic improvement. Thus these are empirical shape fits with an imposed absolute normalization. Fixed-task efficiency is also only a proxy for the universal multiplier in your note.

## Current inference data: price, quality and date regressions

The [source repository](https://github.com/hansgundlach/Algorithmic_Progress_Inference) was frozen at commit `c34454ed3110e667a885d6d2b0167de4cbc98e8e`, dated July 4, 2026. It extends beyond the data described in the [March 2026 paper](https://arxiv.org/html/2511.23455v2). These are independent regressions of benchmark cost, controlling for score and observation date. The primary score control is logit(score); alternatives use robust soft-L1 loss or a linear score control. “Frontier” means no earlier or same-date model is both cheaper and at least as capable; open-model frontiers are formed within the open subset.

To extract a software proxy, subtract hardware improvement from the fitted log price-performance trend: $s=-b_{\rm date}-\ln H$. The primary hardware adjustment is $H=1.49$ per year from [chip performance per dollar](https://epoch.ai/data-insights/chip-performance-per-dollar). The second adjustment is $H=1/0.7$, matching the paper. Prices still contain utilization, serving, margins and subsidy effects, including for open models.

To convert calendar growth into a research law, assume cumulative raw research compute $X$ grows at $G$ per year. Then

$$p=\frac{s}{\ln G},\quad a(x)=\left(1+\frac{k_0x}{p}\right)^p,\quad k(x)=\frac{1}{10^{27.5}+x/p}.$$

The primary $G=3.4$ is [aggregate AI compute capacity growth](https://epoch.ai/trends). Treating capacity as cumulative research FLOPs requires constant research share and utilization, plus approximately exponential prehistory. The $G=5$ sensitivity uses frontier training-run compute, a less direct proxy for aggregate research. No extra recursive multiplier is applied after defining the fitted input as raw compute.

For any positive $p$,

$$x_*\simeq\frac{p}{1+p}N,\qquad x_{120}\simeq pN,\qquad k(x_*)\simeq(1+p)10^{-120}.$$

The primary results below use $H=1.49,G=3.4$. `Nonpositive` means the estimated hardware-adjusted trend is incompatible with imposing positive $k_0$ in this power-law family; it is not evidence that all future algorithmic progress ends. `Insufficient` means fewer than eight usable frontier points.

| Benchmark | Estimator/sample | n | Adjusted gain/year | Optimal FLOPs | Exact threshold FLOPs |
|---|---|---|---|---|---|
| GPQA-Diamond | All offerings, OLS | 165 | 3.016× | 4.743e119 | 9.021e119 |
| GPQA-Diamond | Open offerings, OLS | 85 | 0.859× | Nonpositive | — |
| GPQA-Diamond | All-model frontier, OLS | 56 | 8.526× | 6.365e119 | 1.751e120 |
| GPQA-Diamond | Open frontier, OLS | 44 | 3.713× | 5.174e119 | 1.072e120 |
| GPQA-Diamond | Open frontier, robust | 44 | 3.058× | 4.774e119 | 9.135e119 |
| GPQA-Diamond | Open frontier, linear score | 44 | 2.927× | 4.674e119 | 8.776e119 |
| AIME | All offerings, OLS | 136 | 4.404× | 5.478e119 | 1.211e120 |
| AIME | Open offerings, OLS | 66 | 2.178× | 3.887e119 | 6.359e119 |
| AIME | All-model frontier, OLS | 52 | 6.560× | 6.058e119 | 1.537e120 |
| AIME | Open frontier, OLS | 35 | 3.896× | 5.263e119 | 1.111e120 |
| AIME | Open frontier, robust | 35 | 3.274× | 4.922e119 | 9.692e119 |
| AIME | Open frontier, linear score | 35 | 2.853× | 4.614e119 | 8.566e119 |
| SWE-bench Verified | All offerings, OLS | 31 | 0.822× | Nonpositive | — |
| SWE-bench Verified | Open offerings, OLS | 9 | 0.010× | Nonpositive | — |
| SWE-bench Verified | All-model frontier, OLS | 17 | 3.768× | 5.201e119 | 1.084e120 |
| SWE-bench Verified | Open frontier, OLS | 6 | — | Insufficient | — |
| SWE-bench Verified | Open frontier, robust | 6 | — | Insufficient | — |
| SWE-bench Verified | Open frontier, linear score | 6 | — | Insufficient | — |


The primary fits exclude three source dates that precede the documented model-release month: one Qwen3 GPQA point and two Claude Opus 4.1 AIME points. Release dates were checked against the [official Qwen announcement](https://qwenlm.github.io/blog/qwen3/) and [official Anthropic announcement](https://www.anthropic.com/news/claude-opus-4-1). Removing the anomalous early Qwen point changes GPQA frontier membership and raises its primary estimate from 4.45e119 to 5.17e119 FLOPs. Original rows and all twelve before-cleaning point-fit sensitivities remain archived; no replacement dates were invented.


For the primary open-frontier OLS fits, the individual fitted laws and conditional bootstrap intervals are:


- **GPQA-Diamond**: $k(x)=1/(10^{27.5}+0.9328x)$; stop **5.174e119 FLOPs**; exact threshold **1.072e120**. Conditional bootstrap 5th–95th percentiles: 3.491e119–6.561e119; positive-slope share 100.00%.


- **AIME**: $k(x)=1/(10^{27.5}+0.8999x)$; stop **5.263e119 FLOPs**; exact threshold **1.111e120**. Conditional bootstrap 5th–95th percentiles: 2.541e119–6.812e119; positive-slope share 98.75%.


These bootstrap intervals resample grouped model observations and remain conditional on sample selection, hardware adjustment, input-growth proxy and the power-law continuation. They omit almost all cosmic extrapolation uncertainty. The detailed [inference methods and data-quality report](inference/README.md) records exclusions, grouping and small chronological holdouts. All four $H,G$ combinations per fitted estimator, including negative results, appear in the numeric inventory and the appendix below.

## Historical training-efficiency fits

For vision, I fitted six measured ImageNet fixed-performance compute observations from the [authors' dataset](https://raw.githubusercontent.com/openai/ai-and-efficiency/master/efficiency_sota.csv), spanning 2012–2019. For language models, I independently fitted the [NeurIPS 2024 study's dataset](https://github.com/epoch-research/lm-algorithmic-progress): 245 benchmark evaluations from 144 papers, dated 2012–2023. Those are historical observations accessed now, not 2026 observations.

Vision fits regress log efficiency on time. The LM fit uses a benchmark-specific scaling surface $L_j=A_j e^{-ut}P^{-a}+B_j e^{-vt}D^{-b}$, where $L$ is cross entropy, $P$ parameters and $D$ dataset size. Under compute-optimal allocation, its implied efficiency trend is $s=u/a+v/b$. This is an independent fit rather than a replication of the paper's full regularized ensemble. All rows below use the same raw-input bridge $p=s/\ln G$.

| Fit | s/year | Stop G=3.4 | Stop G=5 | Stop G=4.1 | Exact threshold G=3.4 |
|---|---|---|---|---|---|
| vision_OLS_all | 0.5303 | 3.023e119 | 2.478e119 | 2.732e119 | 4.334e119 |
| vision_OLS_first3 | 0.4903 | 2.861e119 | 2.335e119 | 2.579e119 | 4.007e119 |
| vision_OLS_last3 | 0.4059 | 2.491e119 | 2.014e119 | 2.234e119 | 3.317e119 |
| vision_Theil_Sen_all | 0.5446 | 3.080e119 | 2.528e119 | 2.785e119 | 4.450e119 |
| LM_nonlinear_OLS | 0.9328 | 4.325e119 | 3.669e119 | 3.980e119 | 7.622e119 |
| LM_nonlinear_soft_L1 | 0.9209 | 4.294e119 | 3.639e119 | 3.949e119 | 7.525e119 |
| LM_nonlinear_post2017 | 0.7548 | 3.815e119 | 3.192e119 | 3.485e119 | 6.167e119 |
| LM_nonlinear_pre2020_training_only | 1.4061 | 5.347e119 | 4.663e119 | 4.991e119 | 1.149e120 |


The LM all-years least-squares fit gives $k(x)=1/(10^{27.5}+1.3120x)$. Paper-cluster bootstrap with 200 replicates and seven optimizer starts per replicate gives a model-conditional 90% stopping interval of $3.38–5.53\times10^{119}$ FLOPs at $G=3.4$. Twenty-three replicates hit parameter bounds, so this is a rough sensitivity interval. The early-period LM fit has worse later-period prediction error and should not be treated as an equally reliable estimate of today's rate. [Full training-efficiency methods](vision_lm/README.md).

## Stockfish: fit different laws to the same measured curve

The [2024 authors' observations and notebook](https://github.com/ege-erdil/estimating-returns-to-rnd/blob/main/returns_to_software_rnd_stockfish.ipynb) give 258 matched observations, March 2013–June 2023. I reconstructed chained Elo, converted it to compute efficiency using their calibration, and fitted against cumulative Fishtest test count. Later official regression tests exist, but there is no comparably matched newer research-input series here. Tests are not interchangeable FLOPs.

Two interpretations expose a key ambiguity. A **raw proxy** treats test accumulation as proportional to raw research input. A **recursive effective proxy** treats it as effective research effort that universal efficiency accelerates. For $a\propto F^r$ and $dF/dx\propto a$, the second interpretation yields

$$k(x)=\frac{1}{10^{27.5}+[(1-r)/r]x},\qquad x_*\simeq rN\quad(0<r<1).$$

This differs from the raw-input result $x_*\simeq rN/(1+r)$. The dataset does not choose between these interpretations.

| Curve | Raw-proxy optimum | Recursive-proxy optimum | Holdout log RMSE |
|---|---|---|---|
| power | 4.804e119 | 9.246e119 | 1.294 |
| shifted_power | 6.254e119 | No finite optimum; singular at 7.886e27 | 0.914 |
| logarithmic | Tail unidentified | Tail unidentified | 1.022 |
| exponential | $N-$3.162e27 | No finite optimum; singular at 3.162e27 | 1.010 |
| stretched_exponential | $N-$6.531e85 | No finite optimum; singular at 4.142e27 | 0.664 |
| exp_ceiling | 3.193e29 | 1.997e29 | 1.484 |
| hyperbolic_ceiling | Tail unidentified | Tail unidentified | 0.916 |
| linear_efficiency | 5.000e119 | $N-$3.162e27 | 1.022 |
| hyperbolic_ceiling_p1 | 1.066e74 | 4.132e73 | 1.253 |
| hyperbolic_ceiling_p2 | 4.986e58 | 2.305e58 | 1.345 |


| Curve | Raw-proxy exact threshold | Recursive-proxy exact threshold |
|---|---|---|
| power | 9.246e119 | 1.226e121 |
| shifted_power | 1.669e120 | Never |
| logarithmic | Unidentified | Unidentified |
| exponential | Never | Never |
| stretched_exponential | 1.037e174 | Never |
| exp_ceiling | 3.193e29 | 1.997e29 |
| hyperbolic_ceiling | Unidentified | Unidentified |
| linear_efficiency | 1.000e120 | Never |
| hyperbolic_ceiling_p1 | 1.066e74 | 4.132e73 |
| hyperbolic_ceiling_p2 | 4.986e58 | 2.305e58 |


The simple power exponent is 0.9246. Allowing an initial stock of research raises it to 1.6694 and flips the recursive conclusion to runaway growth. A stretched exponential predicts the chronological holdout best among these candidates; it also gives no finite optimum under recursion. Its raw-proxy optimum leaves only $6.53\times10^{85}$ FLOPs, so the marginal gain there is about $10^{-85.8}$, not $10^{-120}$.

The ceiling models are fitted alternatives, but their long-run shape is weakly identified. The hyperbolic exponents 1 and 2 are explicit sensitivity assumptions. Letting that exponent vary pushes the fit toward a power-law limit; the logarithmic model similarly runs to an optimizer boundary. Those failed identifications are retained, not turned into precise tail forecasts. A mathematical singularity means the unlimited extrapolation fails to supply a physically meaningful stopping prediction, not that infinite computation is attainable. [Stockfish fit equations, validation and source details](stockfish/FINDINGS.md).

## A fitted vision compute floor

A different law fits the ImageNet observations to $C(t)=C_{\min}+A e^{-st}$. The best floor fit has $s=0.5451$ and a floor at 11.71% of the last observed compute requirement. Projecting that historical fit to September 12, 2026 makes the floor 87.09% of projected current compute. This is a projection from 2019 data, not a new observation; $k_0$ is reimposed at that projected anchor.

With $p=s/\ln G$, $f=C_{\min}/C_{\rm anchor}$ and $x_0=p(1-f)/k_0$, the law becomes

$$a(x)=\frac{1}{f+(1-f)(1+x/x_0)^{-p}},$$
$$k(x)=\frac{k_0(1+x/x_0)^{-p-1}}{f+(1-f)(1+x/x_0)^{-p}}.$$

| Input proxy | Projected-2026 floor optimum and exact threshold |
|---|---|
| aggregate_AI_compute_3.4x | 1.982e90 |
| frontier_training_compute_5x | 1.922e95 |
| historically_overlapping_notable_training_compute_4.1x | 9.230e92 |


This is a genuinely different result from a forever power law: roughly $10^{90}$ FLOPs at the primary input-growth proxy. However, adding the floor makes AIC worse by 1.94 and leave-one-out error worse (0.295 versus 0.239). The six observations do not support a positive lower bound on the floor. Nor does a floor for one image-classification task establish a ceiling on universal thought. Both the 2019-anchor sensitivity and every fitted floor profile are retained in the full inventory.

## Structural research-production fits and recent lab inputs

For the Jones law $\dot a/a=\theta a^{-\beta}I^\lambda$, holding raw throughput fixed and assuming the whole research input receives the universal multiplier gives $I\propto a$ and

$$b=\beta-\lambda,\qquad k(x)=\frac{1}{10^{27.5}+bx}.$$

For $b>0$, $x_*\simeq N/(1+b)$ and $x_{120}\simeq N/b$. For $b<0$, the extrapolation diverges at $x_{\rm sing}=10^{27.5}/(-b)$. The growth ratio $r=\lambda/\beta$ alone does not identify $b$.

The [2024 study](https://arxiv.org/html/2405.10494v1) and [November 2025 update](https://epoch.ai/gradient-updates/the-software-intelligence-explosion-debate-needs-experiments) provide endpoint data and code. The 2025 inputs use cumulative publication counts from a November 2025 snapshot, not research FLOPs. Their separate published parameter medians give the following plug-in sensitivities. A difference of marginal medians is not the median difference.

| Published fit | b plug-in | Jones result, FLOPs | Exact threshold |
|---|---|---|---|
| 2024 Computer vision | -0.425 | Singular at 7.441e27 | — |
| 2024 Atari RL | -0.459 | Singular at 6.889e27 | — |
| 2024 SAT | -1.495 | Singular at 2.115e27 | — |
| 2024 Linear programming | 0.031 | 9.699e119 | 3.226e121 |
| 2025 Computer vision | -0.264 | Singular at 1.198e28 | — |
| 2025 Atari RL | -0.134 | Singular at 2.360e28 | — |
| 2025 NLP | -0.751 | Singular at 4.211e27 | — |


I also independently integrated each joint posterior using the authors' endpoint likelihood and independent half-Cauchy priors, with two scrambled Sobol runs of 524,288 points per domain. The table reports probabilities **conditional on that statistical and feedback model**, not real-world probabilities of whether fooming ends. For example, a conditional stop near $9\times10^{119}$ does not erase a much larger singular branch.

| Independent posterior fit | Finite-stop probability | Conditional median x*/N | Conditional 90% x*/N range |
|---|---|---|---|
| 2025 Computer vision | 18.3–19.1% | 0.900–0.909 | 0.67–0.992 |
| 2025 Atari RL | 35.9–36.1% | 0.782–0.787 | 0.42–0.981 |
| 2025 NLP | 4.9–5.5% | 0.918–0.934 | 0.67–0.994 |
| 2024 Computer vision | 12.2–12.7% | 0.902–0.914 | 0.63–0.992 |
| 2024 Atari RL | 22.3–22.6% | 0.794–0.804 | 0.41–0.985 |
| 2024 SAT | 3.7–4.2% | 0.868–0.910 | 0.53–0.994 |
| 2024 Linear programming | 45.0–45.4% | 0.695–0.696 | 0.31–0.970 |


These calculations required a numerical likelihood repair; two independent density formulas were checked against a centered Poisson–gamma mixture. Effective sample sizes are approximately 1,700–22,300, and a small fraction of prior points has unsupported extreme numerical arguments. The displayed ranges are approximate run-to-run summaries, not convergence guarantees. Exact-threshold posterior quantiles and diagnostics remain in the JSON files. [Posterior and source report](published_domains/REPORT.md).

A separate fit uses five observed lab staff reports (2023–2025) and three spend-derived R&D compute estimates (2022, 2024, 2025), excluding the source's 2026–2030 forecasts. In [the authors' lab-growth model](https://github.com/parkerwhitfill/epoch_RRD/blob/main/code/steady_state.py),

$$r=\frac{g_A}{\epsilon_K g_K+(1-\epsilon_K)g_L}.$$

The full-sample OLS input growth rates are $g_K=1.4297$ and $g_L=0.8411$ per year. The efficiency rate $g_A=\ln3$ is imposed from the source's software-growth estimate, not independently fitted to these lab inputs. Converting $r$ into a stopping number further requires the cumulative-effective-effort model $a\propto F^r$, $dF/dx\propto a$. Under that extra assumption, $x_*\simeq rN$:

| Estimator | Compute share | r | Optimal FLOPs | Exact threshold FLOPs |
|---|---|---|---|---|
| OLS | 0.59 | 0.92449 | 9.245e119 | 1.224e121 |
| OLS | 0.67 | 0.88926 | 8.893e119 | 8.030e120 |
| OLS | 0.75 | 0.85661 | 8.566e119 | 5.974e120 |
| endpoint | 0.59 | 0.92204 | 9.220e119 | 1.183e121 |
| endpoint | 0.67 | 0.88664 | 8.866e119 | 7.821e120 |
| endpoint | 0.75 | 0.85385 | 8.539e119 | 5.842e120 |
| Theil-Sen | 0.59 | 0.92864 | 9.286e119 | 1.301e121 |
| Theil-Sen | 0.67 | 0.89154 | 8.915e119 | 8.220e120 |
| Theil-Sen | 0.75 | 0.85730 | 8.573e119 | 6.008e120 |


The central OLS, 67%-compute-share version gives $k(x)=1/(10^{27.5}+0.12453x)$ and $x_*=8.89\times10^{119}$. The rounded numbers in the source article give $9.55\times10^{119}$ instead; that is retained as a rounded-input sensitivity, not another observation-based fit. Source-assumed uncertainty puts 38% of the cumulative-model draws on its singular branch. Conditional on a finite stop, the median is $8.19\times10^{119}$ with a 90% interval $5.11–9.82\times10^{119}$.

If only cognitive labor receives the multiplier, the model changes to $x_*/N=r/(1+\epsilon_Kr)$, roughly 0.52–0.60 across these fits. All nine such changed-feedback cases are retained in the inventory. The [2025 compute-bottleneck study](https://arxiv.org/html/2507.23181v2) motivates taking this modeling choice seriously, but does not independently identify a stopping law or a FLOP stopping number.

## What I would carry forward

For a deliberately scale-free version of your toy model, I would use **roughly half the $10^{120}$ raw FLOPs** as a compact current-data scenario, while retaining the separate effective-effort scenario near $9\times10^{119}$. This is a choice of toy-law family, not an empirically established cosmic forecast. The corresponding inverse-input marginal laws reach $1+O(10^{-120})$ while a macroscopic fraction of the budget remains.

I would not average these predictions with the ceiling or singular cases. The observed histories cover at most a few orders of magnitude of research input, while the requested marginal decline spans 92.5 orders of magnitude from your starting calibration. The data weakly constrain the late tail. Better estimates of today's slope shrink ordinary uncertainty but cannot settle whether a plateau, a power law or a self-amplifying research regime describes that tail.

Power-law stopping fractions are almost independent of $k_0$ when $k_0N\gg1$. Ceiling predictions depend strongly on $k_0$, the ceiling's approach rate and the anchor date. Recursive singularity inputs scale directly as $1/k_0$. This explains why superficially similar present-day fits imply incompatible absolute stopping scales.

## Appendix: every inference hardware/input-proxy combination

Each cell is optimal FLOPs / exact-threshold FLOPs. `Nonpositive` retains an incompatible adjusted trend; it is not dropped. $H_1=1.49$, $H_2=1/0.7$. Insufficient-fit attempts appear in the main table and master inventory.

| Fit | H1,G3.4 | H1,G5 | H2,G3.4 | H2,G5 |
|---|---|---|---|---|
| gpqa_all_ols | 4.743e119 / 9.021e119 | 4.069e119 / 6.860e119 | 4.836e119 / 9.365e119 | 4.159e119 / 7.121e119 |
| gpqa_open_ols | Nonpositive | Nonpositive | Nonpositive | Nonpositive |
| gpqa_pareto_all_ols | 6.365e119 / 1.751e120 | 5.711e119 / 1.332e120 | 6.410e119 / 1.786e120 | 5.759e119 / 1.358e120 |
| gpqa_pareto_open_ols | 5.174e119 / 1.072e120 | 4.491e119 / 8.152e119 | 5.253e119 / 1.106e120 | 4.569e119 / 8.413e119 |
| gpqa_pareto_open_robust | 4.774e119 / 9.135e119 | 4.099e119 / 6.946e119 | 4.866e119 / 9.479e119 | 4.189e119 / 7.208e119 |
| gpqa_pareto_open_linear_score | 4.674e119 / 8.776e119 | 4.002e119 / 6.673e119 | 4.770e119 / 9.120e119 | 4.095e119 / 6.935e119 |
| aime_all_ols | 5.478e119 / 1.211e120 | 4.795e119 / 9.212e119 | 5.547e119 / 1.246e120 | 4.865e119 / 9.473e119 |
| aime_open_ols | 3.887e119 / 6.359e119 | 3.259e119 / 4.836e119 | 4.013e119 / 6.703e119 | 3.376e119 / 5.097e119 |
| aime_pareto_all_ols | 6.058e119 / 1.537e120 | 5.389e119 / 1.169e120 | 6.111e119 / 1.571e120 | 5.444e119 / 1.195e120 |
| aime_pareto_open_ols | 5.263e119 / 1.111e120 | 4.580e119 / 8.449e119 | 5.339e119 / 1.146e120 | 4.656e119 / 8.711e119 |
| aime_pareto_open_robust | 4.922e119 / 9.692e119 | 4.243e119 / 7.370e119 | 5.009e119 / 1.004e120 | 4.328e119 / 7.631e119 |
| aime_pareto_open_linear_score | 4.614e119 / 8.566e119 | 3.944e119 / 6.513e119 | 4.712e119 / 8.910e119 | 4.039e119 / 6.775e119 |
| swe_all_ols | Nonpositive | Nonpositive | Nonpositive | Nonpositive |
| swe_open_ols | Nonpositive | Nonpositive | Nonpositive | Nonpositive |
| swe_pareto_all_ols | 5.201e119 / 1.084e120 | 4.518e119 / 8.242e119 | 5.279e119 / 1.118e120 | 4.596e119 / 8.504e119 |


## Appendix: all vision-floor profiles

Floors are fractions of the last observed compute, with $k_0$ imposed at the 2019 anchor for this sensitivity. Positive-floor optimum and exact threshold coincide at displayed precision. Zero-floor exact thresholds are separately in the inventory.

| Floor | Deviance change | Stop G3.4 | Stop G5 | Stop G4.1 |
|---|---|---|---|---|
| 0.000000 | 0.0000 | 3.023e119 | 2.478e119 | 2.732e119 |
| 0.001000 | -0.0011 | 5.773e93 | 7.035e98 | 3.051e96 |
| 0.010000 | -0.0102 | 1.046e93 | 1.137e98 | 5.200e95 |
| 0.030000 | -0.0280 | 3.883e92 | 4.077e97 | 1.893e95 |
| 0.100000 | -0.0622 | 7.616e91 | 8.165e96 | 3.744e94 |
| 0.117098 | -0.0636 | 5.620e91 | 6.101e96 | 2.780e94 |
| 0.200000 | -0.0295 | 1.502e91 | 1.754e96 | 7.699e93 |
| 0.300000 | 0.1054 | 3.566e90 | 4.599e95 | 1.920e93 |
| 0.500000 | 0.6822 | 2.374e89 | 3.784e94 | 1.420e92 |
| 0.700000 | 1.6119 | 1.698e88 | 3.355e93 | 1.129e91 |
| 0.900000 | 2.7802 | 1.235e87 | 3.013e92 | 9.106e89 |


## Additional check: measured Stockfish CPU-years

# Cumulative CPU-year fit: not completed

The authors' saved Stockfish notebook identifies a potentially useful research-compute input series at:

[Underlying Google Sheet, CPU-year worksheet](https://docs.google.com/spreadsheets/d/1_PTiZ1_faoUW4BjRaGA2rx39tGIK2ODa18FJyTHrZh0/edit#gid=1718304314)

[CSV export](https://docs.google.com/spreadsheets/d/1_PTiZ1_faoUW4BjRaGA2rx39tGIK2ODa18FJyTHrZh0/export?format=csv&gid=1718304314)

Notebook cells 1–2 load the columns `Date` and `CPU years (cumulative)`, with dates parsed as YYYY-MM-DD. The notebook itself contains no recoverable printed observations for this series.

On 2026-09-12, the download attempt was waiting inside an escalated network tool call and was interrupted by the user after approximately 500 seconds. No source CSV was received. There was no explicit remote-server response establishing that the public source is unavailable; the blocker was the interrupted tool/approval flow. The call was not repeated.

Consequently there are **no usable CPU-year observations, fitted exponents, or stopping predictions** from this extra attempt. These must not be counted as completed empirical methods. CPU-years would in any case remain a proxy: without hardware normalization they are not constant FLOPs per CPU-year, and donated testing compute omits other research inputs.
