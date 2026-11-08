import NeuralGeneralization.OnlineLowerTanhCodePartial
import NeuralGeneralization.OnlineLowerOrientation
import Mathlib.Data.Finset.Card
import Mathlib.Tactic.GCongr

/-!
# Local high-order vanishing of competing tanh coefficients

This version uses the slightly looser but elementary estimate `(D τ)^k`
instead of `(4 sqrt(D) τ/π)^k`. At τ≤D⁻² it has the same superpolynomial
vanishing needed by the exact weighted-code proof, without an AM–GM or
complex-analysis dependency.
-/

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel

theorem tanh_walshCoefficient_partial_uniform {d : ℕ}
    (A B : Finset (Fin d)) (hAB : A ⊆ B) (u : Fin d → ℝ) (b τ : ℝ)
    (hτ : 0 ≤ τ) (hcoord : ∀ i ∈ A, |u i| ≤ τ) :
    |walshCoefficients (fun x => Real.tanh (b+incomingLinear u x)) B| ≤
      ((A.card : ℝ)*τ)^A.card := by
  have hprod : (∏ i ∈ A, |u i|) ≤ τ^A.card := by
    calc
      _ ≤ ∏ _i ∈ A, τ := Finset.prod_le_prod (fun _ _ => abs_nonneg _) hcoord
      _ = _ := by simp
  have hfac : (A.card.factorial : ℝ) ≤ (A.card : ℝ)^A.card := by
    exact_mod_cast Nat.factorial_le_pow A.card
  calc
    _ ≤ (A.card.factorial : ℝ)*∏ i ∈ A, |u i| :=
      tanh_walshCoefficient_partial_bound A B hAB u b
    _ ≤ (A.card : ℝ)^A.card*τ^A.card :=
      mul_le_mul hfac hprod (Finset.prod_nonneg fun _ _ => abs_nonneg _) (by positivity)
    _ = _ := (mul_pow _ _ _).symm

/-- A chosen number of inactive coordinates suffices; all remaining incoming
weights and the bias are unrestricted. -/
theorem tanh_walshCoefficient_inactive_bound {d : ℕ}
    (A B : Finset (Fin d)) (u : Fin d → ℝ) (b τ D : ℝ) (k : ℕ)
    (hk : k ≤ (B\A).card) (hD : (k : ℝ) ≤ D) (hτ : 0 ≤ τ)
    (henergy : (∑ i ∈ Aᶜ, u i^2) ≤ τ^2) :
    |walshCoefficients (fun x => Real.tanh (b+incomingLinear u x)) B| ≤ (D*τ)^k := by
  classical
  obtain ⟨J,hJ,hcard⟩ := Finset.exists_subset_card_eq hk
  have hJB : J ⊆ B := fun i hi => (Finset.mem_sdiff.mp (hJ hi)).1
  have hcoord (i : Fin d) (hi : i ∈ J) : |u i| ≤ τ := by
    have hiA : i ∈ Aᶜ := Finset.mem_compl.mpr (Finset.mem_sdiff.mp (hJ hi)).2
    have hs : u i^2 ≤ ∑ j ∈ Aᶜ, u j^2 :=
      Finset.single_le_sum (fun _ _ => sq_nonneg _) hiA
    have hsq := hs.trans henergy
    nlinarith [sq_abs (u i),abs_nonneg (u i)]
  have h := tanh_walshCoefficient_partial_uniform J B hJB u b τ hτ hcoord
  rw [hcard] at h
  apply h.trans
  exact pow_le_pow_left₀ (mul_nonneg (Nat.cast_nonneg k) hτ)
    (mul_le_mul_of_nonneg_right hD hτ) k

/-- Extract two powers of the inactive norm before summing orientations. -/
theorem power_local_quadratic (D τ ρ : ℝ) (k : ℕ)
    (hD : 0 ≤ D) (hτ : 0 ≤ τ) (hτρ : τ ≤ ρ) (hk : 2 ≤ k) :
    (D*τ)^k ≤ D^k * ρ^(k-2) * τ^2 := by
  have he : k = (k-2)+2 := (Nat.sub_add_cancel hk).symm
  rw [mul_pow]
  calc
    D^k*τ^k = D^k*(τ^(k-2)*τ^2) := by congr 1; rw [← pow_add, ← he]
    _ ≤ D^k*(ρ^(k-2)*τ^2) := by
      gcongr
    _ = _ := by ring

/-- The binomial sum of local powers is at most twice its first-order
contribution when the base is small. -/
theorem local_switch_sum_bound (x : ℝ) (p : ℕ) (hx : 0 ≤ x)
    (hsmall : (p : ℝ)*x ≤ 1/2) :
    (1+x)^p-1 ≤ 2*(p : ℝ)*x :=
  OnlineLower.all_switch_counts_bound x hx p hsmall

end NeuralGeneralization.OnlineLowerTanh
