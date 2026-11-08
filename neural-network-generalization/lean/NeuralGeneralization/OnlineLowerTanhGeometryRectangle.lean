import NeuralGeneralization.OnlineLowerTanhGeometryDual
import NeuralGeneralization.OnlineLowerGeometryProjection

/-! # Literal rectangle scores and their exact weighted Fourier costs -/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerGeometry

def rectangleScore {m : ℕ} (u v z : ClippingCube m) : ℝ :=
  -(1 : ℝ) / 2 + pointIndicator (cubeOne m) z + pointIndicator v z -
    pointIndicator u z - pointIndicator (cubeTranslation u v) z

def rectangleBaseline {m : ℕ} (u z : ClippingCube m) : ℝ :=
  -(1 : ℝ) / 2 + pointIndicator (cubeOne m) z - pointIndicator u z

def rectangleEffectiveCost {m : ℕ} (w : Finset (Fin m) → ℝ)
    (u v : ClippingCube m) : ℝ :=
  (walshExpansion w v - walshExpansion w (cubeTranslation u v)) /
    Fintype.card (ClippingCube m)

def rectangleBaselineCost {m : ℕ} (w : Finset (Fin m) → ℝ) (u : ClippingCube m) : ℝ :=
  w ∅ / 2 + (walshExpansion w (cubeOne m) - walshExpansion w u) /
    Fintype.card (ClippingCube m)

theorem rectangleScore_coefficient {m : ℕ} (u v : ClippingCube m)
    (s : Finset (Fin m)) :
    walshCoefficients (rectangleScore u v) s =
      (if s = ∅ then -(1 : ℝ) / 2 else 0) +
      (1 - walshCharacter s u) * (1 + walshCharacter s v) /
        Fintype.card (ClippingCube m) := by
  unfold rectangleScore
  rw [walshCoefficients_sub, walshCoefficients_sub, walshCoefficients_add,
    walshCoefficients_add, walshCoefficients_const]
  simp only [walshCoefficients_pointIndicator, walshCharacter_one,
    walshCharacter_translation]
  ring

theorem rectangleScore_coefficient_empty {m : ℕ} (u v : ClippingCube m) :
    walshCoefficients (rectangleScore u v) ∅ = -(1 : ℝ) / 2 := by
  rw [rectangleScore_coefficient]
  simp [walshCharacter]

theorem rectangleScore_coefficient_nonempty_nonneg {m : ℕ} (u v : ClippingCube m)
    (s : Finset (Fin m)) (hs : s ≠ ∅) :
    0 ≤ walshCoefficients (rectangleScore u v) s := by
  rw [rectangleScore_coefficient, if_neg hs, zero_add]
  have hu : 0 ≤ 1 - walshCharacter s u := by
    rcases walshCharacter_eq_one_or_neg_one s u with h | h <;> rw [h] <;> norm_num
  have hv : 0 ≤ 1 + walshCharacter s v := by
    rcases walshCharacter_eq_one_or_neg_one s v with h | h <;> rw [h] <;> norm_num
  exact div_nonneg (mul_nonneg hu hv) (Nat.cast_nonneg _)

theorem rectangleScore_coefficient_even {m : ℕ} (u v : ClippingCube m)
    (s : Finset (Fin m)) (hs : s ≠ ∅) (heven : walshCharacter s u = 1) :
    walshCoefficients (rectangleScore u v) s = 0 := by
  rw [rectangleScore_coefficient, if_neg hs, heven]
  ring

/-- The exact cost is independent of any sign or dominance condition on
the inverse cost transform. -/
theorem rectangleScore_exact_cost {m : ℕ} (w : Finset (Fin m) → ℝ)
    (u v : ClippingCube m) :
    weightedWalshCost w (rectangleScore u v) =
      rectangleBaselineCost w u + rectangleEffectiveCost w u v := by
  have hterm (s : Finset (Fin m)) :
      w s * |walshCoefficients (rectangleScore u v) s| =
        (if s = ∅ then w ∅ / 2 else 0) +
          (w s * walshCharacter s (cubeOne m) + w s * walshCharacter s v -
            w s * walshCharacter s u - w s * walshCharacter s (cubeTranslation u v)) /
              Fintype.card (ClippingCube m) := by
    by_cases hs : s = ∅
    · subst s
      rw [rectangleScore_coefficient_empty]
      norm_num [walshCharacter]
      ring
    · rw [abs_of_nonneg (rectangleScore_coefficient_nonempty_nonneg u v s hs),
        rectangleScore_coefficient, if_neg hs, walshCharacter_one,
        walshCharacter_translation]
      simp only [if_neg hs]
      ring
  unfold weightedWalshCost weightedL1
  simp_rw [hterm]
  rw [Finset.sum_add_distrib, ← Finset.sum_div]
  simp only [Finset.sum_ite_eq', Finset.mem_univ, if_true,
    Finset.sum_sub_distrib, Finset.sum_add_distrib]
  change w ∅ / 2 + (walshExpansion w (cubeOne m) + walshExpansion w v -
    walshExpansion w u - walshExpansion w (cubeTranslation u v)) /
      Fintype.card (ClippingCube m) = _
  unfold rectangleBaselineCost rectangleEffectiveCost
  ring

/-- The common dual is exactly saturated by every rectangle in its
family. No minimizer selection is involved in this equality. -/
theorem rectangleScore_dual_saturation {m : ℕ} (w : Finset (Fin m) → ℝ)
    (dual : Finset (Fin m) → ℝ) (u v : ClippingCube m)
    (hzero : dual ∅ = -w ∅)
    (hodd : ∀ s, walshCharacter s u ≠ 1 → dual s = w s) :
    uniformCubeMean (fun z => walshExpansion dual z * rectangleScore u v z) =
      weightedWalshCost w (rectangleScore u v) := by
  rw [walsh_inner_identity]
  simp only [walshCoefficients_expansion, weightedWalshCost, weightedL1]
  apply Finset.sum_congr rfl
  intro s _
  by_cases hs : s = ∅
  · subst s
    rw [hzero, rectangleScore_coefficient_empty]
    norm_num
  · by_cases heven : walshCharacter s u = 1
    · rw [rectangleScore_coefficient_even u v s hs heven]
      simp
    · rw [hodd s heven, abs_of_nonneg (rectangleScore_coefficient_nonempty_nonneg u v s hs)]

end NeuralGeneralization.OnlineLowerGeometry
