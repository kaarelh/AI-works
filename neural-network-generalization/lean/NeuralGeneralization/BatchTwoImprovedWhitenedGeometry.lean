import NeuralGeneralization.BatchTwoImprovedSourceGood
import NeuralGeneralization.RobustCompressionLayerGaussian

/-! Exact covariance of the input-independent, zero-safe whitened Gaussian
coefficient construction. No nonsingular matrix inverse is needed. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators RealInnerProductSpace NNReal
open MeasureTheory ProbabilityTheory InnerProductSpace Submodule WithLp Matrix
namespace NeuralGeneralization.BatchTwoImprovedWeightedSampling
open SquaredSampling RobustGaussianGeometry BatchTwoImprovedProjection
open BatchTwoImprovedActiveGeometry RobustCompressionLayerGaussian Classical
variable {N q m : ℕ}

def whitenedMatrix (a : Fin N → ℝ) (s : Fin m → Fin N) (u : Fin N → Fin q → ℝ)
    (j : Fin m) (k : Fin q) : ℝ := gramSchmidtNormed ℝ (sampledColumns a s u) k j

def weightedFeature (a : Fin N → ℝ) (s : Fin m → Fin N) (h : Fin N → ℝ) (j : Fin m) : ℝ :=
  Real.sqrt (a (s j))*h (s j)

theorem whitenedMatrix_contractive (a : Fin N → ℝ) (s : Fin m → Fin N)
    (u : Fin N → Fin q → ℝ) (v : Fin q → ℝ) :
    ∑ j, (Matrix.of (whitenedMatrix a s u) *ᵥ v) j^2 ≤ ∑ k, (v k)^2 := by
  let f := sampledColumns a s u
  have he : (∑ j, (Matrix.of (whitenedMatrix a s u) *ᵥ v) j^2) =
      ‖∑ k, v k • gramSchmidtNormed ℝ f k‖^2 := by
    rw [EuclideanSpace.real_norm_sq_eq]
    apply Finset.sum_congr rfl
    intro j _
    have hc : (∑ k, v k • gramSchmidtNormed ℝ f k) j =
        ∑ k, v k*gramSchmidtNormed ℝ f k j := by
      change (EuclideanSpace.proj j) (∑ k, v k • gramSchmidtNormed ℝ f k)=_
      simp
    rw [hc]
    simp [Matrix.mulVec,dotProduct,whitenedMatrix,f,mul_comm]
  rw [he,active_combination_norm]
  apply Finset.sum_le_sum
  intro k _
  rcases gramSchmidtNormed_norm_zero_or_one f k with hk | hk
  · simp [hk,sq_nonneg]
  · simp [hk]

theorem sourceResidualVariance_whitened (a : Fin N → ℝ) (s : Fin m → Fin N)
    (u : Fin N → Fin q → ℝ) (h : Fin m → ℝ) :
    sourceResidualVariance (whitenedMatrix a s u) h =
      ‖queryResidual (sampledColumns a s u) (toLp 2 h)‖^2 := by
  have he := residual_pythagoras (sampledColumns a s u) (toLp 2 h)
  rw [← active_energy_eq_projection] at he
  simp only [EuclideanSpace.real_norm_sq_eq,ofLp_toLp] at he
  unfold sourceResidualVariance
  have hc : (∑ k, (∑ j, whitenedMatrix a s u j k*h j)^2) =
      ∑ k, (evaluations (gramSchmidtNormed ℝ (sampledColumns a s u)) (toLp 2 h) k)^2 := by
    simp [evaluations,EuclideanSpace.inner_eq_star_dotProduct,dotProduct,whitenedMatrix,mul_comm]
  rw [hc]
  rw [EuclideanSpace.real_norm_sq_eq]
  linarith

theorem queryResidual_smul (f : Fin q → EuclideanSpace ℝ (Fin m))
    (r : EuclideanSpace ℝ (Fin m)) (c : ℝ) :
    queryResidual f (c • r)=c • queryResidual f r := by
  simp only [queryResidual,activeProjection_eq_starProjection,map_smul,smul_sub]

theorem weightedFeature_eq_smul (hm : 0 < m) (a : Fin N → ℝ)
    (s : Fin m → Fin N) (h : Fin N → ℝ) :
    toLp 2 (weightedFeature a s h)=Real.sqrt (m:ℝ) • sampledVector a s h := by
  apply PiLp.ext
  intro j
  have hn : Real.sqrt (m:ℝ) ≠ 0 := (Real.sqrt_pos.mpr (Nat.cast_pos.mpr hm)).ne'
  change Real.sqrt (a (s j))*h (s j)=Real.sqrt (m:ℝ)*(Real.sqrt (a (s j))/Real.sqrt (m:ℝ)*h (s j))
  field_simp

theorem residualVariance_whitened (hm : 0 < m) (a : Fin N → ℝ)
    (s : Fin m → Fin N) (u : Fin N → Fin q → ℝ) (h : Fin N → ℝ) (t : ℝ) :
    (residualVariance (whitenedMatrix a s u) (weightedFeature a s h) t : ℝ) =
      t^2*‖queryResidual (sampledColumns a s u) (sampledVector a s h)‖^2 := by
  have hn : (0:ℝ) < m := Nat.cast_pos.mpr hm
  have hs : Real.sqrt (m:ℝ) ≠ 0 := (Real.sqrt_pos.mpr hn).ne'
  unfold residualVariance
  rw [NNReal.coe_mul,Real.coe_toNNReal _ (sq_nonneg _),
    Real.coe_toNNReal _ (sourceResidualVariance_nonneg _ (whitenedMatrix_contractive a s u) _),
    sourceResidualVariance_whitened,weightedFeature_eq_smul hm,queryResidual_smul,norm_smul,
    Real.norm_of_nonneg (Real.sqrt_nonneg _),mul_pow,div_pow,Real.sq_sqrt hn.le]
  field_simp

theorem sampledVector_sub (a : Fin N → ℝ) (s : Fin m → Fin N) (h g : Fin N → ℝ) :
    sampledVector a s (fun j => h j-g j)=sampledVector a s h-sampledVector a s g := by
  apply PiLp.ext
  intro j
  change Real.sqrt (a (s j))/Real.sqrt (m:ℝ)*(h (s j)-g (s j)) =
    Real.sqrt (a (s j))/Real.sqrt (m:ℝ)*h (s j)-Real.sqrt (a (s j))/Real.sqrt (m:ℝ)*g (s j)
  ring

theorem residual_sampledFeature_eq (hN : 0 < N)
    (b : Fin q → EuclideanSpace ℝ (Fin N)) (h : Fin N → ℝ)
    (a : Fin N → ℝ) (s : Fin m → Fin N) :
    queryResidual (sampledColumns a s (fun j k => sourceRows b j k)) (sampledVector a s h) =
      queryResidual (sampledColumns a s (fun j k => sourceRows b j k))
        (sampledVector a s (sourceResidual b h)) := by
  let u := fun j k => sourceRows b j k
  let ψ := evaluations (gramSchmidtNormed ℝ b) (normalizedFeature h)
  have he : sourceResidual b h=fun j => h j-linearEvaluation (u j) ψ := by
    funext j
    exact sourceResidual_decomposition b h hN j
  rw [he,sampledVector_sub,← sampledColumns_combination]
  symm
  apply queryResidual_sub_span
  exact Submodule.sum_mem _ (fun k _ => Submodule.smul_mem _ _
    (Submodule.subset_span (Set.mem_range_self k)))

end NeuralGeneralization.BatchTwoImprovedWeightedSampling
