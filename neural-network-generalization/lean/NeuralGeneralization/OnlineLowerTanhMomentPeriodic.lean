import NeuralGeneralization.OnlineLowerTanhGlobalMoments

/-! # Exact periodic identities for the three actual bias-moment limits -/
noncomputable section
open scoped BigOperators Topology Classical
namespace NeuralGeneralization.OnlineLowerTanh

lemma balancedMomentLeading_periodic (n j : ℕ) {a : ℝ} (ha : 0 < a) (B θ : ℝ) :
    balancedMomentLeading n j a B ((n : ℝ)*Real.pi/2+θ) =
      (-1 : ℝ)^(n/2) * Real.sqrt (2/Real.pi) *
        ∑' l : ℕ, periodicCoefficient a l * (residualPeak a l)^j *
          Real.sin (residualPeak a l*(B+(n%2 : ℕ)*a)+θ) := by
  have hpoint (l : ℕ) : (-1 : ℝ)^(n*l)*residualDerivativeKernel j (residualPeak a l)*
      Real.sin (B*residualPeak a l+((n : ℝ)*Real.pi/2+θ)) =
      ((a/Real.pi)*(-1 : ℝ)^(n/2)) *
        (periodicCoefficient a l*(residualPeak a l)^j*
          Real.sin (residualPeak a l*(B+(n%2 : ℕ)*a)+θ)) := by
    have hp := residual_peak_phase ha.ne' n l B θ
    have hc := residual_peak_coefficient ha.ne' 0 l
    simp only [zero_mul, neg_zero, zero_div, Real.exp_zero, smoothedCoefficient, one_mul] at hc
    unfold residualDerivativeKernel
    rw [show B*residualPeak a l+((n : ℝ)*Real.pi/2+θ) =
      B*residualPeak a l+(n : ℝ)*Real.pi/2+θ by ring]
    calc
      _ = ((residualPeak a l)^j / Real.sinh (Real.pi*residualPeak a l/2)) *
          ((-1 : ℝ)^(n*l)*Real.sin (B*residualPeak a l+(n : ℝ)*Real.pi/2+θ)) := by ring
      _ = _ := by rw [hp]; rw [div_eq_mul_one_div, hc]; ring
  unfold balancedMomentLeading
  simp_rw [hpoint]
  rw [tsum_mul_left]
  have hcoeff : (Real.sqrt (2*Real.pi)/a)*((a/Real.pi)*(-1 : ℝ)^(n/2)) =
      (-1 : ℝ)^(n/2)*Real.sqrt (2/Real.pi) := by
    rw [← gaussian_height_identity]
    field_simp
  rw [← mul_assoc, hcoeff]

lemma balancedMomentLeading_zero (n : ℕ) {a : ℝ} (ha : 0 < a) (B : ℝ) :
    balancedMomentLeading n 0 a B ((n : ℝ)*Real.pi/2) =
      (-1 : ℝ)^(n/2)*Real.sqrt (2/Real.pi)*
        periodicFourierResponse a (B+(n%2 : ℕ)*a) := by
  have hh := balancedMomentLeading_periodic n 0 ha B 0
  simpa only [add_zero, pow_zero, mul_one, periodicFourierResponse, residualPeak] using hh

lemma balancedMomentLeading_first (n : ℕ) {a : ℝ} (ha : 0 < a) (B : ℝ) :
    balancedMomentLeading n 1 a B ((n : ℝ)*Real.pi/2+Real.pi/2) =
      (-1 : ℝ)^(n/2)*Real.sqrt (2/Real.pi)*
        periodicFourierDerivative a (B+(n%2 : ℕ)*a) := by
  rw [balancedMomentLeading_periodic n 1 ha B (Real.pi/2)]
  simp only [pow_one, Real.sin_add_pi_div_two, periodicFourierDerivative, residualPeak]

lemma balancedMomentLeading_second (n : ℕ) {a : ℝ} (ha : 0 < a) (B : ℝ) :
    -balancedMomentLeading n 2 a B ((n : ℝ)*Real.pi/2) =
      (-1 : ℝ)^(n/2)*Real.sqrt (2/Real.pi)*
        periodicFourierSecond a (B+(n%2 : ℕ)*a) := by
  have hh := balancedMomentLeading_periodic n 2 ha B 0
  simp only [add_zero] at hh
  rw [hh]
  unfold periodicFourierSecond
  simp_rw [neg_mul, tsum_neg]
  unfold residualPeak
  ring

end NeuralGeneralization.OnlineLowerTanh
