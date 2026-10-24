import NeuralGeneralization.BatchTwoNonGaussianRowTail
import NeuralGeneralization.TowerSamplingBudget

/-! Polynomial row bounds for the mixed non-Gaussian/Gaussian realization.
All dependence on the fixed coordinate law is confined to one natural constant. -/

noncomputable section
namespace NeuralGeneralization.BatchTwoNonGaussian
open ConcreteModel

def lawScale (ν : CoordinateLaw) : ℝ := min ν.lowerCurvature 1
def lawFactor (ν : CoordinateLaw) : ℕ :=
  ⌈max 1 (max (ν.comparisonFactor ν.lowerCurvature) (1 / lawScale ν))⌉₊

theorem lawScale_pos (ν : CoordinateLaw) : 0 < lawScale ν :=
  lt_min ν.lowerCurvature_pos zero_lt_one

theorem lawFactor_ge_one (ν : CoordinateLaw) : (1 : ℝ) ≤ lawFactor ν :=
  (le_max_left _ _).trans (Nat.le_ceil _)

theorem comparisonFactor_le_lawFactor (ν : CoordinateLaw) :
    ν.comparisonFactor ν.lowerCurvature ≤ lawFactor ν :=
  (le_max_left _ _).trans ((le_max_right _ _).trans (Nat.le_ceil _))

theorem lawScale_mul_factor (ν : CoordinateLaw) : 1 ≤ lawScale ν * lawFactor ν := by
  have h : 1 / lawScale ν ≤ lawFactor ν :=
    (le_max_right _ _).trans ((le_max_right _ _).trans (Nat.le_ceil _))
  have hm := (div_le_iff₀ (lawScale_pos ν)).mp h
  nlinarith

def actualRowBound (ν : CoordinateLaw) (d E T : ℕ) : ℕ :=
  lawFactor ν * (32 * (T + lawFactor ν * TowerSamplingBudget.width d E *
    (d + TowerSamplingBudget.width d E + 1) + 1))

private theorem generalized_coordinate_probability_lt_quarter {M G a B : ℝ}
    (hM : 0 ≤ M) (hscale : 2 * G + 16 * M + 16 ≤ a * B ^ 2 / 2) :
    2 * M * Real.exp (2 * G - a * B ^ 2 / 2) < 1 / 4 := by
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

theorem actualRowBound_scale (ν : CoordinateLaw) (d E T : ℕ) {G : ℝ}
    (hG : 0 ≤ G) (hT : G ≤ (T : ℝ)) :
    2 * G + 16 * ((lawFactor ν : ℝ) * TowerSamplingBudget.width d E *
      ((d : ℝ) + TowerSamplingBudget.width d E + 1)) + 16 ≤
      lawScale ν * (actualRowBound ν d E T : ℝ) ^ 2 / 2 := by
  let M : ℝ := (lawFactor ν : ℝ) * TowerSamplingBudget.width d E *
    ((d : ℝ) + TowerSamplingBudget.width d E + 1)
  let b : ℝ := 32 * ((T : ℝ) + M + 1)
  have hM : 0 ≤ M := by dsimp [M]; positivity
  have hq := lawFactor_ge_one ν
  have haq := lawScale_mul_factor ν
  have ha := lawScale_pos ν
  have hq2 : 1 ≤ lawScale ν * (lawFactor ν : ℝ) ^ 2 := by
    have hh := mul_le_mul_of_nonneg_right haq (show 0 ≤ (lawFactor ν : ℝ) by positivity)
    nlinarith
  have hB : (actualRowBound ν d E T : ℝ) = lawFactor ν * b := by
    simp [actualRowBound, b, M, Nat.cast_add, Nat.cast_mul]
  rw [hB]
  change 2 * G + 16 * M + 16 ≤ lawScale ν * ((lawFactor ν : ℝ) * b) ^ 2 / 2
  have hbase : 2 * G + 16 * M + 16 ≤ b ^ 2 / 2 := by
    dsimp [b]
    have hT0 : (0 : ℝ) ≤ T := Nat.cast_nonneg _
    nlinarith [sq_nonneg ((T : ℝ) + M)]
  have hmul := mul_le_mul_of_nonneg_right hq2 (sq_nonneg b)
  nlinarith

/-- A single explicit polynomial bound handles actual first-layer coordinates
and Gaussian internal coordinates simultaneously. -/
theorem actual_sampling_budgets (ν : CoordinateLaw) (d E T : ℕ) (hE : 0 < E)
    {G : ℝ} (hG : 0 ≤ G) (hT : G ≤ (T : ℝ)) :
    let N := TowerSamplingBudget.width d E
    let B := (actualRowBound ν d E T : ℝ)
    (2 * (Fintype.card (Cube d) : ℝ) ^ 2 * Real.exp (-(N : ℝ) * (1 / (E : ℝ)) ^ 2 / 2) +
      2 * ν.comparisonFactor ν.lowerCurvature * (N : ℝ) * (d + 1 : ℝ) *
        Real.exp (2 * G - ν.lowerCurvature * B ^ 2 / 2) < 1) ∧
    (2 * (Fintype.card (Cube d) : ℝ) ^ 2 * Real.exp (-(N : ℝ) * (1 / (E : ℝ)) ^ 2 / 2) +
      2 * (N : ℝ) * (N : ℝ) * Real.exp (2 * G - B ^ 2 / 2) < 1) := by
  dsimp only
  let N := TowerSamplingBudget.width d E
  let B : ℝ := actualRowBound ν d E T
  let M : ℝ := (lawFactor ν : ℝ) * N * ((d : ℝ) + N + 1)
  have hc := TowerSamplingBudget.covariance_probability_lt_quarter d
    (TowerSamplingBudget.width_scale d E hE)
  have hM : 0 ≤ M := by dsimp [M]; positivity
  have ht := generalized_coordinate_probability_lt_quarter hM (actualRowBound_scale ν d E T hG hT)
  have hcoef := comparisonFactor_le_lawFactor ν
  have hq := lawFactor_ge_one ν
  have hN0 : 0 ≤ (N : ℝ) := Nat.cast_nonneg N
  have hd0 : 0 ≤ (d : ℝ) := Nat.cast_nonneg d
  have hcomp0 := (ν.comparisonFactor_pos _ ν.lowerCurvature_pos).le
  have hleftCoef : 2 * ν.comparisonFactor ν.lowerCurvature * (N : ℝ) * (d + 1 : ℝ) ≤ 2 * M := by
    dsimp [M]
    have h := mul_le_mul_of_nonneg_right hcoef (show 0 ≤ (N : ℝ) * (d + 1 : ℝ) by positivity)
    have hh := mul_nonneg (show 0 ≤ (lawFactor ν : ℝ) by positivity) (sq_nonneg (N : ℝ))
    nlinarith
  have hrightCoef : 2 * (N : ℝ) * (N : ℝ) ≤ 2 * M := by
    dsimp [M]
    have h := mul_le_mul_of_nonneg_right hq (sq_nonneg (N : ℝ))
    have hh := mul_nonneg (show 0 ≤ (lawFactor ν : ℝ) * N by positivity)
      (show 0 ≤ (d : ℝ) + 1 by positivity)
    nlinarith
  have hleftExp : Real.exp (2 * G - ν.lowerCurvature * B ^ 2 / 2) ≤
      Real.exp (2 * G - lawScale ν * B ^ 2 / 2) := by
    apply Real.exp_le_exp.mpr
    have h := mul_le_mul_of_nonneg_right (min_le_left ν.lowerCurvature 1) (sq_nonneg B)
    dsimp [lawScale]
    linarith
  have hrightExp : Real.exp (2 * G - B ^ 2 / 2) ≤
      Real.exp (2 * G - lawScale ν * B ^ 2 / 2) := by
    apply Real.exp_le_exp.mpr
    have h := mul_le_mul_of_nonneg_right (min_le_right ν.lowerCurvature 1) (sq_nonneg B)
    dsimp [lawScale]
    linarith
  have hleft := mul_le_mul hleftCoef hleftExp (Real.exp_pos _).le (by positivity : 0 ≤ 2 * M)
  have hright := mul_le_mul hrightCoef hrightExp (Real.exp_pos _).le (by positivity : 0 ≤ 2 * M)
  constructor <;> linarith

end NeuralGeneralization.BatchTwoNonGaussian
