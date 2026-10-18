import NeuralGeneralization.RobustEntropyMoments
import NeuralGeneralization.RobustEntropyChain
import NeuralGeneralization.NetworkSpectralTail
import NeuralGeneralization.RobustModel
import Mathlib.Analysis.InnerProductSpace.PiL2

/-!
# Actual Gaussian block laws and posterior block moments

All block distributions are pushforwards of the concrete finite neural-network
prior.  The posterior law is arbitrary; its actual relative entropy is the
only probabilistic hypothesis.
-/

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators NNReal

namespace NeuralGeneralization.RobustCompressionBlockMoments
open ConcreteModel

variable {d N r : ℕ}

def standardizedWeights (σ : ℝ) (w : Weights d N r) : Weights d N r :=
  fun i => whiten w i / σ

theorem measurable_standardizedWeights (σ : ℝ) :
    Measurable (standardizedWeights (d := d) (N := N) (r := r) σ) := by
  unfold standardizedWeights
  exact measurable_pi_lambda _ (fun i =>
    ((measurable_pi_apply i).comp (continuous_whiten d N r).measurable).div_const σ)

theorem smallPrior_standardized (hd : 0 < d) (hN : 0 < N) {σ : ℝ} (hσ : 0 < σ) :
    (smallPrior d N r σ).map (standardizedWeights σ) =
      Measure.pi (fun _ : WeightIndex d N r => gaussianReal 0 1) := by
  have hscale : Measurable (fun u : Weights d N r => fun i => u i / σ) := by fun_prop
  change (smallPrior d N r σ).map
    ((fun u : Weights d N r => fun i => u i / σ) ∘ whiten) = _
  rw [← Measure.map_map hscale (continuous_whiten d N r).measurable,
    map_smallPrior_whiten hd hN hσ,
    Measure.pi_map_pi (f := fun (_ : WeightIndex d N r) (z : ℝ) => z / σ)
      (fun i => (measurable_id.div_const σ).aemeasurable)]
  congr 1
  funext i
  rw [gaussianReal_map_div_const, zero_div]
  congr 1
  apply NNReal.coe_injective
  simp only [NNReal.coe_div, Real.coe_toNNReal _ (sq_nonneg σ), NNReal.coe_mk,
    NNReal.coe_one]
  exact div_self (sq_pos_of_pos hσ).ne'

theorem standardized_subfamily_law {J : Type*} [Fintype J]
    (hd : 0 < d) (hN : 0 < N) {σ : ℝ} (hσ : 0 < σ)
    (e : J → WeightIndex d N r) (he : Function.Injective e) :
    (smallPrior d N r σ).map (fun w j => standardizedWeights σ w (e j)) =
      Measure.pi (fun _ : J => gaussianReal 0 1) := by
  have hmap : Measurable (fun u : Weights d N r => fun j => u (e j)) := by fun_prop
  change (smallPrior d N r σ).map
    ((fun u : Weights d N r => fun j => u (e j)) ∘ standardizedWeights σ) = _
  rw [← Measure.map_map hmap (measurable_standardizedWeights σ),
    smallPrior_standardized hd hN hσ]
  exact productGaussian_map_subfamily 1 e he

theorem first_standardized_law (hd : 0 < d) (hN : 0 < N) {σ : ℝ} (hσ : 0 < σ) :
    (smallPrior d N r σ).map
      (fun w (j : Fin N × Fin (d + 1)) => standardizedWeights σ w (Sum.inl j)) =
      Measure.pi (fun _ : Fin N × Fin (d + 1) => gaussianReal 0 1) :=
  standardized_subfamily_law hd hN hσ Sum.inl Sum.inl_injective

theorem readout_standardized_law (hd : 0 < d) (hN : 0 < N) {σ : ℝ} (hσ : 0 < σ) :
    (smallPrior d N r σ).map
      (fun w (i : Fin N) => standardizedWeights σ w (Sum.inr (Sum.inr i))) =
      Measure.pi (fun _ : Fin N => gaussianReal 0 1) :=
  standardized_subfamily_law hd hN hσ _ (Sum.inr_injective.comp Sum.inr_injective)

/-- Every selected original weight block has a width-uniform physical energy
bound.  Selecting a block uses data processing, never a separate posterior law.
-/
theorem block_energy_moment {J : Type*} [Fintype J]
    (hd : 0 < d) (hN : 0 < N) {σ K : ℝ} (hσ : 0 < σ) (hK : 0 ≤ K)
    (Q : Measure (Weights d N r)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (smallPrior d N r σ) ≤ ENNReal.ofReal (K / σ ^ 2))
    (e : J → WeightIndex d N r) (he : Function.Injective e) :
    Integrable (fun w => ∑ j, whiten w (e j) ^ 2) Q ∧
      (∫ w, ∑ j, whiten w (e j) ^ 2 ∂Q) ≤ 4 * K + 2 * σ ^ 2 * Fintype.card J := by
  let F : Weights d N r → J → ℝ := fun w j => standardizedWeights σ w (e j)
  have hF : Measurable F := measurable_pi_lambda _ (fun j =>
    (measurable_pi_apply (e j)).comp (measurable_standardizedWeights σ))
  letI : IsProbabilityMeasure (Q.map F) := Measure.isProbabilityMeasure_map hF.aemeasurable
  have hdata := RobustEntropy.klDiv_map_le Q (smallPrior d N r σ) hF
  rw [standardized_subfamily_law hd hN hσ e he] at hdata
  have hbudget := hdata.trans hKL
  have hfinite : klDiv (Q.map F) (Measure.pi fun _ : J => gaussianReal 0 1) ≠ ⊤ :=
    ne_top_of_le_ne_top ENNReal.ofReal_ne_top hbudget
  have hreal := ENNReal.toReal_mono ENNReal.ofReal_ne_top hbudget
  rw [ENNReal.toReal_ofReal (div_nonneg hK (sq_nonneg σ))] at hreal
  obtain ⟨hint, hmoment⟩ := RobustEntropyMoments.standard_gaussian_entropy_second_moment
    (Q.map F) hfinite
  have hmeas : Measurable (fun z : J → ℝ => ∑ j, z j ^ 2) := by fun_prop
  have hint' := (integrable_map_measure hmeas.aestronglyMeasurable hF.aemeasurable).mp hint
  have heq (w : Weights d N r) :
      (∑ j, whiten w (e j) ^ 2) = σ ^ 2 * ∑ j, F w j ^ 2 := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro j hj
    dsimp [F, standardizedWeights]
    field_simp
  have hi : Integrable (fun w => ∑ j, whiten w (e j) ^ 2) Q := by
    simp_rw [heq]
    exact hint'.const_mul (σ ^ 2)
  refine ⟨hi, ?_⟩
  rw [integral_map hF.aemeasurable hmeas.aestronglyMeasurable] at hmoment
  have hm : (∫ w, ∑ j, F w j ^ 2 ∂Q) ≤ 4 * (K / σ ^ 2) + 2 * Fintype.card J := by
    linarith
  simp_rw [heq]
  rw [integral_const_mul]
  apply (mul_le_mul_of_nonneg_left hm (sq_nonneg σ)).trans_eq
  field_simp

theorem readout_energy_moment (hd : 0 < d) (hN : 0 < N)
    {σ K : ℝ} (hσ : 0 < σ) (hK : 0 ≤ K) (hscale : (N : ℝ) * σ ^ 2 ≤ 1)
    (Q : Measure (Weights d N r)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (smallPrior d N r σ) ≤ ENNReal.ofReal (K / σ ^ 2)) :
    Integrable readoutEnergy Q ∧ (∫ w, readoutEnergy w ∂Q) ≤ 4 * K + 2 := by
  let e : Fin N → WeightIndex d N r := fun i => Sum.inr (Sum.inr i)
  have he : Function.Injective e := Sum.inr_injective.comp Sum.inr_injective
  obtain ⟨hi, hm⟩ := block_energy_moment hd hN hσ hK Q hKL e he
  have hfun : (fun w : Weights d N r => ∑ i, whiten w (e i) ^ 2) = readoutEnergy := by
    funext w
    exact (readout_energy_eq_whitened hd hN w).symm
  rw [hfun] at hi hm
  refine ⟨hi, ?_⟩
  simp only [Fintype.card_fin] at hm
  nlinarith

theorem readout_energy_abort_probability (hd : 0 < d) (hN : 0 < N)
    {σ K B : ℝ} (hσ : 0 < σ) (hK : 0 ≤ K) (hscale : (N : ℝ) * σ ^ 2 ≤ 1)
    (Q : Measure (Weights d N r)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (smallPrior d N r σ) ≤ ENNReal.ofReal (K / σ ^ 2)) (hB : 0 < B) :
    Q.real {w | B < readoutEnergy w} ≤ (4 * K + 2) / B := by
  obtain ⟨hi, hm⟩ := readout_energy_moment hd hN hσ hK hscale Q hKL
  have hmark := mul_meas_ge_le_integral_of_nonneg
    (Filter.Eventually.of_forall readoutEnergy_nonneg) hi B
  have hbound : Q.real {w | B ≤ readoutEnergy w} ≤ (4 * K + 2) / B := by
    apply (le_div_iff₀ hB).mpr
    nlinarith
  have hsub : {w : Weights d N r | B < readoutEnergy w} ⊆ {w | B ≤ readoutEnergy w} := by
    intro w hw
    change B < readoutEnergy w at hw
    change B ≤ readoutEnergy w
    exact hw.le
  exact (measureReal_mono (μ := Q) hsub).trans hbound

/-- The actual first-layer row in the physical standardized convention `t Z`.
The normalized Boolean input is divided by `sqrt d` when evaluating this row. -/
def firstPhysicalRow (w : Weights d N r) (i : Fin N) : EuclideanSpace ℝ (Fin (d + 1)) :=
  WithLp.toLp 2 (fun j => Real.sqrt (d : ℝ) * w (Sum.inl (i, j)))

theorem firstPhysicalRow_energy (hd : 0 < d) (hN : 0 < N) (w : Weights d N r) :
    (∑ i, ‖firstPhysicalRow w i‖ ^ 2) / (N : ℝ) =
      ∑ j : Fin N × Fin (d + 1), whiten w (Sum.inl j) ^ 2 := by
  have hNR : (N : ℝ) ≠ 0 := (Nat.cast_pos.mpr hN).ne'
  have hdR : (d : ℝ) ≠ 0 := (Nat.cast_pos.mpr hd).ne'
  simp only [EuclideanSpace.real_norm_sq_eq, firstPhysicalRow,
    mul_pow, Real.sq_sqrt (Nat.cast_nonneg d)]
  rw [Finset.sum_div, Fintype.sum_prod_type]
  apply Finset.sum_congr rfl
  intro i hi
  rw [Finset.sum_div]
  apply Finset.sum_congr rfl
  intro j hj
  rw [whiten, div_pow, coordinateScale_sq hd hN]
  simp only [smallVariance, one_pow, mul_one]
  field_simp

theorem first_physical_energy_moment (hd : 0 < d) (hN : 0 < N)
    {σ K : ℝ} (hσ : 0 < σ) (hK : 0 ≤ K) (hscale : (N : ℝ) * σ ^ 2 ≤ 1)
    (Q : Measure (Weights d N r)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (smallPrior d N r σ) ≤ ENNReal.ofReal (K / σ ^ 2)) :
    Integrable (fun w => (∑ i, ‖firstPhysicalRow w i‖ ^ 2) / (N : ℝ)) Q ∧
      (∫ w, (∑ i, ‖firstPhysicalRow w i‖ ^ 2) / (N : ℝ) ∂Q) ≤
        4 * K + 2 * ((d : ℝ) + 1) := by
  let e : Fin N × Fin (d + 1) → WeightIndex d N r := Sum.inl
  obtain ⟨hi, hm⟩ := block_energy_moment hd hN hσ hK Q hKL e Sum.inl_injective
  have hfun : (fun w : Weights d N r => (∑ i, ‖firstPhysicalRow w i‖ ^ 2) / (N : ℝ)) =
      (fun w => ∑ j : Fin N × Fin (d + 1), whiten w (e j) ^ 2) := by
    funext w
    exact firstPhysicalRow_energy hd hN w
  rw [hfun]
  refine ⟨hi, ?_⟩
  simp only [Fintype.card_prod, Fintype.card_fin, Nat.cast_mul, Nat.cast_add, Nat.cast_one] at hm
  have hh := mul_le_mul_of_nonneg_right hscale (by positivity : 0 ≤ 2 * ((d : ℝ) + 1))
  nlinarith

end NeuralGeneralization.RobustCompressionBlockMoments
