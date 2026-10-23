import NeuralGeneralization.BatchTwoImprovedSourceKernel

/-! The single input-independent good-Gram event and its genuine conditional
probability under the measurable source sampling kernel. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators RealInnerProductSpace
open MeasureTheory ProbabilityTheory InnerProductSpace Set WithLp
namespace NeuralGeneralization.BatchTwoImprovedWeightedSampling
open SquaredSampling RobustGaussianGeometry BatchTwoImprovedActiveGeometry Classical
variable {N q m : ℕ}

def sourceBad (b : Fin q → EuclideanSpace ℝ (Fin N)) (s : Fin m → Fin N) : Prop :=
  badGramOn (sourceSampleRow (fun j k => sourceRows b j k)) (onActiveSlots b) s

@[fun_prop] theorem measurable_sourceSampleRow :
    Measurable (sourceSampleRow (N:=N) (q:=q)) := by
  unfold sourceSampleRow
  have ha := measurable_sourceMultiplier (N:=N) (q:=q)
  fun_prop

theorem measurable_sourceBad_fixed (s : Fin m → Fin N) :
    MeasurableSet {b : Fin q → EuclideanSpace ℝ (Fin N) | sourceBad b s} := by
  have hrows : Measurable (fun b : Fin q → EuclideanSpace ℝ (Fin N) =>
      fun j k => sourceRows b j k) := by
    apply measurable_pi_lambda
    intro j
    exact (WithLp.measurable_ofLp 2 (Fin q → ℝ)).comp
      ((measurable_pi_apply j).comp measurable_sourceRows)
  have hs := measurable_sourceSampleRow.comp hrows
  have he : {b : Fin q → EuclideanSpace ℝ (Fin N) | sourceBad b s} =
      ⋃ S : Finset (Fin q), {b | activeSlots b=S} ∩
        {b | badGramOn (sourceSampleRow (fun j k => sourceRows b j k))
          (fun v => ∀ k, k ∉ S → v k=0) s} := by
    ext b
    simp only [mem_setOf_eq,mem_iUnion,mem_inter_iff]
    constructor
    · intro h
      exact ⟨activeSlots b,rfl,h⟩
    · rintro ⟨S,hS,hb⟩
      unfold sourceBad onActiveSlots
      rw [hS]
      exact hb
  rw [he]
  apply MeasurableSet.iUnion
  intro S
  exact (measurableSet_eq_fun measurable_activeSlots measurable_const).inter
    ((isOpen_badGramOn (fun v => ∀ k, k ∉ S → v k=0) s).measurableSet.preimage hs)

theorem measurable_sourceBad :
    MeasurableSet {p : (Fin q → EuclideanSpace ℝ (Fin N)) × (Fin m → Fin N) |
      sourceBad p.1 p.2} := by
  have he : {p : (Fin q → EuclideanSpace ℝ (Fin N)) × (Fin m → Fin N) | sourceBad p.1 p.2} =
      ⋃ s : Fin m → Fin N, {p | p.2=s} ∩ {p | sourceBad p.1 s} := by
    ext p
    simp
  rw [he]
  apply MeasurableSet.iUnion
  intro s
  exact (measurableSet_eq_fun measurable_snd measurable_const).inter
    ((measurable_sourceBad_fixed s).preimage measurable_fst)

theorem sourceBank_failure (hN : 0 < N) (hq : 0 < q) (hm : 0 < m)
    (b : Fin q → EuclideanSpace ℝ (Fin N))
    {η : ℝ} (hη : 0 < η) (hη1 : η ≤ 1)
    (hbudget : 256*(268435456:ℝ)^2*(2*q)*restrictionLog m q ≤ η^2*m) :
    (sourceIndicesKernel hN hq m (fun j k => sourceRows b j k)).real {s | sourceBad b s} ≤ η := by
  let u := fun j k => sourceRows b j k
  let p := sourceProbability u
  have hcov (v : Fin q → ℝ) :
      mean p (fun j => (linearEvaluation (sourceSampleRow u j) v)^2) ≤ ∑ k, (v k)^2 := by
    rw [sourceSampleRow_covariance hN hq]
    have h := sourceRows_quadratic_le b hN (toLp 2 v)
    simpa only [EuclideanSpace.real_norm_sq_eq,EuclideanSpace.inner_eq_star_dotProduct,
      dotProduct,star_trivial,Pi.star_apply,linearEvaluation,mul_comm,u] using h
  have hiso (v : Fin q → ℝ) (hv : onActiveSlots b v) :
      mean p (fun j => (linearEvaluation (sourceSampleRow u j) v)^2) = ∑ k, (v k)^2 := by
    rw [sourceSampleRow_covariance hN hq]
    exact sourceRows_covariance_active b hN v hv
  have hp := fun j => (sourceProbability_pos hN hq u j).le
  have hpm := sourceProbability_mass hN hq u
  have h := weighted_badGramOn_probability_le p hp hpm hm (sourceSampleRow u)
    (onActiveSlots b) (2*q) (by positivity) (sourceSampleRow_energy_le hN hq u (sourceRows_trace b hN))
    hcov hiso hη hη1 hbudget
  change (finiteLaw (iidWeight p m) (iidWeight_nonneg p hp m) (iidWeight_mass p hpm m)).real _ ≤ _
  rw [finiteLaw_real_apply]
  exact h

theorem sourceBank_variance_error (hN : 0 < N) (hq : 0 < q) (hm : 0 < m)
    (b : Fin q → EuclideanSpace ℝ (Fin N)) (h : Fin N → ℝ) (hh : ∀ j, (h j)^2 ≤ 1) :
    let u := fun j k => sourceRows b j k
    let a := sourceMultiplier u
    (∫ s, if sourceBad b s then 0 else
      (‖queryResidual (sampledColumns a s u) (sampledVector a s (sourceResidual b h))‖-
        ‖queryResidual b (normalizedFeature h)‖)^2
      ∂sourceIndicesKernel hN hq m u) ≤ 16*((q:ℝ)+1)/(m:ℝ) := by
  dsimp only
  let u := fun j k => sourceRows b j k
  let p := sourceProbability u
  let a := sourceMultiplier u
  have hp := fun j => (sourceProbability_pos hN hq u j).le
  have hpm := sourceProbability_mass hN hq u
  have ha := fun j => (sourceMultiplier_pos hN hq u j).le
  have hc := whitened_variance_mean_square hN hm p a hp hpm ha
    (sourceProbability_mul_multiplier hN hq u) u (sourceResidual b h)
    (sourceResidual_orthogonal b h)
    (sourceMultiplier_energy_le hN hq u (sourceRows_trace b hN))
    (sourceResidual_weighted_bound b h hN hq hh)
    (sourceResidual_energy_le_one b h hN hh) (activeSlots b)
    (sourceRows_zero_off_active b)
  rw [sourceResidual_energy b h hN,Real.sqrt_sq (norm_nonneg _)] at hc
  change (∫ s, _ ∂finiteLaw (iidWeight p m) (iidWeight_nonneg p hp m) (iidWeight_mass p hpm m)) ≤ _
  rw [finiteLaw_integral]
  exact hc

end NeuralGeneralization.BatchTwoImprovedWeightedSampling
