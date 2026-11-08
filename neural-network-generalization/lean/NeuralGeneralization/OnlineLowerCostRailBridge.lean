import NeuralGeneralization.OnlineLowerCostColumns
import NeuralGeneralization.OnlineLowerRailSystem

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLower

def negativeBitsCube {m : ℕ} (S : Finset (Fin m)) : ClippingCube m :=
  fun i => !(decide (i ∈ S))

def negativeBitsEquiv (m : ℕ) : Finset (Fin m) ≃ ClippingCube m where
  toFun := negativeBitsCube
  invFun x := Finset.univ.filter (fun i => x i = false)
  left_inv S := by
    ext i
    by_cases h : i ∈ S <;> simp [negativeBitsCube, h]
  right_inv x := by
    funext i
    cases h : x i <;> simp [negativeBitsCube, h]

theorem walshCharacter_negativeBits_symm {m : ℕ} (S T : Finset (Fin m)) :
    walshCharacter S (negativeBitsCube T) = walshCharacter T (negativeBitsCube S) := by
  classical
  have hp (U : Finset (Fin m)) (x : ClippingCube m) :
      walshCharacter U x = ∏ i : Fin m, if i ∈ U then cubeCoordinateSign (x i) else 1 := by
    simp [walshCharacter]
  rw [hp, hp]
  apply Finset.prod_congr rfl
  intro i _
  by_cases hs : i ∈ S <;> by_cases ht : i ∈ T <;>
    simp [negativeBitsCube, cubeCoordinateSign, hs, ht]

theorem walshCharacter_railOrientation {p m : ℕ}
    (column : Fin p → Finset (Fin m)) (S : Finset (Fin m)) (j : Fin p) :
    walshCharacter (column j) (negativeBitsCube S) =
      if OnlineLowerRelu.railOrientation column S j then (-1 : ℝ) else 1 := by
  rw [walshCharacter_negativeBits_symm]
  have he : negativeBitsCube (column j) = OnlineLowerRelu.logicalColumnPoint column j := by
    funext i
    by_cases h : i ∈ column j <;>
      simp [negativeBitsCube, OnlineLowerRelu.logicalColumnPoint, h]
  rw [he]
  exact OnlineLowerRelu.character_orientation column S j

theorem columnDegree_railOrientation {p m : ℕ} (n₀ : ℝ)
    (column : Fin p → Finset (Fin m)) (increment : Fin p → ℝ) (S : Finset (Fin m)) :
    columnDegree n₀ column increment (negativeBitsCube S) =
      n₀ + ∑ j, if OnlineLowerRelu.railOrientation column S j then increment j else 0 := by
  unfold columnDegree
  congr 1
  apply Finset.sum_congr rfl
  intro j _
  rw [walshCharacter_railOrientation]
  cases OnlineLowerRelu.railOrientation column S j <;> norm_num

theorem subset_weight_fourier_eq {m : ℕ} (F : ClippingCube m → ℝ)
    (V : Finset (Fin m)) :
    (∑ S : Finset (Fin m), F (negativeBitsCube S) *
      walshCharacter S (negativeBitsCube V)) / Fintype.card (ClippingCube m) =
        walshCoefficients F V := by
  unfold walshCoefficients uniformCubeMean
  rw [← (negativeBitsEquiv m).sum_comp]
  congr 1
  apply Finset.sum_congr rfl
  intro S _
  change F (negativeBitsCube S) * walshCharacter S (negativeBitsCube V) =
    F (negativeBitsCube S) * walshCharacter V (negativeBitsCube S)
  rw [walshCharacter_negativeBits_symm]

end NeuralGeneralization.OnlineLower
