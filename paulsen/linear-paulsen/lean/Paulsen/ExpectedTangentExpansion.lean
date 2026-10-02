import Paulsen.TangentCovarianceGraph

/-! Expected expansion of the actual retained tangent Gaussian. -/

open Matrix MeasureTheory ProbabilityTheory
open scoped BigOperators
noncomputable section
namespace Paulsen

theorem graphEnergy_congr_offDiagonal {n : ℕ} (W V : Frame n n)
    (hWV : ∀ i j, i≠j → W i j=V i j) (x : Fin n → ℝ) :
    graphEnergy W x = graphEnergy V x := by
  unfold graphEnergy
  congr 1
  apply Finset.sum_congr rfl
  intro i _
  apply Finset.sum_congr rfl
  intro j _
  by_cases hij : i=j
  · subst j
    simp
  · rw [hWV i j hij]

theorem graphEnergy_constant_one_meanZero {n : ℕ} (x : Fin n → ℝ) (hx : ∑ i, x i=0) :
    graphEnergy (Matrix.of fun _ _ : Fin n => (1:ℝ)) x = (n:ℝ)*vectorNormSq x := by
  have he : (∑ i, ∑ j, (x i-x j)^2) = 2*(n:ℝ)*vectorNormSq x := by
    calc
      _ = ∑ i, ∑ j, (x i^2+x j^2-2*x i*x j) := by
        apply Finset.sum_congr rfl
        intro i _
        apply Finset.sum_congr rfl
        intro j _
        ring
      _ = _ := by
        simp only [Finset.sum_sub_distrib, Finset.sum_add_distrib, Finset.sum_const,
          Finset.card_univ, Fintype.card_fin, nsmul_eq_mul, ← Finset.mul_sum, hx, mul_zero,
          sub_zero, vectorNormSq]
        ring
  simp only [graphEnergy, Matrix.of_apply, one_mul, he]
  ring

theorem graphEnergy_sub_eq {n : ℕ} (W V : Frame n n) (x : Fin n → ℝ) :
    graphEnergy (W-V) x = graphEnergy W x - graphEnergy V x := by
  simp only [graphEnergy, Matrix.sub_apply, sub_mul, Finset.sum_sub_distrib]
  ring

theorem unconditionedTangent_graphEnergy_formula {n d : ℕ} (U : Frame n d) (x : Fin n → ℝ) :
    (1/(n:ℝ))*tangentCovarianceGraph U x (horizontalProjectionMatrix U) =
      graphEnergy (Matrix.of fun i j =>
        (rowNormSq U i+rowNormSq U j-2*rowNormSq U i*rowNormSq U j-
          2*(frameProjection U i j)^2)/(n:ℝ)) x := by
  rw [tangentCovarianceGraph_eq, ← graphEnergy_smul_eq]
  apply graphEnergy_congr_offDiagonal
  intro i j hij
  exact unconditionedTangent_entry_variance_offDiagonal U i j hij

theorem unconditionedTangent_graphEnergy_lower {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hn : 0<n) {a : ℝ} (_ha : 0<a) (hahalf : a≤1/2)
    (hrows : ∀ i, a/2≤rowNormSq U i ∧ rowNormSq U i≤3*a/2)
    (x : Fin n → ℝ) (hx : ∑ i, x i=0) :
    (a/4)*vectorNormSq x - (2/(n:ℝ))*matrixQuadratic (projectionLaplacian (frameProjection U)) x ≤
      (1/(n:ℝ))*tangentCovarianceGraph U x (horizontalProjectionMatrix U) := by
  have hn' : (0:ℝ)<n := Nat.cast_pos.mpr hn
  have hp (i : Fin n) : rowNormSq U i≤3/4 := by nlinarith [(hrows i).2]
  have hscalar (i j : Fin n) :
      a/4≤rowNormSq U i+rowNormSq U j-2*rowNormSq U i*rowNormSq U j := by
    have h₁ := mul_nonneg (rowNormSq_nonneg U i) (sub_nonneg.mpr (hp j))
    have h₂ := mul_nonneg (rowNormSq_nonneg U j) (sub_nonneg.mpr (hp i))
    nlinarith [(hrows i).1, (hrows j).1]
  have hentry (i j : Fin n) :
      a/(4*(n:ℝ))-(2/(n:ℝ))*(frameProjection U i j)^2 ≤
        (rowNormSq U i+rowNormSq U j-2*rowNormSq U i*rowNormSq U j-
          2*(frameProjection U i j)^2)/(n:ℝ) := by
    have hh := (div_le_div_of_nonneg_right (hscalar i j) hn'.le)
    calc
      _ = (a/4)/(n:ℝ)-(2/(n:ℝ))*(frameProjection U i j)^2 := by ring
      _ ≤ (rowNormSq U i+rowNormSq U j-2*rowNormSq U i*rowNormSq U j)/(n:ℝ) -
          (2/(n:ℝ))*(frameProjection U i j)^2 := sub_le_sub_right hh _
      _ = _ := by ring
  have hgraph := graphEnergy_pointwise_le
    ((a/(4*(n:ℝ))) • (Matrix.of fun _ _ : Fin n => (1:ℝ)) -
      (2/(n:ℝ)) • squaredFrameProjection U)
    (Matrix.of fun i j => (rowNormSq U i+rowNormSq U j-2*rowNormSq U i*rowNormSq U j-
      2*(frameProjection U i j)^2)/(n:ℝ)) (fun i j => by simpa only [Matrix.sub_apply, Matrix.smul_apply, Matrix.of_apply,
        smul_eq_mul, mul_one, squaredFrameProjection] using hentry i j) x
  rw [graphEnergy_sub_eq, graphEnergy_smul_eq, graphEnergy_smul_eq,
    graphEnergy_constant_one_meanZero x hx, ← unconditionedTangent_graphEnergy_formula] at hgraph
  have he : graphEnergy (squaredFrameProjection U) x =
      matrixQuadratic (projectionLaplacian (frameProjection U)) x := (hU.laplacian_energy x).symm
  rw [he] at hgraph
  convert hgraph using 1
  field_simp

/-- Expected graph expansion survives the actual normalized truncation. -/
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
  have ht := integral_retainedTangent_graphEnergy_lower hU hρ.le x
  nlinarith only [hu, hb, hr, ht]

end Paulsen
