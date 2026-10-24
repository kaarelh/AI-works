# Verification record

## Independent statement review and rebuild, 24 October 2026

A second, independent review of all fifteen main statements found that each captures its paper's main theorem; three red-team agents could not break any of them. The import closure of `NeuralGeneralization` and `NeuralGeneralization.BatchTwoAudit` was rebuilt, or replayed from verified traces, from the current sources against the existing pinned mathlib build: 4,617 jobs, no errors, and all five gates pass. Project modules outside that closure, such as the online merging extension, were not built. The 69 batch-two axiom reports list only the standard axioms. Several documentation overstatements were corrected; no Lean source changed. [Review record](review/statement-review-2026-10-24/README.md).

## Statement correspondence recheck, 23 October 2026

The [fifteen-paper statement audit](review/statement-audit-2026-10-23/README.md) compares the original five and second-batch ten main claims with their actual Lean definitions and theorem types. The model, probability, prediction and quantifier checks found no further substantive mismatch after the following qualifications:

- The original robust and improved original-support formalizations count a reserved constant wire at every stage. Width-one targets other than constant `+1` under the manuscripts' prose convention need formal width two; those learner-width-one cases are outside certification.
- The ReLU/GELU polynomial-depth manuscript now explicitly requires the constant-one wire at every stage that its formal circuit definition already requires. Without it, the width-one ReLU claim would be false.
- The previously recorded numerical and ancillary exclusions remain, notably the improved original-support paper's separate `16/ε` allocation.

All 1,313 recorded Lean source/configuration files match the earlier fresh-build snapshot. Rerun theorem-type, confidence, parity and axiom checks passed; the aggregate audit again checks 14,578 proved declarations using only the three standard axioms. This is a semantic source review and a gate rerun using the existing checked build, **not another fresh rebuild**. [Machine recheck record](review/statement-audit-2026-10-23/kernel-recheck.json). No Lean theorem or proof was changed.

## Second formalization batch, 23 October 2026

**PASS.** A fresh build of all 1,304 library modules completed successfully (4,640 build jobs). All seven final gates passed. The aggregate axiom audit checked 14,578 proved project declarations; the source comparison found zero differences across 1,313 source/configuration files.

The main statements of ten additional papers have closed proofs, alongside the original five. [Theorem correspondence and exclusions](review/BatchTwo-coverage.md) · [Entry point](NeuralGeneralization/BatchTwoMain.lean) · [Axiom audit](NeuralGeneralization/BatchTwoAudit.lean).

The second batch covers unified Lipschitz activations; polynomial-depth ReLU/GELU learning under population merging; improved polynomials under the original robust support; the shallow theorem; total online mistakes; circuit and gain-restricted neural converses; non-Gaussian priors; continuous-domain regression; and exponential continuous-regression depth dependence. The latter includes actual finite `γ>1` posteriors with a polynomial sufficient width and width-first `γ=1` posteriors, alongside the strong-prior limit.

The main axiom audit accepts only `propext`, `Classical.choice` and `Quot.sound`. `Audit.lean` additionally checks every imported proved project declaration and preserves the original five exact-type gates. No main endpoint leaves target mass, concentration, compression, covariance approximation or posterior normalization as an assumed analytic conclusion.

**Scope matters.** The improved original-support paper's headline theorem, sixth-power width rate and degree-46 envelope are checked; its separate printed numerical `16/ε` allocation is not. The online paper's three boxed neural budgets are checked, while some optional unboxed extensions are outside coverage. Ancillary classification, iterated-limit, LDP and smooth-density claims in the continuous papers are not all certified. The coverage table and per-paper correspondence records state these exclusions.

Fresh verification uses Lean 4.32.0 and pinned mathlib revision `81a5d257c8e410db227a6665ed08f64fea08e997`. It starts with an empty project build directory and copies no project OLeans. The dependencies use the existing mathlib build cache: this is a fresh **project-source** rebuild, unlike the historical run below which rebuilt mathlib too. Reproduction commands are:

```sh
lake build NeuralGeneralization NeuralGeneralization.BatchTwoAudit
lake env lean Audit.lean
lake env lean CheckMain.lean
lake env lean CheckRobust.lean
lake env lean CheckParity.lean
lake env lean CheckConfidence.lean
```

The release additionally builds every included library source module, including auxiliary modules outside the main import closure. Source checksums, build output, axiom output and check results are recorded in [the second-batch verification directory](review/verification/batch-two-2026-10-23/). The original five proofs, theorem types and historical audits are retained below.

## Original batch verification record

**PASS — 18 October 2026.** All **five exact main learning theorems**, the parity supplement, and the aggregate axiom audit pass in an independent project-source rebuild. The new result is the polynomial-depth generalization theorem under a robustness restriction.

## Independent full-source rebuild, 19 October 2026

During the [collection review of 19 October](../verification/review-2026-10-19.md), the project was rebuilt from a fresh checkout with the pinned Lean 4.32.0 release and mathlib revision `81a5d257c8e410db227a6665ed08f64fea08e997`. No mathlib cache was used, so every imported mathlib module was also compiled from source. The build succeeded, and `Audit.lean` (7,202 declarations, 5 / 5 main results), `CheckMain.lean`, `CheckParity.lean`, and `CheckRobust.lean` all pass. The Lean library sources are unchanged from the snapshot recorded below.

The same run checks a new supplement, [CheckConfidence.lean](CheckConfidence.lean). It proves the strict `>2/3` confidence versions of the strong-prior and gamma > 1 theorems as closed corollaries, using only the standard axioms. Like `CheckParity.lean`, it is not imported by the library. Outputs and environment details are in [review/verification/review-2026-10-19/gates.txt](review/verification/review-2026-10-19/gates.txt).

## Current exact proof targets

| Proposition | Closed theorem |
| --- | --- |
| `MainStatements.StrongPriorGeneralization` | `MainProofs.strongPrior` |
| `MainStatements.AboveMeanFieldGeneralization` | `MainProofs.aboveMeanField` |
| `MainStatements.MeanFieldGeneralization` | `MainProofs.meanField` |
| `MainStatements.SubcriticalExponentialLowerBound` | `MainProofs.subcriticalExponential` |
| `RobustMainStatements.RobustPolynomialDepthGeneralization` | `RobustMainProofs.robustPolynomialDepth` |

The first four propositions are in [Statements.lean](NeuralGeneralization/Statements.lean); the fifth is in [RobustStatements.lean](NeuralGeneralization/RobustStatements.lean), proved by [RobustMain.lean](NeuralGeneralization/RobustMain.lean). The gates require theorem declarations of exactly these types and reject every axiom except `propext`, `Classical.choice`, and `Quot.sound`. An extra unproved compression premise, `sorryAx`, or a new analytic axiom would fail.

The [new exact-type audit](review/verification/robust-2026-10-18/ExactMainAudit.log) passes for all five. [CheckMain.lean](CheckMain.lean), [CheckRobust.lean](CheckRobust.lean), and [CheckParity.lean](CheckParity.lean) also pass. The [aggregate audit](review/verification/robust-2026-10-18/Audit.log) checks **7,202 proved project declarations** and reports **5 / 5** exact main results.

<a name="robustness-theorem-scope-and-correspondence"></a>

## Generalization under a robustness restriction: scope and correspondence

The new theorem concerns the actual finite Gaussian network conditioned on the stated internal-noise robustness event, followed by signed training output strictly above `1/2`. It does not impose a clean-output margin at every input before training. Test risk uses margin `1/4`; the final conclusion includes the strict `>2/3` posterior-confidence rule.

One universal polynomial is chosen before dimension, circuit width, depth, calibration, and statistical parameters. For arbitrary input distributions, one high-probability sample event works simultaneously for every width above the **concrete layered Boolean-circuit width**, and every positive Gaussian scale satisfying `N*sigma^2 <= 1`. Thus it covers the specified family at every `gamma >= 1`. Constant wires and circuit compilation resources are counted. It is not an unconditional theorem for all small analog deep networks.

Specifically, `LayeredBooleanCircuit` reserves one constant-`+1` wire at every stage, including the final stage. The paper's nonconstant width-one examples need formal width two, as its introduction acknowledges. Its learner-width-one cases are not certified by this theorem. See the [fresh correspondence review](review/statement-audit-2026-10-23/original-lower-robust.md).

All ingredients of that main statement are discharged: actual target prior mass, posterior positivity and relative entropy, small- and large-width compression, original-network histories and noise costs, finite coding, and statistical bounds. The proof uses a more conservative Pinsker-and-energy construction than the manuscript's sharper transport estimate. A separate imported [degree calculation](NeuralGeneralization/RobustCompressionExplicitDegree.lean) verifies a sufficient exponent **10974** for its sample-budget formulas; neither this exponent nor the large constants are claimed to be optimal or practical.

The manuscript's optional additional all-input-margin learning variant is not the exact main learning proposition, although its target-mass ingredient is also formalized. Other robustness variants, stronger constants, empirical certificates, and side manuscripts are not automatically certified by the main gate. Independent semantic review checked the correspondence between the formal model and manuscript, separately from Lean's kernel checking:

- [Final robustness semantic review](review/robust-main-semantic-review.txt).
- [Compression construction audit](review/compression-formalization-audit.txt).
- [Earlier four-main coverage inventory](review/formal-coverage-inventory.txt).

## Independent source rebuild on 18 October

The final isolated workspace began with **no project object cache**. Verification ran in two phases: a first source rebuild of the shared proof components, then a source-only refresh including the completed main assembly and final checks in that same isolated workspace. No project `.olean` was copied into either phase. The final import closure contains **614 project source modules**. The final source/configuration/gate snapshot has 621 files; its original, copied, and post-check SHA-256 maps agree.

External mathlib/support-package caches were shared. All **13,170** existing external Lean artifacts were hashed before and after and remained byte-identical. Pinned package revisions and clean tracked sources were checked; Lean/Lake executable hashes are recorded. This is an independent rebuild of the project's proofs, **not** a fresh source rebuild of all of mathlib.

Evidence is in [review/verification/robust-2026-10-18/](review/verification/robust-2026-10-18/):

- [result.json](review/verification/robust-2026-10-18/result.json): both builds, all five gates, source/dependency stability, and final PASS.
- `phase-a-build.log`, `phase-b-build.log`: the two project-source builds.
- `ExactMainAudit.log`, `CheckMain.log`, `CheckRobust.log`, `CheckParity.log`, `Audit.log`: final checks.
- `source-before.json`, `source-after.json`, `snapshot-after.json`: identical final source hashes.
- `phase-a-sources.json`, `phase-b-source-refresh.json`: initial sources and later source-only additions/changes.
- `dependencies-*.json`, `external-artifacts-*.json`, `toolchain.json`: dependency and executable provenance.
- `two-phase-finish.py`: the recorded second-phase driver, using the development workspace paths. For an ordinary fresh reproduction, use the portable procedure below instead.

The published mathematical sources are byte-identical to the final checked snapshot. The earlier four main mathematical developments are unchanged; the aggregate import and audit now include the fifth theorem.

## Reproduce the current snapshot

With the pinned toolchain and dependencies installed:

```sh
lake build
lake env lean CheckMain.lean
lake env lean CheckRobust.lean
lake env lean CheckParity.lean
lake env lean Audit.lean
```

For a new source-only project rebuild, without project object reuse:

```sh
python3 review/verification/rebuild_main.py \
  --main all --destination /tmp/neural-lean-independent-check
python3 review/verification/verify_supplement.py \
  --destination /tmp/neural-lean-independent-check
```

The destination must not already exist. `--main all` now checks all five main theorems; `--main robust` checks the polynomial-depth generalization theorem alone. The supplement command expects the all-main rebuild. The [procedure](review/verification/rebuild-procedure.txt) explains the trust boundary and optional `--fresh-dependencies` mode. The [Lean README](README.md) explains the model conventions and coverage.

---

# Historical verification record — 16 October 2026

The following record is retained for the original four-main snapshot. Its module counts and manuscript hashes describe that earlier release; the current five-main verification is above.

**PASS — 16 October 2026.** All four exact main theorem checks, the independent
source rebuild, source/dependency hash checks, and the parity supplement passed.

The checked scope is the four main learning theorems in
[Statements.lean](NeuralGeneralization/Statements.lean), plus the explicit
polynomial-complexity parity construction and its lower-bound corollary.
The manuscript snapshot is the collection at commit
`7d256b846523529482c8b65c468667ee0b5ec9b1`; manuscript hashes are recorded in
[review/source-manifest.json](review/source-manifest.json).

## Exact proof targets

| Proposition | Theorem |
| --- | --- |
| `MainStatements.StrongPriorGeneralization` | `MainProofs.strongPrior` |
| `MainStatements.AboveMeanFieldGeneralization` | `MainProofs.aboveMeanField` |
| `MainStatements.MeanFieldGeneralization` | `MainProofs.meanField` |
| `MainStatements.SubcriticalExponentialLowerBound` | `MainProofs.subcriticalExponential` |

The publication gate requires theorem declarations whose types are exactly
these propositions. It checks their complete axiom dependencies and rejects
anything beyond `propext`, `Classical.choice`, and `Quot.sound`.
The statements are transparent proposition definitions, not project axioms.

`ParityNetwork.parity_realizes_every_depth` and
`ParityNetwork.exists_parity_complexity` prove actual bounded-weight tanh
complexity at most `32*(d+1)^2`. `MainProofs.subcriticalSmallNetworkLowerBound`
combines this with the exponential lower bound under the same depth and
posterior conventions. The separate [CheckParity.lean](CheckParity.lean) gate
checks this supplement.

## Independent rebuild

The final verification uses a new directory with **no project object cache**.
It copies all 414 transitive project modules needed by the four main proofs,
rebuilds them with dependency-aware Lake commands, and checks all exact types
and axiom closures. It records source hashes before and after, checks the
copied snapshot against the working source, and verifies pinned external
package revisions and clean tracked package sources.

External mathlib/support-package objects may be reused in this run. Their
13,126 existing Lean artifacts are individually hashed before and after;
none may change unnoticed. This is a clean rebuild of the project proofs,
not a claim that every external mathlib theorem was rebuilt in this final run.
The reproducible script supports `--fresh-dependencies` for that additional
check. Toolchain executable hashes and package revisions are recorded too.

A preliminary source rebuild successfully checked all four proofs but refreshed
28 external objects belonging to seven pinned mathlib modules. It therefore
failed the stricter cache-stability check. The final evidence comes from a
second new project directory after that cache refresh; no project objects were
carried over.

The parity supplement adds four source modules. They are rebuilt in the same
isolated directory against the freshly rebuilt main proofs. The final
aggregate axiom audit covers **5,040 proved project declarations**. No
mathematical source is altered between verification and publication.

Final evidence is under [review/verification/final/](review/verification/final/):

- `result.json`: combined main rebuild, exact-type gate, and snapshot status.
- `build.log` and `audit.log`: dependency rebuild and four exact theorem checks.
- `source-before.json`, `source-after.json`, `snapshot-after.json`: checked sources.
- `dependencies-before.json`, `dependencies-after.json`: pinned package state.
- `external-artifacts-before.json`, `external-artifacts-after.json`: external objects.
- Supplement and aggregate logs: the parity construction, `Audit.lean`, and
  `CheckMain.lean` on the isolated build.

See the [rebuild procedure](review/verification/rebuild-procedure.txt) and
[script](review/verification/rebuild_main.py) to reproduce the main checks.
The [supplement verifier](review/verification/verify_supplement.py) reproduces
its isolated rebuild and all public gates after the main verifier passes.
For the ordinary project build, also run `lake env lean CheckParity.lean`.

## Mathematical correspondence and limits

Independent agent reviews compared the formal model and final proof assemblies
with the main manuscripts. No major mathematical error was found in the
reviewed main learning claims. The final subcritical review checks all three
gamma regimes, the common constants chosen before gamma, all sample sizes
including zero, actual global-margin conditioning, tied minimizers, and the
buffered transfer to the strict two-thirds confidence rule.

- [Subcritical semantic review](review/subcritical-main-semantic-review.txt)
- [Above-mean-field semantic review](review/above-meanfield-semantic-review.md)
- [Mean-field semantic review](review/meanfield-semantic-review.txt)
- [Full coverage inventory](review/formal-coverage-inventory.txt)

The formalization sometimes replaces manuscript estimates with different
sufficient estimates. The gamma > 1 proof uses an elementary finite matrix
grid instead of the paper's sharp singular-value tail. The parity construction
uses a linear slope and a quadratic complexity bound instead of optimized
logarithmic weights. These changes preserve the main conclusions.

This verification does not cover every auxiliary equivalence, optimized
constant, general circuit simulation, historical manuscript, or side result.
In particular, the stronger sparse-parity target remains open. The coverage
inventory identifies these exclusions; machine checking does not replace the
separate task of checking that a theorem's formal model expresses its intended
mathematical claim.
