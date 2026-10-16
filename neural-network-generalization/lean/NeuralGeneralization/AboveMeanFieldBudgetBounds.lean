import NeuralGeneralization.AboveMeanFieldBudget
import NeuralGeneralization.SpectralWidthThreshold

/-! # The explicit budgets satisfy every all-width learning inequality -/

noncomputable section
namespace NeuralGeneralization.ConcreteModel

theorem aboveEnergyBudget_ge_first (r d S : ℕ) :
    8 * (d + 1) ≤ aboveEnergyBudget r d S := by
  unfold aboveEnergyBudget
  omega

theorem aboveWidthThreshold_ge_start (r N₀ m d S : ℕ) :
    N₀ ≤ aboveWidthThreshold r N₀ m d S := by
  unfold aboveWidthThreshold
  omega

theorem aboveWidthThreshold_ge_energy (r N₀ m d S : ℕ) :
    aboveEnergyBudget r d S ≤ aboveWidthThreshold r N₀ m d S := by
  unfold aboveWidthThreshold
  omega

theorem aboveWidthThreshold_energy_sq (r N₀ m d S : ℕ) :
    (aboveEnergyBudget r d S : ℝ) ≤ (aboveWidthThreshold r N₀ m d S : ℝ) ^ 2 := by
  have hT : (1 : ℝ) ≤ aboveWidthThreshold r N₀ m d S := by
    exact_mod_cast aboveWidthThreshold_pos r N₀ m d S
  have hKT : (aboveEnergyBudget r d S : ℝ) ≤ aboveWidthThreshold r N₀ m d S := by
    exact_mod_cast aboveWidthThreshold_ge_energy r N₀ m d S
  nlinarith

theorem aboveWidthThreshold_ge_truncation (r N₀ m d S : ℕ) :
    spectralInverseRadius r (aboveEnergyBudget r d S) ^ m ≤
      aboveWidthThreshold r N₀ m d S := by
  change aboveTruncationBase r (aboveEnergyBudget r d S) ^ m ≤ _
  unfold aboveWidthThreshold
  omega

theorem aboveTargetBudget_shifted_ge (r d C : ℕ) (t : ℝ) :
    cylinderPolynomialCoefficient r * (1 + (d : ℝ) + C) ^ cylinderPolynomialDegree r ≤
      (aboveTargetBudget r d (C + ⌈t⌉₊) : ℝ) := by
  exact (cylinderPolynomial_le_aboveTargetBudget r d C).trans
    (by exact_mod_cast aboveTargetBudget_mono_complexity r d (Nat.le_add_right C ⌈t⌉₊))

theorem aboveEnergyBudget_rate_gap (r d C : ℕ) (ε : ℝ) (hε : 0 < ε) :
    cylinderPolynomialCoefficient r * (1 + (d : ℝ) + C) ^ cylinderPolynomialDegree r +
      Real.log (4 * ((r : ℝ) + 1) / ε) ≤
        (aboveEnergyBudget r d (C + ⌈Real.log (1 / ε)⌉₊) : ℝ) / 64 := by
  let t := Real.log (1 / ε)
  let S := C + ⌈t⌉₊
  have ht : t ≤ (S : ℝ) := by
    have hh := Nat.le_ceil t
    dsimp [S]
    push_cast
    linarith [Nat.cast_nonneg C (α := ℝ)]
  have hlog : Real.log (4 * ((r : ℝ) + 1) / ε) ≤ 4 * ((r : ℝ) + 1) + t := by
    have hp : 0 < 4 * ((r : ℝ) + 1) := by positivity
    rw [show 4 * ((r : ℝ) + 1) / ε = (4 * ((r : ℝ) + 1)) * (1 / ε) by ring,
      Real.log_mul hp.ne' (one_div_pos.mpr hε).ne']
    have hl := Real.log_le_sub_one_of_pos hp
    dsimp [t]
    linarith
  have hB := aboveTargetBudget_shifted_ge r d C t
  change _ ≤ (aboveEnergyBudget r d S : ℝ) / 64
  unfold aboveEnergyBudget
  push_cast
  dsimp [S] at hB ⊢
  linarith [Nat.cast_nonneg d (α := ℝ)]

theorem aboveSampleBudget_ge_actual_smallWidth
    (r N₀ m p d C : ℕ) (t γ : ℝ) (hγ : γ ≤ (p : ℝ)) :
    cylinderPolynomialCoefficient r * (1 + (d : ℝ) + C) ^ cylinderPolynomialDegree r *
      (aboveWidthThreshold r N₀ m d (C + ⌈t⌉₊) : ℝ) ^ γ ≤
      (aboveSampleBudget r N₀ m p d (C + ⌈t⌉₊) : ℝ) := by
  let S := C + ⌈t⌉₊
  let T := aboveWidthThreshold r N₀ m d S
  have hT : (1 : ℝ) ≤ T := by exact_mod_cast aboveWidthThreshold_pos r N₀ m d S
  have hpow : (T : ℝ) ^ γ ≤ (T : ℝ) ^ p := by
    simpa only [Real.rpow_natCast] using Real.rpow_le_rpow_of_exponent_le hT hγ
  have hmul : cylinderPolynomialCoefficient r * (1 + (d : ℝ) + C) ^ cylinderPolynomialDegree r *
      (T : ℝ) ^ γ ≤ (aboveTargetBudget r d S : ℝ) * (T : ℝ) ^ p := by
    exact mul_le_mul (aboveTargetBudget_shifted_ge r d C t) hpow
      (Real.rpow_nonneg (by positivity) _) (Nat.cast_nonneg _)
  refine hmul.trans ?_
  exact_mod_cast aboveSampleBudget_ge_smallWidth r N₀ m p d S

end NeuralGeneralization.ConcreteModel
