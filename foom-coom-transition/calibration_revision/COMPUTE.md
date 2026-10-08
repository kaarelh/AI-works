GPT-6 (Codex) — 2026-09-13

# Independent calibration of research FLOPs

A reasonable present-day denominator is **roughly $10^{29}$ raw research FLOPs per year globally**, with a deliberately broad judgmental range of **$10^{28}$–$10^{30}$**. This is an estimate combining observed hardware fleets and uncertain allocations, not a measured global accounting total. At software log-efficiency growth $s=1.2$/year, it implies **$k_0\sim10^{-29}$ per raw FLOP**, roughly 30 times less immediate return per FLOP than the original $10^{-27.5}$ guess. A best date-matched calculation should retain the historical anchors below instead of labeling all of them “today.”

## New hardware evidence

Epoch released its AI Chip Users dataset on September 9, 2026. Its raw CSV gives end-2025 medians of 1.743M H100-equivalents for OpenAI, 1.583M for Google DeepMind, 1.190M for Anthropic, .996M for Meta, and .635M for SpaceXAI: **6.147M total**. The article's SpaceXAI rounded estimate differs slightly from the downloaded CSV; I use the CSV consistently. These estimates include research, training, and customer inference. [Dataset](https://epoch.ai/data/ai-chip-users), [launch announcement](https://epoch.ai/latest/introducing-the-ai-chip-users-explorer).

OpenAI itself disclosed .2 GW, .6 GW and 1.9 GW at the ends of 2023, 2024 and 2025. This is an independent anchor for the hardware estimate. [OpenAI, January 18, 2026](https://openai.com/index/a-business-that-scales-with-the-value-of-intelligence/).

One H100-equivalent means peak dense 8-bit capacity of $1.979\times10^{15}$ operations/second. It is neither actual operations performed nor software-adjusted effective compute. Epoch models uncertain power definitions, chip mixes and deployment delays. Its output is a capacity estimate; workload utilization must be added separately. [Methodology](https://epoch.ai/data/ai-chip-users-documentation/methodology).

My reference conversion is

$$R = H\,(1.979\times10^{15})\,(365.25\times86400)\,u\,r\,c,$$

where $H$ is the fleet in H100-equivalents, $u=.25$ is achieved raw operations relative to dense-8bit peak, $r=.5$ is the share assigned to R&D, and $c=1.3$ accounts for research outside these five labs. **Those last three factors are my assumptions**, not three independently measured quantities.

- $u=.25$ combines the precision actually used, arithmetic utilization, downtime and mixed workloads. A broad plausible range is .1–.5. Counting BF16 work against an FP8 peak without a correction would overstate executed FLOPs. As a sanity check, Meta reports 30.84M H100 GPU-hours for Llama-3.1-405B and approximately 15T training tokens. The rough $6ND$ model-operation count is .166 of the FP8 peak over those hours. This excludes some executed operations, such as recomputation and attention overhead, and is not a fleet-wide measurement. [Meta's model card](https://huggingface.co/meta-llama/Llama-3.1-405B).
- $r=.5$: OpenAI's spending is approximately evenly divided between R&D and inference in 2025. Extending that split to other labs is uncertain; .25–.8 is a reasonable broad sensitivity. Research includes experimental training, evaluations and research-directed inference. Customer serving is excluded.
- $c=1.3$: an uncertain adjustment for Chinese labs, academic researchers, smaller developers and relevant spillovers; 1–3 is a reasonable sensitivity. This does not mean all non-frontier hardware goes to relevant research.

## Three date anchors, with identical conversion assumptions

| Anchor | Raw research FLOPs | $k_0$ if $s=1.2$/year | $1/k_0$ |
|---|---:|---:|---:|
| Actual calendar 2025 interval, fleet interpolated within year | $3.31\times10^{28}$ over the year | $3.63\times10^{-29}$ | $2.76\times10^{28}$ |
| December 31, 2025 capacity annualized | $6.24\times10^{28}$/year | $1.92\times10^{-29}$ | $5.20\times10^{28}$ |
| September 13, 2026 capacity annualized, extrapolated | $1.47\times10^{29}$/year | $8.16\times10^{-30}$ | $1.23\times10^{29}$ |

For the first row I loglinearly interpolate each lab's 2024 and 2025 year-end capacity: the year's average is $(H_{25}-H_{24})/\ln(H_{25}/H_{24})$. Thus “actual calendar interval” does not mean actual operations were directly measured. For the last row I apply assumed capacity growth of 3.4×/year for .701 years after December 2025; **this is an explicit extrapolation**, not a September 2026 observed fleet. Recent global-capacity estimates give approximately 3.3× annual growth, while frontier developers grew faster. [Global capacity analysis](https://epoch.ai/data-insights/ai-chip-production).

For a growth rate measured across 2024–2026, $R\sim(3\text{–}10)\times10^{28}$/year is a more natural matched-period denominator than using the projected September endpoint. The latest-period annualized calibration $R\sim10^{29}$/year is appropriate if the toy process starts “now” and assumes the fitted software growth rate still applies.

## Spending cross-check and a correction to the old inputs

The previously downloaded `openai_rd_spend_flops.csv` was not a series of directly observed research-FLOP totals. Its 2022 input combines compute, data and inference; its 2024 $4B includes amortized research expense; its 2025 $9B was an internal forecast reported during 2025.

The latest August 31, 2026 Epoch company CSV instead records **$8.3B of OpenAI R&D compute in 2025**, reported retrospectively in February 2026, and $8B inference. These remain media-reported financial figures, not company-audited operation counts. At the old source's dollar-to-FLOP conversion, replacing $9B by $8.3B gives $1.17\times10^{28}$ FLOPs. My independent fleet integration gives $7.03\times10^{27}$ OpenAI R&D FLOPs for 2025 before the global adjustment. The factor-1.7 discrepancy is small relative to utilization and price uncertainty. [Current company data](https://epoch.ai/data/ai-companies?tab=compute&view=graph).

Epoch's more detailed 2024 reconstruction uses $5B of incurred R&D cloud cost, splitting training and research and assuming a two-year amortization schedule. It finds only about one tenth of that spending corresponds to final runs of released models; most is experiments or unreleased models. This supports using the whole R&D budget rather than only headline final training runs. The source warns that its 2024 figures still originate in partially projected investor documents. [2024 compute breakdown](https://epoch.ai/data-insights/openai-compute-spend).

The old R&D-FLOP CSV and source repository contain no sufficiently transparent code for reproducing the dollar-to-FLOP conversion, so it should be a cross-check, not the primary calibration.

## What is and is not identified

The identity along a specified historical path is $k=(d\ln\alpha/dt)/(dx/dt)=s/R$. It does **not** show that more research compute causally generates the same marginal gain when human labor, allocation or model quality changes. It also does not show that domain-specific efficiency improvements all transfer to a universal multiplier.

The numerator should cover the same global research system and dates as the denominator. Attributing worldwide frontier software progress to OpenAI's FLOPs alone would overstate returns. Conversely, charging all world research compute to narrowly measured benchmark efficiency could understate returns if it buys other improvements relevant to the toy model. The chosen whole-industry R&D denominator is a reasonable starting point under the user's common-multiplier assumption.

Individual successful inventions are not a better absolute denominator. Barnett's 36-innovation study records many small-compute breakthroughs, but explicitly omits unsuccessful experiments, research lineage, much validation, proprietary innovations and post-training. It does not measure the multiplier gain of each innovation. Summing those selected costs and dividing total progress by the result would introduce strong selection bias. [Barnett, 2025](https://arxiv.org/html/2507.10618v1).

**Recommendation:** use $R_0\sim10^{29}$ raw FLOPs/year for the current-start reference case; vary it over at least $10^{28}$–$10^{30}$ as judgmental uncertainty. With $s$ near one per year, use $k_0\sim10^{-29}$ rather than anchoring on $10^{-27.5}$. Additional uncertainty in replacing human researchers, research allocation and universal transfer should be represented separately. Neither a three-digit estimate nor a narrow confidence interval is warranted.

The downloaded public inputs and arithmetic are in `sources/`, `compute_calibration.py` and `compute_calibration.json` in this folder.
