import NeuralGeneralization.SampledNetworkError
import NeuralGeneralization.CompressionWidth
import NeuralGeneralization.MarginRescaling

/-! # Deterministic conclusion from the actual three sampling events -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.CompressionSampling
open ConcreteModel

/-- At the explicit polynomial width, good lists produce a strict-margin,
    bounded-coefficient representative. The good-list hypotheses are the
    concrete row errors and masses, proved probabilistically in `SamplingLaw`
    and `CompressionSampling`. -/
theorem compression_from_good_lists {d N r K : ℕ} (hd : 1 ≤ d)
    (hN : 0 < N) (hK : 1 ≤ K) (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (f : BooleanFunction d) (w : Weights d N r) (hw : weightedSquaredNorm w ≤ (K : ℝ))
    (hmargin : w ∈ marginEvent φ (1 / 2) f) :
    let M := compressionWidth d r K
    let ρ : ℝ := (compressionQ r K : ℝ)⁻¹
    let q : ℝ := Real.sqrt (N : ℝ)
    let u := prunedWeights ρ q w
    ∀ I : Fin (r + 1) → Fin M → Fin N,
      weightedSquaredNorm (sampledWeights u I) ≤ 4 * (K : ℝ) →
      retainedRowMass w I ≤ 8 * (M : ℝ) * (K : ℝ) →
      (∀ x s a, |rowSamplingError φ u I x s a| ≤
        ρ / 2 * q * internalRowNorm w s (I s.succ a)) →
      (∀ x, |((N : ℝ) / M) * ∑ a,
        u (Sum.inr (Sum.inr (I (Fin.last r) a))) * finalHidden φ u x (I (Fin.last r) a) -
        networkOutput φ u x| ≤ ρ / 2 * q * outputRowNorm w) →
      ∃ v : Weights d M r, v ∈ marginEvent φ (1 / 2) f ∧
        boundedWeights M v ∧ weightedSquaredNorm v ≤ 9 * (K : ℝ) := by
  dsimp only
  intro I hcost hmass hrows hread
  let M := compressionWidth d r K
  let ρ : ℝ := (compressionQ r K : ℝ)⁻¹
  let q : ℝ := Real.sqrt (N : ℝ)
  let u := prunedWeights ρ q w
  let v := sampledWeights u I
  have hM : 0 < M := compressionWidth_pos d r K hK
  have hNR : 0 < (N : ℝ) := by exact_mod_cast hN
  have hKR : 1 ≤ (K : ℝ) := by exact_mod_cast hK
  have hKp : 0 < (K : ℝ) := by linarith
  have hρ : 0 < ρ := inv_pos.mpr (by exact_mod_cast compressionQ_pos r K hK)
  have hq : 0 < q := Real.sqrt_pos.2 hNR
  have hqsq : q ^ 2 = (N : ℝ) := Real.sq_sqrt hNR.le
  have herr (x : Cube d) : |networkOutput φ v x - networkOutput φ w x| ≤ 1 / 12 := by
    have hs := sampled_network_output_error hM φ hφ hρ hq hqsq hKR w u hw I hcost hmass x
      (hrows x) (hread x)
    have hp := pruned_network_output_error hN φ hφ hρ hq hqsq hKR w hw x
    have hpow : (K : ℝ) ^ (r + 1) ≤ (4 * (K : ℝ)) ^ (r + 1) :=
      pow_le_pow_left₀ hKp.le (by linarith) _
    have hm := mul_le_mul_of_nonneg_left hpow
      (show 0 ≤ ((r : ℝ) + 1) * ρ by positivity)
    have hidentity : ((r : ℝ) + 1) * ρ * (4 * (K : ℝ)) ^ (r + 1) = 1 / 24 :=
      compressionQ_error_identity r K hK
    rw [hidentity] at hs hm
    have ht := abs_sub_le (networkOutput φ v x) (networkOutput φ u x) (networkOutput φ w x)
    change |networkOutput φ v x - networkOutput φ u x| ≤ _ at hs
    change |networkOutput φ u x - networkOutput φ w x| ≤ _ at hp
    linarith
  have hscaled : weightedSquaredNorm (rescaleReadout (3 / 2) v) ≤ 9 * (K : ℝ) := by
    have h := rescaleReadout_cost_le (show (1 : ℝ) ≤ 3 / 2 by norm_num) v
    change weightedSquaredNorm v ≤ 4 * (K : ℝ) at hcost
    nlinarith
  have hMN : 9 * (K : ℝ) ≤ (M : ℝ) := by
    change _ ≤ (compressionWidth d r K : ℝ)
    exact_mod_cast compressionWidth_ge_nine_energy d r K
  refine ⟨rescaleReadout (3 / 2) v, rescaleReadout_preserves_margin φ f w v hmargin herr, ?_, hscaled⟩
  exact boundedWeights_of_cost hd (by omega) _ (hscaled.trans hMN)

end NeuralGeneralization.CompressionSampling
