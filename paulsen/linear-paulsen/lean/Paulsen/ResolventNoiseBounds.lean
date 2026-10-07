import Paulsen.ResolventNormalCovariance

namespace Paulsen.Resolvent
open Matrix
open scoped BigOperators
noncomputable section

theorem modeSum_pullback {n d : ℕ} (U : Frame n d) (w : ℝ→ℝ) :
    (normalizedNormalMapMatrix U).transpose*modeSum U w*normalizedNormalMapMatrix U=
      ∑ i ∈ highNormalizedModes U 0,
        (w (normalizedFisherEigenvalue U i)*normalizedFisherEigenvalue U i) • fisherDirectionOuter U i := by
  simp only [modeSum,Matrix.mul_sum,Matrix.sum_mul,Matrix.mul_smul,Matrix.smul_mul]
  apply Finset.sum_congr rfl
  intro i hi
  rw [normalDirectionOuter_pullback U i (Finset.mem_filter.mp hi).2,smul_smul]

theorem kernel_normalized_pullback {n d : ℕ} {U : Frame n d} (hU : IsParseval U) :
    (normalizedNormalMapMatrix U).transpose*retainedHorizontalProjection U 0*
      normalizedNormalMapMatrix U=0 := by
  have he : (normalizedNormalMapMatrix U).transpose*retainedHorizontalProjection U 0*
      normalizedNormalMapMatrix U=lowFisherCovariance U 0 := by
    rw [retainedHorizontalProjection,Matrix.mul_sub,Matrix.sub_mul]
    have hh : (normalizedNormalMapMatrix U).transpose*horizontalProjectionMatrix U*
        normalizedNormalMapMatrix U=normalizedFisher U := by
      rw [Matrix.mul_assoc,horizontalProjectionMatrix_normalizedNormalMap hU]
      rfl
    rw [hh]
    have h := normalizedTruncation_covariance U (le_refl (0:ℝ))
    simpa only [Matrix.mul_sub,Matrix.sub_mul,Matrix.mul_one,normalizedFisher] using h
  rw [he]
  apply Finset.sum_eq_zero
  intro i hi
  have hz : normalizedFisherEigenvalue U i=0 := le_antisymm (Finset.mem_filter.mp hi).2
    (normalizedFisherEigenvalue_nonneg U i)
  simp only [hz,zero_smul]

theorem covariance_normalized_pullback {n d : ℕ} {U : Frame n d} (hU : IsParseval U)
    (ρ : ℝ) :
    (normalizedNormalMapMatrix U).transpose*covariance U ρ*normalizedNormalMapMatrix U=
      ∑ i ∈ highNormalizedModes U 0,
        (retainedWeight ρ (normalizedFisherEigenvalue U i)*normalizedFisherEigenvalue U i) •
          fisherDirectionOuter U i := by
  rw [covariance,Matrix.mul_add,Matrix.add_mul,kernel_normalized_pullback hU,zero_add,modeSum_pullback]

theorem retainedWeight_mul_le {ρ μ : ℝ} (hρ : 0 ≤ ρ) (hμ : 0 ≤ μ) :
    retainedWeight ρ μ * μ ≤ ρ := by
  by_cases hz : ρ + μ = 0
  · simp only [retainedWeight, hz, div_zero, zero_mul]; exact hρ
  · have hd : 0 < ρ + μ := lt_of_le_of_ne (add_nonneg hρ hμ) (Ne.symm hz)
    rw [retainedWeight, div_mul_eq_mul_div]
    apply (div_le_iff₀ hd).mpr
    nlinarith only [sq_nonneg ρ]

theorem covariance_normalized_le {n d : ℕ} {U : Frame n d} (hU : IsParseval U)
    {ρ : ℝ} (hρ : 0≤ρ) :
    (ρ • (1:Matrix (Fin n) (Fin n) ℝ)-
      (normalizedNormalMapMatrix U).transpose*covariance U ρ*normalizedNormalMapMatrix U).PosSemidef := by
  rw [covariance_normalized_pullback hU]
  have he : ρ • (1:Matrix (Fin n) (Fin n) ℝ)-
      (∑ i ∈ highNormalizedModes U 0,
        (retainedWeight ρ (normalizedFisherEigenvalue U i)*normalizedFisherEigenvalue U i) •
          fisherDirectionOuter U i)=
      (∑ i ∈ highNormalizedModes U 0,
        (ρ-retainedWeight ρ (normalizedFisherEigenvalue U i)*normalizedFisherEigenvalue U i) •
          fisherDirectionOuter U i)+
        ∑ i ∈ (highNormalizedModes U 0)ᶜ, ρ • fisherDirectionOuter U i := by
    rw [←sum_fisherDirectionOuter U,Finset.smul_sum,
      ←Finset.sum_add_sum_compl (highNormalizedModes U 0) (fun i=>ρ • fisherDirectionOuter U i)]
    simp only [sub_smul,Finset.sum_sub_distrib]
    abel
  rw [he]
  apply Matrix.PosSemidef.add
  · apply Matrix.posSemidef_sum
    intro i hi
    exact (fisherDirectionOuter_posSemidef U i).smul
      (sub_nonneg.mpr (retainedWeight_mul_le hρ (normalizedFisherEigenvalue_nonneg U i)))
  · exact Matrix.posSemidef_sum _ (fun i hi=>(fisherDirectionOuter_posSemidef U i).smul hρ)

theorem normal_covariance_le {n d : ℕ} {U : Frame n d} (hU : IsParseval U)
    (hp : ∀ i, 0<rowNormSq U i) {ρ : ℝ} (hρ : 0≤ρ) :
    (ρ • Matrix.diagonal (rowNormSq U)-
      (normalMapMatrix U).transpose*covariance U ρ*normalMapMatrix U).PosSemidef := by
  have h := (covariance_normalized_le hU hρ).mul_mul_conjTranspose_same (leverageRoot U)
  have he : (normalMapMatrix U).transpose*covariance U ρ*normalMapMatrix U=
      leverageRoot U*((normalizedNormalMapMatrix U).transpose*covariance U ρ*
        normalizedNormalMapMatrix U)*leverageRoot U := by
    conv_lhs => rw [←normalizedNormalMap_mul_leverageRoot U hp]
    simp only [Matrix.transpose_mul,leverageRoot_transpose,Matrix.mul_assoc]
  rw [he]
  simpa only [Matrix.conjTranspose_eq_transpose_of_trivial,leverageRoot_transpose,
    Matrix.mul_sub,Matrix.sub_mul,Matrix.mul_smul,Matrix.smul_mul,Matrix.mul_one,
    leverageRoot_mul_self] using h

theorem normal_noise_covariance_diagonal_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i, 0<rowNormSq U i) {ρ : ℝ} (hρ : 0≤ρ) (i : Fin n) :
    ((normalMapMatrix U).transpose*
      (normalizedTangentNoiseFactor U ρ*(normalizedTangentNoiseFactor U ρ).transpose)*
        normalMapMatrix U) i i≤ρ*rowNormSq U i/(n:ℝ) := by
  rw [normalizedTangentNoiseFactor_covariance hU hρ,Matrix.mul_smul,Matrix.smul_mul]
  have hh := (normal_covariance_le hU hp hρ).diag_nonneg (i:=i)
  simp only [Matrix.sub_apply,Matrix.smul_apply,smul_eq_mul,Matrix.diagonal_apply_eq] at hh
  change (1/(n:ℝ))*_≤_
  calc
    _ ≤ (1/(n:ℝ))*(ρ*rowNormSq U i) := mul_le_mul_of_nonneg_left (by linarith) (by positivity)
    _ = _ := by ring

def tangentNoiseRowCovariance {n d : ℕ} (U : Frame n d) (ρ : ℝ) (i : Fin n) :
    Matrix (Fin d) (Fin d) ℝ :=
  (normalizedTangentNoiseFactor U ρ*(normalizedTangentNoiseFactor U ρ).transpose).submatrix
    (fun a=>(i,a)) (fun a=>(i,a))

theorem tangentNoiseRowCovariance_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) {ρ : ℝ} (hρ : 0≤ρ) (i : Fin n) :
    ((1/(n:ℝ)) • (1:Matrix (Fin d) (Fin d) ℝ)-tangentNoiseRowCovariance U ρ i).PosSemidef := by
  have hh := ((covariance_le_one hU hρ).smul (show 0≤1/(n:ℝ) by positivity)).submatrix (fun a=>(i,a))
  convert hh using 1
  ext a b
  simp only [tangentNoiseRowCovariance,normalizedTangentNoiseFactor_covariance hU hρ,
    Matrix.submatrix_apply,Matrix.smul_apply,Matrix.sub_apply,smul_eq_mul,Matrix.one_apply]
  simp only [Prod.mk.injEq,true_and]
  ring

theorem tangentNoiseRowCovariance_trace_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) {ρ : ℝ} (hρ : 0≤ρ) (i : Fin n) :
    (tangentNoiseRowCovariance U ρ i).trace≤(d:ℝ)/n := by
  have ht := (tangentNoiseRowCovariance_le hU hρ i).trace_nonneg
  simp only [Matrix.trace_sub,Matrix.trace_smul,Matrix.trace_one,Fintype.card_fin,smul_eq_mul] at ht
  calc
    _ ≤ 1/(n:ℝ)*(d:ℝ) := sub_nonneg.mp ht
    _ = _ := by ring

end
end Paulsen.Resolvent
