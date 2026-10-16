import NeuralGeneralization.IteratedArcsineSeries
import Mathlib.Analysis.SpecialFunctions.Pow.Real

/-! Two-scale exponential deficits control the tails of any nonnegative
summable odd power series. -/
noncomputable section
namespace NeuralGeneralization
open scoped BigOperators

/-- Exponential endpoint deficit of an odd series. -/
def oddSeriesDeficit (b : ℕ → ℝ) (t : ℝ) : ℝ :=
  ∑' m,b m*(1-Real.exp (-((2*m+1 : ℕ) : ℝ)*t))

def coefficientTail (b : ℕ → ℝ) (n : ℕ) : ℝ :=
  ∑' m,if n ≤ m then b m else 0

lemma exponential_deficit_nonneg {x : ℝ} (hx : 0 ≤ x) : 0 ≤ 1-Real.exp (-x) := by
  have h : Real.exp (-x) ≤ 1 := by rw [Real.exp_le_one_iff]; linarith
  linarith

lemma exponential_deficit_le (x : ℝ) : 1-Real.exp (-x) ≤ x := by
  have h := Real.add_one_le_exp (-x)
  linarith

lemma exponential_deficit_lower {x : ℝ} (hx0 : 0 ≤ x) (hx1 : x ≤ 1) :
    x ≤ Real.exp 1*(1-Real.exp (-x)) := by
  have h := mul_le_mul_of_nonneg_right (Real.add_one_le_exp x) (Real.exp_pos (-x)).le
  have he : Real.exp x*Real.exp (-x)=1 := by rw [← Real.exp_add,add_neg_cancel,Real.exp_zero]
  rw [he] at h
  have hfac : 1 ≤ Real.exp 1*Real.exp (-x) := by
    rw [← Real.exp_add,Real.one_le_exp_iff]
    linarith
  calc
    x = x*1 := by ring
    _ ≤ x*(Real.exp 1*Real.exp (-x)) := mul_le_mul_of_nonneg_left hfac hx0
    _ = Real.exp 1*(x*Real.exp (-x)) := by ring
    _ ≤ Real.exp 1*(1-Real.exp (-x)) := by gcongr; linarith

lemma oddSeriesDeficit_summable {b : ℕ → ℝ} (hb : ∀ m,0 ≤ b m)
    (hs : Summable b) {t : ℝ} (ht : 0 ≤ t) :
    Summable (fun m => b m*(1-Real.exp (-((2*m+1 : ℕ) : ℝ)*t))) := by
  apply Summable.of_nonneg_of_le _ _ hs
  · intro m
    apply mul_nonneg (hb m)
    convert exponential_deficit_nonneg (mul_nonneg (by positivity : (0 : ℝ) ≤ (2*m+1 : ℕ)) ht) using 1 <;> first | rfl | ring
  · intro m
    have he := (Real.exp_pos (-((2*m+1 : ℕ) : ℝ)*t)).le
    nlinarith [mul_nonneg (hb m) he]

lemma coefficientTail_summable {b : ℕ → ℝ} (hb : ∀ m,0 ≤ b m)
    (hs : Summable b) (n : ℕ) : Summable (fun m => if n ≤ m then b m else 0) := by
  apply Summable.of_nonneg_of_le _ _ hs <;> intro m <;> split_ifs <;> simp_all

lemma coefficientTail_nonneg {b : ℕ → ℝ} (hb : ∀ m,0 ≤ b m) (n : ℕ) :
    0 ≤ coefficientTail b n := by
  apply tsum_nonneg
  intro m
  split_ifs <;> simp_all

/-- The exponential deficit at reciprocal cutoff controls the upper
coefficient tail with a fixed positive factor. -/
theorem coefficientTail_le_deficit {b : ℕ → ℝ} (hb : ∀ m,0 ≤ b m)
    (hs : Summable b) {n : ℕ} (hn : 0 < n) :
    (1-Real.exp (-1))*coefficientTail b n ≤ oddSeriesDeficit b (1/(2*n : ℝ)) := by
  have hnR : 0 < (n : ℝ) := by exact_mod_cast hn
  have hd : 0 < (2*n : ℝ) := by positivity
  have ht : 0 ≤ 1/(2*n : ℝ) := by positivity
  apply hasSum_le _ ((coefficientTail_summable hb hs n).hasSum.mul_left _)
    (oddSeriesDeficit_summable hb hs ht).hasSum
  intro m
  by_cases hnm : n ≤ m
  · rw [if_pos hnm]
    have hmR : (n : ℝ) ≤ m := by exact_mod_cast hnm
    have hclock : 1 ≤ ((2*m+1 : ℕ) : ℝ)*(1/(2*n : ℝ)) := by
      push_cast
      rw [mul_one_div]
      apply (le_div_iff₀ hd).mpr
      linarith
    have he : Real.exp (-((2*m+1 : ℕ) : ℝ)*(1/(2*n : ℝ))) ≤ Real.exp (-1) := by
      apply Real.exp_le_exp.mpr
      nlinarith
    nlinarith [mul_nonneg (hb m) (sub_nonneg.mpr he)]
  · rw [if_neg hnm,mul_zero]
    apply mul_nonneg (hb m)
    convert exponential_deficit_nonneg (mul_nonneg (by positivity : (0 : ℝ) ≤ (2*m+1 : ℕ)) ht) using 1 <;> first | rfl | ring

/-- A two-scale comparison proves a lower tail from an endpoint cusp
without any moment asymptotic or sum/integral approximation. -/
theorem oddSeriesDeficit_two_scale {b : ℕ → ℝ} (hb : ∀ m,0 ≤ b m)
    (hs : Summable b) {n : ℕ} (hn : 0 < n) {δ : ℝ} (hδ : 0 ≤ δ) :
    oddSeriesDeficit b (δ/(2*n : ℝ)) ≤
      (Real.exp 1*δ)*oddSeriesDeficit b (1/(2*n : ℝ))+coefficientTail b n := by
  have hnR : 0 < (n : ℝ) := by exact_mod_cast hn
  have hd : 0 < (2*n : ℝ) := by positivity
  have ht : 0 ≤ 1/(2*n : ℝ) := by positivity
  have htδ : 0 ≤ δ/(2*n : ℝ) := by positivity
  apply hasSum_le _ (oddSeriesDeficit_summable hb hs htδ).hasSum
    (((oddSeriesDeficit_summable hb hs ht).hasSum.mul_left _).add
      (coefficientTail_summable hb hs n).hasSum)
  intro m
  let x := ((2*m+1 : ℕ) : ℝ)*(1/(2*n : ℝ))
  have hx0 : 0 ≤ x := by dsimp [x]; positivity
  have hclock : -((2*m+1 : ℕ) : ℝ)*(δ/(2*n : ℝ))= -(δ*x) := by dsimp [x]; ring
  have hclock' : -((2*m+1 : ℕ) : ℝ)*(1/(2*n : ℝ))= -x := by dsimp [x]; ring
  rw [hclock,hclock']
  by_cases hnm : n ≤ m
  · rw [if_pos hnm]
    have h0 := exponential_deficit_nonneg hx0
    have hex := (Real.exp_pos (-(δ*x))).le
    have hm := mul_nonneg (mul_nonneg (Real.exp_pos 1).le hδ) (mul_nonneg (hb m) h0)
    nlinarith [mul_nonneg (hb m) hex]
  · rw [if_neg hnm,add_zero]
    have hm : m < n := by omega
    have hmR : (m : ℝ)+1 ≤ n := by exact_mod_cast hm
    have hx1 : x ≤ 1 := by
      dsimp [x]
      push_cast
      rw [mul_one_div]
      apply (div_le_iff₀ hd).mpr
      linarith
    have hlow := exponential_deficit_lower hx0 hx1
    have hup := exponential_deficit_le (δ*x)
    have hm := mul_le_mul_of_nonneg_left hlow hδ
    have hp : 1-Real.exp (-(δ*x)) ≤ (Real.exp 1*δ)*(1-Real.exp (-x)) := by nlinarith
    simpa only [mul_assoc,mul_comm,mul_left_comm] using mul_le_mul_of_nonneg_left hp (hb m)

end NeuralGeneralization
