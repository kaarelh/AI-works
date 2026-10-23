import NeuralGeneralization.BatchTwoContinuousDepthTeacher
import Mathlib.MeasureTheory.Measure.Real

/-! The paired-input obstruction for arbitrary posterior mixtures. The
balanced pair law is explicit; no choice of one posterior predictor occurs. -/
noncomputable section
open MeasureTheory ProbabilityTheory Set
open scoped ENNReal NNReal
namespace NeuralGeneralization.BatchTwoContinuousDepthLower
open Classical
variable {Ω X W : Type*} [MeasurableSpace Ω] [MeasurableSpace X] [MeasurableSpace W]

def balancedPairLaw (ν : Measure Ω) (left right : Ω → X) : Measure X :=
  (1/2 : ℝ≥0) • ν.map left + (1/2 : ℝ≥0) • ν.map right

theorem balancedPairLaw_real (ν : Measure Ω) [IsProbabilityMeasure ν]
    (left right : Ω → X) (hl : Measurable left) (hr : Measurable right)
    (E : Set X) (hE : MeasurableSet E) :
    (balancedPairLaw ν left right).real E =
      (ν.real (left ⁻¹' E)+ν.real (right ⁻¹' E))/2 := by
  letI : IsProbabilityMeasure (ν.map left) := Measure.isProbabilityMeasure_map hl.aemeasurable
  letI : IsProbabilityMeasure (ν.map right) := Measure.isProbabilityMeasure_map hr.aemeasurable
  rw [balancedPairLaw, measureReal_add_apply, measureReal_nnreal_smul_apply,
    measureReal_nnreal_smul_apply, map_measureReal_apply hl hE, map_measureReal_apply hr hE]
  norm_num
  ring

/-- If the two correct-prediction probabilities never sum to more than twice
the threshold, at least half of the balanced input law fails that threshold. -/
theorem paired_confidence_failure (ν : Measure Ω) [IsProbabilityMeasure ν]
    (left right : Ω → X) (hl : Measurable left) (hr : Measurable right)
    (q : X → ℝ) (hq : Measurable q) (θ : ℝ)
    (hpair : ∀ ω, q (left ω)+q (right ω) ≤ 2*θ) :
    (1/2 : ℝ) ≤ (balancedPairLaw ν left right).real {x | q x ≤ θ} := by
  let E : Set X := {x | q x ≤ θ}
  have hE : MeasurableSet E := measurableSet_le hq measurable_const
  have he : (left ⁻¹' E) ∪ (right ⁻¹' E) = univ := by
    ext ω
    simp only [mem_union,mem_preimage,mem_setOf_eq,mem_univ,iff_true,E]
    by_contra h
    push_neg at h
    linarith [hpair ω]
  have hu := measureReal_union_le (μ := ν) (left ⁻¹' E) (right ⁻¹' E)
  rw [he,probReal_univ] at hu
  rw [balancedPairLaw_real ν left right hl hr E hE]
  linarith

theorem correct_pair_sum_le (Q : Measure W) [IsProbabilityMeasure Q]
    (A B G : Set W) (hB : MeasurableSet B) {β : ℝ}
    (hbad : Q.real Gᶜ ≤ β) (hdisjoint : ∀ w ∈ G, ¬(w ∈ A ∧ w ∈ B)) :
    Q.real A+Q.real B ≤ 1+β := by
  have hi : Q.real (A ∩ B) ≤ β :=
    (measureReal_mono (fun w hw hg => hdisjoint w hg hw)).trans hbad
  have hu : Q.real (A ∪ B) ≤ 1 := by
    simpa using (measureReal_mono (μ := Q) (subset_univ (A ∪ B)))
  have he := measureReal_union_add_inter (μ := Q) (s := A) hB
  linarith

theorem incompatible_correct_outputs {a b u v τ Δ : ℝ}
    (hgap : 1 ≤ |a-b|) (hchange : |u-v| ≤ Δ) (hslack : 2*τ+Δ < 1) :
    ¬(|u-a| ≤ τ ∧ |v-b| ≤ τ) := by
  rintro ⟨hu,hv⟩
  have ht1 := abs_sub_le a u b
  have ht2 := abs_sub_le u v b
  rw [abs_sub_comm a u] at ht1
  linarith

/-- A good predictor can be uniformly within h of a smooth approximant.
The exact constants cover H <= 3^r/10, paired distance <=(13/5)3^-r,
and h <=1/32 from the manuscript. -/
theorem approximate_pair_incompatible {a b u v U V h : ℝ}
    (hgap : 1 ≤ |a-b|) (hchange : |U-V| ≤ 13/50)
    (hu : |u-U| ≤ h) (hv : |v-V| ≤ h) (hh : h ≤ 1/32) :
    ¬(|u-a| ≤ (1/4 : ℝ) ∧ |v-b| ≤ (1/4 : ℝ)) := by
  have ht1 := abs_sub_le u U v
  have ht2 := abs_sub_le U V v
  rw [abs_sub_comm V v] at ht2
  apply incompatible_correct_outputs hgap (Δ := (13/50 : ℝ)+2*h)
  · linarith
  · linarith

/-- The mixture statement with the literal probability of the test-tolerance
event. The good-parameter set can, for example, be a measurable energy ball
whose elements have the required smooth approximations. -/
theorem posterior_pair_sum_le (Q : Measure W) [IsProbabilityMeasure Q]
    (z : W → X → ℝ) (hz : ∀ x, Measurable (fun w => z w x))
    (f : X → ℝ) (G : Set W) {β : ℝ} (hbad : Q.real Gᶜ ≤ β)
    (left right : X)
    (hgood : ∀ w ∈ G, ¬(|z w left-f left| ≤ (1/4 : ℝ) ∧ |z w right-f right| ≤ (1/4 : ℝ))) :
    Q.real {w | |z w left-f left| ≤ (1/4 : ℝ)}+
      Q.real {w | |z w right-f right| ≤ (1/4 : ℝ)} ≤ 1+β := by
  apply correct_pair_sum_le Q _ _ G
    (measurableSet_le (((hz right).sub_const _).abs) measurable_const) hbad
  exact hgood

end NeuralGeneralization.BatchTwoContinuousDepthLower
