import Paulsen.SmoothResidualVariance
import Paulsen.SmoothTangentFactor
import Paulsen.ExpectedTangentExpansion

namespace Paulsen.Smooth
open Matrix MeasureTheory ProbabilityTheory
open scoped BigOperators
noncomputable section

theorem positiveResidualEntryLoss_graphEnergy_eq {n d : ℕ} (U : Frame n d)
    (ρ : ℝ) (x : Fin n → ℝ) :
    graphEnergy (Matrix.of (positiveResidualEntryLoss U ρ)) x = (1/(n:ℝ))*
      ∑ j ∈ highNormalizedModes U 0, (residualWeight (max 0 ρ) (normalizedFisherEigenvalue U j))*
        graphEnergy (Matrix.of fun i k => (normalTangentFrame U j i k)^2) x := by
  have he : Matrix.of (positiveResidualEntryLoss U ρ) = (1/(n:ℝ)) •
      ∑ j ∈ highNormalizedModes U 0, (residualWeight (max 0 ρ) (normalizedFisherEigenvalue U j)) •
        Matrix.of (fun i k => (normalTangentFrame U j i k)^2) := by
    ext i k
    simp only [Matrix.of_apply, positiveResidualEntryLoss_formula, Matrix.smul_apply,
      Matrix.sum_apply, smul_eq_mul]
  rw [he, graphEnergy_smul_eq, graphEnergy_finset_sum_eq]
  simp only [graphEnergy_smul_eq]

theorem positiveResidualEntryLoss_graphEnergy_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) {p ρ : ℝ} (hp : 0<p) (hrows : ∀ i,p≤rowNormSq U i)
    (hρ : 0<ρ) (x : Fin n→ℝ) :
    graphEnergy (Matrix.of (positiveResidualEntryLoss U ρ)) x≤
      (4*(d:ℝ)/((n:ℝ)*p*ρ))*matrixQuadratic (projectionLaplacian (frameProjection U)) x := by
  let L:=matrixQuadratic (projectionLaplacian (frameProjection U)) x
  have hL : 0≤L := by dsimp only [L]; rw [←ambientNormal_norm_sq hU]; positivity
  have hpos (i : Fin n) : 0<rowNormSq U i:=hp.trans_le (hrows i)
  rw [positiveResidualEntryLoss_graphEnergy_eq,max_eq_right hρ.le]
  calc
    _ ≤ (1/(n:ℝ))*∑ j ∈ highNormalizedModes U 0,
        (1-normalizedFisherEigenvalue U j)*((4/(p*ρ))*L) := by
      apply mul_le_mul_of_nonneg_left _ (by positivity)
      apply Finset.sum_le_sum
      intro j hj
      have hμ:0<normalizedFisherEigenvalue U j:=(Finset.mem_filter.mp hj).2
      have hμ1:=normalizedFisherEigenvalue_le_one hU hpos j
      have hw:=residualWeight_nonneg hρ.le hμ.le hμ1
      have hg:=normalTangentFrame_graphEnergy_le hU j hμ x
        (inv_nonneg.mpr (Real.sqrt_nonneg p))
        (fun i=>normalizedNormalPotential_abs_le U j i hp (hrows i))
      rw [inv_pow,Real.sq_sqrt hp.le] at hg
      have hh:=residualWeight_div_le hρ hμ.le hμ1
      calc
        _ ≤ residualWeight ρ (normalizedFisherEigenvalue U j)*
            ((4*p⁻¹/normalizedFisherEigenvalue U j)*L) := mul_le_mul_of_nonneg_left hg hw
        _ = (residualWeight ρ (normalizedFisherEigenvalue U j)/normalizedFisherEigenvalue U j)*
            (4*p⁻¹*L) := by ring
        _ ≤ ((1-normalizedFisherEigenvalue U j)/ρ)*(4*p⁻¹*L) :=
          mul_le_mul_of_nonneg_right hh (by positivity)
        _ = _ := by ring
    _ ≤ (1/(n:ℝ))*∑ j, (1-normalizedFisherEigenvalue U j)*((4/(p*ρ))*L) := by
      apply mul_le_mul_of_nonneg_left _ (by positivity)
      exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
        (fun j _ _=>mul_nonneg (sub_nonneg.mpr (normalizedFisherEigenvalue_le_one hU hpos j)) (by positivity))
    _ = _ := by rw [←Finset.sum_mul,normalizedFisher_deficit_sum hU hpos]; ring

theorem positiveResidualEntryLoss_graphEnergy_le_average {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hn : 0<n) (hd : 0<d)
    (hrows : ∀ i,(d:ℝ)/(2*(n:ℝ))≤rowNormSq U i) {ρ : ℝ} (hρ : 0<ρ) (x : Fin n→ℝ) :
    graphEnergy (Matrix.of (positiveResidualEntryLoss U ρ)) x≤
      (8/ρ)*matrixQuadratic (projectionLaplacian (frameProjection U)) x := by
  have hnR:(0:ℝ)<n:=Nat.cast_pos.mpr hn
  have hdR:(0:ℝ)<d:=Nat.cast_pos.mpr hd
  have hh:=positiveResidualEntryLoss_graphEnergy_le hU
    (show (0:ℝ)<(d:ℝ)/(2*(n:ℝ)) by positivity) hrows hρ x
  convert hh using 1
  field_simp <;> ring

theorem retainedTangentFactor_covariance {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) {ρ : ℝ} (hρ : 0≤ρ) :
    retainedTangentFactor U ρ*(retainedTangentFactor U ρ).transpose=
      (1/(n:ℝ)) • (tangentLiftMatrix U*covariance U ρ*(tangentLiftMatrix U).transpose) := by
  unfold retainedTangentFactor
  rw [Matrix.transpose_mul]
  calc
    _ = tangentLiftMatrix U*(normalizedTangentNoiseFactor U ρ*
        (normalizedTangentNoiseFactor U ρ).transpose)*(tangentLiftMatrix U).transpose := by
      simp only [Matrix.mul_assoc]
    _ = _ := by rw [normalizedTangentNoiseFactor_covariance hU hρ,Matrix.mul_smul,Matrix.smul_mul]

theorem covariance_eq_horizontal_sub {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i,0<rowNormSq U i) {ρ : ℝ} (hρ : 0≤ρ) :
    covariance U ρ=horizontalProjectionMatrix U-normalizedNormalCovariance U-normalizedPositiveResidual U ρ := by
  unfold normalizedPositiveResidual
  rw [max_eq_right hρ]
  have hh:=congrArg (fun M=>horizontalProjectionMatrix U-M) (residual_decomposition hU hp hρ)
  convert hh using 1 <;> abel

theorem integral_retainedTangent_graphEnergy_eq {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) {ρ : ℝ} (hρ : 0≤ρ) (x : Fin n→ℝ) :
    (∫ g,graphEnergy (Matrix.of fun i j=>(Matrix.toEuclideanLin (retainedTangentFactor U ρ) g (i,j))^2) x
      ∂stdGaussian (FrameVector n d))=(1/(n:ℝ))*tangentCovarianceGraph U x (covariance U ρ) := by
  rw [integral_gaussianImage_graphEnergy_eq_covariance,retainedTangentFactor_covariance hU hρ,
    tangentCovarianceGraph_eq,←graphEnergy_smul_eq]
  rfl

theorem tangentCovarianceGraph_positive {n d : ℕ} (U : Frame n d) (ρ : ℝ) (x : Fin n→ℝ) :
    (1/(n:ℝ))*tangentCovarianceGraph U x (normalizedPositiveResidual U ρ)=
      graphEnergy (Matrix.of (positiveResidualEntryLoss U ρ)) x := by
  rw [tangentCovarianceGraph_eq,←graphEnergy_smul_eq]
  rfl

theorem integral_retainedTangent_graphEnergy_lower {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i,0<rowNormSq U i) {ρ : ℝ} (hρ : 0≤ρ) (x : Fin n→ℝ) :
    (1/(n:ℝ))*tangentCovarianceGraph U x (horizontalProjectionMatrix U)-
      graphEnergy (baseNormalTangentVariance U) x-graphEnergy (Matrix.of (positiveResidualEntryLoss U ρ)) x≤
    (∫ g,graphEnergy (Matrix.of fun i j=>(Matrix.toEuclideanLin (retainedTangentFactor U ρ) g (i,j))^2) x
      ∂stdGaussian (FrameVector n d)) := by
  rw [integral_retainedTangent_graphEnergy_eq hU hρ,covariance_eq_horizontal_sub hU hp hρ,
    map_sub,map_sub,←tangentCovarianceGraph_base,←tangentCovarianceGraph_positive]
  exact le_of_eq (by ring)
/-- Expected graph expansion survives the smooth normalized filter. -/
theorem expected_retainedTangent_expansion {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hn : 0<n) (hd : 0<d)
    (hdensity : (d:ℝ)/(n:ℝ)≤1/2)
    (hrows : ∀ i, ((d:ℝ)/(n:ℝ))/2≤rowNormSq U i ∧
      rowNormSq U i≤3*((d:ℝ)/(n:ℝ))/2)
    {ρ : ℝ} (hρ : 0<ρ) (x : Fin n → ℝ) (hx : ∑ i, x i=0) :
    (((d:ℝ)/(n:ℝ))/4)*vectorNormSq x -
      (2/(n:ℝ)+80/(d:ℝ)+8/ρ)*matrixQuadratic (projectionLaplacian (frameProjection U)) x ≤
    (∫ g, graphEnergy (Matrix.of fun i j =>
      (Matrix.toEuclideanLin (retainedTangentFactor U ρ) g (i,j))^2) x
      ∂stdGaussian (FrameVector n d)) := by
  have hn' : (0:ℝ)<n := Nat.cast_pos.mpr hn
  have hd' : (0:ℝ)<d := Nat.cast_pos.mpr hd
  have hu := unconditionedTangent_graphEnergy_lower hU hn (show (0:ℝ)<(d:ℝ)/(n:ℝ) by positivity)
    hdensity hrows x hx
  have hb := baseNormalTangentVariance_graphEnergy_le_average hU hn hd (fun i => (hrows i).1) x
  have hr := positiveResidualEntryLoss_graphEnergy_le_average hU hn hd
    (fun i => by convert (hrows i).1 using 1; ring) hρ x
  have ht := integral_retainedTangent_graphEnergy_lower hU
    (fun i=>(show (0:ℝ)<((d:ℝ)/(n:ℝ))/2 by positivity).trans_le (hrows i).1) hρ.le x
  nlinarith only [hu, hb, hr, ht]

end
end Paulsen.Smooth
