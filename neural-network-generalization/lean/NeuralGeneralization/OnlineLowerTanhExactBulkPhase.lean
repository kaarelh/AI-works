import NeuralGeneralization.OnlineLowerTanhDeficitLimit
import NeuralGeneralization.OnlineLowerTanhExactBulk
import NeuralGeneralization.OnlineLowerTanhNearBulkAbsorption
import NeuralGeneralization.OnlineLowerTanhExactBulkAverage

/-! Actual maximality forces vanishing odd-lattice error outside the exact bulk. -/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set
namespace NeuralGeneralization.OnlineLowerTanh
namespace NearBalancedSequence
variable (B:NearBalancedSequence)

lemma outside_energy_over_bulk_tendsto :
    Tendsto (fun k=>incomingEnergy (subsetWeights (B.bulk k)ᶜ (B.u k))/((B.bulk k).card:ℝ))
      atTop (𝓝 0) := by
  have ht:=B.outside_energy_tendsto.div B.bulk_fraction (by norm_num : (1:ℝ)≠0)
  simp only [zero_div] at ht
  apply ht.congr'
  filter_upwards [B.bulk_tendsto.eventually (eventually_gt_atTop 0)] with k hk
  have hn:(B.N k:ℝ)≠0:=by exact_mod_cast (B.N_pos k).ne'
  have hm:((B.bulk k).card:ℝ)≠0:=by exact_mod_cast hk.ne'
  rw [incomingEnergy_subsetWeights]
  dsimp only [Pi.div_apply]
  field_simp

lemma periodic_bulk_peak_tendsto :
    Tendsto (fun k=>periodicFourierMaximum (B.bulkAmplitude k)) atTop
      (𝓝 (scalarF0 limitingGain)) := by
  have hc:ContinuousAt scalarF0 limitingGain:=
    (hasDerivAt_scalarF0 limitingGain (by linarith [limitingGain_mem.1])).continuousAt
  apply (hc.tendsto.comp B.bulkAmplitude_tendsto).congr'
  filter_upwards [B.bulkAmplitude_eventually_mem] with k hk
  exact (periodicFourierMaximum_eq_scalarF0 _ (by linarith [hk.1])).symm

lemma exactBulkPeriodicAverage_cap_eventually :
    ∀ᶠk in atTop,|exactBulkPeriodicAverage (B.bulk k) (B.u k) (B.bulkAmplitude k) 0|≤
      periodicFourierMaximum (B.bulkAmplitude k) := by
  filter_upwards [B.bulkAmplitude_eventually_mem] with k hk
  unfold exactBulkPeriodicAverage
  apply (abs_cubeMean_le _).trans
  apply (cubeMean_mono _ _ ?_).trans_eq (cubeMean_const _)
  intro y
  rw [abs_mul,abs_paritySign,one_mul]
  exact periodicFourierResponse_abs_le (by linarith [hk.1]) hk.2 _

/-- The actual external parity average reaches the limiting periodic peak.
All inputs are derived from the literal globally maximizing network sequence. -/
theorem exactBulk_periodic_deficit_tendsto :
    Tendsto (fun k=>periodicFourierMaximum (B.bulkAmplitude k)-
      |exactBulkPeriodicAverage (B.bulk k) (B.u k) (B.bulkAmplitude k) 0|)
      atTop (𝓝 0) := by
  let c:=Real.sqrt (2/Real.pi)
  have hc:0<c:=by dsimp [c];positivity
  have hraw:=exact_bulk_periodic_average_abs_tendsto B.N B.bulk B.u B.bulkAmplitude
    B.bulk_tendsto B.bulkAmplitude_eventually_mem B.bulk_eventually_amplitude
    B.outside_energy_over_bulk_tendsto
  have hdiv:=hraw.div_const c
  simp only [zero_div] at hdiv
  have happrox:Tendsto (fun k=>abs (Real.sqrt ((B.bulk k).card:ℝ)*|parityCorrelation (B.u k) 0|/c-
      |exactBulkPeriodicAverage (B.bulk k) (B.u k) (B.bulkAmplitude k) 0|)) atTop (𝓝 0) := by
    have he: (fun k=>(Real.sqrt ((B.bulk k).card:ℝ)*|parityCorrelation (B.u k) 0|-
        c*|exactBulkPeriodicAverage (B.bulk k) (B.u k) (B.bulkAmplitude k) 0|)/c)=
        (fun k=>Real.sqrt ((B.bulk k).card:ℝ)*|parityCorrelation (B.u k) 0|/c-
        |exactBulkPeriodicAverage (B.bulk k) (B.u k) (B.bulkAmplitude k) 0|):=by
      funext k
      field_simp
    rw [he] at hdiv
    simpa only [abs_zero] using hdiv.abs
  apply normalized_peak_deficit_tendsto
    (fun k=>periodicFourierMaximum (B.bulkAmplitude k)) B.bulkEfficiencyFactor
    (fun k=>intrinsicEfficiency (B.u k))
    (fun k=>Real.sqrt ((B.bulk k).card:ℝ)*|parityCorrelation (B.u k) 0|/c)
    (fun k=>exactBulkPeriodicAverage (B.bulk k) (B.u k) (B.bulkAmplitude k) 0)
    (scalarF0 limitingGain) (limitingGain/c) limitingParityEfficiency
    B.periodic_bulk_peak_tendsto B.bulkEfficiencyFactor_tendsto B.efficiency_lower
    bulkEfficiencyFactor_limit_match (Eventually.of_forall B.bulkEfficiencyFactor_nonneg)
    (B.bulkEfficiencyFactor_identity_eventually.mono fun k hk=>hk.symm) happrox
    B.exactBulkPeriodicAverage_cap_eventually

lemma tendsto_zero_of_eventual_truncated_bound {E D:ℕ→ℝ} {c:ℝ}
    (hc:0<c) (hE:∀k,0≤E k) (hbound:∀ᶠk in atTop,c*min (E k) 1≤D k)
    (hD:Tendsto D atTop (𝓝 0)) : Tendsto E atTop (𝓝 0) := by
  have hsmall:∀ᶠk in atTop,D k<c:=hD.eventually (eventually_lt_nhds hc)
  have hu:∀ᶠk in atTop,E k≤D k/c:=by
    filter_upwards [hsmall,hbound] with k hk hb
    have hm:min (E k) 1<1:=by nlinarith
    have hEk:E k<1:=(min_lt_iff.mp hm).resolve_right (lt_irrefl _)
    rw [min_eq_left hEk.le] at hb
    exact (le_div_iff₀ hc).mpr (by nlinarith)
  have hdiv:=hD.div_const c
  simp only [zero_div] at hdiv
  exact squeeze_zero' (Eventually.of_forall hE) hu hdiv

/-- The entire complementary vector approaches the odd lattice in squared
Euclidean distance, not merely coordinatewise or in probability. -/
theorem outside_odd_residual_energy_tendsto :
    Tendsto (fun k=>incomingEnergy (oddPhaseResidual (B.bulkAmplitude k)
      (subsetWeights (B.bulk k)ᶜ (B.u k)))) atTop (𝓝 0) := by
  apply tendsto_zero_of_eventual_truncated_bound (c:=periodicPeakFloor/1600)
    (by positivity [periodicPeakFloor_pos]) (fun k=>incomingEnergy_nonneg _) _
    B.exactBulk_periodic_deficit_tendsto
  filter_upwards [B.bulkAmplitude_eventually_mem] with k hk
  have hodd:=exactBulk_outside_phase_odd (B.N_odd k) (B.bulk k)
  have hh:=periodic_external_phase_stability hk.1 hk.2 hodd
    (subsetWeights (B.bulk k)ᶜ (B.u k))
  rw [exactBulkPeriodicAverage_eq_uniformCubeMean]
  simpa only [add_zero] using hh

/-- Every remaining unequal weight exceeds five halves of the exact bulk
amplitude, eventually and uniformly over all coordinates. -/
theorem unequal_coordinate_large_eventually :
    ∀ᶠk in atTop,∀i,B.u k i≠B.bulkAmplitude k →
      (5/2:ℝ)*B.bulkAmplitude k≤B.u k i := by
  obtain ⟨δ,hδ,hgap⟩:=B.exists_outside_amplitude_gap
  let ε:=min δ (1/2:ℝ)
  have hε:0<ε:=lt_min hδ (by norm_num)
  have hε1:ε≤1/2:=min_le_right _ _
  have hεgap:ε≤δ:=min_le_left _ _
  have huniform:=residual_energy_tendsto_uniform
    (fun k=>(B.bulk k)ᶜ.card) B.bulkAmplitude
    (fun k=>subsetWeights (B.bulk k)ᶜ (B.u k)) B.outside_odd_residual_energy_tendsto ε hε
  filter_upwards [hgap,huniform,B.bulkAmplitude_eventually_mem,B.bulk_eventually_amplitude]
    with k hg hs ha hbulk i hi
  have hnot:i∉B.bulk k:=fun h=>hi (hbulk i h)
  let j:Fin (B.bulk k)ᶜ.card:=(B.bulk k)ᶜ.equivFin ⟨i,Finset.mem_compl.mpr hnot⟩
  have hj:subsetWeights (B.bulk k)ᶜ (B.u k) j=B.u k i:=by
    simp [subsetWeights,j]
  have hfar:ε≤|subsetWeights (B.bulk k)ᶜ (B.u k) j-B.bulkAmplitude k|:=by
    rw [hj]
    exact hεgap.trans (hg i hi)
  have hlo:=oddPhaseResidual_outlier_lower ha.1 hε (by linarith)
    (subsetWeights (B.bulk k)ᶜ (B.u k)) j (by rw [hj];exact B.u_nonneg k i) hfar (hs j)
  rw [hj] at hlo
  linarith [ha.1]

end NearBalancedSequence
end NeuralGeneralization.OnlineLowerTanh
