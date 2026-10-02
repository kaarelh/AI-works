import Paulsen.Paper.ManyRowAux1

/-!
# Helpers for `Paulsen.Paper.ManyRowProof`: counting and Markov

Elementary facts used in the proof of `thm:manyrow` (not paper items):
* Markov's inequality at level `20`;
* counting large entries of a row from its squared norm;
* stability of counts of large entries under perturbation;
* `n e^{-c(n-1)} → 0` with an explicit threshold.
-/

namespace Paulsen.Paper

open Matrix MeasureTheory ProbabilityTheory Paulsen
open scoped BigOperators

noncomputable section

/-- Markov at level `20`: `E f ≤ b`, `f ≥ 0` gives `P(f > 20 b) ≤ 1/20`. -/
theorem mrx_markov20 {Ω : Type*} [MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]
    (f : Ω → ℝ) (hf0 : ∀ ω, 0 ≤ f ω) (hfi : Integrable f μ) {b : ℝ} (hE : ∫ ω, f ω ∂μ ≤ b) :
    μ.real {ω | 20 * b < f ω} ≤ 1 / 20 := by
  have hI0 : 0 ≤ ∫ ω, f ω ∂μ := integral_nonneg hf0
  have hb0 : 0 ≤ b := hI0.trans hE
  rcases hb0.lt_or_eq with hb | hb
  · have hm := mul_meas_ge_le_integral_of_nonneg (Filter.Eventually.of_forall hf0) hfi (20 * b)
    have hsub : {ω | 20 * b < f ω} ⊆ {ω | 20 * b ≤ f ω} := fun ω (h : 20 * b < f ω) => h.le
    have h1 := measureReal_mono (μ := μ) hsub
    have h2 : 20 * b * μ.real {ω | 20 * b ≤ f ω} ≤ b := hm.trans hE
    have h3 : μ.real {ω | 20 * b ≤ f ω} ≤ 1 / 20 := by
      by_contra hc
      push Not at hc
      nlinarith
    linarith
  · subst hb
    have hz : ∫ ω, f ω ∂μ = 0 := le_antisymm hE hI0
    have hae := (integral_eq_zero_iff_of_nonneg hf0 hfi).mp hz
    have hnull : μ {ω | 20 * 0 < f ω} = 0 := by
      rw [← nonpos_iff_eq_zero]
      have : {ω | 20 * 0 < f ω} ⊆ {ω | f ω ≠ (0 : Ω → ℝ) ω} := by
        intro ω hω
        simp only [Set.mem_setOf_eq, mul_zero] at hω
        simp only [Set.mem_setOf_eq, Pi.zero_apply]
        exact hω.ne'
      calc μ {ω | 20 * 0 < f ω} ≤ μ {ω | f ω ≠ (0 : Ω → ℝ) ω} := measure_mono this
        _ = 0 := ae_iff.mp hae
    rw [measureReal_def, hnull]
    norm_num

/-- `τ² · #{j : τ ≤ |A_j|} ≤ ∑ A_j²`. -/
theorem mrx_count_le {n : ℕ} (A : Fin n → ℝ) {τ R : ℝ} (hτ : 0 < τ)
    (hR : ∑ j, A j ^ 2 ≤ R) :
    ((Finset.univ.filter (fun j => τ ≤ |A j|)).card : ℝ) ≤ R / τ ^ 2 := by
  rw [le_div_iff₀ (by positivity)]
  calc ((Finset.univ.filter (fun j => τ ≤ |A j|)).card : ℝ) * τ ^ 2 =
        ∑ j ∈ Finset.univ.filter (fun j => τ ≤ |A j|), τ ^ 2 := by
        rw [Finset.sum_const, nsmul_eq_mul]
    _ ≤ ∑ j ∈ Finset.univ.filter (fun j => τ ≤ |A j|), A j ^ 2 := by
        apply Finset.sum_le_sum
        intro j hj
        have h := (Finset.mem_filter.mp hj).2
        have := pow_le_pow_left₀ hτ.le h 2
        rwa [sq_abs] at this
    _ ≤ ∑ j, A j ^ 2 :=
        Finset.sum_le_sum_of_subset_of_nonneg (Finset.filter_subset _ _)
          (fun j _ _ => sq_nonneg _)
    _ ≤ R := hR

/-- Perturbation of counts: a large entry of `A` stays large in `B` unless `A - B` is large
there. -/
theorem mrx_count_perturb {n : ℕ} (A B : Fin n → ℝ) (P : Fin n → Prop) [DecidablePred P]
    (τ₁ τ₂ : ℝ) :
    ((Finset.univ.filter (fun j => P j ∧ τ₁ ≤ |A j|)).card : ℝ) -
        ((Finset.univ.filter (fun j => τ₂ ≤ |A j - B j|)).card : ℝ) ≤
      ((Finset.univ.filter (fun j => P j ∧ τ₁ - τ₂ ≤ |B j|)).card : ℝ) := by
  have hsub : Finset.univ.filter (fun j => P j ∧ τ₁ ≤ |A j|) ⊆
      Finset.univ.filter (fun j => P j ∧ τ₁ - τ₂ ≤ |B j|) ∪
        Finset.univ.filter (fun j => τ₂ ≤ |A j - B j|) := by
    intro j hj
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hj
    simp only [Finset.mem_union, Finset.mem_filter, Finset.mem_univ, true_and]
    by_cases hD : τ₂ ≤ |A j - B j|
    · exact Or.inr hD
    · left
      push Not at hD
      refine ⟨hj.1, ?_⟩
      have := abs_sub_abs_le_abs_sub (A j) (B j)
      linarith [hj.2]
  have hc := (Finset.card_le_card hsub).trans (Finset.card_union_le _ _)
  have hcR : ((Finset.univ.filter (fun j => P j ∧ τ₁ ≤ |A j|)).card : ℝ) ≤
      ((Finset.univ.filter (fun j => P j ∧ τ₁ - τ₂ ≤ |B j|)).card : ℝ) +
        ((Finset.univ.filter (fun j => τ₂ ≤ |A j - B j|)).card : ℝ) := by
    exact_mod_cast hc
  linarith

/-- `c · #{i : c < v_i} ≤ ∑ v_i` for `v ≥ 0`. -/
theorem mrx_count_exceptional {n : ℕ} (v : Fin n → ℝ) (hv : ∀ i, 0 ≤ v i) {c T : ℝ}
    (hc : 0 < c) (hT : ∑ i, v i ≤ T) :
    ((Finset.univ.filter (fun i => c < v i)).card : ℝ) ≤ T / c := by
  rw [le_div_iff₀ hc]
  calc ((Finset.univ.filter (fun i => c < v i)).card : ℝ) * c =
        ∑ i ∈ Finset.univ.filter (fun i => c < v i), c := by
        rw [Finset.sum_const, nsmul_eq_mul]
    _ ≤ ∑ i ∈ Finset.univ.filter (fun i => c < v i), v i :=
        Finset.sum_le_sum fun i hi => (Finset.mem_filter.mp hi).2.le
    _ ≤ ∑ i, v i :=
        Finset.sum_le_sum_of_subset_of_nonneg (Finset.filter_subset _ _) (fun i _ _ => hv i)
    _ ≤ T := hT

/-- `n e^{-c(n-1)} ≤ 8/(c² n)` for `n ≥ 2`. -/
theorem mrx_exp_tail {c : ℝ} (hc : 0 < c) {x : ℝ} (hx : 2 ≤ x) :
    x * Real.exp (-c * (x - 1)) ≤ 8 / (c ^ 2 * x) := by
  have hy : 0 ≤ c * (x - 1) := by nlinarith
  have hq := Real.quadratic_le_exp_of_nonneg hy
  have hexp : Real.exp (-c * (x - 1)) = (Real.exp (c * (x - 1)))⁻¹ := by
    rw [← Real.exp_neg]; ring_nf
  rw [hexp]
  have hpos : 0 < Real.exp (c * (x - 1)) := Real.exp_pos _
  rw [mul_inv_le_iff₀ hpos, div_mul_eq_mul_div, le_div_iff₀ (by positivity)]
  have hx1 : x / 2 ≤ x - 1 := by linarith
  have h2 : (c * (x / 2)) ^ 2 ≤ (c * (x - 1)) ^ 2 :=
    pow_le_pow_left₀ (by positivity) (by nlinarith) 2
  nlinarith [sq_nonneg (c * (x - 1)), mul_pos hc (by linarith : (0:ℝ) < x)]

end

end Paulsen.Paper
