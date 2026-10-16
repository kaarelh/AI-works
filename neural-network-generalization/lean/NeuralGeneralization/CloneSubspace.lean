import NeuralGeneralization.Cloning
import Mathlib.LinearAlgebra.Dimension.Constructions

/-!
# The hidden-vector subspace of the actual padded clone

For arbitrary activation, disconnected padding has value `φ 0`, so the clone
subspace includes its indicator. Its dimension is at most `C+1`, uniformly in
width. This is the subspace a cylinder residual must annihilate.
-/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.ConcreteModel

variable {d C N r k p : ℕ}

/-- `none` denotes the padding group, `some a` the clones of original neuron `a`. -/
def cloneGroup (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (i : Fin N) : Option (Fin C) :=
  match e.symm i with
  | Sum.inl (a,_) => some a
  | Sum.inr _ => none

def cloneGroupIndicator (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (g : Option (Fin C)) : Fin N → ℝ :=
  fun i => if cloneGroup e i = g then 1 else 0

/-- Include the padding group even when it is empty; this preserves the bound. -/
def cloneSubspace (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) :
    Submodule ℝ (Fin N → ℝ) := Submodule.span ℝ (Set.range (cloneGroupIndicator e))

theorem cloneGroup_expansion (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (a : Option (Fin C) → ℝ) :
    (fun i => a (cloneGroup e i)) = ∑ g, a g • cloneGroupIndicator e g := by
  classical
  funext i
  simp [cloneGroupIndicator]

/-- Exact grouping identity, including the possibly nonzero padding activation. -/
theorem clonedHidden_group_expansion (φ : ℝ → ℝ)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (h : Fin C → ℝ) :
    clonedHidden φ e h = ∑ g : Option (Fin C),
      (match g with | none => φ 0 | some a => h a) • cloneGroupIndicator e g := by
  let a : Option (Fin C) → ℝ := fun g => match g with | none => φ 0 | some j => h j
  have he : clonedHidden φ e h = fun i => a (cloneGroup e i) := by
    funext i
    cases hi : e.symm i with
    | inl aj => simp [clonedHidden, cloneGroup, a, hi]
    | inr z => simp [clonedHidden, cloneGroup, a, hi]
  exact he.trans (cloneGroup_expansion e a)

theorem clonedHidden_mem_cloneSubspace (φ : ℝ → ℝ)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (h : Fin C → ℝ) :
    clonedHidden φ e h ∈ cloneSubspace e := by
  classical
  rw [clonedHidden_group_expansion]
  apply Submodule.sum_mem
  intro g hg
  apply Submodule.smul_mem
  exact Submodule.subset_span ⟨g,rfl⟩

/-- The cylinder constraint dimension grows by at most one because of padding. -/
theorem cloneSubspace_finrank_le (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) :
    Module.finrank ℝ (cloneSubspace e) ≤ C + 1 := by
  classical
  letI : Fintype (Set.range (cloneGroupIndicator e)) :=
    (Set.finite_range (cloneGroupIndicator e)).fintype
  have hs := finrank_span_le_card (R := ℝ) (Set.range (cloneGroupIndicator e))
  have hc := Fintype.card_range_le (cloneGroupIndicator e)
  simp only [Set.toFinset_card] at hs
  simp only [Fintype.card_option, Fintype.card_fin] at hc
  exact hs.trans hc

/-- Every actual prefix of the cloned network lies in this same fixed subspace. -/
theorem hiddenFold_cloned_mem_cloneSubspace (hk : 0 < k) (φ : ℝ → ℝ)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (w : Weights d C r)
    (x : Cube d) (ss : List (Fin r)) :
    ss.foldl (hiddenStep φ (clonedWeights e w)) (firstHidden φ (clonedWeights e w) x) ∈
      cloneSubspace e := by
  rw [firstHidden_cloned, hiddenFold_cloned hk]
  exact clonedHidden_mem_cloneSubspace φ e _

theorem firstHidden_cloned_mem_cloneSubspace (φ : ℝ → ℝ)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (w : Weights d C r) (x : Cube d) :
    firstHidden φ (clonedWeights e w) x ∈ cloneSubspace e := by
  rw [firstHidden_cloned]
  exact clonedHidden_mem_cloneSubspace φ e _

theorem finalHidden_cloned_mem_cloneSubspace (hk : 0 < k) (φ : ℝ → ℝ)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (w : Weights d C r) (x : Cube d) :
    finalHidden φ (clonedWeights e w) x ∈ cloneSubspace e := by
  rw [finalHidden_cloned hk]
  exact clonedHidden_mem_cloneSubspace φ e _

/-- Any residual linear operator that kills all clone-group indicators also
    kills every cloned hidden vector, for an arbitrary activation. -/
theorem linearMap_clonedHidden_eq_zero {V : Type*} [AddCommGroup V] [Module ℝ V]
    (φ : ℝ → ℝ) (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (h : Fin C → ℝ)
    (E : (Fin N → ℝ) →ₗ[ℝ] V) (hE : ∀ g, E (cloneGroupIndicator e g) = 0) :
    E (clonedHidden φ e h) = 0 := by
  have hspan : cloneSubspace e ≤ LinearMap.ker E := by
    apply Submodule.span_le.mpr
    rintro v ⟨g,rfl⟩
    exact hE g
  exact hspan (clonedHidden_mem_cloneSubspace φ e h)


/-- At every width above the teacher width, one can choose the output-preserving
    low-cost clone together with a single low-dimensional subspace containing
    all of its hidden states, uniformly over all inputs and layer prefixes. -/
theorem exists_clone_and_hidden_subspace_at_every_width (hC : 0 < C) (hCN : C ≤ N)
    (φ : ℝ → ℝ) (w : Weights d C r) :
    ∃ (v : Weights d N r) (S : Submodule ℝ (Fin N → ℝ)),
      (∀ x, networkOutput φ v x = networkOutput φ w x) ∧
      weightedSquaredNorm v ≤ 2 * weightedSquaredNorm w ∧
      Module.finrank ℝ S ≤ C + 1 ∧
      ∀ x (ss : List (Fin r)), ss.foldl (hiddenStep φ v) (firstHidden φ v x) ∈ S := by
  classical
  let k := N / C
  have hk : 0 < k := Nat.div_pos hCN hC
  have hmod : N % C < C := Nat.mod_lt _ hC
  have hsplit : N % C + C * k = N := Nat.mod_add_div N C
  have hbelow : C * k ≤ N := by omega
  have hCk : C ≤ C * k := by
    simpa only [Nat.mul_one] using Nat.mul_le_mul_left C hk
  have habove : N ≤ 2 * C * k := by nlinarith
  let e : ((Fin C × Fin k) ⊕ Fin (N - C * k)) ≃ Fin N :=
    Fintype.equivOfCardEq (by
      simp only [Fintype.card_sum, Fintype.card_prod, Fintype.card_fin]
      omega)
  exact ⟨clonedWeights e w, cloneSubspace e,
    fun x => networkOutput_cloned hk φ e w x,
    weightedSquaredNorm_cloned_le hC hk hbelow habove e w,
    cloneSubspace_finrank_le e,
    fun x ss => hiddenFold_cloned_mem_cloneSubspace hk φ e w x ss⟩

/-- Every vector constant on the clone groups belongs to the cylinder subspace. -/
theorem cloneGroup_function_mem (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (a : Option (Fin C) → ℝ) : (fun i => a (cloneGroup e i)) ∈ cloneSubspace e := by
  rw [cloneGroup_expansion]
  apply Submodule.sum_mem
  intro g hg
  exact Submodule.smul_mem _ _ (Submodule.subset_span ⟨g,rfl⟩)

/-- Teacher internal rows have no component in the free orthogonal coordinates. -/
theorem cloned_internalRow_mem_cloneSubspace
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (w : Weights d C r) (s : Fin r) (i : Fin N) :
    (fun j => clonedWeights e w (Sum.inr (Sum.inl (s,i,j)))) ∈ cloneSubspace e := by
  let a : Option (Fin C) → ℝ := fun g =>
    match e.symm i, g with
    | Sum.inl (b,_), some c => w (Sum.inr (Sum.inl (s,b,c)))/(k:ℝ)
    | _, _ => 0
  have he : (fun j => clonedWeights e w (Sum.inr (Sum.inl (s,i,j)))) =
      fun j => a (cloneGroup e j) := by
    funext j
    cases hi : e.symm i <;> cases hj : e.symm j <;>
      simp [clonedWeights, cloneGroup, a, hi, hj]
  rw [he]
  exact cloneGroup_function_mem e a

theorem cloned_readout_mem_cloneSubspace
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (w : Weights d C r) :
    (fun j => clonedWeights e w (Sum.inr (Sum.inr j))) ∈ cloneSubspace e := by
  let a : Option (Fin C) → ℝ := fun g =>
    match g with
    | some c => w (Sum.inr (Sum.inr c))/(k:ℝ)
    | none => 0
  have he : (fun j => clonedWeights e w (Sum.inr (Sum.inr j))) =
      fun j => a (cloneGroup e j) := by
    funext j
    cases hj : e.symm j <;> simp [clonedWeights, cloneGroup, a, hj]
  rw [he]
  exact cloneGroup_function_mem e a

/-- A strengthened all-width cloning theorem that records both hidden-signal
and internal-row support in the same fixed subspace. -/
theorem exists_supported_clone_at_every_width (hC : 0 < C) (hCN : C ≤ N)
    (φ : ℝ → ℝ) (w : Weights d C r) :
    ∃ (v : Weights d N r) (S : Submodule ℝ (Fin N → ℝ)),
      (∀ x, networkOutput φ v x = networkOutput φ w x) ∧
      weightedSquaredNorm v ≤ 2 * weightedSquaredNorm w ∧
      Module.finrank ℝ S ≤ C + 1 ∧
      (∀ x (ss : List (Fin r)), ss.foldl (hiddenStep φ v) (firstHidden φ v x) ∈ S) ∧
      (∀ s i, (fun j => v (Sum.inr (Sum.inl (s,i,j)))) ∈ S) ∧
      (fun j => v (Sum.inr (Sum.inr j))) ∈ S := by
  classical
  let k := N / C
  have hk : 0 < k := Nat.div_pos hCN hC
  have hmod : N % C < C := Nat.mod_lt _ hC
  have hsplit : N % C + C*k = N := Nat.mod_add_div N C
  have hbelow : C*k ≤ N := by omega
  have hCk : C ≤ C*k := by simpa only [Nat.mul_one] using Nat.mul_le_mul_left C hk
  have habove : N ≤ 2*C*k := by nlinarith
  let e : ((Fin C × Fin k) ⊕ Fin (N-C*k)) ≃ Fin N :=
    Fintype.equivOfCardEq (by
      simp only [Fintype.card_sum, Fintype.card_prod, Fintype.card_fin]
      omega)
  exact ⟨clonedWeights e w, cloneSubspace e,
    fun x => networkOutput_cloned hk φ e w x,
    weightedSquaredNorm_cloned_le hC hk hbelow habove e w,
    cloneSubspace_finrank_le e,
    fun x ss => hiddenFold_cloned_mem_cloneSubspace hk φ e w x ss,
    fun s i => cloned_internalRow_mem_cloneSubspace e w s i,
    cloned_readout_mem_cloneSubspace e w⟩

end NeuralGeneralization.ConcreteModel
