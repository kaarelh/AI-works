import NeuralGeneralization.BatchTwoMergingCylinderSupport
import NeuralGeneralization.BatchTwoMergingCylinderMass

/-! # The actual Boolean teacher cylinder at every learner width -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators Matrix
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel
variable {d C N r k p : ℕ}

def mergingTeacherEnergy (d C r : ℕ) : ℝ := 2*d+10*r*C+160*C

theorem compiler_energy_le (hC : 0<C) (B : LayeredNorCircuit d C r) :
    weightedSquaredNorm (B.weights 4) ≤ (d:ℝ)+5*r*C+80*C := by
  have hCR : (0:ℝ)<C := by exact_mod_cast hC
  have hf := B.first_squaredSum_le 4
  have hi : (∑s,∑i,∑j,B.weights 4 (Sum.inr (Sum.inl (s,i,j)))^2)≤5*r*C := by
    calc
      _ ≤ ∑_s : Fin r,5*(C:ℝ) := Finset.sum_le_sum fun s _=>B.internal_squaredSum_le 4 s
      _ = _ := by simp; ring
  have ho := (B.readout_squaredSum_bounds 4).2
  have hff := mul_le_mul_of_nonneg_left hf (div_nonneg (Nat.cast_nonneg d) hCR.le)
  have hcc : (d:ℝ)/C*C=d := div_mul_cancel₀ _ hCR.ne'
  have hoo := mul_le_mul_of_nonneg_left ho hCR.le
  unfold weightedSquaredNorm
  nlinarith

theorem cloned_compiler_energy_le (hC : 0<C) (hk : 0<k)
    (hbelow : C*k≤N) (habove : N≤2*C*k)
    (e : ((Fin C×Fin k)⊕Fin p)≃Fin N) (B : LayeredNorCircuit d C r) :
    weightedSquaredNorm (clonedWeights e (B.weights 4))≤mergingTeacherEnergy d C r := by
  have h1 := weightedSquaredNorm_cloned_le hC hk hbelow habove e (B.weights 4)
  have h2 := compiler_energy_le hC B
  unfold mergingTeacherEnergy
  linarith

theorem cloned_compiler_readout_lower (hk : 0<k) (hbelow : C*k≤N)
    (e : ((Fin C×Fin k)⊕Fin p)≃Fin N) (B : LayeredNorCircuit d C r) :
    16*(C:ℝ)≤readoutEnergy (clonedWeights e (B.weights 4)) := by
  have hkR : (0:ℝ)<k := by exact_mod_cast hk
  have hbelowR : (C:ℝ)*k≤N := by exact_mod_cast hbelow
  have ho := (B.readout_squaredSum_bounds 4).1
  unfold readoutEnergy
  rw [readout_squaredSum_cloned hk]
  have hh := mul_le_mul_of_nonneg_left ho (Nat.cast_nonneg N : (0:ℝ)≤N)
  rw [← mul_div_assoc]
  apply (le_div_iff₀ hkR).mpr
  nlinarith

theorem exists_adapted_merging_clone (hk : 0<k)
    (e : ((Fin C×Fin k)⊕Fin p)≃Fin N) (B : LayeredNorCircuit d C r) :
    ∃(b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N))) (J : Finset (Fin N)),
    J.card≤C+1 ∧
    (∀s i j,j∉J→basisCoordinates b
      (fun a=>clonedWeights e (B.weights 4) (Sum.inr (Sum.inl (s,i,a)))) j=0) ∧
    (∀(x : Cube d) (ss : List (Fin r)) j,j∉J→basisCoordinates b
      (ss.foldl (hiddenStep relu (clonedWeights e (B.weights 4)))
        (firstHidden relu (clonedWeights e (B.weights 4)) x)) j=0) ∧
    (∀l j,j∉J→basisCoordinates b (fun i=>populationProjection (clonePartition e) i l) j=0) := by
  let S := cloneSubspace e
  let u : (Fin N→ℝ)≃ₗ[ℝ] EuclideanSpace ℝ (Fin N) :=
    (WithLp.linearEquiv 2 ℝ (Fin N→ℝ)).symm
  let T : Submodule ℝ (EuclideanSpace ℝ (Fin N)) := S.map u.toLinearMap
  obtain ⟨b,J,hJ,hspan⟩ := AdaptedBasis.exists_adapted_orthonormalBasis N T
  have hcard : J.card≤C+1 := by
    rw [hJ]
    change Module.finrank ℝ (S.map u.toLinearMap)≤C+1
    rw [LinearEquiv.finrank_map_eq]
    exact cloneSubspace_finrank_le e
  have hsupport (z : Fin N→ℝ) (hz : z∈S) : ∀j,j∉J→basisCoordinates b z j=0 := by
    apply basisCoordinates_zero_of_mem_span b J z
    rw [← hspan]
    exact Submodule.mem_map.mpr ⟨z,hz,rfl⟩
  exact ⟨b,J,hcard,
    fun s i=>hsupport _ (cloned_internalRow_mem_cloneSubspace e (B.weights 4) s i),
    fun x ss=>hsupport _ (hiddenFold_cloned_mem_cloneSubspace hk relu e (B.weights 4) x ss),
    fun l=>hsupport _ (clone_projection_column_mem e l)⟩

def mergingTargetCost (d C r : ℕ) : ℝ :=
  mergingCylinderCost d r (mergingTeacherEnergy d C r) (C+1)
    (mergingCylinderRadius d r (mergingTeacherEnergy d C r) (C+1))

theorem merging_target_mass_cloned (hd : 0<d) (hC : 0<C) (hk : 0<k)
    (hbelow : C*k≤N) (habove : N≤2*C*k)
    (e : ((Fin C×Fin k)⊕Fin p)≃Fin N) (B : LayeredNorCircuit d C r)
    {σ : ℝ} (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1) :
    Real.exp (-mergingTargetCost d C r/σ^2)≤
      (smallPrior d N r σ).real (mergingSupport relu ∩marginEvent relu (1/2) B.computes) := by
  have hN : 0<N := (Nat.mul_pos hC hk).trans_le hbelow
  have hK : 0≤mergingTeacherEnergy d C r := by unfold mergingTeacherEnergy; positivity
  have hG : (0:ℝ)≤C+1 := by positivity
  obtain ⟨b,J,hJ,hrows,hhidden,hcolumns⟩ := exists_adapted_merging_clone hk e B
  have hJ' : (J.card:ℝ)≤(C:ℝ)+1 := by exact_mod_cast hJ
  have hcost := cloned_compiler_energy_le hC hk hbelow habove e B
  have hρ := (mergingCylinderRadius_bounds (d:=d) (r:=r) hK hG).1
  have hmass := mergingCoordinateCylinder_mass hd hN (clonedWeights e (B.weights 4)) b J
    hρ hσ hscale hJ' hcost
  apply hmass.trans
  apply measureReal_mono _ (measure_ne_top _ _)
  apply merging_cylinder_containment (C:=(C:ℝ)) hd hN (clonePartition e) (clonedWeights e (B.weights 4)) B.computes
    b J hK hG (by exact_mod_cast hC) hσ.le hscale hJ' hcost
  · have hc := clonePartition_count_le e
    have hcR : (populationCount (clonePartition e):ℝ)≤(C:ℝ)+1 := by exact_mod_cast hc
    linarith
  · exact cloned_compiler_readout_lower hk hbelow e B
  · intro x
    rw [networkOutput_cloned hk,LayeredNorCircuit.networkOutput_weights]
  · exact merging_fixes_clone e (B.weights 4)
  · exact hrows
  · exact hhidden
  · exact hcolumns
  · exact cloned_compiler_hidden_bound hk e B 4


theorem merging_target_mass_all_widths (hd : 0<d) (hC : 0<C) (hCN : C≤N)
    (B : LayeredNorCircuit d C r) {σ : ℝ} (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1) :
    Real.exp (-mergingTargetCost d C r/σ^2)≤
      (smallPrior d N r σ).real (mergingSupport relu ∩marginEvent relu (1/2) B.computes) := by
  classical
  let k := N/C
  have hk : 0<k := Nat.div_pos hCN hC
  have hmod : N%C<C := Nat.mod_lt _ hC
  have hsplit : N%C+C*k=N := Nat.mod_add_div N C
  have hbelow : C*k≤N := by omega
  have hCk : C≤C*k := by simpa only [Nat.mul_one] using Nat.mul_le_mul_left C hk
  have habove : N≤2*C*k := by nlinarith
  let e : ((Fin C×Fin k)⊕Fin (N-C*k))≃Fin N := Fintype.equivOfCardEq (by
    simp only [Fintype.card_sum,Fintype.card_prod,Fintype.card_fin]
    omega)
  exact merging_target_mass_cloned hd hC hk hbelow habove e B hσ hscale

theorem mergingTargetCost_nonneg (d C r : ℕ) : 0≤mergingTargetCost d C r := by
  unfold mergingTargetCost mergingCylinderCost mergingTeacherEnergy
  positivity

end NeuralGeneralization.BatchTwoMerging
