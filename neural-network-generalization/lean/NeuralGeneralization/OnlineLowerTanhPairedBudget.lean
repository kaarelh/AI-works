import NeuralGeneralization.OnlineLowerTanhDominantPairBounds
import NeuralGeneralization.OnlineLowerTanhEffectiveColumns
import NeuralGeneralization.OnlineLowerTanhWalshColumnsMass
import NeuralGeneralization.OnlineLowerTanhPathActualCost

/-! The actual paired rectangle mass has a polynomial noncentral-increment bound. -/
noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerTanh.Family
open OnlineLower OnlineLowerRelu OnlineLowerGeometry

/-- Actual paired mass is bounded without assuming that logical coefficients
have the signs of their single independent preimages. Negative singleton
contributions are discarded by the proved positive-mass pushforward. -/
theorem codeBalancedCost_paired_budget (b:ActualGainBranch) :
    ∃S U:ℝ,0<S ∧ 0<U ∧ b.threshold<U ∧
      ∀R H k:ℕ,∀hR:0<R,∀hH:0<H,Even R → Even H →
      U≤((pairDim R H k:ℝ)*R+1) →
      S*(effectiveDim k+1:ℕ)≤((pairDim R H k:ℝ)*R+1) →
      rectanglePairedTotal (codeBalancedCost (physicalCode R H k hR hH)) (shiftPoint k)≤
        (3*optimizedCostCurvature/(4*((pairDim R H k:ℝ)*R+1)^3))*
          ((4*OnlineLowerRelu.Family.pairDim k:ℝ)*
            (4*OnlineLowerRelu.Family.pairDim k+2*H)) := by
  obtain ⟨S₁,hS₁,hbound⟩:=optimized_increment_dominant_pair_bounds b
  obtain ⟨S₂,hS₂,hpositive⟩:=optimized_increment_walsh_positive b
  obtain ⟨U,hU,hbranch,hmono⟩:=optimizedRealCost_eventually_strictMono b
  refine ⟨max S₁ S₂,U,lt_max_of_lt_left hS₁,hU,hbranch,?_⟩
  intro R H k hR hH hRe hHe hbase hthreshold
  let n:ℝ:=(pairDim R H k:ℝ)*R+1
  let δ:=effectiveIncrement H k
  let c:=walshCoefficients (incrementScore δ (optimizedRealCost b) n)
  have h₁:S₁*(effectiveDim k+1:ℕ)≤n:=
    (mul_le_mul_of_nonneg_right (le_max_left _ _) (Nat.cast_nonneg _)).trans hthreshold
  have h₂:S₂*(effectiveDim k+1:ℕ)≤n:=
    (mul_le_mul_of_nonneg_right (le_max_right _ _) (Nat.cast_nonneg _)).trans hthreshold
  have hc:∀I:Finset (Fin (effectiveDim k)),2≤I.card → 0≤c I:=fun I hI=>
    (hpositive _ δ (effectiveIncrement_pos H k hH) n h₂ I hI).le
  have hs:∀i,c {i}≤0:=by
    intro i
    exact increment_walsh_singleton_nonpos δ (fun i=>(effectiveIncrement_pos H k hH i).le)
      (optimizedRealCost b) U n hmono.monotoneOn hbase {i} (by simp)
  have hb:=rectanglePairedTotal_le_column_high_mass (scalarSupportWeight R H k (optimizedRealCost b))
    (effectiveColumn k) c hc hs (centralEffectiveSupport k)
    (scalarSupportWeight_compact_pushforward R H k (optimizedRealCost b))
  rw [centralEffectiveSupport_point] at hb
  have ht:=(hbound (effectiveDim k) δ (effectiveIncrement_pos H k hH) n h₁
    (firstDistinguished k) (secondDistinguished k) (distinguished_ne k)).2
  simp only [δ,effectiveIncrement_sum,effectiveIncrement_old_sum] at ht
  rw [codeBalancedCost_eq_scalarSupportWeight b R H k hR hH hRe hHe (by
    have hh:=hbranch.trans_le hbase
    simpa only [Nat.cast_add,Nat.cast_mul,Nat.cast_one] using hh)]
  exact hb.trans ht

end NeuralGeneralization.OnlineLowerTanh.Family
