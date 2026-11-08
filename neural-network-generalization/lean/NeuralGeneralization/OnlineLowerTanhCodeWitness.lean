import NeuralGeneralization.OnlineLowerTanhSynthesis
import NeuralGeneralization.OnlineLowerReluCodeWitness
import NeuralGeneralization.OnlineLowerTanhGeometryTarget

/-! # Actual finite-width tanh witnesses for the rectangle scores

Integer neuron allocation preserves the entire score exactly. Its energy
converges to the certified Fourier cost, so every sufficiently large fixed
width has the strict globally margined witness needed by the posterior.
-/
noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLower
open ConcreteModel OnlineLowerTanh OnlineLowerGeometry

lemma tanh_code_fourier_weighted_cost {d m:ℕ} (C:WalshCodeMap d m)
    (weight:Finset (Fin m)→ℝ) (r:Finset (Fin m)→ℕ)
    (hweight:∀s,weight s=balancedCost (r s)) (g:ClippingCube m→ℝ) :
    (∑s,|walshCoefficients g s| *balancedCost (r s))=weightedWalshCost weight g := by
  unfold weightedWalshCost weightedL1
  apply Finset.sum_congr rfl
  intro s hs
  rw [hweight]
  ring

theorem tanh_code_score_strict_witness_all_large {d m:ℕ} (hd:144<d)
    (C:WalshCodeMap d m) (weight:Finset (Fin m)→ℝ) (r:Finset (Fin m)→ℕ)
    (hcard:∀s,(C.support s).card=2*r s+1) (hweight:∀s,weight s=balancedCost (r s))
    (g:ClippingCube m→ℝ) (hL1:walshAlgebraNorm g≤(3:ℝ)/2)
    (f:BooleanFunction d)
    (hmargin:∀x,(1/2:ℝ)≤labelReal (f x)*(C.base x*g (C.syndrome x)))
    (B:ℝ) (hbudget:2*Real.sqrt (d:ℝ)*weightedWalshCost weight g<B) :
    ∃N₀:ℕ,0<N₀ ∧ ∀N:ℕ,N₀≤N→∃net:Weights d N 0,
      net∈marginEvent Real.tanh (1/2) f ∧ weightedSquaredNorm net<B := by
  apply odd_parity_expansion_strict_witness hd C.support r hcard (walshCoefficients g) hL1 f
  · intro x
    rw [code_fourier_lift]
    exact hmargin x
  · rw [tanh_code_fourier_weighted_cost C weight r hweight g]
    exact hbudget

/-- The strict witness and a width-uniform closed correct-score barrier
produce actual Gaussian energy gaps at every sufficiently large width. -/
theorem tanh_code_stage_gaps_all_large {d m:ℕ} (hd:144<d)
    (C:WalshCodeMap d m) (weight:Finset (Fin m)→ℝ) (r:Finset (Fin m)→ℕ)
    (hcard:∀s,(C.support s).card=2*r s+1) (hweight:∀s,weight s=balancedCost (r s))
    (g:ClippingCube m→ℝ) (hL1:walshAlgebraNorm g≤(3:ℝ)/2)
    (f:BooleanFunction d) (π:InputOrder d) (j:Fin (Fintype.card (Cube d)))
    (g₀:BooleanFunction d) (hkeep:consistent f (observedPrefix π j) g₀)
    (hmargin:∀x,(1/2:ℝ)≤labelReal (g₀ x)*(C.base x*g (C.syndrome x)))
    (δ:ℝ) (hδ:0<δ)
    (hbarrier:∀N:ℕ,0<N→∀net:Weights d N 0,
      ClosedOnlineFeasible Real.tanh f (observedPrefix π j) net→
      (1/2:ℝ)≤labelReal (f (π j))*networkOutput Real.tanh net (π j)→
      2*Real.sqrt (d:ℝ)*weightedWalshCost weight g+δ≤weightedSquaredNorm net) :
    ∃N₀:ℕ,0<N₀ ∧ ∀N:ℕ,N₀≤N→HasStageEnergyGap Real.tanh f π N j := by
  let B:ℝ:=2*Real.sqrt (d:ℝ)*weightedWalshCost weight g+δ
  obtain ⟨N₀,hN₀,hnet⟩:=tanh_code_score_strict_witness_all_large hd C weight r hcard hweight
    g hL1 g₀ hmargin B (by dsimp [B]; linarith)
  refine ⟨N₀,hN₀,?_⟩
  intro N hN
  obtain ⟨net,hmargin0,hcost⟩:=hnet N hN
  refine ⟨g₀,hkeep,⟨net,hmargin0⟩,?_⟩
  intro g₁ hgkeep hgcorrect hgne
  apply networkEnergy_gap_of_cost_barrier Real.tanh g₀ g₁ net hmargin0 B hcost hgne
  intro w hw
  apply hbarrier N (hN₀.trans_le hN) w
    (closedOnlineFeasible_of_consistent_margin Real.tanh f g₁ (observedPrefix π j) hgkeep w hw)
  simpa only [hgcorrect] using (hw (π j)).le

end NeuralGeneralization.OnlineLower
