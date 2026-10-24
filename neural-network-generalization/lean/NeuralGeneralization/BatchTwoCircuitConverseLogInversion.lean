import NeuralGeneralization.BatchTwoCircuitConversePathwise

/-!
# Explicit inversion of the circuit-prior mistake converse
-/

namespace NeuralGeneralization.BatchTwoCircuitConverse

open scoped BigOperators
noncomputable section
open Classical

/-- An elementary logarithmic inversion, proved by the tangent inequality for log.
The paper only needs b≥6; the lemma holds already for b≥1. -/
theorem logarithmic_inversion {x a b : ℝ} (hx : 0 ≤ x) (ha : 0 ≤ a)
    (hb : 1 ≤ b) (h : x ≤ a * Real.log (b+x)) :
    x ≤ 2*a*Real.log (b+2*a) := by
  have ht : 0 < b+2*a := by linarith
  have hs : 0 < b+x := by linarith
  have hl := Real.log_le_sub_one_of_pos (div_pos hs ht)
  rw [Real.log_div hs.ne' ht.ne'] at hl
  have hlmul := mul_le_mul_of_nonneg_right hl ht.le
  rw [sub_mul, sub_mul, div_mul_cancel₀ _ ht.ne', one_mul] at hlmul
  have hamul := mul_le_mul_of_nonneg_left hlmul ha
  have hhmul := mul_le_mul_of_nonneg_right h ht.le
  have hlog : 0 ≤ Real.log (b+2*a) := Real.log_nonneg (by linarith)
  have hnonneg : 0 ≤ a*b*Real.log (b+2*a) := mul_nonneg (mul_nonneg ha (by linarith)) hlog
  have hsq : 0 ≤ a*a := mul_self_nonneg a
  have hprod : x*(b+a) ≤ (2*a*Real.log (b+2*a))*(b+a) := by
    nlinarith
  exact (mul_le_mul_iff_left₀ (by linarith : 0 < b+a)).mp (by simpa [mul_comm] using hprod)

theorem predictiveCost_le_three_log (d : ℕ) {u : ℝ} (hu : 0 ≤ u) :
    predictiveCost d u ≤ 3*((3*d+3 : ℕ) : ℝ)*
      Real.log (u/Real.log 2 + ((4*d+6 : ℕ) : ℝ)) := by
  have hl2 : (1/2 : ℝ) ≤ Real.log 2 := by
    have h := Real.one_sub_inv_le_log_of_pos (by norm_num : (0:ℝ)<2)
    norm_num at h
    linarith
  have hl2pos : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have harg : (4:ℝ) ≤ u/Real.log 2 + ((4*d+6 : ℕ) : ℝ) := by
    have hh := div_nonneg hu hl2pos.le
    push_cast
    have hd : (0:ℝ) ≤ d := Nat.cast_nonneg d
    linarith
  have hlarg := Real.log_le_log (by norm_num : (0:ℝ)<4) harg
  have hl4 : Real.log (4:ℝ) = 2*Real.log 2 := by
    rw [show (4:ℝ)=2^2 by norm_num, Real.log_pow]
    norm_num
  rw [hl4] at hlarg
  have hfrac : Real.log (4/3 : ℝ) ≤ 1/3 := by
    have h := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<4/3)
    norm_num at h
    exact h
  have hR : (3:ℝ) ≤ ((3*d+3 : ℕ) : ℝ) := by
    push_cast
    have hd : (0:ℝ) ≤ d := Nat.cast_nonneg d
    linarith
  have hm := mul_le_mul_of_nonneg_left hlarg (show (0:ℝ) ≤ ((3*d+3 : ℕ):ℝ) by positivity)
  unfold predictiveCost
  nlinarith

/-- A numerical consequence used both pathwise and after averaging over reveal
orders. The only premise concerns the already-defined actual version-space loss. -/
theorem complexity_bound_of_loss_bound {d : ℕ} (f : Input d → Bool)
    (A : Finset (Input d)) {m : ℝ} (hm : 0 ≤ m)
    (hloss : versionLoss f A ≤ 2*predictiveCost d (versionLoss f A)*m) :
    (complexity f A : ℝ) ≤
      (12*((3*d+3 : ℕ):ℝ)*m/Real.log 2) *
        Real.log (((4*d+6 : ℕ):ℝ) + 12*((3*d+3 : ℕ):ℝ)*m/Real.log 2) := by
  let R : ℝ := ((3*d+3 : ℕ):ℝ)
  let B : ℝ := ((4*d+6 : ℕ):ℝ)
  let u := versionLoss f A
  let x := u/Real.log 2
  let a := 6*R*m/Real.log 2
  have hl2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have hu : 0 ≤ u := versionLoss_nonneg f A
  have hcost := predictiveCost_le_three_log d hu
  have hmul := mul_le_mul_of_nonneg_right hcost hm
  have hlogineq : x ≤ a * Real.log (B+x) := by
    apply (div_le_iff₀ hl2).mpr
    have he : a * Real.log (B+x) * Real.log 2 = 6*R*m*Real.log (B+x) := by
      dsimp [a]
      field_simp
    rw [he]
    dsimp [x, B, R, u] at *
    rw [add_comm (versionLoss f A / Real.log 2) (((4*d+6 : ℕ):ℝ))] at hmul
    nlinarith
  have hx : 0 ≤ x := div_nonneg hu hl2.le
  have ha : 0 ≤ a := by dsimp [a]; positivity
  have hB : 1 ≤ B := by
    dsimp [B]
    push_cast
    have hd : (0:ℝ) ≤ d := Nat.cast_nonneg d
    linarith
  have hinv := logarithmic_inversion hx ha hB hlogineq
  have hC : (complexity f A : ℝ) ≤ x := by
    apply (le_div_iff₀ hl2).mpr
    exact complexity_le_versionLoss f A
  have h2a : 2*a = 12*((3*d+3 : ℕ):ℝ)*m/Real.log 2 := by dsimp [a, R]; ring
  simpa only [h2a, B] using hC.trans hinv

/-- The explicit O(d m log(d+d m)) converse for every deterministic query path,
including incomplete histories. This uses the actual geometric description prior. -/
theorem geometric_pathwise_circuit_converse {d : ℕ} (f : Input d → Bool)
    (query : ℕ → Input d) (n : ℕ) :
    (complexity f (history query n) : ℝ) ≤
      (12*((3*d+3 : ℕ):ℝ)*predictionMistakes f query n/Real.log 2) *
        Real.log (((4*d+6 : ℕ):ℝ) +
          12*((3*d+3 : ℕ):ℝ)*predictionMistakes f query n/Real.log 2) :=
  complexity_bound_of_loss_bound f _ (predictionMistakes_nonneg f query n)
    (geometric_pathwise_loss f query n)

end
end NeuralGeneralization.BatchTwoCircuitConverse
