import NeuralGeneralization.PowerPriorTargetMass
import NeuralGeneralization.SpectralFunctionClass

/-!
# Polynomial budgets for the all-width above-mean-field theorem

These explicit natural budgets combine target mass, the spectral relevant
class, the deterministic truncation threshold, and the small-width splice.
All constants in their polynomial envelopes depend only on the fixed depth
and fixed prior exponent.
-/

noncomputable section

namespace NeuralGeneralization.ConcreteModel

def aboveTargetBudget (r d C : ℕ) : ℕ :=
  ⌈cylinderPolynomialCoefficient r⌉₊ * (1+d+C)^cylinderPolynomialDegree r

def aboveEnergyBudget (r d C : ℕ) : ℕ :=
  64*(aboveTargetBudget r d C+4*(r+1)+d+C+1)

def aboveTruncationBase (r K : ℕ) : ℕ := 12*(K*(2*K+3)^r+1)

def aboveWidthThreshold (r N₀ mγ d C : ℕ) : ℕ :=
  N₀+8+aboveEnergyBudget r d C+
    (aboveTruncationBase r (aboveEnergyBudget r d C))^mγ

def aboveSampleBudget (r N₀ mγ pγ d C : ℕ) : ℕ :=
  spectralCapacity d r (aboveEnergyBudget r d C)+
    aboveTargetBudget r d C*(aboveWidthThreshold r N₀ mγ d C)^pγ

theorem aboveTargetBudget_polynomialGrowth (r : ℕ) :
    PolynomialGrowth2 (fun d C => aboveTargetBudget r d C) := by
  unfold aboveTargetBudget
  exact (PolynomialGrowth2.const _).mul
    ((((PolynomialGrowth2.const 1).add PolynomialGrowth2.left).add
      PolynomialGrowth2.right).pow _)

theorem aboveEnergyBudget_polynomialGrowth (r : ℕ) :
    PolynomialGrowth2 (fun d C => aboveEnergyBudget r d C) := by
  unfold aboveEnergyBudget
  exact (PolynomialGrowth2.const 64).mul
    (((((aboveTargetBudget_polynomialGrowth r).add
      (PolynomialGrowth2.const (4*(r+1)))).add PolynomialGrowth2.left).add
      PolynomialGrowth2.right).add (PolynomialGrowth2.const 1))

theorem aboveTruncationBase_polynomialGrowth (r : ℕ) :
    PolynomialGrowth2 (fun _ K => aboveTruncationBase r K) := by
  unfold aboveTruncationBase
  exact (PolynomialGrowth2.const 12).mul
    ((PolynomialGrowth2.right.mul
      ((((PolynomialGrowth2.const 2).mul PolynomialGrowth2.right).add
        (PolynomialGrowth2.const 3)).pow r)).add (PolynomialGrowth2.const 1))

theorem aboveWidthThreshold_polynomialGrowth (r N₀ mγ : ℕ) :
    PolynomialGrowth2 (fun d C => aboveWidthThreshold r N₀ mγ d C) := by
  unfold aboveWidthThreshold
  exact (((PolynomialGrowth2.const N₀).add (PolynomialGrowth2.const 8)).add
    (aboveEnergyBudget_polynomialGrowth r)).add
    (((aboveTruncationBase_polynomialGrowth r).compositionRight
      (aboveEnergyBudget_polynomialGrowth r)).pow mγ)

theorem aboveSampleBudget_polynomialGrowth (r N₀ mγ pγ : ℕ) :
    PolynomialGrowth2 (fun d C => aboveSampleBudget r N₀ mγ pγ d C) := by
  unfold aboveSampleBudget
  exact ((spectralCapacity_polynomialGrowth r).compositionRight
    (aboveEnergyBudget_polynomialGrowth r)).add
    ((aboveTargetBudget_polynomialGrowth r).mul
      ((aboveWidthThreshold_polynomialGrowth r N₀ mγ).pow pγ))

/-- The exact real polynomial form required by the main theorem, uniformly
for every nonnegative real accuracy argument before it is rounded. -/
theorem aboveSampleBudget_real_envelope (r N₀ mγ pγ : ℕ) :
    ∃ A : ℝ, 0 < A ∧ ∃ m : ℕ, ∀ d C (t : ℝ), 0 ≤ t →
      (aboveSampleBudget r N₀ mγ pγ d (C+⌈t⌉₊) : ℝ) ≤
        A*(1+(d : ℝ)+C+t)^m :=
  (aboveSampleBudget_polynomialGrowth r N₀ mγ pγ).shifted_ceil_real_envelope

theorem cylinderPolynomial_le_aboveTargetBudget (r d C : ℕ) :
    cylinderPolynomialCoefficient r*(1+(d : ℝ)+C)^cylinderPolynomialDegree r ≤
      (aboveTargetBudget r d C : ℝ) := by
  unfold aboveTargetBudget
  push_cast
  exact mul_le_mul_of_nonneg_right (Nat.le_ceil _) (by positivity)

theorem aboveTargetBudget_mono_complexity (r d : ℕ) {C S : ℕ} (hCS : C ≤ S) :
    aboveTargetBudget r d C ≤ aboveTargetBudget r d S := by
  unfold aboveTargetBudget
  apply Nat.mul_le_mul_left
  apply Nat.pow_le_pow_left
  omega

theorem aboveEnergyBudget_pos (r d C : ℕ) : 0 < aboveEnergyBudget r d C := by
  unfold aboveEnergyBudget
  positivity

theorem aboveWidthThreshold_pos (r N₀ mγ d C : ℕ) :
    0 < aboveWidthThreshold r N₀ mγ d C := by
  unfold aboveWidthThreshold
  omega

theorem aboveSampleBudget_ge_capacity (r N₀ mγ pγ d C : ℕ) :
    spectralCapacity d r (aboveEnergyBudget r d C) ≤
      aboveSampleBudget r N₀ mγ pγ d C := by
  unfold aboveSampleBudget
  omega

theorem aboveSampleBudget_ge_smallWidth (r N₀ mγ pγ d C : ℕ) :
    aboveTargetBudget r d C*(aboveWidthThreshold r N₀ mγ d C)^pγ ≤
      aboveSampleBudget r N₀ mγ pγ d C := by
  unfold aboveSampleBudget
  omega

/-- The target budget is an actual prior-mass bound, not just an arithmetic
estimate of a formal cylinder expression. -/
theorem powerPrior_target_mass_aboveBudget {d C N r : ℕ}
    (hd : 0 < d) (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (f : BooleanFunction d) (hf : realizesAtComplexity (r := r) φ f C)
    (hCN : C ≤ N) {γ : ℝ} (hγ : 1 ≤ γ) :
    Real.exp (-(aboveTargetBudget r d C : ℝ)*(N : ℝ)^γ) ≤
      functionMass φ (1/2) (powerPrior d N r γ) f := by
  apply le_trans _ (powerPrior_target_mass_polynomial hd φ hφ f hf hCN hγ)
  apply Real.exp_le_exp.mpr
  have hh := mul_le_mul_of_nonneg_right (cylinderPolynomial_le_aboveTargetBudget r d C)
    (Real.rpow_nonneg (Nat.cast_nonneg N) γ)
  linarith

/-- The complete small-width contribution to the final sample budget. Its
width exponent is any natural upper bound on the fixed real exponent. -/
theorem powerPrior_target_mass_smallWidthBudget {d C S N r N₀ mγ pγ : ℕ}
    (hd : 0 < d) (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (f : BooleanFunction d) (hf : realizesAtComplexity (r := r) φ f C)
    (hCN : C ≤ N) (hCS : C ≤ S)
    (hNT : N ≤ aboveWidthThreshold r N₀ mγ d S)
    {γ : ℝ} (hγ : 1 ≤ γ) (hγp : γ ≤ (pγ : ℝ)) :
    Real.exp (-(aboveSampleBudget r N₀ mγ pγ d S : ℝ)) ≤
      functionMass φ (1/2) (powerPrior d N r γ) f := by
  have hN : 0 < N := lt_of_lt_of_le (Nat.succ_le_iff.mp hf.1) hCN
  have hN1 : (1 : ℝ) ≤ N := by exact_mod_cast hN
  have hpow : (N : ℝ)^γ ≤ (aboveWidthThreshold r N₀ mγ d S : ℝ)^pγ := by
    calc
      _ ≤ (N : ℝ)^(pγ : ℝ) := Real.rpow_le_rpow_of_exponent_le hN1 hγp
      _ = (N : ℝ)^pγ := Real.rpow_natCast _ _
      _ ≤ _ := pow_le_pow_left₀ (Nat.cast_nonneg N) (by exact_mod_cast hNT) pγ
  have hcoef : (aboveTargetBudget r d C : ℝ) ≤ aboveTargetBudget r d S := by
    exact_mod_cast aboveTargetBudget_mono_complexity r d hCS
  have hprod := mul_le_mul hcoef hpow (Real.rpow_nonneg (Nat.cast_nonneg N) γ)
    (Nat.cast_nonneg (aboveTargetBudget r d S) : (0 : ℝ) ≤ _)
  have hsum : (aboveTargetBudget r d S : ℝ)*
      (aboveWidthThreshold r N₀ mγ d S : ℝ)^pγ ≤
      (aboveSampleBudget r N₀ mγ pγ d S : ℝ) := by
    exact_mod_cast aboveSampleBudget_ge_smallWidth r N₀ mγ pγ d S
  apply le_trans _ (powerPrior_target_mass_aboveBudget hd φ hφ f hf hCN hγ)
  apply Real.exp_le_exp.mpr
  linarith [hprod.trans hsum]

end NeuralGeneralization.ConcreteModel
