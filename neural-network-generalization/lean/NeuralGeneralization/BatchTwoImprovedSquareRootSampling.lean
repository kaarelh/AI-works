import NeuralGeneralization.BatchTwoImprovedWeightedMoments

/-! # The variance-sensitive square-root reconstruction estimate -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoImprovedWeightedSampling
variable {α : Type*} [Fintype α]

theorem square_sqrt_gap_le_div {a c : ℝ} (ha : 0 ≤ a) (hc : 0 < c) :
    (Real.sqrt a-Real.sqrt c)^2 ≤ (a-c)^2/c := by
  have ha2 := Real.sq_sqrt ha
  have hc2 := Real.sq_sqrt hc.le
  have hs := mul_nonneg (Real.sqrt_nonneg a) (Real.sqrt_nonneg c)
  have hplus : c ≤ (Real.sqrt a+Real.sqrt c)^2 := by nlinarith
  have hmul := mul_le_mul_of_nonneg_left hplus (sq_nonneg (Real.sqrt a-Real.sqrt c))
  have he : (Real.sqrt a-Real.sqrt c)^2*(Real.sqrt a+Real.sqrt c)^2 = (a-c)^2 := by
    calc
      _ = ((Real.sqrt a)^2-(Real.sqrt c)^2)^2 := by ring
      _ = _ := by rw [ha2,hc2]
  rw [he] at hmul
  exact (le_div_iff₀ hc).mpr hmul

theorem mean_iid_average (w : α → ℝ) (hw : ∑ x, w x = 1)
    (n : ℕ) (hn : 0 < n) (f : α → ℝ) :
    mean (iidWeight w n) (fun s => (∑ i, f (s i))/(n:ℝ)) = mean w f := by
  have hn' : (n:ℝ) ≠ 0 := by exact_mod_cast hn.ne'
  rw [mean_div, mean_sum]
  simp only [mean_iidWeight_eval w hw, Finset.sum_const, Finset.card_univ,
    Fintype.card_fin, nsmul_eq_mul]
  exact mul_div_cancel_left₀ _ hn'

/-- Bounded nonnegative observations have square-root mean squared error
of order B/n, including a zero population variance. -/
theorem mean_squareRoot_average_error (w : α → ℝ) (hw : ∀ x, 0 ≤ w x)
    (hmass : ∑ x, w x = 1) (n : ℕ) (hn : 0 < n) (f : α → ℝ)
    (hf : ∀ x, 0 ≤ f x) {B : ℝ} (hB : 0 ≤ B) (hfB : ∀ x, f x ≤ B) :
    mean (iidWeight w n)
      (fun s => (Real.sqrt ((∑ i, f (s i))/(n:ℝ))-Real.sqrt (mean w f))^2) ≤ B/n := by
  have hnf (s : Fin n → α) : 0 ≤ (∑ i, f (s i))/(n:ℝ) :=
    div_nonneg (Finset.sum_nonneg (fun _ _ => hf _)) (Nat.cast_nonneg n)
  have hc := mean_nonneg w hw hf
  have hn' : (0:ℝ) < n := by exact_mod_cast hn
  by_cases hz : mean w f = 0
  · simp_rw [hz, Real.sqrt_zero, sub_zero, Real.sq_sqrt (hnf _)]
    rw [mean_iid_average w hmass n hn f,hz]
    exact div_nonneg hB hn'.le
  · have hcp : 0 < mean w f := lt_of_le_of_ne hc (Ne.symm hz)
    have h1 := mean_mono (iidWeight w n) (iidWeight_nonneg w hw n)
      (fun s => square_sqrt_gap_le_div (hnf s) hcp)
    rw [mean_div, mean_iid_average_variance w hmass n hn f] at h1
    have h2 : mean w (fun x => (f x)^2) ≤ B*mean w f := by
      rw [← mean_mul]
      apply mean_mono w hw
      intro x
      nlinarith [mul_le_mul_of_nonneg_right (hfB x) (hf x)]
    apply h1.trans
    apply (div_le_iff₀ hcp).mpr
    apply (div_le_iff₀ hn').mpr
    have he : B/(n:ℝ)*mean w f*(n:ℝ) = B*mean w f := by field_simp
    rw [he]
    nlinarith [sq_nonneg (mean w f)]

end NeuralGeneralization.BatchTwoImprovedWeightedSampling
