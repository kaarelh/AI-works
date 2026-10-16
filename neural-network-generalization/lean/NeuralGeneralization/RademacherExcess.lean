import NeuralGeneralization.FiniteProcessMax

/-!
# Positive excesses of actual normalized Rademacher increments

An exponential-moment estimate controls positive excess without an appeal
to a tail-integration theorem. This permits edge-dependent chaining scales.
-/

noncomputable section
namespace NeuralGeneralization.SquaredSampling
open scoped BigOperators

/-- Relative excess above a positive threshold. -/
def relativeExcess (p x : ℝ) : ℝ := max 0 (|x| - p) / p

lemma relativeExcess_nonneg {p : ℝ} (hp : 0 < p) (x : ℝ) : 0 ≤ relativeExcess p x :=
  div_nonneg (le_max_left _ _) hp.le

lemma abs_le_threshold_excess {p : ℝ} (hp : 0 < p) (x : ℝ) :
    |x| ≤ p * (1 + relativeExcess p x) := by
  have h : |x| - p ≤ max 0 (|x| - p) := le_max_right _ _
  unfold relativeExcess
  field_simp [ne_of_gt hp]
  nlinarith

/-- A scalar positive-part estimate using two exponential moments. -/
lemma relativeExcess_le_exponential {p : ℝ} (hp : 0 < p) (x : ℝ) :
    relativeExcess p x ≤
      (Real.exp (-p ^ 2) / p ^ 2) * (Real.exp (p * x) + Real.exp (-p * x)) := by
  have hfirst : p * max 0 (|x| - p) ≤ Real.exp (p * (|x| - p)) := by
    by_cases hx : 0 ≤ |x| - p
    · rw [max_eq_right hx]
      have h := Real.add_one_le_exp (p * (|x| - p))
      linarith
    · rw [max_eq_left (le_of_not_ge hx), mul_zero]
      exact (Real.exp_pos _).le
  have hsign : Real.exp (p * |x|) ≤ Real.exp (p * x) + Real.exp (-p * x) := by
    by_cases hx : 0 ≤ x
    · rw [abs_of_nonneg hx]
      exact le_add_of_nonneg_right (Real.exp_pos _).le
    · rw [abs_of_neg (lt_of_not_ge hx)]
      have he : p * -x = -p * x := by ring
      rw [he]
      exact le_add_of_nonneg_left (Real.exp_pos _).le
  have hexp : Real.exp (p * (|x| - p)) = Real.exp (-p ^ 2) * Real.exp (p * |x|) := by
    rw [← Real.exp_add]
    congr 1
    ring
  rw [hexp] at hfirst
  have hsecond := mul_le_mul_of_nonneg_left hsign (Real.exp_pos (-p ^ 2)).le
  have hbound := hfirst.trans hsecond
  unfold relativeExcess
  apply (div_le_iff₀ hp).mpr
  have hdiv := div_le_div_of_nonneg_right hbound hp.le
  have heq : (Real.exp (-p ^ 2) / p ^ 2) *
      (Real.exp (p * x) + Real.exp (-p * x)) * p =
      Real.exp (-p ^ 2) * (Real.exp (p * x) + Real.exp (-p * x)) / p := by
    field_simp [ne_of_gt hp]
  rw [heq]
  simpa only [mul_div_cancel_left₀ _ (ne_of_gt hp)] using hdiv

/-- The expected normalized excess of an actual unit-variance-proxy
Rademacher linear form. -/
theorem finite_rademacher_relativeExcess (n : ℕ) (a : Fin n → ℝ)
    (henergy : (∑ i, a i ^ 2) ≤ 1) (p : ℝ) (hp : 0 < p) :
    finiteMean (fun ε : Fin n → Bool =>
      relativeExcess p (∑ i, cubeCoordinateSign (ε i) * a i)) ≤
      2 * Real.exp (-(p ^ 2) / 2) / p ^ 2 := by
  have hpoint := finiteMean_mono (fun ε : Fin n → Bool =>
    relativeExcess_le_exponential hp (∑ i, cubeCoordinateSign (ε i) * a i))
  rw [finiteMean_mul, finiteMean_add] at hpoint
  have hpMGF := finite_rademacher_mgf_le n a p
  have hmMGF := finite_rademacher_mgf_le n a (-p)
  simp only [neg_sq] at hmMGF
  have hvar : Real.exp (p ^ 2 * (∑ i, a i ^ 2) / 2) ≤ Real.exp (p ^ 2 / 2) := by
    apply Real.exp_le_exp.mpr
    have h := mul_le_mul_of_nonneg_left henergy (sq_nonneg p)
    nlinarith only [h]
  have hsum := add_le_add (hpMGF.trans hvar) (hmMGF.trans hvar)
  have hscaled := mul_le_mul_of_nonneg_left hsum
    (div_nonneg (Real.exp_pos (-p ^ 2)).le (sq_nonneg p))
  apply hpoint.trans
  apply hscaled.trans_eq
  have he : Real.exp (-p ^ 2) * Real.exp (p ^ 2 / 2) = Real.exp (-(p ^ 2) / 2) := by
    rw [← Real.exp_add]
    congr 1
    ring
  calc
    _ = 2 * (Real.exp (-p ^ 2) * Real.exp (p ^ 2 / 2)) / p ^ 2 := by ring
    _ = _ := by rw [he]

/-- Normalizing an actual increment by any positive upper bound on its
standard deviation gives the unit-variance excess estimate. -/
theorem finite_rademacher_relativeExcess_scaled (n : ℕ) (a : Fin n → ℝ)
    (σ : ℝ) (hσ : 0 < σ) (henergy : (∑ i, a i ^ 2) ≤ σ ^ 2)
    (p : ℝ) (hp : 0 < p) :
    finiteMean (fun ε : Fin n → Bool =>
      relativeExcess p ((∑ i, cubeCoordinateSign (ε i) * a i) / σ)) ≤
      2 * Real.exp (-(p ^ 2) / 2) / p ^ 2 := by
  have hnorm : (∑ i, (a i / σ) ^ 2) ≤ 1 := by
    simp only [div_pow, ← Finset.sum_div]
    exact (div_le_one (sq_pos_of_pos hσ)).mpr henergy
  have h := finite_rademacher_relativeExcess n (fun i => a i / σ) hnorm p hp
  have heq (ε : Fin n → Bool) :
      (∑ i, cubeCoordinateSign (ε i) * (a i / σ)) =
      (∑ i, cubeCoordinateSign (ε i) * a i) / σ := by
    rw [Finset.sum_div]
    apply Finset.sum_congr rfl
    intro i _
    ring
  simpa only [heq] using h

end NeuralGeneralization.SquaredSampling
