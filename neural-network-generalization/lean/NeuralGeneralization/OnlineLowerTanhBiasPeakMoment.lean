import NeuralGeneralization.OnlineLowerTanhBiasPeakPolynomial
import NeuralGeneralization.OnlineLowerTanhCodeKernelGeneral

/-! Literal equal-bulk correlations at every periodic peak are finite
polynomial combinations of actual balanced coefficients. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open Polynomial MeasureTheory Set
namespace NeuralGeneralization.OnlineLowerTanh

/-- Evaluate a polynomial against the actual balanced-coefficient sequence. -/
def balancedPolynomialMoment (r : ℕ) (a : ℝ) (P : Polynomial ℝ) : ℝ :=
  ∑ j∈P.support, P.coeff j*balancedParity (r+j) a

lemma balancedSineKernel_integrable (r : ℕ) (a : ℝ) :
    IntegrableOn (fun t:ℝ=>Real.sin (a*t)^(2*r+1)/Real.sinh (Real.pi*t/2)) (Ioi 0) := by
  have h := integrable_parity_sine_kernel (n:=2*r+1) rfl (fun _=>a)
  simpa only [Finset.prod_const,Finset.card_univ,Fintype.card_fin,mul_comm] using h

lemma balancedPolynomialMoment_integral (r : ℕ) (a : ℝ) (P : Polynomial ℝ) :
    balancedPolynomialMoment r a P =
      ∫t:ℝ in Ioi 0,P.eval ((Real.sin (a*t))^2)*Real.sin (a*t)^(2*r+1)/
        Real.sinh (Real.pi*t/2) := by
  have he (t:ℝ) : P.eval ((Real.sin (a*t))^2)*Real.sin (a*t)^(2*r+1)/
      Real.sinh (Real.pi*t/2) =
      ∑j∈P.support,P.coeff j*(Real.sin (a*t)^(2*(r+j)+1)/Real.sinh (Real.pi*t/2)) := by
    rw [Polynomial.eval_eq_sum]
    simp only [Polynomial.sum,Finset.sum_mul,Finset.sum_div]
    apply Finset.sum_congr rfl
    intro j _
    rw [←pow_mul]
    have hp : Real.sin (a*t)^(2*j)*Real.sin (a*t)^(2*r+1)=Real.sin (a*t)^(2*(r+j)+1) := by
      rw [←pow_add]
      congr 1
      omega
    calc
      _ = P.coeff j*((Real.sin (a*t)^(2*j)*Real.sin (a*t)^(2*r+1))/Real.sinh (Real.pi*t/2)) := by ring
      _ = _ := by rw [hp]
  simp_rw [he]
  rw [integral_finsetSum]
  · unfold balancedPolynomialMoment
    apply Finset.sum_congr rfl
    intro j _
    rw [integral_const_mul,←balancedParity_sine_integral]
  · intro j _
    exact (balancedSineKernel_integrable (r+j) a).const_mul _

lemma sign_nat_square (n:ℕ) : (-1:ℝ)^n*(-1:ℝ)^n=1 := by
  rw [←mul_pow]
  norm_num

/-- Every even-grid peak of an odd equal bulk. -/
theorem odd_bulk_peak_exact (r l : ℕ) (a : ℝ) :
    parityCorrelation (fun _:Fin (2*r+1)=>a) (2*(l:ℝ)*a) =
      (-1:ℝ)^(r+l)*balancedPolynomialMoment r a (oddBiasPeakPolynomial l) := by
  rw [parityCorrelation_sine_integral rfl,balancedPolynomialMoment_integral,pow_add]
  conv_rhs => rw [mul_assoc]
  apply congrArg (fun v:ℝ=>(-1:ℝ)^r*v)
  rw [←integral_const_mul]
  apply integral_congr_ae
  exact Filter.Eventually.of_forall (fun t=>by
    simp only [Finset.prod_const,Finset.card_univ,Fintype.card_fin]
    rw [oddBiasPeakPolynomial_trig]
    have he : t*(2*(l:ℝ)*a)=2*(l:ℝ)*(a*t) := by ring
    rw [he,mul_comm t a]
    calc
      _ = ((-1:ℝ)^l*(-1:ℝ)^l)*(Real.cos (2*(l:ℝ)*(a*t))*
        Real.sin (a*t)^(2*r+1)/Real.sinh (Real.pi*t/2)) := by rw [sign_nat_square]; ring
      _ = _ := by ring)

/-- Every odd-grid peak of an even equal bulk. -/
theorem even_bulk_peak_exact (r l : ℕ) (a : ℝ) :
    parityCorrelation (fun _:Fin (2*r)=>a) ((2*(l:ℝ)+1)*a) =
      (-1:ℝ)^(r+l)*balancedPolynomialMoment r a (evenBiasPeakPolynomial l) := by
  rw [parityCorrelation_sine_integral_all,balancedPolynomialMoment_integral,←integral_const_mul]
  apply integral_congr_ae
  exact Filter.Eventually.of_forall (fun t=>by
    simp only [Finset.prod_const,Finset.card_univ,Fintype.card_fin]
    have he : t*((2*(l:ℝ)+1)*a)+(2*r:ℕ)*Real.pi/2=
        (2*(l:ℝ)+1)*(a*t)+(r:ℝ)*Real.pi := by push_cast; ring
    rw [he,Real.sin_add_nat_mul_pi,mul_comm t a]
    have hpoly := evenBiasPeakPolynomial_trig l (a*t)
    have hs:=sign_nat_square l
    have hsin : Real.sin ((2*(l:ℝ)+1)*(a*t)) =
        (-1:ℝ)^l*(evenBiasPeakPolynomial l).eval ((Real.sin (a*t))^2)*Real.sin (a*t) := by
      calc
        _ = (-1:ℝ)^l*((-1:ℝ)^l*Real.sin ((2*(l:ℝ)+1)*(a*t))) := by nlinarith [congrArg (fun z:ℝ=>z*Real.sin ((2*(l:ℝ)+1)*(a*t))) hs]
        _ = _ := by rw [←hpoly]; ring
    rw [hsin,pow_succ,pow_add]
    ring)

/-- A finite ratio expansion transfers to its polynomial moment with the
exact first coefficient `P'(1)`. -/
theorem polynomial_moment_ratio_error (P : Polynomial ℝ) (q : ℕ→ℝ)
    (n Q : ℝ) (hQ : Q≠0) (K : ℕ→ℝ)
    (h : ∀j∈P.support, |q j/Q-(1-(j:ℝ)/n)|≤K j) :
    |(∑j∈P.support,P.coeff j*q j)/Q-
      (P.eval 1-P.derivative.eval 1/n)|≤∑j∈P.support,|P.coeff j| *K j := by
  have he : (∑j∈P.support,P.coeff j*q j)/Q-
      (P.eval 1-P.derivative.eval 1/n)=
      ∑j∈P.support,P.coeff j*(q j/Q-(1-(j:ℝ)/n)) := by
    rw [Polynomial.eval_eq_sum,Polynomial.derivative_eval]
    simp only [Polynomial.sum,one_pow,mul_one,Finset.sum_div,
      Finset.sum_sub_distrib,mul_sub,mul_one]
    simp only [mul_div_assoc]
  rw [he]
  apply (Finset.abs_sum_le_sum_abs _ _).trans
  apply Finset.sum_le_sum
  intro j hj
  rw [abs_mul]
  exact mul_le_mul_of_nonneg_left (h j hj) (abs_nonneg _)

end NeuralGeneralization.OnlineLowerTanh
