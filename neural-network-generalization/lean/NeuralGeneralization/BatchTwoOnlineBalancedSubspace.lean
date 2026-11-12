import NeuralGeneralization.BatchTwoOnlineBalancedProjection

/-! The actual balanced teacher has a hidden-state subspace of dimension at most C. -/
noncomputable section
set_option autoImplicit false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineBalanced
open ConcreteModel BatchTwoMerging
variable {d C N r : ℕ} {k : Fin C→ℕ}

def layoutIndicator (e : (Σb : Fin C,Fin (k b))≃Fin N) (b : Fin C) : Fin N→ℝ :=
  fun i=>if layoutGroup e i=b then 1 else 0

def layoutSubspace (e : (Σb : Fin C,Fin (k b))≃Fin N) : Submodule ℝ (Fin N→ℝ) :=
  Submodule.span ℝ (Set.range (layoutIndicator e))

theorem layout_function_mem (e : (Σb : Fin C,Fin (k b))≃Fin N) (a : Fin C→ℝ) :
    (fun i=>a (layoutGroup e i))∈layoutSubspace e := by
  classical
  have he : (fun i=>a (layoutGroup e i))=∑b,a b • layoutIndicator e b := by
    funext i
    simp [layoutIndicator]
  rw [he]
  apply Submodule.sum_mem
  intro b _
  exact Submodule.smul_mem _ _ (Submodule.subset_span ⟨b,rfl⟩)

theorem layout_fibre_mem (e : (Σb : Fin C,Fin (k b))≃Fin N) (hk : ∀b,0<k b)
    (z : Fin N→ℝ) (hz : ∀i j,layoutGroup e i=layoutGroup e j→z i=z j) :
    z∈layoutSubspace e := by
  let a : Fin C→ℝ := fun b=>z (e ⟨b,⟨0,hk b⟩⟩)
  have he : z=fun i=>a (layoutGroup e i) := by
    funext i
    apply hz
    simp [layoutGroup]
  rw [he]
  exact layout_function_mem e a

theorem layoutSubspace_finrank_le (e : (Σb : Fin C,Fin (k b))≃Fin N) :
    Module.finrank ℝ (layoutSubspace e)≤C := by
  classical
  letI : Fintype (Set.range (layoutIndicator e)) := (Set.finite_range (layoutIndicator e)).fintype
  have hs := finrank_span_le_card (R:=ℝ) (Set.range (layoutIndicator e))
  have hc := Fintype.card_range_le (layoutIndicator e)
  simp only [Set.toFinset_card] at hs
  simp only [Fintype.card_fin] at hc
  exact hs.trans hc

theorem grouped_internalRow_mem (e : (Σb : Fin C,Fin (k b))≃Fin N)
    (B : LayeredBooleanCircuit d C r) (A a : ℝ) (s : Fin r) (i : Fin N) :
    (fun j=>groupedWeights B e A a (.inr (.inl (s,i,j))))∈layoutSubspace e :=
  layout_function_mem e (fun b=>A*(B.internal s (layoutGroup e i)).coeff B.constant b/(k b:ℝ))

theorem layoutBits_mem (e : (Σb : Fin C,Fin (k b))≃Fin N) (bits : Fin C→Bool) :
    layoutBits e bits∈layoutSubspace e := layout_function_mem e (fun b=>labelReal (bits b))

theorem grouped_hidden_mem (φ : ℝ→ℝ) (e : (Σb : Fin C,Fin (k b))≃Fin N)
    (hk : ∀b,0<k b) (B : LayeredBooleanCircuit d C r) (A a : ℝ)
    (x : Cube d) (ss : List (Fin r)) :
    ss.foldl (hiddenStep φ (groupedWeights B e A a)) (firstHidden φ (groupedWeights B e A a) x)
      ∈layoutSubspace e := by
  apply layout_fibre_mem e hk
  intro i j hg
  cases ss using List.reverseRecOn with
  | nil =>
    simp only [List.foldl_nil,firstHidden]
    congr 1
    apply Finset.sum_congr rfl
    intro b _
    rw [grouped_first_constant e B A a i j hg b]
  | append_singleton ss t _ =>
    simp only [List.foldl_append,List.foldl_cons,List.foldl_nil,hiddenStep]
    congr 1
    apply Finset.sum_congr rfl
    intro l _
    rw [grouped_internal_constant_left e B A a t i j l hg]

theorem exists_adapted_grouped_merging (φ : ℝ→ℝ)
    (e : (Σb : Fin C,Fin (k b))≃Fin N) (hk : ∀b,0<k b)
    (B : LayeredBooleanCircuit d C r) (A a : ℝ) :
    ∃(b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N))) (J : Finset (Fin N)),
      J.card≤C ∧
      (∀s i j,j∉J→basisCoordinates b (fun u=>groupedWeights B e A a (.inr (.inl (s,i,u)))) j=0) ∧
      (∀(x:Cube d) (ss:List (Fin r)) j,j∉J→basisCoordinates b
        (ss.foldl (hiddenStep φ (groupedWeights B e A a)) (firstHidden φ (groupedWeights B e A a) x)) j=0) ∧
      (∀(bits:Fin C→Bool) j,j∉J→basisCoordinates b (layoutBits e bits) j=0) := by
  let S := layoutSubspace e
  let u : (Fin N→ℝ)≃ₗ[ℝ] EuclideanSpace ℝ (Fin N) := (WithLp.linearEquiv 2 ℝ (Fin N→ℝ)).symm
  let T : Submodule ℝ (EuclideanSpace ℝ (Fin N)) := S.map u.toLinearMap
  obtain ⟨b,J,hJ,hspan⟩ := AdaptedBasis.exists_adapted_orthonormalBasis N T
  have hcard : J.card≤C := by
    rw [hJ]
    change Module.finrank ℝ (S.map u.toLinearMap)≤C
    rw [LinearEquiv.finrank_map_eq]
    exact layoutSubspace_finrank_le e
  have hsupport (z : Fin N→ℝ) (hz : z∈S) : ∀j,j∉J→basisCoordinates b z j=0 := by
    apply basisCoordinates_zero_of_mem_span b J z
    rw [←hspan]
    exact Submodule.mem_map.mpr ⟨z,hz,rfl⟩
  exact ⟨b,J,hcard,fun s i=>hsupport _ (grouped_internalRow_mem e B A a s i),
    fun x ss=>hsupport _ (grouped_hidden_mem φ e hk B A a x ss),
    fun bits=>hsupport _ (layoutBits_mem e bits)⟩

end NeuralGeneralization.BatchTwoOnlineBalanced
