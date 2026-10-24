import NeuralGeneralization.BatchTwoNeuralConverseMain
import NeuralGeneralization.BatchTwoCircuitConverseIIDCoverage

/-! Infinite-stream literal mistakes, including every full-support iid law. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators ENNReal
open Classical MeasureTheory ProbabilityTheory
open ConcreteModel
variable {X : Type*} [Fintype X]

def infiniteErrorCount (error : ℕ → Bool) : ℝ≥0∞ :=
  ∑' n, if error n then 1 else 0

theorem observed_mono (query : ℕ → X) {n m : ℕ} (hnm : n≤m) :
    observed query n⊆observed query m :=
  Finset.image_subset_image (Finset.range_mono hnm)

theorem no_errors_after_cover (query : ℕ → X) (error : ℕ → Bool)
    (hfresh : ErrorsAreFresh query error) (stop : ℕ) (hcover : observed query stop=Finset.univ)
    (n : ℕ) (hn : stop≤n) : error n=false := by
  cases he : error n with
  | false => rfl
  | true =>
    exfalso
    apply hfresh n he
    apply observed_mono query hn
    rw [hcover]
    exact Finset.mem_univ _

theorem infiniteErrorCount_eq_prefix (query : ℕ → X) (error : ℕ → Bool)
    (hfresh : ErrorsAreFresh query error) (stop : ℕ) (hcover : observed query stop=Finset.univ) :
    infiniteErrorCount error=(errorCount error stop:ℝ≥0∞) := by
  unfold infiniteErrorCount
  rw [tsum_eq_sum (s:=Finset.range stop) (fun n hn => by
    have he := no_errors_after_cover query error hfresh stop hcover n (Nat.le_of_not_gt (by simpa using hn))
    simp only [he,Bool.false_eq_true,↓reduceIte])]
  simp only [errorCount,Nat.cast_sum,Nat.cast_ite,Nat.cast_one,Nat.cast_zero]

theorem measurable_infiniteErrorCount {Ω : Type*} [MeasurableSpace Ω]
    (error : Ω → ℕ → Bool) (he : ∀ n,Measurable (fun ω => error ω n)) :
    Measurable (fun ω => infiniteErrorCount (error ω)) := by
  apply Measurable.ennreal_tsum
  intro n
  exact measurable_const.ite (measurableSet_eq_fun (he n) measurable_const) measurable_const

def completeRevealTime (query : ℕ → X) : ℕ :=
  if h : ∃ n,observed query n=Finset.univ then Nat.find h else 0

theorem completeRevealTime_spec (query : ℕ → X) (hc : ∃ n,observed query n=Finset.univ) :
    observed query (completeRevealTime query)=Finset.univ := by
  rw [completeRevealTime,dif_pos hc]
  exact Nat.find_spec hc

/-- Infinite total errors are bounded, measurable and equal to the finite
complete-revelation count. No finite-horizon surrogate is used. -/
theorem infinite_mistake_converse {d r : ℕ} (hd : 0<d) {Λ U : ℝ} (hΛ : 1<Λ) (hU : 1<U)
    (f : BooleanFunction d) (query : ℕ → Cube d) (error : ℕ → Bool)
    (hs : SuccessHasMinimizer (neuralSqrtAction r Λ U) f query error)
    (hfresh : ErrorsAreFresh query error) (hcover : ∃ n,observed query n=Finset.univ) :
    infiniteErrorCount error≤Fintype.card (Cube d) ∧
      realizesAtComplexity (r:=r) Real.tanh f
        (mistakeConverseWidth d r Λ U (infiniteErrorCount error).toReal) := by
  obtain ⟨n,hn⟩ := hcover
  rw [infiniteErrorCount_eq_prefix query error hfresh n hn]
  refine ⟨by exact_mod_cast fresh_count_le_card query error hfresh n,?_⟩
  simpa only [ENNReal.toReal_natCast] using polynomial_depth_mistake_converse hd hΛ hU f query error hs n hn

/-- Expected actual total errors on any a.s. complete stream. -/
theorem expected_infinite_mistake_converse {d r : ℕ} (hd : 0<d) {Λ U : ℝ} (hΛ : 1<Λ) (hU : 1<U)
    (f : BooleanFunction d) {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) [IsProbabilityMeasure μ] (query : Ω → ℕ → Cube d) (error : Ω → ℕ → Bool)
    (hs : ∀ᵐ ω ∂μ,SuccessHasMinimizer (neuralSqrtAction r Λ U) f (query ω) (error ω))
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
  have hresult := expected_polynomial_depth_mistake_converse hd hΛ hU f μ query error stop hs hfresh hstop hcount
  rw [←integral_congr_ae heq] at hresult
  refine ⟨?_,hresult⟩
  filter_upwards [hfresh,hstop] with ω hf hc
  rw [infiniteErrorCount_eq_prefix (query ω) (error ω) hf (stop ω) hc]
  exact_mod_cast fresh_count_le_card (query ω) (error ω) hf (stop ω)

/-- Full support is sufficient; no minimum atom mass is assumed. -/
theorem iid_full_support_covers {d : ℕ} {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) [IsProbabilityMeasure μ] (p : PMF (Cube d)) (hp : ∀ x,p x≠0)
    (query : Ω → ℕ → Cube d) (hquery : ∀ n,Measurable (fun ω => query ω n))
    (hind : iIndepFun (fun n ω => query ω n) μ)
    (hlaw : ∀ n x,μ {ω | query ω n=x}=p x) :
    ∀ᵐ ω ∂μ,∃ n,observed (query ω) n=Finset.univ := by
  have hh := BatchTwoCircuitConverse.iid_finite_support_cover μ p query hquery hind hlaw
  filter_upwards [hh] with ω hω
  obtain ⟨n,hn⟩ := hω.2
  refine ⟨n,?_⟩
  unfold BatchTwoCircuitConverse.history at hn
  have hdec : (fun (a b : Cube d) => Fintype.decidablePiFintype a b)=
      (fun (a b : Cube d) => Classical.propDecidable (a=b)) := Subsingleton.elim _ _
  rw [hdec] at hn
  simpa only [observed,Finset.filter_true_of_mem (fun _ _ => hp _)] using hn

/-- Infinite-iid version of the exact polynomial-depth neural converse. -/
theorem iid_mistake_converse {d r : ℕ} (hd : 0<d) {Λ U : ℝ} (hΛ : 1<Λ) (hU : 1<U)
    (f : BooleanFunction d) {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) [IsProbabilityMeasure μ] (p : PMF (Cube d)) (hp : ∀ x,p x≠0)
    (query : Ω → ℕ → Cube d) (hquery : ∀ n,Measurable (fun ω => query ω n))
    (hind : iIndepFun (fun n ω => query ω n) μ) (hlaw : ∀ n x,μ {ω | query ω n=x}=p x)
    (error : Ω → ℕ → Bool)
    (hs : ∀ᵐ ω ∂μ,SuccessHasMinimizer (neuralSqrtAction r Λ U) f (query ω) (error ω))
    (hfresh : ∀ᵐ ω ∂μ,ErrorsAreFresh (query ω) (error ω))
    (hmeas : ∀ n,Measurable (fun ω => error ω n)) :
    (∀ᵐ ω ∂μ,infiniteErrorCount (error ω)≤Fintype.card (Cube d)) ∧
    realizesAtComplexity (r:=r) Real.tanh f
      (mistakeConverseWidth d r Λ U (∫ ω,(infiniteErrorCount (error ω)).toReal ∂μ)) :=
  expected_infinite_mistake_converse hd hΛ hU f μ query error hs hfresh
    (iid_full_support_covers μ p hp query hquery hind hlaw) hmeas

#print axioms iid_mistake_converse
end
end NeuralGeneralization.BatchTwoNeuralConverse
