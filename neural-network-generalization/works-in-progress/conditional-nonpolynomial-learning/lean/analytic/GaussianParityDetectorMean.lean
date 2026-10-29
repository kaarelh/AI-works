import ParityThresholdSeed
import NeuralGeneralization.BatchTwoContinuousDepthCriticalSeedMean

/-! Actual Gaussian tanh detector means with a polynomial gain. The deliberately
coarse gain avoids logarithmic saturation estimates: its polynomial entropy cost
still gives the logarithmic seed resource required by the posterior ceiling. -/

noncomputable section
open scoped BigOperators NNReal
open MeasureTheory ProbabilityTheory NeuralGeneralization
open NeuralGeneralization.BatchTwoContinuousDepthCritical

namespace ConditionalNonpolynomial.Analytic

variable {I : Type*} [Fintype I]

theorem gaussianRowMean_saturation_variance (c : I → ℝ) (m : ℝ) :
    |gaussianRowMean c m - 1| ≤
      2 * Real.exp (-2*m + 2 * ∑ i, c i ^ 2) := by
  have hexp := GaussianTail.integrable_exp_gaussian_linear_form
    (fun _ : I => (1 : NNReal)) c (-2)
  have hleft := (integrable_const (1 : ℝ)).sub (gaussianRow_integrable c m)
  have hright : Integrable
      (fun z : I → ℝ => 2 * Real.exp (-2*m) * Real.exp (-2 * ∑ i, c i*z i))
      (Measure.pi fun _ : I => gaussianReal 0 1) := hexp.const_mul _
  have hh := integral_mono hleft hright (fun z => by
    have h := tanh_saturation_bound (m + ∑ i, c i*z i)
    have he : 2 * Real.exp (-2*(m + ∑ i, c i*z i)) =
        2 * Real.exp (-2*m) * Real.exp (-2 * ∑ i, c i*z i) := by
      rw [mul_assoc, ← Real.exp_add]
      congr 2
      ring
    rwa [he] at h)
  change (∫ z : I → ℝ, 1 - Real.tanh (m + ∑ i, c i*z i)
    ∂(Measure.pi fun _ : I => gaussianReal 0 1)) ≤ _ at hh
  rw [integral_sub (integrable_const _) (gaussianRow_integrable c m),
    integral_const_mul] at hh
  simp only [integral_const, probReal_univ, smul_eq_mul, mul_one] at hh
  have hm : (∫ z : I → ℝ, Real.exp (-2 * ∑ i, c i*z i)
      ∂(Measure.pi fun _ : I => gaussianReal 0 1)) = Real.exp (2 * ∑ i, c i ^ 2) := by
    change mgf (fun z : I → ℝ => ∑ i, c i*z i)
      (Measure.pi fun _ : I => gaussianReal 0 1) (-2) = _
    rw [GaussianTail.mgf_gaussian_linear_form]
    simp only [NNReal.coe_one, mul_one]
    congr 1
    ring
  rw [hm, mul_assoc, ← Real.exp_add] at hh
  rw [abs_of_nonpos (sub_nonpos.mpr (gaussianRowMean_le_one c m))]
  unfold gaussianRowMean
  linarith

theorem gaussianRowMean_signed_saturation (c : I → ℝ) (m M s : ℝ)
    (hs : s = 1 ∨ s = -1) (hmargin : M ≤ s*m) (hvar : ∑ i, c i ^ 2 ≤ 2) :
    |gaussianRowMean c m - s| ≤ 2 * Real.exp (-2*M + 4) := by
  rcases hs with rfl | rfl
  · have h := gaussianRowMean_saturation_variance c m
    exact h.trans (mul_le_mul_of_nonneg_left (Real.exp_le_exp.mpr (by
      simp only [one_mul] at hmargin
      linarith)) (by norm_num))
  · have h := gaussianRowMean_saturation_variance c (-m)
    rw [gaussianRowMean_odd] at h
    have habs : |-gaussianRowMean c m - 1| = |gaussianRowMean c m - -1| := by
      rw [show -gaussianRowMean c m - 1 = -(gaussianRowMean c m - -1) by ring,
        abs_neg]
    rw [habs] at h
    exact h.trans (mul_le_mul_of_nonneg_left (Real.exp_le_exp.mpr (by
      simp only [neg_one_mul] at hmargin
      linarith)) (by norm_num))

theorem polynomial_gain_saturation (k : ℕ) :
    2 * Real.exp (-2 * (8*((k : ℝ)+1)) + 4) ≤ 1 / (4*((k : ℝ)+1)) := by
  have hk : (0 : ℝ) ≤ k := Nat.cast_nonneg k
  have hden : 0 < 4*((k : ℝ)+1) := by positivity
  have hexp := Real.add_one_le_exp (2 * (8*((k : ℝ)+1)) - 4)
  rw [show -2 * (8*((k : ℝ)+1)) + 4 = -(2 * (8*((k : ℝ)+1)) - 4) by ring,
    Real.exp_neg, ← div_eq_mul_inv]
  apply (div_le_div_iff₀ (Real.exp_pos _) hden).mpr
  nlinarith

def parityDetectorGaussianMean {d : ℕ} (S : Finset (Fin d))
    (noise : ClippingCube d → I → ℝ) (j : ℕ) (x : ClippingCube d) : ℝ :=
  gaussianRowMean (noise x) (parityDetectorArgument S j (8*((S.card : ℝ)+1)) x)

theorem parityDetectorGaussianMean_error {d : ℕ} (S : Finset (Fin d))
    (noise : ClippingCube d → I → ℝ)
    (hnoise : ∀ x, ∑ i, noise x i ^ 2 ≤ 2) (j : ℕ) (x : ClippingCube d) :
    |parityDetectorGaussianMean S noise j x - parityStep j (falseCount S x)| ≤
      1 / (4*((S.card : ℝ)+1)) := by
  have hsign : parityStep j (falseCount S x) = 1 ∨
      parityStep j (falseCount S x) = -1 := by
    by_cases hj : j < falseCount S x <;> simp [parityStep, hj]
  exact (gaussianRowMean_signed_saturation (noise x) _ _ _ hsign
    (parityDetectorArgument_margin S j _ (by positivity) x) (hnoise x)).trans
      (polynomial_gain_saturation S.card)

def parityConstantGaussianMean {d : ℕ} (S : Finset (Fin d))
    (noise : ClippingCube d → I → ℝ) (x : ClippingCube d) : ℝ :=
  gaussianRowMean (noise x) (8*((S.card : ℝ)+1) * parityConstant S.card)

theorem parityConstantGaussianMean_error {d : ℕ} (S : Finset (Fin d))
    (noise : ClippingCube d → I → ℝ)
    (hnoise : ∀ x, ∑ i, noise x i ^ 2 ≤ 2) (x : ClippingCube d) :
    |parityConstantGaussianMean S noise x - parityConstant S.card| ≤
      1 / (4*((S.card : ℝ)+1)) := by
  rcases parityConstant_zero_or_one S.card with hzero | hone
  · simp [parityConstantGaussianMean, hzero, gaussianRowMean_zero]
    positivity
  · unfold parityConstantGaussianMean
    rw [hone, mul_one]
    exact (gaussianRowMean_signed_saturation (noise x) _ _ 1 (Or.inl rfl)
      (by simp) (hnoise x)).trans (polynomial_gain_saturation S.card)

def parityGaussianMixtureMean {d : ℕ} (S : Finset (Fin d))
    (noise : ClippingCube d → I → ℝ) (x : ClippingCube d) : ℝ :=
  (parityConstantGaussianMean S noise x +
    ∑ j ∈ Finset.range S.card, (-1 : ℝ)^(j+1) * parityDetectorGaussianMean S noise j x) /
      ((S.card : ℝ)+1)

theorem neg_one_pow_abs (n : ℕ) : |(-1 : ℝ)^n| = 1 := by
  rw [abs_pow]
  norm_num

theorem parityGaussianMixtureMean_error {d : ℕ} (S : Finset (Fin d))
    (noise : ClippingCube d → I → ℝ)
    (hnoise : ∀ x, ∑ i, noise x i ^ 2 ≤ 2) (x : ClippingCube d) :
    |parityGaussianMixtureMean S noise x - walshCharacter S x / ((S.card : ℝ)+1)| ≤
      1 / (4*((S.card : ℝ)+1)) := by
  let e : ℝ := 1 / (4*((S.card : ℝ)+1))
  have hs : 0 < (S.card : ℝ)+1 := by positivity
  have hsum : |∑ j ∈ Finset.range S.card, (-1 : ℝ)^(j+1) *
      (parityDetectorGaussianMean S noise j x - parityStep j (falseCount S x))| ≤
      (S.card : ℝ) * e := by
    calc
      _ ≤ ∑ j ∈ Finset.range S.card, |(-1 : ℝ)^(j+1) *
          (parityDetectorGaussianMean S noise j x - parityStep j (falseCount S x))| :=
        Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ _j ∈ Finset.range S.card, e := by
        apply Finset.sum_le_sum
        intro j _
        rw [abs_mul, neg_one_pow_abs, one_mul]
        exact parityDetectorGaussianMean_error S noise hnoise j x
      _ = _ := by simp
  have hc := parityConstantGaussianMean_error S noise hnoise x
  have herr : |parityConstantGaussianMean S noise x +
      (∑ j ∈ Finset.range S.card, (-1 : ℝ)^(j+1) * parityDetectorGaussianMean S noise j x) -
      walshCharacter S x| ≤ ((S.card : ℝ)+1) * e := by
    rw [walsh_threshold_decomposition S x]
    have heq : parityConstantGaussianMean S noise x +
        (∑ j ∈ Finset.range S.card, (-1 : ℝ)^(j+1) * parityDetectorGaussianMean S noise j x) -
        (parityConstant S.card + ∑ j ∈ Finset.range S.card,
          (-1 : ℝ)^(j+1) * parityStep j (falseCount S x)) =
        (parityConstantGaussianMean S noise x - parityConstant S.card) +
        ∑ j ∈ Finset.range S.card, (-1 : ℝ)^(j+1) *
          (parityDetectorGaussianMean S noise j x - parityStep j (falseCount S x)) := by
      simp_rw [mul_sub, Finset.sum_sub_distrib]
      ring
    rw [heq]
    have htri := abs_add_le (parityConstantGaussianMean S noise x - parityConstant S.card)
      (∑ j ∈ Finset.range S.card, (-1 : ℝ)^(j+1) *
        (parityDetectorGaussianMean S noise j x - parityStep j (falseCount S x)))
    change _ ≤ e at hc
    linarith
  unfold parityGaussianMixtureMean
  rw [← sub_div, abs_div, abs_of_pos hs]
  apply (div_le_iff₀ hs).mpr
  simpa only [e, mul_comm] using herr

/-- The actual Gaussian detector integrals have an inverse-polynomial signed
margin before symmetrization. This includes the empty parity. -/
theorem parityGaussianMixtureMean_margin {d : ℕ} (S : Finset (Fin d))
    (noise : ClippingCube d → I → ℝ)
    (hnoise : ∀ x, ∑ i, noise x i ^ 2 ≤ 2) (x : ClippingCube d) :
    1 / (2*((S.card : ℝ)+1)) ≤ walshCharacter S x * parityGaussianMixtureMean S noise x := by
  have h := parityGaussianMixtureMean_error S noise hnoise x
  have hs : 0 < (S.card : ℝ)+1 := by positivity
  rcases sq_eq_one_iff.mp (walshCharacter_sq S x) with hchar | hchar
  · rw [hchar, one_mul]
    rw [hchar] at h
    have hh := (abs_le.mp h).1
    field_simp at hh ⊢
    nlinarith
  · rw [hchar, neg_one_mul]
    rw [hchar] at h
    have hh := (abs_le.mp h).2
    field_simp at hh ⊢
    nlinarith

end ConditionalNonpolynomial.Analytic

#print axioms ConditionalNonpolynomial.Analytic.parityDetectorGaussianMean_error
#print axioms ConditionalNonpolynomial.Analytic.parityGaussianMixtureMean_margin
