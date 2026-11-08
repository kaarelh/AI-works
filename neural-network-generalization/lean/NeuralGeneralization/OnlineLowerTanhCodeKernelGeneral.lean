import NeuralGeneralization.OnlineLowerTanhCodeKernel

/-! # Tanh parity Fourier representation at every parity degree -/

noncomputable section
open scoped BigOperators
open MeasureTheory Set
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLowerRelu ConcreteModel

lemma complex_I_nat_phase (n : ℕ) :
    Complex.I^n = Complex.exp (((n : ℝ)*Real.pi/2 : ℝ) * Complex.I) := by
  have he : Complex.exp ((Real.pi/2 : ℝ)*Complex.I) = Complex.I := by
    simp [Complex.exp_ofReal_mul_I]
  conv_lhs => rw [← he,←Complex.exp_nat_mul]
  congr 1
  push_cast
  ring

theorem walsh_sine_sum_all {d : ℕ} (S : Finset (Fin d))
    (b : ℝ) (u : Fin d → ℝ) :
    (∑ x : ClippingCube d, walshCharacter S x*Real.sin (cubeAffine b u x)) =
      (2:ℝ)^d * Real.sin (b+(S.card : ℝ)*Real.pi/2)*trigProduct S u := by
  have h := walsh_complex_exp_sum S b u
  rw [complex_trigProduct,complex_I_nat_phase] at h
  have he : Complex.exp ((b:ℂ)*Complex.I)*
      Complex.exp (((S.card : ℝ)*Real.pi/2 : ℝ)*Complex.I) =
      Complex.exp (((b+(S.card : ℝ)*Real.pi/2 : ℝ):ℂ)*Complex.I) := by
    rw [← Complex.exp_add]
    congr 1
    push_cast
    ring
  have hrearr : (2:ℂ)^d * Complex.exp ((b:ℂ)*Complex.I)*
      (Complex.exp (((S.card : ℝ)*Real.pi/2 : ℝ)*Complex.I)*(trigProduct S u : ℂ)) =
      (2:ℂ)^d * (Complex.exp ((b:ℂ)*Complex.I)*
      Complex.exp (((S.card : ℝ)*Real.pi/2 : ℝ)*Complex.I))*(trigProduct S u : ℂ) := by ring
  rw [hrearr,he] at h
  have hi := congrArg Complex.im h
  have htwo : (2:ℂ)^d = (((2:ℝ)^d : ℝ):ℂ) := by simp
  rw [htwo] at hi
  have hsum (f : ClippingCube d → ℂ) :
      (∑ x, f x).im = ∑ x, (f x).im := map_sum Complex.imAddGroupHom f Finset.univ
  rw [hsum] at hi
  simpa only [Complex.mul_im,Complex.mul_re,Complex.ofReal_re,Complex.ofReal_im,
    zero_mul,mul_zero,zero_add,add_zero,sub_zero,Complex.exp_ofReal_mul_I_im] using hi

theorem walsh_sine_frequency_all {d : ℕ} (S : Finset (Fin d))
    (t b : ℝ) (u : Fin d → ℝ) :
    (∑ x : ClippingCube d, walshCharacter S x*Real.sin (t*cubeAffine b u x)) =
      (2:ℝ)^d * Real.sin (t*b+(S.card : ℝ)*Real.pi/2)*trigProduct S (fun i => t*u i) := by
  simpa only [cubeAffine_scale] using walsh_sine_sum_all S (t*b) (fun i => t*u i)

def tanhPhaseKernel {d : ℕ} (S : Finset (Fin d)) (b : ℝ) (u : Fin d → ℝ) (t : ℝ) : ℝ :=
  Real.sin (t*b+(S.card : ℝ)*Real.pi/2)*trigProduct S (fun i => t*u i)/Real.sinh (Real.pi*t/2)

theorem integrable_tanhPhaseKernel {d : ℕ} (S : Finset (Fin d)) (b : ℝ) (u : Fin d → ℝ) :
    IntegrableOn (tanhPhaseKernel S b u) (Ioi 0) := by
  have hi := (weighted_tanh_sine_integrable (walshCharacter S) (cubeAffine b u)).const_mul
    (((2:ℝ)^d)⁻¹)
  apply hi.congr
  exact Filter.Eventually.of_forall (fun t => by
    dsimp only
    simp_rw [mul_comm (cubeAffine b u _)]
    rw [walsh_sine_frequency_all]
    unfold tanhPhaseKernel
    field_simp)

theorem tanh_walsh_integral_all {d : ℕ} (S : Finset (Fin d)) (b : ℝ) (u : Fin d → ℝ) :
    walshCoefficients (fun x => Real.tanh (b+incomingLinear u x)) S =
      ∫ t : ℝ in Ioi 0, tanhPhaseKernel S b u t := by
  have h := weighted_tanh_sine_integral (walshCharacter S) (cubeAffine b u)
  have hk (t : ℝ) :
      (∑ x : ClippingCube d, walshCharacter S x*Real.sin (cubeAffine b u x*t)) /
        Real.sinh (Real.pi*t/2) = (2:ℝ)^d*tanhPhaseKernel S b u t := by
    simp_rw [mul_comm (cubeAffine b u _)]
    rw [walsh_sine_frequency_all]
    unfold tanhPhaseKernel
    ring
  simp_rw [hk] at h
  rw [integral_const_mul] at h
  unfold walshCoefficients uniformCubeMean
  have hs : (∑ x : ClippingCube d, Real.tanh (b+incomingLinear u x)*walshCharacter S x) =
      ∑ x : ClippingCube d, walshCharacter S x*Real.tanh (cubeAffine b u x) := by
    apply Finset.sum_congr rfl
    intro x _
    exact mul_comm _ _
  rw [hs,h]
  simp [ClippingCube]

theorem parityCorrelation_sine_integral_all {n : ℕ} (u : Fin n → ℝ) (b : ℝ) :
    parityCorrelation u b = ∫ t : ℝ in Ioi 0,
      Real.sin (t*b+(n:ℝ)*Real.pi/2)*(∏ i,Real.sin (t*u i))/Real.sinh (Real.pi*t/2) := by
  rw [parityCorrelation_eq_walsh_univ,tanh_walsh_integral_all]
  congr 1
  funext t
  simp [tanhPhaseKernel,trigProduct]

theorem integrable_parity_phase_kernel {n : ℕ} (u : Fin n → ℝ) (b : ℝ) :
    IntegrableOn (fun t : ℝ => Real.sin (t*b+(n:ℝ)*Real.pi/2)*
      (∏ i,Real.sin (t*u i))/Real.sinh (Real.pi*t/2)) (Ioi 0) := by
  have he : tanhPhaseKernel Finset.univ b u =
      (fun t : ℝ => Real.sin (t*b+(n:ℝ)*Real.pi/2)*
        (∏ i,Real.sin (t*u i))/Real.sinh (Real.pi*t/2)) := by
    funext t
    simp [tanhPhaseKernel,trigProduct]
  rw [← he]
  exact integrable_tanhPhaseKernel Finset.univ b u

end NeuralGeneralization.OnlineLowerTanh
