import NeuralGeneralization.BatchTwoImprovedTargetContainment
import NeuralGeneralization.RobustTargetGeometry

/-! Actual independent Gaussian cylinder implies the original calibrated support. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.ConcreteModel
open NeuralGeneralization.BatchTwoMerging
variable {d C N r k p:ℕ}

theorem improvedCoordinateCylinder_containment
    (hd : 0 < d) (hN : 0 < N) (hk : 0 < k) (hwidth : N ≤ 2*C*k) (hbelow:C*k≤N)
    (B : LayeredBooleanCircuit d C r) (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
    (J : Finset (Fin N)) {A a ε τ ρ σ c : ℝ}
    (hA : 0 < A) (ha : 0 ≤ a) (hε : 0 ≤ ε) (hε1 : ε ≤ 1)
    (hτ : 0 ≤ τ) (hρ : 0 ≤ ρ) (hreadρ : ρ ≤ a/2)
    (hfirst : ((d:ℝ)+1)*ρ ≤ A/2)
    (hgroup : 2*(C:ℝ)*ε^2 ≤ (1/16:ℝ)^2)
    (hinit : 3*((2*Real.exp (-A/2))^2+τ^2) ≤ ε^2)
    (hstep : 3*((2*Real.exp (-A/2))^2+(8/A)^2*(4*ρ^2*((C:ℝ)+1)*(1+ε^2)+
      2*(sharpBulkBound r)^2*ε^2)+τ^2) ≤ ε^2)
    (hout : 1 < 15*a/16-2*ρ-τ) (hc : 0 < c) (hcal : 2*c ≤ τ*a*Real.sqrt C)
    (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1) (hJ : J.card ≤ C+1)
    (hrows : ∀ s i j,j ∉ J → basisCoordinates b
      (fun u => B.saturatedClone e A a (.inr (.inl (s,i,u)))) j=0)
    (hideal : ∀ (bits : Fin C → Bool) j,j ∉ J →
      basisCoordinates b (saturatedCloneBits e bits) j=0) :
    sharpCoordinateCylinder (B.saturatedClone e A a) b J ρ σ ⊆
      robustEvent Real.tanh c ∩ marginEvent Real.tanh (1/2) B.computes := by
  classical
  intro w hw
  let v := B.saturatedClone e A a
  have hbox : ∀ q,constrainedIndex J q →
      |rotateInternalRows b.repr (whiten w) q-rotateInternalRows b.repr (whiten v) q| ≤ ρ*σ := by
    intro q hq
    have hh := hw.1 (⟨q,hq⟩ : {q : WeightIndex d N r // constrainedIndex J q}) (Set.mem_univ _)
    change rotateInternalRows b.repr (whiten v) q-ρ*σ ≤ rotateInternalRows b.repr (whiten w) q ∧
      rotateInternalRows b.repr (whiten w) q ≤ rotateInternalRows b.repr (whiten v) q+ρ*σ at hh
    exact abs_le.mpr ⟨by linarith [hh.1],by linarith [hh.2]⟩
  let R : Fin r → Fin N → Fin N → ℝ := fun s i => selectedRow b J
    ((fun u => w (.inr (.inl (s,i,u))))-(fun u => v (.inr (.inl (s,i,u)))))
  let E : Fin r → Fin N → Fin N → ℝ := fun s i => freeRow b J
    (fun u => w (.inr (.inl (s,i,u))))
  have hdecomp : ∀ s i j,w (.inr (.inl (s,i,j)))=v (.inr (.inl (s,i,j)))+R s i j+E s i j := by
    intro s i j
    exact congrFun (row_cylinder_decomposition b J
      (fun u => w (.inr (.inl (s,i,u))))
      (fun u => v (.inr (.inl (s,i,u)))) (hrows s i)) j
  have hR : ∀ s,(∑ i,∑ j,R s i j^2) ≤ ρ^2*((C:ℝ)+1) := by
    intro s
    have hh := selected_matrix_energy_le b J
      (fun i => (fun u => w (.inr (.inl (s,i,u))))-(fun u => v (.inr (.inl (s,i,u)))))
      ρ σ hρ hσ.le hscale (by
        intro i j hj
        simpa only [basisCoordinates_sub, rotated_whiten_internal] using
          hbox (.inr (.inl (s,i,j))) hj)
    apply hh.trans
    apply mul_le_mul_of_nonneg_left _ (sq_nonneg ρ)
    exact_mod_cast hJ
  have hE:∀s,matrixActionBound (E s) (sharpBulkBound r) := by
    intro s
    apply freeRow_layer_matrixActionBound b J _ (sharpBulkBound_nonneg r)
    have hh:‖coordinateMatrixOperator
      (fun q:Fin N×{j:Fin N // j∉J}=>rotateInternalRows b.repr (whiten w)
        (.inr (.inl (s,q.1,q.2.val))))‖≤sharpBulkBound r := hw.2 s
    simpa only [rotated_whiten_internal] using hh
  have hkill : ∀ (bits : Fin C → Bool) s i,(∑ j,E s i j*saturatedCloneBits e bits j)=0 := by
    intro bits s i
    exact freeRow_annihilates b J _ _ (hideal bits)
  have H : ExponentialCylinderConditions B e w A a ε τ ρ ((C:ℝ)+1) (sharpBulkBound r) :=
    { R := R, E := E, gain_pos := hA, readout_nonneg := ha,
      error_nonneg := hε, error_le_one := hε1, noise_nonneg := hτ,
      radius_nonneg := hρ, readout_radius := hreadρ,
      first_error := fun i j => input_error_of_whitened hd hN hσ.le hρ hscale w v i j
        (hbox (.inl (i,j)) (constrainedIndex_input J i j)),
      first_small := hfirst,
      readout_error := fun i => readout_error_of_whitened hd hN hσ.le hρ hscale w v i
        (hbox (.inr (.inr i)) (constrainedIndex_readout J i)),
      decomp := hdecomp, projected_bound := hR, free_bound := hE, free_kills := hkill,
      group_small := hgroup, init_bound := hinit, step_bound := hstep, output_margin := hout }
  exact H.robust_and_target hN hk hwidth hbelow hc hcal

end NeuralGeneralization.ConcreteModel
