import GaussianDenseCertificate
import Mathlib.MeasureTheory.Integral.Prod

/-! Fubini assembly for the dense test of a Gaussian layer whose coefficient
matrix is determined by all previous layers. The exponential moment is
computed from the actual Gaussian row law, not assumed. -/
noncomputable section
set_option linter.unusedSectionVars false
set_option maxHeartbeats 200000
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel NeuralGeneralization.GaussianAngularFields
open NeuralGeneralization.CompressionSampling

variable {Ω Ξ J : Type*} [MeasurableSpace Ω] [MeasurableSpace Ξ] [Fintype J]
variable {d N : ℕ}

def denseOverhead (d N M : ℕ) (G : ℝ) : ℝ :=
  Real.exp ((N:ℝ)*(2*(Fintype.card (Cube d × Cube d):ℝ)*G/M))*
    (((2*M+1)^(Fintype.card (Cube d × Cube d)):ℕ):ℝ)

/-- Actual conditional-layer factorization. `S` only identifies the standardized
raw rows; its exact pushforward law is the sole probabilistic input. -/
theorem adaptive_gaussian_dense_mgf
    (μ : Measure Ω) [IsProbabilityMeasure μ]
    (ν : Measure Ξ) [IsProbabilityMeasure ν]
    (A : Ω → Cube d → J → ℝ) (hA : Measurable A)
    (S : Ξ → Fin N → J → ℝ) (hS : Measurable S)
    (hLaw : ν.map S = iidSamples (standardLaw J) N)
    (F : Ω → ℝ) (hF : Measurable F) (hF0 : ∀ x, 0 ≤ F x) (hFI : Integrable F μ)
    (G : ℝ) (M : ℕ) (hN : 0 < N) :
    Integrable (fun p : Ω × Ξ => F p.1 * Real.exp
        ((N:ℝ)*gaussianDenseCost (A p.1) G M N (S p.2))) (μ.prod ν) ∧
    (∫ p : Ω × Ξ, F p.1 * Real.exp
        ((N:ℝ)*gaussianDenseCost (A p.1) G M N (S p.2)) ∂μ.prod ν)
      = (∫ x, F x ∂μ) * denseOverhead d N M G := by
  let K : Ω → Ξ → ℝ := fun x y => Real.exp
    ((N:ℝ)*gaussianDenseCost (A x) G M N (S y))
  have hKI (x : Ω) : Integrable (K x) ν := by
    have h := gaussianDenseCost_integrable (A x) G M hN
    rw [←hLaw] at h
    exact h.comp_measurable hS
  have hKM (x : Ω) : (∫ y, K x y ∂ν) = denseOverhead d N M G := by
    have h := gaussianDenseCost_mgf (A x) G M hN
    rw [←hLaw] at h
    have hExp : Measurable (fun a => Real.exp ((N:ℝ)*gaussianDenseCost (A x) G M N a)) :=
      Real.measurable_exp.comp (measurable_const.mul
        (measurable_gaussianDenseCost (A x) G M N))
    rw [integral_map hS.aemeasurable hExp.aestronglyMeasurable] at h
    exact h
  have hInputs : Measurable (fun p : Ω × Ξ => (A p.1, S p.2)) :=
    (hA.comp measurable_fst).prodMk (hS.comp measurable_snd)
  have hCost := (continuous_gaussianDenseCost (d:=d) (J:=J) G M N).measurable.comp hInputs
  change Measurable (fun p : Ω × Ξ => gaussianDenseCost (A p.1) G M N (S p.2)) at hCost
  have hK : Measurable (fun p : Ω × Ξ => K p.1 p.2) := by
    exact Real.measurable_exp.comp (measurable_const.mul hCost)
  have hInt : Integrable (fun p : Ω × Ξ => F p.1 * K p.1 p.2) (μ.prod ν) := by
    apply (integrable_prod_iff ((hF.comp measurable_fst).mul hK).aestronglyMeasurable).mpr
    constructor
    · exact ae_of_all _ (fun x => (hKI x).const_mul (F x))
    · have heq : (fun x => ∫ y, ‖F x*K x y‖ ∂ν) =
          (fun x => F x*denseOverhead d N M G) := by
        funext x
        simp only [Real.norm_eq_abs, abs_mul, abs_of_nonneg (hF0 x)]
        have hkabs (y : Ξ) : |K x y|=K x y := abs_of_pos (Real.exp_pos _)
        simp_rw [hkabs]
        rw [integral_const_mul, hKM]
      change Integrable (fun x => ∫ y, ‖F x*K x y‖ ∂ν) μ
      rw [heq]
      exact hFI.mul_const _
  refine ⟨hInt,?_⟩
  rw [integral_prod _ hInt]
  simp_rw [integral_const_mul, hKM]
  exact integral_mul_const _ _

#print axioms adaptive_gaussian_dense_mgf
end ConditionalNonpolynomial.Analytic
