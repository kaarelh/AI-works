import NeuralGeneralization.OnlineLowerTanhConditioningMixture

/-! # Literal pair erasure and averaging at arbitrary varying dimensions -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel

def erasedPairSet {N : ℕ} (i j : Fin N) : Finset (Fin N) :=
  (Finset.univ.erase i).erase j

lemma mem_erasedPairSet {N : ℕ} (i j k : Fin N) :
    k ∈ erasedPairSet i j ↔ k ≠ i ∧ k ≠ j := by
  simp only [erasedPairSet,Finset.mem_erase,Finset.mem_univ,and_true]
  tauto

lemma erasedPairSet_card {N : ℕ} (i j : Fin N) (hij : i ≠ j) :
    (erasedPairSet i j).card=N-2 := by
  unfold erasedPairSet
  rw [Finset.card_erase_of_mem (by simp [Ne.symm hij]),
    Finset.card_erase_of_mem (Finset.mem_univ i),Finset.card_univ,Fintype.card_fin]
  omega

lemma erasedPairSet_odd {N : ℕ} (hN : Odd N) (i j : Fin N) (hij : i ≠ j) :
    Odd (erasedPairSet i j).card := by
  have htwo : 2 ≤ N := by
    have hi := i.isLt
    have hj := j.isLt
    have hne : i.val ≠ j.val := fun h => hij (Fin.ext h)
    omega
  rw [erasedPairSet_card i j hij,Nat.odd_sub htwo]
  simp only [even_two,iff_true]
  exact hN

/-- The exact pair-difference identity in the actual physical dimension,
without casting a varying dimension into the form `n+2`. -/
theorem parityCorrelation_erasedPair {N : ℕ} (hN : Odd N) (hlarge : 3 ≤ N)
    (u : Fin N → ℝ) (i j : Fin N) (hij : i ≠ j) :
    parityCorrelation u 0=
      (parityCorrelation (subsetWeights (erasedPairSet i j) u) (u i+u j)-
       parityCorrelation (subsetWeights (erasedPairSet i j) u) (u i-u j))/2 := by
  obtain ⟨n,rfl⟩ : ∃ n,N=n+2 := ⟨N-2,by omega⟩
  have hn : Odd n := by
    simpa only [Nat.odd_add,even_two,iff_true] using hN
  rw [← parityCorrelation_equiv (pairCoordinateEquiv i j) u,
    reindexed_pairIncoming u i j hij,parityCorrelation_pair hn]
  simp only [parityCorrelation_pairRest u i j hij,pairMean,pairImbalance,
    show (2:ℝ)*((u i+u j)/2)=u i+u j by ring,
    show (2:ℝ)*((u i-u j)/2)=u i-u j by ring]
  rfl

/-- Actual curvature of the canonical erased pair gives a strictly better
physical incoming vector, in any odd ambient dimension at least three. -/
theorem generic_pair_balance_of_curvature {N : ℕ} (hN : Odd N) (hlarge : 3 ≤ N)
    (u : Fin N → ℝ) (i j : Fin N) (hij : i ≠ j) (δ s : ℝ) (hs : |s|=1)
    (hcurv : ∀ b : ℝ, |b| ≤ δ →
      -s*parityBiasSecond (subsetWeights (erasedPairSet i j) u) b < 0)
    (hwindow : |u i-u j| ≤ δ) (hne : u i ≠ u j)
    (hi : 0 < u i) (hj : 0 < u j) (hscore : 0 < s*parityCorrelation u 0) :
    |parityCorrelation u 0|/Real.sqrt (incomingEnergy u) <
      |parityCorrelation (averageIncomingPair u i j) 0|/Real.sqrt (incomingEnergy (averageIncomingPair u i j)) := by
  obtain ⟨n,rfl⟩ : ∃ n,N=n+2 := ⟨N-2,by omega⟩
  have hn : Odd n := by
    simpa only [Nat.odd_add,even_two,iff_true] using hN
  exact arbitrary_pair_balance_of_curvature hn u i j hij δ s hs hcurv hwindow hne hi hj hscore

lemma generic_incomingEnergy_averageIncomingPair {N : ℕ}
    (u : Fin N → ℝ) (i j : Fin N) (hij : i ≠ j) :
    incomingEnergy (averageIncomingPair u i j)+2*(pairImbalance u i j)^2=incomingEnergy u := by
  have htwo : 2 ≤ N := by
    have hi := i.isLt
    have hj := j.isLt
    have hne : i.val ≠ j.val := fun h => hij (Fin.ext h)
    omega
  obtain ⟨n,rfl⟩ : ∃ n,N=n+2 := ⟨N-2,by omega⟩
  exact incomingEnergy_averageIncomingPair u i j hij

end NeuralGeneralization.OnlineLowerTanh
