import NeuralGeneralization.BatchTwoActivationScaledDual
import NeuralGeneralization.BatchTwoActivationTiltedCovariance
import NeuralGeneralization.GaussianFieldCovariance

/-! Actual Gaussian row certificates for bounded whole-vector observables.
The exceptional event is jointly measurable in its incoming coefficient
matrix, so it can be used after conditioning on earlier random layers. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open FiniteDifferential GaussianAngularFields GaussianAngularPrice GaussianFieldTilt
open BoundedDual BoundedTilt ActualBoundedDual DualCertificate CompressionSampling
variable {I J H : Type*} [Fintype I] [Fintype J] [Fintype H]
  [DecidableEq H] [Nonempty H] {N : ℕ}

def observableRows (A : I → J → ℝ) (a : Fin N → J → ℝ) : Fin N → I → ℝ :=
  fun i => fieldLinear A (a i)

theorem observableRows_measurable (A : I → J → ℝ) :
    Measurable (observableRows (N := N) A) := by
  apply measurable_pi_lambda
  intro i
  exact (fieldLinear A).continuous.measurable.comp (measurable_pi_apply i)

theorem observableRows_map (A : I → J → ℝ) :
    (iidSamples (standardLaw J) N).map (observableRows A) = iidSamples (fieldLaw A) N :=
  Measure.pi_map_pi (fun _ => (fieldLinear A).continuous.measurable.aemeasurable)

def scaledBadRows (A : I → J → ℝ) (F : H → (I → ℝ) → ℝ)
    (N : ℕ) (B G K : ℝ) : Set (Fin N → J → ℝ) :=
  observableRows A ⁻¹' scaledDualBad (fieldLaw A) F N B G K

theorem scaledBadRows_tail (A : I → J → ℝ) (F : H → (I → ℝ) → ℝ)
    (hF : ∀ j, Measurable (F j)) {B G K : ℝ} (hB : 0 < B) (hG : 0 < G)
    (hb : ∀ j x, |F j x| ≤ B) {s : ℕ} (hN : 0 < N) (hs : 0 < s) :
    (iidSamples (standardLaw J) N).real (scaledBadRows A F N B G K) ≤
      Real.exp ((s : ℝ) * Real.log (2 * (Fintype.card H : ℝ) + 1) -
        (N : ℝ) * (K - (G*B)^2 / (2*(s : ℝ)))) := by
  have hh := scaledDualBad_tail (fieldLaw A) F hF (K := K) hB hG hb hN hs
  rw [← observableRows_map A, Measure.real,
    Measure.map_apply (observableRows_measurable A)
      (scaledDualBad_measurable (fieldLaw A) F hF hB hb N G K)] at hh
  exact hh

theorem exists_tilt_of_not_scaledBadRows (A : I → J → ℝ)
    (F : H → (I → ℝ) → ℝ) (hF : ∀ j, Measurable (F j)) {B G K : ℝ}
    (hB : 0 < B) (hG : 0 < G) (hb : ∀ j x, |F j x| ≤ B)
    (a : Fin N → J → ℝ) (ha : a ∉ scaledBadRows A F N B G K) :
    ∃ Γ : H → ℝ, (∑ j, |Γ j|) ≤ G ∧ entropy (fieldLaw A) F Γ ≤ K ∧
      ∀ j, |(∑ i, F j (fieldLinear A (a i))) / N -
        mean (fieldLaw A) F Γ j| ≤ K/G := by
  exact exists_scaled_tilt_of_not_bad (fieldLaw A) F hF hB hG hb (observableRows A a) ha

theorem continuous_field_coefficients (z : J → ℝ) :
    Continuous (fun A : I → J → ℝ => fieldLinear A z) := by
  apply continuous_pi
  intro i
  simp only [fieldLinear_apply]
  fun_prop

@[fun_prop] theorem continuous_field_joint :
    Continuous (fun p : (I → J → ℝ) × (J → ℝ) => fieldLinear p.1 p.2) := by
  apply continuous_pi
  intro i
  simp only [fieldLinear_apply]
  fun_prop

theorem continuous_bounded_fieldPartition (F : H → (I → ℝ) → ℝ)
    (hF : ∀ j, Continuous (F j)) (hb : ∀ j x, |F j x| ≤ 1) (v : H → ℝ) :
    Continuous (fun A : I → J → ℝ => partition (fieldLaw A) (potential F v)) := by
  have hpot : Continuous (potential F v) := by
    unfold potential pairing
    fun_prop
  have heq (A : I → J → ℝ) : partition (fieldLaw A) (potential F v) =
      ∫ z, Real.exp (potential F v (fieldLinear A z)) ∂standardLaw J := by
    unfold partition
    exact integral_fieldLaw A _ (Real.continuous_exp.comp hpot).measurable
  simp_rw [heq]
  apply continuous_of_dominated (bound := fun _ : J → ℝ => Real.exp (entryL1 v))
  · intro A
    exact ((Real.continuous_exp.comp hpot).measurable.comp
      (fieldLinear A).continuous.measurable).aestronglyMeasurable
  · intro A
    apply ae_of_all
    intro z
    rw [Real.norm_eq_abs, Real.abs_exp]
    exact Real.exp_le_exp.mpr ((le_abs_self _).trans (potential_bound F hb v _))
  · exact integrable_const _
  · exact ae_of_all _ (fun z => (Real.continuous_exp.comp hpot).comp
      (continuous_field_coefficients z))

theorem continuous_bounded_fieldObjective (F : H → (I → ℝ) → ℝ)
    (hF : ∀ j, Continuous (F j)) (hb : ∀ j x, |F j x| ≤ 1) (v : H → ℝ) :
    Continuous (fun p : (I → J → ℝ) × (H → ℝ) => objective (fieldLaw p.1) F p.2 v) := by
  have hlog := ((continuous_bounded_fieldPartition F hF hb v).comp continuous_fst).log
    (fun p : (I → J → ℝ) × (H → ℝ) =>
      (partition_pos (fieldLaw p.1) _ (measurable_potential F (fun j => (hF j).measurable) v)
        (potential_bound F hb v)).ne')
  exact (by unfold pairing; fun_prop : Continuous
    (fun p : (I → J → ℝ) × (H → ℝ) => pairing v p.2)).sub hlog

theorem scaledBadRows_joint_open (F : H → (I → ℝ) → ℝ)
    (hF : ∀ j, Continuous (F j)) {B : ℝ} (hB : 0 < B)
    (hb : ∀ j x, |F j x| ≤ B) (G K : ℝ) :
    IsOpen {p : (I → J → ℝ) × (Fin N → J → ℝ) |
      p.2 ∈ scaledBadRows p.1 F N B G K} := by
  let F' := normalizedObservables F B
  have hF' : ∀ j, Continuous (F' j) := fun j => (hF j).div_const B
  have hb' : ∀ j x, |F' j x| ≤ 1 := normalizedObservables_bound F hB hb
  have he : {p : (I → J → ℝ) × (Fin N → J → ℝ) |
      p.2 ∈ scaledBadRows p.1 F N B G K} =
      ⋃ v : H → ℝ, ⋃ _hv : entryL1 v ≤ G*B,
      {p | K < objective (fieldLaw p.1) F' (empirical F' (observableRows p.1 p.2)) v} := by
    ext p
    simp only [scaledBadRows, scaledDualBad, Set.mem_preimage, badEvent, Set.mem_setOf_eq,
      Set.mem_iUnion]
    change (∃ v, entryL1 v ≤ G*B ∧
      K < objective (fieldLaw p.1) F' (empirical F' (observableRows p.1 p.2)) v) ↔ _
    tauto
  rw [he]
  apply isOpen_iUnion
  intro v
  apply isOpen_iUnion
  intro hv
  apply isOpen_lt continuous_const
  have hemp : Continuous (fun p : (I → J → ℝ) × (Fin N → J → ℝ) =>
      empirical F' (observableRows p.1 p.2)) := by
    apply continuous_pi
    intro j
    unfold empirical observableRows
    apply Continuous.div_const
    apply continuous_finset_sum
    intro k hk
    exact (hF' j).comp (continuous_field_joint.comp
      (continuous_fst.prodMk ((continuous_apply k).comp continuous_snd)))
  exact (continuous_bounded_fieldObjective F' hF' hb' v).comp
    (continuous_fst.prodMk hemp)

end NeuralGeneralization.BatchTwoActivation
