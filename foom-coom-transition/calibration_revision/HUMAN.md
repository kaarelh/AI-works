GPT-6 (Codex) — 2026-09-13

# Human research compute: a calibration component, not a measured raw-FLOP total

The original note explicitly proposes counting both human and AI thought spent improving software. Its initial `$1+10^{-27.5}$` estimate has no derivation or inputs recorded. It therefore cannot be treated as an empirical observation. The note also moves between universal physical operations and FLOPs; this is a consequential unit assumption.

For a **conventional FLOP-equivalent accounting of direct human research**, my working central estimate is approximately **$2\times10^{26}$ equivalent FLOPs per year**, with an illustrative central sensitivity range of approximately **$10^{24}$–$10^{29}$**. This is built from a researcher-count judgment and uncertain computational-neuroscience modeling, not a direct measurement. It is likely below aggregate frontier-model experimentation compute under the usual brain-equivalence estimate, but the high-brain-cost tail can reverse that conclusion.

## Evidence for human computation and number of researchers

Carlsmith's 2020 primary investigation considers several ways of bounding the compute sufficient to reproduce human cognitive task performance. It regards mechanistic estimates of $10^{13}$–$10^{17}$ FLOP/s as plausible, gives a best-guess median of approximately $10^{15}$ FLOP/s for a particular brain-model class, and gives less than 10% credence to needing more than $10^{21}$ FLOP/s. These are subjective judgments, not statistical confidence bounds or a measured brain throughput. The report explicitly says there is no unique FLOP-equivalent of a brain and that enough compute to reproduce its capabilities is a different concept from its underlying physical operation count. [Carlsmith, *How Much Computational Power Does It Take to Match the Human Brain?*](https://coefficientgiving.org/research/how-much-computational-power-does-it-take-to-match-the-human-brain/).

There is no clean census of researchers whose work causally improves a general AI efficiency frontier. For a contemporary scale check, NeurIPS 2025's main track used **20,518 reviewers, 1,663 area chairs and 199 senior area chairs**, handling **21,575 valid submissions**. These people are neither a census of relevant full-time researchers nor a sample whose total time can be credited to general efficiency progress. The count does establish that an estimate of only hundreds of workers for the whole field would be too narrow. [NeurIPS 2025 program chairs](https://blog.neurips.cc/2025/09/30/reflections-on-the-2025-review-process-from-the-program-committee-chairs/).

I use **30,000 relevant research FTE** as a judgmental central scope, and **10,000–100,000 FTE** as a first sensitivity range. The scope includes academic and industrial method development and engineering that improves the frontier, but excludes ordinary downstream AI deployment. I do **not** claim the NeurIPS figures identify that range. The correspondence between the chosen output metric and which workers count is a larger problem than the arithmetic.

## Calculation

Let $H$ be relevant researcher FTE, $h$ annual counted research hours and $b$ the assumed brain-task FLOP equivalent per second. Then

$$R_{\mathrm{human}} = H\,(3600h)\,b.$$

The central inputs are $H=30{,}000$, $h=2{,}000$ and $b=10^{15}$, giving

$$R_{\mathrm{human}}=2.16\times10^{26}\quad\text{FLOP equivalents/year}.$$

The hours are an accounting convention, not a measured global mean. Counting 24-hour brain operation instead of 2,000 working hours multiplies this number by about 4.4, or 0.64 orders of magnitude. Charging past education and biological development to this year's *marginal* research would usually be inappropriate: those are largely sunk inputs. Current training and coordination overhead can instead be included through the FTE scope or hours.

| Brain-model FLOP equivalent/s | 10,000 FTE | 30,000 FTE | 100,000 FTE |
|---:|---:|---:|---:|
| $10^{13}$ | $7.2\times10^{23}$ | $2.16\times10^{24}$ | $7.2\times10^{24}$ |
| $10^{15}$ | $7.2\times10^{25}$ | $2.16\times10^{26}$ | $7.2\times10^{26}$ |
| $10^{17}$ | $7.2\times10^{27}$ | $2.16\times10^{28}$ | $7.2\times10^{28}$ |
| $10^{21}$, high-cost stress case | $7.2\times10^{31}$ | $2.16\times10^{32}$ | $7.2\times10^{32}$ |

If all observed software efficiency improvement were credited to human thought alone, a logarithmic progress rate $s=1$ per year would imply $k\simeq s/R_{\mathrm{human}}=4.63\times10^{-27}$ per equivalent FLOP, or a characteristic scale $k^{-1}=2.16\times10^{26}$. **This is not the recommended total-R&D calibration**, because model experiments are substantial inputs and attributing all gains to labor alone double counts its productivity.

For comparison, if separately estimated machine R&D uses $R_{\mathrm{machine}}=10^{28}$, $10^{29}$ or $10^{30}$ FLOPs/year, the central human addition is respectively 2.16%, 0.216% or 0.0216%. At $b=10^{17}$, it is respectively 216%, 21.6% or 2.16%. Thus the median brain estimate makes human thought a modest correction to plausible large-scale experimental budgets; uncertainty in how to map brains to FLOPs still needs to be retained.

## What can and cannot be inferred about the marginal research gain

With calendar efficiency growth $s=d\ln\alpha/dt$ and aggregate direct research compute $R=dx/dt$, the ratio

$$k_{\mathrm{observed\ path}}=\frac{s}{R}$$

is the slope along the observed historical input path. It is not automatically the marginal causal return to buying one more FLOP today: research lags, spillovers, complementarities between labor and experiments, hardware improvements and training-compute scaling all matter. A counterfactual involving much more automated cognitive labor may operate at a different mix of inputs. Nevertheless, this ratio is a transparent replacement for the unsupported original normalization, if its scope is stated and uncertainty propagated.

## Physical-operation accounting must remain a separate issue

The familiar $10^{120}$ from Lloyd counts elementary physical/quantum operations associated with the universe's past history, or an upper bound on computations that could have occurred; it is **not** a measurement of the number of future deployable floating-point operations. The speed bound involves energy above the ground state, and its logical operations are not GPU arithmetic instructions. We can preserve $N=10^{120}$ as the user's stipulated toy budget, but must say that applying measured FLOP costs assumes a common accounting unit. [Lloyd, *Computational capacity of the universe*](https://arxiv.org/html/quant-ph/0110141).

A single GPU FLOP has a physical implementation involving many device events; a hypothetical accurate digital simulation of a brain is a third kind of count. They cannot be added to fundamental physical operations without a conversion model. A constant change of units is harmless **only if both the budget and normalization are changed consistently**: if one counted FLOP costs $m$ physical operations, then $k_{\mathrm{physical}}=k_{\mathrm{FLOP}}/m$ and $N_{\mathrm{physical}}=mN_{\mathrm{FLOP}}$. The dimensionless product $Nk_0$ stays invariant. Altering $k_0$ to physical units while leaving a differently defined $N$ unchanged is not a pure unit conversion.

For the present task, the useful operational choice is: **retain the stipulated $10^{120}$ budget in a shared FLOP accounting convention; calibrate direct machine research empirically; include human cognition as uncertain FLOP equivalents; identify the connection to cosmological physical operations as an additional assumption.** There is no defensible independently measured raw-physical-FLOP normalization from the brain literature alone.

## Recommended treatment in the revised forecast

1. Do not give the user's $10^{-27.5}$ privileged prior mass or force a calibration to reproduce it.
2. Use direct experimentation/training/inference R&D as the primary observable denominator, with a matched software-only progress numerator.
3. Add a central human component of approximately $2\times10^{26}$ FLOP equivalents/year, carrying several orders of uncertainty and avoiding counting all unrelated researchers.
4. Treat the brain-model mapping as a nuisance assumption. If the machine denominator is $10^{29}$–$10^{30}$ FLOPs/year, the central human term barely changes it; a $10^{17}$ brain-rate assumption can produce a several-percent to tens-of-percent correction, and much higher assumptions can dominate.
5. Report how the posterior stopping scale changes with normalization separately from the much larger uncertainty about the late-return curve.
