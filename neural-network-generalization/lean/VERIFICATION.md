# Verification record

**PASS — 18 October 2026.** All **five exact main learning theorems**, the parity supplement, and the aggregate axiom audit pass in an independent project-source rebuild. The new result is the robustness-restricted polynomial-depth theorem.

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

## Robustness theorem: scope and correspondence

The new theorem concerns the actual finite Gaussian network conditioned on the stated internal-noise robustness event, followed by signed training output strictly above `1/2`. It does not impose a clean-output margin at every input before training. Test risk uses margin `1/4`; the final conclusion includes the strict `>2/3` posterior-confidence rule.

One universal polynomial is chosen before dimension, circuit width, depth, calibration, and statistical parameters. For arbitrary input distributions, one high-probability sample event works simultaneously for every width above the **concrete layered Boolean-circuit width**, and every positive Gaussian scale satisfying `N*sigma^2 <= 1`. Thus it covers the specified family at every `gamma >= 1`. Constant wires and circuit compilation resources are counted. It is not an unconditional theorem for all small analog deep networks.

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

The destination must not already exist. `--main all` now checks all five main theorems; `--main robust` checks the robustness theorem alone. The supplement command expects the all-main rebuild. The [procedure](review/verification/rebuild-procedure.txt) explains the trust boundary and optional `--fresh-dependencies` mode. The [Lean README](README.md) explains the model conventions and coverage.

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
