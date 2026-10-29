import EventExtraction
import NeuralGeneralization.GaussianDualContinuity

/-! Dense-grid entropy certificates for actual Gaussian coefficient rows.
The coefficient matrix can have deficient rank. -/
noncomputable section
set_option linter.unusedSectionVars false
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel NeuralGeneralization.FiniteDifferential
open NeuralGeneralization.GaussianAngularFields NeuralGeneralization.GaussianAngularPrice
open NeuralGeneralization.GaussianFieldTilt NeuralGeneralization.GaussianDualLayer
open NeuralGeneralization.CompressionSampling NeuralGeneralization.DualCertificate
open NeuralGeneralization.ActualBoundedDual NeuralGeneralization.CovarianceDualLift
open NeuralGeneralization.BoundedDual NeuralGeneralization.TanhDifferential

variable {d N : ℕ} {J : Type*} [Fintype J]

/-- Joint continuity includes variation of the covariance through singular
matrices. It follows from dominated convergence for the bounded tanh tilt. -/
@[fun_prop] theorem continuous_gaussianDenseCost (G : ℝ) (M N : ℕ) :
    Continuous (fun p : (Cube d → J → ℝ) × (Fin N → J → ℝ) =>
      denseCost (fieldLaw p.1) (features Real.tanh) G M N
        (empirical (features Real.tanh) (rows p.1 p.2))) := by
  have hrows : Continuous (fun p : (Cube d → J → ℝ) × (Fin N → J → ℝ) =>
      rows p.1 p.2) := by
    unfold rows
    apply continuous_pi
    intro i
    apply continuous_pi
    intro x
    simp only [fieldLinear_apply]
    fun_prop
  have hpair := continuous_fst.prodMk
    (NeuralGeneralization.GaussianDualContinuity.continuous_empirical_fields.comp hrows)
  have hsum : Continuous (fun p : (Cube d → J → ℝ) × (Fin N → J → ℝ) =>
      denseSum (fieldLaw p.1) (features Real.tanh) G M N
        (empirical (features Real.tanh) (rows p.1 p.2))) := by
    apply continuous_finsetSum
    intro u hu
    exact Real.continuous_exp.comp (continuous_const.mul
      ((NeuralGeneralization.GaussianDualContinuity.continuous_fieldObjective
        (denseParameter G M u)).comp hpair))
  exact ((hsum.log (fun p => (denseSum_pos (fieldLaw p.1)
    (features Real.tanh) G M N _).ne')).div_const _).add continuous_const

/-- Actual empirical covariance test cost for a Gaussian layer. -/
def gaussianDenseCost (A : Cube d → J → ℝ) (G : ℝ) (M N : ℕ)
    (a : Fin N → J → ℝ) : ℝ :=
  denseCost (fieldLaw A) (features Real.tanh) G M N
    (empirical (features Real.tanh) (rows A a))

@[fun_prop] theorem measurable_covariance_denseCost
    (A : Cube d → J → ℝ) (G : ℝ) (M N : ℕ) :
    Measurable (fun q : Cube d × Cube d → ℝ =>
      denseCost (fieldLaw A) (features Real.tanh) G M N q) := by
  unfold denseCost denseSum objective pairing
  fun_prop

@[fun_prop] theorem measurable_gaussianDenseCost
    (A : Cube d → J → ℝ) (G : ℝ) (M N : ℕ) :
    Measurable (gaussianDenseCost A G M N) := by
  apply (measurable_covariance_denseCost A G M N).comp
  apply measurable_pi_lambda
  intro p
  unfold empirical
  apply Measurable.div_const
  apply Finset.measurable_fun_sum
  intro i hi
  exact (continuous_tanhPairValue p.1 p.2).measurable.comp
    ((measurable_pi_apply i).comp (measurable_rows A))

theorem gaussianDenseCost_integrable
    (A : Cube d → J → ℝ) (G : ℝ) (M : ℕ) {N : ℕ} (hN : 0 < N) :
    Integrable (fun a => Real.exp ((N:ℝ)*gaussianDenseCost A G M N a))
      (iidSamples (standardLaw J) N) := by
  have h := integrable_exp_denseCost (fieldLaw A) (features Real.tanh)
    (fun p => (continuous_tanhPairValue p.1 p.2).measurable)
    (features_bound Real.tanh (fun x => (Real.abs_tanh_lt_one x).le)) G M hN
  rw [← map_rows A] at h
  exact h.comp_measurable (measurable_rows A)

/-- Exact conditional exponential moment for a fixed preceding coefficient
matrix. This is uniform in its entries and requires no covariance lower bound. -/
theorem gaussianDenseCost_mgf
    (A : Cube d → J → ℝ) (G : ℝ) (M : ℕ) {N : ℕ} (hN : 0 < N) :
    (∫ a, Real.exp ((N:ℝ)*gaussianDenseCost A G M N a)
      ∂iidSamples (standardLaw J) N) =
      Real.exp ((N:ℝ)*(2*(Fintype.card (Cube d × Cube d):ℝ)*G/M))*
        (((2*M+1)^(Fintype.card (Cube d × Cube d)):ℕ):ℝ) := by
  have h := integral_exp_denseCost (fieldLaw A) (features Real.tanh)
    (fun p => (continuous_tanhPairValue p.1 p.2).measurable)
    (features_bound Real.tanh (fun x => (Real.abs_tanh_lt_one x).le)) G M hN
  rw [← map_rows A] at h
  rw [integral_map (measurable_rows A).aemeasurable] at h
  · exact h
  · exact (Real.measurable_exp.comp
      (measurable_const.mul ((measurable_covariance_denseCost A G M N).comp (by
        apply measurable_pi_lambda
        intro p
        exact (Finset.measurable_fun_sum Finset.univ (fun i _ =>
          (continuous_tanhPairValue p.1 p.2).measurable.comp (measurable_pi_apply i))).div_const _)))).aestronglyMeasurable

/-- A realization in any sufficiently positive Gaussian matrix event admits
an actual controlled row law (an exponential tilt of its Gaussian field law). -/
theorem gaussian_event_contains_actual_tilt
    (A : Cube d → J → ℝ) {G : ℝ} (hG : 0 < G)
    {M N : ℕ} (hM : 0 < M) (hN : 0 < N)
    (E : Set (Fin N → J → ℝ)) (B : ℝ)
    (hMass :
      (Real.exp ((N:ℝ)*(2*(Fintype.card (Cube d × Cube d):ℝ)*G/M))*
        (((2*M+1)^(Fintype.card (Cube d × Cube d)):ℕ):ℝ)) /
          Real.exp ((N:ℝ)*B) < (iidSamples (standardLaw J) N).real E) :
    ∃ a ∈ E, ∃ star : Cube d × Cube d → ℝ, entryL1 star ≤ G ∧
      entropy (fieldLaw A) (features Real.tanh) star ≤ B ∧
      ∀ x y, |(∑ i, Real.tanh (fieldLinear A (a i) x) *
        Real.tanh (fieldLinear A (a i) y))/N -
        mean (fieldLaw A) (features Real.tanh) star (x,y)| ≤ B/G := by
  obtain ⟨a,ha,hcost⟩ := exists_mem_cost_le (iidSamples (standardLaw J) N)
    (gaussianDenseCost A G M N) hN E B _
    (gaussianDenseCost_integrable A G M hN)
    (gaussianDenseCost_mgf A G M hN).le hMass
  obtain ⟨star,hstar,hent,herr⟩ := exists_tilt_of_denseCost (fieldLaw A)
    (features Real.tanh) (fun p => (continuous_tanhPairValue p.1 p.2).measurable)
    (features_bound Real.tanh (fun x => (Real.abs_tanh_lt_one x).le)) hG hM hN
    (empirical (features Real.tanh) (rows A a))
    (empirical_abs_le_one (features Real.tanh)
      (features_bound Real.tanh (fun x => (Real.abs_tanh_lt_one x).le)) hN (rows A a))
  refine ⟨a,ha,star,hstar,hent.trans hcost,?_⟩
  intro x y
  have h := (abs_le_maxAbs (empirical (features Real.tanh) (rows A a)-
    mean (fieldLaw A) (features Real.tanh) star) (x,y)).trans
    (herr.trans (div_le_div_of_nonneg_right hcost hG.le))
  simpa only [Pi.sub_apply, empirical, features, rows] using h

#print axioms gaussianDenseCost_mgf
#print axioms gaussian_event_contains_actual_tilt
end ConditionalNonpolynomial.Analytic
