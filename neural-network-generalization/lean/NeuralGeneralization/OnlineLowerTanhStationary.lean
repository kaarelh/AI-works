import NeuralGeneralization.OnlineLowerTanhStationaryCertificate
import NeuralGeneralization.OnlineLowerTanhSeriesDifferentiability
import Mathlib.Topology.Order.IntermediateValue

/-! The actual limiting stationary gain and its certified positive curvature. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open Set
namespace NeuralGeneralization.OnlineLowerTanh

theorem hasDerivAt_scalarStationary (a : ℝ) (ha : 6/5 < a) :
    HasDerivAt scalarStationary (a*scalarF0Second a) a := by
  have h := ((hasDerivAt_id a).mul (hasDerivAt_scalarF0First a ha)).sub (hasDerivAt_scalarF0 a ha)
  convert h using 1 <;> try rfl
  simp only [id_eq,one_mul]
  ring

theorem continuousOn_scalarStationary_gain_interval :
    ContinuousOn scalarStationary (Icc (123/100) (5/4)) := by
  intro a ha
  exact (hasDerivAt_scalarStationary a (by linarith [ha.1])).continuousAt.continuousWithinAt

theorem scalarF0_pos_gain_interval (a : ℝ) (ha : a ∈ Icc (123/100) (5/4)) : 0 < scalarF0 a := by
  have h := scalarComponentY_enclosure 0 (Real.exp (-2*a)) (decayBall_contains_of_gain_interval a ha)
  have hb : f0Ball.Contains (scalarF0 a) := by
    simpa [componentTargetBall,scalarComponentY,scalarF0] using h
  have hl := (abs_le.mp hb).1
  norm_num [f0Ball] at hl
  linarith

theorem scalarF0Second_neg_gain_interval (a : ℝ) (ha : a ∈ Icc (123/100) (5/4)) :
    scalarF0Second a < 0 := by
  have h := scalarComponentY_enclosure 4 (Real.exp (-2*a)) (decayBall_contains_of_gain_interval a ha)
  have hb : fppBall.Contains (scalarF0Second a) := by
    simpa [componentTargetBall,scalarComponentY,scalarF0Second] using h
  have hu := (abs_le.mp hb).2
  norm_num [fppBall] at hu
  linarith

theorem scalarStationary_strictAntiOn : StrictAntiOn scalarStationary (Icc (123/100) (5/4)) := by
  apply strictAntiOn_of_deriv_neg (convex_Icc _ _) continuousOn_scalarStationary_gain_interval
  intro a ha
  have ha' : a ∈ Icc (123/100) (5/4) := interior_subset ha
  rw [(hasDerivAt_scalarStationary a (by linarith [ha'.1])).deriv]
  exact mul_neg_of_pos_of_neg (by linarith [ha'.1]) (scalarF0Second_neg_gain_interval a ha')

theorem limitingGain_exists : ∃ a ∈ Ioo (123/100 : ℝ) (5/4), scalarStationary a=0 := by
  have hlevel : (0 : ℝ) ∈ Icc (scalarStationary (5/4)) (scalarStationary (123/100)) :=
    ⟨scalarStationary_high_neg.le,scalarStationary_low_pos.le⟩
  obtain ⟨a,ha,he⟩ := intermediate_value_Icc' (by norm_num : (123/100 : ℝ) ≤ 5/4)
    continuousOn_scalarStationary_gain_interval hlevel
  refine ⟨a,⟨?_,?_⟩,he⟩
  · apply lt_of_le_of_ne ha.1
    intro hx
    rw [← hx] at he
    exact scalarStationary_low_pos.ne' he
  · apply lt_of_le_of_ne ha.2
    intro hx
    rw [hx] at he
    exact scalarStationary_high_neg.ne he

def limitingGain : ℝ := Classical.choose limitingGain_exists

theorem limitingGain_mem : limitingGain ∈ Ioo (123/100 : ℝ) (5/4) :=
  (Classical.choose_spec limitingGain_exists).1

theorem limitingGain_stationary : scalarStationary limitingGain=0 :=
  (Classical.choose_spec limitingGain_exists).2

theorem limitingGain_unique (a : ℝ) (ha : a ∈ Icc (123/100 : ℝ) (5/4))
    (h : scalarStationary a=0) : a=limitingGain := by
  apply scalarStationary_strictAntiOn.injOn ha ⟨limitingGain_mem.1.le,limitingGain_mem.2.le⟩
  rw [h,limitingGain_stationary]

theorem limitingGain_pos : 0 < limitingGain := by linarith [limitingGain_mem.1]

theorem scalarF0_limitingGain_pos : 0 < scalarF0 limitingGain :=
  scalarF0_pos_gain_interval _ ⟨limitingGain_mem.1.le,limitingGain_mem.2.le⟩

theorem scalarF0Second_limitingGain_neg : scalarF0Second limitingGain < 0 :=
  scalarF0Second_neg_gain_interval _ ⟨limitingGain_mem.1.le,limitingGain_mem.2.le⟩

theorem limitingGain_nondegenerate : limitingGain*scalarF0Second limitingGain ≠ 0 :=
  (mul_neg_of_pos_of_neg limitingGain_pos scalarF0Second_limitingGain_neg).ne

theorem limitingGain_curvature_positive : 0 < normalizedOptimizedCurvature limitingGain :=
  lt_trans (by norm_num) (normalizedOptimizedCurvature_gt_tenth _
    ⟨limitingGain_mem.1.le,limitingGain_mem.2.le⟩)

end NeuralGeneralization.OnlineLowerTanh
