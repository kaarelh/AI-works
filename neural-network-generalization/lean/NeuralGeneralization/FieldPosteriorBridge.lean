import NeuralGeneralization.FunctionPrior
import Mathlib.Probability.ConditionalProbability
import Mathlib.MeasureTheory.Constructions.BorelSpace.Order
import Mathlib.MeasureTheory.Measure.Real

/-! Exact identification of finite sign-function posteriors with conditioning
the underlying random field, including the global strict-margin convention. -/
noncomputable section
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators
namespace NeuralGeneralization.FieldPosteriorBridge
open ConcreteModel
variable {Ω : Type*} [MeasurableSpace Ω] {d n : ℕ}

def fieldOrthant (H : Ω → Cube d → ℝ) (a : ℝ) (g : BooleanFunction d) : Set Ω :=
  {z | ∀ x, a < labelReal (g x)*H z x}

def globalEvent (H : Ω → Cube d → ℝ) (a : ℝ) : Set Ω := {z | ∀ x, a < |H z x|}

def trainingEvent (H : Ω → Cube d → ℝ) (f : BooleanFunction d) (sample : Fin n → Cube d) : Set Ω :=
  {z | ∀ i, 0 < labelReal (f (sample i))*H z (sample i)}

def correctEvent (H : Ω → Cube d → ℝ) (f : BooleanFunction d) (x : Cube d) : Set Ω :=
  {z | 0 < labelReal (f x)*H z x}

def conditioningEvent (H : Ω → Cube d → ℝ) (a : ℝ) (f : BooleanFunction d)
    (sample : Fin n → Cube d) : Set Ω := globalEvent H a ∩ trainingEvent H f sample

def fieldMass (μ : Measure Ω) (H : Ω → Cube d → ℝ) (a : ℝ) (g : BooleanFunction d) : ℝ :=
  μ.real (fieldOrthant H a g)

theorem signed_pos_iff_eq (b c : Bool) {v : ℝ} (hb : 0 < labelReal b*v) :
    (0 < labelReal c*v) ↔ b=c := by
  cases b <;> cases c <;> simp [labelReal] at hb ⊢ <;> linarith

theorem orthant_subset_global (H : Ω → Cube d → ℝ) (a : ℝ) (g : BooleanFunction d) :
    fieldOrthant H a g ⊆ globalEvent H a := by
  intro z hz x
  calc
    a < labelReal (g x)*H z x := hz x
    _ ≤ |labelReal (g x)*H z x| := le_abs_self _
    _ = |H z x| := by rw [abs_mul, abs_labelReal, one_mul]

def chosenSign (H : Ω → Cube d → ℝ) (z : Ω) : BooleanFunction d :=
  fun x => decide (0 ≤ H z x)

theorem chosenSign_margin (H : Ω → Cube d → ℝ) (a : ℝ) {z : Ω}
    (hz : z ∈ globalEvent H a) : z ∈ fieldOrthant H a (chosenSign H z) := by
  intro x
  have hx := hz x
  by_cases hp : 0 ≤ H z x
  · simpa [chosenSign, labelReal, hp, abs_of_nonneg hp] using hx
  · simpa [chosenSign, labelReal, hp, abs_of_neg (lt_of_not_ge hp)] using hx

theorem fieldOrthants_disjoint (H : Ω → Cube d → ℝ) {a : ℝ} (ha : 0 ≤ a)
    {f g : BooleanFunction d} (hfg : f ≠ g) : Disjoint (fieldOrthant H a f) (fieldOrthant H a g) := by
  apply Set.disjoint_left.mpr
  intro z hf hg
  apply hfg
  funext x
  exact (signed_pos_iff_eq (f x) (g x) (ha.trans_lt (hf x))).mp (ha.trans_lt (hg x))

theorem measurableSet_fieldOrthant (H : Ω → Cube d → ℝ) (hH : ∀ x, Measurable (fun z => H z x))
    (a : ℝ) (g : BooleanFunction d) : MeasurableSet (fieldOrthant H a g) := by
  unfold fieldOrthant
  rw [setOf_forall]
  exact MeasurableSet.iInter fun x => measurableSet_lt measurable_const ((hH x).const_mul _)

theorem measurableSet_globalEvent (H : Ω → Cube d → ℝ) (hH : ∀ x, Measurable (fun z => H z x))
    (a : ℝ) : MeasurableSet (globalEvent H a) := by
  unfold globalEvent
  rw [setOf_forall]
  exact MeasurableSet.iInter fun x => measurableSet_lt measurable_const
    (continuous_abs.measurable.comp (hH x))

theorem measurableSet_trainingEvent (H : Ω → Cube d → ℝ) (hH : ∀ x, Measurable (fun z => H z x))
    (f : BooleanFunction d) (sample : Fin n → Cube d) : MeasurableSet (trainingEvent H f sample) := by
  unfold trainingEvent
  rw [setOf_forall]
  exact MeasurableSet.iInter fun i => measurableSet_lt measurable_const ((hH (sample i)).const_mul _)

theorem measurableSet_correctEvent (H : Ω → Cube d → ℝ) (hH : ∀ x, Measurable (fun z => H z x))
    (f : BooleanFunction d) (x : Cube d) : MeasurableSet (correctEvent H f x) :=
  measurableSet_lt measurable_const ((hH x).const_mul _)

theorem measurableSet_conditioningEvent (H : Ω → Cube d → ℝ)
    (hH : ∀ x, Measurable (fun z => H z x)) (a : ℝ) (f : BooleanFunction d)
    (sample : Fin n → Cube d) : MeasurableSet (conditioningEvent H a f sample) :=
  (measurableSet_globalEvent H hH a).inter (measurableSet_trainingEvent H hH f sample)

def filteredUnion (H : Ω → Cube d → ℝ) (a : ℝ) (keep : BooleanFunction d → Prop) : Set Ω := by
  classical
  exact ⋃ g, if keep g then fieldOrthant H a g else ∅

theorem mem_filteredUnion (H : Ω → Cube d → ℝ) (a : ℝ) (keep : BooleanFunction d → Prop) (z : Ω) :
    z ∈ filteredUnion H a keep ↔ ∃ g, keep g ∧ z ∈ fieldOrthant H a g := by
  classical
  simp only [filteredUnion, mem_iUnion]
  constructor
  · rintro ⟨g,hg⟩
    by_cases hk : keep g
    · exact ⟨g,hk,by simpa only [if_pos hk] using hg⟩
    · simp only [if_neg hk, mem_empty_iff_false] at hg
  · rintro ⟨g,hk,hg⟩
    exact ⟨g,by simpa only [if_pos hk] using hg⟩

theorem mass_filteredUnion (μ : Measure Ω) [IsFiniteMeasure μ]
    (H : Ω → Cube d → ℝ) (hH : ∀ x, Measurable (fun z => H z x))
    {a : ℝ} (ha : 0 ≤ a) (keep : BooleanFunction d → Prop) [DecidablePred keep] :
    μ.real (filteredUnion H a keep) = normalizer (fieldMass μ H a) keep := by
  classical
  unfold filteredUnion
  rw [measureReal_iUnion_fintype]
  · unfold normalizer
    apply Finset.sum_congr rfl
    intro g _
    by_cases hk : keep g <;> simp [hk, fieldMass]
  · intro f g hfg
    dsimp only [Function.onFun]
    by_cases hf : keep f <;> by_cases hg : keep g
    · simpa only [if_pos hf, if_pos hg] using fieldOrthants_disjoint H ha hfg
    all_goals simp [hf,hg]
  · intro g
    by_cases hg : keep g <;> simp only [hg,ite_true,ite_false]
    · exact measurableSet_fieldOrthant H hH a g
    · exact MeasurableSet.empty

theorem filteredUnion_consistent (H : Ω → Cube d → ℝ) {a : ℝ} (ha : 0 ≤ a)
    (f : BooleanFunction d) (sample : Fin n → Cube d) :
    filteredUnion H a (consistent f sample) = conditioningEvent H a f sample := by
  ext z
  rw [mem_filteredUnion]
  constructor
  · rintro ⟨g,hg,hz⟩
    refine ⟨orthant_subset_global H a g hz,fun i => ?_⟩
    rw [← hg i]
    exact ha.trans_lt (hz (sample i))
  · rintro ⟨hz,htrain⟩
    have hm := chosenSign_margin H a hz
    refine ⟨chosenSign H z,fun i => ?_,hm⟩
    exact (signed_pos_iff_eq _ _ (ha.trans_lt (hm (sample i)))).mp (htrain i)

theorem filteredUnion_correct (H : Ω → Cube d → ℝ) {a : ℝ} (ha : 0 ≤ a)
    (f : BooleanFunction d) (sample : Fin n → Cube d) (x : Cube d) :
    filteredUnion H a (fun g => consistent f sample g ∧ g x=f x) =
      conditioningEvent H a f sample ∩ correctEvent H f x := by
  ext z
  rw [mem_filteredUnion]
  constructor
  · rintro ⟨g,⟨hg,hx⟩,hz⟩
    refine ⟨?_,?_⟩
    · rw [← filteredUnion_consistent H ha]
      exact (mem_filteredUnion H a _ z).2 ⟨g,hg,hz⟩
    · change 0 < labelReal (f x)*H z x
      rw [← hx]
      exact ha.trans_lt (hz x)
  · rintro ⟨hc,hx⟩
    rw [← filteredUnion_consistent H ha] at hc
    obtain ⟨g,hg,hz⟩ := (mem_filteredUnion H a _ z).1 hc
    exact ⟨g,⟨hg,(signed_pos_iff_eq _ _ (ha.trans_lt (hz x))).mp hx⟩,hz⟩

theorem normalizer_eq_conditioning_mass (μ : Measure Ω) [IsFiniteMeasure μ]
    (H : Ω → Cube d → ℝ) (hH : ∀ x, Measurable (fun z => H z x))
    {a : ℝ} (ha : 0 ≤ a) (f : BooleanFunction d) (sample : Fin n → Cube d) :
    normalizer (fieldMass μ H a) (consistent f sample) = μ.real (conditioningEvent H a f sample) := by
  rw [← mass_filteredUnion μ H hH ha, filteredUnion_consistent H ha]

theorem correctConfidence_ratio (w : BooleanFunction d → ℝ) (f : BooleanFunction d)
    (sample : Fin n → Cube d) (x : Cube d) :
    ConcreteModel.correctConfidence f (posterior w (consistent f sample)) x =
      normalizer w (fun g => consistent f sample g ∧ g x=f x) / normalizer w (consistent f sample) := by
  classical
  unfold ConcreteModel.correctConfidence posterior normalizer
  rw [Finset.sum_div]
  apply Finset.sum_congr rfl
  intro g _
  by_cases hc : consistent f sample g <;> by_cases hx : g x=f x <;> simp [hc,hx]

/-- Exact posterior confidence under the paper's global margin convention. -/
theorem correctConfidence_eq_conditional (μ : Measure Ω) [IsFiniteMeasure μ]
    (H : Ω → Cube d → ℝ) (hH : ∀ x, Measurable (fun z => H z x))
    {a : ℝ} (ha : 0 ≤ a) (f : BooleanFunction d) (sample : Fin n → Cube d) (x : Cube d) :
    ConcreteModel.correctConfidence f (posterior (fieldMass μ H a) (consistent f sample)) x =
      (cond μ (conditioningEvent H a f sample)).real (correctEvent H f x) := by
  classical
  rw [correctConfidence_ratio, normalizer_eq_conditioning_mass μ H hH ha,
    ← mass_filteredUnion μ H hH ha, filteredUnion_correct H ha]
  simp only [measureReal_def]
  rw [cond_apply (measurableSet_conditioningEvent H hH a f sample),
    ENNReal.toReal_mul, ENNReal.toReal_inv]
  ring

theorem zero_globalEvent_ae_univ (μ : Measure Ω) (H : Ω → Cube d → ℝ)
    (hnull : ∀ x, μ {z | H z x=0}=0) : globalEvent H 0 =ᵐ[μ] univ := by
  have hz : ∀ᵐ z ∂μ, ∀ x, H z x ≠ 0 := by
    rw [ae_all_iff]
    intro x
    rw [ae_iff]
    simpa only [not_not] using hnull x
  filter_upwards [hz] with z hz
  apply propext
  change (∀ x, 0 < |H z x|) ↔ True
  exact ⟨fun _ => trivial, fun _ x => abs_pos.mpr (hz x)⟩

theorem zero_conditioningEvent_ae_training (μ : Measure Ω) (H : Ω → Cube d → ℝ)
    (hnull : ∀ x, μ {z | H z x=0}=0) (f : BooleanFunction d) (sample : Fin n → Cube d) :
    conditioningEvent H 0 f sample =ᵐ[μ] trainingEvent H f sample := by
  filter_upwards [zero_globalEvent_ae_univ μ H hnull] with z hz
  apply propext
  change (z ∈ globalEvent H 0 ∧ z ∈ trainingEvent H f sample) ↔ z ∈ trainingEvent H f sample
  have hg : z ∈ globalEvent H 0 := (propext_iff.mp hz).mpr (mem_univ z)
  simp only [hg,true_and]

theorem cond_eq_of_ae_eq (μ : Measure Ω) {E F : Set Ω} (h : E =ᵐ[μ] F) : cond μ E = cond μ F := by
  unfold ProbabilityTheory.cond
  rw [measure_congr h, Measure.restrict_congr_set h]

/-- Zero margin removes the global event exactly when coordinate boundaries
have probability zero, leaving only the observed signs. -/
theorem correctConfidence_eq_training_conditional (μ : Measure Ω) [IsFiniteMeasure μ]
    (H : Ω → Cube d → ℝ) (hH : ∀ x, Measurable (fun z => H z x))
    (hnull : ∀ x, μ {z | H z x=0}=0) (f : BooleanFunction d) (sample : Fin n → Cube d) (x : Cube d) :
    ConcreteModel.correctConfidence f (posterior (fieldMass μ H 0) (consistent f sample)) x =
      (cond μ (trainingEvent H f sample)).real (correctEvent H f x) := by
  rw [correctConfidence_eq_conditional μ H hH (le_refl 0),
    cond_eq_of_ae_eq μ (zero_conditioningEvent_ae_training μ H hnull f sample)]

end NeuralGeneralization.FieldPosteriorBridge
end
