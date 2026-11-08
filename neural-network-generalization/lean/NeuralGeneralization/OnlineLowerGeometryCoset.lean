import NeuralGeneralization.OnlineLowerGeometryWalsh

/-!
# Affine-coset Fourier identities on the existing Boolean cube

The subgroup is represented by an explicit finite set closed under sign
multiplication.  Its annihilator and the translated coset use the same
Walsh characters as the rest of the repository.
-/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerGeometry

def cubeOne (d : ℕ) : ClippingCube d := fun _ => true

theorem cubeTranslation_one {d : ℕ} (x : ClippingCube d) :
    cubeTranslation (cubeOne d) x = x := by
  funext i
  simp [cubeTranslation, cubeOne]

theorem cubeTranslation_comm {d : ℕ} (x y : ClippingCube d) :
    cubeTranslation x y = cubeTranslation y x := by
  funext i
  cases hx : x i <;> cases hy : y i <;> simp [cubeTranslation, hx, hy]

theorem cubeTranslation_self {d : ℕ} (x : ClippingCube d) :
    cubeTranslation x x = cubeOne d := by
  funext i
  cases hx : x i <;> simp [cubeTranslation, cubeOne, hx]

theorem walshCharacter_one {d : ℕ} (S : Finset (Fin d)) :
    walshCharacter S (cubeOne d) = 1 := by
  simp [walshCharacter, cubeOne, cubeCoordinateSign]

/-- A finite subgroup of the sign cube, with no change of Boolean model. -/
structure CubeSubgroup (d : ℕ) where
  carrier : Finset (ClippingCube d)
  one_mem : cubeOne d ∈ carrier
  mul_mem : ∀ x ∈ carrier, ∀ y ∈ carrier, cubeTranslation x y ∈ carrier

namespace CubeSubgroup

variable {d : ℕ} (H : CubeSubgroup d)

theorem card_pos : 0 < H.carrier.card :=
  Finset.card_pos.mpr ⟨cubeOne d, H.one_mem⟩

theorem translate_mem_iff (t : ClippingCube d) (ht : t ∈ H.carrier)
    (x : ClippingCube d) :
    cubeTranslation t x ∈ H.carrier ↔ x ∈ H.carrier := by
  constructor
  · intro hx
    have h := H.mul_mem t ht (cubeTranslation t x) hx
    simpa only [cubeTranslation_involutive] using h
  · exact H.mul_mem t ht x

def indicator (x : ClippingCube d) : ℝ := if x ∈ H.carrier then 1 else 0

def Annihilates (S : Finset (Fin d)) : Prop :=
  ∀ x ∈ H.carrier, walshCharacter S x = 1

def annihilator : Finset (Finset (Fin d)) := Finset.univ.filter H.Annihilates

/-- Orthogonality on an arbitrary explicit sign subgroup. -/
theorem character_sum (S : Finset (Fin d)) :
    (∑ x : ClippingCube d, if x ∈ H.carrier then walshCharacter S x else 0) =
      if H.Annihilates S then (H.carrier.card : ℝ) else 0 := by
  by_cases hA : H.Annihilates S
  · rw [if_pos hA]
    have hterm (x : ClippingCube d) :
        (if x ∈ H.carrier then walshCharacter S x else 0) =
          if x ∈ H.carrier then (1 : ℝ) else 0 := by
      by_cases hx : x ∈ H.carrier
      · simp [hx, hA x hx]
      · simp [hx]
    simp only [hterm, Fintype.sum_ite_mem, Finset.sum_const,
      nsmul_eq_mul, mul_one]
  · rw [if_neg hA]
    obtain ⟨t, ht, hχ⟩ : ∃ t ∈ H.carrier, walshCharacter S t ≠ 1 := by
      by_contra h
      apply hA
      intro x hx
      by_contra hχ
      exact h ⟨x, hx, hχ⟩
    have hneg : walshCharacter S t = -1 := by
      have hsq := walshCharacter_sq S t
      have hprod : (walshCharacter S t - 1) * (walshCharacter S t + 1) = 0 := by
        nlinarith
      rcases mul_eq_zero.mp hprod with h | h
      · exact False.elim (hχ (by linarith))
      · linarith
    let f : ClippingCube d → ℝ :=
      fun x => if x ∈ H.carrier then walshCharacter S x else 0
    have hflip (x : ClippingCube d) : f (cubeTranslation t x) = -f x := by
      simp only [f, H.translate_mem_iff t ht, walshCharacter_translation, hneg]
      split_ifs <;> ring
    have hsum := (cubeTranslation t).sum_comp f
    simp_rw [hflip] at hsum
    rw [Finset.sum_neg_distrib] at hsum
    change (∑ x, f x) = 0
    linarith

/-- The exact normalized Fourier transform of a subgroup indicator. -/
theorem indicator_coefficient (S : Finset (Fin d)) :
    walshCoefficients H.indicator S =
      if H.Annihilates S then
        (H.carrier.card : ℝ) / Fintype.card (ClippingCube d) else 0 := by
  unfold walshCoefficients uniformCubeMean indicator
  simp only [ite_mul, one_mul, zero_mul]
  rw [H.character_sum]
  split_ifs <;> simp

/-- Fourier inversion gives the annihilator-character sum without an
assumed dimension or cardinality formula for the subgroup. -/
theorem annihilator_sum_scaled (x : ClippingCube d) :
    ((H.carrier.card : ℝ) / Fintype.card (ClippingCube d)) *
      (∑ S ∈ H.annihilator, walshCharacter S x) = H.indicator x := by
  have hinv := walshExpansion_coefficients H.indicator x
  rw [walshExpansion] at hinv
  simp_rw [H.indicator_coefficient] at hinv
  simpa only [annihilator, Finset.sum_filter, mul_ite, ite_mul, zero_mul,
    mul_zero, Finset.mul_sum] using hinv

/-- The size of the annihilator is obtained from the same proven
orthogonality identity, not postulated as a group-theoretic hypothesis. -/
theorem annihilator_card_mul :
    ((H.carrier.card : ℝ) / Fintype.card (ClippingCube d)) *
      (H.annihilator.card : ℝ) = 1 := by
  have h := H.annihilator_sum_scaled (cubeOne d)
  simpa only [walshCharacter_one, Finset.sum_const, nsmul_eq_mul, mul_one,
    indicator, if_pos H.one_mem] using h

def cosetIndicator (v x : ClippingCube d) : ℝ := H.indicator (cubeTranslation v x)

theorem coset_coefficient (v : ClippingCube d) (S : Finset (Fin d)) :
    walshCoefficients (H.cosetIndicator v) S =
      walshCharacter S v *
        (if H.Annihilates S then
          (H.carrier.card : ℝ) / Fintype.card (ClippingCube d) else 0) := by
  unfold cosetIndicator
  rw [walshCoefficients_translation, H.indicator_coefficient]

/-- The half of the annihilator which is negative on the translating
point.  In the manuscript this is `H'⊥ \ (H' + ⟨v⟩)⊥`. -/
def differenceAnnihilator (v : ClippingCube d) : Finset (Finset (Fin d)) :=
  H.annihilator.filter (fun S => walshCharacter S v = -1)

theorem annihilator_difference_scaled (v x : ClippingCube d) :
    (2 * ((H.carrier.card : ℝ) / Fintype.card (ClippingCube d))) *
      (∑ S ∈ H.differenceAnnihilator v, walshCharacter S x) =
        H.indicator x - H.cosetIndicator v x := by
  have hterm (S : Finset (Fin d)) :
      walshCharacter S x - walshCharacter S v * walshCharacter S x =
        if walshCharacter S v = -1 then 2 * walshCharacter S x else 0 := by
    by_cases hneg : walshCharacter S v = -1
    · rw [if_pos hneg, hneg]
      ring
    · have hpos : walshCharacter S v = 1 := by
        have hsq := walshCharacter_sq S v
        have hprod : (walshCharacter S v - 1) * (walshCharacter S v + 1) = 0 := by
          nlinarith
        rcases mul_eq_zero.mp hprod with h | h
        · linarith
        · exact False.elim (hneg (by linarith))
      rw [if_neg hneg, hpos]
      ring
  have hsum :
      (∑ S ∈ H.annihilator,
        (walshCharacter S x - walshCharacter S v * walshCharacter S x)) =
        2 * ∑ S ∈ H.differenceAnnihilator v, walshCharacter S x := by
    simp only [hterm, differenceAnnihilator, Finset.sum_filter,
      Finset.mul_sum, mul_ite, mul_zero]
  calc
    (2 * ((H.carrier.card : ℝ) / Fintype.card (ClippingCube d))) *
        (∑ S ∈ H.differenceAnnihilator v, walshCharacter S x) =
        ((H.carrier.card : ℝ) / Fintype.card (ClippingCube d)) *
          (∑ S ∈ H.annihilator,
            (walshCharacter S x - walshCharacter S v * walshCharacter S x)) := by
      rw [hsum]
      ring
    _ = ((H.carrier.card : ℝ) / Fintype.card (ClippingCube d)) *
        ((∑ S ∈ H.annihilator, walshCharacter S x) -
          ∑ S ∈ H.annihilator, walshCharacter S (cubeTranslation v x)) := by
      simp only [walshCharacter_translation, Finset.sum_sub_distrib]
    _ = H.indicator x - H.cosetIndicator v x := by
      rw [mul_sub, H.annihilator_sum_scaled, H.annihilator_sum_scaled]
      rfl

theorem differenceAnnihilator_card_mul (v : ClippingCube d)
    (hv : v ∉ H.carrier) :
    (2 * ((H.carrier.card : ℝ) / Fintype.card (ClippingCube d))) *
      ((H.differenceAnnihilator v).card : ℝ) = 1 := by
  have h := H.annihilator_difference_scaled v (cubeOne d)
  have hvone : cubeTranslation v (cubeOne d) = v := by
    rw [cubeTranslation_comm, cubeTranslation_one]
  simpa only [walshCharacter_one, Finset.sum_const, nsmul_eq_mul, mul_one,
    indicator, cosetIndicator, hvone, if_pos H.one_mem, if_neg hv, sub_zero] using h

/-- The common dual's affine-coset Fourier identity, including its exact
normalization.  No annihilator-cardinality axiom is used. -/
theorem affine_coset_character_identity (v : ClippingCube d)
    (hv : v ∉ H.carrier) (x : ClippingCube d) :
    (∑ S ∈ H.differenceAnnihilator v, walshCharacter S x) =
      ((H.differenceAnnihilator v).card : ℝ) *
        (H.indicator x - H.cosetIndicator v x) := by
  have hcard := H.differenceAnnihilator_card_mul v hv
  have hscaled := H.annihilator_difference_scaled v x
  calc
    (∑ S ∈ H.differenceAnnihilator v, walshCharacter S x) =
        ((2 * ((H.carrier.card : ℝ) / Fintype.card (ClippingCube d))) *
          ((H.differenceAnnihilator v).card : ℝ)) *
            (∑ S ∈ H.differenceAnnihilator v, walshCharacter S x) := by
      rw [hcard]
      ring
    _ = ((H.differenceAnnihilator v).card : ℝ) *
        ((2 * ((H.carrier.card : ℝ) / Fintype.card (ClippingCube d))) *
          (∑ S ∈ H.differenceAnnihilator v, walshCharacter S x)) := by ring
    _ = _ := by rw [hscaled]

end CubeSubgroup

end NeuralGeneralization.OnlineLowerGeometry
