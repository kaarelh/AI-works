import NeuralGeneralization.OnlineLowerTanhPaperLPMinimum

/-! # Paper-exact cost and normalization for the subgroup-positive theorem

The finite group is the existing sign cube. `quotientCard` equals |G|/|J|;
`cosetWeightTransform` is literally the sum of the normalized weight
transform over a J-coset. Summing an invariant function over G and dividing
by |J+<u>| is the canonical representative-free sum over G/(J+<u>).
-/

noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerGeometry
namespace CubeSubgroup
variable {m : ℕ} (J : CubeSubgroup m)

theorem quotientCard_eq : J.quotientCard =
    (Fintype.card (ClippingCube m):ℝ)/J.carrier.card := by
  have hj : 0<(J.carrier.card:ℝ) := Nat.cast_pos.mpr J.card_pos
  have h := J.annihilator_card_mul
  apply (eq_div_iff (ne_of_gt hj)).mpr
  dsimp [quotientCard]
  field_simp at h
  nlinarith

theorem carrier_ratio_inverse :
    (J.carrier.card:ℝ)/Fintype.card (ClippingCube m) = 1/J.quotientCard := by
  apply (eq_div_iff (ne_of_gt J.quotientCard_pos)).mpr
  exact J.annihilator_card_mul

theorem cosetWeightTransform_eq_sum (w : Finset (Fin m) → ℝ) (x : ClippingCube m) :
    J.cosetWeightTransform w x =
      ∑ a ∈ J.carrier, rectangleWeightTransform w (cubeTranslation a x) := by
  have hchar (s : Finset (Fin m)) : (∑ a ∈ J.carrier, walshCharacter s a) =
      if J.Annihilates s then (J.carrier.card:ℝ) else 0 := by
    simpa using J.character_sum s
  have hsum (s : Finset (Fin m)) :
      (∑ a ∈ J.carrier, w s*walshCharacter s (cubeTranslation a x)) =
        J.carrier.card*(J.restrictedWeights w s*walshCharacter s x) := by
    simp_rw [walshCharacter_translation]
    calc
      _ = ∑ a ∈ J.carrier, (w s*walshCharacter s x)*walshCharacter s a := by
        apply Finset.sum_congr rfl
        intro a ha
        ring
      _ = (w s*walshCharacter s x)*∑ a ∈ J.carrier, walshCharacter s a :=
        (Finset.mul_sum _ _ _).symm
      _ = _ := by
        rw [hchar]
        unfold restrictedWeights
        split_ifs <;> ring
  unfold cosetWeightTransform rectangleWeightTransform
  simp_rw [← Finset.sum_div]
  unfold walshExpansion
  rw [Finset.sum_comm]
  simp_rw [hsum]
  rw [← Finset.mul_sum]
  rw [←div_mul_eq_mul_div, J.carrier_ratio_inverse]
  ring

theorem overshoot_total_coset_sum (w : Finset (Fin m) → ℝ) (u : ClippingCube m)
    (hu : u∉J.carrier) :
    (J.adjoinPoint u).overshootTotal (J.overshootRatio w u) =
      (∑ x, J.overshootKappa w u x) /
        (2*J.carrier.card*J.overshootHeight w u) := by
  unfold overshootTotal walshCoefficients uniformCubeMean
  simp only [walshCharacter, Finset.prod_empty, mul_one]
  simp_rw [overshootRatio, ←Finset.sum_div]
  rw [(J.adjoinPoint u).quotientCard_eq, J.adjoinPoint_card u hu, Nat.cast_mul, Nat.cast_ofNat]
  have hM : (Fintype.card (ClippingCube m):ℝ) ≠ 0 := ne_of_gt (Nat.cast_pos.mpr Fintype.card_pos)
  have hj : (J.carrier.card:ℝ) ≠ 0 := ne_of_gt (Nat.cast_pos.mpr J.card_pos)
  by_cases hh : J.overshootHeight w u = 0
  · simp [hh]
  · field_simp
    <;> ring

theorem overshootScore_cost (w : Finset (Fin m) → ℝ) (u : ClippingCube m) :
    weightedWalshCost w (J.overshootScore u) =
      w ∅/2 + J.cosetWeightTransform w (cubeOne m)-J.cosetWeightTransform w u := by
  have hratio : 0≤(J.carrier.card:ℝ)/Fintype.card (ClippingCube m) := by positivity
  have hterm (s : Finset (Fin m)) :
      w s*|walshCoefficients (J.overshootScore u) s| =
        (if s=∅ then w ∅/2 else 0) +
        ((J.carrier.card:ℝ)/Fintype.card (ClippingCube m))*
          (J.restrictedWeights w s*(1-walshCharacter s u)) := by
    rw [J.overshootScore_coefficient]
    by_cases he : s=∅
    · subst s
      norm_num [walshCharacter]
      ring
    simp only [if_neg he]
    by_cases hJ : J.Annihilates s
    · rw [if_pos hJ]
      have hc : 0≤1-walshCharacter s u := by
        have h1 := le_abs_self (walshCharacter s u)
        rw [abs_walshCharacter] at h1
        linarith
      rw [zero_add, abs_of_nonneg (mul_nonneg hc hratio)]
      simp only [restrictedWeights, if_pos hJ, zero_add]
      ring
    · simp [hJ, restrictedWeights, he]
  unfold weightedWalshCost weightedL1
  simp_rw [hterm]
  rw [Finset.sum_add_distrib, ←Finset.mul_sum]
  simp only [Finset.sum_ite_eq', Finset.mem_univ, ite_true]
  have he : (∑ s, J.restrictedWeights w s*(1-walshCharacter s u)) =
      walshExpansion (J.restrictedWeights w) (cubeOne m)-walshExpansion (J.restrictedWeights w) u := by
    unfold walshExpansion
    simp_rw [walshCharacter_one, mul_one, mul_sub, mul_one, Finset.sum_sub_distrib]
  rw [he, J.carrier_ratio_inverse]
  unfold cosetWeightTransform
  ring

namespace OvershootConditions
variable {J} {w : Finset (Fin m) → ℝ} {u : ClippingCube m} (h : J.OvershootConditions w u)
include h

/-- Full generic theorem: the score and exact minimum cost, with uniqueness
among all real-valued full-margin scores on the entire cube. -/
theorem exact_subgroup_positive_optimizer_paper :
    J.PositiveCell (J.overshootScore u) ∧
    weightedWalshCost w (J.overshootScore u) =
      w ∅/2+J.cosetWeightTransform w (cubeOne m)-J.cosetWeightTransform w u ∧
    ∀ g, J.PositiveCell g →
      w ∅/2+J.cosetWeightTransform w (cubeOne m)-J.cosetWeightTransform w u ≤ weightedWalshCost w g ∧
      (weightedWalshCost w g ≤
        w ∅/2+J.cosetWeightTransform w (cubeOne m)-J.cosetWeightTransform w u →
        g=J.overshootScore u) := by
  obtain ⟨hfeas, hmin⟩ := h.exact_subgroup_positive_optimizer
  refine ⟨hfeas, J.overshootScore_cost w u, ?_⟩
  intro g hg
  simpa only [J.overshootScore_cost w u] using hmin g hg

end OvershootConditions
end CubeSubgroup
end NeuralGeneralization.OnlineLowerGeometry
