import ActualAdjustedGain
import GaussianFieldScalarization
import ControlledMarginPath

/-! Actual query controls with the physical subcritical variance kept in the
reference measure. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open NeuralGeneralization.GaussianFieldTilt
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
variable {X I : Type*} [Fintype X] [Fintype I]

theorem field_coordinate_subcritical_law (A : X → I → ℝ) (x : X)
    (v : ℝ≥0) {p : ℝ} (hp : 0<p)
    (hvar : ‖WithLp.toLp 2 (A x)‖^2=(v:ℝ)*p) :
    HasLaw (fun z : X → ℝ => (Real.sqrt p)⁻¹*z x) (gaussianReal 0 v) (fieldLaw A) := by
  have h := gaussianReal_const_mul (field_coordinate_hasLaw A x) ((Real.sqrt p)⁻¹)
  have hv : (NNReal.mk ((Real.sqrt p)⁻¹^2) (sq_nonneg _))*
      (‖WithLp.toLp 2 (A x)‖^2).toNNReal=v := by
    apply NNReal.coe_injective
    simp only [NNReal.coe_mul,NNReal.coe_mk,Real.coe_toNNReal _ (sq_nonneg _)]
    rw [hvar,inv_pow,Real.sq_sqrt hp.le]
    field_simp
  simpa only [mul_zero,hv] using h

theorem controlled_field_subcritical_step (A : X → I → ℝ) (x : X)
    (Q : Measure (X → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (fieldLaw A)≠∞) (v : ℝ≥0) {p : ℝ} (hp : 0<p)
    (hvar : ‖WithLp.toLp 2 (A x)‖^2=(v:ℝ)*p) :
    ∃R : Measure ℝ,IsProbabilityMeasure R ∧ klDiv R (gaussianReal 0 v)≠∞ ∧
      (klDiv R (gaussianReal 0 v)).toReal≤(klDiv Q (fieldLaw A)).toReal ∧
      scalarTransition p R=∫z,(Real.tanh (z x))^2 ∂Q := by
  let T : (X → ℝ) → ℝ := fun z => (Real.sqrt p)⁻¹*z x
  have hT : Measurable T := by dsimp [T]; fun_prop
  have hmap : (fieldLaw A).map T=gaussianReal 0 v :=
    (field_coordinate_subcritical_law A x v hp hvar).map_eq
  have hdata := NeuralGeneralization.RobustEntropy.klDiv_map_le Q (fieldLaw A) hT
  rw [hmap] at hdata
  have hf : klDiv (Q.map T) (gaussianReal 0 v)≠∞ :=
    ne_of_lt (lt_of_le_of_lt hdata (lt_top_iff_ne_top.mpr hKL))
  refine ⟨Q.map T,Measure.isProbabilityMeasure_map hT.aemeasurable,hf,
    ENNReal.toReal_mono hKL hdata,?_⟩
  unfold scalarTransition varianceTest
  rw [integral_map hT.aemeasurable (by fun_prop)]
  apply integral_congr_ae
  filter_upwards [] with z
  dsimp [T]
  rw [← mul_assoc,mul_inv_cancel₀ (Real.sqrt_pos.mpr hp).ne',one_mul]

theorem scaled_source_variance_eq (P : X → EuclideanSpace ℝ I) (t : ℝ) (x : X) :
    ‖WithLp.toLp 2 (scaledFeatureCoefficients t P x)‖^2=t^2*‖P x‖^2 := by
  have heq : WithLp.toLp 2 (scaledFeatureCoefficients t P x)=t • P x := by
    ext i
    rfl
  rw [heq,norm_smul,Real.norm_eq_abs,mul_pow,sq_abs]

#print axioms controlled_field_subcritical_step
end ConditionalNonpolynomial.Analytic
