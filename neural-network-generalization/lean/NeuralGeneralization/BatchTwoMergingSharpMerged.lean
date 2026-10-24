import NeuralGeneralization.BatchTwoMergingSharpStability

/-! Projection preserves the bulk operator bound. The bulk need only kill the
teacher state, so no extra constrained direction is needed for zero padding. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators Matrix
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel
variable {d N r : ℕ}

theorem projected_matrixActionBound (p:PopulationPartition N)
    (E:Fin r→Fin N→Fin N→ℝ) {B:ℝ}
    (hE:∀s,matrixActionBound (E s) B) (s:Fin r) :
    matrixActionBound (mergedPerturbation p E s) B := by
  intro z
  have heq : (fun i=>∑j,mergedPerturbation p E s i j*z j)=
      populationAverage p (fun i=>∑j,E s i j*populationAverage p z j) := by
    change mergedPerturbation p E s *ᵥ z = _
    unfold mergedPerturbation
    rw [←Matrix.mulVec_mulVec,←Matrix.mulVec_mulVec]
    rfl
  simp_rw [congrFun heq]
  calc
    _ ≤ ∑i,(∑j,E s i j*populationAverage p z j)^2 := populationAverage_squaredSum_le p _
    _ ≤ B^2*∑j,populationAverage p z j^2 := hE s _
    _ ≤ _ := mul_le_mul_of_nonneg_left (populationAverage_squaredSum_le p z) (sq_nonneg B)

theorem projected_bulk_annihilates (p:PopulationPartition N)
    (E:Fin r→Fin N→Fin N→ℝ) (z:Fin N→ℝ)
    (hfixed:populationAverage p z=z)
    (hkill:∀s i,(∑j,E s i j*z j)=0) (s:Fin r) (i:Fin N) :
    (∑j,mergedPerturbation p E s i j*z j)=0 := by
  have heq : (fun i=>∑j,mergedPerturbation p E s i j*z j)=
      populationAverage p (fun i=>∑j,E s i j*populationAverage p z j) := by
    change mergedPerturbation p E s *ᵥ z = _
    unfold mergedPerturbation
    rw [←Matrix.mulVec_mulVec,←Matrix.mulVec_mulVec]
    rfl
  have hz : (fun i=>∑j,E s i j*z j)=0 := by funext i; exact hkill s i
  rw [congrFun heq i,hfixed,hz]
  simp [populationAverage]

theorem merged_internal_decomposition_full (p:PopulationPartition N) (w v:Weights d N r)
    (R E:Fin r→Fin N→Fin N→ℝ)
    (hfixed:mergedWeights (fun _=>p) v=v)
    (hdecomp:∀s i j,w (Sum.inr (Sum.inl (s,i,j)))=
      v (Sum.inr (Sum.inl (s,i,j)))+R s i j+E s i j)
    (s:Fin r) (i j:Fin N) :
    mergedWeights (fun _=>p) w (Sum.inr (Sum.inl (s,i,j)))=
      v (Sum.inr (Sum.inl (s,i,j)))+mergedPerturbation p R s i j+
        mergedPerturbation p E s i j := by
  have hm:internalMatrix w s=internalMatrix v s+Matrix.of (R s)+Matrix.of (E s) := by
    ext i j
    exact hdecomp s i j
  have hv:Matrix.of (populationProjection p)*internalMatrix v s*
      Matrix.of (populationProjection p)=internalMatrix v s := by
    have h:=merged_internalMatrix (fun _=>p) v s
    rw [hfixed] at h
    exact h.symm
  have he:internalMatrix (mergedWeights (fun _=>p) w) s=
      internalMatrix v s+mergedPerturbation p R s+mergedPerturbation p E s := by
    rw [merged_internalMatrix,hm]
    simp only [Matrix.mul_add,Matrix.add_mul]
    rw [hv]
    rfl
  simpa only [internalMatrix,Matrix.of_apply,Matrix.add_apply] using congrFun (congrFun he i) j

end NeuralGeneralization.BatchTwoMerging
