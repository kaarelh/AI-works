import NeuralGeneralization.BatchTwoOnlineReluPolynomialBudget

/-! Fixed-depth polynomial cumulative learning for bounded ReLU teachers. -/
noncomputable section
set_option autoImplicit false
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineReluFinite
open ConcreteModel BatchTwoActivation BatchTwoOnline
set_option maxHeartbeats 1600000
set_option backward.isDefEq.respectTransparency false

theorem reluNatMass_growth (r : ℕ) : PolynomialGrowth2 (fun d k=>reluNatMass d r k) := by
  open PolynomialGrowth2 in
  exact ((right.add (const 2)).pow 2).add
    (((((left.add (const r)).add (const 2)).mul (const 3)).mul
      ((left.add (const r)).add (const 3))).mul
        ((const (8*(r+2))).mul ((right.add (const 2)).pow (r+1))))

theorem reluNatThreshold_growth (r : ℕ) : PolynomialGrowth2 (fun d k=>reluNatThreshold d r k) := by
  open PolynomialGrowth2 in
  exact (const 4).mul (((reluNatMass_growth r).add ((left.add (const r)).add (const 2))).add left)

theorem reluNatLogCount_growth (r : ℕ) : PolynomialGrowth2 (fun d k=>reluNatLogCount d r k) := by
  open PolynomialGrowth2 in
  exact (((((const 4).mul (left.add (const 1))).mul ((reluNatThreshold_growth r).pow (r+2))).mul
    (const ((2*r+3)^2))).mul (left.add (const 1)))

theorem reluNatTeacherEnergy_growth (r : ℕ) : PolynomialGrowth2 (fun d C=>reluNatTeacherEnergy d C r) := by
  open PolynomialGrowth2 in
  exact (const (r+2)).mul ((const 1).add (((const 4).mul left).mul
    ((left.add (const 1)).mul (right.pow (4*(r+2)-2)))))

theorem reluNatTeacherLogCount_growth (r : ℕ) : PolynomialGrowth2 (reluNatTeacherLogCount r) :=
  (reluNatLogCount_growth r).compositionRight (reluNatTeacherEnergy_growth r)

/-- Actual online bounds, with a natural polynomial capacity replacing the
literal smaller capacity. This includes the entire infinite IID stream. -/
theorem relu_bounded_finite_scale_online {d C N r : ℕ} (hd : 0<d) (hC : 0<C)
    (hCN : C≤N) (w : Weights d C r) (f : BooleanFunction d)
    (hbounded : boundedWeights C w) (hw : w∈marginEvent relu (1/2) f)
    {σ : ℝ} (hσ : 0<σ) (hσone : σ^2≤1)
    (hdim : (Fintype.card (WeightIndex d N r):ℝ)*σ^2≤(d:ℝ)+(r+2:ℝ)) :
    NetworkOnlineBounds relu (1/2) (smallPrior d N r σ) f (reluNatTeacherLogCount r d C) := by
  have hmass := relu_finite_variance_target_mass hd hC hCN w f hw hσ hdim
  have hpos := (Real.exp_pos _).trans_le hmass
  apply network_online_of_randomOrder hd relu (1/2) _ f _ (Nat.cast_nonneg _) hpos
  apply bounds_of_relevant_class Fintype.card_pos _ (functionMass_nonneg relu (1/2) _) _ f
    (fun _=>rfl) hpos
    (energyFunctions d r relu (reluTeacherThreshold d r (physicalProduct hC relu_zeroLipschitz w))) _ _
    (Nat.cast_nonneg _) (by positivity)
  · exact (relu_energyFunctions_card_le_exp hd (reluTeacherThreshold_pos _ _ _)).trans
      (Real.exp_le_exp.mpr (relu_bounded_teacher_logCount hd hC w hbounded))
  · exact relu_finite_variance_function_tail hd hC hCN w f hw hσ hσone hdim

/-- A single fixed-depth polynomial works for all widths and every gamma in
the claimed range, including gamma=1 for one hidden layer. -/
theorem relu_finite_variance_polynomial (r : ℕ) :
    ∃Q : ℕ→ℕ→ℕ,PolynomialGrowth2 Q ∧
      ∀d C N : ℕ,0<d→0<C→C≤N→∀w : Weights d C r,∀f : BooleanFunction d,
      boundedWeights C w→w∈marginEvent relu (1/2) f→∀γ : ℝ,
      (2≤γ ∨ r=0 ∧ 1≤γ)→NetworkOnlineBounds relu (1/2) (powerPrior d N r γ) f (Q d C) := by
  refine ⟨reluNatTeacherLogCount r,reluNatTeacherLogCount_growth r,?_⟩
  intro d C N hd hC hCN w f hb hw γ hγ
  have hN : 0<N := hC.trans_le hCN
  have hγ0 : 0≤γ := by rcases hγ with h | ⟨_,h⟩ <;> linarith
  have hv := relu_variance_budget hN hγ0
  rw [powerPrior_eq_smallPrior hN γ]
  apply relu_bounded_finite_scale_online hd hC hCN w f hb hw (Real.sqrt_pos.mpr hv.1)
  · simpa only [Real.sq_sqrt hv.1.le] using hv.2
  · rw [Real.sq_sqrt hv.1.le]
    rcases hγ with h | ⟨hr,h⟩
    · exact relu_dimension_variance_budget hN h
    · subst r
      simpa only [Nat.cast_zero,zero_add] using relu_shallow_dimension_variance_budget hN h

/-- The expectation and logarithmic-confidence thresholds are bounded by
one polynomial in d,C,log(1/delta), with constants chosen before those inputs. -/
theorem relu_finite_variance_budget_polynomial (r : ℕ) :
    ∃A : ℝ,0<A ∧ ∃k : ℕ,∀d C : ℕ,1≤d→∀δ : ℝ,0<δ→δ<1→
      expectationBudget (Fintype.card (Cube d)) (reluNatTeacherLogCount r d C) (1/Fintype.card (Cube d))≤
        A*(1+(d:ℝ)+C+Real.log (1/δ))^k ∧
      highProbabilityBudget (Fintype.card (Cube d)) (reluNatTeacherLogCount r d C) (1/Fintype.card (Cube d)) δ≤
        A*(1+(d:ℝ)+C+Real.log (1/δ))^k :=
  online_budget_polynomial_majorant (reluNatTeacherLogCount r) (reluNatTeacherLogCount_growth r)

#print axioms relu_finite_variance_polynomial
#print axioms relu_finite_variance_budget_polynomial
end NeuralGeneralization.BatchTwoOnlineReluFinite
