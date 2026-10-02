import Paulsen.SmoothDenseCore
import Paulsen.SquaredGraphStability

/-! Deterministic assembly of the moderate seed's lower and upper graph bounds. -/

open Matrix MeasureTheory ProbabilityTheory
open scoped BigOperators
noncomputable section
namespace Paulsen.Smooth

theorem squared_graphEnergy_add_smul {n : ℕ} (P Y : Frame n n) (t : ℝ)
    (x : Fin n → ℝ) :
    graphEnergy (fun i j => (P i j+t*Y i j)^2) x =
      graphEnergy (fun i j => (P i j)^2) x+
        2*t*graphEnergy (fun i j => P i j*Y i j) x+
        t^2*graphEnergy (fun i j => (Y i j)^2) x := by
  have he : (∑ i, ∑ j, (P i j+t*Y i j)^2*(x i-x j)^2) =
      (∑ i, ∑ j, (P i j)^2*(x i-x j)^2)+
      2*t*(∑ i, ∑ j, (P i j*Y i j)*(x i-x j)^2)+
      t^2*(∑ i, ∑ j, (Y i j)^2*(x i-x j)^2) := by
    simp only [Finset.mul_sum, ← Finset.sum_add_distrib]
    apply Finset.sum_congr rfl
    intro i _
    apply Finset.sum_congr rfl
    intro j _
    ring
  simp only [graphEnergy]
  rw [he]
  ring

theorem retainedTangentEntryVariance_graph_lower {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hn : 0<n) (hd : 0<d)
    (hdensity : (d:ℝ)/(n:ℝ)≤1/2)
    (hrows : ∀ i, ((d:ℝ)/(n:ℝ))/2≤rowNormSq U i ∧
      rowNormSq U i≤3*((d:ℝ)/(n:ℝ))/2)
    {ρ : ℝ} (hρ : 0<ρ) (x : Fin n → ℝ) (hx : ∑ i, x i=0) :
    (((d:ℝ)/(n:ℝ))/4)*vectorNormSq x -
      (2/(n:ℝ)+80/(d:ℝ)+8/ρ)*matrixQuadratic (projectionLaplacian (frameProjection U)) x ≤
      graphEnergy (Matrix.of (retainedTangentEntryVariance U ρ)) x := by
  have hh := expected_retainedTangent_expansion hU hn hd hdensity hrows hρ x hx
  rw [integral_gaussianImage_graphEnergy_eq_covariance] at hh
  exact hh

/-- Expected expansion, relative linear control, and centered-square control
produce the required regularized lower bound. -/
theorem moderate_affine_seed_graph_lower {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hn : 0<n) (hd : 0<d)
    (hdensity : (d:ℝ)/(n:ℝ)≤1/2)
    (hrows : ∀ i, ((d:ℝ)/(n:ℝ))/2≤rowNormSq U i ∧
      rowNormSq U i≤3*((d:ℝ)/(n:ℝ))/2)
    {ρ t : ℝ} (hρ : 0<ρ) (Y : Frame n n)
    (hpenalty : t^2*(2/(n:ℝ)+80/(d:ℝ)+8/ρ)≤1/4)
    (x : Fin n → ℝ) (hx : ∑ i, x i=0)
    (hcross : |2*t*graphEnergy (fun i j => frameProjection U i j*Y i j) x|≤
      (1/32)*(matrixQuadratic (projectionLaplacian (frameProjection U)) x+
        ((d:ℝ)/(n:ℝ))*t^2*vectorNormSq x))
    (hcenter : |graphEnergy (fun i j => (Y i j)^2) x-
      graphEnergy (Matrix.of (retainedTangentEntryVariance U ρ)) x|≤
      (((d:ℝ)/(n:ℝ))/32)*vectorNormSq x) :
    (1/8)*(matrixQuadratic (projectionLaplacian (frameProjection U)) x+
      ((d:ℝ)/(n:ℝ))*t^2*vectorNormSq x) ≤
      graphEnergy (fun i j => (frameProjection U i j+t*Y i j)^2) x := by
  have hmean := retainedTangentEntryVariance_graph_lower hU hn hd hdensity hrows hρ x hx
  have hL : 0≤matrixQuadratic (projectionLaplacian (frameProjection U)) x := by
    rw [hU.laplacian_energy]
    exact mul_nonneg (by norm_num) (Finset.sum_nonneg fun i _ =>
      Finset.sum_nonneg fun j _ => mul_nonneg (sq_nonneg _) (sq_nonneg _))
  have hN : 0≤((d:ℝ)/(n:ℝ))*t^2*vectorNormSq x :=
    mul_nonneg (by positivity) (vectorNormSq_nonneg x)
  have hm := mul_le_mul_of_nonneg_left hmean (sq_nonneg t)
  have hc := mul_le_mul_of_nonneg_left (neg_le_of_abs_le hcenter) (sq_nonneg t)
  have hx' := neg_le_of_abs_le hcross
  have hp := mul_le_mul_of_nonneg_right hpenalty hL
  have he : graphEnergy (fun i j => (frameProjection U i j)^2) x =
      matrixQuadratic (projectionLaplacian (frameProjection U)) x := (hU.laplacian_energy x).symm
  rw [squared_graphEnergy_add_smul, he]
  nlinarith only [hm, hc, hx', hp, hL, hN]

theorem moderate_affine_seed_graph_upper {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (Y : Frame n n) (hsym : ∀ i j, Y i j=Y j i)
    (hrow : ∀ i, rowNormSq Y i≤2000*((d:ℝ)/(n:ℝ))) (t : ℝ) (x : Fin n → ℝ) :
    graphEnergy (fun i j => (frameProjection U i j+t*Y i j)^2) x ≤
      8000*(matrixQuadratic (projectionLaplacian (frameProjection U)) x+
        ((d:ℝ)/(n:ℝ))*t^2*vectorNormSq x) := by
  have ht := squared_graphEnergy_triangle (frameProjection U+t • Y) (frameProjection U) x
  have he : graphEnergy (fun i j => ((frameProjection U+t • Y) i j-frameProjection U i j)^2) x =
      t^2*graphEnergy (fun i j => (Y i j)^2) x := by
    simp only [Matrix.add_apply, Matrix.smul_apply, smul_eq_mul, add_sub_cancel_left,
      mul_pow, graphEnergy, mul_assoc, ← Finset.mul_sum]
    ring
  have hEl : graphEnergy (fun i j => (frameProjection U i j)^2) x =
      matrixQuadratic (projectionLaplacian (frameProjection U)) x := (hU.laplacian_energy x).symm
  rw [he, hEl] at ht
  have hY := mul_le_mul_of_nonneg_left
    (squared_graphEnergy_le_of_row_bounds Y _ hsym hrow x) (sq_nonneg t)
  have hL : 0≤matrixQuadratic (projectionLaplacian (frameProjection U)) x := by
    rw [hU.laplacian_energy]
    exact mul_nonneg (by norm_num) (Finset.sum_nonneg fun i _ =>
      Finset.sum_nonneg fun j _ => mul_nonneg (sq_nonneg _) (sq_nonneg _))
  change graphEnergy (fun i j => (frameProjection U i j+t*Y i j)^2) x≤_ at ht
  nlinarith only [ht, hY, hL]

end Paulsen.Smooth
