import NeuralGeneralization.BatchTwoOnlineReluBalancedCoordinates
import NeuralGeneralization.BatchTwoOnlineReluPerturbation

/-! An actual all-width energy-coordinate center at the manuscript's K_R. -/
noncomputable section
set_option autoImplicit false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineReluFinite
open ConcreteModel BatchTwoActivation BatchTwoContinuousDepthPaper CompressionSampling
set_option maxHeartbeats 1600000
set_option backward.isDefEq.respectTransparency false

def reluTeacherEnergy (d r : ℕ) (P : ℝ) : ℝ :=
  (r+2:ℝ)*(4*(d:ℝ)*P^2)^((r+2:ℝ)⁻¹)

theorem reluTeacherEnergy_pos {d r : ℕ} (hd : 0<d) {P : ℝ} (hP : 0<P) :
    0<reluTeacherEnergy d r P := by
  unfold reluTeacherEnergy
  exact mul_pos (by positivity) (Real.rpow_pos_of_pos (by positivity) _)

theorem margin_teacher_nonzero {d C r : ℕ} (w : Weights d C r) (f : BooleanFunction d)
    (hw : w∈marginEvent relu (1/2) f) : ∃x,networkOutput relu w x≠0 := by
  refine ⟨fun _=>false,?_⟩
  intro hz
  have hh := hw (fun _=>false)
  rw [hz,mul_zero] at hh
  norm_num at hh

theorem exists_relu_teacher_center {d C N r : ℕ} (hd : 0<d) (hC : 0<C) (hCN : C≤N)
    (w : Weights d C r) (f : BooleanFunction d) (hw : w∈marginEvent relu (1/2) f) :
    ∃u : Weights d N r,
      (∑q,(u q)^2)=reluTeacherEnergy d r (physicalProduct hC relu_zeroLipschitz w) ∧
      (∀i,normalizedLayerNorm u i=Real.sqrt
        (reluTeacherEnergy d r (physicalProduct hC relu_zeroLipschitz w)/(r+2:ℝ))) ∧
      ∀x,(1:ℝ)<labelReal (f x)*networkOutput relu (unwhiten u) x := by
  have hN : 0<N := hC.trans_le hCN
  let w' : Weights d N r := rescaleReadout 2 (widthPaddedWeights hCN w)
  have hout (x : Cube d) : networkOutput relu w' x=2*networkOutput relu w x := by
    rw [rescaleReadout_output,networkOutput_widthPaddedWeights]
  have hne : ∃x,networkOutput relu w' x≠0 := by
    obtain ⟨x,hx⟩ := margin_teacher_nonzero w f hw
    exact ⟨x,by rw [hout]; exact mul_ne_zero (by norm_num) hx⟩
  have hP : physicalProduct hN relu_zeroLipschitz w'=2*physicalProduct hC relu_zeroLipschitz w := by
    rw [physicalProduct_rescaleReadout hN (by norm_num),physicalProduct_widthPadded]
  obtain ⟨v,hv,he⟩ := exists_balanced_relu_layers hd hN w' hne
  let K := reluTeacherEnergy d r (physicalProduct hC relu_zeroLipschitz w)
  have hK : 0<K := reluTeacherEnergy_pos hd (physical_relu_product_pos hC w (margin_teacher_nonzero w f hw))
  have he' (i : Fin r⊕Bool) : weightedLayerEnergy v i=K/(r+2:ℝ) := by
    rw [he,hP]
    dsimp [K,reluTeacherEnergy]
    have ha : (d:ℝ)*(2*physicalProduct hC relu_zeroLipschitz w)^2=
        4*(d:ℝ)*(physicalProduct hC relu_zeroLipschitz w)^2 := by ring
    rw [ha]
    field_simp
  refine ⟨whiten v,?_,?_,?_⟩
  · rw [←weightedSquaredNorm_unwhiten hd hN,unwhiten_whiten hd hN,←weightedLayerEnergy_sum]
    simp_rw [he']
    simp only [Finset.sum_const,Finset.card_univ,Fintype.card_sum,Fintype.card_fin,Fintype.card_bool,
      nsmul_eq_mul,Nat.cast_add,Nat.cast_ofNat]
    change (r+2:ℝ)*(K/(r+2:ℝ))=K
    field_simp
  · intro i
    exact balanced_whitened_layers hd hN v (by positivity) he' i
  · intro x
    rw [unwhiten_whiten hd hN,hv,hout]
    have hh := hw x
    change (1/2:ℝ)<labelReal (f x)*networkOutput relu w x at hh
    nlinarith

end NeuralGeneralization.BatchTwoOnlineReluFinite
