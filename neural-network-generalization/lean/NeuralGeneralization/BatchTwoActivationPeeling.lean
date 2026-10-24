import NeuralGeneralization.BatchTwoActivationBoundedContraction
import Mathlib.Analysis.InnerProductSpace.PiL2

/-!
# Width-free Frobenius row peeling

This proves the actual exponential-moment inequality for a layer whose row
norms have total squared mass at most one. It is the deterministic geometry
plus convex contraction behind the ReLU capacity bound. No capacity theorem
or expected-process estimate is assumed.
-/

noncomputable section
open scoped BigOperators RealInnerProductSpace

namespace NeuralGeneralization.BatchTwoActivation
open SquaredSampling

variable {U E : Type*} [Nonempty U]
  [NormedAddCommGroup E] [InnerProductSpace ℝ E]

theorem abs_sign (b : Bool) : |cubeCoordinateSign b| = 1 := by
  cases b <;> norm_num [cubeCoordinateSign]

theorem signed_vector_sum_norm_le {n : ℕ} (h : Fin n → E) {R : ℝ}
    (hh : ∀ i, ‖h i‖ ≤ R) (ε : Fin n → Bool) :
    ‖∑ i, cubeCoordinateSign (ε i) • h i‖ ≤ (n : ℝ) * R := by
  apply (norm_sum_le _ _).trans
  calc
    _ ≤ ∑ _i : Fin n, R := by
      apply Finset.sum_le_sum
      intro i _
      simpa only [norm_smul, Real.norm_eq_abs, abs_sign, one_mul] using hh i
    _ = _ := by simp

def vectorProcess {n : ℕ} (h : U → Fin n → E) (ε : Fin n → Bool) : ℝ :=
  processSup (fun u => ‖∑ i, cubeCoordinateSign (ε i) • h u i‖)

theorem vectorProcess_le {n : ℕ} (h : U → Fin n → E) {R : ℝ}
    (hh : ∀ u i, ‖h u i‖ ≤ R) (ε : Fin n → Bool) :
    vectorProcess h ε ≤ (n : ℝ)*R :=
  processSup_le _ (fun u => signed_vector_sum_norm_le (h u) (hh u) ε)

theorem norm_le_vectorProcess {n : ℕ} (h : U → Fin n → E) {R : ℝ}
    (hh : ∀ u i, ‖h u i‖ ≤ R) (ε : Fin n → Bool) (u : U) :
    ‖∑ i, cubeCoordinateSign (ε i) • h u i‖ ≤ vectorProcess h ε :=
  le_processSup _ (fun u => signed_vector_sum_norm_le (h u) (hh u) ε) u

variable {J : Type*} [Fintype J] [Nonempty J]

/-- A literal finite layer, with its row length separated from its unit
direction. For ReLU this is exactly the result of normalizing every row. -/
def normalizedRowLayer (φ : ℝ → ℝ) (r : U → J → ℝ) (u : U → J → E)
    (h : U → Fin n → E) : U → Fin n → EuclideanSpace ℝ J :=
  fun p i => WithLp.toLp 2 (fun j => r p j * φ ⟪u p j, h p i⟫)

theorem linearRow_abs_le (u : E) (hu : ‖u‖ ≤ 1) (h : E) {R : ℝ}
    (hh : ‖h‖ ≤ R) : |⟪u,h⟫| ≤ R := by
  calc
    _ ≤ ‖u‖ * ‖h‖ := abs_real_inner_le_norm _ _
    _ ≤ 1 * ‖h‖ := mul_le_mul_of_nonneg_right hu (norm_nonneg _)
    _ ≤ R := by simpa using hh

/-- The Euclidean row collapse uses only the sum of squared row lengths;
there is no factor depending on the number of rows. -/
theorem normalizedRowLayer_process_le {n : ℕ}
    (φ : ℝ → ℝ) (hzero : φ 0 = 0)
    (hLip : ∀ x y, |φ x - φ y| ≤ |x-y|)
    (r : U → J → ℝ) (u : U → J → E) (h : U → Fin n → E)
    (hr : ∀ p, (∑ j, r p j ^ 2) ≤ 1) (hu : ∀ p j, ‖u p j‖ ≤ 1)
    {R : ℝ} (hh : ∀ p i, ‖h p i‖ ≤ R) (ε : Fin n → Bool) :
    vectorProcess (normalizedRowLayer φ r u h) ε ≤
      envelope (fun pj : U × J => ∑ i, cubeCoordinateSign (ε i) * φ ⟪u pj.1 pj.2, h pj.1 i⟫) := by
  let T : U × J → ℝ := fun pj =>
    ∑ i, cubeCoordinateSign (ε i) * φ ⟪u pj.1 pj.2, h pj.1 i⟫
  have hT (pj : U × J) : |T pj| ≤ (n : ℝ)*R := by
    apply signed_sum_abs_le
    intro i
    have hz := hLip ⟪u pj.1 pj.2, h pj.1 i⟫ 0
    simp only [hzero, sub_zero] at hz
    exact hz.trans (linearRow_abs_le _ (hu _ _) _ (hh _ _))
  have hM := envelope_nonneg T hT
  apply processSup_le
  intro p
  have hcoord (j : J) :
      (∑ i, cubeCoordinateSign (ε i) • normalizedRowLayer φ r u h p i) j =
        r p j * T (p,j) := by
    simp only [WithLp.ofLp_sum, Finset.sum_apply, WithLp.ofLp_smul, Pi.smul_apply, normalizedRowLayer,
      WithLp.ofLp_toLp, smul_eq_mul, T]
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro i _
    ring
  have hsq : ‖∑ i, cubeCoordinateSign (ε i) • normalizedRowLayer φ r u h p i‖^2 ≤
      (envelope T)^2 := by
    rw [EuclideanSpace.real_norm_sq_eq]
    simp_rw [hcoord, mul_pow]
    calc
      _ ≤ ∑ j, r p j ^ 2 * (envelope T)^2 := by
        apply Finset.sum_le_sum
        intro j _
        have ht := le_envelope T hT (p,j)
        have hs : T (p,j)^2 ≤ (envelope T)^2 := by
          simpa only [sq_abs] using pow_le_pow_left₀ (abs_nonneg (T (p,j))) ht 2
        exact mul_le_mul_of_nonneg_left hs (sq_nonneg _)
      _ = (∑ j, r p j^2) * (envelope T)^2 := by rw [Finset.sum_mul]
      _ ≤ 1 * (envelope T)^2 := mul_le_mul_of_nonneg_right (hr p) (sq_nonneg _)
      _ = _ := one_mul _
  nlinarith [norm_nonneg (∑ i, cubeCoordinateSign (ε i) • normalizedRowLayer φ r u h p i)]

theorem linearRow_process_le {n : ℕ} (u : U → J → E) (h : U → Fin n → E)
    (hu : ∀ p j, ‖u p j‖ ≤ 1) {R : ℝ} (hh : ∀ p i, ‖h p i‖ ≤ R)
    (ε : Fin n → Bool) :
    envelope (fun pj : U × J => ∑ i, cubeCoordinateSign (ε i) * ⟪u pj.1 pj.2, h pj.1 i⟫) ≤
      vectorProcess h ε := by
  apply envelope_le
  intro pj
  have heq : (∑ i, cubeCoordinateSign (ε i) * ⟪u pj.1 pj.2, h pj.1 i⟫) =
      ⟪u pj.1 pj.2, ∑ i, cubeCoordinateSign (ε i) • h pj.1 i⟫ := by
    simp only [inner_sum, real_inner_smul_right]
  rw [heq]
  exact linearRow_abs_le _ (hu _ _) _ (norm_le_vectorProcess h hh ε pj.1)

/-- The exponential peeling step, uniformly over the class of preceding
features and the number of neurons in the new layer. -/
theorem normalizedRowLayer_exp_peeling {n : ℕ}
    (φ : ℝ → ℝ) (hzero : φ 0 = 0)
    (hLip : ∀ x y, |φ x - φ y| ≤ |x-y|)
    (r : U → J → ℝ) (u : U → J → E) (h : U → Fin n → E)
    (hr : ∀ p, (∑ j, r p j ^ 2) ≤ 1) (hu : ∀ p j, ‖u p j‖ ≤ 1)
    {R : ℝ} (hh : ∀ p i, ‖h p i‖ ≤ R) (a : ℝ) (ha : 0 ≤ a) :
    finiteMean (fun ε : Fin n → Bool =>
      Real.exp (a * vectorProcess (normalizedRowLayer φ r u h) ε)) ≤
      2 * finiteMean (fun ε : Fin n → Bool => Real.exp (a * vectorProcess h ε)) := by
  have hfirst := finiteMean_mono (fun ε : Fin n → Bool => Real.exp_le_exp.mpr
    (mul_le_mul_of_nonneg_left (normalizedRowLayer_process_le φ hzero hLip r u h hr hu hh ε) ha))
  have hcontract := bounded_rademacher_exp_contraction n (fun _ => φ)
    (fun _ => hzero) (fun _ => hLip)
    (fun pj : U × J => fun i => ⟪u pj.1 pj.2, h pj.1 i⟫)
    (fun pj i => linearRow_abs_le _ (hu _ _) _ (hh _ _)) a ha
  have hlast := finiteMean_mono (fun ε : Fin n → Bool => Real.exp_le_exp.mpr
    (mul_le_mul_of_nonneg_left (linearRow_process_le u h hu hh ε) ha))
  exact hfirst.trans (hcontract.trans (mul_le_mul_of_nonneg_left hlast (by norm_num)))

end NeuralGeneralization.BatchTwoActivation
