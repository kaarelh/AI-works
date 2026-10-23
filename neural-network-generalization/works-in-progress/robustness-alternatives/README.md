# Alternatives to neuron-merging restrictions

Research notes, 22 October 2026. These notes examine prior restrictions motivated by numerical stability, path norms, and dropout. They contain new learning arguments and explicit limitations. They are supporting research, independently reviewed by AI agents, **not Lean verified**. A small diagnostic reuses twelve existing trained tanh networks; it supplies no general trained-network guarantee.

| Condition | Completed guarantee | Qualification |
|---|---|---|
| [Internal-noise stability and bounded noisy activity](internal-noise.md) | ReLU and GELU; polynomial depth and roughly sixth-power Boolean teacher width; every learner width `N≥2C`; strong prior and every `γ≥2` | The corresponding quantitative Gaussian-mass argument for `1≤γ<2` remains open. This is a stronger condition than internal-noise score stability alone. |
| [Absolute path-norm cap](path-norm.md) | ReLU; quadratic in the declared norm budget and polynomial depth, at all eligible widths and every positive Gaussian scale | A Boolean **formula** gives a budget linear in formula size. A comparable guarantee for every small circuit with reused intermediate values is not established. The budget is fixed before seeing labels. |
| [Severe neuron-dropout stability](dropout.md) | Tanh; quadratic Boolean teacher width up to logarithms and polynomial depth; all `N≥C`; strong prior and every `γ≥2` | Retaining only a bounded number of neurons is much stronger than ordinary fixed-fraction dropout. The mean-field extension is open. |

The internal-noise condition is the strongest candidate here for a requirement one might study independently of a compression proof. It asks that clipped predictions survive simultaneous internal disturbances, and that hidden-state RMS magnitudes remain bounded on the same disturbance neighborhood. Neither clause mentions a smaller network. [Restoring Boolean gates](robust-witnesses.md) show that ReLU and GELU can satisfy both conditions at the original circuit depth, with a factor-two width overhead and energy linear in circuit width and depth. The new proof derives a small representation from these properties.

A path-norm cap is familiar and invariant under positive ReLU neuron rescaling. Its learning proof is particularly simple because the entire restricted function class has low capacity. This changes the question: the norm budget is a declared prior parameter, and the theorem does not automatically adapt to an unknown smaller circuit under one unrestricted Gaussian prior.

Dropout uses a familiar operation, but the required degree of redundancy remains strong. For the Boolean teacher witnesses, `O(C log(LC))` retained neurons suffice, even when learner width is arbitrarily larger. The support condition sets the retention budget from each network's own readout-energy/output-amplitude ratio; it does not use the unknown teacher width. Calling it dropout does not establish that ordinary dropout training produces the required property.

The [dropout diagnostic](dropout.md#a-small-diagnostic-on-already-trained-networks) illustrates the distinction. Four ordinarily trained majority models had perfect full-cube predictions and clean margins above `1/2`, but only 6–21 of 100 masks preserved the whole clipped function at 75% retention. Mean sign disagreement was only 0.2–1.3%. This is a small float64 Monte Carlo study, not an exact failure certificate or a representative population study. The theorem's conservative retention calibration selects the identity mask on these small models, so these observations do not refute literal support membership.

## Why simpler stability proxies need care

The [obstruction note](obstructions.md) proves three useful distinctions:

- Input Lipschitzness and an internal spectral cap `c>1`, even arbitrarily close to one, can coexist with all Boolean truth tables at depth proportional to input dimension and low normalized energy. This defeats a proposed capacity implication; it is **not** a Gaussian posterior sample lower bound.
- An unnormalized first-layer operator cap can make fixed-margin targets impossible at large learner widths with bounded readout energy. Width normalization matters.
- A network can have constant path norm and nearly identity scalar layers yet be exponentially sensitive to an internal disturbance: contract first, then expand. The same function may have a stable alternative representation.

These examples favor finite internal-noise control or actual bounds on accumulated transfer gains over clean-input derivatives or a per-layer expansion allowance.

## What remains open

We do not yet have a condition that is convincingly natural, established for relevant trained networks, and yields the general quadratic-width, polynomial-depth theorem throughout `γ≥1`. Internal-noise stability with bounded activity supplies a more directly motivated theorem at a worse width polynomial and a narrower finite-scale range. Path norms and dropout supply different tradeoffs. The existing tanh theorem under the original internal-noise restriction already covers all `γ≥1`, with sixth-power width dependence; see the [earlier paper](../improved-polynomials/original-support-all-scales/).

The main finite-scale bottleneck is quantitative prior mass. An exact stable implementation and a positive-probability neighborhood are insufficient for the usual all-width argument. At `γ≥2`, a full weighted parameter ball has a suitable negative-log-probability cost. At mean field, paying for all its coordinates loses width independence. The free Gaussian part used by existing cheaper constructions can act on adversarial disturbances or be amplified by severe subsampling.

## Verification

[Path-norm audit](verification/path-review.md) · [Dropout audit](verification/dropout-review.md) · [Internal-noise audit](verification/internal-noise-review.md) · [Publication record](verification/publication-check.json).

To replay the diagnostic from the repository root, run `python neural-network-generalization/works-in-progress/robustness-alternatives/check_dropout.py --output /tmp/dropout-replay.json`. It requires NumPy, checks the twelve published checkpoint hashes, and uses fixed random seeds. The [complete recorded results](dropout-diagnostic.json) include every tested model and retention. Checkpoints are reused from the [earlier training package](../improved-polynomials/neuron-merging-naturality/experiments/training-h23/).

The parent researcher independently checked the main derivations as well. Reviews found no remaining substantive gap in the stated results. During review, a first-layer energy constant was increased to cover constant gate inputs, one rounded-score inequality was made non-strict, and the coding discussion was clarified: rounding precision can be exponentially small in depth, while its logarithmic description cost is polynomial. The publication record maps reviewed source hashes to GitHub-formatted copies. Existing PDFs, the manuscript count, and Lean statements are unchanged.
