# Statement blueprint: A linear bound for the Paulsen problem

The current proof is in `Paulsen/Paper/`, namespace `Paulsen.Paper`, with supporting results in the rest of `Paulsen/`. Its statements carry the constants of the paper. All statements are proved; `Audit.lean` checks axioms and the actual dependencies of the final theorems. This document describes the completed development, not a list of proposed proof tasks.

## Main route

`thm_main` ← `thm_projection` ← `prop_equalrow` ← the bounded-rank, many-row and moderate-row arguments. Both seed arguments use the static balancing theorem.

The main statements are `Paulsen.Paper.thm_main : Paulsen.SharpPaulsenBound` and `Paulsen.Paper.thm_projection : Paulsen.SharpProjectionBound`. Their explicit constant chain is

```
C₀ = max{d₀, C_*, 4/c_*, 2+4C_m, 16/ε₀}
C_P = max{4, 2+8C₀}
C = max{12, 1+8C_P}.
```

It is recorded in `prop_equalrow_explicit`, `thm_projection_explicit`, `thm_main_explicit` and `thm_main_constant_chain`.

## Paper labels and Lean statements

Names below are in `Paulsen.Paper`. A wildcard means the named theorem and its explicitly stated component or proof-step theorems. Helper files have the same topic prefix.

| Paper label or item | Lean statements | Main module |
|---|---|---|
| ENP definitions, `eq:nearly` | `def_enp`, `eq_nearly_iff` | `Intro` |
| `thm:main`, `thm:projection` | `thm_main`, `thm_projection`, their `_explicit` forms | `Assembly` |
| `rem:optimal` | `optimalExample`, `rem_optimal` | `Intro`, `IntroAuxOptimal` |
| `lem:align` | `lem_align`, `lem_align_orthogonal`, `lem_align_polar*` | `Toolbox` |
| `lem:energy` | `lem_energy` | `Toolbox` |
| `lem:potential` | `lem_potential`, `scalingPotential`, `scaledProjection`, `scaledDiagonal` | `Toolbox` |
| `lem:scaling-ineq` | `lem_scaling_ineq`, `sqrtScaledDiagonal` | `Toolbox` |
| `def:barrier` | `barrierConstant`, `barrierConstant_le_iff`, `barrier_connected` | `Toolbox` |
| `lem:median` | `lem_median` | `Toolbox` |
| `eq:kkt` | `eq_kkt`, `balancingPotential` | `Toolbox` |
| `thm:balancing` | `thm_balancing`, `thm_balancing_steps` | `Toolbox` |
| Balancing remarks | `rem_balancing_forces_positive`, `rem_balancing_general` | `Toolbox` |
| `lem:core` | `lem_core`, `lem_core_i`, `lem_core_ii`, `lem_core_iii` | `Toolbox` |
| `rem:poisson` | `rem_poisson_barrier_le_twice`, `rem_poisson_le_barrier` | `Toolbox` |
| `def:seed`, `cor:seed` | `IsSeed`, `cor_seed`, `cor_seed_proof` | `Toolbox` |
| `lem:HM`, `cor:exist` | `lem_HM`, `cor_exist`, `cor_exist_trivial` | `Bounded` |
| `thm:manyrow` | `thm_manyrow`, `thm_manyrow_explicit` | `ManyRowProof` |
| Many-row noise, `eq:mr-noise` | `mr_noise_covariance`, `mr_codim_le`, `eq_mr_noise` | `ManyRow` |
| `lem:rowmoments` | `lem_rowmoments*` | `ManyRow` |
| `eq:mr-contract`, `eq:mr-identity` | `eq_mr_contract`, `eq_mr_identity` | `ManyRow` |
| `lem:Q` | `lem_Q` | `ManyRow` |
| `lem:remainder` | `lem_remainder*` | `ManyRow` |
| `lem:mr-dense` | `lem_mr_dense*` | `ManyRow` |
| `thm:moderate` | `thm_moderate`, `thm_moderate_explicit` | `ModerateSeed` |
| `eq:lap-basic` | `eq_lap_basic` | `Moderate` |
| `eq:S`, `eq:finfty` | `eq_S`, `eq_finfty`, `eigenbasis_facts` | `Moderate` |
| Resolvent covariance, `lem:filter` | `filteredCovariance`, `moderateNoise_spec`, `lem_filter_a`, `lem_filter_b`, `lem_filter_c` | `Moderate` |
| `eq:q-cs` | `eq_q_cs` | `Moderate` |
| `lem:commutator` | `lem_commutator_a`, `lem_commutator_b` | `Moderate` |
| `lem:mean` | `lem_mean`, `lem_mean_unfiltered_base`, `lem_mean_base_bound`, `lem_mean_residual` | `Moderate` |
| `rem:drift` | `rem_drift_formula`, `rem_drift_size` | `Moderate` |
| `lem:expected-graph` | `lem_expected_graph`, `lem_expected_graph_unfiltered`, `lem_expected_graph_losses` | `Moderate` |
| `lem:sample`, (S1)–(S4) | `lem_sample`, its explicit form and `sample_S1`–`sample_S4` | `ModerateSample` |
| `lem:retraction` | `lem_retraction*` | `ModerateSeed` |
| `lem:seed-graph` | `lem_seed_graph`, its explicit form and `seed_graph_*` | `ModerateSeed` |
| `prop:equalrow` | `prop_equalrow`, `prop_equalrow_explicit` | `Assembly` |
| `lem:gauss` | `lem_gauss_a`, `lem_gauss_a_correlated`, `lem_gauss_b`, `lem_gauss_c` | `Gaussian` |

The long proofs also state their constant choices and intermediate quantitative estimates as separate lemmas. `All.lean` imports the paper modules.

## The trace and resolvent simplifications

`ScalingTraceDistance.lean` proves the weighted trace identity for a projection and its diagonally scaled subspace. `ToolboxAuxScaled.lean` connects it to `scaledProjection`. The balancing theorem uses this route to obtain cost `1/2`, with general cost `βH / (2(1−βH))`; the former scaling-energy estimate is unnecessary. The seed corollary keeps its bound `3Θ`.

The moderate-row Gaussian has covariance `ρ(ρI+Ω)⁻¹` on the horizontal tangent space. In ambient coordinates it is `ρ Q (ρI+Ω)⁻¹`, where `Q` projects onto that space. The `Resolvent*` modules construct its Gaussian factor and establish its covariance, operator bounds, residual variance and drift. The paper module `ResolventTangent` supplies graph and row adapters.

Writing `α = (1+ρ)⁻¹`, the loss is `αΩ + R`. Its residual and drift are `α` times their earlier counterparts. Reusing identities for this scaling does not reuse the earlier Gaussian: `moderateNoise` now comes from the new resolvent factor. The expected-graph proof uses positivity of the covariance-to-graph map and `I−C ⪯ Ω/ρ`, giving loss `8L/(dρ)`. The previous eigenmode-by-eigenmode graph estimate is unnecessary.

`IntroAuxOptimal.lean` proves the optimality example through a projection trace deficit. The resulting frame-distance lower bound is `εd/4`.

## Encoding

- `Frame n d` is a real `n × d` matrix, whose rows are the frame vectors. `a = (d:ℝ)/n`; `p_i = rowNormSq U i`; `P = frameProjection U`; `L = projectionLaplacian P`.
- `opNorm` is the norm of the associated linear map. Loewner inequalities are often expressed as inequalities for `matrixQuadratic`.
- Supremum-norm bounds are pointwise bounds or arbitrary upper bounds. Conclusions are monotone in these bounds.
- `Linear.HasBarrierBound w H` means `H(L) ≤ H`. `barrierConstant` takes values in `[0,∞]`, including zero for the one-vertex graph. The identification with a random-walk hitting time is explanatory and is not formalised.
- Gaussian random variables are linear images of `stdGaussian (FrameVector n d)`. Expectations are Lebesgue integrals; positive probability means positive measure of the stated good-sample set.
- The many-row construction couples `conditionedNoise` and `rowNoise` using the same Gaussian input. Row normalisation, the centred remainder and the covariance estimates are proved for these variables.
- The moderate-row tangent is represented by the ambient matrix `H = VZ` with `UᵀH = 0`. `moderateNoise U ρ g = Resolvent.moderateNoiseFrame U ρ g`. Its tangent projection derivative is `tangentY U H = HUᵀ+UHᵀ`, and its diagonal map is `diagMap U H`.
- `driftMean U ρ = Resolvent.driftMean U ρ`. The base bias is `(α/n)L(p⁻¹)`; the residual bias is `diagMap U (driftMean U ρ)`.
- `invSqrt M` is continuous functional calculus for `x ↦ 1/√x`. The polar factor and retraction use this specified matrix, rather than an unspecified whitening.
- `d² ≤ n`, `u ≥ 0`, `ε₀ ≤ 1/2` and positivity of dimensions are stated wherever used.

## Verification

Run `lake build` and `lake env lean IndependentCheck.lean`. The former includes `Audit.lean`; the latter checks raw Mathlib restatements without project-specific definitions. See `final-audit.md` for the dates, outputs and limits of the recorded checks. The audit requires the paper statements and the new constructions in the final dependency cone, checks all project theorem axioms, and forbids specified older routes.
