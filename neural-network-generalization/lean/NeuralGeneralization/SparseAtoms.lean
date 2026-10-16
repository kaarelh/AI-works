import NeuralGeneralization.BoundedDual
import Mathlib.Algebra.BigOperators.Field
import Mathlib.Data.Fintype.BigOperators
import Mathlib.Data.Fintype.Option
import Mathlib.Tactic.FieldSimp

/-!
# The finite atom distribution for sparse dual approximation

There are exactly 2D+1 atoms, independent of the parameter being
approximated. For each point of the ℓ¹ ball we give explicit nonnegative
probability weights on those atoms and prove their barycenter is that point.
-/

noncomputable section

open scoped BigOperators

namespace NeuralGeneralization.SparseAtoms

open BoundedDual

abbrev Atom (ι : Type*) := Option (ι × Bool)

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

def vector (G : ℝ) : Atom ι → (ι → ℝ)
  | none => 0
  | some (i, b) => fun j => if j = i then (if b then G else -G) else 0

def weight (G : ℝ) (lam : ι → ℝ) : Atom ι → ℝ
  | none => 1 - entryL1 lam / G
  | some (i, b) => (if b then max (lam i) 0 else max (-lam i) 0) / G

omit [Fintype ι] [DecidableEq ι] in
lemma positive_negative_sum (a : ℝ) : max a 0 + max (-a) 0 = |a| := by
  by_cases ha : 0 ≤ a
  · rw [max_eq_left ha, max_eq_right (neg_nonpos.mpr ha), abs_of_nonneg ha, add_zero]
  · have h := (lt_of_not_ge ha).le
    rw [max_eq_right h, max_eq_left (neg_nonneg.mpr h), abs_of_nonpos h, zero_add]

omit [Fintype ι] [DecidableEq ι] in
lemma positive_negative_sub (a : ℝ) : max a 0 - max (-a) 0 = a := by
  by_cases ha : 0 ≤ a
  · rw [max_eq_left ha, max_eq_right (neg_nonpos.mpr ha), sub_zero]
  · have h := (lt_of_not_ge ha).le
    rw [max_eq_right h, max_eq_left (neg_nonneg.mpr h)]
    ring

omit [DecidableEq ι] in
theorem atom_count : Fintype.card (Atom ι) = 2 * Fintype.card ι + 1 := by
  simp only [Atom, Fintype.card_option, Fintype.card_prod, Fintype.card_bool]
  ring

omit [DecidableEq ι] in
theorem weight_nonneg {G : ℝ} (hG : 0 < G) (lam : ι → ℝ)
    (hlam : entryL1 lam ≤ G) (a : Atom ι) : 0 ≤ weight G lam a := by
  cases a with
  | none =>
      change 0 ≤ 1 - entryL1 lam / G
      exact sub_nonneg.mpr ((div_le_one hG).2 hlam)
  | some p =>
      rcases p with ⟨i, b⟩
      cases b <;> exact div_nonneg (le_max_right _ _) hG.le

omit [DecidableEq ι] in
theorem sum_weight (G : ℝ) (lam : ι → ℝ) :
    ∑ a : Atom ι, weight G lam a = 1 := by
  simp only [Fintype.sum_option, Fintype.sum_prod_type, Fintype.sum_bool, weight]
  simp only [Bool.false_eq_true, ite_false, ite_true]
  simp only [← add_div, positive_negative_sum, ← Finset.sum_div]
  change 1 - entryL1 lam / G + entryL1 lam / G = 1
  ring

theorem mean_vector {G : ℝ} (hG : 0 < G) (lam : ι → ℝ) (i : ι) :
    (∑ a : Atom ι, weight G lam a * vector G a i) = lam i := by
  simp only [Fintype.sum_option, Fintype.sum_prod_type, Fintype.sum_bool,
    weight, vector, Pi.zero_apply, mul_zero, zero_add]
  rw [Finset.sum_eq_single i]
  · simp only [ite_true]
    calc
      max (lam i) 0 / G * G + max (-lam i) 0 / G * -G =
          max (lam i) 0 - max (-lam i) 0 := by
        rw [mul_neg, div_mul_cancel₀ _ hG.ne', div_mul_cancel₀ _ hG.ne']
        ring
      _ = lam i := positive_negative_sub _
  · intro j hj hji
    simp [Ne.symm hji]
  · intro hi
    exact False.elim (hi (Finset.mem_univ i))

theorem mean_pairing {G : ℝ} (hG : 0 < G) (lam z : ι → ℝ) :
    (∑ a : Atom ι, weight G lam a * pairing (vector G a) z) = pairing lam z := by
  simp only [pairing, Finset.mul_sum]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro i hi
  calc
    (∑ a : Atom ι, weight G lam a * (vector G a i * z i)) =
        (∑ a : Atom ι, weight G lam a * vector G a i) * z i := by
      simp only [Finset.sum_mul, mul_assoc]
    _ = lam i * z i := by rw [mean_vector hG]

theorem vector_entryL1_le {G : ℝ} (hG : 0 ≤ G) (a : Atom ι) :
    entryL1 (vector G a) ≤ G := by
  cases a with
  | none => simpa only [vector, entryL1, Pi.zero_apply, abs_zero, Finset.sum_const_zero] using hG
  | some p =>
      rcases p with ⟨i, b⟩
      cases b <;> simp [vector, entryL1, abs_ite, abs_of_nonneg hG]

theorem abs_pairing_vector_le {G : ℝ} (hG : 0 ≤ G)
    (z : ι → ℝ) (hz : ∀ i, |z i| ≤ 1) (a : Atom ι) :
    |pairing (vector G a) z| ≤ G := by
  calc
    |pairing (vector G a) z| ≤ ∑ i, |vector G a i * z i| :=
      Finset.abs_sum_le_sum_abs _ _
    _ ≤ entryL1 (vector G a) := by
      apply Finset.sum_le_sum
      intro i hi
      rw [abs_mul]
      exact (mul_le_mul_of_nonneg_left (hz i) (abs_nonneg _)).trans_eq (mul_one _)
    _ ≤ G := vector_entryL1_le hG a

/-- The average of s atoms, as a vector in the same coordinate space. -/
def average (G : ℝ) (s : ℕ) (a : Fin s → Atom ι) (i : ι) : ℝ :=
  (∑ j, vector G (a j) i) / (s : ℝ)

theorem pairing_average (G : ℝ) (s : ℕ) (a : Fin s → Atom ι) (z : ι → ℝ) :
    pairing (average G s a) z = (∑ j, pairing (vector G (a j)) z) / (s : ℝ) := by
  unfold pairing average
  simp only [div_mul_eq_mul_div, ← Finset.sum_div, Finset.sum_mul]
  rw [Finset.sum_comm]

theorem pairing_average_sub (G : ℝ) {s : ℕ} (hs : 0 < s)
    (a : Fin s → Atom ι) (lam z : ι → ℝ) :
    pairing (average G s a - lam) z =
      ((∑ j, pairing (vector G (a j)) z) - (s : ℝ) * pairing lam z) / (s : ℝ) := by
  have hsR : (s : ℝ) ≠ 0 := by exact_mod_cast hs.ne'
  rw [pairing_sub_left, pairing_average, sub_div, mul_div_cancel_left₀ _ hsR]

/-- The deterministic sparse family, independent of the approximated point. -/
def grid (G : ℝ) (s : ℕ) : Finset (ι → ℝ) := by
  classical
  exact Finset.univ.image (average G s)

theorem average_mem_grid (G : ℝ) (s : ℕ) (a : Fin s → Atom ι) :
    average G s a ∈ grid G s := by
  classical
  exact Finset.mem_image.mpr ⟨a, Finset.mem_univ _, rfl⟩

theorem grid_card_le (G : ℝ) (s : ℕ) :
    (grid (ι := ι) G s).card ≤ (2 * Fintype.card ι + 1) ^ s := by
  classical
  calc
    (grid (ι := ι) G s).card ≤ (Finset.univ : Finset (Fin s → Atom ι)).card :=
      Finset.card_image_le
    _ = (2 * Fintype.card ι + 1) ^ s := by
      simp only [Finset.card_univ, Fintype.card_fun, Fintype.card_fin, atom_count]

theorem average_entryL1_le {G : ℝ} (hG : 0 ≤ G) {s : ℕ} (hs : 0 < s)
    (a : Fin s → Atom ι) : entryL1 (average G s a) ≤ G := by
  have hsR : 0 < (s : ℝ) := by exact_mod_cast hs
  calc
    entryL1 (average G s a) = ∑ i, |∑ j, vector G (a j) i| / (s : ℝ) := by
      simp only [entryL1, average, abs_div, abs_of_pos hsR]
    _ ≤ ∑ i, (∑ j, |vector G (a j) i|) / (s : ℝ) := by
      apply Finset.sum_le_sum
      intro i hi
      exact div_le_div_of_nonneg_right (Finset.abs_sum_le_sum_abs _ _) hsR.le
    _ = (∑ j, entryL1 (vector G (a j))) / (s : ℝ) := by
      rw [← Finset.sum_div, Finset.sum_comm]
      rfl
    _ ≤ ((s : ℝ) * G) / (s : ℝ) := by
      apply div_le_div_of_nonneg_right _ hsR.le
      calc
        (∑ j, entryL1 (vector G (a j))) ≤ ∑ _j : Fin s, G :=
          Finset.sum_le_sum (fun j _ => vector_entryL1_le hG (a j))
        _ = (s : ℝ) * G := by simp
    _ = G := mul_div_cancel_left₀ G hsR.ne'

theorem grid_entryL1_le {G : ℝ} (hG : 0 ≤ G) {s : ℕ} (hs : 0 < s)
    {v : ι → ℝ} (hv : v ∈ grid G s) : entryL1 v ≤ G := by
  classical
  obtain ⟨a, _, rfl⟩ := Finset.mem_image.mp hv
  exact average_entryL1_le hG hs a

end NeuralGeneralization.SparseAtoms

end
