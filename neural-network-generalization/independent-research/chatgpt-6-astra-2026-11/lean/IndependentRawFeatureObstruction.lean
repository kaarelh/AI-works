import Mathlib.Tactic

/-!
An actual six-bit Boolean-cube instance of the raw-feature obstruction.
The selected incoming directions obey x₂*x₃*x₄ = 1. Their ReLU features
annihilate the integer functional 8*(x₁*x₂*x₃*x₄) + x₁, while a signed
combination realizes full six-bit parity. The finite identities are checked
by kernel reduction (`decide`), without native compilation or new axioms.
This file does not formalize the general-dimension or posterior theorems.
-/

set_option maxRecDepth 100000
set_option maxHeartbeats 0

namespace IndependentResearch
open scoped BigOperators

abbrev Cube6 := Fin 64

def cube6Sign (x : Cube6) (i : ℕ) : ℤ :=
  if x.val.testBit i then 1 else -1

def cube6Full (x : Cube6) : ℤ := ∏ i : Fin 6, cube6Sign x i

def cube6Target (x : Cube6) : ℤ := ∏ i : Fin 4, cube6Sign x i

def cube6Selected (z : Cube6) : Prop :=
  cube6Sign z 1 * cube6Sign z 2 * cube6Sign z 3 = 1

instance (z : Cube6) : Decidable (cube6Selected z) := inferInstanceAs
  (Decidable (cube6Sign z 1 * cube6Sign z 2 * cube6Sign z 3 = 1))

def cube6Ridge (z x : Cube6) : ℤ :=
  max 0 (∑ i : Fin 6, cube6Sign z i * cube6Sign x i)

def cube6Feature (z x : Cube6) : ℤ :=
  if cube6Selected z then cube6Ridge z x else 0

def cube6Witness (x : Cube6) : ℤ :=
  8 * cube6Target x + cube6Sign x 0

/-- Every selected ReLU feature annihilates the separating functional. -/
theorem cube6_integer_annihilation : ∀ z : Cube6,
    ∑ x : Cube6, cube6Feature z x * cube6Witness x = 0 := by
  decide

/-- Full parity has an explicit representation in the same raw features. -/
theorem cube6_integer_source_representation : ∀ x : Cube6,
    ∑ z : Cube6, cube6Full z * cube6Feature z x = 6 * cube6Full x := by
  decide

/-- The target character is Boolean-valued, and the witness has its sign. -/
theorem cube6_integer_sign_certificate : ∀ x : Cube6,
    cube6Target x * cube6Target x = 1 ∧
    0 < cube6Target x * cube6Witness x := by
  decide

/-- Exact witness moments determine the sharp six-bit risk obstruction. -/
theorem cube6_integer_witness_moments :
    (∑ x : Cube6, cube6Target x * cube6Witness x) = 512 ∧
    (∑ x : Cube6, cube6Witness x ^ 2) = 4160 := by
  decide

/-- An explicit transfer combination attains the constrained projection. -/
theorem cube6_integer_transfer_representation : ∀ x : Cube6,
    (∑ z : Cube6, cube6Target z * cube6Feature z x) =
      -2 * cube6Target x + 16 * cube6Sign x 0 := by
  decide

noncomputable def cube6RawPredictor (coeff : Cube6 → ℝ) (x : Cube6) : ℝ :=
  ∑ z : Cube6, coeff z * (cube6Feature z x : ℝ)

/-- The concrete annihilator applies to arbitrary real readout coefficients. -/
theorem cube6_real_annihilation (coeff : Cube6 → ℝ) :
    ∑ x : Cube6, cube6RawPredictor coeff x * (cube6Witness x : ℝ) = 0 := by
  simp only [cube6RawPredictor, Finset.sum_mul]
  rw [Finset.sum_comm]
  apply Finset.sum_eq_zero
  intro z _
  calc
    (∑ x : Cube6, coeff z * (cube6Feature z x : ℝ) * (cube6Witness x : ℝ)) =
        coeff z * ∑ x : Cube6, (cube6Feature z x : ℝ) * (cube6Witness x : ℝ) := by
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro x _
      ring
    _ = 0 := by
      have hz : (∑ x : Cube6, (cube6Feature z x : ℝ) * (cube6Witness x : ℝ)) = 0 := by
        exact_mod_cast cube6_integer_annihilation z
      rw [hz, mul_zero]

/-- No raw linear readout has a positive target margin on every cube input. -/
theorem cube6_raw_target_not_strictly_separable (coeff : Cube6 → ℝ) :
    ¬ (∀ x : Cube6, 0 < (cube6Target x : ℝ) * cube6RawPredictor coeff x) := by
  intro hmargin
  have hpositive (x : Cube6) : 0 < cube6RawPredictor coeff x * (cube6Witness x : ℝ) := by
    have hs : (cube6Target x : ℝ) * (cube6Target x : ℝ) = 1 := by
      exact_mod_cast (cube6_integer_sign_certificate x).1
    have hw : 0 < (cube6Target x : ℝ) * (cube6Witness x : ℝ) := by
      exact_mod_cast (cube6_integer_sign_certificate x).2
    have hp := mul_pos (hmargin x) hw
    have heq : ((cube6Target x : ℝ) * cube6RawPredictor coeff x) *
        ((cube6Target x : ℝ) * (cube6Witness x : ℝ)) =
        cube6RawPredictor coeff x * (cube6Witness x : ℝ) := by
      calc
        _ = ((cube6Target x : ℝ) * (cube6Target x : ℝ)) *
            (cube6RawPredictor coeff x * (cube6Witness x : ℝ)) := by ring
        _ = _ := by rw [hs, one_mul]
    rwa [heq] at hp
  have hsum : 0 < ∑ x : Cube6, cube6RawPredictor coeff x * (cube6Witness x : ℝ) := by
    exact Finset.sum_pos (fun x _ => hpositive x) Finset.univ_nonempty
  rw [cube6_real_annihilation coeff] at hsum
  exact (lt_irrefl 0) hsum

/-- The source is full parity, rather than an abstract prescribed vector. -/
theorem cube6_real_source_representation (x : Cube6) :
    cube6RawPredictor (fun z => (cube6Full z : ℝ) / 6) x = (cube6Full x : ℝ) := by
  have h : (∑ z : Cube6, (cube6Full z : ℝ) * (cube6Feature z x : ℝ)) =
      6 * (cube6Full x : ℝ) := by
    exact_mod_cast cube6_integer_source_representation x
  dsimp [cube6RawPredictor]
  calc
    _ = (∑ z : Cube6, (cube6Full z : ℝ) * (cube6Feature z x : ℝ)) / 6 := by
      rw [Finset.sum_div]
      apply Finset.sum_congr rfl
      intro z _
      ring
    _ = _ := by rw [h]; ring

/-- Sharp uniform population square-risk lower bound for the concrete
four-bit target in the raw features of the six-bit source representation. -/
theorem cube6_raw_mse_lower_bound (coeff : Cube6 → ℝ) :
    (64 : ℝ) / 65 ≤ (∑ x : Cube6,
      (cube6RawPredictor coeff x - (cube6Target x : ℝ)) ^ 2) / 64 := by
  have ht : (∑ x : Cube6, (cube6Target x : ℝ) * (cube6Witness x : ℝ)) = 512 := by
    exact_mod_cast cube6_integer_witness_moments.1
  have hw : (∑ x : Cube6, (cube6Witness x : ℝ) ^ 2) = 4160 := by
    exact_mod_cast cube6_integer_witness_moments.2
  have hi : (∑ x : Cube6, (cube6RawPredictor coeff x - (cube6Target x : ℝ)) *
      (cube6Witness x : ℝ)) = -512 := by
    simp only [sub_mul, Finset.sum_sub_distrib]
    rw [cube6_real_annihilation coeff, ht]
    norm_num
  have hcs := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ
    (fun x : Cube6 => cube6RawPredictor coeff x - (cube6Target x : ℝ))
    (fun x : Cube6 => (cube6Witness x : ℝ))
  rw [hi, hw] at hcs
  nlinarith

/-- The displayed raw-feature predictor attains the sharp 64/65 error. -/
theorem cube6_raw_mse_attainment :
    (∑ x : Cube6,
      (cube6RawPredictor (fun z => -(cube6Target z : ℝ) / 130) x -
        (cube6Target x : ℝ)) ^ 2) / 64 = (64 : ℝ) / 65 := by
  have hpoint (x : Cube6) :
      cube6RawPredictor (fun z => -(cube6Target z : ℝ) / 130) x -
        (cube6Target x : ℝ) = -(8 / 65 : ℝ) * (cube6Witness x : ℝ) := by
    have h : (∑ z : Cube6, (cube6Target z : ℝ) * (cube6Feature z x : ℝ)) =
        -2 * (cube6Target x : ℝ) + 16 * (cube6Sign x 0 : ℝ) := by
      exact_mod_cast cube6_integer_transfer_representation x
    have hg : cube6RawPredictor (fun z => -(cube6Target z : ℝ) / 130) x =
        -(∑ z : Cube6, (cube6Target z : ℝ) * (cube6Feature z x : ℝ)) / 130 := by
      dsimp [cube6RawPredictor]
      rw [← Finset.sum_neg_distrib, Finset.sum_div]
      apply Finset.sum_congr rfl
      intro z _
      ring
    rw [hg, h]
    simp only [cube6Witness, Int.cast_add, Int.cast_mul, Int.cast_ofNat]
    ring
  simp only [hpoint, mul_pow]
  rw [← Finset.mul_sum]
  have hw : (∑ x : Cube6, (cube6Witness x : ℝ) ^ 2) = 4160 := by
    exact_mod_cast cube6_integer_witness_moments.2
  rw [hw]
  norm_num

/-- The annihilator also kills an arbitrary constant readout bias. -/
theorem cube6_integer_witness_mean : (∑ x : Cube6, cube6Witness x) = 0 := by
  decide

/-- Explicit Boolean range of the concrete four-bit character. -/
theorem cube6_integer_target_values : ∀ x : Cube6,
    cube6Target x = 1 ∨ cube6Target x = -1 := by
  decide

theorem cube6_affine_annihilation (coeff : Cube6 → ℝ) (bias : ℝ) :
    ∑ x : Cube6, (cube6RawPredictor coeff x + bias) * (cube6Witness x : ℝ) = 0 := by
  simp only [add_mul, Finset.sum_add_distrib, ← Finset.mul_sum]
  have hw : (∑ x : Cube6, (cube6Witness x : ℝ)) = 0 := by
    exact_mod_cast cube6_integer_witness_mean
  rw [cube6_real_annihilation coeff, hw]
  ring

/-- Even weak separation forces the entire affine raw predictor to vanish.
This excludes perfect classification under either fixed constant tie rule. -/
theorem cube6_weak_separator_is_zero (coeff : Cube6 → ℝ) (bias : ℝ)
    (hmargin : ∀ x : Cube6,
      0 ≤ (cube6Target x : ℝ) * (cube6RawPredictor coeff x + bias)) :
    ∀ x : Cube6, cube6RawPredictor coeff x + bias = 0 := by
  have hw (x : Cube6) : 0 < (cube6Target x : ℝ) * (cube6Witness x : ℝ) := by
    exact_mod_cast (cube6_integer_sign_certificate x).2
  have hy (x : Cube6) : (cube6Target x : ℝ) * (cube6Target x : ℝ) = 1 := by
    exact_mod_cast (cube6_integer_sign_certificate x).1
  have hp (x : Cube6) : 0 ≤ (cube6RawPredictor coeff x + bias) * (cube6Witness x : ℝ) := by
    have h := mul_nonneg (hmargin x) (hw x).le
    have heq : ((cube6Target x : ℝ) * (cube6RawPredictor coeff x + bias)) *
        ((cube6Target x : ℝ) * (cube6Witness x : ℝ)) =
        (cube6RawPredictor coeff x + bias) * (cube6Witness x : ℝ) := by
      calc
        _ = ((cube6Target x : ℝ) * (cube6Target x : ℝ)) *
            ((cube6RawPredictor coeff x + bias) * (cube6Witness x : ℝ)) := by ring
        _ = _ := by rw [hy x, one_mul]
    rwa [heq] at h
  intro x
  have hle := Finset.single_le_sum (s := Finset.univ)
    (f := fun x : Cube6 => (cube6RawPredictor coeff x + bias) * (cube6Witness x : ℝ))
    (fun x _ => hp x) (Finset.mem_univ x)
  rw [cube6_affine_annihilation coeff bias] at hle
  have hz := le_antisymm hle (hp x)
  have hwne : (cube6Witness x : ℝ) ≠ 0 := by
    intro hzero
    have h := hw x
    rw [hzero, mul_zero] at h
    exact (lt_irrefl 0) h
  exact (mul_eq_zero.mp hz).resolve_right hwne

/-- Positive ties cannot make an affine raw readout classify every point. -/
theorem cube6_positive_tie_classification_impossible (coeff : Cube6 → ℝ) (bias : ℝ) :
    ¬ (∀ x : Cube6, (0 ≤ cube6RawPredictor coeff x + bias) ↔ cube6Target x = 1) := by
  intro hcorrect
  have hmargin (x : Cube6) :
      0 ≤ (cube6Target x : ℝ) * (cube6RawPredictor coeff x + bias) := by
    rcases cube6_integer_target_values x with hpos | hneg
    · have hg := (hcorrect x).2 hpos
      norm_cast
      rw [hpos]
      simpa using hg
    · have hnot : ¬ cube6Target x = 1 := by omega
      have hg : cube6RawPredictor coeff x + bias < 0 := lt_of_not_ge
        (fun h => hnot ((hcorrect x).1 h))
      rw [hneg]
      push_cast
      nlinarith
  have hz := cube6_weak_separator_is_zero coeff bias hmargin (1 : Cube6)
  have hvalue : cube6Target (1 : Cube6) = -1 := by decide
  have hbad := (hcorrect (1 : Cube6)).1 (by rw [hz])
  omega

/-- Negative ties likewise cannot make an affine raw readout perfect. -/
theorem cube6_negative_tie_classification_impossible (coeff : Cube6 → ℝ) (bias : ℝ) :
    ¬ (∀ x : Cube6, (0 < cube6RawPredictor coeff x + bias) ↔ cube6Target x = 1) := by
  intro hcorrect
  have hmargin (x : Cube6) :
      0 ≤ (cube6Target x : ℝ) * (cube6RawPredictor coeff x + bias) := by
    rcases cube6_integer_target_values x with hpos | hneg
    · have hg := (hcorrect x).2 hpos
      rw [hpos]
      push_cast
      nlinarith
    · have hnot : ¬ cube6Target x = 1 := by omega
      have hg : cube6RawPredictor coeff x + bias ≤ 0 := le_of_not_gt
        (fun h => hnot ((hcorrect x).1 h))
      rw [hneg]
      push_cast
      nlinarith
  have hz := cube6_weak_separator_is_zero coeff bias hmargin (0 : Cube6)
  have hvalue : cube6Target (0 : Cube6) = 1 := by decide
  have hbad := (hcorrect (0 : Cube6)).2 hvalue
  rw [hz] at hbad
  exact (lt_irrefl 0) hbad

end IndependentResearch
