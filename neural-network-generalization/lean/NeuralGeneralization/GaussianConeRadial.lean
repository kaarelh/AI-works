import NeuralGeneralization.GaussianProductDensity
import Mathlib.Probability.ConditionalProbability
import Mathlib.Probability.Moments.MGFAnalytic

/-! Exact radial exponential moments under any positive homogeneous Gaussian
cone. Scaling is proved by the ordinary Gaussian density and Haar change of
variables, so radius-direction independence is a conclusion, not a premise. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal Topology
namespace NeuralGeneralization.GaussianConeRadial
open GaussianProductDensity
variable {I : Type*} [Fintype I]

def squaredRadius (x : I → ℝ) : ℝ := ∑ i, x i ^ 2

def PositiveHomogeneous (E : Set (I → ℝ)) : Prop :=
  ∀ (a : ℝ), 0 < a → ∀ x, (a • x ∈ E ↔ x ∈ E)

theorem squaredRadius_smul (a : ℝ) (x : I → ℝ) :
    squaredRadius (a • x) = a ^ 2 * squaredRadius x := by
  simp [squaredRadius, mul_pow, Finset.mul_sum]

/-- Lebesgue scaling of the radial exponential on an arbitrary measurable cone. -/
theorem cone_gaussian_integral_scale (E : Set (I → ℝ)) (hcone : PositiveHomogeneous E)
    {a : ℝ} (ha : 0 < a) :
    (∫ x, E.indicator (fun y => Real.exp (-(a ^ 2 * squaredRadius y) / 2)) x) =
      (a ^ Fintype.card I)⁻¹ * ∫ x, E.indicator (fun y => Real.exp (-squaredRadius y / 2)) x := by
  have h := Measure.integral_comp_smul (volume : Measure (I → ℝ))
    (E.indicator (fun y => Real.exp (-squaredRadius y / 2))) a
  have heq (x : I → ℝ) :
      E.indicator (fun y => Real.exp (-squaredRadius y / 2)) (a • x) =
      E.indicator (fun y => Real.exp (-(a ^ 2 * squaredRadius y) / 2)) x := by
    by_cases hx : x ∈ E
    · simp only [Set.indicator_of_mem hx, Set.indicator_of_mem ((hcone a ha x).2 hx),
        squaredRadius_smul]
    · simp only [Set.indicator_of_notMem hx,
        Set.indicator_of_notMem (fun hax => hx ((hcone a ha x).1 hax))]
  simp_rw [heq] at h
  simpa only [Module.finrank_pi, Module.finrank_self, Nat.mul_one,
    abs_of_nonneg (inv_nonneg.mpr (pow_nonneg ha.le _)), smul_eq_mul] using h

/-- Product Gaussian set integral in the density form needed for radial scaling. -/
theorem cone_exponential_integral_density (E : Set (I → ℝ)) (hE : MeasurableSet E) (t : ℝ) :
    (∫ x in E, Real.exp (t * squaredRadius x)
      ∂Measure.pi (fun _ : I => gaussianReal 0 1)) =
      (Real.sqrt (2 * Real.pi))⁻¹ ^ Fintype.card I *
      ∫ x, E.indicator (fun y => Real.exp (-((1 - 2 * t) * squaredRadius y) / 2)) x := by
  rw [← integral_indicator hE, integral_gaussianPi 1 (by norm_num)]
  rw [← integral_const_mul]
  apply integral_congr_ae
  apply Filter.Eventually.of_forall
  intro x
  dsimp only
  rw [standard_density_eq]
  by_cases hx : x ∈ E
  · simp only [Set.indicator_of_mem hx]
    rw [mul_assoc, ← Real.exp_add]
    congr 2
    unfold squaredRadius
    ring
  · simp only [Set.indicator_of_notMem hx, mul_zero]

/-- The restricted Gaussian radial MGF factors into cone probability and
exactly the unrestricted chi-square MGF. -/
theorem cone_exponential_integral (E : Set (I → ℝ)) (hE : MeasurableSet E)
    (hcone : PositiveHomogeneous E) {t : ℝ} (ht : t < 1 / 2) :
    (∫ x in E, Real.exp (t * squaredRadius x)
      ∂Measure.pi (fun _ : I => gaussianReal 0 1)) =
      (Real.sqrt (1 - 2 * t) ^ Fintype.card I)⁻¹ *
        (Measure.pi (fun _ : I => gaussianReal 0 1)).real E := by
  have hpos : 0 < 1 - 2 * t := by linarith
  rw [cone_exponential_integral_density E hE t]
  have hscale := cone_gaussian_integral_scale E hcone (Real.sqrt_pos.mpr hpos)
  rw [Real.sq_sqrt hpos.le] at hscale
  rw [hscale]
  have hzero := cone_exponential_integral_density E hE 0
  simp only [zero_mul, mul_zero, Real.exp_zero, sub_zero, one_mul, integral_const, smul_eq_mul, mul_one, Measure.real, Measure.restrict_apply_univ] at hzero
  rw [mul_left_comm]
  rw [← hzero]
  rfl

/-- Conditioning on a cone leaves every finite radial exponential moment
unchanged, including cones with arbitrarily small positive probability. -/
theorem mgf_cond_eq (E : Set (I → ℝ)) (hE : MeasurableSet E)
    (hcone : PositiveHomogeneous E)
    (hprob : (Measure.pi (fun _ : I => gaussianReal 0 1)) E ≠ 0)
    {t : ℝ} (ht : t < 1 / 2) :
    mgf squaredRadius (cond (Measure.pi (fun _ : I => gaussianReal 0 1)) E) t =
      mgf squaredRadius (Measure.pi (fun _ : I => gaussianReal 0 1)) t := by
  have hp : (Measure.pi (fun _ : I => gaussianReal 0 1)).real E ≠ 0 :=
    (ENNReal.toReal_pos hprob (measure_ne_top _ _)).ne'
  unfold mgf ProbabilityTheory.cond
  rw [integral_smul_measure, ENNReal.toReal_inv]
  change ((Measure.pi (fun _ : I => gaussianReal 0 1)).real E)⁻¹ *
    (∫ x in E, Real.exp (t * squaredRadius x) ∂Measure.pi (fun _ : I => gaussianReal 0 1)) = _
  rw [cone_exponential_integral E hE hcone ht]
  have hu := cone_exponential_integral (I := I) Set.univ MeasurableSet.univ
    (fun a ha x => by simp) ht
  simp only [Measure.restrict_univ, probReal_univ, mul_one] at hu
  rw [hu]
  field_simp

/-- The exact radial MGF is finite on its natural open half-line. -/
theorem integrable_exp_squaredRadius {t : ℝ} (ht : t < 1 / 2) :
    Integrable (fun x : I → ℝ => Real.exp (t * squaredRadius x))
      (Measure.pi (fun _ : I => gaussianReal 0 1)) := by
  apply Integrable.of_integral_ne_zero
  have hu := cone_exponential_integral (I := I) Set.univ MeasurableSet.univ
    (fun a ha x => by simp) ht
  simp only [Measure.restrict_univ, probReal_univ, mul_one] at hu
  rw [hu]
  exact inv_ne_zero (pow_ne_zero _ (Real.sqrt_pos.mpr (by linarith)).ne')

theorem zero_mem_interior_integrableExpSet :
    (0 : ℝ) ∈ interior (integrableExpSet (squaredRadius (I := I))
      (Measure.pi (fun _ : I => gaussianReal 0 1))) := by
  apply mem_interior_iff_mem_nhds.mpr
  apply Filter.mem_of_superset (Iio_mem_nhds (show (0 : ℝ) < 1 / 2 by norm_num))
  intro t ht
  exact integrable_exp_squaredRadius ht

theorem zero_mem_interior_integrableExpSet_cond (E : Set (I → ℝ))
    (hprob : (Measure.pi (fun _ : I => gaussianReal 0 1)) E ≠ 0) :
    (0 : ℝ) ∈ interior (integrableExpSet squaredRadius
      (cond (Measure.pi (fun _ : I => gaussianReal 0 1)) E)) := by
  apply mem_interior_iff_mem_nhds.mpr
  apply Filter.mem_of_superset (Iio_mem_nhds (show (0 : ℝ) < 1 / 2 by norm_num))
  intro t ht
  exact (integrable_exp_squaredRadius ht).restrict.smul_measure
    (ENNReal.inv_ne_top.mpr hprob)

/-- Differentiating the exact conditional MGF shows that conditioning on a
positive homogeneous event preserves the expected squared radius. -/
theorem integral_squaredRadius_cond_eq (E : Set (I → ℝ)) (hE : MeasurableSet E)
    (hcone : PositiveHomogeneous E)
    (hprob : (Measure.pi (fun _ : I => gaussianReal 0 1)) E ≠ 0) :
    (∫ x, squaredRadius x ∂cond (Measure.pi (fun _ : I => gaussianReal 0 1)) E) =
      ∫ x, squaredRadius x ∂Measure.pi (fun _ : I => gaussianReal 0 1) := by
  have heq : mgf squaredRadius (cond (Measure.pi (fun _ : I => gaussianReal 0 1)) E)
      =ᶠ[𝓝 (0 : ℝ)] mgf squaredRadius (Measure.pi (fun _ : I => gaussianReal 0 1)) := by
    filter_upwards [Iio_mem_nhds (show (0 : ℝ) < 1 / 2 by norm_num)] with t ht
    exact mgf_cond_eq E hE hcone hprob ht
  have hd := heq.deriv_eq
  rw [deriv_mgf_zero (zero_mem_interior_integrableExpSet_cond E hprob),
    deriv_mgf_zero zero_mem_interior_integrableExpSet] at hd
  exact hd

theorem integral_gaussian_square : (∫ x : ℝ, x ^ 2 ∂gaussianReal 0 1) = 1 := by
  have h := variance_fun_id_gaussianReal (μ := 0) (v := 1)
  rw [variance_eq_integral measurable_id'.aemeasurable] at h
  simpa using h

theorem memLp_eval (i : I) :
    MemLp (fun x : I → ℝ => x i) 2 (Measure.pi (fun _ : I => gaussianReal 0 1)) := by
  exact (memLp_id_gaussianReal (μ := 0) (v := 1) 2).comp_measurePreserving
    (measurePreserving_eval (fun _ : I => gaussianReal 0 1) i)

theorem integrable_eval_sq (i : I) :
    Integrable (fun x : I → ℝ => (x i) ^ 2)
      (Measure.pi (fun _ : I => gaussianReal 0 1)) := by
  exact integrable_comp_eval (μ := fun _ : I => gaussianReal 0 1) (i := i) (Integrable.of_integral_ne_zero
    (by rw [integral_gaussian_square]; norm_num))

theorem integral_squaredRadius :
    (∫ x : I → ℝ, squaredRadius x ∂Measure.pi (fun _ : I => gaussianReal 0 1)) =
      Fintype.card I := by
  unfold squaredRadius
  rw [integral_finsetSum _ (fun i hi => integrable_eval_sq i)]
  have hi (i : I) : (∫ x : I → ℝ, x i ^ 2 ∂Measure.pi (fun _ : I => gaussianReal 0 1)) = 1 := by
    rw [integral_comp_eval (μ := fun _ : I => gaussianReal 0 1) (i := i)
      (show AEStronglyMeasurable (fun x : ℝ => x ^ 2) (gaussianReal 0 1) from by fun_prop)]
    exact integral_gaussian_square
  simp only [hi, Finset.sum_const, Finset.card_univ, nsmul_eq_mul, mul_one]

/-- Exact dimension identity for every Borel homogeneous cone of positive
Gaussian measure. No lower bound on the cone probability is required. -/
theorem integral_squaredRadius_cond (E : Set (I → ℝ)) (hE : MeasurableSet E)
    (hcone : PositiveHomogeneous E)
    (hprob : (Measure.pi (fun _ : I => gaussianReal 0 1)) E ≠ 0) :
    (∫ x, squaredRadius x ∂cond (Measure.pi (fun _ : I => gaussianReal 0 1)) E) =
      Fintype.card I := by
  rw [integral_squaredRadius_cond_eq E hE hcone hprob, integral_squaredRadius]

/-- The squared Euclidean norm of the conditioned Gaussian mean is at most
the ambient dimension, uniformly over all positive homogeneous cones. -/
theorem sum_sq_conditional_mean_le_card (E : Set (I → ℝ)) (hE : MeasurableSet E)
    (hcone : PositiveHomogeneous E)
    (hprob : (Measure.pi (fun _ : I => gaussianReal 0 1)) E ≠ 0) :
    (∑ i, (∫ x : I → ℝ, x i
      ∂cond (Measure.pi (fun _ : I => gaussianReal 0 1)) E) ^ 2) ≤ Fintype.card I := by
  let ν := cond (Measure.pi (fun _ : I => gaussianReal 0 1)) E
  letI : IsProbabilityMeasure ν := cond_isProbabilityMeasure hprob
  have hm (i : I) : MemLp (fun x : I → ℝ => x i) 2 ν :=
    ((memLp_eval i).restrict E).smul_measure (ENNReal.inv_ne_top.mpr hprob)
  have hi (i : I) : Integrable (fun x : I → ℝ => x i ^ 2) ν :=
    (integrable_eval_sq i).restrict.smul_measure (ENNReal.inv_ne_top.mpr hprob)
  have hb (i : I) : (∫ x : I → ℝ, x i ∂ν) ^ 2 ≤ ∫ x : I → ℝ, x i ^ 2 ∂ν := by
    have h := variance_nonneg (X := fun x : I → ℝ => x i) (μ := ν)
    rw [variance_eq_sub (hm i)] at h
    change 0 ≤ (∫ x : I → ℝ, x i ^ 2 ∂ν) - (∫ x : I → ℝ, x i ∂ν) ^ 2 at h
    linarith
  calc
    _ ≤ ∑ i, ∫ x : I → ℝ, x i ^ 2 ∂ν := Finset.sum_le_sum (fun i hi => hb i)
    _ = ∫ x : I → ℝ, squaredRadius x ∂ν := by
      unfold squaredRadius
      rw [integral_finsetSum _ (fun i _ => hi i)]
    _ = Fintype.card I := integral_squaredRadius_cond E hE hcone hprob

end NeuralGeneralization.GaussianConeRadial
