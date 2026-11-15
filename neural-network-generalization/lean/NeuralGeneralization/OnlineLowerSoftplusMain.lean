import NeuralGeneralization.OnlineLowerSoftplusFamilyAssembly
import NeuralGeneralization.OnlineLowerSoftplusTeacherPadding
import NeuralGeneralization.OnlineLowerExplicitThreshold

/-!
# The complete standard-softplus online mistake lower bound

No construction, atom, geometry, energy-gap, or concentration hypotheses
remain. The literal standard-softplus and ReLU learners use the same target,
full nonrepeating input permutation, and designated rounds.
-/
noncomputable section
open scoped BigOperators Topology Classical
open Filter
namespace NeuralGeneralization.OnlineLowerSoftplus
open ConcreteModel OnlineLower OnlineLowerRelu

/-- The full softplus theorem, including raw and padded bounded teachers,
actual circuit size, the same ReLU sequence, and all-large-fixed-width limits. -/
theorem softplus_concrete_main : SoftplusConcreteMainStatement := by
  have hR : 36 ≤ reluFixedRailSize := by
    exact (by norm_num : (36:ℕ) ≤ 2^6).trans
      (Nat.pow_le_pow_right (by norm_num) (by norm_num : 6 ≤ 1024))
  have heven : Even reluFixedRailSize := by norm_num [reluFixedRailSize,Nat.even_pow]
  obtain ⟨k₁,hk₁⟩ := Filter.eventually_atTop.mp
    (Family.calibration_absorption_eventually reluFixedRailSize (by omega) heven)
  refine ⟨max k₁ 3,le_max_right _ _,?_⟩
  intro k hk
  have hk3 : 3 ≤ k := (le_max_right _ _).trans hk
  have hsmall := hk₁ k ((le_max_left _ _).trans hk)
  obtain ⟨hteacher,hcircuit⟩ := reluConcrete_teacher_and_circuit k
  obtain ⟨π,J,hcount,hgaps⟩ :=
    Family.concrete_joint_stage_gaps reluFixedRailSize k hR heven hk3 hsmall
  have hsoft := softplusConcrete_bounded_teacher k
  refine ⟨softplusConcrete_raw_teacher k,hsoft,hcircuit,π,J,?_,?_⟩
  · refine ⟨hcount,?_⟩
    apply fixed_threshold_limits_of_energy_gaps (reluConcreteDimension_pos k)
      (continuous_const.max continuous_id) hteacher π J
      (reluConcreteTeacher_le_threshold k) (reluConcreteThreshold_pos k)
    intro N hN j hj
    exact (hgaps j hj).2 N ((reluConcreteThreshold_pos k).trans_le hN)
      ((reluConcrete_orbits_le_threshold k).trans hN)
  · apply allLargeWidthsFail_of_eventual_stage_gaps (reluConcreteDimension_pos k)
      continuous_softplus hsoft π J
    intro j hj
    obtain ⟨N₀,_,hlarge⟩ := (hgaps j hj).1
    exact ⟨N₀,hlarge⟩

/-- Linear input dimension, quadratic bounded-teacher width, exponentially
many designated mistakes, under the actual softplus Gaussian posterior. -/
theorem softplus_square_root_main : PolynomialResourceFamily softplus 1 2 :=
  softplus_concrete_main.squareRootStatement

/-- The exponential-in-square-root-width lower bound, with arbitrarily large
specified bounded teacher widths and all larger fixed learner widths. -/
theorem softplus_width_square_root_lower_bound : WidthExponentLowerBound softplus (1/2) :=
  polynomial_quadratic_resources_imply_square_root softplus 1 softplus_square_root_main

end NeuralGeneralization.OnlineLowerSoftplus
