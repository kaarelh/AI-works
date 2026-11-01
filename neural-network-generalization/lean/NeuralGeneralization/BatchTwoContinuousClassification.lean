import NeuralGeneralization.BatchTwoContinuousLearning

/-! Binary training-margin conditioning on a continuous input domain.  The
prior is conditioned only at the sampled inputs, not on a global margin. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.BatchTwoContinuous.Classification
open ConcreteModel BatchTwoSurvivalStatistics

def trainingEvent {d N r n : ℕ} (φ : ℝ→ℝ) (label : RealInput d→Bool)
    (s : Fin n→RealInput d) : Set (Weights d N r) :=
  {w | ∀ i, (1/2:ℝ)<labelReal (label (s i))*output φ w (s i)}

def posterior {d N r n : ℕ} (φ : ℝ→ℝ) (μ : Measure (Weights d N r))
    (label : RealInput d→Bool) (s : Fin n→RealInput d) : Measure (Weights d N r) :=
  cond μ (trainingEvent φ label s)

def errorEvent {d N r : ℕ} (φ : ℝ→ℝ) (label : RealInput d→Bool) :
    Set (RealInput d × Weights d N r) := {p | labelReal (label p.1)*output φ p.2 p.1≤0}

def risk {d N r : ℕ} (φ : ℝ→ℝ) (D : Measure (RealInput d))
    (Q : Measure (Weights d N r)) (label : RealInput d→Bool) : ℝ :=
  (D.prod Q).real (errorEvent φ label)

def confidenceFailure {d N r : ℕ} (φ : ℝ→ℝ) (D : Measure (RealInput d))
    (Q : Measure (Weights d N r)) (label : RealInput d→Bool) : ℝ :=
  D.real {x | Q.real {w | 0<labelReal (label x)*output φ w x}≤2/3}

theorem measurable_errorEvent {d N r : ℕ} {φ : ℝ→ℝ} (hφ : Continuous φ)
    {label : RealInput d→Bool} (hl : Measurable label) :
    MeasurableSet (errorEvent (N:=N) (r:=r) φ label) :=
  measurableSet_le (((measurable_of_finite labelReal).comp (hl.comp measurable_fst)).mul
    ((continuous_output_joint hφ).comp continuous_swap).measurable) measurable_const

theorem confidence_le_three_risk {d N r : ℕ} {φ : ℝ→ℝ} (hφ : Continuous φ)
    (D : Measure (RealInput d)) (Q : Measure (Weights d N r))
    [IsProbabilityMeasure D] [IsProbabilityMeasure Q]
    {label : RealInput d→Bool} (hl : Measurable label) :
    confidenceFailure φ D Q label≤3*risk φ D Q label := by
  have h := BatchTwoConfidenceProduct.two_thirds_confidence_bound D Q
    (errorEvent φ label) (measurable_errorEvent hφ hl)
  simpa only [confidenceFailure,risk,errorEvent,Set.preimage_setOf_eq,Set.compl_setOf,not_le] using h

theorem isOpen_trainingEvent {d N r n : ℕ} {φ : ℝ→ℝ} (hφ : Continuous φ)
    (label : RealInput d→Bool) (s : Fin n→RealInput d) :
    IsOpen (trainingEvent (N:=N) (r:=r) φ label s) := by
  unfold trainingEvent
  simp only [Set.setOf_forall]
  exact isOpen_iInter_of_finite fun i => isOpen_lt continuous_const
    (continuous_const.mul (continuous_output_weights hφ (s i)))

theorem uniformTube_subset_training {d N r n : ℕ} (φ : ℝ→ℝ)
    (f : RealInput d→ℝ) (label : RealInput d→Bool) (X : Set (RealInput d)) (ρ : ℝ)
    (hm : ∀ x∈X, 1/2+ρ≤labelReal (label x)*f x)
    (s : Fin n→RealInput d) (hs : ∀ i,s i∈X) :
    uniformTube (N:=N) (r:=r) φ f X ρ ⊆ trainingEvent φ label s := by
  intro w hw i
  have he := abs_lt.mp (hw (s i) (hs i))
  have h := hm (s i) (hs i)
  cases hb : label (s i) <;> simp only [hb,labelReal_false,labelReal_true,neg_one_mul,one_mul] at h ⊢ <;> linarith

def comparison {d : ℕ} {H : Type*} (label : RealInput d→Bool)
    (g : H→RealInput d→ℝ) (a : ℝ) (h : H) : Set (RealInput d) :=
  {x | labelReal (label x)*g h x≤1/2-a}

theorem measurable_comparison {d : ℕ} {H : Type*} {label : RealInput d→Bool}
    (hl : Measurable label) (g : H→RealInput d→ℝ) (hg : ∀ h,Measurable (g h))
    (a : ℝ) (h : H) : MeasurableSet (comparison label g a h) :=
  measurableSet_le (((measurable_of_finite labelReal).comp hl).mul (hg h)) measurable_const

theorem cover_posterior_risk {d N r n : ℕ} {H : Type*} [Fintype H]
    (D : Measure (RealInput d)) [IsProbabilityMeasure D]
    (Q : Measure (Weights d N r)) [IsProbabilityMeasure Q]
    (φ : ℝ→ℝ) (hφ : Continuous φ) (label : RealInput d→Bool) (hl : Measurable label)
    (g : H→RealInput d→ℝ) (X : Set (RealInput d)) (hDX : D Xᶜ=0)
    (s : Fin n→RealInput d) (hsX : ∀ i,s i∈X)
    {a u β : ℝ} (hu : 0≤u) (hgap : 2*a≤1/2)
    (hs : s∉badSamples D (comparison label g a) n u)
    (E : Set (Weights d N r)) (hE : MeasurableSet E) (htail : Q.real E≤β)
    (hgood : ∀ᵐ w ∂Q,w∈trainingEvent φ label s ∧
      (w∉E → ∃ h,∀ x∈X,|output φ w x-g h x|≤a)) : risk φ D Q label≤u+β := by
  apply finite_cover_posterior_error D Q (errorEvent φ label) (measurable_errorEvent hφ hl)
    (comparison label g a) s hu hs E hE htail
  have hX : ∀ᵐ x ∂D,x∈X := by rw [ae_iff]; exact hDX
  filter_upwards [hgood] with w hw
  intro he
  obtain ⟨h,hc⟩ := hw.2 he
  refine ⟨h,?_,?_⟩
  · intro i
    change ¬labelReal (label (s i))*g h (s i)≤1/2-a
    have ht := hw.1 i
    have hb := abs_le.mp (hc (s i) (hsX i))
    cases hi : label (s i) <;> simp only [hi,labelReal_false,labelReal_true,neg_one_mul,one_mul] at ht ⊢ <;> linarith
  · apply ENNReal.toReal_mono (measure_ne_top _ _)
    apply measure_mono_ae
    filter_upwards [hX] with x hx
    intro herr
    change labelReal (label x)*output φ w x≤0 at herr
    change labelReal (label x)*g h x≤1/2-a
    have hb := abs_le.mp (hc x hx)
    cases hi : label x <;> simp only [hi,labelReal_false,labelReal_true,neg_one_mul,one_mul] at herr ⊢ <;> linarith

end NeuralGeneralization.BatchTwoContinuous.Classification
