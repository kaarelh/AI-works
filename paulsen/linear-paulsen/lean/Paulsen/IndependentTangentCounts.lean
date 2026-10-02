import Paulsen.IndependentTangentCore
import Mathlib.MeasureTheory.Integral.Pi
import Mathlib.Analysis.Complex.ExponentialBounds

/-!
# Dense rows from independent normalized tangent perturbations

The scalar small-ball estimate supplies actual Bernoulli means. Finite-product
integration and an exponential Markov bound amplify it to simultaneous dense
rows, including exclusion of each diagonal entry.
-/

open MeasureTheory ProbabilityTheory
open scoped BigOperators ProbabilityTheory

namespace Paulsen
noncomputable section

abbrev TangentRowSpace (d : ℕ) := EuclideanSpace ℝ (Fin d)
abbrev independentTangentMeasure (n d : ℕ) : Measure (Fin n → TangentRowSpace d) :=
  Measure.pi fun _ => stdGaussian (TangentRowSpace d)

/-- Indicator that a perturbed row has a small scalar product with f. -/
def tangentBadIndicator {d : ℕ} (e f : TangentRowSpace d) (t b : ℝ)
    (z : TangentRowSpace d) : ℝ :=
  if |inner ℝ f (independentTangentDirection e t z)| ≤ b then 1 else 0

theorem tangentBadIndicator_nonneg {d : ℕ} (e f : TangentRowSpace d) (t b : ℝ)
    (z : TangentRowSpace d) : 0 ≤ tangentBadIndicator e f t b z := by
  unfold tangentBadIndicator
  split_ifs <;> norm_num

theorem tangentBadIndicator_le_one {d : ℕ} (e f : TangentRowSpace d) (t b : ℝ)
    (z : TangentRowSpace d) : tangentBadIndicator e f t b z ≤ 1 := by
  unfold tangentBadIndicator
  split_ifs <;> norm_num

theorem measurable_tangentBadIndicator {d : ℕ} (e f : TangentRowSpace d) (t b : ℝ) :
    Measurable (tangentBadIndicator e f t b) := by
  apply Measurable.ite _ measurable_const measurable_const
  exact measurableSet_le
    ((continuous_const.inner (continuous_independentTangentDirection e t)).abs.measurable)
    measurable_const

theorem integrable_tangentBadIndicator {d : ℕ} (e f : TangentRowSpace d) (t b : ℝ) :
    Integrable (tangentBadIndicator e f t b) (stdGaussian (TangentRowSpace d)) := by
  apply (integrable_const (1 : ℝ)).mono'
    (measurable_tangentBadIndicator e f t b).aestronglyMeasurable
  exact ae_of_all _ fun z => by
    rw [Real.norm_eq_abs, abs_of_nonneg (tangentBadIndicator_nonneg e f t b z)]
    exact tangentBadIndicator_le_one e f t b z

theorem integral_tangentBadIndicator {d : ℕ} (e f : TangentRowSpace d) (t b : ℝ) :
    (∫ z, tangentBadIndicator e f t b z ∂stdGaussian (TangentRowSpace d)) =
      (stdGaussian (TangentRowSpace d)).real
        {z | |inner ℝ f (independentTangentDirection e t z)| ≤ b} := by
  change (∫ z, ({z | |inner ℝ f (independentTangentDirection e t z)| ≤ b} : Set _).indicator
    (fun _ => (1 : ℝ)) z ∂stdGaussian (TangentRowSpace d)) = _
  exact integral_indicator_one (measurableSet_le
    ((continuous_const.inner (continuous_independentTangentDirection e t)).abs.measurable)
    measurable_const)

theorem exp_tangentBadIndicator {d : ℕ} (e f : TangentRowSpace d) (t b : ℝ)
    (z : TangentRowSpace d) :
    Real.exp (tangentBadIndicator e f t b z) =
      1 + (Real.exp 1 - 1) * tangentBadIndicator e f t b z := by
  unfold tangentBadIndicator
  split_ifs <;> simp

theorem integrable_exp_tangentBadIndicator {d : ℕ} (e f : TangentRowSpace d) (t b : ℝ) :
    Integrable (fun z => Real.exp (tangentBadIndicator e f t b z))
      (stdGaussian (TangentRowSpace d)) := by
  simp_rw [exp_tangentBadIndicator]
  exact (integrable_const _).add ((integrable_tangentBadIndicator e f t b).const_mul _)

theorem integral_exp_tangentBadIndicator_le {d : ℕ} (hd : 0 < d)
    (e f : TangentRowSpace d) (he : ‖e‖ = 1) (hf : ‖f‖ = 1)
    {t h : ℝ} (ht : 0 < t) (ht100 : t ≤ 1 / 100) (hh : 0 < h)
    (hh400 : h ≤ 1 / (400 * Real.exp 1)) :
    (∫ z, Real.exp (tangentBadIndicator e f t (h * t / Real.sqrt d) z)
      ∂stdGaussian (TangentRowSpace d)) ≤ Real.exp (1 / 25) := by
  simp_rw [exp_tangentBadIndicator]
  rw [integral_add (integrable_const _) ((integrable_tangentBadIndicator e f _ _).const_mul _),
    integral_const_mul, integral_const, integral_tangentBadIndicator]
  simp only [probReal_univ, one_smul]
  have hp := independentTangentDirection_small_ball_one_fiftieth hd e f he hf ht ht100 hh hh400
  have hpos : 0 ≤ Real.exp (1 : ℝ) - 1 := sub_nonneg.mpr (Real.one_le_exp (by norm_num))
  have hmul := mul_le_mul_of_nonneg_left hp hpos
  have hexp := Real.add_one_le_exp (1 / 25 : ℝ)
  nlinarith [Real.exp_one_lt_three]

/-- Number of bad rows relative to a fixed unit test direction. -/
def fixedTangentBadCount {n d : ℕ} (e : Fin n → TangentRowSpace d)
    (f : TangentRowSpace d) (t b : ℝ) (g : Fin n → TangentRowSpace d) : ℝ :=
  ∑ j, tangentBadIndicator (e j) f t b (g j)

theorem integral_exp_fixedTangentBadCount_le {n d : ℕ} (hd : 0 < d)
    (e : Fin n → TangentRowSpace d) (he : ∀ j, ‖e j‖ = 1)
    (f : TangentRowSpace d) (hf : ‖f‖ = 1)
    {t h : ℝ} (ht : 0 < t) (ht100 : t ≤ 1 / 100) (hh : 0 < h)
    (hh400 : h ≤ 1 / (400 * Real.exp 1)) :
    (∫ g, Real.exp (fixedTangentBadCount e f t (h * t / Real.sqrt d) g)
      ∂independentTangentMeasure n d) ≤ Real.exp ((n : ℝ) / 25) := by
  simp only [fixedTangentBadCount, Real.exp_sum]
  calc
    _ = ∏ j, ∫ z, Real.exp (tangentBadIndicator (e j) f t (h * t / Real.sqrt d) z)
        ∂stdGaussian (TangentRowSpace d) :=
      integral_fintype_prod_eq_prod (fun j z => Real.exp
        (tangentBadIndicator (e j) f t (h * t / Real.sqrt d) z))
    _ ≤ ∏ _j : Fin n, Real.exp (1 / 25 : ℝ) := by
      apply Finset.prod_le_prod
      · intro j _
        exact integral_nonneg fun z => (Real.exp_pos _).le
      · intro j _
        exact integral_exp_tangentBadIndicator_le hd (e j) f (he j) hf ht ht100 hh hh400
    _ = _ := by
      simp only [Finset.prod_const, Finset.card_univ, Fintype.card_fin, ← Real.exp_nat_mul]
      congr 1
      ring


/-- Number of small off-diagonal Gram entries in row i. -/
def offDiagonalTangentBadCount {n d : ℕ} (e : Fin n → TangentRowSpace d)
    (t b : ℝ) (i : Fin n) (g : Fin n → TangentRowSpace d) : ℝ :=
  ∑ j, if j = i then 0 else tangentBadIndicator (e j)
    (independentTangentDirection (e i) t (g i)) t b (g j)

theorem measurable_offDiagonalTangentBadCount {n d : ℕ}
    (e : Fin n → TangentRowSpace d) (t b : ℝ) (i : Fin n) :
    Measurable (offDiagonalTangentBadCount e t b i) := by
  apply Finset.measurable_sum
  intro j _
  by_cases hji : j = i
  · simp only [hji, if_true]
    exact measurable_const
  · simp only [if_neg hji, tangentBadIndicator]
    apply Measurable.ite _ measurable_const measurable_const
    exact measurableSet_le
      ((((continuous_independentTangentDirection (e i) t).comp (continuous_apply i)).inner
        ((continuous_independentTangentDirection (e j) t).comp (continuous_apply j))).abs.measurable)
      measurable_const

theorem offDiagonalTangentBadCount_nonneg {n d : ℕ}
    (e : Fin n → TangentRowSpace d) (t b : ℝ) (i : Fin n) (g : Fin n → TangentRowSpace d) :
    0 ≤ offDiagonalTangentBadCount e t b i g := by
  apply Finset.sum_nonneg
  intro j _
  split_ifs
  · exact le_rfl
  · exact tangentBadIndicator_nonneg _ _ _ _ _

theorem offDiagonalTangentBadCount_le {n d : ℕ}
    (e : Fin n → TangentRowSpace d) (t b : ℝ) (i : Fin n) (g : Fin n → TangentRowSpace d) :
    offDiagonalTangentBadCount e t b i g ≤ n := by
  calc
    _ ≤ ∑ _j : Fin n, (1 : ℝ) := by
      apply Finset.sum_le_sum
      intro j _
      split_ifs
      · norm_num
      · exact tangentBadIndicator_le_one _ _ _ _ _
    _ = _ := by simp

theorem offDiagonalTangentBadCount_insertNth {n d : ℕ}
    (e : Fin (n + 1) → TangentRowSpace d) (t b : ℝ) (i : Fin (n + 1))
    (u : TangentRowSpace d) (v : Fin n → TangentRowSpace d) :
    offDiagonalTangentBadCount e t b i (i.insertNth u v) =
      fixedTangentBadCount (fun j => e (i.succAbove j))
        (independentTangentDirection (e i) t u) t b v := by
  unfold offDiagonalTangentBadCount fixedTangentBadCount
  rw [Fin.sum_univ_succAbove _ i]
  simp only [if_true, zero_add, Fin.succAbove_ne, if_false,
    Fin.insertNth_apply_same, Fin.insertNth_apply_succAbove]

/-- Integrating the distinguished row leaves independent bad-edge indicators. -/
theorem integral_exp_offDiagonalTangentBadCount_le_succ {n d : ℕ} (hd : 0 < d)
    (e : Fin (n + 1) → TangentRowSpace d) (he : ∀ j, ‖e j‖ = 1)
    {t h : ℝ} (ht : 0 < t) (ht100 : t ≤ 1 / 100) (hh : 0 < h)
    (hh400 : h ≤ 1 / (400 * Real.exp 1)) (i : Fin (n + 1)) :
    (∫ g, Real.exp (offDiagonalTangentBadCount e t (h * t / Real.sqrt d) i g)
      ∂independentTangentMeasure (n + 1) d) ≤ Real.exp ((n : ℝ) / 25) := by
  let μ := stdGaussian (TangentRowSpace d)
  let F : TangentRowSpace d × (Fin n → TangentRowSpace d) → ℝ := fun p =>
    Real.exp (offDiagonalTangentBadCount e t (h * t / Real.sqrt d) i (i.insertNth p.1 p.2))
  let E := MeasurableEquiv.piFinSuccAbove (fun _ : Fin (n + 1) => TangentRowSpace d) i
  have hp := measurePreserving_piFinSuccAbove (fun _ : Fin (n + 1) => μ) i
  have hFeq : F = (fun g => Real.exp (offDiagonalTangentBadCount e t (h * t / Real.sqrt d) i g)) ∘
      E.symm := by
    rfl
  have hFm : Measurable F := by
    rw [hFeq]
    exact (measurable_offDiagonalTangentBadCount e t _ i).exp.comp E.symm.measurable
  have hFi : Integrable F (μ.prod (independentTangentMeasure n d)) := by
    apply (integrable_const (Real.exp (n + 1 : ℝ))).mono' hFm.aestronglyMeasurable
    apply ae_of_all
    intro p
    rw [Real.norm_eq_abs, abs_of_pos (Real.exp_pos _)]
    apply Real.exp_le_exp.mpr
    exact_mod_cast offDiagonalTangentBadCount_le e t (h * t / Real.sqrt d) i (i.insertNth p.1 p.2)
  calc
    _ = ∫ p, F p ∂(μ.prod (independentTangentMeasure n d)) :=
      (hp.symm.integral_comp' _).symm
    _ = ∫ u, ∫ v, F (u,v) ∂independentTangentMeasure n d ∂μ := integral_prod F hFi
    _ ≤ ∫ _u, Real.exp ((n : ℝ) / 25) ∂μ := by
      apply integral_mono_of_nonneg
      · exact ae_of_all _ fun u => integral_nonneg fun v => (Real.exp_pos _).le
      · exact integrable_const _
      · apply ae_of_all
        intro u
        change (∫ v, Real.exp (offDiagonalTangentBadCount e t (h * t / Real.sqrt d)
          i (i.insertNth u v)) ∂independentTangentMeasure n d) ≤ _
        simp_rw [offDiagonalTangentBadCount_insertNth]
        exact integral_exp_fixedTangentBadCount_le hd _ (fun j => he (i.succAbove j)) _
          (norm_independentTangentDirection (e i) (he i) t u) ht ht100 hh hh400
    _ = _ := by simp [μ]

theorem integral_exp_offDiagonalTangentBadCount_le {n d : ℕ} (hd : 0 < d)
    (e : Fin n → TangentRowSpace d) (he : ∀ j, ‖e j‖ = 1)
    {t h : ℝ} (ht : 0 < t) (ht100 : t ≤ 1 / 100) (hh : 0 < h)
    (hh400 : h ≤ 1 / (400 * Real.exp 1)) (i : Fin n) :
    (∫ g, Real.exp (offDiagonalTangentBadCount e t (h * t / Real.sqrt d) i g)
      ∂independentTangentMeasure n d) ≤ Real.exp ((n : ℝ) / 25) := by
  cases n with
  | zero => exact Fin.elim0 i
  | succ n =>
    apply (integral_exp_offDiagonalTangentBadCount_le_succ hd e he ht ht100 hh hh400 i).trans
    apply Real.exp_le_exp.mpr
    push_cast
    linarith


theorem integrable_exp_offDiagonalTangentBadCount {n d : ℕ}
    (e : Fin n → TangentRowSpace d) (t b : ℝ) (i : Fin n) :
    Integrable (fun g => Real.exp (offDiagonalTangentBadCount e t b i g))
      (independentTangentMeasure n d) := by
  apply (integrable_const (Real.exp (n : ℝ))).mono'
    (measurable_offDiagonalTangentBadCount e t b i).exp.aestronglyMeasurable
  apply ae_of_all
  intro g
  rw [Real.norm_eq_abs, abs_of_pos (Real.exp_pos _)]
  exact Real.exp_le_exp.mpr (offDiagonalTangentBadCount_le e t b i g)

/-- Exponential control of the small off-diagonal entries in each actual row. -/
theorem offDiagonalTangentBadCount_tail {n d : ℕ} (hd : 0 < d)
    (e : Fin n → TangentRowSpace d) (he : ∀ j, ‖e j‖ = 1)
    {t h : ℝ} (ht : 0 < t) (ht100 : t ≤ 1 / 100) (hh : 0 < h)
    (hh400 : h ≤ 1 / (400 * Real.exp 1)) (i : Fin n) :
    (independentTangentMeasure n d).real
      {g | (n : ℝ) / 10 ≤ offDiagonalTangentBadCount e t (h * t / Real.sqrt d) i g} ≤
      Real.exp (-3 * n / 50) := by
  have hmarkov := mul_meas_ge_le_integral_of_nonneg
    (ae_of_all _ fun g => (Real.exp_pos (offDiagonalTangentBadCount e t (h * t / Real.sqrt d) i g)).le)
    (integrable_exp_offDiagonalTangentBadCount e t (h * t / Real.sqrt d) i)
    (Real.exp ((n : ℝ) / 10))
  simp only [Real.exp_le_exp] at hmarkov
  have hmean := integral_exp_offDiagonalTangentBadCount_le hd e he ht ht100 hh hh400 i
  have htail : (independentTangentMeasure n d).real
      {g | (n : ℝ) / 10 ≤ offDiagonalTangentBadCount e t (h * t / Real.sqrt d) i g} ≤
        Real.exp ((n : ℝ) / 25) / Real.exp ((n : ℝ) / 10) := by
    apply (le_div_iff₀ (Real.exp_pos _)).mpr
    nlinarith
  convert htail using 1
  rw [← Real.exp_sub]
  congr 1
  ring

/-- Simultaneous row control by a finite union bound. -/
theorem exists_bad_tangent_row_tail {n d : ℕ} (hd : 0 < d)
    (e : Fin n → TangentRowSpace d) (he : ∀ j, ‖e j‖ = 1)
    {t h : ℝ} (ht : 0 < t) (ht100 : t ≤ 1 / 100) (hh : 0 < h)
    (hh400 : h ≤ 1 / (400 * Real.exp 1)) :
    (independentTangentMeasure n d).real
      {g | ∃ i, (n : ℝ) / 10 ≤ offDiagonalTangentBadCount e t (h * t / Real.sqrt d) i g} ≤
      n * Real.exp (-3 * n / 50) := by
  rw [show {g | ∃ i, (n : ℝ) / 10 ≤ offDiagonalTangentBadCount e t (h * t / Real.sqrt d) i g} =
    ⋃ i, {g | (n : ℝ) / 10 ≤ offDiagonalTangentBadCount e t (h * t / Real.sqrt d) i g} by ext; simp]
  calc
    _ ≤ ∑ i, (independentTangentMeasure n d).real
        {g | (n : ℝ) / 10 ≤ offDiagonalTangentBadCount e t (h * t / Real.sqrt d) i g} :=
      measureReal_iUnion_fintype_le _
    _ ≤ ∑ _i : Fin n, Real.exp (-3 * (n : ℝ) / 50) :=
      Finset.sum_le_sum fun i _ => offDiagonalTangentBadCount_tail hd e he ht ht100 hh hh400 i
    _ = _ := by simp

/-- Large off-diagonal Gram entries of the independent normalized rows. -/
def independentTangentGoodNeighbors {n d : ℕ} (e : Fin n → TangentRowSpace d)
    (t b : ℝ) (g : Fin n → TangentRowSpace d) (i : Fin n) : Finset (Fin n) := by
  classical
  exact Finset.univ.filter fun j => j ≠ i ∧
    b < |inner ℝ (independentTangentDirection (e i) t (g i))
      (independentTangentDirection (e j) t (g j))|

theorem independentTangentGoodNeighbors_card {n d : ℕ}
    (e : Fin n → TangentRowSpace d) (t b : ℝ) (g : Fin n → TangentRowSpace d) (i : Fin n) :
    (independentTangentGoodNeighbors e t b g i).card +
      offDiagonalTangentBadCount e t b i g + 1 = (n : ℝ) := by
  classical
  let v := fun j => independentTangentDirection (e j) t (g j)
  have hpoint (j : Fin n) :
      (if j ≠ i ∧ b < |inner ℝ (v i) (v j)| then (1 : ℝ) else 0) +
      (if j = i then 0 else if |inner ℝ (v i) (v j)| ≤ b then 1 else 0) +
      (if j = i then 1 else 0) = 1 := by
    by_cases hji : j = i
    · simp [hji]
    · by_cases hb : |inner ℝ (v i) (v j)| ≤ b
      · simp [hji, hb, not_lt.mpr hb]
      · simp [hji, hb, lt_of_not_ge hb]
  have hsum := Finset.sum_congr rfl (fun j (_ : j ∈ (Finset.univ : Finset (Fin n))) => hpoint j)
  simp only [Finset.sum_add_distrib, Finset.sum_boole, Finset.sum_const,
    Finset.card_univ, Fintype.card_fin, nsmul_eq_mul, mul_one] at hsum
  simpa only [independentTangentGoodNeighbors, offDiagonalTangentBadCount,
    tangentBadIndicator, Finset.filter_eq', Finset.mem_univ, if_true, Finset.card_singleton, Nat.cast_one, v] using hsum

/-- Every row of the independent tangent seed has at least 85 percent large
Gram entries, except on an event of probability at most n exp(-3n/50). -/
theorem independentTangent_dense_core_failure_le {n d : ℕ} (hn : 20 ≤ n) (hd : 0 < d)
    (e : Fin n → TangentRowSpace d) (he : ∀ j, ‖e j‖ = 1)
    {t h : ℝ} (ht : 0 < t) (ht100 : t ≤ 1 / 100) (hh : 0 < h)
    (hh400 : h ≤ 1 / (400 * Real.exp 1)) :
    (independentTangentMeasure n d).real
      {g | ¬ ∀ i, 17 * (n : ℝ) / 20 ≤
        ((independentTangentGoodNeighbors e t (h * t / Real.sqrt d) g i).card : ℝ)} ≤
      n * Real.exp (-3 * n / 50) := by
  apply (measureReal_mono (μ := independentTangentMeasure n d) ?_).trans
    (exists_bad_tangent_row_tail hd e he ht ht100 hh hh400)
  intro g hg
  simp only [Set.mem_setOf_eq, not_forall, not_le] at hg
  obtain ⟨i, hi⟩ := hg
  refine ⟨i, ?_⟩
  have hcard := independentTangentGoodNeighbors_card e t (h * t / Real.sqrt d) g i
  have hnR : (20 : ℝ) ≤ n := by exact_mod_cast hn
  change (n : ℝ) / 10 ≤ _
  linarith


theorem measurable_independentTangentGoodNeighbors_card {n d : ℕ}
    (e : Fin n → TangentRowSpace d) (t b : ℝ) (i : Fin n) :
    Measurable (fun g => ((independentTangentGoodNeighbors e t b g i).card : ℝ)) := by
  have hfun : (fun g => ((independentTangentGoodNeighbors e t b g i).card : ℝ)) =
      fun g => (n : ℝ) - 1 - offDiagonalTangentBadCount e t b i g := by
    funext g
    linarith [independentTangentGoodNeighbors_card e t b g i]
  rw [hfun]
  exact measurable_const.sub (measurable_offDiagonalTangentBadCount e t b i)

theorem measurableSet_independentTangentDenseCore {n d : ℕ}
    (e : Fin n → TangentRowSpace d) (t b : ℝ) :
    MeasurableSet {g | ∀ i, 17 * (n : ℝ) / 20 ≤
      ((independentTangentGoodNeighbors e t b g i).card : ℝ)} := by
  rw [show {g | ∀ i, 17 * (n : ℝ) / 20 ≤
      ((independentTangentGoodNeighbors e t b g i).card : ℝ)} =
      ⋂ i, {g | 17 * (n : ℝ) / 20 ≤
        ((independentTangentGoodNeighbors e t b g i).card : ℝ)} by ext; simp]
  exact MeasurableSet.iInter fun i => measurableSet_le measurable_const
    (measurable_independentTangentGoodNeighbors_card e t b i)

end
end Paulsen
