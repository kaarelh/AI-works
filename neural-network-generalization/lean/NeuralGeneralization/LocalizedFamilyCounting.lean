import NeuralGeneralization.RobustLocalizedPolynomial
import Mathlib.Combinatorics.SetFamily.Shatter

/-! The finite-domain VC cardinality bound used by the localized theorem.
The VC dimension here is Mathlib's shattering definition, not a counting oracle. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.RobustLocalized
open ConcreteModel

lemma sum_choose_le_power (n h : ℕ) :
    (∑ k ∈ Finset.range (h+1),n.choose k) ≤ (n+1)^h := by
  induction h with
  | zero => simp
  | succ h ih =>
    have hchoose : n.choose (h+1) ≤ n.choose h*n := by
      calc
        _ ≤ n.choose (h+1)*(h+1) := Nat.le_mul_of_pos_right _ (by omega)
        _ = n.choose h*(n-h) := Nat.choose_succ_right_eq n h
        _ ≤ _ := Nat.mul_le_mul_left _ (Nat.sub_le _ _)
    have hterm : n.choose h ≤ ∑ k ∈ Finset.range (h+1),n.choose k :=
      Finset.single_le_sum (fun _ _ => Nat.zero_le _) (Finset.mem_range.mpr (by omega))
    rw [show h+1+1 = (h+1)+1 from rfl,Finset.sum_range_succ,pow_succ]
    calc
      _ ≤ (∑ k ∈ Finset.range (h+1),n.choose k)*(n+1) := by nlinarith
      _ ≤ _ := Nat.mul_le_mul_right _ ih

/-- Sauer-Shelah gives the paper's deliberately loose (|X|+1)^h bound. -/
theorem family_card_le_vc_power {X : Type*} [Fintype X] [DecidableEq X]
    (F : Finset (Finset X)) {h : ℕ} (hvc : F.vcDim ≤ h) :
    F.card ≤ (Fintype.card X+1)^h := by
  calc
    _ ≤ F.shatterer.card := Finset.card_le_card_shatterer F
    _ ≤ ∑ k ∈ Finset.Iic F.vcDim,(Fintype.card X).choose k := Finset.card_shatterer_le_sum_vcDim
    _ ≤ (Fintype.card X+1)^F.vcDim := by
      simpa only [← Nat.range_succ_eq_Iic] using sum_choose_le_power (Fintype.card X) F.vcDim
    _ ≤ _ := Nat.pow_le_pow_right (by omega) hvc

/-- On the Boolean cube, a VC bound h costs at most h(d+1) log 2 in the
localized theorem. The family can be presented by arbitrary parameters;
only its distinct subsets of the cube enter this inequality. -/
theorem cube_family_log_card {d h : ℕ} (F : Finset (Finset (Cube d))) (hvc : F.vcDim ≤ h) :
    Real.log (F.card:ℝ) ≤ (h:ℝ)*((d:ℝ)+1)*Real.log 2 := by
  have hcard : Fintype.card (Cube d) = 2^d := by simp [Cube]
  have hbound := family_card_le_vc_power F hvc
  rw [hcard] at hbound
  have hp : 2^d+1 ≤ 2^(d+1) := by
    have hh : 1 ≤ 2^d := Nat.one_le_pow _ _ (by omega)
    rw [pow_succ]
    omega
  have ht : F.card ≤ (2^(d+1))^h := hbound.trans (Nat.pow_le_pow_left hp h)
  have hr : (F.card:ℝ) ≤ ((2:ℝ)^(d+1))^h := by exact_mod_cast ht
  by_cases hz : F.card = 0
  · simp only [hz,Nat.cast_zero,Real.log_zero]
    positivity
  · have hpos : (0:ℝ) < F.card := by exact_mod_cast Nat.pos_of_ne_zero hz
    have hh := Real.log_le_log hpos hr
    rw [Real.log_pow,Real.log_pow] at hh
    push_cast at hh
    nlinarith only [hh]

end NeuralGeneralization.RobustLocalized
