import NeuralGeneralization.OnlineLowerTanhGeometryRectangle

/-! # Quantitative Fourier consequences of the rectangle dual -/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerGeometry

def fourierDualDeficit {m : ℕ} (dual : Finset (Fin m) → ℝ)
    (g : ClippingCube m → ℝ) (B : ℝ) : ℝ :=
  B - uniformCubeMean (fun z => walshExpansion dual z * g z)

theorem fourier_defect_sum {m : ℕ} (w dual : Finset (Fin m) → ℝ)
    (g : ClippingCube m → ℝ) :
    (∑ s, (w s * |walshCoefficients g s| - dual s * walshCoefficients g s)) =
      weightedWalshCost w g - uniformCubeMean (fun z => walshExpansion dual z * g z) := by
  rw [Finset.sum_sub_distrib, walsh_inner_identity]
  simp only [walshCoefficients_expansion, weightedWalshCost, weightedL1]

theorem fourierDualDeficit_nonneg {m : ℕ} (w dual : Finset (Fin m) → ℝ)
    (g : ClippingCube m → ℝ) (B : ℝ) (hdual : ∀ s, |dual s| ≤ w s)
    (hcost : weightedWalshCost w g ≤ B) : 0 ≤ fourierDualDeficit dual g B := by
  have h := walsh_dual_bound w g (walshExpansion dual)
    (fun s => by rw [walshCoefficients_expansion]; exact hdual s)
  unfold fourierDualDeficit
  linarith

def invariantRemainder {m : ℕ} (u : ClippingCube m) (g : ClippingCube m → ℝ) :
    ClippingCube m → ℝ :=
  walshExpansion (fun s => if s ≠ ∅ ∧ walshCharacter s u = 1 then walshCoefficients g s else 0)

/-- The nonconstant even modes are exactly the symmetric part after
removing the constant coefficient. -/
theorem invariantRemainder_symmetry {m : ℕ} (u : ClippingCube m)
    (g : ClippingCube m → ℝ) (z : ClippingCube m) :
    g z + g (cubeTranslation u z) =
      2 * (walshCoefficients g ∅ + invariantRemainder u g z) := by
  have hterm (s : Finset (Fin m)) :
      walshCoefficients g s * walshCharacter s z +
        walshCoefficients g s * walshCharacter s (cubeTranslation u z) =
      2 * ((if s = ∅ then walshCoefficients g ∅ else 0) +
        (if s ≠ ∅ ∧ walshCharacter s u = 1 then walshCoefficients g s else 0) *
          walshCharacter s z) := by
    rw [walshCharacter_translation]
    by_cases hs : s = ∅
    · subst s
      simp [walshCharacter]
      ring
    · rcases walshCharacter_eq_one_or_neg_one s u with h | h <;> norm_num [hs, h] <;> ring
  calc
    _ = walshExpansion (walshCoefficients g) z +
        walshExpansion (walshCoefficients g) (cubeTranslation u z) := by
      rw [walshExpansion_coefficients, walshExpansion_coefficients]
    _ = ∑ s, (walshCoefficients g s * walshCharacter s z +
        walshCoefficients g s * walshCharacter s (cubeTranslation u z)) := by
      simp only [walshExpansion, Finset.sum_add_distrib]
    _ = _ := by
      simp_rw [hterm]
      rw [← Finset.mul_sum, Finset.sum_add_distrib]
      simp only [Finset.sum_ite_eq', Finset.mem_univ, if_true,
        invariantRemainder, walshExpansion]

/-- Strict coefficient slack bounds the entire symmetric remainder in
supremum norm, with the original dual deficit and no dimension loss. -/
theorem invariantRemainder_abs_le {m : ℕ} (w dual : Finset (Fin m) → ℝ)
    (u : ClippingCube m) (g : ClippingCube m → ℝ) (B ε : ℝ)
    (hε : 0 < ε) (hdual : ∀ s, |dual s| ≤ w s)
    (hslack : ∀ s, s ≠ ∅ → walshCharacter s u = 1 → ε ≤ w s - |dual s|)
    (hcost : weightedWalshCost w g ≤ B) (z : ClippingCube m) :
    |invariantRemainder u g z| ≤ fourierDualDeficit dual g B / ε := by
  let mass : ℝ := ∑ s : Finset (Fin m),
    if s ≠ ∅ ∧ walshCharacter s u = 1 then |walshCoefficients g s| else 0
  have hmass : ε * mass ≤ fourierDualDeficit dual g B := by
    have hterm (s : Finset (Fin m)) :
        ε * (if s ≠ ∅ ∧ walshCharacter s u = 1 then |walshCoefficients g s| else 0) ≤
          w s * |walshCoefficients g s| - dual s * walshCoefficients g s := by
      by_cases hs : s ≠ ∅ ∧ walshCharacter s u = 1
      · rw [if_pos hs]
        exact coefficient_slack _ _ _ ε (hslack s hs.1 hs.2)
      · rw [if_neg hs, mul_zero]
        exact coefficient_defect_nonneg _ _ _ (hdual s)
    have hh := Finset.sum_le_sum (fun s (_ : s ∈ Finset.univ) => hterm s)
    rw [fourier_defect_sum, ← Finset.mul_sum] at hh
    dsimp only [fourierDualDeficit]
    exact hh.trans (sub_le_sub_right hcost _)
  have habs : |invariantRemainder u g z| ≤ mass := by
    unfold invariantRemainder walshExpansion
    calc
      _ ≤ ∑ s, |(if s ≠ ∅ ∧ walshCharacter s u = 1 then walshCoefficients g s else 0) *
          walshCharacter s z| := Finset.abs_sum_le_sum_abs _ _
      _ = mass := by
        simp only [abs_mul, abs_walshCharacter, mul_one, abs_ite, abs_zero, mass]
  apply (le_div_iff₀ hε).mpr
  have hh := mul_le_mul_of_nonneg_left habs hε.le
  nlinarith

/-- Saturation at the positive weight controls a coefficient's negative
part by the same total deficit. -/
theorem saturated_coefficient_lower {m : ℕ} (w dual : Finset (Fin m) → ℝ)
    (g : ClippingCube m → ℝ) (B w₀ : ℝ) (hw0 : 0 < w₀)
    (hw : ∀ s, w₀ ≤ w s) (hdual : ∀ s, |dual s| ≤ w s)
    (hcost : weightedWalshCost w g ≤ B) (s : Finset (Fin m)) (hs : dual s = w s) :
    -fourierDualDeficit dual g B / (2 * w₀) ≤ walshCoefficients g s := by
  have hD := fourierDualDeficit_nonneg w dual g B hdual hcost
  by_cases hnonneg : 0 ≤ walshCoefficients g s
  · exact (div_nonpos_of_nonpos_of_nonneg (by linarith) (by linarith)).trans hnonneg
  · have hnegative : walshCoefficients g s < 0 := lt_of_not_ge hnonneg
    have hterm := Finset.single_le_sum
      (fun t (_ : t ∈ Finset.univ) => coefficient_defect_nonneg (w t)
        (walshCoefficients g t) (dual t) (hdual t)) (Finset.mem_univ s)
    rw [fourier_defect_sum, hs, abs_of_neg hnegative] at hterm
    have hweight := mul_nonneg (sub_nonneg.mpr (hw s)) (neg_nonneg.mpr hnegative.le)
    apply (div_le_iff₀ (by linarith : 0 < 2 * w₀)).mpr
    unfold fourierDualDeficit
    nlinarith

end NeuralGeneralization.OnlineLowerGeometry
