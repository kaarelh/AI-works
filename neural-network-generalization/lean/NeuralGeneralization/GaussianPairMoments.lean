import NeuralGeneralization.GaussianSignKernel

/-!
# Two-dimensional reduction of Gaussian feature moments

An arbitrary finite collection of independent Gaussian coordinates reduces
exactly to two coordinates for a pair of output features. The explicit
coefficient formula is continuous even when the limiting pair is collinear.
-/

noncomputable section
open MeasureTheory ProbabilityTheory WithLp
open scoped BigOperators NNReal

namespace NeuralGeneralization.GaussianPairMoments
open GaussianReadout GaussianSignKernel GaussianTanhSaturation

variable {I I' : Type*} [Fintype I] [Fintype I']

def pairMoment (φ : ℝ → ℝ) (v : ℝ≥0) (c d : I → ℝ) : ℝ :=
  ∫ w, φ (∑ i, c i * w i) * φ (∑ i, d i * w i)
    ∂Measure.pi (fun _ : I => gaussianReal 0 v)

theorem pairMoment_eq_of_scaled_gram {φ : ℝ → ℝ} (hφ : Measurable φ)
    (c d : I → ℝ) (c' d' : I' → ℝ) (v v' : ℝ≥0)
    (hc : (v : ℝ) * (∑ i, c i ^ 2) = (v' : ℝ) * ∑ i, c' i ^ 2)
    (hd : (v : ℝ) * (∑ i, d i ^ 2) = (v' : ℝ) * ∑ i, d' i ^ 2)
    (hcd : (v : ℝ) * (∑ i, c i * d i) = (v' : ℝ) * ∑ i, c' i * d' i) :
    pairMoment φ v c d = pairMoment φ v' c' d' := by
  have hg : ∀ x y, (v : ℝ) * gram (pairFeatures c d) x y =
      (v' : ℝ) * gram (pairFeatures c' d') x y := by
    intro x y
    cases x <;> cases y
    · simpa only [gram, pairFeatures, Bool.false_eq_true, ↓reduceIte, ← pow_two] using hc
    · simpa only [gram, pairFeatures, Bool.false_eq_true, ↓reduceIte] using hcd
    · simpa only [gram, pairFeatures, Bool.false_eq_true, ↓reduceIte, mul_comm] using hcd
    · simpa only [gram, pairFeatures, ↓reduceIte, ← pow_two] using hd
  let F : EuclideanSpace ℝ Bool → ℝ := fun z => φ (z false) * φ (z true)
  have hF : Measurable F := by
    dsimp [F]
    apply Measurable.mul
    · exact hφ.comp (show Continuous (fun z : EuclideanSpace ℝ Bool => z false) by fun_prop).measurable
    · exact hφ.comp (show Continuous (fun z : EuclideanSpace ℝ Bool => z true) by fun_prop).measurable
  have h := congrArg (fun μ : Measure (EuclideanSpace ℝ Bool) => ∫ z, F z ∂μ)
    (law_eq_of_gram_eq (pairFeatures c d) (pairFeatures c' d') v v' hg)
  rw [integral_map (continuous_readout _).measurable.aemeasurable hF.aestronglyMeasurable,
    integral_map (continuous_readout _).measurable.aemeasurable hF.aestronglyMeasurable] at h
  simpa only [F, readout, pairFeatures, pairMoment, Bool.false_eq_true,
    ↓reduceIte, mul_comm] using h

/-- Exact passage from a common scalar variance to standard Gaussian inputs. -/
theorem pairMoment_standardize {φ : ℝ → ℝ} (hφ : Measurable φ)
    (c d : I → ℝ) (v : ℝ≥0) :
    pairMoment φ v c d = pairMoment φ 1
      (fun i => Real.sqrt (v : ℝ) * c i) (fun i => Real.sqrt (v : ℝ) * d i) := by
  apply pairMoment_eq_of_scaled_gram hφ
  · simp only [NNReal.coe_one, one_mul, mul_pow, ← Finset.mul_sum,
      Real.sq_sqrt v.coe_nonneg]
  · simp only [NNReal.coe_one, one_mul, mul_pow, ← Finset.mul_sum,
      Real.sq_sqrt v.coe_nonneg]
  · simp only [NNReal.coe_one, one_mul]
    have heq (i : I) : (Real.sqrt (v : ℝ) * c i) * (Real.sqrt (v : ℝ) * d i) =
        (v : ℝ) * (c i * d i) := by
      calc
        _ = Real.sqrt (v : ℝ) ^ 2 * (c i * d i) := by ring
        _ = _ := by rw [Real.sq_sqrt v.coe_nonneg]
    simp only [heq, ← Finset.mul_sum]

theorem tanh_pairMoment_standardize (c d : I → ℝ) (v : ℝ≥0) :
    pairMoment Real.tanh v c d = tanhCovariance 1 (Real.sqrt (v : ℝ)) c d := by
  rw [pairMoment_standardize ConcreteModel.tanh_lipschitzWith.continuous.measurable]
  simp only [pairMoment, tanhCovariance, mul_assoc, ← Finset.mul_sum]

theorem pairMoment_eq_of_gram {φ : ℝ → ℝ} (hφ : Measurable φ)
    (c d : I → ℝ) (c' d' : I' → ℝ) (v : ℝ≥0)
    (hc : (∑ i, c i ^ 2) = ∑ i, c' i ^ 2)
    (hd : (∑ i, d i ^ 2) = ∑ i, d' i ^ 2)
    (hcd : (∑ i, c i * d i) = ∑ i, c' i * d' i) :
    pairMoment φ v c d = pairMoment φ v c' d' := by
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
  let F : EuclideanSpace ℝ Bool → ℝ := fun z => φ (z false) * φ (z true)
  have hF : Measurable F := by
    dsimp [F]
    apply Measurable.mul
    · exact hφ.comp (show Continuous (fun z : EuclideanSpace ℝ Bool => z false) by fun_prop).measurable
    · exact hφ.comp (show Continuous (fun z : EuclideanSpace ℝ Bool => z true) by fun_prop).measurable
  have h := congrArg (fun μ : Measure (EuclideanSpace ℝ Bool) => ∫ z, F z ∂μ)
    (law_eq_of_gram_eq (pairFeatures c d) (pairFeatures c' d') v v hg)
  rw [integral_map (continuous_readout _).measurable.aemeasurable hF.aestronglyMeasurable,
    integral_map (continuous_readout _).measurable.aemeasurable hF.aestronglyMeasurable] at h
  simpa only [F, readout, pairFeatures, pairMoment, Bool.false_eq_true,
    ↓reduceIte, mul_comm] using h

def leftCoefficients (a : ℝ) : Fin 2 → ℝ := ![0, Real.sqrt a]

def rightCoefficients (a b c : ℝ) : Fin 2 → ℝ :=
  ![-Real.sqrt (b - c ^ 2 / a), c / Real.sqrt a]

theorem leftCoefficients_energy {a : ℝ} (ha : 0 ≤ a) :
    (∑ i, leftCoefficients a i ^ 2) = a := by
  simp [leftCoefficients, Fin.sum_univ_two, Real.sq_sqrt ha]

theorem residual_nonneg {a b c : ℝ} (ha : 0 < a) (hpsd : c ^ 2 ≤ a * b) :
    0 ≤ b - c ^ 2 / a := by
  apply sub_nonneg.mpr
  apply (div_le_iff₀ ha).mpr
  nlinarith

theorem rightCoefficients_energy {a b c : ℝ} (ha : 0 < a) (hpsd : c ^ 2 ≤ a * b) :
    (∑ i, rightCoefficients a b c i ^ 2) = b := by
  simp only [rightCoefficients, Fin.sum_univ_two, Matrix.cons_val_zero, Matrix.cons_val_one,
    Matrix.cons_val_fin_one, neg_sq, Real.sq_sqrt (residual_nonneg ha hpsd), div_pow,
    Real.sq_sqrt ha.le]
  ring

theorem coefficient_pairing {a b c : ℝ} (ha : 0 < a) :
    (∑ i, leftCoefficients a i * rightCoefficients a b c i) = c := by
  simp only [leftCoefficients, rightCoefficients, Fin.sum_univ_two, Matrix.cons_val_zero,
    Matrix.cons_val_one, Matrix.cons_val_fin_one, zero_mul, zero_add]
  field_simp [(Real.sqrt_pos.mpr ha).ne']

/-- Exact dimension reduction for the actual Gaussian moment. -/
theorem pairMoment_canonical {φ : ℝ → ℝ} (hφ : Measurable φ)
    (c d : I → ℝ) (v : ℝ≥0) (hc : 0 < ∑ i, c i ^ 2) :
    pairMoment φ v c d =
      pairMoment φ v (leftCoefficients (∑ i, c i ^ 2))
        (rightCoefficients (∑ i, c i ^ 2) (∑ i, d i ^ 2) (∑ i, c i * d i)) := by
  apply pairMoment_eq_of_gram hφ
  · exact (leftCoefficients_energy hc.le).symm
  · exact (rightCoefficients_energy hc (Finset.sum_mul_sq_le_sq_mul_sq Finset.univ c d)).symm
  · exact (coefficient_pairing hc).symm

end NeuralGeneralization.GaussianPairMoments
