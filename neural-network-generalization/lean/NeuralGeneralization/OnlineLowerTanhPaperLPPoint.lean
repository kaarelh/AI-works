import NeuralGeneralization.OnlineLowerGeometryContinuity
import NeuralGeneralization.OnlineLowerGeometryAlgebra
import Mathlib.Topology.Instances.Real.Lemmas

/-! # The point-positive weighted Walsh minimization lemma

This is the unrestricted finite Fourier optimization statement in the tanh
paper.  The proof uses coefficient clipping and affine normalization, rather
than assuming linear-programming duality or a neural calibration certificate.
-/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerGeometry

/-- The full-margin cell positive at exactly the identity of the cube. -/
def PointPositive {m : ℕ} (g : ClippingCube m → ℝ) : Prop :=
  (1 : ℝ) / 2 ≤ g (cubeOne m) ∧ ∀ x, x ≠ cubeOne m → g x ≤ -1/2

private def negPart (a : ℝ) : ℝ := max (-a) 0

private theorem negPart_nonneg (a : ℝ) : 0 ≤ negPart a := le_max_right _ _

private theorem add_negPart (a : ℝ) : a + negPart a = max a 0 := by
  unfold negPart
  by_cases h : 0 ≤ a
  · rw [max_eq_right (by linarith), max_eq_left h]; ring
  · rw [max_eq_left (by linarith), max_eq_right (le_of_not_ge h)]; ring

private theorem abs_negPart (a : ℝ) : |a| = max a 0 + negPart a := by
  unfold negPart
  by_cases h : 0 ≤ a
  · rw [abs_of_nonneg h, max_eq_left h, max_eq_right (by linarith)]; ring
  · rw [abs_of_nonpos (le_of_not_ge h), max_eq_right (le_of_not_ge h),
      max_eq_left (by linarith)]; ring

/-- Move all negative nonconstant coefficients into the constant coefficient. -/
def pointClippedCoefficients {m : ℕ} (c : Finset (Fin m) → ℝ)
    (s : Finset (Fin m)) : ℝ :=
  if s = ∅ then c ∅ - ∑ t ∈ Finset.univ.erase ∅, negPart (c t)
  else max (c s) 0

private theorem sum_erase_empty {m : ℕ} (c : Finset (Fin m) → ℝ) :
    (∑ s, c s) = c ∅ + ∑ s ∈ Finset.univ.erase ∅, c s := by
  simpa only [Finset.sum_filter] using
    (Finset.add_sum_erase (Finset.univ : Finset (Finset (Fin m))) c (Finset.mem_univ ∅)).symm

private theorem expansion_split {m : ℕ} (c : Finset (Fin m) → ℝ)
    (x : ClippingCube m) :
    walshExpansion c x = c ∅ + ∑ s ∈ Finset.univ.erase ∅, c s * walshCharacter s x := by
  rw [walshExpansion, sum_erase_empty]
  simp [walshCharacter]

private theorem clipped_expansion {m : ℕ} (c : Finset (Fin m) → ℝ)
    (x : ClippingCube m) :
    walshExpansion (pointClippedCoefficients c) x = walshExpansion c x +
      ∑ s ∈ Finset.univ.erase ∅, negPart (c s) * (walshCharacter s x - 1) := by
  rw [expansion_split, expansion_split]
  simp only [pointClippedCoefficients, ite_true]
  have heq : (∑ s ∈ Finset.univ.erase ∅,
      (if s = ∅ then c ∅ - ∑ t ∈ Finset.univ.erase ∅, negPart (c t)
      else max (c s) 0) * walshCharacter s x) =
      ∑ s ∈ Finset.univ.erase ∅, (c s + negPart (c s)) * walshCharacter s x := by
    apply Finset.sum_congr rfl
    intro s hs
    rw [if_neg (Finset.ne_of_mem_erase hs), add_negPart]
  rw [heq]
  simp_rw [add_mul, mul_sub, mul_one]
  rw [Finset.sum_add_distrib, Finset.sum_sub_distrib]
  ring

theorem pointClipped_preserves_margin {m : ℕ} (c : Finset (Fin m) → ℝ)
    (hc : PointPositive (walshExpansion c)) :
    PointPositive (walshExpansion (pointClippedCoefficients c)) := by
  constructor
  · simpa only [clipped_expansion, walshCharacter_one, sub_self, mul_zero,
      Finset.sum_const_zero, add_zero] using hc.1
  · intro x hx
    rw [clipped_expansion]
    have hsum : (∑ s ∈ Finset.univ.erase ∅,
        negPart (c s) * (walshCharacter s x - 1)) ≤ 0 := by
      apply Finset.sum_nonpos
      intro s _
      apply mul_nonpos_of_nonneg_of_nonpos (negPart_nonneg _)
      have := le_abs_self (walshCharacter s x)
      rw [abs_walshCharacter] at this
      linarith
    linarith [hc.2 x hx]

private theorem clipped_cost_bound {m : ℕ} (w c : Finset (Fin m) → ℝ)
    (hw0 : 0 ≤ w ∅) :
    weightedL1 w (pointClippedCoefficients c) ≤ weightedL1 w c -
      ∑ s ∈ Finset.univ.erase ∅, (w s - w ∅) * negPart (c s) := by
  have hn : 0 ≤ ∑ s ∈ Finset.univ.erase ∅, negPart (c s) :=
    Finset.sum_nonneg (fun s _ => negPart_nonneg (c s))
  have hconstant : w ∅ * |c ∅ - ∑ s ∈ Finset.univ.erase ∅, negPart (c s)| ≤
      w ∅ * |c ∅| + w ∅ * ∑ s ∈ Finset.univ.erase ∅, negPart (c s) := by
    have := abs_add_le (c ∅) (-(∑ s ∈ Finset.univ.erase ∅, negPart (c s)))
    rw [abs_neg, abs_of_nonneg hn] at this
    simp only [← sub_eq_add_neg] at this
    nlinarith
  unfold weightedL1
  rw [sum_erase_empty, sum_erase_empty]
  simp only [pointClippedCoefficients, ite_true]
  have heq : (∑ s ∈ Finset.univ.erase ∅,
      w s * |if s = ∅ then c ∅ - ∑ t ∈ Finset.univ.erase ∅, negPart (c t)
      else max (c s) 0|) = ∑ s ∈ Finset.univ.erase ∅, w s * max (c s) 0 := by
    apply Finset.sum_congr rfl
    intro s hs
    rw [if_neg (Finset.ne_of_mem_erase hs), abs_of_nonneg (le_max_right _ _)]
  rw [heq]
  conv_rhs => arg 1; arg 2; arg 2; ext s; rw [abs_negPart]
  simp_rw [mul_add, sub_mul]
  rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum]
  linarith

theorem pointClipped_cost_le {m : ℕ} (w c : Finset (Fin m) → ℝ)
    (hw0 : 0 ≤ w ∅) (hw : ∀ s, w ∅ ≤ w s) :
    weightedL1 w (pointClippedCoefficients c) ≤ weightedL1 w c := by
  have hs : 0 ≤ ∑ s ∈ Finset.univ.erase ∅, (w s - w ∅) * negPart (c s) :=
    Finset.sum_nonneg (fun s _ => mul_nonneg (sub_nonneg.mpr (hw s)) (negPart_nonneg _))
  linarith [clipped_cost_bound w c hw0]

theorem pointClipped_cost_lt_of_negative {m : ℕ} (w c : Finset (Fin m) → ℝ)
    (hw0 : 0 ≤ w ∅) (hw : ∀ s, s ≠ ∅ → w ∅ < w s)
    (s : Finset (Fin m)) (hs : s ≠ ∅) (hc : c s < 0) :
    weightedL1 w (pointClippedCoefficients c) < weightedL1 w c := by
  have hn : 0 < negPart (c s) := lt_of_lt_of_le (neg_pos.mpr hc) (le_max_left _ _)
  have hsum : 0 < ∑ t ∈ Finset.univ.erase ∅, (w t - w ∅) * negPart (c t) := by
    exact Finset.sum_pos' (fun t ht => mul_nonneg
      (le_of_lt (sub_pos.mpr (hw t (Finset.ne_of_mem_erase ht)))) (negPart_nonneg _))
      ⟨s, Finset.mem_erase.mpr ⟨hs, Finset.mem_univ _⟩, mul_pos (sub_pos.mpr (hw s hs)) hn⟩
  linarith [clipped_cost_bound w c hw0]

end NeuralGeneralization.OnlineLowerGeometry
