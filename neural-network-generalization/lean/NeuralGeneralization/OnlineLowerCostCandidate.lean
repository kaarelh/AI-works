import NeuralGeneralization.OnlineLowerCostCombined

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLower

def freePathVertex (vs : List Bool) (j : Fin vs.length) : Fin (2*vs.length+1) :=
  ⟨2*j.val, by omega⟩

def fixedPathVertex (vs : List Bool) (j : Fin vs.length) : Fin (2*vs.length+1) :=
  ⟨2*j.val+1, by omega⟩

def terminalPathVertex (vs : List Bool) : Fin (2*vs.length+1) := ⟨2*vs.length, by omega⟩

theorem blockSyndrome_tail (v : Bool) (vs : List Bool) (terminal : Bool)
    (i : Fin (2*vs.length+1)) :
    blockSyndrome (v::vs) terminal ⟨i.val+2, by simp; omega⟩ =
      blockSyndrome vs terminal i := by rfl

theorem blockSyndrome_free (vs : List Bool) (terminal : Bool) (j : Fin vs.length) :
    blockSyndrome vs terminal (freePathVertex vs j) = vs.get j := by
  induction vs with
  | nil => exact j.elim0
  | cons v vs ih =>
    refine Fin.cases ?_ (fun i => ?_) j
    · rfl
    · have he : freePathVertex (v::vs) i.succ =
        ⟨(freePathVertex vs i).val+2, by simp; omega⟩ := by
        apply Fin.ext
        simp [freePathVertex]
        omega
      rw [he, blockSyndrome_tail, ih]
      rfl

theorem blockSyndrome_fixed (vs : List Bool) (terminal : Bool) (j : Fin vs.length) :
    blockSyndrome vs terminal (fixedPathVertex vs j) = true := by
  induction vs with
  | nil => exact j.elim0
  | cons v vs ih =>
    refine Fin.cases ?_ (fun i => ?_) j
    · rfl
    · have he : fixedPathVertex (v::vs) i.succ =
        ⟨(fixedPathVertex vs i).val+2, by simp; omega⟩ := by
        apply Fin.ext
        simp [fixedPathVertex]
        omega
      rw [he, blockSyndrome_tail, ih]

theorem blockSyndrome_terminal (vs : List Bool) (terminal : Bool) :
    blockSyndrome vs terminal (terminalPathVertex vs) = terminal := by
  induction vs with
  | nil => rfl
  | cons v vs ih =>
    have he : terminalPathVertex (v::vs) =
      ⟨(terminalPathVertex vs).val+2, by simp; omega⟩ := by
      apply Fin.ext
      simp [terminalPathVertex]
      omega
    rw [he, blockSyndrome_tail, ih]

theorem cubeCoordinateSign_not_digitSign (b : Bool) :
    cubeCoordinateSign (!b) = -digitSign b := by cases b <;> norm_num [cubeCoordinateSign, digitSign]

theorem product_negated_list_signs (vs : List Bool) :
    (∏ j : Fin vs.length, cubeCoordinateSign (!(vs.get j))) =
      (-1 : ℝ)^vs.length * digitSign (boolSignProduct vs) := by
  induction vs with
  | nil => simp [boolSignProduct, digitSign]
  | cons v vs ih =>
    simp only [List.length_cons, Fin.prod_univ_succ, List.get_eq_getElem,
      Fin.val_zero, Fin.val_succ, List.getElem_cons_zero, List.getElem_cons_succ,
      boolSignProduct, digitSign_signMul, cubeCoordinateSign_not_digitSign, pow_succ]
    simp only [List.get_eq_getElem, cubeCoordinateSign_not_digitSign] at ih
    rw [ih]
    ring

theorem blockSyndrome_free_product (vs : List Bool) (terminal : Bool) :
    (∏ j : Fin vs.length,
      cubeCoordinateSign (!(blockSyndrome vs terminal (freePathVertex vs j)))) =
      (-1 : ℝ)^vs.length * digitSign (boolSignProduct vs) := by
  simp_rw [blockSyndrome_free]
  exact product_negated_list_signs vs

theorem fixedParityBlocks_free_product (endpoint : Bool) (digits : List Bool) :
    (∏ j : Fin (fixedParityBlocks endpoint digits).length,
      cubeCoordinateSign (!(blockSyndrome (fixedParityBlocks endpoint digits) false
        (freePathVertex (fixedParityBlocks endpoint digits) j)))) =
      (-1 : ℝ)^(digits.length+1) * digitSign endpoint := by
  rw [blockSyndrome_free_product, fixedParityBlocks_signProduct, fixedParityBlocks_length]

theorem candidate_parity_constant (k : ℕ) (endpoint : Bool) :
    (-1 : ℝ)^k * digitSign endpoint =
      cubeCoordinateSign (if k % 2 = 0 then endpoint else !endpoint) := by
  rw [neg_one_pow_eq_pow_mod_two]
  by_cases hk : k % 2 = 0
  · cases endpoint <;> norm_num [hk, digitSign, cubeCoordinateSign]
  · have hk1 : k % 2 = 1 := by omega
    cases endpoint <;> norm_num [hk, hk1, digitSign, cubeCoordinateSign]

theorem negativeBitsCube_map_cast {n m : ℕ} (h : n = m)
    (S : Finset (Fin n)) (i : Fin n) :
    negativeBitsCube (S.map (costFinCastEmbedding h)) (Fin.cast h i) =
      negativeBitsCube S i := by
  classical
  unfold negativeBitsCube
  have hm := Finset.mem_map' (costFinCastEmbedding h) (a := i) (s := S)
  change Fin.cast h i ∈ S.map (costFinCastEmbedding h) ↔ i ∈ S at hm
  by_cases hi : i ∈ S
  · have hj := hm.mpr hi
    simp only [hi, hj, decide_true, Bool.not_true]
  · have hj : Fin.cast h i ∉ S.map (costFinCastEmbedding h) := fun hj => hi (hm.mp hj)
    simp only [hi, hj, decide_false, Bool.not_false]

theorem negativeBitsCube_joined (P V : ℕ) (T : Finset (Fin V)) :
    negativeBitsCube (joinedSyndromeSupport P V T) =
      costCubeJoin P V ((fun _ => false), negativeBitsCube T) := by
  funext i
  obtain ⟨j,rfl⟩ := finSumFinEquiv.surjective i
  cases j <;> simp [negativeBitsCube, joinedSyndromeSupport]

open OnlineLowerRelu
namespace FamilyCost

def candidatePoint (k : ℕ) (hk : 1 ≤ k) (endpoint : Bool)
    (digits : Fin (k-1) → Bool) : ClippingCube (Family.logicalDim k) :=
  negativeBitsCube (joinedSyndromeSupport (Family.prefixDim k) (Family.pathDim k)
    (candidatePathSupport k hk endpoint digits))

@[simp] theorem candidatePoint_prefix (k : ℕ) (hk : 1 ≤ k) (endpoint : Bool)
    (digits : Fin (k-1) → Bool) (i : Fin (Family.prefixDim k)) :
    candidatePoint k hk endpoint digits (Family.logicalIndex k (.inl i)) = false := by
  rw [candidatePoint, negativeBitsCube_joined]
  exact costCubeJoin_inl _ _ _ _

theorem candidatePoint_path_cast (k : ℕ) (hk : 1 ≤ k) (endpoint : Bool)
    (digits : Fin (k-1) → Bool)
    (i : Fin (2*(candidateBlocks k endpoint digits).length+1)) :
    candidatePoint k hk endpoint digits (Family.logicalIndex k (.inr
      (Fin.cast (by rw [candidateBlocks_length k hk]) i))) =
      !(blockSyndrome (candidateBlocks k endpoint digits) false i) := by
  rw [candidatePoint, negativeBitsCube_joined]
  simp only [Family.logicalIndex, costCubeJoin_inr]
  unfold candidatePathSupport
  rw [negativeBitsCube_map_cast]
  simp [negativeBitsCube, blockSyndromeSupport]

def familyFreeVertex (k : ℕ) (j : Fin k) : Fin (Family.pathDim k) := ⟨2*j.val, by unfold Family.pathDim; omega⟩

def familyFixedVertex (k : ℕ) (j : Fin k) : Fin (Family.pathDim k) := ⟨2*j.val+1, by unfold Family.pathDim; omega⟩

theorem candidatePoint_fixed (k : ℕ) (hk : 1 ≤ k) (endpoint : Bool)
    (digits : Fin (k-1) → Bool) (j : Fin k) :
    candidatePoint k hk endpoint digits (Family.logicalIndex k (.inr (familyFixedVertex k j))) = false := by
  let vs := candidateBlocks k endpoint digits
  let hlen := candidateBlocks_length k hk endpoint digits
  let i : Fin vs.length := Fin.cast hlen.symm j
  have he : Fin.cast (by rw [candidateBlocks_length k hk]) (fixedPathVertex vs i) =
      familyFixedVertex k j := by apply Fin.ext; rfl
  rw [← he, candidatePoint_path_cast, blockSyndrome_fixed]
  rfl

theorem candidatePoint_terminal (k : ℕ) (hk : 1 ≤ k) (endpoint : Bool)
    (digits : Fin (k-1) → Bool) :
    candidatePoint k hk endpoint digits (Family.logicalIndex k (.inr
      ⟨2*k, by unfold Family.pathDim; omega⟩)) = true := by
  let vs := candidateBlocks k endpoint digits
  have he : Fin.cast (by rw [candidateBlocks_length k hk]) (terminalPathVertex vs) =
      (⟨2*k, by unfold Family.pathDim; omega⟩ : Fin (Family.pathDim k)) := by
    apply Fin.ext
    simp [terminalPathVertex, vs, candidateBlocks_length k hk]
  rw [← he, candidatePoint_path_cast, blockSyndrome_terminal]
  rfl

theorem candidatePoint_free_product (k : ℕ) (hk : 1 ≤ k) (endpoint : Bool)
    (digits : Fin (k-1) → Bool) :
    (∏ j : Fin k, cubeCoordinateSign (candidatePoint k hk endpoint digits
      (Family.logicalIndex k (.inr (familyFreeVertex k j))))) =
      (-1 : ℝ)^k * digitSign endpoint := by
  let vs := candidateBlocks k endpoint digits
  have hlen := candidateBlocks_length k hk endpoint digits
  let e : Fin vs.length ≃ Fin k := finCongr hlen
  rw [← e.prod_comp]
  have he (j : Fin vs.length) : familyFreeVertex k (e j) =
      Fin.cast (by rw [candidateBlocks_length k hk]) (freePathVertex vs j) := by
    apply Fin.ext
    rfl
  simp_rw [he, candidatePoint_path_cast]
  rw [blockSyndrome_free_product]
  change (-1 : ℝ)^(candidateBlocks k endpoint digits).length *
    digitSign (boolSignProduct (fixedParityBlocks endpoint (List.ofFn digits))) = _
  rw [hlen, fixedParityBlocks_signProduct]

def subsetWeight (k : ℕ) (n₀ : ℝ) (cost : ℝ → ℝ)
    (S : Finset (Fin (Family.logicalDim k))) : ℝ :=
  cost (columnDegree n₀ (Family.column k) (fun j => (Family.increment k j : ℝ))
    (negativeBitsCube S))

theorem candidateCost_eq_weightExpansion (k : ℕ) (hk : 1 ≤ k) (n₀ : ℝ)
    (cost : ℝ → ℝ) (endpoint : Bool) (digits : Fin (k-1) → Bool) :
    candidateCost k hk n₀ cost endpoint digits =
      walshExpansion (subsetWeight k n₀ cost) (candidatePoint k hk endpoint digits) /
        Fintype.card (ClippingCube (Family.logicalDim k)) := by
  symm
  exact subset_weight_fourier_eq
    (fun s => cost (columnDegree n₀ (Family.column k) (fun j => (Family.increment k j : ℝ)) s))
    (joinedSyndromeSupport (Family.prefixDim k) (Family.pathDim k)
      (candidatePathSupport k hk endpoint digits))

theorem candidatePoint_injective (k : ℕ) (hk : 3 ≤ k) (endpoint : Bool) :
    Function.Injective (candidatePoint k (by omega) endpoint) := by
  intro xs ys he
  apply candidateCost_injective k hk 2 (by norm_num) endpoint
  rw [candidateCost_eq_weightExpansion, candidateCost_eq_weightExpansion, he]

theorem candidatePoint_card (k : ℕ) (hk : 3 ≤ k) (endpoint : Bool) :
    (Finset.univ.image (candidatePoint k (by omega) endpoint)).card = 2^(k-1) := by
  classical
  rw [Finset.card_image_of_injective _ (candidatePoint_injective k hk endpoint)]
  simp

end FamilyCost

end NeuralGeneralization.OnlineLower
