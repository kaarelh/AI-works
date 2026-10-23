import NeuralGeneralization.BatchTwoActivationFiniteNormalization
import Mathlib.Analysis.MeanInequalities

/-! Exact product-of-layer-Frobenius normalization, including zero matrices.
Auxiliary activations absorb the layer scales; no positive homogeneity is used. -/
noncomputable section
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel

structure ProductNetwork (d H : ℕ) (ℓ : ℝ) where
  width : ℕ→ℕ
  width_pos : ∀s,0<width s
  activation : ∀s,Fin (auxiliaryWidth d width (s+1))→ℝ→ℝ
  activation_class : ∀s j,zeroLipschitzActivation ℓ (activation s j)
  rows : ∀s,Fin (auxiliaryWidth d width (s+1))→EuclideanSpace ℝ (Fin (auxiliaryWidth d width s))
  readout : EuclideanSpace ℝ (Fin (auxiliaryWidth d width H))

def productNetworkState {d H : ℕ} {ℓ : ℝ} (W:ProductNetwork d H ℓ)
    (x:Cube d) : ∀s,EuclideanSpace ℝ (Fin (auxiliaryWidth d W.width s))
  | 0=>concreteInput x
  | s+1=>WithLp.toLp 2 (fun j=>W.activation s j ⟪W.rows s j,productNetworkState W x s⟫)

def productNetworkOutput {d H : ℕ} {ℓ : ℝ} (W:ProductNetwork d H ℓ) (x:Cube d):ℝ:=
  ⟪W.readout,productNetworkState W x H⟫

def layerFrobenius {d H : ℕ} {ℓ : ℝ} (W:ProductNetwork d H ℓ) (s:ℕ):ℝ:=
  Real.sqrt (∑j,‖W.rows s j‖^2)

def productStateScale {d H : ℕ} {ℓ : ℝ} (W:ProductNetwork d H ℓ):ℕ→ℝ
  | 0=>1
  | s+1=>ℓ*layerFrobenius W s*productStateScale W s

theorem layerFrobenius_nonneg {d H : ℕ} {ℓ : ℝ} (W:ProductNetwork d H ℓ) (s:ℕ):
    0≤layerFrobenius W s:=Real.sqrt_nonneg _

theorem layerFrobenius_sq {d H : ℕ} {ℓ : ℝ} (W:ProductNetwork d H ℓ) (s:ℕ):
    (layerFrobenius W s)^2=∑j,‖W.rows s j‖^2:=Real.sq_sqrt (by positivity)

theorem row_norm_le_layerFrobenius {d H : ℕ} {ℓ : ℝ} (W:ProductNetwork d H ℓ)
    (s:ℕ) (j:Fin (auxiliaryWidth d W.width (s+1))):‖W.rows s j‖≤layerFrobenius W s:=by
  have hh:=Finset.single_le_sum (fun i (_:i∈Finset.univ)=>sq_nonneg ‖W.rows s i‖) (Finset.mem_univ j)
  rw [←layerFrobenius_sq] at hh
  nlinarith [norm_nonneg (W.rows s j),layerFrobenius_nonneg W s]

theorem normalizedRows_reconstruct {d H : ℕ} {ℓ : ℝ} (W:ProductNetwork d H ℓ)
    (s:ℕ) (j:Fin (auxiliaryWidth d W.width (s+1))):
    layerFrobenius W s • ((layerFrobenius W s)⁻¹ • W.rows s j)=W.rows s j:=by
  by_cases hz:layerFrobenius W s=0
  · have hw:W.rows s j=0:=norm_eq_zero.mp (le_antisymm (by simpa only [hz] using row_norm_le_layerFrobenius W s j) (norm_nonneg _))
    simp [hw]
  · rw [smul_smul,mul_inv_cancel₀ hz,one_smul]

theorem normalizedRows_energy {d H : ℕ} {ℓ : ℝ} (W:ProductNetwork d H ℓ) (s:ℕ):
    (∑j,‖(layerFrobenius W s)⁻¹ • W.rows s j‖^2)≤1:=by
  simp only [norm_smul,Real.norm_eq_abs,abs_inv,abs_of_nonneg (layerFrobenius_nonneg W s),mul_pow,←Finset.mul_sum]
  rw [←layerFrobenius_sq]
  by_cases hz:layerFrobenius W s=0
  · simp [hz]
  · rw [inv_pow,inv_mul_cancel₀ (pow_ne_zero _ hz)]

theorem productStateScale_nonneg {d H : ℕ} {ℓ : ℝ} (W:ProductNetwork d H ℓ)
    (hℓ:0≤ℓ) (s:ℕ):0≤productStateScale W s:=by
  induction s with
  | zero=>norm_num [productStateScale]
  | succ s ih=>exact mul_nonneg (mul_nonneg hℓ (layerFrobenius_nonneg W s)) ih

def normalizeProductNetwork {d H : ℕ} {ℓ : ℝ} (W:ProductNetwork d H ℓ)
    (hℓ:0<ℓ):AuxiliaryNetwork d H where
  width:=W.width
  width_pos:=W.width_pos
  activation:=fun s j=>normalizedUnitActivation (W.activation_class s j) hℓ
    (mul_nonneg (layerFrobenius_nonneg W s) (productStateScale_nonneg W hℓ.le s))
  rows:=fun s j=>(layerFrobenius W s)⁻¹ • W.rows s j
  row_energy:=normalizedRows_energy W
  readout:=unitDirection W.readout
  readout_norm:=norm_unitDirection_le _

theorem normalizeProductNetwork_state {d H : ℕ} {ℓ : ℝ}
    (W:ProductNetwork d H ℓ) (hℓ:0<ℓ) (x:Cube d) (s:ℕ):
    productNetworkState W x s=productStateScale W s •
      auxiliaryFamilyState (fun _:Unit=>normalizeProductNetwork W hℓ) (fun _:Fin 1=>x) s () 0:=by
  induction s with
  | zero=>simp only [productStateScale,one_smul];rfl
  | succ s ih=>
    apply PiLp.ext
    intro j
    change W.activation s j ⟪W.rows s j,productNetworkState W x s⟫=
      (ℓ*layerFrobenius W s*productStateScale W s)*
      normalizedScalar (W.activation s j) ℓ (layerFrobenius W s*productStateScale W s)
        ⟪(layerFrobenius W s)⁻¹ • W.rows s j,
          auxiliaryFamilyState (fun _:Unit=>normalizeProductNetwork W hℓ) (fun _:Fin 1=>x) s () 0⟫
    rw [ih,real_inner_smul_right]
    nth_rw 1 [←normalizedRows_reconstruct W s j]
    rw [real_inner_smul_left]
    rw [show productStateScale W s*(layerFrobenius W s*
      ⟪(layerFrobenius W s)⁻¹ • W.rows s j,
        auxiliaryFamilyState (fun _:Unit=>normalizeProductNetwork W hℓ) (fun _:Fin 1=>x) s () 0⟫)=
      (layerFrobenius W s*productStateScale W s)*
      ⟪(layerFrobenius W s)⁻¹ • W.rows s j,
        auxiliaryFamilyState (fun _:Unit=>normalizeProductNetwork W hℓ) (fun _:Fin 1=>x) s () 0⟫ by ring]
    rw [normalizedScalar_reconstruct (W.activation_class s j) hℓ
      (mul_nonneg (layerFrobenius_nonneg W s) (productStateScale_nonneg W hℓ.le s))]
    ring

theorem productStateScale_eq {d H : ℕ} {ℓ : ℝ} (W:ProductNetwork d H ℓ) (s:ℕ):
    productStateScale W s=ℓ^s*∏j∈Finset.range s,layerFrobenius W j:=by
  induction s with
  | zero=>simp [productStateScale]
  | succ s ih=>rw [productStateScale,ih,Finset.prod_range_succ,pow_succ];ring

theorem normalizeProductNetwork_output {d H : ℕ} {ℓ : ℝ}
    (W:ProductNetwork d H ℓ) (hℓ:0<ℓ) (x:Cube d):
    productNetworkOutput W x=auxiliaryOutput (normalizeProductNetwork W hℓ)
      (ℓ^H*‖W.readout‖*∏j∈Finset.range H,layerFrobenius W j) x:=by
  unfold productNetworkOutput auxiliaryOutput
  rw [normalizeProductNetwork_state W hℓ x H,productStateScale_eq,real_inner_smul_right]
  change (ℓ^H*∏j∈Finset.range H,layerFrobenius W j)*⟪W.readout,_⟫=_
  nth_rw 1 [←norm_smul_unitDirection W.readout]
  rw [real_inner_smul_left]
  change _ = (ℓ^H*‖W.readout‖*∏j∈Finset.range H,layerFrobenius W j)*
    ⟪unitDirection W.readout,_⟫
  ring

end NeuralGeneralization.BatchTwoActivation
