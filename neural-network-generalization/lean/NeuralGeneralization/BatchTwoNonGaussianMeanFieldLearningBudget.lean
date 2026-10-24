import NeuralGeneralization.BatchTwoNonGaussianMeanFieldStatistics

/-! Explicit natural sample budgets, with all law dependence in fixed constants. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
namespace NeuralGeneralization.BatchTwoNonGaussian.NonGaussianMeanField.LearningBudget
open ConcreteModel

def targetBudget (a p d C : ℕ) : ℕ := a*(1+d+C)^p

def energyBudget (ν : CoordinateLaw) (a p r d C : ℕ) : ℕ :=
  8*tailScale ν*(targetBudget a p d C+6*(r+2)+d+C+1)

def learnerThreshold (ν : CoordinateLaw) (a p r d C : ℕ) : ℕ :=
  widthThreshold ν d r (energyBudget ν a p r d C)

def sampleBudget (ν : CoordinateLaw) (a p r d C : ℕ) : ℕ :=
  capacity ν d r (energyBudget ν a p r d C)+targetBudget a p d C*learnerThreshold ν a p r d C

theorem targetBudget_growth (a p : ℕ) : PolynomialGrowth2 (targetBudget a p) :=
  (PolynomialGrowth2.const a).mul ((((PolynomialGrowth2.const 1).add PolynomialGrowth2.left).add PolynomialGrowth2.right).pow p)

theorem energyBudget_growth (ν : CoordinateLaw) (a p r : ℕ) :
    PolynomialGrowth2 (energyBudget ν a p r) :=
  ((PolynomialGrowth2.const 8).mul (PolynomialGrowth2.const (tailScale ν))).mul
    (((((targetBudget_growth a p).add (PolynomialGrowth2.const (6*(r+2)))).add
      PolynomialGrowth2.left).add PolynomialGrowth2.right).add (PolynomialGrowth2.const 1))

theorem learnerThreshold_growth (ν : CoordinateLaw) (a p r : ℕ) :
    PolynomialGrowth2 (learnerThreshold ν a p r) :=
  (widthThreshold_growth ν r).compositionRight (energyBudget_growth ν a p r)

theorem sampleBudget_growth (ν : CoordinateLaw) (a p r : ℕ) :
    PolynomialGrowth2 (sampleBudget ν a p r) :=
  ((capacity_growth ν r).compositionRight (energyBudget_growth ν a p r)).add
    ((targetBudget_growth a p).mul (learnerThreshold_growth ν a p r))

theorem sampleBudget_real_envelope (ν : CoordinateLaw) (a p r : ℕ) :
    ∃ A : ℝ, 0 < A ∧ ∃ m : ℕ, ∀ d C (t : ℝ), 0 ≤ t →
      (sampleBudget ν a p r d (C+⌈t⌉₊) : ℝ) ≤ A*(1+(d : ℝ)+C+t)^m :=
  (sampleBudget_growth ν a p r).shifted_ceil_real_envelope

theorem targetBudget_mono (a p d : ℕ) {C S : ℕ} (hCS : C ≤ S) :
    targetBudget a p d C ≤ targetBudget a p d S := by
  unfold targetBudget
  apply Nat.mul_le_mul_left
  apply Nat.pow_le_pow_left
  omega

theorem targetBudget_shifted_ge (ν : CoordinateLaw) (a p r : ℕ)
    (hcost : ∀ d C, targetMassCost ν d C r ≤ (a : ℝ)*(1+(d : ℝ)+C)^p)
    (d C : ℕ) (t : ℝ) : targetMassCost ν d C r ≤ targetBudget a p d (C+⌈t⌉₊) := by
  have hbase : targetMassCost ν d C r ≤ targetBudget a p d C := by
    simpa only [targetBudget,Nat.cast_mul,Nat.cast_pow,Nat.cast_add,Nat.cast_one] using hcost d C
  exact hbase.trans (by exact_mod_cast targetBudget_mono a p d (Nat.le_add_right C ⌈t⌉₊))

theorem energyBudget_ge (ν : CoordinateLaw) (a p r d C : ℕ) :
    8*tailScale ν ≤ energyBudget ν a p r d C := by
  unfold energyBudget
  nlinarith

theorem energyBudget_rate_gap (ν : CoordinateLaw) (a p r : ℕ)
    (hcost : ∀ d C, targetMassCost ν d C r ≤ (a : ℝ)*(1+(d : ℝ)+C)^p)
    (d C : ℕ) (ε : ℝ) (hε : 0 < ε) :
    targetMassCost ν d C r+Real.log (6*((r : ℝ)+2)/ε) ≤
      (energyBudget ν a p r d (C+⌈Real.log (1/ε)⌉₊) : ℝ)/(8*(tailScale ν : ℝ)) := by
  let t := Real.log (1/ε)
  let S := C+⌈t⌉₊
  have ht : t ≤ (S : ℝ) := by
    have hh := Nat.le_ceil t
    dsimp [S]
    push_cast
    linarith [Nat.cast_nonneg C (α := ℝ)]
  have hlog : Real.log (6*((r : ℝ)+2)/ε) ≤ 6*((r : ℝ)+2)+t := by
    have hp : 0 < 6*((r : ℝ)+2) := by positivity
    rw [show 6*((r : ℝ)+2)/ε=(6*((r : ℝ)+2))*(1/ε) by ring,
      Real.log_mul hp.ne' (one_div_pos.mpr hε).ne']
    have hl := Real.log_le_sub_one_of_pos hp
    dsimp [t]
    linarith
  have hB := targetBudget_shifted_ge ν a p r hcost d C t
  have hq : (0 : ℝ) < tailScale ν := zero_lt_one.trans_le (tailScale_ge_one ν)
  have he : (energyBudget ν a p r d S : ℝ)/(8*(tailScale ν : ℝ))=
      (targetBudget a p d S : ℝ)+6*((r : ℝ)+2)+d+S+1 := by
    unfold energyBudget
    push_cast
    field_simp [hq.ne']
  change _ ≤ (energyBudget ν a p r d S : ℝ)/(8*(tailScale ν : ℝ))
  rw [he]
  change targetMassCost ν d C r ≤ (targetBudget a p d S : ℝ) at hB
  linarith [Nat.cast_nonneg d (α := ℝ)]

theorem sampleBudget_ge_capacity (ν : CoordinateLaw) (a p r d C : ℕ) :
    capacity ν d r (energyBudget ν a p r d C) ≤ sampleBudget ν a p r d C := by
  unfold sampleBudget
  omega

theorem sampleBudget_ge_smallWidth (ν : CoordinateLaw) (a p r : ℕ)
    (hcost : ∀ d C, targetMassCost ν d C r ≤ (a : ℝ)*(1+(d : ℝ)+C)^p)
    (d C : ℕ) (t : ℝ) :
    targetMassCost ν d C r*(learnerThreshold ν a p r d (C+⌈t⌉₊) : ℝ) ≤
      (sampleBudget ν a p r d (C+⌈t⌉₊) : ℝ) := by
  have hh := mul_le_mul_of_nonneg_right (targetBudget_shifted_ge ν a p r hcost d C t)
    (Nat.cast_nonneg (learnerThreshold ν a p r d (C+⌈t⌉₊)) : (0 : ℝ) ≤ _)
  apply hh.trans
  have hnat : targetBudget a p d (C+⌈t⌉₊)*learnerThreshold ν a p r d (C+⌈t⌉₊) ≤
      sampleBudget ν a p r d (C+⌈t⌉₊) := by unfold sampleBudget; omega
  exact_mod_cast hnat

end NeuralGeneralization.BatchTwoNonGaussian.NonGaussianMeanField.LearningBudget
