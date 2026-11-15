import NeuralGeneralization.OnlineLowerTanhPaperLP
import NeuralGeneralization.OnlineLowerTanhGeometryCoset

/-! # Translation averaging for the full subgroup-positive sign cell

This is the literal averaging reduction used after the point-positive lemma
in the tanh paper.  Strict cost reduction comes from deleting nonzero Walsh
coefficients outside the subgroup annihilator, not from strict convexity.
-/

noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerGeometry

namespace CubeSubgroup
variable {m : ℕ} (H : CubeSubgroup m)

def average (g : ClippingCube m → ℝ) (x : ClippingCube m) : ℝ :=
  (∑ a ∈ H.carrier, g (cubeTranslation a x)) / H.carrier.card

def PositiveCell (g : ClippingCube m → ℝ) : Prop :=
  (∀ x ∈ H.carrier, (1:ℝ)/2 ≤ g x) ∧
  (∀ x ∉ H.carrier, g x ≤ -(1:ℝ)/2)

theorem average_preserves_positiveCell (g : ClippingCube m → ℝ)
    (hg : H.PositiveCell g) : H.PositiveCell (H.average g) := by
  have hj : 0 < (H.carrier.card : ℝ) := Nat.cast_pos.mpr H.card_pos
  constructor
  · intro x hx
    unfold average
    apply (le_div_iff₀ hj).mpr
    calc
      (1:ℝ)/2 * H.carrier.card = ∑ a ∈ H.carrier, (1:ℝ)/2 := by simp; ring
      _ ≤ _ := Finset.sum_le_sum (fun a ha => hg.1 _ (H.mul_mem a ha x hx))
  · intro x hx
    unfold average
    apply (div_le_iff₀ hj).mpr
    calc
      _ ≤ ∑ a ∈ H.carrier, -(1:ℝ)/2 := Finset.sum_le_sum (fun a ha =>
        hg.2 _ (fun h => hx ((H.translate_mem_iff a ha x).mp h)))
      _ = _ := by simp; ring

theorem average_coefficient (g : ClippingCube m → ℝ) (s : Finset (Fin m)) :
    walshCoefficients (H.average g) s =
      if H.Annihilates s then walshCoefficients g s else 0 := by
  have hj : (H.carrier.card : ℝ) ≠ 0 := ne_of_gt (Nat.cast_pos.mpr H.card_pos)
  have hsplit : walshCoefficients (H.average g) s =
      (∑ a ∈ H.carrier, walshCoefficients (fun x => g (cubeTranslation a x)) s) /
        H.carrier.card := by
    unfold walshCoefficients uniformCubeMean average
    simp_rw [div_eq_mul_inv, Finset.sum_mul]
    rw [Finset.sum_comm]
    apply Finset.sum_congr rfl
    intro a ha
    apply Finset.sum_congr rfl
    intro x hx
    ring
  rw [hsplit]
  simp_rw [walshCoefficients_translation]
  rw [← Finset.sum_mul]
  have hchar : (∑ a ∈ H.carrier, walshCharacter s a) =
      if H.Annihilates s then (H.carrier.card : ℝ) else 0 := by
    simpa using H.character_sum s
  rw [hchar]
  split_ifs <;> simp [hj]

theorem average_cost_le (w : Finset (Fin m) → ℝ) (hw : ∀ s, 0 ≤ w s)
    (g : ClippingCube m → ℝ) :
    weightedWalshCost w (H.average g) ≤ weightedWalshCost w g := by
  unfold weightedWalshCost weightedL1
  apply Finset.sum_le_sum
  intro s _
  rw [H.average_coefficient]
  split_ifs
  · exact le_rfl
  · simp only [abs_zero, mul_zero]
    exact mul_nonneg (hw s) (abs_nonneg _)

theorem average_cost_lt_of_coefficient (w : Finset (Fin m) → ℝ)
    (hw : ∀ s, 0 < w s) (g : ClippingCube m → ℝ)
    (s : Finset (Fin m)) (hs : ¬H.Annihilates s) (hgs : walshCoefficients g s ≠ 0) :
    weightedWalshCost w (H.average g) < weightedWalshCost w g := by
  unfold weightedWalshCost weightedL1
  apply Finset.sum_lt_sum
  · intro t _
    rw [H.average_coefficient]
    split_ifs
    · exact le_rfl
    · simp only [abs_zero, mul_zero]
      exact mul_nonneg (hw t).le (abs_nonneg _)
  · refine ⟨s, Finset.mem_univ _, ?_⟩
    rw [H.average_coefficient, if_neg hs, abs_zero, mul_zero]
    exact mul_pos (hw s) (abs_pos.mpr hgs)

theorem average_invariant (g : ClippingCube m → ℝ)
    (a : ClippingCube m) (ha : a ∈ H.carrier) (x : ClippingCube m) :
    H.average g (cubeTranslation a x) = H.average g x := by
  rw [← walshExpansion_coefficients (H.average g) (cubeTranslation a x),
    ← walshExpansion_coefficients (H.average g) x]
  unfold walshExpansion
  apply Finset.sum_congr rfl
  intro s _
  rw [H.average_coefficient, walshCharacter_translation]
  by_cases hs : H.Annihilates s
  · rw [if_pos hs, hs a ha, one_mul]
  · simp [hs]

theorem invariant_of_supported_coefficients (g : ClippingCube m → ℝ)
    (hg : ∀ s, ¬H.Annihilates s → walshCoefficients g s = 0)
    (a : ClippingCube m) (ha : a ∈ H.carrier) (x : ClippingCube m) :
    g (cubeTranslation a x) = g x := by
  rw [← walshExpansion_coefficients g (cubeTranslation a x),
    ← walshExpansion_coefficients g x]
  unfold walshExpansion
  apply Finset.sum_congr rfl
  intro s _
  rw [walshCharacter_translation]
  by_cases hs : H.Annihilates s
  · rw [hs a ha, one_mul]
  · rw [hg s hs, zero_mul, zero_mul]

/-- Every full-sign-cell optimizer is subgroup-invariant, because a
nonzero off-annihilator coefficient would be strictly removed by averaging. -/
theorem positiveCell_minimum_invariant (w : Finset (Fin m) → ℝ)
    (hw : ∀ s, 0 < w s) (g : ClippingCube m → ℝ)
    (hg : H.PositiveCell g)
    (hmin : ∀ q, H.PositiveCell q → weightedWalshCost w g ≤ weightedWalshCost w q) :
    (∀ s, ¬H.Annihilates s → walshCoefficients g s = 0) ∧
    ∀ a ∈ H.carrier, ∀ x, g (cubeTranslation a x) = g x := by
  have hcoeff (s : Finset (Fin m)) (hs : ¬H.Annihilates s) : walshCoefficients g s = 0 := by
    by_contra hc
    have hl := H.average_cost_lt_of_coefficient w hw g s hs hc
    exact (not_lt_of_ge (hmin _ (H.average_preserves_positiveCell g hg))) hl
  exact ⟨hcoeff, fun a ha x => H.invariant_of_supported_coefficients g hcoeff a ha x⟩

end CubeSubgroup
end NeuralGeneralization.OnlineLowerGeometry
