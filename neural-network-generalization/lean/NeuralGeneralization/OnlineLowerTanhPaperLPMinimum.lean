import NeuralGeneralization.OnlineLowerTanhPaperLPDual
import NeuralGeneralization.OnlineLowerGeometryPhysicalMinimum

/-! # Unique optimizer of the generic subgroup-positive Fourier problem -/

noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerGeometry
namespace CubeSubgroup
variable {m : ℕ} (J : CubeSubgroup m)

/-- Positive exactly on J, with one extra negative unit on the coset u+J. -/
def overshootScore (u x : ClippingCube m) : ℝ :=
  -(1:ℝ)/2 + J.indicator x - J.cosetIndicator u x

theorem overshootScore_coefficient (u : ClippingCube m) (s : Finset (Fin m)) :
    walshCoefficients (J.overshootScore u) s = (if s=∅ then -(1:ℝ)/2 else 0) +
      (1-walshCharacter s u) *
        (if J.Annihilates s then (J.carrier.card:ℝ)/Fintype.card (ClippingCube m) else 0) := by
  unfold overshootScore
  rw [walshCoefficients_sub, walshCoefficients_add, walshCoefficients_const,
    J.indicator_coefficient, J.coset_coefficient]
  ring

theorem overshootScore_positiveCell (u : ClippingCube m) (hu : u ∉ J.carrier) :
    J.PositiveCell (J.overshootScore u) := by
  constructor
  · intro x hx
    have hux : cubeTranslation u x ∉ J.carrier := fun hh => J.coset_disjoint u hu x hh hx
    norm_num [overshootScore, indicator, cosetIndicator, hx, hux]
  · intro x hx
    unfold overshootScore cosetIndicator indicator
    rw [if_neg hx]
    split_ifs <;> norm_num

namespace OvershootConditions
variable {J} {w : Finset (Fin m) → ℝ} {u : ClippingCube m} (h : J.OvershootConditions w u)
include h

theorem target_saturation (s : Finset (Fin m)) :
    J.overshootDualCoefficients w u s * walshCoefficients (J.overshootScore u) s =
      w s * |walshCoefficients (J.overshootScore u) s| := by
  rw [J.overshootScore_coefficient]
  by_cases he : s=∅
  · subst s
    rw [J.overshootDual_empty]
    norm_num [walshCharacter]
  rw [if_neg he]
  by_cases hJ : J.Annihilates s
  · rw [if_pos hJ]
    rcases walshCharacter_eq_one_or_neg_one s u with hc | hc
    · rw [hc]; simp
    · rw [hc, J.overshootDual_odd w u s hJ hc]
      have hp : 0 ≤ (1-(-1:ℝ))*((J.carrier.card:ℝ)/Fintype.card (ClippingCube m)) := by positivity
      rw [zero_add, abs_of_nonneg hp]
  · rw [if_neg hJ]
    simp

theorem target_pairing :
    uniformCubeMean (fun x => J.overshootDual w u x * J.overshootScore u x) =
      weightedWalshCost w (J.overshootScore u) := by
  rw [walsh_inner_identity]
  unfold overshootDual weightedWalshCost weightedL1
  simp_rw [walshCoefficients_expansion, h.target_saturation]

theorem margin_product_nonneg (g : ClippingCube m → ℝ) (hg : J.PositiveCell g)
    (x : ClippingCube m) :
    0 ≤ J.overshootDual w u x * (g x-J.overshootScore u x) := by
  by_cases hx : x ∈ J.carrier
  · have hux : cubeTranslation u x ∉ J.carrier := fun hh => J.coset_disjoint u h.outside x hh hx
    have hscore : J.overshootScore u x=1/2 := by norm_num [overshootScore, indicator, cosetIndicator, hx, hux]
    rw [hscore]
    exact mul_nonneg (h.dual_positive_on_subgroup x hx).le (sub_nonneg.mpr (hg.1 x hx))
  by_cases hux : cubeTranslation u x ∈ J.carrier
  · rw [h.dual_zero_on_coset x hux, zero_mul]
  · have hK : x ∉ (J.adjoinPoint u).carrier := by simpa [J.mem_adjoinPoint] using not_or.mpr ⟨hx,hux⟩
    have hscore : J.overshootScore u x= -1/2 := by norm_num [overshootScore, indicator, cosetIndicator, hx, hux]
    rw [hscore]
    exact mul_nonneg_of_nonpos_of_nonpos (h.dual_negative_outside x hK).le
      (sub_nonpos.mpr (hg.2 x hx))

theorem target_cost_le (g : ClippingCube m → ℝ) (hg : J.PositiveCell g) :
    weightedWalshCost w (J.overshootScore u) ≤ weightedWalshCost w g := by
  have hmargin : uniformCubeMean (fun x => J.overshootDual w u x * J.overshootScore u x) ≤
      uniformCubeMean (fun x => J.overshootDual w u x*g x) := by
    apply uniformCubeMean_mono
    intro x
    nlinarith [h.margin_product_nonneg g hg x]
  rw [h.target_pairing] at hmargin
  exact hmargin.trans (walsh_dual_bound w g (J.overshootDual w u) (fun s => by
    rw [overshootDual, walshCoefficients_expansion]
    exact h.dual_feasible s))

theorem target_unique (g : ClippingCube m → ℝ) (hg : J.PositiveCell g)
    (hcost : weightedWalshCost w g ≤ weightedWalshCost w (J.overshootScore u)) :
    g=J.overshootScore u := by
  let D := J.overshootDualCoefficients w u
  have hdual (s : Finset (Fin m)) : |D s| ≤ w s := h.dual_feasible s
  have hinner := walsh_dual_bound w g (J.overshootDual w u) (fun s => by
    rw [overshootDual, walshCoefficients_expansion]; exact hdual s)
  have hmargin : uniformCubeMean (fun x => J.overshootDual w u x * J.overshootScore u x) ≤
      uniformCubeMean (fun x => J.overshootDual w u x*g x) := by
    apply uniformCubeMean_mono
    intro x
    nlinarith [h.margin_product_nonneg g hg x]
  rw [h.target_pairing] at hmargin
  have heq : weightedWalshCost w g = uniformCubeMean (fun x => J.overshootDual w u x*g x) :=
    le_antisymm (hcost.trans hmargin) hinner
  have hzero : uniformCubeMean (fun x => J.overshootDual w u x*(g x-J.overshootScore u x)) = 0 := by
    have he : uniformCubeMean (fun x => J.overshootDual w u x*(g x-J.overshootScore u x)) =
        uniformCubeMean (fun x => J.overshootDual w u x*g x) -
          uniformCubeMean (fun x => J.overshootDual w u x*J.overshootScore u x) := by
      unfold uniformCubeMean
      simp_rw [mul_sub, Finset.sum_sub_distrib, sub_div]
    rw [he, h.target_pairing]
    linarith
  have hz (x : ClippingCube m) : J.overshootDual w u x*(g x-J.overshootScore u x)=0 :=
    uniform_nonnegative_mean_zero _ (h.margin_product_nonneg g hg) hzero x
  have gJ (x : ClippingCube m) (hx : x∈J.carrier) : g x=1/2 := by
    have hh := (mul_eq_zero.mp (hz x)).resolve_left (ne_of_gt (h.dual_positive_on_subgroup x hx))
    have hux : cubeTranslation u x ∉ J.carrier := fun hh => J.coset_disjoint u h.outside x hh hx
    norm_num [overshootScore, indicator, cosetIndicator, hx, hux] at hh
    linarith
  have gOut (x : ClippingCube m) (hx : x∉(J.adjoinPoint u).carrier) : g x= -1/2 := by
    have hh := (mul_eq_zero.mp (hz x)).resolve_left (ne_of_lt (h.dual_negative_outside x hx))
    have hne := not_or.mp ((J.mem_adjoinPoint u x).not.mp hx)
    norm_num [overshootScore, indicator, cosetIndicator, hne.1, hne.2] at hh
    linarith
  have hcoeff (s : Finset (Fin m)) (hs : s≠∅) (hsu : walshCharacter s u=1) :
      walshCoefficients g s=0 := by
    have hstrict : |D s|<w s := by
      by_cases hJ : J.Annihilates s
      · exact h.dual_strict_even s hs ((J.annihilates_adjoin_iff u s).mpr ⟨hJ,hsu⟩)
      · dsimp [D]
        rw [J.overshootDual_off_annihilator w u s hJ, abs_zero]
        exact h.weights_pos s
    have hsbound := coefficient_slack_le_total w (walshCoefficients g) D hdual s
      (w s-|D s|) le_rfl
    have hi := walsh_inner_identity (J.overshootDual w u) g
    simp only [overshootDual, walshCoefficients_expansion] at hi
    change uniformCubeMean _=∑s,D s*walshCoefficients g s at hi
    rw [←hi] at hsbound
    change (w s-|D s|)*|walshCoefficients g s| ≤ weightedWalshCost w g -
      uniformCubeMean (fun x => J.overshootDual w u x*g x) at hsbound
    rw [←heq] at hsbound
    have ha : |walshCoefficients g s|=0 := by
      nlinarith [abs_nonneg (walshCoefficients g s)]
    exact abs_eq_zero.mp ha
  have hsym (x : ClippingCube m) : g x+g (cubeTranslation u x)=2*walshCoefficients g ∅ := by
    have hs := invariantRemainder_symmetry u g x
    have hr : invariantRemainder u g x=0 := by
      unfold invariantRemainder walshExpansion
      apply Finset.sum_eq_zero
      intro s _
      dsimp only
      split_ifs with hc
      · rw [hcoeff s hc.1 hc.2, zero_mul]
      · exact zero_mul _
    simpa [hr] using hs
  have hex : ∃ x, x∉(J.adjoinPoint u).carrier := by
    by_contra hn
    push_neg at hn
    have huniv : (J.adjoinPoint u).carrier=Finset.univ := Finset.eq_univ_of_forall hn
    have hc := (J.adjoinPoint u).annihilator_card_mul
    rw [huniv, Finset.card_univ, div_self (ne_of_gt (Nat.cast_pos.mpr Fintype.card_pos)), one_mul] at hc
    have hL := h.quotient_ge
    dsimp [quotientCard] at hL
    linarith
  obtain ⟨x,hx⟩ := hex
  have hux : cubeTranslation u x∉(J.adjoinPoint u).carrier := by
    rw [(J.adjoinPoint u).translate_mem_iff u (J.point_mem_adjoinPoint u) x]
    exact hx
  have hc0 : walshCoefficients g ∅= -1/2 := by
    have hh := hsym x
    rw [gOut x hx, gOut _ hux] at hh
    linarith
  funext z
  by_cases hzJ : z∈J.carrier
  · have hzU : cubeTranslation u z∉J.carrier := fun hh => J.coset_disjoint u h.outside z hh hzJ
    rw [gJ z hzJ]
    norm_num [overshootScore, indicator, cosetIndicator, hzJ, hzU]
  by_cases hzU : cubeTranslation u z∈J.carrier
  · have hh := hsym z
    rw [gJ _ hzU, hc0] at hh
    have hval : g z= -(3:ℝ)/2 := by linarith
    rw [hval]
    norm_num [overshootScore, indicator, cosetIndicator, hzJ, hzU]
  · rw [gOut z (by simpa only [J.mem_adjoinPoint] using not_or.mpr ⟨hzJ,hzU⟩)]
    norm_num [overshootScore, indicator, cosetIndicator, hzJ, hzU]

/-- The actual generic optimizer, with no dual or minimizer assumption. -/
theorem exact_subgroup_positive_optimizer :
    J.PositiveCell (J.overshootScore u) ∧
    ∀ g, J.PositiveCell g →
      weightedWalshCost w (J.overshootScore u) ≤ weightedWalshCost w g ∧
      (weightedWalshCost w g ≤ weightedWalshCost w (J.overshootScore u) → g=J.overshootScore u) :=
  ⟨J.overshootScore_positiveCell u h.outside, fun g hg => ⟨h.target_cost_le g hg, h.target_unique g hg⟩⟩

end OvershootConditions
end CubeSubgroup
end NeuralGeneralization.OnlineLowerGeometry
