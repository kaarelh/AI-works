import NeuralGeneralization.WalshGaussianEnergy
import NeuralGeneralization.GaussianConditionalEnergy
import NeuralGeneralization.GaussianConditionalSubspace
import NeuralGeneralization.GaussianConeRadial

/-! # Actual posterior population energy of Fourier bands

The normalized Fourier energy is identified with a diagonal Gaussian
quadratic form before the conditioning estimate is applied. The event may
depend on all field coordinates.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.GaussianBandEnergy
open FiniteDifferential GaussianAngularFields GaussianFieldTilt
variable {d : ℕ}

def bandEnergy (H : Finset (Finset (Fin d))) (z : ClippingCube d → ℝ) : ℝ :=
  uniformCubeMean (fun x => walshProjection H z x^2)

lemma walshCoefficients_expansion (c : Finset (Fin d) → ℝ) (S : Finset (Fin d)) :
    walshCoefficients (walshExpansion c) S = c S := by
  unfold walshCoefficients uniformCubeMean
  rw [walshExpansion_pairing]
  simp

lemma field_eq_expansion (w : Finset (Fin d) → ℝ) (z : Finset (Fin d) → ℝ) :
    fieldLinear (WalshGaussianEnergy.matrix w) z = walshExpansion (fun S => Real.sqrt (w S)*z S) := by
  funext x
  rw [fieldLinear_apply]
  unfold WalshGaussianEnergy.matrix WalshGaussianLaw.features walshExpansion
  apply Finset.sum_congr rfl
  intro S hS
  ring

lemma bandEnergy_field (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 ≤ w S)
    (H : Finset (Finset (Fin d))) (z : Finset (Fin d) → ℝ) :
    bandEnergy H (fieldLinear (WalshGaussianEnergy.matrix w) z) =
      ∑ S, (if S ∈ H then w S else 0)*z S^2 := by
  classical
  rw [field_eq_expansion]
  unfold bandEnergy walshProjection
  rw [show walshCoefficients (walshExpansion (fun S => Real.sqrt (w S)*z S)) =
    (fun S => Real.sqrt (w S)*z S) from funext (walshCoefficients_expansion _)]
  rw [uniformCubeMean_walshExpansion_sq]
  apply Finset.sum_congr rfl
  intro S hS
  by_cases hS : S ∈ H
  · simp [maskCoefficients, hS, mul_pow, Real.sq_sqrt (hw S)]
  · simp [maskCoefficients, hS]

@[fun_prop] lemma measurable_bandEnergy (H : Finset (Finset (Fin d))) :
    Measurable (bandEnergy H) := by
  classical
  have he (z : ClippingCube d → ℝ) : bandEnergy H z = ∑ S, maskCoefficients H (walshCoefficients z) S^2 :=
    uniformCubeMean_walshExpansion_sq _
  rw [show bandEnergy H = (fun z => ∑ S, maskCoefficients H (walshCoefficients z) S^2) from funext he]
  apply Finset.measurable_sum
  intro S hS
  by_cases hS : S ∈ H
  · simp only [maskCoefficients, if_pos hS]
    unfold walshCoefficients uniformCubeMean
    fun_prop
  · simp only [maskCoefficients, if_neg hS, zero_pow (by norm_num : 2 ≠ 0)]
    exact measurable_const

lemma integrable_bandEnergy_cond
    (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 ≤ w S)
    (H : Finset (Finset (Fin d))) (E : Set (ClippingCube d → ℝ)) (hE : MeasurableSet E)
    (hEpos : fieldLaw (WalshGaussianEnergy.matrix w) E ≠ 0) :
    Integrable (bandEnergy H) (cond (fieldLaw (WalshGaussianEnergy.matrix w)) E) := by
  let F := fieldLinear (WalshGaussianEnergy.matrix w)
  have hF : Measurable F := F.continuous.measurable
  have hmass : standardLaw (Finset (Fin d)) (F ⁻¹' E)=fieldLaw (WalshGaussianEnergy.matrix w) E :=
    (Measure.map_apply hF hE).symm
  have hp : standardLaw (Finset (Fin d)) (F ⁻¹' E) ≠ 0 := by rwa [hmass]
  have hi : Integrable (fun z : Finset (Fin d) → ℝ =>
      ∑ S, (if S ∈ H then w S else 0)*z S^2)
      (cond (standardLaw (Finset (Fin d))) (F ⁻¹' E)) := by
    apply integrable_finsetSum
    intro S hS
    exact (((GaussianConeRadial.integrable_eval_sq S).restrict).smul_measure
      (ENNReal.inv_ne_top.mpr hp)).const_mul _
  have hc := GaussianConditionalSubspace.map_cond_preimage
    (standardLaw (Finset (Fin d))) F hF E hE
  change (cond (standardLaw (Finset (Fin d))) (F ⁻¹' E)).map F =
    cond (fieldLaw (WalshGaussianEnergy.matrix w)) E at hc
  rw [← hc]
  apply (integrable_map_measure (measurable_bandEnergy H).aestronglyMeasurable hF.aemeasurable).mpr
  simpa only [Function.comp_def, F, bandEnergy_field w hw H] using hi

/-- The full conditional population-band estimate, with exact trace and
maximum normalized eigenvalue. -/
theorem conditional_bandEnergy_le
    (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 ≤ w S)
    (H : Finset (Finset (Fin d))) (ell : ℝ) (hell : 0 < ell)
    (hmax : ∀ S ∈ H, w S ≤ ell)
    (E : Set (ClippingCube d → ℝ)) (hE : MeasurableSet E)
    (hEpos : fieldLaw (WalshGaussianEnergy.matrix w) E ≠ 0) :
    (∫ z, bandEnergy H z ∂cond (fieldLaw (WalshGaussianEnergy.matrix w)) E) ≤
      2*(∑ S ∈ H, w S)+4*ell*Real.log (1/(fieldLaw (WalshGaussianEnergy.matrix w)).real E) := by
  classical
  let F := fieldLinear (WalshGaussianEnergy.matrix w)
  have hF : Measurable F := F.continuous.measurable
  have hmass : standardLaw (Finset (Fin d)) (F ⁻¹' E)=fieldLaw (WalshGaussianEnergy.matrix w) E :=
    (Measure.map_apply hF hE).symm
  have hp : standardLaw (Finset (Fin d)) (F ⁻¹' E) ≠ 0 := by rwa [hmass]
  have hh := conditional_gaussian_diagonal_energy (fun _ : Finset (Fin d) => (1:ℝ≥0))
    (fun S => if S ∈ H then w S else 0) (fun S => by split_ifs; exact hw S; exact le_refl 0)
    ell hell (fun S => by split_ifs with hS <;> simp only [NNReal.coe_one, mul_one]; exact hmax S hS; exact hell.le)
    (F ⁻¹' E) hp
  have hc := GaussianConditionalSubspace.map_cond_preimage
    (standardLaw (Finset (Fin d))) F hF E hE
  change (cond (standardLaw (Finset (Fin d))) (F ⁻¹' E)).map F =
    cond (fieldLaw (WalshGaussianEnergy.matrix w)) E at hc
  rw [← hc, integral_map hF.aemeasurable (measurable_bandEnergy H).aestronglyMeasurable]
  simp_rw [show ∀ z, bandEnergy H (F z)=∑ S, (if S ∈ H then w S else 0)*z S^2 from bandEnergy_field w hw H]
  have hr : (standardLaw (Finset (Fin d))).real (F ⁻¹' E)=
      (fieldLaw (WalshGaussianEnergy.matrix w)).real E := congrArg ENNReal.toReal hmass
  change (∫ z, (∑ S, (if S ∈ H then w S else 0)*z S^2) ∂cond (standardLaw (Finset (Fin d))) (F ⁻¹' E)) ≤ _ at hh
  simp only [NNReal.coe_one, mul_one] at hh
  change (Measure.pi fun _ : Finset (Fin d) => gaussianReal 0 (1:ℝ≥0)).real (F ⁻¹' E)=_ at hr
  rw [hr] at hh
  simpa only [Fintype.sum_ite_mem] using hh

end NeuralGeneralization.GaussianBandEnergy
