import NeuralGeneralization.OnlineLowerTanhPathFamily
import NeuralGeneralization.OnlineLowerTanhCodeNetwork
import NeuralGeneralization.OnlineLowerTanhCostMonotone

/-! The scalar path weights are the literal inverse balanced gains of the
actual odd physical supports, including the shared carrier coordinate. -/
noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerTanh.Family
open OnlineLower OnlineLowerGeometry OnlineLowerRelu

lemma support_card_lower (R H k:ℕ) (s:Finset (Fin (logicalDim k))) :
    pairDim R H k*R+1≤(carrierSupport (size R H k) (column R H k) s).card := by
  rw [carrierSupport_card]
  have h:∑i:Fin (pairDim R H k),R≤∑i:Fin (pairDim R H k),
      size R H k i (railOrientation (column R H k) s i):=by
    apply Finset.sum_le_sum
    intro i _
    cases railOrientation (column R H k) s i <;> simp
  simp only [Finset.sum_const,Finset.card_univ,Fintype.card_fin,smul_eq_mul] at h
  omega

lemma support_card_empty (R H k:ℕ) :
    (carrierSupport (size R H k) (column R H k) ∅).card=pairDim R H k*R+1 := by
  simp [carrierSupport_card,railOrientation_empty,Nat.add_comm]

theorem codeBalancedCost_eq_scalarSupportWeight (b:ActualGainBranch)
    (R H k:ℕ) (hR:0<R) (hH:0<H) (hRe:Even R) (hHe:Even H)
    (hbase:b.threshold<((pairDim R H k*R+1:ℕ):ℝ)) :
    codeBalancedCost (physicalCode R H k hR hH)=
      scalarSupportWeight R H k (optimizedRealCost b) := by
  funext s
  have ho:=support_odd R H k hRe hHe s
  let n:ℕ:=(carrierSupport (size R H k) (column R H k) s).card
  have hn:2*(n/2)+1=n:=by
    have hmod:n%2=1:=Nat.odd_iff.mp ho
    omega
  have hb:b.threshold<(n:ℝ):=hbase.trans_le (by exact_mod_cast support_card_lower R H k s)
  have hi:=optimizedRealCost_odd b (n/2) (by simpa only [hn] using hb)
  unfold codeBalancedCost scalarSupportWeight
  rw [physicalCode_support]
  change balancedCost (n/2)=optimizedRealCost b (n:ℝ)
  simpa only [hn] using hi.symm

/-- The minimum atom cost is attained at the literal empty logical support.
Only the proved eventual monotonicity threshold is used. -/
theorem exists_scalarSupportWeight_min_threshold (b:ActualGainBranch) :
    ∃U:ℝ,0<U ∧ b.threshold<U ∧ ∀R H k:ℕ,
      U≤((pairDim R H k*R+1:ℕ):ℝ)→∀s:Finset (Fin (logicalDim k)),
      scalarSupportWeight R H k (optimizedRealCost b) ∅≤
        scalarSupportWeight R H k (optimizedRealCost b) s := by
  obtain ⟨U,hU,hb,hm⟩:=optimizedRealCost_eventually_strictMono b
  refine ⟨U,hU,hb,?_⟩
  intro R H k hbase s
  unfold scalarSupportWeight
  rw [support_card_empty]
  have hl:((pairDim R H k*R+1:ℕ):ℝ)≤
      ((carrierSupport (size R H k) (column R H k) s).card:ℝ):=by
    exact_mod_cast support_card_lower R H k s
  exact hm.monotoneOn hbase (hbase.trans hl) hl

theorem candidate_rectangle_codeBalancedCost_eq (b:ActualGainBranch)
    (R H k:ℕ) (hR:0<R) (hH:0<H) (hRe:Even R) (hHe:Even H) (hk:1≤k)
    (hbase:b.threshold<((pairDim R H k*R+1:ℕ):ℝ))
    (endpoint:Bool) (digits:CandidateDigits k) :
    rectangleEffectiveCost (codeBalancedCost (physicalCode R H k hR hH)) (shiftPoint k)
      (candidatePoint k hk endpoint digits)=
      -FamilyCost.candidateCost k hk ((pairDim R H k:ℝ)*R+1+H)
        (optimizedRealCost b) endpoint digits := by
  rw [codeBalancedCost_eq_scalarSupportWeight b R H k hR hH hRe hHe hbase]
  exact candidate_rectangle_scalarSupportWeight_eq R H k hk _ endpoint digits

end NeuralGeneralization.OnlineLowerTanh.Family
