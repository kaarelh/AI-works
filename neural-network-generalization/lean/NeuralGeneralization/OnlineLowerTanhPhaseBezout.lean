import NeuralGeneralization.OnlineLowerTanhPhase
import Mathlib.Algebra.Order.BigOperators.Ring.Finset

/-! # Explicit common-peak coercivity for a finite odd alphabet

An integer Bezout identity reduces every common near-maximum to the
nearest odd lattice point.  The estimate is global and has an explicit
constant, so no compactness or unquantified neighborhood is used.
-/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerTanh

lemma phaseError_le_odd_distance (x : ℝ) (z : ℤ) (hz : Odd z) :
    |phaseError true x| ≤ |x - (z : ℝ)| := by
  obtain ⟨a, ha⟩ := hz
  have hr := round_le ((x - 1) / 2) a
  have hleft : phaseError true x =
      2 * ((x - 1) / 2 - (round ((x - 1) / 2) : ℝ)) := by
    simp [phaseError, phaseInteger]
    ring
  have hright : x - (z : ℝ) = 2 * ((x - 1) / 2 - (a : ℝ)) := by
    rw [ha]
    push_cast
    ring
  rw [hleft, hright, abs_mul, abs_mul]
  exact mul_le_mul_of_nonneg_left hr (abs_nonneg _)

lemma phaseError_odd_le_cos (x : ℝ) :
    |phaseError true x| ≤ |Real.cos (Real.pi * x / 2)| := by
  have he : Real.pi * x / 2 =
      (Real.pi * phaseError true x / 2 + Real.pi / 2) +
        (round ((x - 1) / 2) : ℝ) * Real.pi := by
    simp [phaseError, phaseInteger]
    ring
  rw [he, Real.cos_add_int_mul_pi, abs_mul, abs_zpow]
  simp only [abs_neg, abs_one, one_zpow, one_mul, Real.cos_add_pi_div_two, abs_neg]
  have harg : |Real.pi * phaseError true x / 2| ≤ Real.pi := by
    rw [abs_div, abs_mul, abs_of_pos Real.pi_pos]
    norm_num
    nlinarith [phaseError_abs_le_one true x, Real.pi_pos]
  rw [Real.abs_sin_eq_sin_abs_of_abs_le_pi harg]
  rw [abs_div, abs_mul, abs_of_pos Real.pi_pos]
  norm_num
  have hs := Real.le_sin_mul (abs_nonneg (phaseError true x))
    (phaseError_abs_le_one true x)
  convert hs using 1 <;> congr 1 <;> ring

/-- A Bezout combination of nearest odd integers is odd whenever the
same coefficients combine the odd frequencies to one. -/
lemma bezout_phaseInteger_odd {ι : Type*} (s : Finset ι) (q c : ι → ℤ)
    (hq : ∀ i ∈ s, Odd (q i)) (hbezout : ∑ i ∈ s, c i * q i = 1) (x : ℝ) :
    Odd (∑ i ∈ s, c i * phaseInteger true ((q i : ℝ) * x)) := by
  have heven : Even (∑ i ∈ s,
      c i * (phaseInteger true ((q i : ℝ) * x) - q i)) := by
    apply Finset.sum_induction
    · intro a b ha hb
      exact ha.add hb
    · exact ⟨0, by ring⟩
    · intro i hi
      exact ((phaseInteger_odd _).sub_odd (hq i hi)).mul_left _
  have heq : (∑ i ∈ s, c i * phaseInteger true ((q i : ℝ) * x)) =
      (∑ i ∈ s, c i * (phaseInteger true ((q i : ℝ) * x) - q i)) + 1 := by
    simp only [mul_sub, Finset.sum_sub_distrib, hbezout]
    ring
  rw [heq]
  exact heven.add_one

/-- Exact finite-alphabet quadratic localization.  The explicit constant
is the squared Euclidean norm of any integer Bezout coefficient vector. -/
theorem odd_alphabet_phase_coercivity {ι : Type*} (s : Finset ι) (q c : ι → ℤ)
    (hq : ∀ i ∈ s, Odd (q i)) (hbezout : ∑ i ∈ s, c i * q i = 1) (x : ℝ) :
    (phaseError true x)^2 ≤
      (∑ i ∈ s, (c i : ℝ)^2) *
        (∑ i ∈ s, (phaseError true ((q i : ℝ) * x))^2) := by
  have hodd := bezout_phaseInteger_odd s q c hq hbezout x
  have hnearest := phaseError_le_odd_distance x _ hodd
  have hcomb : x - ((∑ i ∈ s, c i * phaseInteger true ((q i : ℝ) * x) : ℤ) : ℝ) =
      ∑ i ∈ s, (c i : ℝ) * phaseError true ((q i : ℝ) * x) := by
    have hb : ∑ i ∈ s, (c i : ℝ) * (q i : ℝ) = 1 := by exact_mod_cast hbezout
    push_cast
    simp only [phaseError, mul_sub, Finset.sum_sub_distrib]
    rw [show (∑ i ∈ s, (c i : ℝ) * ((q i : ℝ) * x)) = x by
      simp_rw [← mul_assoc]
      rw [← Finset.sum_mul, hb, one_mul]]
  rw [hcomb] at hnearest
  have hsq := (sq_le_sq₀ (abs_nonneg _) (abs_nonneg _)).mpr hnearest
  simp only [sq_abs] at hsq
  exact hsq.trans (Finset.sum_mul_sq_le_sq_mul_sq s _ _)

/-- Jordan's inequality converts phase localization to the literal cosine
squares occurring in the tanh Fourier potential. -/
theorem odd_alphabet_cosine_coercivity {ι : Type*} (s : Finset ι) (q c : ι → ℤ)
    (hq : ∀ i ∈ s, Odd (q i)) (hbezout : ∑ i ∈ s, c i * q i = 1) (x : ℝ) :
    (phaseError true x)^2 ≤
      (∑ i ∈ s, (c i : ℝ)^2) *
        (∑ i ∈ s, (Real.cos (Real.pi * ((q i : ℝ) * x) / 2))^2) := by
  apply (odd_alphabet_phase_coercivity s q c hq hbezout x).trans
  apply mul_le_mul_of_nonneg_left _ (Finset.sum_nonneg fun i _ => sq_nonneg _)
  apply Finset.sum_le_sum
  intro i hi
  have hs := (sq_le_sq₀ (abs_nonneg _) (abs_nonneg _)).mpr
    (phaseError_odd_le_cos ((q i : ℝ) * x))
  simpa only [sq_abs] using hs

end NeuralGeneralization.OnlineLowerTanh
