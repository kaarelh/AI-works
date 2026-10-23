import NeuralGeneralization.BatchTwoMergingCoordinateBounds
import NeuralGeneralization.BatchTwoMergingGrid
import NeuralGeneralization.BatchTwoMergingPosterior

/-! # A width-independent finite comparison class on the actual restricted support -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel

theorem partitionSupport_grid_cover {d N r Q : ℕ} (hd : 0 < d) (hN : 0 < N)
    (p : LayerPartitions N r) (hq : ∀ s, populationCount (p s) ≤ Q)
    (w : Weights d N r) (hw : w ∈ partitionSupport relu p) {J : ℝ}
    (hJ : compressedEnergy p w ≤ J) :
    ∃ c : NetworkGridCode d Q r (gridResolution d Q r (1+Real.sqrt J)), ∀ x,
      |clippedScore (networkOutput relu w x) -
        clippedScore (networkOutput relu
          (gridWeights d Q r (gridResolution d Q r (1+Real.sqrt J)) (1+Real.sqrt J) c) x)|
          ≤ 3/32 := by
  have hR : 1 ≤ 1+Real.sqrt J := by linarith [Real.sqrt_nonneg J]
  obtain ⟨c,hc⟩ := exists_grid_output_cover relu_lipschitzZero hR
    (compressedWeights p hq w) (fun i =>
      (compressedWeights_abs_le_sqrt hd hN p hq w hJ i).trans (by linarith))
  refine ⟨c,fun x => ?_⟩
  have hmerged := hw.2 x
  have hgrid := (RobustStatistics.clippedScore_lipschitz
    (networkOutput relu (compressedWeights p hq w) x) _).trans (hc x)
  rw [← compressed_networkOutput hN p hq w x] at hgrid
  have htri := abs_sub_le (clippedScore (networkOutput relu w x))
    (clippedScore (networkOutput relu (mergedWeights p w) x))
    (clippedScore (networkOutput relu
      (gridWeights d Q r (gridResolution d Q r (1+Real.sqrt J)) (1+Real.sqrt J) c) x))
  linarith

theorem compressedEnergy_le_of_not_exceptional {d N r Q : ℕ} {J : ℝ}
    (w : Weights d N r) (hw : w ∉ exceptionalPartitions (Q := Q) J)
    (p : LayerPartitions N r) (hq : ∀ s, populationCount (p s) ≤ Q) :
    compressedEnergy p w ≤ J := by
  by_contra h
  apply hw
  exact Set.mem_iUnion.mpr ⟨⟨p,hq⟩,lt_of_not_ge h⟩

/-- After the two proven Gaussian truncations, every actual posterior network
has one comparison network from a class independent of the learner width,
its prior scale, and the training sample. -/
theorem posteriorEvent_grid_cover {d N r n : ℕ} (hd : 0 < d) (hN : 0 < N)
    (hn : 0 < n) (globalMargin : Bool) (f : BooleanFunction d)
    (sample : Fin n → Cube d) (w : Weights d N r)
    (hw : w ∈ posteriorEvent relu globalMargin f sample) {B J : ℝ}
    (hB : readoutEnergy w ≤ B)
    (hJ : w ∉ exceptionalPartitions (Q := ⌈1+16*B⌉₊) J) :
    ∃ c : NetworkGridCode d ⌈1+16*B⌉₊ r
        (gridResolution d ⌈1+16*B⌉₊ r (1+Real.sqrt J)), ∀ x,
      |clippedScore (networkOutput relu w x) -
        clippedScore (networkOutput relu
          (gridWeights d ⌈1+16*B⌉₊ r
            (gridResolution d ⌈1+16*B⌉₊ r (1+Real.sqrt J)) (1+Real.sqrt J) c) x)|
          ≤ 3/32 := by
  obtain ⟨p,hp,hq⟩ := exists_partition_with_bounded_count hN hn relu globalMargin f sample w hw hB
  exact partitionSupport_grid_cover hd hN p hq w hp
    (compressedEnergy_le_of_not_exceptional w hJ p hq)

end NeuralGeneralization.BatchTwoMerging
