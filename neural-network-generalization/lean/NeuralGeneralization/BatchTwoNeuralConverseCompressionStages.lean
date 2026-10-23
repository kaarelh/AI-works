import NeuralGeneralization.BatchTwoNeuralConverseCompressionPruning
import NeuralGeneralization.BatchTwoNeuralConverseCompressionFresh

/-! Per-input failure events for each actual forward sampling stage. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
open Classical Set MeasureTheory ProbabilityTheory
open ConcreteModel CompressionSampling Compression
variable {d N r M : ℕ}

def internalMatrix (w : Weights d N r) (s : Fin r) : Fin N → Fin N → ℝ :=
  fun i j => w (Sum.inr (Sum.inl (s,i,j)))

def readoutMatrix (w : Weights d N r) : Fin 1 → Fin N → ℝ :=
  fun _ j => w (Sum.inr (Sum.inr j))

def compressionPruned (ρ K : ℝ) (w : Weights d N r) : Weights d N r :=
  prunedWeights (ρ/(4*Real.sqrt K)) (Real.sqrt (N:ℝ)) w

theorem compressionPruned_internal (ρ K : ℝ) (w : Weights d N r) (s : Fin r) :
    internalMatrix (compressionPruned ρ K w) s=
      matrixPruned (ρ/(4*Real.sqrt K)*Real.sqrt (N:ℝ)) (internalMatrix w s) := rfl

theorem compressionPruned_readout (ρ K : ℝ) (w : Weights d N r) :
    readoutMatrix (compressionPruned ρ K w)=
      matrixPruned (ρ/(4*Real.sqrt K)*Real.sqrt (N:ℝ)) (readoutMatrix w) := rfl

theorem compressionPruned_cost_le (ρ K : ℝ) (w : Weights d N r) :
    weightedSquaredNorm (compressionPruned ρ K w)≤weightedSquaredNorm w :=
  prunedWeights_cost_le _ _ _

theorem sampleAverage_matrix_apply {D : ℕ} (A : Fin D → Fin N → ℝ)
    (h : Fin N → ℝ) (J : Fin M → Fin N) (i : Fin D) :
    sampleAverage M (matrixSummand A h) J i=(N:ℝ)/M*∑ a,A i (J a)*h (J a) := by
  change (EuclideanSpace.proj i) (((M:ℝ)⁻¹) • ∑ a,matrixSummand A h (J a))=_
  rw [map_smul,map_sum]
  change (M:ℝ)⁻¹*(∑ a,(N:ℝ)*A i (J a)*h (J a))=_
  simp_rw [mul_assoc]
  rw [←Finset.mul_sum]
  ring

def internalSamplingBad (ρ K : ℝ) (w : Weights d N r) (x : Cube d) (s : Fin r) :
    Set (Fin (r+1) → Fin M → Fin N) :=
  {I | ρ*Real.sqrt ((N:ℝ)*matrixEnergy (internalMatrix w s))/(4*Real.sqrt K)<
    ‖sampleAverage M (matrixSummand (internalMatrix (compressionPruned ρ K w) s)
      (virtualPrefix (compressionPruned ρ K w) I x s.val)) (I s.castSucc)-
      matrixMean (internalMatrix (compressionPruned ρ K w) s)
        (virtualPrefix (compressionPruned ρ K w) I x s.val)‖}

def outputSamplingBad (ρ K : ℝ) (w : Weights d N r) (x : Cube d) :
    Set (Fin (r+1) → Fin M → Fin N) :=
  {I | ρ*Real.sqrt ((N:ℝ)*matrixEnergy (readoutMatrix w))/(4*Real.sqrt K)<
    ‖sampleAverage M (matrixSummand (readoutMatrix (compressionPruned ρ K w))
      (virtualPrefix (compressionPruned ρ K w) I x r)) (I (Fin.last r))-
      matrixMean (readoutMatrix (compressionPruned ρ K w))
        (virtualPrefix (compressionPruned ρ K w) I x r)‖}

theorem internalSamplingBad_probability (hN : 0<N) (hM : 0<M) {ρ K : ℝ} (hρ : 0<ρ) (hK : 0<K)
    (w : Weights d N r) (x : Cube d) (s : Fin r) :
    letI : NeZero N := ⟨Nat.ne_of_gt hN⟩
    (allLayerLists N M r).real (internalSamplingBad (M:=M) ρ K w x s)≤
      Real.exp (1-(M:ℝ)*ρ^2/(128*K)) := by
  letI : NeZero N := ⟨Nat.ne_of_gt hN⟩
  apply allLayerLists_fresh_bound N M r s.castSucc _ (Real.exp_pos _).le
  intro I
  have he (J : Fin M → Fin N) :
      virtualPrefix (compressionPruned ρ K w) (Function.update I s.castSucc J) x s.val=
        virtualPrefix (compressionPruned ρ K w) I x s.val :=
    virtualPrefix_update_fresh _ I x s.castSucc J
  simpa only [internalSamplingBad,Set.mem_setOf_eq,Function.update_self,he,compressionPruned_internal] using
    matrixPruned_stage_tail hN hM hK hρ (internalMatrix w s)
      (virtualPrefix (compressionPruned ρ K w) I x s.val)
      (virtualPrefix_bounded _ I x s.val)

theorem outputSamplingBad_probability (hN : 0<N) (hM : 0<M) {ρ K : ℝ} (hρ : 0<ρ) (hK : 0<K)
    (w : Weights d N r) (x : Cube d) :
    letI : NeZero N := ⟨Nat.ne_of_gt hN⟩
    (allLayerLists N M r).real (outputSamplingBad (M:=M) ρ K w x)≤
      Real.exp (1-(M:ℝ)*ρ^2/(128*K)) := by
  letI : NeZero N := ⟨Nat.ne_of_gt hN⟩
  apply allLayerLists_fresh_bound N M r (Fin.last r) _ (Real.exp_pos _).le
  intro I
  have he (J : Fin M → Fin N) :
      virtualPrefix (compressionPruned ρ K w) (Function.update I (Fin.last r) J) x r=
        virtualPrefix (compressionPruned ρ K w) I x r :=
    virtualPrefix_update_fresh _ I x (Fin.last r) J
  simpa only [outputSamplingBad,Set.mem_setOf_eq,Function.update_self,he,compressionPruned_readout] using
    matrixPruned_stage_tail hN hM hK hρ (readoutMatrix w)
      (virtualPrefix (compressionPruned ρ K w) I x r)
      (virtualPrefix_bounded _ I x r)

end
end NeuralGeneralization.BatchTwoNeuralConverse
