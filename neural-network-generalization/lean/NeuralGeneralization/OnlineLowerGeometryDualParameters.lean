import NeuralGeneralization.OnlineLowerGeometryCore
import Mathlib.Tactic.FieldSimp

/-!
# Scalar parameters of the common rectangle dual

Here `L = |G| / 2`, `wstar = W(u)`, and `K` is the sum of the other
positive quotient costs.  The definitions and estimates are the literal
parameters of the tanh/hardtanh common dual, not an abstract dual oracle.
-/

noncomputable section

namespace NeuralGeneralization.OnlineLowerGeometry

def commonDualH (L w₀ wstar K : ℝ) : ℝ :=
  ((L - 1) * (wstar - 2 * w₀ / L) + K) / (L - 2)

def commonDualB (L h K : ℝ) : ℝ := 2 * L * (h + K) / (L - 1)
def commonDualA (L w₀ h K : ℝ) : ℝ := 2 * w₀ - commonDualB L h K

/-- This is exactly the cancellation giving `dual(u)=0` and the anchor
value `dual(0)=|G|(W(0)-W(u))`. -/
theorem commonDual_cancellation (L w₀ wstar K : ℝ)
    (hL : 2 < L) :
    2 * L * (wstar - commonDualH L w₀ wstar K) - 4 * w₀ +
      commonDualB L (commonDualH L w₀ wstar K) K = 0 := by
  have h₀ : L ≠ 0 := by linarith
  have h₁ : L - 1 ≠ 0 := by linarith
  have h₂ : L - 2 ≠ 0 := by linarith
  unfold commonDualH commonDualB
  field_simp [h₀, h₁, h₂]
  ring

theorem commonDualH_bounds (L w₀ wstar K : ℝ)
    (hL : 32 ≤ L) (hw₀ : 0 ≤ w₀) (hwstar : 0 < wstar)
    (hK : 0 ≤ K) (hKup : K ≤ wstar / 4)
    (hscale : 16 * w₀ ≤ 2 * L * wstar) :
    3 * wstar / 4 ≤ commonDualH L w₀ wstar K ∧
      commonDualH L w₀ wstar K ≤ 5 * wstar / 4 := by
  have hLpos : 0 < L := by linarith
  have hden : 0 < L - 2 := by linarith
  have hL₁ : 0 ≤ L - 1 := by linarith
  have hphase : 2 * w₀ / L ≤ wstar / 4 := by
    apply (div_le_iff₀ hLpos).mpr
    nlinarith
  have hphase_nonneg : 0 ≤ 2 * w₀ / L := div_nonneg (by linarith) hLpos.le
  unfold commonDualH
  constructor
  · apply (le_div_iff₀ hden).mpr
    have hprod := mul_nonneg hL₁ (sub_nonneg.mpr hphase)
    nlinarith
  · apply (div_le_iff₀ hden).mpr
    have hprod := mul_nonneg hL₁ hphase_nonneg
    have hlarge := mul_nonneg (by linarith : 0 ≤ L - 7) hwstar.le
    nlinarith

theorem commonDualB_bounds (L h K wstar : ℝ)
    (hL : 32 ≤ L) (hwstar : 0 < wstar)
    (hhlo : 3 * wstar / 4 ≤ h) (hhhi : h ≤ 5 * wstar / 4)
    (hK : 0 ≤ K) (hKup : K ≤ wstar / 4) :
    0 < commonDualB L h K ∧ commonDualB L h K ≤ 4 * wstar := by
  have hden : 0 < L - 1 := by linarith
  have hLpos : 0 < L := by linarith
  have hhpos : 0 < h := by linarith
  unfold commonDualB
  constructor
  · exact div_pos (mul_pos (mul_pos (by norm_num) hLpos) (by linarith)) hden
  · apply (div_le_iff₀ hden).mpr
    have hprod := mul_nonneg hLpos.le (by linarith : 0 ≤ 3 * wstar / 2 - (h + K))
    have hlarge := mul_nonneg (by linarith : 0 ≤ L - 4) hwstar.le
    nlinarith

theorem commonDualA_bounds (L w₀ h K wstar : ℝ)
    (hB : 0 ≤ commonDualB L h K) (hBup : commonDualB L h K ≤ 4 * wstar)
    (hsmall : wstar ≤ w₀ / 16) :
    7 * w₀ / 4 ≤ commonDualA L w₀ h K ∧ commonDualA L w₀ h K ≤ 2 * w₀ := by
  unfold commonDualA
  constructor <;> linarith

/-- The nonconstant Fourier mass in the probability used by the dual is
at most one third. -/
theorem commonDual_probability_mass_bound (L h K wstar : ℝ)
    (hL : 32 ≤ L) (hwstar : 0 < wstar)
    (hh : 3 * wstar / 4 ≤ h) (hK : 0 ≤ K) (hKup : K ≤ wstar / 4) :
    0 ≤ (L - 1) * K / (L * h + K) ∧
      (L - 1) * K / (L * h + K) ≤ 1 / 3 := by
  have hLpos : 0 < L := by linarith
  have hhpos : 0 < h := by linarith
  have hden : 0 < L * h + K := by nlinarith [mul_pos hLpos hhpos]
  constructor
  · exact div_nonneg (mul_nonneg (by linarith) hK) hden.le
  · apply (div_le_iff₀ hden).mpr
    have hprod := mul_nonneg hLpos.le (by linarith : 0 ≤ h - 3 * K)
    nlinarith

theorem commonDual_probability_zero_mass (L h K : ℝ)
    (hL : 1 < L) (hh : 0 < h) (hK : 0 ≤ K) :
    0 < (h + K) / (L * h + K) ∧
      (h + K) / (L * h + K) < 1 ∧
      1 - (h + K) / (L * h + K) = (L - 1) * h / (L * h + K) := by
  have hLpos : 0 < L := by linarith
  have hden : 0 < L * h + K := by nlinarith [mul_pos hLpos hh]
  refine ⟨div_pos (by linarith) hden, ?_, ?_⟩
  · apply (div_lt_iff₀ hden).mpr
    nlinarith [mul_pos (by linarith : 0 < L - 1) hh]
  · field_simp [ne_of_gt hden]
    ring

end NeuralGeneralization.OnlineLowerGeometry
