import NeuralGeneralization.OnlineLowerTanhActualRestoring
import NeuralGeneralization.OnlineLowerTanhGenericPair
import NeuralGeneralization.OnlineLowerTanhOptimizer

/-! # Exact equality of a nearly equal pair in actual maximizing neurons -/
noncomputable section
open scoped BigOperators Topology
open Filter
namespace NeuralGeneralization.OnlineLowerTanh

/-- A physical orientation, always of absolute value one. -/
def parityOrientation {n : ℕ} (u : Fin n → ℝ) : ℝ :=
  if 0 ≤ parityCorrelation u 0 then 1 else -1

lemma parityOrientation_abs {n : ℕ} (u : Fin n → ℝ) : |parityOrientation u|=1 := by
  unfold parityOrientation
  split_ifs <;> norm_num

lemma parityOrientation_mul {n : ℕ} (u : Fin n → ℝ) :
    parityOrientation u*parityCorrelation u 0=|parityCorrelation u 0| := by
  unfold parityOrientation
  split_ifs with h
  · simp [abs_of_nonneg h]
  · simp [abs_of_neg (lt_of_not_ge h)]

namespace ResidualSequence
variable {ι : Type*} [Fintype ι] [DecidableEq ι] (S : ResidualSequence ι)

lemma height_uniform_pos (hhi2 : S.hi ≤ 2) :
    ∃ c : ℝ,0 < c ∧ ∀ k,c ≤ Real.sqrt (2/Real.pi)*periodicFourierMaximum (S.A k) := by
  let c0 := (Real.pi/S.hi)/Real.sinh (periodicDecay S.lo)
  have hhi : 0 < S.hi := (S.gain_pos 0).trans_le (S.A_hi 0)
  have hc0 : 0 < c0 := div_pos (div_pos Real.pi_pos hhi)
    (Real.sinh_pos_iff.mpr (periodicDecay_pos S.lo_pos))
  refine ⟨Real.sqrt (2/Real.pi)*((9/10:ℝ)*c0),by positivity,?_⟩
  intro k
  apply mul_le_mul_of_nonneg_left _ (Real.sqrt_nonneg _)
  have hF := periodicFourierMaximum_lower (S.gain_pos k) ((S.A_hi k).trans hhi2)
  have hc := periodicCoefficient_zero_lower S.lo_pos (S.A_lo k) (S.A_hi k)
  change c0 ≤ periodicCoefficient (S.A k) 0 at hc
  linarith

/-- Any two selected positive coordinates approaching the same gain are
exactly equal eventually: otherwise the actual pair-averaged neuron has
strictly larger intrinsic gain. The residual bulk and the full near-optimal
coefficient are the concrete outputs of optimizer concentration. -/
theorem actual_maximizer_pair_eventually_equal
    (N : ℕ → ℕ) (u : (k : ℕ) → Fin (N k) → ℝ)
    (i j : (k : ℕ) → Fin (N k)) (hij : ∀ k,i k ≠ j k)
    (hodd : ∀ᶠ k in atTop,Odd (N k)) (hlarge : ∀ᶠ k in atTop,3 ≤ N k)
    (hmax : ∀ᶠ k in atTop,IsIntrinsicMaximizer (u k))
    (A : (k : ℕ) → Finset (Fin (erasedPairSet (i k) (j k)).card))
    (e : (k : ℕ) → Fin (S.N k) ≃ Fin (A k).card)
    (hin : ∀ k,S.incoming k=(fun z =>
      subsetWeights (A k) (subsetWeights (erasedPairSet (i k) (j k)) (u k)) (e k z)))
    (houtside : Tendsto (fun k =>
      incomingEnergy (subsetWeights (A k)ᶜ (subsetWeights (erasedPairSet (i k) (j k)) (u k)))/
      residualVariance (S.alphabet k)) atTop (𝓝 0))
    {a : ℝ} (ha : 0 < a)
    (hi : Tendsto (fun k => u k (i k)) atTop (𝓝 a))
    (hj : Tendsto (fun k => u k (j k)) atTop (𝓝 a)) (hhi2 : S.hi ≤ 2)
    (hnear : ∀ ε > 0,∀ᶠ k in atTop,
      Real.sqrt (2/Real.pi)*periodicFourierMaximum (S.A k)-ε ≤
        Real.sqrt (residualVariance (S.alphabet k))*|parityCorrelation (u k) 0|) :
    ∀ᶠ k in atTop,u k (i k)=u k (j k) := by
  let M := fun k => (erasedPairSet (i k) (j k)).card
  let v := fun k => subsetWeights (erasedPairSet (i k) (j k)) (u k)
  let s := fun k => parityOrientation (u k)
  let μ := fun k => pairMean (u k) (i k) (j k)
  let h := fun k => pairImbalance (u k) (i k) (j k)
  have hs : ∀ k,|s k| ≤ 1 := fun k => (parityOrientation_abs (u k)).le
  have hh : Tendsto h atTop (𝓝 0) := by
    simpa only [h,pairImbalance,sub_self,zero_div] using (hi.sub hj).div_const 2
  have hμlim : Tendsto (fun k => 2*μ k) atTop (𝓝 (2*a)) := by
    have he : (fun k => 2*μ k)=(fun k => u k (i k)+u k (j k)) := by
      funext k
      dsimp [μ,pairMean]
      ring
    rw [he,show 2*a=a+a by ring]
    exact hi.add hj
  have hD : 0 < 2*a+1 := by linarith
  have hμ : ∀ᶠ k in atTop,|2*μ k| ≤ 2*a+1 := by
    have ht := hμlim.abs
    rw [abs_of_pos (by positivity : 0 < 2*a)] at ht
    exact (ht.eventually (gt_mem_nhds (by linarith : 2*a < 2*a+1))).mono (fun _ h => h.le)
  have hnear' : ∀ ε > 0,∀ᶠ k in atTop,
      Real.sqrt (2/Real.pi)*periodicFourierMaximum (S.A k)-ε ≤
        s k*Real.sqrt (residualVariance (S.alphabet k))*
          ((parityCorrelation (v k) (2*μ k)-parityCorrelation (v k) (2*h k))/2) := by
    intro ε hε
    filter_upwards [hnear ε hε,hodd,hlarge] with k hk ho hl
    have hp := parityCorrelation_erasedPair ho hl (u k) (i k) (j k) (hij k)
    have hμk : 2*μ k=u k (i k)+u k (j k) := by dsimp [μ,pairMean];ring
    have hhk : 2*h k=u k (i k)-u k (j k) := by dsimp [h,pairImbalance];ring
    rw [hμk,hhk]
    change _ ≤ s k*Real.sqrt (residualVariance (S.alphabet k))*
      ((parityCorrelation (subsetWeights (erasedPairSet (i k) (j k)) (u k)) _-
        parityCorrelation (subsetWeights (erasedPairSet (i k) (j k)) (u k)) _)/2)
    rw [← hp]
    calc
      _ ≤ Real.sqrt (residualVariance (S.alphabet k))*|parityCorrelation (u k) 0| := hk
      _ = _ := by
        have hor : s k*parityCorrelation (u k) 0=|parityCorrelation (u k) 0| := parityOrientation_mul (u k)
        rw [←hor]
        ring
  obtain ⟨δ,hδ,hcurv⟩ := S.actual_subset_pair_strict_curvature M v A e hin houtside s μ h hs hhi2 hh hD hμ hnear'
  have hdiff : Tendsto (fun k => |u k (i k)-u k (j k)|) atTop (𝓝 0) := by
    simpa only [sub_self,abs_zero] using (hi.sub hj).abs
  obtain ⟨c,hc,hheight⟩ := S.height_uniform_pos hhi2
  filter_upwards [hcurv,hodd,hlarge,hmax,hi.eventually (lt_mem_nhds ha),
    hj.eventually (lt_mem_nhds ha),hdiff.eventually (gt_mem_nhds hδ),
    hnear (c/2) (by linarith)] with k hk ho hl hm hip hjp hdiffk hnk
  by_contra hne
  have hscore : 0 < s k*parityCorrelation (u k) 0 := by
    have habs : 0 < |parityCorrelation (u k) 0| := by
      by_contra hn
      have hz : |parityCorrelation (u k) 0|=0 := le_antisymm (le_of_not_gt hn) (abs_nonneg _)
      rw [hz,mul_zero] at hnk
      linarith [hheight k]
    simpa only [s,parityOrientation_mul] using habs
  have himprove := generic_pair_balance_of_curvature ho hl (u k) (i k) (j k) (hij k) δ (s k)
    (parityOrientation_abs (u k)) hk hdiffk.le hne hip hjp hscore
  have hbad := hm (averageIncomingPair (u k) (i k) (j k))
  exact (not_lt_of_ge hbad) himprove

end ResidualSequence
end NeuralGeneralization.OnlineLowerTanh
