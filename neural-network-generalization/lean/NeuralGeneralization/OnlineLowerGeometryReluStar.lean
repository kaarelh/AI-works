import NeuralGeneralization.OnlineLowerGeometryReluDual

/-!
# Exact ReLU logical star coefficients and dual saturation

These are score identities on the actual finite Walsh cube.  Their neural
realizations and the physical code embedding are separate dependencies.
-/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerGeometry

def reluStar {d : ℕ} (v : ClippingCube d) (x : ClippingCube d) : ℝ :=
  -(1 : ℝ) / 2 + pointIndicator (cubeOne d) x + pointIndicator v x

theorem reluStar_coefficient {d : ℕ} (v : ClippingCube d) (S : Finset (Fin d)) :
    walshCoefficients (reluStar v) S = (if S = ∅ then -(1 : ℝ) / 2 else 0) +
      (1 + walshCharacter S v) / Fintype.card (ClippingCube d) := by
  unfold reluStar
  rw [walshCoefficients_add, walshCoefficients_add, walshCoefficients_const,
    walshCoefficients_pointIndicator, walshCoefficients_pointIndicator,
    walshCharacter_one]
  ring

theorem reluStar_coefficient_empty_nonpos {d : ℕ} (v : ClippingCube d)
    (hcard : 4 ≤ Fintype.card (ClippingCube d)) :
    walshCoefficients (reluStar v) ∅ ≤ 0 := by
  have hcardR : (4 : ℝ) ≤ Fintype.card (ClippingCube d) := by exact_mod_cast hcard
  have hM : (0 : ℝ) < Fintype.card (ClippingCube d) := by linarith
  rw [reluStar_coefficient]
  simp only [walshCharacter, Finset.prod_empty, if_true]
  have hdiv : (1 + (1 : ℝ)) / Fintype.card (ClippingCube d) ≤ 1 / 2 := by
    apply (div_le_iff₀ hM).mpr
    linarith
  linarith

theorem reluStar_coefficient_nonempty_nonneg {d : ℕ} (v : ClippingCube d)
    (S : Finset (Fin d)) (hS : S ≠ ∅) :
    0 ≤ walshCoefficients (reluStar v) S := by
  rw [reluStar_coefficient, if_neg hS, zero_add]
  have hχ : 0 ≤ 1 + walshCharacter S v := by
    nlinarith [walshCharacter_sq S v, sq_nonneg (walshCharacter S v + 1)]
  exact div_nonneg hχ (Nat.cast_nonneg _)

theorem reluStar_coefficient_difference_zero {d : ℕ} (H : CubeSubgroup d)
    (v z : ClippingCube d) (hz : cubeTranslation v z ∈ H.carrier)
    (S : Finset (Fin d)) (hS : S ∈ H.differenceAnnihilator v) :
    walshCoefficients (reluStar z) S = 0 := by
  have hSnot : S ≠ ∅ := by
    intro heq
    subst S
    exact H.empty_not_differenceAnnihilator v hS
  rw [reluStar_coefficient, if_neg hSnot,
    H.difference_character_on_coset v z hz S hS]
  ring

theorem reluStar_coefficient_dual_saturation {d : ℕ}
    (w : Finset (Fin d) → ℝ) (H : CubeSubgroup d) (v z : ClippingCube d)
    (hz : cubeTranslation v z ∈ H.carrier)
    (hcard : 4 ≤ Fintype.card (ClippingCube d)) (S : Finset (Fin d)) :
    reluDualCoefficients w H v S * walshCoefficients (reluStar z) S =
      w S * |walshCoefficients (reluStar z) S| := by
  by_cases hS : S = ∅
  · subst S
    rw [abs_of_nonpos (reluStar_coefficient_empty_nonpos z hcard)]
    simp only [reluDualCoefficients, if_true,
      if_neg (H.empty_not_differenceAnnihilator v)]
    ring
  · by_cases hE : S ∈ H.differenceAnnihilator v
    · rw [reluStar_coefficient_difference_zero H v z hz S hE]
      simp
    · rw [abs_of_nonneg (reluStar_coefficient_nonempty_nonneg z S hS)]
      simp only [reluDualCoefficients, if_neg hS, if_neg hE, sub_zero]

/-- The explicit logical star saturates the explicit feasible dual. -/
theorem reluStar_dual_saturation {d : ℕ}
    (w : Finset (Fin d) → ℝ) (H : CubeSubgroup d) (v z : ClippingCube d)
    (hz : cubeTranslation v z ∈ H.carrier)
    (hcard : 4 ≤ Fintype.card (ClippingCube d)) :
    uniformCubeMean (fun x => reluDualScore w H v x * reluStar z x) =
      weightedWalshCost w (reluStar z) := by
  rw [walsh_inner_identity]
  unfold weightedWalshCost weightedL1
  apply Finset.sum_congr rfl
  intro S _
  rw [reluDualScore, walshCoefficients_expansion]
  exact reluStar_coefficient_dual_saturation w H v z hz hcard S

end NeuralGeneralization.OnlineLowerGeometry
