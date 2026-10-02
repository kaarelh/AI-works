# Verification report

Verified 2 October 2026 with Lean 4.32.0 and mathlib v4.32.0 (commit `81a5d257`).

## Build

This directory was built from scratch with prebuilt mathlib. `lake build` completed **3,925 jobs**. The 215 project modules took about 12 minutes on 4 cores. `Audit.lean` printed (`verification/build-audit-output.txt`):

```text
'Paulsen.Paper.thm_main' depends on axioms: [propext, Classical.choice, Quot.sound]
'Paulsen.Paper.thm_projection' depends on axioms: [propext, Classical.choice, Quot.sound]
Audited 3708 Paulsen theorems. Only propext, Classical.choice, and Quot.sound occur.
The final proofs depend on 1782 project declarations, including all 82 required paper statements; no worse-constant library lemma is used.
Build completed successfully (3925 jobs).
```

## Statements

The final theorems are `Paulsen.Paper.thm_main : Paulsen.SharpPaulsenBound` and `Paulsen.Paper.thm_projection : Paulsen.SharpProjectionBound`. `Audit.lean` checks both by `example`. `SharpPaulsenBound` (in `Paulsen/Definitions.lean`) is the real linear Paulsen bound. One constant C > 0 is chosen before `n`, `d`, `ε` and `U`. The output `W` satisfies `WᵀW = 1`, `‖wᵢ‖² = d/n` and `Σᵢⱼ (Uᵢⱼ − Wᵢⱼ)² ≤ C ε d`.

`IndependentCheck.lean` restates both theorems in plain Mathlib vocabulary, without any project definitions, and derives the restatements from them (`verification/independent-check-output.txt`):

```text
'paulsen_independent' depends on axioms: [propext, Classical.choice, Quot.sound]
'paulsen_projection_independent' depends on axioms: [propext, Classical.choice, Quot.sound]
```

## Faithfulness to the paper

`Paulsen/Paper/` contains a statement for every numbered item of the paper:

- definitions, lemmas, theorems, corollaries and propositions;
- every numbered display that makes a claim;
- every remark with quantitative content;
- the explicit constant claims inside the long proofs.

Every explicit constant of the text appears verbatim, and the docstrings quote the TeX. Constants the paper asserts only to exist are existential in the statements. The proofs exhibit admissible values:

| Constant | Value | Where |
|---|---|---|
| C_𝓜 | 192 | many-row seed |
| h, t₀ | 1/300, 1/30 | many-row seed |
| A_{η'} | 10¹²/η'² | sample lemma |
| C_E | 2·10⁹ | retraction lemma |
| B | an explicit formula | many-row seed |

The formalisation found no false constant. It made three implicit hypotheses explicit, and the paper now states each of them:

- u ≥ 0 in Lemma A.1(b) and (c);
- d² ≤ n in Lemma 4.2;
- ε₀ ≤ ½ in Theorem 5.1.

The Lean statements also assume n ≥ 1 where Lean's convention `log 0 = 0` would otherwise matter.

## Axioms, kernel replay and source scan

- **Axioms.** Every theorem in the `Paulsen` namespace (3,708 of them) was checked with `collectAxioms`. Only the three standard axioms occur, and there is no `sorryAx`.
- **Kernel replay.** `lake env leanchecker <module>` was run on each of the 215 project modules separately. All 215 passed (`verification/leanchecker-summary.txt`).
- **Source scan.** The sources contain no `sorry`, `admit`, `axiom`, `native_decide`, `implemented_by`, `extern`, `unsafe`, `opaque`, `ofReduceBool` or `debug.skipKernelTC`. They also contain no custom `macro`, `elab` or `syntax`, and no `run_cmd` outside `Audit.lean`. The only options set are `maxHeartbeats` (on 7 declarations) and `linter.unusedSectionVars`.

## Proof dependencies

`Audit.lean` traverses the proof terms of the two final theorems. The cone has 1,782 project declarations, and the audit checks two conditions on it.

**Required paper statements.** All 82 `lem_*`, `thm_*`, `cor_*`, `eq_*` and `prop_*` statements of `Paulsen.Paper` must be in the cone, except five that are listed in the file:

- the existential forms `lem_sample` and `lem_seed_graph`, whose explicit versions are used;
- `eq_S`;
- the definitional `eq_nearly_iff`;
- the summary `thm_main_constant_chain`.

The remarks (`rem_*`) are proved as standalone statements.

**Forbidden library lemmas.** The cone must not contain any library lemma whose constant is weaker than the paper's:

- `Linear.sharpPaulsenBound`, `Linear.manyRowBound`, `Linear.moderateParsevalBound` (the earlier route);
- `Linear.balancing_cost_barrier` and the Poisson-form `balancing_cost*` (cost 8);
- `Linear.IsSeed.hasCorrection` (4Θ);
- `euclideanQuadratic_stdGaussian_abs_tail` (1/16);
- `rowIndependentSeed_dense_core_failure_le` (17/20);
- `Smooth.expected_retainedTangent_expansion` (80/d);
- `Smooth.exists_moderateGaussianSample_with_cross` (128 / 600a / 2000a);
- `tangentQuadraticMean_conditioned_bias_le` (d²/n);
- `Linear.exists_drifted_retraction` (huge D only);
- `sharp_correction_of_poisson` and `BoundedPoissonSolvability`.

One library lemma with a weaker constant is reached: the 40000V² fourth-moment bound. It is used only to show that a moment function is integrable; the paper's bound 60/d² is proved separately and used.
