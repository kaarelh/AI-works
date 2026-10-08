GPT-6 (Codex) — 2026-09-13

# Independently calibrating the initial fooming return

Companion to [[will fooming be done?]] and [[Revised all-things-considered stopping forecast]].

**My independently estimated starting point is now approximately $k_0=10^{-29}$ per research FLOP**, where $k_0=d\ln\alpha/dx$ today. This replaces the original quick estimate $10^{-27.5}$. The corresponding local characteristic scale is approximately $10^{29}$ FLOPs per natural-log unit of efficiency gain—about 30 times more research compute than the original estimate. It is a local slope, not a promise that spending that amount will deliver an e-fold, since the return changes during research.

**The resulting all-things-considered stopping guess remains approximately $10^{110}$ raw FLOPs.** Holding the previous tail assumptions fixed, recalibration moves the numerical median from $10^{110.02}$ to $10^{110.12}$. Including broad uncertainty in the new calibration gives $10^{110.10}$. These extra decimal places describe the computation; they are not forecast precision. The initial scale is now better grounded, while the long-run stopping forecast remains highly subjective.

## The independent calculation

I estimate a present research-compute flow and a broad software-efficiency improvement rate separately:

$$k_{\mathrm{path}}\simeq\frac{d\ln\alpha/dt}{dx/dt}
\simeq\frac{1\ \mathrm{year}^{-1}}{10^{29}\ \mathrm{FLOPs/year}}
\simeq10^{-29}\ \mathrm{FLOP}^{-1}.$$

**Research inputs.** A newly released hardware dataset estimates about 6.15 million H100-equivalents across five leading labs at the end of 2025. These are peak capacities. I apply an assumed 0.25 achieved-operation/peak factor, 0.5 research share, and 1.3 adjustment for research elsewhere. This gives $6.24\times10^{28}$ research FLOPs/year at that endpoint. Extrapolating capacity at 3.4×/year gives $1.47\times10^{29}$ FLOPs/year in September 2026. The September rate is an extrapolation, and the allocation/utilization factors are judgments. [Epoch's September 2026 release](https://epoch.ai/latest/introducing-the-ai-chip-users-explorer), [capacity methodology](https://epoch.ai/data/ai-chip-users-documentation/methodology).

For date sensitivity, holding the output proxy at one log unit/year gives:

| Research-input anchor | Estimated research FLOPs/year | Implied $k_{\mathrm{path}}$ per FLOP |
|---|---:|---:|
| Calendar 2025, interpolated fleets integrated over the year | $3.31\times10^{28}$ | $3.02\times10^{-29}$ |
| End-2025 fleet, annualized | $6.24\times10^{28}$ | $1.60\times10^{-29}$ |
| September 2026, extrapolated annualized rate | $1.47\times10^{29}$ | $6.80\times10^{-30}$ |

These rows are alternative date interpretations of the same hardware estimates, not independent experiments. Approximately $10^{29}$ FLOPs/year is an appropriate rounded current-start denominator. I use $10^{28}$–$10^{30}$ as a judgmental input sensitivity range.

Reported spending provides a cross-check. The updated dataset records $8.3 billion of OpenAI research compute for 2025; the old $9 billion input was a projection. Applying the old dollars-to-FLOPs conversion gives $1.17\times10^{28}$ FLOPs, within a factor of two of the new integrated fleet estimate for OpenAI alone. Neither is an audited operation count. The whole industry's output must be compared with the whole industry's relevant research, rather than with one lab alone. [Current company dataset](https://epoch.ai/data/ai-companies?tab=compute&view=graph).

**Research outputs.** Our corrected current inference fits imply about 1.05–1.36 natural-log units of software-efficiency gain per year across the primary GPQA/AIME estimator variants. They adjust for hardware, but price remains an imperfect FLOP proxy. The historical language-model fit gives about 0.93/year. These support a numerator of order one/year, not a precisely measured universal rate. [Inference-efficiency study](https://arxiv.org/html/2511.23455v2), [earlier empirical fits](../empirical_methods/REPORT.md).

A new controlled small-model experiment reports joint model-plus-data efficiency growth of **1.57×/year**, or **0.451 log units/year**, over 2019–2025. Its separate recipe and data gains must not be multiplied to replace the reported joint estimate. Its smaller scale and different metric make it a useful cross-check, rather than a direct measurement of today's common multiplier. [Patel and Han, September 2026](https://www.dwarkesh.com/p/pretraining-progress-is-mostly-data).

**Human thought.** A central accounting convention—30,000 relevant research FTE, 2,000 hours/year and $10^{15}$ brain-equivalent FLOP/s—adds about $2\times10^{26}$ FLOP equivalents/year, small against the machine denominator. Researcher scope and brain equivalence are uncertain; the high-compute tail can matter. Brain simulation-equivalent FLOPs are not directly measured physical brain operations. [Detailed human component](HUMAN.md), [Carlsmith's investigation](https://coefficientgiving.org/research/how-much-computational-power-does-it-take-to-match-the-human-brain/).

## What still requires judgment

The ratio above is a historical path derivative. Transferring it to the marginal productivity of a single optimizing researcher requires assumptions about complementary labor, research allocation, delays, and whether domain improvements transfer to the common multiplier. I find no supported correction of several orders in a particular direction. A modest downward marginal correction would make the central return around $5\times10^{-30}$, still of order $10^{-29}$.

More direct local optimization experiments do not remove that uncertainty. METR's NanoGPT results concern improvements in elapsed training time for a narrow target; transfer to a universal arithmetic-efficiency multiplier is unmeasured. I therefore do not average their cheap local gains into the global calibration. [METR's July 2026 study](https://metr.org/blog/2026-07-21-expenditure-horizon/).

For propagation I use $\log_{10}k_0\sim\mathcal N(-29,1.25^2)$: a subjective 90% range of roughly $10^{-31}$–$10^{-27}$. This is approximately two orders on each side, four orders overall. It includes uncertainty beyond the narrower hardware calculation and is **not an empirical confidence interval**. Independence from the tail parameters is another explicit simplifying assumption. [Calibration prior](calibration_prior.json), [output and transfer analysis](OUTPUT.md), [input calculation](COMPUTE.md).

## How much the stopping forecast changes

The objective and common feedback remain

$$U(x)=a(x)(N-x),\quad N=10^{120},\quad\frac{dF}{dx}=a,\quad
k(x_*)=\frac{1}{N-x_*}.$$

I retain every previous scenario weight and tail-parameter draw. This isolates the effect of correcting today's scale. The exact $k=10^{-120}$ crossing is saved separately, since it differs from optimal stopping when the research fraction is large.

| Initial marginal return $k_0$ | Characteristic inverse slope $1/k_0$ | Median $\log_{10}$ stopping FLOPs |
|---:|---:|---:|
| $10^{-24}$, high-return stress case | $10^{24}$ | 109.65 |
| $10^{-27.5}$, original quick guess | $10^{27.5}$ | 110.02 |
| $10^{-29}$, new central calibration | $10^{29}$ | 110.12 |
| $10^{-31}$ | $10^{31}$ | 110.24 |
| $10^{-34}$, low-return stress case | $10^{34}$ | 110.59 |

For a finite-ceiling cost gap proportional to $F^{-p}$, sufficiently deep in saturation and with $x_*\ll N$,

$$\frac{\partial\log x_*}{\partial\log(1/k_0)}\simeq\frac{p}{1+p}.$$

Thus a 1.5-order correction to initial productivity changes a $p=1$ stop by 0.75 orders, and a $p=0.25$ stop by 0.30 orders. At ceiling headroom $H=10^{12}$, the exact $p=1$ result moves from $10^{73.75}$ to $10^{74.50}$; the $p=0.25$ result moves from $10^{108.10}$ to $10^{108.40}$. Slow tails and scenarios spending a fixed budget fraction are still less sensitive. This explains why independently revising the starting point leaves the broad mixture median near $10^{110}$.

After propagating calibration uncertainty, the central mixture has a median near **$10^{110}$**, an interquartile range near **$10^{96}$–$10^{118}$**, and about **23%** probability of spending at least 1% of the budget. Changing only the subjective family weights still gives medians from approximately **$10^{97}$ to $10^{118}$**. The uncertainty over tail mechanisms remains overwhelmingly larger than the normalization correction.

This is a forecast of the realized optimal transition conditional on a law becoming understood. It is not a fixed allocation that automatically maximizes expected cooming under unresolved uncertainty; that additionally requires a learning model, as discussed in the previous forecast.

I keep the stipulated $10^{120}$ budget in the same FLOP convention throughout. Connecting that convention to cosmological elementary-operation bounds needs a separate conversion model. No claim about calendar years follows from an operation-count stopping point.

## Reproducibility and provenance correction

The recalculation solves 30,720 scenarios. Reusing $k_0=10^{-27.5}$ reproduces the previous baseline exactly; the maximum numerical residual in the economic stopping equation is $3.7\times10^{-12}$ in natural-log units. An independent audit checked parameter preservation and calibration sampling. This verifies the calculation, not the subjective tail prior.

The earlier lab-growth analysis used reported spending estimates that included projections even in the 2022–2025 rows. Excluding its 2026–2030 forecasts did not make every remaining number an observed actual expenditure. The historical fits remain reproducible as fits to those source estimates; the new calibration replaces their use as a current absolute FLOP anchor.

See [results](calibration_results.json), [all recalculated scenarios](calibration_draws.csv), [compute arithmetic](compute_calibration.json), and [reproduction instructions](REPRODUCE.md). The original note is unchanged.
