import NeuralGeneralization.BatchTwoNonGaussianCertificate
import NeuralGeneralization.GaussianTail
import Mathlib.Analysis.Complex.ExponentialBounds

/-! A bounded smooth small-ball kernel, adapted to the already proved relative
Lindeberg theorem. This avoids assuming convolution log-concavity. -/

noncomputable section
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoNonGaussian
open ConcreteModel TanhDifferential FiniteDifferential GaussianFieldTilt GaussianAngularPrice

def softBall (G x : ℝ) : ℝ := Real.exp (-G * Real.tanh x ^ 2)
def normalizedSum (N : ℕ) (x : Fin N → ℝ) : ℝ := (∑ j, x j) / Real.sqrt N

theorem abs_tanh_le_abs (x : ℝ) : |Real.tanh x| ≤ |x| := by
  simpa only [Real.tanh_zero, sub_zero] using tanh_admissible.2 x 0

theorem tanh_monotone : Monotone Real.tanh :=
  monotone_of_deriv_nonneg (fun x => (hasDerivAt_tanh_first x).differentiableAt)
    (fun x => by rw [(hasDerivAt_tanh_first x).deriv]; exact tanhFirst_nonneg x)

theorem half_le_tanh {ρ : ℝ} (hρ : 0 ≤ ρ) (hρhalf : ρ ≤ 1 / 2) : ρ / 2 ≤ Real.tanh ρ := by
  have hder (x : ℝ) (hx : x ∈ interior (Icc 0 ρ)) : (1 / 2 : ℝ) ≤ deriv Real.tanh x := by
    have hxi : x ∈ Icc 0 ρ := interior_subset hx
    have ht := abs_tanh_le_abs x
    rw [abs_of_nonneg hxi.1] at ht
    have hs := (sq_le_sq₀ (abs_nonneg (Real.tanh x)) hxi.1).mpr ht
    rw [sq_abs] at hs
    rw [(hasDerivAt_tanh_first x).deriv, tanhFirst]
    have hx0 := hxi.1
    have hx1 := hxi.2
    nlinarith [sq_nonneg (ρ - x)]
  have h := (convex_Icc (0 : ℝ) ρ).mul_sub_le_image_sub_of_le_deriv
    continuous_tanh.continuousOn
    (fun x _ => (hasDerivAt_tanh_first x).differentiableAt.differentiableWithinAt)
    hder 0 ⟨le_rfl, hρ⟩ ρ ⟨hρ, le_rfl⟩ hρ
  simpa only [sub_zero, Real.tanh_zero, div_eq_mul_inv, one_mul, mul_comm] using h

theorem abs_tanh_lower {ρ x : ℝ} (hρ : 0 ≤ ρ) (hρhalf : ρ ≤ 1 / 2)
    (hx : ρ ≤ |x|) : ρ / 2 ≤ |Real.tanh x| := by
  have h := (half_le_tanh hρ hρhalf).trans (tanh_monotone hx)
  have heq : Real.tanh |x| = |Real.tanh x| := by
    rcases le_total 0 x with hx0 | hx0
    · rw [abs_of_nonneg hx0, abs_of_nonneg]
      simpa only [Real.tanh_zero] using tanh_monotone hx0
    · rw [abs_of_nonpos hx0, Real.tanh_neg, abs_of_nonpos]
      simpa only [Real.tanh_zero] using tanh_monotone hx0
  rwa [heq] at h

theorem softBall_le_one {G : ℝ} (hG : 0 ≤ G) (x : ℝ) : softBall G x ≤ 1 := by
  apply Real.exp_le_one_iff.mpr
  nlinarith [sq_nonneg (Real.tanh x)]

theorem softBall_tail {G ρ x : ℝ} (hG : 0 ≤ G) (hρ : 0 ≤ ρ)
    (hρhalf : ρ ≤ 1 / 2) (hx : ρ ≤ |x|) :
    softBall G x ≤ Real.exp (-G * ρ ^ 2 / 4) := by
  have ht := abs_tanh_lower hρ hρhalf hx
  have hs := (sq_le_sq₀ (by positivity : 0 ≤ ρ / 2) (abs_nonneg (Real.tanh x))).mpr ht
  rw [sq_abs] at hs
  have hh := mul_le_mul_of_nonneg_left hs hG
  apply Real.exp_le_exp.mpr
  nlinarith

theorem softBall_integrable (μ : Measure ℝ) [IsProbabilityMeasure μ] {G : ℝ} (hG : 0 ≤ G) :
    Integrable (softBall G) μ := by
  apply Integrable.of_bound (by unfold softBall; fun_prop) 1
  exact ae_of_all _ (fun x => by
    rw [Real.norm_eq_abs, abs_of_pos (show 0 < softBall G x from Real.exp_pos _)]
    exact softBall_le_one hG x)

theorem gaussian_softBall_lower {G : ℝ} (hG : 0 ≤ G) :
    (Real.sqrt (1 + 2 * G))⁻¹ ≤ ∫ x, softBall G x ∂gaussianReal 0 1 := by
  have hi : Integrable (fun x : ℝ => Real.exp (-G * x ^ 2)) (gaussianReal 0 1) := by
    apply Integrable.of_bound (by fun_prop) 1
    filter_upwards [] with x
    rw [Real.norm_eq_abs, abs_of_pos (Real.exp_pos _)]
    apply Real.exp_le_one_iff.mpr
    nlinarith [sq_nonneg x]
  have h := integral_mono hi (softBall_integrable (gaussianReal 0 1) hG) (fun x => by
    have hs := (sq_le_sq₀ (abs_nonneg (Real.tanh x)) (abs_nonneg x)).mpr (abs_tanh_le_abs x)
    simp only [sq_abs] at hs
    apply Real.exp_le_exp.mpr
    have hh := mul_le_mul_of_nonneg_left hs hG
    linarith)
  rw [GaussianTail.integral_exp_mul_sq_gaussianReal 1 (-G) (by simp; linarith)] at h
  simpa only [NNReal.coe_one, mul_one, mul_neg, sub_neg_eq_add] using h

theorem gaussian_normalized_partition (N : ℕ) (hN : 0 < N) (G : ℝ) :
    fieldPartition (fun _ : Fin N => standardGaussian) (fun _ _ : Unit => -G)
      (fun _ _ => 1 / Real.sqrt N) = ∫ x, softBall G x ∂gaussianReal 0 1 := by
  let A : Unit → Fin N → ℝ := fun _ _ => 1 / Real.sqrt N
  let B : Unit → Unit → ℝ := fun _ _ => 1
  have hNr : 0 < (N : ℝ) := by exact_mod_cast hN
  have hs : Real.sqrt N ≠ 0 := (Real.sqrt_pos.mpr hNr).ne'
  have hgram : ∀ x y, gram A x y = gram B x y := by
    intro x y
    simp only [gram, A, B, Finset.sum_const, Finset.card_univ, Fintype.card_fin,
      Fintype.card_unique, nsmul_eq_mul, mul_one, one_mul]
    field_simp
    simpa using (Real.sq_sqrt hNr.le).symm
  rw [← actualField_partition standardGaussian A, actualFieldLaw_gaussian,
    GaussianFieldCovariance.fieldLaw_eq_of_gram_eq A B hgram,
    ← actualFieldLaw_gaussian B, actualField_partition standardGaussian B]
  unfold fieldPartition fieldExp
  simp only [potentialValue, pairValue, B, Fintype.sum_prod_type, Fintype.sum_unique,
    one_mul, standardGaussian_law]
  have heq : (fun x : Unit → ℝ => Real.exp (-G * (Real.tanh (x default) * Real.tanh (x default)))) =
      fun x => softBall G (x ()) := by funext x; unfold softBall; congr 1; ring
  rw [heq]
  exact integral_comp_eval (by unfold softBall; fun_prop)

/-- Large normalized sums have at least the Gaussian soft-kernel mass, up to
the exact relative-Lindeberg cost. No central-limit theorem is postulated. -/
theorem normalized_softBall_lower (ν : CoordinateLaw) (N : ℕ) (hN : 0 < N)
    {G : ℝ} (hG : 0 ≤ G) (hsize : 4 * G ^ 2 ≤ (N : ℝ))
    (herr : replacementConstant ν standardGaussian * lindebergPolynomial G / Real.sqrt N ≤ 1) :
    Real.exp (-1) / Real.sqrt (1 + 2 * G) ≤
      ∫ x, softBall G (normalizedSum N x) ∂Measure.pi (fun _ : Fin N => ν.law) := by
  let Γ : Unit → Unit → ℝ := fun _ _ => -G
  let a : Fin N → Unit → ℝ := fun _ _ => 1 / Real.sqrt N
  have hΓ : couplingMass Γ ≤ G := by
    simp [couplingMass, Γ, abs_of_nonneg hG]
  have h := relative_lindeberg ν N hN Γ a G hG hΓ
    (fun _ _ => by simp [a, abs_div, abs_one, abs_of_nonneg (Real.sqrt_nonneg _)]) hsize
  have hlog := (abs_le.mp (h.trans herr)).1
  have hpart : Real.exp (-1) * fieldPartition (fun _ : Fin N => standardGaussian) Γ a ≤
      fieldPartition (fun _ : Fin N => ν) Γ a := by
    have hh := Real.exp_le_exp.mpr (show -1 +
      Real.log (fieldPartition (fun _ : Fin N => standardGaussian) Γ a) ≤
      Real.log (fieldPartition (fun _ : Fin N => ν) Γ a) by linarith)
    simpa only [Real.exp_add, Real.exp_log (fieldPartition_pos _ Γ a)] using hh
  rw [gaussian_normalized_partition N hN G] at hpart
  have hlo := mul_le_mul_of_nonneg_left (gaussian_softBall_lower hG) (Real.exp_pos (-1)).le
  have hlo' : Real.exp (-1) / Real.sqrt (1 + 2 * G) ≤
      Real.exp (-1) * ∫ x, softBall G x ∂gaussianReal 0 1 := by
    simpa only [div_eq_mul_inv] using hlo
  apply hlo'.trans
  convert! hpart using 1
  unfold fieldPartition fieldExp softBall normalizedSum
  apply integral_congr_ae
  filter_upwards [] with x
  simp only [potentialValue, pairValue, Γ, a, Fintype.sum_prod_type, Fintype.sum_unique]
  rw [← Finset.mul_sum]
  congr 1
  congr 1
  ring

end NeuralGeneralization.BatchTwoNonGaussian
