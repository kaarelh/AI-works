import NeuralGeneralization.GeneralTwoMarginCompression
import NeuralGeneralization.GeneralMarginPosterior
import NeuralGeneralization.PointwiseRobustSupport
import NeuralGeneralization.RobustTargetAllWidths
import NeuralGeneralization.BatchTwoImprovedGlobalPosterior

/-! The actual general two-margin Gaussian posterior, including optional all-input clean-margin conditioning. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal
namespace NeuralGeneralization.GeneralTwoMargin
open ConcreteModel
open GeneralMargin (trainingEvent measurable_trainingEvent measurable_global_margin)
variable {d C N r n : ℕ} {m u θ : ℝ}

def posteriorEvent (m u θ : ℝ) (c : ℝ) (globalMargin : Bool) (f : BooleanFunction d)
    (S : Fin n → Cube d) : Set (Weights d N r) :=
  support m u θ Real.tanh c ∩ trainingEvent m Real.tanh f S ∩
    (if globalMargin then globalMarginEvent Real.tanh m else Set.univ)

def posterior (m u θ : ℝ) (c σ : ℝ) (globalMargin : Bool) (f : BooleanFunction d)
    (S : Fin n → Cube d) : Measure (Weights d N r) :=
  cond (smallPrior d N r σ) (posteriorEvent m u θ c globalMargin f S)

lemma measurable_posteriorEvent (hF : Parameters m u θ) {c : ℝ} (hc : 0 < c) (globalMargin : Bool)
    (f : BooleanFunction d) (S : Fin n → Cube d) :
    MeasurableSet (posteriorEvent (N := N) (r := r) m u θ c globalMargin f S) := by
  apply MeasurableSet.inter
  · exact (measurable_support m u θ tanh_continuous hc).inter
      (measurable_trainingEvent m tanh_continuous f S)
  · cases globalMargin
    · exact MeasurableSet.univ
    · exact measurable_global_margin m tanh_continuous

lemma target_subset (c : ℝ) (globalMargin : Bool) (f : BooleanFunction d)
    (S : Fin n → Cube d) :
    support (N := N) (r := r) m u θ Real.tanh c ∩ marginEvent Real.tanh m f ⊆
      posteriorEvent m u θ c globalMargin f S := by
  intro w hw
  refine ⟨⟨hw.1,fun i => hw.2 (S i)⟩,?_⟩
  cases globalMargin
  · trivial
  · exact marginEvent_subset_global Real.tanh m f hw.2

/-- Every labeled sample retains the actual target cylinder. -/
theorem posterior_target_mass (hF : Parameters m u θ) (hd : 0 < d) (B : LayeredBooleanCircuit d C r) (hCN : C ≤ N)
    {c σ : ℝ} (hc : 0 < c) (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1)
    (globalMargin : Bool) (S : Fin n → Cube d) :
    Real.exp (-digitalMassPolynomial d C r (c+m+1)/σ^2) ≤
      (smallPrior d N r σ).real (posteriorEvent m u θ c globalMargin B.computes S) :=
  (target_mass hF hd B hCN hc hσ hscale).trans
    (measureReal_mono (target_subset c globalMargin B.computes S))

theorem posterior_probability (hF : Parameters m u θ) (hd : 0 < d) (B : LayeredBooleanCircuit d C r) (hCN : C ≤ N)
    {c σ : ℝ} (hc : 0 < c) (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1)
    (globalMargin : Bool) (S : Fin n → Cube d) :
    IsProbabilityMeasure (posterior (N := N) (r := r) m u θ c σ globalMargin B.computes S) := by
  apply cond_isProbabilityMeasure
  have hp := (Real.exp_pos _).trans_le (posterior_target_mass hF hd B hCN hc hσ hscale globalMargin S)
  intro hz
  simp only [Measure.real,hz,ENNReal.toReal_zero] at hp
  exact (lt_irrefl 0) hp

/-- The literal Gaussian posterior entropy is bounded without an oracle. -/
theorem posterior_entropy (hF : Parameters m u θ) (hd : 0 < d) (B : LayeredBooleanCircuit d C r) (hCN : C ≤ N)
    {c σ : ℝ} (hc : 0 < c) (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1)
    (globalMargin : Bool) (S : Fin n → Cube d) :
    klDiv (posterior (N := N) (r := r) m u θ c σ globalMargin B.computes S) (smallPrior d N r σ) ≤
      ENNReal.ofReal (digitalMassPolynomial d C r (c+m+1)/σ^2) := by
  apply RobustPosterior.klDiv_cond_le_of_mass_lower _ _ (measurable_posteriorEvent hF hc globalMargin B.computes S)
  simpa only [neg_div] using posterior_target_mass hF hd B hCN hc hσ hscale globalMargin S

/-- The learner is exactly prior support conditioning followed by the
unchanged strict training-margin likelihood. -/
theorem posterior_eq_two_stage (hF : Parameters m u θ) {c : ℝ} (hc : 0 < c) (σ : ℝ) (globalMargin : Bool)
    (f : BooleanFunction d) (S : Fin n → Cube d) :
    posterior (N := N) (r := r) m u θ c σ globalMargin f S =
      cond (cond (smallPrior d N r σ)
        (support m u θ Real.tanh c ∩ (if globalMargin then globalMarginEvent Real.tanh m else Set.univ)))
        (trainingEvent m Real.tanh f S) := by
  have hg : MeasurableSet (if globalMargin then globalMarginEvent (d := d) (N := N) (r := r) Real.tanh m else Set.univ) := by
    cases globalMargin
    · exact MeasurableSet.univ
    · exact measurable_global_margin m tanh_continuous
  rw [cond_cond_eq_cond_inter ((measurable_support m u θ tanh_continuous hc).inter hg)
    (measurable_trainingEvent m tanh_continuous f S)]
  unfold posterior posteriorEvent
  congr 1
  ext w
  exact and_right_comm

end NeuralGeneralization.GeneralTwoMargin
