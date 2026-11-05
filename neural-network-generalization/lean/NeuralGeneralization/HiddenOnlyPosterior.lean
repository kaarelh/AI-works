import NeuralGeneralization.HiddenOnlyCompression
import NeuralGeneralization.PointwiseRobustSupport
import NeuralGeneralization.HiddenOnlyTarget
import NeuralGeneralization.BatchTwoImprovedGlobalPosterior

/-! The actual hidden-only Gaussian posterior, including optional all-input clean-margin conditioning. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal
namespace NeuralGeneralization.HiddenOnly
open ConcreteModel
variable {d C N r m n : ℕ}

def posteriorEvent (c : ℝ) (globalMargin : Bool) (f : BooleanFunction d)
    (S : Fin n → Cube d) : Set (Weights d N r) :=
  support Real.tanh c ∩ RobustPosterior.trainingMarginEvent Real.tanh f S ∩
    (if globalMargin then globalMarginEvent Real.tanh (1/2) else Set.univ)

def posterior (c σ : ℝ) (globalMargin : Bool) (f : BooleanFunction d)
    (S : Fin n → Cube d) : Measure (Weights d N r) :=
  cond (smallPrior d N r σ) (posteriorEvent c globalMargin f S)

lemma measurable_posteriorEvent {c : ℝ} (hc : 0 < c) (globalMargin : Bool)
    (f : BooleanFunction d) (S : Fin n → Cube d) :
    MeasurableSet (posteriorEvent (N := N) (r := r) c globalMargin f S) := by
  apply MeasurableSet.inter
  · exact (measurable_support tanh_continuous hc).inter
      (RobustPosterior.measurable_trainingMarginEvent tanh_continuous f S)
  · cases globalMargin
    · exact MeasurableSet.univ
    · exact BatchTwoImprovedGlobalPosterior.measurable_globalMarginEvent tanh_continuous

lemma target_subset (c : ℝ) (globalMargin : Bool) (f : BooleanFunction d)
    (S : Fin n → Cube d) :
    support (N := N) (r := r) Real.tanh c ∩ marginEvent Real.tanh (1/2) f ⊆
      posteriorEvent c globalMargin f S := by
  intro w hw
  refine ⟨⟨hw.1,fun i => hw.2 (S i)⟩,?_⟩
  cases globalMargin
  · trivial
  · exact marginEvent_subset_global Real.tanh (1/2) f hw.2

/-- Every labeled sample retains the actual target cylinder. -/
theorem posterior_target_mass (hd : 0 < d) (B : LayeredBooleanCircuit d C r) (hCN : C ≤ N)
    {c σ : ℝ} (hc : 0 < c) (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1)
    (globalMargin : Bool) (S : Fin n → Cube d) :
    Real.exp (-digitalMassPolynomial d C r c/σ^2) ≤
      (smallPrior d N r σ).real (posteriorEvent c globalMargin B.computes S) :=
  (target_mass hd B hCN hc hσ hscale).trans
    (measureReal_mono (target_subset c globalMargin B.computes S))

theorem posterior_probability (hd : 0 < d) (B : LayeredBooleanCircuit d C r) (hCN : C ≤ N)
    {c σ : ℝ} (hc : 0 < c) (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1)
    (globalMargin : Bool) (S : Fin n → Cube d) :
    IsProbabilityMeasure (posterior (N := N) (r := r) c σ globalMargin B.computes S) := by
  apply cond_isProbabilityMeasure
  have hp := (Real.exp_pos _).trans_le (posterior_target_mass hd B hCN hc hσ hscale globalMargin S)
  intro hz
  simp only [Measure.real,hz,ENNReal.toReal_zero] at hp
  exact (lt_irrefl 0) hp

/-- The literal Gaussian posterior entropy is bounded without an oracle. -/
theorem posterior_entropy (hd : 0 < d) (B : LayeredBooleanCircuit d C r) (hCN : C ≤ N)
    {c σ : ℝ} (hc : 0 < c) (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1)
    (globalMargin : Bool) (S : Fin n → Cube d) :
    klDiv (posterior (N := N) (r := r) c σ globalMargin B.computes S) (smallPrior d N r σ) ≤
      ENNReal.ofReal (digitalMassPolynomial d C r c/σ^2) := by
  apply RobustPosterior.klDiv_cond_le_of_mass_lower _ _ (measurable_posteriorEvent hc globalMargin B.computes S)
  simpa only [neg_div] using posterior_target_mass hd B hCN hc hσ hscale globalMargin S

/-- The learner is exactly prior support conditioning followed by the
unchanged strict training-margin likelihood. -/
theorem posterior_eq_two_stage {c : ℝ} (hc : 0 < c) (σ : ℝ) (globalMargin : Bool)
    (f : BooleanFunction d) (S : Fin n → Cube d) :
    posterior (N := N) (r := r) c σ globalMargin f S =
      cond (cond (smallPrior d N r σ)
        (support Real.tanh c ∩ (if globalMargin then globalMarginEvent Real.tanh (1/2) else Set.univ)))
        (RobustPosterior.trainingMarginEvent Real.tanh f S) := by
  have hg : MeasurableSet (if globalMargin then globalMarginEvent (d := d) (N := N) (r := r) Real.tanh (1/2) else Set.univ) := by
    cases globalMargin
    · exact MeasurableSet.univ
    · exact BatchTwoImprovedGlobalPosterior.measurable_globalMarginEvent tanh_continuous
  rw [cond_cond_eq_cond_inter ((measurable_support tanh_continuous hc).inter hg)
    (RobustPosterior.measurable_trainingMarginEvent tanh_continuous f S)]
  unfold posterior posteriorEvent
  congr 1
  ext w
  exact and_right_comm

end NeuralGeneralization.HiddenOnly
