import SubcriticalMarginAccounting

/-! Raw-cost occupation for actual paths at every 0<t≤1. This applies when
the entire unadjusted action is close to the critical scalar baseline,
including the short nearcritical regime. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel NeuralGeneralization.GaussianFieldTilt

theorem physical_action_dominates_critical_readout {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) :
    (∑j∈Finset.range H,physicalLayerCost P j)+‖P.readout‖^2/2≤P.action := by
  rw [ControlledMarginPath.action]
  change (∑j∈Finset.range H,physicalLayerCost P j)+‖P.readout‖^2/2≤
    (∑j : Fin H,physicalLayerCost P j)+‖P.readout‖^2/(2*t^2)
  rw [Fin.sum_univ_eq_sum_range (physicalLayerCost P) H]
  apply add_le_add le_rfl
  apply div_le_div_of_nonneg_left (sq_nonneg _) (by nlinarith [sq_pos_of_pos P.scale_positive])
  nlinarith [P.scale_positive,P.scale_le_one]

theorem physicalMarginPath_occupation {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (hd : 1≤d) (hH : 1≤H)
    {ε : ℝ} (hε : 0≤ε) (hnear : P.action≤scalarBaseline.toReal+ε) :
    (∑j : Fin H,Real.sqrt (physicalLayerCost P j))≤criticalEntropyBudget H ε ∧
    (∑j : Fin H,maxFeatureVariance (P.feature j))≤criticalVarianceBudget H ε := by
  classical
  obtain ⟨n,rfl⟩ := Nat.exists_eq_succ_of_ne_zero (by omega : H≠0)
  have hrec (j : ℕ) (hj : j<n+1) (x : Cube d) :
      ‖P.feature (j+1) x‖^2=∫z,(Real.tanh (z x))^2 ∂P.law j := by
    simpa only [real_inner_self_eq_norm_sq,pow_two] using P.recursion j hj x x
  have hcost : ∑j∈Finset.range (n+1),physicalLayerCost P j =
      physicalLayerCost P 0+∑j∈Finset.range n,physicalLayerCost P (j+1) := by
    rw [Finset.sum_range_succ']
    ring
  have haction := physical_action_dominates_critical_readout P
  rw [hcost] at haction
  have hD0 : 0≤physicalLayerCost P 0 := ENNReal.toReal_nonneg
  have htailnear : (∑j∈Finset.range n,physicalLayerCost P (j+1))+‖P.readout‖^2/2≤
      scalarBaseline.toReal+ε := by linarith
  let x0 : Cube d := fun _ => false
  have hm : (1/2:ℝ)≤|inner ℝ P.readout (P.feature (n+1) x0)| := by
    have hh := P.margin x0
    have hl : labelReal (f x0)*inner ℝ P.readout (P.feature (n+1) x0)≤
        |inner ℝ P.readout (P.feature (n+1) x0)| := by
      calc
        _ ≤ |labelReal (f x0)*inner ℝ P.readout (P.feature (n+1) x0)| := le_abs_self _
        _ = _ := by rw [abs_mul,abs_labelReal,one_mul]
    linarith
  have ht := controlled_field_occupation n (fun j => P.feature (j+1))
    (fun j => scaledFeatureCoefficients t (P.feature (j+1))) (fun j => P.law (j+1))
    (fun j hj => P.probability (j+1) (by omega))
    (fun j hj => P.finiteKL (j+1) (by omega))
    (fun j hj x => scaled_source_variance_le (P.feature (j+1)) t
      (by rw [abs_of_pos P.scale_positive]; exact P.scale_le_one) x)
    (fun j hj x => by simpa only [Nat.add_assoc] using hrec (j+1) (by omega) x)
    (fun x => by
      letI := P.probability 0 (by omega)
      rw [hrec 0 (by omega)]
      exact field_tanh_moment_le_one (P.law 0) x)
    P.readout x0 (by simpa using hm) ε hε htailnear
  have hD0upper : physicalLayerCost P 0≤257+ε := by
    have htailnonneg : 0≤∑j∈Finset.range n,physicalLayerCost P (j+1) :=
      Finset.sum_nonneg fun j _ => ENNReal.toReal_nonneg
    have hro : 0≤‖P.readout‖^2/2 := by positivity
    linarith [scalarBaseline_le]
  have hinitial : maxFeatureVariance (P.feature 0)≤2 := by
    unfold maxFeatureVariance
    rw [← real_inner_self_eq_norm_sq,P.initial,real_inner_self_eq_norm_sq]
    exact normalizedInputFeature_norm_sq_le_two hd _
  constructor
  · rw [Fin.sum_univ_eq_sum_range (fun j => Real.sqrt (physicalLayerCost P j)) (n+1),Finset.sum_range_succ']
    have hs := Real.sqrt_le_sqrt hD0upper
    simpa only [criticalEntropyBudget,Nat.succ_sub_one,physicalLayerCost,add_comm] using
      add_le_add ht.1 hs
  · rw [Fin.sum_univ_eq_sum_range (fun j => maxFeatureVariance (P.feature j)) (n+1),Finset.sum_range_succ']
    have htail := ht.2
    have hc := mul_le_mul_of_nonneg_left hinitial (by linarith [driftDissipation_pos] : 0≤driftDissipation/2)
    unfold criticalVarianceBudget
    simp only [Nat.succ_sub_one]
    have heq : (2/driftDissipation)*(driftDissipation+
        ((driftDissipation/2)*varianceEntropyConstant+3)*fieldEntropyOccupationBound n ε+
        Real.log (8*(257+ε))) =
      (2*(driftDissipation+
        ((driftDissipation/2)*varianceEntropyConstant+3)*fieldEntropyOccupationBound n ε+
        Real.log (8*(257+ε))))/driftDissipation := by ring
    rw [heq]
    apply (le_div_iff₀ driftDissipation_pos).mpr
    nlinarith


#print axioms physicalMarginPath_occupation
end ConditionalNonpolynomial.Analytic
