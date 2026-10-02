# Verification report

Verified 2 October 2026 with Lean 4.32.0 and mathlib v4.32.0 (commit `81a5d257`).

## Build

This directory was built from scratch with prebuilt mathlib. `lake build` completed **3,877 jobs**. Compiling the 167 project modules took about 8 minutes on 4 cores. The default target `Audit.lean` printed (`verification/build-audit-output.txt`):

```text
'Paulsen.Linear.sharpPaulsenBound' depends on axioms: [propext, Classical.choice, Quot.sound]
'Paulsen.Linear.sharpProjectionBound' depends on axioms: [propext, Classical.choice, Quot.sound]
Audited 2551 Paulsen theorems. Only propext, Classical.choice, and Quot.sound occur.
The final proof depends on 1635 project declarations; all required ones are present and no superseded endpoint is used.
Build completed successfully (3877 jobs).
```

## Statements

`Audit.lean` checks by `example` that the final declarations have the target types:

- `Paulsen.Linear.sharpPaulsenBound : Paulsen.SharpPaulsenBound`
- `Paulsen.Linear.sharpProjectionBound : Paulsen.SharpProjectionBound`

`Paulsen.Definitions` defines `SharpPaulsenBound` using only these objects:

- `Frame n d = Matrix (Fin n) (Fin d) ℝ`
- Parsevalness `UᵀU = 1`
- the quadratic-form near-Parseval condition
- row norms compared with the real quotient `d/n`
- the unnormalised squared Frobenius distance

One constant `C > 0` is chosen before `n`, `d`, `ε` and `U`.

`IndependentCheck.lean` restates both theorems in plain Mathlib vocabulary, with no `Paulsen` definitions: `Matrix.PosSemidef`, dot products, traces, `IsHermitian`, `IsIdempotentElem` and `Matrix.rank`. It derives the restatements from the two theorems. Output (`verification/independent-check-output.txt`):

```text
'paulsen_independent' depends on axioms: [propext, Classical.choice, Quot.sound]
'paulsen_projection_independent' depends on axioms: [propext, Classical.choice, Quot.sound]
```

## Axioms and kernel replay

- **Axioms.** Every theorem in the `Paulsen` namespace was checked with `collectAxioms`. Only `propext`, `Classical.choice` and `Quot.sound` occur, and `sorryAx` does not appear.
- **Kernel replay.** `lake env leanchecker <module>` was run on each of the 167 project modules separately. All 167 passed (`verification/leanchecker-summary.txt`).
- **Source scan.** The sources contain none of the following:
  - `sorry`, `admit`, `axiom`, `native_decide`, `implemented_by`, `extern`, `unsafe`, `opaque`, `ofReduceBool`, `debug.skipKernelTC`;
  - custom `macro`, `elab` or `syntax`;
  - `run_cmd` or `initialize` outside `Audit.lean`.

  The only options set are `maxHeartbeats` (8 declarations) and `linter.unusedSectionVars`.

## Proof dependencies

`Audit.lean` traverses the transitive proof dependencies of `Paulsen.Linear.sharpPaulsenBound` (1,635 project declarations). It **requires** the following:

- **Barrier-constant toolbox:** `HasBarrierBound`, `barrier_subset_bound`, `balancing_cost_barrier`, `core_barrier`, `block_barrier`, `indicator_exceptional_barrier`, `IsSeed.hasCorrection`.
- **Many-row seed:** `manyRowBound` with its centred remainder `tangentRemainder_centred_bound`, and `correction_of_exceptional_set_barrier`.
- **Drifted moderate seed:** `moderateParsevalBound`, `driftMean_diagonal`, `exists_drifted_retraction`.
- **Assembly:** the three-case assembly `low_density_small_error` / `sharpPaulsenBound_of_seeds` and the Hamilton–Moitra bound `quadratic_equalRowBound`.

It **rejects** the library's Poisson-constant endpoints (`BoundedPoissonSolvability`, `sharp_correction_of_poisson`, `balancing_cost`, `balancing_cost_target`, `correction_of_exceptional_set`) and the termwise remainder budget `tangentRemainderBudget`.

The import closure of `Paulsen.Linear.Main` is exactly the 167 modules shipped here; `verification/import_closure.py` recomputes it. It contains no second (correction) scaling, no block partition and no full-mean correction.

The closure does contain the library's concentration of the squared Gaussian graph and its matrix-series bound (`GaussianSchurConcentration`, `GaussianMatrixSeries`, `MatrixSeriesCovariance`). The formal proof uses them for the block gap of the moderate seed; see Appendix B(b) of the paper.
