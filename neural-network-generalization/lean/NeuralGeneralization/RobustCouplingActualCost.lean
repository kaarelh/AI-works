import NeuralGeneralization.RobustCouplingActualHistory

/-! # The live original-network cost under the actual history update -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ENNReal
namespace NeuralGeneralization.RobustCompressionInduction
open ConcreteModel RobustStatistics

/-- The true accumulated disturbance, charged only on a live canonical state. -/
def liveOriginalCost {d N m r s k : ℕ} (hs : s ≤ r) (φ : ℝ → ℝ) (x : Cube d)
    (z : OriginalHistory d N r s × (ActivePrefix d N m s × FutureWeights N k)) : ℝ≥0∞ :=
  if z.2.1.1=true then ENNReal.ofReal (originalPathCost hs φ z.1.1 x z.1.2) else 0

/-- One actual layer's disturbance against the retained original current
matrix, charged only when the new canonical state is live. -/
def liveLocalCost {d N m s k : ℕ} (σ : ℝ) (φ : ℝ → ℝ) (x : Cube d)
    (z : (ActivePrefix d N m s × FutureWeights N (k+1)) ×
      (ActivePrefix d N m (s+1) × FutureWeights N k)) : ℝ≥0∞ :=
  if z.2.1.1=true then ENNReal.ofReal (localPathCost φ
    (fun i j => σ*(splitFuture N k z.1.2).1 (i,j))
    (activeHidden φ z.1.1 x) (activeHidden φ z.2.1 x)) else 0

theorem measurable_liveOriginalCost {d N m r s k : ℕ} (hs : s ≤ r)
    {φ : ℝ → ℝ} (hφ : Continuous φ) (x : Cube d) :
    Measurable (liveOriginalCost (d:=d) (N:=N) (m:=m) (k:=k) hs φ x) :=
  (((measurable_originalPathCost hs hφ x).comp measurable_fst).ennreal_ofReal).ite
    (measurableSet_eq_fun (measurable_fst.comp (measurable_fst.comp measurable_snd))
      measurable_const) measurable_const

theorem measurable_liveLocalCost {d N m s k : ℕ} (σ : ℝ)
    {φ : ℝ → ℝ} (hφ : Continuous φ) (x : Cube d) :
    Measurable (liveLocalCost (N:=N) (m:=m) (s:=s) (k:=k) σ φ x) := by
  have hOld : Measurable (fun z : (ActivePrefix d N m s × FutureWeights N (k+1)) ×
      (ActivePrefix d N m (s+1) × FutureWeights N k) => activeHidden φ z.1.1 x) :=
    (measurable_activeHidden hφ x).comp (measurable_fst.comp measurable_fst)
  have hNew : Measurable (fun z : (ActivePrefix d N m s × FutureWeights N (k+1)) ×
      (ActivePrefix d N m (s+1) × FutureWeights N k) => activeHidden φ z.2.1 x) :=
    (measurable_activeHidden hφ x).comp (measurable_fst.comp measurable_snd)
  have hMatrix : Measurable (fun z : (ActivePrefix d N m s × FutureWeights N (k+1)) ×
      (ActivePrefix d N m (s+1) × FutureWeights N k) =>
        (splitFuture N k z.1.2).1) :=
    measurable_fst.comp ((splitFuture N k).measurable.comp (measurable_snd.comp measurable_fst))
  have hφm := hφ.measurable
  apply Measurable.ite (measurableSet_eq_fun
    (measurable_fst.comp (measurable_fst.comp measurable_snd)) measurable_const) _ measurable_const
  apply Measurable.ennreal_ofReal
  unfold localPathCost
  fun_prop

theorem liveOriginalCost_append_le {d N m r s k : ℕ} (h : s+(k+1) ≤ r)
    {σ : ℝ} (hσ : σ ≠ 0) (φ : ℝ → ℝ) (x : Cube d)
    (history : OriginalHistory d N r s)
    (old : ActivePrefix d N m s × FutureWeights N (k+1))
    (next : ActivePrefix d N m (s+1) × FutureWeights N k)
    (halign : HistoryAligned h σ φ x history old)
    (hlive : next.1.1=true → old.1.1=true) :
    liveOriginalCost (by omega : s+1 ≤ r) φ x (appendOriginalHistory φ x history old next,next) ≤
      liveOriginalCost (by omega : s ≤ r) φ x (history,old) + liveLocalCost σ φ x (old,next) := by
  unfold liveOriginalCost liveLocalCost
  by_cases hn : next.1.1=true
  · rw [if_pos hn, if_pos (hlive hn), if_pos hn, appendOriginalHistory_cost h hσ φ x history old next halign]
    exact ENNReal.ofReal_add_le
  · rw [if_neg hn, if_neg hn]
    exact zero_le

/-- Concrete success-weighted accumulated-cost induction. All original
matrices and virtual activations are those in the actual history, and only
almost-everywhere alignment and absorbing success are needed. -/
theorem advanceOriginalHistory_cost_le {d N m r s k : ℕ} (h : s+(k+1) ≤ r)
    {σ : ℝ} (hσ : σ ≠ 0) {φ : ℝ → ℝ} (hφ : Continuous φ) (x : Cube d)
    {Q : Measure (Weights d N r)}
    {Γ : Measure (ActivePrefix d N m s × FutureWeights N (k+1))}
    {Γ' : Measure (ActivePrefix d N m (s+1) × FutureWeights N k)}
    (P : CanonicalHistoryComparison Q Γ (Prod.fst : OriginalHistory d N r s → Weights d N r))
    (R : ProbabilityCoupling Γ Γ')
    (halign : ∀ᵐ z ∂P.joint, HistoryAligned h σ φ x z.1 z.2)
    (hlive : ∀ᵐ z ∂R.joint, z.2.1.1=true → z.1.1.1=true)
    {a b : ℝ≥0∞}
    (hOld : (∫⁻ z, liveOriginalCost (by omega : s ≤ r) φ x z ∂P.joint) ≤ a)
    (hLocal : (∫⁻ z, liveLocalCost σ φ x z ∂R.joint) ≤ b) :
    (∫⁻ z, liveOriginalCost (by omega : s+1 ≤ r) φ x z
      ∂(advanceHistory P R (appendOriginalHistory φ x) (measurable_appendOriginalHistory hφ x)
        measurable_fst measurable_fst (fun _ _ _ => rfl)).joint) ≤ a+b := by
  apply advanceHistory_cost_le_on_support P R (appendOriginalHistory φ x)
    (measurable_appendOriginalHistory hφ x) measurable_fst measurable_fst (fun _ _ _ => rfl)
    (liveOriginalCost (by omega : s ≤ r) φ x) (liveLocalCost σ φ x)
    (liveOriginalCost (by omega : s+1 ≤ r) φ x)
    (measurable_liveOriginalCost _ hφ x) (measurable_liveLocalCost σ hφ x)
    (measurable_liveOriginalCost _ hφ x)
    (fun z => HistoryAligned h σ φ x z.1 z.2)
    (fun z => z.2.1.1=true → z.1.1.1=true) halign hlive _ hOld hLocal
  intro history old next ha hl
  exact liveOriginalCost_append_le h hσ φ x history old next ha hl

end NeuralGeneralization.RobustCompressionInduction
