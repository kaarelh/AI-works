import NeuralGeneralization.IIDLaw
import Mathlib.Probability.Moments.SubGaussian
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Ring

/-! # MGF and tail bounds for an actual product sample law -/
noncomputable section
open scoped BigOperators ENNReal NNReal
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.CompressionSampling
variable {Ω α : Type*} [MeasurableSpace Ω] [MeasurableSpace α]

/-- The two-sided Chernoff bound obtained from an actual sub-Gaussian MGF. -/
theorem subGaussian_abs_tail {μ : Measure Ω} [IsProbabilityMeasure μ]
    {X : Ω → ℝ} {c : ℝ≥0} (hX : HasSubgaussianMGF X c μ)
    {ε : ℝ} (hε : 0 ≤ ε) :
    μ.real {ω | ε ≤ |X ω|} ≤ 2 * Real.exp (-ε ^ 2 / (2 * (c : ℝ))) := by
  have heq : {ω | ε ≤ |X ω|} = {ω | ε ≤ X ω} ∪ {ω | ε ≤ -X ω} := by
    ext ω
    simp only [Set.mem_setOf_eq, Set.mem_union]
    constructor
    · intro h
      rcases le_total 0 (X ω) with hpos | hneg
      · exact Or.inl (by simpa only [abs_of_nonneg hpos] using h)
      · exact Or.inr (by simpa only [abs_of_nonpos hneg] using h)
    · rintro (h | h)
      · exact h.trans (le_abs_self _)
      · exact h.trans (neg_le_abs _)
  rw [heq]
  have hneg := hX.neg.measure_ge_le hε
  have hpos := hX.measure_ge_le hε
  have hu := measureReal_union_le (μ := μ) {ω | ε ≤ X ω} {ω | ε ≤ -X ω}
  simp only [Pi.neg_apply] at hneg
  linarith

/-- The centered sum of an actual independent sample has a certified MGF bound. -/
theorem iid_bounded_centeredSum_subGaussian (ν : Measure α) [IsProbabilityMeasure ν]
    (M : ℕ) (f : α → ℝ) (hf : Measurable f)
    {B : ℝ} (hB : 0 ≤ B) (hbound : ∀ x, |f x| ≤ B) :
    HasSubgaussianMGF
      (fun ω => (∑ i, f (ω i)) - (M : ℝ) * ∫ x, f x ∂ν)
      ((M : ℝ≥0) * (Real.toNNReal B) ^ 2) (iidSamples ν M) := by
  let c : ℝ≥0 := (‖B - -B‖₊ / 2) ^ 2
  have hsub : HasSubgaussianMGF (fun x => f x - ∫ y, f y ∂ν) c ν := by
    apply hasSubgaussianMGF_of_mem_Icc hf.aemeasurable
    exact ae_of_all ν (fun x => abs_le.mp (hbound x))
  have hindep : iIndepFun
      (fun i : Fin M => fun ω : Fin M → α => f (ω i) - ∫ y, f y ∂ν)
      (iidSamples ν M) := by
    exact iIndepFun_pi (fun _ : Fin M => (hf.sub_const _).aemeasurable)
  have hsubi (i : Fin M) : HasSubgaussianMGF
      (fun ω : Fin M → α => f (ω i) - ∫ y, f y ∂ν) c (iidSamples ν M) := by
    have hmap : (iidSamples ν M).map (fun ω => ω i) = ν :=
      (measurePreserving_eval (fun _ : Fin M => ν) i).map_eq
    have hb : HasSubgaussianMGF (fun x => f x - ∫ y, f y ∂ν) c
        ((iidSamples ν M).map (fun ω => ω i)) := by
      rw [hmap]
      exact hsub
    exact HasSubgaussianMGF.of_map (μ := iidSamples ν M)
      (Y := fun ω : Fin M → α => ω i) (measurable_pi_apply i).aemeasurable hb
  have hsum := HasSubgaussianMGF.sum_of_iIndepFun hindep
    (s := Finset.univ) (fun i _ => hsubi i)
  have hc : (c : ℝ) = B ^ 2 := by
    change (‖B - -B‖ / 2) ^ 2 = B ^ 2
    rw [Real.norm_eq_abs, abs_of_nonneg (by linarith : 0 ≤ B - -B)]
    ring
  have hcN : c = (Real.toNNReal B) ^ 2 := by
    apply NNReal.coe_injective
    simpa only [NNReal.coe_pow, Real.coe_toNNReal B hB] using hc
  simpa only [Finset.sum_sub_distrib, Finset.sum_const, Finset.card_univ,
    Fintype.card_fin, nsmul_eq_mul, hcN] using hsum

/-- Hoeffding's inequality for a bounded function on actual IID draws. -/
theorem iid_bounded_sum_tail (ν : Measure α) [IsProbabilityMeasure ν]
    (M : ℕ) (f : α → ℝ) (hf : Measurable f)
    {B ε : ℝ} (hB : 0 ≤ B) (hbound : ∀ x, |f x| ≤ B) (hε : 0 ≤ ε) :
    (iidSamples ν M).real
      {ω | ε ≤ |(∑ i, f (ω i)) - (M : ℝ) * ∫ x, f x ∂ν|} ≤
      2 * Real.exp (-ε ^ 2 / (2 * (M : ℝ) * B ^ 2)) := by
  have htail := subGaussian_abs_tail
    (iid_bounded_centeredSum_subGaussian ν M f hf hB hbound) hε
  simpa only [NNReal.coe_mul, NNReal.coe_natCast, NNReal.coe_pow, Real.coe_toNNReal B hB, mul_assoc] using htail

end NeuralGeneralization.CompressionSampling
