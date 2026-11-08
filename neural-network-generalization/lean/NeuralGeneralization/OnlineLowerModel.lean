import NeuralGeneralization.ModelFacts
import NeuralGeneralization.OnlineLowerTeacherModel

/-!
# The literal network and online protocol for the adversarial lower bounds

This module uses the existing concrete Gaussian network, not an abstract
distribution on hypotheses.  There is one hidden layer (`r = 0`), an augmented
constant input, a linear readout, and independent Gaussian coordinates.  The
variances are `N * σ² / d` in the incoming layer and `σ² / N` in the readout.
At each fixed width, writing `t = sqrt N * σ` gives the equivalent usual
variances `t²/d` and `t²/N²`; no coordinate is given a special variance.
The posterior first imposes the strict absolute margin `1/2` on the entire
Boolean cube and then conditions on the correct sign of every earlier label.
There is no Gaussian regression likelihood or requirement to fit real outputs.

An `InputOrder` enumerates the entire cube exactly once.  It is chosen before
the learner width and the Gaussian scale.  Prefixes contain precisely the
inputs preceding the designated prediction; the current label is not included.
-/

noncomputable section
open scoped BigOperators Topology
open MeasureTheory Filter

namespace NeuralGeneralization.OnlineLower
open ConcreteModel

/-- The actual globally margin-conditioned, exact-label Gaussian posterior. -/
def posteriorAt {d : ℕ} (φ : ℝ → ℝ) (f : BooleanFunction d)
    (π : InputOrder d) (N : ℕ) (σ : ℝ)
    (j : Fin (Fintype.card (Cube d))) : BooleanFunction d → ℝ :=
  networkPosterior φ (1 / 2) (smallPrior d N 0 σ) f (observedPrefix π j)

/-- Correct-label posterior probability, before the current label is revealed. -/
def correctAt {d : ℕ} (φ : ℝ → ℝ) (f : BooleanFunction d)
    (π : InputOrder d) (N : ℕ) (σ : ℝ)
    (j : Fin (Fintype.card (Cube d))) : ℝ :=
  correctConfidence f (posteriorAt φ f π N σ j) (π j)

/-- Explicit normalization; this must be positive for a valid conditioned law. -/
def denominatorAt {d : ℕ} (φ : ℝ → ℝ) (f : BooleanFunction d)
    (π : InputOrder d) (N : ℕ) (σ : ℝ)
    (j : Fin (Fintype.card (Cube d))) : ℝ :=
  posteriorDenominator φ (1 / 2) (smallPrior d N 0 σ) f (observedPrefix π j)

theorem denominatorAt_pos {d C N : ℕ} (hd : 0 < d) {φ : ℝ → ℝ}
    (hφ : Continuous φ) {f : BooleanFunction d}
    (hteacher : BoundedTeacher φ f C) (hCN : C ≤ N)
    (π : InputOrder d) {σ : ℝ} (hσ : 0 < σ)
    (j : Fin (Fintype.card (Cube d))) :
    0 < denominatorAt φ f π N σ j := by
  exact small_posteriorDenominator_pos hd hφ f hteacher.realizesAtComplexity
    hCN hσ (observedPrefix π j)

theorem posteriorAt_eq_globalConditioned {d C N : ℕ} (hd : 0 < d)
    {φ : ℝ → ℝ} (hφ : Continuous φ) {f : BooleanFunction d}
    (hteacher : BoundedTeacher φ f C) (hCN : C ≤ N)
    (π : InputOrder d) {σ : ℝ} (hσ : 0 < σ)
    (j : Fin (Fintype.card (Cube d))) :
    posteriorAt φ f π N σ j =
      NeuralGeneralization.posterior
        (globalConditionedFunctionPrior φ (1 / 2) (smallPrior d N 0 σ))
        (consistent f (observedPrefix π j)) := by
  exact small_networkPosterior_eq_globalConditioned hd hφ f
    hteacher.realizesAtComplexity hCN hσ (observedPrefix π j)

/-- Positivity of the actual normalizer makes every posterior weight
nonnegative, even when some global sign events are unrepresentable. -/
theorem posteriorAt_nonneg_of_denominator_pos {d N : ℕ}
    (φ : ℝ → ℝ) (f : BooleanFunction d) (π : InputOrder d) (σ : ℝ)
    (j : Fin (Fintype.card (Cube d)))
    (hden : 0 < denominatorAt φ f π N σ j) (g : BooleanFunction d) :
    0 ≤ posteriorAt φ f π N σ j g := by
  classical
  unfold posteriorAt networkPosterior NeuralGeneralization.posterior
  apply div_nonneg
  · split_ifs
    · exact functionMass_nonneg φ (1 / 2) (smallPrior d N 0 σ) g
    · exact le_rfl
  · exact hden.le

/-- The finite sign law is normalized at every positive normalizer. -/
theorem posteriorAt_sum_of_denominator_pos {d N : ℕ}
    (φ : ℝ → ℝ) (f : BooleanFunction d) (π : InputOrder d) (σ : ℝ)
    (j : Fin (Fintype.card (Cube d)))
    (hden : 0 < denominatorAt φ f π N σ j) :
    ∑ g, posteriorAt φ f π N σ j g = 1 := by
  classical
  unfold posteriorAt networkPosterior NeuralGeneralization.posterior
  rw [← Finset.sum_div]
  exact div_self (ne_of_gt hden)

/-- The probability used in the online statements is a genuine probability. -/
theorem correctAt_mem_Icc_of_denominator_pos {d N : ℕ}
    (φ : ℝ → ℝ) (f : BooleanFunction d) (π : InputOrder d) (σ : ℝ)
    (j : Fin (Fintype.card (Cube d)))
    (hden : 0 < denominatorAt φ f π N σ j) :
    correctAt φ f π N σ j ∈ Set.Icc (0 : ℝ) 1 := by
  classical
  have hp := posteriorAt_nonneg_of_denominator_pos φ f π σ j hden
  constructor
  · apply Finset.sum_nonneg
    intro g hg
    split_ifs
    · exact hp g
    · exact le_rfl
  · calc
      correctAt φ f π N σ j ≤ ∑ g, posteriorAt φ f π N σ j g := by
        apply Finset.sum_le_sum
        intro g hg
        split_ifs
        · exact le_rfl
        · exact hp g
      _ = 1 := posteriorAt_sum_of_denominator_pos φ f π σ j hden

/-- This is a conclusion to prove for a constructed target and order.  The
existential width threshold is after the target/order and before the scale
limit.  Normalization positivity is included explicitly to exclude vacuous
zero-denominator interpretations. -/
def AllLargeWidthsFail {d : ℕ} (φ : ℝ → ℝ) (f : BooleanFunction d)
    (C : ℕ) (π : InputOrder d)
    (J : Finset (Fin (Fintype.card (Cube d)))) : Prop :=
  ∃ N₀ : ℕ, C ≤ N₀ ∧ 0 < N₀ ∧
    ∀ N : ℕ, N₀ ≤ N →
      (∀ σ : ℝ, 0 < σ → ∀ j, 0 < denominatorAt φ f π N σ j) ∧
      ∀ j ∈ J,
        Tendsto (fun σ : ℝ => correctAt φ f π N σ j)
          (𝓝[>] (0 : ℝ)) (𝓝 (0 : ℝ))

/-- Enlarging a specified teacher-width bound only enlarges the common
learner-width threshold; it does not change the target or input order. -/
theorem AllLargeWidthsFail.withTeacherWidth
    {d C : ℕ} {φ : ℝ → ℝ} {f : BooleanFunction d} {π : InputOrder d}
    {J : Finset (Fin (Fintype.card (Cube d)))}
    (hfail : AllLargeWidthsFail φ f C π J) (C' : ℕ) :
    AllLargeWidthsFail φ f C' π J := by
  obtain ⟨N₀, hCN₀, hN₀, hlarge⟩ := hfail
  refine ⟨max N₀ C', le_max_right _ _, hN₀.trans_le (le_max_left _ _), ?_⟩
  intro N hN
  exact hlarge N ((le_max_left _ _).trans hN)

end NeuralGeneralization.OnlineLower
