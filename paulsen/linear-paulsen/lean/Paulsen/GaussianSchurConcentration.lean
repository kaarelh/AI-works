import Paulsen.GaussianSchurSquare
import Mathlib.Analysis.Convex.Mul

/-!
# Expected operator concentration of Gaussian squared-entry matrices
-/

namespace Paulsen
open Matrix MeasureTheory ProbabilityTheory
open scoped BigOperators ProbabilityTheory Matrix.Norms.Elementwise
noncomputable section

local instance {n : ℕ} : ContinuousENorm (Matrix (Fin n) (Fin n) ℝ) :=
  inferInstanceAs (ContinuousENorm (Fin n → Fin n → ℝ))

/-- Integrability of a square root under a finite measure, from integrability. -/
theorem integrable_sqrt_of_nonneg {α : Type*} [MeasurableSpace α]
    (μ : Measure α) [IsFiniteMeasure μ] (f : α → ℝ) (hf : Integrable f μ)
    (hpos : ∀ x, 0 ≤ f x) : Integrable (fun x => Real.sqrt (f x)) μ := by
  apply ((integrable_const (1 : ℝ)).add hf).mono'
    (Real.continuous_sqrt.comp_aestronglyMeasurable hf.aestronglyMeasurable)
  exact ae_of_all _ fun x => by
    rw [Real.norm_eq_abs, abs_of_nonneg (Real.sqrt_nonneg _)]
    change Real.sqrt (f x) ≤ 1 + f x
    have hs := Real.sq_sqrt (hpos x)
    nlinarith [Real.sqrt_nonneg (f x), sq_nonneg (Real.sqrt (f x) - 1)]

/-- Scalar square-root Jensen, proved using convexity of the square. -/
theorem integral_sqrt_le_sqrt_integral {α : Type*} [MeasurableSpace α]
    (μ : Measure α) [IsProbabilityMeasure μ] (f : α → ℝ) (hf : Integrable f μ)
    (hpos : ∀ x, 0 ≤ f x) :
    (∫ x, Real.sqrt (f x) ∂μ) ≤ Real.sqrt (∫ x, f x ∂μ) := by
  have hi := integrable_sqrt_of_nonneg μ f hf hpos
  have hs : Integrable (fun x => Real.sqrt (f x) ^ 2) μ := by
    simpa only [Real.sq_sqrt (hpos _)] using hf
  have hj := (convexOn_pow (𝕜 := ℝ) 2).map_integral_le (by fun_prop)
    isClosed_Ici (ae_of_all _ fun x => Real.sqrt_nonneg (f x)) hi hs
  simp only [Real.sq_sqrt (hpos _)] at hj
  exact Real.le_sqrt_of_sq_le hj

variable {κ : Type*} [Fintype κ] [DecidableEq κ]

/-- The conditional Schur product is the actual Gaussian matrix series. -/
theorem hadamardSeries_eq_linearImage {n : ℕ} (Y : Matrix (Fin n) (Fin n) ℝ)
    (C : Matrix (Fin n × Fin n) κ ℝ) (x : κ → ℝ) :
    gaussianMatrixSeries (hadamardSeriesCoefficients Y C) x =
      Matrix.of (fun i j => Y i j * gaussianMatrixImage C (WithLp.toLp 2 x) i j) := by
  ext i j
  simp only [gaussianMatrixSeries, Matrix.sum_apply, Matrix.smul_apply,
    hadamardSeriesCoefficients, Matrix.of_apply, smul_eq_mul,
    gaussianMatrixImage, frameOfVector, Matrix.toLpLin_apply, Matrix.mulVec, dotProduct,
    Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro s _
  ring

theorem integrable_fixedSchurProduct {n : ℕ} (Y : Matrix (Fin n) (Fin n) ℝ)
    (C : Matrix (Fin n × Fin n) κ ℝ) :
    Integrable (fun g => Matrix.of (fun i j => Y i j * gaussianMatrixImage C g i j))
      (stdGaussian (EuclideanSpace ℝ κ)) := by
  apply Integrable.of_eval
  intro i
  apply Integrable.of_eval
  intro j
  exact ((gaussianCoordinate C (i,j)).integrable_comp IsGaussian.integrable_id).const_mul (Y i j)

/-- Matrix-series estimate transported to standard Euclidean Gaussian measure.
The zero-variance boundary is handled without a positivity assumption on R. -/
theorem fixedSchurProduct_expected_operator_norm_le {n : ℕ} (hn : 0 < n)
    (Y : Matrix (Fin n) (Fin n) ℝ) (C : Matrix (Fin n × Fin n) κ ℝ)
    (hY : Y.IsSymm) (hCs : ∀ s i j, C (i,j) s = C (j,i) s)
    {v R : ℝ} (hv : 0 < v) (hR0 : 0 ≤ R)
    (hC : ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 2 ≤ v)
    (hR : ∀ j, (∑ i, Y i j ^ 2) ≤ R) :
    (∫ g, ‖matrixEuclideanOperator
      (Matrix.of (fun i j => Y i j * gaussianMatrixImage C g i j))‖
      ∂stdGaussian (EuclideanSpace ℝ κ)) ≤
      2 * Real.sqrt (2 * Real.exp 1 * (v * R) * (Real.log (n : ℝ) + 2)) := by
  by_cases hRp : 0 < R
  · have hi := (matrixEuclideanOperator.integrable_comp (integrable_fixedSchurProduct Y C)).norm
    rw [← map_pi_eq_stdGaussian]
    rw [integral_map (by fun_prop) (by rw [map_pi_eq_stdGaussian]; exact hi.aestronglyMeasurable)]
    simp_rw [← hadamardSeries_eq_linearImage, matrixEuclideanOperator_apply]
    exact hadamardSeries_expected_operator_norm_le hn Y C hY hCs hv hRp hC hR
  · have hRz : R = 0 := le_antisymm (le_of_not_gt hRp) hR0
    have hYz : Y = 0 := by
      ext i j
      have hi := (Finset.single_le_sum (fun k _ => sq_nonneg (Y k j)) (Finset.mem_univ i)).trans (hR j)
      rw [hRz] at hi
      change Y i j = 0
      nlinarith [sq_nonneg (Y i j)]
    simp [hYz, hRz]
    rfl

theorem gaussianMatrixImage_symmetric {n : ℕ} (C : Matrix (Fin n × Fin n) κ ℝ)
    (hCs : ∀ s i j, C (i,j) s = C (j,i) s) (g : EuclideanSpace ℝ κ) :
    (gaussianMatrixImage C g).IsSymm := by
  ext i j
  simp only [gaussianMatrixImage, frameOfVector, Matrix.transpose_apply, Matrix.toLpLin_apply,
    Matrix.mulVec, dotProduct]
  simp_rw [hCs]

/-- Conditional product expectation is controlled by the actual maximum row energy. -/
theorem gaussianSchurProduct_conditional_norm_le {n : ℕ} [NeZero n]
    (C : Matrix (Fin n × Fin n) κ ℝ) (hCs : ∀ s i j, C (i,j) s = C (j,i) s)
    {v : ℝ} (hv : 0 < v)
    (hC : ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 2 ≤ v)
    (g : EuclideanSpace ℝ κ) :
    (∫ h, ‖matrixEuclideanOperator (gaussianSchurProduct C g h)‖
      ∂stdGaussian (EuclideanSpace ℝ κ)) ≤
      2 * Real.sqrt (2 * Real.exp 1 * v * (Real.log (n : ℝ) + 2) *
        finiteMaximum (fun i x => rowNormSq (gaussianMatrixImage C x) i) g) := by
  let F := finiteMaximum (fun i x => rowNormSq (gaussianMatrixImage C x) i)
  have hF (i : Fin n) : rowNormSq (gaussianMatrixImage C g) i ≤ F g :=
    Finset.le_sup' (fun i => rowNormSq (gaussianMatrixImage C g) i) (Finset.mem_univ i)
  have hF0 : 0 ≤ F g := (rowNormSq_nonneg _ 0).trans (hF 0)
  have hsym := gaussianMatrixImage_symmetric C hCs g
  have hcol (j : Fin n) : (∑ i, (gaussianMatrixImage C g i j) ^ 2) ≤ F g := by
    simpa only [rowNormSq, hsym.apply] using hF j
  have h := fixedSchurProduct_expected_operator_norm_le (Nat.pos_of_ne_zero (NeZero.ne n))
    (gaussianMatrixImage C g) C hsym hCs hv hF0 hC hcol
  change (∫ h, ‖matrixEuclideanOperator (gaussianSchurProduct C g h)‖
    ∂stdGaussian (EuclideanSpace ℝ κ)) ≤ _ at h
  have he : 2 * Real.exp 1 * (v * F g) * (Real.log (n : ℝ) + 2) =
      2 * Real.exp 1 * v * (Real.log (n : ℝ) + 2) * F g := by ring
  simpa only [he] using h

/-- Expected norm of the independent Schur product, from covariance and row means. -/
theorem gaussianSchurProduct_expected_operator_norm_le {n : ℕ} [NeZero n]
    (C : Matrix (Fin n × Fin n) κ ℝ) (hCs : ∀ s i j, C (i,j) s = C (j,i) s)
    {v R : ℝ} (hv : 0 < v)
    (hC : ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 2 ≤ v)
    (henergy : ∀ i, (∑ j, ∑ s, C (i,j) s ^ 2) ≤ R) :
    (∫ z : EuclideanSpace ℝ κ × EuclideanSpace ℝ κ,
      ‖matrixEuclideanOperator (gaussianSchurProduct C z.1 z.2)‖
      ∂((stdGaussian (EuclideanSpace ℝ κ)).prod (stdGaussian (EuclideanSpace ℝ κ)))) ≤
      2 * Real.sqrt (2 * Real.exp 1 * v * (Real.log (n : ℝ) + 2) *
        (2 * R + 4 * v * Real.log n)) := by
  let F := finiteMaximum (fun i x => rowNormSq (gaussianMatrixImage C x) i)
  let k := 2 * Real.exp 1 * v * (Real.log (n : ℝ) + 2)
  have hlog : 0 ≤ Real.log (n : ℝ) := Real.log_nonneg
    (Nat.one_le_cast.mpr (Nat.pos_of_ne_zero (NeZero.ne n)))
  have hk : 0 ≤ k := by dsimp [k]; positivity
  have hF0 (g : EuclideanSpace ℝ κ) : 0 ≤ F g :=
    (rowNormSq_nonneg (gaussianMatrixImage C g) 0).trans
      (Finset.le_sup' (fun i => rowNormSq (gaussianMatrixImage C g) i) (Finset.mem_univ 0))
  have hF : Integrable F (stdGaussian (EuclideanSpace ℝ κ)) :=
    finiteMaximum_integrable _ _ fun i => (memLp_rowNormSq_gaussianImage C i).integrable (by norm_num)
  have hroot := integrable_sqrt_of_nonneg (stdGaussian (EuclideanSpace ℝ κ))
    (fun g => k * F g) (hF.const_mul k) (fun g => mul_nonneg hk (hF0 g))
  have hpair := integrable_gaussianSchurProduct_operator_norm C
  rw [integral_prod _ hpair]
  calc
    _ ≤ ∫ g, 2 * Real.sqrt (k * F g) ∂stdGaussian (EuclideanSpace ℝ κ) := by
      apply integral_mono hpair.integral_prod_left (hroot.const_mul 2)
      intro g
      exact gaussianSchurProduct_conditional_norm_le C hCs hv hC g
    _ = 2 * ∫ g, Real.sqrt (k * F g) ∂stdGaussian (EuclideanSpace ℝ κ) := integral_const_mul _ _
    _ ≤ 2 * Real.sqrt (∫ g, k * F g ∂stdGaussian (EuclideanSpace ℝ κ)) :=
      mul_le_mul_of_nonneg_left
        (integral_sqrt_le_sqrt_integral _ _ (hF.const_mul k) (fun g => mul_nonneg hk (hF0 g)))
        (by norm_num)
    _ = 2 * Real.sqrt (k * ∫ g, F g ∂stdGaussian (EuclideanSpace ℝ κ)) := by rw [integral_const_mul]
    _ ≤ _ := by
      apply mul_le_mul_of_nonneg_left _ (by norm_num)
      apply Real.sqrt_le_sqrt
      exact mul_le_mul_of_nonneg_left (integral_maximum_gaussianRow_energy_le C v R hv hC henergy) hk

/-- Actual Gaussian squared-entry concentration, with no independent-entry
assumption and no supplied integrability or moment hypotheses. -/
theorem gaussianSchurSquare_expected_operator_norm_le {n : ℕ} [NeZero n]
    (C : Matrix (Fin n × Fin n) κ ℝ) (hCs : ∀ s i j, C (i,j) s = C (j,i) s)
    {v R : ℝ} (hv : 0 < v)
    (hC : ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 2 ≤ v)
    (henergy : ∀ i, (∑ j, ∑ s, C (i,j) s ^ 2) ≤ R) :
    (∫ g, ‖matrixEuclideanOperator
      (gaussianSchurSquare C g - ∫ h, gaussianSchurSquare C h ∂stdGaussian (EuclideanSpace ℝ κ))‖
      ∂stdGaussian (EuclideanSpace ℝ κ)) ≤
      4 * Real.sqrt (2 * Real.exp 1 * v * (Real.log (n : ℝ) + 2) *
        (2 * R + 4 * v * Real.log n)) := by
  calc
    _ ≤ 2 * ∫ z : EuclideanSpace ℝ κ × EuclideanSpace ℝ κ,
        ‖matrixEuclideanOperator (gaussianSchurProduct C z.1 z.2)‖
        ∂((stdGaussian (EuclideanSpace ℝ κ)).prod (stdGaussian (EuclideanSpace ℝ κ))) :=
      integral_gaussianSchurSquare_centered_le C
    _ ≤ 2 * (2 * Real.sqrt (2 * Real.exp 1 * v * (Real.log (n : ℝ) + 2) *
        (2 * R + 4 * v * Real.log n))) :=
      mul_le_mul_of_nonneg_left (gaussianSchurProduct_expected_operator_norm_le C hCs hv hC henergy)
        (by norm_num)
    _ = _ := by ring

/-- Markov converts the expected operator estimate to a failure probability. -/
theorem gaussianSchurSquare_operator_tail {n : ℕ} [NeZero n]
    (C : Matrix (Fin n × Fin n) κ ℝ) (hCs : ∀ s i j, C (i,j) s = C (j,i) s)
    {v R t : ℝ} (hv : 0 < v) (ht : 0 < t)
    (hC : ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 2 ≤ v)
    (henergy : ∀ i, (∑ j, ∑ s, C (i,j) s ^ 2) ≤ R) :
    (stdGaussian (EuclideanSpace ℝ κ)).real {g | t ≤ ‖matrixEuclideanOperator
      (gaussianSchurSquare C g - ∫ h, gaussianSchurSquare C h ∂stdGaussian (EuclideanSpace ℝ κ))‖} ≤
      (4 * Real.sqrt (2 * Real.exp 1 * v * (Real.log (n : ℝ) + 2) *
        (2 * R + 4 * v * Real.log n))) / t := by
  have hi := (matrixEuclideanOperator.integrable_comp
    ((integrable_gaussianSchurSquare C).sub (integrable_const
      (∫ h, gaussianSchurSquare C h ∂stdGaussian (EuclideanSpace ℝ κ))))).norm
  have hm := mul_meas_ge_le_integral_of_nonneg
    (ae_of_all _ fun g => norm_nonneg (matrixEuclideanOperator
      (gaussianSchurSquare C g - ∫ h, gaussianSchurSquare C h ∂stdGaussian (EuclideanSpace ℝ κ)))) hi t
  apply (le_div_iff₀ ht).2
  rw [mul_comm]
  exact hm.trans (gaussianSchurSquare_expected_operator_norm_le C hCs hv hC henergy)

end
end Paulsen
