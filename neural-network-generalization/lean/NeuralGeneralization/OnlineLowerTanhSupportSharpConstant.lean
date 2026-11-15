import NeuralGeneralization.OnlineLowerTanhSupport

/-! Literal support constant from the tanh paper: 96 sqrt(6). -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh
variable {ι : Type*} [Fintype ι]

theorem biasTransfer_gap_slice_paper (U a B r : ℝ) (hr : 0 < r)
    (ha : a ^ 2 ≤ U) (hupper : U + B ^ 2 ≤ 6 * r ^ 2) :
    a ^ 2 * B ^ 2 ≤
      12 * Real.sqrt 6 * r ^ 3 * (Real.sqrt (U + B ^ 2) - sqrtPair (U + B ^ 2) (2 * a * B)) := by
  have hx0 : 0 ≤ U + B ^ 2 := by nlinarith [sq_nonneg a, sq_nonneg B]
  have hsr : (Real.sqrt 6 * r)^2 = 6*r^2 := by
    rw [mul_pow,Real.sq_sqrt (by norm_num)]
  have hsn : 0 ≤ Real.sqrt 6 * r := by positivity
  have hroot : Real.sqrt (U + B ^ 2) ≤ Real.sqrt 6 * r := by
    have hs := Real.sq_sqrt hx0
    have hn := Real.sqrt_nonneg (U + B ^ 2)
    nlinarith
  have hgap : 0 ≤ Real.sqrt (U + B ^ 2) - sqrtPair (U + B ^ 2) (2 * a * B) :=
    sub_nonneg.mpr (sqrtPair_le _ _ (biasTransfer_abs_le U a B ha))
  have hbase := sqrtPair_gap_mul (U + B ^ 2) (2 * a * B)
    (biasTransfer_abs_le U a B ha)
  have hprod : 8 * (U + B ^ 2) * Real.sqrt (U + B ^ 2) *
      (Real.sqrt (U + B ^ 2) - sqrtPair (U + B ^ 2) (2 * a * B)) ≤
      48 * Real.sqrt 6 * r ^ 3 * (Real.sqrt (U + B ^ 2) - sqrtPair (U + B ^ 2) (2 * a * B)) := by
    calc
      _ ≤ 8 * (6 * r ^ 2) * (Real.sqrt 6 * r) *
          (Real.sqrt (U + B ^ 2) - sqrtPair (U + B ^ 2) (2 * a * B)) := by
        gcongr
      _ = _ := by ring
  nlinarith


variable {ι : Type*} [Fintype ι]

theorem weighted_biasTransfer_gap_paper (p B : ι → ℝ) (U a v r : ℝ)
    (hp : ∀ i, 0 ≤ p i) (hpsum : ∑ i, p i = 1)
    (ha : a ^ 2 ≤ U) (hv : 0 < v) (hr : 0 < r)
    (hsecond : ∑ i, p i * B i ^ 2 = v)
    (hfourth : ∑ i, p i * B i ^ 4 ≤ 3 * v ^ 2)
    (hrsq : r ^ 2 = U + v) :
    a ^ 2 * v ≤ 24 * Real.sqrt 6 * r ^ 3 *
      (r - ∑ i, p i * sqrtPair (U + B i ^ 2) (2 * a * B i)) := by
  classical
  have hU : 0 ≤ U := (sq_nonneg a).trans ha
  have hX (i : ι) : 0 ≤ U + B i ^ 2 := add_nonneg hU (sq_nonneg _)
  have hmean : ∑ i, p i * (U + B i ^ 2) = r ^ 2 := by
    simp only [mul_add, Finset.sum_add_distrib, ← Finset.sum_mul, hpsum,
      one_mul, hsecond, hrsq]
  have hjensen := weighted_sqrt_le p (fun i => U + B i ^ 2) r
    hp hpsum hX hr hmean
  have hgood := fourthMoment_good_mass p B v hp hv hsecond hfourth
  have hpoint (i : ι) : a ^ 2 *
      (p i * (if B i ^ 2 ≤ 6 * v then B i ^ 2 else 0)) ≤
      12 * Real.sqrt 6 * r ^ 3 * (p i * (Real.sqrt (U + B i ^ 2) -
        sqrtPair (U + B i ^ 2) (2 * a * B i))) := by
    have hg : 0 ≤ Real.sqrt (U + B i ^ 2) -
        sqrtPair (U + B i ^ 2) (2 * a * B i) :=
      sub_nonneg.mpr (sqrtPair_le _ _ (biasTransfer_abs_le U a (B i) ha))
    split_ifs with hi
    · have hu : U + B i ^ 2 ≤ 6 * r ^ 2 := by nlinarith
      have hh := mul_le_mul_of_nonneg_left
        (biasTransfer_gap_slice_paper U a (B i) r hr ha hu) (hp i)
      nlinarith
    · simp only [mul_zero]
      exact mul_nonneg (by positivity) (mul_nonneg (hp i) hg)
  have hsum := Finset.sum_le_sum (fun i (_ : i ∈ Finset.univ) => hpoint i)
  simp only [← Finset.mul_sum, mul_sub, Finset.sum_sub_distrib] at hsum
  have hgood' := mul_le_mul_of_nonneg_left hgood (sq_nonneg a)
  have hfactor : 0 ≤ 12 * Real.sqrt 6 * r ^ 3 := by positivity
  have hupper := mul_le_mul_of_nonneg_left hjensen hfactor
  nlinarith

theorem support_of_midpoint_gap_paper (r v a w q : ℝ) (hr : 0 < r)
    (hv : 0 ≤ v) (hvupper : v ≤ r ^ 2) (hw : 0 ≤ w)
    (hq : q ≤ r) (hcoordinate : q ≤ w * |a|)
    (hgap : a ^ 2 * v ≤ 24 * Real.sqrt 6 * r ^ 3 * (r - q)) :
    v ≤ max 2 (96 * Real.sqrt 6 * w ^ 2) * r * (r - q) := by
  have hdelta : 0 ≤ r - q := sub_nonneg.mpr hq
  by_cases hsmall : q < r / 2
  · have hsimple : v ≤ 2 * r * (r - q) := by
      have hh := mul_nonneg (le_of_lt hr) (show 0 ≤ r - 2 * q by linarith)
      nlinarith
    calc
      v ≤ 2 * r * (r - q) := hsimple
      _ ≤ max 2 (96 * Real.sqrt 6 * w ^ 2) * r * (r - q) := by gcongr; exact le_max_left _ _
  · have hsize : r ^ 2 ≤ 4 * w ^ 2 * a ^ 2 := by
      have hlin : r ≤ 2 * w * |a| := by linarith
      have hnonneg : 0 ≤ 2 * w * |a| := by positivity
      have hsquare := mul_self_le_mul_self (le_of_lt hr) hlin
      have he : (2 * w * |a|) * (2 * w * |a|) = 4 * w ^ 2 * a ^ 2 := by
        rw [← pow_two, mul_pow, mul_pow, sq_abs]
        ring
      rw [he] at hsquare
      nlinarith
    have hmul : r ^ 2 * v ≤ r ^ 2 * (96 * Real.sqrt 6 * w ^ 2 * r * (r - q)) := by
      calc
        r ^ 2 * v ≤ (4 * w ^ 2 * a ^ 2) * v :=
          mul_le_mul_of_nonneg_right hsize hv
        _ = 4 * w ^ 2 * (a ^ 2 * v) := by ring
        _ ≤ 4 * w ^ 2 * (24 * Real.sqrt 6 * r ^ 3 * (r - q)) := by
          exact mul_le_mul_of_nonneg_left hgap (by positivity)
        _ = _ := by ring
    have hstrong : v ≤ 96 * Real.sqrt 6 * w ^ 2 * r * (r - q) :=
      (mul_le_mul_iff_right₀ (sq_pos_of_pos hr)).mp hmul
    calc
      v ≤ 96 * Real.sqrt 6 * w ^ 2 * r * (r - q) := hstrong
      _ ≤ max 2 (96 * Real.sqrt 6 * w ^ 2) * r * (r - q) := by gcongr; exact le_max_right _ _

theorem finite_support_stability_paper (p B : ι → ℝ) (U a v r w q : ℝ)
    (hp : ∀ i, 0 ≤ p i) (hpsum : ∑ i, p i = 1)
    (ha : a ^ 2 ≤ U) (hr : 0 < r) (hw : 0 ≤ w)
    (hsecond : ∑ i, p i * B i ^ 2 = v)
    (hfourth : ∑ i, p i * B i ^ 4 ≤ 3 * v ^ 2)
    (hrsq : r ^ 2 = U + v)
    (htransfer : q ≤ ∑ i, p i * sqrtPair (U + B i ^ 2) (2 * a * B i))
    (hcoordinate : q ≤ w * |a|) :
    v ≤ max 2 (96 * Real.sqrt 6 * w ^ 2) * r * (r - q) := by
  have hU : 0 ≤ U := (sq_nonneg a).trans ha
  have hv : 0 ≤ v := by
    rw [← hsecond]
    exact Finset.sum_nonneg (fun i _ => mul_nonneg (hp i) (sq_nonneg _))
  have hX (i : ι) : 0 ≤ U + B i ^ 2 := add_nonneg hU (sq_nonneg _)
  have hmean : ∑ i, p i * (U + B i ^ 2) = r ^ 2 := by
    simp only [mul_add, Finset.sum_add_distrib, ← Finset.sum_mul, hpsum,
      one_mul, hsecond, hrsq]
  have hjensen := weighted_sqrt_le p (fun i => U + B i ^ 2) r hp hpsum hX hr hmean
  have hpair : (∑ i, p i * sqrtPair (U + B i ^ 2) (2 * a * B i)) ≤
      ∑ i, p i * Real.sqrt (U + B i ^ 2) := by
    apply Finset.sum_le_sum
    intro i _
    exact mul_le_mul_of_nonneg_left
      (sqrtPair_le _ _ (biasTransfer_abs_le U a (B i) ha)) (hp i)
  have hq : q ≤ r := htransfer.trans (hpair.trans hjensen)
  apply support_of_midpoint_gap_paper r v a w q hr hv (by linarith) hw hq hcoordinate
  by_cases hv0 : v = 0
  · rw [hv0, mul_zero]
    positivity
  · have hvpos : 0 < v := lt_of_le_of_ne hv (Ne.symm hv0)
    have hgap := weighted_biasTransfer_gap_paper p B U a v r
      hp hpsum ha hvpos hr hsecond hfourth hrsq
    have hbound := mul_le_mul_of_nonneg_left htransfer (show 0 ≤ 24 * Real.sqrt 6 * r ^ 3 by positivity)
    linarith

end NeuralGeneralization.OnlineLowerTanh
