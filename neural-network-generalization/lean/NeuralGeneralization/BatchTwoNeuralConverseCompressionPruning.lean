import NeuralGeneralization.BatchTwoNeuralConverseCompressionTail

/-! Rowwise pruning and its exact Hilbert-space sampling estimates. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
open MeasureTheory ProbabilityTheory
open ConcreteModel CompressionSampling Compression
variable {D N M : ℕ}

def matrixEnergy (W : Fin D → Fin N → ℝ) : ℝ := ∑ i,∑ j,(W i j)^2

def matrixRowNorm (W : Fin D → Fin N → ℝ) (i : Fin D) : ℝ :=
  Real.sqrt (∑ j,(W i j)^2)

def matrixPruned (t : ℝ) (W : Fin D → Fin N → ℝ) : Fin D → Fin N → ℝ :=
  fun i => prune (2*matrixRowNorm W i/t) (W i)

theorem matrixEnergy_nonneg (W : Fin D → Fin N → ℝ) : 0≤matrixEnergy W := by
  unfold matrixEnergy
  positivity

theorem matrixRowNorm_sq (W : Fin D → Fin N → ℝ) (i : Fin D) :
    (matrixRowNorm W i)^2=∑ j,(W i j)^2 := Real.sq_sqrt (by positivity)

theorem matrixPruned_sq_le (t : ℝ) (W : Fin D → Fin N → ℝ) (i : Fin D) (j : Fin N) :
    (matrixPruned t W i j)^2≤(W i j)^2 := prune_sq_le _ _ _

theorem matrixPruned_bound {t : ℝ} (ht : 0<t) (W : Fin D → Fin N → ℝ) (i : Fin D) (j : Fin N) :
    |matrixPruned t W i j|≤(2/t)*matrixRowNorm W i := by
  have hh := abs_prune_le (by dsimp [matrixRowNorm]; positivity : 0≤2*matrixRowNorm W i/t) (W i) j
  change |prune (2*matrixRowNorm W i/t) (W i) j|≤_
  exact hh.trans_eq (by ring)

theorem matrixPruned_mean_error {t : ℝ} (ht : 0<t) (W : Fin D → Fin N → ℝ)
    (h : Fin N → ℝ) (hh : ∀ j,|h j|≤1) :
    ‖matrixMean (matrixPruned t W) h-matrixMean W h‖≤t/2*Real.sqrt (matrixEnergy W) := by
  have hsq : ‖matrixMean (matrixPruned t W) h-matrixMean W h‖^2≤(t/2)^2*matrixEnergy W := by
    rw [EuclideanSpace.real_norm_sq_eq]
    unfold matrixEnergy
    rw [Finset.mul_sum]
    apply Finset.sum_le_sum
    intro i _
    have hi := row_pruning_error (W i) h hh (Real.sqrt_nonneg _) ht (matrixRowNorm_sq W i).symm
    have hnorm : |(matrixMean (matrixPruned t W) h-matrixMean W h) i|≤t/2*matrixRowNorm W i := by
      simpa only [PiLp.sub_apply,matrixMean_apply,matrixPruned,matrixRowNorm,abs_sub_comm,mul_div_assoc,div_mul_eq_mul_div] using hi
    have hsq := (sq_le_sq₀ (abs_nonneg _) (by dsimp [matrixRowNorm]; positivity)).mpr hnorm
    rw [sq_abs,mul_pow,matrixRowNorm_sq] at hsq
    exact hsq
  have hroot := Real.sq_sqrt (matrixEnergy_nonneg W)
  apply (sq_le_sq₀ (norm_nonneg _) (by positivity)).mp
  nlinarith only [hsq,hroot]

theorem matrixPruned_stage_tail (hN : 0<N) (hM : 0<M) {K ρ : ℝ} (hK : 0<K) (hρ : 0<ρ)
    (W : Fin D → Fin N → ℝ) (h : Fin N → ℝ) (hh : ∀ j,|h j|≤1) :
    letI : NeZero N := ⟨Nat.ne_of_gt hN⟩
    let t := ρ/(4*Real.sqrt K)*Real.sqrt (N:ℝ)
    let A := matrixPruned t W
    (iidSamples (uniformIndexLaw N) M).real
      {J | ρ*Real.sqrt ((N:ℝ)*matrixEnergy W)/(4*Real.sqrt K)<
        ‖sampleAverage M (matrixSummand A h) J-matrixMean A h‖}≤
      Real.exp (1-(M:ℝ)*ρ^2/(128*K)) := by
  letI : NeZero N := ⟨Nat.ne_of_gt hN⟩
  let t := ρ/(4*Real.sqrt K)*Real.sqrt (N:ℝ)
  let A := matrixPruned t W
  have hNR : (0:ℝ)<N := by exact_mod_cast hN
  have hsK : 0<Real.sqrt K := Real.sqrt_pos.mpr hK
  have hsN : 0<Real.sqrt (N:ℝ) := Real.sqrt_pos.mpr hNR
  have ht : 0<t := by dsimp [t]; positivity
  have hbound (j : Fin N) : ‖matrixSummand A h j‖≤
      8*Real.sqrt K*Real.sqrt ((N:ℝ)*matrixEnergy W)/ρ := by
    have hb := matrixSummand_norm_le A h hh (matrixRowNorm W) (fun _ => Real.sqrt_nonneg _)
      (by positivity : 0≤2/t) (matrixPruned_bound ht W) j
    have he : (∑ i,(matrixRowNorm W i)^2)=matrixEnergy W := by simp only [matrixRowNorm_sq,matrixEnergy]
    rw [he] at hb
    refine hb.trans_eq ?_
    rw [Real.sqrt_mul hNR.le]
    dsimp [t]
    field_simp
    rw [Real.sq_sqrt hNR.le]
    ring
  have hmoment := matrixSummand_second_moment hN A W h hh (matrixPruned_sq_le t W)
  have htale := finite_source_stage_tail (uniformIndexLaw N) (matrixSummand A h) hK hρ
    (mul_nonneg hNR.le (matrixEnergy_nonneg W)) hbound hmoment M hM
  rw [matrixSummand_mean hN A h] at htale
  exact htale

theorem matrixPruned_total_error (hN : 0<N) {K ρ : ℝ} (hK : 0<K) (hρ : 0<ρ)
    (W : Fin D → Fin N → ℝ) (h : Fin N → ℝ) (hh : ∀ j,|h j|≤1)
    (J : Fin M → Fin N)
    (hgood : ‖sampleAverage M
        (matrixSummand (matrixPruned (ρ/(4*Real.sqrt K)*Real.sqrt (N:ℝ)) W) h) J-
        matrixMean (matrixPruned (ρ/(4*Real.sqrt K)*Real.sqrt (N:ℝ)) W) h‖≤
      ρ*Real.sqrt ((N:ℝ)*matrixEnergy W)/(4*Real.sqrt K)) :
    ‖sampleAverage M
        (matrixSummand (matrixPruned (ρ/(4*Real.sqrt K)*Real.sqrt (N:ℝ)) W) h) J-
      matrixMean W h‖≤ρ*Real.sqrt ((N:ℝ)*matrixEnergy W)/(2*Real.sqrt K) := by
  have hNR : (0:ℝ)<N := by exact_mod_cast hN
  have hsK : 0<Real.sqrt K := Real.sqrt_pos.mpr hK
  have hsN : 0<Real.sqrt (N:ℝ) := Real.sqrt_pos.mpr hNR
  have ht : 0<ρ/(4*Real.sqrt K)*Real.sqrt (N:ℝ) := by positivity
  have he : (ρ/(4*Real.sqrt K)*Real.sqrt (N:ℝ))/2*Real.sqrt (matrixEnergy W)=
      ρ*Real.sqrt ((N:ℝ)*matrixEnergy W)/(8*Real.sqrt K) := by
    rw [Real.sqrt_mul hNR.le]
    ring
  have hpr := matrixPruned_mean_error ht W h hh
  rw [he] at hpr
  have htri := norm_sub_le
    (sampleAverage M (matrixSummand (matrixPruned (ρ/(4*Real.sqrt K)*Real.sqrt (N:ℝ)) W) h) J)
    (matrixMean W h)
  have hdist := norm_sub_le_norm_sub_add_norm_sub
    (sampleAverage M (matrixSummand (matrixPruned (ρ/(4*Real.sqrt K)*Real.sqrt (N:ℝ)) W) h) J)
    (matrixMean (matrixPruned (ρ/(4*Real.sqrt K)*Real.sqrt (N:ℝ)) W) h) (matrixMean W h)
  have hn : 0≤ρ*Real.sqrt ((N:ℝ)*matrixEnergy W)/(8*Real.sqrt K) := by positivity
  have hsum := hdist.trans (add_le_add hgood hpr)
  have he2 : ρ*Real.sqrt ((N:ℝ)*matrixEnergy W)/(4*Real.sqrt K)=
      2*(ρ*Real.sqrt ((N:ℝ)*matrixEnergy W)/(8*Real.sqrt K)) := by ring
  have he4 : ρ*Real.sqrt ((N:ℝ)*matrixEnergy W)/(2*Real.sqrt K)=
      4*(ρ*Real.sqrt ((N:ℝ)*matrixEnergy W)/(8*Real.sqrt K)) := by ring
  rw [he2] at hsum
  rw [he4]
  linarith only [hsum,hn]

end
end NeuralGeneralization.BatchTwoNeuralConverse
