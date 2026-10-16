import NeuralGeneralization.KernelPoissonIntegral
import NeuralGeneralization.ArcsineCoefficients
import Mathlib.Analysis.SpecialFunctions.Gamma.BohrMollerup
import Mathlib.Analysis.Real.Pi.Bounds

/-! Explicit Gamma-reference comparison for the actual first arcsine layer.
Only log-convexity and the Gamma recurrence are used; no asymptotic theorem
or scalar coefficient certificate is assumed. -/

noncomputable section
namespace NeuralGeneralization

/-- Midpoint log-convexity in a form without fractional powers. -/
theorem gamma_midpoint_square_le {s t : ℝ} (hs : 0 < s) (ht : 0 < t) :
    Real.Gamma ((s+t)/2)^2 ≤ Real.Gamma s*Real.Gamma t := by
  have h := Real.Gamma_mul_add_mul_le_rpow_Gamma_mul_rpow_Gamma hs ht
    (show (0 : ℝ) < 1/2 by norm_num) (show (0 : ℝ) < 1/2 by norm_num)
    (show (1/2 : ℝ)+1/2=1 by norm_num)
  rw [show (1/2 : ℝ)*s+(1/2)*t=(s+t)/2 by ring,
    ← Real.sqrt_eq_rpow,← Real.sqrt_eq_rpow] at h
  calc
    _ ≤ (Real.sqrt (Real.Gamma s)*Real.sqrt (Real.Gamma t))^2 :=
      pow_le_pow_left₀ (Real.Gamma_pos_of_pos (by positivity)).le h 2
    _ = _ := by rw [mul_pow,Real.sq_sqrt (Real.Gamma_pos_of_pos hs).le,
      Real.sq_sqrt (Real.Gamma_pos_of_pos ht).le]

def halfGammaCoefficient (m : ℕ) : ℝ := Real.Gamma ((m : ℝ)-1/2)/(m.factorial : ℝ)

theorem halfGammaCoefficient_pos {m : ℕ} (hm : 1 ≤ m) :
    0 < halfGammaCoefficient m := by
  have hmR : (1 : ℝ) ≤ m := by exact_mod_cast hm
  exact div_pos (Real.Gamma_pos_of_pos (by linarith)) (by positivity)

/-- Uniform Gamma-ratio bounds, including the initial index. -/
theorem halfGammaCoefficient_cubic_square_bounds {m : ℕ} (hm : 1 ≤ m) :
    1 ≤ (m : ℝ)^3*halfGammaCoefficient m^2 ∧
      (m : ℝ)^3*halfGammaCoefficient m^2 ≤ 4 := by
  have hmR : (1 : ℝ) ≤ m := by exact_mod_cast hm
  have hm0 : (0 : ℝ) < m := by linarith
  have hG : 0 < Real.Gamma (m : ℝ) := Real.Gamma_pos_of_pos hm0
  have hA : 0 < Real.Gamma ((m : ℝ)-1/2) := Real.Gamma_pos_of_pos (by linarith)
  have hrec : Real.Gamma ((m : ℝ)+1/2) =
      ((m : ℝ)-1/2)*Real.Gamma ((m : ℝ)-1/2) := by
    have h := Real.Gamma_add_one (show (m : ℝ)-1/2 ≠ 0 by linarith)
    convert h using 1 <;> congr 1 <;> ring
  have hlow := gamma_midpoint_square_le
    (show (0 : ℝ) < m-1/2 by linarith) (show (0 : ℝ) < m+1/2 by positivity)
  rw [show ((m : ℝ)-1/2+(m+1/2))/2=m by ring,hrec] at hlow
  have hlow' : Real.Gamma (m : ℝ)^2 ≤ (m : ℝ)*Real.Gamma ((m : ℝ)-1/2)^2 := by
    nlinarith only [hlow,sq_nonneg (Real.Gamma ((m : ℝ)-1/2))]
  have hupp := gamma_midpoint_square_le hm0 (show (0 : ℝ) < m+1 by positivity)
  rw [show ((m : ℝ)+(m+1))/2=m+1/2 by ring,hrec,
    Real.Gamma_add_one (ne_of_gt hm0)] at hupp
  have hcoef : (m : ℝ)^2 ≤ 4*((m : ℝ)-1/2)^2 := by nlinarith
  have hmul := mul_le_mul_of_nonneg_right hcoef (sq_nonneg (Real.Gamma ((m : ℝ)-1/2)))
  have hupp' : (m : ℝ)*Real.Gamma ((m : ℝ)-1/2)^2 ≤ 4*Real.Gamma (m : ℝ)^2 := by
    apply (mul_le_mul_iff_left₀ hm0).mp
    nlinarith only [hmul,hupp]
  have hfact : (m.factorial : ℝ) = (m : ℝ)*Real.Gamma (m : ℝ) := by
    rw [← Real.Gamma_nat_eq_factorial m,Real.Gamma_add_one (ne_of_gt hm0)]
  have hid : (m : ℝ)^3*halfGammaCoefficient m^2 =
      ((m : ℝ)*Real.Gamma ((m : ℝ)-1/2)^2)/(Real.Gamma (m : ℝ)^2) := by
    unfold halfGammaCoefficient
    rw [hfact]
    field_simp
  rw [hid]
  constructor
  · exact (one_le_div (sq_pos_of_pos hG)).mpr hlow'
  · exact (div_le_iff₀ (sq_pos_of_pos hG)).mpr hupp'

/-- Actual normalized arcsine coefficients are comparable to the Gamma
reference at every odd exponent, with explicit uniform constants. -/
theorem arcsineLinkCoefficient_gamma_comparison (n : ℕ) :
    halfGammaCoefficient (2*n+1)/8 ≤ arcsineLinkCoefficient n ∧
      arcsineLinkCoefficient n ≤ halfGammaCoefficient (2*n+1) := by
  have hc := arcsineCoefficient_cubic_square_bounds n
  have hg := halfGammaCoefficient_cubic_square_bounds (show 1 ≤ 2*n+1 by omega)
  simp only [Nat.cast_add,Nat.cast_mul,Nat.cast_one,Nat.cast_ofNat] at hg
  have hc0 := (arcsineCoefficient_pos n).le
  have hg0 := (halfGammaCoefficient_pos (show 1 ≤ 2*n+1 by omega)).le
  have hM : (0 : ℝ) < (2*n+1 : ℝ)^3 := by positivity
  have hupper : arcsineCoefficient n ≤ halfGammaCoefficient (2*n+1) := by
    apply (sq_le_sq₀ hc0 hg0).mp
    exact (mul_le_mul_iff_right₀ hM).mp (hc.2.trans hg.1)
  have hlower : halfGammaCoefficient (2*n+1) ≤ 4*arcsineCoefficient n := by
    apply (sq_le_sq₀ hg0 (by positivity)).mp
    apply (mul_le_mul_iff_right₀ hM).mp
    nlinarith only [hg.2,hc.1,mul_nonneg hM.le (sq_nonneg (arcsineCoefficient n))]
  have hpiLower : (1/2 : ℝ) ≤ 2/Real.pi := by
    apply (le_div_iff₀ Real.pi_pos).mpr
    linarith [Real.pi_lt_four]
  have hpiUpper : 2/Real.pi ≤ 1 := (div_le_one Real.pi_pos).mpr Real.two_le_pi
  have hlinkLower : arcsineCoefficient n ≤ 2*arcsineLinkCoefficient n := by
    unfold arcsineLinkCoefficient
    nlinarith [mul_le_mul_of_nonneg_right hpiLower hc0]
  have hlinkUpper : arcsineLinkCoefficient n ≤ arcsineCoefficient n := by
    unfold arcsineLinkCoefficient
    simpa using mul_le_mul_of_nonneg_right hpiUpper hc0
  exact ⟨by linarith, hlinkUpper.trans hupper⟩

end NeuralGeneralization
