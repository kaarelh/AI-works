import Paulsen.SmoothGaussianCrossSample
import Paulsen.SmoothSeedGraph

/-! Graph-energy interfaces for the actual simultaneous moderate sample. -/

namespace Paulsen.Smooth
open Matrix MeasureTheory ProbabilityTheory
open scoped BigOperators ProbabilityTheory Matrix.Norms.Elementwise
noncomputable section

/-- The retained tangent realization is symmetric for every coordinate vector. -/
theorem retainedTangent_realization_symmetric {n d : ℕ}
    (U : Frame n d) (ρ : ℝ) (g : FrameVector n d) (i j : Fin n) :
    gaussianMatrixImage (retainedTangentFactor U ρ) g i j =
      gaussianMatrixImage (retainedTangentFactor U ρ) g j i := by
  exact ((gaussianMatrixImage_symmetric _ (retainedTangentFactor_symmetric U ρ) g).apply i j).symm

/-- The sampled operator inequality is exactly the centered squared-entry
energy inequality used by the deterministic seed graph proof. -/
theorem ModerateGaussianSample.centered_energy {n d : ℕ}
    {U : Frame n d} {ρ t u₁ u₂ : ℝ} {M : Frame n n} {g : FrameVector n d}
    (hs : ModerateGaussianSample U ρ t u₁ u₂ M g) (x : Fin n → ℝ) :
    |graphEnergy (fun i j => (gaussianMatrixImage (retainedTangentFactor U ρ) g i j) ^ 2) x -
      graphEnergy (Matrix.of (retainedTangentEntryVariance U ρ)) x| ≤
        (((d : ℝ) / n) / 32) * vectorNormSq x := by
  have he := retainedTangentGraph_energy_bound_of_operator U ρ g hs.centeredGraph.le x
  rw [centeredGaussianSchurSquare_graphEnergy] at he
  have hmean : (∫ h, graphEnergy (gaussianSchurSquare (retainedTangentFactor U ρ) h) x
      ∂stdGaussian (FrameVector n d)) =
      graphEnergy (Matrix.of (retainedTangentEntryVariance U ρ)) x :=
    integral_gaussianImage_graphEnergy_eq_covariance (retainedTangentFactor U ρ) x
  rw [hmean] at he
  exact he

/-- The matrix called `graphLinearCross` contains exactly the cross term in
the squared-entry graph energy; in particular, there is no missing factor two. -/
theorem matrixQuadratic_graphLinearCross_eq {n : ℕ}
    (P Y : Frame n n) (hP : ∀ i j, P i j = P j i) (hY : ∀ i j, Y i j = Y j i)
    (t : ℝ) (x : Fin n → ℝ) :
    matrixQuadratic (graphLinearCross P Y t) x =
      2 * t * graphEnergy (fun i j => P i j * Y i j) x := by
  rw [graphLinearCross, matrixQuadratic_smul, graphLaplacian_quadratic _ (by
    intro i j
    simp only [Matrix.of_apply, hP i j, hY i j])]
  rfl

end
end Paulsen.Smooth
