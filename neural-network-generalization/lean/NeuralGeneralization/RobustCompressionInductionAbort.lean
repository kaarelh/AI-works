import NeuralGeneralization.RobustCompressionMessages
import NeuralGeneralization.RobustEntropyKernel
import Mathlib.MeasureTheory.Integral.Lebesgue.Markov

/-! # Actual bounded query messages and their abort probability

The selected rank is charged to the actual conditional relative entropy.
Markov's inequality bounds the probability of exceeding a fixed rank budget,
including exceptional fibers whose relative entropy is infinite.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ENNReal
namespace NeuralGeneralization.RobustCompressionInduction
open ConcreteModel

/-- A finite selected input set, or one explicit abort value if over budget. -/
def abortQueryMessage {I : Type*} (q : ℕ) (S : Finset I) : QueryMessage I q :=
  if h : S.card ≤ q then some ⟨S,h⟩ else none

theorem abortQueryMessage_eq_none {I : Type*} (q : ℕ) (S : Finset I) :
    abortQueryMessage q S = none ↔ q < S.card := by
  unfold abortQueryMessage
  split_ifs <;> simp_all

theorem abortQueryMessage_eq_some {I : Type*} (q : ℕ) (S : Finset I)
    (h : S.card ≤ q) : abortQueryMessage q S = some ⟨S,h⟩ := by
  simp [abortQueryMessage,h]

theorem measurable_abortQueryMessage {I A : Type*} [Fintype I]
    [MeasurableSpace (Finset I)] [MeasurableSingletonClass (Finset I)]
    [MeasurableSpace A] [MeasurableSpace (QueryMessage I q)]
    (J : A → Finset I) (hJ : Measurable J) :
    Measurable (fun a => abortQueryMessage q (J a)) :=
  (measurable_of_finite (abortQueryMessage q)).comp hJ

variable {A I : Type*} [MeasurableSpace A]

/-- Uniform bound on the actual abort event from a mean conditional entropy
budget. Infinite-entropy fibers are handled by the extended integral. -/
theorem query_abort_probability (μ : Measure A) [IsProbabilityMeasure μ]
    (R : A → ℝ≥0∞) (hR : Measurable R) (J : A → Finset I)
    {q : ℕ} (hq : 0 < q) {δ η : ℝ} (hδ : 0 < δ) (hη : 0 ≤ η)
    (hquery : ∀ a, R a ≠ ∞ → δ*((J a).card:ℝ) ≤ (R a).toReal)
    (hmean : (∫⁻ a, R a ∂μ) ≤ ENNReal.ofReal (η*(δ*q))) :
    μ.real {a | abortQueryMessage q (J a) = none} ≤ η := by
  have hqR : (0:ℝ) < q := by exact_mod_cast hq
  have hcut : 0 < δ*(q:ℝ) := mul_pos hδ hqR
  have hsub : {a | abortQueryMessage q (J a) = none} ⊆
      {a | ENNReal.ofReal (δ*(q:ℝ)) ≤ R a} := by
    intro a ha
    have hcard : (q:ℝ) < (J a).card := by
      exact_mod_cast (abortQueryMessage_eq_none q (J a)).mp ha
    by_cases htop : R a = ∞
    · simp [htop]
    · change ENNReal.ofReal (δ*(q:ℝ)) ≤ R a
      rw [← ENNReal.ofReal_toReal htop]
      exact ENNReal.ofReal_le_ofReal (by nlinarith [hquery a htop])
  have hcut0 : ENNReal.ofReal (δ*(q:ℝ)) ≠ 0 := (ENNReal.ofReal_pos.mpr hcut).ne'
  have hb := meas_ge_le_lintegral_div (μ:=μ) hR.aemeasurable hcut0 ENNReal.ofReal_ne_top
  have hprob : μ {a | abortQueryMessage q (J a) = none} ≤ ENNReal.ofReal η := by
    calc
      _ ≤ μ {a | ENNReal.ofReal (δ*(q:ℝ)) ≤ R a} := measure_mono hsub
      _ ≤ (∫⁻ a, R a ∂μ)/ENNReal.ofReal (δ*(q:ℝ)) := hb
      _ ≤ ENNReal.ofReal (η*(δ*q))/ENNReal.ofReal (δ*(q:ℝ)) :=
        ENNReal.div_le_div_right hmean _
      _ = _ := by
        rw [ENNReal.ofReal_mul hη, ENNReal.mul_div_cancel_right hcut0 ENNReal.ofReal_ne_top]
  have hh := ENNReal.toReal_mono ENNReal.ofReal_ne_top hprob
  simpa only [Measure.real,ENNReal.toReal_ofReal hη] using hh

/-- The physical Gaussian scaling cancels from the rank-abort probability.
The same q works at every positive scale t. -/
theorem query_abort_probability_scaled (μ : Measure A) [IsProbabilityMeasure μ]
    (R : A → ℝ≥0∞) (hR : Measurable R) (J : A → Finset I)
    {q : ℕ} (hq : 0 < q) {N K t δ η : ℝ}
    (hN : 0 < N) (ht : 0 < t) (hδ : 0 < δ) (hη : 0 ≤ η)
    (hquery : ∀ a, R a ≠ ∞ → (N*δ^3/t^2)*((J a).card:ℝ) ≤ (R a).toReal)
    (hmean : (∫⁻ a, R a ∂μ) ≤ ENNReal.ofReal (2*N*K/t^2))
    (hbudget : 2*K ≤ η*δ^3*q) :
    μ.real {a | abortQueryMessage q (J a) = none} ≤ η := by
  apply query_abort_probability μ R hR J hq (by positivity) hη hquery
  apply hmean.trans
  apply ENNReal.ofReal_le_ofReal
  have hh := mul_le_mul_of_nonneg_left hbudget (div_nonneg hN.le (sq_nonneg t))
  calc
    2*N*K/t^2 = (N/t^2)*(2*K) := by ring
    _ ≤ (N/t^2)*(η*δ^3*q) := hh
    _ = η*((N*δ^3/t^2)*q) := by ring

end NeuralGeneralization.RobustCompressionInduction
