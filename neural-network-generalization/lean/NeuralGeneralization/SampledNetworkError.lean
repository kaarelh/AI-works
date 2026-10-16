import NeuralGeneralization.PrunedNetwork

/-! # Deterministic sampled-network error from the three actual good events -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.CompressionSampling
open ConcreteModel Compression

/-- Original squared row masses retained by all internal output lists, plus
    the original linear-readout mass. These are the norms appearing in event B;
    they are not the sampled Frobenius norms from event C. -/
def retainedRowMass {d N r M : ℕ} (w : Weights d N r)
    (I : Fin (r + 1) → Fin M → Fin N) : ℝ :=
  (N : ℝ) * (∑ s : Fin r, ∑ a : Fin M, ∑ j : Fin N,
    w (Sum.inr (Sum.inl (s, I s.succ a, j))) ^ 2) +
  (N : ℝ) * ∑ j, w (Sum.inr (Sum.inr j)) ^ 2

/-- The retained mass for any one internal layer is part of event B's total. -/
theorem one_layer_retained_mass_le {d N r M : ℕ} (w : Weights d N r)
    (I : Fin (r + 1) → Fin M → Fin N) (s : Fin r) :
    (N : ℝ) * (∑ a : Fin M, internalRowNorm w s (I s.succ a) ^ 2) ≤
      retainedRowMass w I := by
  simp only [internalRowNorm_sq, retainedRowMass]
  have hs : (∑ a : Fin M, ∑ j, w (Sum.inr (Sum.inl (s,I s.succ a,j))) ^ 2) ≤
      ∑ t, ∑ a : Fin M, ∑ j, w (Sum.inr (Sum.inl (t,I t.succ a,j))) ^ 2 :=
    Finset.single_le_sum (f := fun t : Fin r => ∑ a : Fin M, ∑ j,
      w (Sum.inr (Sum.inl (t,I t.succ a,j))) ^ 2)
      (fun _ _ => by positivity) (Finset.mem_univ s)
  have hm := mul_le_mul_of_nonneg_left hs (Nat.cast_nonneg N : (0 : ℝ) ≤ N)
  have ho : 0 ≤ (N : ℝ) * ∑ j, w (Sum.inr (Sum.inr j)) ^ 2 := by positivity
  linarith

/-- Event A's row bounds and event B's retained masses control one sampled
    perturbation. `u` is the matrix being sampled; `w` supplies original row norms. -/
theorem sampled_row_errors_squaredSum_le {d N r M : ℕ} (φ : ℝ → ℝ)
    {ρ q K : ℝ} (hρ : 0 < ρ) (hq : 0 < q) (hqsq : q ^ 2 = (N : ℝ))
    (w u : Weights d N r) (I : Fin (r + 1) → Fin M → Fin N)
    (hmass : retainedRowMass w I ≤ 8 * (M : ℝ) * K) (x : Cube d) (s : Fin r)
    (hrow : ∀ a, |rowSamplingError φ u I x s a| ≤
      ρ / 2 * q * internalRowNorm w s (I s.succ a)) :
    (∑ a, rowSamplingError φ u I x s a ^ 2) ≤ 2 * ρ ^ 2 * (M : ℝ) * K := by
  have hs := squaredSum_le_of_abs_le
    (rowSamplingError φ u I x s) (fun a => internalRowNorm w s (I s.succ a))
    (by positivity : 0 ≤ ρ / 2 * q)
    (fun a => internalRowNorm_nonneg w s (I s.succ a)) hrow
  have hb := (one_layer_retained_mass_le w I s).trans hmass
  have hc := mul_le_mul_of_nonneg_left hb (show 0 ≤ ρ ^ 2 / 4 by positivity)
  have he : (ρ / 2 * q) ^ 2 * (∑ a, internalRowNorm w s (I s.succ a) ^ 2) =
      (ρ ^ 2 / 4) * ((N : ℝ) * ∑ a, internalRowNorm w s (I s.succ a) ^ 2) := by
    rw [← hqsq]
    ring
  rw [he] at hs
  nlinarith

/-- Each sampled replacement has a common width-independent error bound on the
    three good events. The row concentration event uses only retained rows. -/
theorem sampled_mixed_step_abs_le {d N r M : ℕ} (hM : 0 < M) (φ : ℝ → ℝ)
    (hφ : admissibleActivation φ) {ρ q K : ℝ}
    (hρ : 0 < ρ) (hq : 0 < q) (hqsq : q ^ 2 = (N : ℝ)) (hK : 1 ≤ K)
    (w u : Weights d N r) (I : Fin (r + 1) → Fin M → Fin N)
    (hcost : weightedSquaredNorm (sampledWeights u I) ≤ 4 * K)
    (hmass : retainedRowMass w I ≤ 8 * (M : ℝ) * K) (x : Cube d) (s : Fin r)
    (hrow : ∀ a, |rowSamplingError φ u I x s a| ≤
      ρ / 2 * q * internalRowNorm w s (I s.succ a)) :
    |mixedOutput φ u (sampledWeights u I) I x s.castSucc -
      mixedOutput φ u (sampledWeights u I) I x s.succ| ≤
        ρ * (4 * K) ^ (r + 1) := by
  have hMR : (M : ℝ) ≠ 0 := by exact_mod_cast Nat.ne_of_gt hM
  have hK0 : 0 ≤ K := by linarith
  have hC : 1 ≤ 4 * K := by linarith
  have hg : suffixSquaredGain (sampledWeights u I) (s.val + 1) ≤
      (4 * K) / (M : ℝ) * (4 * K) ^ r := by
    exact (suffixSquaredGain_le_of_cost hM _ (by positivity) hcost _).trans
      (mul_le_mul_of_nonneg_left (pow_le_pow_right₀ hC (Nat.sub_le _ _)) (by positivity))
  have hj := sampled_row_errors_squaredSum_le φ hρ hq hqsq w u I hmass x s hrow
  have hm := mul_le_mul hg hj (Finset.sum_nonneg (fun _ _ => sq_nonneg _))
    (by positivity : 0 ≤ (4 * K) / (M : ℝ) * (4 * K) ^ r)
  have he : ((4 * K) / (M : ℝ) * (4 * K) ^ r) * (2 * ρ ^ 2 * (M : ℝ) * K) =
      ρ ^ 2 * (4 * K) ^ (r + 2) / 2 := by
    rw [pow_succ, pow_succ]
    field_simp [hMR]
    ring
  rw [he] at hm
  have hp := pow_le_pow_right₀ hC (show r + 2 ≤ 2 * (r + 1) by omega)
  have hb : ρ ^ 2 * (4 * K) ^ (r + 2) / 2 ≤ (ρ * (4 * K) ^ (r + 1)) ^ 2 := by
    calc
      _ ≤ ρ ^ 2 * (4 * K) ^ (r + 2) := by
        nlinarith [mul_nonneg (sq_nonneg ρ) (pow_nonneg (by positivity : 0 ≤ 4 * K) (r + 2))]
      _ ≤ ρ ^ 2 * (4 * K) ^ (2 * (r + 1)) := mul_le_mul_of_nonneg_left hp (sq_nonneg _)
      _ = _ := by rw [mul_pow ρ ((4 * K) ^ (r + 1)), ← pow_mul]; congr 2; omega
  exact abs_le_of_sq_le_sq
    ((mixedOutput_step_squared_le φ hφ.2 u I x s).trans (hm.trans hb)) (by positivity)

/-- Event A's terminal row estimate has the same common error bound. -/
theorem sampled_readout_error_le {d N r M : ℕ} (φ : ℝ → ℝ)
    {ρ q K : ℝ} (hρ : 0 < ρ) (hqsq : q ^ 2 = (N : ℝ)) (hK : 1 ≤ K)
    (w u : Weights d N r) (hw : weightedSquaredNorm w ≤ K)
    (I : Fin (r + 1) → Fin M → Fin N) (x : Cube d)
    (hread : |((N : ℝ) / M) * ∑ a,
      u (Sum.inr (Sum.inr (I (Fin.last r) a))) * finalHidden φ u x (I (Fin.last r) a) -
      networkOutput φ u x| ≤ ρ / 2 * q * outputRowNorm w) :
    |((N : ℝ) / M) * ∑ a,
      u (Sum.inr (Sum.inr (I (Fin.last r) a))) * finalHidden φ u x (I (Fin.last r) a) -
      networkOutput φ u x| ≤ ρ * (4 * K) ^ (r + 1) := by
  have hcost : (N : ℝ) * outputRowNorm w ^ 2 ≤ K := by
    rw [outputRowNorm_sq]
    exact (output_squaredNorm_mul_width_le_cost w).trans hw
  have hK0 : 0 ≤ K := by linarith
  have hs : (ρ / 2 * q * outputRowNorm w) ^ 2 ≤ ρ ^ 2 * K / 4 := by
    have hm := mul_le_mul_of_nonneg_left hcost (sq_nonneg ρ)
    rw [← hqsq] at hm
    nlinarith
  have hp : K ≤ (4 * K) ^ (2 * (r + 1)) := by
    have hC : 1 ≤ 4 * K := by linarith
    have hpow := pow_le_pow_right₀ hC (show 1 ≤ 2 * (r + 1) by omega)
    simp only [pow_one] at hpow
    linarith
  have hb : ρ ^ 2 * K / 4 ≤ (ρ * (4 * K) ^ (r + 1)) ^ 2 := by
    calc
      _ ≤ ρ ^ 2 * K := by nlinarith [mul_nonneg (sq_nonneg ρ) hK0]
      _ ≤ ρ ^ 2 * (4 * K) ^ (2 * (r + 1)) := mul_le_mul_of_nonneg_left hp (sq_nonneg _)
      _ = _ := by rw [mul_pow ρ ((4 * K) ^ (r + 1)), ← pow_mul]; congr 2; omega
  have hp2 := abs_le_of_sq_le_sq (hs.trans hb) (by positivity : 0 ≤ ρ * (4 * K) ^ (r + 1))
  exact hread.trans (le_abs_self _ |>.trans hp2)

/-- Complete reverse-order sampling error estimate on the actual three events. -/
theorem sampled_network_output_error {d N r M : ℕ} (hM : 0 < M) (φ : ℝ → ℝ)
    (hφ : admissibleActivation φ) {ρ q K : ℝ}
    (hρ : 0 < ρ) (hq : 0 < q) (hqsq : q ^ 2 = (N : ℝ)) (hK : 1 ≤ K)
    (w u : Weights d N r) (hw : weightedSquaredNorm w ≤ K)
    (I : Fin (r + 1) → Fin M → Fin N)
    (hcost : weightedSquaredNorm (sampledWeights u I) ≤ 4 * K)
    (hmass : retainedRowMass w I ≤ 8 * (M : ℝ) * K) (x : Cube d)
    (hrow : ∀ s a, |rowSamplingError φ u I x s a| ≤
      ρ / 2 * q * internalRowNorm w s (I s.succ a))
    (hread : |((N : ℝ) / M) * ∑ a,
      u (Sum.inr (Sum.inr (I (Fin.last r) a))) * finalHidden φ u x (I (Fin.last r) a) -
      networkOutput φ u x| ≤ ρ / 2 * q * outputRowNorm w) :
    |networkOutput φ (sampledWeights u I) x - networkOutput φ u x| ≤
      ((r : ℝ) + 1) * ρ * (4 * K) ^ (r + 1) := by
  let F := mixedOutput φ u (sampledWeights u I) I x
  have hc := finite_chain_abs_le F
  have hs : (∑ s : Fin r, |F s.castSucc - F s.succ|) ≤
      (r : ℝ) * (ρ * (4 * K) ^ (r + 1)) := by
    calc
      _ ≤ ∑ _s : Fin r, ρ * (4 * K) ^ (r + 1) :=
        Finset.sum_le_sum (fun s _ => sampled_mixed_step_abs_le hM φ hφ hρ hq hqsq hK
          w u I hcost hmass x s (hrow s))
      _ = _ := by simp
  have hr := sampled_readout_error_le φ hρ hqsq hK w u hw I x hread
  have ht := abs_sub_le (F 0) (F (Fin.last r)) (networkOutput φ u x)
  have hzero : F 0 = networkOutput φ (sampledWeights u I) x := mixedOutput_zero φ u I x
  rw [hzero] at ht hc
  have hlast : F (Fin.last r) = ((N : ℝ) / M) * ∑ a,
      u (Sum.inr (Sum.inr (I (Fin.last r) a))) * finalHidden φ u x (I (Fin.last r) a) :=
    mixedOutput_last φ u I x
  rw [← hlast] at hr
  nlinarith

end NeuralGeneralization.CompressionSampling
