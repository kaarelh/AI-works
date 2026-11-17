# Lean proofs of the NNBayes learning results

The NNBayes formalization proves the original five learning results, the main results of ten second-batch papers, and the conditional nonpolynomial-learning theorem in a separate Lean project. The original results concern the actual finite Gaussian neural-network model. Their proofs use only Lean's standard axioms `propext`, `Classical.choice`, and `Quot.sound`, with no admitted proofs or project axioms supplying analytic or probabilistic ingredients.

The [15 November 2026 coverage completion](review/coverage-completion-2026-11-15.txt) records that all main statements and important mathematical gaps identified in the sixteen-paper review are covered. This includes the improved original-support paper's literal target-cylinder cost, compression and learning budgets, and degree-46 sample bound. The [detailed correspondence inventory](review/coverage-extension-2026-10-30.txt) gives the exact hypotheses and limits; earlier dated entries preserve the gaps that were open at those snapshots. This claim does not extend to every informal display, empirical computation, or other paper in the collection.

The ordinary ReLU/softplus and tanh online lower bounds have separate formalizations, described below. Start with the theorem table for the original five results, the coverage sections for extensions, or [reproduction instructions](#reproduce-the-checks) to run the checks.

## Original five learning theorems

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
closed theorems in [CheckConfidence.lean](CheckConfidence.lean). For the gamma > 1
paper this formalizes the confidence remark after its Theorem 4.3. The strong-prior
paper states no `>2/3` guarantee, so its confidence version is a Lean-side
corollary. Prediction is not defined by the sign of the posterior mean.

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

The five original main proofs discharge the Gaussian mass and width limits, compression, counting, concentration, spectral, sampling, conditioning, and scalar estimates they use. The subcritical proof includes all tied minimum-energy functions when gamma is positive, global-margin Gaussian conditioning when gamma is zero, and the Gaussian sign posterior when gamma is negative.

Some proofs use different sufficient estimates from the manuscripts. The gamma > 1 proof uses a finite matrix grid and an orthogonal energy witness in place of the paper's sharper singular-value tail lemma, while proving the same existential-polynomial learning statement. The subcritical proof uses different numerical constants and explicit buffered confidence thresholds.

The original robustness proof uses a conservative Pinsker-and-energy argument in place of the manuscript's sharper transport estimate. [RobustCompressionExplicitDegree.lean](NeuralGeneralization/RobustCompressionExplicitDegree.lean) checks degree **10974** for that proof's finite-class sample-budget formulas. It is a sufficient envelope, not an optimality claim. The separate improved-support proof below now verifies the paper's literal formulas and degree **46**.

`CheckMain.lean` and `CheckRobust.lean` certify the five exact main statements. Additional theorems have their own checks and correspondence records; the original five-statement checks alone do not certify every appendix, empirical certificate, or auxiliary constant. The [current coverage inventory](review/coverage-extension-2026-10-30.txt) supersedes historical exclusions in the [original inventory](review/formal-coverage-inventory.txt).

The Gaussian quadratic-form implementation adapts locally included lemmas from this repository's Paulsen project, with attribution in the source. Those lemmas are rechecked here; an earlier review is not a proof assumption.

## Second-batch and conditional learning results

The ten second-batch papers extend the activation classes, prior laws, input domains, polynomial budgets, online upper bounds, and converses. [BatchTwoMain.lean](NeuralGeneralization/BatchTwoMain.lean) is their main entry point; [BatchTwoAudit.lean](NeuralGeneralization/BatchTwoAudit.lean) checks endpoint axioms. The [second-batch table](review/BatchTwo-coverage.md) maps papers to theorems, and the [completed sixteen-paper review](review/coverage-completion-2026-11-15.txt) records the subsequent coverage extensions.

| Area | Verified coverage in the completed review |
| --- | --- |
| Lipschitz activations and ReLU/GELU | Actual strong-prior and uniform-scale learning, GELU and confidence consequences; polynomial-depth learning under the stated merging support and counted constant-wire convention |
| Improved original support and shallow networks | Literal original-support learning budgets described below; all three shallow numerical budgets and their norm/resource consequences |
| Online upper bounds | Actual posterior and sampled mistakes under uniform permutation and infinite uniform IID inputs; confidence/majority conversions, general finite-loss comparison, nonuniform IID ordering, and the stated ReLU/GELU and signed/balanced tanh supports |
| Circuit and neural converses | Executable prefix serialization, parsing and prior law; bounded-gain and distinct strict-operator-norm-support neural learners, with the stated order of limits |
| Non-Gaussian priors | Actual independent coordinate laws with the stated two-sided envelopes, and quadratic log-tail limits and rate |
| Continuous domains and depth lower bounds | Regression on the stated laws, actual minimizers and posterior mixtures, iterated Gaussian limits, smooth-density variants, literal width-independent ceiling, finite-scale bounds, and spherical score-to-sign learning |

The [conditional nonpolynomial-learning theorem](../works-in-progress/conditional-nonpolynomial-learning/lean/README.md) assumes nonuniform `P/poly ≠ TC¹`. It rules out a universal sample bound polynomial jointly in input dimension, teacher width and teacher depth, independent of learner width, for the original Gaussian tanh learner at the prescribed positive scales. Its proof includes the actual posterior circuit ceiling and the finite circuit-class reduction; no additional analytic premise remains. The completed review includes the fixed hard family, zero samples, and arbitrary-confidence posterior ceiling. Its separate verification package records the exact statements and build evidence.

The protocols in this table remain distinct: IID and permutation bounds do not assert arbitrary-adversarial-order bounds, and width-first and scale-first limits cannot be interchanged. The later online lower bounds below have their own coverage records.

## Literal compression and learning budgets

The [literal target and learning correspondence](review/manuscript-literal-target-correspondence-2026-11-15.txt) connects the improved original-support paper's exact target-cylinder cost `D_*` to its finite-grid log-cardinality bound `J`. The proof includes actual Gaussian target mass, hidden histories, Gram concentration, clipping, importance readout, small- and large-width compression, and the paper's numerical resource allocations. No target-mass or cost-comparison hypothesis remains in the circuit theorem.

For the original robustness-restricted posterior and its optional global-margin variant, one measurable IID sample event of probability at least `1−δ` works for every `N≥C` and `0<t≤1`, where `σ=t/√N`. The posterior denominator is positive and Gibbs test-margin risk is at most `ε` whenever

```text
16 * (J + log(1/δ)) ≤ n * ε.
```

Training uses strict signed margin `1/2`; test errors use signed output at most `1/4`. The ordinary model imposes no clean margin on unobserved inputs. The generic confidence lemmas give failure mass at most `3ε` at confidence `2/3`, and `2ε` at confidence `1/2`.

For these same literal formulas, the sufficient sample budget is `O(C^6 log^13(2+C))` with `d,L,c,ε,δ` fixed, and at most `A*S^46` for a universal `A`, where

```text
S = 2 + d + L + C + c + 1/c + 1/ε + log(1/δ).
```

The [15 November verification record](review/verification/coverage-manuscript-literal-target-2026-11-15/README.txt) identifies the checked source snapshot, endpoints and compiler/axiom checks. Its historical predecessors retain the numerical gaps that were open at their dates.

<a id="coverage-continuation-2-november-2026"></a>
## Unlabeled pools, neighborhoods, and online upper bounds

[RobustCountablePools](NeuralGeneralization/RobustCountablePools.lean) proves the prescribed countable-family unlabeled-pool guarantee with one common labeled event and exact per-learner unlabeled budgets. [RobustInputNeighborhood](NeuralGeneralization/RobustInputNeighborhood.lean) and [RobustNeighborhoodRadius](NeuralGeneralization/RobustNeighborhoodRadius.lean) prove real-input neighborhood transfer and its exact readout-noise limit. The completed coverage review includes the finite/shared-pool protocols and hidden-only and valid-hidden-state variants.

[BatchTwoOnlineFiniteLossCover](NeuralGeneralization/BatchTwoOnlineFiniteLossCover.lean) proves the general finite-loss comparison. [BatchTwoOnlineMergingSampledIID](NeuralGeneralization/BatchTwoOnlineMergingSampledIID.lean) proves actual sampled-mistake expectation and sharp tails for the merging-supported ReLU Gaussian learner under permutation and infinite uniform IID inputs, using the original polynomial-depth budget. These statements use posterior parameter draws and handle repeated queries and infinite horizons. The completed online coverage includes the stated signed/balanced tanh supports and exact strong-prior and finite-variance ReLU resource budgets; it does not convert these protocols into arbitrary-adversarial-order guarantees.

<a id="localized-union-coverage-2-november-2026"></a>
## Localized robustness and exception families

[RobustLocalizedPolynomial](NeuralGeneralization/RobustLocalizedPolynomial.lean) proves the exact union-conditioned Gaussian guarantee: risk at most `ρ+ε`, universal polynomial labeled complexity, logarithmic-family validation complexity, and one event for every eligible width and scale. It includes the same-input corollary. The strict training-margin likelihood applies at exceptional inputs too. [RobustLocalizedConditioning](NeuralGeneralization/RobustLocalizedConditioning.lean) proves equality with two-stage prior-then-likelihood conditioning.

[FiniteUnionEntropy](NeuralGeneralization/FiniteUnionEntropy.lean) proves the component KL identity and `log M` overhead. The learning proof uses a small-component cutoff and the actual Gaussian compressor; it does not assume every exception component contains a target cylinder. [RobustLocalizedPilot](NeuralGeneralization/RobustLocalizedPilot.lean) handles independent finite-valued pilot selection. [LocalizedFamilyCounting](NeuralGeneralization/LocalizedFamilyCounting.lean) and [LocalizedCubeBalls](NeuralGeneralization/LocalizedCubeBalls.lean) give the VC-family and cube-centered ball description bounds. The completed coverage review includes the further geometric exception counts.

<a id="two-margin-coverage-3-november-2026"></a>
## Two-margin learning

[TwoMarginMain](NeuralGeneralization/TwoMarginMain.lean) proves the numerical two-margin replacement theorem with the original universal polynomial envelope, all-width/all-scale sample event, actual Gaussian posterior, optional global clean-margin restriction, and confidence bound. [TwoMarginLocalizedPolynomial](NeuralGeneralization/TwoMarginLocalizedPolynomial.lean) proves the localized union and same-input counterparts; independent pilot selection and exact two-stage conditioning are formalized too.

[MarginBandScore](NeuralGeneralization/MarginBandScore.lean) and [MarginBandSupport](NeuralGeneralization/MarginBandSupport.lean) prove the exact margin-band formula, contraction through clipping, support inclusions, endpoint interval certificate, and strict-weakening examples. The later [general two-margin verification](review/verification/coverage-general-two-margin-2026-11-05/README.txt) covers arbitrary rounding error with positive residual gap and a universal polynomial bound. The [3 November evidence](review/verification/coverage-two-margin-2026-11-03/record.json) preserves the numerical-specialization checks.

<a id="monotone-score-coverage-3-november-2026"></a>
## Monotone score transforms

[MonotoneScorePolynomial](NeuralGeneralization/MonotoneScorePolynomial.lean) proves the arbitrary monotone-score-transform theorem with one universal polynomial chosen before the transform and explicit inverse-gap dependence. It retains the actual Gaussian posterior, strict training margin, test margin, optional global separation, and all-width/all-scale confidence guarantee. [MonotoneScoreLocalizedPolynomial](NeuralGeneralization/MonotoneScoreLocalizedPolynomial.lean) proves the localized union and same-input variants, with exact conditioning and independent-pilot extensions in the corresponding modules.

[MarginBandMinimality](NeuralGeneralization/MarginBandMinimality.lean) proves full-gap minimality and contraction. The [margin-band specialization](NeuralGeneralization/MarginBandTransformCorollaries.lean) has exactly the original compression resources and finite-class budget. [RobustTargetNoisyMargin](NeuralGeneralization/RobustTargetNoisyMargin.lean) supplies the stronger cylinder property used for unchanged target mass. The [3 November verification record](review/verification/coverage-score-transforms-2026-11-03/record.json) records this proof stage; the completed inventory gives the current coverage status.

## Adversarial online lower bound for ordinary ReLU

The [ReLU online-mistake paper](../works-in-progress/online-mistakes/isotropic-relu-allwidth/paper.pdf) has a complete formalization of its main theorem. [`OnlineLowerReluMain.lean`](NeuralGeneralization/OnlineLowerReluMain.lean) proves the exact [`ReLUConcreteMainStatement`](NeuralGeneralization/OnlineLowerReluConcreteStatement.lean), then its `exp(Ω(√C))` resource corollary. [`CheckOnlineLowerRelu.lean`](CheckOnlineLowerRelu.lean) checks the exact theorem types and dependency axioms. [Paper-to-Lean correspondence](review/OnlineLowerRelu-main-correspondence.md) · [Analytic correspondence](review/OnlineLowerRelu-analytic-correspondence.md).

This is a lower bound on cumulative mistakes along a fixed nonrepeating input order, with a large calibration history. It uses the actual independent Gaussian prior, the initial strict margin at every Boolean input, and subsequent conditioning on Boolean labels. The permutation is fixed before width and scale; the prior scale tends to zero at each fixed width above the explicit threshold. The formalization includes all nonlinear competitors and posterior mixtures. It assumes no energy gap, neuron norm bound, or posterior-concentration theorem: these are proved in its dependency chain.

The exact parameters are `R=2^1024`, `m=6k+4`, `d=(8k+4)(2R+4)`, teacher width `C=3(m+1)(d+1)`, sufficient learner width `N₀=2^(m+d+1)`, and `2^(k−1)` designated mistakes. The teacher has margin at least one and coefficients bounded by `C`. The target has a NAND circuit with at most `17d+5` gates. At every fixed `N≥N₀`, correct-label confidence tends to zero on every designated round; at sufficiently small positive scale the same posterior gives all designated sampling errors with arbitrarily high probability, majority errors, and `>2/3` confidence failures.

The standard-softplus extension has a complete proof in [`OnlineLowerSoftplusMain.lean`](NeuralGeneralization/OnlineLowerSoftplusMain.lean), retaining the same target and permutation as ReLU. The [arbitrary-positive-layer-variance ReLU theorem](NeuralGeneralization/OnlineLowerReluLayerVarianceMain.lean) is also proved. [ReLU/softplus full-paper coverage](review/OnlineLowerRelu-full-paper-coverage.md) · [Tanh full-paper coverage](review/OnlineLowerTanh-full-paper-coverage.md). These inventories distinguish complete main theorems from standalone appendix coverage. The ordinary-tanh main theorem has its own complete proof, described below.

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

## Reproduce the checks

The project pins Lean 4.32.0 and mathlib revision
`81a5d257c8e410db227a6665ed08f64fea08e997`; all dependency revisions are in
[lake-manifest.json](lake-manifest.json). Run the following from this `lean/` directory with the pinned toolchain installed:

```sh
lake exe cache get
lake build
lake env lean Audit.lean
lake env lean CheckMain.lean
lake env lean CheckParity.lean
lake env lean CheckRobust.lean
lake env lean CheckConfidence.lean
lake env lean CheckCoverageExtensions.lean
lake env lean NeuralGeneralization/BatchTwoAudit.lean
```

The cache command is optional. Without access to the official cache, Lake can
build the imported mathlib sources. `Audit.lean` checks every imported project
theorem's axiom closure and reports exact main-proof coverage. `CheckMain.lean`
requires the four earlier exact types; `CheckRobust.lean` requires the fifth. Both reject unexpected axioms, including
`sorryAx`. `CheckCoverageExtensions.lean` checks the additional named endpoints, and
`BatchTwoAudit.lean` audits the second-batch endpoints. A component compilation
alone does not pass these checks. The conditional theorem uses its
[separate project and verification procedure](../works-in-progress/conditional-nonpolynomial-learning/lean/README.md).

For an independent rebuild of the original five results and their supplements,
without reusing project object files:

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

## Reading historical source comments

The following source-comment discrepancies were recorded on 10 November 2026. The files are hash-recorded in earlier audits and retain their historical wording; the theorem declarations establish the proof scope.

- `CheckConfidence.lean` calls both strict-confidence corollaries manuscript statements. The gamma > 1 corollary formalizes the remark after Theorem 4.3; the strong-prior paper states no `>2/3` guarantee, so that confidence result is a Lean-side corollary.
- `OnlineLowerStatements.lean` and `OnlineLowerTanhConcreteStatement.lean` describe tanh propositions as unproved targets. The current main theorems prove `TanhConcreteMainStatement`, `TanhPathLogarithmicRailStatement`, and `TanhSquareRootLogLossStatement`. Three earlier targets have no theorem of their stated type: the weaker `TanhSixthRootLogLossStatement` follows immediately from the square-root-log result, while `TanhEighthRootStatement` and `TanhLogarithmicRailStatement` fix different dimension exponents and are not derived.
