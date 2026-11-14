import NeuralGeneralization.OnlineLowerTanhPaperLPOvershootData

/-! # The generic subgroup overshoot dual and its strict signs -/

noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerGeometry
namespace CubeSubgroup
variable {m : ℕ} (J : CubeSubgroup m)

def overshootDualCoefficients (w : Finset (Fin m) → ℝ) (u : ClippingCube m)
    (s : Finset (Fin m)) : ℝ :=
  J.restrictedWeights w s - (if s=∅ then 2*w ∅ else 0) -
    J.overshootHeight w u * J.quotientCard *
      (J.adjoinPoint u).overshootProbability (J.overshootRatio w u) s

def overshootDual (w : Finset (Fin m) → ℝ) (u : ClippingCube m) : ClippingCube m → ℝ :=
  walshExpansion (J.overshootDualCoefficients w u)

theorem overshootDual_empty (w : Finset (Fin m) → ℝ) (u : ClippingCube m) :
    J.overshootDualCoefficients w u ∅ = -w ∅ := by
  have he : J.Annihilates ∅ := by intro x hx; simp [walshCharacter]
  simp [overshootDualCoefficients, restrictedWeights, overshootProbability, he]
  ring

theorem overshootDual_off_annihilator (w : Finset (Fin m) → ℝ) (u : ClippingCube m)
    (s : Finset (Fin m)) (hs : ¬J.Annihilates s) :
    J.overshootDualCoefficients w u s = 0 := by
  have he : s ≠ ∅ := by rintro rfl; exact hs (by intro x hx; simp [walshCharacter])
  have hk : ¬(J.adjoinPoint u).Annihilates s := fun h => hs ((J.annihilates_adjoin_iff u s).mp h).1
  simp [overshootDualCoefficients, restrictedWeights, overshootProbability, hs, he, hk]

theorem overshootDual_odd (w : Finset (Fin m) → ℝ) (u : ClippingCube m)
    (s : Finset (Fin m)) (hs : J.Annihilates s) (hu : walshCharacter s u = -1) :
    J.overshootDualCoefficients w u s = w s := by
  have he : s ≠ ∅ := by rintro rfl; norm_num [walshCharacter] at hu
  have hk : ¬(J.adjoinPoint u).Annihilates s := by
    intro h
    have := ((J.annihilates_adjoin_iff u s).mp h).2
    linarith
  simp [overshootDualCoefficients, restrictedWeights, overshootProbability, hs, he, hk]

namespace OvershootConditions
variable {J} {w : Finset (Fin m) → ℝ} {u : ClippingCube m} (h : J.OvershootConditions w u)
include h

theorem dual_strict_even (s : Finset (Fin m)) (hs : s ≠ ∅)
    (hK : (J.adjoinPoint u).Annihilates s) : |J.overshootDualCoefficients w u s| < w s := by
  have hJ := ((J.annihilates_adjoin_iff u s).mp hK).1
  have hp := (J.adjoinPoint u).overshootProbability_bounds _ h.ratio_nonneg h.quotient_ge h.total_lt s
  have hpos := mul_pos (mul_pos h.height_pos J.quotientCard_pos) (hp.2.2 hs hK)
  have hbound := (h.probability_bounds s).2
  have hw := h.weight_strict s hs
  unfold overshootDualCoefficients restrictedWeights
  rw [if_pos hJ, if_neg hs, sub_zero]
  exact abs_lt.mpr ⟨by linarith, by linarith⟩

theorem dual_feasible (s : Finset (Fin m)) : |J.overshootDualCoefficients w u s| ≤ w s := by
  by_cases he : s=∅
  · subst s
    rw [J.overshootDual_empty, abs_neg, abs_of_pos h.weight_pos]
  by_cases hJ : J.Annihilates s
  · by_cases hK : (J.adjoinPoint u).Annihilates s
    · exact (h.dual_strict_even s he hK).le
    · have hu : walshCharacter s u = -1 := by
        rcases walshCharacter_eq_one_or_neg_one s u with hu | hu
        · exact False.elim (hK ((J.annihilates_adjoin_iff u s).mpr ⟨hJ,hu⟩))
        · exact hu
      rw [J.overshootDual_odd w u s hJ hu, abs_of_pos (h.weights_pos s)]
  · rw [J.overshootDual_off_annihilator w u s hJ, abs_zero]
    exact (h.weights_pos s).le

end OvershootConditions

theorem overshootDual_formula (w : Finset (Fin m) → ℝ) (u : ClippingCube m)
    (hu : u ∉ J.carrier) (x : ClippingCube m) :
    J.overshootDual w u x = J.quotientCard *
      (J.cosetWeightTransform w x - w ∅ / (J.adjoinPoint u).quotientCard -
        J.overshootHeight w u *
          walshExpansion ((J.adjoinPoint u).overshootProbability (J.overshootRatio w u)) x) := by
  unfold overshootDual walshExpansion overshootDualCoefficients
  simp_rw [sub_mul, Finset.sum_sub_distrib, mul_assoc, ← Finset.mul_sum]
  have hz : (∑ s, (if s=∅ then 2*w ∅ else 0) * walshCharacter s x) = 2*w ∅ := by
    simp [ite_mul, walshCharacter]
  rw [hz]
  have hq := J.quotientCard_pos
  have hK := (J.adjoinPoint u).quotientCard_pos
  dsimp [cosetWeightTransform, walshExpansion]
  rw [← J.quotientCard_adjoin u hu]
  field_simp
  <;> ring

theorem cosetWeightTransform_on_subgroup (w : Finset (Fin m) → ℝ)
    (x : ClippingCube m) (hx : x ∈ J.carrier) :
    J.cosetWeightTransform w x = J.cosetWeightTransform w (cubeOne m) := by
  have h := J.cosetWeightTransform_invariant w x hx (cubeOne m)
  simpa only [cubeTranslation_comm x, cubeTranslation_one] using h

theorem cosetWeightTransform_on_coset (w : Finset (Fin m) → ℝ)
    (u x : ClippingCube m) (hx : cubeTranslation u x ∈ J.carrier) :
    J.cosetWeightTransform w x = J.cosetWeightTransform w u := by
  have h := J.cosetWeightTransform_invariant w (cubeTranslation u x) hx u
  have heq : cubeTranslation (cubeTranslation u x) u = x := by
    rw [cubeTranslation_comm, cubeTranslation_involutive]
  rwa [heq] at h

theorem cosetWeightTransform_identity_gt (w : Finset (Fin m) → ℝ)
    (hw : ∀ s, 0 < w s) (u : ClippingCube m) (hu : u ∉ J.carrier) :
    J.cosetWeightTransform w u < J.cosetWeightTransform w (cubeOne m) := by
  have hex : ∃ s ∈ J.annihilator, walshCharacter s u = -1 := by
    by_contra hn
    push_neg at hn
    have hs (s : Finset (Fin m)) (hs : s ∈ J.annihilator) : walshCharacter s u = 1 := by
      rcases walshCharacter_eq_one_or_neg_one s u with h | h
      · exact h
      · exact False.elim (hn s hs h)
    have hsum := J.annihilator_sum u
    simp only [indicator, if_neg hu, mul_zero] at hsum
    have hcard : (∑ s ∈ J.annihilator, walshCharacter s u) = J.quotientCard := by
      simp_rw [Finset.sum_congr rfl (fun s hs' => hs s hs')]
      simp [quotientCard]
    rw [hcard] at hsum
    exact (ne_of_gt J.quotientCard_pos) hsum
  obtain ⟨s, hs, hsu⟩ := hex
  have hJ : J.Annihilates s := (Finset.mem_filter.mp hs).2
  have hsum : 0 < ∑ t, J.restrictedWeights w t * (1-walshCharacter t u) := by
    apply Finset.sum_pos'
    · intro t _
      have hc : walshCharacter t u ≤ 1 := by
        calc
          _ ≤ |walshCharacter t u| := le_abs_self _
          _ = 1 := abs_walshCharacter _ _
      have hw' : 0 ≤ J.restrictedWeights w t := by
        unfold restrictedWeights
        split_ifs
        · exact (hw t).le
        · exact le_rfl
      exact mul_nonneg hw' (sub_nonneg.mpr hc)
    · refine ⟨s, Finset.mem_univ _, ?_⟩
      rw [restrictedWeights, if_pos hJ, hsu]
      nlinarith [hw s]
  unfold cosetWeightTransform
  apply (div_lt_div_iff_of_pos_right J.quotientCard_pos).mpr
  unfold walshExpansion
  simp_rw [walshCharacter_one, mul_one, mul_sub, mul_one] at hsum ⊢
  rw [Finset.sum_sub_distrib] at hsum
  linarith

namespace OvershootConditions
variable {J} {w : Finset (Fin m) → ℝ} {u : ClippingCube m} (h : J.OvershootConditions w u)
include h

theorem dual_on_enlarged (x : ClippingCube m) (hx : x ∈ (J.adjoinPoint u).carrier) :
    J.overshootDual w u x = J.quotientCard *
      (J.cosetWeightTransform w x-J.cosetWeightTransform w u) := by
  have hQ := (J.adjoinPoint u).overshootProbability_character_mean _
    (J.overshootRatio_invariant w u) x
  have hZ := (J.adjoinPoint u).overshootDenominator_pos _ h.quotient_ge h.total_lt
  rw [J.overshootRatio_on_subgroup w u x hx, indicator, if_pos hx, add_zero] at hQ
  have hQ1 : walshExpansion ((J.adjoinPoint u).overshootProbability (J.overshootRatio w u)) x = 1 := by
    rw [hQ]
    simpa only [mul_one, overshootDenominator] using div_self (ne_of_gt hZ)
  rw [J.overshootDual_formula w u h.outside x, hQ1]
  unfold overshootHeight
  ring

theorem dual_positive_on_subgroup (x : ClippingCube m) (hx : x ∈ J.carrier) :
    0 < J.overshootDual w u x := by
  rw [h.dual_on_enlarged x (J.subset_adjoinPoint u hx), J.cosetWeightTransform_on_subgroup w x hx]
  exact mul_pos J.quotientCard_pos (sub_pos.mpr
    (J.cosetWeightTransform_identity_gt w h.weights_pos u h.outside))

theorem dual_zero_on_coset (x : ClippingCube m) (hx : cubeTranslation u x ∈ J.carrier) :
    J.overshootDual w u x = 0 := by
  rw [h.dual_on_enlarged x ((J.mem_adjoinPoint u x).mpr (Or.inr hx)),
    J.cosetWeightTransform_on_coset w u x hx, sub_self, mul_zero]

omit h in
private theorem outside_scalar (L h w R k a : ℝ) (hL : 0<L) (hh : 0<h)
    (hZ : 0<L-(1+R)) (hR : 0≤1+R) (hk : 0≤k) (ha : a≤k)
    (hd : (1+R)*(h+w/L)<w) :
    a-w/L-h*((L*(k/h)-(1+R))/(L-(1+R)))<0 := by
  have hLt : (w/L)*L=w := div_mul_cancel₀ _ (ne_of_gt hL)
  have hkr : 0≤(1+R)*k := mul_nonneg hR hk
  have hcomp : k-w/L < (L*k-h*(1+R))/(L-(1+R)) := by
    apply (lt_div_iff₀ hZ).mpr
    nlinarith
  have heq : (L*k-h*(1+R))/(L-(1+R)) =
      h*((L*(k/h)-(1+R))/(L-(1+R))) := by field_simp
  rw [heq] at hcomp
  linarith

theorem dual_negative_outside (x : ClippingCube m) (hx : x ∉ (J.adjoinPoint u).carrier) :
    J.overshootDual w u x < 0 := by
  let K := J.adjoinPoint u
  have hQ := K.overshootProbability_character_mean _ (J.overshootRatio_invariant w u) x
  rw [indicator, if_neg hx, zero_add] at hQ
  rw [J.overshootDual_formula w u h.outside x, hQ]
  apply mul_neg_of_pos_of_neg J.quotientCard_pos
  have hR : 0 ≤ K.overshootTotal (J.overshootRatio w u) := by
    unfold overshootTotal walshCoefficients uniformCubeMean
    apply mul_nonneg K.quotientCard_pos.le
    apply div_nonneg _ (Nat.cast_nonneg _)
    apply Finset.sum_nonneg
    intro z _
    simpa [walshCharacter] using h.ratio_nonneg z
  have ha : J.cosetWeightTransform w x ≤ J.overshootKappa w u x := by
    unfold overshootKappa
    rw [if_neg hx]
    exact (le_max_left _ _).trans (le_max_right _ _)
  exact outside_scalar K.quotientCard (J.overshootHeight w u) (w ∅)
    (K.overshootTotal (J.overshootRatio w u)) (J.overshootKappa w u x)
    (J.cosetWeightTransform w x) K.quotientCard_pos h.height_pos
    (K.overshootDenominator_pos _ h.quotient_ge h.total_lt) (by linarith)
    (J.overshootKappa_nonneg w u x) ha h.weight_dominance

end OvershootConditions
end CubeSubgroup
end NeuralGeneralization.OnlineLowerGeometry
