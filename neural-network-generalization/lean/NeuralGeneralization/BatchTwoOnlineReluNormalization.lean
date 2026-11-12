import NeuralGeneralization.BatchTwoOnlineReluPeeling
import NeuralGeneralization.BatchTwoActivationProductNormalizationMain

/-! Actual ReLU networks normalize without changing the activation. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel

def normalizeReluProduct (W : ProductNetwork d H 1) : AuxiliaryNetwork d H where
  width := W.width
  width_pos := W.width_pos
  activation := fun _ _=>reluUnitActivation
  rows := fun s j=>(layerFrobenius W s)⁻¹ • W.rows s j
  row_energy := normalizedRows_energy W
  readout := unitDirection W.readout
  readout_norm := norm_unitDirection_le _

theorem normalizeReluProduct_isRelu (W : ProductNetwork d H 1) :
    IsReluAuxiliary (normalizeReluProduct W) := fun _ _=>rfl

theorem normalizeReluProduct_state (W : ProductNetwork d H 1)
    (hW : ∀s j,W.activation s j=relu) (x : Cube d) (s : ℕ) :
    productNetworkState W x s=productStateScale W s •
      auxiliaryFamilyState (fun _:Unit=>normalizeReluProduct W) (fun _:Fin 1=>x) s () 0 := by
  induction s with
  | zero=>simp only [productStateScale,one_smul];rfl
  | succ s ih=>
    apply PiLp.ext
    intro j
    change W.activation s j ⟪W.rows s j,productNetworkState W x s⟫=
      (1*layerFrobenius W s*productStateScale W s)*
      relu ⟪(layerFrobenius W s)⁻¹ • W.rows s j,
        auxiliaryFamilyState (fun _:Unit=>normalizeReluProduct W) (fun _:Fin 1=>x) s () 0⟫
    rw [hW s j,ih]
    nth_rw 1 [←normalizedRows_reconstruct W s j]
    rw [real_inner_smul_left,real_inner_smul_right,←mul_assoc,
      relu_mul_nonneg (mul_nonneg (layerFrobenius_nonneg W s)
        (productStateScale_nonneg W (by norm_num) s))]
    simp only [one_mul]

theorem normalizeReluProduct_output (W : ProductNetwork d H 1)
    (hW : ∀s j,W.activation s j=relu) (x : Cube d) :
    productNetworkOutput W x=auxiliaryOutput (normalizeReluProduct W)
      (‖W.readout‖*∏j∈Finset.range H,layerFrobenius W j) x := by
  unfold productNetworkOutput auxiliaryOutput
  rw [normalizeReluProduct_state W hW x H,productStateScale_eq,real_inner_smul_right]
  simp only [one_pow,one_mul]
  nth_rw 1 [←norm_smul_unitDirection W.readout]
  rw [real_inner_smul_left]
  change _ = (‖W.readout‖*∏j∈Finset.range H,layerFrobenius W j)*
    ⟪unitDirection W.readout,_⟫
  ring

theorem physical_relu_normalization {d N r : ℕ} (hN : 0<N) (w : Weights d N r) :
    ∃W : AuxiliaryNetwork d (r+1),IsReluAuxiliary W ∧
      ∀x,networkOutput relu w x=auxiliaryOutput W (physicalProduct hN relu_zeroLipschitz w) x := by
  refine ⟨normalizeReluProduct (physicalProductNetwork hN relu_zeroLipschitz w),
    normalizeReluProduct_isRelu _,?_⟩
  intro x
  rw [←physicalProductNetwork_output hN relu_zeroLipschitz w x]
  exact normalizeReluProduct_output _ (fun _ _=>rfl) x

/-- Raising the allowed product scale changes only the unit readout. -/
theorem physical_relu_normalization_bound {d N r : ℕ} (hN : 0<N) (w : Weights d N r)
    {P : ℝ} (hP : 0<P) (hw : physicalProduct hN relu_zeroLipschitz w≤P) :
    ∃W : AuxiliaryNetwork d (r+1),IsReluAuxiliary W ∧
      ∀x,networkOutput relu w x=auxiliaryOutput W P x := by
  obtain ⟨V,hVrelu,hV⟩ := physical_relu_normalization hN w
  let p := physicalProduct hN relu_zeroLipschitz w
  have hp : 0≤p := physicalProduct_nonneg hN relu_zeroLipschitz w
  have ha : 0≤p/P := div_nonneg hp hP.le
  have ha1 : p/P≤1 := (div_le_one hP).mpr hw
  refine ⟨V.scaleReadout ha ha1,hVrelu,?_⟩
  intro x
  rw [hV x]
  unfold auxiliaryOutput
  rw [auxiliary_scaleReadout_state V ha ha1]
  change p*⟪V.readout,_⟫=P*⟪(p/P) • V.readout,_⟫
  rw [real_inner_smul_left]
  field_simp

end NeuralGeneralization.BatchTwoActivation
