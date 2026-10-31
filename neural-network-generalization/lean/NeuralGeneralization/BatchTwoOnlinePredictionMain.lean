import NeuralGeneralization.BatchTwoOnlineSharpNeuralMain
import NeuralGeneralization.BatchTwoOnlineConfidenceInfinite

/-! Confidence and majority consequences of all three literal neural online
budgets. The conclusion uses actual posterior probabilities on both protocols.
At θ=2/3 these are strict-confidence failures (including equality); at θ=1/2
the counts dominate every majority rule, even if it breaks all ties wrongly. -/
noncomputable section
open scoped BigOperators ENNReal
open MeasureTheory
namespace NeuralGeneralization.BatchTwoOnline
open ConcreteModel SquaredSampling

def NetworkConfidenceBounds {d N r : ℕ} (φ : ℝ→ℝ) (a : ℝ)
    (μ : Measure (Weights d N r)) (f : BooleanFunction d) (P θ : ℝ) : Prop :=
  let w := functionMass φ a μ
  let good := fun g i => g (cubeEnumeration d i)=f (cubeEnumeration d i)
  let m := Fintype.card (Cube d)
  let β : ℝ := 1/m
  (finiteMean (permutationConfidenceCount w good θ)≤expectationBudget m P β/(1-θ)) ∧
  (∀δ : ℝ,0<δ→δ<1→finiteEvent (fun π=>
    highProbabilityBudget m P β δ/(1-θ)<permutationConfidenceCount w good θ π)≤δ) ∧
  ((∫⁻s,totalConfidence w good θ s ∂iidQueryLaw (Fin m))≤
    ENNReal.ofReal (expectationBudget m P β/(1-θ))) ∧
  (∀δ : ℝ,0<δ→δ<1→iidQueryLaw (Fin m)
    {s | ENNReal.ofReal (highProbabilityBudget m P β δ/(1-θ))<totalConfidence w good θ s}
      ≤ENNReal.ofReal δ)

theorem network_confidence_of_online {d N r : ℕ} (φ : ℝ→ℝ) (a : ℝ)
    (μ : Measure (Weights d N r)) (f : BooleanFunction d) (P : ℝ)
    (hb : NetworkOnlineBounds φ a μ f P) (θ : ℝ) (hθ : θ<1) :
    NetworkConfidenceBounds φ a μ f P θ := by
  obtain ⟨hfinite,hf,hiid⟩ := hb
  have h₁ := confidence_bounds_of_randomOrderBounds (functionMass φ a μ)
    (functionMass_nonneg φ a μ) _ f (fun _=>rfl) hf P _ hfinite θ hθ
  have h₂ := iid_confidence_bounds (functionMass φ a μ)
    (functionMass_nonneg φ a μ) _ f (fun _=>rfl) hf P _ hiid θ hθ
  exact ⟨h₁.1,h₁.2,h₂.1,h₂.2⟩

/-- Pathwise majority count on an arbitrary infinite stream, with arbitrary
tie breaking. This completes the previously finite-only majority conversion. -/
theorem infinite_majority_count_le_twice_total {H : Type*} [Fintype H] [DecidableEq H]
    {m : ℕ} (w : H→ℝ) (hw : ∀g,0≤w g) (good : H→Fin m→Prop)
    (target : H) (htarget : ∀x,good target x) (hwt : 0<w target)
    (s : ℕ→Fin m) (wrong : ℕ→Prop) [DecidablePred wrong]
    (hmajority : ∀i,wrong i→(1/2:ℝ)≤onlineError w good s i) :
    (∑' i,if wrong i then (1:ℝ≥0∞) else 0)≤2*totalError w good s := by
  have hcount : (∑' i,if wrong i then (1:ℝ≥0∞) else 0)≤
      totalConfidence w good (1/2) s := by
    apply ENNReal.tsum_le_tsum
    intro i
    by_cases hi : wrong i
    · have hbad : 1-onlineError w good s i≤(1/2:ℝ) := by linarith [hmajority i hi]
      simp only [if_pos hi,confidenceError,if_pos hbad,ENNReal.ofReal_one,le_refl]
    · simp [hi]
  have hb := totalConfidence_le_totalError w hw good target htarget hwt (1/2) (by norm_num) s
  norm_num at hb
  exact hcount.trans hb

end NeuralGeneralization.BatchTwoOnline

namespace NeuralGeneralization.BatchTwoOnlineSharp
open ConcreteModel BatchTwoOnline

theorem strongPrior_online_confidence {d C N r : ℕ}
    (hd : 1≤d) (φ : ℝ→ℝ) (hφ : admissibleActivation φ)
    (f : BooleanFunction d) (hf : realizesAtComplexity (r:=r) φ f C) (hCN : C≤N) :
    ∃σ₀ : ℝ,0<σ₀ ∧ ∀σ : ℝ,0<σ→σ<σ₀→∀θ : ℝ,θ<1→
      NetworkConfidenceBounds φ (1/2) (smallPrior d N r σ) f
        (normCapacity d r (teacherBudget d C r)) θ := by
  obtain ⟨σ₀,hσ₀,hmain⟩ := strongPrior_online_paper hd φ hφ f hf hCN
  exact ⟨σ₀,hσ₀,fun σ hσ hσlt θ hθ=>
    network_confidence_of_online φ (1/2) _ f _ (hmain σ hσ hσlt) θ hθ⟩

theorem aboveMeanField_online_confidence {d C N r : ℕ} {γ : ℝ}
    (hd : 1≤d) (hγ : 1<γ) (φ : ℝ→ℝ) (hφ : admissibleActivation φ)
    (f : BooleanFunction d) (hf : realizesAtComplexity (r:=r) φ f C) (hCN : C≤N)
    (θ : ℝ) (hθ : θ<1) :
    let K := onlineEnergy d r (targetCost d C r)
    let T := powerWidthThreshold d C r K γ
    NetworkConfidenceBounds φ (1/2) (powerPrior d N r γ) f
      (if T≤N then normCapacity d r (((r:ℝ)+5)*K) else targetCost d C r*(T:ℝ)^γ/2) θ :=
  network_confidence_of_online φ (1/2) _ f _
    (aboveMeanField_online_paper hd hγ φ hφ f hf hCN) θ hθ

theorem meanField_online_confidence {d C N r : ℕ}
    (hd : 1≤d) (f : BooleanFunction d) (hf : realizesAtComplexity (r:=r) Real.tanh f C)
    (hCN : C≤N) (θ : ℝ) (hθ : θ<1) :
    let K := onlineEnergy d r (targetCost d C r)
    let T := BatchTwoOnlineMeanFieldExact.learnerThreshold d r K
    NetworkConfidenceBounds Real.tanh (1/2) (powerPrior d N r 1) f
      (if T≤N then BatchTwoOnlineMeanFieldExact.capacity d r K else targetCost d C r*(T:ℝ)/2) θ :=
  network_confidence_of_online Real.tanh (1/2) _ f _
    (meanField_online_paper hd f hf hCN) θ hθ

end NeuralGeneralization.BatchTwoOnlineSharp
