import NeuralGeneralization.OnlineLowerReluRandomizedMinimum
import Mathlib.Data.Fintype.BigOperators
import Mathlib.Logic.Equiv.Prod

/-! # Exact uniform restriction to a finite set of Boolean coordinates -/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLowerRelu

theorem finiteAverage_equiv {Ω Ω' : Type*} [Fintype Ω] [Fintype Ω']
    (e : Ω ≃ Ω') (f : Ω' → ℝ) :
    finiteAverage (fun ω => f (e ω)) = finiteAverage f := by
  unfold finiteAverage
  rw [Equiv.sum_comp e f, Fintype.card_congr e]

theorem finiteAverage_restrict {α : Type*} [Fintype α] [DecidableEq α]
    (A : Finset α) (f : (↥A → Bool) → ℝ) :
    finiteAverage (fun x : α → Bool => f (fun i : A => x i)) = finiteAverage f := by
  classical
  let e := Equiv.piEquivPiSubtypeProd (fun i : α => i ∈ A) (fun _ => Bool)
  have hsum := Equiv.sum_comp e (fun p => f p.1)
  have hcard := Fintype.card_congr e
  change (∑ x : α → Bool, f (fun i : A => x i)) =
    ∑ p : (↥A → Bool) × ({i : α // i ∉ A} → Bool), f p.1 at hsum
  change Fintype.card (α → Bool) =
    Fintype.card ((↥A → Bool) × ({i : α // i ∉ A} → Bool)) at hcard
  have hB : (Fintype.card ({i : α // i ∉ A} → Bool) : ℝ) ≠ 0 := by
    exact_mod_cast Fintype.card_ne_zero
  unfold finiteAverage
  rw [hsum, hcard, Fintype.card_prod, Nat.cast_mul]
  simp only [Fintype.sum_prod_type, Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  rw [← Finset.mul_sum]
  field_simp

end NeuralGeneralization.OnlineLowerRelu
