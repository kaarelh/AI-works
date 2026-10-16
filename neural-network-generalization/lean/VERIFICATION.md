# Verification record

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
