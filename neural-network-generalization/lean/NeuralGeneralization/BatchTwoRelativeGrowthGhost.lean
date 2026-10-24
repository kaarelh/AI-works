import NeuralGeneralization.BatchTwoRelativeStatistics
import Mathlib.Analysis.Complex.Exponential

/-! Relative ghost-sample symmetrization for the actual IID law. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open MeasureTheory ProbabilityTheory Set
namespace NeuralGeneralization.BatchTwoRelativeGrowth
open CompressionSampling
open Classical

def hit {X : Type*} (a : X → Bool) (x : X) : ℝ := if a x then 1 else 0
def count {X : Type*} {n : ℕ} (a : X → Bool) (s : Fin n → X) : ℝ := ∑ i, hit a (s i)
def population {X : Type*} [MeasurableSpace X] (D : Measure X) (a : X → Bool) : ℝ :=
  ∫ x, hit a x ∂D

variable {X : Type*} [Fintype X] [MeasurableSpace X] [MeasurableSingletonClass X]

theorem hit_bounds (a : X → Bool) (x : X) : 0 ≤ hit a x ∧ hit a x ≤ 1 := by
  unfold hit
  split_ifs <;> norm_num

theorem quarter_laplace (D : Measure X) [IsProbabilityMeasure D] (a : X → Bool) :
    (∫ x, Real.exp (-hit a x/4) ∂D) ≤ Real.exp (-(7 : ℝ)/32*population D a) := by
  have hscalar : Real.exp (-(1 : ℝ)/4) ≤ 25/32 := by
    rw [show (-1 : ℝ)/4 = -(1/4) by ring, Real.exp_neg]
    apply (inv_le_comm₀ (Real.exp_pos _) (by norm_num : (0 : ℝ) < 25/32)).mpr
    have h := Real.quadratic_le_exp_of_nonneg (by norm_num : 0 ≤ (1 : ℝ)/4)
    norm_num at h ⊢
    linarith
  have he (x : X) : Real.exp (-hit a x/4) ≤ 1-(7 : ℝ)/32*hit a x := by
    unfold hit
    split_ifs
    · norm_num
      simpa only [neg_div] using hscalar
    · simp
  have hp : 0 ≤ population D a := integral_nonneg (fun x => (hit_bounds a x).1)
  calc
    _ ≤ ∫ x, 1-(7 : ℝ)/32*hit a x ∂D := integral_mono
      (RobustStatistics.integrable_finite_domain D _) (RobustStatistics.integrable_finite_domain D _) he
    _ = 1-(7 : ℝ)/32*population D a := by
      rw [integral_sub (integrable_const _) ((RobustStatistics.integrable_finite_domain D _).const_mul _),
        integral_const_mul]
      simp [population]
    _ ≤ _ := by linarith [Real.add_one_le_exp (-(7 : ℝ)/32*population D a)]

theorem lower_count_tail (D : Measure X) [IsProbabilityMeasure D]
    (a : X → Bool) (n : ℕ) :
    (iidSamples D n).real {s | count a s < (3 : ℝ)/4*n*population D a} ≤
      Real.exp (-(n : ℝ)*population D a/32) := by
  let μ := iidSamples D n
  let b := Real.exp (-(3 : ℝ)/16*n*population D a)
  have hb : 0 < b := Real.exp_pos _
  have hsub : {s : Fin n → X | count a s < (3 : ℝ)/4*n*population D a} ⊆
      {s | b ≤ Real.exp (-count a s/4)} := by
    intro s hs
    change count a s < (3 : ℝ)/4*n*population D a at hs
    apply Real.exp_le_exp.mpr
    linarith
  have hi : Integrable (fun s : Fin n → X => Real.exp (-count a s/4)) μ :=
    RobustStatistics.integrable_finite_domain μ _
  have hmark := mul_meas_ge_le_integral_of_nonneg
    (ae_of_all μ (fun s => (Real.exp_pos (-count a s/4)).le)) hi b
  have hmark' : μ.real {s | b ≤ Real.exp (-count a s/4)} ≤
      (∫ s, Real.exp (-count a s/4) ∂μ)/b := by
    apply (le_div_iff₀ hb).mpr
    simpa only [mul_comm] using hmark
  have hmgf : (∫ s, Real.exp (-count a s/4) ∂μ) ≤
      Real.exp (-(7 : ℝ)/32*n*population D a) := by
    have he : (fun s : Fin n → X => Real.exp (-count a s/4)) =
        (fun s => ∏ i, Real.exp (-hit a (s i)/4)) := by
      funext s
      unfold count
      rw [← Real.exp_sum]
      congr 1
      rw [← Finset.sum_div, ← Finset.sum_neg_distrib]
    rw [he]
    dsimp [μ]
    rw [iidSamples, integral_fintype_prod_eq_pow (fun x => Real.exp (-hit a x/4))]
    simp only [Fintype.card_fin]
    calc
      _ ≤ (Real.exp (-(7 : ℝ)/32*population D a))^n :=
        pow_le_pow_left₀ (integral_nonneg (fun _ => (Real.exp_pos _).le)) (quarter_laplace D a) n
      _ = _ := by rw [← Real.exp_nat_mul]; congr 1; ring
  calc
    _ ≤ μ.real {s | b ≤ Real.exp (-count a s/4)} := measureReal_mono hsub
    _ ≤ (∫ s, Real.exp (-count a s/4) ∂μ)/b := hmark'
    _ ≤ Real.exp (-(7 : ℝ)/32*n*population D a)/b :=
      div_le_div_of_nonneg_right hmgf hb.le
    _ = _ := by dsimp [b]; rw [← Real.exp_sub]; congr 1; ring

variable {H : Type*} [Fintype H]

def badSample (D : Measure X) (a : H → X → Bool) (n : ℕ) (u : ℝ) : Set (Fin n → X) :=
  {s | ∃ h, 2*count (a h) s/n+u < population D (a h)}

def doubleSampleEvent (a : H → X → Bool) (n : ℕ) (u : ℝ) : Set ((Fin n → X) × (Fin n → X)) :=
  {p | ∃ h, (3 : ℝ)/2*count (a h) p.1+(3 : ℝ)/4*n*u < count (a h) p.2}

theorem ghost_symmetrization (D : Measure X) [IsProbabilityMeasure D]
    (a : H → X → Bool) (n : ℕ) (hn : 0 < n) {u : ℝ}
    (hu : 32*Real.log 2 ≤ (n : ℝ)*u) :
    (iidSamples D n).real (badSample D a n u) ≤
      2*((iidSamples D n).prod (iidSamples D n)).real (doubleSampleEvent a n u) := by
  let μ := iidSamples D n
  let E := doubleSampleEvent a n u
  have hE : MeasurableSet E := (Set.toFinite E).measurableSet
  have hnR : 0 < (n : ℝ) := by exact_mod_cast hn
  have hfiber : badSample D a n u ⊆ {s | ENNReal.ofReal (1/2 : ℝ) ≤ μ (Prod.mk s ⁻¹' E)} := by
    intro s hs
    obtain ⟨h, hh⟩ := hs
    have hcount : 0 ≤ count (a h) s := Finset.sum_nonneg (fun i _ => (hit_bounds (a h) (s i)).1)
    have hp : u < population D (a h) := by
      have hnn : 0 ≤ 2*count (a h) s/(n : ℝ) := by positivity
      linarith
    have htail := lower_count_tail D (a h) n
    have hexp : Real.exp (-(n : ℝ)*population D (a h)/32) ≤ 1/2 := by
      have hnu := mul_lt_mul_of_pos_left hp hnR
      have he := Real.exp_le_exp.mpr (show -(n : ℝ)*population D (a h)/32 ≤ -Real.log 2 by linarith)
      simpa only [Real.exp_neg, Real.exp_log (by norm_num : (0 : ℝ) < 2), one_div] using he
    let G : Set (Fin n → X) := {t | (3 : ℝ)/4*n*population D (a h) ≤ count (a h) t}
    have hgood : (1 : ℝ)/2 ≤ μ.real G := by
      have hc : Gᶜ = {t | count (a h) t < (3 : ℝ)/4*n*population D (a h)} := by ext t; simp [G]
      have ht := htail.trans hexp
      rw [← hc, probReal_compl_eq_one_sub (Set.toFinite G).measurableSet] at ht
      linarith
    have hsub : G ⊆ Prod.mk s ⁻¹' E := by
      intro t ht
      refine ⟨h, ?_⟩
      have hh' := mul_lt_mul_of_pos_right hh hnR
      have hcancel : (2*count (a h) s/(n : ℝ))*(n : ℝ)=2*count (a h) s := div_mul_cancel₀ _ hnR.ne'
      rw [add_mul, hcancel] at hh'
      change (3 : ℝ)/4*n*population D (a h) ≤ count (a h) t at ht
      nlinarith
    change ENNReal.ofReal (1/2 : ℝ) ≤ μ (Prod.mk s ⁻¹' E)
    rw [ENNReal.ofReal_le_iff_le_toReal (measure_ne_top μ _)]
    exact hgood.trans (measureReal_mono hsub)
  have hmark := mul_meas_ge_le_lintegral (μ := μ)
    (measurable_measure_prodMk_left (ν := μ) hE) (ENNReal.ofReal (1/2 : ℝ))
  rw [← Measure.prod_apply hE] at hmark
  have hreal := ENNReal.toReal_mono (measure_ne_top (μ.prod μ) E) hmark
  rw [ENNReal.toReal_mul, ENNReal.toReal_ofReal (by norm_num : (0 : ℝ) ≤ 1/2)] at hreal
  change (1 : ℝ)/2*μ.real {x | ENNReal.ofReal (1/2 : ℝ) ≤ μ (Prod.mk x ⁻¹' E)} ≤
    (μ.prod μ).real E at hreal
  have hle := measureReal_mono hfiber (measure_ne_top μ _)
  change μ.real (badSample D a n u) ≤ 2*(μ.prod μ).real E
  linarith

end NeuralGeneralization.BatchTwoRelativeGrowth
