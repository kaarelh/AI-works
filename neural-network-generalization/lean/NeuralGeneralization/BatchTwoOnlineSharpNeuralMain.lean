import NeuralGeneralization.BatchTwoOnlineSharpTargetMass
import NeuralGeneralization.BatchTwoOnlineMeanFieldExactBridge

/-! All three boxed online neural corollaries with the literal manuscript
F_L,A_L,T_L,G_L constants, for actual Gaussian priors and both protocols. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators ENNReal
namespace NeuralGeneralization.BatchTwoOnlineSharp
open ConcreteModel BatchTwoOnline MeasureTheory

/-- Above mean field, large-width branch: K,T,h are exactly the appendix
quantities, with A supplied by the actual target-cylinder theorem. -/
theorem aboveMeanField_large_online_paper {d C N r : ℕ} {γ : ℝ}
    (hd : 1≤d) (hγ : 1<γ) (φ : ℝ→ℝ) (hφ : admissibleActivation φ)
    (f : BooleanFunction d) (hf : realizesAtComplexity (r:=r) φ f C) (hCN : C≤N)
    (hTN : powerWidthThreshold d C r (onlineEnergy d r (targetCost d C r)) γ≤N) :
    NetworkOnlineBounds φ (1/2) (powerPrior d N r γ) f
      (normCapacity d r (((r:ℝ)+5)*onlineEnergy d r (targetCost d C r))) := by
  exact aboveMeanField_large_online_of_mass hd
    (lt_of_lt_of_le (Nat.succ_le_iff.mp hf.1) hCN) (targetCost_ge_one _ _ _) hγ φ hφ f hTN
    (powerPrior_target_mass_sharp (by omega) φ hφ f hf hCN hγ.le)

/-- The small-width branch has the exact direct cost J=A T^gamma/2,
pathwise for every infinite query stream. -/
theorem aboveMeanField_small_total_paper {d C N r : ℕ} {γ : ℝ}
    (hd : 1≤d) (hγ : 1<γ) (φ : ℝ→ℝ) (hφ : admissibleActivation φ)
    (f : BooleanFunction d) (hf : realizesAtComplexity (r:=r) φ f C) (hCN : C≤N)
    (hNT : N≤powerWidthThreshold d C r (onlineEnergy d r (targetCost d C r)) γ)
    (query : ℕ→Cube d) :
    totalError (functionMass φ (1/2) (powerPrior d N r γ)) (fun g x=>g x=f x) query≤
      ENNReal.ofReal (targetCost d C r*
        (powerWidthThreshold d C r (onlineEnergy d r (targetCost d C r)) γ:ℝ)^γ/2) := by
  exact aboveMeanField_small_total_of_mass
    (lt_of_lt_of_le (Nat.succ_le_iff.mp hf.1) hCN) (targetCost_ge_one _ _ _) hγ φ hφ f hNT
    (powerPrior_target_mass_sharp (by omega) φ hφ f hf hCN hγ.le) query

theorem aboveMeanField_small_online_paper {d C N r : ℕ} {γ : ℝ}
    (hd : 1≤d) (hγ : 1<γ) (φ : ℝ→ℝ) (hφ : admissibleActivation φ)
    (f : BooleanFunction d) (hf : realizesAtComplexity (r:=r) φ f C) (hCN : C≤N)
    (hNT : N≤powerWidthThreshold d C r (onlineEnergy d r (targetCost d C r)) γ) :
    NetworkOnlineBounds φ (1/2) (powerPrior d N r γ) f
      (targetCost d C r*(powerWidthThreshold d C r (onlineEnergy d r (targetCost d C r)) γ:ℝ)^γ/2) := by
  have hA:=targetCost_ge_one d C r
  have hN:0<N:=lt_of_lt_of_le (Nat.succ_le_iff.mp hf.1) hCN
  have hmass:=powerPrior_target_mass_sharp (by omega : 0<d) φ hφ f hf hCN hγ.le
  have hcost:=aboveMeanField_small_prior_cost hN hA hγ φ f hNT hmass
  let J:=targetCost d C r*(powerWidthThreshold d C r (onlineEnergy d r (targetCost d C r)) γ:ℝ)^γ/2
  have hJ:0≤J:=by dsimp [J];positivity
  have hpos:0<functionMass φ (1/2) (powerPrior d N r γ) f:=(Real.exp_pos _).trans_le hmass
  have hm:Real.exp (-J)≤functionMass φ (1/2) (powerPrior d N r γ) f:=by
    rw [←Real.exp_log hpos]
    apply Real.exp_le_exp.mpr
    change -Real.log (functionMass φ (1/2) (powerPrior d N r γ) f)≤J at hcost
    linarith
  exact network_online_of_randomOrder hd φ (1/2) _ f J hJ hpos
    (network_bounds_of_prior_mass hd (admissibleActivation_continuous hφ) _ f J hJ hm)

/-- Literal above-mean-field boxed corollary at every admissible width.
The two branch budgets are independent of the learner width. -/
theorem aboveMeanField_online_paper {d C N r : ℕ} {γ : ℝ}
    (hd : 1≤d) (hγ : 1<γ) (φ : ℝ→ℝ) (hφ : admissibleActivation φ)
    (f : BooleanFunction d) (hf : realizesAtComplexity (r:=r) φ f C) (hCN : C≤N) :
    let K:=onlineEnergy d r (targetCost d C r)
    let T:=powerWidthThreshold d C r K γ
    NetworkOnlineBounds φ (1/2) (powerPrior d N r γ) f
      (if T≤N then normCapacity d r (((r:ℝ)+5)*K) else targetCost d C r*(T:ℝ)^γ/2) := by
  dsimp only
  split_ifs with hTN
  · exact aboveMeanField_large_online_paper hd hγ φ hφ f hf hCN hTN
  · exact aboveMeanField_small_online_paper hd hγ φ hφ f hf hCN (le_of_not_ge hTN)

/-- Mean-field large-width branch with the exact G_L and T_L budgets. -/
theorem meanField_large_online_paper {d C N r : ℕ}
    (hd : 1≤d) (f : BooleanFunction d) (hf : realizesAtComplexity (r:=r) Real.tanh f C)
    (hCN : C≤N)
    (hTN : BatchTwoOnlineMeanFieldExact.learnerThreshold d r (onlineEnergy d r (targetCost d C r))≤N) :
    NetworkOnlineBounds Real.tanh (1/2) (powerPrior d N r 1) f
      (BatchTwoOnlineMeanFieldExact.capacity d r (onlineEnergy d r (targetCost d C r))) := by
  apply BatchTwoOnlineMeanFieldExact.meanField_large_online_of_mass hd (targetCost_ge_one _ _ _) f hTN
  simpa only [Real.rpow_one] using
    powerPrior_target_mass_sharp (by omega : 0<d) Real.tanh tanh_admissible f hf hCN (γ:=1) le_rfl

/-- Mean-field small-width branch, with the exact direct cost J=A T_L/2. -/
theorem meanField_small_total_paper {d C N r : ℕ}
    (hd : 1≤d) (f : BooleanFunction d) (hf : realizesAtComplexity (r:=r) Real.tanh f C)
    (hCN : C≤N)
    (hNT : N≤BatchTwoOnlineMeanFieldExact.learnerThreshold d r (onlineEnergy d r (targetCost d C r)))
    (query : ℕ→Cube d) :
    totalError (functionMass Real.tanh (1/2) (powerPrior d N r 1)) (fun g x=>g x=f x) query≤
      ENNReal.ofReal (targetCost d C r*
        (BatchTwoOnlineMeanFieldExact.learnerThreshold d r (onlineEnergy d r (targetCost d C r)):ℝ)/2) := by
  apply BatchTwoOnlineMeanFieldExact.meanField_small_total_of_mass (targetCost_ge_one _ _ _) f hNT _ query
  simpa only [Real.rpow_one] using
    powerPrior_target_mass_sharp (by omega : 0<d) Real.tanh tanh_admissible f hf hCN (γ:=1) le_rfl

/-- Literal boxed mean-field corollary, at every width above complexity and
positive prior scale, including both entire input protocols and actual draws. -/
theorem meanField_online_paper {d C N r : ℕ}
    (hd : 1≤d) (f : BooleanFunction d) (hf : realizesAtComplexity (r:=r) Real.tanh f C)
    (hCN : C≤N) :
    let K:=onlineEnergy d r (targetCost d C r)
    let T:=BatchTwoOnlineMeanFieldExact.learnerThreshold d r K
    NetworkOnlineBounds Real.tanh (1/2) (powerPrior d N r 1) f
      (if T≤N then BatchTwoOnlineMeanFieldExact.capacity d r K else targetCost d C r*(T:ℝ)/2) := by
  dsimp only
  split_ifs with hTN
  · exact meanField_large_online_paper hd f hf hCN hTN
  · apply BatchTwoOnlineMeanFieldExact.meanField_small_online_of_mass hd (targetCost_ge_one _ _ _)
      f (le_of_not_ge hTN)
    simpa only [Real.rpow_one] using
      powerPrior_target_mass_sharp (by omega : 0<d) Real.tanh tanh_admissible f hf hCN (γ:=1) le_rfl

end NeuralGeneralization.BatchTwoOnlineSharp
