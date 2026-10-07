# Verification report

Verified **7 October 2026**, after the trace-distance and ordinary-resolvent revisions, with Lean **4.32.0** and mathlib **v4.32.0** (`81a5d257c8e410db227a6665ed08f64fea08e997`).

## Build and final statements

`lake build` passed, including `Audit.lean`. The changed proof modules and their affected dependencies were rebuilt; this was an incremental build using the existing dependency cache, not a second clean installation. The final output is recorded in [`verification/revision-2026-10-07-build.txt`](verification/revision-2026-10-07-build.txt):

```text
'Paulsen.Paper.thm_main' depends on axioms: [propext, Classical.choice, Quot.sound]
'Paulsen.Paper.thm_projection' depends on axioms: [propext, Classical.choice, Quot.sound]
Audited 3307 Paulsen theorems. Only propext, Classical.choice, and Quot.sound occur.
The final proofs depend on 1774 project declarations, including all 81 required paper statements and all 12 required trace/resolvent declarations; no forbidden earlier route is used.
Build completed successfully (3886 jobs).
```

There were linter warnings about unused variables or simplification arguments, and no proof errors or proof placeholders.

The final statements are:

```lean
Paulsen.Paper.thm_main : Paulsen.SharpPaulsenBound
Paulsen.Paper.thm_projection : Paulsen.SharpProjectionBound
```

`SharpPaulsenBound` chooses one real constant `C > 0` before `n`, `d`, `ε` and the input frame. For every real ε-nearly ENP frame it gives a frame with `WᵀW = 1`, every squared row norm equal to `d/n`, and unnormalised squared Frobenius distance at most `C ε d`. The projection statement covers every real symmetric idempotent matrix of the stated rank.

## Independent restatement

`lake env lean IndependentCheck.lean` passed. It restates both results in plain Mathlib vocabulary, using positive semidefiniteness, dot products, traces, Hermitian matrices, idempotence and matrix rank. The statement types use no project definitions. Both restatements are derived from the paper theorems and have only the three standard axioms:

```text
'paulsen_independent' depends on axioms: [propext, Classical.choice, Quot.sound]
'paulsen_projection_independent' depends on axioms: [propext, Classical.choice, Quot.sound]
```

Output: [`verification/revision-2026-10-07-independent.txt`](verification/revision-2026-10-07-independent.txt). This is an independent check of the formulation, not a second independent mathematical proof.

## Revised proof dependencies

The final theorem uses the revised construction throughout:

- `ScalingTraceDistance.lean` proves the weighted trace identity and the projection-distance bound. The static balancing theorem now gives cost `1/2 · ‖q−p‖₁`; its general form has cost `βH / (2(1−βH)) · ‖q−p‖₁`.
- The `Resolvent*` modules construct a new Gaussian factor with covariance `ρ Q (ρI+Ω)⁻¹` in ambient horizontal coordinates. The covariance, scaled residual, mean, drift, sampling, retraction and final seed argument use this construction.
- The expected-graph argument uses the covariance inequality `Q−C ⪯ Ω/ρ`. Its coefficient is `2/n + 8/(dρ)`.
- The optimality remark is proved by a projection trace deficit, giving frame distance at least `εd/4`. As a lower-bound remark, it is checked standalone and is not needed by the upper-bound proof.

`Audit.lean` requires 12 specified trace/resolvent declarations in the final theorem's transitive dependency cone. These include the trace identity, rational covariance identity, Gaussian factor identity, residual decomposition, drift identity and covariance-loss comparison. It explicitly forbids `Smooth.moderateNoiseFrame`, `Smooth.normalizedTangentNoiseFactor` and `Smooth.covariance` in that cone. Generic scalar residual-weight inequalities and the drift algebra are intentionally reused; they do not define the old Gaussian in the new proof.

The audit also requires all 81 relevant `lem_*`, `thm_*`, `cor_*`, `eq_*` and `prop_*` statements in `Paulsen.Paper`. The five explicit exemptions are:

- `lem_sample` and `lem_seed_graph`, whose explicit versions are used;
- the spectral summary `eq_S`;
- the definitional restatement `eq_nearly_iff`;
- the final constant-chain summary `thm_main_constant_chain`.

Remarks are proved as standalone statements. Specified older proof routes with insufficient constants are excluded. A coarse fourth-moment bound is reused only to establish integrability; the sharper bound used quantitatively in the paper is separately proved.

## Source and dependency checks

- A source scan covered **225 Lean files**, excluding comments and string literals. It found no proof placeholders, added axioms, unsafe/native proof bypasses, or custom elaboration commands. `run_cmd` occurs only in the audit. See [`revision-2026-10-07-source-scan.txt`](verification/revision-2026-10-07-source-scan.txt).
- All **nine pinned dependency repositories** matched their manifest revisions and had clean tracked source files. See [`revision-2026-10-07-dependencies.txt`](verification/revision-2026-10-07-dependencies.txt).
- The paper was rebuilt with three LaTeX passes, without unresolved references or overfull/underfull box warnings. All pages were rendered for layout review; the changed mathematical and attribution pages were also inspected at larger size.

The paper-to-Lean map is in [`BLUEPRINT.md`](BLUEPRINT.md). The random-walk interpretation of the barrier constant and explanatory proof-strategy prose remain informal; the quantitative statements needed for the proof are formalised.

## Earlier verification record

The files `verification/build-audit-output.txt`, `verification/independent-check-output.txt` and `verification/leanchecker-summary.txt` retain the earlier **2 October** verification record. That record reports a clean build and separate kernel replay of 215 modules for the earlier version. **The separate `leanchecker` replay was not repeated for this revision.** The current revision was checked by Lean compilation, the expanded axiom/dependency audit and the independent restatement check described above.

The current theorem count is lower than the earlier 3,708 because narrower imports removed unused historical proof modules from the imported environment. All current paper statements remain covered by the audit.
