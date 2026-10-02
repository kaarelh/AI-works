import Paulsen.NormalBaseMean
import Paulsen.GaussianRowMoments

/-!
# Base normal covariance and graph energy

The two-step graph estimate controls the graph contribution of the explicit
base normal covariance, without a concentration or covariance assumption.
-/

open Matrix MeasureTheory ProbabilityTheory
open scoped BigOperators

noncomputable section

namespace Paulsen

theorem graphEnergy_mul_self_le {ι : Type*} [Fintype ι] [DecidableEq ι]
    (W : Matrix ι ι ℝ) (hW : ∀ i j, 0 ≤ W i j)
    (hsymm : ∀ i j, W i j = W j i) {pmax : ℝ}
    (hrows : ∀ i, ∑ j, W i j ≤ pmax) (x : ι → ℝ) :
    graphEnergy (W * W) x ≤ 4*pmax*graphEnergy W x := by
  let S := ∑ i, ∑ j, W i j*(x i-x j)^2
  let T₁ := ∑ i, ∑ j, ∑ k, W i k*W k j*(x i-x k)^2
  let T₂ := ∑ i, ∑ j, ∑ k, W i k*W k j*(x k-x j)^2
  have hfirst : T₁ ≤ pmax*S := by
    dsimp only [T₁, S]
    rw [Finset.mul_sum]
    apply Finset.sum_le_sum
    intro i _
    rw [Finset.sum_comm, Finset.mul_sum]
    apply Finset.sum_le_sum
    intro k _
    calc
      _ = (W i k*(x i-x k)^2)*(∑ j, W k j) := by
        rw [Finset.mul_sum]
        apply Finset.sum_congr rfl
        intro j _
        ring
      _ ≤ (W i k*(x i-x k)^2)*pmax :=
        mul_le_mul_of_nonneg_left (hrows k) (mul_nonneg (hW i k) (sq_nonneg _))
      _ = _ := by ring
  have hsecond : T₂ = T₁ := by
    dsimp only [T₁, T₂]
    rw [Finset.sum_comm]
    apply Finset.sum_congr rfl
    intro i _
    apply Finset.sum_congr rfl
    intro j _
    apply Finset.sum_congr rfl
    intro k _
    rw [hsymm j k, hsymm k i]
    ring
  have hpath : (∑ i, ∑ j, ∑ k, W i k*W k j*(x i-x j)^2) ≤ 2*T₁+2*T₂ := by
    dsimp only [T₁, T₂]
    simp only [Finset.mul_sum, ← Finset.sum_add_distrib]
    apply Finset.sum_le_sum
    intro i _
    apply Finset.sum_le_sum
    intro j _
    apply Finset.sum_le_sum
    intro k _
    have hsq : (x i-x j)^2 ≤ 2*((x i-x k)^2+(x k-x j)^2) := by
      nlinarith [sq_nonneg (x i+x j-2*x k)]
    have hh := mul_le_mul_of_nonneg_left hsq (mul_nonneg (hW i k) (hW k j))
    nlinarith only [hh]
  have hexpand : graphEnergy (W*W) x =
      (1/2:ℝ)*(∑ i, ∑ j, ∑ k, W i k*W k j*(x i-x j)^2) := by
    simp only [graphEnergy, Matrix.mul_apply, Finset.sum_mul]
  rw [hexpand, hsecond] at *
  change (1/2:ℝ)*(∑ i, ∑ j, ∑ k, W i k*W k j*(x i-x j)^2) ≤ 4*pmax*((1/2:ℝ)*S)
  nlinarith only [hpath, hfirst]

def squaredFrameProjection {n d : ℕ} (U : Frame n d) : Matrix (Fin n) (Fin n) ℝ :=
  Matrix.of fun i j => (frameProjection U i j)^2

theorem squaredFrameProjection_row_sum {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (i : Fin n) :
    (∑ j, squaredFrameProjection U i j) = rowNormSq U i :=
  hU.projection_row_squares i

theorem squaredFrameProjection_two_step_energy {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (x : Fin n → ℝ) :
    graphEnergy (squaredFrameProjection U * squaredFrameProjection U) x ≤
      4*graphEnergy (squaredFrameProjection U) x := by
  have hh := graphEnergy_mul_self_le (squaredFrameProjection U)
    (fun i j => sq_nonneg _) (fun i j => by simp [squaredFrameProjection, frameProjection_symm U i j])
    (fun i => by rw [squaredFrameProjection_row_sum hU]; exact hU.leverage_le_one i) x
  simpa only [mul_one] using hh

/-- Tangent projection change produced by one explicit base normal direction. -/
def baseNormalTangent {n d : ℕ} (U : Frame n d) (k : Fin n) : Matrix (Fin n) (Fin n) ℝ :=
  baseNormalDirection U k * U.transpose + U * (baseNormalDirection U k).transpose

/-- Numerator of the base tangent coefficient before dividing by `√pₖ`. -/
def baseNormalTangentCoefficient {n d : ℕ} (U : Frame n d) (i j k : Fin n) : ℝ :=
  frameProjection U i j * ((if i=k then 1 else 0)+(if j=k then 1 else 0)) -
    2*frameProjection U i k*frameProjection U j k

theorem baseNormalTangent_apply {n d : ℕ} (U : Frame n d) (i j k : Fin n) :
    baseNormalTangent U k i j = baseNormalTangentCoefficient U i j k /
      Real.sqrt (rowNormSq U k) := by
  have ht : (baseNormalDirection U k * U.transpose) i j =
      (U * (baseNormalDirection U k).transpose) j i := by
    simpa only [Matrix.transpose_mul, Matrix.transpose_transpose, Matrix.transpose_apply] using
      (congrArg (fun M : Matrix (Fin n) (Fin n) ℝ => M i j)
        (Matrix.transpose_mul U (baseNormalDirection U k).transpose)).symm
  rw [baseNormalTangent, Matrix.add_apply, ht, mul_baseNormalDirection_transpose,
    mul_baseNormalDirection_transpose]
  simp only [frameComplementProjection, Matrix.sub_apply, Matrix.one_apply,
    baseNormalTangentCoefficient]
  rw [frameProjection_symm U j k]
  by_cases hik : i=k <;> by_cases hjk : j=k
  all_goals subst_vars
  all_goals simp_all only [if_true, if_false, frameProjection_symm U]
  all_goals ring


theorem baseNormalTangentCoefficient_sq_le {n d : ℕ} (U : Frame n d) (i j k : Fin n) :
    (baseNormalTangentCoefficient U i j k)^2 ≤
      4*(frameProjection U i j)^2*((if i=k then 1 else 0)+(if j=k then 1 else 0)) +
        8*(frameProjection U i k)^2*(frameProjection U j k)^2 := by
  unfold baseNormalTangentCoefficient
  split_ifs
  all_goals nlinarith [sq_nonneg (frameProjection U i j +
      2*frameProjection U i k*frameProjection U j k),
    sq_nonneg (frameProjection U i j + frameProjection U i k*frameProjection U j k),
    sq_nonneg (frameProjection U i j), sq_nonneg (frameProjection U i k*frameProjection U j k)]

theorem baseNormalTangentCoefficient_sum_sq_le {n d : ℕ} (U : Frame n d) (i j : Fin n) :
    (∑ k, (baseNormalTangentCoefficient U i j k)^2) ≤
      8*((frameProjection U i j)^2 + (squaredFrameProjection U * squaredFrameProjection U) i j) := by
  have hh := Finset.sum_le_sum (fun k (_ : k ∈ Finset.univ) =>
    baseNormalTangentCoefficient_sq_le U i j k)
  apply hh.trans_eq
  simp only [Finset.sum_add_distrib, mul_add, Finset.sum_add_distrib,
    mul_ite, mul_one, mul_zero]
  simp only [Finset.sum_ite_eq, Finset.mem_univ, if_true]
  rw [Matrix.mul_apply]
  simp only [squaredFrameProjection, Matrix.of_apply, Finset.mul_sum]
  congr 1
  · ring
  · apply Finset.sum_congr rfl
    intro k _
    rw [frameProjection_symm U j k]
    ring

/-- The variance coefficient of the actual base tangent, before the `1/n`
Gaussian scaling. -/
theorem baseNormalTangent_sum_sq_le {n d : ℕ} (U : Frame n d)
    {a : ℝ} (ha : 0 < a) (hp : ∀ k, a/2 ≤ rowNormSq U k) (i j : Fin n) :
    (∑ k, (baseNormalTangent U k i j)^2) ≤
      (16/a)*((frameProjection U i j)^2 +
        (squaredFrameProjection U * squaredFrameProjection U) i j) := by
  have hpos (k : Fin n) : 0 < rowNormSq U k := (by linarith : 0<a/2).trans_le (hp k)
  calc
    _ = ∑ k, (baseNormalTangentCoefficient U i j k)^2 / rowNormSq U k := by
      apply Finset.sum_congr rfl
      intro k _
      rw [baseNormalTangent_apply, div_pow, Real.sq_sqrt (hpos k).le]
    _ ≤ ∑ k, (baseNormalTangentCoefficient U i j k)^2 / (a/2) :=
      Finset.sum_le_sum (fun k _ => div_le_div_of_nonneg_left (sq_nonneg _)
        (by positivity) (hp k))
    _ = (2/a)*(∑ k, (baseNormalTangentCoefficient U i j k)^2) := by
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro k _
      ring
    _ ≤ (2/a)*(8*((frameProjection U i j)^2 +
        (squaredFrameProjection U * squaredFrameProjection U) i j)) :=
      mul_le_mul_of_nonneg_left (baseNormalTangentCoefficient_sum_sq_le U i j) (by positivity)
    _ = _ := by ring


def baseNormalTangentVariance {n d : ℕ} (U : Frame n d) : Matrix (Fin n) (Fin n) ℝ :=
  Matrix.of fun i j => (1/(n:ℝ)) * ∑ k, (baseNormalTangent U k i j)^2

theorem baseNormalTangentVariance_apply_le {n d : ℕ} (U : Frame n d)
    {a : ℝ} (ha : 0 < a) (hp : ∀ k, a/2 ≤ rowNormSq U k) (i j : Fin n) :
    baseNormalTangentVariance U i j ≤ (16/(a*(n:ℝ)))*
      ((frameProjection U i j)^2 + (squaredFrameProjection U * squaredFrameProjection U) i j) := by
  have hh := mul_le_mul_of_nonneg_left (baseNormalTangent_sum_sq_le U ha hp i j)
    (by positivity : 0≤1/(n:ℝ))
  apply hh.trans_eq
  ring

theorem graphEnergy_pointwise_le {ι : Type*} [Fintype ι] [DecidableEq ι]
    (W V : Matrix ι ι ℝ) (hWV : ∀ i j, W i j ≤ V i j) (x : ι → ℝ) :
    graphEnergy W x ≤ graphEnergy V x := by
  apply mul_le_mul_of_nonneg_left _ (by norm_num : (0:ℝ)≤1/2)
  exact Finset.sum_le_sum fun i _ => Finset.sum_le_sum fun j _ =>
    mul_le_mul_of_nonneg_right (hWV i j) (sq_nonneg _)

theorem graphEnergy_add_eq {ι : Type*} [Fintype ι] [DecidableEq ι]
    (W V : Matrix ι ι ℝ) (x : ι → ℝ) :
    graphEnergy (W+V) x = graphEnergy W x + graphEnergy V x := by
  simp only [graphEnergy, Matrix.add_apply, add_mul, Finset.sum_add_distrib]
  ring

theorem graphEnergy_smul_eq {ι : Type*} [Fintype ι] [DecidableEq ι]
    (W : Matrix ι ι ℝ) (c : ℝ) (x : ι → ℝ) :
    graphEnergy (c • W) x = c*graphEnergy W x := by
  simp only [graphEnergy, Matrix.smul_apply, smul_eq_mul, mul_assoc, ← Finset.mul_sum]
  ring

/-- The explicit base covariance costs only `O(1/(an))` of the original graph
energy, uniformly in the number of frame rows. -/
theorem baseNormalTangentVariance_graphEnergy_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) {a : ℝ} (ha : 0 < a) (hp : ∀ k, a/2 ≤ rowNormSq U k)
    (x : Fin n → ℝ) :
    graphEnergy (baseNormalTangentVariance U) x ≤
      (80/(a*(n:ℝ)))*graphEnergy (squaredFrameProjection U) x := by
  have hh := graphEnergy_pointwise_le (baseNormalTangentVariance U)
    ((16/(a*(n:ℝ))) • (squaredFrameProjection U + squaredFrameProjection U*squaredFrameProjection U))
    (fun i j => baseNormalTangentVariance_apply_le U ha hp i j) x
  rw [graphEnergy_smul_eq, graphEnergy_add_eq] at hh
  calc
    _ ≤ (16/(a*(n:ℝ)))*(graphEnergy (squaredFrameProjection U) x +
      graphEnergy (squaredFrameProjection U*squaredFrameProjection U) x) := hh
    _ ≤ (16/(a*(n:ℝ)))*(graphEnergy (squaredFrameProjection U) x +
      4*graphEnergy (squaredFrameProjection U) x) :=
      mul_le_mul_of_nonneg_left (add_le_add le_rfl (squaredFrameProjection_two_step_energy hU x))
        (by positivity)
    _ = _ := by ring

theorem baseNormalTangentVariance_graphEnergy_le_average {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hn : 0 < n) (hd : 0 < d)
    (hp : ∀ k, ((d:ℝ)/(n:ℝ))/2 ≤ rowNormSq U k) (x : Fin n → ℝ) :
    graphEnergy (baseNormalTangentVariance U) x ≤
      (80/(d:ℝ))*matrixQuadratic (projectionLaplacian (frameProjection U)) x := by
  have hnp : (0:ℝ)<n := Nat.cast_pos.mpr hn
  have hdp : (0:ℝ)<d := Nat.cast_pos.mpr hd
  have hh := baseNormalTangentVariance_graphEnergy_le hU (show (0:ℝ)<(d:ℝ)/(n:ℝ) by positivity) hp x
  have hc : (d:ℝ)/(n:ℝ)*(n:ℝ) = d := div_mul_cancel₀ _ hnp.ne'
  have he : graphEnergy (squaredFrameProjection U) x =
      matrixQuadratic (projectionLaplacian (frameProjection U)) x := (hU.laplacian_energy x).symm
  rwa [hc, he] at hh


/-- Actual Gaussian factor for the base tangent projection change. -/
def baseNormalTangentFactor {n d : ℕ} (U : Frame n d) :
    Matrix (Fin n × Fin n) (Fin n) ℝ :=
  Matrix.of fun p k => (Real.sqrt (n:ℝ))⁻¹ * baseNormalTangent U k p.1 p.2

def baseNormalTangentGaussian {n d : ℕ} (U : Frame n d)
    (g : EuclideanSpace ℝ (Fin n)) : Matrix (Fin n) (Fin n) ℝ :=
  Matrix.of fun i j => Matrix.toEuclideanLin (baseNormalTangentFactor U) g (i,j)

def baseNormalGaussianFrame {n d : ℕ} (U : Frame n d)
    (g : EuclideanSpace ℝ (Fin n)) : Frame n d :=
  (Real.sqrt (n:ℝ))⁻¹ • ∑ k, (g k) • baseNormalDirection U k

theorem baseNormalGaussianFrame_eq_map {n d : ℕ} (U : Frame n d)
    (g : EuclideanSpace ℝ (Fin n)) :
    baseNormalGaussianFrame U g = Matrix.of (fun i k => (Real.sqrt (n:ℝ))⁻¹ *
      Matrix.toEuclideanLin (normalizedNormalMapMatrix U) g (i,k)) := by
  ext i k
  simp only [baseNormalGaussianFrame, Matrix.smul_apply, Matrix.sum_apply, Matrix.of_apply,
    smul_eq_mul, Matrix.toLpLin_apply, Matrix.mulVec, dotProduct, baseNormalDirection_eq_column]
  congr 1
  apply Finset.sum_congr rfl
  intro j _
  ring

theorem baseNormalTangentGaussian_eq_lift {n d : ℕ} (U : Frame n d)
    (g : EuclideanSpace ℝ (Fin n)) :
    baseNormalTangentGaussian U g =
      baseNormalGaussianFrame U g * U.transpose + U * (baseNormalGaussianFrame U g).transpose := by
  simp only [baseNormalGaussianFrame, Matrix.smul_mul, Matrix.mul_smul,
    Matrix.transpose_smul, Matrix.transpose_sum, Matrix.sum_mul, Matrix.mul_sum,
    ← Finset.sum_add_distrib, ← smul_add]
  ext i j
  simp only [baseNormalTangentGaussian, Matrix.of_apply, Matrix.toLpLin_apply, Matrix.mulVec,
    dotProduct, baseNormalTangentFactor, Matrix.smul_apply, Matrix.sum_apply, Matrix.add_apply,
    smul_eq_mul, baseNormalTangent, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro k _
  ring

theorem baseNormalTangentCoordinate_eq_inner {n d : ℕ} (U : Frame n d) (i j : Fin n) :
    gaussianCoordinate (baseNormalTangentFactor U) (i,j) =
      innerSL ℝ (WithLp.toLp 2 (fun k => baseNormalTangentFactor U (i,j) k)) := by
  ext g
  simp only [gaussianCoordinate_apply, Matrix.toLpLin_apply, Matrix.mulVec, dotProduct,
    innerSL_apply_apply, PiLp.inner_apply, Real.inner_apply]

/-- The deterministic coefficient matrix is the actual second moment of the
Gaussian base tangent change. -/
theorem integral_sq_baseNormalTangentGaussian {n d : ℕ} (U : Frame n d) (i j : Fin n) :
    (∫ g, (baseNormalTangentGaussian U g i j)^2 ∂stdGaussian (EuclideanSpace ℝ (Fin n))) =
      baseNormalTangentVariance U i j := by
  change (∫ g, (gaussianCoordinate (baseNormalTangentFactor U) (i,j) g)^2 ∂_) = _
  rw [integral_sq_dual_stdGaussian, baseNormalTangentCoordinate_eq_inner, innerSL_apply_norm,
    EuclideanSpace.real_norm_sq_eq]
  simp only [baseNormalTangentFactor, Matrix.of_apply, mul_pow, inv_pow,
    Real.sq_sqrt (Nat.cast_nonneg n), ← Finset.mul_sum, baseNormalTangentVariance, one_div]

theorem integrable_sq_baseNormalTangentGaussian {n d : ℕ} (U : Frame n d) (i j : Fin n) :
    Integrable (fun g => (baseNormalTangentGaussian U g i j)^2)
      (stdGaussian (EuclideanSpace ℝ (Fin n))) :=
  (memLp_sq_gaussianCoordinate (baseNormalTangentFactor U) (i,j)).integrable (by norm_num)

theorem integral_baseNormalTangentGaussian_graphEnergy {n d : ℕ} (U : Frame n d)
    (x : Fin n → ℝ) :
    (∫ g, graphEnergy (Matrix.of fun i j => (baseNormalTangentGaussian U g i j)^2) x
      ∂stdGaussian (EuclideanSpace ℝ (Fin n))) = graphEnergy (baseNormalTangentVariance U) x := by
  simp only [graphEnergy, Matrix.of_apply]
  rw [integral_const_mul, integral_finsetSum]
  · congr 1
    apply Finset.sum_congr rfl
    intro i _
    rw [integral_finsetSum]
    · apply Finset.sum_congr rfl
      intro j _
      rw [integral_mul_const, integral_sq_baseNormalTangentGaussian]
    · intro j _
      exact (integrable_sq_baseNormalTangentGaussian U i j).mul_const _
  · intro i _
    exact integrable_finsetSum _ (fun j _ =>
      (integrable_sq_baseNormalTangentGaussian U i j).mul_const _)

theorem integral_baseNormalTangentGaussian_graphEnergy_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hn : 0 < n) (hd : 0 < d)
    (hp : ∀ k, ((d:ℝ)/(n:ℝ))/2 ≤ rowNormSq U k) (x : Fin n → ℝ) :
    (∫ g, graphEnergy (Matrix.of fun i j => (baseNormalTangentGaussian U g i j)^2) x
      ∂stdGaussian (EuclideanSpace ℝ (Fin n))) ≤
      (80/(d:ℝ))*matrixQuadratic (projectionLaplacian (frameProjection U)) x := by
  rw [integral_baseNormalTangentGaussian_graphEnergy]
  exact baseNormalTangentVariance_graphEnergy_le_average hU hn hd hp x

end Paulsen
