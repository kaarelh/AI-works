import NeuralGeneralization.OnlineLowerTanhPeriodicExactShape
import NeuralGeneralization.OnlineLowerTanhPhaseAbsorption

/-! Exact global periodic maximum and all equality locations, at every gain. -/
noncomputable section
open scoped BigOperators
open Set
namespace NeuralGeneralization.OnlineLowerTanh

lemma periodic_response_strictMonoOn {a : ℝ} (ha : 0<a) :
    StrictMonoOn (periodicFourierResponse a) (Icc (-a) a) := by
  apply strictMonoOn_of_deriv_pos (convex_Icc _ _)
    (continuous_iff_continuousAt.mpr (fun b => (periodicFourierResponse_hasDerivAt ha b).continuousAt)).continuousOn
  intro b hb
  rw [interior_Icc] at hb
  rw [(periodicFourierResponse_hasDerivAt ha b).deriv]
  exact periodic_derivative_pos_all_gain ha hb

lemma periodic_maximum_pos_all_gain {a : ℝ} (ha : 0<a) : 0<periodicFourierMaximum a := by
  have h := periodic_response_strictMonoOn ha (show (0:ℝ)∈Icc (-a) a by constructor <;>linarith)
    (show a∈Icc (-a) a by constructor <;>linarith) ha
  simpa only [periodicFourierResponse_zero,periodicFourierMaximum] using h

lemma periodic_response_center_reflection {a z : ℝ} (ha : 0<a) :
    periodicFourierResponse a (a+z)=periodicFourierResponse a (a-z) := by
  have h := periodicFourierResponse_antiperiod ha (z-a)
  rw [show z-a+2*a=a+z by ring,show z-a=-(a-z) by ring,
    periodicFourierResponse_odd,neg_neg] at h
  exact h

lemma periodic_response_near_peak {a z : ℝ} (ha : 0<a) (hz : |z|≤a) :
    0≤periodicFourierResponse a (a+z) ∧
    periodicFourierResponse a (a+z)≤periodicFourierMaximum a ∧
    (periodicFourierResponse a (a+z)=periodicFourierMaximum a ↔ z=0) := by
  have hmono := periodic_response_strictMonoOn ha
  have ht : a-|z|∈Icc (-a) a := ⟨by linarith,by linarith [abs_nonneg z]⟩
  have haI : a∈Icc (-a) a := ⟨by linarith,le_rfl⟩
  have hzero : (0:ℝ)∈Icc (-a) a := ⟨by linarith,ha.le⟩
  have heq : periodicFourierResponse a (a+z)=periodicFourierResponse a (a-|z|) := by
    by_cases hz0 : 0≤z
    · rw [abs_of_nonneg hz0]
      exact periodic_response_center_reflection ha
    · rw [abs_of_nonpos (le_of_not_ge hz0)]
      congr 1
      ring
  rw [heq]
  refine ⟨?_,hmono.monotoneOn ht haI (by linarith [abs_nonneg z]),?_⟩
  · have h := hmono.monotoneOn hzero ht (by linarith)
    simpa only [periodicFourierResponse_zero] using h
  · constructor
    · intro he
      have hh := hmono.injOn ht haI he
      have : |z|=0 := by linarith
      exact abs_eq_zero.mp this
    · rintro rfl
      simp only [abs_zero,sub_zero,periodicFourierMaximum]

/-- The full exact absolute maximum and equality lattice for the actual
periodic response, without any gain restriction besides positivity. -/
theorem periodic_maximum_and_equality_all_gain {a : ℝ} (ha : 0<a) (b : ℝ) :
    |periodicFourierResponse a b|≤periodicFourierMaximum a ∧
    (|periodicFourierResponse a b|=periodicFourierMaximum a ↔
      ∃ r : ℤ, Odd r ∧ b=a*(r:ℝ)) := by
  let r : ℤ := phaseInteger true (b/a)
  let z : ℝ := a*phaseError true (b/a)
  have hr : Odd r := phaseInteger_odd _
  have hz : |z|≤a := by
    dsimp [z]
    rw [abs_mul,abs_of_pos ha]
    exact (mul_le_mul_of_nonneg_left (phaseError_abs_le_one true (b/a)) ha.le).trans_eq (mul_one a)
  have hb : (r:ℝ)*a+z=b := by
    dsimp [r,z,phaseError]
    field_simp
    ring
  have hT : Function.Antiperiodic (periodicFourierResponse a) (2*a) := periodicFourierResponse_antiperiod ha
  obtain ⟨s,hs,hphase⟩ := odd_base_phase (periodicFourierResponse a) a hT hr
  have hphase := hphase z
  rw [hb] at hphase
  obtain ⟨hnon,hbound,heq⟩ := periodic_response_near_peak ha hz
  have habs : |periodicFourierResponse a b|=periodicFourierResponse a (a+z) := by
    rw [hphase,abs_mul,hs,one_mul,abs_of_nonneg hnon]
  refine ⟨habs ▸ hbound,?_⟩
  constructor
  · intro h
    rw [habs] at h
    have hz0 := heq.mp h
    refine ⟨r,hr,?_⟩
    rw [hz0,add_zero] at hb
    linarith
  · rintro ⟨q,hq,hbq⟩
    obtain ⟨t,ht,hqphase⟩ := odd_base_phase (periodicFourierResponse a) a hT hq
    have hh := hqphase 0
    simp only [add_zero] at hh
    rw [hbq,mul_comm a (q:ℝ),hh,abs_mul,ht,one_mul]
    exact abs_of_nonneg (periodic_maximum_pos_all_gain ha).le

end NeuralGeneralization.OnlineLowerTanh
