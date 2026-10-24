import NeuralGeneralization.BatchTwoContinuousDepthLaw
import Mathlib.Analysis.SpecialFunctions.Pow.Real

/-! The explicit small-ball estimate for the fixed invariant input law. -/
noncomputable section
open Set MeasureTheory
open scoped ENNReal
namespace NeuralGeneralization.BatchTwoContinuousDepthLower

def frostmanExponent : ℝ := Real.log 2/Real.log 20

theorem frostmanExponent_pos : 0<frostmanExponent :=
  div_pos (Real.log_pos (by norm_num)) (Real.log_pos (by norm_num))

theorem frostmanExponent_le_one : frostmanExponent≤1 := by
  apply (div_le_one (Real.log_pos (by norm_num))).mpr
  exact Real.log_le_log (by norm_num) (by norm_num)

theorem branch_ratio_rpow : (1/20 : ℝ)^frostmanExponent = 1/2 := by
  rw [Real.rpow_def_of_pos (by norm_num),one_div,Real.log_inv,frostmanExponent]
  have hlog : Real.log (20 : ℝ)≠0 := (Real.log_pos (by norm_num)).ne'
  have he : -Real.log 20*(Real.log 2/Real.log 20) = -Real.log 2 := by field_simp
  rw [he,Real.exp_neg,Real.exp_log (by norm_num)]
  norm_num

theorem branch_power_rpow (n : ℕ) : ((1/20 : ℝ)^n)^frostmanExponent=(1/2 : ℝ)^n := by
  rw [← Real.rpow_pow_comm (by norm_num),branch_ratio_rpow]

/-- Literal manuscript bound for closed intervals of length at most one.
The open and half-open interval versions follow immediately by inclusion. -/
theorem cantorLaw_interval_bound {a b : ℝ} (hl : 0<b-a) (hu : b-a≤1) :
    cantorLaw.real (Icc a b) ≤ 2*(b-a)^frostmanExponent := by
  obtain ⟨n,hlo,hhi⟩ := exists_nat_pow_near_of_lt_one hl hu
    (by norm_num : (0 : ℝ)<1/20) (by norm_num : (1/20 : ℝ)<1)
  have hmass : cantorLaw.real (Icc a b) ≤ (1/2 : ℝ)^n := by
    cases n with
    | zero =>
      simpa only [pow_zero,probReal_univ] using
        (measureReal_mono (μ := cantorLaw) (subset_univ (Icc a b)))
    | succ n =>
      apply cantorLaw_small_diameter n _ measurableSet_Icc
      intro x hx y hy
      have hxy : |x-y|≤b-a := by rw [abs_le]; constructor <;> linarith [hx.1,hx.2,hy.1,hy.2]
      have hp : (1/20 : ℝ)^(n+1)<(1/20 : ℝ)^n := by
        rw [pow_succ]
        nlinarith [pow_pos (by norm_num : (0 : ℝ)<1/20) n]
      exact hxy.trans_lt (hhi.trans_lt hp)
  have hp := Real.rpow_lt_rpow (pow_nonneg (by norm_num : (0 : ℝ)≤1/20) (n+1)) hlo frostmanExponent_pos
  rw [branch_power_rpow,pow_succ] at hp
  linarith

/-- Centered small-ball bound, in the exact form used for sample separation. -/
theorem cantorLaw_small_ball {c δ : ℝ} (hδ : 0<δ) (hsmall : 2*δ≤1) :
    cantorLaw.real {t | |t-c|<δ} ≤ 2*(2*δ)^frostmanExponent := by
  have h := cantorLaw_interval_bound (a := c-δ) (b := c+δ) (by linarith) (by linarith)
  have he : c+δ-(c-δ)=2*δ := by ring
  rw [he] at h
  refine (measureReal_mono (μ := cantorLaw) ?_).trans h
  intro t ht
  have htc := abs_lt.mp (show |t-c|<δ from ht)
  exact ⟨by linarith [htc.1],by linarith [htc.2]⟩

end NeuralGeneralization.BatchTwoContinuousDepthLower
