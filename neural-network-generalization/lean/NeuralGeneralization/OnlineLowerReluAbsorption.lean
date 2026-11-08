import NeuralGeneralization.OnlineLowerReluFamily
import Mathlib.Analysis.SpecificLimits.Normed
import Mathlib.Data.Nat.Factorial.Basic

/-! # Eventual prefix suppression for the concrete fixed-rail family

The fixed rail size is independent of the family index. The displayed
prefix bound beats the complete rounding constant for every sufficiently
large index; no unproved asymptotic comparison is used.
-/

noncomputable section
open Filter
open scoped Topology

namespace NeuralGeneralization.OnlineLower
open OnlineLowerRelu

/-- The full polynomial/exponential coefficient in the finite rounding
estimate, before multiplying by the tiny inverse-cost coefficient. -/
def reluRoundingEnvelope (R : ℝ) (k : ℕ) : ℝ :=
  (2 : ℝ) ^ (25 + Family.logicalDim k) * (Family.pairDim k : ℝ) ^ 3 * R ^ 5

/-- A convenient relaxation of the factorial prefix estimate. -/
def reluPrefixEnvelope (R slope : ℝ) (k : ℕ) : ℝ :=
  8 * slope / ((Family.pairDim k : ℝ) * R - 1) *
    (2 / (R - 1)) ^ Family.prefixDim k

/-- The factorial estimate implies its geometric relaxation whenever the
prefix length does not exceed the number of physical rail pairs. -/
theorem factorial_prefix_geometric_bound (P p : ℕ) (R slope : ℝ)
    (hp : 1 ≤ p) (hP : P ≤ p) (hR : 1 < R) (hslope : 0 ≤ slope) :
    8 * slope * 2 ^ P * (P.factorial : ℝ) / ((p : ℝ) * R - 1) ^ (P + 1) ≤
      8 * slope / ((p : ℝ) * R - 1) * (2 / (R - 1)) ^ P := by
  have hpR : (1 : ℝ) ≤ p := by exact_mod_cast hp
  have hden : 0 < (p : ℝ) * R - 1 := by nlinarith
  have hR1 : 0 < R - 1 := by linarith
  have hfact : (P.factorial : ℝ) ≤ (p : ℝ) ^ P := by
    exact_mod_cast (Nat.factorial_le_pow P).trans (Nat.pow_le_pow_left hP P)
  have hratio : (p : ℝ) / ((p : ℝ) * R - 1) ≤ 1 / (R - 1) := by
    apply (div_le_div_iff₀ hden hR1).mpr
    nlinarith
  have hpow := pow_le_pow_left₀ (div_nonneg (Nat.cast_nonneg _) hden.le) hratio P
  have hfactor : (P.factorial : ℝ) / ((p : ℝ) * R - 1) ^ P ≤ 1 / (R - 1) ^ P := by
    calc
      _ ≤ (p : ℝ) ^ P / ((p : ℝ) * R - 1) ^ P :=
        div_le_div_of_nonneg_right hfact (pow_nonneg hden.le _)
      _ ≤ _ := by simpa only [div_pow, one_pow] using hpow
  have hh := mul_le_mul_of_nonneg_left hfactor
    (show 0 ≤ (8 * slope * 2 ^ P) / ((p : ℝ) * R - 1) by positivity)
  calc
    _ = (8 * slope * 2 ^ P / ((p : ℝ) * R - 1)) *
        ((P.factorial : ℝ) / ((p : ℝ) * R - 1) ^ P) := by
      rw [pow_succ]
      field_simp
    _ ≤ (8 * slope * 2 ^ P / ((p : ℝ) * R - 1)) *
        (1 / (R - 1) ^ P) := hh
    _ = _ := by rw [div_pow]; ring

/-- An explicit geometric base strictly below one controls the whole
rounding product. -/
theorem relu_prefix_rounding_eventually_small (R slope : ℝ)
    (hR : 17 ≤ R) (hslope : 0 ≤ slope) :
    ∀ᶠ k : ℕ in atTop,
      reluPrefixEnvelope R slope k * reluRoundingEnvelope R k < 1 / 2 := by
  let q : ℝ := 2 / (R - 1)
  let b : ℝ := 64 * q ^ 4
  let A : ℝ := 8 * slope * q ^ 3 * 2 ^ 29 * 1728 * R ^ 5
  have hR1 : 0 < R - 1 := by linarith
  have hq : 0 ≤ q := div_nonneg (by norm_num) hR1.le
  have hqu : q ≤ 1 / 8 := by
    apply (div_le_iff₀ hR1).mpr
    linarith
  have hb0 : 0 ≤ b := by positivity
  have hb1 : b < 1 := by
    have hh := pow_le_pow_left₀ hq hqu 4
    dsimp [b]
    norm_num at hh
    nlinarith
  have hbNorm : ‖b‖ < 1 := by rw [Real.norm_eq_abs, abs_of_nonneg hb0]; exact hb1
  have hlim : Tendsto (fun k : ℕ => A * ((k : ℝ) ^ 3 * b ^ k)) atTop (𝓝 0) := by
    simpa only [mul_zero] using
      (summable_pow_mul_geometric_of_norm_lt_one 3 hbNorm).tendsto_atTop_zero.const_mul A
  have hsmall : ∀ᶠ k : ℕ in atTop, A * ((k : ℝ) ^ 3 * b ^ k) < 1 / 2 :=
    hlim.eventually (gt_mem_nhds (by norm_num : (0 : ℝ) < 1 / 2))
  filter_upwards [hsmall, eventually_ge_atTop 1] with k hk hk1
  have hkR : (1 : ℝ) ≤ k := by exact_mod_cast hk1
  have hp : (1 : ℝ) ≤ Family.pairDim k := by rw [Family.pairDim_eq]; norm_num; linarith [Nat.cast_nonneg k (α := ℝ)]
  have hden1 : 1 ≤ (Family.pairDim k : ℝ) * R - 1 := by nlinarith
  have hden : 0 < (Family.pairDim k : ℝ) * R - 1 := by linarith
  have hratio : 8 * slope / ((Family.pairDim k : ℝ) * R - 1) ≤ 8 * slope := by
    apply (div_le_iff₀ hden).mpr
    nlinarith
  have hpbound : (Family.pairDim k : ℝ) ^ 3 ≤ 1728 * (k : ℝ) ^ 3 := by
    have hbase : (Family.pairDim k : ℝ) ≤ 12 * (k : ℝ) := by
      rw [Family.pairDim_eq]
      push_cast
      linarith
    have hh := pow_le_pow_left₀ (Nat.cast_nonneg _) hbase 3
    nlinarith
  have hqpow : q ^ Family.prefixDim k = q ^ 3 * (q ^ 4) ^ k := by
    unfold Family.prefixDim
    rw [pow_add, pow_mul]
    ring
  have h2pow : (2 : ℝ) ^ (25 + Family.logicalDim k) = 2 ^ 29 * (64 : ℝ) ^ k := by
    rw [Family.logicalDim_eq]
    rw [show 25 + (6 * k + 4) = 29 + 6 * k by omega, pow_add, pow_mul]
    norm_num
  have hupper : reluPrefixEnvelope R slope k * reluRoundingEnvelope R k ≤
      A * ((k : ℝ) ^ 3 * b ^ k) := by
    unfold reluPrefixEnvelope reluRoundingEnvelope
    change (8 * slope / ((Family.pairDim k : ℝ) * R - 1) * q ^ Family.prefixDim k) *
      (2 ^ (25 + Family.logicalDim k) * (Family.pairDim k : ℝ) ^ 3 * R ^ 5) ≤ _
    have hleft := mul_le_mul_of_nonneg_right hratio (pow_nonneg hq (Family.prefixDim k))
    have hright := mul_le_mul_of_nonneg_right
      (mul_le_mul_of_nonneg_left hpbound (by positivity : 0 ≤ (2 : ℝ) ^ (25 + Family.logicalDim k)))
      (by positivity : 0 ≤ R ^ 5)
    calc
      _ ≤ (8 * slope * q ^ Family.prefixDim k) *
          (2 ^ (25 + Family.logicalDim k) * (1728 * (k : ℝ) ^ 3) * R ^ 5) :=
        mul_le_mul hleft hright (by positivity) (by positivity)
      _ = _ := by
        rw [hqpow, h2pow]
        dsimp [A, b]
        rw [mul_pow]
        ring
  exact hupper.trans_lt hk

end NeuralGeneralization.OnlineLower
