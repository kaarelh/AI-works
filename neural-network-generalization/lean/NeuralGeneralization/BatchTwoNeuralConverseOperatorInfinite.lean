import NeuralGeneralization.BatchTwoNeuralConverseOperatorMain
import NeuralGeneralization.BatchTwoNeuralConverseInfinite
import NeuralGeneralization.BatchTwoCircuitConverseIIDCoverage

/-! Infinite-stream literal mistakes, including every full-support iid law. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators ENNReal
open Classical MeasureTheory ProbabilityTheory
open ConcreteModel
/-- Infinite total errors are bounded, measurable and equal to the finite
complete-revelation count. No finite-horizon surrogate is used. -/
theorem operator_infinite_mistake_converse {d r : ℕ} (hd : 0<d) {Λ U : ℝ} (hΛ : 1<Λ) (hU : 1<U)
    (f : BooleanFunction d) (query : ℕ → Cube d) (error : ℕ → Bool)
    (hs : SuccessHasMinimizer (operator_neuralSqrtAction r U) f query error)
    (hfresh : ErrorsAreFresh query error) (hcover : ∃ n,observed query n=Finset.univ) :
    infiniteErrorCount error≤Fintype.card (Cube d) ∧
      realizesAtComplexity (r:=r) Real.tanh f
        (mistakeConverseWidth d r Λ U (infiniteErrorCount error).toReal) := by
  obtain ⟨n,hn⟩ := hcover
  rw [infiniteErrorCount_eq_prefix query error hfresh n hn]
  refine ⟨by exact_mod_cast fresh_count_le_card query error hfresh n,?_⟩
  simpa only [ENNReal.toReal_natCast] using operator_polynomial_depth_mistake_converse hd hΛ hU f query error hs n hn

/-- Expected actual total errors on any a.s. complete stream. -/
theorem operator_expected_infinite_mistake_converse {d r : ℕ} (hd : 0<d) {Λ U : ℝ} (hΛ : 1<Λ) (hU : 1<U)
    (f : BooleanFunction d) {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) [IsProbabilityMeasure μ] (query : Ω → ℕ → Cube d) (error : Ω → ℕ → Bool)
    (hs : ∀ᵐ ω ∂μ,SuccessHasMinimizer (operator_neuralSqrtAction r U) f (query ω) (error ω))
    (hfresh : ∀ᵐ ω ∂μ,ErrorsAreFresh (query ω) (error ω))
    (hcover : ∀ᵐ ω ∂μ,∃ n,observed (query ω) n=Finset.univ)
    (hmeas : ∀ n,Measurable (fun ω => error ω n)) :
    (∀ᵐ ω ∂μ,infiniteErrorCount (error ω)≤Fintype.card (Cube d)) ∧
    realizesAtComplexity (r:=r) Real.tanh f
      (mistakeConverseWidth d r Λ U (∫ ω,(infiniteErrorCount (error ω)).toReal ∂μ)) := by
  let stop := fun ω => completeRevealTime (query ω)
  have hstop : ∀ᵐ ω ∂μ,observed (query ω) (stop ω)=Finset.univ :=
    hcover.mono (fun ω hω => completeRevealTime_spec _ hω)
  have heq : ∀ᵐ ω ∂μ,(infiniteErrorCount (error ω)).toReal=(errorCount (error ω) (stop ω):ℝ) := by
    filter_upwards [hfresh,hstop] with ω hf hc
    rw [infiniteErrorCount_eq_prefix (query ω) (error ω) hf (stop ω) hc,ENNReal.toReal_natCast]
  have hcount : AEStronglyMeasurable (fun ω => (errorCount (error ω) (stop ω):ℝ)) μ :=
    ((measurable_infiniteErrorCount error hmeas).ennreal_toReal.aestronglyMeasurable).congr heq
  have hresult := operator_expected_polynomial_depth_mistake_converse hd hΛ hU f μ query error stop hs hfresh hstop hcount
  rw [←integral_congr_ae heq] at hresult
  refine ⟨?_,hresult⟩
  filter_upwards [hfresh,hstop] with ω hf hc
  rw [infiniteErrorCount_eq_prefix (query ω) (error ω) hf (stop ω) hc]
  exact_mod_cast fresh_count_le_card (query ω) (error ω) hf (stop ω)

/-- Infinite-iid version of the exact polynomial-depth neural converse. -/
theorem operator_iid_mistake_converse {d r : ℕ} (hd : 0<d) {Λ U : ℝ} (hΛ : 1<Λ) (hU : 1<U)
    (f : BooleanFunction d) {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) [IsProbabilityMeasure μ] (p : PMF (Cube d)) (hp : ∀ x,p x≠0)
    (query : Ω → ℕ → Cube d) (hquery : ∀ n,Measurable (fun ω => query ω n))
    (hind : iIndepFun (fun n ω => query ω n) μ) (hlaw : ∀ n x,μ {ω | query ω n=x}=p x)
    (error : Ω → ℕ → Bool)
    (hs : ∀ᵐ ω ∂μ,SuccessHasMinimizer (operator_neuralSqrtAction r U) f (query ω) (error ω))
    (hfresh : ∀ᵐ ω ∂μ,ErrorsAreFresh (query ω) (error ω))
    (hmeas : ∀ n,Measurable (fun ω => error ω n)) :
    (∀ᵐ ω ∂μ,infiniteErrorCount (error ω)≤Fintype.card (Cube d)) ∧
    realizesAtComplexity (r:=r) Real.tanh f
      (mistakeConverseWidth d r Λ U (∫ ω,(infiniteErrorCount (error ω)).toReal ∂μ)) :=
  operator_expected_infinite_mistake_converse hd hΛ hU f μ query error hs hfresh
    (iid_full_support_covers μ p hp query hquery hind hlaw) hmeas

#print axioms operator_iid_mistake_converse
end
end NeuralGeneralization.BatchTwoNeuralConverse
