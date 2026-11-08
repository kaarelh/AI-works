import NeuralGeneralization.OnlineLowerReluScalar
import Mathlib.Analysis.Real.Sqrt
import Mathlib.Tactic.Positivity.Basic

/-!
# Deterministic inequalities in the randomized-minimum ReLU comparison

These are the finite-dimensional algebraic steps. The neural Fourier
inequalities supplying their hypotheses are separate dependencies.
-/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLowerRelu

/-- Averaging the smaller of two independently signed rail amplitudes gives
the exact pairwise debt estimate. -/
theorem four_signed_minimum_bound (a b c d : ℝ) (hb : 0 ≤ b) (hd : 0 ≤ d) :
    min (a + b) (c + d) + min (a + b) (c - d) +
      min (a - b) (c + d) + min (a - b) (c - d) ≤
        2 * (a + c) - (b + d) := by
  simp only [min_def]
  split_ifs <;> linarith

/-- The rail-size hypothesis converts the scalar Fourier comparison into
projection onto a balanced dominant-rail vector. -/
theorem weighted_projection_bound {ι : Type*} [Fintype ι]
    (p a b : ι → ℝ) (t R Δ κ D Q : ℝ)
    (hD : 0 < D) (hDsum : ∑ i, p i = D)
    (hp : ∀ i, R ≤ p i) (ha : ∀ i, t ≤ a i) (hb : ∀ i, 0 ≤ b i)
    (hΔ : 0 ≤ Δ) (hκD : κ * Real.sqrt D ≤ 1)
    (hR : 6 * Δ ≤ R)
    (hdebt : ∑ i, b i ≤ 2 * ∑ i, (a i - t))
    (hQ : Q ≤ Real.sqrt D * t + 3 * κ * Δ * ∑ i, b i) :
    Q ≤ (∑ i, p i * a i) / Real.sqrt D := by
  classical
  have hsqrt : 0 < Real.sqrt D := Real.sqrt_pos.2 hD
  have hsqrt2 : Real.sqrt D * Real.sqrt D = D := Real.mul_self_sqrt hD.le
  have hbSum : 0 ≤ ∑ i, b i := Finset.sum_nonneg (fun i _ => hb i)
  have haSum : 0 ≤ ∑ i, (a i - t) :=
    Finset.sum_nonneg (fun i _ => sub_nonneg.mpr (ha i))
  have hweighted : R * (∑ i, (a i - t)) ≤ ∑ i, p i * (a i - t) := by
    rw [Finset.mul_sum]
    exact Finset.sum_le_sum (fun i _ =>
      mul_le_mul_of_nonneg_right (hp i) (sub_nonneg.mpr (ha i)))
  have hidentity : (∑ i, p i * (a i - t)) = (∑ i, p i * a i) - D * t := by
    simp_rw [mul_sub]
    rw [Finset.sum_sub_distrib, ← Finset.sum_mul, hDsum]
  have hstep1 := mul_le_mul_of_nonneg_right hκD
    (show 0 ≤ 3 * Δ * ∑ i, b i by positivity)
  have hstep2 := mul_le_mul_of_nonneg_left hdebt (show 0 ≤ 3 * Δ by positivity)
  have hstep3 := mul_le_mul_of_nonneg_right hR haSum
  have hstepQ := mul_le_mul_of_nonneg_right hQ hsqrt.le
  have hsqrt2t := congrArg (fun z : ℝ => z * t) hsqrt2
  apply (le_div_iff₀ hsqrt).2
  rw [hidentity] at hweighted
  nlinarith

end NeuralGeneralization.OnlineLowerRelu
