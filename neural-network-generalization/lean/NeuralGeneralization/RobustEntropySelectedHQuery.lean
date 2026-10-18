import NeuralGeneralization.RobustEntropySelectedBasis
import NeuralGeneralization.RobustEntropyActiveMap
import NeuralGeneralization.RobustGaussianGeometryActiveKernel

/-! # Actual q-dimensional active-H query law for canonical reconstruction

The active marginal below is the literal original-row pushforward and is
independent of the test input. Only the comparison coupling varies by input.
-/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal RealInnerProductSpace Classical
namespace NeuralGeneralization.RobustEntropy
open RobustGaussianGeometry RobustCompressionInduction ConcreteModel
variable {A Y : Type*} [MeasurableSpace A] [MeasurableSpace Y]
    {N M q : ℕ} [MeasurableSpace (Finset (Fin M))]
    [MeasurableSingletonClass (Finset (Fin M))]
    [MeasurableSpace (QueryMessage (Fin M) q)]
    [MeasurableSingletonClass (QueryMessage (Fin M) q)]
local notation "E" => EuclideanSpace ℝ (Fin N)
local notation "Rows" => Fin N → E
local notation "HRows" => Fin N → EuclideanSpace ℝ (Fin q)

def selectedHQueryKernel (κ : Kernel (A × Y) Rows)
    (b : A → Fin M → E) (hb : Measurable b)
    (J : A × Y → Finset (Fin M)) (hJ : Measurable J) (t : ℝ) (i : Fin M) :
    Kernel (A × Y) (HRows × (Fin N → ℝ)) :=
  activeMapKernel (safeQueryKernel κ (fun a => b a.1) (hb.comp measurable_fst) J hJ i)
    (fun p => actualActiveH (selectedMessageBasis (q := q) b J p.1) t p.2)

instance selectedHQueryKernel_markov (κ : Kernel (A × Y) Rows) [IsMarkovKernel κ]
    (b : A → Fin M → E) (hb : Measurable b)
    (J : A × Y → Finset (Fin M)) (hJ : Measurable J) (t : ℝ) (i : Fin M) :
    IsMarkovKernel (selectedHQueryKernel (q := q) κ b hb J hJ t i) := by
  unfold selectedHQueryKernel
  apply activeMapKernel_markov
  exact measurable_actualActiveH_parameter _ (measurable_selectedMessageBasis b hb J hJ) t

/-- This exact marginal is common to every test input. In particular it is
not an independently chosen per-input approximation to the posterior. -/
theorem selectedHQueryKernel_fst (κ : Kernel (A × Y) Rows) [IsMarkovKernel κ]
    (b : A → Fin M → E) (hb : Measurable b)
    (J : A × Y → Finset (Fin M)) (hJ : Measurable J) (t : ℝ) (i : Fin M) :
    (selectedHQueryKernel (q := q) κ b hb J hJ t i).fst =
      activeHKernel κ (selectedMessageBasis b J)
        (measurable_selectedMessageBasis b hb J hJ) t := by
  have hH := measurable_actualActiveH_parameter (R := N) (selectedMessageBasis (q := q) b J)
    (measurable_selectedMessageBasis b hb J hJ) t
  letI := activeQueryKernel_markov κ (fun a : A × Y => b a.1)
    (hb.comp measurable_fst) J hJ
  rw [selectedHQueryKernel,activeMapKernel_fst _ _ hH,
    safeQueryKernel_fst κ (fun a : A × Y => b a.1) (hb.comp measurable_fst) J hJ i]
  ext a : 1
  rw [parameterMap_apply _ hH,activeHKernel_apply,
    activeQueryKernel_apply κ (fun a : A × Y => b a.1) (hb.comp measurable_fst) J hJ]
  exact map_actualActiveH_rowProjection (selectedMessageBasis b J a) t
    (inputSpan (b a.1) (J a)) (selectedMessageBasis_span_le b J a) (κ a)

/-- Compressing the active coordinates preserves the actual averaged
conditional residual entropy bound. -/
theorem selectedHQueryKernel_averaged_cost
    (μ : Measure (A × Y)) [IsProbabilityMeasure μ]
    (κ : Kernel (A × Y) Rows) [IsMarkovKernel κ]
    (b : A → Fin M → E) (hb : Measurable b)
    (J : A × Y → Finset (Fin M)) (hJ : Measurable J) (t : ℝ) (i : Fin M)
    (D : ℝ≥0∞)
    (hcost : (∫⁻ p, klDiv
      ((safeQueryKernel κ (fun a => b a.1) (hb.comp measurable_fst) J hJ i).condKernel p)
      (RobustCoupling.standardGaussianVector N)
      ∂μ ⊗ₘ (safeQueryKernel κ (fun a => b a.1) (hb.comp measurable_fst) J hJ i).fst) ≤ D) :
    (∫⁻ p, klDiv ((selectedHQueryKernel (q := q) κ b hb J hJ t i).condKernel p)
      (RobustCoupling.standardGaussianVector N)
      ∂μ ⊗ₘ (selectedHQueryKernel (q := q) κ b hb J hJ t i).fst) ≤ D := by
  rw [averaged_conditional_residual_entropy_eq]
  rw [averaged_conditional_residual_entropy_eq] at hcost
  apply le_trans _ hcost
  apply lintegral_mono
  intro a
  exact activeMapKernel_cost _ _
    (measurable_actualActiveH_parameter _ (measurable_selectedMessageBasis b hb J hJ) t)
    (RobustCoupling.standardGaussianVector N) a

end NeuralGeneralization.RobustEntropy
