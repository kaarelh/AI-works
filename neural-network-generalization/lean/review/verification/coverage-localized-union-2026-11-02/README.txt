Verification of the localized-union coverage extension, 2 November 2026

This record verifies the new localized-union, same-input, independent-pilot,
finite-partition entropy and finite-family counting endpoints. It does not
claim complete coverage of all appendices; see the remaining-gap inventory.

Pinned Lean 4.32.0 and mathlib 81a5d257c8e410db227a6665ed08f64fea08e997.
Commands:
  lake build NeuralGeneralization
  lake env lean CheckMain.lean
  lake env lean CheckConfidence.lean
  lake env lean CheckParity.lean
  lake env lean CheckRobust.lean
  lake env lean Audit.lean
  lake env lean CheckCoverageExtensions.lean
  lake build NeuralGeneralization.BatchTwoAudit

All commands pass. The ordinary audit checks all proved project declarations
in the imported environment; the coverage gate checks 196 named endpoints,
including 27 additions. Only propext, Classical.choice and Quot.sound occur.
Build objects are incremental; this is not presented as a clean dependency
rebuild. New source hashes are recorded in record.json.

The source scan strips comments and strings before detecting proof bypasses.
It scanned 2,010 project Lean files with no flagged tokens. This supplements,
rather than replaces, the compiler and transitive axiom checks.

All 561 checked paper/source files are byte-identical to the starting commit.
The separate conditional package is unchanged; its prior fresh build is
linked in record.json, and is not presented as a new build here.

The main localized theorem has the manuscript's universal polynomial form.
Its proof uses a small-component cutoff and additive Hoeffding comparison,
not the sharper relative-Chernoff allocation inside the manuscript proof.
The original exact component-KL identity is separately checked. The actual
prior is conditioned on a union, not an independently normalized mixture.
