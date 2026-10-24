import NeuralGeneralization.RobustStatistics
import Mathlib.MeasureTheory.Integral.Pi
import Mathlib.Analysis.Convex.SpecificFunctions.Basic

/-! A relative finite-class generalization inequality, for the actual IID law.
Unlike an additive Hoeffding estimate, its sample budget is linear in the
inverse target error. It is valid for arbitrary measurable input spaces. -/

noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.BatchTwoRelativeStatistics

theorem exp_neg_unit_le {x : ℝ} (hx : 0 ≤ x) (hx1 : x ≤ 1) :
    Real.exp (-x) ≤ 1 - x / 2 := by
  have h := convexOn_exp.2 (Set.mem_univ (0 : ℝ)) (Set.mem_univ (-1 : ℝ))
    (show 0 ≤ 1-x by linarith) hx (show (1-x)+x=1 by ring)
  have he : Real.exp (-1 : ℝ) ≤ 1 / 2 := by
    rw [Real.exp_neg]
    exact (inv_le_comm₀ (Real.exp_pos _) (by norm_num)).mpr
      (by linarith [Real.add_one_le_exp (1 : ℝ)])
  norm_num at h
  nlinarith [mul_le_mul_of_nonneg_right he hx]

variable {X : Type*} [MeasurableSpace X]

theorem integrable_exp_neg (D : Measure X) [IsProbabilityMeasure D]
    (loss : X → ℝ) (hloss : Measurable loss) (hbound : ∀ x, 0 ≤ loss x) :
    Integrable (fun x => Real.exp (-loss x)) D := by
  apply (integrable_const (1 : ℝ)).mono' (hloss.neg.exp.aestronglyMeasurable)
  filter_upwards [] with x
  rw [Real.norm_eq_abs, abs_of_pos (Real.exp_pos _)]
  exact Real.exp_le_one_iff.mpr (neg_nonpos.mpr (hbound x))

theorem laplace_one_le (D : Measure X) [IsProbabilityMeasure D]
    (loss : X → ℝ) (hloss : Measurable loss)
    (hbound : ∀ x, 0 ≤ loss x ∧ loss x ≤ 1) :
    (∫ x, Real.exp (-loss x) ∂D) ≤ Real.exp (-(∫ x, loss x ∂D) / 2) := by
  have hi : Integrable loss D := by
    apply (integrable_const (1 : ℝ)).mono' hloss.aestronglyMeasurable
    filter_upwards [] with x
    simpa [Real.norm_eq_abs, abs_of_nonneg (hbound x).1] using (hbound x).2
  calc
    _ ≤ ∫ x, 1 - loss x / 2 ∂D := integral_mono
      (integrable_exp_neg D loss hloss (fun x => (hbound x).1))
      ((integrable_const 1).sub (hi.div_const 2))
      (fun x => exp_neg_unit_le (hbound x).1 (hbound x).2)
    _ = 1 - (∫ x, loss x ∂D) / 2 := by
      rw [integral_sub (integrable_const 1) (hi.div_const 2), integral_div]
      simp
    _ ≤ _ := by linarith [Real.add_one_le_exp (-(∫ x, loss x ∂D) / 2)]

theorem laplace_sum_le (D : Measure X) [IsProbabilityMeasure D]
    (loss : X → ℝ) (hloss : Measurable loss)
    (hbound : ∀ x, 0 ≤ loss x ∧ loss x ≤ 1) (n : ℕ) :
    (∫ s, Real.exp (-(∑ i : Fin n, loss (s i))) ∂CompressionSampling.iidSamples D n) ≤
      Real.exp (-(n : ℝ) * (∫ x, loss x ∂D) / 2) := by
  have he : (fun s : Fin n → X => Real.exp (-(∑ i, loss (s i)))) =
      (fun s => ∏ i, Real.exp (-loss (s i))) := by
    funext s
    rw [← Finset.sum_neg_distrib, Real.exp_sum]
  rw [he, CompressionSampling.iidSamples,
    integral_fintype_prod_eq_pow (fun x => Real.exp (-loss x))]
  simp only [Fintype.card_fin]
  calc
    _ ≤ (Real.exp (-(∫ x, loss x ∂D) / 2)) ^ n :=
      pow_le_pow_left₀ (integral_nonneg (fun _ => (Real.exp_pos _).le))
        (laplace_one_le D loss hloss hbound) n
    _ = _ := by rw [← Real.exp_nat_mul]; congr 1; ring

theorem relative_loss_tail (D : Measure X) [IsProbabilityMeasure D]
    (loss : X → ℝ) (hloss : Measurable loss)
    (hbound : ∀ x, 0 ≤ loss x ∧ loss x ≤ 1) (n : ℕ) (hn : 0 < n) (τ : ℝ) :
    (CompressionSampling.iidSamples D n).real
      {s | 2 * ((∑ i, loss (s i)) / n) + τ < ∫ x, loss x ∂D} ≤
      Real.exp (-(n : ℝ) * τ / 2) := by
  let μ := CompressionSampling.iidSamples D n
  let a := ∫ x, loss x ∂D
  let b := Real.exp (-(n : ℝ) * (a-τ) / 2)
  have hnR : 0 < (n : ℝ) := by exact_mod_cast hn
  have hb : 0 < b := Real.exp_pos _
  have hsub : {s : Fin n → X | 2 * ((∑ i, loss (s i)) / n) + τ < a} ⊆
      {s | b ≤ Real.exp (-(∑ i, loss (s i)))} := by
    intro s hs
    apply Real.exp_le_exp.mpr
    have hm := mul_lt_mul_of_pos_right hs hnR
    have hc : ((∑ i, loss (s i)) / n) * (n : ℝ) = ∑ i, loss (s i) :=
      div_mul_cancel₀ _ hnR.ne'
    rw [add_mul, mul_assoc, hc] at hm
    linarith
  have hi : Integrable (fun s : Fin n → X => Real.exp (-(∑ i, loss (s i)))) μ :=
    integrable_exp_neg μ (fun s => ∑ i, loss (s i)) (by fun_prop)
      (fun s => Finset.sum_nonneg (fun i _ => (hbound (s i)).1))
  have hm := mul_meas_ge_le_integral_of_nonneg
    (ae_of_all μ (fun s => (Real.exp_pos (-(∑ i, loss (s i)))).le)) hi b
  have hm' : μ.real {s | b ≤ Real.exp (-(∑ i, loss (s i)))} ≤
      (∫ s, Real.exp (-(∑ i, loss (s i))) ∂μ) / b :=
    (le_div_iff₀ hb).mpr (by simpa only [mul_comm] using hm)
  calc
    _ ≤ μ.real {s | b ≤ Real.exp (-(∑ i, loss (s i)))} := measureReal_mono hsub
    _ ≤ (∫ s, Real.exp (-(∑ i, loss (s i))) ∂μ) / b := hm'
    _ ≤ Real.exp (-(n : ℝ) * a / 2) / b :=
      div_le_div_of_nonneg_right (laplace_sum_le D loss hloss hbound n) hb.le
    _ = _ := by dsimp [b]; rw [← Real.exp_sub]; congr 1; ring

variable {H : Type*} [Fintype H]

def generalizationEvent (D : Measure X) (loss : H → X → ℝ)
    (n : ℕ) (τ : ℝ) : Set (Fin n → X) :=
  {s | ∀ h, (∫ x, loss h x ∂D) ≤ 2 * RobustStatistics.empiricalLoss loss s h + τ}

theorem measurable_generalizationEvent (D : Measure X) (loss : H → X → ℝ)
    (hloss : ∀ h, Measurable (loss h)) (n : ℕ) (τ : ℝ) :
    MeasurableSet (generalizationEvent D loss n τ) := by
  classical
  unfold generalizationEvent
  simp only [Set.setOf_forall]
  apply MeasurableSet.iInter
  intro h
  apply measurableSet_le measurable_const
  unfold RobustStatistics.empiricalLoss
  fun_prop

theorem finite_class_bad_probability (D : Measure X) [IsProbabilityMeasure D]
    (loss : H → X → ℝ) (hloss : ∀ h, Measurable (loss h))
    (hbound : ∀ h x, 0 ≤ loss h x ∧ loss h x ≤ 1)
    (n : ℕ) (hn : 0 < n) (τ : ℝ) :
    (CompressionSampling.iidSamples D n).real
      (generalizationEvent D loss n τ)ᶜ ≤
      (Fintype.card H : ℝ) * Real.exp (-(n : ℝ) * τ / 2) := by
  classical
  have hsub : (generalizationEvent D loss n τ)ᶜ ⊆
      ⋃ h, {s | 2 * RobustStatistics.empiricalLoss loss s h + τ < ∫ x, loss h x ∂D} := by
    intro s hs
    obtain ⟨h, hh⟩ := not_forall.mp hs
    exact Set.mem_iUnion.mpr ⟨h, lt_of_not_ge hh⟩
  calc
    _ ≤ (CompressionSampling.iidSamples D n).real
        (⋃ h, {s | 2 * RobustStatistics.empiricalLoss loss s h + τ < ∫ x, loss h x ∂D}) :=
      measureReal_mono hsub
    _ ≤ ∑ h, (CompressionSampling.iidSamples D n).real
        {s | 2 * RobustStatistics.empiricalLoss loss s h + τ < ∫ x, loss h x ∂D} :=
      measureReal_iUnion_fintype_le _
    _ ≤ ∑ _h : H, Real.exp (-(n : ℝ) * τ / 2) :=
      Finset.sum_le_sum (fun h _ => relative_loss_tail D (loss h) (hloss h) (hbound h) n hn τ)
    _ = _ := by simp

theorem finite_class_good_probability_log [Nonempty H]
    (D : Measure X) [IsProbabilityMeasure D]
    (loss : H → X → ℝ) (hloss : ∀ h, Measurable (loss h))
    (hbound : ∀ h x, 0 ≤ loss h x ∧ loss h x ≤ 1)
    (n : ℕ) (hn : 0 < n) {τ δ E : ℝ} (hδ : 0 < δ)
    (hentropy : Real.log (Fintype.card H : ℝ) ≤ E)
    (hbudget : 2 * (E + Real.log (1 / δ)) ≤ (n : ℝ) * τ) :
    1 - δ ≤ (CompressionSampling.iidSamples D n).real
      (generalizationEvent D loss n τ) := by
  have hcard : 0 < (Fintype.card H : ℝ) := by exact_mod_cast Fintype.card_pos
  have hlog : -(n : ℝ) * τ / 2 ≤
      -(Real.log (Fintype.card H : ℝ) + Real.log (1 / δ)) := by linarith
  have he := Real.exp_le_exp.mpr hlog
  have hid : Real.exp (-(Real.log (Fintype.card H : ℝ) + Real.log (1 / δ))) =
      δ / (Fintype.card H : ℝ) := by
    rw [Real.exp_neg, Real.exp_add, Real.exp_log hcard, Real.exp_log (one_div_pos.mpr hδ)]
    field_simp
  rw [hid] at he
  have hm := mul_le_mul_of_nonneg_left he hcard.le
  have hc : (Fintype.card H : ℝ) * (δ / (Fintype.card H : ℝ)) = δ := by field_simp
  rw [hc] at hm
  have hbad := (finite_class_bad_probability D loss hloss hbound n hn τ).trans hm
  rw [probReal_compl_eq_one_sub (measurable_generalizationEvent D loss hloss n τ)] at hbad
  linarith

theorem averaged_generalization [MeasurableSpace H] [MeasurableSingletonClass H]
    (D : Measure X) (loss : H → X → ℝ) {n : ℕ} {τ : ℝ}
    (s : Fin n → X) (hs : s ∈ generalizationEvent D loss n τ)
    (Γ : Measure H) [IsProbabilityMeasure Γ] :
    (∫ h, ∫ x, loss h x ∂D ∂Γ) ≤
      2 * ((∑ i, ∫ h, loss h (s i) ∂Γ) / n) + τ := by
  have h := integral_mono
    (RobustStatistics.integrable_finite_domain Γ (fun h => ∫ x, loss h x ∂D))
    (((RobustStatistics.integrable_finite_domain Γ
      (RobustStatistics.empiricalLoss loss s)).const_mul 2).add (integrable_const τ)) hs
  simp only [Pi.add_apply] at h
  rw [integral_add, integral_const_mul] at h
  · have hemp : (∫ h, RobustStatistics.empiricalLoss loss s h ∂Γ) =
        (∑ i, ∫ h, loss h (s i) ∂Γ) / n := by
      unfold RobustStatistics.empiricalLoss
      rw [integral_div, integral_finsetSum]
      intro i hi
      exact RobustStatistics.integrable_finite_domain Γ _
    simpa only [hemp, integral_const, probReal_univ, smul_eq_mul, one_mul] using h
  · exact (RobustStatistics.integrable_finite_domain Γ _).const_mul 2
  · exact integrable_const τ

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
    (∫ x, risk x ∂D) ≤ β + 3 * α + τ := by
  have hnR : 0 < (n : ℝ) := by exact_mod_cast hn
  have he := averaged_generalization D loss s hs Γ
  have ht : (∑ i, ∫ h, loss h (s i) ∂Γ) / n ≤ α := by
    apply (div_le_iff₀ hnR).mpr
    calc
      _ ≤ ∑ _i : Fin n, α := Finset.sum_le_sum (fun i _ => htrain i)
      _ = _ := by simp [mul_comm]
  have hp : (∫ x, risk x ∂D) ≤
      ∫ x, β + α + ∫ h, loss h x ∂Γ ∂D := by
    apply integral_mono (RobustStatistics.integrable_finite_domain D _)
      (RobustStatistics.integrable_finite_domain D _)
    intro x
    linarith [hrestore x, hcompare x]
  have hswap : (∫ x, ∫ h, loss h x ∂Γ ∂D) =
      ∫ h, ∫ x, loss h x ∂D ∂Γ := by
    exact integral_integral_swap (RobustStatistics.integrable_finite_domain (D.prod Γ) _)
  rw [integral_add (integrable_const (β + α)) (RobustStatistics.integrable_finite_domain D _),
    integral_const, probReal_univ, smul_eq_mul, one_mul, hswap] at hp
  linarith

end NeuralGeneralization.BatchTwoRelativeStatistics
