import NeuralGeneralization.RobustEntropySelectedBasis
import NeuralGeneralization.RobustGaussianGeometryActiveKernel

/-! # Exact q-coordinate decoding of the selected full-field query observation -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped RealInnerProductSpace Classical
namespace NeuralGeneralization.RobustEntropy
open RobustGaussianGeometry ConcreteModel
variable {A Y : Type*} [MeasurableSpace A] [MeasurableSpace Y]
    {N M q R : ℕ} [MeasurableSpace (Finset (Fin M))]
    [MeasurableSingletonClass (Finset (Fin M))]
    [MeasurableSpace (QueryMessage (Fin M) q)]
    [MeasurableSingletonClass (QueryMessage (Fin M) q)]
local notation "E" => EuclideanSpace ℝ (Fin N)

/-- On a valid selected rank, the q-coordinate active mean is exactly the
mean decoded from the full selected-span projection. -/
theorem selectedActiveH_augmented_mean
    (b : A → Fin M → E) (J : A × Y → Finset (Fin M)) (a : A × Y)
    (hcard : (J a).card ≤ q) (t : ℝ) (i : Fin M)
    (g : Fin R → E) (z : Fin R → ℝ) (j : Fin R) :
    ⟪actualActiveH (selectedMessageBasis (q := q) b J a) t
        (augmentedQueryObservation (fun a : A × Y => b a.1) J i (a,(g,z))).1 j,
      activeCoordinateVector (selectedMessageBasis (q := q) b J a) (b a.1 i)⟫ =
      t*⟪b a.1 i,
        (augmentedQueryObservation (fun a : A × Y => b a.1) J i (a,(g,z))).1 j⟫ := by
  change ⟪actualActiveH (selectedMessageBasis (q := q) b J a) t
      (rowProjection R (inputSpan (b a.1) (J a)) g) j,
    activeCoordinateVector (selectedMessageBasis (q := q) b J a) (b a.1 i)⟫ =
    t*⟪b a.1 i,(rowProjection R (inputSpan (b a.1) (J a)) g) j⟫
  rw [actualActiveH_rowProjection_eq _ t _ (selectedMessageBasis_span_le b J a)]
  change ⟪t • activeCoordinateVector (selectedMessageBasis (q := q) b J a) (g j),
    activeCoordinateVector (selectedMessageBasis (q := q) b J a) (b a.1 i)⟫ = _
  rw [real_inner_smul_left, activeCoordinateVector_inner,
    activeProjection_eq_starProjection, selectedMessageBasis_span_eq b J a hcard]
  rfl

/-- The q-H observation plus the zero-safe residual observation reproduces the
original scaled preactivation exactly. The dummy Gaussian in the zero-residual
branch is multiplied by zero, as proved in augmentedQueryObservation_evaluation. -/
theorem selectedActiveH_augmented_evaluation
    (b : A → Fin M → E) (J : A × Y → Finset (Fin M)) (a : A × Y)
    (hcard : (J a).card ≤ q) (t : ℝ) (i : Fin M)
    (g : Fin R → E) (z : Fin R → ℝ) (j : Fin R) :
    ⟪actualActiveH (selectedMessageBasis (q := q) b J a) t
        (augmentedQueryObservation (fun a : A × Y => b a.1) J i (a,(g,z))).1 j,
      activeCoordinateVector (selectedMessageBasis (q := q) b J a) (b a.1 i)⟫ +
      t*‖queryResidual (maskedInputs (b a.1) (J a)) (b a.1 i)‖ *
        (augmentedQueryObservation (fun a : A × Y => b a.1) J i (a,(g,z))).2 j =
      t*⟪b a.1 i,g j⟫ := by
  rw [selectedActiveH_augmented_mean b J a hcard t i g z j]
  have hh := augmentedQueryObservation_evaluation (fun a : A × Y => b a.1) J i a g z j
  calc
    _ = t*(⟪b a.1 i,
        (augmentedQueryObservation (fun a : A × Y => b a.1) J i (a,(g,z))).1 j⟫ +
      ‖queryResidual (maskedInputs (b a.1) (J a)) (b a.1 i)‖ *
        (augmentedQueryObservation (fun a : A × Y => b a.1) J i (a,(g,z))).2 j) := by ring
    _ = _ := congrArg (fun r : ℝ => t*r) hh

/-- The equivalent form with the bounded q-family residual norm, ready for the
actual finite-source Gaussian comparison parameters. -/
theorem selectedActiveH_augmented_evaluation_qbasis
    (b : A → Fin M → E) (J : A × Y → Finset (Fin M)) (a : A × Y)
    (hcard : (J a).card ≤ q) (t : ℝ) (i : Fin M)
    (g : Fin R → E) (z : Fin R → ℝ) (j : Fin R) :
    ⟪actualActiveH (selectedMessageBasis (q := q) b J a) t
        (augmentedQueryObservation (fun a : A × Y => b a.1) J i (a,(g,z))).1 j,
      activeCoordinateVector (selectedMessageBasis (q := q) b J a) (b a.1 i)⟫ +
      t*‖queryResidual (selectedMessageBasis (q := q) b J a) (b a.1 i)‖ *
        (augmentedQueryObservation (fun a : A × Y => b a.1) J i (a,(g,z))).2 j =
      t*⟪b a.1 i,g j⟫ := by
  rw [selectedMessageBasis_residual_eq b J a hcard]
  exact selectedActiveH_augmented_evaluation b J a hcard t i g z j

end NeuralGeneralization.RobustEntropy
