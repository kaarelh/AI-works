import NeuralGeneralization.BatchTwoContinuousAboveStatistics
import NeuralGeneralization.ExponentialTailRatio

/-! An explicit energy tail for the bounded-width branch of continuous regression. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous.Above
open ConcreteModel BatchTwoNonGaussian

theorem powerPrior_energy_tail (ν : CoordinateLaw) {d N r T : ℕ}
    (hd : 0<d) (hN : 0<N) (hNT : N≤T) (γ b : ℝ) (hγ : 1≤γ)
    (hb : 8*subGaussianVariance ν*((d : ℝ)+2+(r : ℝ)*T)≤b) :
    (powerPrior ν d N r γ).real {w | b<weightedSquaredNorm w} ≤
      Real.exp (-(b/(8*subGaussianVariance ν))*(N : ℝ)^γ) := by
  have hv := subGaussianVariance_pos ν
  have hscale : (N : ℝ)*(N : ℝ)^(-γ)≤1 := by
    simpa only [powerStandardDeviation_sq hN] using
      width_mul_powerStandardDeviation_sq_le_one hN hγ
  have hdim : (Fintype.card (WeightIndex d N r) : ℝ)=
      (N : ℝ)*((d : ℝ)+2+(r : ℝ)*N) := by
    simp [WeightIndex]
    ring
  have hNreal : (N : ℝ)≤T := by exact_mod_cast hNT
  have hsize : 8*(Fintype.card (WeightIndex d N r) : ℝ)*
      ((N : ℝ)^(-γ)*subGaussianVariance ν)≤b := by
    rw [hdim]
    have hh := mul_le_mul_of_nonneg_left hscale
      (show 0≤8*subGaussianVariance ν*((d : ℝ)+2+(r : ℝ)*N) by positivity)
    have ht := mul_le_mul_of_nonneg_left hNreal (Nat.cast_nonneg r (α := ℝ))
    have ht' := mul_le_mul_of_nonneg_left ht (show 0≤8*subGaussianVariance ν by positivity)
    nlinarith
  have ht := powerPrior_whiten_subfamily_tail ν hd hN γ
    (id : WeightIndex d N r → WeightIndex d N r) Function.injective_id b hsize
  have he (w : Weights d N r) : weightedSquaredNorm w=∑ i,(whiten w i)^2 := by
    rw [←weightedSquaredNorm_unwhiten hd hN,unwhiten_whiten hd hN]
  have hsub : {w : Weights d N r | b<weightedSquaredNorm w} ⊆
      {w | b≤∑ i,(whiten w (id i))^2} := by
    intro w hw
    change b<weightedSquaredNorm w at hw
    change b≤∑ i,(whiten w (id i))^2
    simpa only [id_eq,←he] using hw.le
  apply (measureReal_mono hsub).trans ht |>.trans_eq
  congr 1
  rw [Real.rpow_neg (Nat.cast_nonneg N)]
  field_simp

end NeuralGeneralization.BatchTwoContinuous.Above
