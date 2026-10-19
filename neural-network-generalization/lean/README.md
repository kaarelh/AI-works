# Lean proofs of the five main learning results

This project proves the five main learning statements for the actual finite
Gaussian neural-network model. The proofs use only Lean's standard axioms
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

The target is a concrete [layered Boolean circuit](NeuralGeneralization/RobustCircuit.lean) of width `C`, with its constant wire and compilation resources counted. Lean reserves one constant-true wire at every stage, while the manuscript counts a constant wire only where a gate needs one. For `C >= 2` the two conventions compute the same functions; the only manuscript case not covered is learner width `N = 1` for width-one targets other than the constant `+1`. It is not an arbitrary small analog neural circuit. There exist universal constants `A > 0` and a natural-number exponent `m`, chosen before dimension, depth, target circuit, robustness calibration, and statistical parameters, giving a bound

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
