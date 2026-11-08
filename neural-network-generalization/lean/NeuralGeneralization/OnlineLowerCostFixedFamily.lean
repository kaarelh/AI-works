import NeuralGeneralization.OnlineLowerCostPathExponential
import NeuralGeneralization.OnlineLowerCostFamily

noncomputable section
open MeasureTheory
open scoped BigOperators

namespace NeuralGeneralization.OnlineLower

/-- A canonical syndrome on `2 * length + 1` vertices, independent of time. -/
def blockSyndrome : (vs : List Bool) → Bool → Fin (2 * vs.length + 1) → Bool
  | [], terminal => fun _ => terminal
  | v :: vs, terminal =>
      fun i => (Fin.cons v (Fin.cons true (blockSyndrome vs terminal)) :
        Fin ((2 * vs.length + 1) + 1 + 1) → Bool)
        (Fin.cast (show 2 * (v :: vs).length + 1 = (2 * vs.length + 1) + 1 + 1 by
          simp; omega) i)

def blockSyndromeSupport (vs : List Bool) (terminal : Bool) :
    Finset (Fin (2 * vs.length + 1)) := Finset.univ.filter (fun i => blockSyndrome vs terminal i)

theorem pathSyndrome_blockData (x : ℝ) (vs : List Bool) (terminal : Bool)
    (i : Fin ((pathBlockData x vs).length + 1)) :
    pathSyndrome (pathBlockData x vs) terminal i =
      blockSyndrome vs terminal (Fin.cast (by rw [pathBlockData_length]) i) := by
  induction vs with
  | nil => simp [pathBlockData, pathSyndrome, blockSyndrome]
  | cons v vs ih =>
    simp only [pathBlockData, pathSyndrome, blockSyndrome]
    refine Fin.cases ?_ (fun j => ?_) i
    · change v = v
      rfl
    · refine Fin.cases ?_ (fun k => ?_) j
      · change true = true
        rfl
      · exact ih k

def costFinCastEmbedding {n m : ℕ} (h : n = m) : Fin n ↪ Fin m where
  toFun := Fin.cast h
  inj' := by intro i j hij; exact Fin.ext (congrArg (fun k : Fin m => k.val) hij)

theorem walshCoefficients_cast {n m : ℕ} (h : n = m)
    (F : ClippingCube n → ℝ) (S : Finset (Fin n)) :
    walshCoefficients F S =
      walshCoefficients (fun s : ClippingCube m => F (fun i => s (Fin.cast h i)))
        (S.map (costFinCastEmbedding h)) := by
  subst m
  simp [costFinCastEmbedding]

theorem pathSyndromeSupport_blockData (x : ℝ) (vs : List Bool) (terminal : Bool) :
    (pathSyndromeSupport (pathBlockData x vs) terminal).map
      (costFinCastEmbedding (by rw [pathBlockData_length])) =
        blockSyndromeSupport vs terminal := by
  classical
  ext j
  simp only [Finset.mem_map, pathSyndromeSupport, blockSyndromeSupport,
    Finset.mem_filter, Finset.mem_univ, true_and]
  constructor
  · rintro ⟨i, hi, rfl⟩
    simpa only [costFinCastEmbedding, Function.Embedding.coeFn_mk,
      ← pathSyndrome_blockData] using hi
  · intro hj
    let h : (pathBlockData x vs).length + 1 = 2 * vs.length + 1 := by
      rw [pathBlockData_length]
    refine ⟨Fin.cast h.symm j, ?_, ?_⟩
    · rw [pathSyndrome_blockData]
      simpa using hj
    · apply Fin.ext
      rfl

def fixedPathDegree (n₀ : ℝ) (n : ℕ) (s : ClippingCube (n+1)) : ℝ :=
  columnDegree n₀ (pathColumn n) (pathColumnIncrement 4 alternatingEdgeIncrement) s

theorem fixedPathDegree_cast (n₀ : ℝ) {n m : ℕ} (h : n = m)
    (s : ClippingCube (m+1)) :
    fixedPathDegree n₀ n (fun i => s (Fin.cast (congrArg (· + 1) h) i)) =
      fixedPathDegree n₀ m s := by
  subst m
  rfl

def fixedPathCost (n₀ : ℝ) (cost : ℝ → ℝ) (vs : List Bool) (terminal : Bool) : ℝ :=
  walshCoefficients (fun s => cost (fixedPathDegree n₀ (2 * vs.length) s))
    (blockSyndromeSupport vs terminal)

theorem pathCost_transport (n₀ : ℝ) (cost : ℝ → ℝ) (x : ℝ)
    (vs : List Bool) (terminal : Bool) :
    walshCoefficients (fun s => cost (fixedPathDegree n₀ (pathBlockData x vs).length s))
      (pathSyndromeSupport (pathBlockData x vs) terminal) =
        fixedPathCost n₀ cost vs terminal := by
  rw [walshCoefficients_cast (by rw [pathBlockData_length]),
    pathSyndromeSupport_blockData]
  unfold fixedPathCost
  congr 1
  funext s
  rw [fixedPathDegree_cast n₀ (pathBlockData_length x vs)]

theorem fixedPathCost_exp (n₀ t : ℝ) (vs : List Bool) (terminal : Bool) :
    fixedPathCost n₀ (fun n => Real.exp (-n*t)) vs terminal =
      pathLaplacePrefactor n₀ t 4 (@alternatingEdgeIncrement (2 * vs.length)) *
        pathWalshSum (pathLoop (Real.exp (-2*t)))
          (pathBlockData (Real.exp (-2*t)) vs) terminal := by
  have h := path_exp_fourier_explicit n₀ t vs terminal
  dsimp only at h
  change walshCoefficients
    (fun s => (fun n => Real.exp (-n*t))
      (fixedPathDegree n₀ (pathBlockData (Real.exp (-2*t)) vs).length s)) _ = _ at h
  rw [pathCost_transport n₀ (fun n => Real.exp (-n*t)) (Real.exp (-2*t)) vs terminal] at h
  have hp := congrArg (fun n => pathLaplacePrefactor n₀ t 4 (@alternatingEdgeIncrement n))
    (pathBlockData_length (Real.exp (-2*t)) vs)
  rw [hp] at h
  exact h

def fixedCandidateCost (n₀ : ℝ) (cost : ℝ → ℝ) (endpoint : Bool)
    (digits : List Bool) : ℝ :=
  fixedPathCost n₀ cost (fixedParityBlocks endpoint digits) false

theorem fixedCandidateCost_exp (n₀ t : ℝ) (endpoint : Bool) (digits : List Bool) :
    fixedCandidateCost n₀ (fun n => Real.exp (-n*t)) endpoint digits =
      pathLaplacePrefactor n₀ t 4 (@alternatingEdgeIncrement (2 * (digits.length + 1))) *
        candidatePathEnumerator (Real.exp (-2*t)) endpoint digits := by
  unfold fixedCandidateCost
  rw [fixedPathCost_exp, fixedParityBlocks_length, pathWalshSum_eq_edgeSum]
  rfl

theorem blockSyndromeSupport_card_ge_three (vs : List Bool) (terminal : Bool)
    (hlen : 3 ≤ vs.length) : 3 ≤ (blockSyndromeSupport vs terminal).card := by
  classical
  cases vs with
  | nil => simp at hlen
  | cons v vs =>
    cases vs with
    | nil => simp at hlen
    | cons w vs =>
      cases vs with
      | nil => simp at hlen
      | cons z tail =>
        let i : Fin (2 * (v :: w :: z :: tail).length + 1) := ⟨1, by simp⟩
        let j : Fin (2 * (v :: w :: z :: tail).length + 1) := ⟨3, by simp; omega⟩
        let k : Fin (2 * (v :: w :: z :: tail).length + 1) := ⟨5, by simp; omega⟩
        have hi : i ∈ blockSyndromeSupport (v :: w :: z :: tail) terminal := by
          simp only [blockSyndromeSupport, Finset.mem_filter, Finset.mem_univ, true_and]
          rfl
        have hj : j ∈ blockSyndromeSupport (v :: w :: z :: tail) terminal := by
          simp only [blockSyndromeSupport, Finset.mem_filter, Finset.mem_univ, true_and]
          rfl
        have hk : k ∈ blockSyndromeSupport (v :: w :: z :: tail) terminal := by
          simp only [blockSyndromeSupport, Finset.mem_filter, Finset.mem_univ, true_and]
          rfl
        have hsub : ({i,j,k} : Finset _) ⊆ blockSyndromeSupport (v :: w :: z :: tail) terminal := by
          intro l hl
          simp only [Finset.mem_insert, Finset.mem_singleton] at hl
          rcases hl with rfl | rfl | rfl <;> assumption
        have hc : ({i,j,k} : Finset _).card = 3 := by norm_num [i,j,k]
        rw [← hc]
        exact Finset.card_le_card hsub

end NeuralGeneralization.OnlineLower
