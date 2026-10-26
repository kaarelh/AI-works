import NeuralGeneralization.ModelFacts
import FiniteReductionConverse

/-!
# Concrete-posterior interfaces for the conditional lower-bound reduction

These lemmas use the actual Gaussian neural-network posterior. They verify its
normalization and the passage from positive sample-success probability to a
successful sample. They do not prove that most posterior mass is carried by a
small parallel-circuit class; that separate analytic theorem remains required.
-/

noncomputable section
attribute [local instance] Classical.propDecidable
open MeasureTheory
open scoped BigOperators
namespace ConditionalNonpolynomial
open NeuralGeneralization.ConcreteModel

/-- The concrete posterior has nonnegative function weights whenever the
realizable target has positive raw Gaussian mass. -/
theorem actualPosterior_nonneg {d N r n : ℕ} (φ : ℝ → ℝ) (a : ℝ)
    (μ : Measure (Weights d N r)) (f : BooleanFunction d)
    (s : Fin n → Cube d) (hf : 0 < functionMass φ a μ f)
    (g : BooleanFunction d) : 0 ≤ networkPosterior φ a μ f s g := by
  classical
  exact NeuralGeneralization.posterior_nonneg (functionMass φ a μ)
    (consistent f s) (functionMass_nonneg φ a μ) f (fun _ => rfl) hf g

/-- Positive iid success probability implies existence of an actual successful
sample. This is only finite-support probability algebra, not an assumption of
an abstract sample-selection oracle. -/
theorem exists_successful_sample {d n : ℕ} (D : InputLaw d)
    (E : (Fin n → Cube d) → Prop)
    (h : 0 < sampleProbability D n E) : ∃ s, E s := by
  classical
  by_contra hnone
  push Not at hnone
  have hz : sampleProbability D n E = 0 := by
    simp [sampleProbability, hnone]
  linarith

/-- In the original Gaussian model all posterior weights are nonnegative and
sum to one at every width above a realizing teacher's complexity. -/
theorem gaussianPosterior_probability {d C N r n : ℕ} (hd : 0 < d)
    {σ : ℝ} (hσ : 0 < σ) (f : BooleanFunction d)
    (hc : realizesAtComplexity (r := r) Real.tanh f C) (hCN : C ≤ N)
    (s : Fin n → Cube d) :
    (∀ g, 0 ≤ networkPosterior Real.tanh (1/2) (smallPrior d N r σ) f s g) ∧
      ∑ g, networkPosterior Real.tanh (1/2) (smallPrior d N r σ) f s g = 1 := by
  have hf := small_functionMass_pos hd tanh_continuous f hc hCN hσ
  exact ⟨actualPosterior_nonneg Real.tanh (1/2) (smallPrior d N r σ) f s hf,
    networkPosterior_sum Real.tanh (1/2) (smallPrior d N r σ) f s hf⟩

/-- The generic and concrete individual-error conventions coincide exactly. -/
lemma actual_hypothesisError {d : ℕ} (D : InputLaw d) (f g : BooleanFunction d) :
    NeuralGeneralization.hypothesisError D.mass (fun h x => h x) f g =
      weightedError f g D.mass := by
  classical
  unfold NeuralGeneralization.hypothesisError weightedError
  apply Finset.sum_congr rfl
  intro x _
  by_cases h : g x = f x <;> simp [h]

/-- A successful actual posterior with the explicit circuit-class mass premise
contains one weak predictor from that class. The premise is intentionally
visible: this lemma does not prove the analytic posterior circuit ceiling. -/
theorem actualPosterior_extract_weak {d N r n : ℕ} (φ : ℝ → ℝ) (a : ℝ)
    (μ : Measure (Weights d N r)) (f : BooleanFunction d)
    (s : Fin n → Cube d) (hf : 0 < functionMass φ a μ f)
    (D : InputLaw d) (H : Set (BooleanFunction d))
    (hceiling : (5/6:ℝ) ≤ ∑ g, if g ∈ H then networkPosterior φ a μ f s g else 0)
    (hsuccess : NeuralGeneralization.ConcreteModel.confidenceFailure D f (networkPosterior φ a μ f s) ≤ (1/16:ℝ)) :
    ∃ g ∈ H, functionError D f g ≤ (9/20:ℝ) := by
  classical
  let p := networkPosterior φ a μ f s
  have hp : ∀ g, 0 ≤ p g := actualPosterior_nonneg φ a μ f s hf
  have hpsum : ∑ g, p g = 1 := networkPosterior_sum φ a μ f s hf
  have hr := NeuralGeneralization.risk_le_one_third_add_failure
    p D.mass (fun g x => g x) f hp hpsum D.nonneg D.sum_one
  rw [NeuralGeneralization.averageRisk_eq_sum_hypothesis] at hr
  simp_rw [actual_hypothesisError] at hr
  have hconf : NeuralGeneralization.confidenceFailure p D.mass (fun g x => g x) f =
      NeuralGeneralization.ConcreteModel.confidenceFailure D f p := rfl
  rw [hconf] at hr
  have hrisk : (∑ g, p g * weightedError f g D.mass) ≤ (3/8:ℝ) := by
    change NeuralGeneralization.ConcreteModel.confidenceFailure D f p ≤ (1/16:ℝ) at hsuccess
    linarith
  obtain ⟨g,hg,he⟩ := posterior_extract_weak f (fun g => g) p D.mass
    (fun g => g ∈ H) hp D.nonneg hceiling hrisk
  exact ⟨g,hg,he⟩

/-- The actual iid success event yields a weak predictor, using the actual
Gaussian posterior and the explicit common-class mass premise. -/
theorem gaussian_success_implies_weak {d C N r n : ℕ} (hd : 0 < d)
    {σ : ℝ} (hσ : 0 < σ) (f : BooleanFunction d)
    (hc : realizesAtComplexity (r := r) Real.tanh f C) (hCN : C ≤ N)
    (D : InputLaw d) (H : Set (BooleanFunction d))
    (hceiling : ∀ s : Fin n → Cube d,
      (5/6:ℝ) ≤ ∑ g, if g ∈ H then
        networkPosterior Real.tanh (1/2) (smallPrior d N r σ) f s g else 0)
    (hsuccess : 0 < sampleProbability D n (fun s =>
      NeuralGeneralization.ConcreteModel.confidenceFailure D f
        (networkPosterior Real.tanh (1/2) (smallPrior d N r σ) f s) ≤ (1/16:ℝ))) :
    ∃ g ∈ H, functionError D f g ≤ (9/20:ℝ) := by
  obtain ⟨s,hs⟩ := exists_successful_sample D _ hsuccess
  have hf := small_functionMass_pos hd tanh_continuous f hc hCN hσ
  exact actualPosterior_extract_weak Real.tanh (1/2) (smallPrior d N r σ)
    f s hf D H (hceiling s) hs

/-- Complete distribution-free reduction for the actual finite-width Gaussian
posterior. The class H is fixed before the input law. The analytic ceiling
remains an explicit premise rather than an unproved axiom. -/
theorem gaussian_learning_implies_exact_majority {d C N r n : ℕ} (hd : 0 < d)
    {σ : ℝ} (hσ : 0 < σ) (f : BooleanFunction d)
    (hc : realizesAtComplexity (r := r) Real.tanh f C) (hCN : C ≤ N)
    (H : Set (BooleanFunction d))
    (hceiling : ∀ s : Fin n → Cube d,
      (5/6:ℝ) ≤ ∑ g, if g ∈ H then
        networkPosterior Real.tanh (1/2) (smallPrior d N r σ) f s g else 0)
    (hsuccess : ∀ D : InputLaw d, 0 < sampleProbability D n (fun s =>
      NeuralGeneralization.ConcreteModel.confidenceFailure D f
        (networkPosterior Real.tanh (1/2) (smallPrior d N r σ) f s) ≤ (1/16:ℝ))) :
    ∃ gs : Fin (400*(d+1)) → BooleanFunction d,
      (∀ i, gs i ∈ H) ∧ ∀ x, 0 < ∑ i, signedVote f (gs i) x := by
  have hweak : WeakClass f H := by
    apply weakClass_of_normalized
    intro D hD hsum
    let law : InputLaw d := ⟨D,hD,hsum⟩
    exact gaussian_success_implies_weak hd hσ f hc hCN law H hceiling (hsuccess law)
  exact weakClass_exact_majority f H hweak d (by simp)

/-- Failure of the finite exact-majority conclusion produces one input law
under which every constituent is a bad weak predictor. This is the elementary
boosting contrapositive, with an actual finite probability distribution. -/
theorem exists_hard_inputLaw_of_no_majority {d : ℕ} (f : BooleanFunction d)
    (H : Set (BooleanFunction d))
    (hno : ¬ ∃ gs : Fin (400*(d+1)) → BooleanFunction d,
      (∀ i, gs i ∈ H) ∧ ∀ x, 0 < ∑ i, signedVote f (gs i) x) :
    ∃ D : InputLaw d, ∀ g ∈ H, (9/20:ℝ) < functionError D f g := by
  classical
  by_contra hneg
  push Not at hneg
  have hweak : WeakClass f H := by
    apply weakClass_of_normalized
    intro D hD hsum
    exact hneg (⟨D,hD,hsum⟩ : InputLaw d)
  exact hno (weakClass_exact_majority f H hweak d (by simp))

/-- Under the stated analytic class-mass premise, the hard law defeats every
sample, not merely a positive fraction of randomly drawn samples. -/
theorem gaussian_hard_law_every_sample {d C N r n : ℕ} (hd : 0 < d)
    {σ : ℝ} (hσ : 0 < σ) (f : BooleanFunction d)
    (hc : realizesAtComplexity (r := r) Real.tanh f C) (hCN : C ≤ N)
    (H : Set (BooleanFunction d))
    (hceiling : ∀ s : Fin n → Cube d,
      (5/6:ℝ) ≤ ∑ g, if g ∈ H then
        networkPosterior Real.tanh (1/2) (smallPrior d N r σ) f s g else 0)
    (hno : ¬ ∃ gs : Fin (400*(d+1)) → BooleanFunction d,
      (∀ i, gs i ∈ H) ∧ ∀ x, 0 < ∑ i, signedVote f (gs i) x) :
    ∃ D : InputLaw d, ∀ s : Fin n → Cube d,
      (1/16:ℝ) < NeuralGeneralization.ConcreteModel.confidenceFailure D f
        (networkPosterior Real.tanh (1/2) (smallPrior d N r σ) f s) := by
  obtain ⟨D,hD⟩ := exists_hard_inputLaw_of_no_majority f H hno
  refine ⟨D,?_⟩
  intro s
  by_contra hn
  have hfail := le_of_not_gt hn
  have hf := small_functionMass_pos hd tanh_continuous f hc hCN hσ
  obtain ⟨g,hg,he⟩ := actualPosterior_extract_weak Real.tanh (1/2)
    (smallPrior d N r σ) f s hf D H (hceiling s) hfail
  exact (not_le_of_gt (hD g hg)) he

#print axioms gaussian_learning_implies_exact_majority
#print axioms exists_hard_inputLaw_of_no_majority
#print axioms gaussian_hard_law_every_sample
#print axioms actualPosterior_extract_weak
#print axioms gaussian_success_implies_weak
#print axioms gaussianPosterior_probability
#print axioms exists_successful_sample
end ConditionalNonpolynomial
