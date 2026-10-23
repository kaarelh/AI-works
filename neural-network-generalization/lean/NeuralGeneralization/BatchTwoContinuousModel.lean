import NeuralGeneralization.BatchTwoNonGaussianModel
import NeuralGeneralization.RobustPosteriorConditioning
import NeuralGeneralization.BatchTwoConfidenceProduct
import Mathlib.MeasureTheory.Measure.Prod

/-!
# Real-input neural networks and tolerance-conditioned posteriors

The definitions are the literal model of the continuous-domain manuscript:
arbitrary real inputs, a constant input coordinate, tanh hidden layers, and
a linear readout. Only the observed regression constraints condition the
prior. There is no condition on unobserved inputs.
-/

noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open MeasureTheory ProbabilityTheory

namespace NeuralGeneralization.BatchTwoContinuous
open ConcreteModel

abbrev RealInput (d : ℕ) := Fin d → ℝ

def augmentedInput {d : ℕ} (x : RealInput d) : Fin (d + 1) → ℝ :=
  Fin.cases 1 x

def firstHidden {d N r : ℕ} (φ : ℝ → ℝ) (w : Weights d N r)
    (x : RealInput d) : Fin N → ℝ :=
  fun i => φ (∑ j, w (Sum.inl (i, j)) * augmentedInput x j)

def finalHidden {d N r : ℕ} (φ : ℝ → ℝ) (w : Weights d N r)
    (x : RealInput d) : Fin N → ℝ :=
  (List.finRange r).foldl (hiddenStep φ w) (firstHidden φ w x)

def output {d N r : ℕ} (φ : ℝ → ℝ) (w : Weights d N r)
    (x : RealInput d) : ℝ :=
  ∑ i, w (Sum.inr (Sum.inr i)) * finalHidden φ w x i

/-- The continuous model agrees exactly with the existing Boolean model. -/
theorem output_on_cube {d N r : ℕ} (φ : ℝ → ℝ) (w : Weights d N r)
    (x : Cube d) :
    output φ w (fun i => labelReal (x i)) = networkOutput φ w x := rfl

theorem continuous_augmentedInput {d : ℕ} (i : Fin (d + 1)) :
    Continuous (fun x : RealInput d => augmentedInput x i) := by
  refine Fin.cases ?_ (fun i => ?_) i
  · exact continuous_const
  · exact continuous_apply i

theorem continuous_firstHidden_joint {d N r : ℕ} {φ : ℝ → ℝ}
    (hφ : Continuous φ) (i : Fin N) :
    Continuous (fun p : Weights d N r × RealInput d => firstHidden φ p.1 p.2 i) := by
  apply hφ.comp
  exact continuous_finsetSum _ (fun j _ =>
    ((continuous_apply (Sum.inl (i, j))).comp continuous_fst).mul
      ((continuous_augmentedInput j).comp continuous_snd))

theorem continuous_hiddenFold_joint {d N r : ℕ} {φ : ℝ → ℝ}
    (hφ : Continuous φ) (ss : List (Fin r))
    (H : Weights d N r × RealInput d → Fin N → ℝ)
    (hH : ∀ i, Continuous (fun p => H p i)) (i : Fin N) :
    Continuous (fun p => ss.foldl (hiddenStep φ p.1) (H p) i) := by
  induction ss generalizing H with
  | nil => exact hH i
  | cons s ss ih =>
    apply ih (fun p => hiddenStep φ p.1 (H p) s)
    intro j
    apply hφ.comp
    exact continuous_finsetSum _ (fun k _ =>
      ((continuous_apply (Sum.inr (Sum.inl (s, j, k)))).comp continuous_fst).mul (hH k))

theorem continuous_finalHidden_joint {d N r : ℕ} {φ : ℝ → ℝ}
    (hφ : Continuous φ) (i : Fin N) :
    Continuous (fun p : Weights d N r × RealInput d => finalHidden φ p.1 p.2 i) :=
  continuous_hiddenFold_joint hφ _ _ (continuous_firstHidden_joint hφ) i

theorem continuous_output_joint {d N r : ℕ} {φ : ℝ → ℝ}
    (hφ : Continuous φ) :
    Continuous (fun p : Weights d N r × RealInput d => output φ p.1 p.2) :=
  continuous_finsetSum _ (fun i _ =>
    ((continuous_apply (Sum.inr (Sum.inr i))).comp continuous_fst).mul
      (continuous_finalHidden_joint hφ i))

theorem continuous_output_weights {d N r : ℕ} {φ : ℝ → ℝ}
    (hφ : Continuous φ) (x : RealInput d) :
    Continuous (fun w : Weights d N r => output φ w x) :=
  (continuous_output_joint hφ).comp (continuous_id.prodMk continuous_const)

theorem continuous_output_input {d N r : ℕ} {φ : ℝ → ℝ}
    (hφ : Continuous φ) (w : Weights d N r) : Continuous (output φ w) :=
  (continuous_output_joint hφ).comp (continuous_const.prodMk continuous_id)

def trainingEvent {d N r n : ℕ} (φ : ℝ → ℝ) (f : RealInput d → ℝ)
    (ρ : ℝ) (s : Fin n → RealInput d) : Set (Weights d N r) :=
  {w | ∀ i, |output φ w (s i) - f (s i)| < ρ}

def posterior {d N r n : ℕ} (φ : ℝ → ℝ) (μ : Measure (Weights d N r))
    (f : RealInput d → ℝ) (ρ : ℝ) (s : Fin n → RealInput d) :
    Measure (Weights d N r) := cond μ (trainingEvent φ f ρ s)

theorem isOpen_trainingEvent {d N r n : ℕ} {φ : ℝ → ℝ}
    (hφ : Continuous φ) (f : RealInput d → ℝ) (ρ : ℝ)
    (s : Fin n → RealInput d) : IsOpen (trainingEvent (N := N) (r := r) φ f ρ s) := by
  unfold trainingEvent
  simp only [Set.setOf_forall]
  exact isOpen_iInter_of_finite (fun i =>
    isOpen_lt (((continuous_output_weights hφ (s i)).sub continuous_const).abs) continuous_const)

def jointErrorEvent {d N r : ℕ} (φ : ℝ → ℝ) (f : RealInput d → ℝ)
    (τ : ℝ) : Set (RealInput d × Weights d N r) :=
  {p | τ < |output φ p.2 p.1 - f p.1|}

def risk {d N r : ℕ} (φ : ℝ → ℝ) (D : Measure (RealInput d))
    (Q : Measure (Weights d N r)) (f : RealInput d → ℝ) (τ : ℝ) : ℝ :=
  (D.prod Q).real (jointErrorEvent φ f τ)

def correctProbability {d N r : ℕ} (φ : ℝ → ℝ)
    (Q : Measure (Weights d N r)) (f : RealInput d → ℝ) (τ : ℝ)
    (x : RealInput d) : ℝ := Q.real {w | |output φ w x - f x| ≤ τ}

def confidenceFailure {d N r : ℕ} (φ : ℝ → ℝ) (D : Measure (RealInput d))
    (Q : Measure (Weights d N r)) (f : RealInput d → ℝ) (τ : ℝ) : ℝ :=
  D.real {x | correctProbability φ Q f τ x ≤ 2 / 3}

theorem measurable_jointErrorEvent {d N r : ℕ} {φ : ℝ → ℝ}
    (hφ : Continuous φ) {f : RealInput d → ℝ} (hf : Measurable f) (τ : ℝ) :
    MeasurableSet (jointErrorEvent (N := N) (r := r) φ f τ) :=
  measurableSet_lt measurable_const
    ((((continuous_output_joint hφ).comp continuous_swap).measurable.sub
      (hf.comp measurable_fst)).abs)

theorem measurable_correctProbability {d N r : ℕ} {φ : ℝ → ℝ}
    (hφ : Continuous φ) (Q : Measure (Weights d N r)) [IsFiniteMeasure Q]
    {f : RealInput d → ℝ} (hf : Measurable f) (τ : ℝ) :
    Measurable (correctProbability φ Q f τ) := by
  change Measurable (fun x => (Q {w | |output φ w x - f x| ≤ τ}).toReal)
  have hm := measurable_measure_prodMk_left_finite (ν := Q)
    (measurable_jointErrorEvent (N := N) (r := r) hφ hf τ).compl
  simpa only [correctProbability, Measure.real, jointErrorEvent, Set.preimage_compl,
    Set.preimage_setOf_eq, Set.compl_setOf, not_lt] using hm.ennreal_toReal

/-- The exact posterior-mixture confidence implication used in both regression
main theorems. No prediction by the posterior mean is involved. -/
theorem confidenceFailure_le_three_risk {d N r : ℕ} {φ : ℝ → ℝ}
    (hφ : Continuous φ) (D : Measure (RealInput d))
    (Q : Measure (Weights d N r)) [IsProbabilityMeasure D] [IsProbabilityMeasure Q]
    {f : RealInput d → ℝ} (hf : Measurable f) (τ : ℝ) :
    confidenceFailure φ D Q f τ ≤ 3 * risk φ D Q f τ := by
  have h := BatchTwoConfidenceProduct.two_thirds_confidence_bound D Q
    (jointErrorEvent φ f τ) (measurable_jointErrorEvent hφ hf τ)
  simpa only [confidenceFailure, correctProbability, risk, jointErrorEvent,
    Set.preimage_setOf_eq, Set.compl_setOf, not_lt] using h

end NeuralGeneralization.BatchTwoContinuous
