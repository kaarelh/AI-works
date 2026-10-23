import NeuralGeneralization.BatchTwoContinuousDepthPowerPolynomial
import NeuralGeneralization.BatchTwoContinuousDepthSlowMemorizer

/-! Width-uniform sharp prior mass around the actual slow-channel memorizer. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1200000
open MeasureTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthPower
open ConcreteModel BatchTwoContinuous BatchTwoNonGaussian BatchTwoContinuousDepthLower
open BatchTwoContinuous.FiniteTarget

def slowEnergyCeiling (r : ℕ) : ℝ := (49/25)*(r : ℝ)+6

def slowEntropyCost (M r : ℕ) (ρ : ℝ) : ℝ :=
  sharpNoiseCost standardGaussian 2 M (r+1) (slowEnergyCeiling r) ρ

def slowResourceSize (M r : ℕ) (ρ : ℝ) : ℝ :=
  20+(M : ℝ)+10*(r : ℝ)+|Real.log (radiusCap standardGaussian)|+
    Real.log (1/min 1 ρ)

theorem slowEntropyCost_polynomial (M r : ℕ) {ρ : ℝ} (hρ : 0<ρ) :
    slowEntropyCost M r ρ≤noisePolynomialCoefficient standardGaussian*(slowResourceSize M r ρ)^7 := by
  have hlog : 0≤Real.log (1/min 1 ρ) :=
    Real.log_nonneg ((one_le_div (lt_min zero_lt_one hρ)).mpr (min_le_left _ _))
  have ha := abs_nonneg (Real.log (radiusCap standardGaussian))
  have hM := Nat.cast_nonneg M (α := ℝ)
  have hr := Nat.cast_nonneg r (α := ℝ)
  apply powerPolynomialNoiseCost_global standardGaussian
  all_goals dsimp [slowResourceSize,slowEnergyCeiling,targetLogBudget]
  all_goals push_cast
  all_goals linarith

theorem slow_memorizer_training_sharp_mass {n M N r : ℕ} (hn : 0<n) (hMN : M≤N)
    (hM : 2*n≤M) {δ ρ σ : ℝ} (hδ : 0<δ) (hδ1 : δ≤1) (hρ : 0<ρ) (hσ : 0<σ)
    (s : Fin n → RealInput 2) (f : RealInput 2 → ℝ)
    (hs : ∀ i, |s i 0|≤1) (hy : ∀ i, |f (s i)|≤13/20)
    (hsep : ∀ i j, i≠j → δ≤|s i 0-s j 0|)
    (hfirst : 14*(n : ℝ)*(interpolationSlope n δ)^2≤3*M)
    (hsmall : 16*(M : ℝ)*(n : ℝ)^2*((6/7 : ℝ)^(r+1))^2≤1)
    (hball : ∀ i, ∑ j, s i j^2≤1) (hscale : (N : ℝ)*σ^2≤1) :
    Real.exp (-slowEnergyCeiling r/(2*σ^2)-(N : ℝ)*slowEntropyCost M r ρ) ≤
      (ConcreteModel.smallPrior 2 N (r+1) σ).real (trainingEvent Real.tanh f ρ s) := by
  obtain ⟨w,hw,henergy,hout⟩ := exists_slow_channel_memorizer hn (le_refl M) hM hδ hδ1
    s (fun i => f (s i)) hs hy hsep hfirst hsmall
  apply gaussian_training_sharp_mass (by norm_num) (by omega) hMN
    (by unfold slowEnergyCeiling; positivity) hρ hσ w ?_ f s hw hball hscale
  rw [hout]
  unfold slowEnergyCeiling
  linarith

end NeuralGeneralization.BatchTwoContinuousDepthPower
