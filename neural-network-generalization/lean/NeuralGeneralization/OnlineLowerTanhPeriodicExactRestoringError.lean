import NeuralGeneralization.OnlineLowerTanhPeriodicExactRestoringRatioError

/-! Uniform, exact approximation error of the restoring-curvature polynomial. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh

lemma restoringSeries_partial_error {q x : ℝ} (hq0 : 0≤q) (hq : q≤17/200)
    (hx : x∈Set.Icc (-1:ℝ) 1) :
    |restoringSeries q x - ∑ j ∈ Finset.range 6,
      restoringExactRatio q j*restoringWeight q x j| ≤
      ∑' j : ℕ, ((2*(j:ℝ)+13)^2+2)*q^(j+6) := by
  have hq1 : q<1 := by linarith
  have habsq : |q|<1 := by rwa [abs_of_nonneg hq0]
  let f : ℕ→ℝ := fun j => restoringExactRatio q j*restoringWeight q x j
  have hs : Summable f := restoringSeries_summable hq0 hq1 hx
  have ht : restoringSeries q x-(∑ j∈Finset.range 6,f j)=∑'j,f (j+6) := by
    have hh := hs.sum_add_tsum_nat_add 6
    change (∑'j,f j)-(∑j∈Finset.range 6,f j)=_
    linarith
  change |restoringSeries q x-(∑j∈Finset.range 6,f j)|≤_
  rw [ht]
  have htail : Summable (fun j=>f (j+6)) :=
    hs.comp_injective (fun i j h => Nat.add_right_cancel h)
  have hn : Summable (fun j=>‖f (j+6)‖) := htail.norm
  have hb (j : ℕ) : ‖f (j+6)‖≤((2*(j:ℝ)+13)^2+2)*q^(j+6) := by
    dsimp [f]
    rw [abs_mul,abs_of_nonneg (restoringExactRatio_nonneg hq0 hq1 (j+6))]
    have hw := restoringWeight_bound hq0 hq hx (j:=j+6) (by omega)
    have h := mul_le_mul (restoringExactRatio_le_pow hq0 hq1 (j+6)) hw
      (abs_nonneg _) (by positivity : 0≤q^(j+6))
    calc
      _ ≤ q^(j+6)*(((2*(j+6)+1:ℕ):ℝ)^2+2) := h
      _ = _ := by push_cast; ring
  have hle := (norm_tsum_le_tsum_norm hn).trans
    (Summable.tsum_le_tsum hb hn (restoringTail_summable habsq))
  simpa only [Real.norm_eq_abs] using hle

lemma restoringPolynomial_partial_error {q x : ℝ} (hq0 : 0≤q) (hq : q≤17/200)
    (hx : x∈Set.Icc (-1:ℝ) 1) :
    |(∑ j∈Finset.range 6, restoringExactRatio q j*restoringWeight q x j)-
      restoringPolynomial q x| ≤ 295*q^15/(1-q) := by
  have hq1 : q<1 := by linarith
  have hd : 0≤q^15/(1-q) := by positivity
  rw [restoringPolynomial_eq_sum,←Finset.sum_sub_distrib]
  calc
    _ ≤ ∑ j∈Finset.range 6,
        |restoringExactRatio q j*restoringWeight q x j-
          restoringRatioPolynomial q j*restoringWeight q x j| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ j∈Finset.range 6,
        (if j=0 then 0 else ((2*j+1:ℕ):ℝ)^2+2)*(q^15/(1-q)) := by
      apply Finset.sum_le_sum
      intro j hj
      by_cases hj0 : j=0
      · subst j
        simp [restoringExactRatio_zero hq1,restoringRatioPolynomial]
      · rw [if_neg hj0,←sub_mul,abs_mul]
        have hj1 : 1≤j := by omega
        have hj5 : j≤5 := by have hh := Finset.mem_range.mp hj; omega
        have he := restoringRatioPolynomial_error_le hq0 hq1 j hj1 hj5
        have hw := restoringWeight_bound hq0 hq hx hj1
        have h := mul_le_mul he hw (abs_nonneg _) hd
        simpa only [mul_comm] using h
    _ = _ := by norm_num [Finset.sum_range_succ]; ring

/-- The complete analytic error is below the rational margin certified by the
    bivariate polynomial calculation. -/
lemma restoringSeries_polynomial_error {q x : ℝ} (hq0 : 0≤q) (hq : q≤17/200)
    (hx : x∈Set.Icc (-1:ℝ) 1) :
    |restoringSeries q x-restoringPolynomial q x| < 1/10000 := by
  have ht := restoringSeries_partial_error hq0 hq hx
  have hp := restoringPolynomial_partial_error hq0 hq hx
  calc
    _ ≤ |restoringSeries q x-(∑ j∈Finset.range 6,
          restoringExactRatio q j*restoringWeight q x j)|+
        |(∑ j∈Finset.range 6,restoringExactRatio q j*restoringWeight q x j)-
          restoringPolynomial q x| := abs_sub_le _ _ _
    _ ≤ (∑' j : ℕ, ((2*(j:ℝ)+13)^2+2)*q^(j+6))+295*q^15/(1-q) :=
      add_le_add ht hp
    _ < _ := restoringTail_remainder_lt hq0 hq

end NeuralGeneralization.OnlineLowerTanh
