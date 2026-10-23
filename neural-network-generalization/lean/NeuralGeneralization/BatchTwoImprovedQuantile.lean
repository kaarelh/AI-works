import Mathlib.Probability.CDF
import Mathlib.Probability.Kernel.Composition.MapComap
import Mathlib.Probability.Kernel.Composition.Prod
import Mathlib.Topology.Order.LeftRightNhds
import Mathlib.Topology.Order.Monotone
import Mathlib.MeasureTheory.Measure.Lebesgue.Basic

/-! # Explicit measurable quantile coupling

The inverse-CDF map below is jointly measurable in an arbitrary probability
kernel and a uniform random seed. This supplies genuine coupling kernels, not
pointwise nonmeasurable choices. The transport cost is proved separately.
-/
noncomputable section
open MeasureTheory ProbabilityTheory Set Filter
open scoped Topology ENNReal ProbabilityTheory

namespace NeuralGeneralization.BatchTwoImprovedQuantile

/-- A right-continuous nondecreasing real function has closed upper level sets.
The one-sided continuity convention matters at atoms. -/
theorem stieltjes_upper_level_closed (F : StieltjesFunction ℝ) (u : ℝ) :
    IsClosed {x | u ≤ F x} := by
  rw [← isOpen_compl_iff]
  apply isOpen_iff_mem_nhds.mpr
  intro x hx
  have hxu : F x < u := lt_of_not_ge hx
  have he : {y | F y < u} ∈ 𝓝[≥] x :=
    (F.right_continuous x).eventually (Iio_mem_nhds hxu)
  obtain ⟨b, hxb, hsub⟩ := mem_nhdsGE_iff_exists_Ico_subset.mp he
  apply mem_of_superset (Iio_mem_nhds hxb)
  intro y hy
  change ¬ u ≤ F y
  apply not_le.mpr
  by_cases hxy : x ≤ y
  · exact hsub ⟨hxy, hy⟩
  · exact lt_of_le_of_lt (F.mono (le_of_not_ge hxy)) hxu

/-- The zero convention outside `(0,1)` only concerns a null set under the
uniform law used below. -/
def quantile (μ : Measure ℝ) (u : ℝ) : ℝ :=
  if 0 < u ∧ u < 1 then sInf {x | u ≤ cdf μ x} else 0

theorem quantile_level_nonempty (μ : Measure ℝ) {u : ℝ} (hu : u < 1) :
    {x | u ≤ cdf μ x}.Nonempty := by
  obtain ⟨x, hx⟩ := ((tendsto_cdf_atTop μ).eventually (Ioi_mem_nhds hu)).exists
  exact ⟨x, hx.le⟩

theorem quantile_level_bddBelow (μ : Measure ℝ) {u : ℝ} (hu : 0 < u) :
    BddBelow {x | u ≤ cdf μ x} := by
  obtain ⟨x, hx⟩ := ((tendsto_cdf_atBot μ).eventually (Iio_mem_nhds hu)).exists
  refine ⟨x, ?_⟩
  intro y hy
  by_contra hxy
  have hfy := (monotone_cdf μ) (le_of_not_ge hxy)
  exact (not_lt_of_ge hy) (lt_of_le_of_lt hfy hx)

theorem quantile_mem_level (μ : Measure ℝ) {u : ℝ} (hu : 0 < u ∧ u < 1) :
    u ≤ cdf μ (quantile μ u) := by
  rw [quantile, if_pos hu]
  exact (stieltjes_upper_level_closed (cdf μ) u).csInf_mem
    (quantile_level_nonempty μ hu.2) (quantile_level_bddBelow μ hu.1)

theorem quantile_le_iff (μ : Measure ℝ) {u x : ℝ} (hu : 0 < u ∧ u < 1) :
    quantile μ u ≤ x ↔ u ≤ cdf μ x := by
  constructor
  · intro hx
    exact (quantile_mem_level μ hu).trans ((monotone_cdf μ) hx)
  · intro hx
    rw [quantile, if_pos hu]
    exact csInf_le (quantile_level_bddBelow μ hu.1) hx

variable {Θ : Type*} [MeasurableSpace Θ]

/-- Kernel evaluations at a fixed CDF coordinate are measurable. -/
theorem measurable_kernel_cdf (κ : Kernel Θ ℝ) [IsMarkovKernel κ] (x : ℝ) :
    Measurable (fun θ => cdf (κ θ) x) := by
  simp_rw [cdf_eq_real]
  exact (κ.measurable_coe measurableSet_Iic).ennreal_toReal

/-- Joint measurability avoids any measurable-selection hypothesis when the
input law itself depends on previous random network layers. -/
theorem measurable_kernel_quantile (κ : Kernel Θ ℝ) [IsMarkovKernel κ] :
    Measurable (fun p : Θ × ℝ => quantile (κ p.1) p.2) := by
  apply measurable_of_Iic
  intro x
  have hv : MeasurableSet {p : Θ × ℝ | 0 < p.2 ∧ p.2 < 1} := by
    exact (measurableSet_lt measurable_const measurable_snd).inter
      (measurableSet_lt measurable_snd measurable_const)
  have hl : MeasurableSet {p : Θ × ℝ | p.2 ≤ cdf (κ p.1) x} :=
    measurableSet_le measurable_snd ((measurable_kernel_cdf κ x).comp measurable_fst)
  have heq : (fun p : Θ × ℝ => quantile (κ p.1) p.2) ⁻¹' Iic x =
      ({p | 0 < p.2 ∧ p.2 < 1} ∩ {p | p.2 ≤ cdf (κ p.1) x}) ∪
      ({p | ¬ (0 < p.2 ∧ p.2 < 1)} ∩ {p | (0 : ℝ) ≤ x}) := by
    ext p
    by_cases hp : 0 < p.2 ∧ p.2 < 1
    · simp only [mem_preimage, mem_Iic, mem_union, mem_inter_iff, mem_setOf_eq,
        hp, true_and, not_true_eq_false, false_and, or_false]
      exact quantile_le_iff _ hp
    · simp only [mem_preimage, mem_Iic, mem_union, mem_inter_iff, mem_setOf_eq]
      rw [quantile, if_neg hp]
      simp only [hp, false_and, false_or, not_false_eq_true, true_and]
  rw [heq]
  exact (hv.inter hl).union (hv.compl.inter (by
    by_cases hx : (0 : ℝ) ≤ x <;> simp [hx]))

/-- A probability uniform seed on the open unit interval. -/
def uniformSeed : Measure ℝ := volume.restrict (Ioo 0 1)

instance uniformSeed_probability : IsProbabilityMeasure uniformSeed := by
  constructor
  simp [uniformSeed, Real.volume_Ioo]

/-- Actual scalar quantile coupling of two parameterized probability laws. -/
def quantileCouplingKernel (κ η : Kernel Θ ℝ)
    [IsMarkovKernel κ] [IsMarkovKernel η] : Kernel Θ (ℝ × ℝ) :=
  (Kernel.id ×ₖ Kernel.const Θ uniformSeed).map
    (fun p => (quantile (κ p.1) p.2, quantile (η p.1) p.2))

instance quantileCouplingKernel_markov (κ η : Kernel Θ ℝ)
    [IsMarkovKernel κ] [IsMarkovKernel η] :
    IsMarkovKernel (quantileCouplingKernel κ η) := by
  unfold quantileCouplingKernel
  exact Kernel.IsMarkovKernel.map _
    ((measurable_kernel_quantile κ).prodMk (measurable_kernel_quantile η))


theorem measurable_quantile (μ : Measure ℝ) [IsProbabilityMeasure μ] :
    Measurable (quantile μ) := by
  have h := (measurable_kernel_quantile (Kernel.const Unit μ)).comp
    (measurable_const.prodMk measurable_id : Measurable (fun u : ℝ => ((), u)))
  simpa only [Kernel.const_apply, Function.comp_def] using h

theorem volume_unit_seed_cdf {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    volume (Iic p ∩ Ioo (0 : ℝ) 1) = ENNReal.ofReal p := by
  by_cases hp : p < 1
  · have hs : Iic p ∩ Ioo (0 : ℝ) 1 = Ioc 0 p := by
      ext u
      simp only [mem_inter_iff, mem_Iic, mem_Ioo, mem_Ioc]
      constructor
      · rintro ⟨hup, hu0, hu1⟩
        exact ⟨hu0, hup⟩
      · rintro ⟨hu0, hup⟩
        exact ⟨hup, hu0, hup.trans_lt hp⟩
    rw [hs, Real.volume_Ioc]
    simp
  · have hp' : p = 1 := le_antisymm hp1 (le_of_not_gt hp)
    subst p
    have hs : Iic (1 : ℝ) ∩ Ioo 0 1 = Ioo 0 1 :=
      inter_eq_right.mpr (fun _ hx => hx.2.le)
    rw [hs, Real.volume_Ioo]
    norm_num

/-- Exact inverse-CDF sampling, valid for atomic laws as well as continuous
ones. No density hypothesis is imposed. -/
theorem quantile_pushforward (μ : Measure ℝ) [IsProbabilityMeasure μ] :
    uniformSeed.map (quantile μ) = μ := by
  have hm := measurable_quantile μ
  letI : IsProbabilityMeasure (uniformSeed.map (quantile μ)) :=
    Measure.isProbabilityMeasure_map hm.aemeasurable
  apply Measure.ext_of_Iic
  intro x
  rw [Measure.map_apply hm measurableSet_Iic, uniformSeed,
    Measure.restrict_apply (measurableSet_Iic.preimage hm)]
  have hs : quantile μ ⁻¹' Iic x ∩ Ioo 0 1 = Iic (cdf μ x) ∩ Ioo 0 1 := by
    ext u
    simp only [mem_inter_iff, mem_preimage, mem_Iic, mem_Ioo]
    constructor
    · rintro ⟨hux, hu⟩
      exact ⟨(quantile_le_iff μ hu).mp hux, hu⟩
    · rintro ⟨hux, hu⟩
      exact ⟨(quantile_le_iff μ hu).mpr hux, hu⟩
  rw [hs, volume_unit_seed_cdf (cdf_nonneg μ x) (cdf_le_one μ x), ofReal_cdf]

theorem quantileCouplingKernel_apply (κ η : Kernel Θ ℝ)
    [IsMarkovKernel κ] [IsMarkovKernel η] (θ : Θ) :
    quantileCouplingKernel κ η θ = uniformSeed.map
      (fun u => (quantile (κ θ) u, quantile (η θ) u)) := by
  have hm := (measurable_kernel_quantile κ).prodMk (measurable_kernel_quantile η)
  rw [quantileCouplingKernel, Kernel.map_apply _ hm, Kernel.prod_apply,
    Kernel.id_apply, Kernel.const_apply, Measure.dirac_prod,
    Measure.map_map hm measurable_prodMk_left]
  rfl

theorem quantileCouplingKernel_fst (κ η : Kernel Θ ℝ)
    [IsMarkovKernel κ] [IsMarkovKernel η] (θ : Θ) :
    (quantileCouplingKernel κ η θ).map Prod.fst = κ θ := by
  rw [quantileCouplingKernel_apply,
    Measure.map_map measurable_fst
      ((measurable_quantile (κ θ)).prodMk (measurable_quantile (η θ)))]
  exact quantile_pushforward (κ θ)

theorem quantileCouplingKernel_snd (κ η : Kernel Θ ℝ)
    [IsMarkovKernel κ] [IsMarkovKernel η] (θ : Θ) :
    (quantileCouplingKernel κ η θ).map Prod.snd = η θ := by
  rw [quantileCouplingKernel_apply,
    Measure.map_map measurable_snd
      ((measurable_quantile (κ θ)).prodMk (measurable_quantile (η θ)))]
  exact quantile_pushforward (η θ)

end NeuralGeneralization.BatchTwoImprovedQuantile
