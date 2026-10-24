import NeuralGeneralization.BatchTwoContinuousPairMomentsTail
import NeuralGeneralization.BatchTwoContinuousPairMomentNumerics
import NeuralGeneralization.BatchTwoContinuousDepthSphere

/-! Actual finite-width Gaussian separation tails for the expanding teacher's
paired inputs. These avoid a finite-dimensional large-deviation premise. -/
noncomputable section
open MeasureTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthLower
open ConcreteModel BatchTwoContinuous BatchTwoContinuous.PairMoments

theorem paired_input_distance_sq (H : ℕ) (ω : SignStream) :
    inputDistanceSq (sphereCoding ω) (sphereCoding (flipCoordinate H ω)) ≤
      9*(1/9 : ℝ)^H := by
  have h := sphereCoding_pair_distance H ω
  have hh : inputDistance (sphereCoding ω) (sphereCoding (flipCoordinate H ω)) ≤
      3*(1/3 : ℝ)^H := h.trans (by gcongr <;> norm_num)
  have hs := pow_le_pow_left₀ (Real.sqrt_nonneg _) hh 2
  change (Real.sqrt (inputDistanceSq (sphereCoding ω) (sphereCoding (flipCoordinate H ω))))^2 ≤ _ at hs
  rw [Real.sq_sqrt (inputDistanceSq_nonneg _ _)] at hs
  have he : (3*(1/3 : ℝ)^H)^2 = 9*(1/9 : ℝ)^H := by
    rw [mul_pow,←pow_mul,pow_mul']
    norm_num
  rwa [he] at hs

theorem small_scale_pair_tail {N r : ℕ} (hN : 0 < N) (hr : 60 ≤ r+1)
    {σ : ℝ} (hσ : 0 < σ) (hscale : (N : ℝ)*σ^2 ≤ 1/16)
    (x y : RealInput 2) (hxy : inputDistanceSq x y ≤ 9*(1/9 : ℝ)^(r+1)) :
    (smallPrior 2 N r σ).real {w | (1/2 : ℝ) ≤ |output Real.tanh w x-output Real.tanh w y|} ≤
      Real.exp (-(11/10)*((r : ℝ)+1)/σ^2) := by
  have ht := output_pair_tail (r := r) (by norm_num) hN hσ (by norm_num : (0 : ℝ)<1/2)
    x y (pairMomentOrder (σ^2)) (pairMomentOrder_pos (sq_pos_of_pos hσ))
  have hc := pair_moment_coefficient_bound hN hr (sq_pos_of_pos hσ) hscale
    (inputDistanceSq_nonneg x y) hxy
  have he : outputPairMomentBase 2 N r (pairMomentOrder (σ^2)) σ x y/(1/2 : ℝ)^2 =
      2*inputDistanceSq x y*σ^2*(1+2*(pairMomentOrder (σ^2) : ℝ))*
        (σ^2*((N : ℝ)+2*(pairMomentOrder (σ^2) : ℝ)))^(r+1) := by
    unfold outputPairMomentBase
    norm_num
    ring
  rw [he] at ht
  exact ht.trans (by simpa only [Nat.cast_add,Nat.cast_one] using hc)

theorem small_scale_paired_input_tail {N r : ℕ} (hN : 0 < N) (hr : 60 ≤ r+1)
    {σ : ℝ} (hσ : 0 < σ) (hscale : (N : ℝ)*σ^2 ≤ 1/16) (ω : SignStream) :
    (smallPrior 2 N r σ).real {w | (1/2 : ℝ) ≤
      |output Real.tanh w (sphereCoding ω)-output Real.tanh w (sphereCoding (flipCoordinate (r+1) ω))|} ≤
      Real.exp (-(11/10)*((r : ℝ)+1)/σ^2) :=
  small_scale_pair_tail hN hr hσ hscale _ _ (paired_input_distance_sq (r+1) ω)

theorem meanfield_pair_coefficient_bound {N H : ℕ} (hN : 0 < N) (hH : 12 ≤ H)
    {v Dsq : ℝ} (hv : 0 < v) (hscale : (N : ℝ)*v=1)
    (hD : 0 ≤ Dsq) (hDsmall : Dsq ≤ 9*(1/9 : ℝ)^H) :
    (2*Dsq*v*(1+2*(N : ℝ))*(v*((N : ℝ)+2*N))^H)^N ≤
      Real.exp (-(H : ℝ)*(N : ℝ)/2) := by
  have hNR : (1 : ℝ)≤N := by exact_mod_cast hN
  have hv1 : v≤1 := by nlinarith only [hNR,hv,hscale]
  have hscalar : v*(1+2*(N : ℝ))≤3 := by nlinarith only [hv1,hscale]
  have hmatrix : v*((N : ℝ)+2*N)=3 := by nlinarith only [hscale]
  have hbase : 2*Dsq*v*(1+2*(N : ℝ))*(v*((N : ℝ)+2*N))^H ≤
      54*(1/3 : ℝ)^H := by
    calc
      _ = 2*Dsq*(v*(1+2*(N : ℝ)))*3^H := by rw [hmatrix]; ring
      _ ≤ 2*(9*(1/9 : ℝ)^H)*3*3^H := by gcongr
      _ = _ := by rw [show (1/3 : ℝ)^H=(1/9)^H*3^H by rw [←mul_pow]; norm_num]; ring
  have h54 : (54 : ℝ)≤Real.exp 6 := by
    have h := pow_le_pow_left₀ (by norm_num : (0 : ℝ)≤2) Real.exp_one_gt_two.le 6
    rw [←Real.exp_nat_mul] at h
    norm_num at h
    linarith only [h]
  have hthird : (1/3 : ℝ)≤Real.exp (-1) := by
    rw [Real.exp_neg]
    simpa only [one_div] using one_div_le_one_div_of_le (Real.exp_pos 1) Real.exp_one_lt_three.le
  have hexp : 54*(1/3 : ℝ)^H ≤ Real.exp (-(H : ℝ)/2) := by
    have hpow := pow_le_pow_left₀ (by norm_num : (0 : ℝ)≤1/3) hthird H
    rw [←Real.exp_nat_mul] at hpow
    calc
      _ ≤ Real.exp 6 * Real.exp ((H : ℝ)*(-1)) := by gcongr
      _ = Real.exp (6-(H : ℝ)) := by rw [←Real.exp_add]; congr 1; ring
      _ ≤ _ := Real.exp_le_exp.mpr (by
        have hHR : (12 : ℝ)≤H := by exact_mod_cast hH
        linarith only [hHR])
  have hnonneg : 0 ≤ 2*Dsq*v*(1+2*(N : ℝ))*(v*((N : ℝ)+2*N))^H := by positivity
  have h := pow_le_pow_left₀ hnonneg (hbase.trans hexp) N
  rw [←Real.exp_nat_mul] at h
  convert h using 1 <;> congr 1 <;> ring

theorem meanfield_paired_input_tail {N r : ℕ} (hN : 0 < N) (hr : 12 ≤ r+1)
    {σ : ℝ} (hσ : 0 < σ) (hscale : (N : ℝ)*σ^2=1) (ω : SignStream) :
    (smallPrior 2 N r σ).real {w | (1/2 : ℝ) ≤
      |output Real.tanh w (sphereCoding ω)-output Real.tanh w (sphereCoding (flipCoordinate (r+1) ω))|} ≤
      Real.exp (-((r : ℝ)+1)*(N : ℝ)/2) := by
  have ht := output_pair_tail (r := r) (by norm_num) hN hσ (by norm_num : (0 : ℝ)<1/2)
    (sphereCoding ω) (sphereCoding (flipCoordinate (r+1) ω)) N hN
  have hc := meanfield_pair_coefficient_bound hN hr (sq_pos_of_pos hσ) hscale
    (inputDistanceSq_nonneg _ _) (paired_input_distance_sq (r+1) ω)
  have he : outputPairMomentBase 2 N r N σ (sphereCoding ω)
      (sphereCoding (flipCoordinate (r+1) ω))/(1/2 : ℝ)^2 =
      2*inputDistanceSq (sphereCoding ω) (sphereCoding (flipCoordinate (r+1) ω))*σ^2*
        (1+2*(N : ℝ))*(σ^2*((N : ℝ)+2*N))^(r+1) := by
    unfold outputPairMomentBase
    norm_num
    ring
  rw [he] at ht
  exact ht.trans (by simpa only [Nat.cast_add,Nat.cast_one] using hc)

#print axioms small_scale_paired_input_tail
#print axioms meanfield_paired_input_tail
end NeuralGeneralization.BatchTwoContinuousDepthLower
