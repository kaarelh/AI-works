import NeuralGeneralization.BatchTwoActivationEndpointTail
import NeuralGeneralization.LearningBudget

/-! One finite-class sample event works simultaneously for an arbitrary family
of widths and prior scales. This is the statistical closure, not a substitute
for the separate actual prior estimates. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1200000
set_option maxRecDepth 10000
open scoped BigOperators
open MeasureTheory
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel Classical
attribute [local instance] Classical.propDecidable

def finiteClassSampleGood {d n : ℕ} (D : InputLaw d) (f : BooleanFunction d)
    (A : Finset (BooleanFunction d)) (a : ℝ) (s : Fin n → Cube d) : Prop :=
  ∀g∈A,consistent f s g → functionError D f g≤a

section GoodProbability
local instance : DecidableEq Bool := Classical.decEq Bool

theorem finiteClassSampleGood_probability {d : ℕ} (D : InputLaw d) (f : BooleanFunction d)
    (A : Finset (BooleanFunction d)) {a : ℝ} (ha1 : a≤1) (n : ℕ) :
    1-(A.card:ℝ)*Real.exp (-(n:ℝ)*a)≤sampleProbability D n (finiteClassSampleGood D f A a) := by
  classical
  let G : BooleanFunction d → Cube d → Prop := fun g x => g x=f x
  let B := A.filter (fun g => a<functionError D f g)
  have he (s : Fin n → Cube d) : (¬finiteClassSampleGood D f A a s) ↔
      ∃g∈B,allObservations (G g) n s := by
    simp only [finiteClassSampleGood,not_forall,not_le,exists_prop,B,Finset.mem_filter]
    constructor
    · rintro ⟨g,hg,hc,he⟩
      exact ⟨g,⟨hg,he⟩,hc⟩
    · rintro ⟨g,⟨hg,he⟩,hc⟩
      exact ⟨g,hg,hc,he⟩
  have hsurv (g) (hg : g∈B) :
      (∑x,if G g x then D.mass x else 0)^n≤Real.exp (-(n:ℝ)*a) := by
    have herr := (Finset.mem_filter.mp hg).2
    have hn : 0≤∑x,if G g x then D.mass x else 0 := by
      apply Finset.sum_nonneg
      intro x _
      split_ifs
      · exact D.nonneg x
      · exact le_refl _
    have hh : (∑x,if G g x then D.mass x else 0)≤1-a := by
      rw [event_survival_eq_one_sub_error D.mass D.sum_one (G g)]
      dsimp [G]
      rw [←functionError_eq_eventError D f g] 
      linarith
    exact (pow_le_pow_left₀ hn hh n).trans (pow_one_sub_le_exp a ha1 n)
  have hbad : sampleProbability D n (fun s => ¬finiteClassSampleGood D f A a s)≤
      (A.card:ℝ)*Real.exp (-(n:ℝ)*a) := by
    unfold sampleProbability
    simp_rw [he]
    have hu := iid_union_bound D.mass D.nonneg G B n
    apply le_trans hu
    calc
      _ ≤ ∑_g∈B,Real.exp (-(n:ℝ)*a) := Finset.sum_le_sum hsurv
      _ = (B.card:ℝ)*Real.exp (-(n:ℝ)*a) := by simp
      _ ≤ (A.card:ℝ)*Real.exp (-(n:ℝ)*a) := by
        apply mul_le_mul_of_nonneg_right _ (Real.exp_pos _).le
        exact_mod_cast (Finset.card_filter_le A (fun g => a<functionError D f g))
  rw [sampleProbability_compl] at hbad
  linarith

end GoodProbability

theorem networkRisk_le_on_finiteClassSampleGood {d N r n : ℕ}
    (φ : ℝ → ℝ) (μ : Measure (Weights d N r)) (D : InputLaw d) (f : BooleanFunction d)
    (hf : 0<functionMass φ (1/2) μ f) (A : Finset (BooleanFunction d))
    {a τ : ℝ} (ha : 0≤a)
    (htail : (∑g∈Finset.univ\A,functionMass φ (1/2) μ g)/functionMass φ (1/2) μ f≤τ)
    (s : Fin n → Cube d) (hs : finiteClassSampleGood D f A a s) :
    posteriorRisk D f (networkPosterior φ (1/2) μ f s)≤a+τ := by
  classical
  have herr (g) : 0≤functionError D f g ∧ functionError D f g≤1 := by
    rw [functionError_eq_eventError]
    exact ⟨eventError_nonneg D.mass D.nonneg _,eventError_le_one D.mass D.nonneg D.sum_one _⟩
  have hflat : ((∑g,functionMass φ (1/2) μ g)-∑g∈A,functionMass φ (1/2) μ g)/
      functionMass φ (1/2) μ f≤τ := by
    simpa only [Finset.sum_sdiff_eq_sub (Finset.subset_univ A)] using htail
  letI : DecidableEq (BooleanFunction d) := fun x y => Classical.propDecidable (x=y)
  have ht : (∑g∈Finset.univ\A,functionMass φ (1/2) μ g)/
      functionMass φ (1/2) μ f≤τ := by
    simpa only [Finset.sum_sdiff_eq_sub (Finset.subset_univ A)] using hflat
  have hh := posterior_risk_le (functionMass φ (1/2) μ) (consistent f s)
    (functionMass_nonneg φ (1/2) μ) f (fun _ => rfl) hf
    (functionError D f) herr A a τ ha hs ht
  exact hh

theorem uniform_prior_family_learning {T : Type*} {d r : ℕ}
    (width : T → ℕ) (φ : ℝ → ℝ) (μ : ∀i,Measure (Weights d (width i) r))
    (D : InputLaw d) (f : BooleanFunction d) (A : Finset (BooleanFunction d))
    {ε δ P : ℝ} (hε : 0<ε) (hε1 : ε<1) (hδ : 0<δ)
    (hcount : (A.card:ℝ)≤Real.exp P)
    (hpos : ∀i,0<functionMass φ (1/2) (μ i) f)
    (htail : ∀i,(∑g∈Finset.univ\A,functionMass φ (1/2) (μ i) g)/
      functionMass φ (1/2) (μ i) f≤ε/2)
    (n : ℕ) (hn : (2/ε)*(P+Real.log (1/δ))≤(n:ℝ)) :
    (∀i,∀s : Fin n → Cube d,0<posteriorDenominator φ (1/2) (μ i) f s) ∧
    1-δ≤sampleProbability D n (fun s => ∀i,
      posteriorRisk D f (networkPosterior φ (1/2) (μ i) f s)≤ε) := by
  have hbudget : P+Real.log (1/δ)≤(n:ℝ)*(ε/2) := by
    have he : (2/ε)*(P+Real.log (1/δ))=(P+Real.log (1/δ))/(ε/2) := by field_simp
    rw [he] at hn
    exact (div_le_iff₀ (by linarith : 0<ε/2)).mp hn
  have hexp := exponential_sample_bound (A.card:ℝ) P (ε/2) δ n hcount hδ hbudget
  constructor
  · intro i s
    exact posteriorDenominator_pos φ (1/2) (μ i) f s (hpos i)
  · apply le_trans _ (sampleProbability_mono D n (finiteClassSampleGood D f A (ε/2)) _ ?_)
    · have hh := finiteClassSampleGood_probability D f A (by linarith : ε/2≤1) n
      linarith
    · intro s hs i
      have hh := networkRisk_le_on_finiteClassSampleGood φ (μ i) D f (hpos i) A
        (by linarith : 0≤ε/2) (htail i) s hs
      simpa only [add_halves] using hh

end NeuralGeneralization.BatchTwoActivation
