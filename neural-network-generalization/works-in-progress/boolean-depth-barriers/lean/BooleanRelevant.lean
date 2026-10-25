import FreezeSigns
import SequentialMaurey

open scoped BigOperators RealInnerProductSpace

namespace BooleanDepthResearch
namespace BooleanRelevant

noncomputable section
open SignFreezing

variable {I E : Type*} [Fintype I] [DecidableEq I]
  [NormedAddCommGroup E] [InnerProductSpace ℝ E]

/-- A coordinate is relevant if changing only that coordinate can change the label. -/
def Relevant (f : (I → Bool) → Bool) (i : I) : Prop :=
  ∃ x y : I → Bool, (∀ j, j ≠ i → x j = y j) ∧ f x ≠ f y

def relevantSet (f : (I → Bool) → Bool) : Finset I := by
  classical
  exact Finset.univ.filter (Relevant f)

@[simp] theorem mem_relevantSet (f : (I → Bool) → Bool) (i : I) :
    i ∈ relevantSet f ↔ Relevant f i := by
  classical
  simp [relevantSet]

/-- A Boolean function depends only on its relevant coordinates. -/
theorem eq_of_agree_relevant (f : (I → Bool) → Bool) (x y : I → Bool)
    (h : ∀ i, Relevant f i → x i = y i) : f x = f y := by
  classical
  have aux (s : Finset I) : ∀ x y : I → Bool,
      (∀ i, i ∉ s → x i = y i) →
      (∀ i, Relevant f i → x i = y i) → f x = f y := by
    induction s using Finset.induction_on with
    | empty =>
      intro x y hout _
      congr 1
      funext i
      exact hout i (by simp)
    | @insert a s ha ih =>
      intro x y hout hrel
      let z := Function.update x a (y a)
      have hxz : f x = f z := by
        by_cases hr : Relevant f a
        · have hxa := hrel a hr
          have hz : z = x := by
            funext i
            by_cases hi : i = a
            · subst i; simp [z, ← hxa]
            · simp [z, hi]
          rw [hz]
        · by_contra hf
          apply hr
          exact ⟨x, z, fun j hj ↦ by simp [z, hj], hf⟩
      apply hxz.trans
      apply ih z y
      · intro i hi
        by_cases hia : i = a
        · subst i; simp [z]
        · simpa [z, hia] using hout i (by simp [hi, hia])
      · intro i hr
        by_cases hia : i = a
        · subst i; simp [z]
        · simpa [z, hia] using hrel i hr
  exact aux Finset.univ x y (by simp) h

/-- The affine input feature vector, with its actual bias and columns. -/
def affineCube (b : E) (v : I → E) (x : I → Bool) : E :=
  b + ∑ i, sign (x i) • v i

lemma affineCube_sub_of_agree_off (b : E) (v : I → E) (i : I)
    (x y : I → Bool) (h : ∀ j, j ≠ i → x j = y j) :
    affineCube b v x - affineCube b v y = (sign (x i) - sign (y i)) • v i := by
  classical
  simp only [affineCube, add_sub_add_left_eq_sub, ← Finset.sum_sub_distrib, ← sub_smul]
  apply Finset.sum_eq_single i
  · intro j _ hji
    rw [h j hji]
    simp
  · simp

lemma affineCube_dist_of_agree_off (b : E) (v : I → E) (i : I)
    (x y : I → Bool) (h : ∀ j, j ≠ i → x j = y j) :
    dist (affineCube b v x) (affineCube b v y) ≤ 2 * ‖v i‖ := by
  rw [dist_eq_norm, affineCube_sub_of_agree_off b v i x y h, norm_smul, Real.norm_eq_abs]
  apply mul_le_mul_of_nonneg_right _ (norm_nonneg _)
  calc
    |sign (x i) - sign (y i)| ≤ |sign (x i)| + |sign (y i)| := abs_sub _ _
    _ = 2 := by norm_num

lemma output_separation (g : (I → Bool) → ℝ) (f : (I → Bool) → Bool)
    (hm : ∀ x, 1 ≤ sign (f x) * g x) (x y : I → Bool) (hxy : f x ≠ f y) :
    2 ≤ dist (g x) (g y) := by
  have hx := hm x
  have hy := hm y
  rw [Real.dist_eq]
  cases hfx : f x <;> cases hfy : f y <;> simp_all [sign]
  · exact le_trans (by linarith) (neg_le_abs _)
  · exact le_trans (by linarith) (le_abs_self _)

/-- Unit margin plus a T-Lipschitz suffix forces each relevant input column
    to have norm at least 1/T. -/
theorem relevant_column_bound (b : E) (v : I → E) (G : E → ℝ) (T : NNReal)
    (hG : LipschitzWith T G) (f : (I → Bool) → Bool)
    (hm : ∀ x, 1 ≤ sign (f x) * G (affineCube b v x))
    (i : I) (hi : Relevant f i) : 1 ≤ (T : ℝ) * ‖v i‖ := by
  obtain ⟨x, y, hxy, hf⟩ := hi
  have hsep := output_separation (fun x ↦ G (affineCube b v x)) f hm x y hf
  have hlip := hG.dist_le_mul (affineCube b v x) (affineCube b v y)
  have hdist := affineCube_dist_of_agree_off b v i x y hxy
  have hmul := mul_le_mul_of_nonneg_left hdist T.coe_nonneg
  nlinarith

/-- Number of relevant Boolean coordinates is bounded by squared product energy.
    The bias is charged, so the budget is the genuine augmented first-layer budget. -/
theorem relevant_card_le (b : E) (v : I → E) (G : E → ℝ) (T : NNReal)
    (hG : LipschitzWith T G) (f : (I → Bool) → Bool)
    (hm : ∀ x, 1 ≤ sign (f x) * G (affineCube b v x)) :
    ((relevantSet f).card : ℝ) ≤ (T : ℝ)^2 * (‖b‖^2 + ∑ i, ‖v i‖^2) := by
  classical
  have hsingle (i : I) (hi : i ∈ relevantSet f) :
      (1 : ℝ) ≤ (T : ℝ)^2 * ‖v i‖^2 := by
    have h := relevant_column_bound b v G T hG f hm i ((mem_relevantSet f i).mp hi)
    nlinarith [sq_nonneg ((T : ℝ) * ‖v i‖ - 1)]
  calc
    ((relevantSet f).card : ℝ) = ∑ i ∈ relevantSet f, (1 : ℝ) := by simp
    _ ≤ ∑ i ∈ relevantSet f, (T : ℝ)^2 * ‖v i‖^2 := Finset.sum_le_sum hsingle
    _ = (T : ℝ)^2 * ∑ i ∈ relevantSet f, ‖v i‖^2 := by rw [Finset.mul_sum]
    _ ≤ (T : ℝ)^2 * ∑ i, ‖v i‖^2 := by
      apply mul_le_mul_of_nonneg_left _ (sq_nonneg _)
      exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _) (fun i _ _ ↦ sq_nonneg _)
    _ ≤ (T : ℝ)^2 * (‖b‖^2 + ∑ i, ‖v i‖^2) := by
      exact mul_le_mul_of_nonneg_left (by nlinarith [sq_nonneg ‖b‖]) (sq_nonneg _)

/-- Specialization to the actual augmented first-layer linear map: column zero
is the constant coordinate, the remaining columns are Boolean coordinates. -/
theorem relevant_card_le_frobenius_product_sq [FiniteDimensional ℝ E]
    (n : ℕ) (W : Euclid (n + 1) →ₗ[ℝ] E) (G : E → ℝ) (T : NNReal)
    (hG : LipschitzWith T G) (f : (Fin n → Bool) → Bool)
    (hm : ∀ x, 1 ≤ sign (f x) * G
      (affineCube (W (EuclideanSpace.basisFun (Fin (n + 1)) ℝ 0))
        (fun i ↦ W (EuclideanSpace.basisFun (Fin (n + 1)) ℝ i.succ)) x)) :
    ((relevantSet f).card : ℝ) ≤ ((T : ℝ) * frobeniusNorm W)^2 := by
  have h := relevant_card_le (I := Fin n) (E := E)
    (W (EuclideanSpace.basisFun (Fin (n + 1)) ℝ 0))
    (fun i ↦ W (EuclideanSpace.basisFun (Fin (n + 1)) ℝ i.succ)) G T hG f hm
  have hs := frobeniusSq_eq_sum_norm_sq W (EuclideanSpace.basisFun (Fin (n + 1)) ℝ)
  rw [Fin.sum_univ_succ] at hs
  rw [← hs, ← frobeniusNorm_sq] at h
  simpa [mul_pow] using h

/-- Zero all irrelevant columns and absorb one common Boolean freezing into the
bias. The affine parameter squared norm does not increase, and the original
Boolean labels and their margin are preserved on the entire cube. -/
theorem exists_freezing_preserving_margin (b : E) (v : I → E) (G : E → ℝ)
    (f : (I → Bool) → Bool)
    (hm : ∀ x, 1 ≤ sign (f x) * G (affineCube b v x)) :
    ∃ b' : E,
      ‖b'‖^2 + ∑ i, ‖if i ∈ relevantSet f then v i else 0‖^2 ≤
        ‖b‖^2 + ∑ i, ‖v i‖^2 ∧
      ∀ x, 1 ≤ sign (f x) * G (affineCube b'
        (fun i ↦ if i ∈ relevantSet f then v i else 0) x) := by
  classical
  let va : I → E := fun i ↦ if i ∈ relevantSet f then v i else 0
  let vi : I → E := fun i ↦ if i ∈ relevantSet f then 0 else v i
  obtain ⟨s, hs⟩ := exists_signs_norm_sq_le b vi
  let b' := b + ∑ i, sign (s i) • vi i
  refine ⟨b', ?_, ?_⟩
  · change ‖b'‖^2 + ∑ i, ‖va i‖^2 ≤ _
    have hsplit : (∑ i, ‖vi i‖^2) + ∑ i, ‖va i‖^2 = ∑ i, ‖v i‖^2 := by
      rw [← Finset.sum_add_distrib]
      apply Finset.sum_congr rfl
      intro i _
      by_cases hi : Relevant f i <;> simp [vi, va, hi]
    change ‖b'‖^2 ≤ ‖b‖^2 + ∑ i, ‖vi i‖^2 at hs
    linarith
  · intro x
    let z : I → Bool := fun i ↦ if i ∈ relevantSet f then x i else s i
    have hlabel : f z = f x := by
      apply eq_of_agree_relevant
      intro i hi
      simp [z, hi]
    have heval : affineCube b' va x = affineCube b v z := by
      unfold affineCube
      change (b + ∑ i, sign (s i) • vi i) + ∑ i, sign (x i) • va i = _
      rw [add_assoc, ← Finset.sum_add_distrib]
      congr 1
      apply Finset.sum_congr rfl
      intro i _
      by_cases hi : Relevant f i <;> simp [vi, va, z, hi]
    change 1 ≤ sign (f x) * G (affineCube b' va x)
    rw [heval, ← hlabel]
    exact hm z

#print axioms exists_freezing_preserving_margin

#print axioms relevant_card_le_frobenius_product_sq
#print axioms relevant_card_le
#print axioms eq_of_agree_relevant

end
end BooleanRelevant
end BooleanDepthResearch
