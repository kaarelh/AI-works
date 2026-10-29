# Quadratic-width learning with symmetry-invariant neuron merging

[Paper PDF](paper.pdf) · [LaTeX source](source/paper.tex) · [mathematical review](verification/mathematical-review.md) · [trained-network experiments and reproduction](experiments/README.md)

**Every eligible layered Boolean circuit has an implementation satisfying the restriction.** More natural versions of the restriction also retain the quadratic learning bound: neurons may merge after aligning their signs, groups may have unequal sizes, and the group-count budget can be normalized by output scale. The empirical evidence supports some ordinarily trained networks, including a rigorously certified reduction from width 32 to one signed population per layer; it does not establish that these conditions generally hold after gradient training.

This is a supporting research paper with independent AI-agent mathematical review, not Lean verification. It leaves the five main results unchanged. Authors: ChatGPT-6 Astra, Claude Fable 5 and Opus 5, Kaarel Hänni, and Dmitry Vaintrob, listed alphabetically.

## Boolean circuits pass, with positive prior mass

For a layered Boolean circuit of width `C` and depth `L`, including constant wires and compilation overhead, the construction groups the learner's neurons into `C` populations and makes each population implement one circuit wire. This works at **every learner width `N >= C`**, even when `C` does not divide `N`. Averaging the constructed weights preserves its real output exactly; its output signs compute the Boolean function with a strict margin.

The claim extends to an explicitly bounded neighborhood with positive Gaussian probability. Both the original and merged networks have the same saturated clipped predictions throughout that neighborhood. The construction satisfies the original internal-noise restriction as well. Thus the learning proof does not rely on a measure-zero set of exactly cloned neurons. This is an existence statement about implementations, not a statement that every network computing the function satisfies the condition. See the paper's target-mass appendix and the [target audit](verification/target-audit.md).

## Why change the original merging condition?

The [earlier condition](../neuron-averaging/) used unsigned, balanced populations. It has an exact symmetry defect: flipping a tanh neuron's incoming and outgoing signs preserves the function, its Gaussian prior density, and its internal-noise stability, but can destroy unsigned averaging. The paper gives a two-neuron example.

**Signed merging fixes this.** Neurons can be aligned with either sign before averaging. The new theorem also permits arbitrary nonempty group sizes and different population counts in different layers. It proves the same quadratic teacher-width dependence, with polynomial depth dependence, at all `N >= C` and every `gamma >= 1`. The proof normalizes by population mass and codes the group sizes; tiny groups do not introduce a learner-width penalty.

The original budget was `q <= 1 + Ev`, where `Ev = N ||v||²` and `q` is the largest number of populations in a layer. It becomes automatic when `Ev >= N-1`, because the identity partition with `q=N` is allowed. Increasing readout scale can purchase this certificate. The Gaussian prior still charges for that increased energy, so this is not a counterexample to the learning theorem, but automatic membership is weak evidence of redundancy.

A proved alternative is

$$
(q-1)M(w)^2\le4E_v(w),\qquad M(w)=\max_x|z_w(x)|.
$$

This **count budget** is invariant under readout rescaling. The accompanying requirement that merging change clipped outputs by at most `1/16` still uses fixed output margins. The Boolean construction satisfies the new budget too. Both the old and new budgets give quadratic bounds for signed, unequal populations, with or without additionally imposing the original internal-noise restriction. Neither budget is completely representation invariant: unequal replication of individual neurons can change its value.

For the output-normalized version, one sufficient bound is

$$
n=\widetilde O\!\left(\frac{LdQ+L^2Q^2+\log(1/\delta)}{\varepsilon}\right),\qquad
Q=\widetilde O\!\left(d+LC+c^2C+\log(1/\varepsilon)\right).
$$

The paper specifies all hidden logarithms and also gives a literal quadratic-width polynomial envelope. Training requires signed output above `1/2`; the conclusion bounds posterior-average test-margin failure at `1/4`. A strict `2/3` confidence guarantee follows by adjusting the error tolerance.

## A more local candidate condition

There is a sufficient condition formulated in the weights: neurons in the same signed population approximately agree on signals that are constant within the preceding populations. It bounds the part of the incoming weight matrix that breaks that agreement. Combined with the original internal-noise stability, this implies that merging preserves predictions.

The proof treats each layer's disagreement as an allowed internal disturbance. It does not multiply worst-case amplification factors across all later layers. Boolean implementations again have a positive-mass neighborhood satisfying the condition, with only logarithmic changes to the target-mass budget, so the quadratic-width conclusion survives. See the paper's final section and the [local-certificate derivation](verification/local-certificate.md).

This is a more interpretable sufficient condition, but it can be conservative: its simple operator-norm bounds are poor for the three trained networks whose merging stability we certified directly. Activation similarity alone is insufficient, and standard fixed-size neuron subsampling can destroy cancellation in the Gaussian background. Neither is an automatic substitute for the proved conditions.

## What ordinary gradient training produced

The [experiment package](experiments/README.md) contains all outcomes from **40 fresh tanh networks** trained with ordinary Adam or SGD, initialized using the theorem's mean-field variances, without a population penalty or post-training output rescaling. All fit every training point with the required margin. Five satisfy the original count budget automatically; 35 need actual compression.

| Search result on the 35 nonautomatic fresh networks | Witnesses found |
|---|---:|
| Original unsigned balanced populations, activation clustering | 0 |
| Signed populations, activation clustering | 6 |
| Signed populations, including an output-aware sign search | 14 |

The final 14 all have signed balanced witnesses; allowing unequal sizes is not needed for these particular successes. Across the full 40-model cohort, the output-aware search finds **11 one-population witnesses**, including shallower majority networks and four-hidden-layer Adam-trained majority networks. It uses the network's own outputs, not target labels. The large change after adding this search demonstrates why a failed clustering search is not evidence that no suitable grouping exists.

Three witnesses have exhaustive outward-rounded interval certificates, including a width-32, four-hidden-layer Adam network with readout energy about `3.53` whose clipped outputs are preserved exactly by **one signed population in every layer**, on all 256 inputs. Other successes are exhaustive float64 checks. These checks certify the merging condition; they do not automatically certify the optional internal-noise condition, and are not tests of Bayesian sample complexity.

The package also includes a larger historical checkpoint inventory, the alternative count budgets, every fresh training protocol and outcome, complete search records, and a portable replay command. The experiments establish examples and expose search limitations; they do not estimate prevalence in practical deep learning.

## Status and reproduction

The signed and unequal-group extension resolves specific artificial features of the original restriction. It remains a substantive structural assumption. A quadratic bound under **only** the original internal-noise restriction is still open, as is a general explanation of when ordinary training produces these population structures.

Run `./build.sh` to rebuild the paper. To replay the published trained-network witnesses and all three interval certificates, install NumPy, SciPy, and mpmath, then run `python replay.py --interval` from `experiments/`. The [publication record](verification/publication-build.json) records hashes, isolated source rebuilding, and empirical replay. No new Lean claim is made.

The PDF was reviewed and rebuilt from the included source on 29 October 2026. The [review record](../../../verification/remaining-papers-2026-10-29.md) describes exposition changes, mathematical corrections, and the limits of the checks. Existing formalization claims retain their stated scope.
