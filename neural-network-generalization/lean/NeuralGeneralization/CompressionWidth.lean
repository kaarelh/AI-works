import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Ring
import Lean.Elab.Tactic.Omega

/-! # Explicit polynomial widths for the retained-row union bound -/
noncomputable section
namespace NeuralGeneralization.CompressionSampling

/-- The cube cardinality is absorbed by a linear amount in the exponential. -/
theorem two_pow_le_exp (d : ℕ) : (2 : ℝ) ^ d ≤ Real.exp (d : ℝ) := by
  have h : (2 : ℝ) ≤ Real.exp 1 := by
    have h := Real.add_one_le_exp 1
    linarith
  have hp := pow_le_pow_left₀ (by norm_num : (0 : ℝ) ≤ 2) h d
  simpa only [← Real.exp_nat_mul, mul_one] using hp

/-- A convenient elementary inverse-square estimate for an exponential tail. -/
theorem exp_neg_le_eight_div_sq {t : ℝ} (ht : 0 < t) :
    Real.exp (-t / 2) ≤ 8 / t ^ 2 := by
  have hquad := Real.pow_div_factorial_le_exp (t / 2) (by positivity) 2
  norm_num at hquad
  have hbase : 0 < t ^ 2 / 8 := by positivity
  have hh : t ^ 2 / 8 ≤ Real.exp (t / 2) := by nlinarith
  have hi := one_div_le_one_div_of_le hbase hh
  rw [one_div, ← Real.exp_neg] at hi
  convert hi using 1
  · rfl
  · congr 1
    ring
  · field_simp

/-- An explicit polynomial width suffices for the exact retained-row union
    bound, with no logarithms and no original-width factor. -/
theorem retained_union_bound_le_quarter (d r : ℕ) {M ρ : ℝ}
    (hM : 1 ≤ M) (hρ : 0 < ρ)
    (hd : 64 * (d : ℝ) ≤ ρ ^ 4 * M)
    (hlarge : 65536 * ((r : ℝ) + 1) ≤ ρ ^ 8 * M) :
    (((r : ℝ) * M + 1) * (2 : ℝ) ^ d *
      (2 * Real.exp (-ρ ^ 4 * M / 32))) ≤ 1 / 4 := by
  let t := ρ ^ 4 * M / 32
  have ht : 0 < t := by dsimp [t]; positivity
  have hdt : (d : ℝ) ≤ t / 2 := by dsimp [t]; linarith
  have hcube : (2 : ℝ) ^ d * Real.exp (-t) ≤ Real.exp (-t / 2) := by
    calc
      _ ≤ Real.exp (d : ℝ) * Real.exp (-t) :=
        mul_le_mul_of_nonneg_right (two_pow_le_exp d) (Real.exp_pos _).le
      _ = Real.exp ((d : ℝ) - t) := by rw [sub_eq_add_neg, Real.exp_add]
      _ ≤ _ := Real.exp_le_exp.mpr (by linarith)
  have htail := exp_neg_le_eight_div_sq ht
  have hr : 0 ≤ (r : ℝ) * M + 1 := by positivity
  have hstart : (((r : ℝ) * M + 1) * (2 : ℝ) ^ d * (2 * Real.exp (-t))) ≤
      16 * ((r : ℝ) * M + 1) / t ^ 2 := by
    have hm := mul_le_mul_of_nonneg_left (hcube.trans htail) (show 0 ≤ 2 * ((r : ℝ) * M + 1) by positivity)
    convert hm using 1
    · rfl
    · ring
    · ring
  have hnum : 16 * ((r : ℝ) * M + 1) / t ^ 2 ≤ 1 / 4 := by
    apply (div_le_iff₀ (sq_pos_of_pos ht)).2
    have hmr : ((r : ℝ) * M + 1) ≤ ((r : ℝ) + 1) * M := by nlinarith
    have hm := mul_le_mul_of_nonneg_right hlarge (show 0 ≤ M by linarith)
    dsimp [t]
    have hpow : ρ ^ 4 * ρ ^ 4 = ρ ^ 8 := by ring
    nlinarith
  have he : -ρ ^ 4 * M / 32 = -t := by dsimp [t]; ring
  rw [he]
  exact hstart.trans hnum

/-- An integer energy budget permits an entirely polynomial integer width. -/
def compressionQ (r K : ℕ) : ℕ := 24 * (r + 1) * (4 * K) ^ (r + 1)

def compressionWidth (d r K : ℕ) : ℕ :=
  65536 * (r + 1) * (d + 1) * compressionQ r K ^ 8 + 9 * K


theorem compressionQ_pos (r K : ℕ) (hK : 1 ≤ K) : 0 < compressionQ r K := by
  unfold compressionQ
  positivity

theorem compressionWidth_ge_nine_energy (d r K : ℕ) :
    9 * K ≤ compressionWidth d r K := by
  unfold compressionWidth
  omega

theorem compressionWidth_pos (d r K : ℕ) (hK : 1 ≤ K) :
    0 < compressionWidth d r K := by
  have h := compressionWidth_ge_nine_energy d r K
  omega

/-- The explicit integer width satisfies the two elementary tail thresholds. -/
theorem compressionWidth_tail_conditions (d r K : ℕ) (hK : 1 ≤ K) :
    64 * (d : ℝ) ≤ ((compressionQ r K : ℝ)⁻¹) ^ 4 * compressionWidth d r K ∧
    65536 * ((r : ℝ) + 1) ≤ ((compressionQ r K : ℝ)⁻¹) ^ 8 * compressionWidth d r K := by
  let Q : ℝ := compressionQ r K
  let M : ℝ := compressionWidth d r K
  have hQ : 1 ≤ Q := by
    change 1 ≤ (compressionQ r K : ℝ)
    exact_mod_cast Nat.succ_le_iff.mpr (compressionQ_pos r K hK)
  have hQpos : 0 < Q := by linarith
  have hbig : 65536 * ((r : ℝ) + 1) * ((d : ℝ) + 1) * Q ^ 8 ≤ M := by
    change (65536 * ((r : ℝ) + 1) * ((d : ℝ) + 1) * (compressionQ r K : ℝ) ^ 8) ≤ _
    have hn : 65536 * (r + 1) * (d + 1) * compressionQ r K ^ 8 ≤ compressionWidth d r K := by
      unfold compressionWidth
      omega
    change _ ≤ (compressionWidth d r K : ℝ)
    exact_mod_cast hn
  have hfac : 64 * (d : ℝ) ≤ 65536 * ((r : ℝ) + 1) * ((d : ℝ) + 1) := by
    have hr : 0 ≤ (r : ℝ) := Nat.cast_nonneg r
    have hd : 0 ≤ (d : ℝ) := Nat.cast_nonneg d
    nlinarith
  have hp := pow_le_pow_right₀ hQ (show 4 ≤ 8 by omega)
  have hd : 64 * (d : ℝ) * Q ^ 4 ≤ M := by
    exact (mul_le_mul hfac hp (by positivity) (by positivity)).trans hbig
  have hl : 65536 * ((r : ℝ) + 1) * Q ^ 8 ≤ M := by
    have hn : 0 ≤ (65536 : ℝ) * ((r : ℝ) + 1) * Q ^ 8 := by positivity
    have hh := mul_le_mul_of_nonneg_left (show (1 : ℝ) ≤ (d : ℝ) + 1 by linarith [(Nat.cast_nonneg d : (0 : ℝ) ≤ d)]) hn
    nlinarith
  change 64 * (d : ℝ) ≤ Q⁻¹ ^ 4 * M ∧ 65536 * ((r : ℝ) + 1) ≤ Q⁻¹ ^ 8 * M
  constructor
  · rw [inv_pow, inv_mul_eq_div]
    exact (le_div_iff₀ (pow_pos hQpos 4)).2 hd
  · rw [inv_pow, inv_mul_eq_div]
    exact (le_div_iff₀ (pow_pos hQpos 8)).2 hl

/-- The explicit integer width makes event A fail with probability at most 1/4. -/
theorem compressionWidth_row_bound (d r K : ℕ) (hK : 1 ≤ K) :
    (((r : ℝ) * compressionWidth d r K + 1) * (2 : ℝ) ^ d *
      (2 * Real.exp (-((compressionQ r K : ℝ)⁻¹) ^ 4 * compressionWidth d r K / 32))) ≤ 1 / 4 := by
  have hM : 1 ≤ (compressionWidth d r K : ℝ) := by
    exact_mod_cast compressionWidth_pos d r K hK
  have hQ : 0 < (compressionQ r K : ℝ) := by exact_mod_cast compressionQ_pos r K hK
  obtain ⟨hd,hl⟩ := compressionWidth_tail_conditions d r K hK
  exact retained_union_bound_le_quarter d r hM (inv_pos.mpr hQ) hd hl

/-- Each of the two deterministic error bounds is at most 1/24. -/
theorem compressionQ_error_identity (r K : ℕ) (hK : 1 ≤ K) :
    ((r : ℝ) + 1) * (compressionQ r K : ℝ)⁻¹ * (4 * (K : ℝ)) ^ (r + 1) = 1 / 24 := by
  have hKpos : 0 < (K : ℝ) := by exact_mod_cast (show 0 < K by omega)
  have hr : ((r : ℝ) + 1) ≠ 0 := by positivity
  unfold compressionQ
  push_cast
  field_simp

end NeuralGeneralization.CompressionSampling
