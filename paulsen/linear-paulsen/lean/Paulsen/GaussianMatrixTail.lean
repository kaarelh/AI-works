import Paulsen.GaussianMatrixMoments
import Mathlib.Data.Finset.Max

/-!
# Operator norm bounds from Gaussian trace moments
-/

open MeasureTheory ProbabilityTheory Unitary
open scoped BigOperators ProbabilityTheory NNReal

noncomputable section

namespace Paulsen

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- Coordinatewise diagonal action in a real symmetric matrix's eigenbasis. -/
theorem eigenbasis_repr_toEuclideanLin (X : Matrix ι ι ℝ) (hX : X.IsHermitian)
    (x : EuclideanSpace ℝ ι) (i : ι) :
    hX.eigenvectorBasis.repr (Matrix.toEuclideanLin X x) i =
      hX.eigenvalues i * hX.eigenvectorBasis.repr x i := by
  rw [hX.eigenvectorBasis.repr_apply_apply,
    ← (Matrix.isSymmetric_toEuclideanLin_iff.mpr hX) (hX.eigenvectorBasis i) x,
    toEuclideanLin_eigenvector X hX, real_inner_smul_left,
    ← hX.eigenvectorBasis.repr_apply_apply]

/-- A bound on all absolute eigenvalues bounds the Euclidean operator norm. -/
theorem euclidean_operator_norm_le_of_eigenvalues (X : Matrix ι ι ℝ)
    (hX : X.IsHermitian) (B : ℝ) (hB : 0 ≤ B)
    (heigen : ∀ i, |hX.eigenvalues i| ≤ B) :
    ‖(Matrix.toEuclideanLin X).toContinuousLinearMap‖ ≤ B := by
  apply ContinuousLinearMap.opNorm_le_bound _ hB
  intro x
  apply (sq_le_sq₀ (norm_nonneg _) (mul_nonneg hB (norm_nonneg _))).1
  change ‖Matrix.toEuclideanLin X x‖ ^ 2 ≤ (B * ‖x‖) ^ 2
  calc
    _ = ∑ i, (hX.eigenvalues i * hX.eigenvectorBasis.repr x i) ^ 2 := by
      rw [← hX.eigenvectorBasis.repr.norm_map (Matrix.toEuclideanLin X x),
        EuclideanSpace.real_norm_sq_eq]
      simp only [eigenbasis_repr_toEuclideanLin]
    _ ≤ ∑ i, B ^ 2 * (hX.eigenvectorBasis.repr x i) ^ 2 := by
      apply Finset.sum_le_sum
      intro i hi
      rw [mul_pow]
      apply mul_le_mul_of_nonneg_right _ (sq_nonneg _)
      simpa only [sq_abs] using (sq_le_sq₀ (abs_nonneg _) hB).2 (heigen i)
    _ = _ := by
      rw [← Finset.mul_sum, ← EuclideanSpace.real_norm_sq_eq,
        hX.eigenvectorBasis.repr.norm_map, mul_pow]

/-- The trace of a symmetric power is the sum of powers of its eigenvalues. -/
theorem trace_pow_eq_sum_eigenvalues (X : Matrix ι ι ℝ) (hX : X.IsHermitian) (m : ℕ) :
    (X ^ m).trace = ∑ i, hX.eigenvalues i ^ m := by
  have hspec : X = conjStarAlgAut ℝ (Matrix ι ι ℝ) hX.eigenvectorUnitary
      (Matrix.diagonal hX.eigenvalues) := by
    simpa only [Function.comp_def, RCLike.ofReal_real_eq_id, id_eq] using hX.spectral_theorem
  conv_lhs => rw [hspec]
  rw [← map_pow, trace_conjStarAlgAut, Matrix.diagonal_pow, Matrix.trace_diagonal]
  rfl

/-- A positive even trace moment dominates the corresponding operator-norm
moment, including the zero-dimensional matrix space. -/
theorem euclidean_operator_norm_even_pow_le_trace (X : Matrix ι ι ℝ)
    (hX : X.IsHermitian) (p : ℕ) (hp : 0 < p) :
    ‖(Matrix.toEuclideanLin X).toContinuousLinearMap‖ ^ (2 * p) ≤
      (X ^ (2 * p)).trace := by
  cases isEmpty_or_nonempty ι with
  | inl hi =>
    letI := hi
    have hzero : (Matrix.toEuclideanLin X).toContinuousLinearMap = 0 := by
      ext x i
      exact isEmptyElim i
    simp [hzero, Matrix.trace, Nat.ne_of_gt hp]
  | inr hi =>
    letI := hi
    obtain ⟨i, hi, hmax⟩ := Finset.exists_max_image Finset.univ
      (fun i => |hX.eigenvalues i|) Finset.univ_nonempty
    calc
      _ ≤ |hX.eigenvalues i| ^ (2 * p) :=
        pow_le_pow_left₀ (norm_nonneg _)
          (euclidean_operator_norm_le_of_eigenvalues X hX _ (abs_nonneg _)
            (fun j => hmax j (Finset.mem_univ j))) _
      _ = hX.eigenvalues i ^ (2 * p) := (even_two_mul p).pow_abs _
      _ ≤ ∑ j, hX.eigenvalues j ^ (2 * p) :=
        Finset.single_le_sum (fun j _ => (even_two_mul p).pow_nonneg _) (Finset.mem_univ i)
      _ = _ := (trace_pow_eq_sum_eigenvalues X hX _).symm

/-- Nonnegativity of every even trace power of a symmetric matrix. -/
theorem trace_even_pow_nonneg (X : Matrix ι ι ℝ) (hX : X.IsHermitian) (p : ℕ) :
    0 ≤ (X ^ (2 * p)).trace := by
  rw [trace_pow_eq_sum_eigenvalues X hX]
  exact Finset.sum_nonneg (fun i _ => (even_two_mul p).pow_nonneg _)

variable {τ : Type*} [Fintype τ] [DecidableEq τ]

/-- Operator-norm tail from a genuine Gaussian trace moment bound. -/
theorem gaussianMatrixSeries_operator_norm_tail (A : τ → Matrix ι ι ℝ)
    (hA : ∀ j, (A j).IsHermitian) (v : ℝ) (hv : 0 ≤ v)
    (hvar : (v • (1 : Matrix ι ι ℝ) - ∑ j, A j ^ 2).PosSemidef)
    (p : ℕ) (hp : 0 < p) (u : ℝ) (hu : 0 < u) :
    (Measure.pi fun _ : τ => gaussianReal 0 1).real
      {x : τ → ℝ | u ≤ ‖(Matrix.toEuclideanLin (gaussianMatrixSeries A x)).toContinuousLinearMap‖} ≤
      (Fintype.card ι : ℝ) * (2 * (p : ℝ) * v) ^ p / u ^ (2 * p) := by
  have hsubset :
      {x : τ → ℝ | u ≤ ‖(Matrix.toEuclideanLin (gaussianMatrixSeries A x)).toContinuousLinearMap‖} ⊆
      {x : τ → ℝ | u ^ (2 * p) ≤ (gaussianMatrixSeries A x ^ (2 * p)).trace} := by
    intro x hx
    exact (pow_le_pow_left₀ hu.le hx _).trans
      (euclidean_operator_norm_even_pow_le_trace _ (isHermitian_gaussianMatrixSeries A hA x) p hp)
  have hMarkov := mul_meas_ge_le_integral_of_nonneg
    (μ := Measure.pi fun _ : τ => gaussianReal 0 1)
    (f := fun x : τ → ℝ => (gaussianMatrixSeries A x ^ (2 * p)).trace)
    (Filter.Eventually.of_forall (fun x =>
      trace_even_pow_nonneg _ (isHermitian_gaussianMatrixSeries A hA x) p))
    (integrable_trace_gaussianMatrixSeries_pow A (2 * p)) (u ^ (2 * p))
  apply (measureReal_mono hsubset).trans
  apply (le_div_iff₀ (pow_pos hu _)).2
  rw [mul_comm]
  exact hMarkov.trans (integral_trace_gaussianMatrixSeries_even_bound_simple A hA v hv hvar p)

/-- A power majorant for a nonnegative scalar, avoiding any moment interpolation. -/
theorem le_threshold_add_pow_div (a u : ℝ) (ha : 0 ≤ a) (hu : 0 < u)
    (m : ℕ) (hm : 0 < m) : a ≤ u + a ^ m / u ^ (m - 1) := by
  rcases le_total a u with hau | hua
  · exact hau.trans (le_add_of_nonneg_right (div_nonneg (pow_nonneg ha _) (pow_pos hu _).le))
  · have hp : u ^ (m - 1) ≤ a ^ (m - 1) := pow_le_pow_left₀ hu.le hua _
    have hmul := mul_le_mul_of_nonneg_left hp ha
    have heq : a * a ^ (m - 1) = a ^ m := by
      rw [← pow_succ', Nat.sub_add_cancel hm]
    rw [heq] at hmul
    have habound : a ≤ a ^ m / u ^ (m - 1) := (le_div_iff₀ (pow_pos hu _)).2 hmul
    linarith

omit [DecidableEq τ] in
theorem continuous_gaussianMatrixSeries_operator_norm (A : τ → Matrix ι ι ℝ) :
    Continuous (fun x : τ → ℝ =>
      ‖(Matrix.toEuclideanLin (gaussianMatrixSeries A x)).toContinuousLinearMap‖) := by
  have hfun : (fun x : τ → ℝ =>
      ‖(Matrix.toEuclideanLin (gaussianMatrixSeries A x)).toContinuousLinearMap‖) =
      fun x : τ → ℝ => ‖∑ j, x j • (Matrix.toEuclideanLin (A j)).toContinuousLinearMap‖ := by
    ext x
    simp only [gaussianMatrixSeries, map_sum, map_smul]
  rw [hfun]
  fun_prop

/-- Expected operator norm from any positive trace moment and a threshold.
This suffices for the logarithmic matrix-series estimate without Jensen. -/
theorem gaussianMatrixSeries_expected_operator_norm_le_threshold
    (A : τ → Matrix ι ι ℝ) (hA : ∀ j, (A j).IsHermitian) (v : ℝ) (hv : 0 ≤ v)
    (hvar : (v • (1 : Matrix ι ι ℝ) - ∑ j, A j ^ 2).PosSemidef)
    (p : ℕ) (hp : 0 < p) (u : ℝ) (hu : 0 < u) :
    (∫ x : τ → ℝ,
      ‖(Matrix.toEuclideanLin (gaussianMatrixSeries A x)).toContinuousLinearMap‖
      ∂(Measure.pi fun _ : τ => gaussianReal 0 1)) ≤
      u + (Fintype.card ι : ℝ) * (2 * (p : ℝ) * v) ^ p / u ^ (2 * p - 1) := by
  let μ : Measure (τ → ℝ) := Measure.pi fun _ : τ => gaussianReal 0 1
  let f := fun x : τ → ℝ =>
    ‖(Matrix.toEuclideanLin (gaussianMatrixSeries A x)).toContinuousLinearMap‖
  let g := fun x : τ → ℝ => u + (gaussianMatrixSeries A x ^ (2 * p)).trace / u ^ (2 * p - 1)
  have hfg (x : τ → ℝ) : f x ≤ g x := by
    exact (le_threshold_add_pow_div _ u (norm_nonneg _) hu (2 * p) (by omega)).trans
      (add_le_add_right (div_le_div_of_nonneg_right
        (euclidean_operator_norm_even_pow_le_trace _ (isHermitian_gaussianMatrixSeries A hA x) p hp)
        (pow_pos hu _).le) u)
  have hg : Integrable g μ := (integrable_const u).add
    ((integrable_trace_gaussianMatrixSeries_pow A (2 * p)).div_const _)
  have hf : Integrable f μ := hg.mono'
    (continuous_gaussianMatrixSeries_operator_norm A).aestronglyMeasurable
    (Filter.Eventually.of_forall (fun x => by simpa only [f, Real.norm_eq_abs, abs_of_nonneg (norm_nonneg _)] using hfg x))
  have hb := integral_mono hf hg hfg
  change (∫ x, f x ∂μ) ≤ _
  calc
    _ ≤ ∫ x, g x ∂μ := hb
    _ = u + (∫ x : τ → ℝ, (gaussianMatrixSeries A x ^ (2 * p)).trace ∂μ) /
        u ^ (2 * p - 1) := by
      rw [integral_add (integrable_const u)
        ((integrable_trace_gaussianMatrixSeries_pow A (2 * p)).div_const _),
        integral_div]
      simp [μ]
    _ ≤ _ := add_le_add_right (div_le_div_of_nonneg_right
      (integral_trace_gaussianMatrixSeries_even_bound_simple A hA v hv hvar p)
      (pow_pos hu _).le) u

/-- The arithmetic conversion from trace moments to exponential decay. -/
theorem gaussian_matrix_moment_ratio_le_exp (p : ℕ) (v u : ℝ)
    (hv : 0 ≤ v) (hu : 0 < u)
    (hu2 : 2 * Real.exp 1 * (p : ℝ) * v ≤ u ^ 2) :
    (2 * (p : ℝ) * v) ^ p / u ^ (2 * p) ≤ Real.exp (-(p : ℝ)) := by
  have hbase : (2 * (p : ℝ) * v) * Real.exp 1 ≤ u ^ 2 := by nlinarith [hu2]
  have hpow := pow_le_pow_left₀ (by positivity : 0 ≤ (2 * (p : ℝ) * v) * Real.exp 1) hbase p
  rw [mul_pow, ← Real.exp_nat_mul, mul_one, ← pow_mul] at hpow
  apply (div_le_iff₀ (pow_pos hu _)).2
  calc
    _ = Real.exp (-(p : ℝ)) * ((2 * (p : ℝ) * v) ^ p * Real.exp (p : ℝ)) := by
      rw [mul_left_comm, ← Real.exp_add]
      simp
    _ ≤ _ := mul_le_mul_of_nonneg_left hpow (Real.exp_pos _).le

/-- The standard exponential tail at the threshold √(2 e p v), or any larger
positive threshold. -/
theorem gaussianMatrixSeries_operator_norm_tail_exp
    (A : τ → Matrix ι ι ℝ) (hA : ∀ j, (A j).IsHermitian) (v : ℝ) (hv : 0 ≤ v)
    (hvar : (v • (1 : Matrix ι ι ℝ) - ∑ j, A j ^ 2).PosSemidef)
    (p : ℕ) (hp : 0 < p) (u : ℝ) (hu : 0 < u)
    (hu2 : 2 * Real.exp 1 * (p : ℝ) * v ≤ u ^ 2) :
    (Measure.pi fun _ : τ => gaussianReal 0 1).real
      {x : τ → ℝ | u ≤ ‖(Matrix.toEuclideanLin (gaussianMatrixSeries A x)).toContinuousLinearMap‖} ≤
      (Fintype.card ι : ℝ) * Real.exp (-(p : ℝ)) := by
  refine (gaussianMatrixSeries_operator_norm_tail A hA v hv hvar p hp u hu).trans ?_
  rw [mul_div_assoc]
  exact mul_le_mul_of_nonneg_left (gaussian_matrix_moment_ratio_le_exp p v u hv hu hu2)
    (Nat.cast_nonneg _)

/-- With p at least log(matrix dimension), the expected norm is at most twice
the threshold √(2 e p v). All Gaussian and matrix estimates are proved above. -/
theorem gaussianMatrixSeries_expected_operator_norm_le
    (A : τ → Matrix ι ι ℝ) (hA : ∀ j, (A j).IsHermitian) (v : ℝ) (hv : 0 ≤ v)
    (hvar : (v • (1 : Matrix ι ι ℝ) - ∑ j, A j ^ 2).PosSemidef)
    (p : ℕ) (hp : 0 < p) (hlog : Real.log (Fintype.card ι : ℝ) ≤ (p : ℝ))
    (u : ℝ) (hu : 0 < u) (hu2 : 2 * Real.exp 1 * (p : ℝ) * v ≤ u ^ 2) :
    (∫ x : τ → ℝ,
      ‖(Matrix.toEuclideanLin (gaussianMatrixSeries A x)).toContinuousLinearMap‖
      ∂(Measure.pi fun _ : τ => gaussianReal 0 1)) ≤ 2 * u := by
  have hratio : (Fintype.card ι : ℝ) * (2 * (p : ℝ) * v) ^ p / u ^ (2 * p) ≤ 1 := by
    calc
      _ = (Fintype.card ι : ℝ) * ((2 * (p : ℝ) * v) ^ p / u ^ (2 * p)) := by ring
      _ ≤ (Fintype.card ι : ℝ) * Real.exp (-(p : ℝ)) :=
        mul_le_mul_of_nonneg_left (gaussian_matrix_moment_ratio_le_exp p v u hv hu hu2)
          (Nat.cast_nonneg _)
      _ ≤ Real.exp (p : ℝ) * Real.exp (-(p : ℝ)) :=
        mul_le_mul_of_nonneg_right (Real.le_exp_of_log_le hlog) (Real.exp_pos _).le
      _ = 1 := by rw [← Real.exp_add]; simp
  have hnum : (Fintype.card ι : ℝ) * (2 * (p : ℝ) * v) ^ p ≤ u ^ (2 * p) := by
    have h := (div_le_iff₀ (pow_pos hu (2 * p))).1 hratio
    simpa only [one_mul] using h
  have hdiv : (Fintype.card ι : ℝ) * (2 * (p : ℝ) * v) ^ p / u ^ (2 * p - 1) ≤ u := by
    apply (div_le_iff₀ (pow_pos hu _)).2
    rw [← pow_succ', Nat.sub_add_cancel (by omega : 1 ≤ 2 * p)]
    exact hnum
  have h := gaussianMatrixSeries_expected_operator_norm_le_threshold A hA v hv hvar p hp u hu
  linarith

/-- An explicit logarithmic expectation bound, obtained by choosing the trace
moment order. The constant is independent of the number of Gaussian variables. -/
theorem gaussianMatrixSeries_expected_operator_norm_log_bound [Nonempty ι]
    (A : τ → Matrix ι ι ℝ) (hA : ∀ j, (A j).IsHermitian) (v : ℝ) (hv : 0 < v)
    (hvar : (v • (1 : Matrix ι ι ℝ) - ∑ j, A j ^ 2).PosSemidef) :
    (∫ x : τ → ℝ,
      ‖(Matrix.toEuclideanLin (gaussianMatrixSeries A x)).toContinuousLinearMap‖
      ∂(Measure.pi fun _ : τ => gaussianReal 0 1)) ≤
      2 * Real.sqrt (2 * Real.exp 1 * v * (Real.log (Fintype.card ι : ℝ) + 2)) := by
  have hr : (1 : ℝ) ≤ (Fintype.card ι : ℝ) := by exact_mod_cast Fintype.card_pos
  have hlog : 0 ≤ Real.log (Fintype.card ι : ℝ) := Real.log_nonneg hr
  let p : ℕ := ⌈Real.log (Fintype.card ι : ℝ)⌉₊ + 1
  have hp : 0 < p := Nat.succ_pos _
  have hlogp : Real.log (Fintype.card ι : ℝ) ≤ (p : ℝ) := by
    have hceil := Nat.le_ceil (Real.log (Fintype.card ι : ℝ))
    simp only [p, Nat.cast_add, Nat.cast_one]
    linarith
  have hple : (p : ℝ) ≤ Real.log (Fintype.card ι : ℝ) + 2 := by
    have hceil := Nat.ceil_lt_add_one hlog
    simp only [p, Nat.cast_add, Nat.cast_one]
    linarith
  have harg : 0 < 2 * Real.exp 1 * v * (Real.log (Fintype.card ι : ℝ) + 2) := by positivity
  apply gaussianMatrixSeries_expected_operator_norm_le A hA v hv.le hvar p hp hlogp _
    (Real.sqrt_pos.2 harg)
  rw [Real.sq_sqrt harg.le]
  nlinarith [mul_le_mul_of_nonneg_left hple (by positivity : 0 ≤ 2 * Real.exp 1 * v)]

end Paulsen
