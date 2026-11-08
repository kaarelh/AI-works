import NeuralGeneralization.OnlineLowerTanhCodeLocal
import Mathlib.Tactic.Positivity

/-! Explicit polynomial radii used to absorb all competing orientations. -/
noncomputable section
namespace NeuralGeneralization.OnlineLowerTanh

lemma inverse_power_absorption_numerics (D : ℝ) (p R : ℕ)
    (hD : 2 ≤ D) (hp : (p:ℝ) ≤ D) (hR : 16 ≤ R) :
    let η := (D^2)⁻¹
    0 < η ∧ (p:ℝ)*(D*η)^R ≤ 1/2 ∧
    2*D^3*(D^12)⁻¹*D^2 ≤ η^2 ∧
    2*D^3*D*(2*D^2*(p:ℝ)*(D*η)^R/η^2) ≤ 1 := by
  have hD0 : 0 < D := by linarith
  have hDn : D ≠ 0 := hD0.ne'
  have hD1 : 1 ≤ D := by linarith
  have hη : D*(D^2)⁻¹ = D⁻¹ := by field_simp <;> ring
  have hpow2 : D^2 ≤ D^R := pow_le_pow_right₀ hD1 (by omega)
  have hpow13 : D^13 ≤ D^R := pow_le_pow_right₀ hD1 (by omega)
  have hp0 : 0 ≤ (p:ℝ) := by positivity
  dsimp only
  refine ⟨by positivity, ?_, ?_, ?_⟩
  · rw [hη,inv_pow]
    have hi : (D^R)⁻¹ ≤ (D^2)⁻¹ := (inv_le_inv₀ (by positivity) (by positivity)).mpr hpow2
    calc
      (p:ℝ)*(D^R)⁻¹ ≤ D*(D^2)⁻¹ := mul_le_mul hp hi (by positivity) (by positivity)
      _ = D⁻¹ := hη
      _ ≤ (2:ℝ)⁻¹ := (inv_le_inv₀ hD0 (by norm_num : (0:ℝ)<2)).mpr hD
      _ = 1/2 := by norm_num
  · have he : 2*D^3*(D^12)⁻¹*D^2 = (2/D^3)*(D^2)⁻¹^2 := by field_simp <;> ring
    rw [he]
    apply mul_le_of_le_one_left (by positivity)
    apply (div_le_one (by positivity : 0<D^3)).mpr
    have hcube : (2:ℝ)^3 ≤ D^3 := pow_le_pow_left₀ (by norm_num) hD 3
    norm_num at hcube
    linarith
  · rw [hη,inv_pow]
    have he : 2*D^3*D*(2*D^2*(p:ℝ)*(D^R)⁻¹/((D^2)⁻¹)^2) =
        4*(p:ℝ)*D^10/(D^R) := by field_simp <;> ring
    rw [he]
    apply (div_le_one (by positivity : 0<D^R)).mpr
    have hsq : (4:ℝ) ≤ D^2 := by nlinarith
    calc
      4*(p:ℝ)*D^10 ≤ 4*D*D^10 := by gcongr
      _ = 4*D^11 := by ring
      _ ≤ D^2*D^11 := mul_le_mul_of_nonneg_right hsq (by positivity)
      _ = D^13 := by ring
      _ ≤ D^R := hpow13

end NeuralGeneralization.OnlineLowerTanh
