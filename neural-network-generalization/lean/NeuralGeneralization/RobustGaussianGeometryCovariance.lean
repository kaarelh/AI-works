import NeuralGeneralization.GaussianCovarianceFactor
import NeuralGeneralization.GaussianFieldCovariance
import Mathlib.Probability.Kernel.Composition.MapComap
import Mathlib.Probability.Distributions.Gaussian.Multivariate
import Mathlib.MeasureTheory.Constructions.BorelSpace.Basic

/-! # Canonical measurable residual Gaussian factors -/
noncomputable section
open MeasureTheory ProbabilityTheory Matrix
open scoped BigOperators MatrixOrder Matrix.Norms.L2Operator
namespace NeuralGeneralization.RobustGaussianGeometry

variable {m q : ℕ}

/-- Coefficient-array presentation of the canonical PSD square root. -/
def covarianceFactor (Q : Fin m → Fin m → ℝ) : Fin m → Fin m → ℝ :=
  fun i j => (CFC.sqrt (Matrix.of Q)) i j

/-- The canonical square root is measurable including singular covariance
matrices. Outside the PSD cone its totalized value is zero. -/
theorem measurable_covarianceFactor : Measurable (covarianceFactor (m := m)) := by
  classical
  let S : Set (Fin m → Fin m → ℝ) := {Q | (Matrix.of Q).PosSemidef}
  have hs : IsClosed S := by
    have heq : S = {Q | (Matrix.of Q).conjTranspose = Matrix.of Q} ∩
        ⋂ x : Fin m → ℝ, {Q | 0 ≤ star x ⬝ᵥ (Matrix.of Q *ᵥ x)} := by
      ext Q
      simp only [S, Set.mem_setOf_eq, Matrix.posSemidef_iff_dotProduct_mulVec,
        Matrix.IsHermitian, Set.mem_inter_iff, Set.mem_iInter]
    rw [heq]
    apply IsClosed.inter
    · exact isClosed_eq (by fun_prop) (by fun_prop)
    · apply isClosed_iInter
      intro x
      exact isClosed_le continuous_const (by
        simp only [dotProduct, Matrix.mulVec]
        fun_prop)
  have hc : ContinuousOn (covarianceFactor (m := m)) S := by
    exact GaussianCovarianceFactor.continuousOn_sqrt
  have hzero : ∀ Q ∉ S, covarianceFactor Q = 0 := by
    intro Q hQ
    have hn : ¬ 0 ≤ Matrix.of Q := by simpa only [S, Set.mem_setOf_eq, Matrix.nonneg_iff_posSemidef] using hQ
    funext i j
    change (CFC.sqrt (Matrix.of Q)) i j = 0
    rw [CFC.sqrt_of_not_nonneg hn]
    rfl
  have heq : covarianceFactor (m := m) = S.piecewise covarianceFactor (fun _ => 0) := by
    funext Q
    by_cases hQ : Q ∈ S
    · simp [hQ]
    · simp [hQ, hzero Q hQ]
  rw [heq]
  exact hc.measurable_piecewise continuous_const.continuousOn hs.measurableSet

/-- Multiplying the canonical factor by its transpose recovers the covariance. -/
theorem covarianceFactor_gram (Q : Fin m → Fin m → ℝ)
    (hQ : (Matrix.of Q).PosSemidef) (i j : Fin m) :
    (∑ k, covarianceFactor Q i k * covarianceFactor Q j k) = Q i j := by
  exact GaussianCovarianceFactor.gram_canonicalFeatures (Matrix.of Q) hQ i j

/-- The random residual is an explicit measurable transformation of a standard
finite product Gaussian, so it defines a genuine parameterized kernel. -/
def residualDraw (Q : Fin m → Fin m → ℝ) (g : Fin m → ℝ) : Fin m → ℝ :=
  fun i => ∑ j, covarianceFactor Q i j * g j

theorem measurable_residualDraw :
    Measurable (fun p : (Fin m → Fin m → ℝ) × (Fin m → ℝ) => residualDraw p.1 p.2) := by
  apply measurable_pi_lambda
  intro i
  apply Finset.measurable_sum
  intro j hj
  exact ((measurable_pi_apply j).comp ((measurable_pi_apply i).comp
    (measurable_covarianceFactor.comp measurable_fst))).mul
      ((measurable_pi_apply j).comp measurable_snd)

/-- A measurable Markov kernel with an explicit Gaussian sampling recipe. -/
def residualKernel : Kernel (Fin m → Fin m → ℝ) (Fin m → ℝ) where
  toFun := fun Q => (Measure.pi (fun _ : Fin m => gaussianReal 0 1)).map (residualDraw Q)
  measurable' := by
    apply Measure.measurable_of_measurable_coe
    intro B hB
    have hdraw (Q : Fin m → Fin m → ℝ) : Measurable (residualDraw Q) :=
      measurable_residualDraw.comp (measurable_const.prodMk measurable_id)
    simp_rw [Measure.map_apply (hdraw _) hB]
    exact measurable_measure_prodMk_left (measurable_residualDraw hB)

instance residualKernel_markov : IsMarkovKernel (residualKernel (m := m)) where
  isProbabilityMeasure _Q :=
    Measure.isProbabilityMeasure_map
      (measurable_residualDraw.comp (measurable_const.prodMk measurable_id)).aemeasurable

/-- The recipe is exactly mathlib's actual centered multivariate Gaussian. -/
theorem residualKernel_toLp (Q : Fin m → Fin m → ℝ) :
    (residualKernel Q).map (WithLp.toLp 2) =
      multivariateGaussian 0 (Matrix.of Q) := by
  change ((Measure.pi (fun _ : Fin m => gaussianReal 0 1)).map (residualDraw Q)).map
    (WithLp.toLp 2) = _
  have hdraw : Measurable (residualDraw Q) :=
    measurable_residualDraw.comp (measurable_const.prodMk measurable_id)
  rw [Measure.map_map (WithLp.measurable_toLp 2 (Fin m → ℝ)) hdraw]
  rw [multivariateGaussian, ← map_pi_eq_stdGaussian,
    Measure.map_map (by fun_prop) (WithLp.measurable_toLp 2 (Fin m → ℝ))]
  congr 1
  funext g
  simp only [Function.comp_apply, zero_add, Matrix.toEuclideanCLM_toLp]
  rfl

/-- In particular its actual coordinate covariances equal the supplied PSD matrix. -/
theorem residualKernel_covariance (Q : Fin m → Fin m → ℝ)
    (hQ : (Matrix.of Q).PosSemidef) (i j : Fin m) :
    cov[fun x => x i, fun x => x j; residualKernel Q] = Q i j := by
  have h := covariance_eval_multivariateGaussian (μ := (0 : EuclideanSpace ℝ (Fin m))) hQ i j
  rw [← residualKernel_toLp Q,
    covariance_map (by fun_prop) (by fun_prop)
      (WithLp.measurable_toLp 2 (Fin m → ℝ)).aemeasurable] at h
  exact h

/-- A Euclidean contraction is also a contraction after transposition. -/
theorem transpose_contraction (D : Matrix (Fin m) (Fin q) ℝ)
    (hD : ∀ v : Fin q → ℝ, ∑ i, (D *ᵥ v) i ^ 2 ≤ ∑ j, v j ^ 2)
    (z : Fin m → ℝ) :
    ∑ j, (D.transpose *ᵥ z) j ^ 2 ≤ ∑ i, z i ^ 2 := by
  let v := D.transpose *ᵥ z
  have hcs := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ z (D *ᵥ v)
  have heq : (∑ i, z i * (D *ᵥ v) i) = ∑ j, v j ^ 2 := by
    change z ⬝ᵥ (D *ᵥ v) = _
    rw [dotProduct_mulVec]
    rw [← Matrix.mulVec_transpose]
    change (D.transpose *ᵥ z) ⬝ᵥ v = _
    simp only [v, dotProduct, pow_two]
  rw [heq] at hcs
  have hz : 0 ≤ ∑ i, z i ^ 2 := Finset.sum_nonneg (fun _ _ => sq_nonneg _)
  have hv : 0 ≤ ∑ j, v j ^ 2 := Finset.sum_nonneg (fun _ _ => sq_nonneg _)
  have hh := mul_le_mul_of_nonneg_left (hD v) hz
  change (∑ j, v j ^ 2) ≤ _
  nlinarith

/-- The residual covariance needed by clipped source sampling is PSD. -/
theorem residualCovariance_posSemidef (D : Matrix (Fin m) (Fin q) ℝ)
    (hD : ∀ v : Fin q → ℝ, ∑ i, (D *ᵥ v) i ^ 2 ≤ ∑ j, v j ^ 2) :
    (1 - D * D.transpose).PosSemidef := by
  apply Matrix.PosSemidef.of_dotProduct_mulVec_nonneg
  · simpa only [Matrix.conjTranspose_eq_transpose_of_trivial] using
      (Matrix.isHermitian_one.sub (Matrix.isHermitian_mul_conjTranspose_self D))
  · intro z
    have h := transpose_contraction D hD z
    have heq : z ⬝ᵥ ((D * D.transpose) *ᵥ z) =
        ∑ j, (D.transpose *ᵥ z) j ^ 2 := by
      rw [← Matrix.mulVec_mulVec, dotProduct_mulVec, ← Matrix.mulVec_transpose]
      simp only [dotProduct, pow_two]
    simp only [star_trivial, Matrix.sub_mulVec, Matrix.one_mulVec, dotProduct_sub, heq]
    simpa only [pow_two, dotProduct] using sub_nonneg.mpr h

/-- Covariance coefficient array used for source-noise completion. -/
def residualCovariance (D : Fin m → Fin q → ℝ) : Fin m → Fin m → ℝ :=
  fun i j => (if i = j then 1 else 0) - ∑ k, D i k * D j k

theorem residualCovariance_eq (D : Fin m → Fin q → ℝ) :
    Matrix.of (residualCovariance D) = 1 - Matrix.of D * (Matrix.of D).transpose := by
  ext i j
  simp [residualCovariance, Matrix.mul_apply, Matrix.one_apply]

theorem measurable_residualCovariance : Measurable (residualCovariance (m := m) (q := q)) := by
  unfold residualCovariance
  fun_prop

/-- A kernel directly parametrized by sampled active coefficients. -/
def sourceResidualKernel : Kernel (Fin m → Fin q → ℝ) (Fin m → ℝ) :=
  residualKernel.comap residualCovariance measurable_residualCovariance

instance sourceResidualKernel_markov : IsMarkovKernel (sourceResidualKernel (m := m) (q := q)) :=
  inferInstanceAs (IsMarkovKernel (residualKernel.comap _ _))

theorem sourceResidualKernel_covariance (D : Fin m → Fin q → ℝ)
    (hD : ∀ v : Fin q → ℝ, ∑ i, (Matrix.of D *ᵥ v) i ^ 2 ≤ ∑ j, v j ^ 2)
    (i j : Fin m) :
    cov[fun x => x i, fun x => x j; sourceResidualKernel D] =
      (if i = j then 1 else 0) - ∑ k, D i k * D j k := by
  exact residualKernel_covariance (residualCovariance D)
    (by rw [residualCovariance_eq]; exact residualCovariance_posSemidef _ hD) i j

/-- The combined linear sampler uses disjoint independent Gaussian coordinates. -/
def completedCoefficients (D : Fin m → Fin q → ℝ) (i : Fin m) : Fin q ⊕ Fin m → ℝ :=
  Sum.elim (D i) (covarianceFactor (residualCovariance D) i)

theorem completedCoefficients_gram (D : Fin m → Fin q → ℝ)
    (hD : ∀ v : Fin q → ℝ, ∑ i, (Matrix.of D *ᵥ v) i ^ 2 ≤ ∑ j, v j ^ 2)
    (i j : Fin m) :
    GaussianAngularPrice.gram (completedCoefficients D) i j = if i = j then 1 else 0 := by
  have hQ : (Matrix.of (residualCovariance D)).PosSemidef := by
    rw [residualCovariance_eq]
    exact residualCovariance_posSemidef _ hD
  unfold GaussianAngularPrice.gram
  simp only [completedCoefficients, Fintype.sum_sum_type, Sum.elim_inl, Sum.elim_inr]
  rw [covarianceFactor_gram _ hQ i j]
  simp only [residualCovariance]
  ring

/-- Exact standard Gaussian law of the completed coefficients. This proves the
marginal law used by reconstruction, rather than merely checking covariance. -/
theorem completedCoefficients_law (D : Fin m → Fin q → ℝ)
    (hD : ∀ v : Fin q → ℝ, ∑ i, (Matrix.of D *ᵥ v) i ^ 2 ≤ ∑ j, v j ^ 2) :
    (Measure.pi (fun _ : Fin q ⊕ Fin m => gaussianReal 0 1)).map
      (FiniteDifferential.fieldLinear (completedCoefficients D)) =
      Measure.pi (fun _ : Fin m => gaussianReal 0 1) := by
  let I : Fin m → Fin m → ℝ := fun i j => if i = j then 1 else 0
  have heq : GaussianFieldTilt.fieldLaw (completedCoefficients D) =
      GaussianFieldTilt.fieldLaw I := by
    apply GaussianFieldCovariance.fieldLaw_eq_of_gram_eq
    intro i j
    rw [completedCoefficients_gram D hD]
    simp [GaussianAngularPrice.gram, I]
  have hi : FiniteDifferential.fieldLinear I = ContinuousLinearMap.id ℝ (Fin m → ℝ) := by
    ext z i
    simp [FiniteDifferential.fieldLinear_apply, I]
  change GaussianFieldTilt.fieldLaw (completedCoefficients D) = _
  rw [heq]
  unfold GaussianFieldTilt.fieldLaw
  rw [hi]
  exact Measure.map_id

/-- The same exact law in the more familiar product-source form: first draw
ζ independently of g, then return Dζ + sqrt(I−DDᵀ)g. -/
theorem completed_product_law (D : Fin m → Fin q → ℝ)
    (hD : ∀ v : Fin q → ℝ, ∑ i, (Matrix.of D *ᵥ v) i ^ 2 ≤ ∑ j, v j ^ 2) :
    ((Measure.pi (fun _ : Fin q => gaussianReal 0 1)).prod
      (Measure.pi (fun _ : Fin m => gaussianReal 0 1))).map
      (fun p => fun i => (∑ j, D i j * p.1 j) + residualDraw (residualCovariance D) p.2 i) =
      Measure.pi (fun _ : Fin m => gaussianReal 0 1) := by
  let e := (MeasurableEquiv.sumPiEquivProdPi (fun _ : Fin q ⊕ Fin m => ℝ)).symm
  have heq : (fun p : (Fin q → ℝ) × (Fin m → ℝ) => fun i =>
      (∑ j, D i j * p.1 j) + residualDraw (residualCovariance D) p.2 i) =
      (FiniteDifferential.fieldLinear (completedCoefficients D)) ∘ e := by
    funext p i
    simp [FiniteDifferential.fieldLinear_apply, completedCoefficients, residualDraw,
      Fintype.sum_sum_type, e, MeasurableEquiv.sumPiEquivProdPi]
  rw [heq, ← Measure.map_map (FiniteDifferential.fieldLinear _).continuous.measurable e.measurable,
    (measurePreserving_sumPiEquivProdPi_symm
      (fun _ : Fin q ⊕ Fin m => gaussianReal 0 1)).map_eq]
  exact completedCoefficients_law D hD


/-- The empirical quadratic bound gives the exact contraction required above,
with the paper's deterministic normalization. -/
theorem normalized_sample_contraction (C : Fin m → Fin q → ℝ)
    (hm : 0 < m) {a : ℝ} (ha : 0 ≤ a)
    (hG : ∀ v : Fin q → ℝ,
      (∑ j, ∑ k, v j * ((∑ i, C i j * C i k) / (m : ℝ)) * v k) ≤
        (1 + a) * ∑ j, v j ^ 2) :
    ∀ v : Fin q → ℝ,
      (∑ i, (Matrix.of (fun i j => C i j / Real.sqrt ((m : ℝ) * (1+a))) *ᵥ v) i ^ 2) ≤
        ∑ j, v j ^ 2 := by
  intro v
  have hmR : (0 : ℝ) < m := by exact_mod_cast hm
  have hden : 0 < (m : ℝ) * (1+a) := by positivity
  have heq : (∑ j, ∑ k, v j * ((∑ i, C i j * C i k) / (m : ℝ)) * v k) =
      (∑ i, (Matrix.of C *ᵥ v) i ^ 2) / (m : ℝ) := by
    let M : Matrix (Fin q) (Fin q) ℝ := (m : ℝ)⁻¹ • ((Matrix.of C).transpose * Matrix.of C)
    have hM : ∀ j k, M j k = (∑ i, C i j * C i k) / (m : ℝ) := by
      intro j k
      simp [M, Matrix.mul_apply, Matrix.smul_apply, div_eq_mul_inv, mul_comm]
    calc
      _ = v ⬝ᵥ (M *ᵥ v) := by
        simp only [dotProduct, Matrix.mulVec, Finset.mul_sum, hM, mul_assoc]
      _ = (m : ℝ)⁻¹ * (v ⬝ᵥ (((Matrix.of C).transpose * Matrix.of C) *ᵥ v)) := by
        simp only [M, Matrix.smul_mulVec, dotProduct_smul, smul_eq_mul]
      _ = _ := by
        rw [← Matrix.mulVec_mulVec, Matrix.dotProduct_transpose_mulVec]
        simp only [dotProduct, pow_two, div_eq_mul_inv, mul_comm]
  have hg := hG v
  rw [heq] at hg
  have hsum : (∑ i, (Matrix.of C *ᵥ v) i ^ 2) ≤
      ((1+a) * ∑ j, v j ^ 2) * (m : ℝ) := (div_le_iff₀ hmR).mp hg
  have hnorm : ∀ i, (Matrix.of (fun i j => C i j / Real.sqrt ((m : ℝ)*(1+a))) *ᵥ v) i =
      (Matrix.of C *ᵥ v) i / Real.sqrt ((m : ℝ)*(1+a)) := by
    intro i
    simp only [Matrix.mulVec, dotProduct, Matrix.of_apply, div_mul_eq_mul_div, Finset.sum_div]
  simp_rw [hnorm, div_pow]
  rw [← Finset.sum_div, Real.sq_sqrt hden.le]
  apply (div_le_iff₀ hden).mpr
  nlinarith [hsum]


end NeuralGeneralization.RobustGaussianGeometry
