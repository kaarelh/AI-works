import Paulsen.GaussianLinearImage
import Paulsen.GaussianRowMoments
import Mathlib.Analysis.Convex.Integral

/-!
# Expected maximum Gaussian row energy

A finite-family exponential moment argument bounds the expected maximum without
integrating a tail bound. Applied to positive quadratic forms it gives
`2 R + 4 v log m`, where `R` bounds the mean row energy and `v` bounds its
covariance operator norm. Correlations between rows are unrestricted.
-/

namespace Paulsen
open Matrix MeasureTheory ProbabilityTheory Set
open scoped BigOperators ProbabilityTheory NNReal
noncomputable section

variable {α ι κ : Type*} [MeasurableSpace α]
  [Fintype ι] [Nonempty ι] [Fintype κ] [DecidableEq κ]

def finiteMaximum (f : ι → α → ℝ) (x : α) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (fun i => f i x)

theorem finiteMaximum_integrable (μ : Measure α) (f : ι → α → ℝ)
    (hf : ∀ i, Integrable (f i) μ) : Integrable (finiteMaximum f) μ := by
  have h : Integrable (Finset.univ.sup' Finset.univ_nonempty f) μ := by
    apply Finset.sup'_induction Finset.univ_nonempty f (p := fun F : α → ℝ => Integrable F μ)
    · intro f hf g hg
      exact hf.sup hg
    · intro i _
      exact hf i
  convert h using 1
  funext x
  exact (Finset.sup'_apply Finset.univ_nonempty f x).symm

/-- The finite exponential-moment method, allowing fully dependent variables. -/
theorem integral_finiteMaximum_le_of_exp (μ : Measure α) [IsProbabilityMeasure μ]
    (f : ι → α → ℝ) (hf : ∀ i, Integrable (f i) μ)
    (s M : ℝ) (hs : 0 < s)
    (he : ∀ i, Integrable (fun x => Real.exp (s * f i x)) μ)
    (hb : ∀ i, (∫ x, Real.exp (s * f i x) ∂μ) ≤ Real.exp M) :
    (∫ x, finiteMaximum f x ∂μ) ≤ (Real.log (Fintype.card ι) + M) / s := by
  have hF := finiteMaximum_integrable μ f hf
  have hexp : (fun x => Real.exp (s * finiteMaximum f x)) =
      finiteMaximum (fun i x => Real.exp (s * f i x)) := by
    funext x
    obtain ⟨i, _, hi⟩ := Finset.exists_mem_eq_sup' Finset.univ_nonempty (fun i => f i x)
    apply le_antisymm
    · change Real.exp (s * Finset.univ.sup' _ _) ≤ Finset.univ.sup' _ _
      rw [hi]
      exact Finset.le_sup' (fun i => Real.exp (s * f i x)) (Finset.mem_univ i)
    · apply Finset.sup'_le
      intro j _
      exact Real.exp_le_exp.mpr (mul_le_mul_of_nonneg_left
        (Finset.le_sup' (fun i => f i x) (Finset.mem_univ j)) hs.le)
  have hE : Integrable (fun x => Real.exp (s * finiteMaximum f x)) μ := by
    rw [hexp]
    exact finiteMaximum_integrable μ _ he
  have hj := convexOn_exp.map_integral_le Real.continuous_exp.continuousOn isClosed_univ
    (ae_of_all μ fun _ => mem_univ _) (hF.const_mul s) hE
  rw [integral_const_mul] at hj
  have hsum : (∫ x, Real.exp (s * finiteMaximum f x) ∂μ) ≤
      (Fintype.card ι : ℝ) * Real.exp M := by
    calc
      _ ≤ ∫ x, ∑ i, Real.exp (s * f i x) ∂μ := by
        apply integral_mono hE (integrable_finsetSum _ (fun i _ => he i))
        intro x
        obtain ⟨i, _, hi⟩ := Finset.exists_mem_eq_sup' Finset.univ_nonempty (fun i => f i x)
        change Real.exp (s * Finset.univ.sup' _ _) ≤ _
        rw [hi]
        exact Finset.single_le_sum (fun j _ => (Real.exp_pos (s * f j x)).le) (Finset.mem_univ i)
      _ = ∑ i, ∫ x, Real.exp (s * f i x) ∂μ :=
        integral_finsetSum _ (fun i _ => he i)
      _ ≤ ∑ _i : ι, Real.exp M := Finset.sum_le_sum fun i _ => hb i
      _ = _ := by simp
  have hcard : (0 : ℝ) < Fintype.card ι := Nat.cast_pos.mpr Fintype.card_pos
  have heq : (Fintype.card ι : ℝ) * Real.exp M =
      Real.exp (Real.log (Fintype.card ι) + M) := by
    rw [Real.exp_add, Real.exp_log hcard]
  rw [heq] at hsum
  exact (le_div_iff₀ hs).mpr (by
    simpa only [mul_comm] using Real.exp_le_exp.mp (hj.trans hsum))

/-- A positive Gaussian quadratic form has a simple trace-controlled MGF. -/
theorem integral_exp_positive_quadratic_le (A : Matrix κ κ ℝ)
    (hA : A.PosSemidef) (s : ℝ) (hs : 0 ≤ s)
    (hsmall : ∀ i, 4 * s * hA.isHermitian.eigenvalues i ≤ 1) :
    (∫ g, Real.exp (s * euclideanQuadratic A g)
      ∂stdGaussian (EuclideanSpace ℝ κ)) ≤ Real.exp (2 * s * A.trace) := by
  have hdomain (i : κ) : 0 < 1 - 2 * s * hA.isHermitian.eigenvalues i := by
    linarith [hsmall i]
  have heq : (fun g => Real.exp (s * euclideanQuadratic A g)) =
      fun g => Real.exp (s * A.trace) * Real.exp (s * (euclideanQuadratic A g - A.trace)) := by
    funext g
    rw [← Real.exp_add]
    congr 1
    ring
  rw [heq, integral_const_mul]
  change Real.exp (s * A.trace) * mgf _ _ s ≤ _
  rw [mgf_euclideanQuadratic_stdGaussian A hA.isHermitian s hdomain]
  have hterm (i : κ) : Real.exp (-s * hA.isHermitian.eigenvalues i) /
      Real.sqrt (1 - 2 * s * hA.isHermitian.eigenvalues i) ≤
        Real.exp (s * hA.isHermitian.eigenvalues i) := by
    have hb := mgf_centered_square_le_exp (1 : ℝ≥0) (s * hA.isHermitian.eigenvalues i)
      (by simp only [NNReal.coe_one, mul_one]; nlinarith [hsmall i])
    rw [mgf_centered_square_gaussianReal (1 : ℝ≥0) _ (by
      simpa only [NNReal.coe_one, mul_one, mul_assoc] using hdomain i)] at hb
    simp only [NNReal.coe_one, mul_one, one_pow, mul_pow, ← mul_assoc] at hb
    simp only [neg_mul]
    apply hb.trans (Real.exp_le_exp.mpr ?_)
    have hn := mul_nonneg hs (hA.eigenvalues_nonneg i)
    have hm := mul_le_mul_of_nonneg_right (hsmall i) hn
    nlinarith
  calc
    _ ≤ Real.exp (s * A.trace) * ∏ i, Real.exp (s * hA.isHermitian.eigenvalues i) :=
      mul_le_mul_of_nonneg_left (Finset.prod_le_prod
        (fun i _ => div_nonneg (Real.exp_pos _).le (Real.sqrt_nonneg _))
        (fun i _ => hterm i)) (Real.exp_pos _).le
    _ = _ := by
      have htrace : A.trace = ∑ i, hA.isHermitian.eigenvalues i := by
        simpa only [RCLike.ofReal_real_eq_id, id_eq] using hA.isHermitian.trace_eq_sum_eigenvalues
      rw [← Real.exp_sum, ← Finset.mul_sum, ← htrace, ← Real.exp_add]
      congr 1
      ring

theorem integrable_exp_positive_quadratic (A : Matrix κ κ ℝ)
    (hA : A.PosSemidef) (s : ℝ)
    (hsmall : ∀ i, 4 * s * hA.isHermitian.eigenvalues i ≤ 1) :
    Integrable (fun g => Real.exp (s * euclideanQuadratic A g))
      (stdGaussian (EuclideanSpace ℝ κ)) := by
  have h := (integrable_exp_euclideanQuadratic_stdGaussian A hA.isHermitian s
    (fun i => by linarith [hsmall i])).const_mul (Real.exp (s * A.trace))
  convert h using 1
  funext g
  rw [← Real.exp_add]
  congr 1
  ring

/-- Only the covariance scale and mean energy enter the expected maximum. -/
theorem integral_maximum_positive_quadratic_le (A : ι → Matrix κ κ ℝ)
    (hA : ∀ i, (A i).PosSemidef) (v R : ℝ) (hv : 0 < v)
    (hnorm : ∀ i, ‖(Matrix.toEuclideanLin (A i)).toContinuousLinearMap‖ ≤ v)
    (htrace : ∀ i, (A i).trace ≤ R) :
    (∫ g, finiteMaximum (fun i => euclideanQuadratic (A i)) g
      ∂stdGaussian (EuclideanSpace ℝ κ)) ≤
        2 * R + 4 * v * Real.log (Fintype.card ι) := by
  let s := 1 / (4 * v)
  have hs : 0 < s := by dsimp [s]; positivity
  have hsmall (i : ι) (j : κ) : 4 * s * (hA i).isHermitian.eigenvalues j ≤ 1 := by
    have h := (le_abs_self _).trans
      ((abs_eigenvalue_le_euclidean_operator_norm (A i) (hA i).isHermitian j).trans (hnorm i))
    dsimp [s]
    calc
      4 * (1 / (4 * v)) * (hA i).isHermitian.eigenvalues j ≤ 4 * (1 / (4 * v)) * v :=
        mul_le_mul_of_nonneg_left h (by positivity)
      _ = 1 := by field_simp
  have hi (i : ι) : Integrable (euclideanQuadratic (A i)) (stdGaussian (EuclideanSpace ℝ κ)) := by
    have h := ((memLp_centered_euclideanQuadratic_stdGaussian (A i) (hA i).isHermitian).integrable
      (by norm_num)).add (integrable_const (A i).trace)
    apply h.congr
    exact ae_of_all _ fun g => by simp
  have hb := integral_finiteMaximum_le_of_exp (stdGaussian (EuclideanSpace ℝ κ))
    (fun i => euclideanQuadratic (A i)) hi s (2 * s * R) hs
    (fun i => integrable_exp_positive_quadratic (A i) (hA i) s (hsmall i))
    (fun i => (integral_exp_positive_quadratic_le (A i) (hA i) s hs.le (hsmall i)).trans
      (Real.exp_le_exp.mpr (mul_le_mul_of_nonneg_left (htrace i) (by positivity))))
  calc
    _ ≤ (Real.log (Fintype.card ι) + 2 * s * R) / s := hb
    _ = _ := by dsimp [s]; field_simp; ring

variable {υ : Type*} [Fintype υ] [DecidableEq υ]

/-- The maximum expected squared norm of correlated Gaussian linear images. -/
theorem integral_maximum_gaussianImage_norm_sq_le (D : ι → Matrix υ κ ℝ)
    (v R : ℝ) (hv : 0 < v)
    (hnorm : ∀ i, ‖(Matrix.toEuclideanLin (D i)).toContinuousLinearMap‖ ^ 2 ≤ v)
    (henergy : ∀ i, (∑ j, ∑ k, D i j k ^ 2) ≤ R) :
    (∫ g, finiteMaximum (fun i g => ‖Matrix.toEuclideanLin (D i) g‖ ^ 2) g
      ∂stdGaussian (EuclideanSpace ℝ κ)) ≤
        2 * R + 4 * v * Real.log (Fintype.card ι) := by
  have hpsd (i : ι) : ((D i).transpose * D i).PosSemidef := by
    simpa only [Matrix.conjTranspose_eq_transpose_of_trivial] using
      Matrix.posSemidef_conjTranspose_mul_self (D i)
  have hnorm' (i : ι) :
      ‖(Matrix.toEuclideanLin ((D i).transpose * D i)).toContinuousLinearMap‖ ≤ v := by
    calc
      _ ≤ ‖(Matrix.toEuclideanLin (D i).transpose).toContinuousLinearMap‖ *
          ‖(Matrix.toEuclideanLin (D i)).toContinuousLinearMap‖ :=
        euclidean_operator_norm_mul_le _ _
      _ = ‖(Matrix.toEuclideanLin (D i)).toContinuousLinearMap‖ ^ 2 := by
        rw [euclidean_operator_norm_transpose, pow_two]
      _ ≤ v := hnorm i
  have htrace (i : ι) : ((D i).transpose * D i).trace ≤ R := by
    have h : ((D i).transpose * D i).trace = ∑ j, ∑ k, D i j k ^ 2 := by
      simp only [Matrix.trace, Matrix.diag_apply, Matrix.mul_apply,
        Matrix.transpose_apply, ← sq]
      exact Finset.sum_comm
    rw [h]
    exact henergy i
  have heq (i : ι) (g : EuclideanSpace ℝ κ) :
      euclideanQuadratic ((D i).transpose * D i) g =
        ‖Matrix.toEuclideanLin (D i) g‖ ^ 2 := by
    have h := euclideanQuadratic_linear_image (1 : Matrix υ υ ℝ) (D i) g
    simp only [Matrix.mul_one] at h
    rw [← h]
    simp [euclideanQuadratic]
  simpa only [finiteMaximum, heq] using integral_maximum_positive_quadratic_le
    (fun i => (D i).transpose * D i) hpsd v R hv hnorm' htrace

def gaussianRowFactor {n d : ℕ} (C : Matrix (Fin n × Fin d) κ ℝ) (i : Fin n) :
    Matrix (Fin d) κ ℝ := Matrix.of fun j s => C (i,j) s

theorem gaussianRowFactor_norm_le {n d : ℕ}
    (C : Matrix (Fin n × Fin d) κ ℝ) (i : Fin n) :
    ‖(Matrix.toEuclideanLin (gaussianRowFactor C i)).toContinuousLinearMap‖ ≤
      ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ := by
  apply ContinuousLinearMap.opNorm_le_bound _ (norm_nonneg _)
  intro g
  apply le_trans _ ((Matrix.toEuclideanLin C).toContinuousLinearMap.le_opNorm g)
  apply (sq_le_sq₀ (norm_nonneg _) (norm_nonneg _)).mp
  change ‖Matrix.toEuclideanLin (gaussianRowFactor C i) g‖ ^ 2 ≤
    ‖Matrix.toEuclideanLin C g‖ ^ 2
  simp only [EuclideanSpace.real_norm_sq_eq, Fintype.sum_prod_type]
  change (∑ j, (Matrix.toEuclideanLin C g (i,j)) ^ 2) ≤ _
  exact Finset.single_le_sum (fun r _ => Finset.sum_nonneg fun j _ =>
    sq_nonneg (Matrix.toEuclideanLin C g (r,j))) (Finset.mem_univ i)

/-- Expected maximum row energy for one vectorized Gaussian matrix. -/
theorem integral_maximum_gaussianRow_energy_le {n d : ℕ} [NeZero n]
    (C : Matrix (Fin n × Fin d) κ ℝ) (v R : ℝ) (hv : 0 < v)
    (hC : ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 2 ≤ v)
    (henergy : ∀ i, (∑ j, ∑ s, C (i,j) s ^ 2) ≤ R) :
    (∫ g, finiteMaximum
      (fun i g => rowNormSq (frameOfVector (Matrix.toEuclideanLin C g)) i) g
      ∂stdGaussian (EuclideanSpace ℝ κ)) ≤ 2 * R + 4 * v * Real.log n := by
  have hnorm (i : Fin n) :
      ‖(Matrix.toEuclideanLin (gaussianRowFactor C i)).toContinuousLinearMap‖ ^ 2 ≤ v :=
    (pow_le_pow_left₀ (norm_nonneg _) (gaussianRowFactor_norm_le C i) 2).trans hC
  have heq (i : Fin n) (g : EuclideanSpace ℝ κ) :
      ‖Matrix.toEuclideanLin (gaussianRowFactor C i) g‖ ^ 2 =
        rowNormSq (frameOfVector (Matrix.toEuclideanLin C g)) i := by
    rw [EuclideanSpace.real_norm_sq_eq]
    rfl
  simpa only [finiteMaximum, heq, Fintype.card_fin] using
    integral_maximum_gaussianImage_norm_sq_le (gaussianRowFactor C) v R hv hnorm henergy

end
end Paulsen
