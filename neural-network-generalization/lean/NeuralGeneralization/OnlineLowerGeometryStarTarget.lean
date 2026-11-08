import NeuralGeneralization.OnlineLowerGeometryCodeOrder
import NeuralGeneralization.OnlineLowerGeometryReluStar

/-! # Actual half-margin stars and their Boolean fiber-flip classifiers -/

noncomputable section
open scoped Classical

namespace NeuralGeneralization.OnlineLowerGeometry
open ConcreteModel

namespace WalshCodeMap
variable {d m : ℕ} (C : WalshCodeMap d m)

/-- The literal physical star has closed margin exactly one half for
the classifier obtained by flipping precisely its exceptional fiber. -/
theorem physical_star_fiberFlip_margin {T : ℕ}
    (point : Fin T → ClippingCube m) (hinj : Function.Injective point)
    (hpoint : ∀ i, point i ≠ cubeOne m) (target : BooleanFunction d)
    (htarget : ∀ x, labelReal (target x) = C.base x *
      (if C.syndrome x = cubeOne m then 1 else -1)) (i : Fin T) (x : Cube d) :
    labelReal (fiberFlip target (C.codeFiber point) i x) *
      (C.base x * reluStar (point i) (C.syndrome x)) = (1 : ℝ) / 2 := by
  by_cases hx : C.syndrome x = point i
  · have hf := (C.codeFiber_eq_some_iff point hinj x i).mpr hx
    have hnot : C.syndrome x ≠ cubeOne m := by rw [hx]; exact hpoint i
    have hn : labelReal (!(target x)) = -labelReal (target x) := by
      cases ht : target x <;> norm_num [labelReal, ht]
    simp only [fiberFlip, if_pos hf, hn, htarget x, if_neg hnot,
      reluStar, pointIndicator, if_pos hx]
    have hbase := C.base_sq x
    nlinarith
  · have hf : C.codeFiber point x ≠ some i := by
      intro h
      exact hx ((C.codeFiber_eq_some_iff point hinj x i).mp h)
    simp only [fiberFlip, if_neg hf, htarget x, reluStar, pointIndicator, if_neg hx]
    by_cases hz : C.syndrome x = cubeOne m
    · simp only [if_pos hz]
      nlinarith [C.base_sq x]
    · simp only [if_neg hz]
      nlinarith [C.base_sq x]

theorem physical_star_wrong_at_section {T : ℕ}
    (point : Fin T → ClippingCube m) (hpoint : ∀ i, point i ≠ cubeOne m)
    (target : BooleanFunction d)
    (htarget : ∀ x, labelReal (target x) = C.base x *
      (if C.syndrome x = cubeOne m then 1 else -1)) (i : Fin T) :
    labelReal (target (C.sectionPoint (point i))) *
      (C.base (C.sectionPoint (point i)) *
        reluStar (point i) (C.syndrome (C.sectionPoint (point i)))) = -(1 : ℝ) / 2 := by
  rw [htarget, C.syndrome_sectionPoint]
  simp only [if_neg (hpoint i), reluStar, pointIndicator, if_neg (hpoint i), if_true]
  nlinarith [C.base_sq (C.sectionPoint (point i))]

end WalshCodeMap
end NeuralGeneralization.OnlineLowerGeometry
