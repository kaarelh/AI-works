import NeuralGeneralization.SquaredProcessIncrements
import Mathlib.Data.Fintype.Lattice
import Mathlib.Analysis.SpecialFunctions.Log.Basic

/-!
# Actual expected maxima of finite Rademacher processes

This elementary exponential-moment bound supplies the finite-maximal step
used in chaining. It is proved from the literal uniform sign law.
-/

noncomputable section
namespace NeuralGeneralization.SquaredSampling
open scoped BigOperators

/-- Jensen's exponential inequality for a literal finite mean, proved from
the supporting-line inequality for `exp`. -/
theorem exp_finiteMean_le {α : Type*} [Fintype α] [Nonempty α] (f : α → ℝ) :
    Real.exp (finiteMean f) ≤ finiteMean (fun x => Real.exp (f x)) := by
  have hpoint (x : α) : Real.exp (finiteMean f) * (f x - finiteMean f + 1) ≤ Real.exp (f x) := by
    have h := mul_le_mul_of_nonneg_left (Real.add_one_le_exp (f x - finiteMean f))
      (Real.exp_pos (finiteMean f)).le
    calc
      _ ≤ Real.exp (finiteMean f) * Real.exp (f x - finiteMean f) := h
      _ = _ := by
        rw [← Real.exp_add]
        congr 1
        ring
  have h := finiteMean_mono hpoint
  rw [finiteMean_mul, finiteMean_add, finiteMean_sub, finiteMean_const, finiteMean_const] at h
  simpa using h

lemma envelope_eq_of_max {ι : Type*} [Nonempty ι] (f : ι → ℝ) (i : ι)
    (hmax : ∀ j, |f j| ≤ |f i|) : envelope f = |f i| :=
  le_antisymm (envelope_le f hmax) (le_envelope f hmax i)

lemma exp_envelope_le_sum {ι : Type*} [Fintype ι] [Nonempty ι]
    (f : ι → ℝ) (t : ℝ) :
    Real.exp (t * envelope f) ≤ ∑ i, (Real.exp (t * f i) + Real.exp (-t * f i)) := by
  classical
  obtain ⟨i, hi⟩ := Finite.exists_max (fun i => |f i|)
  rw [envelope_eq_of_max f i hi]
  have hscalar : Real.exp (t * |f i|) ≤ Real.exp (t * f i) + Real.exp (-t * f i) := by
    by_cases h : 0 ≤ f i
    · rw [abs_of_nonneg h]
      exact le_add_of_nonneg_right (Real.exp_pos _).le
    · rw [abs_of_neg (lt_of_not_ge h)]
      have he : t * -f i = -t * f i := by ring
      rw [he]
      exact le_add_of_nonneg_left (Real.exp_pos _).le
  exact hscalar.trans (Finset.single_le_sum
    (f := fun j => Real.exp (t * f j) + Real.exp (-t * f j))
    (fun j _ => add_nonneg (Real.exp_pos _).le (Real.exp_pos _).le) (Finset.mem_univ i))

/-- A logarithmic expected-maximum bound for an actual finite family of
Rademacher linear forms. The energy bound is the literal sum of squared
coefficients, and the signs are independent uniform Boolean variables. -/
theorem finite_rademacher_expected_max {ι : Type*} [Fintype ι] [Nonempty ι]
    (n : ℕ) (a : ι → Fin n → ℝ) (V t : ℝ) (ht : 0 < t)
    (hV : ∀ j, (∑ i, a j i ^ 2) ≤ V) :
    finiteMean (fun ε : Fin n → Bool =>
      envelope (fun j => ∑ i, cubeCoordinateSign (ε i) * a j i)) ≤
      (Real.log (2 * Fintype.card ι) + t ^ 2 * V / 2) / t := by
  classical
  let X := fun ε : Fin n → Bool => fun j : ι => ∑ i, cubeCoordinateSign (ε i) * a j i
  have hmax := finiteMean_mono (fun ε : Fin n → Bool => exp_envelope_le_sum (X ε) t)
  rw [finiteMean_sum] at hmax
  have hterm (j : ι) :
      finiteMean (fun ε : Fin n → Bool => Real.exp (t * X ε j) + Real.exp (-t * X ε j)) ≤
      2 * Real.exp (t ^ 2 * V / 2) := by
    rw [finiteMean_add]
    have hp := finite_rademacher_mgf_le n (a j) t
    have hm := finite_rademacher_mgf_le n (a j) (-t)
    have hscale := mul_le_mul_of_nonneg_left (hV j) (sq_nonneg t)
    have hupper : Real.exp (t ^ 2 * (∑ i, a j i ^ 2) / 2) ≤
        Real.exp (t ^ 2 * V / 2) := Real.exp_le_exp.mpr (by linarith)
    change finiteMean (fun ε => Real.exp (t * X ε j)) ≤ _ at hp
    change finiteMean (fun ε => Real.exp (-t * X ε j)) ≤ _ at hm
    simp only [neg_sq] at hm
    linarith [hp.trans hupper, hm.trans hupper]
  have hsum := Finset.sum_le_sum (fun j (_ : j ∈ Finset.univ) => hterm j)
  have hJ := exp_finiteMean_le (fun ε : Fin n → Bool => t * envelope (X ε))
  rw [finiteMean_mul] at hJ
  have hcombined := hJ.trans (hmax.trans hsum)
  have hc : (0 : ℝ) < 2 * Fintype.card ι := mul_pos (by norm_num) (Nat.cast_pos.mpr Fintype.card_pos)
  have hrhs : (∑ _j : ι, 2 * Real.exp (t ^ 2 * V / 2)) =
      Real.exp (Real.log (2 * Fintype.card ι) + t ^ 2 * V / 2) := by
    rw [Real.exp_add, Real.exp_log hc]
    simp
    ring
  rw [hrhs, Real.exp_le_exp] at hcombined
  apply (le_div_iff₀ ht).mpr
  simpa only [X, mul_comm] using hcombined

end NeuralGeneralization.SquaredSampling
