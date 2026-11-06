import NeuralGeneralization.BatchTwoNeuralConverseOperatorAction
import NeuralGeneralization.BatchTwoNeuralConverseWidthLimit
import Mathlib.Topology.Order.Monotone
import NeuralGeneralization.NetworkEnergy

/-! Width convergence of the actual strict spectral function energy. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators Topology
open Classical Set Filter
open ConcreteModel

def operator_fixedSqrtAction {d : ℕ} (N r : ℕ) (U : ℝ) (f : BooleanFunction d) : ℝ :=
  sInf ((fun w : Weights d N r => Real.sqrt (weightedSquaredNorm w)) '' operatorFunctionSupport U f)

theorem operator_fixedCosts_bddBelow {d : ℕ} (N r : ℕ) (U : ℝ) (f : BooleanFunction d) :
    BddBelow ((fun w : Weights d N r => Real.sqrt (weightedSquaredNorm w)) '' operatorFunctionSupport U f) := by
  refine ⟨0,?_⟩
  rintro _ ⟨w,hw,rfl⟩
  exact Real.sqrt_nonneg _

theorem operator_fixedSqrtAction_le {d N r : ℕ} {U : ℝ} {f : BooleanFunction d}
    (w : Weights d N r) (hw : w ∈ operatorFunctionSupport U f) :
    operator_fixedSqrtAction N r U f≤Real.sqrt (weightedSquaredNorm w) :=
  csInf_le (operator_fixedCosts_bddBelow N r U f) ⟨w,hw,rfl⟩

theorem operator_neuralSqrtAction_le_fixed {d N r : ℕ} {U : ℝ} {f : BooleanFunction d}
    (hne : (operatorFunctionSupport (N := N) (r := r) U f).Nonempty) :
    operator_neuralSqrtAction r U f≤operator_fixedSqrtAction N r U f := by
  apply le_csInf (hne.image _)
  rintro _ ⟨w,hw,rfl⟩
  exact operator_neuralSqrtAction_le w hw

theorem operator_eventually_functionSupport_nonempty {d : ℕ} (hd : 0<d) (r : ℕ) {U : ℝ}
    (hU : 1<U) (f : BooleanFunction d) :
    ∀ᶠ N : ℕ in atTop, (operatorFunctionSupport (N := N) (r := r) U f).Nonempty := by
  obtain ⟨C,hC,w,hw⟩ := operator_exists_supported_function hd r hU f
  filter_upwards [eventually_ge_atTop C] with N hN
  exact ⟨paddedClone hC N w,operator_paddedClone_supported hC hN w hw⟩

theorem operator_fixedSqrtAction_tendsto {d : ℕ} (hd : 0<d) (r : ℕ) {U : ℝ}
    (hU : 1<U) (f : BooleanFunction d) :
    Tendsto (fun N : ℕ => operator_fixedSqrtAction N r U f) atTop (𝓝 (operator_neuralSqrtAction r U f)) := by
  apply tendsto_order.mpr
  constructor
  · intro a ha
    filter_upwards [operator_eventually_functionSupport_nonempty hd r hU f] with N hne
    exact ha.trans_le (operator_neuralSqrtAction_le_fixed hne)
  · intro b hb
    obtain ⟨c,hc,hcb⟩ := (csInf_lt_iff (operator_sqrtCosts_bddBelow r U f)
      (operator_sqrtCosts_nonempty hd r hU f)).mp hb
    obtain ⟨C,hC,w,hw,rfl⟩ := hc
    have hlim := (clone_factor_tendsto hC).mul_const (weightedSquaredNorm w)
    have hroot := Real.continuous_sqrt.continuousAt.tendsto.comp hlim
    simp only [one_mul] at hroot
    have hevent := hroot.eventually (gt_mem_nhds hcb)
    filter_upwards [eventually_ge_atTop C,hevent] with N hN hbound
    apply (operator_fixedSqrtAction_le (paddedClone hC N w) (operator_paddedClone_supported hC hN w hw)).trans_lt
    exact (Real.sqrt_le_sqrt (paddedClone_energy_le hC hN w)).trans_lt hbound

theorem operator_fixedSqrtAction_eq_sqrt_inf {d N r : ℕ} {U : ℝ} {f : BooleanFunction d}
    (hne : (operatorFunctionSupport (N := N) (r := r) U f).Nonempty) :
    operator_fixedSqrtAction N r U f = Real.sqrt (sInf (weightedSquaredNorm '' operatorFunctionSupport (N := N) (r := r) U f)) := by
  symm
  have h := Monotone.map_csInf_of_continuousAt
    Real.continuous_sqrt.continuousAt Real.sqrt_monotone
    (hne.image weightedSquaredNorm) (weightedSquaredNorm_image_bddBelow _)
  simpa only [Set.image_image,Function.comp_def,operator_fixedSqrtAction] using h

end
end NeuralGeneralization.BatchTwoNeuralConverse
