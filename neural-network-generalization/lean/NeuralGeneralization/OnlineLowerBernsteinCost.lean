import NeuralGeneralization.OnlineLowerBernsteinConvolution
import NeuralGeneralization.OnlineLowerGammaCost

/-! The inverse balanced ReLU coefficient has a strictly positive Laplace remainder.
All kernels below are actual integrals, rather than analytic hypotheses. -/
noncomputable section
open MeasureTheory Set
namespace NeuralGeneralization.OnlineLowerBernstein

def reluCostSlope : ℝ := Real.sqrt 2 * Real.Gamma (1/2)
def reluCostIntercept : ℝ := -(3/4) * reluCostSlope
def reluCostDensity (t : ℝ) : ℝ := 4 * reluCostSlope * positiveKernel (2*t)

theorem reluCostSlope_pos : 0 < reluCostSlope :=
  mul_pos (Real.sqrt_pos.mpr (by norm_num)) (Real.Gamma_pos_of_pos (by norm_num))

theorem reluCostDensity_pos (t : ℝ) : 0 < reluCostDensity t := by
  unfold reluCostDensity
  exact mul_pos (mul_pos (by norm_num) reluCostSlope_pos) (positiveKernel_pos _)

theorem positiveKernel_measurable : Measurable positiveKernel :=
  (Bprime_continuous.measurable.div_const 2).sub Bsecond_measurable

theorem positiveKernel_laplaceIntegrable {z : ℝ} (hz : 1/2 < z) :
    LaplaceIntegrable z positiveKernel :=
  laplaceIntegrable_of_exp_bound z 2 positiveKernel hz (by norm_num)
    positiveKernel_measurable positiveKernel_abs_bound

theorem gammaCost_twice {z : ℝ} (hz : 1/2 < z) :
    gammaCost (2*z) = 2 * reluCostSlope * (z*(z-1/2)*laplace z B) := by
  have hz0 : 0 < z := by linarith
  have hgm : Real.Gamma (z-1/2) ≠ 0 := (Real.Gamma_pos_of_pos (by linarith)).ne'
  have hzp : z-1/2 ≠ 0 := by linarith
  have hs : Real.sqrt z ≠ 0 := (Real.sqrt_pos.mpr hz0).ne'
  have hsq : Real.sqrt z ^ 2 = z := Real.sq_sqrt hz0.le
  have hg : Real.Gamma (z+1/2) = (z-1/2)*Real.Gamma (z-1/2) := by
    convert! Real.Gamma_add_one hzp using 1 <;> congr 1 <;> ring
  rw [laplace_B_gamma hz0, hg]
  unfold gammaCost reluCostSlope
  rw [Real.sqrt_mul (by norm_num : (0 : ℝ) ≤ 2)]
  rw [show 2*z/2=z by ring, show (2*z-1)/2=z-1/2 by ring]
  have hgm' : Real.Gamma ((2*z-1)/2) ≠ 0 := by
    simpa only [show (2*z-1)/2=z-1/2 by ring] using hgm
  have hdiff : 2*z-1 ≠ 0 := by linarith
  field_simp [hgm, hgm', hzp, hs, hdiff]
  <;> nlinarith

theorem gammaCost_bernstein_half {n : ℝ} (hn : 1 < n) :
    gammaCost n = reluCostSlope*n + reluCostIntercept -
      2*reluCostSlope*laplace (n/2) positiveKernel := by
  have hz : 1/2 < n/2 := by linarith
  have h := gammaCost_twice hz
  rw [actual_bernstein_laplace_identity hz] at h
  rw [show 2*(n/2)=n by ring] at h
  rw [h, reluCostIntercept]
  ring

theorem reluCostDensity_laplaceIntegrable {n : ℝ} (hn : 1 < n) :
    LaplaceIntegrable n reluCostDensity := by
  have hi := (integrableOn_Ioi_comp_mul_left_iff
    (fun t => Real.exp (-(n/2)*t)*positiveKernel t) 0 (by norm_num : (0 : ℝ)<2)).mpr
      (by simpa only [LaplaceIntegrable, mul_zero] using positiveKernel_laplaceIntegrable (by linarith : 1/2<n/2))
  have hc := hi.const_mul (4*reluCostSlope)
  apply hc.congr
  filter_upwards [] with t
  simp only [reluCostDensity]
  rw [show -(n/2)*(2*t) = -n*t by ring]
  ring

theorem laplace_reluCostDensity (n : ℝ) :
    laplace n reluCostDensity = 2*reluCostSlope*laplace (n/2) positiveKernel := by
  have hs := integral_comp_mul_left_Ioi
    (fun t => Real.exp (-(n/2)*t)*positiveKernel t) 0 (by norm_num : (0 : ℝ)<2)
  simp only [mul_zero, smul_eq_mul] at hs
  unfold laplace reluCostDensity
  have he (t : ℝ) : Real.exp (-n*t)*(4*reluCostSlope*positiveKernel (2*t)) =
      4*reluCostSlope*(Real.exp (-(n/2)*(2*t))*positiveKernel (2*t)) := by
    rw [show -(n/2)*(2*t)=-n*t by ring]
    ring
  simp_rw [he]
  rw [integral_const_mul, hs]
  ring

/-- Exact positive-density Bernstein representation of the actual ReLU atom cost. -/
theorem gammaCost_bernstein {n : ℝ} (hn : 1 < n) :
    gammaCost n = reluCostSlope*n + reluCostIntercept -
      ∫ t in Ioi (0 : ℝ), Real.exp (-n*t)*reluCostDensity t := by
  rw [← laplace, laplace_reluCostDensity]
  exact gammaCost_bernstein_half hn

theorem reluCostDensity_bound {t : ℝ} (ht : 0 ≤ t) :
    reluCostDensity t ≤ 8*reluCostSlope*Real.exp t := by
  have h := positiveKernel_abs_bound (2*t)
  rw [abs_of_nonneg (by linarith : 0 ≤ 2*t), show 2*t/2=t by ring] at h
  have hh : positiveKernel (2*t) ≤ 2*Real.exp t := (le_abs_self _).trans h
  have hm := mul_le_mul_of_nonneg_left hh (mul_pos (by norm_num : (0 : ℝ)<4) reluCostSlope_pos).le
  simpa only [reluCostDensity] using (show
    4*reluCostSlope*positiveKernel (2*t) ≤ 8*reluCostSlope*Real.exp t by nlinarith)

end NeuralGeneralization.OnlineLowerBernstein
