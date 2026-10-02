# Lean formalisation of the linear Paulsen bound

This project formalises the proof in *A linear bound for the Paulsen problem* (`../paper/linear-paulsen.pdf`). There are no proof placeholders and no project-specific axioms.

## Statement

Frames are real `n × d` matrices whose rows are the frame vectors. The target proposition [`SharpPaulsenBound`](Paulsen/Definitions.lean) is:

```lean
∃ C : ℝ, 0 < C ∧
  ∀ (n d : ℕ), 0 < d → d ≤ n →
  ∀ (ε : ℝ) (U : Frame n d), 0 < ε → ε < 1 →
    IsNearlyEqualNormParseval ε U →
    ∃ W : Frame n d, IsEqualNormParseval W ∧
      sqDistance U W ≤ C * ε * (d : ℝ)
```

- The hypotheses mean `(1−ε)I ≤ UᵀU ≤ (1+ε)I`, stated as a quadratic-form condition, and `(1−ε)d/n ≤ ‖uᵢ‖² ≤ (1+ε)d/n`.
- The output satisfies `WᵀW = I` and `‖wᵢ‖² = d/n`.
- The distance is `Σᵢⱼ (Uᵢⱼ − Wᵢⱼ)²`, not normalised.

[`SharpProjectionBound`](Paulsen/SharpProjection.lean) is the projection form. For an arbitrary real symmetric idempotent `P` with `P.rank = d` and `|Pᵢᵢ − d/n| ≤ β`, it gives a symmetric idempotent `Q` of rank `d` with `Qᵢᵢ = d/n` and `‖P − Q‖²_F ≤ C n β`.

Both are proved in [`Paulsen/Linear/Main.lean`](Paulsen/Linear/Main.lean):

```lean
theorem Paulsen.Linear.sharpPaulsenBound : Paulsen.SharpPaulsenBound
theorem Paulsen.Linear.sharpProjectionBound : Paulsen.SharpProjectionBound
```

[`IndependentCheck.lean`](IndependentCheck.lean) restates both theorems in plain Mathlib vocabulary and derives the restatements from them. That vocabulary is `Matrix.PosSemidef`, dot products, `trace ((U − W)ᵀ (U − W))`, `IsHermitian`, `IsIdempotentElem` and `Matrix.rank`.

## Structure

`Paulsen/Linear/` (about 3,600 lines) implements the argument of the paper. The rest of `Paulsen/` (about 26,000 lines) is the supporting library: frames, scaling, Gaussian tools, the noises and sampling estimates, and Hamilton–Moitra.

| Paper | Lean |
|---|---|
| Barrier constant, median barrier (Def. 2.6, Lemma 2.7) | [`Barrier.lean`](Paulsen/Linear/Barrier.lean) |
| Static balancing (Thm. 2.8) | [`Balancing.lean`](Paulsen/Linear/Balancing.lean) |
| Dense core with exceptional vertices (Lemma 2.10) | [`Core.lean`](Paulsen/Linear/Core.lean), [`BlockBarrier.lean`](Paulsen/Linear/BlockBarrier.lean), [`ManyRowBarrier.lean`](Paulsen/Linear/ManyRowBarrier.lean) |
| Seeds (Def. 2.12, Cor. 2.13) | [`Seed.lean`](Paulsen/Linear/Seed.lean) |
| Many-row seed: row moments, centred remainder, sample, theorem | `ManyRowMoments`, `ManyRowRemainder`, `ManyRowGraph`, `ManyRowSample`, `ManyRowParameters`, `ManyRow` |
| Moderate-row seed: commutator, drift `m_*`, drifted retraction, seed graph, theorem | `DriftAlgebra`, `DriftRetraction`, `DriftDiagonal`, `ModerateBarrier`, `ModerateDrift` |
| Assembly (Prop. 6.1, Thms. 1.1 and 1.2) | [`Assembly.lean`](Paulsen/Linear/Assembly.lean), [`Main.lean`](Paulsen/Linear/Main.lean) |

Appendix B of the paper lists where the formal proof differs in detail. The constants are much larger. The block gap of the moderate seed is derived from global concentration events of the library rather than from second moments. The balancing cost constant is 8 rather than 15/4.

## Build and audit

The project pins **Lean 4.32.0** and **mathlib v4.32.0** (`81a5d257c8e410db227a6665ed08f64fea08e997`). From this directory:

```sh
lake exe cache get
lake build
```

The default targets are `Paulsen` and [`Audit.lean`](Audit.lean). The audit checks three things:

- **Statements.** The final declarations have exactly the types `Paulsen.SharpPaulsenBound` and `Paulsen.SharpProjectionBound`.
- **Axioms.** Every theorem in the `Paulsen` namespace depends only on `propext`, `Classical.choice` and `Quot.sound`. Any other axiom, or `sorryAx`, fails the build.
- **Proof dependencies.** The proof of the main theorem actually uses the barrier-constant toolbox, the centred many-row remainder, the drifted moderate retraction and the partition-free assembly. It must not use the library's Poisson-constant balancing endpoints or its termwise remainder budget.

To print the audit and the independent restatement again:

```sh
lake env lean Audit.lean
lake env lean IndependentCheck.lean
```

See [`final-audit.md`](final-audit.md) for the recorded output.
