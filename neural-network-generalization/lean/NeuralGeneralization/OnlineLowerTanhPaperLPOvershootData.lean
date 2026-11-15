import NeuralGeneralization.OnlineLowerTanhPaperLPDistribution

/-! # Explicit data in the arbitrary-subgroup overshoot theorem -/

noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerGeometry
namespace CubeSubgroup
variable {m : ℕ} (J : CubeSubgroup m)

theorem annihilates_adjoin_iff (u : ClippingCube m) (s : Finset (Fin m)) :
    (J.adjoinPoint u).Annihilates s ↔ J.Annihilates s ∧ walshCharacter s u = 1 := by
  constructor
  · intro h
    exact ⟨fun x hx => h x (J.subset_adjoinPoint u hx), h u (J.point_mem_adjoinPoint u)⟩
  · rintro ⟨hJ, hu⟩ x hx
    rcases (J.mem_adjoinPoint u x).mp hx with hx | hx
    · exact hJ x hx
    · have h := hJ _ hx
      rw [walshCharacter_translation, hu, one_mul] at h
      exact h

theorem quotientCard_adjoin (u : ClippingCube m) (hu : u ∉ J.carrier) :
    2 * (J.adjoinPoint u).quotientCard = J.quotientCard := by
  have hM : (Fintype.card (ClippingCube m):ℝ) ≠ 0 := ne_of_gt (Nat.cast_pos.mpr Fintype.card_pos)
  have hJ := J.annihilator_card_mul
  have hK := (J.adjoinPoint u).annihilator_card_mul
  rw [J.adjoinPoint_card u hu, Nat.cast_mul, Nat.cast_ofNat] at hK
  have hj : 0 < (J.carrier.card:ℝ) := Nat.cast_pos.mpr J.card_pos
  field_simp at hJ hK
  change 2 * ((J.adjoinPoint u).annihilator.card:ℝ) = (J.annihilator.card:ℝ)
  nlinarith

/-- Fourier weights restricted to characters constant on J. -/
def restrictedWeights (w : Finset (Fin m) → ℝ) (s : Finset (Fin m)) : ℝ :=
  if J.Annihilates s then w s else 0

/-- The quotient's normalized weight transform. -/
def cosetWeightTransform (w : Finset (Fin m) → ℝ) (x : ClippingCube m) : ℝ :=
  walshExpansion (J.restrictedWeights w) x / J.quotientCard

theorem cosetWeightTransform_invariant (w : Finset (Fin m) → ℝ)
    (a : ClippingCube m) (ha : a ∈ J.carrier) (x : ClippingCube m) :
    J.cosetWeightTransform w (cubeTranslation a x) = J.cosetWeightTransform w x := by
  unfold cosetWeightTransform walshExpansion
  congr 1
  apply Finset.sum_congr rfl
  intro s _
  unfold restrictedWeights
  rw [walshCharacter_translation]
  by_cases hs : J.Annihilates s
  · rw [if_pos hs, hs a ha, one_mul]
  · simp [hs]

def overshootHeight (w : Finset (Fin m) → ℝ) (u : ClippingCube m) : ℝ :=
  J.cosetWeightTransform w u - w ∅ / (J.adjoinPoint u).quotientCard

def overshootKappa (w : Finset (Fin m) → ℝ) (u x : ClippingCube m) : ℝ :=
  if x ∈ (J.adjoinPoint u).carrier then 0 else
    max 0 (max (J.cosetWeightTransform w x) (J.cosetWeightTransform w (cubeTranslation u x)))

def overshootRatio (w : Finset (Fin m) → ℝ) (u x : ClippingCube m) : ℝ :=
  J.overshootKappa w u x / J.overshootHeight w u

theorem overshootKappa_nonneg (w : Finset (Fin m) → ℝ) (u x : ClippingCube m) :
    0 ≤ J.overshootKappa w u x := by
  unfold overshootKappa
  split_ifs
  · exact le_rfl
  · exact le_max_left _ _

theorem overshootKappa_invariant (w : Finset (Fin m) → ℝ) (u : ClippingCube m)
    (a : ClippingCube m) (ha : a ∈ (J.adjoinPoint u).carrier) (x : ClippingCube m) :
    J.overshootKappa w u (cubeTranslation a x) = J.overshootKappa w u x := by
  unfold overshootKappa
  simp only [(J.adjoinPoint u).translate_mem_iff a ha x]
  split_ifs
  · rfl
  · congr 1
    rcases (J.mem_adjoinPoint u a).mp ha with ha | ha
    · rw [J.cosetWeightTransform_invariant w a ha x, cubeTranslation_swap,
        J.cosetWeightTransform_invariant w a ha (cubeTranslation u x)]
    · have hx : cubeTranslation a x = cubeTranslation (cubeTranslation u a) (cubeTranslation u x) :=
        (cubeTranslation_cancel_pair u a x).symm
      rw [hx, J.cosetWeightTransform_invariant w _ ha _, cubeTranslation_swap,
        cubeTranslation_involutive, J.cosetWeightTransform_invariant w _ ha _, max_comm]

theorem overshootRatio_invariant (w : Finset (Fin m) → ℝ) (u : ClippingCube m)
    (a : ClippingCube m) (ha : a ∈ (J.adjoinPoint u).carrier) (x : ClippingCube m) :
    J.overshootRatio w u (cubeTranslation a x) = J.overshootRatio w u x := by
  unfold overshootRatio
  rw [J.overshootKappa_invariant w u a ha x]

theorem overshootRatio_on_subgroup (w : Finset (Fin m) → ℝ) (u x : ClippingCube m)
    (hx : x ∈ (J.adjoinPoint u).carrier) : J.overshootRatio w u x = 0 := by
  simp [overshootRatio, overshootKappa, hx]

/-- These are precisely the scalar hypotheses of the manuscript's generic
subgroup-positive theorem; every function and Fourier quantity is explicit. -/
structure OvershootConditions (w : Finset (Fin m) → ℝ) (u : ClippingCube m) : Prop where
  outside : u ∉ J.carrier
  quotient_ge : 2 ≤ (J.adjoinPoint u).quotientCard
  weight_pos : 0 < w ∅
  weight_strict : ∀ s, s ≠ ∅ → w ∅ < w s
  height_pos : 0 < J.overshootHeight w u
  total_lt : (J.adjoinPoint u).overshootTotal (J.overshootRatio w u) < 1
  weight_dominance :
    (1 + (J.adjoinPoint u).overshootTotal (J.overshootRatio w u)) *
      (J.overshootHeight w u + w ∅/(J.adjoinPoint u).quotientCard) < w ∅

namespace OvershootConditions
variable {J} {w : Finset (Fin m) → ℝ} {u : ClippingCube m} (h : J.OvershootConditions w u)
include h

theorem ratio_nonneg (x : ClippingCube m) : 0 ≤ J.overshootRatio w u x :=
  div_nonneg (J.overshootKappa_nonneg w u x) h.height_pos.le

theorem weights_pos (s : Finset (Fin m)) : 0 < w s := by
  by_cases hs : s = ∅
  · simpa [hs] using h.weight_pos
  · exact h.weight_pos.trans (h.weight_strict s hs)

theorem probability_bounds (s : Finset (Fin m)) :
    0 ≤ (J.adjoinPoint u).overshootProbability (J.overshootRatio w u) s ∧
    J.overshootHeight w u * J.quotientCard *
      (J.adjoinPoint u).overshootProbability (J.overshootRatio w u) s < 2*w ∅ := by
  let K := J.adjoinPoint u
  let R := K.overshootTotal (J.overshootRatio w u)
  let Z := K.overshootDenominator (J.overshootRatio w u)
  let L := K.quotientCard
  have hZ : 0 < Z := K.overshootDenominator_pos _ h.quotient_ge h.total_lt
  have hp := K.overshootProbability_bounds _ h.ratio_nonneg h.quotient_ge h.total_lt s
  refine ⟨hp.1, ?_⟩
  have hdom := h.weight_dominance
  have hL : 0 < L := K.quotientCard_pos
  change (1+R)*(J.overshootHeight w u+w ∅/L)<w ∅ at hdom
  have hdom' : (1+R)*(J.overshootHeight w u*L+w ∅)<w ∅*L := by
    have hh := mul_lt_mul_of_pos_right hdom hL
    field_simp at hh
    nlinarith
  have hscalar : J.overshootHeight w u * J.quotientCard * ((1+R)/Z) < 2*w ∅ := by
    rw [J.quotientCard_adjoin u h.outside |>.symm]
    change J.overshootHeight w u * (2*L) * ((1+R)/Z) < 2*w ∅
    rw [← mul_div_assoc]
    apply (div_lt_iff₀ hZ).mpr
    change J.overshootHeight w u*(2*L)*(1+R) < 2*w ∅*(L-(1+R))
    nlinarith [hdom' ]
  have hh := mul_le_mul_of_nonneg_left hp.2.1
    (mul_nonneg h.height_pos.le J.quotientCard_pos.le)
  exact hh.trans_lt hscalar

end OvershootConditions
end CubeSubgroup
end NeuralGeneralization.OnlineLowerGeometry
