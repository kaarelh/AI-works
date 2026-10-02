# Lean formalisation of the linear Paulsen bound, with the paper's constants

This project formalises *A linear bound for the Paulsen problem* (`../paper/linear-paulsen.pdf`). The formalisation is **statement by statement and constant by constant**:

- Every numbered definition, lemma, theorem, corollary and proposition has a Lean counterpart that carries exactly the constants of the text. So does every numbered display that makes a claim and every remark that makes a quantitative claim.
- Explicit constants include, among others: the balancing cost 15/4, the seed bound 3Θ, `R = √b/λ` in the dense-core lemma, the Gaussian tail constants 1/8, 2/π² and 32, the net bound 16, the counts 0.9(n−1) and 0.95n, δ₀ = 1/6400, and every constant recipe inside the proofs.
- Each Lean declaration quotes the corresponding TeX in its docstring.
- Everything is proved, with no proof placeholders and no project-specific axioms.

## Main results

[`Paulsen/Paper/Assembly.lean`](Paulsen/Paper/Assembly.lean):

```lean
theorem Paulsen.Paper.thm_main : Paulsen.SharpPaulsenBound            -- Theorem 1.1
theorem Paulsen.Paper.thm_projection : Paulsen.SharpProjectionBound   -- Theorem 1.2
```

The explicit dependence C = max{12, 1+8C_P}, C_P = max{4, 2+8C₀}, C₀ = max{d₀, C_*, 4/c_*, 2+4C_m, 16/ε₀} is in `thm_main_explicit`, `thm_projection_explicit` and `prop_equalrow_explicit`.

`SharpPaulsenBound` ([`Paulsen/Definitions.lean`](Paulsen/Definitions.lean)) reads:

```lean
∃ C : ℝ, 0 < C ∧
  ∀ (n d : ℕ), 0 < d → d ≤ n →
  ∀ (ε : ℝ) (U : Frame n d), 0 < ε → ε < 1 →
    IsNearlyEqualNormParseval ε U →
    ∃ W : Frame n d, IsEqualNormParseval W ∧
      sqDistance U W ≤ C * ε * (d : ℝ)
```

Frames are real `n × d` matrices whose rows are the frame vectors. Parseval means `UᵀU = 1`, the spectral condition is stated as a quadratic-form inequality, and row norms are compared with the real quotient `d/n`. The distance is the unnormalised squared Frobenius distance.

[`IndependentCheck.lean`](IndependentCheck.lean) restates both theorems in plain Mathlib vocabulary (`PosSemidef`, dot products, traces, `IsHermitian`, `IsIdempotentElem`, `Matrix.rank`) and derives the restatements from them.

## Layout

| Paper | Lean (`Paulsen/Paper/`) |
|---|---|
| §1 (statement, Remark 1.3 optimality) | `Intro` |
| §2 scaling toolbox | `Toolbox`, `ToolboxAux*` |
| §3 Hamilton–Moitra | `Bounded` |
| §4 many-row seed | `ManyRow`, `ManyRowProof`, `ManyRowAux*` |
| §5.1–5.4 moderate seed: covariance, commutators, mean, drift, expected graph | `Moderate`, `ModerateAux*` |
| §5.5 sample lemma (S1)–(S4) | `ModerateSample`, `SampleAux*` |
| §5.6–5.7 retraction, seed graph, Theorem 5.1 | `ModerateSeed`, `SeedAux*` |
| §6 assembly, Theorems 1.1 and 1.2 | `Assembly`, `AssemblyAux` |
| Appendix A Gaussian tools | `Gaussian` |

[`BLUEPRINT.md`](BLUEPRINT.md) maps every paper label to its Lean name.

The rest of `Paulsen/` is the supporting library: frames, projections, the log-determinant potential, Gaussian measures, the noises, and Hamilton–Moitra. It includes `Paulsen/Linear/`, an earlier formal route to the same theorem with larger constants. Some of its definitions are reused (for example the drift `Γ_f`, `m_*` and the barrier predicates). Its theorems with worse constants are not used, and the audit checks this.

Lines of code:

| Part | Lines |
|---|---|
| `Paulsen/Paper/` | 16,100 |
| library | 29,700 |

## Build and audit

The project pins **Lean 4.32.0** and **mathlib v4.32.0** (`81a5d257c8e410db227a6665ed08f64fea08e997`). From this directory:

```sh
lake exe cache get
lake build
```

The default targets are `Paulsen` and [`Audit.lean`](Audit.lean). The audit checks:

1. The final theorems have exactly the types `SharpPaulsenBound` and `SharpProjectionBound`.
2. Every theorem in the `Paulsen` namespace depends only on `propext`, `Classical.choice` and `Quot.sound`. Hence every paper statement is fully proved.
3. Every `lem_*`, `thm_*`, `cor_*`, `eq_*` and `prop_*` statement of `Paulsen.Paper` (82 of them) lies in the dependency cone of the final theorems. The only exceptions are listed in the file: two existential forms whose explicit versions are used, the facts (5.2) and the definitional restatement of (1.1). Remarks are proved standalone.
4. No library lemma with a constant weaker than the paper's is used. Examples: balancing cost 8, Gaussian tail constant 1/16, the 17/20 dense core, the 80/d expected-graph bound, the old seed thresholds.

See [`final-audit.md`](final-audit.md) for the recorded output.
