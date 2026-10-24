import NeuralGeneralization.BatchTwoNeuralConverseCompressionStages

/-! All successful sampling stages produce a genuine small finite disturbance. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
open Classical Set MeasureTheory ProbabilityTheory
open ConcreteModel CompressionSampling Compression
variable {d N r M : ℕ}

theorem euclidean_tanh_difference_sq_le {D : ℕ} (a b : EuclideanSpace ℝ (Fin D)) :
    (∑ i,(Real.tanh (a i)-Real.tanh (b i))^2)≤‖a-b‖^2 := by
  rw [EuclideanSpace.real_norm_sq_eq]
  apply Finset.sum_le_sum
  intro i _
  have hh := tanh_admissible.2 (a i) (b i)
  have hs := (sq_le_sq₀ (abs_nonneg _) (abs_nonneg _)).mpr hh
  simpa only [sq_abs,PiLp.sub_apply] using hs

theorem internal_disturbance_sq_le (hN : 0<N) {ρ K : ℝ} (hρ : 0<ρ) (hK : 0<K)
    (w : Weights d N r) (I : Fin (r+1) → Fin M → Fin N) (x : Cube d) (s : Fin r)
    (hgood : I∉internalSamplingBad ρ K w x s) :
    (∑ i,((virtualDisturbance w (compressionPruned ρ K w) I x).1 s.succ i)^2)≤
      ρ^2*(N:ℝ)*matrixEnergy (internalMatrix w s)/(4*K) := by
  let h := virtualPrefix (compressionPruned ρ K w) I x s.val
  let a := sampleAverage M (matrixSummand (internalMatrix (compressionPruned ρ K w) s) h) (I s.castSucc)
  let b := matrixMean (internalMatrix w s) h
  have htail : ‖a-matrixMean (internalMatrix (compressionPruned ρ K w) s) h‖≤
      ρ*Real.sqrt ((N:ℝ)*matrixEnergy (internalMatrix w s))/(4*Real.sqrt K) := le_of_not_gt hgood
  rw [compressionPruned_internal] at htail
  have herr := matrixPruned_total_error hN hK hρ (internalMatrix w s) h
    (virtualPrefix_bounded _ I x s.val) (I s.castSucc) htail
  change ‖a-b‖≤_ at herr
  have he (i : Fin N) : (virtualDisturbance w (compressionPruned ρ K w) I x).1 s.succ i=
      Real.tanh (a i)-Real.tanh (b i) := by
    simp only [virtualDisturbance,Fin.cases_succ,Pi.sub_apply,virtualPrefix_succ,virtualStep,
      hiddenStep,a,b,h,sampleAverage_matrix_apply,matrixMean_apply,internalMatrix]
  simp_rw [he]
  refine (euclidean_tanh_difference_sq_le a b).trans ?_
  have hs := (sq_le_sq₀ (norm_nonneg _) (by positivity)).mpr herr
  rw [div_pow,mul_pow,Real.sq_sqrt (mul_nonneg (Nat.cast_nonneg N) (matrixEnergy_nonneg _)),mul_pow,Real.sq_sqrt hK.le] at hs
  convert hs using 1 <;> first | ring | rfl

theorem output_disturbance_sq_le (hN : 0<N) {ρ K : ℝ} (hρ : 0<ρ) (hK : 0<K)
    (w : Weights d N r) (I : Fin (r+1) → Fin M → Fin N) (x : Cube d)
    (hgood : I∉outputSamplingBad ρ K w x) :
    ((virtualDisturbance w (compressionPruned ρ K w) I x).2)^2≤
      ρ^2*(N:ℝ)*matrixEnergy (readoutMatrix w)/(4*K) := by
  let h := virtualPrefix (compressionPruned ρ K w) I x r
  let a := sampleAverage M (matrixSummand (readoutMatrix (compressionPruned ρ K w)) h) (I (Fin.last r))
  let b := matrixMean (readoutMatrix w) h
  have htail : ‖a-matrixMean (readoutMatrix (compressionPruned ρ K w)) h‖≤
      ρ*Real.sqrt ((N:ℝ)*matrixEnergy (readoutMatrix w))/(4*Real.sqrt K) := le_of_not_gt hgood
  rw [compressionPruned_readout] at htail
  have herr := matrixPruned_total_error hN hK hρ (readoutMatrix w) h
    (virtualPrefix_bounded _ I x r) (I (Fin.last r)) htail
  change ‖a-b‖≤_ at herr
  have he : ‖a-b‖^2=((virtualDisturbance w (compressionPruned ρ K w) I x).2)^2 := by
    rw [EuclideanSpace.real_norm_sq_eq]
    simp only [Fin.sum_univ_one,PiLp.sub_apply,a,b,h,sampleAverage_matrix_apply,matrixMean_apply,
      readoutMatrix,virtualDisturbance,virtualOutput]
  have hs := (sq_le_sq₀ (norm_nonneg _) (by positivity)).mpr herr
  rw [he,div_pow,mul_pow,Real.sq_sqrt (mul_nonneg (Nat.cast_nonneg N) (matrixEnergy_nonneg _)),mul_pow,Real.sq_sqrt hK.le] at hs
  convert hs using 1 <;> first | ring | rfl

theorem virtualDisturbance_first_zero (ρ K : ℝ) (w : Weights d N r)
    (I : Fin (r+1) → Fin M → Fin N) (x : Cube d) (i : Fin N) :
    (virtualDisturbance w (compressionPruned ρ K w) I x).1 0 i=0 := by
  simp only [virtualDisturbance,Fin.cases_zero,Pi.sub_apply,firstHidden,compressionPruned,prunedWeights,sub_self]

theorem matrixEnergy_readout (w : Weights d N r) :
    matrixEnergy (readoutMatrix w)=∑ j,w (Sum.inr (Sum.inr j))^2 := by
  simp only [matrixEnergy,readoutMatrix,Fin.sum_univ_one]

theorem matrixEnergy_layers_le_cost (w : Weights d N r) :
    (∑ s,matrixEnergy (internalMatrix w s))+(N:ℝ)*matrixEnergy (readoutMatrix w)≤weightedSquaredNorm w := by
  simp only [matrixEnergy,internalMatrix,readoutMatrix,Fin.sum_univ_one,weightedSquaredNorm]
  have hfirst : 0≤(d:ℝ)/N*∑ i,∑ j,w (Sum.inl (i,j))^2 := by positivity
  linarith

theorem virtualDisturbance_budget (hN : 0<N) {ρ K : ℝ} (hρ : 0<ρ) (hK : 0<K)
    (w : Weights d N r) (hw : weightedSquaredNorm w≤K)
    (I : Fin (r+1) → Fin M → Fin N) (x : Cube d)
    (hi : ∀ s,I∉internalSamplingBad ρ K w x s) (ho : I∉outputSamplingBad ρ K w x) :
    noiseBudgetSq (virtualDisturbance w (compressionPruned ρ K w) I x)≤ρ^2/4 := by
  have hNR : (0:ℝ)<N := by exact_mod_cast hN
  have hsum := Finset.sum_le_sum (fun s (_ : s∈Finset.univ) =>
    internal_disturbance_sq_le hN hρ hK w I x s (hi s))
  have houtput := output_disturbance_sq_le hN hρ hK w I x ho
  unfold noiseBudgetSq
  rw [Fin.sum_univ_succ]
  simp only [virtualDisturbance_first_zero,zero_pow (by omega : 2≠0),Finset.sum_const_zero,zero_add]
  have hbound := add_le_add (div_le_div_of_nonneg_right hsum hNR.le) houtput
  refine hbound.trans ?_
  have hcost := (matrixEnergy_layers_le_cost w).trans hw
  have hmul := mul_le_mul_of_nonneg_left hcost (show 0≤ρ^2/(4*K) by positivity)
  have he : ((∑ s,ρ^2*(N:ℝ)*matrixEnergy (internalMatrix w s)/(4*K)))/(N:ℝ)+
      ρ^2*(N:ℝ)*matrixEnergy (readoutMatrix w)/(4*K)=
      (ρ^2/(4*K))*((∑ s,matrixEnergy (internalMatrix w s))+(N:ℝ)*matrixEnergy (readoutMatrix w)) := by
    rw [←Finset.sum_div,←Finset.mul_sum]
    field_simp
  have heK : ρ^2/(4*K)*K=ρ^2/4 := by field_simp
  rw [heK] at hmul
  rw [he]
  exact hmul

end
end NeuralGeneralization.BatchTwoNeuralConverse
