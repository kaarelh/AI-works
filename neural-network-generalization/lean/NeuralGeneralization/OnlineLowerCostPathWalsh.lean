import NeuralGeneralization.OnlineLowerCostFourier
import NeuralGeneralization.OnlineLowerCostColumns
import Mathlib.Algebra.BigOperators.Fin

/-! # The transfer sum as the repository's actual Walsh coefficient -/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLower

def pathSyndrome : (data : List (Bool × ℝ)) → Bool → Fin (data.length + 1) → Bool
  | [], terminal => fun _ => terminal
  | (v, _) :: rest, terminal => Fin.cons v (pathSyndrome rest terminal)

def pathSyndromeSupport (data : List (Bool × ℝ)) (terminal : Bool) :
    Finset (Fin (data.length + 1)) :=
  Finset.univ.filter fun i => pathSyndrome data terminal i

/-- Product over every singleton loop and adjacent-pair edge of the path. -/
def pathColumnProduct (a : ℝ) (data : List (Bool × ℝ))
    (spins : Fin (data.length + 1) → Bool) : ℝ :=
  (∏ i, (1 + a * pathSpin (spins i))) *
    ∏ j : Fin data.length,
      (1 + (data.get j).2 * pathSpin (spins j.castSucc) * pathSpin (spins j.succ))

theorem pathTailWeight_eq_product (a : ℝ) (data : List (Bool × ℝ))
    (terminal : Bool) (spins : Fin (data.length + 1) → Bool) :
    pathVertexWeight a data terminal spins =
      (∏ i, pathWalshBit (pathSyndrome data terminal i) (spins i)) *
        pathColumnProduct a data spins := by
  classical
  induction data with
  | nil => simp [pathVertexWeight, pathTailWeight, pathSyndrome, pathColumnProduct]
  | cons ve rest ih =>
    obtain ⟨v, e⟩ := ve
    have ih' := ih (fun i => spins i.succ)
    change pathWalshBit v (spins 0) * (1 + a * pathSpin (spins 0)) *
        (1 + e * pathSpin (spins 0) * pathSpin (spins (Fin.succ 0))) *
        pathVertexWeight a rest terminal (fun i => spins i.succ) = _
    rw [ih']
    simp only [pathColumnProduct, pathSyndrome, List.length_cons, Fin.prod_univ_succ,
      Fin.cons_zero, Fin.cons_succ, List.get_eq_getElem, List.getElem_cons_zero,
      List.getElem_cons_succ, Fin.val_zero, Fin.val_succ, Fin.castSucc_zero,
      Fin.castSucc_succ]
    ring

theorem path_walsh_character (data : List (Bool × ℝ)) (terminal : Bool)
    (spins : Fin (data.length + 1) → Bool) :
    walshCharacter (pathSyndromeSupport data terminal) (fun i => !(spins i)) =
      ∏ i, pathWalshBit (pathSyndrome data terminal i) (spins i) := by
  classical
  simp only [walshCharacter, pathSyndromeSupport, Finset.prod_filter]
  apply Finset.prod_congr rfl
  intro i _
  cases hv : pathSyndrome data terminal i <;> cases hs : spins i <;>
    norm_num [pathWalshBit, pathSpin, cubeCoordinateSign, hv, hs]

theorem pathVertexWeight_eq_walsh (a : ℝ) (data : List (Bool × ℝ))
    (terminal : Bool) (spins : Fin (data.length + 1) → Bool) :
    pathVertexWeight a data terminal spins =
      walshCharacter (pathSyndromeSupport data terminal) (fun i => !(spins i)) *
        pathColumnProduct a data spins := by
  rw [path_walsh_character, pathTailWeight_eq_product]

def pathSpinNegation (n : ℕ) : ClippingCube n ≃ ClippingCube n where
  toFun s i := !(s i)
  invFun s i := !(s i)
  left_inv s := by funext i; simp
  right_inv s := by funext i; simp

theorem pathWalshSum_eq_walshCoefficient (a : ℝ) (data : List (Bool × ℝ))
    (terminal : Bool) :
    pathWalshSum a data terminal =
      walshCoefficients (fun s => pathColumnProduct a data (fun i => !(s i)))
        (pathSyndromeSupport data terminal) := by
  classical
  rw [pathWalshSum_eq_vertex_mean]
  have hsum := (pathSpinNegation (data.length + 1)).sum_comp
    (fun s => pathVertexWeight a data terminal s)
  simp only [pathVertexWeight_eq_walsh, pathSpinNegation, Equiv.coe_fn_mk,
    Bool.not_not] at hsum
  unfold walshCoefficients uniformCubeMean
  simp only [pathVertexWeight_eq_walsh]
  rw [← hsum]
  congr 1
  · apply Finset.sum_congr rfl
    intro s _
    ring
  · simp [ClippingCube]

end NeuralGeneralization.OnlineLower
