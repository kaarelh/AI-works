import NeuralGeneralization.OnlineLowerTanhGeometryCalibration

/-! # Explicit density of the negative observed rectangle region -/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerGeometry

lemma uniformCubeMean_const {m : ℕ} (a : ℝ) :
    uniformCubeMean (fun _ : ClippingCube m => a) = a := by simp [uniformCubeMean]

lemma uniformCubeMean_sub {m : ℕ} (f g : ClippingCube m → ℝ) :
    uniformCubeMean (fun z => f z - g z) = uniformCubeMean f - uniformCubeMean g := by
  simp only [uniformCubeMean, Finset.sum_sub_distrib, sub_div]

lemma uniformCubeMean_pointIndicator {m : ℕ} (v : ClippingCube m) :
    uniformCubeMean (pointIndicator v) = 1 / Fintype.card (ClippingCube m) := by
  simp [uniformCubeMean, pointIndicator]

lemma uniformCubeMean_character {m : ℕ} (S : Finset (Fin m)) :
    uniformCubeMean (walshCharacter S) = if S = ∅ then 1 else 0 := by
  simpa only [walshCoefficients, one_mul] using walshCoefficients_const (d := m) 1 S

lemma uniformCubeMean_two_false {m : ℕ} (i j : Fin m) (hij : i ≠ j) :
    uniformCubeMean (fun z : ClippingCube m => if z i = false ∧ z j = false then (1 : ℝ) else 0) = 1 / 4 := by
  have hpoint (z : ClippingCube m) :
      (if z i = false ∧ z j = false then (1 : ℝ) else 0) =
        (1 / 4 : ℝ) * ((1 - walshCharacter {i} z - walshCharacter {j} z) + walshCharacter {i,j} z) := by
    cases hi : z i <;> cases hj : z j <;>
      norm_num [walshCharacter, cubeCoordinateSign, hij, hi, hj]
  rw [show (fun z : ClippingCube m => if z i = false ∧ z j = false then (1 : ℝ) else 0) =
    (fun z => (1 / 4 : ℝ) * ((1 - walshCharacter {i} z - walshCharacter {j} z) +
      walshCharacter {i,j} z)) from funext hpoint]
  rw [uniformCubeMean_mul, uniformCubeMean_add, uniformCubeMean_sub, uniformCubeMean_sub,
    uniformCubeMean_const, uniformCubeMean_character, uniformCubeMean_character,
    uniformCubeMean_character]
  simp

/-- Two fixed negative prefix coordinates already suffice: the enlarged
coset occupies at most a quarter of the cube, and removing the anchor
and the shift costs at most two further points. -/
theorem rectangleNegativeObserved_density {m : ℕ} (H : CubeSubgroup m)
    (v u : ClippingCube m) (i j : Fin m) (hij : i ≠ j)
    (hM : 8 ≤ Fintype.card (ClippingCube m))
    (hprefix : ∀ z, cubeTranslation v z ∈ (H.adjoinPoint u).carrier →
      z i = false ∧ z j = false) :
    (1 : ℝ) / 2 ≤ uniformCubeMean (fun z =>
      if z ∈ rectangleNegativeObserved H v u then 1 else 0) := by
  have hpoint (z : ClippingCube m) :
      1 - (if z i = false ∧ z j = false then (1 : ℝ) else 0) -
        pointIndicator (cubeOne m) z - pointIndicator u z ≤
      (if z ∈ rectangleNegativeObserved H v u then 1 else 0) := by
    by_cases hn : z ∈ rectangleNegativeObserved H v u
    · rw [if_pos hn]
      unfold pointIndicator
      split_ifs <;> norm_num
    · rw [if_neg hn]
      by_cases hz0 : z = cubeOne m
      · subst z
        simp only [pointIndicator, if_true]
        split_ifs <;> norm_num
      · by_cases hzu : z = u
        · subst z
          simp only [pointIndicator, if_neg hz0, if_true]
          split_ifs <;> norm_num
        · have hmem : cubeTranslation v z ∈ (H.adjoinPoint u).carrier := by
            by_contra hh
            exact hn ⟨⟨hh, hzu⟩, hz0⟩
          rw [if_pos (hprefix z hmem)]
          simp [pointIndicator, hz0, hzu]
  have hmean := uniformCubeMean_mono _ _ hpoint
  rw [uniformCubeMean_sub, uniformCubeMean_sub, uniformCubeMean_sub,
    uniformCubeMean_const, uniformCubeMean_two_false i j hij,
    uniformCubeMean_pointIndicator, uniformCubeMean_pointIndicator] at hmean
  have hMr : (8 : ℝ) ≤ Fintype.card (ClippingCube m) := by exact_mod_cast hM
  have hfrac : (1 : ℝ) / Fintype.card (ClippingCube m) ≤ 1 / 8 := by
    exact one_div_le_one_div_of_le (by norm_num) hMr
  linarith

end NeuralGeneralization.OnlineLowerGeometry
