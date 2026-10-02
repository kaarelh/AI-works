import Paulsen.GaussianRotationConcentration
import Mathlib.Analysis.InnerProductSpace.PiL2
import Mathlib.Analysis.Calculus.ContDiff.Operations

/-!
# Smooth small-coordinate counts for correlated Gaussians

The kernel `exp (-(x/h)^2)` bounds the indicator of `|x| ≤ h` after multiplication
by `exp 1`. Its smoothness permits the elementary rotation concentration theorem.
-/

open MeasureTheory ProbabilityTheory Real Set
open scoped BigOperators ProbabilityTheory NNReal

noncomputable section

namespace Paulsen

def gaussianSoftIndicator (h x : ℝ) : ℝ := exp (-(x / h) ^ 2)

theorem gaussianSoftIndicator_nonneg (h x : ℝ) : 0 ≤ gaussianSoftIndicator h x :=
  (exp_pos _).le

theorem gaussianSoftIndicator_le_one (h x : ℝ) : gaussianSoftIndicator h x ≤ 1 := by
  unfold gaussianSoftIndicator
  rw [exp_le_one_iff]
  exact neg_nonpos.mpr (sq_nonneg _)

theorem gaussianSoftIndicator_ge_of_abs_le {h x : ℝ} (hh : 0 < h) (hx : |x| ≤ h) :
    exp (-1) ≤ gaussianSoftIndicator h x := by
  apply exp_le_exp.mpr
  have ha : |x / h| ≤ 1 := by
    rw [abs_div, abs_of_pos hh, div_le_one hh]
    exact hx
  have hs : (x / h) ^ 2 ≤ 1 := by
    nlinarith [sq_nonneg (|x / h| - 1), sq_abs (x / h), abs_nonneg (x / h)]
  linarith

theorem contDiff_gaussianSoftIndicator (h : ℝ) : ContDiff ℝ 1 (gaussianSoftIndicator h) := by
  unfold gaussianSoftIndicator
  fun_prop

theorem hasDerivAt_gaussianSoftIndicator (h x : ℝ) :
    HasDerivAt (gaussianSoftIndicator h) ((-2 / h) * (x / h) * gaussianSoftIndicator h x) x := by
  unfold gaussianSoftIndicator
  convert! ((((hasDerivAt_id x).div_const h).pow 2).neg).exp using 1
  simp only [Pi.pow_apply, Pi.neg_apply, id_eq]
  ring

/-- A simple derivative bound suffices; the optimal constant is unnecessary. -/
theorem abs_deriv_gaussianSoftIndicator_le {h : ℝ} (hh : 0 < h) (x : ℝ) :
    |deriv (gaussianSoftIndicator h) x| ≤ 2 / h := by
  rw [(hasDerivAt_gaussianSoftIndicator h x).deriv]
  have hk : |x / h| * exp (-(x / h) ^ 2) ≤ 1 := by
    have ha : |x / h| ≤ exp ((x / h) ^ 2) := by
      have he := add_one_le_exp ((x / h) ^ 2)
      have hs := sq_nonneg (|x / h| - 1 / 2)
      nlinarith [sq_abs (x / h)]
    calc
      _ ≤ exp ((x / h) ^ 2) * exp (-(x / h) ^ 2) :=
        mul_le_mul_of_nonneg_right ha (exp_pos _).le
      _ = 1 := by rw [← exp_add]; simp
  have hc : |(-2 : ℝ) / h| = 2 / h := by
    rw [abs_div, abs_of_pos hh]
    norm_num
  rw [abs_mul, abs_mul, hc, abs_of_nonneg (gaussianSoftIndicator_nonneg h x)]
  unfold gaussianSoftIndicator
  calc
    _ = (2 / h) * (|x / h| * exp (-(x / h) ^ 2)) := by ring
    _ ≤ (2 / h) * 1 := mul_le_mul_of_nonneg_left hk (by positivity)
    _ = _ := mul_one _

theorem lipschitzWith_gaussianSoftIndicator {h : ℝ} (hh : 0 < h) :
    LipschitzWith ⟨2 / h, by positivity⟩ (gaussianSoftIndicator h) := by
  apply lipschitzWith_of_nnnorm_deriv_le (contDiff_gaussianSoftIndicator h).differentiable_one
  intro x
  exact abs_deriv_gaussianSoftIndicator_le hh x

variable {ι : Type*} [Fintype ι]

/-- Average of a scalar function over Euclidean coordinates. -/
def coordinateAverage (φ : ℝ → ℝ) (z : EuclideanSpace ℝ ι) : ℝ :=
  (∑ i, φ (z i)) / Fintype.card ι

theorem contDiff_coordinateAverage (φ : ℝ → ℝ) (hφ : ContDiff ℝ 1 φ) :
    ContDiff ℝ 1 (coordinateAverage (ι := ι) φ) := by
  unfold coordinateAverage
  apply ContDiff.div_const
  apply ContDiff.sum
  intro i _
  simpa using! hφ.comp (EuclideanSpace.proj (𝕜 := ℝ) i).contDiff

theorem sum_abs_coordinates_le (z : EuclideanSpace ℝ ι) :
    (∑ i, |z i|) ≤ sqrt (Fintype.card ι) * ‖z‖ := by
  have h := Real.sum_mul_le_sqrt_mul_sqrt Finset.univ (fun _ : ι => (1 : ℝ))
    (fun i => |z i|)
  simpa [EuclideanSpace.norm_eq, Real.norm_eq_abs] using h

/-- Averaging improves the scalar Lipschitz constant by the square root of the
number of coordinates. -/
theorem lipschitzWith_coordinateAverage [Nonempty ι] (φ : ℝ → ℝ) {K : ℝ≥0}
    (hφ : LipschitzWith K φ) :
    LipschitzWith ⟨(K : ℝ) / sqrt (Fintype.card ι), by positivity⟩
      (coordinateAverage (ι := ι) φ) := by
  have hn : (0 : ℝ) < Fintype.card ι := by exact_mod_cast Fintype.card_pos
  have hs : 0 < sqrt (Fintype.card ι) := sqrt_pos.2 hn
  apply LipschitzWith.of_dist_le_mul
  intro x y
  simp only [dist_eq_norm, Real.norm_eq_abs, coordinateAverage, ← sub_div]
  rw [abs_div, abs_of_pos hn, ← Finset.sum_sub_distrib]
  calc
    _ ≤ (∑ i, |φ (x i) - φ (y i)|) / Fintype.card ι := by
      gcongr
      exact Finset.abs_sum_le_sum_abs _ _
    _ ≤ (∑ i, (K : ℝ) * |x i - y i|) / Fintype.card ι := by
      gcongr with i
      simpa only [dist_eq_norm, Real.norm_eq_abs] using hφ.dist_le_mul (x i) (y i)
    _ = (K : ℝ) * (∑ i, |(x - y) i|) / Fintype.card ι := by
      simp [Finset.mul_sum]
    _ ≤ (K : ℝ) * (sqrt (Fintype.card ι) * ‖x - y‖) / Fintype.card ι := by
      gcongr
      exact sum_abs_coordinates_le (x - y)
    _ = _ := by
      change _ = ((K : ℝ) / sqrt (Fintype.card ι)) * ‖x - y‖
      have he := sq_sqrt hn.le
      field_simp
      rw [he]
      ring

def gaussianSoftCount (h : ℝ) : EuclideanSpace ℝ ι → ℝ :=
  coordinateAverage (gaussianSoftIndicator h)

theorem contDiff_gaussianSoftCount (h : ℝ) :
    ContDiff ℝ 1 (gaussianSoftCount (ι := ι) h) :=
  contDiff_coordinateAverage _ (contDiff_gaussianSoftIndicator h)

theorem lipschitzWith_gaussianSoftCount [Nonempty ι] {h : ℝ} (hh : 0 < h) :
    LipschitzWith ⟨2 / (h * sqrt (Fintype.card ι)), by positivity⟩
      (gaussianSoftCount (ι := ι) h) := by
  have hl := lipschitzWith_coordinateAverage (ι := ι) (gaussianSoftIndicator h)
    (lipschitzWith_gaussianSoftIndicator hh)
  convert! hl using 1
  congr 1
  change 2 / (h * sqrt (Fintype.card ι)) = (2 / h) / sqrt (Fintype.card ι)
  ring

theorem integrable_gaussianSoftIndicator_volume {h : ℝ} (hh : 0 < h) :
    Integrable (gaussianSoftIndicator h) volume := by
  simpa only [gaussianSoftIndicator, neg_one_mul] using!
    (integrable_exp_neg_mul_sq (b := 1) (by norm_num)).comp_div hh.ne'

theorem integral_gaussianSoftIndicator_volume {h : ℝ} (hh : 0 < h) :
    (∫ x, gaussianSoftIndicator h x) = h * sqrt π := by
  have hi := Measure.integral_comp_div (fun x : ℝ => exp (-1 * x ^ 2)) h
  have hg : (∫ y : ℝ, exp (-y ^ 2)) = sqrt π := by
    simpa using integral_gaussian 1
  simpa [gaussianSoftIndicator, hg, abs_of_pos hh, smul_eq_mul] using! hi

theorem gaussianPDFReal_le_max (m : ℝ) (v : ℝ≥0) (x : ℝ) :
    gaussianPDFReal m v x ≤ (sqrt (2 * π * (v : ℝ)))⁻¹ := by
  rw [gaussianPDFReal_def]
  apply mul_le_of_le_one_right (by positivity)
  apply exp_le_one_iff.mpr
  exact div_nonpos_of_nonpos_of_nonneg (neg_nonpos.mpr (sq_nonneg _)) (by positivity)

/-- The mean of the smooth indicator is small uniformly in the Gaussian mean.
This follows directly from the maximum of the Gaussian density. -/
theorem integral_gaussianSoftIndicator_gaussianReal_le (m : ℝ) {v : ℝ≥0}
    (hv : 0 < v) {h : ℝ} (hh : 0 < h) :
    (∫ x, gaussianSoftIndicator h x ∂gaussianReal m v) ≤ h / sqrt (2 * (v : ℝ)) := by
  have hp : Integrable (fun x => gaussianPDFReal m v x * gaussianSoftIndicator h x) volume := by
    apply (integrable_gaussianPDFReal m v).mono' (by unfold gaussianSoftIndicator; fun_prop)
    filter_upwards with x
    rw [Real.norm_eq_abs, abs_of_nonneg (mul_nonneg (gaussianPDFReal_nonneg _ _ _)
      (gaussianSoftIndicator_nonneg _ _))]
    exact mul_le_of_le_one_right (gaussianPDFReal_nonneg _ _ _)
      (gaussianSoftIndicator_le_one _ _)
  rw [integral_gaussianReal_eq_integral_smul (ne_of_gt hv)]
  simp only [smul_eq_mul]
  calc
    _ ≤ ∫ x, (sqrt (2 * π * (v : ℝ)))⁻¹ * gaussianSoftIndicator h x := by
      apply integral_mono_ae hp ((integrable_gaussianSoftIndicator_volume hh).const_mul _)
      exact ae_of_all _ fun x => mul_le_mul_of_nonneg_right (gaussianPDFReal_le_max m v x)
        (gaussianSoftIndicator_nonneg h x)
    _ = (sqrt (2 * π * (v : ℝ)))⁻¹ * (h * sqrt π) := by
      rw [integral_const_mul, integral_gaussianSoftIndicator_volume hh]
    _ = _ := by
      have hvR : 0 < (v : ℝ) := hv
      have hden : sqrt (2 * π * (v : ℝ)) = sqrt π * sqrt (2 * (v : ℝ)) := by
        rw [show 2 * π * (v : ℝ) = π * (2 * (v : ℝ)) by ring, sqrt_mul pi_pos.le]
      rw [hden]
      field_simp

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
  [FiniteDimensional ℝ E] [MeasurableSpace E] [BorelSpace E]

/-- Scalar shifted Gaussian estimate expressed directly in terms of a linear
functional of a standard Gaussian. -/
theorem integral_gaussianSoftIndicator_affine_le (D : StrongDual ℝ E) (m : ℝ)
    {v h : ℝ} (hv : 0 < v) (hDv : v ≤ ‖D‖ ^ 2) (hh : 0 < h) :
    (∫ x, gaussianSoftIndicator h (m + D x) ∂stdGaussian E) ≤ h / sqrt (2 * v) := by
  have hmap : (stdGaussian E).map D = gaussianReal 0 (‖D‖ ^ 2).toNNReal := by
    simpa [variance_dual_stdGaussian] using IsGaussian.map_eq_gaussianReal (μ := stdGaussian E) D
  have hl : HasLaw D (gaussianReal 0 (‖D‖ ^ 2).toNNReal) (stdGaussian E) :=
    ⟨D.continuous.aemeasurable, hmap⟩
  have ha := gaussianReal_const_add hl m
  have heq := ha.integral_comp (f := gaussianSoftIndicator h)
    (contDiff_gaussianSoftIndicator h).continuous.aestronglyMeasurable
  have hvD : 0 < (‖D‖ ^ 2).toNNReal := by
    exact Real.toNNReal_pos.mpr (lt_of_lt_of_le hv hDv)
  calc
    _ = ∫ y, gaussianSoftIndicator h y ∂gaussianReal m (‖D‖ ^ 2).toNNReal := by
      simpa using! heq
    _ ≤ h / sqrt (2 * (‖D‖ ^ 2).toNNReal) :=
      integral_gaussianSoftIndicator_gaussianReal_le m hvD hh
    _ ≤ _ := by
      simp only [Real.toNNReal_of_nonneg (sq_nonneg ‖D‖)]
      gcongr
      exact hDv

/-- The smooth count of the coordinates of an affine image of a standard
Gaussian. The output coordinates may be arbitrarily correlated. -/
def affineGaussianSoftCount (h : ℝ) (m : EuclideanSpace ℝ ι)
    (C : E →L[ℝ] EuclideanSpace ℝ ι) (x : E) : ℝ :=
  gaussianSoftCount h (m + C x)

omit [FiniteDimensional ℝ E] [MeasurableSpace E] [BorelSpace E] in
theorem contDiff_affineGaussianSoftCount (h : ℝ) (m : EuclideanSpace ℝ ι)
    (C : E →L[ℝ] EuclideanSpace ℝ ι) : ContDiff ℝ 1 (affineGaussianSoftCount h m C) :=
  (contDiff_gaussianSoftCount h).comp (contDiff_const.add C.contDiff)

omit [FiniteDimensional ℝ E] [MeasurableSpace E] [BorelSpace E] in
theorem lipschitzWith_affineGaussianSoftCount [Nonempty ι] {h B : ℝ} (hh : 0 < h)
    (hB : 0 ≤ B) (m : EuclideanSpace ℝ ι) (C : E →L[ℝ] EuclideanSpace ℝ ι)
    (hC : ‖C‖ ≤ B) :
    LipschitzWith ⟨2 * B / (h * sqrt (Fintype.card ι)), by positivity⟩
      (affineGaussianSoftCount h m C) := by
  have hc : LipschitzWith ⟨B, hB⟩ (fun x => m + C x) := by
    apply LipschitzWith.of_dist_le_mul
    intro x y
    simp only [dist_add_left]
    calc
      _ ≤ ‖C‖ * dist x y := C.lipschitz.dist_le_mul x y
      _ ≤ _ := mul_le_mul_of_nonneg_right hC dist_nonneg
  convert! (lipschitzWith_gaussianSoftCount hh).comp hc using 1
  congr 1
  change _ = (2 / (h * sqrt (Fintype.card ι))) * B
  ring

/-- The upper tail has exponent proportional to the number of output
coordinates divided by the covariance operator bound `B²`. -/
theorem affineGaussianSoftCount_upper_tail [Nonempty ι] {h B : ℝ} (hh : 0 < h)
    (hB : 0 < B) (m : EuclideanSpace ℝ ι) (C : E →L[ℝ] EuclideanSpace ℝ ι)
    (hC : ‖C‖ ≤ B) {u : ℝ} (hu : 0 ≤ u) :
    (stdGaussian E).real {x | u ≤ affineGaussianSoftCount h m C x -
      ∫ y, affineGaussianSoftCount h m C y ∂stdGaussian E} ≤
      exp (-(u ^ 2 * h ^ 2 * Fintype.card ι) / (2 * π ^ 2 * B ^ 2)) := by
  have hn : (0 : ℝ) < Fintype.card ι := by exact_mod_cast Fintype.card_pos
  have hs : 0 < sqrt (Fintype.card ι) := sqrt_pos.2 hn
  have hl := lipschitzWith_affineGaussianSoftCount hh hB.le m C hC
  have ht := stdGaussian_smooth_upper_tail (affineGaussianSoftCount h m C)
    (contDiff_affineGaussianSoftCount h m C)
    (show 0 < 2 * B / (h * sqrt (Fintype.card ι)) by positivity)
    (fun x => norm_fderiv_le_of_lipschitz ℝ hl) hu
  convert ht using 1
  congr 1
  field_simp
  rw [sq_sqrt hn.le]

theorem integrable_gaussianSoftIndicator_affine (D : StrongDual ℝ E) (m h : ℝ) :
    Integrable (fun x => gaussianSoftIndicator h (m + D x)) (stdGaussian E) := by
  apply (integrable_const (1 : ℝ)).mono'
    (((contDiff_gaussianSoftIndicator h).continuous.comp
      (continuous_const.add D.continuous)).aestronglyMeasurable)
  exact ae_of_all _ fun x => by
    change ‖gaussianSoftIndicator h (m + D x)‖ ≤ 1
    rw [Real.norm_eq_abs, abs_of_nonneg (gaussianSoftIndicator_nonneg _ _)]
    exact gaussianSoftIndicator_le_one _ _

/-- Scalar Gaussian small-ball probability, uniform in the deterministic mean. -/
theorem stdGaussian_affine_smallBall (D : StrongDual ℝ E) (m : ℝ)
    {v h : ℝ} (hv : 0 < v) (hDv : v ≤ ‖D‖ ^ 2) (hh : 0 < h) :
    (stdGaussian E).real {x | |m + D x| ≤ h} ≤ exp 1 * h / sqrt (2 * v) := by
  have hm := mul_meas_ge_le_integral_of_nonneg
    (μ := stdGaussian E) (f := fun x => gaussianSoftIndicator h (m + D x))
    (ae_of_all _ fun x => gaussianSoftIndicator_nonneg _ _)
    (integrable_gaussianSoftIndicator_affine D m h) (exp (-1))
  have hi := integral_gaussianSoftIndicator_affine_le D m hv hDv hh
  calc
    _ ≤ (stdGaussian E).real {x | exp (-1) ≤ gaussianSoftIndicator h (m + D x)} := by
      apply measureReal_mono (μ := stdGaussian E) ?_ (by finiteness)
      exact fun x hx => gaussianSoftIndicator_ge_of_abs_le hh hx
    _ = exp 1 * (exp (-1) * (stdGaussian E).real
        {x | exp (-1) ≤ gaussianSoftIndicator h (m + D x)}) := by
      rw [← mul_assoc, ← exp_add]
      norm_num
    _ ≤ exp 1 * (h / sqrt (2 * v)) :=
      mul_le_mul_of_nonneg_left (hm.trans hi) (exp_pos _).le
    _ = _ := by ring

/-- If every output coordinate has variance at least `v`, the expected soft
count is at most `h / sqrt (2v)`, irrespective of the correlations or means. -/
theorem integral_affineGaussianSoftCount_le [Nonempty ι] {h v : ℝ} (hh : 0 < h)
    (hv : 0 < v) (m : EuclideanSpace ℝ ι) (C : E →L[ℝ] EuclideanSpace ℝ ι)
    (hvar : ∀ i, v ≤ ‖(EuclideanSpace.proj i).comp C‖ ^ 2) :
    (∫ x, affineGaussianSoftCount h m C x ∂stdGaussian E) ≤ h / sqrt (2 * v) := by
  have hn : (0 : ℝ) < Fintype.card ι := by exact_mod_cast Fintype.card_pos
  unfold affineGaussianSoftCount gaussianSoftCount coordinateAverage
  rw [integral_div, integral_finsetSum]
  · calc
      _ ≤ (∑ _i : ι, h / sqrt (2 * v)) / Fintype.card ι := by
        apply div_le_div_of_nonneg_right _ hn.le
        apply Finset.sum_le_sum
        intro i _
        simpa using! integral_gaussianSoftIndicator_affine_le
          ((EuclideanSpace.proj i).comp C) (m i) hv (hvar i) hh
      _ = _ := by simp [hn.ne']
  · intro i _
    simpa using! integrable_gaussianSoftIndicator_affine ((EuclideanSpace.proj i).comp C) (m i) h

/-- Fraction of coordinates of absolute value at most `h`. -/
def smallCoordinateFraction (h : ℝ) (z : EuclideanSpace ℝ ι) : ℝ := by
  classical
  exact ((Finset.univ.filter (fun i => |z i| ≤ h)).card : ℝ) / Fintype.card ι

theorem smallCoordinateFraction_le_softCount {h : ℝ} (hh : 0 < h)
    (z : EuclideanSpace ℝ ι) :
    smallCoordinateFraction h z ≤ exp 1 * gaussianSoftCount h z := by
  classical
  have hsum : ((Finset.univ.filter (fun i => |z i| ≤ h)).card : ℝ) ≤
      ∑ i, exp 1 * gaussianSoftIndicator h (z i) := by
    calc
      _ = ∑ i ∈ Finset.univ.filter (fun i => |z i| ≤ h), (1 : ℝ) := by simp
      _ ≤ ∑ i ∈ Finset.univ.filter (fun i => |z i| ≤ h), exp 1 * gaussianSoftIndicator h (z i) := by
        apply Finset.sum_le_sum
        intro i hi
        have hi' := (Finset.mem_filter.mp hi).2
        calc
          (1 : ℝ) = exp 1 * exp (-1) := by rw [← exp_add]; norm_num
          _ ≤ _ := mul_le_mul_of_nonneg_left (gaussianSoftIndicator_ge_of_abs_le hh hi') (exp_pos _).le
      _ ≤ _ := Finset.sum_le_sum_of_subset_of_nonneg (Finset.filter_subset _ _)
        (fun i _ _ => mul_nonneg (exp_pos _).le (gaussianSoftIndicator_nonneg _ _))
  unfold smallCoordinateFraction gaussianSoftCount coordinateAverage
  rw [← Finset.mul_sum] at hsum
  calc
    _ ≤ (exp 1 * ∑ i, gaussianSoftIndicator h (z i)) / Fintype.card ι := by
      exact div_le_div_of_nonneg_right hsum (by positivity)
    _ = _ := by ring

/-- Exponential control of an actual small-coordinate count for a correlated
affine Gaussian vector, uniform over its mean. -/
theorem affineGaussian_smallCoordinateFraction_tail [Nonempty ι]
    {h v B : ℝ} (hh : 0 < h) (hv : 0 < v) (hB : 0 < B)
    (m : EuclideanSpace ℝ ι) (C : E →L[ℝ] EuclideanSpace ℝ ι)
    (hC : ‖C‖ ≤ B) (hvar : ∀ i, v ≤ ‖(EuclideanSpace.proj i).comp C‖ ^ 2)
    {u : ℝ} (hu : 0 ≤ u) :
    (stdGaussian E).real {x | exp 1 * (h / sqrt (2 * v) + u) ≤
      smallCoordinateFraction h (m + C x)} ≤
      exp (-(u ^ 2 * h ^ 2 * Fintype.card ι) / (2 * π ^ 2 * B ^ 2)) := by
  have hmean := integral_affineGaussianSoftCount_le hh hv m C hvar
  calc
    _ ≤ (stdGaussian E).real {x | u ≤ affineGaussianSoftCount h m C x -
        ∫ y, affineGaussianSoftCount h m C y ∂stdGaussian E} := by
      apply measureReal_mono (μ := stdGaussian E) ?_ (by finiteness)
      intro x hx
      have hsoft := smallCoordinateFraction_le_softCount hh (m + C x)
      have he : 0 < exp (1 : ℝ) := exp_pos _
      have hx' : h / sqrt (2 * v) + u ≤ affineGaussianSoftCount h m C x := by
        exact (mul_le_mul_iff_right₀ he).mp (hx.trans hsoft)
      change u ≤ _
      linarith
    _ ≤ _ := affineGaussianSoftCount_upper_tail hh hB m C hC hu

theorem integral_gaussianSoftIndicator_affine_le_one (D : StrongDual ℝ E) (m h : ℝ) :
    (∫ x, gaussianSoftIndicator h (m + D x) ∂stdGaussian E) ≤ 1 := by
  calc
    _ ≤ ∫ _x : E, (1 : ℝ) ∂stdGaussian E :=
      integral_mono (integrable_gaussianSoftIndicator_affine D m h) (integrable_const _)
        (fun x => gaussianSoftIndicator_le_one _ _)
    _ = _ := by simp

/-- The same expectation bound with an explicit allowance for coordinates whose
variance has not been bounded below. -/
theorem integral_affineGaussianSoftCount_le_on [Nonempty ι] [DecidableEq ι]
    {h v : ℝ} (hh : 0 < h) (hv : 0 < v) (m : EuclideanSpace ℝ ι)
    (C : E →L[ℝ] EuclideanSpace ℝ ι) (S : Finset ι)
    (hvar : ∀ i ∈ S, v ≤ ‖(EuclideanSpace.proj i).comp C‖ ^ 2) :
    (∫ x, affineGaussianSoftCount h m C x ∂stdGaussian E) ≤
      h / sqrt (2 * v) + (Sᶜ.card : ℝ) / Fintype.card ι := by
  have hn : (0 : ℝ) < Fintype.card ι := by exact_mod_cast Fintype.card_pos
  let q : ι → ℝ := fun i => ∫ x, gaussianSoftIndicator h (m i + (C x) i) ∂stdGaussian E
  have hgood : (∑ i ∈ S, q i) ≤ (S.card : ℝ) * (h / sqrt (2 * v)) := by
    calc
      _ ≤ ∑ _i ∈ S, h / sqrt (2 * v) := by
        apply Finset.sum_le_sum
        intro i hi
        simpa only [q, ContinuousLinearMap.comp_apply, EuclideanSpace.coe_proj] using!
          integral_gaussianSoftIndicator_affine_le ((EuclideanSpace.proj i).comp C)
            (m i) hv (hvar i hi) hh
      _ = _ := by simp
  have hbad : (∑ i ∈ Sᶜ, q i) ≤ (Sᶜ.card : ℝ) := by
    calc
      _ ≤ ∑ _i ∈ Sᶜ, (1 : ℝ) := by
        apply Finset.sum_le_sum
        intro i _
        simpa only [q, ContinuousLinearMap.comp_apply, EuclideanSpace.coe_proj] using!
          integral_gaussianSoftIndicator_affine_le_one ((EuclideanSpace.proj i).comp C) (m i) h
      _ = _ := by simp
  have hcard : (S.card : ℝ) ≤ Fintype.card ι := by exact_mod_cast Finset.card_le_univ S
  have heq : (∫ x, affineGaussianSoftCount h m C x ∂stdGaussian E) =
      (∑ i, q i) / Fintype.card ι := by
    unfold affineGaussianSoftCount gaussianSoftCount coordinateAverage
    rw [integral_div, integral_finsetSum]
    · rfl
    · intro i _
      simpa using! integrable_gaussianSoftIndicator_affine ((EuclideanSpace.proj i).comp C) (m i) h
  rw [heq, ← Finset.sum_add_sum_compl S q]
  calc
    _ ≤ ((S.card : ℝ) * (h / sqrt (2 * v)) + Sᶜ.card) / Fintype.card ι := by
      exact div_le_div_of_nonneg_right (add_le_add hgood hbad) hn.le
    _ ≤ ((Fintype.card ι : ℝ) * (h / sqrt (2 * v)) + Sᶜ.card) / Fintype.card ι := by
      gcongr
    _ = _ := by field_simp

/-- Correlated Gaussian small-coordinate counts allowing a specified exceptional
set of output coordinates. Only the coordinates in `S` need positive variance. -/
theorem affineGaussian_smallCoordinateFraction_tail_on [Nonempty ι] [DecidableEq ι]
    {h v B : ℝ} (hh : 0 < h) (hv : 0 < v) (hB : 0 < B)
    (m : EuclideanSpace ℝ ι) (C : E →L[ℝ] EuclideanSpace ℝ ι)
    (hC : ‖C‖ ≤ B) (S : Finset ι)
    (hvar : ∀ i ∈ S, v ≤ ‖(EuclideanSpace.proj i).comp C‖ ^ 2)
    {u : ℝ} (hu : 0 ≤ u) :
    (stdGaussian E).real {x | exp 1 * (h / sqrt (2 * v) +
      (Sᶜ.card : ℝ) / Fintype.card ι + u) ≤ smallCoordinateFraction h (m + C x)} ≤
      exp (-(u ^ 2 * h ^ 2 * Fintype.card ι) / (2 * π ^ 2 * B ^ 2)) := by
  have hmean := integral_affineGaussianSoftCount_le_on hh hv m C S hvar
  calc
    _ ≤ (stdGaussian E).real {x | u ≤ affineGaussianSoftCount h m C x -
        ∫ y, affineGaussianSoftCount h m C y ∂stdGaussian E} := by
      apply measureReal_mono (μ := stdGaussian E) ?_ (by finiteness)
      intro x hx
      have hsoft := smallCoordinateFraction_le_softCount hh (m + C x)
      have he : 0 < exp (1 : ℝ) := exp_pos _
      have hx' : h / sqrt (2 * v) + (Sᶜ.card : ℝ) / Fintype.card ι + u ≤
          affineGaussianSoftCount h m C x :=
        (mul_le_mul_iff_right₀ he).mp (hx.trans hsoft)
      change u ≤ _
      linarith
    _ ≤ _ := affineGaussianSoftCount_upper_tail hh hB m C hC hu

/-- Covariance-scale form of the count estimate. For `z = m + Cg`, the squared
operator norm of `C` is the operator norm of the covariance. -/
theorem affineGaussian_smallCoordinateFraction_tail_covariance [Nonempty ι] [DecidableEq ι]
    {h v κ : ℝ} (hh : 0 < h) (hv : 0 < v) (hκ : 0 < κ)
    (m : EuclideanSpace ℝ ι) (C : E →L[ℝ] EuclideanSpace ℝ ι)
    (hC : ‖C‖ ^ 2 ≤ κ) (S : Finset ι)
    (hvar : ∀ i ∈ S, v ≤ ‖(EuclideanSpace.proj i).comp C‖ ^ 2)
    {u : ℝ} (hu : 0 ≤ u) :
    (stdGaussian E).real {x | exp 1 * (h / sqrt (2 * v) +
      (Sᶜ.card : ℝ) / Fintype.card ι + u) ≤ smallCoordinateFraction h (m + C x)} ≤
      exp (-(u ^ 2 * h ^ 2 * Fintype.card ι) / (2 * π ^ 2 * κ)) := by
  have hCs : ‖C‖ ≤ sqrt κ := (le_sqrt (norm_nonneg _) hκ.le).2 hC
  simpa only [sq_sqrt hκ.le] using
    affineGaussian_smallCoordinateFraction_tail_on hh hv (sqrt_pos.mpr hκ) m C hCs S hvar hu

end Paulsen
