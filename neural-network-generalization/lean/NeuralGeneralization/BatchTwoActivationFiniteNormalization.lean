import NeuralGeneralization.BatchTwoActivationAuxiliaryCapacity

/-! Exact normalization of finite reconstructed networks with heterogeneous
Lipschitz activations. No homogeneity of any activation is assumed. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel

structure RawAuxiliaryNetwork (d H : ℕ) (ℓ K : ℝ) where
  width : ℕ → ℕ
  width_pos : ∀s,0<width s
  activation : ∀s,Fin (auxiliaryWidth d width (s+1)) → ℝ → ℝ
  activation_class : ∀s j,zeroLipschitzActivation ℓ (activation s j)
  rows : ∀s,Fin (auxiliaryWidth d width (s+1)) → EuclideanSpace ℝ (Fin (auxiliaryWidth d width s))
  row_energy : ∀s,(∑j,‖rows s j‖^2)≤K^2
  readout : EuclideanSpace ℝ (Fin (auxiliaryWidth d width H))
  readout_norm : ‖readout‖≤K

def rawAuxiliaryState {d H : ℕ} {ℓ K : ℝ} (W : RawAuxiliaryNetwork d H ℓ K)
    (x : Cube d) : ∀s,EuclideanSpace ℝ (Fin (auxiliaryWidth d W.width s))
  | 0 => concreteInput x
  | s+1 => WithLp.toLp 2 (fun j => W.activation s j ⟪W.rows s j,rawAuxiliaryState W x s⟫)

def rawAuxiliaryOutput {d H : ℕ} {ℓ K : ℝ} (W : RawAuxiliaryNetwork d H ℓ K)
    (x : Cube d) : ℝ := ⟪W.readout,rawAuxiliaryState W x H⟫

def normalizeRawAuxiliary {d H : ℕ} {ℓ K : ℝ} (W : RawAuxiliaryNetwork d H ℓ K)
    (hℓ : 0<ℓ) (hK : 0<K) : AuxiliaryNetwork d H where
  width := W.width
  width_pos := W.width_pos
  activation := fun s j => normalizedUnitActivation (W.activation_class s j) hℓ
    (show 0≤K*(ℓ*K)^s by positivity)
  rows := fun s j => K⁻¹ • W.rows s j
  row_energy := by
    intro s
    simp only [norm_smul,Real.norm_eq_abs,abs_inv,abs_of_pos hK,mul_pow,←Finset.mul_sum]
    have hh := mul_le_mul_of_nonneg_left (W.row_energy s) (sq_nonneg K⁻¹)
    have he : K⁻¹^2*K^2=(1:ℝ) := by field_simp
    exact hh.trans_eq he
  readout := K⁻¹ • W.readout
  readout_norm := by
    rw [norm_smul,Real.norm_eq_abs,abs_inv,abs_of_pos hK]
    have hh := mul_le_mul_of_nonneg_left W.readout_norm (inv_nonneg.mpr hK.le)
    simpa only [inv_mul_cancel₀ hK.ne'] using hh

theorem normalizeRawAuxiliary_state {d H : ℕ} {ℓ K : ℝ}
    (W : RawAuxiliaryNetwork d H ℓ K) (hℓ : 0<ℓ) (hK : 0<K) (x : Cube d) (s : ℕ) :
    rawAuxiliaryState W x s=(ℓ*K)^s •
      auxiliaryFamilyState (fun _ : Unit => normalizeRawAuxiliary W hℓ hK)
        (fun _ : Fin 1 => x) s () 0 := by
  induction s with
  | zero => simp only [pow_zero,one_smul]; rfl
  | succ s ih =>
    apply PiLp.ext
    intro j
    change W.activation s j ⟪W.rows s j,rawAuxiliaryState W x s⟫ =
      (ℓ*K)^(s+1)*
        normalizedScalar (W.activation s j) ℓ (K*(ℓ*K)^s)
          ⟪K⁻¹ • W.rows s j,auxiliaryFamilyState
            (fun _ : Unit => normalizeRawAuxiliary W hℓ hK) (fun _ : Fin 1 => x) s () 0⟫
    rw [ih,real_inner_smul_right,real_inner_smul_left]
    have he (v : ℝ) : (ℓ*K)^s*v=(K*(ℓ*K)^s)*(K⁻¹*v) := by field_simp <;> ring
    rw [he,normalizedScalar_reconstruct (W.activation_class s j) hℓ (by positivity)]
    rw [pow_succ]
    ring

theorem normalizeRawAuxiliary_output {d H : ℕ} {ℓ K : ℝ}
    (W : RawAuxiliaryNetwork d H ℓ K) (hℓ : 0<ℓ) (hK : 0<K) (x : Cube d) :
    rawAuxiliaryOutput W x =
      auxiliaryOutput (normalizeRawAuxiliary W hℓ hK) (K*(ℓ*K)^H) x := by
  unfold rawAuxiliaryOutput auxiliaryOutput
  rw [normalizeRawAuxiliary_state W hℓ hK x H]
  change ⟪W.readout,(ℓ*K)^H • _⟫=K*(ℓ*K)^H*⟪K⁻¹ • W.readout,_⟫
  rw [real_inner_smul_right,real_inner_smul_left]
  field_simp

theorem rawAuxiliary_margin_function_mem {d H : ℕ} {ℓ K : ℝ}
    (W : RawAuxiliaryNetwork d H ℓ K) (hℓ : 0<ℓ) (hK : 0<K)
    (f : BooleanFunction d) (hf : ∀x,(1/2:ℝ)≤labelReal (f x)*rawAuxiliaryOutput W x) :
    f∈auxiliaryFunctions d H (K*(ℓ*K)^H) := by
  classical
  apply Finset.mem_filter.mpr
  refine ⟨Finset.mem_univ _,normalizeRawAuxiliary W hℓ hK,?_⟩
  intro x
  rw [←normalizeRawAuxiliary_output]
  exact hf x

end NeuralGeneralization.BatchTwoActivation
