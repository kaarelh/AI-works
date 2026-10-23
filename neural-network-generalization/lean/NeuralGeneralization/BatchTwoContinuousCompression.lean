import NeuralGeneralization.BatchTwoContinuousSampling
import NeuralGeneralization.CompressionConclusion

/-! Actual finite-input compression of real-input networks, proved from the
same neuron-index sampling construction as the Boolean result. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous
open ConcreteModel CompressionSampling

variable {ι : Type*} [Fintype ι]

theorem finite_real_input_compression {d N r K : ℕ}
    (hd : 1 ≤ d) (hN : 0 < N) (hK : 1 ≤ K)
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (w : Weights d N r) (hw : weightedSquaredNorm w ≤ (K : ℝ))
    (input : ι → RealInput d) (hinput : ∀ x, ∑ j, input x j^2 ≤ 1) :
    let M := compressionWidth (netDimension d ι) r (2*K)
    ∃ v : Weights d M r, weightedSquaredNorm v ≤ 4*(K : ℝ) ∧
      boundedWeights M v ∧ ∀ x, |output φ v (input x)-output φ w (input x)| ≤ 1/12 := by
  letI : NeZero N := ⟨hN.ne'⟩
  let K' := 2*K
  let M := compressionWidth (netDimension d ι) r K'
  let ρ : ℝ := (compressionQ r K' : ℝ)⁻¹
  let q : ℝ := Real.sqrt N
  let u := prunedWeights ρ q w
  have hK' : 1 ≤ K' := by dsimp [K']; omega
  have hM : 0 < M := compressionWidth_pos _ _ _ hK'
  have hKR : 1 ≤ (K' : ℝ) := by exact_mod_cast hK'
  have hK0 : 0 < (K : ℝ) := by exact_mod_cast hK
  have hKeq : (K' : ℝ)=2*(K : ℝ) := by dsimp [K']; push_cast; rfl
  have hρ : 0 < ρ := inv_pos.mpr (Nat.cast_pos.mpr (compressionQ_pos r K' hK'))
  have hq : 0 < q := Real.sqrt_pos.mpr (Nat.cast_pos.mpr hN)
  have hqsq : q^2=(N : ℝ) := Real.sq_sqrt (Nat.cast_nonneg N)
  have hu : weightedSquaredNorm u ≤ (K : ℝ) := (prunedWeights_cost_le ρ q w).trans hw
  obtain ⟨I,hcost,hmass,hrows⟩ := exists_real_input_sampling_lists hM φ hφ.1 hρ hq hqsq hK0 w u hw hu input
    (prunedWeights_internal_bound hρ.le hq.le w) (prunedWeights_output_bound hρ.le hq.le w)
    (real_sampling_width_budget (ι := ι) d r K' hK')
  let v := sampledWeights u I
  have hbound : boundedWeights M v := by
    apply boundedWeights_of_cost hd (by omega) v
    have hMbound := compressionWidth_ge_nine_energy (netDimension d ι) r K'
    have hMR : 9*(K' : ℝ) ≤ (M : ℝ) := by exact_mod_cast hMbound
    change weightedSquaredNorm v ≤ 4*(K : ℝ) at hcost
    rw [hKeq] at hMR
    linarith
  refine ⟨v,hcost,hbound,?_⟩
  intro x
  let y : Cube d := fun _ => false
  have hwx : weightedSquaredNorm (freezeInput (input x) w) ≤ (K' : ℝ) := by
    have h := (energy_freeze_unit_ball (input x) (hinput x) w)
    rw [hKeq]
    linarith
  have hcostx : weightedSquaredNorm (sampledWeights (freezeInput (input x) u) I) ≤ 4*(K' : ℝ) := by
    rw [← freeze_sampledWeights]
    have h := energy_freeze_unit_ball (input x) (hinput x) v
    rw [hKeq]
    change weightedSquaredNorm (freezeInput (input x) v) ≤ 4*(2*(K : ℝ))
    linarith
  have hmassx : retainedRowMass (freezeInput (input x) w) I ≤ 8*(M : ℝ)*(K' : ℝ) := by
    rw [retainedRowMass_freeze, hKeq]
    have hMK : 0 ≤ (M : ℝ)*(K : ℝ) := by positivity
    nlinarith
  have hs := sampled_network_output_error hM φ hφ hρ hq hqsq hKR
    (freezeInput (input x) w) (freezeInput (input x) u) hwx I hcostx hmassx y
    (hrows x y).1 (by simpa only [freezeInput, finalHidden_freeze, output_freeze, outputRowNorm_freeze]
      using (hrows x y).2)
  rw [← freeze_sampledWeights, output_freeze, output_freeze] at hs
  have hp := pruned_network_output_error hN φ hφ hρ hq hqsq hKR
    (freezeInput (input x) w) hwx y
  rw [← freeze_prunedWeights, output_freeze, output_freeze] at hp
  have hpow : (K' : ℝ)^(r+1) ≤ (4*(K' : ℝ))^(r+1) :=
    pow_le_pow_left₀ (by linarith) (by linarith) _
  have hm := mul_le_mul_of_nonneg_left hpow (show 0 ≤ ((r : ℝ)+1)*ρ by positivity)
  have hid : ((r : ℝ)+1)*ρ*(4*(K' : ℝ))^(r+1)=1/24 := compressionQ_error_identity r K' hK'
  rw [hid] at hs hm
  have ht := abs_sub_le (output φ v (input x)) (output φ u (input x)) (output φ w (input x))
  change |output φ v (input x)-output φ u (input x)| ≤ 1/24 at hs
  change |output φ u (input x)-output φ w (input x)| ≤ _ at hp
  linarith

end NeuralGeneralization.BatchTwoContinuous
