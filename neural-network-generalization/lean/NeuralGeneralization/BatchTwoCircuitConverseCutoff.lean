import NeuralGeneralization.BatchTwoCircuitConversePrediction
import Mathlib.Algebra.Order.Floor.Ring

/-!
# Removing the cutoff assumption in the geometric predictive bound
-/

namespace NeuralGeneralization.BatchTwoCircuitConverse

open scoped BigOperators
noncomputable section
open Classical

variable {d : ℕ}

/-- A_d in the manuscript. -/
def predictiveCost (d : ℕ) (u : ℝ) : ℝ :=
  Real.log (4/3) + ((3*d+3 : ℕ) : ℝ) * Real.log 2 +
    2 * ((3*d+3 : ℕ) : ℝ) * Real.log (u / Real.log 2 + ((4*d+6 : ℕ) : ℝ))

def posteriorCutoff (f : Input d → Bool) (A : Finset (Input d)) : ℕ :=
  ⌈versionLoss f A / Real.log 2⌉₊ + 1

theorem posteriorCutoff_tail (f : Input d → Bool) (A : Finset (Input d)) :
    (2 : ℝ)⁻¹^(posteriorCutoff f A+1) ≤ versionMass f A / 4 := by
  have hlog2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have hz := versionMass_pos f A
  apply (Real.log_le_log_iff (by positivity) (by positivity)).mp
  rw [Real.log_pow, Real.log_inv, Real.log_div (ne_of_gt hz) (by norm_num)]
  have hl4 : Real.log (4 : ℝ) = 2 * Real.log 2 := by
    have he : (4 : ℝ) = 2^2 := by norm_num
    rw [he, Real.log_pow]
    norm_num
  rw [hl4]
  have hc := Nat.le_ceil (versionLoss f A / Real.log 2)
  have hmul := mul_le_mul_of_nonneg_right hc hlog2.le
  rw [div_mul_cancel₀ _ hlog2.ne'] at hmul
  unfold posteriorCutoff
  push_cast
  unfold versionLoss at *
  nlinarith

theorem posteriorCutoff_upper (f : Input d → Bool) (A : Finset (Input d)) :
    ((d + posteriorCutoff f A + (3*d+3) + 1 : ℕ) : ℝ) ≤
      versionLoss f A / Real.log 2 + ((4*d+6 : ℕ) : ℝ) := by
  have hc := Nat.ceil_lt_add_one (div_nonneg (versionLoss_nonneg f A)
    (Real.log_pos (by norm_num : (1:ℝ)<2)).le)
  unfold posteriorCutoff
  push_cast at *
  linarith

theorem repairRatio_toReal_pos (d K : ℕ) : 0 < (repairRatio d K).toReal := by
  simp only [repairRatio, ENNReal.toReal_div, ENNReal.toReal_pow,
    ENNReal.toReal_inv, ENNReal.toReal_ofNat, ENNReal.toReal_natCast]
  positivity

theorem neg_log_repair_floor (d K : ℕ) :
    -Real.log ((3/4 : ℝ) * (repairRatio d K).toReal) =
      Real.log (4/3) + ((3*d+3 : ℕ) : ℝ)*Real.log 2 +
        2*((3*d+3 : ℕ) : ℝ)*Real.log (((d+K+(3*d+3)+1 : ℕ) : ℝ)) := by
  simp only [repairRatio, ENNReal.toReal_div, ENNReal.toReal_pow,
    ENNReal.toReal_inv, ENNReal.toReal_ofNat, ENNReal.toReal_natCast]
  rw [Real.log_mul (by norm_num) (by positivity)]
  rw [Real.log_div (by positivity : (2 : ℝ)⁻¹^(3*d+3) ≠ 0) (by positivity),
    Real.log_pow, Real.log_inv, Real.log_pow]
  have hfrac : -Real.log (3/4 : ℝ) = Real.log (4/3 : ℝ) := by
    rw [show (4/3 : ℝ) = (3/4 : ℝ)⁻¹ by norm_num, Real.log_inv]
  push_cast
  rw [← hfrac]
  ring

/-- The concrete prior gives the paper's logarithmic predictive floor at every
noiseless history; the integer truncation premise has been discharged. -/
theorem neg_log_correctProbability_le (f : Input d → Bool)
    (A : Finset (Input d)) (x : Input d) :
    -Real.log (correctProbability f A x) ≤ predictiveCost d (versionLoss f A) := by
  let K := posteriorCutoff f A
  have hf := correctProbability_ge_truncated_repair f A x K (posteriorCutoff_tail f A)
  have hpos : 0 < (3/4 : ℝ) * (repairRatio d K).toReal :=
    mul_pos (by norm_num) (repairRatio_toReal_pos d K)
  have hl := neg_le_neg (Real.log_le_log hpos hf)
  rw [neg_log_repair_floor] at hl
  have harg := posteriorCutoff_upper f A
  have hlog := Real.log_le_log (by positivity :
    (0 : ℝ) < ((d+K+(3*d+3)+1 : ℕ) : ℝ)) harg
  have hm := mul_le_mul_of_nonneg_left hlog
    (by positivity : (0 : ℝ) ≤ 2*((3*d+3 : ℕ) : ℝ))
  unfold predictiveCost
  linarith

/-- Equivalent exponential formulation of the predictive-floor lemma. -/
theorem correctProbability_ge_exp_cost (f : Input d → Bool)
    (A : Finset (Input d)) (x : Input d) :
    Real.exp (-predictiveCost d (versionLoss f A)) ≤ correctProbability f A x := by
  apply (Real.exp_le_exp.mpr (neg_le_neg (neg_log_correctProbability_le f A x))).trans_eq
  rw [neg_neg, Real.exp_log (correctProbability_pos f A x)]

end
end NeuralGeneralization.BatchTwoCircuitConverse
