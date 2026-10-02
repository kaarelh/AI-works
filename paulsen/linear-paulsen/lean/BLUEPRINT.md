# Statement blueprint: "A linear bound for the Paulsen problem" (constant-faithful)

Directory `Paulsen/Paper/`, namespace `Paulsen.Paper`. Every numbered item of the paper
(`paper/sections/*.tex`) has a Lean statement that carries **exactly the paper's constants**.
The explicit-constant claims inside the proofs of `thm:balancing`, `cor:seed`, `lem:rowmoments`,
`lem:Q`, `lem:remainder`, `lem:mr-dense`, `thm:manyrow`, `lem:mean`, `lem:expected-graph`,
`lem:sample`, `lem:retraction`, `lem:seed-graph`, `thm:moderate`, `prop:equalrow`,
`thm:projection` and `thm:main` are stated as separate lemmas. Each declaration has a docstring
that quotes the TeX of the item.

* Build: `lake build Paulsen.Paper.All` (about 70 s on a warm cache). Every file compiles with
  `sorry` warnings only.
* Size: 10 Lean files, **143 theorems and 94 definitions/structures/abbrevs**. 140 theorems are
  `sorry`; three are proved by `Iff.rfl` (`def_enp`, `sharpProjectionBound_iff`,
  `sharpPaulsenBound_iff`). **No definition uses `sorry`** (checked with `collectAxioms`).
* The final theorems are `Paulsen.Paper.thm_main : Paulsen.SharpPaulsenBound` and
  `Paulsen.Paper.thm_projection : Paulsen.SharpProjectionBound`. The explicit constant chain
  `C₀ = max{d₀,C_*,4/c_*,2+4C_m,16/ε₀}`, `C_P = max{4,2+8C₀}` and `C = max{12,1+8C_P}` is in
  `prop_equalrow_explicit`, `thm_projection_explicit`, `thm_main_explicit` and
  `thm_main_constant_chain`.

## Files

| File | Paper part | Imports (library) |
|---|---|---|
| `Toolbox.lean` | §2 toolbox; generic notation (`opNorm`, `frobSq`, `invSqrt`, `polarFactor`) | `Linear.Seed`, `Linear.Core`, `Linear.BlockBarrier`, `MedianBarrier`, `FrameAlignment`, `ScalingDistance`, `NormalTangentGraph`, `PolarGram`, `DiagonalScalingPotential`, Mathlib Hermitian CFC |
| `Intro.lean` | §1: `eq:nearly`, ENP definitions, `rem:optimal` | Toolbox |
| `Bounded.lean` | §3: `lem:HM`, `cor:exist` | Toolbox |
| `Gaussian.lean` | App. A: `lem:gauss` (a)(b)(c), covariance domination | `GaussianQuadraticForm`, `GaussianLinearImage`, `GaussianRotationConcentration`, `GaussianOperatorNet` |
| `ManyRow.lean` | §4.1–4.3 (noise, row moments, identities, `lem:Q`, `lem:remainder`, `lem:mr-dense`) | Gaussian, `Linear.ManyRow` |
| `ManyRowProof.lean` | §4.4 proof of `thm:manyrow`: constants, the event, all intermediate claims | ManyRow |
| `Moderate.lean` | §5 preamble and 5.1–5.4 (`eq:lap-basic`, `eq:S`, `eq:finfty`, filtered covariance, `lem:filter`, `eq:q-cs`, `lem:commutator`, `lem:mean`, `rem:drift`, `lem:expected-graph`, remark after `thm:moderate`) | Gaussian, `Linear.ModerateDrift`, `SmoothRationalCovariance`, `SmoothExpectedExpansion` |
| `ModerateSample.lean` | §5.5: `𝔅`, (S1)–(S4), `lem:sample` and its proof constants | Moderate |
| `ModerateSeed.lean` | §5.6–5.7: retraction, `lem:retraction`, `lem:seed-graph`, proof of `thm:moderate` | ModerateSample |
| `Assembly.lean` | §6 and `thm:main`, `thm:projection` | all of the above, `SharpProjection` |
| `All.lean` | imports everything | |

## Encoding conventions (also in the header of `Toolbox.lean`)

* `X : Frame n d` (rows are the frame vectors), `a = (d:ℝ)/n`, `p_i = rowNormSq U i = P_ii`,
  `P = frameProjection U`, `L = L_P = projectionLaplacian P`.
* `‖M‖_op = opNorm M`, the norm of `(toEuclideanLin M).toContinuousLinearMap`. For a symmetric
  matrix, `A ⪯ B` and `‖·‖_op` are sometimes encoded by quadratic forms (`matrixQuadratic`).
* `‖XᵀX - I‖_op ≤ η` is `IsNearlyParseval η X` (`isNearlyParseval_iff_opNorm`). Where the paper
  *defines* `η := ‖XᵀX - I‖` (`lem:HM`, `thm:manyrow`, `prop:equalrow`), the blueprint takes any
  `η ≥ ‖XᵀX-I‖`. All conclusions are monotone in `η`, so this is equivalent.
* `max_i` and `min_i` bounds, `‖·‖_∞` and `β = ‖q-p‖_∞` are written pointwise ("for all `i`") or
  with an arbitrary upper or lower bound. These encodings are equivalent because every
  conclusion is monotone.
* Barrier constant: `Linear.HasBarrierBound w H` is `H(L) ≤ H`. The value
  `barrierConstant w : ℝ≥0∞` is defined as an infimum (`barrierConstant_le_iff`).
* Probability: `(stdGaussian (FrameVector n d)).real {g | …}`; "with positive probability" is
  `0 < (…).real {g | …}`; `E` is a Bochner integral.
* Many-row noise: `Z = conditionedNoise X g = n^{-1/2} Π_F g` and `Z₀ = rowNoise X g = n^{-1/2} Π_E g`
  use the same `g`. `V = tangentSeed X Z a t` and `V₀ = rowIndependentSeed X t g`.
* Moderate noise, in ambient horizontal coordinates: `H = VZ` with `Uᵀ H = 0`, written
  `moderateNoise U ρ g = Smooth.moderateNoiseFrame U ρ g`. Further:
  * `Y_Z = tangentY U H = HUᵀ + UHᵀ` and `𝒜Z = diagMap U H`;
  * `N_x = ambientNormal U x`, `Γ_f = Linear.driftGamma U f` and `m_* = Linear.driftMean U ρ`;
  * `Ω = normalizedNormalCovariance U`, and `I_𝒵 = horizontalProjectionMatrix U`;
  * `C_ρ = filteredCovariance U ρ` (shown equal to `Smooth.covariance U ρ` in
    `moderateNoise_spec`).

  Then `‖Zᵀv_i‖ = ‖row_i H‖` and `‖Zu_i‖ = ‖row_i (UHᵀ)‖`.
* `M^{-1/2}` is `invSqrt M := cfc (x ↦ 1/√x) M`. The polar factor is `polarFactor X = X·invSqrt(XᵀX)`,
  and the retraction is `retraction U W t = (U+tW)·invSqrt(1+t²WᵀW)`.

Bridge lemmas (not in the paper; they tie the encodings to the library): `isNearlyParseval_iff_opNorm`,
`invSqrt_spec`, `barrierConstant_le_iff`, `mrQ_mrR_eq_library`, `moderateNoise_spec`,
`sharpPaulsenBound_iff`, `sharpProjectionBound_iff`, `manyRowWith_of_explicit`.

## Map

Legend: **lib** gives the library constant compared with the paper's: `=` (equal), `better`,
`worse`, or `new` (nothing usable in the library). **Eff** is the effort: S < 60 lines (mostly
wrapping), M is 60–250 lines, L > 250 lines or substantial new mathematics. Library names are in
namespace `Paulsen` (`Linear.` = `Paulsen.Linear`, `Smooth.` = `Paulsen.Smooth`).

### §1 Statement (`Intro.lean`, `Assembly.lean`)

| Label | Lean name | File | Library route | lib | Eff |
|---|---|---|---|---|---|
| ENP defs | `def_enp` (proved) | Intro | `Iff.rfl` | = | done |
| `eq:nearly` | `eq_nearly_iff` | Intro | quadratic forms ↔ `PosSemidef` (Mathlib `Matrix.PosSemidef` with `dotProduct`) | = | S |
| `thm:main` | `thm_main : SharpPaulsenBound` | Assembly | `thm_main_explicit` + `thm_projection_explicit` + `prop_equalrow` (currently also `Linear.sharpPaulsenBound` in `Linear/Main.lean`) | = | S (given the rest) |
| `thm:projection` | `thm_projection : SharpProjectionBound` | Assembly | `thm_projection_explicit` + `prop_equalrow`; the library goes the other way (`sharpProjectionBound_of_sharpPaulsenBound`) | = | S (given the rest) |
| `rem:optimal` | `rem_optimal`, def `optimalExample` | Intro | new. Block matrices `Matrix.fromBlocks`/`reindex`; trace argument; `projection_sqDistance_le_twice` | new | M |

### §2 Toolbox (`Toolbox.lean`)

| Label | Lean name | Library route | lib | Eff |
|---|---|---|---|---|
| `lem:align` (display) | `lem_align`, def `crossSingularValues` | `exists_parseval_frame_alignment` (≤ part), `projection_sqDistance_eq_twice_residual`, `parseval_projection_distance_crossGram`, `projection_sqDistance_le_twice`. The `IsLeast` (exact min = `2∑(1-σ_k)`) needs the nuclear-norm/von Neumann trace inequality and singular-value bookkeeping | = for the inequalities; the exact `min` and the σ-formulas are new | M–L |
| `lem:align` (O(d)) | `lem_align_orthogonal` | `IsParseval.mul_orthogonal`, `rowNormSq_mul_orthogonal` | = | S |
| `lem:align` (polar) | `lem_align_polar`, `lem_align_polar_half` | `exists_polar_normalization(_row_gram)` (PolarNormalization/PolarGram) prove these for *some* Parseval `U` and equal-norm `X`; here it is the specific `X(XᵀX)^{-1/2}` for general `X`. Adapt: spectral calculus of `invSqrt` (`invSqrt_spec`, `Matrix.IsHermitian.cfc_eq`) | = (6δ², 2δ) | M |
| bridge | `isNearlyParseval_iff_opNorm`, `invSqrt_spec` | `abs_matrixQuadratic_le_operator_norm`-type lemmas; Mathlib CFC (`cfc_mul`, `cfc_comp`) | — | S / M |
| `lem:energy` | `lem_energy` | `parseval_laplacian_apply_eq_weighted`, `projectionLaplacian_posSemidef`, `graphLaplacian_mulVec_const`, `projectionLaplacian_complement`, `projectionLaplacian_quadratic`, `rowScale_residual_energy`, `diagonalCommutator_frob_sq` | = | S |
| `lem:scaled` | `lem_scaled` | `diagonal_scaling_projection_distance_le`, `exists_posDef_right_whitening`, `columnSpaceProjection_eq_of_parseval_right_mul`; needs `invSqrt_spec` for the specific `M` | = | M |
| `lem:potential` | `lem_potential`, defs `scalingPotential`, `scaledProjection`, `scaledDiagonal` | `diagonalScalingPotential_eq_logdet`, `hasFDerivAt_diagonalScalingPotential`, `sum_exp_scaledLeverage`, `rowScale_projection_diagonal`. `ContDiff ∞` and `ConvexOn` are new (convexity: Cauchy–Binet log-sum-exp, `diagonalScalingPartition`) | = (convexity new) | M |
| `lem:scaling-ineq` | `lem_scaling_ineq`, def `sqrtScaledDiagonal` | `parseval_diagonal_scaling_first_inequality`, `diagonal_scaling_reciprocal_inequality` (+ `IsParseval.exists_complement`, `parseval_laplacian_apply_eq_weighted`, `rowScale_projection_diagonal`) | = | S |
| `def:barrier` | `barrierConstant`, `barrierConstant_le_iff`; predicates `Linear.IsBarrier`, `Linear.HasBarrierBound` | library predicate matches; attainment of the infimum is new (closed feasible sets, finitely many `S`) | = / new | M |
| ¶ after `def:barrier` | `barrier_connected` | new (sum of `Lψ` over a component) | new | S |
| `lem:median` | `lem_median` | `Linear.barrier_median_sandwich` (hypotheses identical, without symmetry) | = | S |
| `eq:kkt` | `eq_kkt`, def `balancingPotential` | `targetScalingPotential_box_optimality`, `isCompact_Icc.exists_isMinOn` (bridge `scalingPotential ↔ diagonalScalingPotential`, `scaledDiagonal ↔ scaledLeverage`) | = | S–M |
| `thm:balancing` | `thm_balancing` | `Linear.exists_box_radial_scaling_barrier` (ratio `(1-βH)^{-1} ≤ 2`) + `Linear.balancing_projection_cost_barrier`, which gives **8** | **worse** (8 vs 15/4) | M |
| proof of `thm:balancing` | `thm_balancing_steps`, def `osc` | the 15/4 needs `zᵀLz ≤ ∑ zᵢ² fᵢ = ∑(zᵢ²-c)fᵢ ≤ ½ osc(z²)‖f‖₁` (centering, new) and `(z_i-z_j)² ≥ 4 min w² (w_i-w_j)²`. The library uses the crude `Z²/(2m⁴)` (`diagonal_scaling_energy_le_total_error`) | worse → new | M |
| remark after `thm:balancing` (1) | `rem_balancing_forces_positive` | new (barrier for `[n]∖{i}`) | new | S |
| remark after `thm:balancing` (2) | `rem_balancing_general` | the same as `thm_balancing` with a general box side | new | M |
| `lem:core` | `lem_core`, defs `CoreDense`, `CoreExceptional` | `Linear.core_barrier` (identical) | = | S |
| `lem:core`(i) | `lem_core_i` | `Linear.core_of_counts` | = | S |
| `lem:core`(ii) | `lem_core_ii` | `Linear.block_barrier` gives `R = b/λ` | **worse** (b/λ vs √b/λ) | S–M (replace the sup bound by `‖y‖∞ ≤ ‖y‖₂ ≤ ‖𝖫⁻¹‖‖𝟙_B‖₂`) |
| `lem:core`(iii) | `lem_core_iii` | `projection_killed_row_lower_of_leverage` (3α/8) + `projection_entry_sq_le_diagonal_mul` + `Linear.indicator_exceptional_barrier` | = | S |
| `rem:poisson` | `rem_poisson_barrier_le_twice`, `rem_poisson_le_barrier` | `H ≤ 2K`: `halfSetForcing_sum`, `halfSetForcing_abs_le_one` (as inside `poisson_subset_bound_restricted`); `K ≤ H`: new (connectivity ⇒ solvability, median max principle `Linear.barrier_subset_bound`) | = / new | S / M |
| `def:seed` | `IsSeed` (abbrev of `Linear.IsSeed`) | identical | = | done |
| `cor:seed` | `cor_seed`, `cor_seed_proof` | `Linear.IsSeed.hasCorrection` gives **4Θ** (from cost 8). With `thm_balancing` (15/4) the paper's `3Θ` follows | **worse** (4Θ vs 3Θ) | S once `thm_balancing` is done |

### §3 Bounded rank (`Bounded.lean`)

| Label | Lean name | Library route | lib | Eff |
|---|---|---|---|---|
| `lem:HM` | `lem_HM` | `equalRow_quadratic_correction` | = | S |
| `cor:exist` | `cor_exist`, `cor_exist_trivial` | `exists_equalNormParseval`, `Linear.equalNorm_hasCorrection_trivial` (4d), `sqDistance_le_twice_energy` | = | S |

### App. A Gaussian tools (`Gaussian.lean`)

| Label | Lean name | Library route | lib | Eff |
|---|---|---|---|---|
| `lem:gauss`(a) | `lem_gauss_a` | variance: `integral_sq_centered_euclideanQuadratic_stdGaussian`, `integral_euclideanQuadratic_stdGaussian`. Tail: `euclideanQuadratic_stdGaussian_abs_tail` has **1/16** | **worse** (1/16 vs 1/8). Redo the Chernoff step with the paper's `2s²‖A‖²` MGF bound (`mgf_euclideanQuadratic_stdGaussian`; the library `mgf_sum_centered_gaussian_squares_le` gives `4s²…`) | M |
| `lem:gauss`(a) correlated | `lem_gauss_a_correlated` | `euclideanQuadratic_linear_image`, `entry_sq_sum_quadratic_pullback_le`, `euclidean_operator_norm_quadratic_pullback_le`; tail from `lem_gauss_a` | = (1/8 after (a)) | S–M |
| `lem:gauss`(b) | `lem_gauss_b` | `stdGaussian_smooth_abs_tail` (stronger: `u ≤`, needs `0 < ℓ`; the `ℓ = 0` case is trivial) | = | S |
| `lem:gauss`(c) | `lem_gauss_c` | `gaussian_matrix_operator_net_tail` with `u ↦ u/4` | = | S |
| covariance domination | `covariance_domination` | `integral_norm_sq_gaussianImage`, `entry_sq_sum_mul_le` (trace with a PSD Gram matrix) | = | S–M |

### §4 Many-row seed (`ManyRow.lean`, `ManyRowProof.lean`)

| Label | Lean name | Library route | lib | Eff |
|---|---|---|---|---|
| def. of `m` | `mr_codim_le`, def `mrCodim` | `tangent_codimension_le` (≤ d²); `d(d+1)/2` is new (image ⊆ Sym_d) | = (d²) / new for `d(d+1)/2` | S–M |
| noise covariance | `mr_noise_covariance` | `tangentNoiseFactor_operator_norm_sq_le`, `Linear.rowTangentNoiseFactor_operator_norm_sq_le'`; row covariance via `Π_F ⪯ Π_E` | = | S–M |
| `eq:mr-noise` | `eq_mr_noise`, def `rowNoise` | `integral_tangentNoise_norm_sq` (= dim F/n), `Linear.rowTangentSpace_finrank`, `integral_tangentNoise_coupling_sq_le` (≤ d²/n); exact `= m/n` via `tangentNoise_coupling_eq` + finrank of `removedTangentSpace` | = | M |
| `lem:rowmoments` (δ claims) | `lem_rowmoments_deficit`, defs `mrRatio`, `mrRatioMean`, `mrDeficit` | `integral_tangentNoise_norm_sq`, `Linear.globalTangentSpace_finrank_ge`; `μ_i ≤ (d-1)/d` from `z_i ⊥ x_i` | new | M |
| `lem:rowmoments` (𝓜) | `lem_rowmoments`, def `mrMoment` | `Linear.integral_rowFourthDeviation_conditioned`: `12(1+d²/n)+120024 ≤ 120048` when `d² ≤ n`. `(r-1)²(1+r)² = (r²-1)²` | = (an absolute constant) | S |
| proof of `lem:rowmoments` | `lem_rowmoments_gaussian` (12, 48, 60/d²), `lem_rowmoments_scalar` (16, 4), def `mrRowCovariance` | exact 4th moment `12(trΣ²)²+48trΣ⁴`: new (the library's `Linear.centered_euclideanQuadratic_four` gives `40000 V²`) | **worse** (40000 vs 60) | M–L (exact cumulants) / S |
| `eq:mr-contract` | `eq_mr_contract`, `mr_normalisation_lipschitz` | `tangentSeed_rowNormSq`, `tangentSeed_distance_from_input`, `tangentSeed_sqDistance_le`, `frameEnergy_tangentSeed_le_perturbed` (→ operator norm) | = | S |
| `eq:mr-identity` | `eq_mr_identity`, defs `mrWeight`, `mrQ`, `mrR3`, `mrR4`; bridge `mrQ_mrR_eq_library` | `tangentSeed_frameOperator_expansion` (`tangentQuadratic`, `tangentRemainder = R₃+R₄`) | = | S |
| `lem:Q` | `lem_Q`, def `mrQMean` | `tangentQuadraticMean_conditioned_bias_le` gives **d²/n**, not `m/n`; fluctuation `integral_conditionedFluctuation_sq_le` (8d²/n) | mean: **worse** (d²/n vs m/n, harmless since m ≤ d²); fluctuation = | M (`m/n`: trace argument on `E Q(Z_⊥)`) |
| proof of `lem:Q` | `lem_Q_row_mean`, `lem_Q_coefficients` | `tangentQuadraticMean_rowTangentNoiseFactor_eq`; coefficient sum is new (elementary) | = / new | S |
| `lem:remainder` | `lem_remainder`, defs `mrCbar`, `mrGamma`, `mrLambda` | `Linear.tangentRemainder_centred_bound` (combined quadratic-form version with `M = rowFourthDeviation`). Needs splitting into `‖R₃‖`, `‖R₄‖` with `‖ΓZ‖_F`, `‖ΛX‖_F` | = in substance; restatement needed | M |
| `lem:remainder` moments | `lem_remainder_moments` | `Linear.centred_weight_sq_le`, `Linear.centred_leverage_weight_sq_le` (`≤ (r²-1)²`) + `Linear.integral_rowFourthDeviation_conditioned` | = | S–M |
| proof of `lem:remainder` | `lem_remainder_scalar` | elementary algebra | new | S |
| remark after `lem:remainder` | `rem_remainder_termwise` | `tangentRemainder_quadratic_bound`-style termwise bound | = | S |
| `lem:mr-dense` | `lem_mr_dense`, def `MrDenseConclusion` | `rowIndependentSeed_dense_core_failure_le` gives `17n/20` neighbours (j = i allowed), probability `1 - n e^{-3n/50}`, `h ≤ 1/(400e)`, `t ≤ 1/100` | **worse** count (0.85n vs 0.9(n-1)) and exponent (3/50 vs 1/10-(e-1)/50 ≈ 0.0656) | M (rerun the library argument with the paper's thresholds) |
| proof of `lem:mr-dense` | `lem_mr_dense_explicit` (`c₁ = 1/10-(e-1)/50`, `3h+t₀²/3+8t₀² ≤ 1/50`), `lem_mr_dense_pair` (`4h/√(3π/2) ≤ 3h`, `16t²/d ≤ 8t²`) | RowSeedCore internals; `gaussianReal` density bound | new | M / S |
| constants | defs `mrKappa0` (h²/200), `mrCPrime` (36²·20), `mrCmix` (125/h²+3), `mrTheta` (max{42,C_mix}), `mrSmallTheta` (min{1/(4Θ),h/60}), `mrCR` (300+100√C_𝓜), `mrT1`, `mrAmplitude` (t²=4η/θ), `mrCStar` (θt₁²/4), `mrCostStar` (12Θ/θ); `MrBChoice`, `RowMomentBound` | — | — | — |
| proof: constants | `mr_constants` (incl. `c_* ≤ 1/64`), `mr_B_exists` | real arithmetic | new | S |
| proof: event | `MrEvent`, `mr_event_failures` (1/20 ×5, `2·5^{n+d}e^{-8n}` ×2), `mr_event_budget`, `MrSetting`, `mr_event_pos` | `Linear.exists_manyRow_sample` uses thresholds 100× and 128 (via `exists_mem_core_lt_budgets`, `gaussian_matrix_operator_failure_le`). Paper thresholds (20, 160, 16) need Markov with K = 20 and the net bound at u = 16 | **worse** (100, 128 vs 20, 16) | M |
| proof: spectral error | `mr_remainder_bound` (2√(40𝓜)+256+16√(20𝓜)+3/2+√(40𝓜) ≤ C_R), `mr_spectral_error` (θ/4+θ/4+θ/4+θ/16 < θ) | `Linear.conditionedSeed_nearParseval_centred` (quadratic-form version); identity from `eq_mr_identity` | = in substance | M |
| proof: graph | `mr_graph_coupling` (√2+16 ≤ 18, 36t), `mr_graph_exceptional` (n/50, 0.85n), def `mrExceptional`, `mr_graph_whitened` (6aθ²t⁴, n/20, 0.8n, a/2 ≤ P_ii ≤ 2a, ∑ ≤ 1/4) | `Linear.tangentSeed_operator_norm_sq_le_op`, `Linear.tangentSeed_gram_coupling_le_op`, `exists_polar_normalization_row_gram`; the library uses different thresholds (17/20, γ/20, `4γ`) in `Linear.manyRow_seed_correction_of_budgets` | different/worse | M |
| proof: barrier | `mr_barrier` ((7/3)/(0.3γ)+8/(3a) ≤ C_mix/(at²)) | `lem_core` + `lem_core_i` (ϑ = 0.3) + `lem_core_iii` (α = a). The library `Linear.correction_of_exceptional_set_barrier` uses ϑ via `core_of_counts'` with 4/5 | different | S–M |
| proof: seed | `mr_seed` (42t²d, 2aδ ≤ 2θat² ≤ at²/(2Θ)), `mr_final_cost` (3Θt²d = (12Θ/θ)ηd) | `lem_align_polar(_half)`, `eq_mr_contract` | new wiring | S–M |
| `thm:manyrow` | `thm_manyrow`, `thm_manyrow_explicit` | `Linear.manyRow_equalRowBound` (B = 10^40, c = 10^-60, C = 10^17) | **worse** constants; explicit recipe new | M (wiring of the claims above) |

### §5 Moderate-row seed (`Moderate.lean`, `ModerateSample.lean`, `ModerateSeed.lean`)

| Label | Lean name | Library route | lib | Eff |
|---|---|---|---|---|
| standing | `ModerateStanding` (a/2 ≤ p ≤ 3a/2, 2d ≤ n) | — | — | — |
| `𝓛`, `𝒞`, `𝖪` | defs `edgeVec`, `sqLaplacian`, `crossLaplacian`, `completeLaplacian`; `lap_facts` | `projectionLaplacian_eq_graph`, `graphLaplacian_quadratic`, `diagonalCommutator_frob_sq`; `Smooth.matrixQuadratic_graphLinearCross_eq` | = | S–M |
| `eq:lap-basic` | `eq_lap_basic` | elementary (`(x_i-x_j)² ≤ 2x_i²+2x_j²`, `(v+w)² ≥ ½v²-w²`) | new | S |
| `Y_Z` facts | `tangentY_facts`, def `tangentY` | `Linear.rowNormSq_tangent_horizontal`, `normalFrobVector_*` | = | S |
| `𝒜`, `𝒜^*` | `diagMap_adjoint`, def `diagMap` | `ambientNormal_norm_sq`, `ambientNormal_horizontal`, `normalFrobVector_inner` | = | S |
| `eq:S` | `eq_S` | `normalizedFisher_eq_normalized_laplacian`, `normalizedFisherEigenvalue_nonneg`, `normalizedFisherEigenvalue_le_one`, the trace lemma in NormalizedNormalMap | = | S–M |
| eigenbasis | `eigenbasis_facts` | `normalizedNormalFrame_eq`, `normalizedNormalCovariance_decomposition`, orthogonality lemmas in NormalizedNormalMap | = | M |
| `eq:finfty` | `eq_finfty` | `normalizedNormalPotential_abs_le` with `p = a/2` | = | S |
| Def. filtered covariance | `filteredCovariance`, `moderateNoise`; `moderateNoise_spec` | `Smooth.covariance_rational_formula`, `Smooth.factorRoot_sq`, `Smooth.factorRoot_transpose`, `Smooth.moderateNoiseFrame` horizontality | = | S |
| `lem:filter`(a) | `lem_filter_a` | `Smooth.covariance_le_one`, `Smooth.retainedWeight_le_one`, `Smooth.kernel_modeSum` | = | S–M |
| `lem:filter`(b) | `lem_filter_b` | `Smooth.normalDiagonalNoiseDual` (SmoothGaussianEvents) + rational calculus on `S` | = (exact formula new) | M |
| `lem:filter`(c) | `lem_filter_c` | `Smooth.residual_decomposition`, `Smooth.residual_trace_le`, `Smooth.residual_inverse_sqrt_sum_le`, `Smooth.residualWeight_div_le` | = | S |
| remark after `lem:filter` | `rem_filter_rational`, `rem_filter_hard` | elementary; hard-cutoff sum as for `residual_inverse_sqrt_sum_le` | new | S |
| `eq:q-cs` | `eq_q_cs` | `Linear.horizontalQuadraticDiagonal_add`, `Linear.horizontalQuadraticCross_abs_le` (weighted; optimise `s`), `Linear.horizontalQuadraticDiagonal_abs_le`, `Linear.rowNormSq_tangent_horizontal` | = | S |
| `lem:commutator`(a) | `lem_commutator_a` | `Linear.horizontalQuadraticDiagonal_ambientNormal`, `Linear.driftGamma_norm_le`, `projectionReflection_*` | = | S |
| `lem:commutator`(b) | `lem_commutator_b` | `ambientNormalTangent_eq`, `ambientNormalTangent_commutator`, `ambientNormalTangent_graphEnergy_le`; `T_{e_k}` bound in NormalBaseGraph (`baseNormalTangent*`) | = | S–M |
| `lem:mean` | `lem_mean`, defs `baseBias`, `driftMean`, `residualBias` | `Smooth.integral_horizontalQuadraticDiagonal_normalizedTangentNoise`, `Linear.driftMean_diagonal`, `horizontalQuadraticDiagonal_base_mean_abs_le` (**4ε/n**), `Linear.driftMean_horizontal`, `Linear.driftMean_norm_sq_le` | b₀: **better** (4ε/n vs 12ε/n); m_* = | S |
| proof of `lem:mean` | `lem_mean_unfiltered_base`, `lem_mean_base_bound` (8ε/a, 12ε), `lem_mean_residual` | `horizontalQuadraticDiagonal_base_sum_eq_laplacian`, NormalBaseMean, `normalizedNormalPotential_image_norm`, `Linear.driftMean_norm_le` | = | S–M |
| `rem:drift` | `rem_drift_formula`, `rem_drift_size` (√(a/2)/D) | formula: new (sum over the eigenbasis; kernel modes give `Γ_f = 0`); size from `Linear.driftMean_norm_sq_le` | new / = | M / S |
| `lem:expected-graph` | `lem_expected_graph` | `Smooth.expected_retainedTangent_expansion` gives **80/d**, for mean-zero `x` | **worse** (80/d vs 8/d) | M |
| proof of `lem:expected-graph` | `lem_expected_graph_unfiltered`, `lem_expected_graph_losses` (2/a·2 = 8/a, 8/d, 8/(aμ), 8/ρ), def `unfilteredNoise` | NormalBaseGraph, `normalTangentFrame_graphEnergy_le`, TangentCovarianceGraph | base-loss constant is where the library loses (80) | M |
| remark after `thm:moderate` | `rem_after_moderate` | `diagMap_adjoint` + Cauchy–Schwarz + `Linear.driftMean_norm_sq_le` (the library also has `Smooth.normalResidualDiagonal_dual_energy_le`) | = | S |
| `𝔅` | `residualRowLoss`, `delta0` (1/6400), `bMax` (2/δ₀), `exceptionalSet`; `exceptionalSet_card` | `Smooth.positiveResidualRowLoss` and `Smooth.moderateVarianceExceptional` use threshold a/10⁶ and give `card ≤ 2·10⁶` | **worse** (2·10⁶ vs 12800) | S–M |
| (S1)–(S4) | `SampleS1`–`SampleS4`, `GoodSample` | `Smooth.ModerateGaussianSample` | different (see below) | — |
| `lem:sample` | `lem_sample`, `lem_sample_explicit`, `sampleH` (1/500), `SampleThreshold` | `Smooth.exists_moderateGaussianSample_with_cross` gives ‖Z‖ < 128, rows < 600a and 2000a, the S3 analogue with h = 1/1000 and fraction 1/20, and the S4 analogue only as *global* events (d ≥ 4·10¹⁵(log n+2)) | **worse** (128/600a/2000a vs 16/3a/800a; S4 different) | L |
| proof (S1) | `sample_S1` (2·5ⁿe^{-8n}, c = 1/4, (√(3a)+16√(3a/2))² ≤ 800a) | `gaussian_matrix_operator_net_tail`; `lem_gauss_a` with u = 2a | worse → new | M |
| proof (S2) | `sample_S2` (3ρa/(2n), 2(2n)^{-3}, ‖𝖬_i‖ ≤ 1, ‖𝖬_i‖_F² ≤ 2(d+np_i²) ≤ 7d, c = 1/56), def `quadraticCoefficient` | SmoothGaussianThresholds (`normalDiagonalNoiseDual`), `Smooth.horizontalQuadraticCoefficient` (SmoothQuadraticTail) | different | M |
| proof (S3) | `sample_S3_unfiltered_scalar` (a/8), `sample_S3_counts` (24, 3(…), 45/n, 1440n/d, 32δ₀n), `sample_S3_variance` (0.0065n, 0.01n, 0.99n, a/(16n)), `sample_S3_smallball` (0.01+7h, 4/(h√d)), `sample_S3_numerics` (0.04, 0.95n) | SmoothDenseVariance (`retainedTangentVarianceGood`), `affineGaussian_smallCoordinateFraction_tail_covariance`, `integral_gaussianSoftIndicator_affine_le`, `stdGaussian_affine_smallBall` | different thresholds | L |
| proof (S4) | `sample_S4_cross` (2/(at²), 2/n, 16b/d, 16b/(dη'²)), `sample_S4_square` (3a, 12a/n, 8/n², 20b²a²/d, 20b²/(dη'²)), defs `blockJ`, `blockOmega`, `blockXi` | new (paper: second moments only); the library has the global-event replacement (`centeredGraph` field, WhitenedGraphCross) | new | L |
| retraction defs | `retraction`, `driftedNoise`, `driftedFrame`, `retractionError`, `retractionRemainder`; `retraction_parseval` | `exists_horizontal_polar_retraction_taylor_uniform` (HorizontalTaylor), whose projection formula matches | = | S–M |
| `lem:retraction` | `lem_retraction`, `IsRetractionConstant` | `Linear.exists_drifted_retraction` gives C_E = 20000 for (a), but (b) only as `≤ at²/3.2·10⁸` under `t² ≤ 10⁻²⁴` and `t²‖m‖² ≤ a/10⁷⁸` (i.e. D huge), and the remainder `10¹² a t³ + a t²/10³⁵`; `Linear.drift_diagonal_bound` for (d) | **different/worse** (needs D ≥ 12 only, and the paper form `at²(D⁻²+C_E t²)`) | M–L |
| proof of `lem:retraction` | `lem_retraction_aux` (1/24, 17, 17√d, 2√a, 17√(3a/2), 2a/ρ, 289t², 18, 4√a), `lem_retraction_error`, `lem_retraction_expansion`, `lem_retraction_drift_split`, `lem_retraction_terms` (6D, 12ε/n, 40/D, 1/(2D²)) | HorizontalTaylor, DriftRetraction, DriftAlgebra | = in form, constants new | M |
| `lem:seed-graph` | `lem_seed_graph`, `lem_seed_graph_explicit`, `SeedGraphConclusion`, `coreConstant` (10(1+b_max)/h²+32√b_max) | the library route: `moderate_retracted_graph_comparison` (global gap a t²/32), `moderate_dense_core_after_correction`, `Linear.frameBarrier_of_core_and_gap` (γ/5, 9λ/10, b/λ), `Linear.moderate_barrier_numerics` | **different/worse** | L |
| proof of `lem:seed-graph` | `seed_graph_core` (0.05n, 0.9n), `seed_graph_block` (¼·9/10−1/16 ≥ 1/8, at²/8, at²/32), `seed_graph_barrier` (ϑ = 0.4, λ = at²/32) | `lem_core`, `lem_core_i`, `lem_core_ii`, `eq_lap_basic`, `lem_expected_graph`, (S4) | new | M–L |
| proof of `thm:moderate` | `modTheta` (max{2,C_core,C_E}), `modK0` (12Θ), `modEtaPrime` (min{1/32,1/(12Θ)}), `modCm` (36Θ²), `ModerateChoice`, `moderate_choice_exists`, `moderate_drift_numerics` (D ≥ 500Θ ⇒ 40/D+1/(2D²) ≤ 1/(12Θ)), `moderate_seed` (6/(12Θ) = 1/(2Θ), 3Θt²d = 36Θ²εd) | real arithmetic + `cor_seed` | new | M |
| `thm:moderate` | `thm_moderate`, `thm_moderate_explicit` (target `Linear.ModerateParsevalBound`) | `Linear.moderateParsevalBound` (A = 10¹³⁰, ε₀ = 10⁻¹³⁰, C = 10⁴⁶) | **worse** constants; recipe new | M (wiring) |

### §6 Assembly (`Assembly.lean`)

| Label | Lean name | Library route | lib | Eff |
|---|---|---|---|---|
| interfaces | `ManyRowWith`, `EqualRowBoundWith`, `ProjectionBoundWith`, `PaulsenBoundWith`; `manyRowWith_of_explicit` | — | — | S |
| `prop:equalrow` | `prop_equalrow`, `prop_equalrow_explicit` (C₀ = max{d₀,C_*,4/c_*,2+4C_m,16/ε₀}) | `Linear.low_density_small_error` (∃ C, not explicit), `quadratic_equalRowBound`, `Linear.exists_log_threshold` | = in structure; explicit formula new | M |
| proof of `prop:equalrow` | `prop_equalrow_d0`, `prop_equalrow_cases`, `prop_equalrow_polar` | `Linear.exists_log_threshold`, `exists_polar_normalization` (gives `IsNearlyEqualNorm (2η)` and `η²d`) | = | S |
| `thm:projection` | `thm_projection`, `thm_projection_explicit` (C_P = max{4,2+8C₀}), `thm_projection_steps` | complement: `projectionLaplacian_complement`-style facts, `ComplementReduction`; row normalisation `exists_equal_row_normalization` (RowNormalization); `projection_sqDistance_le_twice` | new wiring (the library derives projection *from* main) | M |
| `thm:main` | `thm_main`, `thm_main_explicit` (C = max{12,1+8C_P}), `thm_main_steps` | `exists_polar_normalization`, `lem_align` (isometry spanning `Q`: `ProjectionFactor`) | new wiring | M |
| chain | `thm_main_constant_chain` | composition of the above | — | S |

## Flagged issues (the paper text was not changed)

None of the paper's explicit numerical constants appears to be false: every arithmetic step of
every constant recipe was re-derived while writing the statements. The points below are implicit
hypotheses, edge cases or looseness. Where needed, the Lean statement makes the hypothesis
explicit.

1. **`def:barrier`: "`H(L) ∈ (0,∞]`" fails for `n = 1`.** The only `S` with `|S| ≥ 1/2` is
   `[1]`, and `ψ = 0` is an `S`-barrier, so `H(L) = 0`. This is harmless: nothing uses
   `H > 0` except the remark after `thm:balancing`, which assumes `n ≥ 2`.
   `barrierConstant` takes values in `[0,∞]`.
2. **`lem:rowmoments` depends on the standing assumption `n ≥ B d²`.** Both `∑_i aδ_i = 1+m/n ≤ 2`
   and the display "`m ≤ dim Sym_d ≤ d² ≤ n`" use `d² ≤ n`; without it `m/n` can exceed 1. The
   Lean statements add `(d:ℝ)^2 ≤ n`.
3. **`lem:gauss`(b) and (c) are false for negative `u`.** For `u < 0` and large `|u|` the
   left-hand side is 1 while the right-hand side is less than 1. The paper means `u > 0`; Lean
   adds `0 ≤ u`. Part (a) is true for all `u` (in Lean, `x/0 = 0` makes the degenerate cases
   trivially true).
4. **`prop:equalrow` uses `ε₀ ≤ 1/2`, which `thm:moderate` does not state.** The polar step
   needs `η ≤ ε₀/4 ≤ 1/2`, and the bound `2dη² ≤ 2ηd` needs `η ≤ 1`. Both come from the Section 5
   preamble "`ε₀ ≤ ½`". With a large `ε₀` the stated
   `C₀ = max{…,16/ε₀}` is not justified by the argument given. `prop_equalrow_explicit` and
   `thm_main_constant_chain` therefore assume `ε₀ ≤ 1/2`, which the proof of `thm:moderate`
   guarantees.
5. **The choice of `A` in the proof of `thm:moderate` uses `2d ≤ n`.** "`d ≥ A log(2n)` implies
   `b_max ≤ n/10`" is only true together with `2d ≤ n` from the context.
   `ModerateChoice.A_large` includes it. Similarly, "`d ≥ A_{η'} log(2n)` implies `d ≥ 10⁶`" needs
   `n ≥ 1`, because Lean has `log 0 = 0`; `SampleThreshold` includes `1 ≤ n`.
6. **The unnamed constants `c` in `lem:sample` can be made explicit.** Through `lem:gauss`(a)
   they are `c = 1/4` in (S1), from `min{…} ≥ 2d` and the factor 1/8, and `c = 1/56` in (S2),
   from `η' ≤ 1/32 < 7`. `sample_S1` and `sample_S2` state these values.
7. **Some bounds in the proof of `lem:sample` are loose but correct.** "the row depends on `Z`
   through a linear map of norm `≤ 2`" holds with norm 1, since
   `‖Y_i‖² = ‖Zᵀv_i‖²+‖Zu_i‖² ≤ ‖Z‖_F²`. Likewise "`(Y_ij)_{i<j}` have covariance `⪯ (2/n)I`"
   holds with `1/n`. Neither affects the result.
8. **The net bound in (S1) relies on `Z ∈ ℝ^{(n-d)×d}`.** That gives `5^{(n-d)+d} = 5ⁿ`. Applied
   naively in ambient coordinates (`n×d`) the bound becomes `5^{n+d}`; the statement keeps `5ⁿ`,
   which is true. Note for provers.
9. **The meaning of "`m_*` does not depend on the choice of eigenbasis" (`rem:drift`).** In the
   closed formula `(D_p^{-1/2}(I-S)(ρI+S)^{-1}D_p^{-1/2})∘(I-2P)`, the kernel modes of `S` enter
   with weight `1/ρ`. They are absent from the defining sum `∑_{μ>0}`. The formula is still
   correct, because for `Sy = 0` one has `N_f = 0` and hence `Γ_f = B_fN_f - N_fA_f = 0`; the
   proof should use exactly this.
10. **`thm:balancing` and `cor:seed` need `d ≥ 1` and `n ≥ 1` in Lean.** Lean's `x/0 = 0` would
    make `Θ/(a t²) = 0` when `d = 0`, so `cor_seed` assumes `0 < d ≤ n`. `thm_balancing_steps`
    assumes `0 < n` so that `max`/`min` (`⨆`/`⨅`) are the true extrema.
11. **Interpretive paragraphs are not formalised.** These are the identification of `H(L_P)` with
    a random-walk hitting time (the paragraph after `def:barrier`) and the heuristics of
    "The plan" and the "Scales" table. Their quantitative content is covered by
    `lem:retraction`(d).

## Suggested order of work

1. Quick wins (S): `lem_energy`, `lem_median`, `lem_core`, `lem_core_i`, `lem_core_iii`,
   `lem_HM`, `cor_exist*`, `lem_gauss_b`, `lem_gauss_c`, `eq_mr_identity`, `eq_mr_contract`,
   `lem_filter_c`, `eq_q_cs`, `lem_commutator_a`, `lem_mean`, the scalar lemmas (`*_scalar`,
   `*_numerics`, `mr_constants`), and the bridges.
2. Constant improvements over the library (M):
   * `thm_balancing` (15/4), and then `cor_seed` (3Θ);
   * `lem_core_ii` (√b/λ);
   * `lem_gauss_a` (1/8);
   * `lem_expected_graph` (8/d);
   * `lem_Q` (m/n);
   * `lem_rowmoments_gaussian` (exact 4th moment);
   * `lem_mr_dense` (0.9(n-1)).
3. The main new work (L): `lem_sample` with the paper's (S1)–(S4) thresholds, in particular
   (S4) from second moments; `lem_retraction` for all `D ≥ 12`; `lem_seed_graph` (block-only
   gap); then the wiring of `thm_manyrow_explicit`, `thm_moderate_explicit`, `prop_equalrow_explicit`,
   `thm_projection_explicit` and `thm_main_explicit`.
