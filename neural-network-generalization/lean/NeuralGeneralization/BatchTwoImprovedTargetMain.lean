import NeuralGeneralization.BatchTwoImprovedTargetParameters
import NeuralGeneralization.BatchTwoMergingSharpTarget

/-! Original calibrated support: actual Gaussian target mass with a logarithmic
Boolean compiler gain, uniformly at every learner width above circuit width. -/
noncomputable section
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.ConcreteModel
open NeuralGeneralization.BatchTwoMerging
variable {d C N r k p:ℕ}

theorem improved_target_mass_cloned (hd:0<d) (hC:0<C) (hk:0<k)
    (hbelow:C*k≤N) (habove:N≤2*C*k)
    (e:((Fin C×Fin k)⊕Fin p)≃Fin N) (B:LayeredBooleanCircuit d C r)
    {c σ:ℝ} (hc:0<c) (hσ:0<σ) (hscale:(N:ℝ)*σ^2≤1):
    Real.exp (-improvedTargetCost d C r c/σ^2)≤
      (smallPrior d N r σ).real (robustEvent Real.tanh c ∩marginEvent Real.tanh (1/2) B.computes) := by
  have hN:0<N := (Nat.mul_pos hC hk).trans_le hbelow
  obtain ⟨b,J,hJ,hrows,hhidden⟩ := exists_adapted_saturated_clone B e (improvedGain C r) (improvedReadout c)
  have hcost:weightedSquaredNorm (B.saturatedClone e (improvedGain C r) (improvedReadout c))≤
      improvedTeacherCost d C r c := B.saturatedClone_sharp_energy e hN hk habove _ _
  obtain ⟨hA,ha,hε,hε1,hτ,hρ,hreadρ,hfirst,hgroup,hinit,hstep,hout,hcal⟩ :=
    improved_parameter_conditions d r hC hc
  have hr:0< improvedRadius d C := (improvedRadius_bounds d hC).1
  have hr16:improvedRadius d C≤1/16 := by
    have hh:=(improvedRadius_bounds d hC).2.1
    have he:=(improvedError_bounds hC).2
    linarith
  have hm:=sharpCoordinateCylinder_mass hd hN
    (B.saturatedClone e (improvedGain C r) (improvedReadout c)) b J hr hr16 hσ hscale
    (show (J.card:ℝ)≤(C:ℝ)+1 by exact_mod_cast hJ) hcost
  exact hm.trans (measureReal_mono (improvedCoordinateCylinder_containment hd hN hk habove hbelow B e b J
    hA ha hε hε1 hτ hρ hreadρ hfirst hgroup hinit hstep hout hc hcal hσ hscale hJ hrows hhidden)
    (measure_ne_top _ _))

theorem improved_target_mass_all_widths (hd:0<d) (hC:0<C) (hCN:C≤N)
    (B:LayeredBooleanCircuit d C r) {c σ:ℝ} (hc:0<c) (hσ:0<σ) (hscale:(N:ℝ)*σ^2≤1):
    Real.exp (-improvedTargetCost d C r c/σ^2)≤
      (smallPrior d N r σ).real (robustEvent Real.tanh c ∩marginEvent Real.tanh (1/2) B.computes) := by
  classical
  let k:=N/C
  have hk:0<k := Nat.div_pos hCN hC
  have hmod:N%C<C := Nat.mod_lt _ hC
  have hsplit:N%C+C*k=N := Nat.mod_add_div N C
  have hbelow:C*k≤N := by omega
  have hCk:C≤C*k := by simpa only [Nat.mul_one] using Nat.mul_le_mul_left C hk
  have habove:N≤2*C*k := by nlinarith
  let e:((Fin C×Fin k)⊕Fin (N-C*k))≃Fin N := Fintype.equivOfCardEq (by
    simp only [Fintype.card_sum,Fintype.card_prod,Fintype.card_fin]
    omega)
  exact improved_target_mass_cloned hd hC hk hbelow habove e B hc hσ hscale

theorem improvedTargetCost_nonneg (d r:ℕ) (hC:0<C) (c:ℝ):
    0≤ improvedTargetCost d C r c := by
  obtain ⟨hr,hrE,_,_⟩ := improvedRadius_bounds d hC
  have he:=(improvedError_bounds hC).2
  exact sharpCylinderCost_nonneg d r (by unfold improvedTeacherCost;positivity)
    (by positivity) hr (by linarith)

end NeuralGeneralization.ConcreteModel
