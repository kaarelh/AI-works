import NeuralGeneralization.OnlineLowerTanhExactBulk

/-! # A fixed neighborhood is absorbed into the exact balanced bulk -/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set
set_option backward.isDefEq.respectTransparency false
namespace NeuralGeneralization.OnlineLowerTanh
namespace NearBalancedSequence
variable (B : NearBalancedSequence)

/-- A uniform neighborhood of the limiting gain contains only coordinates
equal to the exact bulk amplitude, for all sufficiently large maximizers. -/
theorem exists_absorption_neighborhood :
    ∃ δ : ℝ,0 < δ ∧ ∀ᶠ k in atTop,∀ i,
      |B.u k i-limitingGain| ≤ δ → B.u k i=B.bulkAmplitude k := by
  by_contra hbad
  have hfreq (δ : ℝ) (hδ : 0 < δ) :
      ∃ᶠ k in atTop,∃ i,|B.u k i-limitingGain| ≤ δ ∧ B.u k i ≠ B.bulkAmplitude k := by
    have hn : ¬∀ᶠ k in atTop,∀ i,|B.u k i-limitingGain| ≤ δ → B.u k i=B.bulkAmplitude k :=
      fun h => hbad ⟨δ,hδ,h⟩
    have hf : ∃ᶠ k in atTop,¬(∀ i,|B.u k i-limitingGain| ≤ δ → B.u k i=B.bulkAmplitude k) := by
      simpa only [Filter.Frequently,not_not] using hn
    apply hf.mono
    intro k hk
    push Not at hk
    exact hk
  obtain ⟨k₀,hk₀⟩ := eventually_atTop.mp
    (B.bulk_tendsto.eventually (eventually_gt_atTop 0))
  have hw (n : ℕ) : ∃ k,n+k₀ ≤ k ∧ ∃ i,
      |B.u k i-limitingGain| ≤ 1/((n:ℝ)+1) ∧ B.u k i ≠ B.bulkAmplitude k :=
    frequently_atTop.1 (hfreq (1/((n:ℝ)+1)) (by positivity)) (n+k₀)
  choose φ hφge i hi hne using hw
  have hφ : Tendsto φ atTop atTop :=
    tendsto_atTop_mono (fun n => (Nat.le_add_right n k₀).trans (hφge n)) tendsto_id
  let C := B.reindex φ hφ
  have hn (k : ℕ) : (B.bulk (φ k)).Nonempty :=
    Finset.card_pos.mp (hk₀ (φ k) (by have hh:=hφge k;omega))
  let j := fun k => (hn k).choose
  have hj (k : ℕ) : B.u (φ k) (j k)=B.bulkAmplitude (φ k) := by
    simp only [bulkAmplitude,dif_pos (hn k),j]
  have hbound : Tendsto (fun n : ℕ => 1/((n:ℝ)+1)) atTop (𝓝 0) :=
    tendsto_const_nhds.div_atTop (tendsto_atTop_add_const_right atTop (1:ℝ) tendsto_natCast_atTop_atTop)
  have hti : Tendsto (fun k => C.u k (i k)) atTop (𝓝 limitingGain) := by
    have hd : Tendsto (fun k => B.u (φ k) (i k)-limitingGain) atTop (𝓝 0) := by
      apply squeeze_zero_norm' _ hbound
      exact Eventually.of_forall (fun k => by simpa only [Real.norm_eq_abs] using hi k)
    change Tendsto (fun k => B.u (φ k) (i k)) atTop (𝓝 limitingGain)
    simpa only [sub_add_cancel,zero_add] using hd.add_const limitingGain
  have htj : Tendsto (fun k => C.u k (j k)) atTop (𝓝 limitingGain) := by
    change Tendsto (fun k => B.u (φ k) (j k)) atTop (𝓝 limitingGain)
    exact (B.bulkAmplitude_tendsto.comp hφ).congr'
      (Eventually.of_forall (fun k => (hj k).symm))
  obtain ⟨k,hk⟩ := (C.pair_eventually_equal i j hti htj).exists
  exact hne k (hk.trans (hj k))

/-- Every coordinate not equal to the exact bulk stays a fixed positive
distance from its moving amplitude. -/
theorem exists_outside_amplitude_gap :
    ∃ ε : ℝ,0 < ε ∧ ∀ᶠ k in atTop,∀ i,
      B.u k i ≠ B.bulkAmplitude k → ε ≤ |B.u k i-B.bulkAmplitude k| := by
  obtain ⟨δ,hδ,habsorb⟩ := B.exists_absorption_neighborhood
  have hclose : ∀ᶠ k in atTop,|B.bulkAmplitude k-limitingGain| < δ/2 := by
    have ht := (B.bulkAmplitude_tendsto.sub_const limitingGain).abs
    simp only [sub_self,abs_zero] at ht
    exact ht.eventually (gt_mem_nhds (by positivity : (0:ℝ)<δ/2))
  refine ⟨δ/2,by positivity,?_⟩
  filter_upwards [habsorb,hclose] with k hk hc i hi
  have hout : δ < |B.u k i-limitingGain| := lt_of_not_ge (fun h => hi (hk i h))
  have htri := abs_sub_le (B.u k i) (B.bulkAmplitude k) limitingGain
  linarith

end NearBalancedSequence
end NeuralGeneralization.OnlineLowerTanh
