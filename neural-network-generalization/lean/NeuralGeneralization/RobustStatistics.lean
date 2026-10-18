import NeuralGeneralization.IIDHoeffding
import Mathlib.MeasureTheory.Integral.Bochner.Set
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.FunProp
import Mathlib.Tactic.Push

/-!
# One finite-class sample event for all posterior indices

The sample law below is the actual product of the input distribution.
The event depends only on the fixed finite class of bounded losses.  In
particular, subsequent laws on the candidates may depend on the sample,
width, or Gaussian scale without requiring another union bound.
-/

noncomputable section
open scoped BigOperators
open MeasureTheory ProbabilityTheory

namespace NeuralGeneralization.RobustStatistics

variable {X H : Type*} [MeasurableSpace X] [Fintype H]

def empiricalLoss (loss : H → X → ℝ) {n : ℕ} (s : Fin n → X) (h : H) : ℝ :=
  (∑ i, loss h (s i)) / n

def generalizationEvent (D : Measure X) (loss : H → X → ℝ)
    (n : ℕ) (τ : ℝ) : Set (Fin n → X) :=
  {s | ∀ h, (∫ x, loss h x ∂D) ≤ empiricalLoss loss s h + τ}

theorem measurable_generalizationEvent (D : Measure X) (loss : H → X → ℝ)
    (hloss : ∀ h, Measurable (loss h)) (n : ℕ) (τ : ℝ) :
    MeasurableSet (generalizationEvent D loss n τ) := by
  classical
  unfold generalizationEvent
  simp only [Set.setOf_forall]
  apply MeasurableSet.iInter
  intro h
  apply measurableSet_le measurable_const
  unfold empiricalLoss
  fun_prop

theorem finite_class_bad_probability (D : Measure X) [IsProbabilityMeasure D]
    (loss : H → X → ℝ) (hloss : ∀ h, Measurable (loss h))
    (hbound : ∀ h x, 0 ≤ loss h x ∧ loss h x ≤ 1)
    (n : ℕ) (hn : 0 < n) (τ : ℝ) (hτ : 0 ≤ τ) :
    (CompressionSampling.iidSamples D n).real
      (generalizationEvent D loss n τ)ᶜ ≤
      2 * (Fintype.card H : ℝ) * Real.exp (-(n : ℝ) * τ ^ 2 / 2) := by
  classical
  let μ := CompressionSampling.iidSamples D n
  let E : H → Set (Fin n → X) := fun h =>
    {s | (n : ℝ) * τ ≤
      |(∑ i, loss h (s i)) - (n : ℝ) * ∫ x, loss h x ∂D|}
  have hnR : 0 < (n : ℝ) := by exact_mod_cast hn
  have hsub : (generalizationEvent D loss n τ)ᶜ ⊆ ⋃ h, E h := by
    intro s hs
    have hs' : ¬ ∀ h, (∫ x, loss h x ∂D) ≤ empiricalLoss loss s h + τ := hs
    obtain ⟨h, hh⟩ := not_forall.mp hs'
    refine Set.mem_iUnion.mpr ⟨h, ?_⟩
    have hh' := lt_of_not_ge hh
    have hmul := (mul_lt_mul_of_pos_right hh' hnR)
    have hemp : empiricalLoss loss s h * (n : ℝ) = ∑ i, loss h (s i) := by
      unfold empiricalLoss
      exact div_mul_cancel₀ _ hnR.ne'
    rw [add_mul, hemp] at hmul
    have hd : (n : ℝ) * τ ≤
        -((∑ i, loss h (s i)) - (n : ℝ) * ∫ x, loss h x ∂D) := by
      nlinarith [hmul]
    exact hd.trans (neg_le_abs _)
  have hE (h : H) : μ.real (E h) ≤ 2 * Real.exp (-(n : ℝ) * τ ^ 2 / 2) := by
    have ht := CompressionSampling.iid_bounded_sum_tail D n (loss h) (hloss h)
      (B := 1) (by norm_num)
      (fun x => (abs_of_nonneg (hbound h x).1).trans_le (hbound h x).2)
      (mul_nonneg hnR.le hτ)
    have he : -((n : ℝ) * τ) ^ 2 / (2 * (n : ℝ) * (1 : ℝ) ^ 2) =
        -(n : ℝ) * τ ^ 2 / 2 := by
      field_simp
    simpa only [he] using ht
  calc
    μ.real (generalizationEvent D loss n τ)ᶜ ≤ μ.real (⋃ h, E h) :=
      measureReal_mono hsub
    _ ≤ ∑ h, μ.real (E h) := measureReal_iUnion_fintype_le _
    _ ≤ ∑ _h : H, 2 * Real.exp (-(n : ℝ) * τ ^ 2 / 2) :=
      Finset.sum_le_sum (fun h _ => hE h)
    _ = _ := by simp; ring

theorem finite_class_good_probability (D : Measure X) [IsProbabilityMeasure D]
    (loss : H → X → ℝ) (hloss : ∀ h, Measurable (loss h))
    (hbound : ∀ h x, 0 ≤ loss h x ∧ loss h x ≤ 1)
    (n : ℕ) (hn : 0 < n) (τ δ : ℝ) (hτ : 0 ≤ τ)
    (hsize : 2 * (Fintype.card H : ℝ) * Real.exp (-(n : ℝ) * τ ^ 2 / 2) ≤ δ) :
    1 - δ ≤ (CompressionSampling.iidSamples D n).real
      (generalizationEvent D loss n τ) := by
  have hbad := (finite_class_bad_probability D loss hloss hbound n hn τ hτ).trans hsize
  rw [probReal_compl_eq_one_sub (measurable_generalizationEvent D loss hloss n τ)] at hbad
  linarith

theorem hoeffding_prefactor_le_of_log_budget [Nonempty H]
    {n : ℕ} {τ δ E : ℝ} (hδ : 0 < δ)
    (hentropy : Real.log (Fintype.card H : ℝ) ≤ E)
    (hbudget : 2 * (E + Real.log (2 / δ)) ≤ (n : ℝ) * τ ^ 2) :
    2 * (Fintype.card H : ℝ) * Real.exp (-(n : ℝ) * τ ^ 2 / 2) ≤ δ := by
  have hcard : 0 < (Fintype.card H : ℝ) := by exact_mod_cast Fintype.card_pos
  have hlog : -(n : ℝ) * τ ^ 2 / 2 ≤
      -(Real.log (Fintype.card H : ℝ) + Real.log (2 / δ)) := by linarith
  have he := Real.exp_le_exp.mpr hlog
  have hid : Real.exp (-(Real.log (Fintype.card H : ℝ) + Real.log (2 / δ))) =
      δ / (2 * (Fintype.card H : ℝ)) := by
    rw [Real.exp_neg, Real.exp_add, Real.exp_log hcard, Real.exp_log (div_pos (by norm_num) hδ)]
    field_simp
  rw [hid] at he
  have hm := mul_le_mul_of_nonneg_left he (show 0 ≤ 2 * (Fintype.card H : ℝ) by positivity)
  have hc : 2 * (Fintype.card H : ℝ) * (δ / (2 * (Fintype.card H : ℝ))) = δ := by
    field_simp
  simpa only [hc] using hm

theorem finite_class_good_probability_log [Nonempty H]
    (D : Measure X) [IsProbabilityMeasure D]
    (loss : H → X → ℝ) (hloss : ∀ h, Measurable (loss h))
    (hbound : ∀ h x, 0 ≤ loss h x ∧ loss h x ≤ 1)
    (n : ℕ) (hn : 0 < n) {τ δ E : ℝ} (hτ : 0 ≤ τ) (hδ : 0 < δ)
    (hentropy : Real.log (Fintype.card H : ℝ) ≤ E)
    (hbudget : 2 * (E + Real.log (2 / δ)) ≤ (n : ℝ) * τ ^ 2) :
    1 - δ ≤ (CompressionSampling.iidSamples D n).real
      (generalizationEvent D loss n τ) :=
  finite_class_good_probability D loss hloss hbound n hn τ δ hτ
    (hoeffding_prefactor_le_of_log_budget hδ hentropy hbudget)

theorem integrable_finite_domain {A : Type*} [Fintype A] [MeasurableSpace A]
    [MeasurableSingletonClass A] (μ : Measure A) [IsFiniteMeasure μ] (g : A → ℝ) :
    Integrable g μ := by
  simpa only [integrableOn_univ] using
    (IntegrableOn.of_finite (μ := μ) (f := g) Set.finite_univ)

theorem averaged_generalization [MeasurableSpace H] [MeasurableSingletonClass H]
    (D : Measure X) (loss : H → X → ℝ) {n : ℕ} {τ : ℝ}
    (s : Fin n → X) (hs : s ∈ generalizationEvent D loss n τ)
    (Γ : Measure H) [IsProbabilityMeasure Γ] :
    (∫ h, ∫ x, loss h x ∂D ∂Γ) ≤
      (∑ i, ∫ h, loss h (s i) ∂Γ) / n + τ := by
  have h := integral_mono
    (integrable_finite_domain Γ (fun h => ∫ x, loss h x ∂D))
    ((integrable_finite_domain Γ (empiricalLoss loss s)).add (integrable_const τ)) hs
  simp only [Pi.add_apply] at h
  rw [integral_add (integrable_finite_domain Γ (empiricalLoss loss s)) (integrable_const τ)] at h
  have hemp : (∫ h, empiricalLoss loss s h ∂Γ) =
      (∑ i, ∫ h, loss h (s i) ∂Γ) / n := by
    unfold empiricalLoss
    rw [integral_div, integral_finsetSum]
    intro i hi
    exact integrable_finite_domain Γ _
  simpa only [hemp, integral_const, probReal_univ, smul_eq_mul, one_mul] using h

/-- The deterministic learning step, on the single fixed-class sample event.
Both the posterior and its candidate law may be selected after seeing the sample.
The comparisons here are supplied by the pointwise coupling theorem. -/
theorem risk_on_generalization_event [Fintype X] [MeasurableSingletonClass X]
    [MeasurableSpace H] [MeasurableSingletonClass H]
    (D : Measure X) [IsProbabilityMeasure D] (loss : H → X → ℝ)
    {n : ℕ} (hn : 0 < n) {τ α β : ℝ}
    (s : Fin n → X) (hs : s ∈ generalizationEvent D loss n τ)
    (Γ : Measure H) [IsProbabilityMeasure Γ]
    (risk retainedRisk : X → ℝ)
    (hrestore : ∀ x, risk x ≤ β + retainedRisk x)
    (hcompare : ∀ x, retainedRisk x ≤ α + ∫ h, loss h x ∂Γ)
    (htrain : ∀ i, (∫ h, loss h (s i) ∂Γ) ≤ α) :
    (∫ x, risk x ∂D) ≤ β + 2 * α + τ := by
  have hnR : 0 < (n : ℝ) := by exact_mod_cast hn
  have he := averaged_generalization D loss s hs Γ
  have ht : (∑ i, ∫ h, loss h (s i) ∂Γ) / n ≤ α := by
    apply (div_le_iff₀ hnR).mpr
    calc
      _ ≤ ∑ _i : Fin n, α := Finset.sum_le_sum (fun i _ => htrain i)
      _ = _ := by simp [mul_comm]
  have hp : (∫ x, risk x ∂D) ≤
      ∫ x, β + α + ∫ h, loss h x ∂Γ ∂D := by
    apply integral_mono (integrable_finite_domain D _) (integrable_finite_domain D _)
    intro x
    linarith [hrestore x, hcompare x]
  have hswap : (∫ x, ∫ h, loss h x ∂Γ ∂D) =
      ∫ h, ∫ x, loss h x ∂D ∂Γ := by
    exact integral_integral_swap (integrable_finite_domain (D.prod Γ) _)
  rw [integral_add (integrable_const (β + α)) (integrable_finite_domain D _),
    integral_const, probReal_univ, smul_eq_mul, one_mul, hswap] at hp
  linarith

end NeuralGeneralization.RobustStatistics
