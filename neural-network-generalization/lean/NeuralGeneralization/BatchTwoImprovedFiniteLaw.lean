import NeuralGeneralization.BatchTwoImprovedGramProbability
import NeuralGeneralization.SamplingLaw

/-! # Probability-measure interpretation of weighted finite sampling -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators ENNReal
namespace NeuralGeneralization.BatchTwoImprovedWeightedSampling
open Classical
variable {α : Type*} [Fintype α] [MeasurableSpace α] [MeasurableSingletonClass α]

def finiteLaw (w : α → ℝ) (hw : ∀ x, 0 ≤ w x) (hm : ∑ x, w x = 1) : Measure α :=
  (PMF.ofFintype (fun x => ENNReal.ofReal (w x)) (by
    rw [← ENNReal.ofReal_sum_of_nonneg (fun x _ => hw x), hm, ENNReal.ofReal_one])).toMeasure

instance finiteLaw_probability (w : α → ℝ) (hw : ∀ x, 0 ≤ w x) (hm : ∑ x, w x = 1) :
    IsProbabilityMeasure (finiteLaw w hw hm) := by unfold finiteLaw; infer_instance

theorem finiteLaw_singleton (w : α → ℝ) (hw : ∀ x, 0 ≤ w x) (hm : ∑ x, w x = 1) (x : α) :
    finiteLaw w hw hm {x} = ENNReal.ofReal (w x) := by
  exact PMF.toMeasure_apply_singleton _ _ (measurableSet_singleton x)

theorem finiteLaw_integral (w : α → ℝ) (hw : ∀ x, 0 ≤ w x) (hm : ∑ x, w x = 1)
    (f : α → ℝ) : (∫ x, f x ∂finiteLaw w hw hm) = mean w f := by
  rw [integral_fintype Integrable.of_finite]
  simp only [Measure.real, finiteLaw_singleton, ENNReal.toReal_ofReal (hw _), smul_eq_mul, mean]

theorem finiteLaw_real_apply (w : α → ℝ) (hw : ∀ x, 0 ≤ w x) (hm : ∑ x, w x = 1)
    (s : Set α) : (finiteLaw w hw hm).real s = mean w (fun x => if x ∈ s then 1 else 0) := by
  rw [← integral_indicator_one (μ := finiteLaw w hw hm) (Set.toFinite s).measurableSet,
    finiteLaw_integral]
  rfl

theorem iid_finiteLaw_singleton (w : α → ℝ) (hw : ∀ x, 0 ≤ w x) (hm : ∑ x, w x = 1)
    (m : ℕ) (s : Fin m → α) :
    (Measure.pi (fun _ : Fin m => finiteLaw w hw hm)).real {s} = iidWeight w m s := by
  rw [Measure.real, Measure.pi_singleton]
  simp only [finiteLaw_singleton, ENNReal.toReal_prod, ENNReal.toReal_ofReal (hw _), iidWeight]

theorem iid_finiteLaw_integral (w : α → ℝ) (hw : ∀ x, 0 ≤ w x) (hm : ∑ x, w x = 1)
    (m : ℕ) (f : (Fin m → α) → ℝ) :
    (∫ s, f s ∂Measure.pi (fun _ : Fin m => finiteLaw w hw hm)) = mean (iidWeight w m) f := by
  rw [integral_fintype Integrable.of_finite]
  simp only [iid_finiteLaw_singleton, smul_eq_mul, mean]

theorem iid_finiteLaw_real_apply (w : α → ℝ) (hw : ∀ x, 0 ≤ w x) (hm : ∑ x, w x = 1)
    (m : ℕ) (s : Set (Fin m → α)) :
    (Measure.pi (fun _ : Fin m => finiteLaw w hw hm)).real s =
      mean (iidWeight w m) (fun x => if x ∈ s then 1 else 0) := by
  rw [← integral_indicator_one (μ := Measure.pi (fun _ : Fin m => finiteLaw w hw hm))
    (Set.toFinite s).measurableSet, iid_finiteLaw_integral]
  rfl

/-- The Gram estimate concerns the actual iid product probability measure. -/
theorem iid_badGram_probability_le (w : α → ℝ)
    (hw : ∀ x, 0 ≤ w x) (hmass : ∑ x, w x = 1)
    {m D : ℕ} (hm : 0 < m) (a : α → Fin D → ℝ)
    (V : ℝ) (hV : 0 < V) (ha : ∀ x, ∑ j, (a x j)^2 ≤ V)
    (hiso : ∀ v : Fin D → ℝ,
      mean w (fun x => (SquaredSampling.linearEvaluation (a x) v)^2) = ∑ j, (v j)^2)
    {η : ℝ} (hη : 0 < η) (hη1 : η ≤ 1)
    (hbudget : 256*(268435456:ℝ)^2*V*SquaredSampling.restrictionLog m D ≤ η^2*m) :
    (Measure.pi (fun _ : Fin m => finiteLaw w hw hmass)).real {s | badGram a s} ≤ η := by
  rw [iid_finiteLaw_real_apply]
  exact weighted_badGram_probability_le w hw hmass hm a V hV ha hiso hη hη1 hbudget

end NeuralGeneralization.BatchTwoImprovedWeightedSampling
