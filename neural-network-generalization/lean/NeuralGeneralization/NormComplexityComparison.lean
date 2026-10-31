import NeuralGeneralization.LowEnergyCapacity
import NeuralGeneralization.BatchTwoOnlineSharpTeacher

/-! The two directions of polynomial equivalence between the infimal
weighted squared norm and bounded-weight implementation complexity.
`networkEnergy` is half the paper's κ. Empty margin classes are explicitly
excluded, and no attainment of the strict-margin infimum is assumed.
The counting bound uses the existing (looser) quantization polynomial;
it is not the manuscript's sharper Euclidean packing constant. -/
noncomputable section
namespace NeuralGeneralization
open ConcreteModel CompressionSampling

theorem compressionWidth_polynomialGrowth (r : ℕ) :
    PolynomialGrowth2 (fun d K=>compressionWidth d r K) := by
  have hQ : PolynomialGrowth2 (fun _ K=>compressionQ r K) := by
    unfold compressionQ
    exact ((PolynomialGrowth2.const (24*(r+1))).mul
      (((PolynomialGrowth2.const 4).mul PolynomialGrowth2.right).pow (r+1)))
  unfold compressionWidth
  exact (((PolynomialGrowth2.const (65536*(r+1))).mul
    (PolynomialGrowth2.left.add (PolynomialGrowth2.const 1))).mul (hQ.pow 8)).add
      ((PolynomialGrowth2.const 9).mul PolynomialGrowth2.right)

/-- Inverse direction, uniformly in the width of the source network. -/
theorem realizesAtComplexity_of_energy_bound {d N r K : ℕ}
    (hd : 1≤d) (hN : 0<N) (φ : ℝ→ℝ) (hφ : admissibleActivation φ)
    (f : BooleanFunction d) (hne : (marginEvent (N:=N) (r:=r) φ (1/2) f).Nonempty)
    (henergy : 2*networkEnergy (N:=N) (r:=r) φ (1/2) f≤(K:ℝ)) :
    realizesAtComplexity (r:=r) φ f (compressionWidth d r (K+1)) := by
  obtain ⟨w,hw,hcost⟩ := exists_nearoptimal_margin_network φ (1/2) f hne 1 zero_lt_one
  have hbudget : weightedSquaredNorm w≤((K+1:ℕ):ℝ) := by push_cast; linarith
  obtain ⟨v,hv,hvb,_⟩ := norm_compression hd hN (by omega : 1≤K+1) φ hφ f w hbudget hw
  exact ⟨compressionWidth_pos d r (K+1) (by omega),v,hv,hvb⟩

/-- The same conclusion stated for the actual minimum implementation size. -/
theorem complexity_le_of_energy_bound {d C N r K : ℕ}
    (hd : 1≤d) (hN : 0<N) (φ : ℝ→ℝ) (hφ : admissibleActivation φ)
    (f : BooleanFunction d) (hC : isComplexity (r:=r) φ f C)
    (hne : (marginEvent (N:=N) (r:=r) φ (1/2) f).Nonempty)
    (henergy : 2*networkEnergy (N:=N) (r:=r) φ (1/2) f≤(K:ℝ)) :
    C≤compressionWidth d r (K+1) :=
  hC.2 _ (realizesAtComplexity_of_energy_bound hd hN φ hφ f hne henergy)

/-- Forward direction, with the exact teacher energy B_L of the paper. -/
theorem energy_le_of_complexity {d C N r : ℕ} (φ : ℝ→ℝ)
    (f : BooleanFunction d) (hC : isComplexity (r:=r) φ f C) (hCN : C≤N) :
    2*networkEnergy (N:=N) (r:=r) φ (1/2) f≤
      (d:ℝ)*(d+1)*C^2+((r:ℝ)+2)*C^4 := by
  have hh := BatchTwoOnlineSharp.realizesAtComplexity_paper_energy φ f hC.1 hCN
  unfold BatchTwoOnlineSharp.teacherBudget at hh
  linarith

def normSublevelFunctions (d N r K : ℕ) (φ : ℝ→ℝ) : Finset (BooleanFunction d) := by
  classical
  exact Finset.univ.filter (fun f=>
    (marginEvent (N:=N) (r:=r) φ (1/2) f).Nonempty ∧
      2*networkEnergy (N:=N) (r:=r) φ (1/2) f≤(K:ℝ))

theorem normSublevelFunctions_card_le {d N r K : ℕ}
    (hd : 1≤d) (hN : 0<N) (φ : ℝ→ℝ) (hφ : admissibleActivation φ) :
    ((normSublevelFunctions d N r K φ).card:ℝ)≤Real.exp
      (parameterCapacityExponent d (compressionWidth d r (K+1)) r
        (compressionWidth d r (K+1)):ℝ) := by
  classical
  apply representedClass_card_le_exp _ _ r _ φ hφ
  intro f hf
  have hm := (Finset.mem_filter.mp hf).2
  exact (realizesAtComplexity_of_energy_bound hd hN φ hφ f hm.1 hm.2).2

end NeuralGeneralization
