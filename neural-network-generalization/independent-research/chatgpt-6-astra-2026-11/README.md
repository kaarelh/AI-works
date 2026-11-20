# Independent research by ChatGPT-6 Astra

**Sole author of these papers: ChatGPT-6 Astra. Independent AI research.**

This collection contains 33 manuscripts developed during November 17–20, 2026. Execution was interrupted between active research sessions; elapsed calendar time is not presented as uninterrupted work. It is separate from the repository's jointly authored papers. Existing results, imported formalizations, and inherited certificates retain their original credit; their use here does not change their author lists.

The manuscripts are research drafts with conventional proofs and same-session checks. They have not received independent review. 53 selected deterministic statements have Lean proofs; this is not a claim of complete formalization of the papers. The [verification inventory](verification/README.md) separates exact certificates, Lean proofs, numerical checks, and experiments.

## Research questions and reading map

1. **How much continuous initialization noise destroys useful parity features?** For smoothed Rademacher weights, the polynomial/superpolynomial boundary is at total injected variance of order log dimension. The initialization paper gives a finite-feature perceptron guarantee, sharp kernel asymptotics, and separately specified noisy population-gradient obstructions. It also proves a same-variance arithmetic contrast between bounded discrete priors, including the effect of hidden-bias cancellations.
2. **Can polynomial Bayesian pretraining create transferable features?** For Gaussian and every fixed lighter-tailed exponential-power prior, a sufficiently cold actual posterior learns features from polynomially many IID samples. Nearby parity tasks then have polynomial readout complexity. A low-rank cancellation gives a finite-data guarantee for each fixed nearby task using the original raw features, with an explicit confidence--dimension condition. Exact posterior sampling is assumed.
3. **How local is that transfer?** The same representation can help nearby parity tasks while leaving distant, equally small neural targets expensive. A separate dimension-dependent heavy-tail prior can obstruct even nearby frozen-feature regression.
4. **Which likelihood and input-process assumptions control lifetime mistakes?** Positive observed margins, width-scaled logistic likelihoods, and density-controlled input streams have different guarantees. Zero-margin and unscaled-likelihood examples show why these distinctions matter.
5. **How do optimization traps depend on the trainable parameters?** Explicit full-support examples exhibit shortcut traps, renewal directions, and a partially learned attractor. Their initialization and bias assumptions are stated; typical-random-initialization trapping is not inferred from a constructed basin.

## Main additions in the second round

| Paper | Main conclusion | Material qualification |
| --- | --- | --- |
| [Independent large-width constructions for Gaussian ReLU posteriors](papers/relu-independent-posterior/README.md) | Independent large-width constructions for both hard-margin and smooth-likelihood full-label posteriors, converging in total variation. | Full-cube observations and fixed dimension at least six; expected cost is linear in width with an unrestricted dimension constant. No finite-width accuracy rate. |
| [A critical exponential tilt of a Gaussian ReLU neuron](papers/relu-critical-tilt-proof/README.md) | Scalar-conditioning evidence, an independent asymptotic posterior construction, and stable/Gaussian output fluctuations. | One global parity statistic rather than individual labels; fixed dimension, no finite-width sampling-error rate. A sampled network can fail while posterior majority is correct. |
| [Finite-data raw-feature transfer by removing a low-rank component](papers/raw-finite-data-transfer/README.md) | Finite polynomial-data transfer to each fixed nearby parity using the original raw features. | The failure bound averages over IID pretraining and the posterior; an explicit confidence--dimension condition applies, and simultaneous success on every task is not asserted. |
| [Continuous smoothing of parity features: a quantitative initialization threshold](papers/continuous-initialization-parity/README.md) | Smoothing threshold, exact high-degree kernel asymptotics, and noisy optimization obstructions. | The positive perceptron and negative gradient protocols are distinct; hinge hardness additionally uses zero readouts and a small-noise condition. |
| [Polynomial-data feature transfer for cold Gaussian ReLU Bayes](papers/near-minimum-energy-transfer/README.md) | Polynomial-data, finite-width cold Gaussian feature transfer. | Even features or a linear input skip; exact posterior sampling. |
| [Gaussian square likelihoods can learn transferable parity features](papers/square-likelihood-transfer/README.md) | The transfer result also holds for a specified Gaussian likelihood. | The ordinary-likelihood corollary relates width, data size, and prior variance. |
| [Polynomial-data parity transfer under Gaussian and lighter tails](papers/power-prior-transfer/README.md) | Finite transfer for every fixed exponential-power exponent p >= 2; a narrower continuous bias prior gives Gaussian-order sufficient sample exponents. | Cold scale and fixed p; no efficient posterior-pretraining algorithm. |
| [Locality of parity transfer in a learned neural representation](papers/transfer-locality/README.md) | Polynomial nearby-task learning and exponential distant-task readout complexity in the same representation. | Frozen Gaussian readouts and squared error; not a general classification lower bound. |
| [Heavy-tail sparsity can obstruct frozen-feature transfer](papers/heavy-tail-transfer-obstruction/README.md) | Superpolynomial nearby-task frozen-regression complexity despite full source pretraining. | p=1/log(r) varies with dimension, and width tends to infinity first. |

## Further transfer refinements

The finite-energy transfer paper gives an exact obstruction for raw features, including polynomial-width source networks with arbitrarily near-minimal energy. The full-data transfer and orientation papers prove a complementary typical-sector result: raw exceptional features transfer to nearby parities with high probability as dimension grows, uniformly down to arbitrarily cold positive priors in the stated width-first limit. The latter uses a cited asymptotic enumeration theorem for resilient Boolean functions. The new low-rank paper separately gives finite-polynomial-data raw transfer for each fixed nearby task, with a weaker confidence bound and an explicit dimension condition. It does not establish simultaneous raw transfer for every task in every finite representation.

## Remaining question: margins only on observed inputs

The shared repository already proves a [superpolynomial strong-prior ReLU/softplus mistake lower bound](../../works-in-progress/online-mistakes/isotropic-relu-allwidth/README.md) with an initial absolute-margin restriction on the whole cube. The question left open here removes that restriction: this collection does **not** prove a superpolynomial classification-mistake lower bound for the isotropic Gaussian, one-hidden-layer ReLU learner conditioned only on observed positive margins in the strong-prior limit. Exact certificates give fifteen designated wrong predictions in four bits and seventeen in five bits; neither is a scalable family. The new superpolynomial transfer bounds concern frozen-feature regression under their stated priors and readouts. These statements must not be substituted for the unresolved adversarial theorem.

## Manuscripts

### 1. Likelihood and online learning

- [Quantitative width and online Bayesian mistakes](papers/polynomial-width-online-proof/README.md).
- [A smooth-likelihood all-width mistake bound](papers/logistic-online-polynomial/README.md).
- [A one-neuron target that defeats wide sign-only Bayes](papers/sign-only-fourier-counterexample/README.md).
- [Observed-margin ReLU mistakes on four and five bits](papers/observed-margin-relu-fifteen-errors/README.md).

### 2. Bayesian feature learning and prior tails

- [A critical exponential tilt of a Gaussian ReLU neuron](papers/relu-critical-tilt-proof/README.md).
- [Exponentially many exceptional neurons in a Gaussian ReLU posterior](papers/relu-exponential-posterior-condensation/README.md).
- [The exact ReLU condensate count and its polynomial evidence cost](papers/relu-sharp-condensate-count/README.md).
- [The orientation law of Gaussian ReLU condensates](papers/relu-orientation-law/README.md).
- [Independent large-width constructions for Gaussian ReLU posteriors](papers/relu-independent-posterior/README.md).
- [Width-uniform IID learning and feature amplification for Gaussian ReLU Bayes](papers/relu-iid-feature-learning/README.md).
- [Transfer to nearby parity targets after Bayesian feature learning](papers/relu-parity-feature-transfer/README.md).
- [Kernel fluctuations within a ReLU orientation sector](papers/relu-posterior-kernel-fluctuations/README.md).
- [Bayesian feature selection among irrelevant inputs](papers/relu-irrelevant-dimensions/README.md).
- [Ordinary feature adaptation under faster-than-Gaussian ReLU priors](papers/relu-quartic-posterior/README.md).
- [Sparse posterior condensation under heavier-than-Gaussian ReLU priors](papers/relu-heavy-tail-posterior/README.md).
- [Gaussian softplus neurons need not have entropy projections](papers/softplus-critical-tilt-proof/README.md).
- [Exactly four softplus condensates](papers/softplus-exact-four-condensates/README.md).
- [A likelihood-driven condensation transition](papers/softplus-likelihood-phase-transition/README.md).
- [Exponentially many posterior condensates for a small parity teacher](papers/softplus-exponential-condensation/README.md).
- [Checking and moving between posterior sectors](papers/posterior-sampling-methods/README.md).
- [Polynomial-data feature transfer for cold Gaussian ReLU Bayes](papers/near-minimum-energy-transfer/README.md).
- [Heavy-tail sparsity can obstruct frozen-feature transfer](papers/heavy-tail-transfer-obstruction/README.md).
- [Gaussian square likelihoods can learn transferable parity features](papers/square-likelihood-transfer/README.md).
- [Locality of parity transfer in a learned neural representation](papers/transfer-locality/README.md).
- [Polynomial-data parity transfer under Gaussian and lighter tails](papers/power-prior-transfer/README.md).
- [Finite-data raw-feature transfer by removing a low-rank component](papers/raw-finite-data-transfer/README.md).

### 3. Alignment, trapping, and feature renewal

- [A full-support Boolean shortcut trap](papers/full-support-shortcut-trap/README.md).
- [Imbalance and one-neuron renewal at the shortcut trap](papers/shortcut-renewal-and-imbalance/README.md).
- [An exact partially learned parity attractor](papers/partial-recovery-dead-point/README.md).
- [A shortcut trap with trainable hidden biases](papers/trainable-bias-shortcut-trap/README.md).

### 4. Adaptive distribution shift

- [Tiny adaptive shifts and the importance of a density lower bound](papers/adaptive-shift-comparison/README.md).
- [Controlled shifts for observed-margin Gaussian ReLU Bayes](papers/adaptive-shift-observed-margin/README.md).

### 5. Initialization and noisy optimization

- [Continuous smoothing of parity features: a quantitative initialization threshold](papers/continuous-initialization-parity/README.md).

## Conventions that must be kept distinct

- **Width-first results** fix dimension and prior parameters before taking width to infinity. They do not provide a polynomial effective width unless explicitly stated.
- **Cold fixed-width results** take prior variance to zero at a fixed eligible architecture. They are separate from fixed-temperature width limits.
- **Finite-data transfer results** have explicit polynomial thresholds and an accuracy-dependent prior scale. Their feature transformation and downstream learning rule are part of the theorem.
- **Norm or squared-error lower bounds** do not, by themselves, imply classification-mistake lower bounds.
- **Numerical chains** do not have mixing certificates. Agreement between starts or with a formula is diagnostic evidence only.

## Relationship to the shared repository

The [parity-energy paper](../../works-in-progress/online-mistakes/relu-parity-energy-width/README.md) supplies the sharp ReLU atom geometry used in several proofs. The [online upper-bound paper](../../works-in-progress/online-mistakes/upper/README.md) is the starting point for the quantitative online extensions. The existing four-bit certificate data are preserved with provenance in [baseline-copy/d4](baseline-copy/d4).

The recent shared papers on [Gaussian posterior path-norm geometry](../../works-in-progress/agnostic-relu-path-geometry/README.md) and [raw Gaussian approximation guarantees](../../works-in-progress/agnostic-gaussian-raw-width-only/README.md) address related posterior-objective and prediction questions. The feature-transfer and initialization conclusions here are separate questions; generic posterior variational bounds are not claimed as a new theme.

## Reproduction

Each paper has a self-contained `source` directory and `build.sh`. Run `bash build.sh` in its directory with Tectonic or pdflatex installed. `TECTONIC` can specify an executable; `TECTONIC_OFFLINE=1` uses only cached TeX resources.

The [first-round exploratory archive](exploratory/first-round/README.md) preserves supporting code and selected diagnostics, including abandoned approaches explicitly distinguished from the papers. The [verification inventory](verification/README.md) gives commands and exact coverage. [paper-index.json](paper-index.json) is the machine-readable reading map. Large exploratory trajectories are not presented as mathematical certificates. The supplied code and selected diagnostics document the calculations; the conventional proofs carry the asymptotic claims.
