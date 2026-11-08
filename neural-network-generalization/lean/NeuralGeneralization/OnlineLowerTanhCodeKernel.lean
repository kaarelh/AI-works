import NeuralGeneralization.OnlineLowerTanhSine
import NeuralGeneralization.OnlineLowerReluCosineProduct
import NeuralGeneralization.OnlineLowerTanhCodeSupport

/-!
# Exact physical tanh Walsh integral

The formulas here apply the proved sine transform of the literal real tanh
function to a finite Boolean cube. Integrability follows from finite sums of
actual sine-transform kernels, not from an assumed oscillatory identity.
-/

noncomputable section
open scoped BigOperators
open MeasureTheory Set
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLowerRelu ConcreteModel

theorem walsh_sine_sum_odd {d r : ℕ} (S : Finset (Fin d))
    (hcard : S.card = 2*r+1) (b : ℝ) (u : Fin d → ℝ) :
    (∑ x : ClippingCube d, walshCharacter S x * Real.sin (cubeAffine b u x)) =
      (2:ℝ)^d * (-1:ℝ)^r * Real.cos b * trigProduct S u := by
  have h := congrArg Complex.im (walsh_complex_exp_sum S b u)
  rw [complex_trigProduct,hcard,pow_add,pow_mul,Complex.I_sq,pow_one] at h
  have htwo : (2:ℂ)^d = (((2:ℝ)^d : ℝ):ℂ) := by simp
  have hneg : (-1:ℂ)^r = (((-1:ℝ)^r : ℝ):ℂ) := by simp
  rw [htwo,hneg] at h
  have hsum (f : ClippingCube d → ℂ) :
      (∑ x, f x).im = ∑ x, (f x).im := map_sum Complex.imAddGroupHom f Finset.univ
  rw [hsum] at h
  simp only [Complex.mul_re,Complex.mul_im,Complex.ofReal_re,Complex.ofReal_im,
    Complex.I_re,Complex.I_im,zero_mul,mul_zero,sub_zero,add_zero,zero_add,mul_one,
    Complex.exp_ofReal_mul_I_re,Complex.exp_ofReal_mul_I_im] at h
  nlinarith [h]

theorem walsh_sine_frequency_odd {d r : ℕ} (S : Finset (Fin d))
    (hcard : S.card = 2*r+1) (t b : ℝ) (u : Fin d → ℝ) :
    (∑ x : ClippingCube d, walshCharacter S x * Real.sin (t*cubeAffine b u x)) =
      (2:ℝ)^d * (-1:ℝ)^r * Real.cos (t*b) * trigProduct S (fun i => t*u i) := by
  simpa only [cubeAffine_scale] using walsh_sine_sum_odd S hcard (t*b) (fun i => t*u i)

theorem weighted_tanh_sine_integral {ι : Type*} [Fintype ι]
    (c a : ι → ℝ) :
    (∑ i, c i*Real.tanh (a i)) =
      ∫ t : ℝ in Ioi 0, (∑ i, c i*Real.sin (a i*t))/Real.sinh (Real.pi*t/2) := by
  calc
    _ = ∑ i, ∫ t : ℝ in Ioi 0,
        c i*(Real.sin (a i*t)/Real.sinh (Real.pi*t/2)) := by
      simp_rw [integral_const_mul,tanh_sine_integral]
    _ = ∫ t : ℝ in Ioi 0, ∑ i, c i*(Real.sin (a i*t)/Real.sinh (Real.pi*t/2)) :=
      (integral_finsetSum _ (fun i _ => (tanh_sine_integrable (a i)).const_mul (c i))).symm
    _ = _ := by
      apply integral_congr_ae
      exact Filter.Eventually.of_forall (fun t => by
        dsimp only
        rw [Finset.sum_div]
        apply Finset.sum_congr rfl
        intro i _
        ring)

theorem weighted_tanh_sine_integrable {ι : Type*} [Fintype ι]
    (c a : ι → ℝ) :
    IntegrableOn (fun t : ℝ => (∑ i, c i*Real.sin (a i*t))/Real.sinh (Real.pi*t/2))
      (Ioi 0) := by
  have hi := integrable_finsetSum Finset.univ
    (fun i _ => (tanh_sine_integrable (a i)).const_mul (c i))
  apply hi.congr
  exact Filter.Eventually.of_forall (fun t => by
    dsimp only
    rw [Finset.sum_div]
    apply Finset.sum_congr rfl
    intro i _
    ring)

def tanhTrigKernel {d : ℕ} (S : Finset (Fin d)) (u : Fin d → ℝ) (t : ℝ) : ℝ :=
  trigProduct S (fun i => t*u i)/Real.sinh (Real.pi*t/2)

theorem integrable_tanhTrigKernel {d r : ℕ} (S : Finset (Fin d))
    (hcard : S.card = 2*r+1) (u : Fin d → ℝ) :
    IntegrableOn (tanhTrigKernel S u) (Ioi 0) := by
  have hi := weighted_tanh_sine_integrable (walshCharacter S) (cubeAffine 0 u)
  let C : ℝ := (2:ℝ)^d * (-1:ℝ)^r
  have hC : C ≠ 0 := by dsimp [C]; positivity
  have hs := hi.const_mul C⁻¹
  apply hs.congr
  exact Filter.Eventually.of_forall (fun t => by
    dsimp only
    have he (x : ClippingCube d) : cubeAffine 0 u x*t = t*cubeAffine 0 u x := mul_comm _ _
    simp_rw [he]
    rw [walsh_sine_frequency_odd S hcard]
    simp only [mul_zero,Real.cos_zero,mul_one]
    dsimp [C,tanhTrigKernel]
    field_simp)

/-- Exact odd-support formula on the physical cube. -/
theorem tanh_walsh_integral_odd {d r : ℕ} (S : Finset (Fin d))
    (hcard : S.card = 2*r+1) (b : ℝ) (u : Fin d → ℝ) :
    walshCoefficients (fun x => Real.tanh (b+incomingLinear u x)) S =
      (-1:ℝ)^r * ∫ t : ℝ in Ioi 0,
        Real.cos (t*b)*tanhTrigKernel S u t := by
  have h := weighted_tanh_sine_integral (walshCharacter S) (cubeAffine b u)
  have hk (t : ℝ) :
      (∑ x : ClippingCube d, walshCharacter S x*Real.sin (cubeAffine b u x*t)) /
        Real.sinh (Real.pi*t/2) =
      ((2:ℝ)^d*(-1:ℝ)^r)*(Real.cos (t*b)*tanhTrigKernel S u t) := by
    have he (x : ClippingCube d) : cubeAffine b u x*t = t*cubeAffine b u x := mul_comm _ _
    simp_rw [he]
    rw [walsh_sine_frequency_odd S hcard]
    unfold tanhTrigKernel
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
  simp only [ClippingCube,Fintype.card_fun,Fintype.card_bool,Fintype.card_fin,
    Nat.cast_pow,Nat.cast_ofNat]
  field_simp
  simp only [mul_comm b]


/-- The pre-existing intrinsic correlation uses exactly the full physical
Walsh support, including the same uniform normalization. -/
theorem parityCorrelation_eq_walsh_univ {n : ℕ} (u : Fin n → ℝ) (b : ℝ) :
    parityCorrelation u b = walshCoefficients
      (fun x => Real.tanh (b+incomingLinear u x)) Finset.univ := by
  unfold parityCorrelation walshCoefficients uniformCubeMean paritySign walshCharacter
  rw [div_eq_mul_inv,mul_comm]
  congr 1
  apply Finset.sum_congr rfl
  intro x _
  exact mul_comm _ _

/-- Exact intrinsic odd-parity formula, with arbitrary incoming bias. -/
theorem parityCorrelation_sine_integral {n r : ℕ} (hn : n=2*r+1)
    (u : Fin n → ℝ) (b : ℝ) :
    parityCorrelation u b = (-1:ℝ)^r *
      ∫ t : ℝ in Ioi 0, Real.cos (t*b) *
        (∏ i, Real.sin (t*u i))/Real.sinh (Real.pi*t/2) := by
  rw [parityCorrelation_eq_walsh_univ,
    tanh_walsh_integral_odd Finset.univ (by simpa using hn)]
  congr 1
  apply integral_congr_ae
  exact Filter.Eventually.of_forall (fun t => by
    simp [tanhTrigKernel,trigProduct,mul_div_assoc])

theorem integrable_parity_sine_kernel {n r : ℕ} (hn : n=2*r+1)
    (u : Fin n → ℝ) :
    IntegrableOn (fun t : ℝ => (∏ i, Real.sin (t*u i))/Real.sinh (Real.pi*t/2))
      (Ioi 0) := by
  have he : tanhTrigKernel Finset.univ u =
      (fun t : ℝ => (∏ i, Real.sin (t*u i))/Real.sinh (Real.pi*t/2)) := by
    funext t
    simp [tanhTrigKernel,trigProduct]
  rw [← he]
  exact integrable_tanhTrigKernel Finset.univ (by simpa using hn) u


end NeuralGeneralization.OnlineLowerTanh
