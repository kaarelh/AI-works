import NeuralGeneralization.TanhGaussianPrice

/-! Endpoint laws for singular finite Gaussian fields and their actual tilts. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.GaussianFieldTilt
open FiniteDifferential GaussianAngularFields GaussianAngularPrice TanhDifferential TanhGaussianPrice
variable {I J K : Type*} [Fintype I] [Fintype J] [Fintype K] [DecidableEq I]

def fieldLaw (A : I → J → ℝ) : Measure (I → ℝ) :=
  (standardLaw J).map (fieldLinear A)

instance fieldLaw_probability (A : I → J → ℝ) : IsProbabilityMeasure (fieldLaw A) :=
  Measure.isProbabilityMeasure_map (fieldLinear A).continuous.measurable.aemeasurable

omit [Fintype K] [DecidableEq I] in
theorem integral_fieldLaw (A : I → J → ℝ) (H : (I → ℝ) → ℝ) (hH : Measurable H) :
    (∫ x, H x ∂fieldLaw A) = ∫ z, H (fieldLinear A z) ∂standardLaw J :=
  integral_map (fieldLinear A).continuous.measurable.aemeasurable hH.aestronglyMeasurable

omit [DecidableEq I] in
theorem integral_leftField (A : I → J → ℝ) (H : (I → ℝ) → ℝ) :
    (∫ z : J ⊕ K → ℝ, H (leftField A z) ∂standardLaw (J ⊕ K)) =
      ∫ z, H (fieldLinear A z) ∂standardLaw J := by
  have h := (measurePreserving_sumPiEquivProdPi
    (fun _ : J ⊕ K => gaussianReal (0 : ℝ) (1 : ℝ≥0))).integral_comp'
      (fun z : (J → ℝ) × (K → ℝ) => H (fieldLinear A z.1))
  have hf (z : J ⊕ K → ℝ) :
      fieldLinear A ((MeasurableEquiv.sumPiEquivProdPi (fun _ : J ⊕ K => ℝ)) z).1 =
        leftField A z := by
    ext i
    simp only [fieldLinear_apply, leftField, MeasurableEquiv.coe_sumPiEquivProdPi]
    rfl
  simp_rw [hf] at h
  change (∫ z : J ⊕ K → ℝ, H (leftField A z) ∂standardLaw (J ⊕ K)) =
    ∫ z, H (fieldLinear A z.1) ∂(standardLaw J).prod (standardLaw K) at h
  exact h.trans (by simpa only [probReal_univ, one_smul] using
    integral_fun_fst (μ := standardLaw J) (ν := standardLaw K) (fun z => H (fieldLinear A z)))

omit [DecidableEq I] in
theorem integral_rightField (B : I → K → ℝ) (H : (I → ℝ) → ℝ) :
    (∫ z : J ⊕ K → ℝ, H (rightField B z) ∂standardLaw (J ⊕ K)) =
      ∫ z, H (fieldLinear B z) ∂standardLaw K := by
  have h := (measurePreserving_sumPiEquivProdPi
    (fun _ : J ⊕ K => gaussianReal (0 : ℝ) (1 : ℝ≥0))).integral_comp'
      (fun z : (J → ℝ) × (K → ℝ) => H (fieldLinear B z.2))
  have hf (z : J ⊕ K → ℝ) :
      fieldLinear B ((MeasurableEquiv.sumPiEquivProdPi (fun _ : J ⊕ K => ℝ)) z).2 =
        rightField B z := by
    ext i
    simp only [fieldLinear_apply, rightField, MeasurableEquiv.coe_sumPiEquivProdPi]
    rfl
  simp_rw [hf] at h
  change (∫ z : J ⊕ K → ℝ, H (rightField B z) ∂standardLaw (J ⊕ K)) =
    ∫ z, H (fieldLinear B z.2) ∂(standardLaw J).prod (standardLaw K) at h
  exact h.trans (by simpa only [probReal_univ, one_smul] using
    integral_fun_snd (μ := standardLaw J) (ν := standardLaw K) (fun z => H (fieldLinear B z)))

omit [DecidableEq I] in
theorem integral_angularField_zero (A : I → J → ℝ) (B : I → K → ℝ) (H : (I → ℝ) → ℝ) :
    (∫ z, H (angularField A B 0 z) ∂standardLaw (J ⊕ K)) =
      ∫ z, H (fieldLinear A z) ∂standardLaw J := by
  simp_rw [angularField_eq, Real.cos_zero, Real.sin_zero, one_smul, zero_smul, add_zero]
  exact integral_leftField A H

omit [DecidableEq I] in
theorem integral_angularField_pi_div_two (A : I → J → ℝ) (B : I → K → ℝ) (H : (I → ℝ) → ℝ) :
    (∫ z, H (angularField A B (Real.pi / 2) z) ∂standardLaw (J ⊕ K)) =
      ∫ z, H (fieldLinear B z) ∂standardLaw K := by
  simp_rw [angularField_eq, Real.cos_pi_div_two, Real.sin_pi_div_two, zero_smul, one_smul, zero_add]
  exact integral_rightField B H

def tiltedMoment (A : I → J → ℝ) (Γ : I → I → ℝ) (p q : I) : ℝ :=
  ∫ x, pairValue Real.tanh p q x ∂(fieldLaw A).tilted (potentialValue Real.tanh Γ)

omit [Fintype K] [DecidableEq I] in
theorem tiltedMoment_eq_ratio (A : I → J → ℝ) (Γ : I → I → ℝ) (p q : I) :
    tiltedMoment A Γ p q =
      (∫ z, pairValue Real.tanh p q (fieldLinear A z) *
        Real.exp (potentialValue Real.tanh Γ (fieldLinear A z)) ∂standardLaw J) /
      (∫ z, Real.exp (potentialValue Real.tanh Γ (fieldLinear A z)) ∂standardLaw J) := by
  rw [tiltedMoment, integral_tilted]
  simp only [smul_eq_mul]
  have heq (x : I → ℝ) :
      (Real.exp (potentialValue Real.tanh Γ x) /
        ∫ x, Real.exp (potentialValue Real.tanh Γ x) ∂fieldLaw A) * pairValue Real.tanh p q x =
      (pairValue Real.tanh p q x * Real.exp (potentialValue Real.tanh Γ x)) /
        (∫ x, Real.exp (potentialValue Real.tanh Γ x) ∂fieldLaw A) := by ring
  simp_rw [heq]
  rw [integral_div]
  rw [integral_fieldLaw A _ (by fun_prop), integral_fieldLaw A _ (by fun_prop)]

theorem angularTiltedMoment_zero (A : I → J → ℝ) (B : I → K → ℝ)
    (Γ : I → I → ℝ) (p q : I) :
    angularTiltedMoment A B Γ p q 0 = tiltedMoment A Γ p q := by
  rw [angularTiltedMoment, tiltedMoment_eq_ratio]
  congr 1
  · exact integral_angularField_zero A B (fun x => pairValue Real.tanh p q x *
      Real.exp (potentialValue Real.tanh Γ x))
  · exact integral_angularField_zero A B (fun x => Real.exp (potentialValue Real.tanh Γ x))

theorem angularTiltedMoment_pi_div_two (A : I → J → ℝ) (B : I → K → ℝ)
    (Γ : I → I → ℝ) (p q : I) :
    angularTiltedMoment A B Γ p q (Real.pi / 2) = tiltedMoment B Γ p q := by
  rw [angularTiltedMoment, tiltedMoment_eq_ratio]
  congr 1
  · exact integral_angularField_pi_div_two A B (fun x => pairValue Real.tanh p q x *
      Real.exp (potentialValue Real.tanh Γ x))
  · exact integral_angularField_pi_div_two A B (fun x => Real.exp (potentialValue Real.tanh Γ x))

/-- Price stability for the expectations under the actual Gaussian tilted
probability measures, for arbitrary finite linear fields including singular
ones. Only the covariance-entry discrepancy appears in the conclusion. -/
theorem tiltedMoment_stability (A : I → J → ℝ) (B : I → K → ℝ)
    (Γ : I → I → ℝ) (p q : I) {g e : ℝ} (hg : 0 ≤ g) (he : 0 ≤ e)
    (hΓ : couplingMass Γ ≤ g) (hCov : ∀ i k, |gram B i k - gram A i k| ≤ e) :
    |tiltedMoment B Γ p q - tiltedMoment A Γ p q| ≤ 8 * (1 + g) ^ 2 * e := by
  simpa only [angularTiltedMoment_zero, angularTiltedMoment_pi_div_two] using
    angularTiltedMoment_endpoints A B Γ p q hg he hΓ hCov

end NeuralGeneralization.GaussianFieldTilt
end
