import NeuralGeneralization.GaussianAmplitudeSmallBall
import NeuralGeneralization.ConditionalEventMoment
import Mathlib.MeasureTheory.Integral.Prod

/-!
# Independent Gaussian noise and globally imposed margins

The margin event may depend arbitrarily on the residual randomness and noise.
Only its inclusion in the coordinatewise survival event is used. In particular
we do not assume independence of conditioning on coordinates outside the chosen
subset.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.GaussianAmplitude

/-- Number of residual means in a prescribed interval, as a real number. -/
def smallMeanCount {ι : Type*} [Fintype ι] (b : ℝ) (h : ι → ℝ) : ℝ :=
  ∑ i, if |h i| ≤ b then 1 else 0

lemma smallMeanCount_nonneg {ι : Type*} [Fintype ι] (b : ℝ) (h : ι → ℝ) :
    0 ≤ smallMeanCount b h := by
  unfold smallMeanCount
  exact Finset.sum_nonneg fun i _ => by split <;> positivity

lemma smallMeanCount_le_card {ι : Type*} [Fintype ι] (b : ℝ) (h : ι → ℝ) :
    smallMeanCount b h ≤ Fintype.card ι := by
  calc
    _ ≤ ∑ _i : ι, (1:ℝ) := Finset.sum_le_sum fun i _ => by split <;> norm_num
    _ = _ := by simp

lemma measurable_smallMeanCount {ι : Type*} [Fintype ι] (b : ℝ) :
    Measurable (smallMeanCount (ι:=ι) b) := by
  unfold smallMeanCount
  exact Finset.measurable_sum _ fun i _ =>
    Measurable.ite (measurableSet_le (measurable_pi_apply i).abs measurable_const)
      measurable_const measurable_const

lemma survival_mass_le {ι : Type*} [Fintype ι] (a σ t : ℝ)
    (hσ : 0 < σ) (ht : 0 ≤ t) (ha : σ/2 ≤ a) (h : ι → ℝ) :
    (Measure.pi fun _i : ι => gaussianReal 0 1).real
      {z | ∀ i, a < |h i+σ*z i|} ≤
        Real.exp (-smallBall t*smallMeanCount (a+σ*t) h) := by
  let μ := gaussianReal 0 1
  let ν := Measure.pi fun _i : ι => μ
  have hevent : {z : ι → ℝ | ∀ i, a < |h i+σ*z i|} =
      Set.univ.pi (fun i => {z : ℝ | a < |h i+σ*z|}) := by
    ext z
    simp
  have hprod : ν.real {z | ∀ i, a < |h i+σ*z i|} =
      ∏ i, μ.real {z | a < |h i+σ*z|} := by
    simp only [Measure.real, ν, hevent, Measure.pi_pi, ENNReal.toReal_prod]
  rw [hprod]
  have hi (i : ι) : μ.real {z | a < |h i+σ*z|} ≤
      Real.exp (-smallBall t*(if |h i| ≤ a+σ*t then 1 else 0)) := by
    by_cases hh : |h i| ≤ a+σ*t
    · rw [if_pos hh, mul_one]
      have hm := shifted_interval_mass_lower a σ t (h i) hσ ht ha hh
      have hs : MeasurableSet {z : ℝ | |h i+σ*z| ≤ a} :=
        measurableSet_le (measurable_const.add (measurable_const.mul measurable_id)).abs
          measurable_const
      have hcomp : {z : ℝ | a < |h i+σ*z|} = {z : ℝ | |h i+σ*z| ≤ a}ᶜ := by
        ext z
        simp
      rw [hcomp, probReal_compl_eq_one_sub hs]
      have hexp := Real.add_one_le_exp (-smallBall t)
      dsimp [μ]
      linarith
    · rw [if_neg hh, mul_zero, Real.exp_zero]
      exact measureReal_le_one
  calc
    _ ≤ ∏ i, Real.exp (-smallBall t*(if |h i| ≤ a+σ*t then 1 else 0)) :=
      Finset.prod_le_prod (fun i _ => measureReal_nonneg) (fun i _ => hi i)
    _ = _ := by
      rw [← Real.exp_sum]
      congr 1
      simp only [smallMeanCount, Finset.mul_sum]

/-- Bounded residual-mean counts are integrable for every probability law. -/
lemma integrable_smallMeanCount {Ω ι : Type*} [MeasurableSpace Ω] [Fintype ι]
    (μ : Measure Ω) [IsProbabilityMeasure μ] (H : Ω → ι → ℝ)
    (hH : Measurable H) (b : ℝ) :
    Integrable (fun x => smallMeanCount b (H x)) μ := by
  apply Integrable.of_bound ((measurable_smallMeanCount b).comp hH).aestronglyMeasurable
    (Fintype.card ι)
  exact Filter.Eventually.of_forall fun x => by
    change |smallMeanCount b (H x)| ≤ _
    rw [abs_of_nonneg (smallMeanCount_nonneg _ _)]
    exact smallMeanCount_le_card _ _

lemma integrable_exp_smallMeanCount {Ω ι : Type*} [MeasurableSpace Ω] [Fintype ι]
    (μ : Measure Ω) [IsProbabilityMeasure μ] (H : Ω → ι → ℝ)
    (hH : Measurable H) (b p : ℝ) (hp : 0 ≤ p) :
    Integrable (fun x => Real.exp (p*smallMeanCount b (H x))) μ := by
  apply Integrable.of_bound
    ((measurable_const.mul ((measurable_smallMeanCount b).comp hH)).exp).aestronglyMeasurable
    (Real.exp (p*Fintype.card ι))
  exact Filter.Eventually.of_forall fun x => by
    rw [Real.norm_eq_abs, abs_of_pos (Real.exp_pos _)]
    exact Real.exp_le_exp.mpr (mul_le_mul_of_nonneg_left (smallMeanCount_le_card _ _) hp)


/-- The survival event suppresses the exponentially weighted count of small
residual means. Additional restrictions on the event only decrease this moment. -/
theorem restricted_count_exponential_moment
    {Ω ι : Type*} [MeasurableSpace Ω] [Fintype ι]
    (μ : Measure Ω) [IsProbabilityMeasure μ] (H : Ω → ι → ℝ)
    (hH : Measurable H) (a σ t : ℝ)
    (hσ : 0 < σ) (ht : 0 ≤ t) (ha : σ/2 ≤ a)
    (E : Set (Ω × (ι → ℝ))) (hE : MeasurableSet E)
    (hmargin : ∀ x ∈ E, ∀ i, a < |H x.1 i+σ*x.2 i|) :
    (∫ x in E, Real.exp (smallBall t*smallMeanCount (a+σ*t) (H x.1))
      ∂μ.prod (Measure.pi fun _i : ι => gaussianReal 0 1)) ≤ 1 := by
  let ν := Measure.pi fun _i : ι => gaussianReal 0 1
  let F : Ω × (ι → ℝ) → ℝ :=
    fun x => Real.exp (smallBall t*smallMeanCount (a+σ*t) (H x.1))
  have hF : Integrable F (μ.prod ν) :=
    integrable_exp_smallMeanCount (μ.prod ν) (fun x => H x.1)
      (hH.comp measurable_fst) _ _ (smallBall_pos ht).le
  have hEF : Integrable (E.indicator F) (μ.prod ν) := hF.indicator hE
  rw [← integral_indicator hE, integral_prod _ hEF]
  have hpoint (x : Ω) : (∫ z, E.indicator F (x,z) ∂ν) ≤ 1 := by
    let Eₓ : Set (ι → ℝ) := {z | (x,z) ∈ E}
    have hx : MeasurableSet Eₓ := hE.preimage measurable_prodMk_left
    have hsub : Eₓ ⊆ {z | ∀ i, a < |H x i+σ*z i|} := by
      intro z hz
      exact hmargin (x,z) hz
    have hm := (measureReal_mono hsub).trans (survival_mass_le a σ t hσ ht ha (H x))
    have hid : (fun z => E.indicator F (x,z)) =
        Eₓ.indicator (fun _ => Real.exp (smallBall t*smallMeanCount (a+σ*t) (H x))) := by
      funext z
      simp [Eₓ, F, Set.indicator]
    rw [hid, integral_indicator_const _ hx]
    change ν.real Eₓ*Real.exp (smallBall t*smallMeanCount (a+σ*t) (H x)) ≤ 1
    calc
      _ ≤ Real.exp (-smallBall t*smallMeanCount (a+σ*t) (H x))*
          Real.exp (smallBall t*smallMeanCount (a+σ*t) (H x)) :=
        mul_le_mul_of_nonneg_right hm (Real.exp_pos _).le
      _ = 1 := by
        rw [← Real.exp_add]
        simp only [neg_mul, neg_add_cancel, Real.exp_zero]
  have hint := integral_mono hEF.integral_prod_left (integrable_const (1:ℝ)) hpoint
  simpa using hint

/-- An actual conditional-mean estimate under arbitrary additional conditioning.
The event cost is the logarithm of its actual inverse probability. -/
theorem conditional_smallMeanCount
    {Ω ι : Type*} [MeasurableSpace Ω] [Fintype ι]
    (μ : Measure Ω) [IsProbabilityMeasure μ] (H : Ω → ι → ℝ)
    (hH : Measurable H) (a σ t : ℝ)
    (hσ : 0 < σ) (ht : 0 ≤ t) (ha : σ/2 ≤ a)
    (E : Set (Ω × (ι → ℝ))) (hE : MeasurableSet E)
    (hEpos : (μ.prod (Measure.pi fun _i : ι => gaussianReal 0 1)) E ≠ 0)
    (hmargin : ∀ x ∈ E, ∀ i, a < |H x.1 i+σ*x.2 i|) :
    (∫ x, smallMeanCount (a+σ*t) (H x.1)
      ∂cond (μ.prod (Measure.pi fun _i : ι => gaussianReal 0 1)) E) ≤
      Real.log (1/(μ.prod (Measure.pi fun _i : ι => gaussianReal 0 1)).real E)/smallBall t := by
  let ν := Measure.pi fun _i : ι => gaussianReal 0 1
  have hQ := integrable_smallMeanCount (μ.prod ν) (fun x => H x.1)
    (hH.comp measurable_fst) (a+σ*t)
  have hX := integrable_exp_smallMeanCount (μ.prod ν) (fun x => H x.1)
    (hH.comp measurable_fst) (a+σ*t) (smallBall t) (smallBall_pos ht).le
  have hm := restricted_count_exponential_moment μ H hH a σ t hσ ht ha E hE hmargin
  have hh := conditional_expectation_le_of_restricted_exponential_moment
    (μ.prod ν) (fun x => smallMeanCount (a+σ*t) (H x.1)) (smallBall t) 0
      (smallBall_pos ht) hQ hX E hEpos (by simpa only [Real.exp_zero] using hm)
  simpa only [zero_add] using hh

end NeuralGeneralization.GaussianAmplitude
