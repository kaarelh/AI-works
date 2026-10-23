import NeuralGeneralization.BatchTwoActivationFullNetworkEventsDiagonal
import NeuralGeneralization.BatchTwoActivationStrongPrior

/-! Joint measurability of the adaptive full-network exceptional events. -/
noncomputable section
set_option maxHeartbeats 1200000
set_option maxRecDepth 10000
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel GaussianAngularFields CompressionSampling FiniteDifferential
open RobustCompressionBlockMoments NetworkLayerSplit TowerNetwork

variable {b d K H N r : ℕ} {σ ℓ B : ℝ} {φ : ℝ→ℝ}

theorem activationStageBad_joint_measurable (hb : 1≤b) (hK : 1≤K)
    {s n : ℕ} (hs : s≤H) (hφ : zeroLipschitzActivation ℓ φ)
    (hℓ0 : 0≤ℓ) (hB0 : 0≤B) (hℓ : ℓ≤b) (hB : B≤b)
    (hder : ∀t,|deriv scalarCutoff t|≤B)
    (hder2 : ∀t,|deriv (deriv scalarCutoff) t|≤B) :
    MeasurableSet {p : (Cube d → Fin n →ℝ) × (Fin N→Fin n→ℝ) |
      p.2∈polynomialLayerBad p.1 φ
        (activationStageBudget H (activationBaseBudget b d K H) s) N
        (activationDiagonalBudget b d K s) (4*(K:ℝ))} := by
  obtain ⟨hk,hℓk,hBk,_,_,_,_,hlog⟩:=activation_stage_budget_envelopes hb hK hs hℓ hB
  exact polynomialLayerBad_joint_measurable _ hk hφ hℓ0 hB0
    (Nat.cast_pos.mpr (activationDiagonalBudget_pos hb)) hℓk hBk hlog hder hder2 _

theorem measurableSet_activationInputBad (hb : 1≤b) (hK : 1≤K)
    (hφ : zeroLipschitzActivation ℓ φ) (hℓ0 : 0≤ℓ) (hB0 : 0≤B)
    (hℓ : ℓ≤b) (hB : B≤b) (hder : ∀t,|deriv scalarCutoff t|≤B)
    (hder2 : ∀t,|deriv (deriv scalarCutoff) t|≤B) :
    MeasurableSet (activationInputBad b d K H N φ σ) := by
  have he := activationStageBad_joint_measurable (b:=b) (d:=d) (K:=K) (H:=H)
    (N:=N) (n:=d+1) hb hK (s:=0) (Nat.zero_le H) hφ hℓ0 hB0 hℓ hB hder hder2
  have hm : Measurable (fun w : Weights d N 0=>(activationInputSource d N σ,activationInputRows σ w)) :=
    measurable_const.prodMk (measurable_activationInputRows σ)
  have hh := he.preimage hm
  exact hh

theorem measurableSet_activationLastBad (hb : 1≤b) (hK : 1≤K) (hr : r+1≤H)
    (hφ : zeroLipschitzActivation ℓ φ) (hℓ0 : 0≤ℓ) (hB0 : 0≤B)
    (hℓ : ℓ≤b) (hB : B≤b) (hder : ∀t,|deriv scalarCutoff t|≤B)
    (hder2 : ∀t,|deriv (deriv scalarCutoff) t|≤B) :
    MeasurableSet (activationLastBad b d K H N r φ σ) := by
  have he := activationStageBad_joint_measurable (b:=b) (d:=d) (K:=K) (H:=H)
    (N:=N) (n:=N) hb hK hr hφ hℓ0 hB0 hℓ hB hder hder2
  have hm : Measurable (fun w : Weights d N (r+1)=>(activationLastSource φ σ (previousWeights w),activationLastRows σ w)) :=
    ((measurable_activationLastSource (zeroLipschitzActivation_continuous hφ hℓ0) σ).comp
      continuous_previousWeights.measurable).prodMk (measurable_activationLastRows σ)
  have hh := he.preimage hm
  exact hh

theorem measurableSet_ActivationGoodHidden (hb : 1≤b) (hK : 1≤K)
    (hφ : zeroLipschitzActivation ℓ φ) (hℓ0 : 0≤ℓ) (hB0 : 0≤B)
    (hℓ : ℓ≤b) (hB : B≤b) (hder : ∀t,|deriv scalarCutoff t|≤B)
    (hder2 : ∀t,|deriv (deriv scalarCutoff) t|≤B) :
    ∀r,r≤H→MeasurableSet {w | ActivationGoodHidden b d K H N φ σ r w} := by
  intro r
  induction r with
  | zero =>
    intro _
    exact (measurableSet_activationInputBad hb hK hφ hℓ0 hB0 hℓ hB hder hder2).compl
  | succ r ih =>
    intro hr
    exact ((ih (by omega)).preimage continuous_previousWeights.measurable).inter
      (measurableSet_activationLastBad hb hK hr hφ hℓ0 hB0 hℓ hB hder hder2).compl

end NeuralGeneralization.BatchTwoActivation
