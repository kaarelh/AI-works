import NeuralGeneralization.BatchTwoMergingGeluCylinderSupport
import NeuralGeneralization.BatchTwoMergingGeluCircuitNorm
import NeuralGeneralization.BatchTwoMergingCylinderMass

/-! # The actual Boolean teacher cylinder at every learner width -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators Matrix
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel
variable {d C N r k p : ℕ}

def geluMergingTeacherEnergy (d C r : ℕ) : ℝ := 2*d+50*r*C+800*C

theorem gelu_compiler_energy_le (hC : 0<C) (B : LayeredNorCircuit d C r) :
    weightedSquaredNorm (B.geluWeights 4) ≤ (d:ℝ)+25*r*(2*C)+400*(2*C) := by
  have hCR : (0:ℝ)<(2*C:ℕ) := by exact_mod_cast (Nat.mul_pos (by omega : 0<2) hC)
  have hf := B.gelu_first_squaredSum_le 4
  have hi : (∑s,∑i,∑j,B.geluWeights 4 (Sum.inr (Sum.inl (s,i,j)))^2)≤25*r*(2*C) := by
    calc
      _ ≤ ∑_s : Fin r,25*(2*C:ℝ) := Finset.sum_le_sum fun s _=>B.gelu_internal_squaredSum_le 4 s
      _ = _ := by simp; ring
  have ho := (B.gelu_readout_squaredSum_bounds 4).2
  have hff := mul_le_mul_of_nonneg_left hf (div_nonneg (Nat.cast_nonneg d) hCR.le)
  have hcc : (d:ℝ)/(2*C)*(2*C)=d := div_mul_cancel₀ _ (by simpa using hCR.ne')
  have hoo := mul_le_mul_of_nonneg_left ho hCR.le
  unfold weightedSquaredNorm
  push_cast at hff hoo ⊢
  nlinarith

theorem cloned_gelu_compiler_energy_le (hC : 0<C) (hk : 0<k)
    (hbelow : (2*C)*k≤N) (habove : N≤2*(2*C)*k)
    (e : ((Fin (2*C)×Fin k)⊕Fin p)≃Fin N) (B : LayeredNorCircuit d C r) :
    weightedSquaredNorm (clonedWeights e (B.geluWeights 4))≤geluMergingTeacherEnergy d (2*C) r := by
  have h1 := weightedSquaredNorm_cloned_le (Nat.mul_pos (by omega) hC) hk hbelow habove e (B.geluWeights 4)
  have h2 := gelu_compiler_energy_le hC B
  unfold geluMergingTeacherEnergy
  push_cast
  linarith

theorem gelu_cloned_compiler_readout_lower (hk : 0<k) (hbelow : (2*C)*k≤N)
    (e : ((Fin (2*C)×Fin k)⊕Fin p)≃Fin N) (B : LayeredNorCircuit d C r) :
    16*(2*C:ℝ)≤readoutEnergy (clonedWeights e (B.geluWeights 4)) := by
  have hkR : (0:ℝ)<k := by exact_mod_cast hk
  have hbelowR : (2*C:ℝ)*k≤N := by exact_mod_cast hbelow
  have ho := (B.gelu_readout_squaredSum_bounds 4).1
  unfold readoutEnergy
  rw [readout_squaredSum_cloned hk]
  have hh := mul_le_mul_of_nonneg_left ho (Nat.cast_nonneg N : (0:ℝ)≤N)
  rw [← mul_div_assoc]
  apply (le_div_iff₀ hkR).mpr
  nlinarith

theorem exists_adapted_gelu_merging_clone (hk : 0<k)
    (e : ((Fin (2*C)×Fin k)⊕Fin p)≃Fin N) (B : LayeredNorCircuit d C r) :
    ∃(b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N))) (J : Finset (Fin N)),
    J.card≤2*C+1 ∧
    (∀s i j,j∉J→basisCoordinates b
      (fun a=>clonedWeights e (B.geluWeights 4) (Sum.inr (Sum.inl (s,i,a)))) j=0) ∧
    (∀(x : Cube d) (ss : List (Fin r)) j,j∉J→basisCoordinates b
      (ss.foldl (hiddenStep gelu (clonedWeights e (B.geluWeights 4)))
        (firstHidden gelu (clonedWeights e (B.geluWeights 4)) x)) j=0) ∧
    (∀l j,j∉J→basisCoordinates b (fun i=>populationProjection (clonePartition e) i l) j=0) := by
  let S := cloneSubspace e
  let u : (Fin N→ℝ)≃ₗ[ℝ] EuclideanSpace ℝ (Fin N) :=
    (WithLp.linearEquiv 2 ℝ (Fin N→ℝ)).symm
  let T : Submodule ℝ (EuclideanSpace ℝ (Fin N)) := S.map u.toLinearMap
  obtain ⟨b,J,hJ,hspan⟩ := AdaptedBasis.exists_adapted_orthonormalBasis N T
  have hcard : J.card≤2*C+1 := by
    rw [hJ]
    change Module.finrank ℝ (S.map u.toLinearMap)≤2*C+1
    rw [LinearEquiv.finrank_map_eq]
    exact cloneSubspace_finrank_le e
  have hsupport (z : Fin N→ℝ) (hz : z∈S) : ∀j,j∉J→basisCoordinates b z j=0 := by
    apply basisCoordinates_zero_of_mem_span b J z
    rw [← hspan]
    exact Submodule.mem_map.mpr ⟨z,hz,rfl⟩
  exact ⟨b,J,hcard,
    fun s i=>hsupport _ (cloned_internalRow_mem_cloneSubspace e (B.geluWeights 4) s i),
    fun x ss=>hsupport _ (hiddenFold_cloned_mem_cloneSubspace hk gelu e (B.geluWeights 4) x ss),
    fun l=>hsupport _ (clone_projection_column_mem e l)⟩

def geluMergingTargetCost (d C r : ℕ) : ℝ :=
  mergingCylinderCost d r (geluMergingTeacherEnergy d C r) (C+1)
    (geluMergingCylinderRadius d r (geluMergingTeacherEnergy d C r) (C+1))

theorem gelu_merging_target_mass_cloned (hd : 0<d) (hC : 0<C) (hk : 0<k)
    (hbelow : (2*C)*k≤N) (habove : N≤2*(2*C)*k)
    (e : ((Fin (2*C)×Fin k)⊕Fin p)≃Fin N) (B : LayeredNorCircuit d C r)
    {σ : ℝ} (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1) :
    Real.exp (-geluMergingTargetCost d (2*C) r/σ^2)≤
      (smallPrior d N r σ).real (mergingSupport gelu ∩marginEvent gelu (1/2) B.computes) := by
  have hN : 0<N := (Nat.mul_pos (Nat.mul_pos (by omega) hC) hk).trans_le hbelow
  have hK : 0≤geluMergingTeacherEnergy d (2*C) r := by unfold geluMergingTeacherEnergy; positivity
  have hG : (0:ℝ)≤2*C+1 := by positivity
  obtain ⟨b,J,hJ,hrows,hhidden,hcolumns⟩ := exists_adapted_gelu_merging_clone hk e B
  have hJ' : (J.card:ℝ)≤2*C+1 := by exact_mod_cast hJ
  have hcost := cloned_gelu_compiler_energy_le hC hk hbelow habove e B
  have hρ := (geluMergingCylinderRadius_bounds (d:=d) (r:=r) hK hG).1
  have hmass := mergingCoordinateCylinder_mass hd hN (clonedWeights e (B.geluWeights 4)) b J
    hρ hσ hscale hJ' hcost
  unfold geluMergingTargetCost
  norm_num only [Nat.cast_mul,Nat.cast_ofNat]
  apply hmass.trans
  apply measureReal_mono _ (measure_ne_top _ _)
  apply gelu_merging_cylinder_containment (C:=(2*C:ℝ)) hd hN (clonePartition e) (clonedWeights e (B.geluWeights 4)) B.computes
    b J hK hG (by exact_mod_cast (Nat.mul_pos (by omega : 0<2) hC)) hσ.le hscale hJ' hcost
  · have hc := clonePartition_count_le e
    have hcR : (populationCount (clonePartition e):ℝ)≤2*C+1 := by exact_mod_cast hc
    linarith
  · exact gelu_cloned_compiler_readout_lower hk hbelow e B
  · intro x
    rw [networkOutput_cloned hk,LayeredNorCircuit.gelu_networkOutput]
  · exact merging_fixes_clone e (B.geluWeights 4)
  · exact hrows
  · exact hhidden
  · exact hcolumns
  · intro x ss i
    rw [firstHidden_cloned,hiddenFold_cloned hk]
    cases hi : e.symm i with
    | inl ai => simpa only [clonedHidden,hi] using B.gelu_hiddenFold_abs_le_one 4 ss x ai.1
    | inr j => simp [clonedHidden,hi,gelu_zero]


theorem gelu_merging_target_mass_all_widths (hd : 0<d) (hC : 0<C) (hCN : 2*C≤N)
    (B : LayeredNorCircuit d C r) {σ : ℝ} (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1) :
    Real.exp (-geluMergingTargetCost d (2*C) r/σ^2)≤
      (smallPrior d N r σ).real (mergingSupport gelu ∩marginEvent gelu (1/2) B.computes) := by
  classical
  let k := N/(2*C)
  have hk : 0<k := Nat.div_pos hCN (Nat.mul_pos (by omega) hC)
  have hmod : N%(2*C)<2*C := Nat.mod_lt _ (Nat.mul_pos (by omega) hC)
  have hsplit : N%(2*C)+(2*C)*k=N := Nat.mod_add_div N (2*C)
  have hbelow : (2*C)*k≤N := by omega
  have hCk : 2*C≤(2*C)*k := by simpa only [Nat.mul_one] using Nat.mul_le_mul_left (2*C) hk
  have habove : N≤2*(2*C)*k := by nlinarith
  let e : ((Fin (2*C)×Fin k)⊕Fin (N-(2*C)*k))≃Fin N := Fintype.equivOfCardEq (by
    simp only [Fintype.card_sum,Fintype.card_prod,Fintype.card_fin]
    omega)
  exact gelu_merging_target_mass_cloned hd hC hk hbelow habove e B hσ hscale

theorem geluMergingTargetCost_nonneg (d C r : ℕ) : 0≤geluMergingTargetCost d C r := by
  unfold geluMergingTargetCost mergingCylinderCost geluMergingTeacherEnergy
  positivity

end NeuralGeneralization.BatchTwoMerging
