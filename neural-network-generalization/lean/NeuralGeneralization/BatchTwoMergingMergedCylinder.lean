import NeuralGeneralization.BatchTwoMergingAveraging
import NeuralGeneralization.BatchTwoMergingEvaluation
import NeuralGeneralization.BatchTwoMergingCylinderStability

/-! # The free Gaussian bulk disappears under the teacher's population averaging -/
noncomputable section
open scoped BigOperators Matrix
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel

variable {d N r : ℕ}

theorem merged_first_difference {p : PopulationPartition N} (w v : Weights d N r)
    (hfixed : mergedWeights (fun _ => p) v=v) (i : Fin N) (j : Fin (d+1)) :
    mergedWeights (fun _ => p) w (Sum.inl (i,j))-v (Sum.inl (i,j)) =
      populationAverage p (fun k => w (Sum.inl (k,j))-v (Sum.inl (k,j))) i := by
  have hf := congrFun hfixed (Sum.inl (i,j))
  rw [← hf]
  simp only [mergedWeights,populationAverage,mul_sub,Finset.sum_sub_distrib]

theorem merged_readout_difference {p : PopulationPartition N} (w v : Weights d N r)
    (hfixed : mergedWeights (fun _ => p) v=v) (i : Fin N) :
    mergedWeights (fun _ => p) w (Sum.inr (Sum.inr i))-v (Sum.inr (Sum.inr i)) =
      populationAverage p (fun k => w (Sum.inr (Sum.inr k))-v (Sum.inr (Sum.inr k))) i := by
  have hf := congrFun hfixed (Sum.inr (Sum.inr i))
  rw [← hf]
  simp only [mergedWeights,populationAverage,mul_sub,Finset.sum_sub_distrib]

def mergedPerturbation (p : PopulationPartition N) (R : Fin r → Fin N → Fin N → ℝ)
    (s : Fin r) : Matrix (Fin N) (Fin N) ℝ :=
  Matrix.of (populationProjection p)*Matrix.of (R s)*Matrix.of (populationProjection p)

theorem mergedPerturbation_squaredSum_le (p : PopulationPartition N)
    (R : Fin r → Fin N → Fin N → ℝ) (s : Fin r) :
    (∑ i,∑ j,mergedPerturbation p R s i j^2) ≤ ∑ i,∑ j,R s i j^2 :=
  (projection_right_squaredSum_le p (Matrix.of (populationProjection p)*Matrix.of (R s))).trans
    (projection_left_squaredSum_le p (Matrix.of (R s)))

theorem merged_internal_decomposition (p : PopulationPartition N) (w v : Weights d N r)
    (R E : Fin r → Fin N → Fin N → ℝ)
    (hfixed : mergedWeights (fun _ => p) v=v)
    (hdecomp : ∀ s i j,w (Sum.inr (Sum.inl (s,i,j)))=
      v (Sum.inr (Sum.inl (s,i,j)))+R s i j+E s i j)
    (hkill : ∀ s,Matrix.of (E s)*Matrix.of (populationProjection p)=0)
    (s : Fin r) (i j : Fin N) :
    mergedWeights (fun _ => p) w (Sum.inr (Sum.inl (s,i,j)))=
      v (Sum.inr (Sum.inl (s,i,j)))+mergedPerturbation p R s i j+0 := by
  have hm : internalMatrix w s=internalMatrix v s+Matrix.of (R s)+Matrix.of (E s) := by
    ext i j
    exact hdecomp s i j
  have hv : Matrix.of (populationProjection p)*internalMatrix v s*
      Matrix.of (populationProjection p)=internalMatrix v s := by
    have h := merged_internalMatrix (fun _ => p) v s
    rw [hfixed] at h
    exact h.symm
  have he : internalMatrix (mergedWeights (fun _ => p) w) s =
      internalMatrix v s+mergedPerturbation p R s := by
    rw [merged_internalMatrix,hm]
    simp only [Matrix.mul_add,Matrix.add_mul]
    rw [hv,Matrix.mul_assoc _ (Matrix.of (E s)),hkill,Matrix.mul_zero,add_zero]
    rfl
  simpa only [internalMatrix, Matrix.of_apply, Matrix.add_apply, add_zero] using congrFun (congrFun he i) j

theorem merged_cylinder_output_sq (hN : 0 < N) {φ : ℝ → ℝ}
    (hφ : LipschitzZero φ) (p : PopulationPartition N) (w v : Weights d N r)
    (R E : Fin r → Fin N → Fin N → ℝ) {K G B ρ : ℝ}
    (hK : 0 ≤ K) (hG : 0 ≤ G) (hρ : 0 ≤ ρ) (hρ1 : ρ ≤ 1)
    (hfixed : mergedWeights (fun _ => p) v=v)
    (hdecomp : ∀ s i j,w (Sum.inr (Sum.inl (s,i,j)))=
      v (Sum.inr (Sum.inl (s,i,j)))+R s i j+E s i j)
    (hkill : ∀ s,Matrix.of (E s)*Matrix.of (populationProjection p)=0)
    (hv : weightedSquaredNorm v ≤ K)
    (hR : ∀ s,(∑ i,∑ j,R s i j^2) ≤ ρ^2*G)
    (hfirst : ∀ i j,|w (Sum.inl (i,j))-v (Sum.inl (i,j))| ≤ ρ)
    (hread : ∀ i,|w (Sum.inr (Sum.inr i))-v (Sum.inr (Sum.inr i))| ≤ ρ/N)
    (hbounded : ∀ (x : Cube d) (ss : List (Fin r)) i,
      |ss.foldl (hiddenStep φ v) (firstHidden φ v x) i| ≤ 1)
    (x : Cube d) :
    (networkOutput φ (mergedWeights (fun _ => p) w) x-networkOutput φ v x)^2 ≤
      ρ^2*unboundedCylinderOutputFactor d r K G B := by
  apply unbounded_cylinder_output_sq hN hφ (mergedWeights (fun _ => p) w) v
    (fun s i j => mergedPerturbation p R s i j) (fun _ _ _ => 0)
    hK hG hρ hρ1 (merged_internal_decomposition p w v R E hfixed hdecomp hkill) hv
  · intro s
    exact (mergedPerturbation_squaredSum_le p R s).trans (hR s)
  · intro s z
    simp only [zero_mul,Finset.sum_const_zero,zero_pow (by omega : 2≠0)]
    positivity
  · intro i j
    rw [merged_first_difference w v hfixed]
    exact populationAverage_abs_le p _ ρ (fun k => hfirst k j) i
  · intro i
    rw [merged_readout_difference w v hfixed]
    exact populationAverage_abs_le p _ (ρ/N) hread i
  · exact hbounded
  · intro x ss s i
    simp

end NeuralGeneralization.BatchTwoMerging
