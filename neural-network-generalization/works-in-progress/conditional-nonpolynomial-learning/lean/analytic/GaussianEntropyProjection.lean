import GaussianCovarianceEntropy
import Mathlib.MeasureTheory.Measure.Tilted

/-! Exact finite-KL reference change for integrable exponential tilts, followed
by the Gaussian quadratic information projection. -/

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal NNReal

namespace ConditionalNonpolynomial.Analytic

theorem klDiv_tilted_reference_change
    {Ω : Type*} [MeasurableSpace Ω] (Q G : Measure Ω)
    [IsProbabilityMeasure Q] [IsProbabilityMeasure G]
    (hKL : klDiv Q G ≠ ∞) (V : Ω → ℝ)
    (hVQ : Integrable V Q) (hVG : Integrable (fun x => Real.exp (V x)) G) :
    klDiv Q (G.tilted V) ≠ ∞ ∧
      (klDiv Q G).toReal = (klDiv Q (G.tilted V)).toReal +
        (∫ x, V x ∂Q) - Real.log (∫ x, Real.exp (V x) ∂G) := by
  haveI : IsProbabilityMeasure (G.tilted V) := isProbabilityMeasure_tilted hVG
  obtain ⟨hQG, hlogQG⟩ := klDiv_ne_top_iff.mp hKL
  have hQH : Q ≪ G.tilted V := hQG.trans (absolutelyContinuous_tilted hVG)
  have hp : 0 < ∫ x, Real.exp (V x) ∂G := integral_exp_pos hVG
  have hlog : llr Q (G.tilted V) =ᵐ[Q]
      fun x => llr Q G x - V x + Real.log (∫ y, Real.exp (V y) ∂G) := by
    filter_upwards [hQG (toReal_rnDeriv_tilted_right Q G hVG),
      Measure.rnDeriv_pos hQG, hQG (Measure.rnDeriv_lt_top Q G)] with x hx hpos htop
    have hreal : (Q.rnDeriv G x).toReal ≠ 0 :=
      (ENNReal.toReal_pos hpos.ne' htop.ne).ne'
    rw [llr, hx, Real.log_mul (mul_ne_zero (Real.exp_ne_zero _) hp.ne') hreal,
      Real.log_mul (Real.exp_ne_zero _) hp.ne', Real.log_exp]
    change _ = Real.log (Q.rnDeriv G x).toReal - _ + _
    ring
  have hlogQH : Integrable (llr Q (G.tilted V)) Q :=
    ((hlogQG.sub hVQ).add (integrable_const _)).congr hlog.symm
  refine ⟨klDiv_ne_top hQH hlogQH, ?_⟩
  rw [toReal_klDiv hQG hlogQG, toReal_klDiv hQH hlogQH, integral_congr_ae hlog]
  have hsub : Integrable (fun x => llr Q G x - V x) Q := hlogQG.sub hVQ
  rw [integral_add hsub (integrable_const _), integral_sub hlogQG hVQ]
  simp
  ring

def diagonalQuadraticPotential {I : Type*} [Fintype I] (v : I → ℝ) (x : I → ℝ) : ℝ :=
  ∑ i, ((1 - (v i)⁻¹) / 2) * ((x i)^2 - 1)

def diagonalQuadraticLogPartition {I : Type*} [Fintype I] (v : I → ℝ) : ℝ :=
  ∑ i, (-((1 - (v i)⁻¹) / 2) + Real.log (v i) / 2)

theorem diagonalQuadratic_exp_integrable
    {I : Type*} [Fintype I] (v : I → ℝ) (hv : ∀ i, 0 < v i) :
    Integrable (fun x => Real.exp (diagonalQuadraticPotential v x))
      (Measure.pi fun _ : I => gaussianReal 0 1) := by
  apply Integrable.congr
    (NeuralGeneralization.GaussianTail.integrable_exp_sum_centered_gaussian_squares
      (fun _ : I => (1 : ℝ≥0)) (fun i => (1-(v i)⁻¹)/2) 1 ?_) ?_
  · intro i
    simp only [NNReal.coe_one, one_mul, mul_one]
    have := inv_pos.mpr (hv i)
    linarith
  · filter_upwards [] with x
    simp only [NNReal.coe_one, one_mul, diagonalQuadraticPotential]

theorem diagonalQuadratic_exp_integral
    {I : Type*} [Fintype I] (v : I → ℝ) (hv : ∀ i, 0 < v i) :
    (∫ x : I → ℝ, Real.exp (diagonalQuadraticPotential v x)
      ∂(Measure.pi fun _ : I => gaussianReal 0 1)) =
        Real.exp (diagonalQuadraticLogPartition v) := by
  classical
  have hdom (i : I) : 0 < 1 - 2 * (1:ℝ) * ((1-(v i)⁻¹)/2) * (1 : ℝ≥0) := by
    simp only [NNReal.coe_one, one_mul, mul_one]
    have := inv_pos.mpr (hv i)
    linarith
  have h := NeuralGeneralization.GaussianTail.mgf_sum_centered_gaussian_squares
    (fun _ : I => (1 : ℝ≥0)) (fun i => (1-(v i)⁻¹)/2) 1 hdom
  simp only [mgf, one_mul, NNReal.coe_one, mul_one] at h
  change (∫ x, Real.exp (diagonalQuadraticPotential v x)
    ∂(Measure.pi fun _ : I => gaussianReal 0 1)) = _ at h
  rw [h, diagonalQuadraticLogPartition, Real.exp_sum]
  apply Finset.prod_congr rfl
  intro i _
  have heq : 1 - 2 * ((1 - (v i)⁻¹)/2) = (v i)⁻¹ := by ring
  rw [heq]
  simp only [neg_mul, one_mul]
  have hp : 0 < Real.exp (-((1 - (v i)⁻¹)/2)) / Real.sqrt ((v i)⁻¹) :=
    div_pos (Real.exp_pos _) (Real.sqrt_pos.mpr (inv_pos.mpr (hv i)))
  rw [← Real.exp_log hp, Real.log_div (Real.exp_ne_zero _)
    (Real.sqrt_pos.mpr (inv_pos.mpr (hv i))).ne', Real.log_exp,
    Real.log_sqrt (inv_nonneg.mpr (hv i).le), Real.log_inv]
  congr 1
  ring

/-- Exact decomposition into the nonnegative KL relative to the quadratic
Gaussian tilt and the Gaussian second-moment cost. -/
theorem gaussian_diagonal_entropy_decomposition
    {I : Type*} [Fintype I] (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞)
    (v : I → ℝ) (hv : ∀ i, 0 < v i)
    (hm : ∀ i, ∫ x : I → ℝ, x i ^ 2 ∂Q = v i) :
    klDiv Q ((Measure.pi fun _ : I => gaussianReal 0 1).tilted
      (diagonalQuadraticPotential v)) ≠ ∞ ∧
    (klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1)).toReal =
      (klDiv Q ((Measure.pi fun _ : I => gaussianReal 0 1).tilted
        (diagonalQuadraticPotential v))).toReal +
      (∑ i, (v i - 1 - Real.log (v i))) / 2 := by
  classical
  have hi (i : I) : Integrable (fun x : I → ℝ => ((1-(v i)⁻¹)/2) * ((x i)^2 - 1)) Q :=
    ((gaussian_coordinate_second_moment_integrable Q hKL i).sub (integrable_const 1)).const_mul _
  have hVQ : Integrable (diagonalQuadraticPotential v) Q :=
    integrable_finsetSum _ (fun i _ => hi i)
  obtain ⟨hfinite, heq⟩ := klDiv_tilted_reference_change Q
    (Measure.pi fun _ : I => gaussianReal 0 1) hKL
    (diagonalQuadraticPotential v) hVQ (diagonalQuadratic_exp_integrable v hv)
  refine ⟨hfinite, ?_⟩
  rw [diagonalQuadratic_exp_integral v hv, Real.log_exp] at heq
  have hmean : (∫ x, diagonalQuadraticPotential v x ∂Q) =
      ∑ i, ((1-(v i)⁻¹)/2) * (v i - 1) := by
    simp only [diagonalQuadraticPotential]
    rw [integral_finsetSum _ (fun i _ => hi i)]
    apply Finset.sum_congr rfl
    intro i _
    rw [integral_const_mul,
      integral_sub (gaussian_coordinate_second_moment_integrable Q hKL i)
        (integrable_const 1), hm i]
    simp
  rw [hmean] at heq
  have hid : (∑ i, ((1-(v i)⁻¹)/2) * (v i - 1)) - diagonalQuadraticLogPartition v =
      (∑ i, (v i - 1 - Real.log (v i))) / 2 := by
    unfold diagonalQuadraticLogPartition
    rw [← Finset.sum_sub_distrib, Finset.sum_div]
    apply Finset.sum_congr rfl
    intro i _
    field_simp [ne_of_gt (hv i)]
    ring
  linarith

#print axioms klDiv_tilted_reference_change
#print axioms gaussian_diagonal_entropy_decomposition

end ConditionalNonpolynomial.Analytic
