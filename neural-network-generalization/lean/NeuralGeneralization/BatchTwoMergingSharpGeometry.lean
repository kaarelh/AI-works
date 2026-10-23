import NeuralGeneralization.BatchTwoMergingSharpRadius
import NeuralGeneralization.BatchTwoMergingSharpBulk

/-! The paper-radius cylinder controls both the raw network and its actual
population average. Only the active teacher span is constrained. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators Matrix
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel
variable {d N r : ℕ}

def sharpCoordinateCylinder (v : Weights d N r)
    (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
    (J : Finset (Fin N)) (ρ σ : ℝ) : Set (Weights d N r) :=
  orthogonalWhiten (internalRowIsometry b.repr) ⁻¹'
    ((MeasurableEquiv.piEquivPiSubtypeProd
      (fun _ : WeightIndex d N r => ℝ) (constrainedIndex J)) ⁻¹'
      ((Set.pi Set.univ fun q =>
        Set.Icc (rotateInternalRows b.repr (whiten v) q.val - ρ*σ)
          (rotateInternalRows b.repr (whiten v) q.val + ρ*σ)) ×ˢ
        sharpFreeCoordinateEvent J (sharpBulkBound r)))

theorem freeRow_layer_matrixActionBound
    (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
    (J : Finset (Fin N)) (Z : Fin N → Fin N → ℝ) {B:ℝ} (hB:0≤B)
    (hZ : ‖coordinateMatrixOperator
      (fun q : Fin N × {j:Fin N // j∉J} => basisCoordinates b (Z q.1) q.2.val)‖≤B) :
    matrixActionBound (fun i=>freeRow b J (Z i)) B := by
  intro z
  simp_rw [freeRow_eq_basisReconstructRow,basisReconstructRow_action]
  exact (coordinateMatrix_action_squared_le _ B hB hZ _).trans
    (mul_le_mul_of_nonneg_left
      (basisCoordinates_subset_energy_le b (fun a:{j:Fin N // j∉J}=>a.val)
        Subtype.val_injective z) (sq_nonneg B))

theorem sharp_cylinder_raw_merged_error (hd:0<d) (hN:0<N)
    (φ:ℝ→ℝ) (p:PopulationPartition N) (v w:Weights d N r)
    (b:OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
    (J:Finset (Fin N)) {ℓ κ C σ:ℝ}
    (hℓ:1≤ℓ) (hφ:∀u v,|φ u-φ v|≤ℓ*|u-v|)
    (hκ:1≤κ) (hC:1≤C) (hσ:0≤σ) (hscale:(N:ℝ)*σ^2≤1)
    (hJ:(J.card:ℝ)≤C)
    (hlayers:∀s,(∑i,∑j,v (Sum.inr (Sum.inl (s,i,j)))^2)≤κ*C)
    (hreadcost:readoutEnergy v≤16*κ*C)
    (hfixed:mergedWeights (fun _=>p) v=v)
    (hstatefixed:∀(x:Cube d) (ss:List (Fin r)),
      populationAverage p (ss.foldl (hiddenStep φ v) (firstHidden φ v x))=
        ss.foldl (hiddenStep φ v) (firstHidden φ v x))
    (hrows:∀s i j,j∉J→basisCoordinates b (fun a=>v (Sum.inr (Sum.inl (s,i,a)))) j=0)
    (hhidden:∀(x:Cube d) (ss:List (Fin r)) j,j∉J→
      basisCoordinates b (ss.foldl (hiddenStep φ v) (firstHidden φ v x)) j=0)
    (hbounded:∀(x:Cube d) (ss:List (Fin r)) i,
      |ss.foldl (hiddenStep φ v) (firstHidden φ v x) i|≤1)
    (hw:w∈sharpCoordinateCylinder v b J (sharpRadius ℓ κ C (sharpBulkBound r) d r) σ) :
    (∀x,|networkOutput φ w x-networkOutput φ v x|≤1/4) ∧
    (∀x,|networkOutput φ (mergedWeights (fun _=>p) w) x-networkOutput φ v x|≤1/4) ∧
    (∀i,|w (Sum.inr (Sum.inr i))-v (Sum.inr (Sum.inr i))|≤
      sharpRadius ℓ κ C (sharpBulkBound r) d r/N) := by
  classical
  let ρ:=sharpRadius ℓ κ C (sharpBulkBound r) d r
  obtain ⟨hρ,hρ16,hA,hamp,hfinal⟩ := sharpRadius_control d r hℓ hκ hC (sharpBulkBound_nonneg r)
  have hℓ0:0≤ℓ := by linarith
  have hC0:0≤C := by linarith
  have hκC:0≤κ*C := mul_nonneg (by linarith) hC0
  have hbox : ∀q,constrainedIndex J q→
      |rotateInternalRows b.repr (whiten w) q-rotateInternalRows b.repr (whiten v) q|≤ρ*σ := by
    intro q hq
    have hh := hw.1 ⟨q,hq⟩ (Set.mem_univ _)
    change rotateInternalRows b.repr (whiten v) q-ρ*σ≤rotateInternalRows b.repr (whiten w) q ∧
      rotateInternalRows b.repr (whiten w) q≤rotateInternalRows b.repr (whiten v) q+ρ*σ at hh
    exact abs_le.mpr ⟨by linarith [hh.1],by linarith [hh.2]⟩
  have hfirst : ∀i j,|w (Sum.inl (i,j))-v (Sum.inl (i,j))|≤ρ := by
    intro i j
    exact input_error_of_whitened hd hN hσ hρ.le hscale w v i j
      (hbox _ (constrainedIndex_input J i j))
  have hread : ∀i,|w (Sum.inr (Sum.inr i))-v (Sum.inr (Sum.inr i))|≤ρ/N := by
    intro i
    exact readout_error_of_whitened hd hN hσ hρ.le hscale w v i
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
  have hR : ∀s,(∑i,∑j,R s i j^2)≤ρ^2*C := by
    intro s
    have hh := selected_matrix_energy_le b J
      (fun i a => w (Sum.inr (Sum.inl (s,i,a)))-v (Sum.inr (Sum.inl (s,i,a))))
      ρ σ hρ.le hσ hscale (fun i j hj => by
        change |basisCoordinates b ((fun a => w (Sum.inr (Sum.inl (s,i,a))))-
          (fun a => v (Sum.inr (Sum.inl (s,i,a))))) j|≤_
        rw [basisCoordinates_sub]
        simpa only [rotated_whiten_internal] using hbox (Sum.inr (Sum.inl (s,i,j))) hj)
    exact hh.trans (mul_le_mul_of_nonneg_left hJ (sq_nonneg ρ))
  have hE : ∀s,matrixActionBound (E s) (sharpBulkBound r) := by
    intro s
    apply freeRow_layer_matrixActionBound b J _ (sharpBulkBound_nonneg r)
    have hh : ‖coordinateMatrixOperator
        (fun q:Fin N × {j:Fin N // j∉J} =>
          rotateInternalRows b.repr (whiten w) (Sum.inr (Sum.inl (s,q.1,q.2.val))))‖≤
          sharpBulkBound r := hw.2 s
    simpa only [rotated_whiten_internal] using hh
  have hkill : ∀(x:Cube d) (ss:List (Fin r)) s i,
      (∑j,E s i j*ss.foldl (hiddenStep φ v) (firstHidden φ v x) j)=0 := by
    intro x ss s i
    exact freeRow_annihilates b J _ _ (hhidden x ss)
  refine ⟨?_,?_,hread⟩
  · intro x
    exact (sharp_cylinder_output hN φ hℓ0 hφ hκC hC0 (sharpBulkBound_nonneg r)
      hρ.le (by positivity) hA hamp w v R E hdecomp hlayers hR hE hfirst hread
      hreadcost hbounded hkill x).trans hfinal
  · intro x
    apply (sharp_cylinder_output hN φ hℓ0 hφ hκC hC0 (sharpBulkBound_nonneg r)
      hρ.le (by positivity) hA hamp (mergedWeights (fun _=>p) w) v
      (fun s i j=>mergedPerturbation p R s i j)
      (fun s i j=>mergedPerturbation p E s i j)
      (merged_internal_decomposition_full p w v R E hfixed hdecomp) hlayers
      (fun s=>(mergedPerturbation_squaredSum_le p R s).trans (hR s))
      (projected_matrixActionBound p E hE) ?_ ?_ hreadcost hbounded ?_ x).trans hfinal
    · intro i j
      rw [merged_first_difference w v hfixed]
      exact populationAverage_abs_le p _ ρ (fun k=>hfirst k j) i
    · intro i
      rw [merged_readout_difference w v hfixed]
      exact populationAverage_abs_le p _ (ρ/N) hread i
    · intro x ss s i
      exact projected_bulk_annihilates p E _ (hstatefixed x ss) (hkill x ss) s i

end NeuralGeneralization.BatchTwoMerging
