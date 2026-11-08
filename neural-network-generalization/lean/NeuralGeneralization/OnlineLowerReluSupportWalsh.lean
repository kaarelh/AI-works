import NeuralGeneralization.OnlineLowerReluBalancedWalsh
import NeuralGeneralization.OnlineLowerReluUniformMarginal

/-! # Balanced ReLU atoms on arbitrary supports in the ambient Boolean cube -/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLowerRelu

def supportIncoming {d : ℕ} (A : Finset (Fin d)) : Fin (d + 1) → ℝ :=
  Fin.cases 0 (fun i => if i ∈ A then 1 else 0)

theorem supportIncoming_score {d : ℕ} (A : Finset (Fin d)) (x : ClippingCube d) :
    OnlineLower.atomOutput (fun t => max t 0) (supportIncoming A) x =
      max (∑ i ∈ A, cubeCoordinateSign (x i)) 0 := by
  unfold OnlineLower.atomOutput
  rw [Fin.sum_univ_succ]
  simp only [supportIncoming, ConcreteModel.inputVector, Fin.cases_zero, Fin.cases_succ,
    zero_mul, zero_add]
  change max (∑ i, (if i ∈ A then (1 : ℝ) else 0) * cubeCoordinateSign (x i)) 0 = _
  simp [ite_mul]

theorem supportIncoming_cost {d : ℕ} (A : Finset (Fin d)) :
    OnlineLower.incomingAtomCost (supportIncoming A) = (d : ℝ) * A.card := by
  unfold OnlineLower.incomingAtomCost
  rw [Fin.sum_univ_succ]
  simp [supportIncoming]

theorem support_relu_walsh_eq_balanced {d : ℕ} (A : Finset (Fin d)) :
    walshCoefficients (OnlineLower.atomOutput (fun t => max t 0) (supportIncoming A)) A =
      walshCoefficients
        (OnlineLower.atomOutput (fun t => max t 0) (balancedIncoming A.card)) Finset.univ := by
  classical
  let F : (↥A → Bool) → ℝ := fun y =>
    max (∑ i : A, cubeCoordinateSign (y i)) 0 * ∏ i : A, cubeCoordinateSign (y i)
  have hpoint (x : ClippingCube d) :
      OnlineLower.atomOutput (fun t => max t 0) (supportIncoming A) x * walshCharacter A x =
        F (fun i : A => x i) := by
    rw [supportIncoming_score]
    dsimp [F, walshCharacter]
    rw [Finset.sum_attach A (fun i => cubeCoordinateSign (x i)),
      Finset.prod_attach A (fun i => cubeCoordinateSign (x i))]
  have hfirst : walshCoefficients
      (OnlineLower.atomOutput (fun t => max t 0) (supportIncoming A)) A = finiteAverage F := by
    unfold walshCoefficients uniformCubeMean
    simp_rw [hpoint]
    exact finiteAverage_restrict A F
  rw [hfirst]
  let e : ↥A ≃ Fin A.card := Fintype.equivOfCardEq (by simp)
  let E : (Fin A.card → Bool) ≃ (↥A → Bool) := Equiv.arrowCongr e.symm (Equiv.refl Bool)
  have he := finiteAverage_equiv E F
  have hepoint (x : Fin A.card → Bool) : F (E x) =
      max (∑ i : Fin A.card, cubeCoordinateSign (x i)) 0 *
        ∏ i : Fin A.card, cubeCoordinateSign (x i) := by
    change max (∑ i : A, cubeCoordinateSign (x (e i))) 0 *
      (∏ i : A, cubeCoordinateSign (x (e i))) = _
    rw [Equiv.sum_comp e (fun i => cubeCoordinateSign (x i)),
      Equiv.prod_comp e (fun i => cubeCoordinateSign (x i))]
  rw [← he]
  simp_rw [hepoint]
  unfold walshCoefficients uniformCubeMean finiteAverage
  simp_rw [balancedIncoming_score]
  rfl

/-- Exact coefficient at an arbitrary even support, with all unused
incoming coordinates identically zero and the actual ambient prior cost. -/
theorem support_relu_walsh_exact {d : ℕ} (A : Finset (Fin d)) (r : ℕ)
    (hcard : A.card = 2 * r + 2) :
    walshCoefficients (OnlineLower.atomOutput (fun t => max t 0) (supportIncoming A)) A =
      (-1 : ℝ) ^ r * evenReluKappa r := by
  rw [support_relu_walsh_eq_balanced, hcard]
  exact balanced_relu_walsh_exact r

theorem support_relu_walsh_abs {d : ℕ} (A : Finset (Fin d)) (r : ℕ)
    (hcard : A.card = 2 * r + 2) :
    |walshCoefficients (OnlineLower.atomOutput (fun t => max t 0) (supportIncoming A)) A| =
      evenReluKappa r := by
  rw [support_relu_walsh_eq_balanced, hcard]
  exact balanced_relu_walsh_abs r

end NeuralGeneralization.OnlineLowerRelu
