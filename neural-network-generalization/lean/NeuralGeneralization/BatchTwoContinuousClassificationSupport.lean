import NeuralGeneralization.BatchTwoContinuousClassificationMain

/-! The classification margin may hold only almost everywhere. Null-set
changes of labels leave the success probability unchanged. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory Filter
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous.Classification
open ConcreteModel CompressionSampling BatchTwoNonGaussian

def teacherLabel {d C r : ℕ} (w : Weights d C r) (x : RealInput d) : Bool :=
  if 0<output Real.tanh w x then true else false

def marginSupport {d C r : ℕ} (w : Weights d C r) (X : Set (RealInput d)) (a : ℝ) :=
  X ∩ {x | a≤|output Real.tanh w x|}

theorem measurable_teacherLabel {d C r : ℕ} (w : Weights d C r) : Measurable (teacherLabel w) := by
  apply Measurable.ite _ measurable_const measurable_const
  exact (isOpen_lt continuous_const (continuous_output_input tanh_continuous w)).measurableSet

theorem teacherLabel_mul_output {d C r : ℕ} (w : Weights d C r) (x : RealInput d) :
    labelReal (teacherLabel w x)*output Real.tanh w x=|output Real.tanh w x| := by
  unfold teacherLabel
  split_ifs with h
  · simp [labelReal,abs_of_pos h]
  · simp [labelReal,abs_of_nonpos (le_of_not_gt h)]

theorem label_eq_teacherLabel {d C r : ℕ} (w : Weights d C r) (x : RealInput d)
    (label : Bool) {a : ℝ} (ha : 0<a) (h : a≤labelReal label*output Real.tanh w x) :
    label=teacherLabel w x := by
  cases label <;> simp only [labelReal_false,labelReal_true,neg_one_mul,one_mul] at h
  · have hx : ¬0<output Real.tanh w x := by linarith
    simp [teacherLabel,hx]
  · have hx : 0<output Real.tanh w x := by linarith
    simp [teacherLabel,hx]

theorem marginSupport_admissible {d C r : ℕ} (w : Weights d C r)
    (X : Set (RealInput d)) (hX : admissibleDomain X) (a : ℝ)
    (hne : (marginSupport w X a).Nonempty) : admissibleDomain (marginSupport w X a) :=
  ⟨hne,hX.2.1.inter_right (isClosed_le continuous_const
    (continuous_output_input tanh_continuous w).abs),fun x hx => hX.2.2 x hx.1⟩

theorem ae_margin_support {d C r : ℕ} (w : Weights d C r) (X : Set (RealInput d))
    (D : Measure (RealInput d)) (hDX : D Xᶜ=0) (label : RealInput d→Bool) {a : ℝ}
    (ha : 0<a) (hm : ∀ᵐ x ∂D,a≤labelReal (label x)*output Real.tanh w x) :
    D (marginSupport w X a)ᶜ=0 ∧ label=ᵐ[D]teacherLabel w := by
  have hx : ∀ᵐ x ∂D,x∈X := by rw [ae_iff]; exact hDX
  have hl : label=ᵐ[D]teacherLabel w := by
    filter_upwards [hm] with x hm
    exact label_eq_teacherLabel w x (label x) ha hm
  refine ⟨?_,hl⟩
  change D {x | x∉marginSupport w X a}=0
  rw [← ae_iff]
  filter_upwards [hx,hm,hl] with x hx hm hl
  refine ⟨hx,?_⟩
  rw [hl,teacherLabel_mul_output] at hm
  exact hm

theorem confidence_congr_label_ae {d N r : ℕ} (φ : ℝ→ℝ) (D : Measure (RealInput d))
    (Q : Measure (Weights d N r)) {label label' : RealInput d→Bool} (he : label=ᵐ[D]label') :
    confidenceFailure φ D Q label=confidenceFailure φ D Q label' := by
  unfold confidenceFailure Measure.real
  congr 1
  apply measure_congr
  filter_upwards [he] with x hx
  change ((Q {w | 0<labelReal (label x)*output φ w x}).toReal≤2/3) =
    ((Q {w | 0<labelReal (label' x)*output φ w x}).toReal≤2/3)
  rw [hx]

theorem success_probability_transfer {d N r n : ℕ} (φ : ℝ→ℝ)
    (μ : Measure (Weights d N r)) (D : Measure (RealInput d)) [IsProbabilityMeasure D]
    {label label' : RealInput d→Bool} (he : label=ᵐ[D]label') {ε δ : ℝ}
    (h : 1-δ≤(iidSamples D n).real {s |
      risk φ D (posterior φ μ label' s) label'≤ε/3 ∧
      confidenceFailure φ D (posterior φ μ label' s) label'≤ε}) :
    1-δ≤(iidSamples D n).real {s | confidenceFailure φ D (posterior φ μ label s) label≤ε} := by
  apply h.trans
  apply ENNReal.toReal_mono (measure_ne_top _ _)
  apply measure_mono_ae
  have hs : ∀ᵐ s ∂iidSamples D n,∀ i,label (s i)=label' (s i) :=
    eventually_all.mpr fun i => (show Tendsto (fun s : Fin n→RealInput d => s i)
      (ae (iidSamples D n)) (ae D) from Measure.tendsto_eval_ae_ae).eventually he
  filter_upwards [hs] with s hs
  intro hh
  change confidenceFailure φ D (posterior φ μ label s) label≤ε
  change risk φ D (posterior φ μ label' s) label'≤ε/3 ∧
    confidenceFailure φ D (posterior φ μ label' s) label'≤ε at hh
  have hpost : posterior φ μ label s=posterior φ μ label' s := by
    unfold posterior
    congr 1
    ext w
    change (∀ i,(1/2:ℝ)<labelReal (label (s i))*output φ w (s i)) ↔
      (∀ i,(1/2:ℝ)<labelReal (label' (s i))*output φ w (s i))
    simp only [hs]
  rw [hpost,confidence_congr_label_ae φ D _ he]
  exact hh.2

end NeuralGeneralization.BatchTwoContinuous.Classification
