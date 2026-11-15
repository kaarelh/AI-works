import NeuralGeneralization.BatchTwoManuscriptTargetParameters
import NeuralGeneralization.BatchTwoManuscriptTargetGeometry
import NeuralGeneralization.BatchTwoManuscriptTargetCylinderMass
import NeuralGeneralization.BatchTwoOnlineBalancedTarget

/-! Original Gaussian target mass at every width, with the displayed D_* exactly. -/
noncomputable section
set_option autoImplicit false
set_option maxHeartbeats 1000000
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.BatchTwoManuscriptTarget
open ConcreteModel BatchTwoMerging BatchTwoOnlineBalanced
variable {d C N r : ℕ}

theorem targetCost_ge_one (d r : ℕ) (hC : 0<C) (c : ℝ) : 1≤targetCost d C r c := by
  obtain ⟨hρ,hρ4,_,_⟩ := targetRadius_bounds d r hC
  have hc : (1:ℝ)≤C := by exact_mod_cast hC
  have ha : 2≤targetReadout c := le_max_left _ _
  have hCa := mul_le_mul_of_nonneg_right hc (sq_nonneg (targetReadout c))
  have hK : 8≤targetTeacherCost d C r c := by
    unfold targetTeacherCost
    nlinarith [mul_nonneg (show 0≤9*(d:ℝ) by positivity) (sq_nonneg (targetGain C r)),
      mul_nonneg (show 0≤18*(r:ℝ)*C by positivity) (sq_nonneg (targetGain C r))]
  have hroot : 1≤Real.sqrt (2*Real.pi) := by
    apply (Real.le_sqrt (by norm_num) (by positivity)).mpr
    nlinarith only [Real.pi_gt_three]
  have he : 1≤Real.exp 1 := by simpa only [Real.exp_zero] using Real.exp_le_exp.mpr (show (0:ℝ)≤1 by norm_num)
  have hprod : 1≤Real.exp 1*Real.sqrt (2*Real.pi) := by nlinarith
  have harg : 1≤Real.exp 1*Real.sqrt (2*Real.pi)/(2*targetRadius d C r) := by
    apply (le_div_iff₀ (by positivity)).mpr
    linarith
  have hlog := Real.log_nonneg harg
  have hm := mul_nonneg (show 0≤(d:ℝ)+2+(r:ℝ)*C by positivity) hlog
  have hl2 : 0≤Real.log 2 := Real.log_nonneg (by norm_num)
  unfold targetCost sharpCylinderCost
  linarith

theorem literal_target_mass_all_widths (hd : 0<d) (hC : 0<C) (hCN : C≤N)
    (B : LayeredBooleanCircuit d C r) {c σ : ℝ} (hc : 0<c) (hσ : 0<σ)
    (hscale : (N:ℝ)*σ^2≤1) :
    Real.exp (-targetCost d C r c/σ^2)≤(smallPrior d N r σ).real
      (robustEvent Real.tanh c ∩ marginEvent Real.tanh (1/2) B.computes) := by
  have hN := hC.trans_le hCN
  let e := balancedLayout (N:=N) hC
  have hk := balancedGroupSize_pos hC hCN
  have habove := fun a=>(balancedGroupSize_bounds hC hCN a).1
  have hbelow := fun a=>(balancedGroupSize_bounds hC hCN a).2
  obtain ⟨b,J,hJ,hrows,_,hideal⟩ :=
    exists_adapted_grouped_merging Real.tanh e hk B (targetGain C r) (targetReadout c)
  obtain ⟨hA,ha,hε,hε1,hτ,hρ,hreadρ,hfirst,hgroup,hinit,hstep,hout,hcal⟩ :=
    target_parameter_conditions d r hC hc
  have hcontain := targetCoordinateCylinder_containment hd hN hk habove hbelow B e b J
    hA ha hε hε1 hτ hρ hreadρ hfirst hgroup hinit hstep hout hc hcal hσ hscale hJ hrows hideal
  have hsub : sharpCoordinateCylinder (groupedWeights B e (targetGain C r) (targetReadout c))
      b J (targetRadius d C r) σ ⊆ robustEvent Real.tanh c ∩ marginEvent Real.tanh (1/2) B.computes := by
    intro w hw
    obtain ⟨hr,hm⟩ := hcontain hw
    refine ⟨hr,?_⟩
    intro x
    have hh := hm x
    linarith
  have henergy := grouped_teacher_energy B e hN hk habove hbelow (targetGain C r) (targetReadout c)
  have hm := targetCoordinateCylinder_mass hd hN (groupedWeights B e (targetGain C r) (targetReadout c))
    b J (targetRadius_bounds d r hC).1 (targetRadius_bounds d r hC).2.1 hσ hscale
    (show (J.card:ℝ)≤C by exact_mod_cast hJ) henergy
  exact hm.trans (measureReal_mono hsub (measure_ne_top _ _))

end NeuralGeneralization.BatchTwoManuscriptTarget
