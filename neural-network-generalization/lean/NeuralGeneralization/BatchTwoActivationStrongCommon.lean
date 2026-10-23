import NeuralGeneralization.BatchTwoActivationUniformLearning
import NeuralGeneralization.BatchTwoActivationUniformTail
import NeuralGeneralization.BatchTwoActivationStrongPrior

/-! The original Gaussian strong-prior rate gives a common sample event
across widths, while allowing width-specific small-variance thresholds. -/
noncomputable section
set_option maxHeartbeats 1600000
open scoped BigOperators Topology
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel Filter MeasureTheory

theorem strong_common_class_learning {d C r:ℕ} (hd:1≤d) {φ:ℝ→ℝ}
    (hφ:Continuous φ) (f:BooleanFunction d) (hf:realizesAtComplexity (r:=r) φ f C)
    (F:Finset (BooleanFunction d)) {P:ℝ} (hcount:(F.card:ℝ)≤Real.exp P)
    (hsub:∀N,C≤N→lowEnergyFunctions (N:=N) (r:=r) φ f⊆F)
    {ε:ℝ} (hε:0<ε) (hε1:ε<1) :
    ∃σ₀:ℕ→ℝ,(∀N,0<σ₀ N) ∧
      ∀D:InputLaw d,∀δ:ℝ,0<δ→∀n:ℕ,
      (2/ε)*(P+Real.log (1/δ))≤(n:ℝ)→
      (∀N,C≤N→∀σ,0<σ→σ<σ₀ N→∀s:Fin n→Cube d,
        0<posteriorDenominator φ (1/2) (smallPrior d N r σ) f s) ∧
      1-δ≤sampleProbability D n (fun s=>∀N,C≤N→∀σ,0<σ→σ<σ₀ N→
        posteriorRisk D f (networkPosterior φ (1/2) (smallPrior d N r σ) f s)≤ε) := by
  classical
  have hth (N:ℕ) : ∃σ₀:ℝ,0<σ₀ ∧ ∀hCN:C≤N,∀σ,0<σ→σ<σ₀→
      0<functionMass φ (1/2) (smallPrior d N r σ) f ∧
      (∑g∈Finset.univ\F,functionMass φ (1/2) (smallPrior d N r σ) g)/
        functionMass φ (1/2) (smallPrior d N r σ) f≤ε/2 := by
    by_cases hCN:C≤N
    · have hN:0<N := (by have := hf.1;omega : 0<C).trans_le hCN
      have ht := network_highEnergy_tail_ratio_tendsto_zero (by omega) hN hφ f
        (margin_witness_at_larger_width φ f hf hCN)
      have he : ∀ᶠσ in 𝓝[>] (0:ℝ),
          0<functionMass φ (1/2) (smallPrior d N r σ) f ∧
          (∑g∈Finset.univ\F,functionMass φ (1/2) (smallPrior d N r σ) g)/
            functionMass φ (1/2) (smallPrior d N r σ) f≤ε/2 := by
        have he' := ht.eventually (gt_mem_nhds (show (0:ℝ)<ε/2 by linarith))
        filter_upwards [self_mem_nhdsWithin,he'] with σ hσ hh
        have hp := small_functionMass_pos (by omega) hφ f hf hCN (show 0<σ from hσ)
        refine ⟨hp,?_⟩
        have hm := div_le_div_of_nonneg_right
          (functionMass_complement_mono φ (smallPrior d N r σ) (hsub N hCN)) hp.le
        exact hm.trans hh.le
      obtain ⟨σ₀,hσ₀,hs⟩ := mem_nhdsGT_iff_exists_Ioo_subset.mp he
      exact ⟨σ₀,hσ₀,fun _ σ hσ hσlt=>hs ⟨hσ,hσlt⟩⟩
    · exact ⟨1,by norm_num,fun h=>False.elim (hCN h)⟩
  choose σ₀ hσ₀ hsmall using hth
  refine ⟨σ₀,hσ₀,?_⟩
  intro D δ hδ n hn
  let T := {p:ℕ×ℝ // C≤p.1 ∧0<p.2 ∧p.2<σ₀ p.1}
  let width:T→ℕ := fun i=>i.val.1
  let μ:∀i:T,Measure (Weights d (width i) r) := fun i=>smallPrior d i.val.1 r i.val.2
  have hp:∀i:T,0<functionMass φ (1/2) (μ i) f := by
    intro i
    exact (hsmall i.val.1 i.property.1 i.val.2 i.property.2.1 i.property.2.2).1
  have ht:∀i:T,(∑g∈Finset.univ\F,functionMass φ (1/2) (μ i) g)/
      functionMass φ (1/2) (μ i) f≤ε/2 := by
    intro i
    exact (hsmall i.val.1 i.property.1 i.val.2 i.property.2.1 i.property.2.2).2
  obtain ⟨hden,hlearn⟩ := uniform_prior_family_learning width φ μ D f F hε hε1 hδ hcount hp ht n hn
  constructor
  · intro N hCN σ hσ hσlt s
    exact hden ⟨(N,σ),hCN,hσ,hσlt⟩ s
  · apply hlearn.trans (sampleProbability_mono D n _ _ ?_)
    intro s hs N hCN σ hσ hσlt
    exact hs ⟨(N,σ),hCN,hσ,hσlt⟩

end NeuralGeneralization.BatchTwoActivation
