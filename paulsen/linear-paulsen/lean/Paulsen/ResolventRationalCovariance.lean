import Paulsen.ResolventNormalCovariance

/-! Identification of the concrete spectral Gaussian covariance with the
rational filter in the mathematical proof. The identity is stated in the
ambient matrix space; Q is the identity on horizontal tangents. -/
namespace Paulsen.Resolvent
open Matrix
open scoped BigOperators
noncomputable section

theorem covariance_resolvent_equation {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i,0<rowNormSq U i) {ρ : ℝ} (hρ : 0<ρ) :
    covariance U ρ*(ρ • 1+normalizedNormalCovariance U)=
      ρ • horizontalProjectionMatrix U := by
  have hw (i : Fin n) :
      ρ*retainedWeight ρ (normalizedFisherEigenvalue U i)+
        retainedWeight ρ (normalizedFisherEigenvalue U i)*normalizedFisherEigenvalue U i=
      ρ := by
    rw [retainedWeight_eq]
    have hd : 0<ρ+normalizedFisherEigenvalue U i :=
      add_pos_of_pos_of_nonneg hρ (normalizedFisherEigenvalue_nonneg U i)
    field_simp
  have hsum : ρ • modeSum U (retainedWeight ρ)+
      modeSum U (fun μ=>retainedWeight ρ μ*μ)=
      ρ • normalizedHighProjection U 0 := by
    rw [←modeSum_one]
    simp only [modeSum,Finset.smul_sum,smul_smul,←Finset.sum_add_distrib,←Finset.sum_sub_distrib]
    apply Finset.sum_congr rfl
    intro i hi
    rw [←add_smul]
    congr 1
    simpa only [id_eq,mul_sub,mul_one] using hw i
  have hCB : covariance U ρ*normalizedNormalCovariance U=
      modeSum U (fun μ=>retainedWeight ρ μ*μ) := by
    rw [←modeSum_identity,covariance,Matrix.add_mul,kernel_modeSum hU,modeSum_mul,zero_add]
    rfl
  rw [Matrix.mul_add,Matrix.mul_smul,Matrix.mul_one,hCB,covariance,smul_add]
  rw [show ρ • retainedHorizontalProjection U 0+ρ • modeSum U (retainedWeight ρ)+
      modeSum U (fun μ=>retainedWeight ρ μ*μ)=
      ρ • retainedHorizontalProjection U 0+
        (ρ • modeSum U (retainedWeight ρ)+modeSum U (fun μ=>retainedWeight ρ μ*μ)) by abel]
  rw [hsum,retainedHorizontalProjection,smul_sub]
  abel


/-- The inverse formula for the covariance. Restricted to the horizontal
subspace, Q is its identity and B is the normalized normal covariance. -/
theorem covariance_rational_formula {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i,0<rowNormSq U i) {ρ : ℝ} (hρ : 0<ρ) :
    covariance U ρ=ρ • (horizontalProjectionMatrix U*
      (ρ • 1+normalizedNormalCovariance U)⁻¹) := by
  have hB : (normalizedNormalCovariance U).PosSemidef := by
    rw [normalizedNormalCovariance_decomposition]
    exact Matrix.posSemidef_sum _ (fun i hi=>(normalDirectionOuter_posSemidef U i).smul
      (normalizedFisherEigenvalue_nonneg U i))
  have hD : (ρ • 1+normalizedNormalCovariance U).PosDef :=
    (Matrix.PosDef.one.smul hρ).add_posSemidef hB
  have hunit : IsUnit (ρ • 1+normalizedNormalCovariance U).det :=
    isUnit_iff_ne_zero.mpr hD.det_pos.ne'
  have he:=congrArg (fun M=>M*(ρ • 1+normalizedNormalCovariance U)⁻¹)
    (covariance_resolvent_equation hU hp hρ)
  simpa only [Matrix.mul_assoc,Matrix.mul_nonsing_inv _ hunit,Matrix.mul_one,Matrix.smul_mul] using he

end
end Paulsen.Resolvent
