import NeuralGeneralization.BatchTwoActivationSharpScalarCover
import NeuralGeneralization.BatchTwoActivationDepthIteration

/-! The manuscript's linear-entropy exponential row peeling, uniformly in
all layer widths and all neuronwise unit-Lipschitz activations. -/
noncomputable section
set_option maxHeartbeats 1200000
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoActivation
open SquaredSampling

variable {U : Type*} [Nonempty U]
variable {J : U→Type*} [∀p,Fintype (J p)] [∀p,Nonempty (J p)]
variable {E : U→Type*} [∀p,NormedAddCommGroup (E p)] [∀p,InnerProductSpace ℝ (E p)]

theorem dependentHeterogeneousRowLayer_sharp_exp_peeling {n : ℕ}
    (ψ : ∀p,J p→UnitActivation) (r : ∀p,J p→ℝ)
    (u : ∀p,J p→E p) (h : ∀p,Fin n→E p)
    (hr : ∀p,(∑j,r p j^2)≤1) (hu : ∀p j,‖u p j‖≤1)
    {R η : ℝ} (hR : 0<R) (hη : 0<η) (hηR : η≤R)
    (hh : ∀p i,‖h p i‖≤R) (a : ℝ) (ha : 0≤a) :
    finiteMean (fun ε : Fin n→Bool => Real.exp (a*dependentVectorProcess
      (dependentHeterogeneousRowLayer ψ r u h) ε))≤
    Real.exp (14*R/η+a*((n:ℝ)*η))*
      finiteMean (fun ε : Fin n→Bool => Real.exp (a*dependentVectorProcess h ε)) := by
  letI : Nonempty (Σp,J p) := ⟨⟨Classical.choice inferInstance,Classical.choice inferInstance⟩⟩
  let q := sharpActivationResolution R η
  have hq : 0<q := sharpActivationResolution_pos hR hη
  letI : Nonempty (ActivationWalk q) := ⟨sharpActivationCode hR hq zeroUnitActivation⟩
  have hscalar (p : U) (j : J p) (i : Fin n) : |(ψ p j).val ⟪u p j,h p i⟫|≤R := by
    have hp := activation_abs_le (ψ p j).property ⟪u p j,h p i⟫
    simp only [one_mul] at hp
    exact hp.trans (linearRow_abs_le _ (hu _ _) _ (hh _ _))
  have hfirst := finiteMean_mono (fun ε : Fin n→Bool => Real.exp_le_exp.mpr
    (mul_le_mul_of_nonneg_left
      (dependentWeightedArrayLayer_process_le r (fun p j i => (ψ p j).val ⟪u p j,h p i⟫) hr hscalar ε) ha))
  have hcontract := covered_rademacher_exp_contraction n
    (fun pj : (Σp,J p) => (ψ pj.1 pj.2).val)
    (fun code : ActivationWalk q => (sharpActivationRepresentative hR hq code).val)
    (fun code => (sharpActivationRepresentative hR hq code).property.1)
    (fun code x y => by simpa only [one_mul] using (sharpActivationRepresentative hR hq code).property.2 x y)
    (fun pj : (Σp,J p) => fun i=>⟪u pj.1 pj.2,h pj.1 i⟫)
    (fun pj i => linearRow_abs_le _ (hu _ _) _ (hh _ _))
    (fun pj : (Σp,J p) => sharpActivationCode hR hq (ψ pj.1 pj.2))
    (fun pj i => (sharpActivationRepresentative_covers hR hq (ψ pj.1 pj.2) _
      (linearRow_abs_le _ (hu _ _) _ (hh _ _))).trans (sharpActivationResolution_error hR hη)) a ha
  have hlast := finiteMean_mono (fun ε : Fin n→Bool => Real.exp_le_exp.mpr
    (mul_le_mul_of_nonneg_left (dependentLinearRow_process_le u h hu hh ε) ha))
  have hresult := hfirst.trans (hcontract.trans (mul_le_mul_of_nonneg_left hlast (by positivity)))
  apply hresult.trans
  have hmean0 : 0≤finiteMean (fun ε : Fin n→Bool => Real.exp (a*dependentVectorProcess h ε)) :=
    finiteMean_nonneg (fun _=> (Real.exp_pos _).le)
  apply mul_le_mul_of_nonneg_right _ hmean0
  rw [Real.exp_add]
  apply mul_le_mul_of_nonneg_right (sharpActivationResolution_entropy hR hη hηR) (Real.exp_pos _).le

/-- Literal finite-depth iteration with the optimized activation entropy. -/
theorem normalizedFamilyState_sharp_mgf {n : ℕ} (w : ℕ→U→ℕ)
    (hw : ∀s p,0<w s p)
    (ψ : ∀s p,Fin (w (s+1) p)→UnitActivation)
    (r : ∀s p,Fin (w (s+1) p)→ℝ)
    (u : ∀s p,Fin (w (s+1) p)→EuclideanSpace ℝ (Fin (w s p)))
    (input : ∀p,Fin n→EuclideanSpace ℝ (Fin (w 0 p)))
    (hr : ∀s p,(∑j,r s p j^2)≤1) (hu : ∀s p j,‖u s p j‖≤1)
    {R η : ℝ} (hR : 0<R) (hη : 0<η) (hηR : η≤R)
    (hinput : ∀p i,‖input p i‖≤R) (a : ℝ) (ha : 0≤a) (s : ℕ) :
    finiteMean (fun ε : Fin n→Bool => Real.exp (a*dependentVectorProcess
      (normalizedFamilyState w ψ r u input s) ε))≤
    Real.exp ((s:ℝ)*(14*R/η+a*((n:ℝ)*η)))*
      finiteMean (fun ε : Fin n→Bool => Real.exp (a*dependentVectorProcess input ε)) := by
  induction s with
  | zero => simp [normalizedFamilyState]
  | succ s ih =>
    letI : ∀p,Nonempty (Fin (w (s+1) p)) := fun p=>⟨⟨0,hw (s+1) p⟩⟩
    have hprev := normalizedFamilyState_norm_le w hw ψ r u input hr hu hinput s
    have hstep := dependentHeterogeneousRowLayer_sharp_exp_peeling (ψ s) (r s) (u s)
      (normalizedFamilyState w ψ r u input s) (hr s) (hu s) hR hη hηR hprev a ha
    change finiteMean (fun ε : Fin n→Bool => Real.exp (a*dependentVectorProcess
      (normalizedFamilyState w ψ r u input (s+1)) ε))≤_ at hstep
    have hh := mul_le_mul_of_nonneg_left ih (Real.exp_pos (14*R/η+a*((n:ℝ)*η))).le
    apply (hstep.trans hh).trans_eq
    rw [←mul_assoc,←Real.exp_add]
    congr 2
    push_cast
    ring

end NeuralGeneralization.BatchTwoActivation
