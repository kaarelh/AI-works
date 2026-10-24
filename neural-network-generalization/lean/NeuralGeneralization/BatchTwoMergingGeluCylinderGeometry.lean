import NeuralGeneralization.BatchTwoMergingGeluCylinderStability
import NeuralGeneralization.BatchTwoMergingCloneGeometry
import NeuralGeneralization.RobustTargetProbability

/-! # Simultaneous raw and merged output control in the actual Gaussian cylinder -/
noncomputable section
open scoped BigOperators Matrix
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel
variable {d N r : ℕ}

theorem gelu_cylinder_raw_merged_error (hd : 0<d) (hN : 0<N)
    (p : PopulationPartition N) (v w : Weights d N r)
    (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
    (J : Finset (Fin N)) {K G ρ σ : ℝ}
    (hK : 0≤K) (hG : 0≤G) (hρ : 0≤ρ) (hρ1 : ρ≤1/2) (hσ : 0≤σ)
    (hscale : (N:ℝ)*σ^2≤1) (hJ : (J.card:ℝ)≤G)
    (hcost : weightedSquaredNorm v≤K)
    (hfixed : mergedWeights (fun _ => p) v=v)
    (hrows : ∀ s i j,j∉J→basisCoordinates b (fun a => v (Sum.inr (Sum.inl (s,i,a)))) j=0)
    (hhidden : ∀ (x : Cube d) (ss : List (Fin r)) j,j∉J→
      basisCoordinates b (ss.foldl (hiddenStep gelu v) (firstHidden gelu v x)) j=0)
    (hcolumns : ∀ k j,j∉J→basisCoordinates b (fun i => populationProjection p i k) j=0)
    (hbounded : ∀ (x : Cube d) (ss : List (Fin r)) i,
      |ss.foldl (hiddenStep gelu v) (firstHidden gelu v x) i|≤1)
    (hw : w∈robustCoordinateCylinder v b J ρ σ) :
    (∀x,(networkOutput gelu w x-networkOutput gelu v x)^2≤
      ρ^2*geluCylinderOutputFactor d r K G (16*((r:ℝ)+1))) ∧
    (∀x,(networkOutput gelu (mergedWeights (fun _ => p) w) x-networkOutput gelu v x)^2≤
      ρ^2*geluCylinderOutputFactor d r K G (16*((r:ℝ)+1))) ∧
    (∀i,|w (Sum.inr (Sum.inr i))-v (Sum.inr (Sum.inr i))|≤ρ/N) := by
  classical
  have hbox : ∀q,constrainedIndex J q→
      |rotateInternalRows b.repr (whiten w) q-rotateInternalRows b.repr (whiten v) q|≤ρ*σ := by
    intro q hq
    have hh := hw.1 ⟨q,hq⟩ (Set.mem_univ _)
    change rotateInternalRows b.repr (whiten v) q-ρ*σ≤rotateInternalRows b.repr (whiten w) q ∧
      rotateInternalRows b.repr (whiten w) q≤rotateInternalRows b.repr (whiten v) q+ρ*σ at hh
    exact abs_le.mpr ⟨by linarith [hh.1],by linarith [hh.2]⟩
  have hfirst : ∀i j,|w (Sum.inl (i,j))-v (Sum.inl (i,j))|≤ρ := by
    intro i j
    exact input_error_of_whitened hd hN hσ hρ hscale w v i j
      (hbox _ (constrainedIndex_input J i j))
  have hread : ∀i,|w (Sum.inr (Sum.inr i))-v (Sum.inr (Sum.inr i))|≤ρ/N := by
    intro i
    exact readout_error_of_whitened hd hN hσ hρ hscale w v i
      (hbox _ (constrainedIndex_readout J i))
  let R : Fin r→Fin N→Fin N→ℝ := fun s i => selectedRow b J
    (fun a => w (Sum.inr (Sum.inl (s,i,a)))-v (Sum.inr (Sum.inl (s,i,a))))
  let E : Fin r→Fin N→Fin N→ℝ := fun s i => freeRow b J
    (fun a => w (Sum.inr (Sum.inl (s,i,a))))
  have hdecomp : ∀s i j,w (Sum.inr (Sum.inl (s,i,j)))=
      v (Sum.inr (Sum.inl (s,i,j)))+R s i j+E s i j := by
    intro s i j
    exact congrFun (row_cylinder_decomposition b J
      (fun a => w (Sum.inr (Sum.inl (s,i,a))))
      (fun a => v (Sum.inr (Sum.inl (s,i,a)))) (hrows s i)) j
  have hR : ∀s,(∑i,∑j,R s i j^2)≤ρ^2*G := by
    intro s
    have hh := selected_matrix_energy_le b J
      (fun i a => w (Sum.inr (Sum.inl (s,i,a)))-v (Sum.inr (Sum.inl (s,i,a))))
      ρ σ hρ hσ hscale (fun i j hj => by
        change |basisCoordinates b ((fun a => w (Sum.inr (Sum.inl (s,i,a))))-
          (fun a => v (Sum.inr (Sum.inl (s,i,a))))) j|≤_
        rw [basisCoordinates_sub]
        simpa only [rotated_whiten_internal] using hbox (Sum.inr (Sum.inl (s,i,j))) hj)
    exact hh.trans (mul_le_mul_of_nonneg_left hJ (sq_nonneg ρ))
  have hE : ∀s,matrixActionBound (E s) (16*((r:ℝ)+1)) := by
    apply freeRow_stack_matrixActionBound b J _ _ (by positivity)
    have hh : ‖coordinateMatrixOperator
        (fun q : (Fin r × Fin N) × {j : Fin N // j ∉ J} =>
          rotateInternalRows b.repr (whiten w) (Sum.inr (Sum.inl (q.1.1,q.1.2,q.2.val))))‖ ≤
        16*((r:ℝ)+1) := hw.2
    simpa only [rotated_whiten_internal] using hh
  have hkill : ∀(x : Cube d) (ss : List (Fin r)) s i,
      (∑j,E s i j*ss.foldl (hiddenStep gelu v) (firstHidden gelu v x) j)=0 := by
    intro x ss s i
    exact freeRow_annihilates b J _ _ (hhidden x ss)
  have hEP : ∀s,Matrix.of (E s)*Matrix.of (populationProjection p)=0 := by
    intro s
    ext i k
    exact freeRow_annihilates b J _ _ (hcolumns k)
  refine ⟨?_,?_,hread⟩
  · intro x
    exact gelu_cylinder_output_sq hN w v R E hK hG hρ hρ1
      hdecomp hcost hR hE hfirst hread hbounded hkill x
  · intro x
    exact gelu_merged_cylinder_output_sq hN p w v R E hK hG hρ hρ1
      hfixed hdecomp hEP hcost hR hfirst hread hbounded x

end NeuralGeneralization.BatchTwoMerging
