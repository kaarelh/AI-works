import NeuralGeneralization.BatchTwoOnlineMeanFieldExactGaussian

/-! Actual finite-width probability of failure of the hidden covariance
certificates, using exact product-prior independence at each layer. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoOnlineMeanFieldExact
open ConcreteModel GaussianAngularPrice GaussianDualLayer GaussianDualMatrix
open GaussianTowerConstruction MeanFieldGoodEvent NetworkLayerSplit TowerNetwork
open TanhDifferential ProductFiberBound

theorem inputBad_tail {d N s : ℕ} (hd : 0 < d) (hN : 0 < N) (hs : 0 < s)
    {G : ℝ} (hG : 0 < G) (K : ℝ) :
    (powerPrior d N 0 1).real (inputBad G K) ≤
      Real.exp ((s : ℝ) * testEntropy d - (N : ℝ) * (K - G ^ 2 / (2 * (s : ℝ)))) := by
  have hp := MeasurePreserving.symm (NetworkInputSplit.split d N)
    (NetworkInputSplit.measurePreserving_split d N 1)
  have hset : (NetworkInputSplit.split d N).symm ⁻¹' inputBad G K =
      badMatrix (inputMatrix d) (inputFeatures d) N G K ×ˢ Set.univ := by
    ext p
    rcases p with ⟨a,b⟩
    simp only [Set.mem_preimage, Set.mem_prod, Set.mem_univ, and_true]
    rfl
  rw [← hp.map_eq, Measure.real, Measure.map_apply hp.measurable (isOpen_inputBad G K).measurableSet,
    hset, Measure.prod_prod, measure_univ, mul_one]
  have hcov (x y : Cube d) : ((1 / (d : ℝ)).toNNReal : ℝ) * gram (inputFeatures d) x y =
      gram (inputMatrix d) x y := by
    rw [Real.toNNReal_of_nonneg (by positivity)]
    change (1 / (d : ℝ)) * gram (inputFeatures d) x y =
      gram (fun x j => inputFeatures d x j / Real.sqrt (d : ℝ)) x y
    rw [gram_div_sqrt _ (Nat.cast_nonneg d)]
    ring
  have ht := BatchTwoOnlineMeanFieldExact.badMatrix_tail (inputMatrix d) (inputFeatures d) (1 / (d : ℝ)).toNNReal
    hcov hN hs hG K
  simpa only [NetworkInputSplit.inputPrior, sub_self, Real.rpow_zero, Measure.real] using ht

theorem lastBad_tail {d N r s : ℕ} (hd : 0 < d) (hN : 0 < N) (hs : 0 < s)
    {G : ℝ} (hG : 0 < G) (K : ℝ) :
    (powerPrior d N (r + 1) 1).real (lastBad G K) ≤
      Real.exp ((s : ℝ) * testEntropy d - (N : ℝ) * (K - G ^ 2 / (2 * (s : ℝ)))) := by
  have hp := MeasurePreserving.symm (NetworkLayerSplit.split d N r)
    (NetworkLayerSplit.measurePreserving_split d N r 1)
  rw [← hp.map_eq, Measure.real, Measure.map_apply hp.measurable (isOpen_lastBad G K).measurableSet]
  apply real_prod_le (powerPrior d N r 1) (matrixPrior N 1)
    ((NetworkLayerSplit.split d N r).symm ⁻¹' lastBad G K)
    ((isOpen_lastBad G K).measurableSet.preimage hp.measurable) (Real.exp_pos _).le
  intro w
  have hset : Prod.mk w ⁻¹' ((NetworkLayerSplit.split d N r).symm ⁻¹' lastBad G K) =
      badMatrix (activationMatrix w) (incomingFeatures w) N G K := by
    ext a
    simp only [Set.mem_preimage, lastBad, Set.mem_setOf_eq, split_symm_apply,
      previousWeights_appendLayer, badMatrix]
    change (fun i j => lastMatrix (appendLayer w (fun i j => a (i,j))) (i,j)) ∈ _ ↔ _
    rw [lastMatrix_appendLayer]
  rw [hset]
  have hcov (x y : Cube d) : (((N : ℝ) ^ (-(1 : ℝ))).toNNReal : ℝ) *
      gram (incomingFeatures w) x y = gram (activationMatrix w) x y := by
    rw [Real.rpow_neg_one, Real.toNNReal_of_nonneg (inv_nonneg.mpr (Nat.cast_nonneg N))]
    change (N : ℝ)⁻¹ * gram (incomingFeatures w) x y =
      gram (fun x j => incomingFeatures w x j / Real.sqrt (N : ℝ)) x y
    rw [gram_div_sqrt _ (Nat.cast_nonneg N)]
    ring
  exact BatchTwoOnlineMeanFieldExact.badMatrix_tail (activationMatrix w) (incomingFeatures w)
    ((N : ℝ) ^ (-(1 : ℝ))).toNNReal hcov hN hs hG K

theorem entropy_exponent_le {d N s : ℕ} {K G : ℝ} (hs : 0 < s) (hK : 4 ≤ K)
    (hGs : G ^ 2 ≤ 2 * (s : ℝ))
    (hthreshold : (s : ℝ) * testEntropy d ≤ (N : ℝ) * (K - 1) / 2) :
    (s : ℝ) * testEntropy d - (N : ℝ) * (K - G ^ 2 / (2 * (s : ℝ))) ≤
      -(N : ℝ) * K / 8 := by
  have hsp : (0 : ℝ) < s := by exact_mod_cast hs
  have hratio : G ^ 2 / (2 * (s : ℝ)) ≤ 1 := (div_le_one (by positivity)).mpr hGs
  have hmul := mul_le_mul_of_nonneg_left hratio (Nat.cast_nonneg N : (0 : ℝ) ≤ N)
  have hNK := mul_nonneg (Nat.cast_nonneg N : (0 : ℝ) ≤ N) (sub_nonneg.mpr hK)
  nlinarith

/-- A union bound over the actual recursively independent matrices. The
incoming covariance may depend on all previous weights and may be singular. -/
theorem goodHidden_compl_tail {d N r s : ℕ} (hd : 0 < d) (hN : 0 < N) (hs : 0 < s)
    (G : ℕ → ℝ) (K : ℝ) (hK : 4 ≤ K)
    (hG : ∀ j, j ≤ r → 0 < G j) (hGs : ∀ j, j ≤ r → (G j) ^ 2 ≤ 2 * (s : ℝ))
    (hthreshold : (s : ℝ) * testEntropy d ≤ (N : ℝ) * (K - 1) / 2) :
    (powerPrior d N r 1).real {w | ¬GoodHidden d N r G K w} ≤
      (r + 1 : ℝ) * Real.exp (-(N : ℝ) * K / 8) := by
  induction r with
  | zero =>
    have ht := (inputBad_tail hd hN hs (hG 0 (by omega)) K).trans
      (Real.exp_le_exp.mpr (entropy_exponent_le hs hK (hGs 0 (by omega)) hthreshold))
    simpa only [GoodHidden, not_not, Nat.cast_zero, zero_add, one_mul, Set.setOf_mem_eq] using ht
  | succ r ih =>
    have hprev := ih (fun j hj => hG j (by omega)) (fun j hj => hGs j (by omega))
    have hp : MeasurePreserving (@previousWeights d N r) (powerPrior d N (r + 1) 1)
        (powerPrior d N r 1) :=
      measurePreserving_fst.comp (NetworkLayerSplit.measurePreserving_split d N r 1)
    have hprevmeas : MeasurableSet {w : Weights d N r | ¬GoodHidden d N r G K w} :=
      (isClosed_GoodHidden d N r G K).measurableSet.compl
    have heq : (powerPrior d N (r + 1) 1).real
        {w | ¬GoodHidden d N r G K (previousWeights w)} =
        (powerPrior d N r 1).real {w | ¬GoodHidden d N r G K w} := by
      rw [← hp.map_eq]
      simp only [Measure.real]
      rw [Measure.map_apply hp.measurable hprevmeas]
      rfl
    have hlast := (lastBad_tail (r := r) hd hN hs (hG (r+1) (le_refl _)) K).trans
      (Real.exp_le_exp.mpr (entropy_exponent_le hs hK (hGs (r+1) (le_refl _)) hthreshold))
    have hset : {w | ¬GoodHidden d N (r+1) G K w} =
        {w | ¬GoodHidden d N r G K (previousWeights w)} ∪ lastBad (G (r+1)) K := by
      ext w
      simp only [Set.mem_setOf_eq, GoodHidden, Set.mem_union]
      tauto
    rw [hset]
    calc
      _ ≤ (powerPrior d N (r+1) 1).real {w | ¬GoodHidden d N r G K (previousWeights w)} +
          (powerPrior d N (r+1) 1).real (lastBad (G (r+1)) K) := measureReal_union_le _ _
      _ ≤ (r + 1 : ℝ) * Real.exp (-(N : ℝ) * K / 8) + Real.exp (-(N : ℝ) * K / 8) := by
        rw [heq]
        exact add_le_add hprev hlast
      _ = _ := by push_cast; ring

end NeuralGeneralization.BatchTwoOnlineMeanFieldExact
end
