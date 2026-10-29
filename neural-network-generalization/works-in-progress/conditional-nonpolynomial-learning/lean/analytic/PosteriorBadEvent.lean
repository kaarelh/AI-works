import FiniteWidthEntropyCertificate
import NeuralGeneralization.FunctionPriorFacts

/-! Exact passage from posterior mass on a function class to the original
parameter event, with the global-margin normalizer cancelled as in NNbayes. -/
noncomputable section
set_option linter.unusedSectionVars false
open MeasureTheory
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic
attribute [local instance] Classical.propDecidable
open NeuralGeneralization.ConcreteModel

variable {d N r n : ℕ}

/-- Parameter event selecting a globally margin-separated sign function in B
which agrees with every observed label. -/
def compatibleClassEvent (φ : ℝ→ℝ) (a : ℝ) (f : BooleanFunction d)
    (sample : Fin n→Cube d) (B : Set (BooleanFunction d)) : Set (Weights d N r) := by
  classical
  exact ⋃ g : BooleanFunction d, if g∈B ∧ consistent f sample g then marginEvent φ a g else ∅

lemma mem_compatibleClassEvent (φ : ℝ→ℝ) (a : ℝ) (f : BooleanFunction d)
    (sample : Fin n→Cube d) (B : Set (BooleanFunction d)) (w : Weights d N r) :
    w∈compatibleClassEvent φ a f sample B ↔
      ∃g∈B,consistent f sample g ∧ w∈marginEvent φ a g := by
  classical
  simp only [compatibleClassEvent,Set.mem_iUnion]
  constructor
  · rintro ⟨g,hg⟩
    split_ifs at hg with h
    · exact ⟨g,h.1,h.2,hg⟩
    · exact False.elim hg
  · rintro ⟨g,hB,hc,hw⟩
    refine ⟨g,?_⟩
    rw [if_pos (show g∈B ∧ consistent f sample g from ⟨hB,hc⟩)]
    exact hw

lemma measurableSet_compatibleClassEvent {φ : ℝ→ℝ} (hφ : Continuous φ)
    (a : ℝ) (f : BooleanFunction d) (sample : Fin n→Cube d) (B : Set (BooleanFunction d)) :
    MeasurableSet (compatibleClassEvent (N:=N) (r:=r) φ a f sample B) := by
  classical
  apply MeasurableSet.iUnion
  intro g
  split_ifs
  · exact (isOpen_marginEvent hφ a g).measurableSet
  · exact MeasurableSet.empty

theorem compatibleClassEvent_mass {φ : ℝ→ℝ} (hφ : Continuous φ)
    {a : ℝ} (ha : 0≤a) (μ : Measure (Weights d N r)) [IsFiniteMeasure μ]
    (f : BooleanFunction d) (sample : Fin n→Cube d) (B : Set (BooleanFunction d)) :
    μ.real (compatibleClassEvent φ a f sample B)=
      ∑g : BooleanFunction d,if g∈B ∧ consistent f sample g then functionMass φ a μ g else 0 := by
  classical
  have hdisj : Pairwise (fun g h : BooleanFunction d => Disjoint
      (if g∈B ∧ consistent f sample g then marginEvent (N:=N) (r:=r) φ a g else ∅)
      (if h∈B ∧ consistent f sample h then marginEvent φ a h else ∅)) := by
    intro g h hne
    split_ifs
    · exact marginEvents_disjoint φ ha hne
    · exact Set.disjoint_empty _
    · exact Set.empty_disjoint _
    · exact Set.empty_disjoint _
  have hm (g : BooleanFunction d) : MeasurableSet
      (if g∈B ∧ consistent f sample g then marginEvent (N:=N) (r:=r) φ a g else ∅) := by
    split_ifs
    · exact (isOpen_marginEvent hφ a g).measurableSet
    · exact MeasurableSet.empty
  unfold Measure.real compatibleClassEvent
  rw [measure_iUnion hdisj hm,tsum_fintype,ENNReal.toReal_sum (fun g _=>measure_ne_top μ _)]
  apply Finset.sum_congr rfl
  intro g hg
  split_ifs <;> simp [functionMass]

/-- Exact raw event mass equals posterior mass times its actual conditioning
normalizer. This applies to an arbitrary finite parameter measure. -/
theorem compatibleClassEvent_mass_eq_posterior {φ : ℝ→ℝ} (hφ : Continuous φ)
    {a : ℝ} (ha : 0≤a) (μ : Measure (Weights d N r)) [IsFiniteMeasure μ]
    (f : BooleanFunction d) (sample : Fin n→Cube d) (B : Set (BooleanFunction d))
    (hZ : 0<posteriorDenominator φ a μ f sample) :
    μ.real (compatibleClassEvent φ a f sample B)=posteriorDenominator φ a μ f sample*
      (∑g : BooleanFunction d,if g∈B then networkPosterior φ a μ f sample g else 0) := by
  classical
  rw [compatibleClassEvent_mass hφ ha μ f sample B,Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro g hg
  by_cases hB : g∈B <;> by_cases hc : consistent f sample g
  · simp only [hB,hc,true_and,if_true,networkPosterior,NeuralGeneralization.posterior]
    change functionMass φ a μ g=posteriorDenominator φ a μ f sample*
      (functionMass φ a μ g/posteriorDenominator φ a μ f sample)
    field_simp
  · simp [hB,hc,networkPosterior,NeuralGeneralization.posterior]
  · simp [hB]
  · simp [hB]

/-- A quantitative posterior lower bound transfers to actual prior mass. -/
theorem posterior_class_raw_mass_lower {φ : ℝ→ℝ} (hφ : Continuous φ)
    {a : ℝ} (ha : 0≤a) (μ : Measure (Weights d N r)) [IsFiniteMeasure μ]
    (f : BooleanFunction d) (sample : Fin n→Cube d) (B : Set (BooleanFunction d))
    (hZ : 0<posteriorDenominator φ a μ f sample) {z β : ℝ} (hβ : 0≤β)
    (hz : z≤posteriorDenominator φ a μ f sample)
    (hB : β≤∑g : BooleanFunction d,if g∈B then networkPosterior φ a μ f sample g else 0) :
    z*β≤μ.real (compatibleClassEvent φ a f sample B) := by
  rw [compatibleClassEvent_mass_eq_posterior hφ ha μ f sample B hZ]
  exact mul_le_mul hz hB hβ hZ.le

lemma networkPosterior_sum_of_denominator_pos (φ : ℝ→ℝ) (a : ℝ)
    (μ : Measure (Weights d N r)) (f : BooleanFunction d) (sample : Fin n→Cube d)
    (hZ : 0<posteriorDenominator φ a μ f sample) :
    ∑g : BooleanFunction d,networkPosterior φ a μ f sample g=1 := by
  classical
  unfold networkPosterior NeuralGeneralization.posterior
  rw [←Finset.sum_div]
  exact div_self hZ.ne'

/-- If a proposed ceiling class has posterior mass less than 5/6, its actual
complementary parameter event has at least one sixth of the normalizer. -/
theorem posterior_ceiling_failure_raw_mass {φ : ℝ→ℝ} (hφ : Continuous φ)
    {a : ℝ} (ha : 0≤a) (μ : Measure (Weights d N r)) [IsFiniteMeasure μ]
    (f : BooleanFunction d) (sample : Fin n→Cube d) (B : Set (BooleanFunction d))
    (hZ : 0<posteriorDenominator φ a μ f sample)
    (hbad : (∑g : BooleanFunction d,if g∈B then networkPosterior φ a μ f sample g else 0)<5/6) :
    posteriorDenominator φ a μ f sample/6≤μ.real (compatibleClassEvent φ a f sample Bᶜ) := by
  classical
  have htotal := networkPosterior_sum_of_denominator_pos φ a μ f sample hZ
  have hsum : (∑g : BooleanFunction d,if g∈B then networkPosterior φ a μ f sample g else 0)+
      (∑g : BooleanFunction d,if g∈Bᶜ then networkPosterior φ a μ f sample g else 0)=1 := by
    rw [←Finset.sum_add_distrib]
    convert htotal using 1
    apply Finset.sum_congr rfl
    intro g hg
    by_cases h : g∈B <;> simp [h]
  have hc : 1/6≤∑g : BooleanFunction d,if g∈Bᶜ then networkPosterior φ a μ f sample g else 0 := by
    linarith
  simpa only [mul_one_div] using posterior_class_raw_mass_lower hφ ha μ f sample Bᶜ hZ
    (by norm_num : (0:ℝ)≤1/6) le_rfl (by simpa using hc)

/-- An exponential denominator lower bound becomes an exponential actual
bad-event lower bound, at the precise additional rate log(6)/N. -/
theorem posterior_ceiling_failure_exp_mass {φ : ℝ→ℝ} (hφ : Continuous φ)
    {a : ℝ} (ha : 0≤a) (μ : Measure (Weights d N r)) [IsFiniteMeasure μ]
    (f : BooleanFunction d) (sample : Fin n→Cube d) (B : Set (BooleanFunction d))
    (hN : 0<N) (A : ℝ)
    (hZ : Real.exp (-(N:ℝ)*A)≤posteriorDenominator φ a μ f sample)
    (hbad : (∑g : BooleanFunction d,if g∈B then networkPosterior φ a μ f sample g else 0)<5/6) :
    Real.exp (-(N:ℝ)*(A+Real.log 6/N))≤
      μ.real (compatibleClassEvent φ a f sample Bᶜ) := by
  have hZ0 : 0<posteriorDenominator φ a μ f sample := (Real.exp_pos _).trans_le hZ
  have hh := posterior_ceiling_failure_raw_mass hφ ha μ f sample B hZ0 hbad
  have hn : (N:ℝ)≠0 := by exact_mod_cast hN.ne'
  calc
    _ = Real.exp (-(N:ℝ)*A)/6 := by
      rw [show -(N:ℝ)*(A+Real.log 6/N)=-(N:ℝ)*A-Real.log 6 by field_simp; ring,
        Real.exp_sub,Real.exp_log (by norm_num : (0:ℝ)<6)]
    _ ≤ posteriorDenominator φ a μ f sample/6 := div_le_div_of_nonneg_right hZ (by norm_num)
    _ ≤ _ := hh

#print axioms posterior_ceiling_failure_exp_mass
#print axioms compatibleClassEvent_mass_eq_posterior
#print axioms posterior_ceiling_failure_raw_mass
end ConditionalNonpolynomial.Analytic
