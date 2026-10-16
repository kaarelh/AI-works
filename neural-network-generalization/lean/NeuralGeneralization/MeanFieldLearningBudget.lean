import NeuralGeneralization.PowerPriorTargetMass
import NeuralGeneralization.MeanFieldFunctionClass

/-!
# Explicit polynomial learning budgets at mean-field scaling

The energy pays the all-width target rate and the finite layer prefactor.
The sample budget adds the compressed class entropy to the target rate at
the polynomial width threshold. Integer rounding absorbs log(1/epsilon).
-/

noncomputable section
namespace NeuralGeneralization.MeanFieldLearningBudget
open ConcreteModel MeanFieldBudgets

def targetBudget (r d C : ℕ) : ℕ :=
  ⌈cylinderPolynomialCoefficient r⌉₊*(1+d+C)^cylinderPolynomialDegree r

def energyBudget (r d C : ℕ) : ℕ :=
  8*(targetBudget r d C+6*(r+2)+d+C+1)

def widthThreshold (r d C : ℕ) : ℕ :=
  empiricalWidthThreshold d r (energyBudget r d C)

def sampleBudget (r d C : ℕ) : ℕ :=
  MeanFieldFunctionClass.capacity d r (energyBudget r d C)+
    targetBudget r d C*widthThreshold r d C

theorem targetBudget_polynomialGrowth (r : ℕ) :
    PolynomialGrowth2 (fun d C => targetBudget r d C) := by
  unfold targetBudget
  exact (PolynomialGrowth2.const _).mul
    ((((PolynomialGrowth2.const 1).add PolynomialGrowth2.left).add
      PolynomialGrowth2.right).pow _)

theorem energyBudget_polynomialGrowth (r : ℕ) :
    PolynomialGrowth2 (fun d C => energyBudget r d C) := by
  unfold energyBudget
  exact (PolynomialGrowth2.const 8).mul
    (((((targetBudget_polynomialGrowth r).add
      (PolynomialGrowth2.const (6*(r+2)))).add PolynomialGrowth2.left).add
      PolynomialGrowth2.right).add (PolynomialGrowth2.const 1))

theorem widthThreshold_polynomialGrowth (r : ℕ) :
    PolynomialGrowth2 (fun d C => widthThreshold r d C) := by
  exact (empiricalWidthThreshold_polynomialGrowth r).compositionRight
    (energyBudget_polynomialGrowth r)

theorem sampleBudget_polynomialGrowth (r : ℕ) :
    PolynomialGrowth2 (fun d C => sampleBudget r d C) := by
  unfold sampleBudget
  exact ((MeanFieldFunctionClass.capacity_polynomialGrowth r).compositionRight
    (energyBudget_polynomialGrowth r)).add
    ((targetBudget_polynomialGrowth r).mul (widthThreshold_polynomialGrowth r))

theorem sampleBudget_real_envelope (r : ℕ) :
    ∃ A : ℝ, 0 < A ∧ ∃ m : ℕ, ∀ d C (t : ℝ), 0 ≤ t →
      (sampleBudget r d (C+⌈t⌉₊) : ℝ) ≤ A*(1+(d : ℝ)+C+t)^m :=
  (sampleBudget_polynomialGrowth r).shifted_ceil_real_envelope

theorem cylinderPolynomial_le_targetBudget (r d C : ℕ) :
    cylinderPolynomialCoefficient r*(1+(d : ℝ)+C)^cylinderPolynomialDegree r ≤
      (targetBudget r d C : ℝ) := by
  unfold targetBudget
  push_cast
  exact mul_le_mul_of_nonneg_right (Nat.le_ceil _) (by positivity)

theorem targetBudget_mono_complexity (r d : ℕ) {C S : ℕ} (hCS : C ≤ S) :
    targetBudget r d C ≤ targetBudget r d S := by
  unfold targetBudget
  apply Nat.mul_le_mul_left
  apply Nat.pow_le_pow_left
  omega

theorem targetBudget_shifted_ge (r d C : ℕ) (t : ℝ) :
    cylinderPolynomialCoefficient r*(1+(d : ℝ)+C)^cylinderPolynomialDegree r ≤
      (targetBudget r d (C+⌈t⌉₊) : ℝ) := by
  exact (cylinderPolynomial_le_targetBudget r d C).trans
    (by exact_mod_cast targetBudget_mono_complexity r d (Nat.le_add_right C ⌈t⌉₊))

theorem energyBudget_ge_eight (r d C : ℕ) : 8 ≤ energyBudget r d C := by
  unfold energyBudget
  omega

theorem widthThreshold_pos (r d C : ℕ) : 0 < widthThreshold r d C := by
  unfold widthThreshold empiricalWidthThreshold
  omega

/-- Every actual target rate and the union factor `r+2` are paid by this
explicit polynomial energy budget. -/
theorem energyBudget_rate_gap (r d C : ℕ) (ε : ℝ) (hε : 0 < ε) :
    cylinderPolynomialCoefficient r*(1+(d : ℝ)+C)^cylinderPolynomialDegree r +
      Real.log (6*((r : ℝ)+2)/ε) ≤
      (energyBudget r d (C+⌈Real.log (1/ε)⌉₊) : ℝ)/8 := by
  let t := Real.log (1/ε)
  let S := C+⌈t⌉₊
  have ht : t ≤ (S : ℝ) := by
    have hh := Nat.le_ceil t
    dsimp [S]
    push_cast
    linarith [Nat.cast_nonneg C (α := ℝ)]
  have hlog : Real.log (6*((r : ℝ)+2)/ε) ≤ 6*((r : ℝ)+2)+t := by
    have hp : 0 < 6*((r : ℝ)+2) := by positivity
    rw [show 6*((r : ℝ)+2)/ε = (6*((r : ℝ)+2))*(1/ε) by ring,
      Real.log_mul hp.ne' (one_div_pos.mpr hε).ne']
    have hl := Real.log_le_sub_one_of_pos hp
    dsimp [t]
    linarith
  have hB := targetBudget_shifted_ge r d C t
  change _ ≤ (energyBudget r d S : ℝ)/8
  unfold energyBudget
  push_cast
  dsimp [S] at hB ⊢
  linarith [Nat.cast_nonneg d (α := ℝ)]

theorem sampleBudget_ge_capacity (r d C : ℕ) :
    MeanFieldFunctionClass.capacity d r (energyBudget r d C) ≤ sampleBudget r d C := by
  unfold sampleBudget
  omega

theorem sampleBudget_ge_actual_smallWidth (r d C : ℕ) (t : ℝ) :
    cylinderPolynomialCoefficient r*(1+(d : ℝ)+C)^cylinderPolynomialDegree r *
      (widthThreshold r d (C+⌈t⌉₊) : ℝ) ≤
      (sampleBudget r d (C+⌈t⌉₊) : ℝ) := by
  have hrate := mul_le_mul_of_nonneg_right (targetBudget_shifted_ge r d C t)
    (Nat.cast_nonneg (widthThreshold r d (C+⌈t⌉₊)) : (0 : ℝ) ≤ _)
  apply hrate.trans
  have hh : targetBudget r d (C+⌈t⌉₊)*widthThreshold r d (C+⌈t⌉₊) ≤
      sampleBudget r d (C+⌈t⌉₊) := by unfold sampleBudget; omega
  exact_mod_cast hh

end NeuralGeneralization.MeanFieldLearningBudget
