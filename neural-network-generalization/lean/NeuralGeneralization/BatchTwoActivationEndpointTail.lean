import NeuralGeneralization.BatchTwoActivationEndpointClass
import NeuralGeneralization.BatchTwoActivationFullNetworkEvents
import NeuralGeneralization.BatchTwoActivationStrongPrior

/-! Actual prior mass outside one polynomial-capacity class, uniform in the
Gaussian scale throughout Nσ²≤1. -/
noncomputable section
open MeasureTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel

theorem activation_endpoint_complement_mass_le {b d K N r : ℕ}
    (hb : 1≤b) (hd : 1≤d) (hK : 1≤K) (hN : 0<N)
    {ℓ B σ : ℝ} (hℓ0 : 0<ℓ) (hℓ : ℓ≤b) (hB0 : 0≤B) (hB : B≤b)
    (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1)
    {φ : ℝ → ℝ} (hφ : zeroLipschitzActivation ℓ φ)
    (hb' : ∀u,|deriv scalarCutoff u|≤B) (hbb : ∀u,|deriv (deriv scalarCutoff) u|≤B)
    (hwidth : activationLearnerThreshold b d K (r+1)≤N) :
    (∑f∈Finset.univ\activationEndpointFunctions b d K (r+1),
      functionMass φ (1/2) (smallPrior d N r σ) f)≤
      (2*((r:ℝ)+1)+1)*Real.exp (-(N:ℝ)*(K:ℝ)) := by
  classical
  let μ := smallPrior d N r σ
  let A := Finset.univ\activationEndpointFunctions b d K (r+1)
  have hcont := zeroLipschitzActivation_continuous hφ hℓ0.le
  have heq : μ.real (⋃f∈A,marginEvent φ (1/2) f)=
      ∑f∈A,functionMass φ (1/2) μ f := by
    exact measureReal_biUnion_finset
      (fun f _ g _ hfg => marginEvents_disjoint φ (by norm_num) hfg)
      (fun f _ => (isOpen_marginEvent hcont (1/2) f).measurableSet)
  change (∑f∈A,functionMass φ (1/2) μ f)≤_
  rw [←heq]
  apply le_trans _ (ActivationGoodNetwork.compl_tail (by omega) hN hb hK (by omega : r≤r+1)
    hσ hscale hφ hℓ0.le hB0 hℓ hB hb' hbb hwidth)
  apply measureReal_mono _ (measure_ne_top μ _)
  intro w hw hgood
  obtain ⟨f,hf,hwf⟩ := Set.mem_iUnion₂.mp hw
  have hnot : f∉activationEndpointFunctions b d K (r+1) := (Finset.mem_sdiff.mp hf).2
  apply hnot
  exact actual_good_network_endpoint_mem hb hd hK hN hℓ0 hℓ hB0 hB hσ hscale hφ hb' hbb
    w f hwf hgood.1 hgood.2

end NeuralGeneralization.BatchTwoActivation
