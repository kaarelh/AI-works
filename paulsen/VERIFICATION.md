# Verification of the `for-hugo` Paulsen package

Date: 2026-10-02. Input: `for-hugo.zip` (paper `paulsen-static-proof.pdf` and LaTeX, Lean 4 project `lean/`).

## 1. Is the Lean statement correct?

**Yes.** `Paulsen.SharpPaulsenBound` (`lean/Paulsen/Definitions.lean`) is a faithful formalisation of the real Paulsen problem with the linear bound:

```lean
∃ C : ℝ, 0 < C ∧ ∀ (n d : ℕ), 0 < d → d ≤ n → ∀ (ε : ℝ) (U : Frame n d), 0 < ε → ε < 1 →
  IsNearlyEqualNormParseval ε U →
  ∃ W : Frame n d, IsEqualNormParseval W ∧ sqDistance U W ≤ C * ε * (d : ℝ)
```

The objects in it:

| Definition | Meaning | OK |
|---|---|---|
| `Frame n d := Matrix (Fin n) (Fin d) ℝ` | rows are the frame vectors | ✓ |
| `IsParseval U := Uᵀ * U = 1` | frame operator Σ uᵢuᵢᵀ = I_d | ✓ |
| `IsEqualNorm U := ∀ i, ‖uᵢ‖² = d/n` | real division of casts | ✓ |
| `IsNearlyParseval ε U` | ∀x, (1−ε)‖x‖² ≤ ‖Ux‖² ≤ (1+ε)‖x‖², i.e. (1−ε)I ≼ UᵀU ≼ (1+ε)I | ✓ |
| `IsNearlyEqualNorm ε U` | (1−ε)d/n ≤ ‖uᵢ‖² ≤ (1+ε)d/n | ✓ |
| `sqDistance U W := Σᵢⱼ (Uᵢⱼ − Wᵢⱼ)²` | squared Frobenius distance, unnormalised | ✓ |

Points to be aware of (none is a defect):

- **Real frames only.** The complex Paulsen problem is not covered; it does not obviously follow from the real case.
- **The side conditions are harmless.** `0 < d` excludes a trivial case. `ε < 1` already forces `d ≤ n`. Large ε is trivial, since any ENP frame is within (2+ε)d.
- **Order of quantifiers is right.** One constant `C` is chosen before `n, d, ε, U`.
- **The constant is astronomically large.** It can be read off the proof chain as roughly 3·10²⁶⁵. So the bound is non-vacuous only for ε ≲ 10⁻²⁶⁵. It is still exactly the asymptotic O(εd) statement.
- **Only the upper bound is formalised.** The matching Ω(εd) lower bound, which makes it "optimal", is not.
- **The projection form is also faithful.** `SharpProjectionBound` (`SharpProjection.lean`) states it for arbitrary real symmetric idempotent `P` with `P.rank = d` and |Pᵢᵢ − d/n| ≤ β, giving `Q` of the same kind with diagonal d/n and ‖P−Q‖²_F ≤ Cnβ. Only the direction frame ⇒ projection is formalised; that is all the statement needs.

**Independent restatement.** `verification/IndependentCheck.lean` restates both theorems from scratch in standard Mathlib vocabulary, using no `Paulsen` definitions:
- `Matrix.PosSemidef` for the Loewner bounds;
- `⬝ᵥ` dot products for row norms;
- `trace((U−W)ᵀ(U−W))` for the distance;
- `IsHermitian`, `IsIdempotentElem` and `Matrix.rank` for projections.

It derives both restatements from the project's theorems. `lake env lean IndependentCheck.lean` prints:

```
'paulsen_independent' depends on axioms: [propext, Classical.choice, Quot.sound]
'paulsen_projection_independent' depends on axioms: [propext, Classical.choice, Quot.sound]
```

## 2. Does the Lean proof check?

**Yes.**

- **Toolchain.** Lean 4.32.0 (from the GitHub release) and mathlib at the pinned commit `81a5d257` (tag v4.32.0, official repository, clean checkout). Mathlib was built from source because this sandbox's network policy blocks the mathlib cache hosts. The `lakefile.toml` has no custom options, and mathlib is the only dependency.
- **Build.** `lake build` succeeded: 3,903 jobs in 112 minutes on 4 cores. There were only linter warnings. The project's `Audit.lean` ran as part of the build; its output is in `verification/build-audit-output.txt`:
  ```
  'Paulsen.sharpPaulsenBound' depends on axioms: [propext, Classical.choice, Quot.sound]
  'Paulsen.sharpProjectionBound' depends on axioms: [propext, Classical.choice, Quot.sound]
  Audited 2654 Paulsen theorems. Only propext, Classical.choice, and Quot.sound are allowed.
  Build completed successfully (3903 jobs).
  ```
- **Kernel replay.** `leanchecker` replayed every compiled `Paulsen.*` module separately into the kernel, which guards against environment hacking. All 185 modules passed (`verification/leanchecker-summary.txt`). The root module `Paulsen.lean` contains only imports. Six source files are not imported by the build and have no `.olean`: `GaussianSmallCountTopology`, `GraphCrossConcentration`, `ModerateConstruction`, `ModerateGaussianCrossSample`, `ModerateGaussianGeneric`, `ModerateSampleGraph`. They are superseded routes; the final theorem does not depend on them.
- **Source scan.** No `sorry`, `admit`, `axiom`, `unsafe`, `implemented_by`, `extern`, `opaque`, `native_decide`, `ofReduceBool` or `debug.skipKernelTC`. No custom `macro`, `elab`, `syntax`, notation, `run_cmd`, `initialize` or environment manipulation, and no instance overrides on `Matrix` or `ℝ`. The only `set_option` is `maxHeartbeats`.

## 3. Review of the paper

The paper was reviewed section by section, by hand and with numerical checks of every identity and inequality on random and near-direct-sum examples. **No false statement and no substantive gap was found.** The issues found are presentational:
- heavy notation overloading: K, B, D, R, W, A, C, ρ and η each have two or three meanings;
- several terse or unstated justifications, especially in the sampling estimates (§3.3) and the dense-core variance bookkeeping;
- one constant slip: 𝖫(W²) ≼ 2p_max·L is stated, but the argument gives 4p_max·L, which is harmless;
- one sentence whose order of constants looks circular as written but is not: η plays two roles.

## 4. Simplifications → `linear-paulsen/paper/linear-paulsen.pdf`

Three substantive simplifications survived adversarial checking. The streamlined write-up is built around them.

1. **Drift instead of a second scaling (moderate seed).** The identity q(N_f) = 𝒜(Vᵀ F(I−2P)F U) writes the filter bias as b_* = 𝒜m_*, where m_* is an explicit deterministic tangent direction with ‖m_*‖²_F ≤ 2a/ρ. Adding (t/2)m_* to the Gaussian cancels the bias at first order. This removes the local correction lemma (the second minimisation and the Hessian comparison) and the global two-sided spectral comparison. It also removes concentration of the full squared Gaussian graph, the matrix-series (Khintchine) bound, and the re-check of the dense core after correction. Only a bounded deterministic block of rows needs a spectral-gap estimate, and second moments suffice for it.
2. **Many-row seed for all η ≤ c, not only η ≤ c/d², which removes the partition.** The constraint XᵀZ + ZᵀX = 0 lets the remainder weights be centred at 1/(1+t²). That gives ‖R‖ = O(t³) instead of O(t³d). Numerically ‖R₃‖/t³ ≈ 0.05–0.08 for d = 10 and 20, while the original termwise bound is ≈ 2.5d (`verification/manyrow_remainder_check.{py,txt}`). Consequently the random partition into blocks of size ⌈Ld⁶⌉ is unnecessary. The global argument is three cases: d < D (Hamilton–Moitra), n ≥ Bd² (many-row seed) and n < Bd² (moderate seed).
3. **Barrier constant instead of Poisson constant.** The half-set hitting time of the squared-Gram random walk is within a factor 2 of the Poisson constant, and it is exactly what the median barrier uses. With it the maximum principle needs no connectivity argument, and the dense-core estimate becomes one explicit barrier instead of a Schur complement. The balancing constant improves from 8 to 15/4.

The write-up also has one scaling toolbox, a single seed interface used by both constructions, a table of error scales, complete proofs of all sampling estimates, and explicit acyclic constant choices.

**Checking of the streamlined paper.** Five independent agent reviewers checked the new text section by section, by hand and numerically, and were asked to break it. They found **no errors and no gaps**; about 40 minor or clarity items were all fixed. Highlights:
- **Drift.** b_* = 𝒜m_* holds to 10⁻¹⁸. A Monte Carlo on a hub-joined near-direct sum (n = 200, d = 20) shows that without the drift the mean diagonal error is −t²b_*, and with the drift it is O(t) relative to at².
- **Barrier constant.** K ≤ H ≤ 2K holds on 60 Laplacians, and the factor 2 is essentially attained. The median-barrier lemma and static balancing hold on hundreds of adversarial instances, with cost ratio at most 0.17 against the bound 15/4.
- **Many-row remainder.** The centred remainder bound and the moment bounds were checked with explicit projection onto the constraint subspace.

The intro also gains a short proof that the bound is optimal: a direct sum of two slightly unbalanced ENP blocks forces ‖X−W‖² ≥ εd/8.

**Formalisation of the streamlined proof.** The streamlined proof is now formalised separately, in `linear-paulsen/lean/`. Its final theorem `Paulsen.Linear.sharpPaulsenBound` has the same target type `Paulsen.SharpPaulsenBound`. It builds from scratch, passes the audit (axioms and proof dependencies) and the independent restatement, and every module was replayed with `leanchecker`. See `linear-paulsen/lean/final-audit.md`.
