import NeuralGeneralization.EntropySupportedEvent
import NeuralGeneralization.SamplingLaw
import Mathlib.MeasureTheory.Constructions.Pi
import Mathlib.MeasureTheory.Integral.Pi

/-! The unlabeled-pool entropy lemma. One event controls every posterior
supported on the observed stability checks, even after arbitrary later data. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal
open scoped BigOperators
open Classical
namespace NeuralGeneralization.UnlabeledStability
variable {W X : Type*} [MeasurableSpace W] [MeasurableSpace X]

def instability (D : Measure X) (stable : W → X → Prop) (w : W) : ℝ :=
  D.real {x | ¬ stable w x}

def poolEvent (stable : W → X → Prop) {m : ℕ} (s : Fin m → X) : Set W :=
  {w | ∀ i, stable w (s i)}

lemma measurable_instability (D : Measure X) [IsProbabilityMeasure D]
    (stable : W → X → Prop) (hs : MeasurableSet {p : W × X | stable p.1 p.2}) :
    Measurable (instability D stable) := by
  exact (measurable_measure_prodMk_left hs.compl).ennreal_toReal

lemma instability_nonneg (D : Measure X) (stable : W → X → Prop) (w : W) :
    0 ≤ instability D stable w := measureReal_nonneg

lemma instability_le_one (D : Measure X) [IsProbabilityMeasure D]
    (stable : W → X → Prop) (w : W) : instability D stable w ≤ 1 :=
  measureReal_le_one

lemma measurable_poolEvent (stable : W → X → Prop)
    (hs : MeasurableSet {p : W × X | stable p.1 p.2}) {m : ℕ} (s : Fin m → X) :
    MeasurableSet (poolEvent stable s) := by
  unfold poolEvent
  simp only [Set.setOf_forall]
  apply MeasurableSet.iInter
  intro i
  exact hs.preimage (measurable_id.prodMk measurable_const)

lemma measurable_pool_pairs (stable : W → X → Prop)
    (hs : MeasurableSet {p : W × X | stable p.1 p.2}) (m : ℕ) :
    MeasurableSet {p : (Fin m → X) × W | p.2 ∈ poolEvent stable p.1} := by
  change MeasurableSet {p : (Fin m → X) × W | ∀ i, stable p.2 (p.1 i)}
  simp only [Set.setOf_forall]
  apply MeasurableSet.iInter
  intro i
  exact hs.preimage (measurable_snd.prodMk ((measurable_pi_apply i).comp measurable_fst))

/-- Exact probability of all m checks for a fixed hypothesis. -/
lemma pool_probability (D : Measure X) [IsProbabilityMeasure D]
    (stable : W → X → Prop) (hs : MeasurableSet {p : W × X | stable p.1 p.2})
    (m : ℕ) (w : W) :
    (Measure.pi (fun _ : Fin m => D)).real {s | w ∈ poolEvent stable s} =
      (1-instability D stable w)^m := by
  have hset : {s : Fin m → X | w ∈ poolEvent stable s} =
      Set.univ.pi (fun _ : Fin m => {x | stable w x}) := by ext s; simp [poolEvent]
  rw [Measure.real, hset, Measure.pi_pi]
  simp only [Finset.prod_const, Finset.card_univ, Fintype.card_fin, ENNReal.toReal_pow]
  have hm : MeasurableSet {x | stable w x} := hs.preimage (measurable_const.prodMk measurable_id)
  have hh := probReal_compl_eq_one_sub hm (μ := D)
  change instability D stable w = 1-D.real {x | stable w x} at hh
  have he : (D {x | stable w x}).toReal = 1-instability D stable w := by
    change D.real {x | stable w x} = _
    linarith
  rw [he]

lemma exp_survival_le_one {b : ℝ} (hb : 0 ≤ b) (hb1 : b ≤ 1) (m : ℕ) :
    Real.exp ((m:ℝ)*b/2)*(1-b)^m ≤ 1 := by
  have he : 1-b ≤ Real.exp (-b) := by linarith [Real.add_one_le_exp (-b)]
  have hp := pow_le_pow_left₀ (by linarith : 0 ≤ 1-b) he m
  calc
    _ ≤ Real.exp ((m:ℝ)*b/2)*(Real.exp (-b))^m :=
      mul_le_mul_of_nonneg_left hp (Real.exp_pos _).le
    _ = Real.exp (-(m:ℝ)*b/2) := by
      rw [← Real.exp_nat_mul, ← Real.exp_add]
      congr 1
      ring
    _ ≤ 1 := Real.exp_le_one_iff.mpr (by nlinarith [(Nat.cast_nonneg m : (0:ℝ) ≤ m)])

def poolMoment (G : Measure W) (D : Measure X) (stable : W → X → Prop)
    (m : ℕ) (s : Fin m → X) : ℝ :=
  ∫ w, (poolEvent stable s).indicator (fun w => Real.exp ((m:ℝ)*instability D stable w/2)) w ∂G

lemma pool_integrand_integrable (G : Measure W) [IsProbabilityMeasure G]
    (D : Measure X) [IsProbabilityMeasure D] (stable : W → X → Prop)
    (hs : MeasurableSet {p : W × X | stable p.1 p.2}) (m : ℕ) :
    Integrable (fun p : (Fin m → X) × W =>
      (poolEvent stable p.1).indicator (fun w => Real.exp ((m:ℝ)*instability D stable w/2)) p.2)
      ((Measure.pi (fun _ : Fin m => D)).prod G) := by
  have hm : Measurable (fun p : (Fin m → X) × W =>
      (poolEvent stable p.1).indicator (fun w => Real.exp ((m:ℝ)*instability D stable w/2)) p.2) := by
    exact (((measurable_instability D stable hs).comp measurable_snd).const_mul (m:ℝ)).div_const 2 |>.exp |>.indicator (measurable_pool_pairs stable hs m)
  apply Integrable.of_bound hm.aestronglyMeasurable (Real.exp ((m:ℝ)/2))
  filter_upwards [] with p
  by_cases hp : p.2 ∈ poolEvent stable p.1
  · simp only [Set.indicator_of_mem hp, Real.norm_eq_abs, abs_of_pos (Real.exp_pos _)]
    apply Real.exp_le_exp.mpr
    have hh := mul_le_mul_of_nonneg_left (instability_le_one D stable p.2) (Nat.cast_nonneg m : (0:ℝ) ≤ m)
    linarith
  · simp [hp, (Real.exp_pos ((m:ℝ)/2)).le]

lemma poolMoment_nonneg (G : Measure W) (D : Measure X) (stable : W → X → Prop)
    (m : ℕ) (s : Fin m → X) : 0 ≤ poolMoment G D stable m s := by
  apply integral_nonneg
  intro w
  exact Set.indicator_nonneg (fun _ _ => (Real.exp_pos _).le) _

lemma poolMoment_integrable (G : Measure W) [IsProbabilityMeasure G]
    (D : Measure X) [IsProbabilityMeasure D] (stable : W → X → Prop)
    (hs : MeasurableSet {p : W × X | stable p.1 p.2}) (m : ℕ) :
    Integrable (poolMoment G D stable m) (Measure.pi (fun _ : Fin m => D)) :=
  (pool_integrand_integrable G D stable hs m).integral_prod_left

/-- The moment bound uses the actual IID input law and the actual prior. -/
theorem poolMoment_expectation_le_one (G : Measure W) [IsProbabilityMeasure G]
    (D : Measure X) [IsProbabilityMeasure D] (stable : W → X → Prop)
    (hs : MeasurableSet {p : W × X | stable p.1 p.2}) (m : ℕ) :
    (∫ s,poolMoment G D stable m s ∂Measure.pi (fun _ : Fin m => D)) ≤ 1 := by
  unfold poolMoment
  rw [integral_integral_swap (pool_integrand_integrable G D stable hs m)]
  have he (w : W) : (∫ s,(poolEvent stable s).indicator
      (fun w => Real.exp ((m:ℝ)*instability D stable w/2)) w ∂Measure.pi (fun _ : Fin m => D)) =
      Real.exp ((m:ℝ)*instability D stable w/2)*(1-instability D stable w)^m := by
    have hset : MeasurableSet {s : Fin m → X | w ∈ poolEvent stable s} :=
      (measurable_pool_pairs stable hs m).preimage (measurable_id.prodMk measurable_const)
    change (∫ s, {s : Fin m → X | w ∈ poolEvent stable s}.indicator
      (fun _ => Real.exp ((m:ℝ)*instability D stable w/2)) s ∂Measure.pi (fun _ : Fin m => D)) = _
    rw [integral_indicator hset, integral_const]
    simp only [smul_eq_mul, Measure.real, Measure.restrict_apply_univ]
    change (Measure.pi (fun _ : Fin m => D)).real {s | w ∈ poolEvent stable s} * _ = _
    rw [pool_probability D stable hs m w, mul_comm]
  simp_rw [he]
  apply (integral_mono_of_nonneg (Filter.Eventually.of_forall (fun w => mul_nonneg (Real.exp_pos _).le
      (pow_nonneg (by linarith [instability_le_one D stable w]) _)))
    (integrable_const (1:ℝ)) (Filter.Eventually.of_forall (fun w =>
      exp_survival_le_one (instability_nonneg D stable w) (instability_le_one D stable w) m))).trans_eq
  simp

/-- One pool event simultaneously controls every finite-KL posterior supported
on the observed checks. Its choice may depend on any additional labeled data. -/
theorem uniform_pool_coverage (G : Measure W) [IsProbabilityMeasure G]
    (D : Measure X) [IsProbabilityMeasure D] (stable : W → X → Prop)
    (hs : MeasurableSet {p : W × X | stable p.1 p.2})
    (m : ℕ) (hm : 0 < m) {δ : ℝ} (hδ : 0 < δ) :
    ∃ E : Set (Fin m → X), MeasurableSet E ∧
      1-δ ≤ (Measure.pi (fun _ : Fin m => D)).real E ∧
      ∀ s ∈ E, ∀ Q : Measure W, ∀ _ : IsProbabilityMeasure Q,
        klDiv Q G ≠ ∞ → (∀ᵐ w ∂Q,w ∈ poolEvent stable s) →
        (∫ w,instability D stable w ∂Q) ≤
          (2/(m:ℝ))*((klDiv Q G).toReal+Real.log (1/δ)) := by
  let E : Set (Fin m → X) := {s | poolMoment G D stable m s ≤ 1/δ}
  have hmeas : Measurable (poolMoment G D stable m) := by
    have hh : Measurable (fun p : (Fin m → X) × W =>
      (poolEvent stable p.1).indicator (fun w => Real.exp ((m:ℝ)*instability D stable w/2)) p.2) :=
      (((measurable_instability D stable hs).comp measurable_snd).const_mul (m:ℝ)).div_const 2 |>.exp |>.indicator (measurable_pool_pairs stable hs m)
    exact hh.stronglyMeasurable.integral_prod_right'.measurable
  have hE : MeasurableSet E := measurableSet_le hmeas measurable_const
  have hmark := mul_meas_ge_le_integral_of_nonneg
    (Filter.Eventually.of_forall (poolMoment_nonneg G D stable m))
    (poolMoment_integrable G D stable hs m) (1/δ)
  have htail : (Measure.pi (fun _ : Fin m => D)).real Eᶜ ≤ δ := by
    have hsub : Eᶜ ⊆ {s | 1/δ ≤ poolMoment G D stable m s} := by
      intro s h
      exact (lt_of_not_ge (show ¬ poolMoment G D stable m s ≤ 1/δ from h)).le
    have hh := hmark.trans (poolMoment_expectation_le_one G D stable hs m)
    have ht : (Measure.pi (fun _ : Fin m => D)).real {s | 1/δ ≤ poolMoment G D stable m s} ≤ δ := by
      have hc := (mul_le_mul_iff_right₀ (one_div_pos.mpr hδ)).mp (show
        (1/δ)*(Measure.pi (fun _ : Fin m => D)).real {s | 1/δ ≤ poolMoment G D stable m s} ≤ (1/δ)*δ by
          simpa [hδ.ne'] using hh)
      exact hc
    exact (measureReal_mono hsub).trans ht
  refine ⟨E,hE,?_,?_⟩
  · rw [probReal_compl_eq_one_sub hE] at htail
    linarith
  · intro s hsE Q hQ hKL hsupport
    letI := hQ
    have hi : Integrable (instability D stable) Q := by
      apply Integrable.of_bound (measurable_instability D stable hs).aestronglyMeasurable 1
      exact Filter.Eventually.of_forall (fun w => by
        rw [Real.norm_of_nonneg (instability_nonneg D stable w)]
        exact instability_le_one D stable w)
    have he : Integrable ((poolEvent stable s).indicator
        (fun w => Real.exp ((m:ℝ)*instability D stable w/2))) G := by
      apply Integrable.of_bound
        (((measurable_instability D stable hs).const_mul (m:ℝ)).div_const 2 |>.exp |>.indicator
          (measurable_poolEvent stable hs s)).aestronglyMeasurable (Real.exp ((m:ℝ)/2))
      filter_upwards [] with w
      by_cases hw : w ∈ poolEvent stable s
      · simp only [Set.indicator_of_mem hw, Real.norm_eq_abs, abs_of_pos (Real.exp_pos _)]
        apply Real.exp_le_exp.mpr
        have hh := mul_le_mul_of_nonneg_left (instability_le_one D stable w) (Nat.cast_nonneg m : (0:ℝ) ≤ m)
        linarith
      · simp [hw, (Real.exp_pos ((m:ℝ)/2)).le]
    have hh := RobustEntropyMoments.integral_le_kl_add_on_support Q G hKL
      (poolEvent stable s) (measurable_poolEvent stable hs s) hsupport
      (fun w => (m:ℝ)*instability D stable w/2) ((hi.const_mul _).div_const _) he
      (Real.log (1/δ)) (by rw [Real.exp_log (one_div_pos.mpr hδ)]; exact hsE)
    rw [integral_div, integral_const_mul] at hh
    have hmp : (0:ℝ) < m := by exact_mod_cast hm
    apply (mul_le_mul_iff_right₀ (show (0:ℝ) < (m:ℝ)/2 by positivity)).mp
    have heq : (m:ℝ)/2*((2/(m:ℝ))*((klDiv Q G).toReal+Real.log (1/δ))) =
        (klDiv Q G).toReal+Real.log (1/δ) := by field_simp
    rw [heq]
    nlinarith

end NeuralGeneralization.UnlabeledStability
