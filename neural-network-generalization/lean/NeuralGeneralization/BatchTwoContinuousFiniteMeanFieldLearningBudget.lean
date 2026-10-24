import NeuralGeneralization.BatchTwoContinuousAboveEnergy
import NeuralGeneralization.BatchTwoContinuousFiniteMeanFieldGrowth
import NeuralGeneralization.BatchTwoContinuousFiniteTargetPower
import NeuralGeneralization.BatchTwoContinuousStrongBudget

/-! Width-independent polynomial resources for continuous regression at the mean-field exponent. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous.FiniteMeanField
open ConcreteModel BatchTwoNonGaussian NonGaussianMeanField

def targetBudget (a p d S : ℕ) : ℕ := a*(1+d+S)^p
def energyBudget (ν : CoordinateLaw) (a p r d S : ℕ) : ℕ :=
  64*tailScale ν*(targetBudget a p d S+24*(r+1)+d+S+1)
def accuracyBudget (S : ℕ) : ℕ := 2*(S+1)
def thresholdBudget (ν : CoordinateLaw) (a p r d S : ℕ) : ℕ :=
  FiniteQuery.widthThreshold ν d r (energyBudget ν a p r d S) (accuracyBudget S)
def smallEnergyBudget (ν : CoordinateLaw) (a p r d S : ℕ) : ℕ :=
  energyBudget ν a p r d S+
    8*tailScale ν*(d+2+r*thresholdBudget ν a p r d S)
def sampleBudget (ν : CoordinateLaw) (a p r d S : ℕ) : ℕ :=
  capacity ν d r (energyBudget ν a p r d S) (accuracyBudget S)+
    coverEntropy d r (smallEnergyBudget ν a p r d S) (accuracyBudget S)

theorem targetBudget_growth (a p : ℕ) : PolynomialGrowth2 (targetBudget a p) := by
  unfold targetBudget
  exact (PolynomialGrowth2.const a).mul
    ((((PolynomialGrowth2.const 1).add PolynomialGrowth2.left).add PolynomialGrowth2.right).pow p)

theorem energyBudget_growth (ν : CoordinateLaw) (a p r : ℕ) :
    PolynomialGrowth2 (energyBudget ν a p r) := by
  unfold energyBudget
  exact (PolynomialGrowth2.const (64*tailScale ν)).mul
    (((((targetBudget_growth a p).add (PolynomialGrowth2.const (24*(r+1)))).add
      PolynomialGrowth2.left).add PolynomialGrowth2.right).add (PolynomialGrowth2.const 1))

theorem accuracyBudget_growth : PolynomialGrowth2 (fun _ S => accuracyBudget S) := by
  unfold accuracyBudget
  exact (PolynomialGrowth2.const 2).mul (PolynomialGrowth2.right.add (PolynomialGrowth2.const 1))

theorem thresholdBudget_growth (ν : CoordinateLaw) (a p r : ℕ) :
    PolynomialGrowth2 (thresholdBudget ν a p r) := by
  exact widthThreshold_growth ν r (energyBudget_growth ν a p r) accuracyBudget_growth

theorem smallEnergyBudget_growth (ν : CoordinateLaw) (a p r : ℕ) :
    PolynomialGrowth2 (smallEnergyBudget ν a p r) := by
  unfold smallEnergyBudget
  exact (energyBudget_growth ν a p r).add
    ((PolynomialGrowth2.const (8*tailScale ν)).mul
      ((PolynomialGrowth2.left.add (PolynomialGrowth2.const 2)).add
        ((PolynomialGrowth2.const r).mul (thresholdBudget_growth ν a p r))))

theorem sampleBudget_growth (ν : CoordinateLaw) (a p r : ℕ) :
    PolynomialGrowth2 (sampleBudget ν a p r) := by
  have hR := accuracyBudget_growth
  have hK := energyBudget_growth ν a p r
  have hSmall := smallEnergyBudget_growth ν a p r
  apply ((capacity_growth ν r hK hR).add
    ((coverEntropy_polynomial r).compositionRight (hSmall.add hR))).mono
  intro d S
  exact Nat.add_le_add le_rfl (coverEntropy_mono (by omega) (by omega))

theorem energyBudget_pos (ν : CoordinateLaw) (a p r d S : ℕ) :
    0<energyBudget ν a p r d S := by
  have hq : 0<tailScale ν := by exact_mod_cast tailScale_ge_one ν
  unfold energyBudget
  positivity

theorem energyBudget_ge_first (ν : CoordinateLaw) (a p r d S : ℕ) :
    8*tailScale ν*(d+1)≤energyBudget ν a p r d S := by
  unfold energyBudget
  have hh : 8*(d+1)≤64*(targetBudget a p d S+24*(r+1)+d+S+1) := by omega
  nlinarith [Nat.mul_le_mul_left (tailScale ν) hh]

theorem energyBudget_rate_gap (ν : CoordinateLaw) (a p r d S : ℕ) {D ε : ℝ}
    (hD : D≤(targetBudget a p d S : ℝ)) (hε : 0<ε)
    (ht : Real.log (1/ε)≤(S : ℝ)) :
    D+Real.log (24*((r : ℝ)+1)/ε)≤(energyBudget ν a p r d S : ℝ)/(64*(tailScale ν : ℝ)) := by
  have hlog : Real.log (24*((r : ℝ)+1)/ε)≤24*((r : ℝ)+1)+(S : ℝ) := by
    have hp : 0<24*((r : ℝ)+1) := by positivity
    rw [show 24*((r : ℝ)+1)/ε=24*((r : ℝ)+1)*(1/ε) by ring,
      Real.log_mul hp.ne' (one_div_pos.mpr hε).ne']
    have hh := Real.log_le_sub_one_of_pos hp
    linarith
  unfold energyBudget
  push_cast
  rw [mul_div_cancel_left₀ _ (show 64*(tailScale ν : ℝ)≠0 by
    have := tailScale_ge_one ν; positivity)]
  linarith [Nat.cast_nonneg d (α := ℝ)]

theorem accuracyBudget_gap {ρ τ : ℝ} (hgap : ρ<τ) {S : ℕ}
    (hu : inverseGap ρ τ≤(S : ℝ)) :
    ρ+2*(2/(3*(accuracyBudget S : ℝ)))≤τ := by
  have hp : 0<min 1 (τ-ρ) := lt_min zero_lt_one (by linarith)
  have hu' : 1≤(S : ℝ)*min 1 (τ-ρ) := (div_le_iff₀ hp).mp hu
  have hs : (0 : ℝ)<S+1 := by positivity
  have hinv : 1/((S : ℝ)+1)≤min 1 (τ-ρ) := (div_le_iff₀ hs).mpr (by nlinarith)
  have hh : 2*(2/(3*(accuracyBudget S : ℝ)))≤1/((S : ℝ)+1) := by
    unfold accuracyBudget
    push_cast
    field_simp
    norm_num
  linarith [min_le_right (1 : ℝ) (τ-ρ)]

end NeuralGeneralization.BatchTwoContinuous.FiniteMeanField
