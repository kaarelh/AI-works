import Paulsen.RowSeedCore
import Paulsen.Paper.ManyRowAux1

/-!
# Helpers for `lem:mr-dense`: amplification of a per-pair failure bound

The rows of `Z₀` are independent.  Condition on row `i`; the failure indicators
`|⟨u_i, u_j⟩| < b` (`j ≠ i`) are then independent with probabilities at most `p`, so by the
exponential Markov inequality with parameter `1`,
`P(#failures ≥ 0.1(n-1)) ≤ (1+(e-1)p)^{n-1} e^{-0.1(n-1)} ≤ exp(-(n-1)(0.1-(e-1)p))`.
A union bound over `i` finishes.  (Adapted from `Paulsen.IndependentTangentCounts`, with the
strict failure event `|⟨u_i,u_j⟩| < b` and a general per-pair bound `p`.)
-/

namespace Paulsen.Paper

open MeasureTheory ProbabilityTheory Paulsen
open scoped BigOperators ProbabilityTheory

noncomputable section

/-- Indicator of a failure `|⟨f, u_e(z)⟩| < b`. -/
def mrxBadInd {d : ℕ} (e f : TangentRowSpace d) (t b : ℝ) (z : TangentRowSpace d) : ℝ :=
  if |inner ℝ f (independentTangentDirection e t z)| < b then 1 else 0

theorem mrxBadInd_nonneg {d : ℕ} (e f : TangentRowSpace d) (t b : ℝ) (z : TangentRowSpace d) :
    0 ≤ mrxBadInd e f t b z := by
  unfold mrxBadInd; split_ifs <;> norm_num

theorem mrxBadInd_le_one {d : ℕ} (e f : TangentRowSpace d) (t b : ℝ) (z : TangentRowSpace d) :
    mrxBadInd e f t b z ≤ 1 := by
  unfold mrxBadInd; split_ifs <;> norm_num

theorem measurable_mrxBadInd {d : ℕ} (e f : TangentRowSpace d) (t b : ℝ) :
    Measurable (mrxBadInd e f t b) := by
  apply Measurable.ite _ measurable_const measurable_const
  exact measurableSet_lt
    ((continuous_const.inner (continuous_independentTangentDirection e t)).abs.measurable)
    measurable_const

theorem integrable_mrxBadInd {d : ℕ} (e f : TangentRowSpace d) (t b : ℝ) :
    Integrable (mrxBadInd e f t b) (stdGaussian (TangentRowSpace d)) := by
  apply (integrable_const (1 : ℝ)).mono' (measurable_mrxBadInd e f t b).aestronglyMeasurable
  exact ae_of_all _ fun z => by
    rw [Real.norm_eq_abs, abs_of_nonneg (mrxBadInd_nonneg e f t b z)]
    exact mrxBadInd_le_one e f t b z

theorem integral_mrxBadInd {d : ℕ} (e f : TangentRowSpace d) (t b : ℝ) :
    (∫ z, mrxBadInd e f t b z ∂stdGaussian (TangentRowSpace d)) =
      (stdGaussian (TangentRowSpace d)).real
        {z | |inner ℝ f (independentTangentDirection e t z)| < b} := by
  change (∫ z, ({z | |inner ℝ f (independentTangentDirection e t z)| < b} : Set _).indicator
    (fun _ => (1 : ℝ)) z ∂stdGaussian (TangentRowSpace d)) = _
  exact integral_indicator_one (measurableSet_lt
    ((continuous_const.inner (continuous_independentTangentDirection e t)).abs.measurable)
    measurable_const)

theorem exp_mrxBadInd {d : ℕ} (e f : TangentRowSpace d) (t b : ℝ) (z : TangentRowSpace d) :
    Real.exp (mrxBadInd e f t b z) = 1 + (Real.exp 1 - 1) * mrxBadInd e f t b z := by
  unfold mrxBadInd; split_ifs <;> simp

/-- `E e^{β} = 1 + (e-1) P(β = 1) ≤ 1 + (e-1) p`. -/
theorem integral_exp_mrxBadInd_le {d : ℕ} (e f : TangentRowSpace d) (t b p : ℝ)
    (hp : (stdGaussian (TangentRowSpace d)).real
      {z | |inner ℝ f (independentTangentDirection e t z)| < b} ≤ p) :
    (∫ z, Real.exp (mrxBadInd e f t b z) ∂stdGaussian (TangentRowSpace d)) ≤
      1 + (Real.exp 1 - 1) * p := by
  simp_rw [exp_mrxBadInd]
  rw [integral_add (integrable_const _) ((integrable_mrxBadInd e f _ _).const_mul _),
    integral_const_mul, integral_const, integral_mrxBadInd]
  simp only [probReal_univ, one_smul]
  have hpos : 0 ≤ Real.exp (1 : ℝ) - 1 := sub_nonneg.mpr (Real.one_le_exp (by norm_num))
  nlinarith [mul_le_mul_of_nonneg_left hp hpos]

/-- The number of failures against a fixed direction `f`. -/
def mrxFixedCount {n d : ℕ} (e : Fin n → TangentRowSpace d) (f : TangentRowSpace d) (t b : ℝ)
    (g : Fin n → TangentRowSpace d) : ℝ :=
  ∑ j, mrxBadInd (e j) f t b (g j)

theorem integral_exp_mrxFixedCount_le {n d : ℕ} (e : Fin n → TangentRowSpace d)
    (f : TangentRowSpace d) (t b p : ℝ)
    (hp : ∀ j, (stdGaussian (TangentRowSpace d)).real
      {z | |inner ℝ f (independentTangentDirection (e j) t z)| < b} ≤ p) :
    (∫ g, Real.exp (mrxFixedCount e f t b g) ∂independentTangentMeasure n d) ≤
      (1 + (Real.exp 1 - 1) * p) ^ n := by
  simp only [mrxFixedCount, Real.exp_sum]
  calc
    _ = ∏ j, ∫ z, Real.exp (mrxBadInd (e j) f t b z) ∂stdGaussian (TangentRowSpace d) :=
      integral_fintype_prod_eq_prod (fun j z => Real.exp (mrxBadInd (e j) f t b z))
    _ ≤ ∏ _j : Fin n, (1 + (Real.exp 1 - 1) * p) := by
      apply Finset.prod_le_prod
      · intro j _
        exact integral_nonneg fun z => (Real.exp_pos _).le
      · intro j _
        exact integral_exp_mrxBadInd_le (e j) f t b p (hp j)
    _ = _ := by simp

/-- The number of failures in row `i` (off the diagonal). -/
def mrxOffCount {n d : ℕ} (e : Fin n → TangentRowSpace d) (t b : ℝ) (i : Fin n)
    (g : Fin n → TangentRowSpace d) : ℝ :=
  ∑ j, if j = i then 0 else mrxBadInd (e j) (independentTangentDirection (e i) t (g i)) t b (g j)

theorem measurable_mrxOffCount {n d : ℕ} (e : Fin n → TangentRowSpace d) (t b : ℝ) (i : Fin n) :
    Measurable (mrxOffCount e t b i) := by
  apply Finset.measurable_sum
  intro j _
  by_cases hji : j = i
  · simp only [hji, if_true]
    exact measurable_const
  · simp only [if_neg hji, mrxBadInd]
    apply Measurable.ite _ measurable_const measurable_const
    exact measurableSet_lt
      ((((continuous_independentTangentDirection (e i) t).comp (continuous_apply i)).inner
        ((continuous_independentTangentDirection (e j) t).comp (continuous_apply j))).abs.measurable)
      measurable_const

theorem mrxOffCount_le {n d : ℕ} (e : Fin n → TangentRowSpace d) (t b : ℝ) (i : Fin n)
    (g : Fin n → TangentRowSpace d) : mrxOffCount e t b i g ≤ n := by
  calc
    _ ≤ ∑ _j : Fin n, (1 : ℝ) := by
      apply Finset.sum_le_sum
      intro j _
      split_ifs
      · norm_num
      · exact mrxBadInd_le_one _ _ _ _ _
    _ = _ := by simp

theorem mrxOffCount_insertNth {n d : ℕ} (e : Fin (n + 1) → TangentRowSpace d) (t b : ℝ)
    (i : Fin (n + 1)) (u : TangentRowSpace d) (v : Fin n → TangentRowSpace d) :
    mrxOffCount e t b i (i.insertNth u v) =
      mrxFixedCount (fun j => e (i.succAbove j)) (independentTangentDirection (e i) t u) t b v := by
  unfold mrxOffCount mrxFixedCount
  rw [Fin.sum_univ_succAbove _ i]
  simp only [if_true, zero_add, Fin.succAbove_ne, if_false,
    Fin.insertNth_apply_same, Fin.insertNth_apply_succAbove]

/-- Conditioning on row `i`: `E e^{count_i} ≤ (1 + (e-1)p)^{n-1}`. -/
theorem integral_exp_mrxOffCount_le {n d : ℕ} (e : Fin n → TangentRowSpace d) (he : ∀ j, ‖e j‖ = 1)
    (t b p : ℝ) (hp : ∀ e' f : TangentRowSpace d, ‖e'‖ = 1 → ‖f‖ = 1 →
      (stdGaussian (TangentRowSpace d)).real
        {z | |inner ℝ f (independentTangentDirection e' t z)| < b} ≤ p) (i : Fin n) :
    (∫ g, Real.exp (mrxOffCount e t b i g) ∂independentTangentMeasure n d) ≤
      (1 + (Real.exp 1 - 1) * p) ^ (n - 1) := by
  cases n with
  | zero => exact Fin.elim0 i
  | succ n =>
    let μ := stdGaussian (TangentRowSpace d)
    let F : TangentRowSpace d × (Fin n → TangentRowSpace d) → ℝ := fun q =>
      Real.exp (mrxOffCount e t b i (i.insertNth q.1 q.2))
    let E := MeasurableEquiv.piFinSuccAbove (fun _ : Fin (n + 1) => TangentRowSpace d) i
    have hmp := measurePreserving_piFinSuccAbove (fun _ : Fin (n + 1) => μ) i
    have hFeq : F = (fun g => Real.exp (mrxOffCount e t b i g)) ∘ E.symm := rfl
    have hFm : Measurable F := by
      rw [hFeq]
      exact (measurable_mrxOffCount e t b i).exp.comp E.symm.measurable
    have hFi : Integrable F (μ.prod (independentTangentMeasure n d)) := by
      apply (integrable_const (Real.exp (n + 1 : ℝ))).mono' hFm.aestronglyMeasurable
      apply ae_of_all
      intro q
      rw [Real.norm_eq_abs, abs_of_pos (Real.exp_pos _)]
      apply Real.exp_le_exp.mpr
      exact_mod_cast mrxOffCount_le e t b i (i.insertNth q.1 q.2)
    calc
      _ = ∫ q, F q ∂(μ.prod (independentTangentMeasure n d)) :=
        (hmp.symm.integral_comp' _).symm
      _ = ∫ u, ∫ v, F (u, v) ∂independentTangentMeasure n d ∂μ := integral_prod F hFi
      _ ≤ ∫ _u, (1 + (Real.exp 1 - 1) * p) ^ n ∂μ := by
        apply integral_mono_of_nonneg
        · exact ae_of_all _ fun u => integral_nonneg fun v => (Real.exp_pos _).le
        · exact integrable_const _
        · apply ae_of_all
          intro u
          change (∫ v, Real.exp (mrxOffCount e t b i (i.insertNth u v))
            ∂independentTangentMeasure n d) ≤ _
          simp_rw [mrxOffCount_insertNth]
          exact integral_exp_mrxFixedCount_le _ _ t b p (fun j => hp _ _ (he (i.succAbove j))
            (norm_independentTangentDirection (e i) (he i) t u))
      _ = _ := by simp [μ]

theorem integrable_exp_mrxOffCount {n d : ℕ} (e : Fin n → TangentRowSpace d) (t b : ℝ)
    (i : Fin n) :
    Integrable (fun g => Real.exp (mrxOffCount e t b i g)) (independentTangentMeasure n d) := by
  apply (integrable_const (Real.exp (n : ℝ))).mono'
    (measurable_mrxOffCount e t b i).exp.aestronglyMeasurable
  apply ae_of_all
  intro g
  rw [Real.norm_eq_abs, abs_of_pos (Real.exp_pos _)]
  exact Real.exp_le_exp.mpr (mrxOffCount_le e t b i g)

/-- Exponential Markov with parameter `1`, then a union bound over the rows. -/
theorem mrx_exists_bad_row_tail {n d : ℕ} (e : Fin n → TangentRowSpace d)
    (he : ∀ j, ‖e j‖ = 1) (t b p : ℝ) (hp0 : 0 ≤ p)
    (hp : ∀ e' f : TangentRowSpace d, ‖e'‖ = 1 → ‖f‖ = 1 →
      (stdGaussian (TangentRowSpace d)).real
        {z | |inner ℝ f (independentTangentDirection e' t z)| < b} ≤ p) :
    (independentTangentMeasure n d).real
      {g | ∃ i, 1 / 10 * ((n : ℝ) - 1) ≤ mrxOffCount e t b i g} ≤
      n * Real.exp (-(1 / 10 - (Real.exp 1 - 1) * p) * ((n : ℝ) - 1)) := by
  rw [show {g | ∃ i, 1 / 10 * ((n : ℝ) - 1) ≤ mrxOffCount e t b i g} =
    ⋃ i, {g | 1 / 10 * ((n : ℝ) - 1) ≤ mrxOffCount e t b i g} by ext; simp]
  have hrow (i : Fin n) : (independentTangentMeasure n d).real
      {g | 1 / 10 * ((n : ℝ) - 1) ≤ mrxOffCount e t b i g} ≤
      Real.exp (-(1 / 10 - (Real.exp 1 - 1) * p) * ((n : ℝ) - 1)) := by
    have hn1 : (1 : ℝ) ≤ n := by
      have := i.pos; exact_mod_cast this
    have hmarkov := mul_meas_ge_le_integral_of_nonneg
      (ae_of_all _ fun g => (Real.exp_pos (mrxOffCount e t b i g)).le)
      (integrable_exp_mrxOffCount e t b i) (Real.exp (1 / 10 * ((n : ℝ) - 1)))
    simp only [Real.exp_le_exp] at hmarkov
    have hmean := integral_exp_mrxOffCount_le e he t b p hp i
    have hq : (1 + (Real.exp 1 - 1) * p) ^ (n - 1) ≤
        Real.exp ((Real.exp 1 - 1) * p * ((n : ℝ) - 1)) := by
      have h1 := Real.add_one_le_exp ((Real.exp 1 - 1) * p)
      have h0 : 0 ≤ 1 + (Real.exp 1 - 1) * p := by
        have : 0 ≤ Real.exp (1 : ℝ) - 1 := sub_nonneg.mpr (Real.one_le_exp (by norm_num))
        positivity
      calc (1 + (Real.exp 1 - 1) * p) ^ (n - 1) ≤ (Real.exp ((Real.exp 1 - 1) * p)) ^ (n - 1) :=
            pow_le_pow_left₀ h0 (by linarith) _
        _ = Real.exp ((Real.exp 1 - 1) * p * ((n - 1 : ℕ) : ℝ)) := by
            rw [← Real.exp_nat_mul]; ring_nf
        _ = _ := by rw [Nat.cast_sub (by exact_mod_cast hn1)]; simp
    have htail : (independentTangentMeasure n d).real
        {g | 1 / 10 * ((n : ℝ) - 1) ≤ mrxOffCount e t b i g} ≤
          Real.exp ((Real.exp 1 - 1) * p * ((n : ℝ) - 1)) /
            Real.exp (1 / 10 * ((n : ℝ) - 1)) := by
      apply (le_div_iff₀ (Real.exp_pos _)).mpr
      nlinarith
    convert htail using 1
    rw [← Real.exp_sub]
    congr 1
    ring
  calc
    _ ≤ ∑ i, (independentTangentMeasure n d).real
        {g | 1 / 10 * ((n : ℝ) - 1) ≤ mrxOffCount e t b i g} := measureReal_iUnion_fintype_le _
    _ ≤ ∑ _i : Fin n, Real.exp (-(1 / 10 - (Real.exp 1 - 1) * p) * ((n : ℝ) - 1)) :=
      Finset.sum_le_sum fun i _ => hrow i
    _ = _ := by simp

/-- Good neighbours `+` failures `+ 1 = n`. -/
theorem mrx_good_card {n d : ℕ} (e : Fin n → TangentRowSpace d) (t b : ℝ)
    (g : Fin n → TangentRowSpace d) (i : Fin n) :
    ((Finset.univ.filter fun j => j ≠ i ∧
      b ≤ |inner ℝ (independentTangentDirection (e i) t (g i))
        (independentTangentDirection (e j) t (g j))|).card : ℝ) + mrxOffCount e t b i g + 1 =
      (n : ℝ) := by
  classical
  let v := fun j => independentTangentDirection (e j) t (g j)
  have hpoint (j : Fin n) :
      (if j ≠ i ∧ b ≤ |inner ℝ (v i) (v j)| then (1 : ℝ) else 0) +
      (if j = i then 0 else if |inner ℝ (v i) (v j)| < b then 1 else 0) +
      (if j = i then 1 else 0) = 1 := by
    by_cases hji : j = i
    · simp [hji]
    · by_cases hb : |inner ℝ (v i) (v j)| < b
      · simp [hji, hb, not_le.mpr hb]
      · simp [hji, hb, le_of_not_gt hb]
  have hsum := Finset.sum_congr rfl (fun j (_ : j ∈ (Finset.univ : Finset (Fin n))) => hpoint j)
  simp only [Finset.sum_add_distrib, Finset.sum_boole, Finset.sum_const,
    Finset.card_univ, Fintype.card_fin, nsmul_eq_mul, mul_one] at hsum
  simpa only [mrxOffCount, mrxBadInd, Finset.filter_eq', Finset.mem_univ, if_true,
    Finset.card_singleton, Nat.cast_one, v] using hsum

/-- The failure probability of the dense reference graph for the actual sample. -/
theorem mrx_dense_failure_le {n d : ℕ} (X : Frame n d) (hn : 0 < n) (hd : 0 < d)
    (hX : IsEqualNorm X) {t h p : ℝ} (ht : 0 < t) (hh : 0 < h) (hp0 : 0 ≤ p)
    (hp : ∀ e' f : TangentRowSpace d, ‖e'‖ = 1 → ‖f‖ = 1 →
      (stdGaussian (TangentRowSpace d)).real
        {z | |inner ℝ f (independentTangentDirection e' t z)| < h * t / Real.sqrt d} ≤ p) :
    (stdGaussian (FrameVector n d)).real
      {g | ¬ ∀ i : Fin n, 9 / 10 * ((n : ℝ) - 1) ≤
        ((Finset.univ.filter (fun j => j ≠ i ∧
          h * t * Real.sqrt (((d : ℝ) / n) / n) ≤
            |(rowIndependentSeed X t g * (rowIndependentSeed X t g).transpose) i j|)).card : ℝ)} ≤
      n * Real.exp (-(1 / 10 - (Real.exp 1 - 1) * p) * ((n : ℝ) - 1)) := by
  set e := frameRowDirection X ((d : ℝ) / n)
  have ha : 0 < (d : ℝ) / n := by positivity
  have he : ∀ j, ‖e j‖ = 1 := norm_frameRowDirection X ha hX
  set b := h * t / Real.sqrt d
  set S : Set (Fin n → TangentRowSpace d) := {w | ∃ i, 1 / 10 * ((n : ℝ) - 1) ≤ mrxOffCount e t b i w}
  -- the threshold conversion `h t √(a/n) ≤ a |⟨u_i,u_j⟩| ⟺ b ≤ |⟨u_i,u_j⟩|`
  have hconv : h * t * Real.sqrt (((d : ℝ) / n) / n) = ((d : ℝ) / n) * b := by
    have hn' : (0 : ℝ) < n := by exact_mod_cast hn
    have hd' : (0 : ℝ) < d := by exact_mod_cast hd
    have e1 : ((d : ℝ) / n) / n = (Real.sqrt d / n) ^ 2 := by
      rw [div_pow, Real.sq_sqrt hd'.le]; ring
    rw [e1, Real.sqrt_sq (by positivity)]
    simp only [b]
    have hs : Real.sqrt (d : ℝ) ≠ 0 := (Real.sqrt_pos.mpr hd').ne'
    field_simp
    rw [Real.sq_sqrt hd'.le]
  have hsub : {g : FrameVector n d | ¬ ∀ i : Fin n, 9 / 10 * ((n : ℝ) - 1) ≤
      ((Finset.univ.filter (fun j => j ≠ i ∧
        h * t * Real.sqrt (((d : ℝ) / n) / n) ≤
          |(rowIndependentSeed X t g * (rowIndependentSeed X t g).transpose) i j|)).card : ℝ)} ⊆
      gaussianRows ⁻¹' S := by
    intro g hg
    simp only [Set.mem_setOf_eq, not_forall, not_le] at hg
    obtain ⟨i, hi⟩ := hg
    refine ⟨i, ?_⟩
    have hcard := mrx_good_card e t b (gaussianRows g) i
    have heq : (Finset.univ.filter (fun j => j ≠ i ∧
        h * t * Real.sqrt (((d : ℝ) / n) / n) ≤
          |(rowIndependentSeed X t g * (rowIndependentSeed X t g).transpose) i j|)) =
        Finset.univ.filter fun j => j ≠ i ∧
          b ≤ |inner ℝ (independentTangentDirection (e i) t (gaussianRows g i))
            (independentTangentDirection (e j) t (gaussianRows g j))| := by
      apply Finset.filter_congr
      intro j _
      rw [rowIndependentSeed_gram X hn hd hX t g i j, abs_mul, abs_of_pos ha, hconv]
      constructor
      · rintro ⟨h1, h2⟩; exact ⟨h1, le_of_mul_le_mul_left h2 ha⟩
      · rintro ⟨h1, h2⟩; exact ⟨h1, mul_le_mul_of_nonneg_left h2 ha.le⟩
    rw [heq] at hi
    change 1 / 10 * ((n : ℝ) - 1) ≤ mrxOffCount e t b i (gaussianRows g)
    linarith
  have hmeasS : MeasurableSet S := by
    rw [show S = ⋃ i, {w | 1 / 10 * ((n : ℝ) - 1) ≤ mrxOffCount e t b i w} by ext; simp [S]]
    exact MeasurableSet.iUnion fun i => measurableSet_le measurable_const
      (measurable_mrxOffCount e t b i)
  have hmap : (stdGaussian (FrameVector n d)).real (gaussianRows ⁻¹' S) =
      (independentTangentMeasure n d).real S := by
    apply congrArg ENNReal.toReal
    exact gaussianRows_measurePreserving.measure_preimage hmeasS.nullMeasurableSet
  apply (measureReal_mono (μ := stdGaussian (FrameVector n d)) hsub).trans
  rw [hmap]
  exact mrx_exists_bad_row_tail e he t b p hp0 hp

end

end Paulsen.Paper
