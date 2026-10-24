import NeuralGeneralization.BatchTwoContinuousDepthCriticalFreeTracking
import NeuralGeneralization.BatchTwoContinuousDepthCriticalControlledTracking

/-! One fixed finite-width tolerance suffices for the complete seed, cooling,
amplification and saturation schedule. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
open ConcreteModel

/-- Pure population-to-empirical bridge. Every hypothesis is a local numerical
property of the actual finite path; the probability of these properties is
proved separately from the genuine Gaussian weight law. -/
theorem phase_sequence_saturates {J:Type*} [Fintype J] {n P H h:ℕ}
    (hn:0<n) (hP:0<P) (hH:H≤h) (labels:J→Bool) :
    ∃δ:ℝ,0<δ ∧ ∀ {I:Type*} [Fintype I]
      (s:ℕ→((J→ℝ)×(J→ℝ))) (c:ℕ→J→I→ℝ),
      (∀k,k≤H→s k∈momentBox J) →
      (∀i,seedSignal n P≤labelReal (labels i)*(s 0).2 i) →
      (∀k,k<H→dist (s (k+1)) (freeMomentMap (s k))<δ) →
      (∀k,k≤amplificationCount (retainedSignal n P h)→∀i,∑j,c k i j^2≤1) →
      (∀k,k<amplificationCount (retainedSignal n P h)→∀i,
        |(s (H+k+1)).2 i-gaussianRowMean (c k i)
          (robustAmplificationGain*(s (H+k)).2 i)|<δ) →
      (∀i,|(s (H+amplificationCount (retainedSignal n P h)+1)).2 i-
        gaussianRowMean (c (amplificationCount (retainedSignal n P h)) i)
          (saturationGain*(s (H+amplificationCount (retainedSignal n P h))).2 i)|<δ) →
      ∀i,|(s (H+amplificationCount (retainedSignal n P h)+1)).2 i-labelReal (labels i)|<1/50 := by
  let u:=retainedSignal n P h
  let m:=amplificationCount u
  have hu:0<u:=retainedSignal_pos hn hP h
  have hu1:u≤1:=retainedSignal_le_one hn hP h
  obtain ⟨δ₀,hδ₀,hfree⟩:=free_layers_retain_signal hn hP hH labels
  let δ:=min δ₀ (min u (min (amplificationConstant/2) (1/100)))
  have hδ:0<δ := lt_min hδ₀ (lt_min hu (lt_min (by linarith [amplificationConstant_pos]) (by norm_num)))
  have hδfree:δ≤δ₀:=min_le_left _ _
  have hδu:δ≤u:=(min_le_right _ _).trans (min_le_left _ _)
  have hδC:δ≤amplificationConstant/2:=(min_le_right _ _).trans ((min_le_right _ _).trans (min_le_left _ _))
  have hδsat:δ≤1/100:=(min_le_right _ _).trans ((min_le_right _ _).trans (min_le_right _ _))
  refine ⟨δ,hδ,?_⟩
  intro I _ s c hs hseed hstep hc hamp hsat i
  have hinitial:u<labelReal (labels i)*(s H).2 i :=
    hfree s hs hseed (fun k hk=>(hstep k hk).trans_le hδfree) i
  have hind:∀k,k≤m→min ((2:ℝ)^k*u) (amplificationConstant/2)≤labelReal (labels i)*(s (H+k)).2 i := by
    intro k
    induction k with
    | zero=>
      intro _
      simpa only [Nat.add_zero,pow_zero,one_mul] using (min_le_left u (amplificationConstant/2)).trans hinitial.le
    | succ k ih=>
      intro hk
      have hi:=ih (by omega)
      have hpow:u≤(2:ℝ)^k*u := by
        have hh:1≤(2:ℝ)^k:=one_le_pow₀ (by norm_num)
        nlinarith
      have hbase:min u (amplificationConstant/2)≤labelReal (labels i)*(s (H+k)).2 i :=
        (min_le_min hpow le_rfl).trans hi
      have hbasepos:0<min u (amplificationConstant/2):=lt_min hu (by linarith [amplificationConstant_pos])
      have hraw:=signed_amplification_with_error (c k i) (hc k (by change k≤m;omega) i) (labels i)
        (hbasepos.le.trans hbase) (hamp k (by change k<m;omega) i).le
      have hnext:=robust_amplification_step hbasepos hbase (le_min hδu hδC) hδC hraw
      have hh:min (2*min ((2:ℝ)^k*u) (amplificationConstant/2)) (amplificationConstant/2)≤
          min (2*(labelReal (labels i)*(s (H+k)).2 i)) (amplificationConstant/2):=
        min_le_min (mul_le_mul_of_nonneg_left hi (by norm_num : (0:ℝ)≤2)) le_rfl
      have he:min (2*min ((2:ℝ)^k*u) (amplificationConstant/2)) (amplificationConstant/2)=
          min ((2:ℝ)^(k+1)*u) (amplificationConstant/2) := by
        rw [mul_min_of_nonneg _ _ (by norm_num : (0:ℝ)≤2),pow_succ]
        rw [min_assoc,min_eq_right (show amplificationConstant/2≤2*(amplificationConstant/2) by linarith [amplificationConstant_pos])]
        congr 1
        ring
      rw [he] at hh
      simpa only [Nat.add_assoc] using hh.trans hnext
  have hfinal:amplificationConstant/2≤labelReal (labels i)*(s (H+m)).2 i := by
    have hh:=hind m le_rfl
    have hp:=amplificationCount_power hu hu1
    have hc:=amplificationConstant_le_half
    rwa [min_eq_right (by change amplificationConstant/2≤(2:ℝ)^amplificationCount u*u;linarith)] at hh
  exact saturation_empirical_error (c m i) (hc m le_rfl i) (labels i) hfinal ((hsat i).trans_le hδsat)

end NeuralGeneralization.BatchTwoContinuousDepthCritical
