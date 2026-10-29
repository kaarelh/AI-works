import StatisticEntropyLift
import GaussianDirectionalCovarianceCost
import GaussianAdjustedCostFloor
import SubcriticalMarginAccounting
import ActualGaussianL2Layer

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 2400000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal NNReal BigOperators RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.FiniteDifferential NeuralGeneralization.GaussianAngularFields
open NeuralGeneralization.GaussianAngularPrice NeuralGeneralization.GaussianFieldTilt
open NeuralGeneralization.ConcreteModel
variable {I X : Type*} [Fintype I] [Fintype X]

def gaussianFieldSourceControl (A : X→I→ℝ) (Q : Measure (X→ℝ)) : Measure (I→ℝ) :=
  statisticEntropyLift (standardLaw I) (fieldLinear A) Q

theorem gaussianFieldSourceControl_probability (A : X→I→ℝ) (Q : Measure (X→ℝ))
    [IsProbabilityMeasure Q] : IsProbabilityMeasure (gaussianFieldSourceControl A Q) :=
  statisticEntropyLift_probability _ _ _

theorem gaussianFieldSourceControl_map (A : X→I→ℝ) (Q : Measure (X→ℝ))
    [IsProbabilityMeasure Q] (hQ : klDiv Q (fieldLaw A)≠∞) :
    (gaussianFieldSourceControl A Q).map (fieldLinear A)=Q :=
  statisticEntropyLift_map _ (fieldLinear A).continuous.measurable Q hQ

theorem gaussianFieldSourceControl_kl (A : X→I→ℝ) (Q : Measure (X→ℝ))
    [IsProbabilityMeasure Q] (hQ : klDiv Q (fieldLaw A)≠∞) :
    klDiv (gaussianFieldSourceControl A Q) (standardLaw I)=klDiv Q (fieldLaw A) :=
  statisticEntropyLift_kl _ (fieldLinear A).continuous.measurable Q hQ

lemma gaussian_tanh_moment_le_linear (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hQ : klDiv Q (standardLaw I)≠∞) (a : EuclideanSpace ℝ I) :
    (∫z,(Real.tanh (gaussianLinearForm a z))^2 ∂Q)≤∫z,(gaussianLinearForm a z)^2 ∂Q := by
  have hlin : MemLp (gaussianLinearForm a) 2 Q :=
    (memLp_congr_ae (linearL2Map_ae Q hQ a)).mp (Lp.memLp (linearL2Map Q hQ a))
  have htanh : MemLp (fun z=>Real.tanh (gaussianLinearForm a z)) 2 Q :=
    MemLp.of_bound (by unfold gaussianLinearForm; fun_prop) 1
      (Filter.Eventually.of_forall fun z=>by simpa only [Real.norm_eq_abs] using (Real.abs_tanh_lt_one _).le)
  apply integral_mono htanh.integrable_sq hlin.integrable_sq
  intro z
  simpa only [sq_abs] using pow_le_pow_left₀ (abs_nonneg _)
    (NeuralGeneralization.BatchTwoNonGaussian.abs_tanh_le_abs _) 2

variable {d H : ℕ} {t : ℝ} {f : BooleanFunction d}

def physicalSourceControl (P : ControlledMarginPath d H t f) (j : ℕ) :
    Measure (Cube d⊕Cube d→ℝ) :=
  gaussianFieldSourceControl (scaledFeatureCoefficients t (P.feature j)) (P.law j)

theorem physicalSourceControl_probability (P : ControlledMarginPath d H t f)
    (j : ℕ) (hj : j<H) : IsProbabilityMeasure (physicalSourceControl P j) := by
  letI := P.probability j hj
  exact gaussianFieldSourceControl_probability _ _

theorem physicalSourceControl_kl (P : ControlledMarginPath d H t f)
    (j : ℕ) (hj : j<H) :
    klDiv (physicalSourceControl P j) (standardLaw (Cube d⊕Cube d))=
      klDiv (P.law j) (fieldLaw (scaledFeatureCoefficients t (P.feature j))) := by
  letI := P.probability j hj
  exact gaussianFieldSourceControl_kl _ _ (P.finiteKL j hj)

theorem physicalSourceControl_map (P : ControlledMarginPath d H t f)
    (j : ℕ) (hj : j<H) :
    (physicalSourceControl P j).map (fieldLinear (scaledFeatureCoefficients t (P.feature j)))=P.law j := by
  letI := P.probability j hj
  exact gaussianFieldSourceControl_map _ _ (P.finiteKL j hj)

/-- The full source-row non-Gaussian entropy is paid by the actual adjusted
layer charge; covariance entropy pays the physical baseline and variance gain. -/
theorem physicalSourceControl_nonGaussian_le_adjusted
    (P : ControlledMarginPath d H t f) (j : ℕ) (hj : j<H) :
    (klDiv (physicalSourceControl P j) (matchingGaussian (physicalSourceControl P j))).toReal≤
      physicalAdjustedCost P j := by
  classical
  let Q := physicalSourceControl P j
  letI := P.probability j hj
  letI := physicalSourceControl_probability P j hj
  have hQ : klDiv Q (standardLaw (Cube d⊕Cube d))≠∞ := by
    rw [physicalSourceControl_kl P j hj]
    exact P.finiteKL j hj
  let x := featureMaximizer (P.feature (j+1))
  let a := P.feature j x
  have hnext : 0<physicalMaxVariance P (j+1) :=
    controlledMarginPath_variance_positive P _ (by omega)
  have hmoment : physicalMaxVariance P (j+1)=∫z,(Real.tanh (z x))^2 ∂P.law j :=
    controlledMarginPath_diagonal P j hj x
  have hsource := controlled_field_positive_source
    (scaledFeatureCoefficients t (P.feature j)) x (P.law j) (P.finiteKL j hj)
    (by rwa [←hmoment])
  rw [scaled_source_variance_eq] at hsource
  have ha : 0<‖a‖ := by
    have hs : 0<‖a‖^2 := (mul_pos_iff_of_pos_left (sq_pos_of_pos P.scale_positive)).mp hsource
    nlinarith [norm_nonneg a]
  let u : EuclideanSpace ℝ (Cube d⊕Cube d) := ‖a‖⁻¹ • a
  have hu : ‖u‖=1 := by
    dsimp [u]
    rw [norm_smul,Real.norm_eq_abs,abs_inv,abs_of_pos ha,inv_mul_cancel₀ ha.ne']
  have husum : ∑i,(u i)^2=1 := by
    have hh := EuclideanSpace.norm_sq_eq u
    rw [hu,one_pow] at hh
    simpa only [Real.norm_eq_abs,sq_abs] using hh.symm
  let M := ∫z,(gaussianLinearForm u z)^2 ∂Q
  have hM0 : 0≤M := integral_nonneg fun z=>sq_nonneg _
  have hcov : gaussianVarianceCost M≤gaussianCovarianceCost Q := by
    have hh := gaussian_directional_covariance_cost Q hQ (fun i=>u i) husum
    simpa only [M,gaussianVarianceCost,gaussianLinearForm,PiLp.inner_apply,Real.inner_apply,mul_comm] using hh
  have hscale (z : Cube d⊕Cube d→ℝ) :
      gaussianLinearForm (t • a) z=(t*‖a‖)*gaussianLinearForm u z := by
    dsimp [u,gaussianLinearForm]
    rw [real_inner_smul_left,real_inner_smul_left]
    field_simp
  have hmomentQ : physicalMaxVariance P (j+1)=
      ∫z,(Real.tanh (gaussianLinearForm (t • a) z))^2 ∂Q := by
    have htest : Measurable (fun z : Cube d→ℝ => (Real.tanh (z x))^2) :=
      (NeuralGeneralization.TanhDifferential.continuous_tanh.measurable.comp
        (measurable_pi_apply x)).pow_const 2
    rw [hmoment,←physicalSourceControl_map P j hj,
      integral_map (fieldLinear _).continuous.measurable.aemeasurable htest.aestronglyMeasurable]
    apply integral_congr_ae
    filter_upwards [] with z
    simp only [fieldLinear_apply,scaledFeatureCoefficients,gaussianLinearForm,
      PiLp.inner_apply,PiLp.smul_apply,Real.inner_apply,smul_eq_mul,a,featureCoefficients,mul_comm]
  have hvarianceLocal : physicalMaxVariance P (j+1)≤‖a‖^2*(t^2*M) := by
    rw [hmomentQ]
    calc
      _ ≤ ∫z,(gaussianLinearForm (t • a) z)^2 ∂Q := gaussian_tanh_moment_le_linear Q hQ (t • a)
      _ = ‖a‖^2*(t^2*M) := by
        simp_rw [hscale,mul_pow]
        rw [integral_const_mul]
        ring
  have hM : 0<M := by
    by_contra hn
    have hz : M=0 := le_antisymm (not_lt.mp hn) hM0
    rw [hz,mul_zero,mul_zero] at hvarianceLocal
    linarith
  have hvariance : physicalMaxVariance P (j+1)≤physicalMaxVariance P j*((physicalVariance P:ℝ)*M) := by
    rw [physicalVariance_coe]
    exact hvarianceLocal.trans (mul_le_mul_of_nonneg_right
      (feature_variance_le_max (P.feature j) x) (mul_nonneg (sq_nonneg t) hM0))
  have hdecomp := (gaussianCovarianceCost_decomposition Q hQ).2
  have hh := nonGaussian_cost_le_adjusted (physicalVariance P) (physicalVariance_ne_zero P)
    (physicalVariance_le_one P) hdecomp hcov
    (controlledMarginPath_variance_positive P j (by omega)) hnext hM hvariance
  have hcost : (klDiv Q (Measure.pi fun _ : Cube d⊕Cube d=>gaussianReal 0 1)).toReal=
      physicalLayerCost P j := congrArg ENNReal.toReal (physicalSourceControl_kl P j hj)
  rw [hcost] at hh
  exact hh

#print axioms physicalSourceControl_nonGaussian_le_adjusted
end ConditionalNonpolynomial.Analytic
