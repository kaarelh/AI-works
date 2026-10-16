import NeuralGeneralization.Network
import NeuralGeneralization.Compression
import Mathlib.Algebra.BigOperators.Fin
import Lean.Elab.Tactic.Omega

/-!
# Actual sampled network and reverse-order deterministic comparison

Mixed networks use the original prefix and the final sampled suffix. Thus every
local row error is evaluated on the original hidden vector, while the downstream
amplification involves the final sampled matrices. No hidden independence claim
is involved in this deterministic file.
-/

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.CompressionSampling
open ConcreteModel Compression

/-- The fully sampled network from the paper, before margin rescaling. -/
def sampledWeights {d N r M : ℕ} (w : Weights d N r)
    (I : Fin (r + 1) → Fin M → Fin N) : Weights d M r
  | Sum.inl (a, j) => w (Sum.inl (I 0 a, j))
  | Sum.inr (Sum.inl (s, a, b)) =>
      ((N : ℝ) / M) * w (Sum.inr (Sum.inl (s, I s.succ a, I s.castSucc b)))
  | Sum.inr (Sum.inr a) => ((N : ℝ) / M) * w (Sum.inr (Sum.inr (I (Fin.last r) a)))

/-- The original network prefix through hidden layer `m`. -/
def hiddenPrefix {d N r : ℕ} (φ : ℝ → ℝ) (w : Weights d N r)
    (x : Cube d) (m : ℕ) : Fin N → ℝ :=
  ((List.finRange r).take m).foldl (hiddenStep φ w) (firstHidden φ w x)

/-- An actual suffix of the final sampled network. -/
def hiddenSuffix {d M r : ℕ} (φ : ℝ → ℝ) (v : Weights d M r)
    (m : ℕ) (h : Fin M → ℝ) : Fin M → ℝ :=
  ((List.finRange r).drop m).foldl (hiddenStep φ v) h

def linearReadout {d M r : ℕ} (v : Weights d M r) (h : Fin M → ℝ) : ℝ :=
  ∑ a, v (Sum.inr (Sum.inr a)) * h a

/-- The mixed-width output after all layers downstream of `m` have been sampled. -/
def mixedOutput {d N M r : ℕ} (φ : ℝ → ℝ) (w : Weights d N r)
    (v : Weights d M r) (I : Fin (r + 1) → Fin M → Fin N) (x : Cube d)
    (m : Fin (r + 1)) : ℝ :=
  linearReadout v (hiddenSuffix φ v m.val
    (fun a => hiddenPrefix φ w x m.val (I m a)))

@[simp] theorem hiddenPrefix_zero {d N r : ℕ} (φ : ℝ → ℝ)
    (w : Weights d N r) (x : Cube d) : hiddenPrefix φ w x 0 = firstHidden φ w x := by
  simp [hiddenPrefix]

theorem hiddenPrefix_succ {d N r : ℕ} (φ : ℝ → ℝ)
    (w : Weights d N r) (x : Cube d) (s : Fin r) :
    hiddenPrefix φ w x (s.val + 1) = hiddenStep φ w (hiddenPrefix φ w x s.val) s := by
  unfold hiddenPrefix
  rw [List.take_succ_eq_append_getElem (by simp)]
  simp

@[simp] theorem hiddenPrefix_last {d N r : ℕ} (φ : ℝ → ℝ)
    (w : Weights d N r) (x : Cube d) : hiddenPrefix φ w x r = finalHidden φ w x := by
  unfold hiddenPrefix finalHidden
  rw [List.take_of_length_le (by simp)]

theorem hiddenSuffix_step {d M r : ℕ} (φ : ℝ → ℝ)
    (v : Weights d M r) (s : Fin r) (h : Fin M → ℝ) :
    hiddenSuffix φ v s.val h =
      hiddenSuffix φ v (s.val + 1) (hiddenStep φ v h s) := by
  unfold hiddenSuffix
  have hs : s.val < (List.finRange r).length := by simp
  rw [List.drop_eq_getElem_cons hs]
  simp

@[simp] theorem hiddenSuffix_last {d M r : ℕ} (φ : ℝ → ℝ)
    (v : Weights d M r) (h : Fin M → ℝ) : hiddenSuffix φ v r h = h := by
  unfold hiddenSuffix
  rw [List.drop_eq_nil_of_le (by simp)]
  rfl

/-- The initial mixed network really is the fully sampled network. -/
theorem mixedOutput_zero {d N M r : ℕ} (φ : ℝ → ℝ) (w : Weights d N r)
    (I : Fin (r + 1) → Fin M → Fin N) (x : Cube d) :
    mixedOutput φ w (sampledWeights w I) I x 0 = networkOutput φ (sampledWeights w I) x := by
  rfl

/-- The final mixed network is exactly the sampled readout on the original final
    hidden vector. This is the single-row terminal concentration event. -/
theorem mixedOutput_last {d N M r : ℕ} (φ : ℝ → ℝ) (w : Weights d N r)
    (I : Fin (r + 1) → Fin M → Fin N) (x : Cube d) :
    mixedOutput φ w (sampledWeights w I) I x (Fin.last r) =
      ((N : ℝ) / M) * ∑ a, w (Sum.inr (Sum.inr (I (Fin.last r) a))) *
        finalHidden φ w x (I (Fin.last r) a) := by
  simp only [mixedOutput, Fin.val_last, hiddenSuffix_last, hiddenPrefix_last,
    linearReadout, sampledWeights, mul_assoc, Finset.mul_sum]

/-- The squared amplification of a suffix in the final sampled network. -/
def suffixSquaredGain {d M r : ℕ} (v : Weights d M r) (m : ℕ) : ℝ :=
  (∑ a, v (Sum.inr (Sum.inr a)) ^ 2) *
    (((List.finRange r).drop m).map (fun s =>
      ∑ a, ∑ b, v (Sum.inr (Sum.inl (s, a, b))) ^ 2)).prod

theorem suffixSquaredGain_nonneg {d M r : ℕ} (v : Weights d M r) (m : ℕ) :
    0 ≤ suffixSquaredGain v m := by
  unfold suffixSquaredGain
  apply mul_nonneg (Finset.sum_nonneg (fun _ _ => sq_nonneg _))
  apply List.prod_nonneg
  intro a ha
  obtain ⟨s, hs, rfl⟩ := List.mem_map.mp ha
  positivity

/-- Actual suffix sensitivity, including the final linear readout. -/
theorem suffix_readout_squaredDistance_le {d M r : ℕ} (φ : ℝ → ℝ)
    (hφ : ∀ t s, |φ t - φ s| ≤ |t - s|) (v : Weights d M r)
    (m : ℕ) (u z : Fin M → ℝ) :
    (linearReadout v (hiddenSuffix φ v m u) -
      linearReadout v (hiddenSuffix φ v m z)) ^ 2 ≤
      suffixSquaredGain v m * squaredDistance u z := by
  let As := ((List.finRange r).drop m).map
    (fun s a b => v (Sum.inr (Sum.inl (s, a, b))))
  have hs (h : Fin M → ℝ) : hiddenSuffix φ v m h = propagate φ As h := by
    unfold hiddenSuffix propagate
    dsimp only [As]
    rw [List.foldl_map]
    rfl
  have hp := propagate_squaredDistance_le φ hφ As u z
  have hr := readout_squaredDistance_le (fun a => v (Sum.inr (Sum.inr a)))
    (hiddenSuffix φ v m u) (hiddenSuffix φ v m z)
  unfold linearReadout
  calc
    _ ≤ (∑ a, v (Sum.inr (Sum.inr a)) ^ 2) *
      squaredDistance (hiddenSuffix φ v m u) (hiddenSuffix φ v m z) := hr
    _ ≤ (∑ a, v (Sum.inr (Sum.inr a)) ^ 2) *
      ((As.map squaredFrobenius).prod * squaredDistance u z) := by
      rw [hs u, hs z]
      exact mul_le_mul_of_nonneg_left hp (Finset.sum_nonneg (fun _ _ => sq_nonneg _))
    _ = _ := by
      simp only [suffixSquaredGain, As, List.map_map, Function.comp_def,
        squaredFrobenius]
      ring

/-- The actual retained-row preactivation error for original layer `s`. -/
def rowSamplingError {d N M r : ℕ} (φ : ℝ → ℝ) (w : Weights d N r)
    (I : Fin (r + 1) → Fin M → Fin N) (x : Cube d) (s : Fin r) (a : Fin M) : ℝ :=
  ((N : ℝ) / M) * ∑ b, w (Sum.inr (Sum.inl (s, I s.succ a, I s.castSucc b))) *
    hiddenPrefix φ w x s.val (I s.castSucc b) -
  ∑ j, w (Sum.inr (Sum.inl (s, I s.succ a, j))) * hiddenPrefix φ w x s.val j

/-- Reverse-order comparison: the original prefix is the same in both row sums,
    and the suffix gain belongs to the final sampled network. -/
theorem mixedOutput_step_squared_le {d N M r : ℕ} (φ : ℝ → ℝ)
    (hφ : ∀ t u, |φ t - φ u| ≤ |t - u|) (w : Weights d N r)
    (I : Fin (r + 1) → Fin M → Fin N) (x : Cube d) (s : Fin r) :
    (mixedOutput φ w (sampledWeights w I) I x s.castSucc -
      mixedOutput φ w (sampledWeights w I) I x s.succ) ^ 2 ≤
    suffixSquaredGain (sampledWeights w I) (s.val + 1) *
      ∑ a, rowSamplingError φ w I x s a ^ 2 := by
  let v := sampledWeights w I
  let u := hiddenStep φ v (fun a => hiddenPrefix φ w x s.val (I s.castSucc a)) s
  let z := fun a => hiddenPrefix φ w x (s.val + 1) (I s.succ a)
  have hu : mixedOutput φ w v I x s.castSucc =
      linearReadout v (hiddenSuffix φ v (s.val + 1) u) := by
    unfold mixedOutput
    exact congrArg (linearReadout v) (hiddenSuffix_step φ v s _)
  have hz : mixedOutput φ w v I x s.succ =
      linearReadout v (hiddenSuffix φ v (s.val + 1) z) := rfl
  change (mixedOutput φ w v I x s.castSucc - mixedOutput φ w v I x s.succ) ^ 2 ≤ _
  rw [hu, hz]
  have hs : squaredDistance u z ≤ ∑ a, rowSamplingError φ w I x s a ^ 2 := by
    unfold squaredDistance
    apply Finset.sum_le_sum
    intro a ha
    have h := hφ
      (∑ b, v (Sum.inr (Sum.inl (s, a, b))) * hiddenPrefix φ w x s.val (I s.castSucc b))
      (∑ j, w (Sum.inr (Sum.inl (s, I s.succ a, j))) * hiddenPrefix φ w x s.val j)
    have hsq := (sq_le_sq₀ (abs_nonneg _) (abs_nonneg _)).2 h
    simpa only [u, z, v, hiddenStep, hiddenPrefix_succ, sampledWeights,
      rowSamplingError, ← Finset.mul_sum, mul_assoc, sq_abs] using hsq
  exact (suffix_readout_squaredDistance_le φ hφ v (s.val + 1) u z).trans
    (mul_le_mul_of_nonneg_left hs (suffixSquaredGain_nonneg v _))

/-- Every original-prefix coordinate remains in the bounded activation range. -/
theorem hiddenPrefix_bounded {d N r : ℕ} (φ : ℝ → ℝ)
    (hφ : ∀ t, |φ t| ≤ 1) (w : Weights d N r) (x : Cube d)
    (m : ℕ) (i : Fin N) : |hiddenPrefix φ w x m i| ≤ 1 := by
  have hf (l : List (Fin r)) (h : Fin N → ℝ) (hh : ∀ j, |h j| ≤ 1) :
      ∀ j, |l.foldl (hiddenStep φ w) h j| ≤ 1 := by
    induction l generalizing h with
    | nil => exact hh
    | cons s l ih =>
      exact ih (hiddenStep φ w h s) (fun j => hφ _)
  exact hf _ _ (fun j => hφ _) i

/-- Telescoping over actual hidden-layer indices. -/
theorem finite_chain_abs_le {r : ℕ} (F : Fin (r + 1) → ℝ) :
    |F 0 - F (Fin.last r)| ≤ ∑ s : Fin r, |F s.castSucc - F s.succ| := by
  have hfirst := Fin.sum_univ_succ F
  have hlast := Fin.sum_univ_castSucc F
  have htel : (∑ s : Fin r, (F s.castSucc - F s.succ)) = F 0 - F (Fin.last r) := by
    rw [Finset.sum_sub_distrib]
    linarith
  rw [← htel]
  exact Finset.abs_sum_le_sum_abs _ _

/-- Deterministic assembly of the reverse-order comparisons. Each input may have
    its own row errors, but all suffixes and all weights are the actual final ones. -/
theorem sampled_output_abs_error_le {d N M r : ℕ} (φ : ℝ → ℝ)
    (hφ : ∀ t u, |φ t - φ u| ≤ |t - u|) (w : Weights d N r)
    (I : Fin (r + 1) → Fin M → Fin N) (x : Cube d)
    (e : Fin r → ℝ) {b : ℝ} (he : ∀ s, 0 ≤ e s)
    (hlocal : ∀ s, suffixSquaredGain (sampledWeights w I) (s.val + 1) *
      (∑ a, rowSamplingError φ w I x s a ^ 2) ≤ e s ^ 2)
    (hreadout : |((N : ℝ) / M) * ∑ a,
      w (Sum.inr (Sum.inr (I (Fin.last r) a))) *
        finalHidden φ w x (I (Fin.last r) a) - networkOutput φ w x| ≤ b) :
    |networkOutput φ (sampledWeights w I) x - networkOutput φ w x| ≤
      (∑ s, e s) + b := by
  let F := mixedOutput φ w (sampledWeights w I) I x
  have hstep (s : Fin r) : |F s.castSucc - F s.succ| ≤ e s := by
    exact abs_le_of_sq_le_sq ((mixedOutput_step_squared_le φ hφ w I x s).trans
      (hlocal s)) (he s)
  have hc := finite_chain_abs_le F
  have hs := Finset.sum_le_sum (fun s (_ : s ∈ (Finset.univ : Finset (Fin r))) => hstep s)
  have hr : |F (Fin.last r) - networkOutput φ w x| ≤ b := by
    simpa only [F, mixedOutput_last] using hreadout
  have ht := abs_sub_le (F 0) (F (Fin.last r)) (networkOutput φ w x)
  rw [show F 0 = networkOutput φ (sampledWeights w I) x from mixedOutput_zero φ w I x] at ht hc
  linarith

/-- A nonnegative list product is bounded by the corresponding power of a
    common factor bound. -/
theorem list_prod_le_pow {B : ℝ} (hB : 0 ≤ B) (l : List ℝ)
    (hl : ∀ a ∈ l, 0 ≤ a ∧ a ≤ B) : l.prod ≤ B ^ l.length := by
  induction l with
  | nil => simp
  | cons a l ih =>
    have ha := hl a (List.mem_cons_self)
    have ht : ∀ b ∈ l, 0 ≤ b ∧ b ≤ B := fun b hb => hl b (List.mem_cons_of_mem a hb)
    have hn : 0 ≤ l.prod := List.prod_nonneg (fun b hb => (ht b hb).1)
    simpa only [List.prod_cons, List.length_cons, pow_succ'] using
      mul_le_mul ha.2 (ih ht) hn hB

/-- The suffix amplification is controlled by the actual per-layer squared
    Frobenius norms and the actual readout squared norm. -/
theorem suffixSquaredGain_le {d M r : ℕ} (v : Weights d M r)
    (m : ℕ) {B R : ℝ} (hB : 0 ≤ B) (hR : 0 ≤ R)
    (hread : (∑ a, v (Sum.inr (Sum.inr a)) ^ 2) ≤ R)
    (hint : ∀ s, (∑ a, ∑ b, v (Sum.inr (Sum.inl (s, a, b))) ^ 2) ≤ B) :
    suffixSquaredGain v m ≤ R * B ^ (r - m) := by
  let l := (((List.finRange r).drop m).map (fun s =>
      ∑ a, ∑ b, v (Sum.inr (Sum.inl (s, a, b))) ^ 2))
  have hl : ∀ a ∈ l, 0 ≤ a ∧ a ≤ B := by
    intro a ha
    obtain ⟨s, hs, rfl⟩ := List.mem_map.mp ha
    exact ⟨by positivity, hint s⟩
  have hp := list_prod_le_pow hB l hl
  have hlen : l.length = r - m := by simp [l]
  rw [hlen] at hp
  exact mul_le_mul hread hp (List.prod_nonneg (fun a ha => (hl a ha).1)) hR


/-- Preactivation discrepancy between arbitrary replacement matrices, evaluated
    on the same original prefix and selected output row. -/
def rowReplacementError {d N M r : ℕ} (φ : ℝ → ℝ) (w : Weights d N r)
    (v : Weights d M r) (I : Fin (r + 1) → Fin M → Fin N)
    (x : Cube d) (s : Fin r) (a : Fin M) : ℝ :=
  (∑ b, v (Sum.inr (Sum.inl (s,a,b))) * hiddenPrefix φ w x s.val (I s.castSucc b)) -
  ∑ j, w (Sum.inr (Sum.inl (s,I s.succ a,j))) * hiddenPrefix φ w x s.val j

/-- The same reverse-order comparison applies to arbitrary layer replacements,
    including the deterministic pruning stage. -/
theorem mixedOutput_replacement_step_squared_le {d N M r : ℕ} (φ : ℝ → ℝ)
    (hφ : ∀ t u, |φ t - φ u| ≤ |t - u|) (w : Weights d N r) (v : Weights d M r)
    (I : Fin (r + 1) → Fin M → Fin N) (x : Cube d) (s : Fin r) :
    (mixedOutput φ w v I x s.castSucc - mixedOutput φ w v I x s.succ) ^ 2 ≤
    suffixSquaredGain v (s.val + 1) * ∑ a, rowReplacementError φ w v I x s a ^ 2 := by
  let u := hiddenStep φ v (fun a => hiddenPrefix φ w x s.val (I s.castSucc a)) s
  let z := fun a => hiddenPrefix φ w x (s.val + 1) (I s.succ a)
  have hu : mixedOutput φ w v I x s.castSucc =
      linearReadout v (hiddenSuffix φ v (s.val + 1) u) := by
    unfold mixedOutput
    exact congrArg (linearReadout v) (hiddenSuffix_step φ v s _)
  have hz : mixedOutput φ w v I x s.succ =
      linearReadout v (hiddenSuffix φ v (s.val + 1) z) := rfl
  rw [hu, hz]
  have hs : squaredDistance u z ≤ ∑ a, rowReplacementError φ w v I x s a ^ 2 := by
    unfold squaredDistance
    apply Finset.sum_le_sum
    intro a ha
    have h := hφ
      (∑ b, v (Sum.inr (Sum.inl (s,a,b))) * hiddenPrefix φ w x s.val (I s.castSucc b))
      (∑ j, w (Sum.inr (Sum.inl (s,I s.succ a,j))) * hiddenPrefix φ w x s.val j)
    have hsq := (sq_le_sq₀ (abs_nonneg _) (abs_nonneg _)).2 h
    simpa only [u, z, hiddenStep, hiddenPrefix_succ, rowReplacementError, sq_abs] using hsq
  exact (suffix_readout_squaredDistance_le φ hφ v (s.val + 1) u z).trans
    (mul_le_mul_of_nonneg_left hs (suffixSquaredGain_nonneg v _))

/-- The initial mixed output is the replacement network whenever first-layer
    coordinates are copied according to the initial selector. -/
theorem mixedOutput_zero_of_first_eq {d N M r : ℕ} (φ : ℝ → ℝ) (w : Weights d N r)
    (v : Weights d M r) (I : Fin (r + 1) → Fin M → Fin N) (x : Cube d)
    (hfirst : ∀ a j, v (Sum.inl (a,j)) = w (Sum.inl (I 0 a,j))) :
    mixedOutput φ w v I x 0 = networkOutput φ v x := by
  have hh : (fun a => firstHidden φ w x (I 0 a)) = firstHidden φ v x := by
    funext a
    simp only [firstHidden, hfirst]
  simp only [mixedOutput, Fin.val_zero, hiddenPrefix_zero, hiddenSuffix,
    List.drop_zero, hh, linearReadout, networkOutput, finalHidden]

end NeuralGeneralization.CompressionSampling
