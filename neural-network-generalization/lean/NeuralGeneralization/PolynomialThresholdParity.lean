import NeuralGeneralization.KernelEnergy
import NeuralGeneralization.ParityError
import Mathlib.Data.Finset.Max
import Mathlib.LinearAlgebra.FiniteDimensional.Lemmas
import Mathlib.LinearAlgebra.Dimension.Constructions

/-!
# The finite polynomial-threshold obstruction for full parity

The proof uses a low-degree polynomial vanishing on the entire error set.
It is finite-dimensional linear algebra and Walsh orthogonality, without
sampling, concentration, or a supplied threshold approximation theorem.
-/

noncomputable section

namespace NeuralGeneralization

open scoped BigOperators

abbrev DegreeIndices (d t : ℕ) := {S : Finset (Fin d) // S.card ≤ t}

/-- Walsh polynomials with coefficient index restricted to degrees at most `t`. -/
def lowDegreeField {d t : ℕ} (a : DegreeIndices d t → ℝ) (x : ClippingCube d) : ℝ :=
  ∑ S, a S * walshCharacter S.val x

theorem lowDegreeField_coefficient {d t : ℕ} (a : DegreeIndices d t → ℝ)
    (S : DegreeIndices d t) :
    (∑ x, lowDegreeField a x * walshCharacter S.val x) =
      (Fintype.card (ClippingCube d) : ℝ) * a S := by
  classical
  unfold lowDegreeField
  simp_rw [Finset.sum_mul]
  rw [Finset.sum_comm]
  have hterm (T : DegreeIndices d t) :
      (∑ x, (a T * walshCharacter T.val x) * walshCharacter S.val x) =
        if T = S then (Fintype.card (ClippingCube d) : ℝ) * a S else 0 := by
    simp_rw [mul_assoc]
    rw [← Finset.mul_sum, walshCharacter_orthogonal]
    by_cases hTS : T = S
    · simp [hTS, mul_comm]
    · have hval : T.val ≠ S.val := fun h => hTS (Subtype.ext h)
      simp [hTS, hval]
  simp_rw [hterm]
  simp

theorem lowDegreeField_injective {d t : ℕ} :
    Function.Injective (@lowDegreeField d t) := by
  intro a b hab
  funext S
  have h := congrArg (fun q : ClippingCube d → ℝ => ∑ x, q x * walshCharacter S.val x) hab
  rw [lowDegreeField_coefficient, lowDegreeField_coefficient] at h
  exact mul_left_cancel₀ (Nat.cast_ne_zero.mpr Fintype.card_ne_zero) h

/-- Fewer evaluation constraints than coefficients leave a nonzero polynomial
that vanishes at every constrained point. -/
theorem exists_lowDegreeField_vanishing {d t : ℕ} (E : Finset (ClippingCube d))
    (hcard : E.card < Fintype.card (DegreeIndices d t)) :
    ∃ a : DegreeIndices d t → ℝ, a ≠ 0 ∧ ∀ x ∈ E, lowDegreeField a x = 0 := by
  classical
  let evaluation : (DegreeIndices d t → ℝ) →ₗ[ℝ] (E → ℝ) :=
    { toFun := fun a x => lowDegreeField a x.val
      map_add' := by
        intro a b; funext x
        simp [lowDegreeField, add_mul, Finset.sum_add_distrib]
      map_smul' := by
        intro c a; funext x
        simp [lowDegreeField, Finset.mul_sum, mul_assoc] }
  have hdim : Module.finrank ℝ (E → ℝ) < Module.finrank ℝ (DegreeIndices d t → ℝ) := by
    simpa using hcard
  obtain ⟨a, ha, hne⟩ := Submodule.exists_mem_ne_zero_of_ne_bot
    (LinearMap.ker_ne_bot_of_finrank_lt (f := evaluation) hdim)
  refine ⟨a, hne, ?_⟩
  intro x hx
  have heq : evaluation a = 0 := ha
  exact congrFun heq ⟨x, hx⟩

/-- The parity moment of three characters vanishes whenever their total
support size is less than the ambient dimension. -/
theorem parity_walsh_triple_sum_zero {d : ℕ} (S T U : Finset (Fin d))
    (hcard : S.card + T.card + U.card < d) :
    (∑ x : ClippingCube d,
      fullParity x * walshCharacter S x * walshCharacter T x * walshCharacter U x) = 0 := by
  classical
  have hunion : (S ∪ T ∪ U).card < d := by
    have h₁ := Finset.card_union_le S T
    have h₂ := Finset.card_union_le (S ∪ T) U
    omega
  obtain ⟨i, hi⟩ : ∃ i : Fin d, i ∉ S ∪ T ∪ U := by
    by_contra h
    have hall : S ∪ T ∪ U = Finset.univ := by
      ext i
      simp only [Finset.mem_univ, iff_true]
      exact not_not.mp (not_exists.mp h i)
    rw [hall, Finset.card_univ, Fintype.card_fin] at hunion
    omega
  have hiS : i ∉ S := fun h => hi (Finset.mem_union_left _ (Finset.mem_union_left _ h))
  have hiT : i ∉ T := fun h => hi (Finset.mem_union_left _ (Finset.mem_union_right _ h))
  have hiU : i ∉ U := fun h => hi (Finset.mem_union_right _ h)
  have hflip (x : ClippingCube d) :
      fullParity (cubeFlip i x) * walshCharacter S (cubeFlip i x) *
        walshCharacter T (cubeFlip i x) * walshCharacter U (cubeFlip i x) =
      -(fullParity x * walshCharacter S x * walshCharacter T x * walshCharacter U x) := by
    rw [fullParity_cubeFlip, walshCharacter_flip, walshCharacter_flip, walshCharacter_flip]
    simp [hiS, hiT, hiU]
  have hsum := (cubeFlip i).sum_comp (fun x =>
    fullParity x * walshCharacter S x * walshCharacter T x * walshCharacter U x)
  simp_rw [hflip, Finset.sum_neg_distrib] at hsum
  linarith

/-- The parity moment of `P Q²` vanishes if `deg P + 2 deg Q < d`. -/
theorem parity_lowDegreeField_square_sum_zero {d s t : ℕ}
    (a : Finset (Fin d) → ℝ) (hdegree : ∀ S, a S ≠ 0 → S.card ≤ s)
    (b : DegreeIndices d t → ℝ) (hst : s + 2 * t < d) :
    (∑ x : ClippingCube d, fullParity x * walshExpansion a x * lowDegreeField b x ^ 2) = 0 := by
  classical
  have hterm (S : Finset (Fin d)) (T U : DegreeIndices d t) :
      (∑ x : ClippingCube d,
        fullParity x * (a S * walshCharacter S x) *
          ((b T * walshCharacter T.val x) * (b U * walshCharacter U.val x))) = 0 := by
    by_cases ha : a S = 0
    · simp [ha]
    · have hcard : S.card + T.val.card + U.val.card < d := by
        have hS := hdegree S ha
        have hT := T.property
        have hU := U.property
        omega
      have heq (x : ClippingCube d) :
          fullParity x * (a S * walshCharacter S x) *
            ((b T * walshCharacter T.val x) * (b U * walshCharacter U.val x)) =
          (a S * b T * b U) * (fullParity x * walshCharacter S x *
            walshCharacter T.val x * walshCharacter U.val x) := by ring
      simp_rw [heq]
      rw [← Finset.mul_sum, parity_walsh_triple_sum_zero S T.val U.val hcard, mul_zero]
  unfold walshExpansion lowDegreeField
  simp_rw [pow_two, Finset.sum_mul, Finset.mul_sum]
  rw [Finset.sum_comm]
  apply Finset.sum_eq_zero
  intro S _
  rw [Finset.sum_comm]
  apply Finset.sum_eq_zero
  intro T _
  simp_rw [Finset.sum_mul]
  rw [Finset.sum_comm]
  apply Finset.sum_eq_zero
  intro U _
  exact hterm U S T

/-- A degree-`s` polynomial with no zeros makes at least as many parity
errors as there are Walsh monomials of degree at most `t`, whenever
`s + 2*t < d`. This is the finite-dimensional threshold obstruction. -/
theorem polynomial_threshold_parity_error_card {d s t : ℕ}
    (a : Finset (Fin d) → ℝ) (hdegree : ∀ S, a S ≠ 0 → S.card ≤ s)
    (hzero : ∀ x, walshExpansion a x ≠ 0) (hst : s + 2 * t < d) :
    Fintype.card (DegreeIndices d t) ≤
      (Finset.univ.filter (fun x : ClippingCube d => fullParity x * walshExpansion a x < 0)).card := by
  classical
  by_contra hcard
  let E := Finset.univ.filter (fun x : ClippingCube d => fullParity x * walshExpansion a x < 0)
  have hcard' : E.card < Fintype.card (DegreeIndices d t) := Nat.lt_of_not_ge hcard
  obtain ⟨b, hb, hvanish⟩ := exists_lowDegreeField_vanishing E hcard'
  have hQ : ∃ x, lowDegreeField b x ≠ 0 := by
    by_contra h
    have heq : lowDegreeField b = lowDegreeField (0 : DegreeIndices d t → ℝ) := by
      funext x
      have hx := not_not.mp (not_exists.mp h x)
      simpa [lowDegreeField] using hx
    exact hb (lowDegreeField_injective heq)
  have hnonneg (x : ClippingCube d) :
      0 ≤ fullParity x * walshExpansion a x * lowDegreeField b x ^ 2 := by
    by_cases hx : x ∈ E
    · rw [hvanish x hx]; simp
    · have hpos : 0 ≤ fullParity x * walshExpansion a x := by
        simpa [E] using hx
      exact mul_nonneg hpos (sq_nonneg _)
  obtain ⟨x, hx⟩ := hQ
  have hxE : x ∉ E := fun h => hx (hvanish x h)
  have hxsign : 0 < fullParity x * walshExpansion a x := by
    have hnon : 0 ≤ fullParity x * walshExpansion a x := by simpa [E] using hxE
    have hf : fullParity x ≠ 0 := by rcases fullParity_sign x with h | h <;> simp [h]
    exact lt_of_le_of_ne hnon (Ne.symm (mul_ne_zero hf (hzero x)))
  have hpos : 0 < ∑ y : ClippingCube d,
      fullParity y * walshExpansion a y * lowDegreeField b y ^ 2 := by
    exact Finset.sum_pos' (fun y _ => hnonneg y) ⟨x, Finset.mem_univ _, mul_pos hxsign (sq_pos_of_ne_zero hx)⟩
  rw [parity_lowDegreeField_square_sum_zero a hdegree b hst] at hpos
  exact lt_irrefl _ hpos


/-- A finite family of strictly positive reals has a strictly positive
common strict lower bound. -/
private theorem exists_positive_strict_lower_bound {ι : Type*} [Fintype ι] [Nonempty ι]
    (b : ι → ℝ) (hb : ∀ i, 0 < b i) : ∃ e : ℝ, 0 < e ∧ ∀ i, e < b i := by
  classical
  let values := Finset.univ.image b
  have hvalues : values.Nonempty := Finset.image_nonempty.mpr Finset.univ_nonempty
  have hmin : 0 < values.min' hvalues := by
    apply (Finset.lt_min'_iff _ _).mpr
    intro y hy
    obtain ⟨i, _, rfl⟩ := Finset.mem_image.mp hy
    exact hb i
  refine ⟨values.min' hvalues / 2, by positivity, ?_⟩
  intro i
  have hle : values.min' hvalues ≤ b i :=
    Finset.min'_le _ _ (Finset.mem_image.mpr ⟨i, Finset.mem_univ _, rfl⟩)
  linarith

/-- An arbitrarily small positive constant perturbation resolves every zero
with the convention used by `binarySign`, and changes no classification. -/
theorem exists_positive_shift_binarySign {d : ℕ} (P : ClippingCube d → ℝ) :
    ∃ e : ℝ, 0 < e ∧ (∀ x, P x + e ≠ 0) ∧
      ∀ x, binarySign (P x + e) = binarySign (P x) := by
  classical
  let b : ClippingCube d → ℝ := fun x => if P x = 0 then 1 else |P x|
  have hb : ∀ x, 0 < b x := by
    intro x
    by_cases h : P x = 0
    · simp [b, h]
    · simp [b, h, abs_pos]
  obtain ⟨e, he, heP⟩ := exists_positive_strict_lower_bound b hb
  have hsign (x : ClippingCube d) :
      (0 ≤ P x → 0 < P x + e) ∧ (P x < 0 → P x + e < 0) := by
    constructor
    · intro hx; linarith
    · intro hx
      have hlt := heP x
      simp only [b, if_neg (ne_of_lt hx), abs_of_neg hx] at hlt
      linarith
  refine ⟨e, he, ?_, ?_⟩
  · intro x
    by_cases hx : 0 ≤ P x
    · exact ne_of_gt ((hsign x).1 hx)
    · exact ne_of_lt ((hsign x).2 (lt_of_not_ge hx))
  · intro x
    by_cases hx : 0 ≤ P x
    · simp [binarySign, hx, ((hsign x).1 hx).le]
    · simp [binarySign, hx, not_le.mpr ((hsign x).2 (lt_of_not_ge hx))]

/-- Adding a constant changes only the empty-set Walsh coefficient. -/
theorem walshExpansion_add_constant {d : ℕ} (a : Finset (Fin d) → ℝ) (e : ℝ)
    (x : ClippingCube d) :
    walshExpansion (fun S => a S + if S = ∅ then e else 0) x =
      walshExpansion a x + e := by
  classical
  unfold walshExpansion
  simp_rw [add_mul, Finset.sum_add_distrib]
  simp [ite_mul, walshCharacter]

/-- The polynomial-threshold error bound with the actual common convention
that zero is classified as `+1`. The polynomial is allowed to have zeros. -/
theorem polynomial_threshold_parity_error_card_with_ties {d s t : ℕ}
    (a : Finset (Fin d) → ℝ) (hdegree : ∀ S, a S ≠ 0 → S.card ≤ s)
    (hst : s + 2 * t < d) :
    Fintype.card (DegreeIndices d t) ≤
      (Finset.univ.filter (fun x : ClippingCube d =>
        binarySign (walshExpansion a x) ≠ fullParity x)).card := by
  classical
  obtain ⟨e, he, hzero, hsign⟩ := exists_positive_shift_binarySign (walshExpansion a)
  let b := fun S : Finset (Fin d) => a S + if S = ∅ then e else 0
  have hb (x : ClippingCube d) : walshExpansion b x = walshExpansion a x + e :=
    walshExpansion_add_constant a e x
  have hbdegree : ∀ S, b S ≠ 0 → S.card ≤ s := by
    intro S hS
    by_cases hEmpty : S = ∅
    · simp [hEmpty]
    · apply hdegree
      simpa only [b, if_neg hEmpty, add_zero] using hS
  have hbzero : ∀ x, walshExpansion b x ≠ 0 := by simpa only [hb] using hzero
  have h := polynomial_threshold_parity_error_card b hbdegree hbzero hst
  have hequiv (x : ClippingCube d) :
      fullParity x * walshExpansion b x < 0 ↔ binarySign (walshExpansion a x) ≠ fullParity x := by
    rw [← hsign x, ← hb x]
    have hn := hbzero x
    rcases lt_or_gt_of_ne hn with hn | hn <;>
      rcases fullParity_sign x with hf | hf <;> rw [hf] <;>
      unfold binarySign <;> split_ifs with hx <;> norm_num <;> linarith
  simpa only [hequiv] using h

/-- The normalized finite error lower bound, including the common zero-tie
convention. `card (DegreeIndices d t)` is exactly the number of monomials
of degree at most `t`. -/
theorem polynomial_threshold_parity_error {d s t : ℕ}
    (a : Finset (Fin d) → ℝ) (hdegree : ∀ S, a S ≠ 0 → S.card ≤ s)
    (hst : s + 2 * t < d) :
    (Fintype.card (DegreeIndices d t) : ℝ) / Fintype.card (ClippingCube d) ≤
      uniformParityError (walshExpansion a) := by
  classical
  have h := polynomial_threshold_parity_error_card_with_ties a hdegree hst
  have hreal : (Fintype.card (DegreeIndices d t) : ℝ) ≤
      ((Finset.univ.filter (fun x : ClippingCube d =>
        binarySign (walshExpansion a x) ≠ fullParity x)).card : ℝ) := by exact_mod_cast h
  have hsum : (∑ x : ClippingCube d,
      if binarySign (walshExpansion a x) = fullParity x then (0 : ℝ) else 1) =
      ((Finset.univ.filter (fun x : ClippingCube d =>
        binarySign (walshExpansion a x) ≠ fullParity x)).card : ℝ) := by
    rw [← Finset.sum_boole]
    apply Finset.sum_congr rfl
    intro x _
    split_ifs <;> simp_all
  unfold uniformParityError uniformCubeMean
  rw [hsum]
  exact div_le_div_of_nonneg_right hreal (Nat.cast_nonneg _)


/-- The coefficient-space dimension is the exact binomial lower tail. -/
theorem degreeIndices_card (d t : ℕ) :
    Fintype.card (DegreeIndices d t) = ∑ j ∈ Finset.range (t + 1), d.choose j := by
  classical
  have h := Finset.sum_card_fiberwise_eq_card_filter
    (Finset.univ : Finset (Finset (Fin d))) (Finset.range (t + 1)) Finset.card
  have hfiber (j : ℕ) :
      (Finset.univ.filter (fun S : Finset (Fin d) => S.card = j)) =
        Finset.univ.powersetCard j := by
    ext S
    simp
  simp_rw [hfiber, Finset.card_powersetCard, Finset.card_univ, Fintype.card_fin] at h
  have hcard : Fintype.card (DegreeIndices d t) =
      (Finset.univ.filter (fun S : Finset (Fin d) => S.card ≤ t)).card := by
    simp [DegreeIndices, Fintype.card_subtype]
  rw [hcard]
  simpa only [Finset.mem_range, Nat.lt_succ_iff] using h.symm

end NeuralGeneralization
