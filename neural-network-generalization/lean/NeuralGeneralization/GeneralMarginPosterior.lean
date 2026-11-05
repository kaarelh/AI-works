import NeuralGeneralization.GeneralMarginCompression
import NeuralGeneralization.PointwiseRobustSupport
import NeuralGeneralization.RobustTargetAllWidths
import NeuralGeneralization.BatchTwoImprovedGlobalPosterior

/-! The actual transformed-score Gaussian posterior, including optional all-input clean-margin conditioning. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal
namespace NeuralGeneralization.GeneralMargin
open ConcreteModel
variable {d C N r n : ℕ} {m u : ℝ} {F : ℝ → ℝ}

def trainingEvent (m : ℝ) (φ : ℝ → ℝ) (f : BooleanFunction d) (S : Fin n → Cube d) : Set (Weights d N r) :=
  {w | ∀ i,m < labelReal (f (S i))*networkOutput φ w (S i)}

lemma measurable_trainingEvent (m : ℝ) {φ : ℝ → ℝ} (hφ : Continuous φ)
    (f : BooleanFunction d) (S : Fin n → Cube d) :
    MeasurableSet (trainingEvent (N := N) (r := r) m φ f S) := by
  simp only [trainingEvent,Set.setOf_forall]
  exact MeasurableSet.iInter fun i => measurableSet_lt measurable_const
    ((continuous_networkOutput hφ (S i)).measurable.const_mul _)

lemma measurable_global_margin (m : ℝ) {φ : ℝ → ℝ} (hφ : Continuous φ) :
    MeasurableSet (globalMarginEvent (d := d) (N := N) (r := r) φ m) := by
  simp only [globalMarginEvent,Set.setOf_forall]
  exact MeasurableSet.iInter fun x => measurableSet_lt measurable_const
    (continuous_networkOutput hφ x).measurable.abs

def posteriorEvent (m u : ℝ) (F : ℝ → ℝ) (c : ℝ) (globalMargin : Bool) (f : BooleanFunction d)
    (S : Fin n → Cube d) : Set (Weights d N r) :=
  support m u F Real.tanh c ∩ trainingEvent m Real.tanh f S ∩
    (if globalMargin then globalMarginEvent Real.tanh m else Set.univ)

def posterior (m u : ℝ) (F : ℝ → ℝ) (c σ : ℝ) (globalMargin : Bool) (f : BooleanFunction d)
    (S : Fin n → Cube d) : Measure (Weights d N r) :=
  cond (smallPrior d N r σ) (posteriorEvent m u F c globalMargin f S)

lemma measurable_posteriorEvent (hF : Admissible m u F) {c : ℝ} (hc : 0 < c) (globalMargin : Bool)
    (f : BooleanFunction d) (S : Fin n → Cube d) :
    MeasurableSet (posteriorEvent (N := N) (r := r) m u F c globalMargin f S) := by
  apply MeasurableSet.inter
  · exact (measurable_support hF tanh_continuous hc).inter
      (measurable_trainingEvent m tanh_continuous f S)
  · cases globalMargin
    · exact MeasurableSet.univ
    · exact measurable_global_margin m tanh_continuous

lemma target_subset (c : ℝ) (globalMargin : Bool) (f : BooleanFunction d)
    (S : Fin n → Cube d) :
    support (N := N) (r := r) m u F Real.tanh c ∩ marginEvent Real.tanh m f ⊆
      posteriorEvent m u F c globalMargin f S := by
  intro w hw
  refine ⟨⟨hw.1,fun i => hw.2 (S i)⟩,?_⟩
  cases globalMargin
  · trivial
  · exact marginEvent_subset_global Real.tanh m f hw.2

/-- Every labeled sample retains the actual target cylinder. -/
theorem posterior_target_mass (hF : Admissible m u F) (hd : 0 < d) (B : LayeredBooleanCircuit d C r) (hCN : C ≤ N)
    {c σ : ℝ} (hc : 0 < c) (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1)
    (globalMargin : Bool) (S : Fin n → Cube d) :
    Real.exp (-digitalMassPolynomial d C r (c+m+1)/σ^2) ≤
      (smallPrior d N r σ).real (posteriorEvent m u F c globalMargin B.computes S) :=
  (target_mass hF hd B hCN hc hσ hscale).trans
    (measureReal_mono (target_subset c globalMargin B.computes S))

theorem posterior_probability (hF : Admissible m u F) (hd : 0 < d) (B : LayeredBooleanCircuit d C r) (hCN : C ≤ N)
    {c σ : ℝ} (hc : 0 < c) (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1)
    (globalMargin : Bool) (S : Fin n → Cube d) :
    IsProbabilityMeasure (posterior (N := N) (r := r) m u F c σ globalMargin B.computes S) := by
  apply cond_isProbabilityMeasure
  have hp := (Real.exp_pos _).trans_le (posterior_target_mass hF hd B hCN hc hσ hscale globalMargin S)
  intro hz
  simp only [Measure.real,hz,ENNReal.toReal_zero] at hp
  exact (lt_irrefl 0) hp

/-- The literal Gaussian posterior entropy is bounded without an oracle. -/
theorem posterior_entropy (hF : Admissible m u F) (hd : 0 < d) (B : LayeredBooleanCircuit d C r) (hCN : C ≤ N)
    {c σ : ℝ} (hc : 0 < c) (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1)
    (globalMargin : Bool) (S : Fin n → Cube d) :
    klDiv (posterior (N := N) (r := r) m u F c σ globalMargin B.computes S) (smallPrior d N r σ) ≤
      ENNReal.ofReal (digitalMassPolynomial d C r (c+m+1)/σ^2) := by
  apply RobustPosterior.klDiv_cond_le_of_mass_lower _ _ (measurable_posteriorEvent hF hc globalMargin B.computes S)
  simpa only [neg_div] using posterior_target_mass hF hd B hCN hc hσ hscale globalMargin S

/-- The learner is exactly prior support conditioning followed by the
unchanged strict training-margin likelihood. -/
theorem posterior_eq_two_stage (hF : Admissible m u F) {c : ℝ} (hc : 0 < c) (σ : ℝ) (globalMargin : Bool)
    (f : BooleanFunction d) (S : Fin n → Cube d) :
    posterior (N := N) (r := r) m u F c σ globalMargin f S =
      cond (cond (smallPrior d N r σ)
        (support m u F Real.tanh c ∩ (if globalMargin then globalMarginEvent Real.tanh m else Set.univ)))
        (trainingEvent m Real.tanh f S) := by
  have hg : MeasurableSet (if globalMargin then globalMarginEvent (d := d) (N := N) (r := r) Real.tanh m else Set.univ) := by
    cases globalMargin
    · exact MeasurableSet.univ
    · exact measurable_global_margin m tanh_continuous
  rw [cond_cond_eq_cond_inter ((measurable_support hF tanh_continuous hc).inter hg)
    (measurable_trainingEvent m tanh_continuous f S)]
  unfold posterior posteriorEvent
  congr 1
  ext w
  exact and_right_comm

end NeuralGeneralization.GeneralMargin
