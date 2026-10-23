import NeuralGeneralization.BatchTwoNonGaussianMeanFieldLearningBudget
import NeuralGeneralization.SpectralWidthThreshold
import NeuralGeneralization.AboveMeanFieldBudget

/-! Polynomial budgets for the actual non-Gaussian γ>1 all-width theorem. -/
noncomputable section
namespace NeuralGeneralization.BatchTwoNonGaussian.NonGaussianAbove
open ConcreteModel NonGaussianMeanField

def targetBudget (a p d C : ℕ) : ℕ := a*(1+d+C)^p

def energyBudget (ν : CoordinateLaw) (a p r d C : ℕ) : ℕ :=
  64*tailScale ν*(targetBudget a p d C+12*(r+1)+d+C+1)

def widthThreshold (ν : CoordinateLaw) (a p r N₀ mγ d C : ℕ) : ℕ :=
  N₀+8+energyBudget ν a p r d C+(spectralInverseRadius r (energyBudget ν a p r d C))^mγ

def sampleBudget (ν : CoordinateLaw) (a p r N₀ mγ pγ d C : ℕ) : ℕ :=
  spectralCapacity d r (energyBudget ν a p r d C)+
    targetBudget a p d C*(widthThreshold ν a p r N₀ mγ d C)^pγ

theorem targetBudget_growth (a p : ℕ) : PolynomialGrowth2 (fun d C => targetBudget a p d C) :=
  (PolynomialGrowth2.const a).mul
    ((((PolynomialGrowth2.const 1).add PolynomialGrowth2.left).add PolynomialGrowth2.right).pow p)

theorem energyBudget_growth (ν : CoordinateLaw) (a p r : ℕ) :
    PolynomialGrowth2 (fun d C => energyBudget ν a p r d C) :=
  (PolynomialGrowth2.const (64*tailScale ν)).mul
    (((((targetBudget_growth a p).add (PolynomialGrowth2.const (12*(r+1)))).add
      PolynomialGrowth2.left).add PolynomialGrowth2.right).add (PolynomialGrowth2.const 1))

theorem widthThreshold_growth (ν : CoordinateLaw) (a p r N₀ mγ : ℕ) :
    PolynomialGrowth2 (fun d C => widthThreshold ν a p r N₀ mγ d C) := by
  unfold widthThreshold
  exact (((PolynomialGrowth2.const N₀).add (PolynomialGrowth2.const 8)).add
    (energyBudget_growth ν a p r)).add
      (((aboveTruncationBase_polynomialGrowth r).compositionRight (energyBudget_growth ν a p r)).pow mγ)

theorem sampleBudget_growth (ν : CoordinateLaw) (a p r N₀ mγ pγ : ℕ) :
    PolynomialGrowth2 (fun d C => sampleBudget ν a p r N₀ mγ pγ d C) := by
  unfold sampleBudget
  exact ((spectralCapacity_polynomialGrowth r).compositionRight (energyBudget_growth ν a p r)).add
    ((targetBudget_growth a p).mul ((widthThreshold_growth ν a p r N₀ mγ).pow pγ))

theorem sampleBudget_real_envelope (ν : CoordinateLaw) (a p r N₀ mγ pγ : ℕ) :
    ∃ A : ℝ, 0 < A ∧ ∃ m : ℕ, ∀ d C (t : ℝ), 0 ≤ t →
      (sampleBudget ν a p r N₀ mγ pγ d (C+⌈t⌉₊) : ℝ) ≤ A*(1+(d : ℝ)+C+t)^m :=
  (sampleBudget_growth ν a p r N₀ mγ pγ).shifted_ceil_real_envelope

theorem targetBudget_mono (a p d : ℕ) {C S : ℕ} (hCS : C ≤ S) :
    targetBudget a p d C ≤ targetBudget a p d S := by
  unfold targetBudget
  exact Nat.mul_le_mul_left _ (Nat.pow_le_pow_left (by omega) p)

theorem targetBudget_cost (ν : CoordinateLaw) (a p r : ℕ)
    (hcost : ∀ d C, targetMassCost ν d C r ≤ (a : ℝ)*(1+(d : ℝ)+C)^p)
    (d C S : ℕ) (hCS : C ≤ S) : targetMassCost ν d C r ≤ (targetBudget a p d S : ℝ) := by
  apply (hcost d C).trans
  have hh := targetBudget_mono a p d hCS
  simpa only [targetBudget,Nat.cast_mul,Nat.cast_pow,Nat.cast_add,Nat.cast_one] using
    (show (targetBudget a p d C : ℝ) ≤ targetBudget a p d S by exact_mod_cast hh)

theorem energyBudget_ge_first (ν : CoordinateLaw) (a p r d S : ℕ) :
    8*tailScale ν*(d+1) ≤ energyBudget ν a p r d S := by
  unfold energyBudget
  have h : 8*(d+1) ≤ 64*(targetBudget a p d S+12*(r+1)+d+S+1) := by omega
  nlinarith [Nat.mul_le_mul_left (tailScale ν) h]

theorem energyBudget_pos (ν : CoordinateLaw) (a p r d C : ℕ) :
    0 < energyBudget ν a p r d C := by
  have hq : 0 < tailScale ν := by exact_mod_cast tailScale_ge_one ν
  unfold energyBudget
  positivity

theorem widthThreshold_pos (ν : CoordinateLaw) (a p r N₀ mγ d C : ℕ) :
    0 < widthThreshold ν a p r N₀ mγ d C := by unfold widthThreshold; omega

theorem widthThreshold_ge_start (ν : CoordinateLaw) (a p r N₀ mγ d C : ℕ) :
    N₀ ≤ widthThreshold ν a p r N₀ mγ d C := by unfold widthThreshold; omega

theorem widthThreshold_energy_sq (ν : CoordinateLaw) (a p r N₀ mγ d C : ℕ) :
    (energyBudget ν a p r d C : ℝ) ≤ (widthThreshold ν a p r N₀ mγ d C : ℝ)^2 := by
  have hT : (1 : ℝ) ≤ widthThreshold ν a p r N₀ mγ d C := by
    exact_mod_cast widthThreshold_pos ν a p r N₀ mγ d C
  have hKT : (energyBudget ν a p r d C : ℝ) ≤ widthThreshold ν a p r N₀ mγ d C := by
    exact_mod_cast (show energyBudget ν a p r d C ≤ widthThreshold ν a p r N₀ mγ d C by
      unfold widthThreshold; omega)
  nlinarith

theorem widthThreshold_ge_truncation (ν : CoordinateLaw) (a p r N₀ mγ d C : ℕ) :
    spectralInverseRadius r (energyBudget ν a p r d C)^mγ ≤
      widthThreshold ν a p r N₀ mγ d C := by unfold widthThreshold; omega

theorem sampleBudget_ge_capacity (ν : CoordinateLaw) (a p r N₀ mγ pγ d C : ℕ) :
    spectralCapacity d r (energyBudget ν a p r d C) ≤ sampleBudget ν a p r N₀ mγ pγ d C := by
  unfold sampleBudget; omega

theorem energyBudget_rate_gap (ν : CoordinateLaw) (a p r : ℕ)
    (hcost : ∀ d C, targetMassCost ν d C r ≤ (a : ℝ)*(1+(d : ℝ)+C)^p)
    (d C : ℕ) (ε : ℝ) (hε : 0 < ε) :
    targetMassCost ν d C r+Real.log (12*((r : ℝ)+1)/ε) ≤
      (energyBudget ν a p r d (C+⌈Real.log (1/ε)⌉₊) : ℝ)/(64*(tailScale ν : ℝ)) := by
  let t := Real.log (1/ε)
  let S := C+⌈t⌉₊
  have ht : t ≤ (S : ℝ) := by
    have hh := Nat.le_ceil t
    dsimp [S]
    push_cast
    linarith [Nat.cast_nonneg C (α := ℝ)]
  have hlog : Real.log (12*((r : ℝ)+1)/ε) ≤ 12*((r : ℝ)+1)+t := by
    have hp : 0 < 12*((r : ℝ)+1) := by positivity
    rw [show 12*((r : ℝ)+1)/ε=12*((r : ℝ)+1)*(1/ε) by ring,
      Real.log_mul hp.ne' (one_div_pos.mpr hε).ne']
    have hh := Real.log_le_sub_one_of_pos hp
    dsimp [t]
    linarith
  have hB := targetBudget_cost ν a p r hcost d C S (by dsimp [S]; omega)
  change _ ≤ (energyBudget ν a p r d S : ℝ)/(64*(tailScale ν : ℝ))
  unfold energyBudget
  push_cast
  rw [mul_div_cancel_left₀ _ (show 64*(tailScale ν : ℝ) ≠ 0 by
    have := tailScale_ge_one ν; positivity)]
  linarith [Nat.cast_nonneg d (α := ℝ)]

theorem sampleBudget_ge_smallWidth (ν : CoordinateLaw) (a p r : ℕ)
    (hcost : ∀ d C, targetMassCost ν d C r ≤ (a : ℝ)*(1+(d : ℝ)+C)^p)
    (N₀ mγ pγ d C : ℕ) (t γ : ℝ) (hγ : γ ≤ (pγ : ℝ)) :
    targetMassCost ν d C r*(widthThreshold ν a p r N₀ mγ d (C+⌈t⌉₊) : ℝ)^γ ≤
      (sampleBudget ν a p r N₀ mγ pγ d (C+⌈t⌉₊) : ℝ) := by
  let S := C+⌈t⌉₊
  let T := widthThreshold ν a p r N₀ mγ d S
  have hT : (1 : ℝ) ≤ T := by exact_mod_cast widthThreshold_pos ν a p r N₀ mγ d S
  have hpow : (T : ℝ)^γ ≤ (T : ℝ)^pγ := by
    simpa only [Real.rpow_natCast] using Real.rpow_le_rpow_of_exponent_le hT hγ
  have hh := mul_le_mul (targetBudget_cost ν a p r hcost d C S (by dsimp [S]; omega)) hpow
    (Real.rpow_nonneg (Nat.cast_nonneg T) γ) (Nat.cast_nonneg (targetBudget a p d S))
  apply hh.trans
  exact_mod_cast (show targetBudget a p d S*T^pγ ≤ sampleBudget ν a p r N₀ mγ pγ d S by
    unfold sampleBudget
    dsimp only [T]
    omega)

end NeuralGeneralization.BatchTwoNonGaussian.NonGaussianAbove
