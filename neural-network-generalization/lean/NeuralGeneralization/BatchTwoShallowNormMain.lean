import NeuralGeneralization.BatchTwoShallowSharpMain
import NeuralGeneralization.BatchTwoShallowWidthPolynomials

/-! Explicit resource-only versions of the dimension-sharpened theorem.
The norm bound eliminates the readout L1 norm from the target radius;
the width bound also applies to the sharper budget, not just the finite-cube
budget. No learner-width or prior-scale dependence enters these budgets. -/
noncomputable section
open scoped BigOperators
open MeasureTheory ProbabilityTheory Set
namespace NeuralGeneralization.BatchTwoShallow
open ConcreteModel CompressionSampling

theorem readoutL1_le_sqrt_energy {d C : ℕ} (w : Weights d C 0) :
    readoutL1 w≤Real.sqrt (weightedSquaredNorm w) := by
  have hc := Finset.sum_mul_sq_le_sq_mul_sq (Finset.univ : Finset (Fin C))
    (fun _=>(1:ℝ)) (fun i=>|w (Sum.inr (Sum.inr i))|)
  simp only [one_mul,one_pow,Finset.sum_const,Finset.card_univ,Fintype.card_fin,
    nsmul_eq_mul,mul_one,sq_abs] at hc
  have he : (C:ℝ)*readoutEnergySum w≤weightedSquaredNorm w := by
    unfold weightedSquaredNorm readoutEnergySum
    simp only [Finset.univ_eq_empty,Finset.sum_empty,add_zero]
    exact le_add_of_nonneg_left (by positivity)
  apply (Real.le_sqrt (Finset.sum_nonneg (fun _ _=>abs_nonneg _))
    (weightedSquaredNorm_nonneg w)).mpr
  exact hc.trans he

def normTargetCost (d : ℕ) (s κ : ℝ) : ℝ :=
  2*s^2*κ+((d:ℝ)+2)*Real.log
    (2*Real.exp 1*Real.sqrt (2*Real.pi)*(1+s*Real.sqrt κ*(d+1)/Real.sqrt d))

theorem targetCost_le_normTargetCost {d C : ℕ} {s : ℝ} (hs : 1≤s)
    (w : Weights d C 0) : targetCost s w≤normTargetCost d s (weightedSquaredNorm w) := by
  have hs0 : 0≤s := by linarith
  have hL0 : 0≤readoutL1 w := Finset.sum_nonneg (fun _ _=>abs_nonneg _)
  have hL := readoutL1_le_sqrt_energy w
  have he : Real.exp 1*Real.sqrt (2*Real.pi)/(2*targetRadius s w)=
      2*Real.exp 1*Real.sqrt (2*Real.pi)*(1+s*readoutL1 w*(d+1)/Real.sqrt d) := by
    unfold targetRadius
    field_simp
    <;> ring
  apply (targetCost_le_energy hs w).trans
  rw [he]
  unfold normTargetCost
  gcongr

def resourceVoteCount (D ε : ℝ) : ℕ :=
  ⌈4096*(D+Real.log (4/ε))*Real.log (24/ε)⌉₊

theorem voteCount_le_resource {d C : ℕ} {s ε D : ℝ}
    (hs : 0≤s) (hε : 0<ε) (hε1 : ε<1) (w : Weights d C 0)
    (hcost : targetCost s w≤D) : voteCount s ε w≤resourceVoteCount D ε := by
  unfold voteCount resourceVoteCount
  apply Nat.ceil_mono
  rw [readoutBound_sq hs hε hε1,readoutBoundSq]
  have hl : 0≤Real.log (24/ε) := Real.log_nonneg ((one_le_div hε).mpr (by linarith))
  nlinarith [mul_le_mul_of_nonneg_right hcost hl]

theorem sharpExplicitBudget_mono {d m k : ℕ} (hm : 0<m) (hmk : m≤k)
    {ε δ : ℝ} (hε : 0<ε) (hε1 : ε<1) (hδ : 0<δ) (hδ1 : δ<1) :
    sharpExplicitBudget d m ε δ≤sharpExplicitBudget d k ε δ := by
  have hT : sharpBudgetParameter d m ε δ≤sharpBudgetParameter d k ε δ := by
    unfold sharpBudgetParameter
    gcongr
  have hT0 : 0<sharpBudgetParameter d m ε δ := by
    unfold sharpBudgetParameter
    have hh := sharp_log_pos m hδ hδ1
    positivity
  have hT1 : 1≤8*Real.exp 1*sharpBudgetParameter d m ε δ := by
    have hmR : (1:ℝ)≤m := by exact_mod_cast hm
    have hdR : (0:ℝ)≤d := Nat.cast_nonneg d
    have h64 : (64:ℝ)≤64/ε := (le_div_iff₀ hε).mpr (by linarith)
    have hl := sharp_log_pos m hδ hδ1
    have hfactor : 1≤(m:ℝ)*(d+1)+Real.log (4*((m:ℝ)+2)/δ) := by nlinarith
    have hlarge : 64≤sharpBudgetParameter d m ε δ := by
      unfold sharpBudgetParameter
      nlinarith
    have he := Real.add_one_le_exp (1:ℝ)
    nlinarith
  unfold sharpExplicitBudget
  apply Nat.ceil_mono
  have hTk : 0<sharpBudgetParameter d k ε δ := hT0.trans_le hT
  exact mul_le_mul (by linarith) (Real.log_le_log (by positivity) (by gcongr))
    (Real.log_nonneg hT1) (by positivity)

/-- A cost majorant can replace the detailed teacher resources in the exact
dimension-sharpened sample budget. -/
theorem sharpBudget_le_resource {d C : ℕ} {s ε δ D : ℝ}
    (hs : 0≤s) (hε : 0<ε) (hε1 : ε<1) (hδ : 0<δ) (hδ1 : δ<1)
    (w : Weights d C 0) (hcost : targetCost s w≤D) :
    sharpExplicitBudget d (voteCount s ε w) ε δ≤
      sharpExplicitBudget d (resourceVoteCount D ε) ε δ :=
  sharpExplicitBudget_mono (voteCount_pos hs hε hε1 w)
    (voteCount_le_resource hs hε hε1 w hcost) hε hε1 hδ hδ1

theorem sharp_norm_sample_bound {d C : ℕ} {s ε δ : ℝ}
    (hs : 1≤s) (hε : 0<ε) (hε1 : ε<1) (hδ : 0<δ) (hδ1 : δ<1)
    (w : Weights d C 0) :
    sharpExplicitBudget d (voteCount s ε w) ε δ≤
      sharpExplicitBudget d
        (resourceVoteCount (normTargetCost d s (weightedSquaredNorm w)) ε) ε δ :=
  sharpBudget_le_resource (by linarith) hε hε1 hδ hδ1 w (targetCost_le_normTargetCost hs w)

/-- The sharp budget has a quadratic teacher-width resource inside its
logarithmic sample-size factor. The readout coefficient bound V is fixed
independently of C, as required in the manuscript. -/
theorem sharp_quadratic_width_sample_bound {d C : ℕ} (hC : 0<C)
    {s V ε δ : ℝ} (hs : 0≤s) (hV : 0≤V)
    (hε : 0<ε) (hε1 : ε<1) (hδ : 0<δ) (hδ1 : δ<1)
    (w : Weights d C 0) (hw : ∀i j,|w (Sum.inl (i,j))|≤(C:ℝ))
    (hv : ∀i,|w (Sum.inr (Sum.inr i))|≤V) :
    sharpExplicitBudget d (voteCount s ε w) ε δ≤
      sharpExplicitBudget d
        (resourceVoteCount (widthCostCoefficient d s V*(C:ℝ)^2) ε) ε δ :=
  sharpBudget_le_resource hs hε hε1 hδ hδ1 w (targetCost_quadratic hC hs hV w hw hv)

/-- The norm-only learning consequence for the actual posterior, all support
switches, all eligible widths, and all scales Nσ²≤1 on one sample event. -/
theorem shallow_norm_all_width_all_scale {d C n : ℕ} (hd : 0<d) (hC : 0<C)
    (w : Weights d C 0) (f : BooleanFunction d) (hw : w∈marginEvent Real.tanh (1/2) f)
    {c ε δ : ℝ} (hc : 0<c) (hε : 0<ε) (hε1 : ε<1) (hδ : 0<δ) (hδ1 : δ<1)
    (robust global : Bool) (D : Measure (Cube d)) [IsProbabilityMeasure D]
    (hn : sharpExplicitBudget d
      (resourceVoteCount (normTargetCost d (targetScale c robust) (weightedSquaredNorm w)) ε)
      ε δ≤n) :
    ∃A : Set (Fin n→Cube d),MeasurableSet A ∧ 1-δ≤(iidSamples D n).real A ∧
      ∀sample∈A,∀N : ℕ,C≤N→∀σ : ℝ,0<σ→(N:ℝ)*σ^2≤1→
        0<(smallPrior d N 0 σ).real (conditioningEvent c robust global f sample) ∧
        RobustConfidence.gibbsMarginRisk D (posterior (N:=N) σ c robust global f sample)
          (fun x=>labelReal (f x)) (networkOutput Real.tanh) (1/4)≤ε := by
  apply shallow_explicit_sharp_all_width_all_scale hd hC w f hw hc hε hε1 hδ hδ1 robust global D
  have hs : 1≤targetScale c robust := by
    unfold targetScale
    cases robust <;> simp <;> linarith
  exact (sharp_norm_sample_bound hs hε hε1 hδ hδ1 w).trans hn

end NeuralGeneralization.BatchTwoShallow
