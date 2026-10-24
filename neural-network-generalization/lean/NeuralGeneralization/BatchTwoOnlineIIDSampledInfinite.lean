import NeuralGeneralization.BatchTwoOnlineIIDInfinite

/-! # Literal posterior draws at every round of an infinite IID stream -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators ENNReal
open Classical MeasureTheory ProbabilityTheory
attribute [local instance] Classical.propDecidable
namespace NeuralGeneralization.BatchTwoOnline
open SquaredSampling
variable {H X : Type*} [Fintype H] [DecidableEq H] [MeasurableSpace H] [MeasurableSingletonClass H]

/-- Conditional on the entire query sequence, fresh hypotheses are independent
and each has the actual consistency-posterior law at that round. -/
def posteriorSampleLaw (w : H → ℝ) (good : H → X → Prop) (query : ℕ → X)
    (hw : ∀ g,0 ≤ w g) (target : H) (htarget : ∀ x,good target x) (hwt : 0 < w target) :
    Measure (ℕ → H) :=
  Measure.infinitePi (fun n => finiteWeightLaw (onlinePosterior w good query n)
    (onlinePosterior_nonneg w good query hw target htarget hwt n)
    (onlinePosterior_sum w good query hw target htarget hwt n))

instance posteriorSampleLaw_probability (w : H → ℝ) (good : H → X → Prop) (query : ℕ → X)
    (hw : ∀ g,0 ≤ w g) (target : H) (htarget : ∀ x,good target x) (hwt : 0 < w target) :
    IsProbabilityMeasure (posteriorSampleLaw w good query hw target htarget hwt) := by
  unfold posteriorSampleLaw
  infer_instance

def sampledError (good : H → X → Prop) (query : ℕ → X) (n : ℕ) (draw : ℕ → H) : ℝ :=
  if good (draw n) (query n) then 0 else 1

def sampledTotal (good : H → X → Prop) (query : ℕ → X) (draw : ℕ → H) : ℝ≥0∞ :=
  ∑' n,ENNReal.ofReal (sampledError good query n draw)

lemma sampledError_nonneg (good : H → X → Prop) (query : ℕ → X) (n : ℕ) (draw : ℕ → H) :
    0 ≤ sampledError good query n draw := by unfold sampledError; split_ifs <;> norm_num

lemma measurable_sampledError (good : H → X → Prop) (query : ℕ → X) (n : ℕ) :
    Measurable (sampledError good query n) :=
  (measurable_of_finite (fun g : H => if good g (query n) then (0:ℝ) else 1)).comp (measurable_pi_apply n)

lemma expected_sampledError (w : H → ℝ) (good : H → X → Prop) (query : ℕ → X)
    (hw : ∀ g,0 ≤ w g) (target : H) (htarget : ∀ x,good target x) (hwt : 0 < w target) (n : ℕ) :
    (∫⁻ draw,ENNReal.ofReal (sampledError good query n draw)
      ∂posteriorSampleLaw w good query hw target htarget hwt) = ENNReal.ofReal (onlineError w good query n) := by
  have he := lintegral_map (μ := posteriorSampleLaw w good query hw target htarget hwt)
    (f := fun g : H => ENNReal.ofReal (if good g (query n) then (0:ℝ) else 1))
    (measurable_of_finite _) (measurable_pi_apply n)
  unfold posteriorSampleLaw at he
  rw [Measure.infinitePi_map_eval, finiteWeightLaw_lintegral _ _ _ _
    (fun g => by split_ifs <;> norm_num)] at he
  unfold sampledError posteriorSampleLaw
  rw [← he]
  congr 1
  unfold onlineError
  apply Finset.sum_congr rfl
  intro g _
  split_ifs <;> simp

/-- Equality of the actual infinite sampled-mistake expectation and the
predictable posterior-error sum, conditional on every query stream. -/
theorem expected_sampledTotal_eq (w : H → ℝ) (good : H → X → Prop) (query : ℕ → X)
    (hw : ∀ g,0 ≤ w g) (target : H) (htarget : ∀ x,good target x) (hwt : 0 < w target) :
    (∫⁻ draw,sampledTotal good query draw ∂posteriorSampleLaw w good query hw target htarget hwt) =
      totalError w good query := by
  unfold sampledTotal totalError
  rw [lintegral_tsum (fun n => (measurable_sampledError good query n).ennreal_ofReal.aemeasurable)]
  exact tsum_congr (expected_sampledError w good query hw target htarget hwt)

lemma posteriorSampleLaw_prefix (w : H → ℝ) (good : H → X → Prop) (query : ℕ → X)
    (hw : ∀ g,0 ≤ w g) (target : H) (htarget : ∀ x,good target x) (hwt : 0 < w target) (n : ℕ) :
    (posteriorSampleLaw w good query hw target htarget hwt).map (sequencePrefix n) =
      Measure.pi (fun i : Fin n => finiteWeightLaw (onlinePosterior w good query i.val)
        (onlinePosterior_nonneg w good query hw target htarget hwt i.val)
        (onlinePosterior_sum w good query hw target htarget hwt i.val)) :=
  infinitePi_map_sequencePrefix _ n

lemma sampledPrefix_eq (good : H → X → Prop) (query : ℕ → X) (n : ℕ) (draw : ℕ → H) :
    (∑ i∈Finset.range n,sampledError good query i draw) =
      sequentialMistakes good query n (sequencePrefix n draw) := by
  exact (Fin.sum_univ_eq_sum_range (fun i => sampledError good query i draw) n).symm

lemma posteriorSampleLaw_prefix_event (w : H → ℝ) (good : H → X → Prop) (query : ℕ → X)
    (hw : ∀ g,0 ≤ w g) (target : H) (htarget : ∀ x,good target x) (hwt : 0 < w target)
    (n : ℕ) (U : ℝ) :
    posteriorSampleLaw w good query hw target htarget hwt
      {draw | U < ∑ i∈Finset.range n,sampledError good query i draw} =
      ENNReal.ofReal (∑ draw : Fin n → H, if U < sequentialMistakes good query n draw
        then sequentialDrawWeight w good query n draw else 0) := by
  have he := Measure.map_apply
    (μ := posteriorSampleLaw w good query hw target htarget hwt) (f := sequencePrefix (X := H) n)
    (measurable_sequencePrefix n)
    ((Set.to_countable {draw : Fin n → H | U < sequentialMistakes good query n draw}).measurableSet)
  rw [posteriorSampleLaw_prefix, productWeightLaw_event] at he
  convert he.symm using 1
  · congr 1
    ext draw
    simp only [Set.mem_setOf_eq, Set.mem_preimage, sampledPrefix_eq]
  · unfold sequentialDrawWeight
    congr! 5

variable {m : ℕ} [NeZero m]

lemma sequential_tail_eq_iidSampledTail (hm : 0 < m) (w : H → ℝ) (good : H → Fin m → Prop)
    (query : ℕ → Fin m) (n : ℕ) (U : ℝ) :
    (∑ draw : Fin n → H, if U < sequentialMistakes good query n draw
      then sequentialDrawWeight w good query n draw else 0) =
      iidSampledTail hm w good U (sequencePrefix n query) := by
  have hp (i : Fin n) := onlinePosterior_eq_prefix hm w good query n i.val i.isLt
  unfold sequentialMistakes sequentialDrawWeight iidSampledTail iidMistakes iidDrawWeight
    sequentialDrawWeight independentWeight pointLoss
  simp only [sequencePrefix, hp]

/-- On each finite horizon, the conditional tail probability is a measurable
function of the finite query prefix and equals the previously proved finite law. -/
lemma posteriorSampleLaw_iid_prefix_event (hm : 0 < m)
    (w : H → ℝ) (good : H → Fin m → Prop) (query : ℕ → Fin m)
    (hw : ∀ g,0 ≤ w g) (target : H) (htarget : ∀ x,good target x) (hwt : 0 < w target)
    (n : ℕ) (U : ℝ) :
    posteriorSampleLaw w good query hw target htarget hwt
      {draw | U < ∑ i∈Finset.range n,sampledError good query i draw} =
      ENNReal.ofReal (iidSampledTail hm w good U (sequencePrefix n query)) := by
  rw [posteriorSampleLaw_prefix_event, sequential_tail_eq_iidSampledTail hm]

/-- This iterated integral is the literal experiment: first draw an infinite
IID query stream, then draw a fresh hypothesis from each actual posterior. -/
theorem iid_expected_sampledTotal_eq (w : H → ℝ) (good : H → Fin m → Prop)
    (hw : ∀ g,0 ≤ w g) (target : H) (htarget : ∀ x,good target x) (hwt : 0 < w target) :
    (∫⁻ query, ∫⁻ draw,sampledTotal good query draw
      ∂posteriorSampleLaw w good query hw target htarget hwt ∂iidQueryLaw (Fin m)) =
      ∫⁻ query,totalError w good query ∂iidQueryLaw (Fin m) :=
  lintegral_congr (fun query => expected_sampledTotal_eq w good query hw target htarget hwt)

lemma iidSampledTail_nonneg (hm : 0 < m) (w : H → ℝ) (good : H → Fin m → Prop)
    (hw : ∀ g,0 ≤ w g) (target : H) (htarget : ∀ x,good target x) (hwt : 0 < w target)
    (n : ℕ) (U : ℝ) (query : Fin n → Fin m) : 0 ≤ iidSampledTail hm w good U query := by
  unfold iidSampledTail
  apply Finset.sum_nonneg
  intro draw _
  split_ifs
  · exact independentWeight_nonneg _
      (fun i g => onlinePosterior_nonneg w good _ hw target htarget hwt i.val g) draw
  · exact le_rfl

/-- Exact infinite-IID sampled-mistake tail domination under the literal
query-then-posterior product experiment. No exceptional infinite path is omitted. -/
theorem iid_sampledTotal_tail_le_permutation (hm : 0 < m)
    (w : H → ℝ) (good : H → Fin m → Prop)
    (hw : ∀ g,0 ≤ w g) (target : H) (htarget : ∀ x,good target x) (hwt : 0 < w target)
    (U : ℝ) (hU : 0 ≤ U) :
    (∫⁻ query, posteriorSampleLaw w good query hw target htarget hwt
      {draw | ENNReal.ofReal U < sampledTotal good query draw} ∂iidQueryLaw (Fin m)) ≤
      ENNReal.ofReal (finiteMean (fun π : Equiv.Perm (Fin m) => ∑ draw,
        if U < sampledMistakes good π draw then permutationDrawWeight w good π draw else 0)) := by
  let F (n : ℕ) (query : ℕ → Fin m) : ℝ≥0∞ :=
    posteriorSampleLaw w good query hw target htarget hwt
      {draw | U < ∑ i∈Finset.range n,sampledError good query i draw}
  have hF (n : ℕ) (query : ℕ → Fin m) : F n query =
      ENNReal.ofReal (iidSampledTail hm w good U (sequencePrefix n query)) :=
    posteriorSampleLaw_iid_prefix_event hm w good query hw target htarget hwt n U
  have hFm (n : ℕ) : Measurable (F n) := by
    have he : F n = (fun s : Fin n → Fin m => ENNReal.ofReal (iidSampledTail hm w good U s)) ∘
        sequencePrefix n := funext (hF n)
    rw [he]
    exact (measurable_of_finite _).comp (measurable_sequencePrefix n)
  have hmono : Monotone F := by
    intro n k hnk query
    apply measure_mono
    intro draw hdraw
    exact hdraw.trans_le (nonnegative_partial_monotone (sampledError good query)
      (sampledError_nonneg good query) draw hnk)
  have he (query : ℕ → Fin m) :
      posteriorSampleLaw w good query hw target htarget hwt
        {draw | ENNReal.ofReal U < sampledTotal good query draw} = ⨆ n,F n query := by
    have hs : {draw | ENNReal.ofReal U < sampledTotal good query draw} =
        ⋃ n,{draw | U < ∑ i∈Finset.range n,sampledError good query i draw} := by
      ext draw
      simp only [Set.mem_setOf_eq, Set.mem_iUnion, sampledTotal,
        infinite_total_eq_iSup (sampledError good query) (sampledError_nonneg good query) draw,
        lt_iSup_iff, ENNReal.ofReal_lt_ofReal_iff_of_nonneg hU]
    rw [hs]
    exact (show Monotone (fun n => {draw | U < ∑ i∈Finset.range n,sampledError good query i draw}) from
      fun n k hnk draw hd => hd.trans_le (nonnegative_partial_monotone
        (sampledError good query) (sampledError_nonneg good query) draw hnk)).measure_iUnion
  rw [show (fun query => posteriorSampleLaw w good query hw target htarget hwt
      {draw | ENNReal.ofReal U < sampledTotal good query draw}) = (fun query => ⨆ n,F n query) from funext he,
    lintegral_iSup hFm hmono]
  apply iSup_le
  intro n
  have hfun := funext (hF n)
  rw [hfun, iidQueryLaw_prefix_lintegral n (iidSampledTail hm w good U)
    (iidSampledTail_nonneg hm w good hw target htarget hwt n U)]
  exact ENNReal.ofReal_le_ofReal (iidSampledTail_le_permutation hm w hw good target htarget hwt n U)

end NeuralGeneralization.BatchTwoOnline
