import NeuralGeneralization.RobustPinsker
import Mathlib.MeasureTheory.Measure.Prod
import Mathlib.MeasureTheory.Measure.Sub

/-!
# Explicit common-part couplings

The construction couples a common submeasure on the diagonal and couples
the two remaining measures independently. Its marginal and disagreement
claims are proved for actual Borel probability measures on the real line.
-/

noncomputable section
open MeasureTheory Set
open scoped ENNReal

namespace NeuralGeneralization.RobustCoupling

def commonCoupling (μ ν ρ : Measure ℝ) : Measure (ℝ × ℝ) :=
  if (μ - ρ) univ = 0 then μ.map (fun x => (x, x))
  else ρ.map (fun x => (x, x)) +
    ((μ - ρ) univ)⁻¹ • ((μ - ρ).prod (ν - ρ))

theorem map_fst_diagonal (μ : Measure ℝ) :
    (μ.map (fun x => (x, x))).map Prod.fst = μ := by
  have hd : Measurable (fun x : ℝ => (x, x)) := measurable_id.prodMk measurable_id
  rw [Measure.map_map measurable_fst hd]
  exact Measure.map_id

theorem map_snd_diagonal (μ : Measure ℝ) :
    (μ.map (fun x => (x, x))).map Prod.snd = μ := by
  have hd : Measurable (fun x : ℝ => (x, x)) := measurable_id.prodMk measurable_id
  rw [Measure.map_map measurable_snd hd]
  exact Measure.map_id

theorem commonCoupling_fst (μ ν ρ : Measure ℝ)
    [IsProbabilityMeasure μ] [IsProbabilityMeasure ν] [IsFiniteMeasure ρ]
    (hρμ : ρ ≤ μ) (hρν : ρ ≤ ν) :
    (commonCoupling μ ν ρ).map Prod.fst = μ := by
  letI : IsFiniteMeasure (μ - ρ) := isFiniteMeasure_of_le μ Measure.sub_le
  letI : IsFiniteMeasure (ν - ρ) := isFiniteMeasure_of_le ν Measure.sub_le
  have hmass : (ν - ρ) univ = (μ - ρ) univ := by
    rw [Measure.sub_apply MeasurableSet.univ hρν,
      Measure.sub_apply MeasurableSet.univ hρμ]
    simp only [measure_univ]
  by_cases hz : (μ - ρ) univ = 0
  · simp [commonCoupling, hz, map_fst_diagonal]
  · rw [commonCoupling, if_neg hz, Measure.map_add _ _ measurable_fst,
      map_fst_diagonal, Measure.map_smul, Measure.map_fst_prod, hmass,
      smul_smul, ENNReal.inv_mul_cancel hz (measure_ne_top _ _), one_smul,
      add_comm, Measure.sub_add_cancel_of_le hρμ]

theorem commonCoupling_snd (μ ν ρ : Measure ℝ)
    [IsProbabilityMeasure μ] [IsProbabilityMeasure ν] [IsFiniteMeasure ρ]
    (hρμ : ρ ≤ μ) (hρν : ρ ≤ ν) :
    (commonCoupling μ ν ρ).map Prod.snd = ν := by
  letI : IsFiniteMeasure (μ - ρ) := isFiniteMeasure_of_le μ Measure.sub_le
  letI : IsFiniteMeasure (ν - ρ) := isFiniteMeasure_of_le ν Measure.sub_le
  have hmass : (ν - ρ) univ = (μ - ρ) univ := by
    rw [Measure.sub_apply MeasurableSet.univ hρν,
      Measure.sub_apply MeasurableSet.univ hρμ]
    simp only [measure_univ]
  by_cases hz : (μ - ρ) univ = 0
  · have hμzero : μ - ρ = 0 := Measure.measure_univ_eq_zero.mp hz
    have hνzero : ν - ρ = 0 := Measure.measure_univ_eq_zero.mp (hmass.trans hz)
    have hμeq : ρ = μ := by simpa [hμzero] using Measure.sub_add_cancel_of_le hρμ
    have hνeq : ρ = ν := by simpa [hνzero] using Measure.sub_add_cancel_of_le hρν
    simp [commonCoupling, map_snd_diagonal, ← hμeq, ← hνeq]
  · rw [commonCoupling, if_neg hz, Measure.map_add _ _ measurable_snd,
      map_snd_diagonal, Measure.map_smul, Measure.map_snd_prod,
      smul_smul, ENNReal.inv_mul_cancel hz (measure_ne_top _ _), one_smul,
      add_comm, Measure.sub_add_cancel_of_le hρν]

/-- The explicitly constructed common-part coupling has total mass one. -/
theorem commonCoupling_isProbability (μ ν ρ : Measure ℝ)
    [IsProbabilityMeasure μ] [IsProbabilityMeasure ν] [IsFiniteMeasure ρ]
    (hρμ : ρ ≤ μ) (hρν : ρ ≤ ν) :
    IsProbabilityMeasure (commonCoupling μ ν ρ) := by
  constructor
  have hf := commonCoupling_fst μ ν ρ hρμ hρν
  have hh := congrArg (fun m : Measure ℝ => m univ) hf
  rw [Measure.map_apply measurable_fst MeasurableSet.univ] at hh
  simpa using hh

/-- The diagonal common mass never contributes to disagreement. -/
theorem commonCoupling_disagreement_le (μ ν ρ : Measure ℝ)
    [IsProbabilityMeasure μ] [IsProbabilityMeasure ν] [IsFiniteMeasure ρ]
    (hρμ : ρ ≤ μ) (hρν : ρ ≤ ν) :
    commonCoupling μ ν ρ {p | p.1 ≠ p.2} ≤ (μ - ρ) univ := by
  letI : IsFiniteMeasure (μ - ρ) := isFiniteMeasure_of_le μ Measure.sub_le
  letI : IsFiniteMeasure (ν - ρ) := isFiniteMeasure_of_le ν Measure.sub_le
  have hd : Measurable (fun x : ℝ => (x, x)) := measurable_id.prodMk measurable_id
  have he : MeasurableSet {p : ℝ × ℝ | p.1 ≠ p.2} :=
    (measurableSet_eq_fun measurable_fst measurable_snd).compl
  have hdiag (m : Measure ℝ) : m.map (fun x => (x, x)) {p | p.1 ≠ p.2} = 0 := by
    rw [Measure.map_apply hd he]
    simp
  have hmass : (ν - ρ) univ = (μ - ρ) univ := by
    rw [Measure.sub_apply MeasurableSet.univ hρν,
      Measure.sub_apply MeasurableSet.univ hρμ]
    simp only [measure_univ]
  by_cases hz : (μ - ρ) univ = 0
  · simp [commonCoupling, hz, hdiag]
  · rw [commonCoupling, if_neg hz, Measure.add_apply, hdiag, zero_add]
    calc
      _ ≤ (((μ - ρ) univ)⁻¹ • ((μ - ρ).prod (ν - ρ))) univ :=
        measure_mono (subset_univ _)
      _ = (μ - ρ) univ := by
        rw [Measure.smul_apply, smul_eq_mul, ← univ_prod_univ, Measure.prod_prod, hmass,
          ← mul_assoc, ENNReal.inv_mul_cancel hz (measure_ne_top _ _), one_mul]

def commonPart (μ ν : Measure ℝ) : Measure ℝ :=
  ν.withDensity (fun x => ENNReal.ofReal (min (μ.rnDeriv ν x).toReal 1))

theorem commonPart_le_right (μ ν : Measure ℝ) : commonPart μ ν ≤ ν := by
  have h := withDensity_mono (μ := ν)
    (Filter.Eventually.of_forall (fun x => show
      ENNReal.ofReal (min (μ.rnDeriv ν x).toReal 1) ≤ (1 : ℝ≥0∞) by
        exact (ENNReal.ofReal_le_ofReal (min_le_right _ _)).trans_eq (by simp)))
  simpa [commonPart] using h

theorem commonPart_le_left (μ ν : Measure ℝ) [IsFiniteMeasure μ]
    [IsFiniteMeasure ν] (hac : μ ≪ ν) : commonPart μ ν ≤ μ := by
  have h := withDensity_mono (μ := ν)
    (Filter.Eventually.of_forall (fun x => show
      ENNReal.ofReal (min (μ.rnDeriv ν x).toReal 1) ≤ μ.rnDeriv ν x from
        (ENNReal.ofReal_le_ofReal (min_le_left _ _)).trans ENNReal.ofReal_toReal_le))
  simpa [commonPart, Measure.withDensity_rnDeriv_eq μ ν hac] using h

theorem commonPart_le_left_general (μ ν : Measure ℝ) [IsFiniteMeasure μ]
    [IsFiniteMeasure ν] : commonPart μ ν ≤ μ := by
  have h := withDensity_mono (μ := ν)
    (Filter.Eventually.of_forall (fun x => show
      ENNReal.ofReal (min (μ.rnDeriv ν x).toReal 1) ≤ μ.rnDeriv ν x from
        (ENNReal.ofReal_le_ofReal (min_le_left _ _)).trans ENNReal.ofReal_toReal_le))
  exact h.trans (Measure.withDensity_rnDeriv_le μ ν)

instance commonPart_finite (μ ν : Measure ℝ) [IsFiniteMeasure ν] :
    IsFiniteMeasure (commonPart μ ν) :=
  isFiniteMeasure_of_le ν (commonPart_le_right μ ν)

theorem commonPart_mass (μ ν : Measure ℝ) :
    (commonPart μ ν).real univ = ∫ x, min (μ.rnDeriv ν x).toReal 1 ∂ν := by
  rw [measureReal_def, commonPart, withDensity_apply _ MeasurableSet.univ]
  simp only [Measure.restrict_univ]
  symm
  exact integral_eq_lintegral_of_nonneg_ae
    (Filter.Eventually.of_forall fun _ => le_min ENNReal.toReal_nonneg zero_le_one)
    (((Measure.measurable_rnDeriv μ ν).ennreal_toReal.min measurable_const).aestronglyMeasurable)

theorem residual_mass_le_l1 (μ ν : Measure ℝ)
    [IsProbabilityMeasure μ] [IsProbabilityMeasure ν] (hac : μ ≪ ν) :
    ((μ - commonPart μ ν) univ).toReal ≤
      ∫ x, |(μ.rnDeriv ν x).toReal - 1| ∂ν := by
  have hρ := commonPart_le_left μ ν hac
  have hd : Integrable (fun x => (μ.rnDeriv ν x).toReal) ν :=
    Measure.integrable_toReal_rnDeriv
  have hm : Integrable (fun x => min (μ.rnDeriv ν x).toReal 1) ν := by
    apply (integrable_const (1 : ℝ)).mono'
      (((Measure.measurable_rnDeriv μ ν).ennreal_toReal.min measurable_const).aestronglyMeasurable)
    exact Filter.Eventually.of_forall fun x => by
      rw [Real.norm_of_nonneg (le_min ENNReal.toReal_nonneg zero_le_one)]
      exact min_le_right _ _
  have hsub : (∫ x, (μ.rnDeriv ν x).toReal - min (μ.rnDeriv ν x).toReal 1 ∂ν) =
      1 - (commonPart μ ν).real univ := by
    rw [integral_sub hd hm, Measure.integral_toReal_rnDeriv hac, ← commonPart_mass]
    simp
  have hmass : ((μ - commonPart μ ν) univ).toReal =
      1 - (commonPart μ ν).real univ := by
    rw [Measure.sub_apply MeasurableSet.univ hρ,
      ENNReal.toReal_sub_of_le (hρ univ) (measure_ne_top μ univ)]
    simp [measureReal_def]
  rw [hmass, ← hsub]
  apply integral_mono (hd.sub hm) (hd.sub (integrable_const 1)).abs
  intro x
  change (μ.rnDeriv ν x).toReal - min (μ.rnDeriv ν x).toReal 1 ≤
    |(μ.rnDeriv ν x).toReal - 1|
  by_cases hle : (μ.rnDeriv ν x).toReal ≤ 1
  · rw [min_eq_left hle, sub_self]
    exact abs_nonneg _
  · rw [min_eq_right (le_of_not_ge hle)]
    exact le_abs_self _

def entropyCoupling (μ ν : Measure ℝ) : Measure (ℝ × ℝ) :=
  commonCoupling μ ν (commonPart μ ν)

instance entropyCoupling_isProbability (μ ν : Measure ℝ)
    [IsProbabilityMeasure μ] [IsProbabilityMeasure ν] :
    IsProbabilityMeasure (entropyCoupling μ ν) :=
  commonCoupling_isProbability μ ν (commonPart μ ν)
    (commonPart_le_left_general μ ν) (commonPart_le_right μ ν)

theorem entropyCoupling_fst (μ ν : Measure ℝ)
    [IsProbabilityMeasure μ] [IsProbabilityMeasure ν] :
    (entropyCoupling μ ν).map Prod.fst = μ :=
  commonCoupling_fst μ ν (commonPart μ ν)
    (commonPart_le_left_general μ ν) (commonPart_le_right μ ν)

theorem entropyCoupling_snd (μ ν : Measure ℝ)
    [IsProbabilityMeasure μ] [IsProbabilityMeasure ν] :
    (entropyCoupling μ ν).map Prod.snd = ν :=
  commonCoupling_snd μ ν (commonPart μ ν)
    (commonPart_le_left_general μ ν) (commonPart_le_right μ ν)

/-- Actual probability coupling with a proved Pinsker-type disagreement bound.
The constant is deliberately loose and is enough for polynomial compression. -/
theorem entropyCoupling_disagreement_le (μ ν : Measure ℝ)
    [IsProbabilityMeasure μ] [IsProbabilityMeasure ν]
    (hfinite : InformationTheory.klDiv μ ν ≠ ⊤) :
    (entropyCoupling μ ν).real {p | p.1 ≠ p.2} ≤
      2 * Real.sqrt (InformationTheory.klDiv μ ν).toReal := by
  have hac := (InformationTheory.klDiv_ne_top_iff.mp hfinite).1
  letI : IsFiniteMeasure (μ - commonPart μ ν) := isFiniteMeasure_of_le μ Measure.sub_le
  have hdis := commonCoupling_disagreement_le μ ν (commonPart μ ν)
    (commonPart_le_left_general μ ν) (commonPart_le_right μ ν)
  exact (ENNReal.toReal_mono (measure_ne_top _ _) hdis).trans
    ((residual_mass_le_l1 μ ν hac).trans
      (RobustPinsker.integral_abs_rnDeriv_sub_one_le_sqrt μ ν hfinite))

/-- Parameterized disagreement control is convenient when conditional KL
costs will be added before choosing a tuning parameter. -/
theorem entropyCoupling_disagreement_le_parameter (μ ν : Measure ℝ)
    [IsProbabilityMeasure μ] [IsProbabilityMeasure ν]
    (hfinite : InformationTheory.klDiv μ ν ≠ ⊤) {s : ℝ} (hs : 0 < s) :
    (entropyCoupling μ ν).real {p | p.1 ≠ p.2} ≤
      (InformationTheory.klDiv μ ν).toReal / s + s := by
  have hac := (InformationTheory.klDiv_ne_top_iff.mp hfinite).1
  letI : IsFiniteMeasure (μ - commonPart μ ν) := isFiniteMeasure_of_le μ Measure.sub_le
  have hdis := commonCoupling_disagreement_le μ ν (commonPart μ ν)
    (commonPart_le_left_general μ ν) (commonPart_le_right μ ν)
  exact (ENNReal.toReal_mono (measure_ne_top _ _) hdis).trans
    ((residual_mass_le_l1 μ ν hac).trans
      (RobustPinsker.integral_abs_rnDeriv_sub_one_le μ ν hfinite hs))

/-- A bounded measurable observation loses at most four times the
disagreement mass under any probability law on pairs. -/
theorem bounded_squared_error_le_disagreement (π : Measure (ℝ × ℝ))
    [IsProbabilityMeasure π]
    (g : ℝ → ℝ) (hg : Measurable g) (hbound : ∀ x, |g x| ≤ 1) :
    (∫ p, (g p.1 - g p.2) ^ 2 ∂π) ≤ 4 * π.real {p | p.1 ≠ p.2} := by
  let E : Set (ℝ × ℝ) := {p | p.1 ≠ p.2}
  have hE : MeasurableSet E :=
    (measurableSet_eq_fun measurable_fst measurable_snd).compl
  have hfour (p : ℝ × ℝ) : (g p.1 - g p.2) ^ 2 ≤ 4 := by
    have h1 := abs_le.mp (hbound p.1)
    have h2 := abs_le.mp (hbound p.2)
    nlinarith [sq_nonneg (g p.1 - g p.2)]
  have hi : Integrable (fun p : ℝ × ℝ => (g p.1 - g p.2) ^ 2) π := by
    apply (integrable_const (4 : ℝ)).mono'
      (((hg.comp measurable_fst).sub (hg.comp measurable_snd)).pow_const 2).aestronglyMeasurable
    exact Filter.Eventually.of_forall fun p => by
      rw [Real.norm_of_nonneg (sq_nonneg _)]
      exact hfour p
  have hcomp : (∫ p, (g p.1 - g p.2) ^ 2 ∂π) ≤
      ∫ p, E.indicator (fun _ => (4 : ℝ)) p ∂π := by
    apply integral_mono hi ((integrable_const (4 : ℝ)).indicator hE)
    intro p
    by_cases hp : p ∈ E
    · rw [Set.indicator_of_mem hp]
      exact hfour p
    · have heq : p.1 = p.2 := not_ne_iff.mp hp
      simp [Set.indicator_of_notMem hp, heq]
  rw [integral_indicator_const 4 hE, smul_eq_mul] at hcomp
  simpa only [E, mul_comm] using hcomp

theorem entropyCoupling_bounded_squared_error (μ ν : Measure ℝ)
    [IsProbabilityMeasure μ] [IsProbabilityMeasure ν]
    (hfinite : InformationTheory.klDiv μ ν ≠ ⊤)
    (g : ℝ → ℝ) (hg : Measurable g) (hbound : ∀ x, |g x| ≤ 1) :
    (∫ p, (g p.1 - g p.2) ^ 2 ∂entropyCoupling μ ν) ≤
      8 * Real.sqrt (InformationTheory.klDiv μ ν).toReal := by
  have hc := bounded_squared_error_le_disagreement (entropyCoupling μ ν) g hg hbound
  have hdis := entropyCoupling_disagreement_le μ ν hfinite
  linarith

theorem entropyCoupling_bounded_squared_error_parameter (μ ν : Measure ℝ)
    [IsProbabilityMeasure μ] [IsProbabilityMeasure ν]
    (hfinite : InformationTheory.klDiv μ ν ≠ ⊤) {s : ℝ} (hs : 0 < s)
    (g : ℝ → ℝ) (hg : Measurable g) (hbound : ∀ x, |g x| ≤ 1) :
    (∫ p, (g p.1 - g p.2) ^ 2 ∂entropyCoupling μ ν) ≤
      4 * ((InformationTheory.klDiv μ ν).toReal / s + s) := by
  have hc := bounded_squared_error_le_disagreement (entropyCoupling μ ν) g hg hbound
  have hdis := entropyCoupling_disagreement_le_parameter μ ν hfinite hs
  linarith

end NeuralGeneralization.RobustCoupling
