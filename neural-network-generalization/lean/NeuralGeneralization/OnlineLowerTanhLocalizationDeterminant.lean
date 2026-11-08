import NeuralGeneralization.OnlineLowerOrientation
import Mathlib.Algebra.Ring.Parity
import Mathlib.Algebra.Order.BigOperators.Ring.Finset
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.GCongr

/-!
# Collective phase separation for tanh transversal codes

The estimates here concern the actual integer phases of coordinate sine and
cosine factors. They are finite algebraic estimates: no localization or
analytic estimate is assumed as an axiom. The key bound sums determinants
across whole sets of coordinates, avoiding an extra factor of the number of
rail pairs.
-/

noncomputable section

open scoped BigOperators

namespace NeuralGeneralization.OnlineLowerTanh

private theorem four_term_square (a b c d : ℝ) :
    (a + b + c + d)^2 ≤ 4 * (a^2 + b^2 + c^2 + d^2) := by
  nlinarith [sq_nonneg (a-b), sq_nonneg (a-c), sq_nonneg (a-d),
    sq_nonneg (b-c), sq_nonneg (b-d), sq_nonneg (c-d)]

/-- An odd integer determinant has real square at least one. -/
theorem odd_int_square_one_le (z : ℤ) (hz : Odd z) : (1 : ℝ) ≤ (z : ℝ)^2 := by
  have hz0 : z ≠ 0 := by rintro rfl; norm_num at hz
  have hs : (1 : ℤ) ≤ z^2 := by
    rcases lt_or_gt_of_ne hz0 with hn | hp
    · have hn' : z ≤ -1 := by omega
      nlinarith
    · have hp' : 1 ≤ z := by omega
      nlinarith
  exact_mod_cast hs

/-- A determinant between two rescaled integer phases is controlled by
old and new phase errors. No bound on any individual coordinate is needed. -/
theorem phase_determinant_sq (ka kb la lb δa δb εa εb γ : ℝ)
    (ha : γ * (ka + δa) = la + εa)
    (hb : γ * (kb + δb) = lb + εb) :
    (ka * lb - kb * la)^2 ≤
      4 * (ka^2 * εb^2 + kb^2 * εa^2 +
        γ^2 * (ka^2 * δb^2 + kb^2 * δa^2)) := by
  have he : ka * lb - kb * la =
      γ * ka * δb - γ * kb * δa - ka * εb + kb * εa := by
    nlinarith [congrArg (fun t => ka * t) hb, congrArg (fun t => kb * t) ha]
  rw [he]
  convert four_term_square (-(ka*εb)) (kb*εa) (γ*ka*δb) (-(γ*kb*δa)) using 1 <;> ring

/-- Summed determinant estimate. The two coordinate sets need not have the
same size, and all energies are taken over the full sets. -/
theorem phase_determinant_sum {ι : Type*} [DecidableEq ι]
    (A B : Finset ι) (k l : ι → ℤ) (δ ε : ι → ℝ) (γ : ℝ)
    (hphase : ∀ i ∈ A ∪ B, γ * ((k i : ℝ) + δ i) = (l i : ℝ) + ε i)
    (hodd : ∀ a ∈ A, ∀ b ∈ B, Odd (k a * l b - k b * l a)) :
    (A.card : ℝ) * (B.card : ℝ) ≤
      4 * ((∑ a ∈ A, (k a : ℝ)^2) * (∑ b ∈ B, ε b^2) +
        (∑ b ∈ B, (k b : ℝ)^2) * (∑ a ∈ A, ε a^2) +
        γ^2 * ((∑ a ∈ A, (k a : ℝ)^2) * (∑ b ∈ B, δ b^2) +
          (∑ b ∈ B, (k b : ℝ)^2) * (∑ a ∈ A, δ a^2))) := by
  have hpoint (a : ι) (ha : a ∈ A) (b : ι) (hb : b ∈ B) :
      (1 : ℝ) ≤ 4 * ((k a : ℝ)^2 * ε b^2 + (k b : ℝ)^2 * ε a^2 +
        γ^2 * ((k a : ℝ)^2 * δ b^2 + (k b : ℝ)^2 * δ a^2)) := by
    have ho := odd_int_square_one_le _ (hodd a ha b hb)
    push_cast at ho
    exact ho.trans (phase_determinant_sq _ _ _ _ _ _ _ _ _
      (hphase a (Finset.mem_union_left B ha))
      (hphase b (Finset.mem_union_right A hb)))
  have hs := Finset.sum_le_sum (fun a ha => Finset.sum_le_sum (fun b hb => hpoint a ha b hb))
  simpa only [Finset.sum_const, nsmul_eq_mul, mul_one, Finset.sum_add_distrib,
    ← Finset.mul_sum, ← Finset.sum_mul] using hs

/-- Whole-set energy form. Disjointness makes the sum of the two set
energies at most the total energy; this is the source of the improved
polylogarithmic rail baseline. -/
theorem phase_determinant_total_bound {ι : Type*} [DecidableEq ι]
    (A B : Finset ι) (k l : ι → ℤ) (δ ε : ι → ℝ) (γ Ktot Etot Δtot : ℝ)
    (hphase : ∀ i ∈ A ∪ B, γ * ((k i : ℝ) + δ i) = (l i : ℝ) + ε i)
    (hodd : ∀ a ∈ A, ∀ b ∈ B, Odd (k a * l b - k b * l a))
    (hK : (∑ a ∈ A, (k a : ℝ)^2) + (∑ b ∈ B, (k b : ℝ)^2) ≤ Ktot)
    (hE : (∑ a ∈ A, ε a^2) + (∑ b ∈ B, ε b^2) ≤ Etot)
    (hΔ : (∑ a ∈ A, δ a^2) + (∑ b ∈ B, δ b^2) ≤ Δtot) :
    (A.card : ℝ) * (B.card : ℝ) ≤ 4 * Ktot * (Etot + γ^2 * Δtot) := by
  have hKA : 0 ≤ ∑ a ∈ A, (k a : ℝ)^2 := Finset.sum_nonneg (fun _ _ => sq_nonneg _)
  have hKB : 0 ≤ ∑ b ∈ B, (k b : ℝ)^2 := Finset.sum_nonneg (fun _ _ => sq_nonneg _)
  have hEA : 0 ≤ ∑ a ∈ A, ε a^2 := Finset.sum_nonneg (fun _ _ => sq_nonneg _)
  have hEB : 0 ≤ ∑ b ∈ B, ε b^2 := Finset.sum_nonneg (fun _ _ => sq_nonneg _)
  have hDA : 0 ≤ ∑ a ∈ A, δ a^2 := Finset.sum_nonneg (fun _ _ => sq_nonneg _)
  have hDB : 0 ≤ ∑ b ∈ B, δ b^2 := Finset.sum_nonneg (fun _ _ => sq_nonneg _)
  have hK0 : 0 ≤ Ktot := (add_nonneg hKA hKB).trans hK
  have hE0 : 0 ≤ Etot := (add_nonneg hEA hEB).trans hE
  have hD0 : 0 ≤ Δtot := (add_nonneg hDA hDB).trans hΔ
  have hcrossE :
      (∑ a ∈ A, (k a : ℝ)^2) * (∑ b ∈ B, ε b^2) +
        (∑ b ∈ B, (k b : ℝ)^2) * (∑ a ∈ A, ε a^2) ≤ Ktot * Etot := by
    have hm := mul_le_mul hK hE (add_nonneg hEA hEB) hK0
    nlinarith [mul_nonneg hKA hEA, mul_nonneg hKB hEB]
  have hcrossD :
      (∑ a ∈ A, (k a : ℝ)^2) * (∑ b ∈ B, δ b^2) +
        (∑ b ∈ B, (k b : ℝ)^2) * (∑ a ∈ A, δ a^2) ≤ Ktot * Δtot := by
    have hm := mul_le_mul hK hΔ (add_nonneg hDA hDB) hK0
    nlinarith [mul_nonneg hKA hDA, mul_nonneg hKB hDB]
  have hs := phase_determinant_sum A B k l δ ε γ hphase hodd
  have hd := mul_le_mul_of_nonneg_left hcrossD (sq_nonneg γ)
  nlinarith

end NeuralGeneralization.OnlineLowerTanh
