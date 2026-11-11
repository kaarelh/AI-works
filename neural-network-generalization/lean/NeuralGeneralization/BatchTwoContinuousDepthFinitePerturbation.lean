import NeuralGeneralization.BatchTwoContinuousDepthFiniteStability

/-! The manuscript's uniform perturbation bound and its Gaussian-body instance. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthPaper
open ConcreteModel BatchTwoContinuous
set_option maxHeartbeats 1600000
set_option backward.isDefEq.respectTransparency false

theorem normalized_perturbation_product_bound {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    (u v : Weights d N r) {η B : ℝ} (hη : 0 ≤ η) (hB : 0 < B)
    (hv : smallEnergyBlocks v η)
    (hbudget : ∑ i,(normalizedLayerNorm u i+η)^2 ≤ B)
    (x : RealInput d) (hx : ∑ i,x i^2 ≤ 1) :
    |normalizedOutput (u+v) x-normalizedOutput u x| ≤
      Real.sqrt 2*((r : ℝ)+2)*η*(B/((r : ℝ)+1))^(((r : ℝ)+1)/2) := by
  have hb (j : ℕ) (hj : j < r+2) : 0 ≤ layerNormAt u j+η := by
    have hh := normalizedLayerNorm_nonneg u (⟨j,hj⟩ : Fin (r+2))
    rw [← layerNormAt_fin] at hh
    exact add_nonneg hh hη
  have hsum : (∑ j ∈ Finset.range (r+2),(layerNormAt u j+η)^2) ≤ B := by
    rw [← Fin.sum_univ_eq_sum_range]
    simpa only [layerNormAt_fin] using hbudget
  have hu (j : ℕ) (hj : j < r+2) : normalizedNormTrace u x (j+1) ≤
      (layerNormAt u j+η)*normalizedNormTrace u x j :=
    (normalizedNormTrace_step hN u x j hj).trans (mul_le_mul_of_nonneg_right
      (le_add_of_nonneg_right hη) (normalizedNormTrace_nonneg u x j))
  have hh := numerical_chain_error (by omega : 2 ≤ r+2)
    (fun j => layerNormAt u j+η) (normalizedNormTrace u x) (normalizedErrorTrace (u+v) u x)
    (Real.sqrt_nonneg 2) hη hB hb (normalizedInput_norm hd x hx) le_rfl hu
    (normalizedErrorTrace_step hN u v hv x) hsum
  simpa only [normalizedErrorTrace,if_neg (by omega : ¬ r+1 ≤ r),Nat.cast_add,Nat.cast_ofNat,
    show (r : ℝ)+2-1=(r : ℝ)+1 by ring] using hh

theorem normalized_perturbation_estimate {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    (u v : Weights d N r) {η K : ℝ} (hη : 0 ≤ η) (hK : 0 ≤ K)
    (hv : smallEnergyBlocks v η) (henergy : ∑ q,u q^2 ≤ K+1)
    (x : RealInput d) (hx : ∑ i,x i^2 ≤ 1) :
    |normalizedOutput (u+v) x-normalizedOutput u x| ≤
      Real.sqrt 2*((r : ℝ)+2)*η*
        ((K+1+2*η*Real.sqrt (((r : ℝ)+2)*(K+1))+((r : ℝ)+2)*η^2)/((r : ℝ)+1))^(((r : ℝ)+1)/2) := by
  apply normalized_perturbation_product_bound hd hN u v hη (by positivity) hv _ x hx
  have hh := inflated_layer_square_sum (normalizedLayerNorm u) (normalizedLayerNorm_nonneg u)
    hK hη (by rw [normalizedLayerNorm_energy];exact henergy)
  simpa only [Nat.cast_add,Nat.cast_ofNat] using hh

/-- Uniform h-approximation at the exact manuscript radius. -/
theorem normalized_perturbation_at_radius {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    (u v : Weights d N r) {K h : ℝ} (hK : 0 ≤ K) (hh : 0 < h)
    (hv : smallEnergyBlocks v (approximationRadius (r+2) K h))
    (henergy : ∑ q,u q^2 ≤ K+1) (x : RealInput d) (hx : ∑ i,x i^2 ≤ 1) :
    |output Real.tanh (unwhiten (u+v)) x-output Real.tanh (unwhiten u) x| ≤ h := by
  have hη := approximationRadius_pos (by omega : 2 ≤ r+2) hK hh
  have hsum := inflated_layer_square_sum (normalizedLayerNorm u) (normalizedLayerNorm_nonneg u)
    hK hη.le (by rw [normalizedLayerNorm_energy];exact henergy)
  have hbudget : (∑ i,(normalizedLayerNorm u i+approximationRadius (r+2) K h)^2) ≤ K+2 :=
    hsum.trans (approximationRadius_energy (by omega : 2 ≤ r+2) hK hh).2.2
  have hb := normalized_perturbation_product_bound hd hN u v hη.le (by linarith : 0 < K+2)
    hv hbudget x hx
  rw [normalizedOutput_eq_output hd hN,normalizedOutput_eq_output hd hN] at hb
  apply hb.trans
  simpa only [approximationAmplification,Nat.cast_add,Nat.cast_ofNat,
    show (r : ℝ)+2-1=(r : ℝ)+1 by ring] using
      approximationRadius_output (by omega : 2 ≤ r+2) (K:=K) (h:=h) hK

theorem typicalBody_smallEnergyBlocks {d N r : ℕ} (u : EnergySpace d N r)
    (hu : u ∈ typicalBody d N r) {σ η : ℝ} (hσ : 0 ≤ σ)
    (hscale : σ*Real.sqrt N*noiseRadius d (r+2) ≤ η) :
    smallEnergyBlocks (fun q => σ*u q) η := by
  have hfirst : Real.sqrt (firstNoiseSquared d) ≤ noiseRadius d (r+2) :=
    Real.sqrt_le_sqrt (le_max_left _ _)
  have hinter : Real.sqrt (internalNoiseSquared (r+2)) ≤ noiseRadius d (r+2) :=
    Real.sqrt_le_sqrt (le_max_right _ _)
  have hbound : σ*boundaryNoiseRadius d N ≤ η := by
    unfold boundaryNoiseRadius
    calc
      _ = (σ*Real.sqrt N)*Real.sqrt (firstNoiseSquared d) := by ring
      _ ≤ σ*Real.sqrt N*noiseRadius d (r+2) := mul_le_mul_of_nonneg_left hfirst (by positivity)
      _ ≤ η := hscale
  have hibound : σ*internalNoiseRadius N (r+2) ≤ η := by
    unfold internalNoiseRadius
    calc
      _ = (σ*Real.sqrt N)*Real.sqrt (internalNoiseSquared (r+2)) := by ring
      _ ≤ σ*Real.sqrt N*noiseRadius d (r+2) := mul_le_mul_of_nonneg_left hinter (by positivity)
      _ ≤ η := hscale
  have hbody := (mem_typicalBody u).mp hu
  refine ⟨?_,?_,?_⟩
  · change ‖firstBlockProjection d N r (σ • u)‖ ≤ η
    rw [map_smul,norm_smul,Real.norm_eq_abs,abs_of_nonneg hσ]
    exact (mul_le_mul_of_nonneg_left hbody.1 hσ).trans hbound
  · intro s
    change ‖internalBlockProjection d N r s (σ • u)‖ ≤ η
    rw [map_smul,norm_smul,Real.norm_eq_abs,abs_of_nonneg hσ]
    exact (mul_le_mul_of_nonneg_left (hbody.2.2 s) hσ).trans hibound
  · change ‖readoutBlockProjection d N r (σ • u)‖ ≤ η
    rw [map_smul,norm_smul,Real.norm_eq_abs,abs_of_nonneg hσ]
    exact (mul_le_mul_of_nonneg_left hbody.2.1 hσ).trans hbound

theorem approximationWidth_noise_radius {d M L N : ℕ} {K h ζ β σ : ℝ}
    (hL : 2 ≤ L) (hK : 0 ≤ K) (hh : 0 < h) (hζ : 0 < ζ) (hσ : 0 ≤ σ)
    (hN : approximationWidth d M L K h ζ β ≤ N)
    (hscale : σ^2 ≤ (N : ℝ)^(-(1+ζ))) :
    σ*Real.sqrt N*noiseRadius d L ≤ approximationRadius L K h := by
  have hs := (approximationWidth_properties hL hK hh hζ hN hscale).2.2.2.1
  have hsq : (σ*Real.sqrt N*noiseRadius d L)^2=(N : ℝ)*σ^2*(noiseRadius d L)^2 := by
    rw [mul_pow,mul_pow,Real.sq_sqrt (Nat.cast_nonneg N)]
    ring
  have hη := approximationRadius_pos hL hK hh
  have hnon : 0 ≤ σ*Real.sqrt N*noiseRadius d L :=
    mul_nonneg (mul_nonneg hσ (Real.sqrt_nonneg _)) (noiseRadius_pos d L).le
  nlinarith

end NeuralGeneralization.BatchTwoContinuousDepthPaper
