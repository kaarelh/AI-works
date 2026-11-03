import NeuralGeneralization.BatchTwoOnlineActualDraws
import NeuralGeneralization.BatchTwoOnlineSetSampled
import NeuralGeneralization.BatchTwoOnlineRawIID

/-! Exact infinite uniform-IID sampled-mistake domination for arbitrary
set-dependent posterior measures, including continuous parameter spaces. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators ENNReal
open Classical
attribute [local instance] Classical.propDecidable
namespace NeuralGeneralization.BatchTwoOnlineRaw
open BatchTwoOnline SquaredSampling
variable {W : Type*} [MeasurableSpace W] {m : ℕ}

def setDrawLaw (Q : Finset (Fin m) → Measure W) (query : ℕ → Fin m) : Measure (ℕ → W) :=
  Measure.infinitePi (fun n => Q ((Finset.range n).image query))

def actualStreamError (err : W → Fin m → Prop) (query : ℕ → Fin m) (n : ℕ) (draw : ℕ → W) : ℝ :=
  if err (draw n) (query n) then 1 else 0

def actualStreamTotal (err : W → Fin m → Prop) (query : ℕ → Fin m) (draw : ℕ → W) : ℝ≥0∞ :=
  ∑' n,ENNReal.ofReal (actualStreamError err query n draw)

lemma actualStreamError_nonneg (err : W → Fin m → Prop) (query : ℕ → Fin m) (n : ℕ) (draw : ℕ → W) :
    0 ≤ actualStreamError err query n draw := by unfold actualStreamError; split_ifs <;> norm_num

lemma measurable_actualErrorCount (err : W → Fin m → Prop)
    (herr : ∀ x,MeasurableSet {w | err w x}) {n : ℕ} (s : Fin n → Fin m) :
    Measurable (actualErrorCount err s) := by
  unfold actualErrorCount
  apply Finset.measurable_sum
  intro i _
  exact Measurable.ite ((herr (s i)).preimage (measurable_pi_apply i)) measurable_const measurable_const

variable (Q : Finset (Fin m) → Measure W) [∀ S,IsProbabilityMeasure (Q S)]
variable (err : W → Fin m → Prop) (herr : ∀ x,MeasurableSet {w | err w x})
include herr

lemma actual_prefix_tail (query : ℕ → Fin m) (n : ℕ) (U : ℝ) :
    setDrawLaw Q query {draw | U < ∑ i∈Finset.range n,actualStreamError err query i draw} =
      ENNReal.ofReal (setSampledTail (fun S x => (Q S).real {w | err w x}) U (sequencePrefix n query)) := by
  have hE := measurableSet_lt (measurable_const (a := U))
    (measurable_actualErrorCount err herr (sequencePrefix n query))
  have he := Measure.map_apply (μ := setDrawLaw Q query) (f := sequencePrefix (X := W) n)
    (measurable_sequencePrefix n) hE
  unfold setDrawLaw at he
  rw [infinitePi_map_sequencePrefix] at he
  have hset : sequencePrefix n ⁻¹' {draw | U < actualErrorCount err (sequencePrefix n query) draw} =
      {draw | U < ∑ i∈Finset.range n,actualStreamError err query i draw} := by
    ext draw
    change (U < ∑ i : Fin n,actualStreamError err query i.val draw) ↔
      U < ∑ i∈Finset.range n,actualStreamError err query i draw
    rw [Fin.sum_univ_eq_sum_range (fun i => actualStreamError err query i draw) n]
  rw [hset] at he
  unfold setDrawLaw
  rw [← he]
  have ht := actual_draw_tail_identity (fun i : Fin n => Q ((Finset.range i.val).image query))
    err herr (sequencePrefix n query) U
  have hreal : (Measure.pi (fun i : Fin n => Q ((Finset.range i.val).image query))).real
      {draw | U < actualErrorCount err (sequencePrefix n query) draw} =
      setSampledTail (fun S x => (Q S).real {w | err w x}) U (sequencePrefix n query) := by
    rw [ht]
    simp only [setSampledTail,seenSet_prefix,sequencePrefix]
  rw [← hreal,measureReal_def,ENNReal.ofReal_toReal (measure_ne_top _ _)]

/-- Exact expectation equality under the conditional law of infinitely many
actual posterior draws; countably many rounds are handled by Tonelli. -/
theorem actual_stream_expectation (query : ℕ → Fin m) :
    (∫⁻ draw,actualStreamTotal err query draw ∂setDrawLaw Q query) =
      streamTotal (fun S x => (Q S).real {w | err w x}) query := by
  have hm (i : ℕ) : Measurable (actualStreamError err query i) :=
    Measurable.ite ((herr (query i)).preimage (measurable_pi_apply i)) measurable_const measurable_const
  unfold actualStreamTotal streamTotal
  rw [lintegral_tsum (fun i => (hm i).ennreal_ofReal.aemeasurable)]
  apply tsum_congr
  intro i
  have hi : (fun w : W => ENNReal.ofReal (if err w (query i) then (1:ℝ) else 0)) =
      ({w | err w (query i)} : Set W).indicator (fun _ => (1:ℝ≥0∞)) := by
    funext w
    by_cases hw : err w (query i) <;> simp [hw]
  have hmeas : Measurable (fun w : W => ENNReal.ofReal (if err w (query i) then (1:ℝ) else 0)) := by
    rw [hi]
    exact measurable_const.indicator (herr _)
  have he := lintegral_map (μ := setDrawLaw Q query) hmeas (measurable_pi_apply i)
  unfold setDrawLaw at he
  rw [Measure.infinitePi_map_eval,hi,lintegral_indicator (herr _)] at he
  simp only [lintegral_const,Measure.restrict_apply_univ,one_mul] at he
  unfold actualStreamError setDrawLaw streamRound
  rw [← he]
  simp only [measureReal_def,ENNReal.ofReal_toReal (measure_ne_top _ _)]

variable [NeZero m]

/-- The literal query-then-posterior experiment has the same sharp tail as
one uniform permutation. No separate independence assumption across first
appearance times is needed. -/
theorem actual_iid_tail_le_permutation (hm : 0 < m)
    (hrepeat : ∀ S x,x ∈ S → (Q S).real {w | err w x}=0) (U : ℝ) (hU : 0 ≤ U) :
    (∫⁻ query,setDrawLaw Q query {draw | ENNReal.ofReal U < actualStreamTotal err query draw}
      ∂iidQueryLaw (Fin m)) ≤
      ENNReal.ofReal (finiteMean (setPermutationSampledTail (fun S x => (Q S).real {w | err w x}) U)) := by
  let R := fun S x => (Q S).real {w | err w x}
  have hR (S x) : 0 ≤ R S x ∧ R S x ≤ 1 := ⟨measureReal_nonneg,measureReal_le_one⟩
  let F (n : ℕ) (query : ℕ → Fin m) : ℝ≥0∞ :=
    setDrawLaw Q query {draw | U < ∑ i∈Finset.range n,actualStreamError err query i draw}
  have hF (n query) : F n query=ENNReal.ofReal (setSampledTail R U (sequencePrefix n query)) :=
    actual_prefix_tail Q err herr query n U
  have hFm (n : ℕ) : Measurable (F n) := by
    have he : F n=(fun s : Fin n → Fin m => ENNReal.ofReal (setSampledTail R U s)) ∘ sequencePrefix n :=
      funext (hF n)
    rw [he]
    exact (measurable_of_finite _).comp (measurable_sequencePrefix n)
  have hmono : Monotone F := by
    intro n k hnk query
    apply measure_mono
    intro draw hdraw
    exact hdraw.trans_le (nonnegative_partial_monotone (actualStreamError err query)
      (actualStreamError_nonneg err query) draw hnk)
  have he (query : ℕ → Fin m) :
      setDrawLaw Q query {draw | ENNReal.ofReal U < actualStreamTotal err query draw} = ⨆ n,F n query := by
    have hs : {draw | ENNReal.ofReal U < actualStreamTotal err query draw} =
        ⋃ n,{draw | U < ∑ i∈Finset.range n,actualStreamError err query i draw} := by
      ext draw
      simp only [Set.mem_setOf_eq,Set.mem_iUnion,actualStreamTotal,
        infinite_total_eq_iSup (actualStreamError err query) (actualStreamError_nonneg err query) draw,
        lt_iSup_iff,ENNReal.ofReal_lt_ofReal_iff_of_nonneg hU]
    rw [hs]
    exact (show Monotone (fun n => {draw | U < ∑ i∈Finset.range n,actualStreamError err query i draw}) from
      fun n k hnk draw hd => hd.trans_le (nonnegative_partial_monotone
        (actualStreamError err query) (actualStreamError_nonneg err query) draw hnk)).measure_iUnion
  rw [show (fun query => setDrawLaw Q query {draw | ENNReal.ofReal U < actualStreamTotal err query draw}) =
      (fun query => ⨆ n,F n query) from funext he,lintegral_iSup hFm hmono]
  apply iSup_le
  intro n
  have hnon (s : Fin n → Fin m) : 0 ≤ setSampledTail R U s := by
    apply Finset.sum_nonneg
    intro b _
    split_ifs
    · exact independentWeight_nonneg _ (fun i => errorBitWeight_nonneg (hR _ _)) b
    · exact le_rfl
  rw [funext (hF n),iidQueryLaw_prefix_lintegral n (setSampledTail R U) hnon]
  exact ENNReal.ofReal_le_ofReal (setSampledTail_le_permutation hm R hR hrepeat n U)

#print axioms actual_iid_tail_le_permutation
end NeuralGeneralization.BatchTwoOnlineRaw
