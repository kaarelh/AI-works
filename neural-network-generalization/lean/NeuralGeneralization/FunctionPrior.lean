import NeuralGeneralization.Network
import NeuralGeneralization.FinitePosterior
import Mathlib.MeasureTheory.Measure.OpenPos
import Mathlib.Topology.Algebra.Ring.Real

/-!
# Function priors and posteriors of the actual finite network

The network architecture is concrete; its parameter measure is arbitrary.
`Model.lean` specializes it to the exact Gaussian priors in the manuscripts.
The strict global margin, sign-function masses, IID sample convention, and
strict confidence criterion are defined here without analytic assumptions.
-/

noncomputable section
open scoped BigOperators
open MeasureTheory

namespace NeuralGeneralization.ConcreteModel

theorem continuous_firstHidden {d N r : ℕ} {φ : ℝ → ℝ}
    (hφ : Continuous φ) (x : Cube d) (i : Fin N) :
    Continuous (fun w : Weights d N r => firstHidden φ w x i) := by
  apply hφ.comp
  exact continuous_finsetSum _ (fun j _ =>
    (continuous_apply (Sum.inl (i, j))).mul continuous_const)

theorem continuous_hiddenStep {d N r : ℕ} {φ : ℝ → ℝ}
    (hφ : Continuous φ) (H : Weights d N r → Fin N → ℝ)
    (hH : ∀ i, Continuous (fun w => H w i)) (s : Fin r) (i : Fin N) :
    Continuous (fun w => hiddenStep φ w (H w) s i) := by
  apply hφ.comp
  exact continuous_finsetSum _ (fun j _ =>
    (continuous_apply (Sum.inr (Sum.inl (s, i, j)))).mul (hH j))

theorem continuous_hiddenFold {d N r : ℕ} {φ : ℝ → ℝ}
    (hφ : Continuous φ) (ss : List (Fin r)) (H : Weights d N r → Fin N → ℝ)
    (hH : ∀ i, Continuous (fun w => H w i)) (i : Fin N) :
    Continuous (fun w => ss.foldl (hiddenStep φ w) (H w) i) := by
  induction ss generalizing H with
  | nil => exact hH i
  | cons s ss ih =>
    exact ih (fun w => hiddenStep φ w (H w) s)
      (continuous_hiddenStep hφ H hH s)

theorem continuous_finalHidden {d N r : ℕ} {φ : ℝ → ℝ}
    (hφ : Continuous φ) (x : Cube d) (i : Fin N) :
    Continuous (fun w : Weights d N r => finalHidden φ w x i) :=
  continuous_hiddenFold hφ _ (fun w => firstHidden φ w x)
    (continuous_firstHidden hφ x) i

theorem continuous_networkOutput {d N r : ℕ} {φ : ℝ → ℝ}
    (hφ : Continuous φ) (x : Cube d) :
    Continuous (fun w : Weights d N r => networkOutput φ w x) := by
  exact continuous_finsetSum _ (fun i _ =>
    (continuous_apply (Sum.inr (Sum.inr i))).mul (continuous_finalHidden hφ x i))

theorem isOpen_marginEvent {d N r : ℕ} {φ : ℝ → ℝ} (hφ : Continuous φ)
    (a : ℝ) (f : BooleanFunction d) :
    IsOpen (marginEvent (N := N) (r := r) φ a f) := by
  have hset : marginEvent (N := N) (r := r) φ a f =
      ⋂ x : Cube d, {w | a < labelReal (f x) * networkOutput φ w x} := by
    ext w
    simp [marginEvent]
  rw [hset]
  exact isOpen_iInter_of_finite (fun x =>
    isOpen_lt continuous_const (continuous_const.mul (continuous_networkOutput hφ x)))

/-- Unnormalized mass of one sign function under the actual Gaussian law. -/
def functionMass {d N r : ℕ} (φ : ℝ → ℝ) (a : ℝ)
    (μ : Measure (Weights d N r)) (g : BooleanFunction d) : ℝ :=
  (μ (marginEvent φ a g)).toReal

theorem functionMass_nonneg {d N r : ℕ} (φ : ℝ → ℝ) (a : ℝ)
    (μ : Measure (Weights d N r)) (g : BooleanFunction d) :
    0 ≤ functionMass φ a μ g := ENNReal.toReal_nonneg

/-- The function law after imposing the absolute margin on the entire cube. -/
def globalConditionedFunctionPrior {d N r : ℕ} (φ : ℝ → ℝ) (a : ℝ)
    (μ : Measure (Weights d N r)) (g : BooleanFunction d) : ℝ :=
  functionMass φ a μ g / (μ (globalMarginEvent φ a)).toReal

def consistent {d n : ℕ} (f : BooleanFunction d)
    (sample : Fin n → Cube d) (g : BooleanFunction d) : Prop :=
  ∀ i, g (sample i) = f (sample i)

instance consistent_decidablePred {d n : ℕ} (f : BooleanFunction d)
    (sample : Fin n → Cube d) : DecidablePred (consistent f sample) :=
  Classical.decPred _

/-- Normalizing only after consistency also cancels the global-margin normalizer. -/
def networkPosterior {d N r n : ℕ} (φ : ℝ → ℝ) (a : ℝ)
    (μ : Measure (Weights d N r)) (f : BooleanFunction d)
    (sample : Fin n → Cube d) : BooleanFunction d → ℝ := by
  classical
  exact NeuralGeneralization.posterior (functionMass φ a μ) (consistent f sample)

def posteriorDenominator {d N r n : ℕ} (φ : ℝ → ℝ) (a : ℝ)
    (μ : Measure (Weights d N r)) (f : BooleanFunction d)
    (sample : Fin n → Cube d) : ℝ := by
  classical
  exact NeuralGeneralization.normalizer (functionMass φ a μ) (consistent f sample)

theorem posteriorDenominator_pos {d N r n : ℕ} (φ : ℝ → ℝ) (a : ℝ)
    (μ : Measure (Weights d N r)) (f : BooleanFunction d)
    (sample : Fin n → Cube d) (hf : 0 < functionMass φ a μ f) :
    0 < posteriorDenominator φ a μ f sample := by
  classical
  exact NeuralGeneralization.normalizer_pos (functionMass φ a μ)
    (consistent f sample) (functionMass_nonneg φ a μ) f (fun _ => rfl) hf

theorem networkPosterior_sum {d N r n : ℕ} (φ : ℝ → ℝ) (a : ℝ)
    (μ : Measure (Weights d N r)) (f : BooleanFunction d)
    (sample : Fin n → Cube d) (hf : 0 < functionMass φ a μ f) :
    ∑ g, networkPosterior φ a μ f sample g = 1 := by
  classical
  exact NeuralGeneralization.posterior_sum (functionMass φ a μ)
    (consistent f sample) (functionMass_nonneg φ a μ) f (fun _ => rfl) hf

/-- An arbitrary probability distribution on the finite input cube. -/
structure InputLaw (d : ℕ) where
  mass : Cube d → ℝ
  nonneg : ∀ x, 0 ≤ mass x
  sum_one : ∑ x, mass x = 1

def uniformLaw (d : ℕ) : InputLaw d where
  mass := fun _ => (Fintype.card (Cube d) : ℝ)⁻¹
  nonneg := fun _ => inv_nonneg.mpr (Nat.cast_nonneg _)
  sum_one := by simp

def functionError {d : ℕ} (D : InputLaw d) (f g : BooleanFunction d) : ℝ :=
  ∑ x, if g x = f x then 0 else D.mass x

def posteriorRisk {d : ℕ} (D : InputLaw d) (f : BooleanFunction d)
    (p : BooleanFunction d → ℝ) : ℝ :=
  ∑ g, p g * functionError D f g

def correctConfidence {d : ℕ} (f : BooleanFunction d)
    (p : BooleanFunction d → ℝ) (x : Cube d) : ℝ :=
  ∑ g, if g x = f x then p g else 0

/-- Equality with `2/3` is a failure, exactly as requested. -/
def confidenceFailure {d : ℕ} (D : InputLaw d) (f : BooleanFunction d)
    (p : BooleanFunction d → ℝ) : ℝ := by
  classical
  exact ∑ x, if correctConfidence f p x ≤ (2 : ℝ) / 3 then D.mass x else 0

/-- The exact finite product probability of an event of `n` IID training inputs. -/
def sampleProbability {d : ℕ} (D : InputLaw d) (n : ℕ)
    (E : (Fin n → Cube d) → Prop) : ℝ := by
  classical
  exact ∑ s, if E s then ∏ i, D.mass (s i) else 0

theorem sampleProbability_true {d : ℕ} (D : InputLaw d) (n : ℕ) :
    sampleProbability D n (fun _ => True) = 1 := by
  classical
  simp only [sampleProbability, if_pos True.intro]
  rw [← Fintype.sum_pow, D.sum_one, one_pow]

theorem sampleProbability_nonneg {d : ℕ} (D : InputLaw d) (n : ℕ)
    (E : (Fin n → Cube d) → Prop) : 0 ≤ sampleProbability D n E := by
  classical
  apply Finset.sum_nonneg
  intro s _
  split_ifs
  · exact Finset.prod_nonneg (fun i _ => D.nonneg (s i))
  · exact le_refl 0

theorem sampleProbability_le_one {d : ℕ} (D : InputLaw d) (n : ℕ)
    (E : (Fin n → Cube d) → Prop) : sampleProbability D n E ≤ 1 := by
  classical
  calc
    sampleProbability D n E ≤ sampleProbability D n (fun _ => True) := by
      apply Finset.sum_le_sum
      intro s _
      simp only [if_pos True.intro]
      split_ifs
      · exact le_refl _
      · exact Finset.prod_nonneg (fun i _ => D.nonneg (s i))
    _ = 1 := sampleProbability_true D n

/-- The parity label is `+1` precisely when the product of input signs is `+1`. -/
def parity (d : ℕ) : BooleanFunction d :=
  fun x => decide ((∏ i, if x i then (1 : ℤ) else -1) = 1)

end NeuralGeneralization.ConcreteModel
