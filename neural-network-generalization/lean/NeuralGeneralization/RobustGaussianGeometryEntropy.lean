import NeuralGeneralization.RobustGaussianGeometryActive
import NeuralGeneralization.RobustEntropyMoments
import NeuralGeneralization.RobustEntropyChain

/-! # Dimension-sharp active energy under an actual finite-KL tilt -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory InnerProductSpace
open scoped BigOperators ENNReal
namespace NeuralGeneralization.RobustGaussianGeometry
open GaussianOrthogonal
variable {N q R : ℕ}

/-- Zero-safe active coordinates, flattened into a fixed finite ambient type. -/
def activeMatrixCoordinates (b : Fin q → EuclideanSpace ℝ (Fin N))
    (X : Fin R → EuclideanSpace ℝ (Fin N)) : Fin R × Fin q → ℝ :=
  fun ij => evaluations (gramSchmidtNormed ℝ b) (X ij.1) ij.2

@[fun_prop] theorem measurable_activeMatrixCoordinates
    (b : Fin q → EuclideanSpace ℝ (Fin N)) : Measurable (activeMatrixCoordinates (R := R) b) := by
  unfold activeMatrixCoordinates evaluations
  fun_prop

/-- KL of the actual active law controls exactly the projected row energy,
with dimension R*q instead of R*N. -/
theorem active_matrix_entropy_second_moment
    (b : Fin q → EuclideanSpace ℝ (Fin N))
    (Q : Measure (Fin R → EuclideanSpace ℝ (Fin N))) [IsProbabilityMeasure Q]
    (hKL : klDiv (Q.map (activeMatrixCoordinates b))
      ((Measure.pi (fun _ : Fin R => euclideanGaussian (ι := Fin N) 1)).map
        (activeMatrixCoordinates b)) ≠ ∞) :
    Integrable (fun X => ∑ i : Fin R, ‖activeProjection b (X i)‖^2) Q ∧
      (∫ X, (∑ i : Fin R, ‖activeProjection b (X i)‖^2) ∂Q) ≤
        4 * (klDiv (Q.map (activeMatrixCoordinates b))
          ((Measure.pi (fun _ : Fin R => euclideanGaussian (ι := Fin N) 1)).map
            (activeMatrixCoordinates b))).toReal + 2 * (R : ℝ) * q := by
  let F := activeMatrixCoordinates (R := R) b
  have hF : Measurable F := measurable_activeMatrixCoordinates b
  letI : IsProbabilityMeasure (Q.map F) := Measure.isProbabilityMeasure_map hF.aemeasurable
  have hG : (Measure.pi (fun _ : Fin R => euclideanGaussian (ι := Fin N) 1)).map F =
      Measure.pi (fun ij : Fin R × Fin q => gaussianReal 0 (activeVariance b ij.2)) :=
    active_matrix_coordinates_law R b
  change klDiv (Q.map F) _ ≠ ∞ at hKL
  rw [hG] at hKL
  have hb := RobustEntropyMoments.bounded_variance_gaussian_entropy_second_moment
    (fun ij : Fin R × Fin q => activeVariance b ij.2)
    (fun ij => activeVariance_le_one b ij.2) (Q.map F) hKL
  have heq : (fun X => ∑ ij : Fin R × Fin q, (F X ij)^2) =
      (fun X => ∑ i : Fin R, ‖activeProjection b (X i)‖^2) := by
    funext X
    exact active_matrix_energy_eq_projection b X
  have hi := (integrable_map_measure hb.1.aestronglyMeasurable hF.aemeasurable).mp hb.1
  have hi' : Integrable (fun X => ∑ i : Fin R, ‖activeProjection b (X i)‖^2) Q := by
    simpa only [Function.comp_def, heq] using hi
  refine ⟨hi', ?_⟩
  have hbm := hb.1.aestronglyMeasurable
  rw [integral_map hF.aemeasurable hbm, heq] at hb
  change _ ≤ 4 * (klDiv (Q.map F) ((Measure.pi
    (fun _ : Fin R => euclideanGaussian (ι := Fin N) 1)).map F)).toReal + _
  rw [hG]
  simpa only [Fintype.card_prod, Fintype.card_fin, Nat.cast_mul, mul_assoc] using hb.2

/-- Data processing bounds the active entropy by the original row-law KL. -/
theorem active_matrix_entropy_second_moment_of_full
    (b : Fin q → EuclideanSpace ℝ (Fin N))
    (Q : Measure (Fin R → EuclideanSpace ℝ (Fin N))) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi (fun _ : Fin R => euclideanGaussian (ι := Fin N) 1)) ≠ ∞) :
    Integrable (fun X => ∑ i : Fin R, ‖activeProjection b (X i)‖^2) Q ∧
      (∫ X, (∑ i : Fin R, ‖activeProjection b (X i)‖^2) ∂Q) ≤
        4 * (klDiv Q (Measure.pi (fun _ : Fin R => euclideanGaussian (ι := Fin N) 1))).toReal +
          2 * (R : ℝ) * q := by
  have hdp := RobustEntropy.klDiv_map_le Q
    (Measure.pi (fun _ : Fin R => euclideanGaussian (ι := Fin N) 1))
    (measurable_activeMatrixCoordinates (R := R) b)
  have hfin : klDiv (Q.map (activeMatrixCoordinates b))
      ((Measure.pi (fun _ : Fin R => euclideanGaussian (ι := Fin N) 1)).map
        (activeMatrixCoordinates b)) ≠ ∞ := ne_top_of_le_ne_top hKL hdp
  obtain ⟨hi,hb⟩ := active_matrix_entropy_second_moment b Q hfin
  refine ⟨hi, hb.trans ?_⟩
  have hr := ENNReal.toReal_mono hKL hdp
  linarith

end NeuralGeneralization.RobustGaussianGeometry
