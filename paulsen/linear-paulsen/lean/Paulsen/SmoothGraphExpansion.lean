import Paulsen.SmoothGraphProbability
import Paulsen.SmoothExpectedExpansion

/-! Concentration converts the actual retained tangent covariance expansion into
an expansion estimate for every successful Gaussian sample. -/
namespace Paulsen.Smooth
open Matrix MeasureTheory ProbabilityTheory
open scoped BigOperators ProbabilityTheory Matrix.Norms.Elementwise
noncomputable section

local instance {n : ℕ} : ContinuousENorm (Matrix (Fin n) (Fin n) ℝ) :=
  inferInstanceAs (ContinuousENorm (Fin n → Fin n → ℝ))

variable {κ : Type*} [Fintype κ] [DecidableEq κ]

theorem gaussianSchurSquare_mean_graphEnergy {n : ℕ}
    (C : Matrix (Fin n × Fin n) κ ℝ) (x : Fin n → ℝ) :
    graphEnergy (∫ h, gaussianSchurSquare C h ∂stdGaussian (EuclideanSpace ℝ κ)) x =
      ∫ h, graphEnergy (gaussianSchurSquare C h) x ∂stdGaussian (EuclideanSpace ℝ κ) := by
  have hI : (∫ h, graphEnergy (gaussianSchurSquare C h) x ∂stdGaussian (EuclideanSpace ℝ κ)) =
      graphEnergy (Matrix.of fun i j => (C * C.transpose) (i,j) (i,j)) x := by
    exact integral_gaussianImage_graphEnergy_eq_covariance C x
  rw [hI]
  congr 1
  ext i j
  have hmean : (∫ h, gaussianSchurSquare C h ∂stdGaussian (EuclideanSpace ℝ κ)) i j =
      ∑ s, C (i,j) s ^ 2 := by
    exact gaussianSchurSquare_integral_entry C i j
  rw [hmean]
  simp only [Matrix.of_apply, Matrix.mul_apply, Matrix.transpose_apply, pow_two]

theorem centeredGaussianSchurSquare_graphEnergy {n : ℕ}
    (C : Matrix (Fin n × Fin n) κ ℝ) (g : EuclideanSpace ℝ κ) (x : Fin n → ℝ) :
    graphEnergy (centeredGaussianSchurSquare C g) x =
      graphEnergy (gaussianSchurSquare C g) x -
        ∫ h, graphEnergy (gaussianSchurSquare C h) x ∂stdGaussian (EuclideanSpace ℝ κ) := by
  rw [centeredGaussianSchurSquare, graphEnergy_sub_eq, gaussianSchurSquare_mean_graphEnergy]

/-- Uniform graph expansion for a sample whose centered Laplacian obeys the bound. -/
theorem retainedTangent_graph_expansion_of_operator {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hn : 0 < n) (hd : 0 < d)
    (hdensity : (d : ℝ) / n ≤ 1 / 2)
    (hrows : ∀ i, ((d : ℝ) / n) / 2 ≤ rowNormSq U i ∧
      rowNormSq U i ≤ 3 * ((d : ℝ) / n) / 2)
    {ρ δ : ℝ} (hρ : 0 < ρ) (g : FrameVector n d)
    (hbound : ‖matrixEuclideanOperator (graphLaplacian
      (centeredGaussianSchurSquare (retainedTangentFactor U ρ) g))‖ ≤ δ * d / n)
    (x : Fin n → ℝ) (hx : ∑ i, x i = 0) :
    (1 / 4 - δ) * ((d : ℝ) / n) * vectorNormSq x -
      (2 / (n : ℝ) + 80 / (d : ℝ) + 8 / ρ) *
        matrixQuadratic (projectionLaplacian (frameProjection U)) x ≤
      graphEnergy (gaussianSchurSquare (retainedTangentFactor U ρ) g) x := by
  have hmean : (((d : ℝ) / n) / 4) * vectorNormSq x -
      (2 / (n : ℝ) + 80 / (d : ℝ) + 8 / ρ) *
        matrixQuadratic (projectionLaplacian (frameProjection U)) x ≤
      ∫ h, graphEnergy (gaussianSchurSquare (retainedTangentFactor U ρ) h) x
        ∂stdGaussian (FrameVector n d) := by
    exact expected_retainedTangent_expansion hU hn hd hdensity hrows hρ x hx
  have herror := retainedTangentGraph_energy_bound_of_operator U ρ g hbound x
  rw [centeredGaussianSchurSquare_graphEnergy] at herror
  have hlow := (abs_le.mp herror).1
  calc
    _ = ((((d : ℝ) / n) / 4) * vectorNormSq x -
        (2 / (n : ℝ) + 80 / (d : ℝ) + 8 / ρ) *
          matrixQuadratic (projectionLaplacian (frameProjection U)) x) -
        δ * d / n * vectorNormSq x := by ring
    _ ≤ (∫ h, graphEnergy (gaussianSchurSquare (retainedTangentFactor U ρ) h) x
        ∂stdGaussian (FrameVector n d)) - δ * d / n * vectorNormSq x :=
      sub_le_sub_right hmean _
    _ ≤ _ := by linarith only [hlow]

end
end Paulsen.Smooth
