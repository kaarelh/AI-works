import NeuralGeneralization.BatchTwoNonGaussianTargetMass
import NeuralGeneralization.PowerPriorScaling

/-! Exact conversion of the original non-Gaussian layerwise exponents to the
common small-prior scale, including the mean-field endpoint. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.BatchTwoNonGaussian
open ConcreteModel

theorem powerScale_pos {d N r : ℕ} (hd : 0 < d) (hN : 0 < N) (γ : ℝ)
    (i : WeightIndex d N r) : 0 < powerScale d N r γ i := by
  have hNR : (0 : ℝ) < N := Nat.cast_pos.mpr hN
  rcases i with ij | (sij | j)
  · exact div_pos (Real.rpow_pos_of_pos hNR _) (Real.sqrt_pos.mpr (Nat.cast_pos.mpr hd))
  · exact Real.rpow_pos_of_pos hNR _
  · exact Real.rpow_pos_of_pos hNR _

theorem powerScale_sq {d N r : ℕ} (hd : 0 < d) (hN : 0 < N) (γ : ℝ)
    (i : WeightIndex d N r) : (powerScale d N r γ i)^2=powerVariance d N r γ i := by
  have hNR : (0 : ℝ) ≤ N := Nat.cast_nonneg N
  have hrpow (a : ℝ) : ((N : ℝ)^(a/2))^2=(N : ℝ)^a := by
    rw [←Real.rpow_mul_natCast hNR]
    congr 1
    ring
  rcases i with ij | (sij | j)
  · simp only [powerScale,powerVariance,div_pow,Real.sq_sqrt (Nat.cast_nonneg d),hrpow]
  · exact hrpow (-γ)
  · change ((N : ℝ)^(-(γ+1)/2))^2=(N : ℝ)^(-γ-1)
    rw [hrpow]
    congr 1
    ring

theorem powerScale_eq_smallScale {d N r : ℕ} (hd : 0 < d) (hN : 0 < N) (γ : ℝ) :
    powerScale d N r γ=smallScale d N r (powerStandardDeviation N γ) := by
  funext i
  have hpow := powerScale_sq hd hN γ i
  have hsmall := smallScale_sq (r := r) hd hN (powerStandardDeviation N γ) i
  change _ = smallVariance d N r (Real.sqrt ((N : ℝ)^(-γ))) i at hsmall
  rw [←powerVariance_eq_smallVariance hN γ] at hsmall
  nlinarith [powerScale_pos (r := r) hd hN γ i,
    smallScale_pos (r := r) hd hN (powerStandardDeviation_pos hN γ) i]

theorem powerPrior_eq_smallPrior_standardDeviation (ν : CoordinateLaw) {d N r : ℕ}
    (hd : 0 < d) (hN : 0 < N) (γ : ℝ) :
    powerPrior ν d N r γ=smallPrior ν d N r (powerStandardDeviation N γ) := by
  unfold powerPrior smallPrior
  rw [powerScale_eq_smallScale hd hN γ]

theorem powerPrior_target_mass_all_width (ν : CoordinateLaw) {d C N r : ℕ}
    (hd : 0 < d) (f : BooleanFunction d)
    (hf : realizesAtComplexity (r := r) Real.tanh f C) (hCN : C ≤ N)
    {γ : ℝ} (hγ : 1 ≤ γ) :
    Real.exp (-(targetMassCost ν d C r*(N : ℝ)^γ)) ≤
      functionMass Real.tanh (1/2) (powerPrior ν d N r γ) f := by
  have hN : 0 < N := (Nat.succ_le_iff.mp hf.1).trans_le hCN
  rw [powerPrior_eq_smallPrior_standardDeviation ν hd hN γ]
  have h := smallPrior_target_mass_all_width ν hd f hf hCN (powerStandardDeviation_pos hN γ)
    (width_mul_powerStandardDeviation_sq_le_one hN hγ)
  have he : -targetMassCost ν d C r/powerStandardDeviation N γ^2=
      -(targetMassCost ν d C r*(N : ℝ)^γ) := by
    rw [←powerStandardDeviation_inv_sq hN γ]
    ring
  rwa [he] at h

end NeuralGeneralization.BatchTwoNonGaussian
