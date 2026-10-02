import Paulsen.SmoothNoiseBounds
import Paulsen.ModerateMean
import Paulsen.ConditionedSeedBounds

namespace Paulsen.Smooth
open Matrix MeasureTheory ProbabilityTheory
open scoped BigOperators
noncomputable section

def normalResidualDiagonal {n d : ℕ} (U : Frame n d) (ρ : ℝ) (i : Fin n) : ℝ :=
  (1/(n:ℝ))*∑ j ∈ highNormalizedModes U 0,
    residualWeight ρ (normalizedFisherEigenvalue U j)*
      horizontalQuadraticDiagonal U (normalizedNormalFrame U j) i

theorem residual_inverse_sqrt_sum_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i,0<rowNormSq U i) {ρ : ℝ} (hρ : 0<ρ) :
    (∑ j ∈ highNormalizedModes U 0,
      residualWeight ρ (normalizedFisherEigenvalue U j)/Real.sqrt (normalizedFisherEigenvalue U j))≤
        (d:ℝ)/(2*Real.sqrt ρ) := by
  calc
    _ ≤ ∑ j ∈ highNormalizedModes U 0, (1-normalizedFisherEigenvalue U j)/(2*Real.sqrt ρ) :=
      Finset.sum_le_sum (fun j hj=>residualWeight_div_sqrt_le hρ
        (normalizedFisherEigenvalue_nonneg U j) (normalizedFisherEigenvalue_le_one hU hp j))
    _ ≤ ∑ j, (1-normalizedFisherEigenvalue U j)/(2*Real.sqrt ρ) :=
      Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
        (fun j _ _=>div_nonneg (sub_nonneg.mpr (normalizedFisherEigenvalue_le_one hU hp j)) (by positivity))
    _ = _ := by rw [←Finset.sum_div,normalizedFisher_deficit_sum hU hp]

theorem normalResidualDiagonal_pairing_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i,0<rowNormSq U i)
    {ρ M : ℝ} (hρ : 0<ρ) (hM : 0≤M)
    (hf : ∀ j i, |normalizedNormalPotential U j i|≤M) (x : Fin n→ℝ) :
    |∑ i, x i*normalResidualDiagonal U ρ i|≤
      ((d:ℝ)*M/((n:ℝ)*Real.sqrt ρ))*
        Real.sqrt (matrixQuadratic (projectionLaplacian (frameProjection U)) x) := by
  let E:=Real.sqrt (matrixQuadratic (projectionLaplacian (frameProjection U)) x)
  let q:=fun j=>∑ i, x i*horizontalQuadraticDiagonal U (normalizedNormalFrame U j) i
  have he : (∑ i,x i*normalResidualDiagonal U ρ i)=
      (1/(n:ℝ))*∑ j ∈ highNormalizedModes U 0,
        residualWeight ρ (normalizedFisherEigenvalue U j)*q j := by
    unfold normalResidualDiagonal q
    simp only [Finset.mul_sum]
    rw [Finset.sum_comm]
    apply Finset.sum_congr rfl
    intro j hj
    apply Finset.sum_congr rfl
    intro i hi
    ring
  rw [he,abs_mul,abs_of_nonneg (show 0≤1/(n:ℝ) by positivity)]
  calc
    _ ≤ (1/(n:ℝ))*∑ j ∈ highNormalizedModes U 0,
        |residualWeight ρ (normalizedFisherEigenvalue U j)*q j| := by
      gcongr
      exact Finset.abs_sum_le_sum_abs _ _
    _ ≤ (1/(n:ℝ))*∑ j ∈ highNormalizedModes U 0,
        (residualWeight ρ (normalizedFisherEigenvalue U j)/
          Real.sqrt (normalizedFisherEigenvalue U j))*(2*M*E) := by
      apply mul_le_mul_of_nonneg_left _ (by positivity)
      apply Finset.sum_le_sum
      intro j hj
      have hw := residualWeight_nonneg hρ.le (normalizedFisherEigenvalue_nonneg U j)
        (normalizedFisherEigenvalue_le_one hU hp j)
      have hq := normalizedNormalFrame_quadratic_pairing_le hU j (Finset.mem_filter.mp hj).2 x hM (hf j)
      rw [abs_mul,abs_of_nonneg hw]
      have hh := mul_le_mul_of_nonneg_left hq hw
      convert hh using 1 <;> dsimp only [q,E] <;> ring
    _ = (1/(n:ℝ))*(∑ j ∈ highNormalizedModes U 0,
        residualWeight ρ (normalizedFisherEigenvalue U j)/
          Real.sqrt (normalizedFisherEigenvalue U j))*(2*M*E) := by rw [←Finset.sum_mul]; ring
    _ ≤ (1/(n:ℝ))*((d:ℝ)/(2*Real.sqrt ρ))*(2*M*E) := by
      gcongr
      exact residual_inverse_sqrt_sum_le hU hp hρ
    _ = _ := by dsimp only [E]; field_simp <;> ring

theorem normalResidualDiagonal_dual_energy_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) {p ρ : ℝ} (hp : 0<p)
    (hrows : ∀ i,p≤rowNormSq U i) (hρ : 0<ρ) (x : Fin n→ℝ) :
    (∑ i,x i*normalResidualDiagonal U ρ i)^2≤
      ((d:ℝ)^2/((n:ℝ)^2*p*ρ))*matrixQuadratic (projectionLaplacian (frameProjection U)) x := by
  have hb := normalResidualDiagonal_pairing_le hU (fun i=>hp.trans_le (hrows i)) hρ
    (inv_nonneg.mpr (Real.sqrt_nonneg p))
    (fun j i=>normalizedNormalPotential_abs_le U j i hp (hrows i)) x
  have he : 0≤matrixQuadratic (projectionLaplacian (frameProjection U)) x := by
    rw [←ambientNormal_norm_sq hU]; positivity
  have hs:=pow_le_pow_left₀ (abs_nonneg _) hb 2
  simpa only [sq_abs,mul_pow,div_pow,inv_pow,Real.sq_sqrt hp.le,Real.sq_sqrt hρ.le,
    Real.sq_sqrt he,div_eq_mul_inv,mul_inv,←mul_assoc,mul_comm,mul_left_comm] using hs

theorem normalResidualDiagonal_dual_energy_le_average {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hn : 0<n) (hd : 0<d)
    (hrows : ∀ i,(d:ℝ)/(2*(n:ℝ))≤rowNormSq U i) {ρ : ℝ} (hρ : 0<ρ) (x : Fin n→ℝ) :
    (∑ i,x i*normalResidualDiagonal U ρ i)^2≤
      (2*((d:ℝ)/(n:ℝ))/ρ)*matrixQuadratic (projectionLaplacian (frameProjection U)) x := by
  have hnR : (0:ℝ)<n:=Nat.cast_pos.mpr hn
  have hdR : (0:ℝ)<d:=Nat.cast_pos.mpr hd
  have hh := normalResidualDiagonal_dual_energy_le hU
    (show (0:ℝ)<(d:ℝ)/(2*(n:ℝ)) by positivity) hrows hρ x
  convert hh using 1
  field_simp <;> ring

theorem integral_horizontalQuadraticDiagonal_normalizedTangentNoise {n d : ℕ}
    (hn : 0<n) {U : Frame n d} (hU : IsParseval U)
    (hp : ∀ i,0<rowNormSq U i) {ρ : ℝ} (hρ : 0≤ρ) (i : Fin n) :
    (∫ g,horizontalQuadraticDiagonal U
      (frameOfVector (Matrix.toEuclideanLin (normalizedTangentNoiseFactor U ρ) g)) i
      ∂stdGaussian (FrameVector n d))=
      (d:ℝ)/n-rowNormSq U i-
        (1/(n:ℝ))*(projectionLaplacian (frameProjection U)*ᵥ(fun j=>(rowNormSq U j)⁻¹)) i-
        normalResidualDiagonal U ρ i := by
  rw [integral_horizontalQuadraticDiagonal_eq_covariance,
    normalizedTangentNoiseFactor_covariance hU hρ,map_smul]
  have he : covariance U ρ=horizontalProjectionMatrix U-normalizedNormalCovariance U-
      modeSum U (residualWeight ρ) := by
    have hh := residual_decomposition hU hp hρ
    have he := congrArg (fun M=>horizontalProjectionMatrix U-M) hh
    convert he using 1 <;> abel
  rw [he,map_sub,map_sub,normalQuadraticCovariance_horizontalProjection hU]
  have hb : normalQuadraticCovariance U i (normalizedNormalCovariance U)=
      (projectionLaplacian (frameProjection U)*ᵥ(fun j=>(rowNormSq U j)⁻¹)) i := by
    rw [normalizedNormalCovariance_decomposition,map_sum]
    simpa only [map_smul,smul_eq_mul,normalQuadraticCovariance_normalDirectionOuter] using
      normalizedNormalFrame_weighted_sum hU hp i
  rw [hb]
  simp only [modeSum,map_sum,map_smul,normalQuadraticCovariance_normalDirectionOuter,smul_eq_mul,
    normalResidualDiagonal]
  field_simp [Nat.cast_ne_zero.mpr hn.ne'] <;> ring


theorem normalResidualDiagonal_sum_zero {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hn : 0<n) (hd : 0<d)
    (hrows : ∀ i,(d:ℝ)/(2*(n:ℝ))≤rowNormSq U i) {ρ : ℝ} (hρ : 0<ρ) :
    (∑ i,normalResidualDiagonal U ρ i)=0 := by
  have hh:=normalResidualDiagonal_dual_energy_le_average hU hn hd hrows hρ (fun _=>1)
  have he : matrixQuadratic (projectionLaplacian (frameProjection U)) (fun _=>1)=0 := by
    rw [hU.laplacian_energy]
    simp only [graphEnergy,sub_self,zero_pow (by decide : 2≠0),mul_zero,Finset.sum_const_zero]
  simp only [one_mul,he,mul_zero] at hh
  nlinarith [sq_nonneg (∑ i,normalResidualDiagonal U ρ i)]

theorem normalResidualDiagonal_dual_energy_budget {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hn : 0<n) (hd : 0<d)
    (hrows : ∀ i,(d:ℝ)/(2*(n:ℝ))≤rowNormSq U i) {ρ : ℝ} (hρ : 0<ρ) (x : Fin n→ℝ) :
    (∑ i,x i*normalResidualDiagonal U ρ i)^2≤
      (32*((d:ℝ)/(n:ℝ))/ρ)*matrixQuadratic (projectionLaplacian (frameProjection U)) x := by
  apply (normalResidualDiagonal_dual_energy_le_average hU hn hd hrows hρ x).trans
  apply mul_le_mul_of_nonneg_right _ (by rw [←ambientNormal_norm_sq hU]; positivity)
  have ha:0≤(d:ℝ)/(n:ℝ):=by positivity
  apply div_le_div_of_nonneg_right _ hρ.le
  nlinarith

end
end Paulsen.Smooth
