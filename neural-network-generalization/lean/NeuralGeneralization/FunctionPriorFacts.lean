import NeuralGeneralization.FunctionPrior
import NeuralGeneralization.Cloning
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic

/-!
# The global-margin conditioning convention and positive target mass

The sign events partition the global strict-margin event. This proves the
cancellation of its normalizer, and proves positive mass whenever an actual
strict-margin parameter witness lies in the support of the parameter measure.
-/

noncomputable section
open scoped BigOperators NNReal
open MeasureTheory MeasureTheory.Measure

namespace NeuralGeneralization.ConcreteModel

theorem admissibleActivation_continuous {φ : ℝ → ℝ}
    (hφ : admissibleActivation φ) : Continuous φ := by
  apply (LipschitzWith.mk_one (f := φ) ?_).continuous
  intro x y
  simpa only [Real.dist_eq] using hφ.2 x y

theorem tanh_continuous : Continuous Real.tanh := by
  have heq : Real.tanh = fun x => Real.sinh x / Real.cosh x := by
    funext x
    exact Real.tanh_eq_sinh_div_cosh x
  rw [heq]
  exact Real.continuous_sinh.div Real.continuous_cosh (fun x => (Real.cosh_pos x).ne')

/-- The function masses really partition the absolute-margin event. -/
theorem sum_functionMass_eq_globalMargin {d N r : ℕ} {φ : ℝ → ℝ}
    (hφ : Continuous φ) {a : ℝ} (ha : 0 ≤ a)
    (μ : Measure (Weights d N r)) [IsFiniteMeasure μ] :
    (∑ g : BooleanFunction d, functionMass φ a μ g) =
      (μ (globalMarginEvent φ a)).toReal := by
  classical
  symm
  rw [globalMarginEvent_eq_iUnion]
  rw [measure_iUnion (fun f g hfg => marginEvents_disjoint φ ha hfg)
    (fun f => (isOpen_marginEvent hφ a f).measurableSet)]
  rw [tsum_fintype, ENNReal.toReal_sum (fun g _ => measure_ne_top μ _)]
  rfl

theorem functionMass_sum_le_one {d N r : ℕ} {φ : ℝ → ℝ}
    (hφ : Continuous φ) {a : ℝ} (ha : 0 ≤ a)
    (μ : Measure (Weights d N r)) [IsProbabilityMeasure μ] :
    (∑ g : BooleanFunction d, functionMass φ a μ g) ≤ 1 := by
  rw [sum_functionMass_eq_globalMargin hφ ha μ]
  simpa using ENNReal.toReal_mono ENNReal.one_ne_top
    (prob_le_one (μ := μ) (s := globalMarginEvent φ a))

theorem globalConditionedFunctionPrior_sum {d N r : ℕ} {φ : ℝ → ℝ}
    (hφ : Continuous φ) {a : ℝ} (ha : 0 ≤ a)
    (μ : Measure (Weights d N r)) [IsFiniteMeasure μ]
    (hglobal : (μ (globalMarginEvent φ a)).toReal ≠ 0) :
    (∑ g : BooleanFunction d, globalConditionedFunctionPrior φ a μ g) = 1 := by
  unfold globalConditionedFunctionPrior
  rw [← Finset.sum_div, sum_functionMass_eq_globalMargin hφ ha μ, div_self hglobal]

/-- Normalizing the global-margin prior before observing the labels gives
exactly the concrete posterior used in all four main statements. -/
theorem networkPosterior_eq_globalConditioned {d N r n : ℕ} (φ : ℝ → ℝ)
    (a : ℝ) (μ : Measure (Weights d N r)) (f : BooleanFunction d)
    (s : Fin n → Cube d) (hglobal : (μ (globalMarginEvent φ a)).toReal ≠ 0) :
    networkPosterior φ a μ f s =
      NeuralGeneralization.posterior (globalConditionedFunctionPrior φ a μ)
        (consistent f s) := by
  classical
  exact (NeuralGeneralization.posterior_div_const (functionMass φ a μ)
    (consistent f s) (μ (globalMarginEvent φ a)).toReal hglobal).symm

theorem globalMarginMass_pos_of_functionMass {d N r : ℕ} (φ : ℝ → ℝ)
    (a : ℝ) (μ : Measure (Weights d N r)) [IsFiniteMeasure μ]
    (f : BooleanFunction d) (hf : 0 < functionMass φ a μ f) :
    0 < (μ (globalMarginEvent φ a)).toReal := by
  exact lt_of_lt_of_le hf (ENNReal.toReal_mono (measure_ne_top μ _)
    (measure_mono (marginEvent_subset_global φ a f)))

theorem functionMass_pos_of_mem {d N r : ℕ} {φ : ℝ → ℝ}
    (hφ : Continuous φ) (a : ℝ) (μ : Measure (Weights d N r))
    [IsOpenPosMeasure μ] [IsFiniteMeasure μ]
    (f : BooleanFunction d) (w : Weights d N r) (hw : w ∈ marginEvent φ a f) :
    0 < functionMass φ a μ f := by
  exact ENNReal.toReal_pos
    ((isOpen_marginEvent hφ a f).measure_pos μ ⟨w, hw⟩).ne'
    (measure_ne_top μ _)

theorem margin_witness_at_larger_width {d C N r : ℕ} (φ : ℝ → ℝ)
    (f : BooleanFunction d) (hc : realizesAtComplexity (r := r) φ f C)
    (hCN : C ≤ N) : ∃ w : Weights d N r, w ∈ marginEvent φ (1 / 2) f := by
  obtain ⟨hC, w, hw, _⟩ := hc
  obtain ⟨v, hv, _⟩ := exists_clone_at_every_width (Nat.succ_le_iff.mp hC) hCN φ w
  refine ⟨v, ?_⟩
  intro x
  rw [hv x]
  exact hw x


end NeuralGeneralization.ConcreteModel
