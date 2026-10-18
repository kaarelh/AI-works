import NeuralGeneralization.RobustEntropySelectedHQuery
import NeuralGeneralization.RobustEntropySelectedDecoding
import NeuralGeneralization.RobustCompressionObservableKernel

/-! # The q-H observation retains the literal complete original row field -/
noncomputable section
set_option maxHeartbeats 400000
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

def selectedHObservation (b : A → Fin M → E)
    (J : A × Y → Finset (Fin M)) (t : ℝ) (i : Fin M)
    (p : (A × Y) × (Rows × (Fin N → ℝ))) : HRows × (Fin N → ℝ) :=
  (actualActiveH (selectedMessageBasis (q := q) b J p.1) t p.2.1,
    (augmentedQueryObservation (fun a : A × Y => b a.1) J i p).2)

theorem measurable_selectedHObservation (b : A → Fin M → E) (hb : Measurable b)
    (J : A × Y → Finset (Fin M)) (hJ : Measurable J) (t : ℝ) (i : Fin M) :
    Measurable (selectedHObservation (q := q) b J t i) := by
  have hm : Measurable (fun p : (A × Y) × (Rows × (Fin N → ℝ)) => (p.1,p.2.1)) :=
    measurable_fst.prodMk measurable_snd.fst
  have hH := (measurable_actualActiveH_parameter (R := N)
    (selectedMessageBasis (q := q) b J)
    (measurable_selectedMessageBasis b hb J hJ) t).comp hm
  exact hH.prodMk
    (measurable_augmentedQueryObservation (fun a : A × Y => b a.1)
      (hb.comp measurable_fst) J hJ i).snd

/-- Exact observation law, with original rows retained and an independent
dummy Gaussian used only when the residual direction is zero. -/
theorem selectedHQueryKernel_augmented_law
    (κ : Kernel (A × Y) Rows) [IsMarkovKernel κ]
    (b : A → Fin M → E) (hb : Measurable b)
    (J : A × Y → Finset (Fin M)) (hJ : Measurable J) (t : ℝ) (i : Fin M)
    (a : A × Y) :
    ((κ a).prod (RobustCoupling.standardGaussianVector N)).map
      (fun p => selectedHObservation (q := q) b J t i (a,p)) =
      selectedHQueryKernel (q := q) κ b hb J hJ t i a := by
  have hH := measurable_actualActiveH_parameter (R := N)
    (selectedMessageBasis (q := q) b J)
    (measurable_selectedMessageBasis b hb J hJ) t
  have ho : Measurable (fun p : Rows × (Fin N → ℝ) =>
      augmentedQueryObservation (fun a : A × Y => b a.1) J i (a,p)) :=
    (measurable_augmentedQueryObservation (R := N)
    (fun a : A × Y => b a.1) (hb.comp measurable_fst) J hJ i).comp
      measurable_prodMk_left
  have hHa : Measurable (fun u : Rows => actualActiveH
      (selectedMessageBasis (q := q) b J a) t u) :=
    by
      have hm : Measurable (fun u : Rows => (a,u)) := measurable_prodMk_left
      simpa only [Function.comp_def] using hH.comp hm
  rw [selectedHQueryKernel, activeMapKernel_apply _ _ hH,
    ← safeQueryKernel_augmented_law κ (fun a : A × Y => b a.1)
      (hb.comp measurable_fst) J hJ i a,
    Measure.map_map (hHa.prodMap measurable_id) ho]
  congr 1
  funext p
  simp only [Function.comp_def, Prod.map, selectedHObservation,
    augmentedQueryObservation, Prod.mk.injEq]
  constructor
  · exact (actualActiveH_rowProjection_eq (selectedMessageBasis b J a) t
      (inputSpan (b a.1) (J a)) (selectedMessageBasis_span_le b J a) p.1).symm
  · rfl

/-- The literal complete-current-field kernel, augmented only by an independent
standard Gaussian used on the zero-residual branch. -/
def augmentedCurrentRows (κ : Kernel (A × Y) Rows) :
    Kernel (A × Y) (Rows × (Fin N → ℝ)) :=
  κ ×ₖ Kernel.const (A × Y) (RobustCoupling.standardGaussianVector N)

instance augmentedCurrentRows_markov (κ : Kernel (A × Y) Rows) [IsMarkovKernel κ] :
    IsMarkovKernel (augmentedCurrentRows κ) := by
  unfold augmentedCurrentRows
  infer_instance

theorem augmentedCurrentRows_fst (κ : Kernel (A × Y) Rows) [IsMarkovKernel κ] :
    (augmentedCurrentRows κ).fst = κ := by
  ext a : 1
  simp [augmentedCurrentRows,Kernel.fst_apply,Kernel.prod_apply,Measure.fst]

/-- Kernel-level equality ready for the complete-field conditional lift. -/
theorem selectedHQueryKernel_parameterMap
    (κ : Kernel (A × Y) Rows) [IsMarkovKernel κ]
    (b : A → Fin M → E) (hb : Measurable b)
    (J : A × Y → Finset (Fin M)) (hJ : Measurable J) (t : ℝ) (i : Fin M) :
    RobustCompression.parameterMap (augmentedCurrentRows κ)
      (selectedHObservation (q := q) b J t i)
      (measurable_selectedHObservation b hb J hJ t i) =
      selectedHQueryKernel (q := q) κ b hb J hJ t i := by
  ext a : 1
  rw [RobustCompression.parameterMap_apply,augmentedCurrentRows,Kernel.prod_apply,
    Kernel.const_apply]
  exact selectedHQueryKernel_augmented_law κ b hb J hJ t i a

/-- Decoding q-H and its residual gives the original preactivation on every
valid message, including the zero residual branch. -/
theorem selectedHObservation_evaluation
    (b : A → Fin M → E) (J : A × Y → Finset (Fin M))
    (a : A × Y) (hcard : (J a).card ≤ q) (t : ℝ) (i : Fin M)
    (g : Rows) (z : Fin N → ℝ) (j : Fin N) :
    ⟪(selectedHObservation (q := q) b J t i (a,(g,z))).1 j,
      activeCoordinateVector (selectedMessageBasis (q := q) b J a) (b a.1 i)⟫ +
      t*‖queryResidual (selectedMessageBasis (q := q) b J a) (b a.1 i)‖ *
        (selectedHObservation (q := q) b J t i (a,(g,z))).2 j =
      t*⟪b a.1 i,g j⟫ := by
  have he := selectedActiveH_augmented_evaluation_qbasis b J a hcard t i g z j
  change ⟪actualActiveH (selectedMessageBasis (q := q) b J a) t
      (rowProjection N (inputSpan (b a.1) (J a)) g) j, _⟫ + _ = _ at he
  rw [actualActiveH_rowProjection_eq _ t _ (selectedMessageBasis_span_le b J a)] at he
  exact he

end NeuralGeneralization.RobustEntropy
