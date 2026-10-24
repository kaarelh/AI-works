import NeuralGeneralization.BatchTwoMergingTeacher
import NeuralGeneralization.BatchTwoMergingGeluCircuitNorm

/-! Exact layerwise energy and the active clone subspace. Zero activation at
zero removes the padding direction from the constrained Gaussian coordinates. -/
noncomputable section
open scoped BigOperators Matrix
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel
variable {d C N r k p : ℕ}

def activeCloneSubspace (e : ((Fin C×Fin k)⊕Fin p)≃Fin N) : Submodule ℝ (Fin N→ℝ) :=
  Submodule.span ℝ (Set.range (fun a : Fin C=>cloneGroupIndicator e (some a)))

theorem activeCloneSubspace_finrank_le (e : ((Fin C×Fin k)⊕Fin p)≃Fin N) :
    Module.finrank ℝ (activeCloneSubspace e)≤C := by
  classical
  let v : Fin C→Fin N→ℝ := fun a=>cloneGroupIndicator e (some a)
  letI : Fintype (Set.range v) := (Set.finite_range v).fintype
  have hs := finrank_span_le_card (R:=ℝ) (Set.range v)
  have hc := Fintype.card_range_le v
  simp only [Set.toFinset_card] at hs
  simp only [Fintype.card_fin] at hc
  exact hs.trans hc

theorem zeroClonedHidden_expansion (φ : ℝ→ℝ) (hφ : φ 0=0)
    (e : ((Fin C×Fin k)⊕Fin p)≃Fin N) (h : Fin C→ℝ) :
    clonedHidden φ e h=∑a:Fin C,h a • cloneGroupIndicator e (some a) := by
  rw [clonedHidden_group_expansion]
  simp [Fintype.sum_option,hφ]

theorem zeroClonedHidden_mem_active (φ : ℝ→ℝ) (hφ : φ 0=0)
    (e : ((Fin C×Fin k)⊕Fin p)≃Fin N) (h : Fin C→ℝ) :
    clonedHidden φ e h∈activeCloneSubspace e := by
  classical
  rw [zeroClonedHidden_expansion φ hφ]
  apply Submodule.sum_mem
  intro a _
  apply Submodule.smul_mem
  exact Submodule.subset_span ⟨a,rfl⟩

theorem cloned_internalRow_mem_active (e : ((Fin C×Fin k)⊕Fin p)≃Fin N)
    (w : Weights d C r) (s : Fin r) (i : Fin N) :
    (fun j=>clonedWeights e w (Sum.inr (Sum.inl (s,i,j))))∈activeCloneSubspace e := by
  cases hi : e.symm i with
  | inr z =>
    have he : (fun j=>clonedWeights e w (Sum.inr (Sum.inl (s,i,j))))=0 := by
      funext j
      simp [clonedWeights,hi]
    rw [he]
    exact Submodule.zero_mem _
  | inl ai =>
    have he : (fun j=>clonedWeights e w (Sum.inr (Sum.inl (s,i,j))))=
        clonedHidden relu e (fun a=>w (Sum.inr (Sum.inl (s,ai.1,a)))/k) := by
      funext j
      cases hj : e.symm j <;> simp [clonedWeights,clonedHidden,hi,hj,relu_zero]
    rw [he]
    exact zeroClonedHidden_mem_active relu relu_zero e _

theorem hiddenFold_cloned_mem_active (hk : 0<k) (φ : ℝ→ℝ) (hφ : φ 0=0)
    (e : ((Fin C×Fin k)⊕Fin p)≃Fin N) (w : Weights d C r)
    (x : Cube d) (ss : List (Fin r)) :
    ss.foldl (hiddenStep φ (clonedWeights e w))
      (firstHidden φ (clonedWeights e w) x)∈activeCloneSubspace e := by
  rw [firstHidden_cloned,hiddenFold_cloned hk]
  exact zeroClonedHidden_mem_active φ hφ e _

theorem activeClone_average_fixed (φ : ℝ→ℝ) (e : ((Fin C×Fin k)⊕Fin p)≃Fin N)
    (h : Fin C→ℝ) : populationAverage (clonePartition e) (clonedHidden φ e h)=clonedHidden φ e h := by
  apply populationAverage_eq_of_fibre_constant
  intro i j hij
  have hh := (clonePartition_label_eq e i j).mp hij
  cases hi : e.symm i <;> cases hj : e.symm j <;>
    simp_all [cloneGroup,clonedHidden]

theorem exists_adapted_active_clone (hk : 0<k) (φ : ℝ→ℝ) (hφ : φ 0=0)
    (e : ((Fin C×Fin k)⊕Fin p)≃Fin N) (w : Weights d C r) :
    ∃(b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N))) (J : Finset (Fin N)),
      J.card≤C ∧
      (∀s i j,j∉J→basisCoordinates b
        (fun a=>clonedWeights e w (Sum.inr (Sum.inl (s,i,a)))) j=0) ∧
      (∀(x:Cube d) (ss:List (Fin r)) j,j∉J→basisCoordinates b
        (ss.foldl (hiddenStep φ (clonedWeights e w)) (firstHidden φ (clonedWeights e w) x)) j=0) := by
  let S := activeCloneSubspace e
  let u : (Fin N→ℝ)≃ₗ[ℝ] EuclideanSpace ℝ (Fin N) :=
    (WithLp.linearEquiv 2 ℝ (Fin N→ℝ)).symm
  let T : Submodule ℝ (EuclideanSpace ℝ (Fin N)) := S.map u.toLinearMap
  obtain ⟨b,J,hJ,hspan⟩ := AdaptedBasis.exists_adapted_orthonormalBasis N T
  have hcard : J.card≤C := by
    rw [hJ]
    change Module.finrank ℝ (S.map u.toLinearMap)≤C
    rw [LinearEquiv.finrank_map_eq]
    exact activeCloneSubspace_finrank_le e
  have hsupport (z : Fin N→ℝ) (hz : z∈S) : ∀j,j∉J→basisCoordinates b z j=0 := by
    apply basisCoordinates_zero_of_mem_span b J z
    rw [←hspan]
    exact Submodule.mem_map.mpr ⟨z,hz,rfl⟩
  exact ⟨b,J,hcard,
    fun s i=>hsupport _ (cloned_internalRow_mem_active e w s i),
    fun x ss=>hsupport _ (hiddenFold_cloned_mem_active hk φ hφ e w x ss)⟩

theorem sharp_cloned_compiler_energy (hC : 0<C) (hk : 0<k)
    (hbelow : C*k≤N) (habove : N≤2*C*k)
    (e : ((Fin C×Fin k)⊕Fin p)≃Fin N) (B : LayeredNorCircuit d C r) (a:ℝ) :
    weightedSquaredNorm (clonedWeights e (B.weights a))≤
      (d:ℝ)+5*r*C+10*a^2*C := by
  have hN : 0<N := (Nat.mul_pos hC hk).trans_le hbelow
  have hNr : (0:ℝ)<N := by exact_mod_cast hN
  have hkr : (0:ℝ)<k := by exact_mod_cast hk
  have hbr : (C:ℝ)*k≤N := by exact_mod_cast hbelow
  have har : (N:ℝ)≤2*C*k := by exact_mod_cast habove
  have hf := mul_le_mul_of_nonneg_left (B.first_squaredSum_le a)
    (by positivity : 0≤(d:ℝ)*k/N)
  have hff : ((d:ℝ)*k/N)*(C:ℝ)≤d := by
    rw [div_mul_eq_mul_div]
    apply (div_le_iff₀ hNr).mpr
    nlinarith [mul_le_mul_of_nonneg_left hbr (Nat.cast_nonneg d : (0:ℝ)≤d)]
  have hi : (∑s,∑i,∑j,B.weights a (Sum.inr (Sum.inl (s,i,j)))^2)≤5*r*C := by
    calc
      _ ≤ ∑_s:Fin r,5*(C:ℝ) := Finset.sum_le_sum fun s _=>B.internal_squaredSum_le a s
      _ = _ := by simp; ring
  have hv := mul_le_mul_of_nonneg_left (B.readout_squaredSum_bounds a).2
    (by positivity : 0≤(N:ℝ)/k)
  have hvv : ((N:ℝ)/k)*(5*a^2)≤10*a^2*C := by
    rw [div_mul_eq_mul_div]
    apply (div_le_iff₀ hkr).mpr
    nlinarith [mul_le_mul_of_nonneg_right har (by positivity : 0≤5*a^2)]
  rw [weightedSquaredNorm_cloned hk]
  linarith

end NeuralGeneralization.BatchTwoMerging
