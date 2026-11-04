import NeuralGeneralization.RobustPosterior
import NeuralGeneralization.MonotoneScoreSupport
import NeuralGeneralization.RobustLocalizedPosterior
import NeuralGeneralization.FiniteUnionConditioning
import NeuralGeneralization.PointwiseRobustSupport
import NeuralGeneralization.RobustTargetAllWidths

/-! The literal transformed-score Gaussian conditioned on the union of admissible exceptional
regions, followed by all training-margin constraints. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
namespace NeuralGeneralization.ScoreTransform.Localized
open ConcreteModel RobustPosterior RobustStatistics FiniteUnionConditioning
variable {d C N r M m n : ℕ} {F : ℝ → ℝ}

abbrev exceptionLoss := @RobustLocalized.exceptionLoss

def witnessEvent (F : ℝ → ℝ) (B : Fin M → Set (Cube d)) (c ρ : ℝ) (f : BooleanFunction d)
    (V : Fin m → Cube d) (S : Fin n → Cube d) (j : Fin M) : Set (Weights d N r) :=
  {w | empiricalLoss (exceptionLoss B) V j ≤ ρ ∧
    (∀ x, x ∉ B j → atInput F Real.tanh c w x) ∧ w ∈ trainingMarginEvent Real.tanh f S}

def posteriorEvent (F : ℝ → ℝ) (B : Fin M → Set (Cube d)) (c ρ : ℝ) (f : BooleanFunction d)
    (V : Fin m → Cube d) (S : Fin n → Cube d) : Set (Weights d N r) :=
  ⋃ j, witnessEvent F B c ρ f V S j

def posterior (F : ℝ → ℝ) (B : Fin M → Set (Cube d)) (c ρ σ : ℝ) (f : BooleanFunction d)
    (V : Fin m → Cube d) (S : Fin n → Cube d) : Measure (Weights d N r) :=
  cond (smallPrior d N r σ) (posteriorEvent F B c ρ f V S)

lemma measurable_witnessEvent (hF : Admissible F) (B : Fin M → Set (Cube d)) {c : ℝ} (hc : 0 < c)
    (ρ : ℝ) (f : BooleanFunction d) (V : Fin m → Cube d) (S : Fin n → Cube d) (j : Fin M) :
    MeasurableSet (witnessEvent (N := N) (r := r) F B c ρ f V S j) := by
  unfold witnessEvent
  apply MeasurableSet.inter (MeasurableSet.const _)
  apply MeasurableSet.inter
  · change MeasurableSet {w : Weights d N r | ∀ x, x ∉ B j → atInput F Real.tanh c w x}
    simp only [Set.setOf_forall]
    exact MeasurableSet.iInter fun x => MeasurableSet.iInter fun _ =>
      (isClosed_atInput hF tanh_continuous hc x).measurableSet
  · exact measurable_trainingMarginEvent tanh_continuous f S

lemma measurable_posteriorEvent (hF : Admissible F) (B : Fin M → Set (Cube d)) {c : ℝ} (hc : 0 < c)
    (ρ : ℝ) (f : BooleanFunction d) (V : Fin m → Cube d) (S : Fin n → Cube d) :
    MeasurableSet (posteriorEvent (N := N) (r := r) F B c ρ f V S) :=
  MeasurableSet.iUnion (measurable_witnessEvent hF B hc ρ f V S)

lemma target_subset (B : Fin M → Set (Cube d)) (j0 : Fin M) (hzero : B j0 = ∅)
    {ρ : ℝ} (hρ : 0 ≤ ρ) (c : ℝ) (f : BooleanFunction d)
    (V : Fin m → Cube d) (S : Fin n → Cube d) :
    support (N := N) (r := r) F Real.tanh c ∩ marginEvent Real.tanh (1/2) f ⊆
      posteriorEvent F B c ρ f V S := by
  classical
  intro w hw
  apply Set.mem_iUnion.mpr
  refine ⟨j0,?_,fun x _ => hw.1 x,fun i => hw.2 (S i)⟩
  simpa [empiricalLoss,exceptionLoss,RobustLocalized.exceptionLoss,hzero] using hρ

theorem target_mass (hF : Admissible F) (hd : 0 < d) (T : LayeredBooleanCircuit d C r) (hCN : C ≤ N)
    (B : Fin M → Set (Cube d)) (j0 : Fin M) (hzero : B j0 = ∅)
    {c ρ σ : ℝ} (hc : 0 < c) (hρ : 0 ≤ ρ) (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1)
    (V : Fin m → Cube d) (S : Fin n → Cube d) :
    Real.exp (-digitalMassPolynomial d C r c/σ^2) ≤
      (smallPrior d N r σ).real (posteriorEvent F B c ρ T.computes V S) :=
  (ScoreTransform.target_mass hF hd T hCN hc hσ hscale).trans
    (measureReal_mono (target_subset B j0 hzero hρ c T.computes V S))

theorem posterior_probability (hF : Admissible F) (hd : 0 < d) (T : LayeredBooleanCircuit d C r) (hCN : C ≤ N)
    (B : Fin M → Set (Cube d)) (j0 : Fin M) (hzero : B j0 = ∅)
    {c ρ σ : ℝ} (hc : 0 < c) (hρ : 0 ≤ ρ) (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1)
    (V : Fin m → Cube d) (S : Fin n → Cube d) :
    IsProbabilityMeasure (posterior (N := N) (r := r) F B c ρ σ T.computes V S) := by
  apply cond_isProbabilityMeasure
  intro hz
  have hp := (Real.exp_pos _).trans_le (target_mass hF hd T hCN B j0 hzero hc hρ hσ hscale V S)
  simp only [Measure.real,hz,ENNReal.toReal_zero] at hp
  exact (lt_irrefl 0) hp

theorem posterior_entropy (hF : Admissible F) (hd : 0 < d) (T : LayeredBooleanCircuit d C r) (hCN : C ≤ N)
    (B : Fin M → Set (Cube d)) (j0 : Fin M) (hzero : B j0 = ∅)
    {c ρ σ : ℝ} (hc : 0 < c) (hρ : 0 ≤ ρ) (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1)
    (V : Fin m → Cube d) (S : Fin n → Cube d) :
    klDiv (posterior (N := N) (r := r) F B c ρ σ T.computes V S) (smallPrior d N r σ) ≤
      ENNReal.ofReal (digitalMassPolynomial d C r c/σ^2) := by
  apply klDiv_cond_le_of_mass_lower _ _ (measurable_posteriorEvent hF B hc ρ T.computes V S)
  simpa only [neg_div] using target_mass hF hd T hCN B j0 hzero hc hρ hσ hscale V S

end NeuralGeneralization.ScoreTransform.Localized
