import NeuralGeneralization.BatchTwoOnlineTanhGrid
import NeuralGeneralization.BatchTwoOnlineTanhSignedSupport
import NeuralGeneralization.BatchTwoMergingCover

/-! The actual Real.tanh restricted posterior has a common finite comparison class. -/
noncomputable section
set_option autoImplicit false
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineTanhMerging
open ConcreteModel BatchTwoMerging

theorem tanh_partitionSupport_grid_cover {d N r Q : ℕ} (hd : 0<d) (hN : 0<N)
    (p : LayerPartitions N r) (hq : ∀s,populationCount (p s)≤Q)
    (w : Weights d N r) (hw : w∈partitionSupport Real.tanh p) {J : ℝ}
    (hJ : compressedEnergy p w≤J) :
    ∃c : TanhGridCode d Q r (tanhGridResolution d Q r (1+Real.sqrt J)),∀x,
      |clippedScore (networkOutput Real.tanh w x)-
        clippedScore (perspectiveOutput
          (tanhGridWeights d Q r (tanhGridResolution d Q r (1+Real.sqrt J)) (1+Real.sqrt J) c)
          (tanhGridMasses d Q r (tanhGridResolution d Q r (1+Real.sqrt J)) c) x)|≤3/32 := by
  have hR : 1≤1+Real.sqrt J := by linarith [Real.sqrt_nonneg J]
  obtain ⟨c,hc⟩ := exists_tanh_grid_output_cover hR (compressedWeights p hq w)
    (populationScales p hq)
    (fun i=>(compressedWeights_abs_le_sqrt hd hN p hq w hJ i).trans (by linarith))
    (fun s i=>populationScale_bounds hN (p s) (hq s) i)
  refine ⟨c,fun x=>?_⟩
  have hmerged := hw.2 x
  have hgrid := (RobustStatistics.clippedScore_lipschitz
    (perspectiveOutput (compressedWeights p hq w) (populationScales p hq) x) _).trans (hc x)
  rw [←tanh_compressed_networkOutput hN p hq w x] at hgrid
  have htri := abs_sub_le (clippedScore (networkOutput Real.tanh w x))
    (clippedScore (networkOutput Real.tanh (mergedWeights p w) x))
    (clippedScore (perspectiveOutput
      (tanhGridWeights d Q r (tanhGridResolution d Q r (1+Real.sqrt J)) (1+Real.sqrt J) c)
      (tanhGridMasses d Q r (tanhGridResolution d Q r (1+Real.sqrt J)) c) x))
  linarith

theorem signed_partition_grid_cover {d N r Q : ℕ} (hd : 0<d) (hN : 0<N)
    (p : LayerPartitions N r) (s : HiddenSigns N r) (hq : ∀j,populationCount (p j)≤Q)
    (w : Weights d N r) (hw : w∈signedPartitionSupport p s) {J : ℝ}
    (hJ : compressedEnergy p (flipHiddenSigns s w)≤J) :
    ∃c : TanhGridCode d Q r (tanhGridResolution d Q r (1+Real.sqrt J)),∀x,
      |clippedScore (networkOutput Real.tanh w x)-
        clippedScore (perspectiveOutput
          (tanhGridWeights d Q r (tanhGridResolution d Q r (1+Real.sqrt J)) (1+Real.sqrt J) c)
          (tanhGridMasses d Q r (tanhGridResolution d Q r (1+Real.sqrt J)) c) x)|≤3/32 := by
  have hp : flipHiddenSigns s w∈partitionSupport Real.tanh p := by
    simpa only [signedPartitionSupport_eq_preimage,Set.mem_preimage] using hw
  simpa only [flipHiddenSigns_output] using tanh_partitionSupport_grid_cover hd hN p hq (flipHiddenSigns s w) hp hJ

end NeuralGeneralization.BatchTwoOnlineTanhMerging
