import NeuralGeneralization.KernelEnergy
import NeuralGeneralization.OnlineLowerGeometryCore

/-!
# Walsh specializations of the online lower-bound geometry

This file uses the repository's existing `ClippingCube`, Walsh transform,
and uniform cube mean.  In particular it does not introduce a second
Boolean or Fourier model.
-/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerGeometry

/-- Translation in the sign cube.  The all-true point is the identity,
because the existing coordinate-sign convention sends `true` to `+1`.
This is pointwise multiplication of signs, expressed as a permutation
of the existing Boolean cube. -/
def cubeTranslation {d : ℕ} (t : ClippingCube d) : ClippingCube d ≃ ClippingCube d where
  toFun x i := if t i then x i else !(x i)
  invFun x i := if t i then x i else !(x i)
  left_inv x := by
    funext i
    cases h : t i <;> simp [h]
  right_inv x := by
    funext i
    cases h : t i <;> simp [h]

theorem cubeTranslation_involutive {d : ℕ} (t x : ClippingCube d) :
    cubeTranslation t (cubeTranslation t x) = x := by
  exact (cubeTranslation t).symm_apply_apply x

theorem cubeCoordinateSign_translation {d : ℕ} (t x : ClippingCube d) (i : Fin d) :
    cubeCoordinateSign (cubeTranslation t x i) =
      cubeCoordinateSign (t i) * cubeCoordinateSign (x i) := by
  cases ht : t i <;> cases hx : x i <;>
    norm_num [cubeTranslation, cubeCoordinateSign, ht, hx]

theorem walshCharacter_translation {d : ℕ} (t x : ClippingCube d)
    (S : Finset (Fin d)) :
    walshCharacter S (cubeTranslation t x) =
      walshCharacter S t * walshCharacter S x := by
  simp only [walshCharacter, cubeCoordinateSign_translation, Finset.prod_mul_distrib]

theorem walshCoefficients_expansion {d : ℕ} (a : Finset (Fin d) → ℝ)
    (S : Finset (Fin d)) :
    walshCoefficients (walshExpansion a) S = a S := by
  have hM : (Fintype.card (ClippingCube d) : ℝ) ≠ 0 :=
    ne_of_gt (Nat.cast_pos.mpr Fintype.card_pos)
  unfold walshCoefficients uniformCubeMean
  rw [walshExpansion_pairing]
  field_simp

theorem walshCoefficients_add {d : ℕ} (F G : ClippingCube d → ℝ)
    (S : Finset (Fin d)) :
    walshCoefficients (fun x => F x + G x) S =
      walshCoefficients F S + walshCoefficients G S := by
  simp only [walshCoefficients, uniformCubeMean, add_mul, Finset.sum_add_distrib, add_div]

theorem walshCoefficients_const {d : ℕ} (c : ℝ) (S : Finset (Fin d)) :
    walshCoefficients (fun _ : ClippingCube d => c) S = if S = ∅ then c else 0 := by
  have hM : (Fintype.card (ClippingCube d) : ℝ) ≠ 0 :=
    ne_of_gt (Nat.cast_pos.mpr Fintype.card_pos)
  have hsum : (∑ x : ClippingCube d, walshCharacter S x) =
      if S = ∅ then (Fintype.card (ClippingCube d) : ℝ) else 0 := by
    simpa only [walshCharacter, Finset.prod_empty, mul_one] using
      walshCharacter_orthogonal S ∅
  unfold walshCoefficients uniformCubeMean
  rw [← Finset.mul_sum, hsum]
  by_cases hS : S = ∅ <;> simp [hS, hM]

theorem walshCoefficients_character {d : ℕ} (T S : Finset (Fin d)) :
    walshCoefficients (walshCharacter T) S = if T = S then 1 else 0 := by
  have hM : (Fintype.card (ClippingCube d) : ℝ) ≠ 0 :=
    ne_of_gt (Nat.cast_pos.mpr Fintype.card_pos)
  unfold walshCoefficients uniformCubeMean
  rw [walshCharacter_orthogonal]
  by_cases h : T = S <;> simp [h, hM]

def pointIndicator {d : ℕ} (v x : ClippingCube d) : ℝ := if x = v then 1 else 0

theorem walshCoefficients_pointIndicator {d : ℕ} (v : ClippingCube d)
    (S : Finset (Fin d)) :
    walshCoefficients (pointIndicator v) S =
      walshCharacter S v / Fintype.card (ClippingCube d) := by
  simp [walshCoefficients, uniformCubeMean, pointIndicator, ite_mul]

/-- The exact normalized Fourier pairing identity. -/
theorem walsh_inner_identity {d : ℕ} (F G : ClippingCube d → ℝ) :
    uniformCubeMean (fun x => F x * G x) =
      ∑ S, walshCoefficients F S * walshCoefficients G S := by
  have hM : (Fintype.card (ClippingCube d) : ℝ) ≠ 0 :=
    ne_of_gt (Nat.cast_pos.mpr Fintype.card_pos)
  have h := walshExpansion_inner (walshCoefficients F) (walshCoefficients G)
  simp only [walshExpansion_coefficients] at h
  unfold uniformCubeMean
  rw [h]
  field_simp

def weightedWalshCost {d : ℕ} (w : Finset (Fin d) → ℝ)
    (F : ClippingCube d → ℝ) : ℝ := weightedL1 w (walshCoefficients F)

/-- A genuine physical score-space dual bound, using the existing Walsh
transform rather than treating Fourier coefficients as unrelated variables. -/
theorem walsh_dual_bound {d : ℕ} (w : Finset (Fin d) → ℝ)
    (F dual : ClippingCube d → ℝ)
    (hdual : ∀ S, |walshCoefficients dual S| ≤ w S) :
    uniformCubeMean (fun x => dual x * F x) ≤ weightedWalshCost w F := by
  rw [walsh_inner_identity]
  exact dual_pairing_le_weightedL1 w (walshCoefficients F) (walshCoefficients dual) hdual

/-- Walsh coefficients diagonalize cube translations. -/
theorem walshCoefficients_translation {d : ℕ} (t : ClippingCube d)
    (F : ClippingCube d → ℝ) (S : Finset (Fin d)) :
    walshCoefficients (fun x => F (cubeTranslation t x)) S =
      walshCharacter S t * walshCoefficients F S := by
  have hsum := (cubeTranslation t).sum_comp
    (fun x => F (cubeTranslation t x) * walshCharacter S x)
  simp only [cubeTranslation_involutive, walshCharacter_translation] at hsum
  have hfactor : (∑ x : ClippingCube d,
      F x * (walshCharacter S t * walshCharacter S x)) =
      walshCharacter S t * ∑ x : ClippingCube d, F x * walshCharacter S x := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro x _
    ring
  rw [hfactor] at hsum
  unfold walshCoefficients uniformCubeMean
  rw [← hsum]
  ring

/-- The generic independent-set argument specializes to translation by
any cube point, including every physical code column. -/
theorem cube_translation_observability {d : ℕ} (t : ClippingCube d)
    (J : Set (ClippingCube d)) (q : ClippingCube d → ℝ)
    (hq : ∀ x, 0 ≤ q x)
    (hinv : ∀ x, q (cubeTranslation t x) = q x)
    (hind : ∀ x, x ∈ J → cubeTranslation t x ∉ J) :
    uniformCubeMean q ≤
      2 * uniformCubeMean (fun x => if x ∉ J then q x else 0) := by
  classical
  have h := independent_set_observability (cubeTranslation t) J q hq hinv hind
  have hdiv := div_le_div_of_nonneg_right h
    (Nat.cast_nonneg (Fintype.card (ClippingCube d)) :
      (0 : ℝ) ≤ Fintype.card (ClippingCube d))
  simpa only [uniformCubeMean, mul_div_assoc] using hdiv

end NeuralGeneralization.OnlineLowerGeometry
