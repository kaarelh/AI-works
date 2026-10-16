import NeuralGeneralization.GaussianResidualTrace
import NeuralGeneralization.WalshGaussianLaw

/-! Actual Walsh-feature Gaussian residual variances: the exceptional fraction
is bounded by twice sample count times the largest tail eigenvalue divided
by the population tail variance. -/
noncomputable section
open MeasureTheory ProbabilityTheory WithLp
open scoped BigOperators NNReal RealInnerProductSpace
namespace NeuralGeneralization.GaussianWalshResidual
open GaussianSignRegression GaussianResidualIndependence GaussianResidualTrace
variable {d : ℕ}

abbrev FeatureSpace (d : ℕ) := EuclideanSpace ℝ (Finset (Fin d))

def featureVector (w : Finset (Fin d) → ℝ) (x : ClippingCube d) : FeatureSpace d :=
  toLp 2 (fun S => Real.sqrt (w S) * walshCharacter S x)

theorem featureVector_norm_sq (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 ≤ w S)
    (x : ClippingCube d) : ‖featureVector w x‖ ^ 2 = ∑ S, w S := by
  rw [EuclideanSpace.real_norm_sq_eq]
  simp only [featureVector, PiLp.toLp_apply, mul_pow, walshCharacter_sq, mul_one,
    Real.sq_sqrt (hw _)]

theorem inner_featureVector (w : Finset (Fin d) → ℝ) (u : FeatureSpace d)
    (x : ClippingCube d) :
    ⟪u, featureVector w x⟫ = walshExpansion (fun S => Real.sqrt (w S) * u S) x := by
  simp only [featureVector, EuclideanSpace.inner_eq_star_dotProduct, dotProduct, walshExpansion]
  apply Finset.sum_congr rfl
  intro S hS
  simp
  ring

theorem average_inner_sq (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 ≤ w S)
    (u : FeatureSpace d) :
    (∑ x : ClippingCube d, ⟪u, featureVector w x⟫ ^ 2) / Fintype.card (ClippingCube d) =
      ∑ S, w S * u S ^ 2 := by
  simp_rw [inner_featureVector]
  change uniformCubeMean (fun x => walshExpansion (fun S => Real.sqrt (w S) * u S) x ^ 2) = _
  rw [uniformCubeMean_walshExpansion_sq]
  simp only [mul_pow, Real.sq_sqrt (hw _)]

theorem average_inner_sq_le (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 ≤ w S)
    (ell : ℝ) (hmax : ∀ S, w S ≤ ell) (u : FeatureSpace d) :
    (∑ x : ClippingCube d, ⟪u, featureVector w x⟫ ^ 2) / Fintype.card (ClippingCube d) ≤
      ell * ‖u‖ ^ 2 := by
  rw [average_inner_sq w hw, EuclideanSpace.real_norm_sq_eq, Finset.mul_sum]
  exact Finset.sum_le_sum (fun S hS => mul_le_mul_of_nonneg_right (hmax S) (sq_nonneg _))

def coordinateMaskLinear (T : Finset (Finset (Fin d))) : FeatureSpace d →ₗ[ℝ] FeatureSpace d where
  toFun u := toLp 2 (fun S => if S ∈ T then u S else 0)
  map_add' := by
    intro u v
    ext S
    by_cases hS : S ∈ T <;> simp [hS]
  map_smul' := by
    intro a u
    ext S
    by_cases hS : S ∈ T <;> simp [hS]

def coordinateMask (T : Finset (Finset (Fin d))) : FeatureSpace d →L[ℝ] FeatureSpace d :=
  (coordinateMaskLinear T).toContinuousLinearMap

theorem coordinateMask_apply (T : Finset (Finset (Fin d))) (u : FeatureSpace d)
    (S : Finset (Fin d)) : coordinateMask T u S = if S ∈ T then u S else 0 := rfl

theorem coordinateMask_contracts (T : Finset (Finset (Fin d))) (u : FeatureSpace d) :
    ‖coordinateMask T u‖ ≤ ‖u‖ := by
  have hs : ‖coordinateMask T u‖ ^ 2 ≤ ‖u‖ ^ 2 := by
    rw [EuclideanSpace.real_norm_sq_eq, EuclideanSpace.real_norm_sq_eq]
    apply Finset.sum_le_sum
    intro S hS
    rw [coordinateMask_apply]
    by_cases h : S ∈ T <;> simp [h, sq_nonneg]
  nlinarith [norm_nonneg (coordinateMask T u), norm_nonneg u]

theorem coordinateMask_featureVector (T : Finset (Finset (Fin d)))
    (w : Finset (Fin d) → ℝ) (x : ClippingCube d) :
    coordinateMask T (featureVector w x) = featureVector (maskCoefficients T w) x := by
  ext S
  rw [coordinateMask_apply]
  by_cases h : S ∈ T <;> simp [featureVector, maskCoefficients, h]

section Observations
variable {J : Type*} [Fintype J]

def maskedObservations (T : Finset (Finset (Fin d))) (A : J → Finset (Fin d) → ℝ) :
    J → Finset (Fin d) → ℝ := fun j => ofLp (coordinateMask T (toLp 2 (A j)))

theorem coordinateMask_span (T : Finset (Finset (Fin d))) (A : J → Finset (Fin d) → ℝ)
    (u : FeatureSpace d) (hu : u ∈ observationSpan A) :
    coordinateMask T u ∈ observationSpan (maskedObservations T A) := by
  induction hu using Submodule.span_induction with
  | mem u hu =>
    obtain ⟨j, rfl⟩ := hu
    exact observation_mem (maskedObservations T A) j
  | zero => simp
  | add u v hu hv ihu ihv => simpa only [map_add] using
      (observationSpan (maskedObservations T A)).add_mem ihu ihv
  | smul a u hu ihu => simpa only [map_smul] using
      (observationSpan (maskedObservations T A)).smul_mem a ihu

/-- The exact Gaussian posterior residual variance dominates the residual
variance after exposing every feature outside the selected Fourier tail. -/
theorem masked_residual_le (T : Finset (Finset (Fin d))) (w : Finset (Fin d) → ℝ)
    (A : J → Finset (Fin d) → ℝ) (x : ClippingCube d) :
    residualVariance (observationSpan (maskedObservations T A))
      (featureVector (maskCoefficients T w) x) ≤
        residualVariance (observationSpan A) (featureVector w x) := by
  rw [← coordinateMask_featureVector]
  exact residualVariance_contraction _ _ (coordinateMask T) (coordinateMask_contracts T)
    (coordinateMask_span T A) _

/-- The paper's finite-sample residual-variance exceptional-set bound, for
arbitrary linear observations and an explicit finite Walsh tail. -/
theorem small_variance_fraction_le (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 ≤ w S)
    (T : Finset (Finset (Fin d))) (ell : ℝ) (hell : 0 ≤ ell)
    (hmax : ∀ S ∈ T, w S ≤ ell)
    (htau : 0 < ∑ S ∈ T, w S) (A : J → Finset (Fin d) → ℝ) :
    ((Finset.univ.filter (fun x : ClippingCube d =>
      residualVariance (observationSpan A) (featureVector w x) < (∑ S ∈ T, w S) / 2)).card : ℝ) /
        Fintype.card (ClippingCube d) ≤ 2 * Fintype.card J * ell / (∑ S ∈ T, w S) := by
  classical
  have hwT (S : Finset (Fin d)) : 0 ≤ maskCoefficients T w S := by
    unfold maskCoefficients
    split_ifs
    · exact hw S
    · exact le_rfl
  have hmaxT (S : Finset (Fin d)) : maskCoefficients T w S ≤ ell := by
    unfold maskCoefficients
    split_ifs with h
    · exact hmax S h
    · exact hell
  have hsum : (∑ S, maskCoefficients T w S) = ∑ S ∈ T, w S := by
    simp only [maskCoefficients]
    convert Fintype.sum_ite_mem T w using 1
    apply Finset.sum_congr rfl
    intro S hS
    by_cases h : S ∈ T <;> simp [h]
  have hb := small_residual_fraction_le
    (observationSpan (maskedObservations T A)) (featureVector (maskCoefficients T w))
    ell (∑ S ∈ T, w S) htau
    (fun x => by rw [featureVector_norm_sq _ hwT, hsum])
    (average_inner_sq_le _ hwT ell hmaxT)
  have hsubset : (Finset.univ.filter (fun x : ClippingCube d =>
      residualVariance (observationSpan A) (featureVector w x) < (∑ S ∈ T, w S) / 2)) ⊆
    Finset.univ.filter (fun x : ClippingCube d =>
      residualVariance (observationSpan (maskedObservations T A))
        (featureVector (maskCoefficients T w) x) < (∑ S ∈ T, w S) / 2) := by
    intro x hx
    exact Finset.mem_filter.mpr ⟨Finset.mem_univ _, (masked_residual_le T w A x).trans_lt
      (Finset.mem_filter.mp hx).2⟩
  apply le_trans (div_le_div_of_nonneg_right (Nat.cast_le.mpr (Finset.card_le_card hsubset))
    (Nat.cast_nonneg _))
  apply hb.trans
  apply div_le_div_of_nonneg_right _ htau.le
  apply mul_le_mul_of_nonneg_right _ hell
  exact mul_le_mul_of_nonneg_left (Nat.cast_le.mpr (finrank_observationSpan_le _)) (by norm_num)

end Observations
end NeuralGeneralization.GaussianWalshResidual
