import NeuralGeneralization.GaussianSignAngle
import NeuralGeneralization.GaussianTanhSaturation

/-! # The arcsine covariance of arbitrary finite Gaussian linear forms -/
noncomputable section
open MeasureTheory ProbabilityTheory WithLp
open scoped BigOperators NNReal

namespace NeuralGeneralization.GaussianSignKernel
open GaussianReadout GaussianTanhSaturation

variable {I I' : Type*} [Fintype I] [Fintype I']

def pairFeatures (c d : I → ℝ) (i : I) (b : Bool) : ℝ := if b then d i else c i

/-- Equality of the three actual covariance entries determines the sign
moment, even at singular covariance matrices. -/
theorem signCovariance_eq_of_gram (c d : I → ℝ) (c' d' : I' → ℝ)
    (v : ℝ≥0) (hc : (∑ i, c i ^ 2) = ∑ i, c' i ^ 2)
    (hd : (∑ i, d i ^ 2) = ∑ i, d' i ^ 2)
    (hcd : (∑ i, c i * d i) = ∑ i, c' i * d' i) :
    signCovariance v c d = signCovariance v c' d' := by
  have hg : ∀ x y, (v : ℝ) * gram (pairFeatures c d) x y =
      (v : ℝ) * gram (pairFeatures c' d') x y := by
    intro x y
    cases x <;> cases y
    · simpa only [gram, pairFeatures, Bool.false_eq_true, ↓reduceIte, ← pow_two] using
        congrArg ((v : ℝ) * ·) hc
    · simpa only [gram, pairFeatures, Bool.false_eq_true, ↓reduceIte] using
        congrArg ((v : ℝ) * ·) hcd
    · simpa only [gram, pairFeatures, Bool.false_eq_true, ↓reduceIte, mul_comm] using
        congrArg ((v : ℝ) * ·) hcd
    · simpa only [gram, pairFeatures, ↓reduceIte, ← pow_two] using
        congrArg ((v : ℝ) * ·) hd
  let F : EuclideanSpace ℝ Bool → ℝ := fun z => Real.sign (z false) * Real.sign (z true)
  have hF : Measurable F := by
    dsimp [F]
    apply Measurable.mul
    · exact TanhSaturation.measurable_sign.comp
        (show Continuous (fun z : EuclideanSpace ℝ Bool => z false) by fun_prop).measurable
    · exact TanhSaturation.measurable_sign.comp
        (show Continuous (fun z : EuclideanSpace ℝ Bool => z true) by fun_prop).measurable
  have h := congrArg (fun μ : Measure (EuclideanSpace ℝ Bool) => ∫ z, F z ∂μ)
    (law_eq_of_gram_eq (pairFeatures c d) (pairFeatures c' d') v v hg)
  rw [integral_map (continuous_readout _).measurable.aemeasurable hF.aestronglyMeasurable,
    integral_map (continuous_readout _).measurable.aemeasurable hF.aestronglyMeasurable] at h
  simpa only [F, readout, pairFeatures, signCovariance, Bool.false_eq_true,
    ↓reduceIte, mul_comm] using h

theorem canonical_signCovariance {ρ : ℝ} (hρlo : -1 ≤ ρ) (hρhi : ρ ≤ 1) :
    signCovariance 1 (![0, 1] : Fin 2 → ℝ) ![-Real.sqrt (1 - ρ ^ 2), ρ] =
      (2 / Real.pi) * Real.arcsin ρ := by
  have hp := measurePreserving_finTwoArrow (gaussianReal 0 1)
  have h := hp.integral_comp' (fun p : ℝ × ℝ =>
    Real.sign p.2 * Real.sign (ρ * p.2 - Real.sqrt (1 - ρ ^ 2) * p.1))
  have heq : signCovariance 1 (![0, 1] : Fin 2 → ℝ) ![-Real.sqrt (1 - ρ ^ 2), ρ] =
      ∫ p : ℝ × ℝ, Real.sign p.2 *
        Real.sign (ρ * p.2 - Real.sqrt (1 - ρ ^ 2) * p.1) ∂GaussianPolar.standardPair := by
    simpa only [signCovariance, GaussianPolar.standardPair, Fin.sum_univ_two, Matrix.cons_val_zero, Matrix.cons_val_one,
      Matrix.cons_val_fin_one, zero_mul, one_mul, zero_add, neg_mul, sub_eq_add_neg, add_comm,
      MeasurableEquiv.finTwoArrow, MeasurableEquiv.piFinTwo_apply] using h
  rw [heq]
  exact GaussianSignAngle.gaussian_sign_arcsin hρlo hρhi

/-- The Gaussian sign kernel for arbitrary unit coefficient vectors. -/
theorem unit_signCovariance (c d : I → ℝ)
    (hc : (∑ i, c i ^ 2) = 1) (hd : (∑ i, d i ^ 2) = 1) :
    signCovariance 1 c d = (2 / Real.pi) * Real.arcsin (∑ i, c i * d i) := by
  let ρ : ℝ := ∑ i, c i * d i
  have hcs := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ c d
  rw [hc, hd, one_mul] at hcs
  have hρsq : ρ ^ 2 ≤ 1 := hcs
  have hρlo : -1 ≤ ρ := by nlinarith
  have hρhi : ρ ≤ 1 := by nlinarith
  have hroot : Real.sqrt (1 - ρ ^ 2) ^ 2 = 1 - ρ ^ 2 :=
    Real.sq_sqrt (by linarith)
  have h := signCovariance_eq_of_gram c d (![0, 1] : Fin 2 → ℝ)
    ![-Real.sqrt (1 - ρ ^ 2), ρ] 1
    (by simpa using hc)
    (by simpa [Fin.sum_univ_two, hroot] using hd)
    (by simp [ρ])
  exact h.trans (canonical_signCovariance hρlo hρhi)

/-- Positive rescaling of either scalar Gaussian field leaves its sign
covariance unchanged. -/
theorem signCovariance_div (v : ℝ≥0) (c d : I → ℝ) {a b : ℝ}
    (ha : 0 < a) (hb : 0 < b) :
    signCovariance v (fun i => c i / a) (fun i => d i / b) = signCovariance v c d := by
  unfold signCovariance
  apply integral_congr_ae
  filter_upwards [] with w
  simp only [div_eq_inv_mul, mul_assoc, ← Finset.mul_sum,
    GaussianSignAngle.sign_pos_mul (inv_pos.mpr ha),
    GaussianSignAngle.sign_pos_mul (inv_pos.mpr hb)]

/-- The exact arcsine kernel of arbitrary nondegenerate finite Gaussian
linear forms. Joint degeneracy and correlation `±1` remain allowed. -/
theorem signCovariance_arcsin (c d : I → ℝ)
    (hc : 0 < ∑ i, c i ^ 2) (hd : 0 < ∑ i, d i ^ 2) :
    signCovariance 1 c d = (2 / Real.pi) *
      Real.arcsin ((∑ i, c i * d i) /
        (Real.sqrt (∑ i, c i ^ 2) * Real.sqrt (∑ i, d i ^ 2))) := by
  let a := Real.sqrt (∑ i, c i ^ 2)
  let b := Real.sqrt (∑ i, d i ^ 2)
  have ha : 0 < a := Real.sqrt_pos.mpr hc
  have hb : 0 < b := Real.sqrt_pos.mpr hd
  have ha2 : a ^ 2 = ∑ i, c i ^ 2 := Real.sq_sqrt hc.le
  have hb2 : b ^ 2 = ∑ i, d i ^ 2 := Real.sq_sqrt hd.le
  have hcu : (∑ i, (c i / a) ^ 2) = 1 := by
    simp only [div_pow, ← Finset.sum_div, ← ha2]
    exact div_self (pow_ne_zero _ ha.ne')
  have hdu : (∑ i, (d i / b) ^ 2) = 1 := by
    simp only [div_pow, ← Finset.sum_div, ← hb2]
    exact div_self (pow_ne_zero _ hb.ne')
  have h := unit_signCovariance (fun i => c i / a) (fun i => d i / b) hcu hdu
  rw [signCovariance_div 1 c d ha hb] at h
  simp only [div_mul_div_comm, ← Finset.sum_div] at h
  exact h

end NeuralGeneralization.GaussianSignKernel
