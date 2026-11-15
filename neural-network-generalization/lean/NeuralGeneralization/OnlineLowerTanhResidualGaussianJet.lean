import NeuralGeneralization.OnlineLowerTanhResidualAllDerivatives
import Mathlib.RingTheory.Polynomial.Hermite.Gaussian

/-! # Uniform bounds for every derivative of the slowly varying Gaussian -/
noncomputable section
open scoped BigOperators Topology
open Filter
namespace NeuralGeneralization.OnlineLowerTanh

def residualUnitGaussian (x:ℝ) : ℝ := Real.exp (-(x^2/2))
def residualGaussianDerivativeBound (j:ℕ) : ℝ :=
  ∑ i ∈ (Polynomial.hermite j).support,
    |((Polynomial.hermite j).coeff i:ℝ)| *(i.factorial:ℝ)*Real.exp (1/2)

lemma residualGaussianDerivativeBound_nonneg (j:ℕ) :
    0 ≤ residualGaussianDerivativeBound j := by
  unfold residualGaussianDerivativeBound
  exact Finset.sum_nonneg (fun i _=>by positivity)

lemma gaussian_monomial_bound (j:ℕ) (x:ℝ) :
    |x|^j*residualUnitGaussian x ≤ (j.factorial:ℝ)*Real.exp (1/2) := by
  have h := polynomial_exponential_bound j (by norm_num : (0:ℝ)<1) (abs_nonneg x)
  simp only [one_pow,div_one,neg_mul,one_mul] at h
  have hs : -(x^2/2) ≤ (1/2:ℝ)-|x| := by
    have hh:=sq_nonneg (|x|-1)
    nlinarith [sq_abs x]
  have he:=Real.exp_le_exp.mpr hs
  rw [Real.exp_sub] at he
  have hm:=mul_le_mul_of_nonneg_left he (pow_nonneg (abs_nonneg x) j)
  have hp:=mul_le_mul_of_nonneg_right h (Real.exp_pos (1/2:ℝ)).le
  rw [Real.exp_neg] at hp
  exact hm.trans (by convert hp using 1 <;> ring)

/-- Hermite's exact derivative formula gives a finite explicit bound,
uniform over the complete real line, at every fixed derivative order. -/
lemma residualUnitGaussian_derivative_bound (j:ℕ) (x:ℝ) :
    |iteratedDeriv j residualUnitGaussian x| ≤ residualGaussianDerivativeBound j := by
  rw [iteratedDeriv_eq_iterate]
  unfold residualUnitGaussian
  rw [Polynomial.deriv_gaussian_eq_hermite_mul_gaussian,abs_mul,abs_mul]
  simp only [abs_pow,abs_neg,abs_one,one_pow,one_mul,abs_of_pos (Real.exp_pos _)]
  rw [Polynomial.aeval_def,Polynomial.eval₂_eq_sum,Polynomial.sum_def]
  have hs:=Finset.abs_sum_le_sum_abs
    (fun i=> (algebraMap ℤ ℝ) ((Polynomial.hermite j).coeff i)*x^i)
    (Polynomial.hermite j).support
  have hm:=mul_le_mul_of_nonneg_right hs (Real.exp_pos (-(x^2/2))).le
  apply hm.trans
  rw [Finset.sum_mul]
  unfold residualGaussianDerivativeBound
  apply Finset.sum_le_sum
  intro i hi
  simp only [abs_mul,abs_pow]
  have hh:=mul_le_mul_of_nonneg_left (gaussian_monomial_bound i x)
    (abs_nonneg (((Polynomial.hermite j).coeff i:ℤ):ℝ))
  simpa [residualUnitGaussian,mul_assoc] using hh

lemma residualGaussian_scaled_derivative_bound (j:ℕ) (s x:ℝ) :
    |iteratedDeriv j (fun b=>residualUnitGaussian (s*b)) x| ≤
      |s|^j*residualGaussianDerivativeBound j := by
  rw [iteratedDeriv_comp_const_mul (show ContDiff ℝ j residualUnitGaussian by
    unfold residualUnitGaussian; fun_prop)]
  simp only [abs_mul,abs_pow]
  exact mul_le_mul_of_nonneg_left (residualUnitGaussian_derivative_bound j (s*x))
    (pow_nonneg (abs_nonneg s) j)

lemma smoothedMoment_abs_bound (j:ℕ) {a E lo hi:ℝ}
    (hlo:0<lo) (ha:lo≤a) (hah:a≤hi) (hE:0≤E) (b δ:ℝ) :
    |smoothedMoment j a E b δ| ≤ ∑' l:ℕ,momentMajorant j lo hi l := by
  have ha0:=hlo.trans_le ha
  have hhi:=ha0.trans_le hah
  let f:ℕ→ℝ:=fun l=>smoothedCoefficient a E l*(residualPeak a l)^j*
    Real.sin (residualPeak a l*b+δ)
  have hb (l:ℕ):‖f l‖≤momentMajorant j lo hi l := by
    dsimp [f]
    rw [abs_mul,abs_mul,abs_of_pos (smoothedCoefficient_pos ha0 E l),
      abs_of_nonneg (pow_nonneg (residual_peak_pos ha0 l).le j)]
    exact (mul_le_of_le_one_right
      (mul_nonneg (smoothedCoefficient_pos ha0 E l).le (pow_nonneg (residual_peak_pos ha0 l).le j))
      (Real.abs_sin_le_one _)).trans
        (smoothedMoment_coefficient_bound j hlo ha hah hE l)
  have hm:=momentMajorant_summable j (lo:=lo) hhi
  have hs:=hm.of_nonneg_of_le (fun l=>norm_nonneg (f l)) hb
  exact (norm_tsum_le_tsum_norm hs).trans (Summable.tsum_le_tsum hb hs hm)

lemma smoothedResponse_derivative_bound (j:ℕ) {a E lo hi:ℝ}
    (hlo:0<lo) (ha:lo≤a) (hah:a≤hi) (hE:0≤E) (b:ℝ) :
    |iteratedDeriv j (smoothedResponse a E) b| ≤ ∑' l:ℕ,momentMajorant j lo hi l := by
  rw [iteratedDeriv_smoothedResponse (hlo.trans_le ha) hE]
  exact smoothedMoment_abs_bound j hlo ha hah hE b _

end NeuralGeneralization.OnlineLowerTanh
