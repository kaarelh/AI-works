import NeuralGeneralization.HiddenOnlyComparison
import NeuralGeneralization.RobustSpectralCertificate

/-! The hidden-only gain has no scalar-injection term. Nonexpansive internal
layers therefore give exactly sqrt(H E_v), and the calibrated raw variation
is at most c. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.HiddenOnly
open ConcreteModel BatchTwoNeuralConverse RobustCertificates
variable {d N r : ℕ}

theorem hidden_noise_sq (hN : 0 < N) (w : Weights d N r) (x : Cube d)
    (η : NetworkDisturbance N r) (hzero : η.2=0) :
    (noisyNetworkOutput Real.tanh w x η-networkOutput Real.tanh w x)^2 ≤
      gainSq w*noiseBudgetSq η := by
  let a : Fin (r+1) × Fin N → ℝ := fun p =>
    pathRow w (realizedSlopes w x η) ((List.finRange r).drop p.1.val) p.2
  let b : Fin (r+1) × Fin N → ℝ := fun p => η.1 p.1 p.2
  have hc := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ a b
  have hg := gainEnergy_le_gainSq w (realizedSlopes w x η) (realizedSlopes_mem w x η)
  change (N:ℝ)*(∑ j : Fin (r+1),∑ i,(a (j,i))^2) ≤ gainSq w at hg
  have hg' : (N:ℝ)*(∑ p,(a p)^2) ≤ gainSq w := by
    simpa only [Fintype.sum_prod_type] using hg
  have hm := mul_le_mul_of_nonneg_right hg' (show 0 ≤ (∑ p,(b p)^2)/(N:ℝ) by positivity)
  have he : ((N:ℝ)*(∑ p,(a p)^2))*((∑ p,(b p)^2)/(N:ℝ)) =
      (∑ p,(a p)^2)*(∑ p,(b p)^2) := by
    have hNR : (N:ℝ) ≠ 0 := by positivity
    field_simp
  rw [he] at hm
  have hh := hc.trans hm
  simp only [Fintype.sum_prod_type,a,b] at hh
  rw [noisy_difference_expansion,hzero,add_zero]
  simpa only [noiseBudgetSq,hzero,zero_pow (by decide : 2 ≠ 0),add_zero] using hh

theorem contractive_gain (w : Weights d N r) (hW : ∀ s,internalNorm w s ≤ 1) :
    gainSq w ≤ ((r:ℝ)+1)*readoutEnergy w := by
  have hh := gainSq_suffix_bound w (fun _ => 1) (fun s =>
    matrixActionBound_of_operatorNorm _ 1 (by norm_num) (hW s))
  simpa [suffixSquareSum,suffixProduct,mul_comm] using hh

/-- The square of the exact hidden-only gain sqrt(H E_v). -/
theorem contractive_hidden_noise_sq (hN : 0 < N) (w : Weights d N r)
    (hW : ∀ s,internalNorm w s ≤ 1) (x : Cube d)
    (η : NetworkDisturbance N r) (hzero : η.2=0) :
    (noisyNetworkOutput Real.tanh w x η-networkOutput Real.tanh w x)^2 ≤
      (((r:ℝ)+1)*readoutEnergy w)*noiseBudgetSq η :=
  (hidden_noise_sq hN w x η hzero).trans
    (mul_le_mul_of_nonneg_right (contractive_gain w hW) (noiseBudgetSq_nonneg η))

/-- Exact calibrated raw variation, with the zero-readout case covered too. -/
theorem contractive_calibrated_noise (hN : 0 < N) (w : Weights d N r)
    (hW : ∀ s,internalNorm w s ≤ 1) {c : ℝ} (hc : 0 ≤ c) (x : Cube d)
    (η : NetworkDisturbance N r) (hzero : η.2=0)
    (hη : noiseBudgetSq η ≤ (radius c w)^2) :
    |noisyNetworkOutput Real.tanh w x η-networkOutput Real.tanh w x| ≤ c := by
  by_cases he : readoutEnergy w=0
  · simpa only [noisyNetworkOutput,networkOutput,readout_zero_of_energy hN w he,
      zero_mul,Finset.sum_const_zero,hzero,add_zero,sub_self,abs_zero] using hc
  · have hE : 0 < readoutEnergy w := lt_of_le_of_ne (readoutEnergy_nonneg w) (Ne.symm he)
    have hden : 0 < ((r:ℝ)+1)*readoutEnergy w := by positivity
    have hh := (contractive_hidden_noise_sq hN w hW x η hzero).trans
      (mul_le_mul_of_nonneg_left hη hden.le)
    have hcancel : (((r:ℝ)+1)*readoutEnergy w)*(radius c w)^2=c^2 := by
      rw [radius,div_pow,Real.sq_sqrt hden.le]
      field_simp
    rw [hcancel] at hh
    exact (sq_le_sq₀ (abs_nonneg _) hc).mp (by simpa only [sq_abs] using hh)

theorem contractive_support (hN : 0 < N) (w : Weights d N r)
    (hW : ∀ s,internalNorm w s ≤ 1) {c : ℝ} (hc : 0 ≤ c) (hc16 : c ≤ 1/16) :
    w ∈ support Real.tanh c := by
  intro x
  right
  intro η hη hzero
  exact (RobustStatistics.clippedScore_lipschitz _ _).trans
    ((contractive_calibrated_noise hN w hW hc x η hzero hη).trans hc16)

end NeuralGeneralization.HiddenOnly
