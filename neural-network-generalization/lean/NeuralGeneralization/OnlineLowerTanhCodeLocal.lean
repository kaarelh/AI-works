import NeuralGeneralization.OnlineLowerTanhCodeSwitches
import Mathlib.Tactic.FieldSimp

/-! # Full finite local off-orientation estimate for actual tanh neurons -/

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel

theorem weighted_power_quadratic (D τ ρ W : ℝ) (k : ℕ)
    (hD : 0 ≤ D) (hτ : 0 ≤ τ) (hτρ : τ ≤ ρ) (hρ : 0 < ρ)
    (hW : 0 ≤ W) (hk : 2 ≤ k) :
    W*(D*τ)^k ≤ (W*τ^2/ρ^2)*(D*ρ)^k := by
  have h := power_local_quadratic D τ ρ k hD hτ hτρ hk
  have hmul := mul_le_mul_of_nonneg_left h hW
  have he : W*(D^k*ρ^(k-2)*τ^2) = (W*τ^2/ρ^2)*(D*ρ)^k := by
    rw [mul_pow]
    have heρ : ρ^k = ρ^(k-2)*ρ^2 := by
      rw [← pow_add, Nat.sub_add_cancel hk]
    rw [heρ]
    field_simp
    <;> ring
  exact hmul.trans_eq he

/-- Literal weighted Walsh mass of all retained competing orientations.
Only the inactive energy relative to one support is small; the bias and all
selected incoming weights are arbitrary. -/
theorem tanh_local_offmass {p R : ℕ} (size : Fin p → Bool → ℕ)
    (hR : 2 ≤ R) (hsize : ∀ i b, R ≤ size i b)
    (s : Fin p → Bool) (J : Finset (Fin p → Bool))
    (weight : (Fin p → Bool) → ℝ) (W : ℝ)
    (hw : ∀ t ∈ J, 0 ≤ weight t) (hW : ∀ t ∈ J, weight t ≤ W) (hW0 : 0 ≤ W)
    (u : Fin (carrierDimension size) → ℝ) (b τ ρ : ℝ)
    (hτ : 0 ≤ τ) (hτρ : τ ≤ ρ) (hρ : 0 < ρ)
    (henergy : (∑ i ∈ (carrierTransversal size s)ᶜ, u i^2) ≤ τ^2) :
    (∑ t ∈ J.erase s, weight t * |walshCoefficients
      (fun x => Real.tanh (b+incomingLinear u x)) (carrierTransversal size t)|) ≤
      (W*τ^2/ρ^2)*((1+(((p*R : ℕ) : ℝ)*ρ)^R)^p-1) := by
  let D : ℝ := (p*R : ℕ)
  let x := (D*ρ)^R
  apply retained_switch_sum_bound s J _ (W*τ^2/ρ^2) x (by positivity) (by dsimp [x,D]; positivity)
  intro t ht
  have htJ : t ∈ J := Finset.mem_of_mem_erase ht
  have hts : t ≠ s := (Finset.mem_erase.mp ht).1
  let k := (changedRails s t).card * R
  have hk : 2 ≤ k := by
    have hc : 1 ≤ (changedRails s t).card := (changedRails_nonempty s t hts).card_pos
    dsimp [k]
    exact hR.trans (by nlinarith)
  have hki : k ≤ (carrierTransversal size t\carrierTransversal size s).card :=
    carrierTransversal_difference_card_lower size hsize s t
  have hD : (k : ℝ) ≤ D := by
    dsimp [k,D]
    exact_mod_cast Nat.mul_le_mul_right R (changedRails_card_le s t)
  have hcoeff := tanh_walshCoefficient_inactive_bound
    (carrierTransversal size s) (carrierTransversal size t) u b τ D k hki hD hτ henergy
  calc
    _ ≤ weight t*(D*τ)^k := mul_le_mul_of_nonneg_left hcoeff (hw t htJ)
    _ ≤ W*(D*τ)^k := mul_le_mul_of_nonneg_right (hW t htJ) (by dsimp [D]; positivity)
    _ ≤ (W*τ^2/ρ^2)*(D*ρ)^k := weighted_power_quadratic D τ ρ W k
      (by dsimp [D]; positivity) hτ hτρ hρ hW0 hk
    _ = (W*τ^2/ρ^2)*x^(changedRails s t).card := by
      dsimp [x,k]
      rw [← pow_mul]
      congr 2
      exact Nat.mul_comm _ _

/-- Small-base simplification of the actual local offmass bound. -/
theorem tanh_local_offmass_small {p R : ℕ} (size : Fin p → Bool → ℕ)
    (hR : 2 ≤ R) (hsize : ∀ i b, R ≤ size i b)
    (s : Fin p → Bool) (J : Finset (Fin p → Bool))
    (weight : (Fin p → Bool) → ℝ) (W : ℝ)
    (hw : ∀ t ∈ J, 0 ≤ weight t) (hW : ∀ t ∈ J, weight t ≤ W) (hW0 : 0 ≤ W)
    (u : Fin (carrierDimension size) → ℝ) (b τ ρ : ℝ)
    (hτ : 0 ≤ τ) (hτρ : τ ≤ ρ) (hρ : 0 < ρ)
    (henergy : (∑ i ∈ (carrierTransversal size s)ᶜ, u i^2) ≤ τ^2)
    (hsmall : (p : ℝ)*((((p*R : ℕ) : ℝ)*ρ)^R) ≤ 1/2) :
    (∑ t ∈ J.erase s, weight t * |walshCoefficients
      (fun x => Real.tanh (b+incomingLinear u x)) (carrierTransversal size t)|) ≤
      2*W*(p : ℝ)*((((p*R : ℕ) : ℝ)*ρ)^R)/ρ^2*τ^2 := by
  have h := tanh_local_offmass size hR hsize s J weight W hw hW hW0 u b τ ρ hτ hτρ hρ henergy
  have hb := local_switch_sum_bound ((((p*R : ℕ) : ℝ)*ρ)^R) p (by positivity) hsmall
  have hm := mul_le_mul_of_nonneg_left hb (show 0 ≤ W*τ^2/ρ^2 by positivity)
  apply h.trans
  convert hm using 1 <;> ring

end NeuralGeneralization.OnlineLowerTanh
