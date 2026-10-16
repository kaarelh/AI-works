import NeuralGeneralization.TiltedRowSampling
import NeuralGeneralization.Network
import Mathlib.Analysis.SpecialFunctions.Pow.Real

/-! Explicit polynomial sampling choices discharge every probability budget. -/
noncomputable section
namespace NeuralGeneralization.TowerSamplingBudget
open ConcreteModel

def width (d E : ℕ) : ℕ := 32 * E ^ 2 * (d + 1)
def rowBound (d E T : ℕ) : ℕ :=
  32 * (T + width d E * (d + width d E + 1) + 1)

theorem covariance_probability_lt_quarter (d : ℕ) {N : ℕ} {η : ℝ}
    (hscale : 4 * (d : ℝ) + 16 ≤ (N : ℝ) * η ^ 2) :
    2 * (Fintype.card (Cube d) : ℝ) ^ 2 * Real.exp (-(N : ℝ) * η ^ 2 / 2) < 1 / 4 := by
  have htwo : (2 : ℝ) ≤ Real.exp 1 := by linarith [Real.add_one_le_exp (1 : ℝ)]
  have hc : (Fintype.card (Cube d) : ℝ) ^ 2 ≤ Real.exp (2 * (d : ℝ)) := by
    have hpow := pow_le_pow_left₀ (by norm_num : (0 : ℝ) ≤ 2) htwo (2 * d)
    rw [← Real.exp_nat_mul] at hpow
    simpa [Cube, Fintype.card_fun, pow_mul, mul_comm, mul_left_comm, mul_assoc] using hpow
  calc
    _ ≤ 2 * Real.exp (2 * (d : ℝ)) * Real.exp (-(N : ℝ) * η ^ 2 / 2) :=
      mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_left hc (by norm_num)) (Real.exp_pos _).le
    _ = 2 * Real.exp (2 * (d : ℝ) - (N : ℝ) * η ^ 2 / 2) := by
      rw [mul_assoc, ← Real.exp_add]; congr 2; ring
    _ ≤ 2 * Real.exp (-8) := by
      apply mul_le_mul_of_nonneg_left _ (by norm_num)
      apply Real.exp_le_exp.mpr
      linarith
    _ < 1 / 4 := by
      rw [Real.exp_neg]
      change 2 / Real.exp 8 < 1 / 4
      apply (div_lt_iff₀ (Real.exp_pos _)).2
      linarith [Real.add_one_le_exp (8 : ℝ)]

theorem coordinate_probability_lt_quarter {M G B : ℝ} (hM : 0 ≤ M)
    (hscale : 2 * G + 16 * M + 16 ≤ B ^ 2 / 2) :
    2 * M * Real.exp (2 * G - B ^ 2 / 2) < 1 / 4 := by
  calc
    _ ≤ 2 * M * Real.exp (-(16 * M + 16)) := by
      apply mul_le_mul_of_nonneg_left _ (by positivity)
      apply Real.exp_le_exp.mpr
      linarith
    _ < 1 / 4 := by
      rw [Real.exp_neg]
      change (2 * M) / Real.exp (16 * M + 16) < 1 / 4
      apply (div_lt_iff₀ (Real.exp_pos _)).2
      linarith [Real.add_one_le_exp (16 * M + 16)]

theorem width_pos (d E : ℕ) (hE : 0 < E) : 0 < width d E := by
  unfold width
  positivity

theorem width_scale (d E : ℕ) (hE : 0 < E) :
    4 * (d : ℝ) + 16 ≤ (width d E : ℝ) * (1 / (E : ℝ)) ^ 2 := by
  have hER : (E : ℝ) ≠ 0 := by exact_mod_cast hE.ne'
  have heq : (width d E : ℝ) * (1 / (E : ℝ)) ^ 2 = 32 * ((d : ℝ) + 1) := by
    simp only [width, Nat.cast_mul, Nat.cast_pow, Nat.cast_add, Nat.cast_ofNat, Nat.cast_one]
    field_simp
  rw [heq]
  nlinarith [(Nat.cast_nonneg d : (0 : ℝ) ≤ d)]

theorem rowBound_scale (d E T : ℕ) {G : ℝ} (hG : 0 ≤ G) (hT : G ≤ (T : ℝ)) :
    2 * G + 16 * ((width d E : ℝ) * ((d : ℝ) + width d E + 1)) + 16 ≤
      (rowBound d E T : ℝ) ^ 2 / 2 := by
  let M : ℝ := (width d E : ℝ) * ((d : ℝ) + width d E + 1)
  have hM : 0 ≤ M := by dsimp [M]; positivity
  have hB : (rowBound d E T : ℝ) = 32 * ((T : ℝ) + M + 1) := by
    simp [rowBound, M, Nat.cast_add, Nat.cast_mul]
  rw [hB]
  change 2 * G + 16 * M + 16 ≤ (32 * ((T : ℝ) + M + 1)) ^ 2 / 2
  have hT0 : (0 : ℝ) ≤ T := Nat.cast_nonneg _
  nlinarith [sq_nonneg ((T : ℝ) + M)]

/-- One common polynomial width and scalar bound work for input and internal rows. -/
theorem sampling_budgets (d E T : ℕ) (hE : 0 < E) {G : ℝ}
    (hG : 0 ≤ G) (hT : G ≤ (T : ℝ)) :
    let N := width d E
    let B := (rowBound d E T : ℝ)
    (2 * (Fintype.card (Cube d) : ℝ) ^ 2 * Real.exp (-(N : ℝ) * (1 / (E : ℝ)) ^ 2 / 2) +
      2 * (N : ℝ) * (d + 1 : ℝ) * Real.exp (2 * G - B ^ 2 / 2) < 1) ∧
    (2 * (Fintype.card (Cube d) : ℝ) ^ 2 * Real.exp (-(N : ℝ) * (1 / (E : ℝ)) ^ 2 / 2) +
      2 * (N : ℝ) * (N : ℝ) * Real.exp (2 * G - B ^ 2 / 2) < 1) := by
  dsimp only
  have hc := covariance_probability_lt_quarter d (width_scale d E hE)
  have hw := coordinate_probability_lt_quarter
    (show 0 ≤ (width d E : ℝ) * ((d : ℝ) + width d E + 1) by positivity)
    (rowBound_scale d E T hG hT)
  have hleft : 2 * (width d E : ℝ) * (d + 1 : ℝ) *
      Real.exp (2 * G - (rowBound d E T : ℝ) ^ 2 / 2) ≤
      2 * ((width d E : ℝ) * ((d : ℝ) + width d E + 1)) *
      Real.exp (2 * G - (rowBound d E T : ℝ) ^ 2 / 2) := by
    apply mul_le_mul_of_nonneg_right _ (Real.exp_pos _).le
    nlinarith [(Nat.cast_nonneg (width d E) : (0 : ℝ) ≤ width d E)]
  have hright : 2 * (width d E : ℝ) * (width d E : ℝ) *
      Real.exp (2 * G - (rowBound d E T : ℝ) ^ 2 / 2) ≤
      2 * ((width d E : ℝ) * ((d : ℝ) + width d E + 1)) *
      Real.exp (2 * G - (rowBound d E T : ℝ) ^ 2 / 2) := by
    apply mul_le_mul_of_nonneg_right _ (Real.exp_pos _).le
    have hp := mul_nonneg (Nat.cast_nonneg (width d E) : (0 : ℝ) ≤ width d E)
      (show 0 ≤ (d : ℝ) + 1 by positivity)
    nlinarith
  constructor <;> linarith

end NeuralGeneralization.TowerSamplingBudget
