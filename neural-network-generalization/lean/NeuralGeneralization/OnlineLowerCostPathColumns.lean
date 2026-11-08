import NeuralGeneralization.OnlineLowerCostPathWalsh

/-! # Literal singleton/adjacent-pair columns and their Laplace transform -/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLower

def pathColumn (n : ℕ) : (Fin (n + 1) ⊕ Fin n) → Finset (Fin (n + 1))
  | .inl i => {i}
  | .inr j => {j.castSucc, j.succ}

def pathColumnIncrement {n : ℕ} (loopIncrement : ℝ) (edgeIncrement : Fin n → ℝ) :
    (Fin (n + 1) ⊕ Fin n) → ℝ
  | .inl _ => loopIncrement
  | .inr j => edgeIncrement j

theorem pathColumn_card_le_two (n : ℕ) (j : Fin (n+1) ⊕ Fin n) :
    (pathColumn n j).card ≤ 2 := by
  cases j with
  | inl i => simp [pathColumn]
  | inr j =>
    unfold pathColumn
    exact le_trans (Finset.card_insert_le _ _) (by simp)

theorem walshCharacter_pathColumn_loop (n : ℕ) (i : Fin (n + 1)) (s : ClippingCube (n+1)) :
    walshCharacter (pathColumn n (.inl i)) s = cubeCoordinateSign (s i) := by
  simp [pathColumn, walshCharacter]

theorem walshCharacter_pathColumn_edge (n : ℕ) (j : Fin n) (s : ClippingCube (n+1)) :
    walshCharacter (pathColumn n (.inr j)) s =
      cubeCoordinateSign (s j.castSucc) * cubeCoordinateSign (s j.succ) := by
  have hj : j.castSucc ≠ j.succ := by intro h; have := congrArg Fin.val h; simp at this
  simp [pathColumn, walshCharacter, hj]

theorem pathSpin_not (b : Bool) : pathSpin (!b) = cubeCoordinateSign b := by
  cases b <;> rfl

theorem pathColumnProduct_eq (data : List (Bool × ℝ)) (a : ℝ) (t loopIncrement : ℝ)
    (edgeIncrement : Fin data.length → ℝ)
    (ha : a = columnLaplaceFugacity loopIncrement t)
    (he : ∀ j, (data.get j).2 = columnLaplaceFugacity (edgeIncrement j) t)
    (s : ClippingCube (data.length + 1)) :
    pathColumnProduct a data (fun i => !(s i)) =
      ∏ j : Fin (data.length + 1) ⊕ Fin data.length,
        (1 + columnLaplaceFugacity (pathColumnIncrement loopIncrement edgeIncrement j) t *
          walshCharacter (pathColumn data.length j) s) := by
  rw [Fintype.prod_sum_type]
  simp only [pathColumnIncrement, walshCharacter_pathColumn_loop,
    walshCharacter_pathColumn_edge, pathColumnProduct, pathSpin_not, ha, he]
  congr 1
  apply Finset.prod_congr rfl
  intro j _
  ring

def pathLaplacePrefactor (n₀ t loopIncrement : ℝ) {n : ℕ} (edgeIncrement : Fin n → ℝ) : ℝ :=
  Real.exp (-n₀ * t) * ∏ j : Fin (n+1) ⊕ Fin n,
    columnLaplaceAlpha (pathColumnIncrement loopIncrement edgeIncrement j) t

theorem pathLaplacePrefactor_pos (n₀ t loopIncrement : ℝ) {n : ℕ}
    (edgeIncrement : Fin n → ℝ) : 0 < pathLaplacePrefactor n₀ t loopIncrement edgeIncrement := by
  apply mul_pos (Real.exp_pos _)
  exact Finset.prod_pos fun _ _ => columnLaplaceAlpha_pos _ _

theorem path_exp_degree_coefficient (n₀ t loopIncrement a : ℝ)
    (data : List (Bool × ℝ)) (terminal : Bool) (edgeIncrement : Fin data.length → ℝ)
    (ha : a = columnLaplaceFugacity loopIncrement t)
    (he : ∀ j, (data.get j).2 = columnLaplaceFugacity (edgeIncrement j) t) :
    walshCoefficients
      (fun s => Real.exp (-columnDegree n₀ (pathColumn data.length)
        (pathColumnIncrement loopIncrement edgeIncrement) s * t))
      (pathSyndromeSupport data terminal) =
        pathLaplacePrefactor n₀ t loopIncrement edgeIncrement * pathWalshSum a data terminal := by
  rw [pathWalshSum_eq_walshCoefficient]
  have hpoint (s : ClippingCube (data.length+1)) :
      Real.exp (-columnDegree n₀ (pathColumn data.length)
        (pathColumnIncrement loopIncrement edgeIncrement) s * t) =
      pathLaplacePrefactor n₀ t loopIncrement edgeIncrement *
        pathColumnProduct a data (fun i => !(s i)) := by
    rw [exp_columnDegree, pathColumnProduct_eq data a t loopIncrement edgeIncrement ha he s]
    rfl
  simp only [walshCoefficients, uniformCubeMean, hpoint]
  rw [← mul_div_assoc, Finset.mul_sum]
  congr 1
  apply Finset.sum_congr rfl
  intro s _
  ring

end NeuralGeneralization.OnlineLower
