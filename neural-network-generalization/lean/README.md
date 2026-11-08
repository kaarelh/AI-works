# Lean proofs of the NNBayes learning results

This project proves the original five main learning statements and the main statements of ten additional papers. The second batch extends the activations, priors, domains, polynomial bounds, online learning and converses. [Second-batch coverage](review/BatchTwo-coverage.md) · [Main entry point](NeuralGeneralization/BatchTwoMain.lean) · [Axiom audit](NeuralGeneralization/BatchTwoAudit.lean).

The [current paper-to-Lean correspondence review](review/coverage-extension-2026-10-30.txt) records the closed and remaining coverage gaps. The latest additions close the circuit-width mismatch, the full squared-sampling estimates, biased-IID adverse ordering, several finite-noise certificates, the sparse-exception obstruction, and the unlabeled/shared-pool learning results, and the exact localized-union posterior theorem. The improved-support paper’s literal compression-budget constants and other listed variants remain open.

The original five statements concern the actual finite Gaussian neural-network model. The proofs use only Lean's standard axioms
`propext`, `Classical.choice`, and `Quot.sound`: there are no admitted proofs or
project axioms asserting analytic or probabilistic ingredients.

| Main result | Exact proposition | Closed proof |
| --- | --- | --- |
| Strong-prior limit, at each fixed width above complexity | `MainStatements.StrongPriorGeneralization` | [`MainProofs.strongPrior`](NeuralGeneralization/StrongPriorMain.lean) |
| Every width above complexity, fixed gamma > 1 | `MainStatements.AboveMeanFieldGeneralization` | [`MainProofs.aboveMeanField`](NeuralGeneralization/AboveMeanFieldMain.lean) |
| Every width above complexity, gamma = 1 | `MainStatements.MeanFieldGeneralization` | [`MainProofs.meanField`](NeuralGeneralization/MeanFieldMain.lean) |
| Full-parity exponential sample lower bound, every fixed gamma < 1 | `MainStatements.SubcriticalExponentialLowerBound` | [`MainProofs.subcriticalExponential`](NeuralGeneralization/SubcriticalMain.lean) |
| Robustness-restricted prior: polynomial depth, all widths and gamma >= 1 | `RobustMainStatements.RobustPolynomialDepthGeneralization` | [`RobustMainProofs.robustPolynomialDepth`](NeuralGeneralization/RobustMain.lean) |

[Statements.lean](NeuralGeneralization/Statements.lean) defines the exact
first four propositions; [RobustStatements.lean](NeuralGeneralization/RobustStatements.lean) defines the fifth. The separately named theorems prove them. The fourth theorem
includes gamma = 0 and gamma < 0. Its constants are chosen before gamma, and it
covers every specified sample size from zero to `exp(c*d)`. Its target is full
parity, `k = d`; the stronger sparse-parity question remains open.

A polynomial version of the parity-network appendix is also proved: [`ParityNetwork.exists_parity_complexity`](NeuralGeneralization/ParityNetworkDepth.lean) gives actual bounded-weight
complexity at most `32*(d+1)^2` at every depth.
[`subcriticalSmallNetworkLowerBound`](NeuralGeneralization/SubcriticalCircuitCorollary.lean) combines this construction with the exponential posterior lower bound.
The construction uses a simpler polynomial bound than the appendix's optimized logarithmic weights.

## Adversarial online lower bound for ordinary ReLU

The [ReLU online-mistake paper](../works-in-progress/online-mistakes/isotropic-relu-allwidth/paper.pdf) also has a complete formalization. [`OnlineLowerReluMain.lean`](NeuralGeneralization/OnlineLowerReluMain.lean) proves the exact [`ReLUConcreteMainStatement`](NeuralGeneralization/OnlineLowerReluConcreteStatement.lean), then its `exp(Ω(√C))` resource corollary. [`CheckOnlineLowerRelu.lean`](CheckOnlineLowerRelu.lean) checks the exact theorem types and dependency axioms. [Paper-to-Lean correspondence](review/OnlineLowerRelu-main-correspondence.md) · [Analytic correspondence](review/OnlineLowerRelu-analytic-correspondence.md).

This is a lower bound on cumulative mistakes along a fixed nonrepeating input order, with a large calibration history. It uses the actual independent Gaussian prior, the initial strict margin at every Boolean input, and subsequent conditioning on Boolean labels. The permutation is fixed before width and scale; the prior scale tends to zero at each fixed width above the explicit threshold. The formalization includes all nonlinear competitors and posterior mixtures. It assumes no energy gap, neuron norm bound, or posterior-concentration theorem: these are proved in its dependency chain.

The exact parameters are `R=2^1024`, `m=6k+4`, `d=(8k+4)(2R+4)`, teacher width `C=3(m+1)(d+1)`, sufficient learner width `N₀=2^(m+d+1)`, and `2^(k−1)` designated mistakes. The teacher has margin at least one and coefficients bounded by `C`. The target has a NAND circuit with at most `17d+5` gates. At every fixed `N≥N₀`, correct-label confidence tends to zero on every designated round; at sufficiently small positive scale the same posterior gives all designated sampling errors with arbitrarily high probability, majority errors, and `>2/3` confidence failures.

The softplus extension is not included in this formalization. The ordinary-tanh theorem has its own complete proof, described below.

```sh
lake build NeuralGeneralization.OnlineLowerReluMain
lake env lean CheckOnlineLowerRelu.lean
```

## Adversarial online lower bound for ordinary tanh

The [ordinary-tanh paper](../works-in-progress/online-mistakes/isotropic-tanh-allwidth/paper.pdf) has a complete formalization of its improved main theorem. [`OnlineLowerTanhMain.lean`](NeuralGeneralization/OnlineLowerTanhMain.lean) proves `tanh_concrete_main : TanhConcreteMainStatement`, the logarithmic-rail resource statement, and `tanh_square_root_log_loss_lower_bound : TanhSquareRootLogLossStatement`. [`CheckOnlineLowerTanh.lean`](CheckOnlineLowerTanh.lean) checks these exact types and their transitive axioms. [Paper-to-Lean correspondence](review/OnlineLowerTanh-main-correspondence.md) · [Independent global analytic review](review/OnlineLowerTanh-global-independent-audit.md).

The bound is `exp(Ω(√C/log(C+2)))` designated mistakes for a displayed bounded-weight shallow tanh teacher of width `C`. One fixed full-cube input permutation works at every sufficiently large fixed learner width, then as the Gaussian scale tends to zero. The prior has the initial strict margin on the entire cube, and training conditions on the observed signs and margins. Its Gaussian law includes every nonlinear competitor and posterior mixture. Normalizers are proved positive. The exact construction uses `m=6k+6`, rails `R=2⌈K log²(m+2)⌉`, increment `H=2⌈m log(m+2)⌉`, and `2^(k−1)` designated rounds; its dimension is `Θ(k log² k)` and teacher width is `O(k² log² k)`.

The proof discharges the sharp global tanh parity inequality, affine support bounds, physical code localization, scalar cost ordering, calibration and finite-width realization, and the Gaussian posterior comparison. The analytic ingredients are proved, rather than supplied as hypotheses. All main endpoints use only `propext`, `Classical.choice`, and `Quot.sound`. The sufficient degree and width thresholds are existential. The [verification record](../works-in-progress/online-mistakes/isotropic-tanh-allwidth/verification/README.md) distinguishes main-theorem coverage from additional standalone appendix assertions.

```sh
lake build NeuralGeneralization.OnlineLowerTanhMain
lake env lean CheckOnlineLowerTanh.lean
```

## Model and quantifiers

For the first four theorems, [Network.lean](NeuralGeneralization/Network.lean) defines the concrete network,
all weight coordinates, and bounded-weight network complexity. Depth is `r + 2`.
[Model.lean](NeuralGeneralization/Model.lean) defines the independent Gaussian
weight laws. Network.lean also defines the strict output margin at **every**
Boolean input, and [FunctionPrior.lean](NeuralGeneralization/FunctionPrior.lean)
defines exact noiseless conditioning, posterior risk, confidence failure, and
the finite IID sample distribution. Prediction succeeds when the correct-label
posterior probability is **strictly greater than 2/3**; equality counts as
failure. The mean-field and subcritical statements use this criterion directly.
The strong-prior and gamma > 1 statements bound posterior average error; their
confidence versions, obtained by applying them at accuracy `epsilon/3`, are
closed theorems in [CheckConfidence.lean](CheckConfidence.lean). Prediction is not
defined by the sign of the posterior mean.

The strong-prior result fixes width before taking the variance small. Its
variance threshold may depend on width, but precedes the input law, sample
size, and confidence parameter. The two all-width results hold for every
`N >= C_L(f)` at the specified nonzero variance. The subcritical theorem fixes
dimension, sample size, margin, depth, and gamma before letting width tend to
infinity. It proves probability at least 3/4 of a confidence-failure liminf at
least 1/16; it does not give a quantitative minimum width or a joint limit.

The upper-bound results quantify over arbitrary input distributions. The
subcritical lower bound uses uniform IID inputs and holds for each specified
sample size, with common constants. It does not assert one event for all
prefixes of a sample sequence or monotonicity of this learner in sample size.

## Conventions for generalization under a robustness restriction

[RobustModel.lean](NeuralGeneralization/RobustModel.lean) defines stability of the clipped score under a ball of simultaneous hidden-activation and output perturbations. Its radius is calibrated by depth and readout energy. The Gaussian prior is restricted to this support event; **no clean-output margin on every input is imposed**. Training requires signed output strictly above `1/2`; test risk uses signed output at most `1/4`.

The target is a concrete [layered Boolean circuit](NeuralGeneralization/RobustCircuit.lean) of width `C`, with its constant wire and compilation resources counted. A true bias wire is required only when a NAND gate consumes it. Padding copies the designated circuit slot, so it does not add a compulsory constant final output. The target-cylinder proofs preserve the counted width, and width-one literal/copy/negation cases are checked in [RobustCircuitWidthOne](NeuralGeneralization/RobustCircuitWidthOne.lean). It is not an arbitrary small analog neural circuit. There exist universal constants `A > 0` and a natural-number exponent `m`, chosen before dimension, depth, target circuit, robustness calibration, and statistical parameters, giving a bound

```text
A * (2 + d + C + r + c + 1/c + 1/epsilon + log(1/delta))^m
```

Here depth is `r + 2`. For arbitrary input law, **one sample event** of probability at least `1-delta` works for every `N >= C` and every positive `sigma` with `N*sigma^2 <= 1`. This includes every `gamma >= 1` under `sigma^2 = N^(-gamma)`. The exact theorem gives positive posterior normalization, Gibbs test-margin risk at most `epsilon/3`, and test-input fraction at most `epsilon` whose correct-label margin confidence is at most `2/3`.

The proof constructs the actual large-width couplings and histories; a conditional compression theorem is not substituted for the main proof. Small widths, target prior mass, conditioning, finite coding, and sampling are also discharged. [CheckRobust.lean](CheckRobust.lean) rejects a purported main theorem with extra hypotheses.

## Proof coverage

The main proofs discharge the Gaussian mass and width limits, compression,
counting, concentration, spectral, sampling, conditioning, and scalar estimates
they use. The subcritical proof includes all tied minimum-energy functions
when gamma is positive, global-margin Gaussian conditioning when gamma is
zero, and the Gaussian sign posterior when gamma is negative.

Some proofs use different sufficient estimates from the manuscripts. In
particular, the gamma > 1 proof uses a finite matrix grid and an orthogonal
energy witness instead of the paper's sharper singular-value tail lemma.
It proves the same existential-polynomial main learning statement. The
subcritical proof also uses different numerical constants and explicit
buffered confidence thresholds.

The robustness proof uses a conservative Pinsker-and-energy argument in place of the manuscript's sharper transport estimate. [RobustCompressionExplicitDegree.lean](NeuralGeneralization/RobustCompressionExplicitDegree.lean) checks a loose degree **10974** for its exact finite-class sample-budget formulas. This is a sufficient envelope, not a practical estimate or an optimality claim.

This verifies the **five exact main learning theorems**, not every sentence,
appendix, or auxiliary sharp constant in the PDFs. The general circuit
simulation, depth-dependent cardinality lower bound, and separate inverse
mass-to-complexity equivalence are not additional conclusions of this gate.
The side-result papers and open sparse-parity refinements are outside its
scope. For the robustness manuscript, the optional extra all-input-margin learning variant, other robustness extensions, empirical certificates, and sharper displayed constants are not additional conclusions of the exact main gate. See the [coverage inventory](review/formal-coverage-inventory.txt)
and the semantic reviews for the precise distinction.

The Gaussian quadratic-form implementation adapts some locally included
lemmas from this repository's Paulsen project, with attribution in the
source. Those lemmas are rechecked here; an earlier review is not a proof
assumption.

## Reproduce the checks

The project pins Lean 4.32.0 and mathlib revision
`81a5d257c8e410db227a6665ed08f64fea08e997`; all dependency revisions are in
[lake-manifest.json](lake-manifest.json). With the pinned toolchain installed:

```sh
lake exe cache get
lake build
lake env lean Audit.lean
lake env lean CheckMain.lean
lake env lean CheckParity.lean
lake env lean CheckRobust.lean
lake env lean CheckConfidence.lean
```

The cache command is optional. Without access to the official cache, Lake can
build the imported mathlib sources. `Audit.lean` checks every imported project
theorem's axiom closure and reports exact main-proof coverage. `CheckMain.lean`
requires the four earlier exact types; `CheckRobust.lean` requires the fifth. Both reject unexpected axioms, including
`sorryAx`. A component compilation alone does not pass this gate.

For an independent rebuild without reusing project object files:

```sh
python3 review/verification/rebuild_main.py \
  --main all --destination /tmp/neural-lean-independent-check
python3 review/verification/verify_supplement.py \
  --destination /tmp/neural-lean-independent-check
```

Choose a destination that does not already exist. The script copies the full
transitive project source closure into a new directory, checks the pinned
external packages, rebuilds every project dependency, verifies exact theorem
types and axiom closures, and checks source hashes before and after. By default
it reuses external package objects and records their hashes. Add
`--fresh-dependencies` to rebuild those packages from source too. See the
[procedure](review/verification/rebuild-procedure.txt) for the trust boundary
and generated evidence.

## Coverage continuation: 2 November 2026

[RobustCountablePools](NeuralGeneralization/RobustCountablePools.lean) proves the
prescribed countable-family unlabeled-pool guarantee with one common labeled
event and exact per-learner unlabeled budgets.
[RobustInputNeighborhood](NeuralGeneralization/RobustInputNeighborhood.lean) and
[RobustNeighborhoodRadius](NeuralGeneralization/RobustNeighborhoodRadius.lean)
prove the real-input neighborhood transfer and its exact readout-noise limit.

[BatchTwoOnlineFiniteLossCover](NeuralGeneralization/BatchTwoOnlineFiniteLossCover.lean)
proves the general finite-loss online comparison.
[BatchTwoOnlineMergingSampledIID](NeuralGeneralization/BatchTwoOnlineMergingSampledIID.lean)
closes the actual sampled-mistake expectation and sharp tail for the existing
merging-supported ReLU Gaussian learner under permutation and infinite uniform
IID inputs, using the original polynomial-depth budget. These statements use
actual posterior parameter draws, with repeated queries and infinite horizons
handled explicitly. They do not concern arbitrary adversarial query orders.

The [coverage review](review/coverage-extension-2026-10-30.txt) continues to list
the unresolved claims; this is not complete coverage of every appendix.

## Localized-union coverage: 2 November 2026

[RobustLocalizedPolynomial](NeuralGeneralization/RobustLocalizedPolynomial.lean)
proves the paper's exact union-conditioned Gaussian guarantee: risk at most
rho + epsilon, universal polynomial labeled complexity, logarithmic-family
validation complexity, and one event for every eligible width and scale.
It also proves the same-input corollary. The strict training-margin likelihood
is unchanged, including at exceptional inputs. [RobustLocalizedConditioning](NeuralGeneralization/RobustLocalizedConditioning.lean)
checks equality with the two-stage prior-then-likelihood conditioning.

[FiniteUnionEntropy](NeuralGeneralization/FiniteUnionEntropy.lean) proves the
exact component KL identity and log M overhead. The learning proof uses an
alternative small-component cutoff and the actual Gaussian compressor; it
never assumes each exception component contains a target cylinder.
[RobustLocalizedPilot](NeuralGeneralization/RobustLocalizedPilot.lean) handles
independent finite-valued pilot selection. [LocalizedFamilyCounting](NeuralGeneralization/LocalizedFamilyCounting.lean)
and [LocalizedCubeBalls](NeuralGeneralization/LocalizedCubeBalls.lean) prove the
VC-family bound and the exact cube-centered Euclidean-ball description bound.
The geometric upper-orthant/ellipsoid VC estimates and other remaining
extensions are listed in the coverage review. No paper was edited.


## Two-margin coverage: 3 November 2026

[TwoMarginMain](NeuralGeneralization/TwoMarginMain.lean) proves the paper's
numerical two-margin replacement theorem, with the original universal
polynomial envelope, all-width/all-scale sample event, actual Gaussian
posterior, optional global clean-margin restriction, and confidence bound.
[TwoMarginLocalizedPolynomial](NeuralGeneralization/TwoMarginLocalizedPolynomial.lean)
proves its localized union and same-input counterparts; independent pilot
selection and exact two-stage conditioning are also formalized.

[MarginBandScore](NeuralGeneralization/MarginBandScore.lean) and
[MarginBandSupport](NeuralGeneralization/MarginBandSupport.lean) prove the exact
margin-band formula, contraction through clipping, the support inclusions,
endpoint interval certificate, and the manuscript's strict-weakening examples.
The arbitrary monotone-transform learning theorem, full-gap minimality and
general-margin extension remain listed in the coverage review. Papers are
unchanged. Verification is recorded in
[the two-margin evidence](review/verification/coverage-two-margin-2026-11-03/record.json).


## Monotone-score coverage: 3 November 2026

[MonotoneScorePolynomial](NeuralGeneralization/MonotoneScorePolynomial.lean)
proves the arbitrary monotone-score-transform theorem with one universal
polynomial, chosen before the transform, and explicit inverse-gap dependence.
The actual Gaussian posterior, strict training margin, test margin, optional
global separation and all-width/all-scale confidence guarantee are retained.
[MonotoneScoreLocalizedPolynomial](NeuralGeneralization/MonotoneScoreLocalizedPolynomial.lean)
closes the localized union and same-input variants, with exact conditioning
and independent-pilot extensions in their corresponding modules.

[MarginBandMinimality](NeuralGeneralization/MarginBandMinimality.lean) proves
the paper's full-gap minimality identity and contraction. The
[margin-band specialization](NeuralGeneralization/MarginBandTransformCorollaries.lean)
has exactly the original compression resources and finite-class budget.
[RobustTargetNoisyMargin](NeuralGeneralization/RobustTargetNoisyMargin.lean)
exposes the stronger cylinder property that supplies the unchanged target mass.
No paper was edited; other coverage gaps remain in the review. See the
[verification record](review/verification/coverage-score-transforms-2026-11-03/record.json).
