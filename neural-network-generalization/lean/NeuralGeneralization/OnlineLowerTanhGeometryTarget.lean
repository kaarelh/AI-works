import NeuralGeneralization.OnlineLowerTanhGeometryMass
import NeuralGeneralization.OnlineLowerGeometryStarTarget

/-! # Literal rectangle classifiers and their physical margins -/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerGeometry
open ConcreteModel

lemma pointIndicator_translation {m : ℕ} (u v z : ClippingCube m) :
    pointIndicator v (cubeTranslation u z) = pointIndicator (cubeTranslation u v) z := by
  have he : cubeTranslation u z = v ↔ z = cubeTranslation u v := by
    constructor
    · intro hh
      have h := congrArg (cubeTranslation u) hh
      simpa only [cubeTranslation_involutive] using h
    · intro hh
      rw [hh, cubeTranslation_involutive]
  simp only [pointIndicator, he]

lemma rectangleMassScore_pointIndicator {m : ℕ} (u v : ClippingCube m) :
    rectangleMassScore u (pointIndicator v) = rectangleScore u v := by
  ext z
  unfold rectangleMassScore rectangleBaseline rectangleScore
  rw [pointIndicator_translation]
  ring

lemma rectangleScore_anchor {m : ℕ} (u v : ClippingCube m)
    (hu : u ≠ cubeOne m) (hv : v ≠ cubeOne m) (hvu : v ≠ u) :
    rectangleScore u v (cubeOne m) = (1 : ℝ) / 2 := by
  have huv : cubeTranslation u v ≠ cubeOne m := fun hh => hvu ((cubeTranslation_eq_one_iff u v).mp hh)
  norm_num [rectangleScore, pointIndicator, Ne.symm hu, Ne.symm hv, Ne.symm huv]

lemma rectangleScore_live {m : ℕ} (u v : ClippingCube m)
    (hu : u ≠ cubeOne m) (hv : v ≠ cubeOne m) (hvu : v ≠ u) :
    rectangleScore u v v = (1 : ℝ) / 2 := by
  have huv : v ≠ cubeTranslation u v := by
    intro hh
    have h := congrArg (cubeTranslation v) hh
    rw [cubeTranslation_self, cubeTranslation_swap, cubeTranslation_self,
      cubeTranslation_comm u (cubeOne m), cubeTranslation_one] at h
    exact hu h.symm
  norm_num [rectangleScore, pointIndicator, hv, hvu, huv]

lemma rectangleScore_negative {m : ℕ} (u v z : ClippingCube m)
    (hz0 : z ≠ cubeOne m) (hzv : z ≠ v) : rectangleScore u v z ≤ -(1 : ℝ) / 2 := by
  unfold rectangleScore pointIndicator
  rw [if_neg hz0, if_neg hzv]
  split_ifs <;> norm_num

/-- The rectangle's Fourier coefficient mass is exactly 3/2, independent
of the number of logical coordinates. -/
theorem rectangleScore_algebraNorm {m : ℕ} (u v : ClippingCube m)
    (hu : u ≠ cubeOne m) (hv : v ≠ cubeOne m) (hvu : v ≠ u) :
    walshAlgebraNorm (rectangleScore u v) = (3 : ℝ) / 2 := by
  have hterm (s : Finset (Fin m)) : |walshCoefficients (rectangleScore u v) s| =
      walshCoefficients (rectangleScore u v) s + (if s = ∅ then 1 else 0) := by
    by_cases hs : s = ∅
    · subst s
      rw [rectangleScore_coefficient_empty]
      norm_num
    · rw [if_neg hs, add_zero]
      exact abs_of_nonneg (rectangleScore_coefficient_nonempty_nonneg u v s hs)
  unfold walshAlgebraNorm
  simp_rw [hterm]
  rw [Finset.sum_add_distrib]
  simp only [Finset.sum_ite_eq', Finset.mem_univ, if_true]
  have hsum : (∑ s, walshCoefficients (rectangleScore u v) s) = rectangleScore u v (cubeOne m) := by
    have hh := walshExpansion_coefficients (rectangleScore u v) (cubeOne m)
    simpa only [walshExpansion, walshCharacter_one, mul_one] using hh
  rw [hsum, rectangleScore_anchor u v hu hv hvu]
  norm_num

namespace WalshCodeMap
variable {d m : ℕ} (C : WalshCodeMap d m)

theorem physical_rectangle_fiberFlip_margin {T : ℕ}
    (point : Fin T → ClippingCube m) (hinj : Function.Injective point)
    (u : ClippingCube m) (hu : u ≠ cubeOne m)
    (hpoint : ∀ i, point i ≠ cubeOne m) (hshift : ∀ i, point i ≠ u)
    (target : BooleanFunction d)
    (htarget : ∀ x, labelReal (target x) = C.base x *
      (if C.syndrome x = cubeOne m then 1 else -1)) (i : Fin T) (x : Cube d) :
    (1 : ℝ) / 2 ≤ labelReal (fiberFlip target (C.codeFiber point) i x) *
      (C.base x * rectangleScore u (point i) (C.syndrome x)) := by
  by_cases hx : C.syndrome x = point i
  · have hf := (C.codeFiber_eq_some_iff point hinj x i).mpr hx
    have hz0 : C.syndrome x ≠ cubeOne m := by rw [hx]; exact hpoint i
    have hn : labelReal (!(target x)) = -labelReal (target x) := by
      cases ht : target x <;> norm_num [labelReal, ht]
    simp only [fiberFlip, if_pos hf, hn, htarget x, if_neg hz0, hx, if_neg (hpoint i),
      rectangleScore_live u (point i) hu (hpoint i) (hshift i)]
    nlinarith [C.base_sq x]
  · have hf : C.codeFiber point x ≠ some i := fun hh => hx ((C.codeFiber_eq_some_iff point hinj x i).mp hh)
    simp only [fiberFlip, if_neg hf, htarget x]
    by_cases hz0 : C.syndrome x = cubeOne m
    · rw [if_pos hz0, hz0, rectangleScore_anchor u (point i) hu (hpoint i) (hshift i)]
      nlinarith [C.base_sq x]
    · rw [if_neg hz0]
      have hn := rectangleScore_negative u (point i) (C.syndrome x) hz0 hx
      have he : (C.base x * -1) * (C.base x * rectangleScore u (point i) (C.syndrome x)) =
          -rectangleScore u (point i) (C.syndrome x) := by
        nlinarith [C.base_sq x]
      rw [he]
      linarith

theorem physical_rectangle_wrong_at_section {T : ℕ}
    (point : Fin T → ClippingCube m) (u : ClippingCube m) (hu : u ≠ cubeOne m)
    (hpoint : ∀ i, point i ≠ cubeOne m) (hshift : ∀ i, point i ≠ u)
    (target : BooleanFunction d)
    (htarget : ∀ x, labelReal (target x) = C.base x *
      (if C.syndrome x = cubeOne m then 1 else -1)) (i : Fin T) :
    labelReal (target (C.sectionPoint (point i))) *
      (C.base (C.sectionPoint (point i)) * rectangleScore u (point i)
        (C.syndrome (C.sectionPoint (point i)))) = -(1 : ℝ) / 2 := by
  rw [htarget, C.syndrome_sectionPoint, if_neg (hpoint i),
    rectangleScore_live u (point i) hu (hpoint i) (hshift i)]
  nlinarith [C.base_sq (C.sectionPoint (point i))]

end WalshCodeMap
end NeuralGeneralization.OnlineLowerGeometry
