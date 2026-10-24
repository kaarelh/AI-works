import NeuralGeneralization.BatchTwoImprovedQuantile
import Mathlib.MeasureTheory.Integral.Lebesgue.Add

/-! # Stability of the measurable quantile coupling under distribution limits

Pointwise convergence of CDFs implies almost-everywhere convergence of the
explicit quantiles. Fatou then passes quadratic coupling-cost bounds to the
limit, without assuming an optimal-transport or compactness theorem.
-/
noncomputable section
open MeasureTheory ProbabilityTheory Set Filter
open scoped Topology ENNReal

namespace NeuralGeneralization.BatchTwoImprovedQuantile

theorem monotoneOn_quantile (μ : Measure ℝ) :
    MonotoneOn (quantile μ) (Ioo 0 1) := by
  intro u hu v hv huv
  apply (quantile_le_iff μ hu).mpr
  exact huv.trans (quantile_mem_level μ hv)

theorem ae_continuousAt_quantile (μ : Measure ℝ) :
    ∀ᵐ u ∂uniformSeed, ContinuousAt (quantile μ) u := by
  letI : NullSingletonClass uniformSeed := by
    dsimp [uniformSeed]
    infer_instance
  have hc := (monotoneOn_quantile μ).countable_not_continuousWithinAt
  have hmem : ∀ᵐ u ∂uniformSeed, u ∈ Ioo (0 : ℝ) 1 :=
    ae_restrict_mem measurableSet_Ioo
  filter_upwards [hmem, hc.ae_notMem uniformSeed] with u hu hgood
  have hwithin : ContinuousWithinAt (quantile μ) (Ioo 0 1) u := by
    by_contra hn
    exact hgood ⟨hu, hn⟩
  exact hwithin.continuousAt (isOpen_Ioo.mem_nhds hu)

/-- CDF convergence is only needed at the fixed test coordinates used in the
inverse-CDF comparison. Continuity of the limiting quantile excludes the
countably many levels at which an interval of zero probability is skipped. -/
theorem tendsto_quantile_of_cdf {ι : Type*} {l : Filter ι}
    (P : ι → Measure ℝ) (μ : Measure ℝ)
    (hP : ∀ x, Tendsto (fun i => cdf (P i) x) l (𝓝 (cdf μ x)))
    {u : ℝ} (hu : 0 < u ∧ u < 1) (hcont : ContinuousAt (quantile μ) u) :
    Tendsto (fun i => quantile (P i) u) l (𝓝 (quantile μ u)) := by
  apply tendsto_order.mpr
  constructor
  · intro a ha
    have hca : cdf μ a < u := by
      apply lt_of_not_ge
      intro h
      exact (not_le_of_gt ha) ((quantile_le_iff μ hu).mpr h)
    filter_upwards [(hP a).eventually (Iio_mem_nhds hca)] with i hi
    apply lt_of_not_ge
    intro hq
    exact (not_le_of_gt hi) ((quantile_le_iff (P i) hu).mp hq)
  · intro b hb
    have hn : {v | quantile μ v < b} ∈ 𝓝 u :=
      hcont.eventually (Iio_mem_nhds hb)
    obtain ⟨w, huw, hsub⟩ := exists_Ico_subset_of_mem_nhds hn (exists_gt u)
    obtain ⟨v, huv, hvw⟩ := exists_between (lt_min huw hu.2)
    have hv0 : 0 < v := hu.1.trans huv
    have hv1 : v < 1 := hvw.trans_le (min_le_right _ _)
    have hvb : quantile μ v < b := hsub ⟨huv.le, hvw.trans_le (min_le_left _ _)⟩
    have hcv : u < cdf μ (quantile μ v) :=
      huv.trans_le (quantile_mem_level μ ⟨hv0, hv1⟩)
    filter_upwards [(hP (quantile μ v)).eventually (Ioi_mem_nhds hcv)] with i hi
    exact ((quantile_le_iff (P i) hu).mpr hi.le).trans_lt hvb

theorem ae_tendsto_quantile_of_cdf {ι : Type*} {l : Filter ι}
    (P : ι → Measure ℝ) (μ : Measure ℝ)
    (hP : ∀ x, Tendsto (fun i => cdf (P i) x) l (𝓝 (cdf μ x))) :
    ∀ᵐ u ∂uniformSeed,
      Tendsto (fun i => quantile (P i) u) l (𝓝 (quantile μ u)) := by
  have hmem : ∀ᵐ u ∂uniformSeed, u ∈ Ioo (0 : ℝ) 1 :=
    ae_restrict_mem measurableSet_Ioo
  filter_upwards [hmem, ae_continuousAt_quantile μ] with u hu hc
  exact tendsto_quantile_of_cdf P μ hP hu hc


/-- The squared displacement of the explicit one-dimensional quantile coupling.
The extended integral also covers laws without finite second moment. -/
def quantileQuadraticCost (μ ν : Measure ℝ) : ℝ≥0∞ :=
  ∫⁻ u, ENNReal.ofReal ((quantile μ u - quantile ν u)^2) ∂uniformSeed

theorem quantileQuadraticCost_lower_semicontinuous
    (P Q : ℕ → Measure ℝ) (μ ν : Measure ℝ)
    [∀ n, IsProbabilityMeasure (P n)] [∀ n, IsProbabilityMeasure (Q n)]
    (hP : ∀ x, Tendsto (fun n => cdf (P n) x) atTop (𝓝 (cdf μ x)))
    (hQ : ∀ x, Tendsto (fun n => cdf (Q n) x) atTop (𝓝 (cdf ν x))) :
    quantileQuadraticCost μ ν ≤
      liminf (fun n => quantileQuadraticCost (P n) (Q n)) atTop := by
  have hm (n : ℕ) : Measurable (fun u =>
      ENNReal.ofReal ((quantile (P n) u - quantile (Q n) u)^2)) :=
    (((measurable_quantile (P n)).sub (measurable_quantile (Q n))).pow_const 2).ennreal_ofReal
  have heq : (fun u => ENNReal.ofReal ((quantile μ u - quantile ν u)^2)) =ᵐ[uniformSeed]
      (fun u => liminf (fun n =>
        ENNReal.ofReal ((quantile (P n) u - quantile (Q n) u)^2)) atTop) := by
    filter_upwards [ae_tendsto_quantile_of_cdf P μ hP,
      ae_tendsto_quantile_of_cdf Q ν hQ] with u hp hq
    exact (ENNReal.continuous_ofReal.tendsto _ |>.comp ((hp.sub hq).pow 2)).liminf_eq.symm
  unfold quantileQuadraticCost
  rw [lintegral_congr_ae heq]
  exact lintegral_liminf_le hm

/-- Quadratic cost estimates survive simultaneous CDF limits of both actual
marginals. This is the limiting step needed when smooth positive densities are
used to approximate general finite-entropy measures. -/
theorem quantileQuadraticCost_le_of_cdf_limits
    (P Q : ℕ → Measure ℝ) (μ ν : Measure ℝ)
    [∀ n, IsProbabilityMeasure (P n)] [∀ n, IsProbabilityMeasure (Q n)]
    (hP : ∀ x, Tendsto (fun n => cdf (P n) x) atTop (𝓝 (cdf μ x)))
    (hQ : ∀ x, Tendsto (fun n => cdf (Q n) x) atTop (𝓝 (cdf ν x)))
    (B : ℕ → ℝ≥0∞) (b : ℝ≥0∞) (hB : Tendsto B atTop (𝓝 b))
    (hcost : ∀ n, quantileQuadraticCost (P n) (Q n) ≤ B n) :
    quantileQuadraticCost μ ν ≤ b := by
  have h := quantileQuadraticCost_lower_semicontinuous P Q μ ν hP hQ
  have hb : liminf (fun n => quantileQuadraticCost (P n) (Q n)) atTop ≤
      liminf B atTop := liminf_le_liminf (Filter.Eventually.of_forall hcost)
  rw [hB.liminf_eq] at hb
  exact h.trans hb

end NeuralGeneralization.BatchTwoImprovedQuantile
