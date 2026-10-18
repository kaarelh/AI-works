import NeuralGeneralization.RobustEntropyFeatureNormalization
import NeuralGeneralization.RobustCompressionMessageBasis

/-! # The bounded active family depends only on prefix and finite message -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped RealInnerProductSpace Classical
namespace NeuralGeneralization.RobustEntropy
open RobustGaussianGeometry RobustCompressionInduction ConcreteModel
variable {A Y : Type*} [MeasurableSpace A] [MeasurableSpace Y]
    {N M q : ℕ} [MeasurableSpace (Finset (Fin M))]
    [MeasurableSingletonClass (Finset (Fin M))]
    [MeasurableSpace (QueryMessage (Fin M) q)]
    [MeasurableSingletonClass (QueryMessage (Fin M) q)]
local notation "E" => EuclideanSpace ℝ (Fin N)

def selectedMessageBasis (b : A → Fin M → E) (J : A × Y → Finset (Fin M)) :
    A × Y → Fin q → E :=
  fun a => basisFromQueryMessage b (a.1,abortQueryMessage q (J a))

theorem measurable_selectedMessageBasis
    (b : A → Fin M → E) (hb : Measurable b)
    (J : A × Y → Finset (Fin M)) (hJ : Measurable J) :
    Measurable (selectedMessageBasis (q := q) b J) :=
  (measurable_basisFromQueryMessage b hb).comp
    (measurable_fst.prodMk (measurable_abortQueryMessage J hJ))

theorem selectedMessageBasis_span_le
    (b : A → Fin M → E) (J : A × Y → Finset (Fin M)) (a : A × Y) :
    Submodule.span ℝ (Set.range (selectedMessageBasis (q := q) b J a)) ≤
      inputSpan (b a.1) (J a) := by
  by_cases h : (J a).card ≤ q
  · exact (basisFromQueryMessage_span_inputSpan b a.1 (J a) h).le
  · simp only [selectedMessageBasis,abortQueryMessage,dif_neg h,basisFromQueryMessage]
    apply Submodule.span_le.mpr
    rintro _ ⟨j,rfl⟩
    exact Submodule.zero_mem _

theorem selectedMessageBasis_span_eq
    (b : A → Fin M → E) (J : A × Y → Finset (Fin M)) (a : A × Y)
    (h : (J a).card ≤ q) :
    Submodule.span ℝ (Set.range (selectedMessageBasis (q := q) b J a)) =
      inputSpan (b a.1) (J a) :=
  basisFromQueryMessage_span_inputSpan b a.1 (J a) h

theorem selectedMessageBasis_residual_eq
    (b : A → Fin M → E) (J : A × Y → Finset (Fin M)) (a : A × Y)
    (h : (J a).card ≤ q) (x : E) :
    queryResidual (selectedMessageBasis (q := q) b J a) x =
      queryResidual (maskedInputs (b a.1) (J a)) x := by
  apply queryResidual_eq_of_span_eq
  rw [selectedMessageBasis_span_eq b J a h,span_maskedInputs]

theorem selectedMessageBasis_normalized_residual_eq
    (b : A → Fin M → E) (J : A × Y → Finset (Fin M)) (a : A × Y)
    (h : (J a).card ≤ q) (x : E) :
    normalizedQueryResidual (selectedMessageBasis (q := q) b J a) x =
      normalizedQueryResidual (maskedInputs (b a.1) (J a)) x := by
  unfold normalizedQueryResidual
  rw [selectedMessageBasis_residual_eq b J a h]

end NeuralGeneralization.RobustEntropy
