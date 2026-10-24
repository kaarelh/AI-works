import NeuralGeneralization.BatchTwoOnlineSharpCylinderStability
import NeuralGeneralization.BatchTwoMergingSharpGeometry

/-! The exact orthogonal Gaussian cylinder lies in the original strict target
event, for every bounded 1-Lipschitz activation and every learner width. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineSharp
open ConcreteModel

theorem sharp_cylinder_containment {d C N r : ℕ} (hd : 0<d) (hN : 0<N) (hC : 1≤C)
    (φ : ℝ→ℝ) (hφ : admissibleActivation φ) (f : BooleanFunction d) (w v : Weights d N r)
    (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N))) (J : Finset (Fin N))
    {σ : ℝ} (hσ : 0≤σ) (hscale : (N:ℝ)*σ^2≤1) (hJ : J.card≤C+1)
    (hmargin : v∈marginEvent φ (3/2) f)
    (hlayers : ∀s,(∑i,∑j,v (Sum.inr (Sum.inl (s,i,j)))^2)≤(C:ℝ)^4)
    (hreadcost : (N:ℝ)*(∑i,v (Sum.inr (Sum.inr i))^2)≤18*(C:ℝ)^4)
    (hrows : ∀s i j,j∉J→basisCoordinates b (fun a=>v (Sum.inr (Sum.inl (s,i,a)))) j=0)
    (hhidden : ∀(x : Cube d) (ss : List (Fin r)) j,j∉J→
      basisCoordinates b (ss.foldl (hiddenStep φ v) (firstHidden φ v x)) j=0)
    (hw : w∈BatchTwoMerging.sharpCoordinateCylinder v b J (cylinderRadius d C r) σ) :
    w∈marginEvent φ (1/2) f := by
  classical
  let ρ:=cylinderRadius d C r
  have hρ:0<ρ:=cylinderRadius_pos _ _ _
  have hbox:∀q,constrainedIndex J q→
      |rotateInternalRows b.repr (whiten w) q-rotateInternalRows b.repr (whiten v) q|≤ρ*σ :=by
    intro q hq
    have hh:=hw.1 ⟨q,hq⟩ (Set.mem_univ _)
    change rotateInternalRows b.repr (whiten v) q-ρ*σ≤rotateInternalRows b.repr (whiten w) q ∧
      rotateInternalRows b.repr (whiten w) q≤rotateInternalRows b.repr (whiten v) q+ρ*σ at hh
    exact abs_le.mpr ⟨by linarith [hh.1],by linarith [hh.2]⟩
  have hfirst:∀i j,|w (Sum.inl (i,j))-v (Sum.inl (i,j))|≤ρ:=by
    intro i j
    exact input_error_of_whitened hd hN hσ hρ.le hscale w v i j
      (hbox _ (constrainedIndex_input J i j))
  have hread:∀i,|w (Sum.inr (Sum.inr i))-v (Sum.inr (Sum.inr i))|≤ρ/N:=by
    intro i
    exact readout_error_of_whitened hd hN hσ hρ.le hscale w v i
      (hbox _ (constrainedIndex_readout J i))
  let R:Fin r→Fin N→Fin N→ℝ:=fun s i=>selectedRow b J
    (fun a=>w (Sum.inr (Sum.inl (s,i,a)))-v (Sum.inr (Sum.inl (s,i,a))))
  let E:Fin r→Fin N→Fin N→ℝ:=fun s i=>freeRow b J
    (fun a=>w (Sum.inr (Sum.inl (s,i,a))))
  have hdecomp:∀s i j,w (Sum.inr (Sum.inl (s,i,j)))=
      v (Sum.inr (Sum.inl (s,i,j)))+R s i j+E s i j:=by
    intro s i j
    exact congrFun (row_cylinder_decomposition b J
      (fun a=>w (Sum.inr (Sum.inl (s,i,a))))
      (fun a=>v (Sum.inr (Sum.inl (s,i,a)))) (hrows s i)) j
  have hR:∀s,(∑i,∑j,R s i j^2)≤ρ^2*((C:ℝ)+1):=by
    intro s
    have hh:=selected_matrix_energy_le b J
      (fun i a=>w (Sum.inr (Sum.inl (s,i,a)))-v (Sum.inr (Sum.inl (s,i,a))))
      ρ σ hρ.le hσ hscale (fun i j hj=>by
        change |basisCoordinates b ((fun a=>w (Sum.inr (Sum.inl (s,i,a))))-
          (fun a=>v (Sum.inr (Sum.inl (s,i,a))))) j|≤_
        rw [basisCoordinates_sub]
        simpa only [rotated_whiten_internal] using hbox (Sum.inr (Sum.inl (s,i,j))) hj)
    exact hh.trans (mul_le_mul_of_nonneg_left (by exact_mod_cast hJ : (J.card:ℝ)≤(C:ℝ)+1) (sq_nonneg ρ))
  have hE:∀s,matrixActionBound (E s) (cylinderBulkBound r):=by
    intro s
    apply BatchTwoMerging.freeRow_layer_matrixActionBound b J _ (cylinderBulkBound_nonneg r)
    have hh:‖coordinateMatrixOperator (fun q:Fin N×{j:Fin N//j∉J}=>
      rotateInternalRows b.repr (whiten w) (Sum.inr (Sum.inl (s,q.1,q.2.val))))‖≤
        cylinderBulkBound r:=hw.2 s
    simpa only [rotated_whiten_internal] using hh
  have hkill:∀(x:Cube d) (ss:List (Fin r)) s i,
      (∑j,E s i j*ss.foldl (hiddenStep φ v) (firstHidden φ v x) j)=0:=by
    intro x ss s i
    exact freeRow_annihilates b J _ _ (hhidden x ss)
  intro x
  have herr:=cylinder_output_error hN hC φ hφ w v R E hdecomp hlayers hreadcost hR hE hfirst hread hkill x
  have habs:|labelReal (f x)*(networkOutput φ w x-networkOutput φ v x)|≤1:=by
    simpa only [abs_mul,abs_labelReal,one_mul] using herr
  have hl:=(abs_le.mp habs).1
  have hm:=hmargin x
  nlinarith

end NeuralGeneralization.BatchTwoOnlineSharp
