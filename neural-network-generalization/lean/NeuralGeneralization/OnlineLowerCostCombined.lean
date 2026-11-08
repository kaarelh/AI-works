import NeuralGeneralization.OnlineLowerCostPrefixBound
import NeuralGeneralization.OnlineLowerCostRailBridge
import NeuralGeneralization.OnlineLowerReluFamily

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLower

def costCubeJoin (P V : ℕ) : ClippingCube P × ClippingCube V ≃ ClippingCube (P+V) where
  toFun z i := Sum.elim z.1 z.2 (finSumFinEquiv.symm i)
  invFun s := (fun i => s (finSumFinEquiv (.inl i)), fun i => s (finSumFinEquiv (.inr i)))
  left_inv z := by
    apply Prod.ext <;> funext i <;> simp
  right_inv s := by
    funext i
    obtain ⟨j,rfl⟩ := finSumFinEquiv.surjective i
    cases j <;> simp

@[simp] theorem costCubeJoin_inl (P V : ℕ) (z : ClippingCube P × ClippingCube V) (i : Fin P) :
    costCubeJoin P V z (finSumFinEquiv (.inl i)) = z.1 i := by simp [costCubeJoin]

@[simp] theorem costCubeJoin_inr (P V : ℕ) (z : ClippingCube P × ClippingCube V) (i : Fin V) :
    costCubeJoin P V z (finSumFinEquiv (.inr i)) = z.2 i := by simp [costCubeJoin]

@[simp] theorem costCubeJoin_castAdd (P V : ℕ) (z : ClippingCube P × ClippingCube V) (i : Fin P) :
    costCubeJoin P V z (Fin.castAdd V i) = z.1 i := costCubeJoin_inl P V z i

@[simp] theorem costCubeJoin_natAdd (P V : ℕ) (z : ClippingCube P × ClippingCube V) (i : Fin V) :
    costCubeJoin P V z (Fin.natAdd P i) = z.2 i := costCubeJoin_inr P V z i

def joinedSyndromeSupport (P V : ℕ) (T : Finset (Fin V)) : Finset (Fin (P+V)) := by
  classical
  exact Finset.univ.filter fun i => match finSumFinEquiv.symm i with
    | .inl _ => True
    | .inr j => j ∈ T

theorem joinedSyndrome_character (P V : ℕ) (T : Finset (Fin V))
    (z : ClippingCube P × ClippingCube V) :
    walshCharacter (joinedSyndromeSupport P V T) (costCubeJoin P V z) =
      prefixParity P z.1 * walshCharacter T z.2 := by
  classical
  unfold walshCharacter joinedSyndromeSupport
  rw [Finset.prod_filter, ← finSumFinEquiv.prod_comp, Fintype.prod_sum_type]
  simp only [Equiv.symm_apply_apply, costCubeJoin_inl, costCubeJoin_inr, ite_true]
  simp [prefixParity]

open OnlineLowerRelu
namespace FamilyCost

theorem prefix_column_character (k : ℕ)
    (z : ClippingCube (Family.prefixDim k) × ClippingCube (Family.pathDim k))
    (i : Fin (Family.prefixDim k)) :
    walshCharacter (Family.column k (Family.pairIndex k (.inl i)))
      (costCubeJoin _ _ z) = cubeCoordinateSign (z.1 i) := by
  simp [walshCharacter, Family.logicalIndex]

theorem path_column_character (k : ℕ)
    (z : ClippingCube (Family.prefixDim k) × ClippingCube (Family.pathDim k))
    (j : Fin (Family.pathDim k) ⊕ Fin (2*k)) :
    walshCharacter (Family.column k (Family.pairIndex k (.inr j)))
      (costCubeJoin _ _ z) = walshCharacter (pathColumn (2*k) j) z.2 := by
  cases j with
  | inl i => simp [pathColumn, walshCharacter, Family.logicalIndex]
  | inr j =>
    have hj : j.castSucc ≠ j.succ := by intro h; have hh := congrArg Fin.val h; simp at hh
    simp [pathColumn, walshCharacter, hj, Family.logicalIndex]

theorem path_increment (k : ℕ) (j : Fin (Family.pathDim k) ⊕ Fin (2*k)) :
    (Family.increment k (Family.pairIndex k (.inr j)) : ℝ) =
      pathColumnIncrement 4 (@alternatingEdgeIncrement (2*k)) j := by
  cases j with
  | inl i => simp [pathColumnIncrement]
  | inr j =>
    simp only [Family.increment_edge, pathColumnIncrement, alternatingEdgeIncrement]
    split_ifs <;> norm_num

theorem degree_join (k : ℕ) (n₀ : ℝ)
    (z : ClippingCube (Family.prefixDim k) × ClippingCube (Family.pathDim k)) :
    columnDegree n₀ (Family.column k) (fun j => (Family.increment k j : ℝ))
      (costCubeJoin _ _ z) =
      fixedPathDegree (n₀+prefixDegree (Family.prefixDim k) z.1) (2*k) z.2 := by
  unfold fixedPathDegree columnDegree
  rw [← (Family.pairIndex k).sum_comp]
  simp_rw [Fintype.sum_sum_type]
  simp only [Family.increment_prefix, Nat.cast_ofNat, prefix_column_character,
    path_increment, path_column_character]
  unfold prefixDegree
  norm_num
  ring

def scalarCost (k : ℕ) (n₀ : ℝ) (cost : ℝ → ℝ)
    (T : Finset (Fin (Family.pathDim k))) : ℝ :=
  walshCoefficients (fun s => cost (columnDegree n₀ (Family.column k)
    (fun j => (Family.increment k j : ℝ)) s))
      (joinedSyndromeSupport (Family.prefixDim k) (Family.pathDim k) T)

theorem scalarCost_split (k : ℕ) (n₀ : ℝ) (cost : ℝ → ℝ)
    (T : Finset (Fin (Family.pathDim k))) :
    scalarCost k n₀ cost T =
      (∑ s : ClippingCube (Family.prefixDim k), prefixParity (Family.prefixDim k) s *
        walshCoefficients (fun z => cost (fixedPathDegree
          (n₀+prefixDegree (Family.prefixDim k) s) (2*k) z)) T) /
            (2 : ℝ)^(Family.prefixDim k) := by
  classical
  unfold scalarCost walshCoefficients uniformCubeMean
  rw [← (costCubeJoin (Family.prefixDim k) (Family.pathDim k)).sum_comp,
    Fintype.sum_prod_type]
  simp only [degree_join, joinedSyndrome_character]
  simp only [Fintype.card_fun, Fintype.card_bool, Fintype.card_fin, Nat.cast_pow, Nat.cast_ofNat]
  rw [pow_add]
  simp_rw [← mul_div_assoc]
  rw [← Finset.sum_div, div_div, mul_comm ((2 : ℝ)^(2*k+1)) ((2 : ℝ)^Family.prefixDim k)]
  congr 1
  apply Finset.sum_congr rfl
  intro s _
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro z _
  ring

def candidateBlocks (k : ℕ) (endpoint : Bool) (digits : Fin (k-1) → Bool) : List Bool :=
  fixedParityBlocks endpoint (List.ofFn digits)

theorem candidateBlocks_length (k : ℕ) (hk : 1 ≤ k) (endpoint : Bool)
    (digits : Fin (k-1) → Bool) : (candidateBlocks k endpoint digits).length = k := by
  simp only [candidateBlocks, fixedParityBlocks_length, List.length_ofFn]
  omega

def candidatePathSupport (k : ℕ) (hk : 1 ≤ k) (endpoint : Bool)
    (digits : Fin (k-1) → Bool) : Finset (Fin (Family.pathDim k)) :=
  (blockSyndromeSupport (candidateBlocks k endpoint digits) false).map
    (costFinCastEmbedding (by rw [candidateBlocks_length k hk]))

theorem candidatePathCost_eq (k : ℕ) (hk : 1 ≤ k) (n₀ : ℝ) (cost : ℝ → ℝ)
    (endpoint : Bool) (digits : Fin (k-1) → Bool) :
    walshCoefficients (fun s => cost (fixedPathDegree n₀ (2*k) s))
      (candidatePathSupport k hk endpoint digits) =
      fixedCandidateCost n₀ cost endpoint (List.ofFn digits) := by
  symm
  change fixedPathCost n₀ cost (candidateBlocks k endpoint digits) false = _
  unfold fixedPathCost
  rw [walshCoefficients_cast (by rw [candidateBlocks_length k hk])]
  unfold candidatePathSupport
  congr 1
  funext s
  rw [fixedPathDegree_cast n₀ (congrArg (2 * ·) (candidateBlocks_length k hk endpoint digits))]

def candidateCost (k : ℕ) (hk : 1 ≤ k) (n₀ : ℝ) (cost : ℝ → ℝ)
    (endpoint : Bool) (digits : Fin (k-1) → Bool) : ℝ :=
  scalarCost k n₀ cost (candidatePathSupport k hk endpoint digits)

theorem candidateCost_eq_prefixed (k : ℕ) (hk : 1 ≤ k) (n₀ : ℝ) (cost : ℝ → ℝ)
    (endpoint : Bool) (digits : Fin (k-1) → Bool) :
    candidateCost k hk n₀ cost endpoint digits =
      prefixedCandidateCost (Family.prefixDim k) n₀ cost endpoint (List.ofFn digits) := by
  unfold candidateCost
  rw [scalarCost_split]
  unfold prefixedCandidateCost
  congr 1
  apply Finset.sum_congr rfl
  intro s _
  rw [candidatePathCost_eq]

theorem candidateCost_injective (k : ℕ) (hk : 3 ≤ k) (n₀ : ℝ) (hn₀ : 1 < n₀)
    (endpoint : Bool) : Function.Injective
      (candidateCost k (by omega) n₀ OnlineLowerBernstein.gammaCost endpoint) := by
  intro xs ys h
  simp only [candidateCost_eq_prefixed] at h
  exact reluPrefixedBlockCost_injective (Family.prefixDim k) n₀ hn₀ endpoint k hk h

theorem candidateCost_card (k : ℕ) (hk : 3 ≤ k) (n₀ : ℝ) (hn₀ : 1 < n₀)
    (endpoint : Bool) :
    (Finset.univ.image (candidateCost k (by omega) n₀ OnlineLowerBernstein.gammaCost endpoint)).card =
      2^(k-1) := by
  classical
  rw [Finset.card_image_of_injective _ (candidateCost_injective k hk n₀ hn₀ endpoint)]
  simp

end FamilyCost
end NeuralGeneralization.OnlineLower
