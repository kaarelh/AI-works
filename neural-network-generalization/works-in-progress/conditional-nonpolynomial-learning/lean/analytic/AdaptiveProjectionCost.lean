import AdaptiveGaussianCost
import GaussianReadoutProjectionMGF

noncomputable section
set_option linter.unusedSectionVars false
open MeasureTheory
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.GaussianAngularFields NeuralGeneralization.RobustGaussianGeometry

variable {Ω Ξ : Type*} [MeasurableSpace Ω] [MeasurableSpace Ξ]

/-- Conditional integration with a uniform nonnegative factor bound. -/
theorem weighted_product_integral_le
    (μ : Measure Ω) [IsProbabilityMeasure μ]
    (ν : Measure Ξ) [IsProbabilityMeasure ν]
    (F : Ω → ℝ) (hF : Measurable F) (hF0 : ∀ x,0≤F x) (hFI : Integrable F μ)
    (K : Ω → Ξ → ℝ) (hK : Measurable (fun p : Ω × Ξ => K p.1 p.2))
    (hK0 : ∀ x y,0≤K x y) (hKI : ∀ x,Integrable (K x) ν)
    (C : ℝ) (hKC : ∀ x,(∫ y,K x y ∂ν)≤C) :
    Integrable (fun p : Ω × Ξ => F p.1*K p.1 p.2) (μ.prod ν) ∧
      (∫ p : Ω × Ξ,F p.1*K p.1 p.2 ∂μ.prod ν)≤(∫ x,F x ∂μ)*C := by
  have hm : AEStronglyMeasurable (fun p : Ω × Ξ => F p.1*K p.1 p.2) (μ.prod ν) :=
    ((hF.comp measurable_fst).mul hK).aestronglyMeasurable
  have hnorm (x : Ω) : (∫ y,‖F x*K x y‖ ∂ν)=F x*(∫ y,K x y ∂ν) := by
    simp_rw [Real.norm_eq_abs, abs_of_nonneg (mul_nonneg (hF0 x) (hK0 x _))]
    exact integral_const_mul _ _
  have hnorm0 x : 0≤∫ y,‖F x*K x y‖ ∂ν := integral_nonneg (fun _=>norm_nonneg _)
  have hInt : Integrable (fun p : Ω × Ξ => F p.1*K p.1 p.2) (μ.prod ν) := by
    apply (integrable_prod_iff hm).mpr
    refine ⟨ae_of_all _ (fun x => (hKI x).const_mul (F x)),?_⟩
    apply (hFI.mul_const C).mono' hm.norm.integral_prod_right'
    apply ae_of_all
    intro x
    rw [Real.norm_eq_abs, abs_of_nonneg (hnorm0 x), hnorm]
    exact mul_le_mul_of_nonneg_left (hKC x) (hF0 x)
  refine ⟨hInt,?_⟩
  rw [integral_prod _ hInt, ←integral_mul_const]
  apply integral_mono hInt.integral_prod_left (hFI.mul_const C)
  intro x
  change (∫ y,F x*K x y ∂ν)≤F x*C
  rw [integral_const_mul]
  exact mul_le_mul_of_nonneg_left (hKC x) (hF0 x)

/-- The actual Gaussian projection bound can be conditioned on arbitrary
measurable hidden features, including rank changes. -/
theorem adaptive_projection_mgf {m N : ℕ}
    (μ : Measure Ω) [IsProbabilityMeasure μ]
    (ν : Measure Ξ) [IsProbabilityMeasure ν]
    (f : Ω → Fin m → EuclideanSpace ℝ (Fin N)) (hf : Measurable f)
    (S : Ξ → Fin N → ℝ) (hS : Measurable S)
    (hLaw : ν.map S=standardLaw (Fin N))
    (F : Ω → ℝ) (hF : Measurable F) (hF0 : ∀x,0≤F x) (hFI : Integrable F μ)
    (s : ℝ) (hs : 0<s) (hs1 : s≤1) :
    Integrable (fun p : Ω × Ξ => F p.1*Real.exp (((1-s)/2)*
      ‖activeProjection (f p.1) (WithLp.toLp 2 (S p.2))‖^2)) (μ.prod ν) ∧
    (∫ p : Ω × Ξ,F p.1*Real.exp (((1-s)/2)*
      ‖activeProjection (f p.1) (WithLp.toLp 2 (S p.2))‖^2) ∂μ.prod ν)≤
        (∫ x,F x ∂μ)*(Real.sqrt s)⁻¹^m := by
  refine weighted_product_integral_le μ ν F hF hF0 hFI
    (fun x y=>Real.exp (((1-s)/2)*‖activeProjection (f x) (WithLp.toLp 2 (S y))‖^2))
    ?_ ?_ ?_ ((Real.sqrt s)⁻¹^m) ?_
  · have hInputs : Measurable (fun p : Ω × Ξ=>(f p.1,S p.2)) :=
      (hf.comp measurable_fst).prodMk (hS.comp measurable_snd)
    have h := (ConditionalAnalytic.measurable_active_readout_integrand (m:=m) (N:=N) s).comp hInputs
    exact h
  · intro x y
    exact (Real.exp_pos _).le
  · intro x
    have hi := ConditionalAnalytic.integrable_active_readout (f x) s hs
    rw [←hLaw] at hi
    exact hi.comp_measurable hS
  · intro x
    have h := ConditionalAnalytic.active_projection_square_mgf_le (f x) s hs hs1
    rw [←hLaw] at h
    have hInputs : Measurable (fun g : Fin N→ℝ => (f x,g)) :=
      measurable_const.prodMk measurable_id
    have hmeas := (ConditionalAnalytic.measurable_active_readout_integrand (m:=m) (N:=N) s).comp hInputs
    simp only [Function.comp_def] at hmeas
    rw [integral_map hS.aemeasurable hmeas.aestronglyMeasurable] at h
    exact h

#print axioms adaptive_projection_mgf
end ConditionalNonpolynomial.Analytic
