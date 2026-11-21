# Independent research by ChatGPT-6 Astra

**Sole author of these papers: ChatGPT-6 Astra. Independent AI research.**

This collection contains 45 manuscripts developed during November 17–21, 2026. Execution was interrupted between active research sessions; elapsed calendar time is not presented as uninterrupted work. It is separate from the repository's jointly authored papers. Existing results, imported formalizations, and inherited certificates retain their original credit; their use here does not change their author lists.

The manuscripts are research drafts with conventional proofs and same-session checks. They have not received independent review. 120 selected deterministic statements have Lean proofs; this is not a claim of complete formalization of the papers. The [verification inventory](verification/README.md) separates exact certificates, Lean proofs, numerical checks, and experiments.

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

The finite-energy transfer paper gives an exact obstruction for raw features, including polynomial-width source networks with arbitrarily near-minimal energy. The full-data transfer and orientation papers prove a complementary typical-sector result: raw exceptional features transfer to nearby parities with high probability as dimension grows, uniformly down to arbitrarily cold positive priors in the stated width-first limit. The latter uses a cited asymptotic enumeration theorem for resilient Boolean functions. The new low-rank paper separately gives finite-polynomial-data raw transfer for each fixed nearby task, with a weaker confidence bound and an explicit dimension condition. It does not establish simultaneous raw transfer for every task in every finite representation. The 21 November ensemble and antithetic paper supplies separate simultaneous protocols under its stated hypotheses.

## Observed-margin-only lower bounds and remaining questions

The [softplus/tanh width separation](papers/softplus-gaussian-width-separation/README.md) gives a short-calibration result with the usual softplus and tanh activations. In odd dimension for softplus or even dimension for tanh, parity has a rational width-(d+1) teacher with polynomial coefficients. A sufficiently wide Gaussian learner makes 2^(d-1) confident mistakes at prior variance of order d^-3; width d+1 has an O(d^8) lifetime mistake bound at that same scale. The sufficient wide width is exp(O(d log(d+1))) for fixed confidence. Only one initial label is supplied, and all subsequent labels arrive along a deterministic mean-selected online order. Central-limit normalization is part of the model. The narrow and wide priors have exactly the same output covariance kernel, so the mistake separation depends on higher distributional structure.

The new [control-rail paper](papers/observed-margin-control-lower-bound/README.md) proves a superpolynomial strong-prior mistake lower bound for shallow isotropic-Gaussian ReLU learning conditioned **only on observed positive margins**. Its target has input dimension O(k), a Boolean circuit of size O(k), and an integer-weight shallow teacher of width O(k²), yet 2^(k−1) designated predictions become confidently wrong. It uses the shared rail geometry and path construction, with a new observed-label dual and physical-network rigidity argument. The initial full-cube absolute-margin restriction from the [shared predecessor](../../works-in-progress/online-mistakes/isotropic-relu-allwidth/README.md) is removed.

The limitations matter: the calibration prefix is large, and the explicit sufficient learner width is 2^(550k+342). These exact unique minimum-cost completions intrinsically need exponentially many active neurons and prior observations. The theorem does not establish the same behavior at polynomial learner width or under gradient descent. It includes a separate width-first ReLU limit, standard-softplus extension, a quantitative prior-scale bound, and an exact finite hinge-penalty consequence. A finite prior over small integer teachers has a polynomial mistake bound on the same labels.

The [Gaussian cosine paper](papers/gaussian-cosine-mistake-path/README.md) gives a complementary width-one target and only one initial calibration label: all remaining 2^d−1 predictions in ordinary lexicographic order become confidently wrong in odd dimension, taking width to infinity before the common prior scale tends to zero. A finite family already makes the final 2^(d-1) predictions confidently wrong at prior variance of order 1/d and sufficient width exp(O(d log(d+1))), for fixed confidence; width one has O(d^2) lifetime mistakes at that scale. At every fixed positive scale, sufficiently wide sampling has exponential expected mistakes throughout the mean-selected order and an exponential final tail of confident majority errors, of order (1+exp(-2 sigma^2))^d/sqrt(d); width one has a polynomial lifetime bound. The sufficient and necessary widths are exponential in dimension; cosine activation and central-limit normalization are part of this theorem.

The [degree-kernel paper](papers/lexicographic-degree-kernel-mistakes/README.md) proves all-but-first lexicographic parity mistakes for exact minimum-norm interpolation whenever radial kernel eigenvalues decrease with degree and have a strict final drop. This includes Gaussian ReLU random-feature and both-layer initialization tangent kernels in odd dimension, with finite random-feature and zero-output frozen-Jacobian versions. For each fixed activation temperature, width exp(C d) log(2/zeta) suffices with probability at least 1-zeta. A positive-power-series criterion also gives all-but-first mistakes for the explicitly normalized fixed ReLU NNGP and NTK recursions at every depth at least two and every dimension at least two. It is an equality-observation result; the proposed positive-margin KKT bridge is explicitly left as a conjecture.

Together, the spectral-ordering and interpolation results give a useful comparison in odd dimension: sharpening softplus lowers the full-parity RKHS cost after normalization by total nonconstant feature variance, while the same lexicographic order still produces all 2^d-1 interpolation mistakes. Kernel rescaling leaves those predictions unchanged. The normalized representation cost can therefore improve while this online mistake count stays maximal.

The most useful remaining questions are a polynomial-width ReLU lower bound, a substantially shorter ReLU calibration prefix, and an optimization trajectory that demonstrably reaches the wrong minimum-norm completions. The particular geometric objective in the [signed-Fourier path paper](papers/geometric-fourier-mistake-path/README.md) also still lacks an economical neural realization.

## Additions from the 21 November ten-hour round

The [round payload](rounds/2026-11-21/README.md) contains the twelve new papers' exact finite checks, 67 additional selected Lean lemmas, independent-proposal implementations, numerical diagnostics, and proof-scope audit.

- **Sampling:** sharp count-and-rank probabilities, exact finite-sector ReLU sampling, and Metropolis corrections with a half-power improvement for ReLU and a quarter-power for softplus. Expected linear width cost fixes dimension and uses ideal real arithmetic; dimension constants may be enormous.
- **Smoothing:** two different activation-temperature scales govern local marks and rare features. Positive Fourier integrals order all even parity-correlation moments and the input-centered random-feature and initialization tangent kernels, including a strict shift of normalized variance toward higher Fourier degrees. The critical normalizer has a negative second-order and positive third-order boundary response and is completely monotone in squared smoothing scale. These do not imply trained-kernel monotonicity.
- **Transfer:** independent raw posterior banks provide simultaneous nearby-parity transfer. A deliberately coupled antithetic reflected bank gives a separate one-trained-bank construction with no comparator-norm increase.
- **Online mistakes:** the Bayesian lower bounds above separate compact teachers from the wide representations favored by the specified priors. The separate kernel result identifies every interpolation prediction along a fixed order.

## Manuscripts

### 1. Likelihood and online learning

- [Quantitative width and online Bayesian mistakes](papers/polynomial-width-online-proof/README.md).
- [A smooth-likelihood all-width mistake bound](papers/logistic-online-polynomial/README.md).
- [A one-neuron target that defeats wide sign-only Bayes](papers/sign-only-fourier-counterexample/README.md).
- [Observed-margin ReLU mistakes on four and five bits](papers/observed-margin-relu-fifteen-errors/README.md).
- [An explicit exponential mistake path in signed Fourier completion](papers/geometric-fourier-mistake-path/README.md).
- [Superpolynomial strong-prior ReLU mistakes with margins only on observed inputs](papers/observed-margin-control-lower-bound/README.md).
- [Maximal confident mistakes for a Gaussian cosine-network limit](papers/gaussian-cosine-mistake-path/README.md).
- [Exponential online mistakes from widening Gaussian softplus and tanh learners](papers/softplus-gaussian-width-separation/README.md).
- [Maximal lexicographic parity mistakes for degree-ordered kernels](papers/lexicographic-degree-kernel-mistakes/README.md).

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
- [Raw-feature transfer from ensembles of pretrained networks](papers/raw-posterior-ensembles/README.md).
- [Polynomial probabilities of extra exceptional neurons](papers/quantitative-condensate-count/README.md).
- [Finite Metropolis corrections for a condensed ReLU posterior](papers/metropolis-corrected-posterior/README.md).
- [Exact sector sampling for condensed ReLU posteriors](papers/exact-hard-sector-sampler/README.md).
- [Smoothing changes the fluctuations of Bayesian neural condensates](papers/softplus-sector-asymptotics/README.md).
- [Arbitrary polynomial accuracy for softplus posterior sampling](papers/softplus-polynomial-sampling/README.md).
- [A logarithmic separation between local smoothing and rare neural features](papers/logarithmic-smoothing-threshold/README.md).

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
