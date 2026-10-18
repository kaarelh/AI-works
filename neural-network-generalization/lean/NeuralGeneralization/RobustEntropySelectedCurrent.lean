import NeuralGeneralization.RobustEntropyCurrentBlock
import NeuralGeneralization.RobustEntropyQueryObservation
import NeuralGeneralization.RobustCompressionMessageBasis

/-! # Selected queries for the actual current-block conditional law

This is the actual selection constructor from a canonical prefix/current/future
law. All costs come from disintegration of that law and its original future
entropy. The selected finite message may depend on the future, while the
q-slot basis is a function only of prefix and that finite message.
-/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal RealInnerProductSpace Classical
namespace NeuralGeneralization.RobustEntropy
open RobustCompressionInduction RobustGaussianGeometry

variable {A Y : Type*} [MeasurableSpace A] [MeasurableSpace Y]
    [StandardBorelSpace A] [StandardBorelSpace Y] [Nonempty A] [Nonempty Y]
    {N M : ℕ} [MeasurableSpace (Finset (Fin M))]
    [MeasurableSingletonClass (Finset (Fin M))]
local notation "Rows" => Fin N → EuclideanSpace ℝ (Fin N)

/-- The actual joint law after moving the whole future into the conditioning
coordinate. No independence under Q is required. -/
def currentRowJoint (Q : Measure (A × (Rows × Y))) : Measure ((A × Y) × Rows) :=
  Q.map currentGivenFuture

instance currentRowJoint_probability (Q : Measure (A × (Rows × Y))) [IsProbabilityMeasure Q] :
    IsProbabilityMeasure (currentRowJoint Q) :=
  Measure.isProbabilityMeasure_map measurable_currentGivenFuture.aemeasurable

/-- A measurable selection for the actual disintegration, together with its
uniform rank-abort bound and all genuine residual-kernel entropy budgets. -/
theorem exists_actual_current_queries
    (Q : Measure (A × (Rows × Y))) [IsProbabilityMeasure Q]
    (P : Measure Y) [IsProbabilityMeasure P]
    (b : A → Fin M → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    {q : ℕ} (hq : 0 < q) {K t δ η : ℝ}
    (hN : 0 < N) (ht : 0 < t) (hδ : 0 < δ) (hη : 0 ≤ η)
    (hentropy : futureEntropy Q ((rowGaussian N N).prod P) ≤
      ENNReal.ofReal (2*N*K/t^2))
    (hrank : 2*K ≤ η*δ^3*q) :
    ∃ J : A × Y → Finset (Fin M), ∃ hJ : Measurable J,
      (∀ a, klDiv ((currentRowJoint Q).condKernel a) (rowGaussian N N) ≠ ∞ →
        (N*δ^3/t^2)*(J a).card ≤
          (klDiv ((currentRowJoint Q).condKernel a) (rowGaussian N N)).toReal) ∧
      (currentRowJoint Q).fst.real {a | abortQueryMessage q (J a) = none} ≤ η ∧
      ∀ i, (∫⁻ p, klDiv
        ((safeQueryKernel (currentRowJoint Q).condKernel (fun a => b a.1)
          (hb.comp measurable_fst) J hJ i).condKernel p)
        (RobustCoupling.standardGaussianVector N)
        ∂(currentRowJoint Q).fst ⊗ₘ
          (safeQueryKernel (currentRowJoint Q).condKernel (fun a => b a.1)
            (hb.comp measurable_fst) J hJ i).fst) ≤
          ENNReal.ofReal (N*δ^3/t^2) := by
  let κ := (currentRowJoint Q).condKernel
  let μ := (currentRowJoint Q).fst
  have hNR : (0:ℝ) < N := by exact_mod_cast hN
  have hcut : 0 ≤ (N:ℝ)*δ^3/t^2 := by positivity
  obtain ⟨J,hJ,hbudget,hcost⟩ := exists_measurable_active_queries N κ
    (fun a : A × Y => b a.1) (hb.comp measurable_fst) ((N:ℝ)*δ^3/t^2) hcut
  have hmean : (∫⁻ a, klDiv (κ a) (rowGaussian N N) ∂μ) ≤
      ENNReal.ofReal (2*N*K/t^2) :=
    (current_given_future_entropy_le Q (rowGaussian N N) P).trans hentropy
  have habort := query_abort_probability_scaled μ
    (fun a => klDiv (κ a) (rowGaussian N N))
    (measurable_kernel_klDiv κ (Kernel.const (A × Y) (rowGaussian N N))) J
    hq hNR ht hδ hη hbudget hmean hrank
  have hfinite : ∀ᵐ a ∂μ, klDiv (κ a) (rowGaussian N N) ≠ ∞ :=
    current_given_future_entropy_ae_finite Q (rowGaussian N N) P
      (ne_top_of_le_ne_top ENNReal.ofReal_ne_top hentropy)
  refine ⟨J,hJ,hbudget,habort,?_⟩
  intro i
  apply safeQueryKernel_averaged_cost μ κ (fun a : A × Y => b a.1)
    (hb.comp measurable_fst) J hJ i ((N:ℝ)*δ^3/t^2)
  filter_upwards [hfinite] with a ha
  exact hcost a ha i

end NeuralGeneralization.RobustEntropy
