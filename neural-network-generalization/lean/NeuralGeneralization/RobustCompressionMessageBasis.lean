import NeuralGeneralization.RobustCompressionMessagesVectors
import NeuralGeneralization.RobustCompressionInductionAbort

/-! # Active query family determined only by prefix and bounded message

The family has q slots, with zero padding and an all-zero abort value. It
generates exactly the selected input span. It is an input family for the
measurable orthogonalization map, not a claim that the query vectors themselves
are orthonormal. No unprocessed weight coordinate is an additional argument.
-/

noncomputable section
open MeasureTheory

namespace NeuralGeneralization.RobustCompressionInduction
open ConcreteModel

variable {A I E : Type*} {q : ℕ}

def basisFromQueryMessage [Zero E] (b : A → I → E) : A × QueryMessage I q → Fin q → E :=
  fun p => match p.2 with
    | none => fun _ => 0
    | some S => paddedQueryVectors (b p.1) S

@[simp] theorem basisFromQueryMessage_none [Zero E] (b : A → I → E) (a : A) :
    basisFromQueryMessage (q := q) b (a,none) = fun _ => 0 := rfl

@[simp] theorem basisFromQueryMessage_some [Zero E] (b : A → I → E) (a : A)
    (S : BoundedQuerySubset I q) :
    basisFromQueryMessage b (a,some S) = paddedQueryVectors (b a) S := rfl

theorem measurable_basisFromQueryMessage [Fintype I] [Zero E]
    [MeasurableSpace A] [MeasurableSpace E]
    [MeasurableSpace (QueryMessage I q)] [MeasurableSingletonClass (QueryMessage I q)]
    (b : A → I → E) (hb : Measurable b) :
    Measurable (basisFromQueryMessage (q := q) b) := by
  apply measurable_from_prod_countable_left
  intro J
  cases J with
  | none => exact measurable_const
  | some S =>
    exact (measurable_paddedQueryVectors_fixed S).comp hb

theorem span_basisFromQueryMessage_some [AddCommGroup E] [Module ℝ E]
    (b : A → I → E) (a : A) (S : BoundedQuerySubset I q) :
    Submodule.span ℝ (Set.range (basisFromQueryMessage b (a,some S))) =
      Submodule.span ℝ ((b a) '' (S.val : Set I)) :=
  span_paddedQueryVectors (b a) S

theorem span_basisFromQueryMessage_abortQueryMessage [AddCommGroup E] [Module ℝ E]
    (b : A → I → E) (a : A) (J : Finset I) (hJ : J.card ≤ q) :
    Submodule.span ℝ (Set.range (basisFromQueryMessage b (a,abortQueryMessage q J))) =
      Submodule.span ℝ ((b a) '' (J : Set I)) := by
  rw [abortQueryMessage_eq_some q J hJ]
  exact span_basisFromQueryMessage_some b a ⟨J,hJ⟩

theorem basisFromQueryMessage_span_inputSpan {M N : ℕ}
    (b : A → Fin M → EuclideanSpace ℝ (Fin N)) (a : A)
    (J : Finset (Fin M)) (hJ : J.card ≤ q) :
    Submodule.span ℝ (Set.range (basisFromQueryMessage b (a,abortQueryMessage q J))) =
      RobustEntropy.inputSpan (b a) J :=
  span_basisFromQueryMessage_abortQueryMessage b a J hJ

end NeuralGeneralization.RobustCompressionInduction
