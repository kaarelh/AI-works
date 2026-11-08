import NeuralGeneralization.OnlineLowerTanhNearPairEquality

/-! # Exact equality throughout the literal majority bulk -/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set
set_option backward.isDefEq.respectTransparency false
namespace NeuralGeneralization.OnlineLowerTanh
namespace NearBalancedSequence
variable (B : NearBalancedSequence)

/-- A selected physical coordinate supplies the common gain. The value on an
empty initial bulk is immaterial and is fixed to the limiting gain. -/
def bulkAmplitude (k : ℕ) : ℝ :=
  if h : (B.bulk k).Nonempty then B.u k h.choose else limitingGain

lemma bulkAmplitude_close :
    ∀ᶠ k in atTop,|B.bulkAmplitude k-B.a k| ≤ B.D k := by
  filter_upwards [B.bulk_tendsto.eventually (eventually_gt_atTop 0)] with k hk
  have hn : (B.bulk k).Nonempty := Finset.card_pos.mp hk
  simp only [bulkAmplitude,dif_pos hn]
  exact B.bulk_close k hn.choose hn.choose_spec

lemma bulkAmplitude_tendsto : Tendsto B.bulkAmplitude atTop (𝓝 limitingGain) := by
  have ht : Tendsto (fun k => B.bulkAmplitude k-B.a k) atTop (𝓝 0) := by
    apply squeeze_zero_norm' _ B.D_tendsto
    simpa only [Real.norm_eq_abs] using B.bulkAmplitude_close
  simpa only [sub_add_cancel,zero_add] using ht.add B.a_tendsto

lemma bulkAmplitude_eventually_mem : ∀ᶠ k in atTop,B.bulkAmplitude k ∈ Icc (1:ℝ) 2 := by
  have hlo : (1:ℝ)<limitingGain := by linarith [limitingGain_mem.1]
  have hhi : limitingGain<(2:ℝ) := by linarith [limitingGain_mem.2]
  filter_upwards [B.bulkAmplitude_tendsto.eventually (lt_mem_nhds hlo),
    B.bulkAmplitude_tendsto.eventually (gt_mem_nhds hhi)] with k hk hl
  exact ⟨hk.le,hl.le⟩

/-- All coordinates of the selected majority bulk are exactly equal eventually. -/
theorem bulk_eventually_equal :
    ∀ᶠ k in atTop,∀ i ∈ B.bulk k,∀ j ∈ B.bulk k,B.u k i=B.u k j := by
  by_contra hbad
  have hf : ∃ᶠ k in atTop,¬(∀ i ∈ B.bulk k,∀ j ∈ B.bulk k,B.u k i=B.u k j) := by
    simpa only [Filter.Frequently,not_not] using hbad
  have hf' : ∃ᶠ k in atTop,∃ i ∈ B.bulk k,∃ j ∈ B.bulk k,B.u k i ≠ B.u k j := by
    apply hf.mono
    intro k hk
    push_neg at hk
    exact hk
  obtain ⟨φ,hφ,hw⟩ := Filter.subseq_forall_of_frequently (x := fun k : ℕ => k)
    (p := fun k => ∃ i ∈ B.bulk k,∃ j ∈ B.bulk k,B.u k i ≠ B.u k j) tendsto_id hf'
  choose i hi j hj hne using hw
  let C := B.reindex φ hφ
  have hti : Tendsto (fun k => C.u k (i k)) atTop (𝓝 limitingGain) :=
    C.bulk_coordinate_tendsto i hi
  have htj : Tendsto (fun k => C.u k (j k)) atTop (𝓝 limitingGain) :=
    C.bulk_coordinate_tendsto j hj
  obtain ⟨k,hk⟩ := (C.pair_eventually_equal i j hti htj).exists
  exact hne k hk

/-- A literal common amplitude exists on the original bulk, whose size tends
to infinity; no optimizer or equality assumption is added to the sequence. -/
theorem bulk_eventually_constant :
    ∀ᶠ k in atTop,∃ a : ℝ,∀ i ∈ B.bulk k,B.u k i=a := by
  filter_upwards [B.bulk_eventually_equal,
    B.bulk_tendsto.eventually (eventually_gt_atTop 0)] with k hk hn
  obtain ⟨j,hj⟩ := Finset.card_pos.mp hn
  exact ⟨B.u k j,fun i hi => hk i hi j hj⟩

theorem bulk_eventually_amplitude :
    ∀ᶠ k in atTop,∀ i ∈ B.bulk k,B.u k i=B.bulkAmplitude k := by
  filter_upwards [B.bulk_eventually_equal] with k hk i hi
  have hn : (B.bulk k).Nonempty := ⟨i,hi⟩
  simp only [bulkAmplitude,dif_pos hn]
  exact hk i hi hn.choose hn.choose_spec

end NearBalancedSequence
end NeuralGeneralization.OnlineLowerTanh
