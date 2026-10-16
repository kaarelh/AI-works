import Mathlib.MeasureTheory.Integral.Bochner.Set
import Mathlib.MeasureTheory.Measure.ProbabilityMeasure
import Mathlib.Tactic.Linarith

/-! Bounded convergence in probability when the underlying probability spaces
vary with the index. This is used for random feature arrays of varying width. -/
noncomputable section
open MeasureTheory Filter Set
open scoped Topology

namespace NeuralGeneralization

theorem integral_deviation_le_bad_mass {Ω E : Type*} [MeasurableSpace Ω]
    [NormedAddCommGroup E] [NormedSpace ℝ E] [CompleteSpace E]
    (μ : Measure Ω) [IsProbabilityMeasure μ] (F : Ω → E) (z : E)
    (B ε : ℝ) (_hB : 0 ≤ B) (hε : 0 ≤ ε) (hF : AEStronglyMeasurable F μ)
    (hbound : ∀ x, ‖F x‖ ≤ B) (A : Set Ω) (hA : MeasurableSet A)
    (hgood : ∀ x ∉ A, ‖F x - z‖ ≤ ε) :
    ‖(∫ x, F x ∂μ) - z‖ ≤ ε + (B + ‖z‖) * μ.real A := by
  have hFi : Integrable F μ :=
    (integrable_const B).mono' hF (Eventually.of_forall hbound)
  have hpoint (x : Ω) : ‖F x - z‖ ≤ ε + A.indicator (fun _ => B + ‖z‖) x := by
    by_cases hx : x ∈ A
    · rw [indicator_of_mem hx]
      exact (norm_sub_le _ _).trans (by linarith [hbound x])
    · rw [indicator_of_notMem hx, add_zero]
      exact hgood x hx
  have hind : Integrable (A.indicator (fun _ : Ω => B + ‖z‖)) μ :=
    (integrable_const _).indicator hA
  have he : (∫ x, F x ∂μ) - z = ∫ x, F x - z ∂μ := by
    rw [integral_sub hFi (integrable_const z)]
    simp
  rw [he]
  calc
    _ ≤ ∫ x, ‖F x - z‖ ∂μ := norm_integral_le_integral_norm _
    _ ≤ ∫ x, ε + A.indicator (fun _ : Ω => B + ‖z‖) x ∂μ :=
      integral_mono (hFi.sub (integrable_const z)).norm ((integrable_const ε).add hind) hpoint
    _ = _ := by
      rw [integral_add (integrable_const ε) hind, integral_indicator hA, setIntegral_const]
      simp [mul_comm]

theorem tendsto_integral_of_varying_probability {Ω : ℕ → Type*}
    [∀ n, MeasurableSpace (Ω n)] {E : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E] [CompleteSpace E]
    (μ : ∀ n, Measure (Ω n)) [∀ n, IsProbabilityMeasure (μ n)]
    (F : ∀ n, Ω n → E) (z : E) (B : ℝ) (hB : 0 ≤ B)
    (hF : ∀ n, StronglyMeasurable (F n)) (hbound : ∀ n x, ‖F n x‖ ≤ B)
    (hprob : ∀ ε : ℝ, 0 < ε →
      Tendsto (fun n => (μ n).real {x | ε ≤ ‖F n x - z‖}) atTop (𝓝 0)) :
    Tendsto (fun n => ∫ x, F n x ∂μ n) atTop (𝓝 z) := by
  apply Metric.tendsto_nhds.mpr
  intro ε hε
  have hC : 0 < B + ‖z‖ + 1 := by positivity
  have hsmall := (hprob (ε / 2) (by positivity)).eventually
    (gt_mem_nhds (show 0 < ε / (2 * (B + ‖z‖ + 1)) by positivity))
  filter_upwards [hsmall] with n hn
  rw [dist_eq_norm]
  have hA : MeasurableSet {x : Ω n | ε / 2 ≤ ‖F n x - z‖} := by
    exact measurableSet_le measurable_const ((hF n).sub stronglyMeasurable_const).norm.measurable
  have hh := integral_deviation_le_bad_mass (μ n) (F n) z B (ε / 2) hB
    (by positivity) (hF n).aestronglyMeasurable (hbound n) _ hA
    (fun x hx => (lt_of_not_ge hx).le)
  have hmass : 0 ≤ (μ n).real {x | ε / 2 ≤ ‖F n x - z‖} := measureReal_nonneg
  have hprod : (B + ‖z‖ + 1) * (μ n).real {x | ε / 2 ≤ ‖F n x - z‖} < ε / 2 := by
    rw [mul_comm]
    apply (lt_div_iff₀ hC).mp
    simpa only [div_div] using hn
  exact hh.trans_lt (by nlinarith)

end NeuralGeneralization
