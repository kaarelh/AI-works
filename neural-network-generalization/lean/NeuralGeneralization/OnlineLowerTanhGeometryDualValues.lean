import NeuralGeneralization.OnlineLowerTanhGeometryDual

/-! # Scalar dominance parameters and physical-calibration dual values -/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerGeometry

/-- All bounds needed for the literal common dual, derived from the four
scalar dominance inequalities rather than supplied as a dual certificate. -/
theorem rectangle_parameter_bounds (M w₀ wstar K : ℝ)
    (hM : 64 ≤ M) (hw0 : 0 < w₀) (hstar : 0 < wstar)
    (hsmall : wstar ≤ w₀ / 16) (hK : 0 ≤ K) (hKup : K ≤ wstar / 4)
    (hscale : 16 * w₀ ≤ M * wstar) :
    let h := commonDualH (M / 2) w₀ wstar K
    let a := commonDualA (M / 2) w₀ h K
    let c := commonDualC (M / 2) h K
    7 * w₀ / 4 ≤ a ∧ a ≤ 2 * w₀ ∧ 0 < a ∧
      a + c + 2 * K = 2 * w₀ ∧ c + 2 * K ≤ w₀ / 4 ∧
      wstar ≤ c - 2 * K ∧ c * (M / 2) + 2 * a = M * wstar := by
  dsimp only
  have hL : 32 ≤ M / 2 := by linarith
  have hh := commonDualH_bounds (M / 2) w₀ wstar K hL hw0.le hstar hK hKup (by nlinarith)
  have hb := commonDualB_bounds (M / 2) (commonDualH (M / 2) w₀ wstar K) K wstar
    hL hstar hh.1 hh.2 hK hKup
  have ha := commonDualA_bounds (M / 2) w₀ (commonDualH (M / 2) w₀ wstar K) K wstar
    hb.1.le hb.2 hsmall
  refine ⟨ha.1, ha.2, by linarith, ?_, ?_, ?_, ?_⟩
  · unfold commonDualA commonDualC
    ring
  · unfold commonDualC
    linarith [hb.2]
  · exact commonDualC_lower (M / 2) _ K wstar (by linarith) hh.1 hstar hK hKup
  · have h := commonDualC_cancellation (M / 2) w₀ wstar K (by linarith)
    nlinarith only [h]

theorem rectanglePairedTotal_nonneg {m : ℕ} (w : Finset (Fin m) → ℝ)
    (u : ClippingCube m) : 0 ≤ rectanglePairedTotal w u := by
  exact div_nonneg (Finset.sum_nonneg fun z _ => rectanglePairedCost_nonneg w u z) (by norm_num)

theorem rectanglePairedCost_sum {m : ℕ} (w : Finset (Fin m) → ℝ) (u : ClippingCube m) :
    (∑ z, rectanglePairedCost w u z) = 2 * rectanglePairedTotal w u := by
  unfold rectanglePairedTotal
  ring

theorem rectanglePairedCost_dominates {m : ℕ} (w : Finset (Fin m) → ℝ)
    (u z : ClippingCube m) (hz0 : z ≠ cubeOne m) (hzu : z ≠ u) :
    walshExpansion w z / Fintype.card (ClippingCube m) ≤ rectanglePairedCost w u z := by
  rw [rectanglePairedCost, if_neg (not_or.mpr ⟨hz0, hzu⟩)]
  exact (le_max_left _ _).trans (le_max_right _ _)

theorem rectangleDualScore_off_anchor {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v u : ClippingCube m) (k : ClippingCube m → ℝ)
    (a c : ℝ) (hv : v ∉ H.carrier) (hE : 0 < (H.differenceAnnihilator v).card)
    (z : ClippingCube m) (hz0 : z ≠ cubeOne m) (hzu : z ≠ u) :
    rectangleDualScore w H v u k a c z = walshExpansion w z -
      Fintype.card (ClippingCube m) * k z - a - a * H.indicator z + a * H.cosetIndicator v z := by
  rw [rectangleDualScore_formula w H v u k a c hv hE]
  simp only [pointIndicator, if_neg hz0, if_neg hzu]
  ring

theorem rectangleDualScore_on_coset {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v u : ClippingCube m) (k : ClippingCube m → ℝ)
    (a c : ℝ) (hv : v ∉ H.carrier) (hu : u ∈ H.carrier)
    (hE : 0 < (H.differenceAnnihilator v).card)
    (z : ClippingCube m) (hz : cubeTranslation v z ∈ H.carrier) :
    rectangleDualScore w H v u k a c z =
      walshExpansion w z - Fintype.card (ClippingCube m) * k z := by
  have hnot := H.coset_disjoint v hv z hz
  have hz0 : z ≠ cubeOne m := by rintro rfl; exact hnot H.one_mem
  have hzu : z ≠ u := by rintro rfl; exact hnot hu
  rw [rectangleDualScore_off_anchor w H v u k a c hv hE z hz0 hzu]
  simp only [CubeSubgroup.indicator, CubeSubgroup.cosetIndicator, if_neg hnot, if_pos hz]
  ring

/-- Every negative observed fiber has a dual value at most `-a`. -/
theorem rectangleDualScore_negative_observed {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v u : ClippingCube m) (a c : ℝ)
    (hv : v ∉ H.carrier) (ha : 0 ≤ a) (hE : 0 < (H.differenceAnnihilator v).card)
    (z : ClippingCube m) (hz0 : z ≠ cubeOne m) (hzu : z ≠ u)
    (hz : cubeTranslation v z ∉ H.carrier) :
    rectangleDualScore w H v u (rectanglePairedCost w u) a c z ≤ -a := by
  have hM : (0 : ℝ) < Fintype.card (ClippingCube m) := Nat.cast_pos.mpr Fintype.card_pos
  have hcost := (div_le_iff₀ hM).mp (rectanglePairedCost_dominates w u z hz0 hzu)
  have hind := mul_nonneg ha (H.indicator_nonneg z)
  rw [rectangleDualScore_off_anchor w H v u _ a c hv hE z hz0 hzu]
  have hc : H.cosetIndicator v z = 0 := by simp [CubeSubgroup.cosetIndicator, CubeSubgroup.indicator, hz]
  rw [hc, mul_zero, add_zero]
  nlinarith

theorem rectangleDualScore_anchor {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v u : ClippingCube m) (a c : ℝ)
    (hv : v ∉ H.carrier) (hu : u ≠ cubeOne m)
    (hE : 0 < (H.differenceAnnihilator v).card)
    (hcancel : c * ((Fintype.card (ClippingCube m) : ℝ) / 2) + 2 * a = walshExpansion w u) :
    rectangleDualScore w H v u (rectanglePairedCost w u) a c (cubeOne m) =
      walshExpansion w (cubeOne m) - walshExpansion w u := by
  rw [rectangleDualScore_formula w H v u _ a c hv hE]
  have hv0 : cubeTranslation v (cubeOne m) = v := by rw [cubeTranslation_comm, cubeTranslation_one]
  simp only [pointIndicator, if_pos rfl, if_neg (Ne.symm hu), rectanglePairedCost,
    true_or, if_true, mul_zero, sub_zero, CubeSubgroup.indicator, if_pos H.one_mem,
    CubeSubgroup.cosetIndicator, hv0, if_neg hv, mul_one, add_zero]
  linarith

theorem rectangleDualScore_at_shift {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v u : ClippingCube m) (a c : ℝ)
    (hv : v ∉ H.carrier) (hu : u ∈ H.carrier) (hu0 : u ≠ cubeOne m)
    (hE : 0 < (H.differenceAnnihilator v).card)
    (hcancel : c * ((Fintype.card (ClippingCube m) : ℝ) / 2) + 2 * a = walshExpansion w u) :
    rectangleDualScore w H v u (rectanglePairedCost w u) a c u = 0 := by
  have huv : cubeTranslation v u ∉ H.carrier := by
    intro hh
    exact H.coset_disjoint v hv u hh hu
  rw [rectangleDualScore_formula w H v u _ a c hv hE]
  simp only [pointIndicator, if_neg hu0, if_pos rfl, rectanglePairedCost,
    or_true, if_true, mul_zero, sub_zero, CubeSubgroup.indicator, if_pos hu,
    CubeSubgroup.cosetIndicator, if_neg huv, mul_one, add_zero, zero_add]
  linarith

/-- The anchor's positive calibration slack follows from the minimum
weight and the same small distinguished cost. -/
theorem rectangleDualScore_positive_anchor {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v u : ClippingCube m) (a c : ℝ)
    (hv : v ∉ H.carrier) (hu : u ≠ cubeOne m)
    (hE : 0 < (H.differenceAnnihilator v).card)
    (hcancel : c * ((Fintype.card (ClippingCube m) : ℝ) / 2) + 2 * a = walshExpansion w u)
    (hM : 4 ≤ Fintype.card (ClippingCube m)) (hw0 : 0 ≤ w ∅)
    (hw : ∀ s, w ∅ ≤ w s) (ha : a ≤ 2 * w ∅)
    (hsmall : walshExpansion w u / Fintype.card (ClippingCube m) ≤ w ∅ / 16) :
    a ≤ rectangleDualScore w H v u (rectanglePairedCost w u) a c (cubeOne m) := by
  have hMpos : (0 : ℝ) < Fintype.card (ClippingCube m) := Nat.cast_pos.mpr Fintype.card_pos
  have hMr : (4 : ℝ) ≤ Fintype.card (ClippingCube m) := by exact_mod_cast hM
  have hcard : Fintype.card (Finset (Fin m)) = Fintype.card (ClippingCube m) := by
    simp [ClippingCube]
  have hsum : (Fintype.card (ClippingCube m) : ℝ) * w ∅ ≤ walshExpansion w (cubeOne m) := by
    have h := Finset.sum_le_sum (fun s (_ : s ∈ Finset.univ) => hw s)
    simpa only [walshExpansion, walshCharacter_one, mul_one, Finset.sum_const,
      Finset.card_univ, nsmul_eq_mul, hcard] using h
  have hstar := (div_le_iff₀ hMpos).mp hsmall
  rw [rectangleDualScore_anchor w H v u a c hv hu hE hcancel]
  nlinarith [mul_nonneg hw0 (by linarith : 0 ≤ (Fintype.card (ClippingCube m) : ℝ) - 4)]

theorem rectanglePairedCost_of_order {m : ℕ} (w : Finset (Fin m) → ℝ)
    (u z : ClippingCube m) (hz0 : z ≠ cubeOne m) (hzu : z ≠ u)
    (hpos : 0 ≤ walshExpansion w z / Fintype.card (ClippingCube m))
    (horder : walshExpansion w z / Fintype.card (ClippingCube m) ≤
      walshExpansion w (cubeTranslation u z) / Fintype.card (ClippingCube m)) :
    rectanglePairedCost w u z =
      walshExpansion w (cubeTranslation u z) / Fintype.card (ClippingCube m) := by
  rw [rectanglePairedCost, if_neg (not_or.mpr ⟨hz0, hzu⟩), max_eq_right horder,
    max_eq_right (hpos.trans horder)]

/-- On a live fiber the dual is its signed effective rectangle cost. -/
theorem rectangleDualScore_live {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v u : ClippingCube m) (a c : ℝ)
    (hv : v ∉ H.carrier) (hu : u ∈ H.carrier)
    (hE : 0 < (H.differenceAnnihilator v).card)
    (z : ClippingCube m) (hz : cubeTranslation v z ∈ H.carrier)
    (hpos : 0 ≤ walshExpansion w z / Fintype.card (ClippingCube m))
    (horder : walshExpansion w z / Fintype.card (ClippingCube m) ≤
      walshExpansion w (cubeTranslation u z) / Fintype.card (ClippingCube m)) :
    rectangleDualScore w H v u (rectanglePairedCost w u) a c z =
      walshExpansion w z - walshExpansion w (cubeTranslation u z) := by
  have hnot := H.coset_disjoint v hv z hz
  have hz0 : z ≠ cubeOne m := by rintro rfl; exact hnot H.one_mem
  have hzu : z ≠ u := by rintro rfl; exact hnot hu
  have hM : (Fintype.card (ClippingCube m) : ℝ) ≠ 0 :=
    ne_of_gt (Nat.cast_pos.mpr Fintype.card_pos)
  rw [rectangleDualScore_on_coset w H v u _ a c hv hu hE z hz,
    rectanglePairedCost_of_order w u z hz0 hzu hpos horder, mul_div_cancel₀ _ hM]

/-- Translation by the overshoot direction has zero dual value on the
partner of every live fiber. -/
theorem rectangleDualScore_partner {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v u : ClippingCube m) (a c : ℝ)
    (hv : v ∉ H.carrier) (hu : u ∈ H.carrier)
    (hE : 0 < (H.differenceAnnihilator v).card)
    (z : ClippingCube m) (hz : cubeTranslation v z ∈ H.carrier)
    (hpos : 0 ≤ walshExpansion w z / Fintype.card (ClippingCube m))
    (horder : walshExpansion w z / Fintype.card (ClippingCube m) ≤
      walshExpansion w (cubeTranslation u z) / Fintype.card (ClippingCube m)) :
    rectangleDualScore w H v u (rectanglePairedCost w u) a c (cubeTranslation u z) = 0 := by
  have hnot := H.coset_disjoint v hv z hz
  have hz0 : z ≠ cubeOne m := by rintro rfl; exact hnot H.one_mem
  have hzu : z ≠ u := by rintro rfl; exact hnot hu
  have htranslate : cubeTranslation v (cubeTranslation u z) =
      cubeTranslation u (cubeTranslation v z) := by
    funext i
    cases hvi : v i <;> cases hui : u i <;> cases hzi : z i <;>
      simp [cubeTranslation, hvi, hui, hzi]
  have hp : cubeTranslation v (cubeTranslation u z) ∈ H.carrier := by
    rw [htranslate]
    exact H.mul_mem u hu _ hz
  have hM : (Fintype.card (ClippingCube m) : ℝ) ≠ 0 :=
    ne_of_gt (Nat.cast_pos.mpr Fintype.card_pos)
  rw [rectangleDualScore_on_coset w H v u _ a c hv hu hE _ hp,
    rectanglePairedCost_invariant, rectanglePairedCost_of_order w u z hz0 hzu hpos horder,
    mul_div_cancel₀ _ hM, sub_self]

end NeuralGeneralization.OnlineLowerGeometry
