import NeuralGeneralization.OnlineLowerReluScalar
import Mathlib.Data.Nat.Choose.Central

/-! # Exact normalization and monotonicity along even ReLU parity degrees -/

noncomputable section

namespace NeuralGeneralization.OnlineLowerRelu

/-- The sharp coefficient at physical degree `2r+2`. -/
def evenReluKappa (r : ℕ) : ℝ :=
  (Nat.centralBinom r : ℝ) / (2 : ℝ) ^ (2 * r + 1)

theorem evenReluKappa_pos (r : ℕ) : 0 < evenReluKappa r := by
  unfold evenReluKappa
  exact div_pos (by exact_mod_cast Nat.centralBinom_pos r) (pow_pos (by norm_num) _)

theorem evenReluKappa_recurrence (r : ℕ) :
    2 * ((r : ℝ) + 1) * evenReluKappa (r + 1) =
      (2 * (r : ℝ) + 1) * evenReluKappa r := by
  have h : ((r : ℝ) + 1) * (Nat.centralBinom (r + 1) : ℝ) =
      2 * (2 * (r : ℝ) + 1) * (Nat.centralBinom r : ℝ) := by
    exact_mod_cast Nat.succ_mul_centralBinom_succ r
  have hp : (2 : ℝ) ^ (2 * (r + 1) + 1) = 4 * (2 : ℝ) ^ (2 * r + 1) := by
    rw [show 2 * (r + 1) + 1 = (2 * r + 1) + 2 by omega, pow_add]
    ring
  unfold evenReluKappa
  rw [hp]
  field_simp
  nlinarith

theorem evenReluKappa_succ_le (r : ℕ) : evenReluKappa (r + 1) ≤ evenReluKappa r := by
  have hr := evenReluKappa_recurrence r
  have hpos := evenReluKappa_pos r
  have hnonneg : (0 : ℝ) ≤ r := Nat.cast_nonneg r
  nlinarith

theorem evenReluKappa_antitone : Antitone evenReluKappa :=
  antitone_nat_of_succ_le evenReluKappa_succ_le

theorem evenReluKappa_eq_coefficient (r : ℕ) :
    evenReluKappa r = ((2 * r).choose ((2 * r) / 2) : ℝ) /
      (2 : ℝ) ^ (2 * r + 1) := by
  simp [evenReluKappa, Nat.centralBinom]

end NeuralGeneralization.OnlineLowerRelu
