import NeuralGeneralization.SamplingNetwork
import Mathlib.Analysis.Real.Sqrt

/-!
# The actual row-pruned finite network

The zero-row case is part of the construction. Every threshold is determined by
an actual row norm, and deleting coordinates can only lower the Gaussian cost.
-/

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.CompressionSampling
open ConcreteModel Compression

def internalRowNorm {d N r : ℕ} (w : Weights d N r) (s : Fin r) (i : Fin N) : ℝ :=
  Real.sqrt (∑ j, w (Sum.inr (Sum.inl (s, i, j))) ^ 2)

def outputRowNorm {d N r : ℕ} (w : Weights d N r) : ℝ :=
  Real.sqrt (∑ j, w (Sum.inr (Sum.inr j)) ^ 2)

@[simp] theorem internalRowNorm_sq {d N r : ℕ} (w : Weights d N r)
    (s : Fin r) (i : Fin N) :
    internalRowNorm w s i ^ 2 = ∑ j, w (Sum.inr (Sum.inl (s, i, j))) ^ 2 := by
  exact Real.sq_sqrt (Finset.sum_nonneg (fun _ _ => sq_nonneg _))

@[simp] theorem outputRowNorm_sq {d N r : ℕ} (w : Weights d N r) :
    outputRowNorm w ^ 2 = ∑ j, w (Sum.inr (Sum.inr j)) ^ 2 := by
  exact Real.sq_sqrt (Finset.sum_nonneg (fun _ _ => sq_nonneg _))

theorem internalRowNorm_nonneg {d N r : ℕ} (w : Weights d N r)
    (s : Fin r) (i : Fin N) : 0 ≤ internalRowNorm w s i := Real.sqrt_nonneg _

theorem outputRowNorm_nonneg {d N r : ℕ} (w : Weights d N r) :
    0 ≤ outputRowNorm w := Real.sqrt_nonneg _

/-- First-layer coordinates are retained; every later row is thresholded using
    its original Euclidean norm. `q` will be the square root of the width. -/
def prunedWeights {d N r : ℕ} (ρ q : ℝ) (w : Weights d N r) : Weights d N r
  | Sum.inl (i,j) => w (Sum.inl (i,j))
  | Sum.inr (Sum.inl (s,i,j)) =>
      prune (2 * internalRowNorm w s i / (ρ * q))
        (fun b => w (Sum.inr (Sum.inl (s,i,b)))) j
  | Sum.inr (Sum.inr j) =>
      prune (2 * outputRowNorm w / (ρ * q)) (fun b => w (Sum.inr (Sum.inr b))) j

theorem prunedWeights_internal_bound {d N r : ℕ} {ρ q : ℝ}
    (hρ : 0 ≤ ρ) (hq : 0 ≤ q) (w : Weights d N r) (s : Fin r) (i j : Fin N) :
    |prunedWeights ρ q w (Sum.inr (Sum.inl (s,i,j)))| ≤
      2 * internalRowNorm w s i / (ρ * q) := by
  apply abs_prune_le
  exact div_nonneg (mul_nonneg (by norm_num) (internalRowNorm_nonneg w s i))
    (mul_nonneg hρ hq)

theorem prunedWeights_output_bound {d N r : ℕ} {ρ q : ℝ}
    (hρ : 0 ≤ ρ) (hq : 0 ≤ q) (w : Weights d N r) (j : Fin N) :
    |prunedWeights ρ q w (Sum.inr (Sum.inr j))| ≤
      2 * outputRowNorm w / (ρ * q) := by
  apply abs_prune_le
  exact div_nonneg (mul_nonneg (by norm_num) (outputRowNorm_nonneg w))
    (mul_nonneg hρ hq)

/-- Pruning reduces the actual weighted Gaussian energy, at every width. -/
theorem prunedWeights_cost_le {d N r : ℕ} (ρ q : ℝ) (w : Weights d N r) :
    weightedSquaredNorm (prunedWeights ρ q w) ≤ weightedSquaredNorm w := by
  unfold weightedSquaredNorm
  apply add_le_add
  · apply add_le_add le_rfl
    apply Finset.sum_le_sum
    intro s hs
    apply Finset.sum_le_sum
    intro i hi
    exact prune_squaredSum_le _ _
  · apply mul_le_mul_of_nonneg_left _ (Nat.cast_nonneg N)
    exact prune_squaredSum_le _ _

/-- Row pruning's exact error bound also covers a zero original row. -/
theorem row_pruning_error {ι : Type*} [Fintype ι] (w h : ι → ℝ)
    (hh : ∀ i, |h i| ≤ 1) {a t : ℝ} (ha : 0 ≤ a) (ht : 0 < t)
    (ha_sq : ∑ i, w i ^ 2 = a ^ 2) :
    |(∑ i, w i * h i) - ∑ i, prune (2 * a / t) w i * h i| ≤ t * a / 2 := by
  by_cases hz : a = 0
  · have hw : (∑ i, w i ^ 2) = 0 := by simpa [hz] using ha_sq
    rw [zero_row_pruning_exact w h hw]
    simp [hz]
  · exact normalized_pruning_error ht (lt_of_le_of_ne ha (Ne.symm hz)) w h hh ha_sq

theorem pruned_internal_preactivation_error {d N r : ℕ} {ρ q : ℝ}
    (hρ : 0 < ρ) (hq : 0 < q) (w : Weights d N r) (s : Fin r)
    (i : Fin N) (h : Fin N → ℝ) (hh : ∀ j, |h j| ≤ 1) :
    |(∑ j, w (Sum.inr (Sum.inl (s,i,j))) * h j) -
      ∑ j, prunedWeights ρ q w (Sum.inr (Sum.inl (s,i,j))) * h j| ≤
        ρ / 2 * q * internalRowNorm w s i := by
  have hb := row_pruning_error (fun j => w (Sum.inr (Sum.inl (s,i,j)))) h hh
    (internalRowNorm_nonneg w s i) (mul_pos hρ hq) (internalRowNorm_sq w s i).symm
  simp only [prunedWeights]
  convert hb using 1
  ring

theorem pruned_output_preactivation_error {d N r : ℕ} {ρ q : ℝ}
    (hρ : 0 < ρ) (hq : 0 < q) (w : Weights d N r)
    (h : Fin N → ℝ) (hh : ∀ j, |h j| ≤ 1) :
    |(∑ j, w (Sum.inr (Sum.inr j)) * h j) -
      ∑ j, prunedWeights ρ q w (Sum.inr (Sum.inr j)) * h j| ≤
        ρ / 2 * q * outputRowNorm w := by
  have hb := row_pruning_error (fun j => w (Sum.inr (Sum.inr j))) h hh
    (outputRowNorm_nonneg w) (mul_pos hρ hq) (outputRowNorm_sq w).symm
  simp only [prunedWeights]
  convert hb using 1
  ring


/-- Every layer's squared Frobenius norm is at most the full Gaussian energy. -/
theorem internal_squaredNorm_le_cost {d N r : ℕ} (w : Weights d N r) (s : Fin r) :
    (∑ i, ∑ j, w (Sum.inr (Sum.inl (s,i,j))) ^ 2) ≤ weightedSquaredNorm w := by
  have hs : (∑ i, ∑ j, w (Sum.inr (Sum.inl (s,i,j))) ^ 2) ≤
      ∑ t, ∑ i, ∑ j, w (Sum.inr (Sum.inl (t,i,j))) ^ 2 :=
    Finset.single_le_sum (f := fun t : Fin r => ∑ i, ∑ j,
      w (Sum.inr (Sum.inl (t,i,j))) ^ 2)
      (fun _ _ => by positivity) (Finset.mem_univ s)
  unfold weightedSquaredNorm
  have hf : 0 ≤ (d : ℝ) / N * (∑ i, ∑ j, w (Sum.inl (i,j)) ^ 2) := by positivity
  have ho : 0 ≤ (N : ℝ) * ∑ j, w (Sum.inr (Sum.inr j)) ^ 2 := by positivity
  linarith

theorem output_squaredNorm_mul_width_le_cost {d N r : ℕ} (w : Weights d N r) :
    (N : ℝ) * (∑ j, w (Sum.inr (Sum.inr j)) ^ 2) ≤ weightedSquaredNorm w := by
  unfold weightedSquaredNorm
  have hf : 0 ≤ (d : ℝ) / N * (∑ i, ∑ j, w (Sum.inl (i,j)) ^ 2) := by positivity
  have hi : 0 ≤ ∑ t, ∑ i, ∑ j, w (Sum.inr (Sum.inl (t,i,j))) ^ 2 := by positivity
  linarith

theorem output_squaredNorm_le_of_cost {d N r : ℕ} (hN : 0 < N)
    (w : Weights d N r) {K : ℝ} (hw : weightedSquaredNorm w ≤ K) :
    (∑ j, w (Sum.inr (Sum.inr j)) ^ 2) ≤ K / (N : ℝ) := by
  apply (le_div_iff₀ (by exact_mod_cast hN : 0 < (N : ℝ))).2
  have h := (output_squaredNorm_mul_width_le_cost w).trans hw
  nlinarith

/-- A cost bound gives a suffix bound independent of how the replacement was made. -/
theorem suffixSquaredGain_le_of_cost {d N r : ℕ} (hN : 0 < N)
    (w : Weights d N r) {K : ℝ} (hK : 0 ≤ K) (hw : weightedSquaredNorm w ≤ K)
    (m : ℕ) : suffixSquaredGain w m ≤ K / (N : ℝ) * K ^ (r - m) := by
  exact suffixSquaredGain_le w m hK (div_nonneg hK (Nat.cast_nonneg _))
    (output_squaredNorm_le_of_cost hN w hw)
    (fun s => (internal_squaredNorm_le_cost w s).trans hw)

/-- The local pruning injection bound is expressed in the original row masses. -/
theorem pruned_rowReplacement_squaredSum_le {d N r : ℕ} (φ : ℝ → ℝ)
    (hφ : ∀ t, |φ t| ≤ 1) {ρ q : ℝ} (hρ : 0 < ρ) (hq : 0 < q)
    (w : Weights d N r) (x : Cube d) (s : Fin r) :
    (∑ i, rowReplacementError φ w (prunedWeights ρ q w) (fun _ i => i) x s i ^ 2) ≤
      (ρ / 2 * q) ^ 2 * ∑ i, ∑ j, w (Sum.inr (Sum.inl (s,i,j))) ^ 2 := by
  have hrow (i : Fin N) :
      |rowReplacementError φ w (prunedWeights ρ q w) (fun _ i => i) x s i| ≤
      (ρ / 2 * q) * internalRowNorm w s i := by
    have hp := pruned_internal_preactivation_error hρ hq w s i
      (hiddenPrefix φ w x s.val) (fun j => hiddenPrefix_bounded φ hφ w x s.val j)
    simpa only [rowReplacementError, abs_sub_comm] using hp
  have hs := squaredSum_le_of_abs_le
    (fun i => rowReplacementError φ w (prunedWeights ρ q w) (fun _ i => i) x s i)
    (internalRowNorm w s) (by positivity : 0 ≤ ρ / 2 * q)
    (internalRowNorm_nonneg w s) hrow
  simpa only [internalRowNorm_sq] using hs


/-- A convenient common bound for every pruning replacement. Constants are
    deliberately generous; the resulting width bound is still polynomial at
    every fixed depth. -/
theorem pruned_mixed_step_abs_le {d N r : ℕ} (hN : 0 < N) (φ : ℝ → ℝ)
    (hφ : admissibleActivation φ) {ρ q K : ℝ}
    (hρ : 0 < ρ) (hq : 0 < q) (hqsq : q ^ 2 = (N : ℝ)) (hK : 1 ≤ K)
    (w : Weights d N r) (hw : weightedSquaredNorm w ≤ K) (x : Cube d) (s : Fin r) :
    |mixedOutput φ w (prunedWeights ρ q w) (fun _ i => i) x s.castSucc -
      mixedOutput φ w (prunedWeights ρ q w) (fun _ i => i) x s.succ| ≤
      ρ * K ^ (r + 1) := by
  have hNR : (N : ℝ) ≠ 0 := by exact_mod_cast Nat.ne_of_gt hN
  have hK0 : 0 ≤ K := by linarith
  let v := prunedWeights ρ q w
  have hvc : weightedSquaredNorm v ≤ K := (prunedWeights_cost_le ρ q w).trans hw
  have hg : suffixSquaredGain v (s.val + 1) ≤ K / (N : ℝ) * K ^ r := by
    exact (suffixSquaredGain_le_of_cost hN v hK0 hvc _).trans
      (mul_le_mul_of_nonneg_left (pow_le_pow_right₀ hK (Nat.sub_le _ _))
        (div_nonneg hK0 (Nat.cast_nonneg _)))
  have hj : (∑ i, rowReplacementError φ w v (fun _ i => i) x s i ^ 2) ≤
      ρ ^ 2 * (N : ℝ) * K / 4 := by
    have hp := pruned_rowReplacement_squaredSum_le φ hφ.1 hρ hq w x s
    have hi := (internal_squaredNorm_le_cost w s).trans hw
    have hh := hp.trans (mul_le_mul_of_nonneg_left hi (sq_nonneg (ρ / 2 * q)))
    have he : (ρ / 2 * q) ^ 2 * K = ρ ^ 2 * (N : ℝ) * K / 4 := by
      rw [← hqsq]
      ring
    exact he ▸ hh
  have hmul := mul_le_mul hg hj
    (Finset.sum_nonneg (fun _ _ => sq_nonneg _)) (by positivity : 0 ≤ K / (N : ℝ) * K ^ r)
  have hnum : (K / (N : ℝ) * K ^ r) * (ρ ^ 2 * (N : ℝ) * K / 4) =
      ρ ^ 2 * K ^ (r + 2) / 4 := by
    rw [pow_succ, pow_succ]
    field_simp [hNR]
    ring
  rw [hnum] at hmul
  have hpow := pow_le_pow_right₀ hK (show r + 2 ≤ 2 * (r + 1) by omega)
  have hbound : ρ ^ 2 * K ^ (r + 2) / 4 ≤ (ρ * K ^ (r + 1)) ^ 2 := by
    calc
      _ ≤ ρ ^ 2 * K ^ (r + 2) := by
        nlinarith [mul_nonneg (sq_nonneg ρ) (pow_nonneg hK0 (r + 2))]
      _ ≤ ρ ^ 2 * K ^ (2 * (r + 1)) := mul_le_mul_of_nonneg_left hpow (sq_nonneg _)
      _ = _ := by rw [mul_pow, ← pow_mul]; congr 2; omega
  apply abs_le_of_sq_le_sq _ (mul_nonneg hρ.le (pow_nonneg hK0 _))
  exact (mixedOutput_replacement_step_squared_le φ hφ.2 w v (fun _ i => i) x s).trans
    (hmul.trans hbound)

/-- The final pruning replacement is the original readout versus the pruned
    readout applied to the same original hidden vector. -/
theorem pruned_mixed_last_abs_le {d N r : ℕ} (φ : ℝ → ℝ)
    (hφ : admissibleActivation φ) {ρ q K : ℝ}
    (hρ : 0 < ρ) (hq : 0 < q) (hqsq : q ^ 2 = (N : ℝ)) (hK : 1 ≤ K)
    (w : Weights d N r) (hw : weightedSquaredNorm w ≤ K) (x : Cube d) :
    |mixedOutput φ w (prunedWeights ρ q w) (fun _ i => i) x (Fin.last r) -
      networkOutput φ w x| ≤ ρ * K ^ (r + 1) := by
  have hp := pruned_output_preactivation_error hρ hq w (finalHidden φ w x)
    (fun j => by simpa only [hiddenPrefix_last] using hiddenPrefix_bounded φ hφ.1 w x r j)
  have hh : |mixedOutput φ w (prunedWeights ρ q w) (fun _ i => i) x (Fin.last r) -
      networkOutput φ w x| ≤ ρ / 2 * q * outputRowNorm w := by
    simpa only [mixedOutput, Fin.val_last, hiddenSuffix_last, hiddenPrefix_last,
      linearReadout, networkOutput, abs_sub_comm] using hp
  have hcost : (N : ℝ) * outputRowNorm w ^ 2 ≤ K := by
    rw [outputRowNorm_sq]
    exact (output_squaredNorm_mul_width_le_cost w).trans hw
  have hK0 : 0 ≤ K := by linarith
  have hs : (ρ / 2 * q * outputRowNorm w) ^ 2 ≤ ρ ^ 2 * K / 4 := by
    have hm := mul_le_mul_of_nonneg_left hcost (sq_nonneg ρ)
    rw [← hqsq] at hm
    nlinarith
  have hpow : K ≤ K ^ (2 * (r + 1)) := by
    simpa only [pow_one] using pow_le_pow_right₀ hK (show 1 ≤ 2 * (r + 1) by omega)
  have hb : ρ ^ 2 * K / 4 ≤ (ρ * K ^ (r + 1)) ^ 2 := by
    calc
      _ ≤ ρ ^ 2 * K := by
        nlinarith [mul_nonneg (sq_nonneg ρ) hK0]
      _ ≤ ρ ^ 2 * K ^ (2 * (r + 1)) := mul_le_mul_of_nonneg_left hpow (sq_nonneg _)
      _ = _ := by rw [mul_pow, ← pow_mul]; congr 2; omega
  have hp2 := abs_le_of_sq_le_sq (hs.trans hb) (by positivity : 0 ≤ ρ * K ^ (r + 1))
  exact hh.trans (le_abs_self _ |>.trans hp2)

/-- Complete deterministic truncation theorem for the actual finite network. -/
theorem pruned_network_output_error {d N r : ℕ} (hN : 0 < N) (φ : ℝ → ℝ)
    (hφ : admissibleActivation φ) {ρ q K : ℝ}
    (hρ : 0 < ρ) (hq : 0 < q) (hqsq : q ^ 2 = (N : ℝ)) (hK : 1 ≤ K)
    (w : Weights d N r) (hw : weightedSquaredNorm w ≤ K) (x : Cube d) :
    |networkOutput φ (prunedWeights ρ q w) x - networkOutput φ w x| ≤
      ((r : ℝ) + 1) * ρ * K ^ (r + 1) := by
  let F := mixedOutput φ w (prunedWeights ρ q w) (fun _ i => i) x
  have hc := finite_chain_abs_le F
  have hs : (∑ s : Fin r, |F s.castSucc - F s.succ|) ≤ (r : ℝ) * (ρ * K ^ (r + 1)) := by
    calc
      _ ≤ ∑ _s : Fin r, ρ * K ^ (r + 1) :=
        Finset.sum_le_sum (fun s _ => pruned_mixed_step_abs_le hN φ hφ hρ hq hqsq hK w hw x s)
      _ = _ := by simp
  have hr := pruned_mixed_last_abs_le φ hφ hρ hq hqsq hK w hw x
  have ht := abs_sub_le (F 0) (F (Fin.last r)) (networkOutput φ w x)
  have hzero : F 0 = networkOutput φ (prunedWeights ρ q w) x :=
    mixedOutput_zero_of_first_eq φ w _ _ x (fun _ _ => rfl)
  rw [hzero] at ht hc
  change |F (Fin.last r) - networkOutput φ w x| ≤ _ at hr
  nlinarith

end NeuralGeneralization.CompressionSampling
