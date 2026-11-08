# ReLU rail atom formalization: statement correspondence

Status: the arbitrary affine full-transversal norm and stability, retained-code stability, and concrete whole-network bounds are kernel-checked. This record does not by itself assert completion of the online posterior lower bound.

The implementation uses the repository's actual Boolean cube, Walsh characters and `walshCoefficients`. Incoming energy is the explicit sum of coordinate squares, not the default supremum norm on a function type. No atom norm, Fourier representation, balanced-ray estimate, or sampling theorem is postulated.

## Final endpoints

`OnlineLowerReluRailAtom.full_rail_atom_norm` applies to `p ≥ 2` pairs of even rails. The first length is `P i ≥ 2`; the second is `r i + 2`, with `r i` even. Every length is at least `R`, their within-pair absolute differences are at most `Δ`, and `R ≥ 6Δ`. For arbitrary real bias and arbitrary physical incoming weights, it proves

```
Στ cost(τ) |Walsh(ReLU(bias + ⟨u,x⟩), support(τ))|
  ≤ sqrt(bias² + Σi u_i²).
```

The sum runs over the actual finite set of all transversals. `samplerSupport` is the union of the chosen physical rails. `samplerTransversalCost` is the exact balanced parity cost `sqrt(degree)/κ_degree`, with the binomial normalization proved in the scalar modules.

`OnlineLowerReluRailStability.full_rail_atom_stability` assumes additionally a common upper rail length `U`, with `U ≥ 2`, `R > 0`, and `U ≤ 2R`. It produces an actual physical coordinate vector `v`, a transversal `τ`, and `c ≥ 0` such that

```
|v_i| = if i ∈ support(τ) then c else 0,
bias² + Σi (u_i-v_i)² ≤ 48 U ρ (ρ-Q),
ρ = sqrt(bias² + Σi u_i²),
Q = the full weighted transversal mass above.
```

The vector's coordinate signs are inherited from the incoming weights. The theorem includes the energy of the discarded bias. Its witness may lie on any full transversal; restriction to the retained logical code is a separate, explicit transfer.

`OnlineLowerFamilyNorm.Family.affine_atom_retained_norm`, supplied by the sign/conditioning agent, composes the norm endpoint with actual logical-to-transversal support and cost identities. It establishes the retained mass bound for the explicit family when its even baseline satisfies `R ≥ 36`.

`OnlineLowerFamilyRetainedStability.Family.actual_row_retained_stability` supplies the literal first hidden layer's downward projection error with constant `2^16 * p^2 * R^4`. Its retained-versus-omitted split uses the actual balanced ray's saturation coefficient and the proved coefficient Lipschitz inequality.

`OnlineLowerFamilyNetwork.Family.network_bounds` is unconditional for the explicit family with even `R ≥ 36` and every `N > 0`. For the actual shallow network it proves logical weighted cost at most `B = networkVariationBudget`, and downward squared residual at most `stabilityBudget * B * (B - logicalCost)`. The budget is the existing model's weighted parameter energy divided by `2 sqrt(d)`. This endpoint has no Fourier, atom-norm, sampling, calibration, or network-error premise.

## Dependency correspondence

| Mathematical step | Checked implementation |
| --- | --- |
| Integrable representation of absolute value and ReLU | `OnlineLowerReluFourier.weighted_relu_cosine_integral` |
| Literal finite-cube cosine character expansion | `OnlineLowerReluCosineProduct.walsh_cosine_frequency_even` |
| Actual Walsh coefficient integral | `OnlineLowerReluWalshIntegral.relu_walsh_integral_even` |
| Positive potential dominates arbitrary bias | `relu_walsh_abs_le_potential` |
| Removing unused coordinates and inserting coordinate signs | `supportPotential_zero_unused`, `supportPotential_abs_weights` |
| Simultaneous replacement of every rail by a sampled coordinate | `OnlineLowerReluBlockPotential.blockCodePotential_square_le_sample_mean` |
| Actual finite product-law energy preservation | `OnlineLowerReluSamplingEnergy.blockEnergy_sample_average` |
| Independent rail moments | `uniformBlockAverage_mul_coordinates` |
| Exact randomized minimum for balanced physical atoms | `OnlineLowerSamplerMinimum.actual_relu_randomized_minimum` and `OnlineLowerSamplerPhase.sampler_potential_mass_bound` |
| Correct marginal estimate only for positive length increments | `OnlineLowerSamplerOpposite.sampler_opposite_mass_bound` |
| Weighted cost comparison | `OnlineLowerSamplerWeighted.sampler_weighted_projection` |
| Arbitrary dominant sides and signs | `OnlineLowerSamplerOrientation.sampler_arbitrary_balanced_norm` |
| Concrete balanced sampled ray | `OnlineLowerSamplerRay.sampler_balanced_ray_exists` |
| Deterministic signed coordinate rounding | `OnlineLowerSamplingDistance.sampling_signed_distance` |
| Squared potential deficit to actual signed mass deficit | `OnlineLowerReluRailStability.block_signed_distance_le_square_deficit` |
| Bias and norm-deficit conversion | `OnlineLowerReluAtomClosure.affine_distance_from_square_deficit` |
| Actual neuron L2 Lipschitz estimate | `OnlineLowerReluLipschitz.relu_neuron_l2_difference_le` |
| Coordinate coefficient Lipschitz estimate | `relu_walsh_difference_sq_le` |
| Exact Fourier vanishing outside a physical support | `relu_walsh_eq_zero_outside_support` |

The Fourier normalization is defined as the positive finite real integral `fourierAbsConstant`. Its numerical value is unnecessary: the same proved positive normalization appears in every integral identity and cancels in the exact finite-cube balanced coefficient comparison.

The square-mean stability proof does not divide by a coefficient, ray gain, norm, or deficit. Consequently zero atoms, zero balanced gain, and zero Fourier mass are covered by the stated endpoints without separate omitted branches.

## Verification

Direct Lean 4.32 checks produced the corresponding `.olean` files for the final atom and stability modules. `CheckOnlineLowerReluAnalysis.lean` prints axioms for the analytic chain and the four full-rail endpoints. Every checked endpoint reports only Lean's standard `propext`, `Classical.choice`, and `Quot.sound`; there is no `sorryAx` or additional mathematical axiom.

The audit output is recorded at `/workspace/nnbayes-improve-lean-2026-11-08/foundation-axiom-audit.log`.

## Scope still composed elsewhere

The retained-code ray-versus-zero argument, downward Fourier projection estimate, and network Cauchy–Schwarz transfer are composed in the checked `Family.network_bounds` endpoint and included in its axiom audit. Physical calibration and the Gaussian posterior/mistake-count argument are separate team modules; this record does not replace their final composition or its own axiom check. The ordinary-tanh support primitives remain conditional on their explicitly named intrinsic sharp-parity hypothesis; they are not used as assumptions in the ReLU atom endpoints.
