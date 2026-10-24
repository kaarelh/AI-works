import NeuralGeneralization.BatchTwoCircuitConverseDeterministic
import Mathlib.MeasureTheory.Integral.Bochner.Basic

/-!
# Minimum-action learning and exact exception repairs

This file proves the finite-hypothesis potential argument used by the neural
converse. The analytic neural implementation of its repair inequality is a
separate obligation; this lemma does not assert that arbitrary NN priors have it.
-/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
open Classical
open scoped BigOperators
open MeasureTheory

variable {X : Type*} [Fintype X]

def Fits (g f : X → Bool) (A : Finset X) : Prop := ∀ x ∈ A, g x = f x

def version (f : X → Bool) (A : Finset X) : Finset (X → Bool) :=
  Finset.univ.filter (fun g => Fits g f A)

theorem mem_version (f g : X → Bool) (A : Finset X) : g ∈ version f A ↔ Fits g f A := by
  simp [version]

theorem version_nonempty (f : X → Bool) (A : Finset X) : (version f A).Nonempty :=
  ⟨f, (mem_version f f A).mpr (fun _ _ => rfl)⟩

theorem exists_min_action (R : (X → Bool) → ℝ) (f : X → Bool) (A : Finset X) :
    ∃ g, Fits g f A ∧ ∀ h, Fits h f A → R g ≤ R h := by
  obtain ⟨g, hg, hmin⟩ := Finset.exists_min_image (version f A) R (version_nonempty f A)
  exact ⟨g, (mem_version f g A).mp hg,
    fun h hh => hmin h ((mem_version f h A).mpr hh)⟩

def minimizer (R : (X → Bool) → ℝ) (f : X → Bool) (A : Finset X) : X → Bool :=
  Classical.choose (exists_min_action R f A)

def minAction (R : (X → Bool) → ℝ) (f : X → Bool) (A : Finset X) : ℝ :=
  R (minimizer R f A)

theorem minimizer_fits (R : (X → Bool) → ℝ) (f : X → Bool) (A : Finset X) :
    Fits (minimizer R f A) f A := (Classical.choose_spec (exists_min_action R f A)).1

theorem minAction_le (R : (X → Bool) → ℝ) (f g : X → Bool) (A : Finset X)
    (hg : Fits g f A) : minAction R f A ≤ R g :=
  (Classical.choose_spec (exists_min_action R f A)).2 g hg

theorem minAction_univ (R : (X → Bool) → ℝ) (f : X → Bool) :
    minAction R f Finset.univ = R f := by
  have he : minimizer R f Finset.univ = f := by
    funext x
    exact minimizer_fits R f _ x (Finset.mem_univ x)
  simp only [minAction, he]

theorem fits_update (f g : X → Bool) (A : Finset X) (hg : Fits g f A) (a : X) :
    Fits (Function.update g a (f a)) f (insert a A) := by
  intro x hx
  rcases Finset.mem_insert.mp hx with rfl | hx
  · simp
  · by_cases he : x = a
    · subst x; simp
    · rw [Function.update_of_ne he]
      exact hg x hx

def observed (query : ℕ → X) (t : ℕ) : Finset X := (Finset.range t).image query

@[simp] theorem observed_zero (query : ℕ → X) : observed query 0 = ∅ := by simp [observed]
@[simp] theorem observed_succ (query : ℕ → X) (t : ℕ) :
    observed query (t+1) = insert (query t) (observed query t) := by
  simp [observed, Finset.range_add_one]

def errorCount (error : ℕ → Bool) (t : ℕ) : ℕ :=
  ∑ i ∈ Finset.range t, if error i then 1 else 0

@[simp] theorem errorCount_zero (error : ℕ → Bool) : errorCount error 0 = 0 := by simp [errorCount]
@[simp] theorem errorCount_succ (error : ℕ → Bool) (t : ℕ) :
    errorCount error (t+1) = errorCount error t + if error t then 1 else 0 := by
  unfold errorCount
  rw [Finset.sum_range_succ]

/-- A successful prediction has a correct-label member among the current
minimizers. This is shared by posterior sampling, majority, and every positive
posterior-confidence threshold. Tied minimizers are unrestricted. -/
def SuccessHasMinimizer (R : (X → Bool) → ℝ) (f : X → Bool)
    (query : ℕ → X) (error : ℕ → Bool) : Prop :=
  ∀ t, error t = false → ∃ g, Fits g f (observed query t) ∧
    R g = minAction R f (observed query t) ∧ g (query t) = f (query t)

theorem minimum_action_pathwise (R : (X → Bool) → ℝ) (f : X → Bool)
    (query : ℕ → X) (error : ℕ → Bool) {b : ℝ}
    (hrepair : ∀ g a y, R (Function.update g a y) ≤ R g+b)
    (hsuccess : SuccessHasMinimizer R f query error) (t : ℕ) :
    minAction R f (observed query t) ≤ minAction R f ∅+b*(errorCount error t : ℝ) := by
  induction t with
  | zero => simp
  | succ t ih =>
      rw [observed_succ, errorCount_succ]
      cases he : error t with
      | false =>
          obtain ⟨g, hfit, hmin, hcorrect⟩ := hsuccess t he
          have hfit' : Fits g f (insert (query t) (observed query t)) := by
            intro x hx
            rcases Finset.mem_insert.mp hx with rfl | hx
            · exact hcorrect
            · exact hfit x hx
          have hle := minAction_le R f g _ hfit'
          rw [hmin] at hle
          simpa only [Bool.false_eq_true, ↓reduceIte, add_zero] using hle.trans ih
      | true =>
          let g := minimizer R f (observed query t)
          have hle := minAction_le R f (Function.update g (query t) (f (query t))) _
            (fits_update f g _ (minimizer_fits R f _) (query t))
          have hr := hrepair g (query t) (f (query t))
          change R (Function.update g (query t) (f (query t))) ≤
            minAction R f (observed query t)+b at hr
          simp only [↓reduceIte, Nat.cast_add, Nat.cast_one]
          nlinarith

theorem minimum_action_complete (R : (X → Bool) → ℝ) (f : X → Bool)
    (query : ℕ → X) (error : ℕ → Bool) {b a₀ : ℝ}
    (hrepair : ∀ g a y, R (Function.update g a y) ≤ R g+b)
    (hsuccess : SuccessHasMinimizer R f query error) (hinitial : minAction R f ∅ ≤ a₀)
    (t : ℕ) (hcover : observed query t = Finset.univ) :
    R f ≤ a₀+b*(errorCount error t : ℝ) := by
  have h := minimum_action_pathwise R f query error hrepair hsuccess t
  rw [hcover, minAction_univ] at h
  linarith

/-- Taking expectations acts on the linear square-root action inequality,
before squaring. No reversed Jensen inequality is used. -/
theorem expected_action_bound {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) [IsProbabilityMeasure μ] (R : (X → Bool) → ℝ) (f : X → Bool)
    (query : Ω → ℕ → X) (error : Ω → ℕ → Bool) (stop : Ω → ℕ) {b a₀ : ℝ}
    (hrepair : ∀ g a y, R (Function.update g a y) ≤ R g+b)
    (hsuccess : ∀ᵐ ω ∂μ, SuccessHasMinimizer R f (query ω) (error ω))
    (hcover : ∀ᵐ ω ∂μ, observed (query ω) (stop ω) = Finset.univ)
    (hinitial : minAction R f ∅ ≤ a₀)
    (hint : Integrable (fun ω => (errorCount (error ω) (stop ω) : ℝ)) μ) :
    R f ≤ a₀+b*(∫ ω, (errorCount (error ω) (stop ω) : ℝ) ∂μ) := by
  have hpoint : ∀ᵐ ω ∂μ, R f ≤ a₀+b*(errorCount (error ω) (stop ω) : ℝ) := by
    filter_upwards [hsuccess, hcover] with ω hs hc
    exact minimum_action_complete R f (query ω) (error ω) hrepair hs hinitial (stop ω) hc
  have hi := integral_mono_ae (integrable_const (R f)) ((integrable_const a₀).add (hint.const_mul b)) hpoint
  simp only [Pi.add_apply] at hi
  rw [integral_add (integrable_const a₀) (hint.const_mul b), integral_const_mul] at hi
  simpa only [integral_const, probReal_univ, smul_eq_mul, one_mul] using hi

end
end NeuralGeneralization.BatchTwoNeuralConverse
