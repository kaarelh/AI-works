import NeuralGeneralization.BatchTwoMergingCompressedGaussian
import NeuralGeneralization.BatchTwoMergingPartitions

/-! # Gaussian energy truncation before selecting a population witness -/

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal

namespace NeuralGeneralization.BatchTwoMerging

open ConcreteModel

def compressedEnergy {d N r : ℕ} (p : LayerPartitions N r) (w : Weights d N r) : ℝ :=
  ∑ a, compressedWhitened p w a ^ 2

theorem measurable_compressedEnergy {d N r : ℕ} (p : LayerPartitions N r) :
    Measurable (compressedEnergy (d := d) p) := by
  apply Finset.measurable_sum
  intro a _
  exact ((measurable_pi_apply a).comp (measurable_compressedWhitened p)).pow_const 2

theorem compressedIndex_card {d N r : ℕ} (p : LayerPartitions N r) :
    Fintype.card (CompressedIndex d N r p) =
      populationCount (p 0) * (d + 1) +
        (∑ s : Fin r, populationCount (p s.succ) * populationCount (p s.castSucc)) +
          populationCount (p (Fin.last r)) := by
  simp [CompressedIndex, Fintype.card_sum, Fintype.card_sigma,
    Fintype.card_prod, Fintype.card_fin, Nat.add_assoc]

theorem compressedIndex_card_le_width {d N r Q : ℕ} (p : LayerPartitions N r)
    (hp : ∀ s, populationCount (p s) ≤ Q) :
    Fintype.card (CompressedIndex d N r p) ≤ N * (d + 2 + r * Q) := by
  rw [compressedIndex_card]
  have hfirst := Nat.mul_le_mul_right (d + 1) (populationCount_le (p 0))
  have hlast := populationCount_le (p (Fin.last r))
  have hmiddle : (∑ s : Fin r, populationCount (p s.succ) * populationCount (p s.castSucc)) ≤
      r * (N * Q) := by
    calc
      _ ≤ ∑ _s : Fin r, N * Q := Finset.sum_le_sum fun s _ =>
        Nat.mul_le_mul (populationCount_le (p s.succ)) (hp s.castSucc)
      _ = _ := by simp
  nlinarith

theorem compressedIndex_card_le_grid {d N r Q : ℕ} (p : LayerPartitions N r)
    (hp : ∀ s, populationCount (p s) ≤ Q) :
    Fintype.card (CompressedIndex d N r p) ≤ Q * (d + 2) + r * Q ^ 2 := by
  rw [compressedIndex_card]
  have hfirst := Nat.mul_le_mul_right (d + 1) (hp 0)
  have hlast := hp (Fin.last r)
  have hmiddle : (∑ s : Fin r, populationCount (p s.succ) * populationCount (p s.castSucc)) ≤
      r * (Q * Q) := by
    calc
      _ ≤ ∑ _s : Fin r, Q * Q := Finset.sum_le_sum fun s _ =>
        Nat.mul_le_mul (hp s.succ) (hp s.castSucc)
      _ = _ := by simp
  nlinarith

theorem smallPrior_compressedEnergy_tail {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    {σ : ℝ} (hσ : 0 < σ) (p : LayerPartitions N r) (J : ℝ) :
    (smallPrior d N r σ).real {w | J < compressedEnergy p w} ≤
      Real.exp ((Fintype.card (CompressedIndex d N r p) : ℝ) / 2 * Real.log 2 -
        J / (4 * σ ^ 2)) := by
  have h := gaussian_squaredNorm_log_chernoff (I := CompressedIndex d N r p)
    (σ ^ 2).toNNReal (by rw [Real.coe_toNNReal _ (sq_nonneg σ)]; exact sq_pos_of_pos hσ) J
  rw [Real.coe_toNNReal _ (sq_nonneg σ), ← smallPrior_map_compressedWhitened hd hN hσ p,
    Measure.real, Measure.map_apply (measurable_compressedWhitened p)
      (measurableSet_le measurable_const (by fun_prop))] at h
  apply (measureReal_mono (μ := smallPrior d N r σ) ?_).trans h
  intro w hw
  change J ≤ compressedEnergy p w
  exact hw.le

def exceptionalPartitions {d N r Q : ℕ} (J : ℝ) : Set (Weights d N r) :=
  ⋃ p : BoundedLayerPartitions N r Q, {w | J < compressedEnergy p.val w}

theorem measurable_exceptionalPartitions {d N r Q : ℕ} (J : ℝ) :
    MeasurableSet (exceptionalPartitions (d := d) (N := N) (r := r) (Q := Q) J) := by
  apply MeasurableSet.iUnion
  intro p
  exact measurableSet_lt measurable_const (measurable_compressedEnergy p.val)

/-- A genuine finite union bound for all population witnesses. The witness may
subsequently depend on every sampled network coordinate. -/
theorem smallPrior_exceptionalPartitions_tail {d N r Q : ℕ}
    (hd : 0 < d) (hN : 0 < N) (hQ : 0 < Q) {σ : ℝ} (hσ : 0 < σ) (J : ℝ) :
    (smallPrior d N r σ).real (exceptionalPartitions (Q := Q) J) ≤
      Real.exp (((r + 1) * (N + 1) : ℕ) * Real.log (Q : ℝ) +
        (N : ℝ) / 2 * (d + 2 + r * Q : ℕ) * Real.log 2 - J / (4 * σ ^ 2)) := by
  have hqR : (0 : ℝ) < Q := Nat.cast_pos.mpr hQ
  have hlog : 0 ≤ Real.log 2 := Real.log_nonneg (by norm_num)
  let E := (N : ℝ) / 2 * (d + 2 + r * Q : ℕ) * Real.log 2 - J / (4 * σ ^ 2)
  have hone (p : BoundedLayerPartitions N r Q) :
      (smallPrior d N r σ).real {w | J < compressedEnergy p.val w} ≤ Real.exp E := by
    apply (smallPrior_compressedEnergy_tail hd hN hσ p.val J).trans
    apply Real.exp_le_exp.mpr
    have hc : (Fintype.card (CompressedIndex d N r p.val) : ℝ) ≤
        (N : ℝ) * (d + 2 + r * Q : ℕ) := by
      exact_mod_cast compressedIndex_card_le_width p.val p.property
    have hm := mul_le_mul_of_nonneg_right hc hlog
    dsimp [E]
    nlinarith
  calc
    _ ≤ ∑ p : BoundedLayerPartitions N r Q,
        (smallPrior d N r σ).real {w | J < compressedEnergy p.val w} :=
      measureReal_iUnion_fintype_le _
    _ ≤ ∑ _p : BoundedLayerPartitions N r Q, Real.exp E :=
      Finset.sum_le_sum fun p _ => hone p
    _ = (Fintype.card (BoundedLayerPartitions N r Q) : ℝ) * Real.exp E := by simp
    _ ≤ (Q : ℝ) ^ ((r + 1) * (N + 1)) * Real.exp E := by
      apply mul_le_mul_of_nonneg_right _ (Real.exp_nonneg _)
      exact_mod_cast boundedLayerPartitions_card_le (r := r) (Q := Q) hN
    _ = _ := by
      rw [← Real.exp_log hqR, ← Real.exp_nat_mul, ← Real.exp_add]
      congr 1
      simp only [Real.log_exp]
      dsimp [E]
      ring

end NeuralGeneralization.BatchTwoMerging
