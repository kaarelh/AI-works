import NeuralGeneralization.BatchTwoNeuralConverseActualAction
import NeuralGeneralization.BatchTwoNeuralConverseWidthLimit
import Mathlib.Topology.Order.Monotone
import NeuralGeneralization.NetworkEnergy

/-! Width convergence of the actual gain-restricted function energy. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators Topology
open Classical Set Filter
open ConcreteModel

def fixedSqrtAction {d : ℕ} (N r : ℕ) (Λ U : ℝ) (f : BooleanFunction d) : ℝ :=
  sInf ((fun w : Weights d N r => Real.sqrt (weightedSquaredNorm w)) '' functionSupport Λ U f)

theorem fixedCosts_bddBelow {d : ℕ} (N r : ℕ) (Λ U : ℝ) (f : BooleanFunction d) :
    BddBelow ((fun w : Weights d N r => Real.sqrt (weightedSquaredNorm w)) '' functionSupport Λ U f) := by
  refine ⟨0,?_⟩
  rintro _ ⟨w,hw,rfl⟩
  exact Real.sqrt_nonneg _

theorem fixedSqrtAction_le {d N r : ℕ} {Λ U : ℝ} {f : BooleanFunction d}
    (w : Weights d N r) (hw : w ∈ functionSupport Λ U f) :
    fixedSqrtAction N r Λ U f≤Real.sqrt (weightedSquaredNorm w) :=
  csInf_le (fixedCosts_bddBelow N r Λ U f) ⟨w,hw,rfl⟩

theorem neuralSqrtAction_le_fixed {d N r : ℕ} {Λ U : ℝ} {f : BooleanFunction d}
    (hne : (functionSupport (N := N) (r := r) Λ U f).Nonempty) :
    neuralSqrtAction r Λ U f≤fixedSqrtAction N r Λ U f := by
  apply le_csInf (hne.image _)
  rintro _ ⟨w,hw,rfl⟩
  exact neuralSqrtAction_le w hw

theorem eventually_functionSupport_nonempty {d : ℕ} (hd : 0<d) (r : ℕ) {Λ U : ℝ}
    (hΛ : 1<Λ) (hU : 1<U) (f : BooleanFunction d) :
    ∀ᶠ N : ℕ in atTop, (functionSupport (N := N) (r := r) Λ U f).Nonempty := by
  obtain ⟨C,hC,w,hw⟩ := exists_supported_function hd r hΛ hU f
  filter_upwards [eventually_ge_atTop C] with N hN
  exact ⟨paddedClone hC N w,paddedClone_supported hC hN w hw⟩

theorem fixedSqrtAction_tendsto {d : ℕ} (hd : 0<d) (r : ℕ) {Λ U : ℝ}
    (hΛ : 1<Λ) (hU : 1<U) (f : BooleanFunction d) :
    Tendsto (fun N : ℕ => fixedSqrtAction N r Λ U f) atTop (𝓝 (neuralSqrtAction r Λ U f)) := by
  apply tendsto_order.mpr
  constructor
  · intro a ha
    filter_upwards [eventually_functionSupport_nonempty hd r hΛ hU f] with N hne
    exact ha.trans_le (neuralSqrtAction_le_fixed hne)
  · intro b hb
    obtain ⟨c,hc,hcb⟩ := (csInf_lt_iff (sqrtCosts_bddBelow r Λ U f)
      (sqrtCosts_nonempty hd r hΛ hU f)).mp hb
    obtain ⟨C,hC,w,hw,rfl⟩ := hc
    have hlim := (clone_factor_tendsto hC).mul_const (weightedSquaredNorm w)
    have hroot := Real.continuous_sqrt.continuousAt.tendsto.comp hlim
    simp only [one_mul] at hroot
    have hevent := hroot.eventually (gt_mem_nhds hcb)
    filter_upwards [eventually_ge_atTop C,hevent] with N hN hbound
    apply (fixedSqrtAction_le (paddedClone hC N w) (paddedClone_supported hC hN w hw)).trans_lt
    exact (Real.sqrt_le_sqrt (paddedClone_energy_le hC hN w)).trans_lt hbound

theorem fixedSqrtAction_eq_sqrt_inf {d N r : ℕ} {Λ U : ℝ} {f : BooleanFunction d}
    (hne : (functionSupport (N := N) (r := r) Λ U f).Nonempty) :
    fixedSqrtAction N r Λ U f = Real.sqrt (sInf (weightedSquaredNorm '' functionSupport (N := N) (r := r) Λ U f)) := by
  symm
  have h := Monotone.map_csInf_of_continuousAt
    Real.continuous_sqrt.continuousAt Real.sqrt_monotone
    (hne.image weightedSquaredNorm) (weightedSquaredNorm_image_bddBelow _)
  simpa only [Set.image_image,Function.comp_def,fixedSqrtAction] using h

end
end NeuralGeneralization.BatchTwoNeuralConverse
