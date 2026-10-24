import NeuralGeneralization.BatchTwoMergingGeluGrid
import NeuralGeneralization.BatchTwoMergingCover

/-! The actual GELU restricted posterior has a common finite comparison class. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel

theorem gelu_partitionSupport_grid_cover {d N r Q : ℕ} (hd : 0<d) (hN : 0<N)
    (p : LayerPartitions N r) (hq : ∀s,populationCount (p s)≤Q)
    (w : Weights d N r) (hw : w∈partitionSupport gelu p) {J : ℝ}
    (hJ : compressedEnergy p w≤J) :
    ∃c : GeluGridCode d Q r (geluGridResolution d Q r (1+Real.sqrt J)),∀x,
      |clippedScore (networkOutput gelu w x)-
        clippedScore (perspectiveOutput
          (geluGridWeights d Q r (geluGridResolution d Q r (1+Real.sqrt J)) (1+Real.sqrt J) c)
          (geluGridMasses d Q r (geluGridResolution d Q r (1+Real.sqrt J)) c) x)|≤3/32 := by
  have hR : 1≤1+Real.sqrt J := by linarith [Real.sqrt_nonneg J]
  obtain ⟨c,hc⟩ := exists_gelu_grid_output_cover hR (compressedWeights p hq w)
    (populationScales p hq)
    (fun i=>(compressedWeights_abs_le_sqrt hd hN p hq w hJ i).trans (by linarith))
    (fun s i=>populationScale_bounds hN (p s) (hq s) i)
  refine ⟨c,fun x=>?_⟩
  have hmerged := hw.2 x
  have hgrid := (RobustStatistics.clippedScore_lipschitz
    (perspectiveOutput (compressedWeights p hq w) (populationScales p hq) x) _).trans (hc x)
  rw [←gelu_compressed_networkOutput hN p hq w x] at hgrid
  have htri := abs_sub_le (clippedScore (networkOutput gelu w x))
    (clippedScore (networkOutput gelu (mergedWeights p w) x))
    (clippedScore (perspectiveOutput
      (geluGridWeights d Q r (geluGridResolution d Q r (1+Real.sqrt J)) (1+Real.sqrt J) c)
      (geluGridMasses d Q r (geluGridResolution d Q r (1+Real.sqrt J)) c) x))
  linarith

theorem gelu_posteriorEvent_grid_cover {d N r n : ℕ} (hd : 0<d) (hN : 0<N)
    (hn : 0<n) (globalMargin : Bool) (f : BooleanFunction d)
    (sample : Fin n→Cube d) (w : Weights d N r)
    (hw : w∈posteriorEvent gelu globalMargin f sample) {B J : ℝ}
    (hB : readoutEnergy w≤B)
    (hJ : w∉exceptionalPartitions (Q:=⌈1+16*B⌉₊) J) :
    ∃c : GeluGridCode d ⌈1+16*B⌉₊ r
        (geluGridResolution d ⌈1+16*B⌉₊ r (1+Real.sqrt J)),∀x,
      |clippedScore (networkOutput gelu w x)-
        clippedScore (perspectiveOutput
          (geluGridWeights d ⌈1+16*B⌉₊ r
            (geluGridResolution d ⌈1+16*B⌉₊ r (1+Real.sqrt J)) (1+Real.sqrt J) c)
          (geluGridMasses d ⌈1+16*B⌉₊ r
            (geluGridResolution d ⌈1+16*B⌉₊ r (1+Real.sqrt J)) c) x)|≤3/32 := by
  obtain ⟨p,hp,hq⟩ := exists_partition_with_bounded_count hN hn gelu globalMargin f sample w hw hB
  exact gelu_partitionSupport_grid_cover hd hN p hq w hp
    (compressedEnergy_le_of_not_exceptional w hJ p hq)

end NeuralGeneralization.BatchTwoMerging
