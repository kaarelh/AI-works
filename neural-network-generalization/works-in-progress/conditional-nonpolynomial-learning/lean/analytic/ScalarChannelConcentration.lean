import NeuralGeneralization.BatchTwoContinuousDepthCriticalControlLLN
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.FunProp

/-! Actual simultaneous concentration of the three scalar-channel statistics.
The coarse Chebyshev rate is sufficient when the width may be exponential in
the Boolean input dimension. No sampling certificate is an assumption. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
open NeuralGeneralization.BatchTwoContinuousDepthCritical
namespace ConditionalAnalytic

variable {Ω J X : Type*} [MeasurableSpace Ω] [Fintype J] [Fintype X]

def finiteMomentEvent (μ : Measure Ω) (F : J → Ω → ℝ) (α : ℝ) (N : ℕ) :
    Set (Fin N → Ω) := {w | ∀ j, |rowAverage (F j) w - ∫ z, F j z ∂μ| < α}

theorem measurableSet_finiteMomentEvent (μ : Measure Ω) (F : J → Ω → ℝ)
    (hF : ∀ j, Measurable (F j)) (α : ℝ) (N : ℕ) :
    MeasurableSet (finiteMomentEvent μ F α N) := by
  simp only [finiteMomentEvent, Set.setOf_forall]
  apply MeasurableSet.iInter
  intro j
  apply measurableSet_lt _ measurable_const
  unfold rowAverage
  fun_prop

theorem finiteMomentEvent_compl_tail (μ : Measure Ω) [IsProbabilityMeasure μ]
    (F : J → Ω → ℝ) (hF : ∀ j, Measurable (F j)) {B α : ℝ}
    (hB : 0 ≤ B) (hb : ∀ j z, |F j z| ≤ B) {N : ℕ} (hN : 0 < N)
    (hα : 0 < α) :
    (Measure.pi fun _ : Fin N => μ).real (finiteMomentEvent μ F α N)ᶜ ≤
      (Fintype.card J : ℝ) * B^2 / ((N : ℝ) * α^2) := by
  classical
  let E : J → Set (Fin N → Ω) := fun j =>
    {w | α ≤ |rowAverage (F j) w - ∫ z, F j z ∂μ|}
  have hmem (j : J) : MemLp (F j) 2 μ :=
    MemLp.of_bound (hF j).aestronglyMeasurable B
      (Filter.Eventually.of_forall fun z => by simpa only [Real.norm_eq_abs] using hb j z)
  have hsq (j : J) : (∫ z, (F j z)^2 ∂μ) ≤ B^2 := by
    have hpoint (z : Ω) : (F j z)^2 ≤ B^2 := by
      have hh := hb j z
      nlinarith [sq_abs (F j z), abs_nonneg (F j z)]
    calc
      _ ≤ ∫ _ : Ω, B^2 ∂μ := integral_mono_of_nonneg
        (Filter.Eventually.of_forall fun z => sq_nonneg (F j z))
        (integrable_const _) (Filter.Eventually.of_forall hpoint)
      _ = B^2 := by simp
  have ht (j : J) : (Measure.pi fun _ : Fin N => μ).real (E j) ≤
      B^2 / ((N : ℝ) * α^2) := iid_rowAverage_tail μ (hmem j) (hsq j) hN hα
  have hsub : (finiteMomentEvent μ F α N)ᶜ ⊆ ⋃ j, E j := by
    intro w hw
    by_contra hn
    apply hw
    intro j
    apply lt_of_not_ge
    intro hj
    exact hn (Set.mem_iUnion.mpr ⟨j, hj⟩)
  calc
    _ ≤ (Measure.pi fun _ : Fin N => μ).real (⋃ j, E j) := measureReal_mono hsub
    _ ≤ ∑ j, (Measure.pi fun _ : Fin N => μ).real (E j) :=
      measureReal_iUnion_fintype_le E
    _ ≤ ∑ _j : J, B^2 / ((N : ℝ) * α^2) := Finset.sum_le_sum fun j _ => ht j
    _ = _ := by simp only [Finset.sum_const, Finset.card_univ, nsmul_eq_mul, mul_div_assoc]

def channelObservables (b : Ω → ℝ) (h : X → Ω → ℝ) :
    Unit ⊕ (X ⊕ X) → Ω → ℝ
  | .inl _ => fun z => (b z)^2
  | .inr (.inl x) => fun z => b z * h x z
  | .inr (.inr x) => fun z => (h x z)^2

theorem channelObservables_measurable (b : Ω → ℝ) (h : X → Ω → ℝ)
    (hb : Measurable b) (hh : ∀ x, Measurable (h x)) :
    ∀ j, Measurable (channelObservables b h j) := by
  rintro (_ | (x | x))
  · exact hb.pow_const 2
  · exact hb.mul (hh x)
  · exact (hh x).pow_const 2

theorem channelObservables_bound (b : Ω → ℝ) (h : X → Ω → ℝ) {B : ℝ}
    (hB : 1 ≤ B) (hb : ∀ z, |b z| ≤ B) (hh : ∀ x z, |h x z| ≤ 1) :
    ∀ j z, |channelObservables b h j z| ≤ B^2 := by
  rintro (_ | (x | x)) z
  · change |(b z)^2| ≤ B^2
    rw [abs_of_nonneg (sq_nonneg _)]
    nlinarith [hb z, abs_nonneg (b z), sq_abs (b z)]
  · change |b z * h x z| ≤ B^2
    rw [abs_mul]
    have hp := mul_le_mul (hb z) (hh x z) (abs_nonneg _) (by linarith : 0 ≤ B)
    nlinarith
  · change |(h x z)^2| ≤ B^2
    rw [abs_of_nonneg (sq_nonneg _)]
    nlinarith [hh x z, abs_nonneg (h x z), sq_abs (h x z)]

/-- Uniform in the source space and in all bounded feature functions. -/
theorem scalar_channel_moment_tail (μ : Measure Ω) [IsProbabilityMeasure μ]
    (b : Ω → ℝ) (h : X → Ω → ℝ) (hb : Measurable b)
    (hh : ∀ x, Measurable (h x)) {B α : ℝ} (hB : 1 ≤ B)
    (hbB : ∀ z, |b z| ≤ B) (hhB : ∀ x z, |h x z| ≤ 1)
    {N : ℕ} (hN : 0 < N) (hα : 0 < α) :
    (Measure.pi fun _ : Fin N => μ).real
      (finiteMomentEvent μ (channelObservables b h) α N)ᶜ ≤
      (1 + 2 * (Fintype.card X : ℝ)) * B^4 / ((N : ℝ) * α^2) := by
  have ht := finiteMomentEvent_compl_tail μ (channelObservables b h)
    (channelObservables_measurable b h hb hh) (sq_nonneg B)
    (channelObservables_bound b h hB hbB hhB) hN hα
  simpa only [Fintype.card_sum, Fintype.card_unit, Nat.cast_add, Nat.cast_one,
    ← pow_mul, show (2 : ℕ) * 2 = 4 from rfl, two_mul] using ht

theorem scalar_channel_moment_probability (μ : Measure Ω) [IsProbabilityMeasure μ]
    (b : Ω → ℝ) (h : X → Ω → ℝ) (hb : Measurable b)
    (hh : ∀ x, Measurable (h x)) {B α κ : ℝ} (hB : 1 ≤ B)
    (hbB : ∀ z, |b z| ≤ B) (hhB : ∀ x z, |h x z| ≤ 1)
    {N : ℕ} (hN : 0 < N) (hα : 0 < α)
    (hwidth : (1 + 2 * (Fintype.card X : ℝ)) * B^4 ≤ κ * ((N : ℝ) * α^2)) :
    1 - κ ≤ (Measure.pi fun _ : Fin N => μ).real
      (finiteMomentEvent μ (channelObservables b h) α N) := by
  have ht := scalar_channel_moment_tail μ b h hb hh hB hbB hhB hN hα
  rw [probReal_compl_eq_one_sub
    (measurableSet_finiteMomentEvent μ _ (channelObservables_measurable b h hb hh) α N)] at ht
  have hden : 0 < (N : ℝ) * α^2 := mul_pos (by exact_mod_cast hN) (sq_pos_of_pos hα)
  have hfrac := (div_le_iff₀ hden).mpr hwidth
  linarith

#print axioms scalar_channel_moment_probability
end ConditionalAnalytic
