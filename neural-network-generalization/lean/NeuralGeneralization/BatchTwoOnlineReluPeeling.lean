import NeuralGeneralization.BatchTwoActivationSharpAuxiliary

/-! Exact factor-two ReLU peeling over arbitrary architecture families. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoActivation
open SquaredSampling

variable {U : Type*} [Nonempty U]
variable {J : U→Type*} [∀p,Fintype (J p)] [∀p,Nonempty (J p)]
variable {E : U→Type*} [∀p,NormedAddCommGroup (E p)] [∀p,InnerProductSpace ℝ (E p)]

def reluUnitActivation : UnitActivation := ⟨relu, relu_zeroLipschitz⟩

theorem dependentReluRowLayer_exp_peeling {n : ℕ}
    (r : ∀p,J p→ℝ) (u : ∀p,J p→E p) (h : ∀p,Fin n→E p)
    (hr : ∀p,(∑j,r p j^2)≤1) (hu : ∀p j,‖u p j‖≤1)
    {R : ℝ} (hh : ∀p i,‖h p i‖≤R) (a : ℝ) (ha : 0≤a) :
    finiteMean (fun ε : Fin n→Bool => Real.exp (a*dependentVectorProcess
      (dependentHeterogeneousRowLayer (fun _ _ => reluUnitActivation) r u h) ε))≤
    2*finiteMean (fun ε : Fin n→Bool => Real.exp (a*dependentVectorProcess h ε)) := by
  letI : Nonempty (Σp,J p) := ⟨⟨Classical.choice inferInstance,Classical.choice inferInstance⟩⟩
  have hscalar (p : U) (j : J p) (i : Fin n) : |relu ⟪u p j,h p i⟫|≤R := by
    have hp := activation_abs_le relu_zeroLipschitz ⟪u p j,h p i⟫
    simp only [one_mul] at hp
    exact hp.trans (linearRow_abs_le _ (hu _ _) _ (hh _ _))
  have hfirst := finiteMean_mono (fun ε : Fin n→Bool => Real.exp_le_exp.mpr
    (mul_le_mul_of_nonneg_left
      (dependentWeightedArrayLayer_process_le r (fun p j i => relu ⟪u p j,h p i⟫) hr hscalar ε) ha))
  have hcontract := bounded_rademacher_exp_contraction n (fun _ => relu)
    (fun _ => relu_zeroLipschitz.1)
    (fun _ x y => by simpa only [one_mul] using relu_zeroLipschitz.2 x y)
    (fun pj : (Σp,J p) => fun i=>⟪u pj.1 pj.2,h pj.1 i⟫)
    (fun pj i => linearRow_abs_le _ (hu _ _) _ (hh _ _)) a ha
  have hlast := finiteMean_mono (fun ε : Fin n→Bool => Real.exp_le_exp.mpr
    (mul_le_mul_of_nonneg_left (dependentLinearRow_process_le u h hu hh ε) ha))
  exact hfirst.trans (hcontract.trans (mul_le_mul_of_nonneg_left hlast (by norm_num)))

def IsReluAuxiliary {d H : ℕ} (W : AuxiliaryNetwork d H) : Prop :=
  ∀ s j, (W.activation s j).val=relu

/-- The architecture, including all intermediate widths, may vary with p. -/
theorem relu_auxiliaryFamilyState_mgf {d H n : ℕ}
    (W : U→AuxiliaryNetwork d H) (hW : ∀p,IsReluAuxiliary (W p))
    (x : Fin n→ConcreteModel.Cube d) {R : ℝ} (hR : 0≤R)
    (hx : ∀i,‖concreteInput (x i)‖≤R) (a : ℝ) (ha : 0≤a) (s : ℕ) :
    finiteMean (fun ε : Fin n→Bool => Real.exp (a*dependentVectorProcess
      (auxiliaryFamilyState W x s) ε))≤
    Real.exp ((s:ℝ)*Real.log 2+a*R*Real.sqrt n+a^2*(n:ℝ)*R^2/2) := by
  induction s with
  | zero =>
    have he (ε : Fin n→Bool) : dependentVectorProcess (auxiliaryFamilyState W x 0) ε=
        ‖∑i,cubeCoordinateSign (ε i)•concreteInput (x i)‖ := by
      simp only [auxiliaryFamilyState, matrixFamilyState, dependentVectorProcess,
        processSup]
      change sSup (Set.range (fun _ : U => ‖∑i,cubeCoordinateSign (ε i)•concreteInput (x i)‖)) = _
      rw [Set.range_const, csSup_singleton]
    simp_rw [he]
    simpa only [Nat.cast_zero,zero_mul,zero_add] using
      sharp_input_vector_sign_mgf n (fun i=>concreteInput (x i)) hR hx ha
  | succ s ih =>
    letI : ∀p,Nonempty (Fin (auxiliaryWidth d (W p).width (s+1))) :=
      fun p=>⟨⟨0,(W p).width_pos s⟩⟩
    have hprev := auxiliaryFamilyState_sharp_norm_le W x hx s
    have hstep := dependentReluRowLayer_exp_peeling
      (fun p j=>‖(W p).rows s j‖) (fun p j=>unitDirection ((W p).rows s j))
      (auxiliaryFamilyState W x s) (fun p=>(W p).row_energy s)
      (fun p j=>norm_unitDirection_le _) hprev a ha
    have he : auxiliaryFamilyState W x (s+1)=
        dependentHeterogeneousRowLayer (fun _ _=>reluUnitActivation)
          (fun p j=>‖(W p).rows s j‖) (fun p j=>unitDirection ((W p).rows s j))
          (auxiliaryFamilyState W x s) := by
      funext p i
      apply PiLp.ext
      intro j
      change ((W p).activation s j).val ⟪(W p).rows s j,auxiliaryFamilyState W x s p i⟫=_
      rw [hW p s j, relu_inner_normalized]
      rfl
    rw [←he] at hstep
    apply (hstep.trans (mul_le_mul_of_nonneg_left ih (by norm_num))).trans_eq
    nth_rw 1 [show (2:ℝ)=Real.exp (Real.log 2) from (Real.exp_log (by norm_num)).symm]
    rw [←Real.exp_add]
    congr 1
    push_cast
    ring

end NeuralGeneralization.BatchTwoActivation
