import NeuralGeneralization.OnlineLowerCarrierRails
import NeuralGeneralization.OnlineLowerTanhCodeVanishing
import Mathlib.Algebra.BigOperators.Ring.Finset

/-! # Exact summation of Boolean rail orientations by changed coordinates -/

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh

def toggleOrientation {p : ℕ} (s : Fin p → Bool) (J : Finset (Fin p)) : Fin p → Bool :=
  fun i => if i ∈ J then !(s i) else s i

@[simp] theorem changedRails_toggle {p : ℕ} (s : Fin p → Bool) (J : Finset (Fin p)) :
    changedRails s (toggleOrientation s J) = J := by
  classical
  ext i
  simp only [changedRails, Finset.mem_filter, Finset.mem_univ, true_and,toggleOrientation]
  by_cases hi : i ∈ J <;> cases hs : s i <;> simp [hi,hs]

@[simp] theorem toggle_changedRails {p : ℕ} (s t : Fin p → Bool) :
    toggleOrientation s (changedRails s t) = t := by
  classical
  funext i
  simp only [toggleOrientation,changedRails,Finset.mem_filter,Finset.mem_univ,true_and]
  cases hs : s i <;> cases ht : t i <;> simp [hs,ht]

def orientationSwitchEquiv {p : ℕ} (s : Fin p → Bool) : (Fin p → Bool) ≃ Finset (Fin p) where
  toFun := changedRails s
  invFun := toggleOrientation s
  left_inv := toggle_changedRails s
  right_inv := changedRails_toggle s

@[simp] theorem changedRails_self {p : ℕ} (s : Fin p → Bool) : changedRails s s = ∅ := by
  simp [changedRails]

theorem changedRails_nonempty {p : ℕ} (s t : Fin p → Bool) (hst : t ≠ s) :
    (changedRails s t).Nonempty := by
  by_contra he
  have he' : changedRails s t = changedRails s s := by
    rw [changedRails_self]
    exact Finset.not_nonempty_iff_eq_empty.mp he
  exact hst ((orientationSwitchEquiv s).injective he')

theorem changedRails_card_le {p : ℕ} (s t : Fin p → Bool) : (changedRails s t).card ≤ p := by
  exact (Finset.card_le_card (Finset.subset_univ _)).trans_eq (Finset.card_univ.trans (Fintype.card_fin p))

/-- Exact generating function, before applying any analytic estimate. -/
theorem sum_orientation_switch_powers {p : ℕ} (s : Fin p → Bool) (x : ℝ) :
    (∑ t : Fin p → Bool, x^(changedRails s t).card) = (1+x)^p := by
  have he := (orientationSwitchEquiv s).sum_comp (fun J => x^J.card)
  change (∑ t : Fin p → Bool, x^(changedRails s t).card) = ∑ J : Finset (Fin p), x^J.card at he
  rw [he]
  have h := Fintype.prod_add (fun _ : Fin p => x) (fun _ => (1:ℝ))
  simpa [add_comm] using h.symm

theorem sum_other_orientation_switch_powers {p : ℕ} (s : Fin p → Bool) (x : ℝ) :
    (∑ t ∈ (Finset.univ : Finset (Fin p → Bool)).erase s, x^(changedRails s t).card) =
      (1+x)^p-1 := by
  have h := Finset.add_sum_erase (Finset.univ : Finset (Fin p → Bool))
    (fun t => x^(changedRails s t).card) (Finset.mem_univ s)
  rw [sum_orientation_switch_powers,changedRails_self,Finset.card_empty,pow_zero] at h
  linarith

/-- A retained family costs no more than the full family, and the full sum
has the exact binomial generating function. -/
theorem retained_switch_sum_bound {p : ℕ} (s : Fin p → Bool)
    (J : Finset (Fin p → Bool)) (mass : (Fin p → Bool) → ℝ) (K x : ℝ)
    (hK : 0 ≤ K) (hx : 0 ≤ x)
    (hpoint : ∀ t ∈ J.erase s, mass t ≤ K*x^(changedRails s t).card) :
    (∑ t ∈ J.erase s, mass t) ≤ K*((1+x)^p-1) := by
  calc
    _ ≤ ∑ t ∈ J.erase s, K*x^(changedRails s t).card := Finset.sum_le_sum hpoint
    _ ≤ ∑ t ∈ (Finset.univ : Finset (Fin p → Bool)).erase s, K*x^(changedRails s t).card := by
      apply Finset.sum_le_sum_of_subset_of_nonneg
        (Finset.erase_subset_erase s (Finset.subset_univ J))
      intro t _ _
      exact mul_nonneg hK (pow_nonneg hx _)
    _ = K*((1+x)^p-1) := by rw [← Finset.mul_sum,sum_other_orientation_switch_powers]

end NeuralGeneralization.OnlineLowerTanh
