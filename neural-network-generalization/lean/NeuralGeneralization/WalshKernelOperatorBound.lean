import NeuralGeneralization.NeuralSpectrumMonotone

/-! Deterministic operator and masked-row estimates for the actual Walsh
kernel. These supply concrete inputs to random-restriction concentration. -/
noncomputable section
namespace NeuralGeneralization
open scoped BigOperators
open Classical
attribute [local instance] Classical.propDecidable

variable {d : ℕ}

/-- Actual matrix action in normalized population Fourier coordinates. -/
theorem walshKernel_action (w : Finset (Fin d) → ℝ) (u : ClippingCube d → ℝ)
    (x : ClippingCube d) :
    (∑ y, walshKernel w x y*u y) =
      (Fintype.card (ClippingCube d):ℝ)*
        walshExpansion (fun S => w S*walshCoefficients u S) x := by
  unfold walshKernel featureKernel walshExpansion walshCoefficients uniformCubeMean
  simp_rw [Finset.sum_mul]
  rw [Finset.sum_comm, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro S _
  have hc : (Fintype.card (ClippingCube d):ℝ) ≠ 0 := by positivity
  calc
    _ = (w S*walshCharacter S x)*(∑ y,u y*walshCharacter S y) := by
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro y _
      ring
    _ = _ := by field_simp

/-- Exact squared matrix action, with all factors of the cube cardinality
shown explicitly. -/
theorem walshKernel_square_action (w : Finset (Fin d) → ℝ) (u : ClippingCube d → ℝ) :
    (∑ x, (∑ y,walshKernel w x y*u y)^2) =
      (Fintype.card (ClippingCube d):ℝ)^3*
        ∑ S,(w S*walshCoefficients u S)^2 := by
  simp_rw [walshKernel_action, mul_pow]
  rw [← Finset.mul_sum, walshExpansion_parseval]
  ring

/-- The actual Euclidean operator norm is at most cube-size times the
largest absolute population eigenvalue. This is proved from Parseval. -/
theorem walshKernel_square_action_le (w : Finset (Fin d) → ℝ) (ell : ℝ)
    (hell : 0 ≤ ell) (hw : ∀ S, |w S| ≤ ell) (u : ClippingCube d → ℝ) :
    (∑ x, (∑ y,walshKernel w x y*u y)^2) ≤
      ((Fintype.card (ClippingCube d):ℝ)*ell)^2*∑ x,u x^2 := by
  have hcoeff := walshExpansion_parseval (walshCoefficients u)
  simp_rw [walshExpansion_coefficients] at hcoeff
  have hspec : (∑ S,(w S*walshCoefficients u S)^2) ≤
      ell^2*∑ S,walshCoefficients u S^2 := by
    rw [Finset.mul_sum]
    apply Finset.sum_le_sum
    intro S _
    rw [mul_pow]
    apply mul_le_mul_of_nonneg_right _ (sq_nonneg _)
    have h := (sq_le_sq₀ (abs_nonneg (w S)) hell).mpr (hw S)
    simpa only [sq_abs] using h
  rw [walshKernel_square_action, hcoeff]
  have hh := mul_le_mul_of_nonneg_left hspec
    (show (0:ℝ) ≤ (Fintype.card (ClippingCube d):ℝ)^3 by positivity)
  convert hh using 1 <;> first | rfl | ring

/-- Every entry of a nonnegative Walsh kernel is bounded by its trace. -/
theorem walshKernel_abs_le_trace (w : Finset (Fin d) → ℝ) (hw : ∀ S,0 ≤ w S)
    (x y : ClippingCube d) : |walshKernel w x y| ≤ ∑ S,w S := by
  unfold walshKernel featureKernel
  apply (Finset.abs_sum_le_sum_abs _ _).trans
  apply Finset.sum_le_sum
  intro S _
  have hx : |walshCharacter S x|=1 := by
    have hs := walshCharacter_sq S x
    nlinarith [sq_abs (walshCharacter S x),abs_nonneg (walshCharacter S x)]
  have hy : |walshCharacter S y|=1 := by
    have hs := walshCharacter_sq S y
    nlinarith [sq_abs (walshCharacter S y),abs_nonneg (walshCharacter S y)]
  simp only [abs_mul,abs_of_nonneg (hw S),hx,hy,mul_one,le_refl]

/-- An entry mask can only decrease a squared row sum. -/
theorem masked_square_row_le {X Y : Type*} [Fintype Y]
    (K : X → Y → ℝ) (keep : X → Y → Prop) [DecidableRel keep] (x : X) :
    (∑ y,(if keep x y then K x y else 0)^2) ≤ ∑ y,K x y^2 := by
  apply Finset.sum_le_sum
  intro y _
  split_ifs
  · exact le_rfl
  · simpa using sq_nonneg (K x y)

/-- Removing at most `b` entries of magnitude at most `tau` in each row
has the stated absolute row-sum cost. -/
theorem masked_abs_row_le {X Y : Type*} [Fintype Y]
    (K : X → Y → ℝ) (keep : X → Y → Prop) [DecidableRel keep]
    (tau b : ℝ) (htau : 0 ≤ tau) (hK : ∀ x y,|K x y| ≤ tau)
    (hcount : ∀ x, ((Finset.univ.filter (keep x)).card:ℝ) ≤ b) (x : X) :
    (∑ y,|if keep x y then K x y else 0|) ≤ tau*b := by
  calc
    _ ≤ ∑ y,if keep x y then tau else 0 := by
      apply Finset.sum_le_sum
      intro y _
      split_ifs
      · exact hK x y
      · simp
    _ = tau*((Finset.univ.filter (keep x)).card:ℝ) := by
      rw [← Finset.sum_filter]
      simp [mul_comm]
    _ ≤ _ := mul_le_mul_of_nonneg_left (hcount x) htau

/-- Finite Schur test, proved directly by weighted Cauchy--Schwarz.
Both rectangular and symmetric matrices are included. -/
theorem square_action_le_of_abs_row_column {X Y : Type*} [Fintype X] [Fintype Y]
    (A : X → Y → ℝ) (B : ℝ) (hB : 0 ≤ B)
    (hrow : ∀ x,(∑ y,|A x y|) ≤ B) (hcol : ∀ y,(∑ x,|A x y|) ≤ B)
    (u : Y → ℝ) :
    (∑ x,(∑ y,A x y*u y)^2) ≤ B^2*∑ y,u y^2 := by
  have hx (x : X) : (∑ y,A x y*u y)^2 ≤ B*∑ y,|A x y| *u y^2 := by
    have hcs := Finset.sum_sq_le_sum_mul_sum_of_sq_le_mul Finset.univ
      (fun y _ => abs_nonneg (A x y))
      (fun y _ => mul_nonneg (abs_nonneg (A x y)) (sq_nonneg (u y)))
      (fun y _ => show (A x y*u y)^2 ≤ |A x y| *(|A x y| *u y^2) by
        rw [mul_pow]
        nlinarith only [sq_abs (A x y)])
    exact hcs.trans (mul_le_mul_of_nonneg_right (hrow x)
      (Finset.sum_nonneg (fun y _ => mul_nonneg (abs_nonneg _) (sq_nonneg _))))
  apply (Finset.sum_le_sum (fun x _ => hx x)).trans
  rw [← Finset.mul_sum, Finset.sum_comm]
  have hinner : (∑ y,∑ x,|A x y| *u y^2) ≤ B*∑ y,u y^2 := by
    rw [Finset.mul_sum]
    apply Finset.sum_le_sum
    intro y _
    rw [← Finset.sum_mul]
    exact mul_le_mul_of_nonneg_right (hcol y) (sq_nonneg _)
  have hh := mul_le_mul_of_nonneg_left hinner hB
  simpa only [pow_two,mul_assoc] using hh

end NeuralGeneralization
