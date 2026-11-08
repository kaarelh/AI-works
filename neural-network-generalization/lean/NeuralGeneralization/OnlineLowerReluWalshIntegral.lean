import NeuralGeneralization.OnlineLowerReluCosineProduct
import NeuralGeneralization.KernelEnergy

/-! # Exact affine ReLU Walsh integral on the actual physical cube -/

noncomputable section
open scoped BigOperators
open MeasureTheory

namespace NeuralGeneralization.OnlineLowerRelu

theorem sum_walsh_eq_zero {d : ℕ} (S : Finset (Fin d)) (hS : S ≠ ∅) :
    (∑ x : ClippingCube d, walshCharacter S x) = 0 := by
  simpa [walshCharacter, hS] using walshCharacter_orthogonal S ∅

theorem sum_walsh_affine_eq_zero {d : ℕ} (S : Finset (Fin d))
    (hS : 2 ≤ S.card) (b : ℝ) (u : Fin d → ℝ) :
    (∑ x : ClippingCube d, walshCharacter S x * cubeAffine b u x) = 0 := by
  have hS0 : S ≠ ∅ := by intro h; simp [h] at hS
  have hzero := sum_walsh_eq_zero S hS0
  have hsingle (i : Fin d) :
      (∑ x : ClippingCube d, walshCharacter S x * cubeCoordinateSign (x i)) = 0 := by
    have hne : S ≠ {i} := by intro h; simp [h] at hS
    simpa [walshCharacter, hne] using walshCharacter_orthogonal S {i}
  simp only [cubeAffine, mul_add, Finset.mul_sum, Finset.sum_add_distrib]
  rw [← Finset.sum_mul, hzero, zero_mul, zero_add, Finset.sum_comm]
  have hterm (i : Fin d) :
      (∑ x : ClippingCube d, walshCharacter S x * (u i * cubeCoordinateSign (x i))) = 0 := by
    calc
      _ = u i * ∑ x : ClippingCube d, walshCharacter S x * cubeCoordinateSign (x i) := by
        rw [Finset.mul_sum]
        apply Finset.sum_congr rfl
        intro x _
        ring
      _ = 0 := by rw [hsingle, mul_zero]
  simp_rw [hterm]
  simp

/-- Exact normalized Fourier representation; the normalization is the
proved positive `fourierAbsConstant`, not an unevaluated assumed constant. -/
theorem relu_walsh_integral_even {d r : ℕ} (S : Finset (Fin d))
    (hS : 2 ≤ S.card) (hcard : S.card = 2 * r) (b : ℝ) (u : Fin d → ℝ) :
    walshCoefficients (fun x => max (cubeAffine b u x) 0) S =
      (-1 : ℝ) ^ (r + 1) / (2 * fourierAbsConstant) *
        ∫ t : ℝ, Real.cos (t * b) * trigProduct S (fun i => t * u i) / t ^ 2 := by
  have hS0 : S ≠ ∅ := by intro h; simp [h] at hS
  have h := weighted_relu_cosine_integral (walshCharacter S) (cubeAffine b u)
    (sum_walsh_eq_zero S hS0) (sum_walsh_affine_eq_zero S hS b u)
  have hk (t : ℝ) :
      (∑ x : ClippingCube d, walshCharacter S x * Real.cos (t * cubeAffine b u x)) / t ^ 2 =
        ((2 : ℝ) ^ d * (-1 : ℝ) ^ r) *
          (Real.cos (t * b) * trigProduct S (fun i => t * u i) / t ^ 2) := by
    rw [walsh_cosine_frequency_even S hcard]
    ring
  simp_rw [hk] at h
  rw [integral_const_mul] at h
  unfold walshCoefficients uniformCubeMean
  have hs : (∑ x : ClippingCube d, max (cubeAffine b u x) 0 * walshCharacter S x) =
      ∑ x : ClippingCube d, walshCharacter S x * max (cubeAffine b u x) 0 := by
    apply Finset.sum_congr rfl
    intro x _
    ring
  rw [hs, h]
  simp only [ClippingCube, Fintype.card_fun, Fintype.card_bool, Fintype.card_fin,
    Nat.cast_pow, Nat.cast_ofNat, pow_succ]
  field_simp [fourierAbsConstant_pos.ne']
  ring_nf
  simp only [mul_comm b]

/-- Signed sine/cosine kernel with its removable null-point value. -/
def trigKernel {d : ℕ} (S : Finset (Fin d)) (u : Fin d → ℝ) (t : ℝ) : ℝ :=
  trigProduct S (fun i => t * u i) / t ^ 2

theorem measurable_trigKernel {d : ℕ} (S : Finset (Fin d)) (u : Fin d → ℝ) :
    Measurable (trigKernel S u) := by
  unfold trigKernel trigProduct
  apply Measurable.div
  · apply Finset.measurable_prod
    intro i _
    by_cases hi : i ∈ S
    · simp only [if_pos hi]
      fun_prop
    · simp only [if_neg hi]
      fun_prop
  · fun_prop

/-- Absolute integrability follows from the finite cosine cancellation;
no unproved oscillatory integral is used. -/
theorem integrable_trigKernel_even {d r : ℕ} (S : Finset (Fin d))
    (hS : S ≠ ∅) (hcard : S.card = 2 * r) (u : Fin d → ℝ) :
    Integrable (trigKernel S u) := by
  have hi := integrable_weighted_cosine (walshCharacter S) (cubeAffine 0 u)
    (sum_walsh_eq_zero S hS)
  let C : ℝ := (2 : ℝ) ^ d * (-1 : ℝ) ^ r
  have hC : C ≠ 0 := by dsimp [C]; positivity
  have hscaled := hi.const_mul C⁻¹
  apply hscaled.congr
  exact Filter.Eventually.of_forall (fun t => by
    dsimp only
    rw [walsh_cosine_frequency_even S hcard]
    simp only [mul_zero, Real.cos_zero, mul_one, trigKernel]
    dsimp [C]
    field_simp)

theorem integrable_cos_mul_trigKernel {d r : ℕ} (S : Finset (Fin d))
    (hS : S ≠ ∅) (hcard : S.card = 2 * r) (b : ℝ) (u : Fin d → ℝ) :
    Integrable (fun t => Real.cos (t * b) * trigKernel S u t) := by
  apply (integrable_trigKernel_even S hS hcard u).bdd_mul
    (by fun_prop : AEStronglyMeasurable (fun t : ℝ => Real.cos (t * b)) volume)
  exact Filter.Eventually.of_forall (fun t => by
    simpa only [Real.norm_eq_abs] using Real.abs_cos_le_one (t * b))

/-- The bias-free absolute Fourier potential of one support. -/
def supportFourierPotential {d : ℕ} (S : Finset (Fin d)) (u : Fin d → ℝ) : ℝ :=
  (∫ t : ℝ, |trigKernel S u t|) / (2 * fourierAbsConstant)

theorem supportFourierPotential_nonneg {d : ℕ} (S : Finset (Fin d)) (u : Fin d → ℝ) :
    0 ≤ supportFourierPotential S u := by
  exact div_nonneg (integral_nonneg (fun _ => abs_nonneg _))
    (by positivity [fourierAbsConstant_pos])

/-- Every arbitrary affine ReLU coefficient is bounded by its actual
positive Fourier potential, with bias removed by `abs cos ≤ 1`. -/
theorem relu_walsh_abs_le_potential {d r : ℕ} (S : Finset (Fin d))
    (hS : 2 ≤ S.card) (hcard : S.card = 2 * r) (b : ℝ) (u : Fin d → ℝ) :
    |walshCoefficients (fun x => max (cubeAffine b u x) 0) S| ≤
      supportFourierPotential S u := by
  have hS0 : S ≠ ∅ := by intro h; simp [h] at hS
  have hden : 0 < 2 * fourierAbsConstant := by positivity [fourierAbsConstant_pos]
  have hpoint (t : ℝ) : |Real.cos (t * b) * trigKernel S u t| ≤ |trigKernel S u t| := by
    rw [abs_mul]
    exact mul_le_of_le_one_left (abs_nonneg _) (Real.abs_cos_le_one _)
  have hint : |∫ t : ℝ, Real.cos (t * b) * trigKernel S u t| ≤
      ∫ t : ℝ, |trigKernel S u t| :=
    abs_integral_le_integral_abs.trans
      (integral_mono (integrable_cos_mul_trigKernel S hS0 hcard b u).abs
        (integrable_trigKernel_even S hS0 hcard u).abs hpoint)
  rw [relu_walsh_integral_even S hS hcard]
  simp only [abs_mul, abs_div, abs_pow, abs_neg, abs_one, one_pow,
    abs_of_pos hden]
  simp_rw [mul_div_assoc]
  change (1 / (2 * fourierAbsConstant)) *
    |∫ t : ℝ, Real.cos (t * b) * trigKernel S u t| ≤ _
  simpa only [supportFourierPotential, one_div, div_eq_mul_inv, one_mul, mul_comm] using
    mul_le_mul_of_nonneg_left hint (inv_nonneg.mpr hden.le)

/-- If the balanced sine/cosine product is nonnegative, the potential is
exactly the absolute coefficient. This is the fixed-sign bridge used for
all even rail blocks. -/
theorem relu_walsh_abs_eq_potential_of_nonneg {d r : ℕ} (S : Finset (Fin d))
    (hS : 2 ≤ S.card) (hcard : S.card = 2 * r) (u : Fin d → ℝ)
    (hkernel : ∀ t, 0 ≤ trigKernel S u t) :
    |walshCoefficients (fun x => max (cubeAffine 0 u x) 0) S| =
      supportFourierPotential S u := by
  have hden : 0 < 2 * fourierAbsConstant := by positivity [fourierAbsConstant_pos]
  rw [relu_walsh_integral_even S hS hcard]
  simp only [mul_zero, Real.cos_zero, one_mul, abs_mul, abs_div, abs_pow,
    abs_neg, abs_one, one_pow, abs_of_pos hden]
  change (1 / (2 * fourierAbsConstant)) * |∫ t : ℝ, trigKernel S u t| = _
  rw [abs_of_nonneg (integral_nonneg hkernel)]
  unfold supportFourierPotential
  simp_rw [abs_of_nonneg (hkernel _)]
  ring

/-- The exact Fourier phase for a nonnegative balanced kernel. -/
theorem relu_walsh_signed_eq_potential_of_nonneg {d r : ℕ} (S : Finset (Fin d))
    (hS : 2 ≤ S.card) (hcard : S.card = 2 * r) (u : Fin d → ℝ)
    (hkernel : ∀ t, 0 ≤ trigKernel S u t) :
    (-1 : ℝ) ^ (r + 1) * walshCoefficients (fun x => max (cubeAffine 0 u x) 0) S =
      supportFourierPotential S u := by
  rw [relu_walsh_integral_even S hS hcard]
  simp only [mul_zero, Real.cos_zero, one_mul]
  change (-1 : ℝ) ^ (r + 1) * ((-1 : ℝ) ^ (r + 1) /
    (2 * fourierAbsConstant) * ∫ t : ℝ, trigKernel S u t) = _
  have hphase : (-1 : ℝ) ^ (r + 1) * (-1 : ℝ) ^ (r + 1) = 1 := by
    rw [← pow_two, ← pow_mul, Nat.mul_comm (r + 1) 2, pow_mul]
    norm_num
  calc
    _ = ((-1 : ℝ) ^ (r + 1) * (-1 : ℝ) ^ (r + 1)) *
        ((∫ t : ℝ, trigKernel S u t) / (2 * fourierAbsConstant)) := by ring
    _ = (∫ t : ℝ, trigKernel S u t) / (2 * fourierAbsConstant) := by rw [hphase, one_mul]
    _ = _ := by simp only [supportFourierPotential, abs_of_nonneg (hkernel _)]

/-- Set a specified collection of incoming physical weights to zero. -/
def zeroIncoming {d : ℕ} (B : Finset (Fin d)) (u : Fin d → ℝ) (i : Fin d) : ℝ :=
  if i ∈ B then 0 else u i

theorem abs_trigKernel {d : ℕ} (S : Finset (Fin d)) (u : Fin d → ℝ) (t : ℝ) :
    |trigKernel S u t| =
      (∏ i, |if i ∈ S then Real.sin (t * u i) else Real.cos (t * u i)|) / t ^ 2 := by
  simp only [trigKernel, trigProduct, abs_div, abs_pow, sq_abs, Finset.abs_prod]

theorem abs_trigKernel_abs_weights {d : ℕ} (S : Finset (Fin d))
    (u : Fin d → ℝ) (t : ℝ) :
    |trigKernel S (fun i => |u i|) t| = |trigKernel S u t| := by
  rw [abs_trigKernel, abs_trigKernel]
  congr 1
  apply Finset.prod_congr rfl
  intro i _
  by_cases hu : 0 ≤ u i
  · rw [abs_of_nonneg hu]
  · have hn : u i < 0 := lt_of_not_ge hu
    rw [abs_of_neg hn]
    by_cases hi : i ∈ S <;> simp [hi, mul_neg, Real.sin_neg, Real.cos_neg]

/-- Coordinatewise sign changes preserve the positive Fourier potential. -/
theorem supportPotential_abs_weights {d : ℕ} (S : Finset (Fin d)) (u : Fin d → ℝ) :
    supportFourierPotential S (fun i => |u i|) = supportFourierPotential S u := by
  unfold supportFourierPotential
  simp_rw [abs_trigKernel_abs_weights]

/-- Removing unused incoming coordinates can only increase the positive
potential. This is the opposite-rail marginal comparison. -/
theorem supportPotential_zero_unused {d r : ℕ} (S B : Finset (Fin d))
    (hS : S ≠ ∅) (hcard : S.card = 2 * r) (hSB : Disjoint S B) (u : Fin d → ℝ) :
    supportFourierPotential S u ≤ supportFourierPotential S (zeroIncoming B u) := by
  have hpoint (t : ℝ) : |trigKernel S u t| ≤ |trigKernel S (zeroIncoming B u) t| := by
    rw [abs_trigKernel, abs_trigKernel]
    apply div_le_div_of_nonneg_right _ (sq_nonneg t)
    apply Finset.prod_le_prod (fun _ _ => abs_nonneg _)
    intro i _
    by_cases hiB : i ∈ B
    · have hiS : i ∉ S := by
        intro hiS
        exact Finset.disjoint_left.mp hSB hiS hiB
      simpa [zeroIncoming, hiB, hiS] using Real.abs_cos_le_one (t * u i)
    · simp [zeroIncoming, hiB]
  apply div_le_div_of_nonneg_right _ (by positivity [fourierAbsConstant_pos])
  exact integral_mono (integrable_trigKernel_even S hS hcard u).abs
    (integrable_trigKernel_even S hS hcard (zeroIncoming B u)).abs hpoint

/-- A zero selected incoming coordinate makes the corresponding potential
and Fourier coefficient vanish exactly. -/
theorem supportPotential_eq_zero_of_selected_zero {d : ℕ} (S : Finset (Fin d))
    (u : Fin d → ℝ) (i : Fin d) (hi : i ∈ S) (hui : u i = 0) :
    supportFourierPotential S u = 0 := by
  have hk (t : ℝ) : trigKernel S u t = 0 := by
    unfold trigKernel trigProduct
    have hp : (∏ j : Fin d, if j ∈ S then Real.sin (t * u j) else Real.cos (t * u j)) = 0 :=
      Finset.prod_eq_zero (Finset.mem_univ i) (by simp [hi, hui])
    rw [hp, zero_div]
  simp [supportFourierPotential, hk]

end NeuralGeneralization.OnlineLowerRelu
