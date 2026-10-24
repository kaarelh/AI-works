import NeuralGeneralization.BatchTwoSurvivalStatistics
import Mathlib.MeasureTheory.Measure.Prod

/-! Posterior-mixture error from exact finite-class survival. A compressed
representative is chosen only inside a pointwise proof, never as a measurable
map of the parameters. This applies to continuous as well as finite inputs. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ENNReal
namespace NeuralGeneralization.BatchTwoSurvivalStatistics
variable {X W H : Type*} [MeasurableSpace X] [MeasurableSpace W] [Fintype H]

theorem product_error_le_tail (D : Measure X) (Q : Measure W)
    [IsProbabilityMeasure D] [IsProbabilityMeasure Q]
    (A : Set (X × W)) (hA : MeasurableSet A) (E : Set W) (hE : MeasurableSet E)
    {τ β : ℝ} (hτ : 0 ≤ τ) (htail : Q.real E ≤ β)
    (hgood : ∀ᵐ w ∂Q, w ∉ E → D.real ((fun x => (x,w)) ⁻¹' A) ≤ τ) :
    (D.prod Q).real A ≤ τ+β := by
  classical
  have hpoint : ∀ᵐ w ∂Q, D ((fun x => (x,w)) ⁻¹' A) ≤
      ENNReal.ofReal τ+E.indicator (fun _ => (1 : ℝ≥0∞)) w := by
    filter_upwards [hgood] with w hw
    by_cases he : w ∈ E
    · rw [Set.indicator_of_mem he]
      exact ((measure_mono (Set.subset_univ _)).trans_eq (measure_univ : D Set.univ=1)).trans
        (le_add_of_nonneg_left (show (0 : ℝ≥0∞) ≤ ENNReal.ofReal τ from bot_le))
    · rw [Set.indicator_of_notMem he,add_zero]
      exact (ENNReal.toReal_le_toReal (measure_ne_top _ _) ENNReal.ofReal_ne_top).mp
        (by simpa only [ENNReal.toReal_ofReal hτ,Measure.real] using hw he)
  have hbound : (D.prod Q) A ≤ ENNReal.ofReal τ+Q E := by
    rw [Measure.prod_apply_symm hA]
    apply (lintegral_mono_ae hpoint).trans
    rw [lintegral_add_left measurable_const,lintegral_const,measure_univ,mul_one,
      lintegral_indicator_const hE,one_mul]
  have hr := ENNReal.toReal_mono (ENNReal.add_ne_top.mpr ⟨ENNReal.ofReal_ne_top,measure_ne_top _ _⟩) hbound
  rw [ENNReal.toReal_add ENNReal.ofReal_ne_top (measure_ne_top _ _),ENNReal.toReal_ofReal hτ] at hr
  change (D.prod Q).real A ≤ τ+Q.real E at hr
  linarith

theorem finite_cover_posterior_error (D : Measure X) (Q : Measure W)
    [IsProbabilityMeasure D] [IsProbabilityMeasure Q]
    (A : Set (X × W)) (hA : MeasurableSet A)
    (B : H → Set X) {n : ℕ} (sample : Fin n → X) {τ β : ℝ} (hτ : 0 ≤ τ)
    (hs : sample ∉ badSamples D B n τ)
    (E : Set W) (hE : MeasurableSet E) (htail : Q.real E ≤ β)
    (hgood : ∀ᵐ w ∂Q, w ∉ E → ∃ h, sample ∈ survives (B h) n ∧
      D.real ((fun x => (x,w)) ⁻¹' A) ≤ D.real (B h)) :
    (D.prod Q).real A ≤ τ+β := by
  apply product_error_le_tail D Q A hA E hE hτ htail
  filter_upwards [hgood] with w hw
  intro he
  obtain ⟨h,htrain,hcover⟩ := hw he
  apply hcover.trans
  apply le_of_not_gt
  intro hh
  exact hs ⟨h,hh,htrain⟩

end NeuralGeneralization.BatchTwoSurvivalStatistics
