import NeuralGeneralization.OnlineLowerGeometryCoset

/-!
# The explicit affine-coset dual for ReLU calibration

The dual is constructed from its actual Walsh coefficients.  The proofs
below establish coefficient feasibility and its pointwise calibration
values.  The sign condition on the nonconstant inverse cost transform is
an explicit scalar-cost input, to be discharged by the ReLU cost theorem.
-/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerGeometry

namespace CubeSubgroup

variable {d : ℕ} (H : CubeSubgroup d)

theorem indicator_nonneg (x : ClippingCube d) : 0 ≤ H.indicator x := by
  unfold indicator
  split_ifs <;> norm_num

theorem cosetIndicator_nonneg (v x : ClippingCube d) : 0 ≤ H.cosetIndicator v x :=
  H.indicator_nonneg _

theorem coset_disjoint (v : ClippingCube d) (hv : v ∉ H.carrier)
    (x : ClippingCube d) (hx : cubeTranslation v x ∈ H.carrier) :
    x ∉ H.carrier := by
  intro hxin
  apply hv
  have h := H.mul_mem x hxin (cubeTranslation v x) hx
  rw [cubeTranslation_comm v x, cubeTranslation_involutive] at h
  exact h

theorem empty_not_differenceAnnihilator (v : ClippingCube d) :
    (∅ : Finset (Fin d)) ∉ H.differenceAnnihilator v := by
  norm_num [differenceAnnihilator, walshCharacter]

theorem difference_character_on_coset (v x : ClippingCube d)
    (hx : cubeTranslation v x ∈ H.carrier) (S : Finset (Fin d))
    (hS : S ∈ H.differenceAnnihilator v) : walshCharacter S x = -1 := by
  obtain ⟨hA, hv⟩ := Finset.mem_filter.mp hS
  have hann := (Finset.mem_filter.mp hA).2
  have h := hann (cubeTranslation v x) hx
  rw [walshCharacter_translation, hv] at h
  linarith

end CubeSubgroup

def reluDualCoefficients {d : ℕ} (w : Finset (Fin d) → ℝ)
    (H : CubeSubgroup d) (v : ClippingCube d) (S : Finset (Fin d)) : ℝ :=
  w S - (if S = ∅ then 2 * w ∅ else 0) -
    (if S ∈ H.differenceAnnihilator v then
      2 * w ∅ / (H.differenceAnnihilator v).card else 0)

def reluDualScore {d : ℕ} (w : Finset (Fin d) → ℝ)
    (H : CubeSubgroup d) (v : ClippingCube d) : ClippingCube d → ℝ :=
  walshExpansion (reluDualCoefficients w H v)

theorem reluDual_coefficients_feasible {d : ℕ} (w : Finset (Fin d) → ℝ)
    (H : CubeSubgroup d) (v : ClippingCube d)
    (hw₀ : 0 ≤ w ∅) (hw : ∀ S, w ∅ ≤ w S)
    (hcard : 2 ≤ (H.differenceAnnihilator v).card) (S : Finset (Fin d)) :
    |reluDualCoefficients w H v S| ≤ w S := by
  have hcardR : (2 : ℝ) ≤ (H.differenceAnnihilator v).card := by exact_mod_cast hcard
  have hcardPos : (0 : ℝ) < (H.differenceAnnihilator v).card := by linarith
  have hpnonneg : 0 ≤ 2 * w ∅ / (H.differenceAnnihilator v).card :=
    div_nonneg (by linarith) hcardPos.le
  have hpupper : 2 * w ∅ / (H.differenceAnnihilator v).card ≤ w ∅ := by
    apply (div_le_iff₀ hcardPos).mpr
    nlinarith [mul_nonneg hw₀
      (by linarith : (0 : ℝ) ≤ ((H.differenceAnnihilator v).card : ℝ) - 2)]
  unfold reluDualCoefficients
  by_cases hS : S = ∅
  · subst S
    rw [if_pos rfl, if_neg (H.empty_not_differenceAnnihilator v)]
    have heq : w ∅ - 2 * w ∅ - 0 = -(w ∅) := by ring
    rw [heq, abs_neg, abs_of_nonneg hw₀]
  · rw [if_neg hS, sub_zero]
    split_ifs with hE
    · rw [abs_of_nonneg (by linarith [hw S])]
      linarith
    · rw [sub_zero, abs_of_nonneg (hw₀.trans (hw S))]

/-- Inversion of the literal coefficient formula. -/
theorem reluDualScore_formula {d : ℕ} (w : Finset (Fin d) → ℝ)
    (H : CubeSubgroup d) (v : ClippingCube d) (hv : v ∉ H.carrier)
    (hcard : 0 < (H.differenceAnnihilator v).card) (x : ClippingCube d) :
    reluDualScore w H v x = walshExpansion w x - 2 * w ∅ -
      2 * w ∅ * H.indicator x + 2 * w ∅ * H.cosetIndicator v x := by
  have hcardne : ((H.differenceAnnihilator v).card : ℝ) ≠ 0 :=
    ne_of_gt (Nat.cast_pos.mpr hcard)
  have hzero : (∑ S : Finset (Fin d),
      (if S = ∅ then 2 * w ∅ else 0) * walshCharacter S x) = 2 * w ∅ := by
    simp [ite_mul, walshCharacter]
  have hE : (∑ S : Finset (Fin d),
      (if S ∈ H.differenceAnnihilator v then
        2 * w ∅ / (H.differenceAnnihilator v).card else 0) * walshCharacter S x) =
      2 * w ∅ * (H.indicator x - H.cosetIndicator v x) := by
    calc
      _ = (2 * w ∅ / (H.differenceAnnihilator v).card) *
          ∑ S ∈ H.differenceAnnihilator v, walshCharacter S x := by
        simp only [ite_mul, zero_mul, Fintype.sum_ite_mem, Finset.mul_sum]
      _ = _ := by
        rw [H.affine_coset_character_identity v hv x]
        field_simp [hcardne]
  unfold reluDualScore walshExpansion reluDualCoefficients
  simp_rw [sub_mul]
  rw [Finset.sum_sub_distrib, Finset.sum_sub_distrib, hzero, hE]
  ring

theorem reluDual_on_coset {d : ℕ} (w : Finset (Fin d) → ℝ)
    (H : CubeSubgroup d) (v : ClippingCube d) (hv : v ∉ H.carrier)
    (hcard : 0 < (H.differenceAnnihilator v).card)
    (x : ClippingCube d) (hx : cubeTranslation v x ∈ H.carrier) :
    reluDualScore w H v x = walshExpansion w x := by
  rw [reluDualScore_formula w H v hv hcard x]
  have hxin := H.coset_disjoint v hv x hx
  simp only [CubeSubgroup.indicator, CubeSubgroup.cosetIndicator, if_neg hxin, if_pos hx]
  ring

/-- Every observed negative fiber has the correct dual sign with the
required fixed magnitude. -/
theorem reluDual_negative_calibration {d : ℕ} (w : Finset (Fin d) → ℝ)
    (H : CubeSubgroup d) (v : ClippingCube d) (hv : v ∉ H.carrier)
    (hw₀ : 0 ≤ w ∅) (hcard : 0 < (H.differenceAnnihilator v).card)
    (x : ClippingCube d) (hx : cubeTranslation v x ∉ H.carrier)
    (hcost : walshExpansion w x ≤ 0) :
    reluDualScore w H v x ≤ -(2 * w ∅) := by
  rw [reluDualScore_formula w H v hv hcard x]
  have hcoset : H.cosetIndicator v x = 0 := by
    simp [CubeSubgroup.cosetIndicator, CubeSubgroup.indicator, hx]
  rw [hcoset, mul_zero, add_zero]
  have hnonneg := mul_nonneg (by linarith : 0 ≤ 2 * w ∅) (H.indicator_nonneg x)
  linarith

/-- The observed positive anchor has the same margin in the dual. -/
theorem reluDual_anchor_calibration {d : ℕ} (w : Finset (Fin d) → ℝ)
    (H : CubeSubgroup d) (v : ClippingCube d) (hv : v ∉ H.carrier)
    (hcard : 0 < (H.differenceAnnihilator v).card)
    (hsum : 6 * w ∅ ≤ ∑ S, w S) :
    2 * w ∅ ≤ reluDualScore w H v (cubeOne d) := by
  rw [reluDualScore_formula w H v hv hcard]
  have hvone : cubeTranslation v (cubeOne d) = v := by
    rw [cubeTranslation_comm, cubeTranslation_one]
  simp only [walshExpansion, walshCharacter_one, mul_one,
    CubeSubgroup.indicator, CubeSubgroup.cosetIndicator,
    if_pos H.one_mem, hvone, if_neg hv, mul_zero, add_zero]
  linarith

end NeuralGeneralization.OnlineLowerGeometry
