GPT-6 (Codex) — 2026-09-13

# Calibrating the output side of current research productivity

**Recommendation:** use a central calendar log-efficiency rate of approximately **1 natural-log unit per year** (2.7× efficiency/year), with an explicitly judgmental working range **0.3–3/year**, before dividing by a matched research-compute flow. This is an output proxy, not an estimate of the universal multiplier or of the causal return to one more FLOP. The denominator and the bridge from present mixed human/computer R&D to the toy model dominate its uncertainty.

## What the existing data actually say

The corrected local inference regressions use observations through April 2026 and remove three independently verified date errors. After dividing annual price-performance improvement by hardware improvement H=1.49, their estimated software log-growth rates are:

| Sample and estimator | Natural-log gain/year | Annual factor |
|---|---:|---:|
| GPQA open frontier, OLS | 1.311945 | 3.7134 |
| GPQA open frontier, robust | 1.117919 | 3.0585 |
| GPQA open frontier, linear score | 1.074039 | 2.9272 |
| AIME open frontier, OLS | 1.359875 | 3.8957 |
| AIME open frontier, robust | 1.186133 | 3.2744 |
| AIME open frontier, linear score | 1.048264 | 2.8527 |

These are read directly from `empirical_methods/inference/inference_results.json`, with s = raw price-efficiency log growth − ln(1.49). GPQA OLS has 44 observations but only 22 base-model clusters; AIME has 35 and 17. The estimator variants share data and must not be treated as independent studies. Our earlier historical language-model fit gives s=0.933/year (2012–2023), while the six-point ImageNet series gives s=0.530/year (2012–2019).

The inference paper itself reports approximately 3×/year after open-model and hardware adjustments. Prices also reflect utilization, memory bandwidth, provider pricing and serving systems. Open models reduce some pricing confounds, but do not convert prices into measured physical FLOPs. These regressions are nonetheless useful evidence that a current numerator of order one/year is more reasonable than, say, 10^-4/year or 10^4/year. [Gundlach et al., March 2026](https://arxiv.org/html/2511.23455v2).

H=1.49 comes from a fit to chip purchases in 2023–2025, published August 2026. It is a bit-operations-per-dollar measure, with a bootstrap 90% interval of 1.36–1.66/year. It is not a direct measure of rented inference FLOPs per dollar. This uncertainty changes s by around ±0.1/year, much less than input attribution and transfer uncertainty. [Epoch hardware estimate](https://epoch.ai/data-insights/chip-performance-per-dollar).

## A new physical-compute experiment

Patel and Han, published 8 September 2026, train representative 2019–2025 model recipes and datasets at fixed compute up to 10^19 nominal FLOPs. Their measured **joint** improvement is **1.57×/year [1.49, 1.65]**, or **s=ln(1.57)=0.4511/year [0.3988, 0.5008]**. The authors explicitly say this is not the product of their separate model-side and data-side multipliers. This corrects our initial, invalid multiplicative approximation of 0.632/year. The study concerns small-scale pretraining, omits RL and inference optimizations, and uses easy downstream benchmarks. Most tested corpora are different curations of the same Common Crawl, rather than new information sources. [Primary experiment, appendix and footnote 7](https://www.dwarkesh.com/p/pretraining-progress-is-mostly-data).

The correction strengthens evidence for a lower numerator in small-scale pretraining, but does not change our rounded all-method central rate of order one/year: the current inference estimators give 1.05–1.36/year, and the historical LM fit gives 0.933/year. These measure different targets and should not be pooled as repeated measurements of one invariant parameter.

Curation and filtering of a fixed information stock can qualify as algorithmic progress, and this is the relevant interpretation for most of the experiment's data improvements. A separate general accounting issue arises when a different efficiency estimate includes newly created external information: the toy model must charge its production to research or treat it as an initial endowment. That issue should not be mistaken for an explanation of this study's measured data gains.

## Why calendar progress divided by research FLOPs is not automatically marginal productivity

Let s = d ln A/dt and Q = dX/dt be a matched raw research-compute flow. Then

$$k_{path}=s/Q$$

is the derivative along the observed historical path. It can calibrate the toy model if research progress is represented by a one-state deterministic function A(X), and the research mix embodied in Q is the one the toy agent can reproduce. It is not generally the counterfactual effect of one extra experimental FLOP holding other inputs fixed.

For example, suppose the local production of log-efficiency progress is

$$s=B(A)Q^\epsilon L^{1-\epsilon},$$

where L is researcher labor. Then the marginal increase in the progress flow from extra compute is

$$\frac{\partial s}{\partial Q}=\epsilon\frac{s}{Q}.$$

The historical s/Q credits compute with the contribution of complementary human labor. If the extra FLOPs instead purchase a proportional expansion of the entire reproducible research bundle, the correct multiplier is its total returns-to-scale elasticity, which is not necessarily epsilon. If extra FLOPs fund longer sequential research while labor accompanies them, that is a third counterfactual. The user's scalar model hides this choice; empirical calibration must name it.

A useful bookkeeping equation is

$$k_0=\eta\,m\,\frac{\theta}{f}\,\frac{s}{Q_{all}}.$$

Here f is the fraction of counted R&D compute spent on improvements relevant to the target multiplier, theta is the fraction of measured log improvement attributable to that research, m is the appropriate marginal-to-path-average correction, and eta bridges transfer to the universal target plus differences between current mixed human/AI R&D and the reproducible automated research bundle. Setting all four corrections to one is a simplifying prior, not a result. These factors must not be estimated independently without care: f and theta are correlated, and attributing the same human complementarity to m and eta would double-count it.

In particular, dividing total industry progress by only one laboratory's compute overstates return unless the lab's contribution or spillovers are assigned consistently. Dividing it by every deployed AI FLOP understates targeted research return because most deployment does not produce algorithmic improvements. Conversely, dividing by only the successful final training runs misses failed experiments and upstream research.

## What contemporary R&D observations add

METR's July 2026 NanoGPT experiment directly measures autonomous optimization, including inference and experimental expenditure. The best agents deliver roughly 1–1.5% revalidated gains; the maintainer judges about 50–60% of speedup mergeable. Crucially, the metric is **wall-clock training time**, not physical FLOPs, and improvements include data-loader work and narrow tuning. [METR, July 2026](https://metr.org/blog/2026-07-21-expenditure-horizon/).

This establishes some genuine local gains but cannot calibrate the common multiplier. Removing a data-loader bottleneck may leave arithmetic unchanged, and training one small model faster need not improve inference or research proportionally. No positive lower bound on universal gain follows. API-inference FLOPs and transferable benefits are unmeasured. Cheap local wins therefore should not be averaged with industry-wide productivity estimates; their chief relevance is demonstrating heterogeneous returns and the importance of measuring gains beyond the optimized task.

OpenAI's September 2026 internal snapshot reports increased experiments per researcher alongside both increased agent use and increased available compute. People continue to choose priorities and judge research. More than half of successful tasks estimated at 4–8 human hours required intervention. This supports treating present research as a joint production process and withholding a precise conversion from annual progress to fully automated marginal returns. It gives neither a causal acceleration factor nor physical inference-FLOP totals sufficient for calibration. [OpenAI, September 2026](https://openai.com/index/research-acceleration-view-inside-openai/).

The intelligence-per-watt study cited by the inference paper is weaker corroboration than it initially sounds: its 3.1× model contribution over 2023–2025 is closely tied to a change in success rate, not a clean fixed-quality physical-FLOP reduction. I would not count it as an independent measurement of the required numerator. [Saad-Falcon et al.](https://arxiv.org/html/2511.07885).

## Recommended implementation in the recalibration

1. Use s0≈1/year centrally, and label 0.3–3/year a judgmental sensitivity interval rather than a statistical confidence interval. This interval changes inverse productivity by only one order of magnitude.
2. Use a denominator measuring actual executed algorithmic-R&D FLOPs for the same research ecosystem and approximate date. Peak capacity is not executed FLOPs. Latest data end April 2026, so a September denominator additionally assumes the fitted output rate remains approximately current.
3. Show the literal s/Q calibration first. Then expose an overall multiplicative bridge eta*m*theta/f rather than quietly relabeling the ratio as measured causal marginal productivity. Use broad factor sensitivities until direct evidence is available; the data do not impose identifiable positive bounds on this bridge for a universal autonomous multiplier.
4. Do not multiply k0 by an assumed future intelligence-explosion acceleration and also apply the same recursive multiplier inside the future model. That double-counts feedback. Normalize at a clearly specified present state or a clearly specified future automation state.
5. Separate initial scale uncertainty from asymptotic-tail uncertainty. In a tail k≈const*x^(-q) with the scale normalized by k0, the stopping log scale has sensitivity d log10(x*) / d log10(1/k0) = (q−1)/q. A tenfold error in k0 changes the q=2 stopping estimate by only half an order, and a q=1.1 slow-tail estimate by only 0.091 order. This is why a better k0 matters without resolving the tens-of-orders disagreement among tail hypotheses.

The cleanest reported quantity is H0=1/k0, **raw FLOPs per local natural-log unit of efficiency improvement**, not cumulative past research compute and not the cost of a guaranteed realized e-fold. If the denominator is Q=10^29 FLOPs/year and s≈1/year, the uncorrected scale is H0≈10^29 FLOPs. If m=0.5 with the other corrections one, H0≈2×10^29. Those are conditional examples; the input-side analysis should supply Q rather than borrowing the user's 10^27.5 guess.

My independent central correction, conditional on the input-side estimate Q≈10^29/year, would be **k0≈5×10^-30/FLOP**, rounded to **order 10^-29/FLOP**. The factor 0.5 is a judgmental allowance for causal marginal return being below historical path-average return; it is not fitted from these data. I do not see good evidence for a net correction of multiple orders in either direction. For current universal automated research, an uncertainty allowance of several orders around that rounded scale is more honest than inheriting the comparatively narrow sampling error in s. The current datasets provide no identifiable confidence interval for the full bridge.
