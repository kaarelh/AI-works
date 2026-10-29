import ControlledSubcriticalStep
import CriticalMarginOccupation

/-! Adjusted entropy accounting for an actual controlled margin path at
any physical scaling 0<t≤1. The Gaussian variance is retained in the
reference measure and the original normalized Boolean input is unchanged. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel NeuralGeneralization.GaussianFieldTilt

variable {d H : ℕ} {t : ℝ} {f : BooleanFunction d}

def physicalLayerCost (P : ControlledMarginPath d H t f) (j : ℕ) : ℝ :=
  (klDiv (P.law j) (fieldLaw (scaledFeatureCoefficients t (P.feature j)))).toReal

def physicalVariance (P : ControlledMarginPath d H t f) : ℝ≥0 := (t^2).toNNReal

@[simp] theorem physicalVariance_coe (P : ControlledMarginPath d H t f) :
    (physicalVariance P : ℝ)=t^2 := Real.coe_toNNReal _ (sq_nonneg _)

theorem physicalVariance_ne_zero (P : ControlledMarginPath d H t f) :
    physicalVariance P≠0 := by
  intro h
  have h' := congrArg (fun z : ℝ≥0 => (z:ℝ)) h
  simp only [physicalVariance_coe,NNReal.coe_zero] at h'
  nlinarith [P.scale_positive]

theorem physicalVariance_le_one (P : ControlledMarginPath d H t f) :
    physicalVariance P≤1 := by
  apply NNReal.coe_le_coe.mp
  simp only [physicalVariance_coe,NNReal.coe_one]
  nlinarith [P.scale_positive,P.scale_le_one]

def physicalMaxVariance (P : ControlledMarginPath d H t f) (j : ℕ) : ℝ :=
  maxFeatureVariance (P.feature j)

def physicalAdjustedCost (P : ControlledMarginPath d H t f) (j : ℕ) : ℝ :=
  adjustedLayerCost (physicalLayerCost P j) (physicalVariance P)
    (physicalMaxVariance P j) (physicalMaxVariance P (j+1))

def physicalPathLogGain (P : ControlledMarginPath d H t f) (j : ℕ) : ℝ :=
  physicalLogGain (physicalLayerCost P j) (physicalVariance P)

theorem controlledMarginPath_diagonal (P : ControlledMarginPath d H t f)
    (j : ℕ) (hj : j<H) (x : Cube d) :
    ‖P.feature (j+1) x‖^2=∫z,(Real.tanh (z x))^2 ∂P.law j := by
  simpa only [real_inner_self_eq_norm_sq,pow_two] using P.recursion j hj x x

theorem controlledMarginPath_readout (P : ControlledMarginPath d H t f) :
    0<physicalMaxVariance P H ∧ 1/(8*physicalMaxVariance P H)≤‖P.readout‖^2/2 := by
  let x : Cube d := fun _ => false
  apply margin_implies_max_variance_readout (P.feature H) P.readout x
  have hh := P.margin x
  have hl : labelReal (f x)*inner ℝ P.readout (P.feature H x)≤
      |inner ℝ P.readout (P.feature H x)| := by
    calc
      _ ≤ |labelReal (f x)*inner ℝ P.readout (P.feature H x)| := le_abs_self _
      _ = _ := by rw [abs_mul,abs_labelReal,one_mul]
  linarith

theorem controlledMarginPath_variance_positive (P : ControlledMarginPath d H t f) :
    ∀j≤H,0<physicalMaxVariance P j := by
  apply controlled_field_max_variance_pos H P.feature
    (fun j => scaledFeatureCoefficients t (P.feature j)) P.law P.probability P.finiteKL
    (fun j hj x => scaled_source_variance_le (P.feature j) t
      (by rw [abs_of_pos P.scale_positive]; exact P.scale_le_one) x)
    (controlledMarginPath_diagonal P)
  exact (controlledMarginPath_readout P).1

theorem controlledMarginPath_variance_le_one (P : ControlledMarginPath d H t f)
    (j : ℕ) (hj : j≤H) (hjpos : 1≤j) : physicalMaxVariance P j≤1 := by
  obtain ⟨k,rfl⟩ := Nat.exists_eq_succ_of_ne_zero (by omega : j≠0)
  letI := P.probability k (by omega)
  unfold physicalMaxVariance maxFeatureVariance
  rw [controlledMarginPath_diagonal P k (by omega)]
  exact field_tanh_moment_le_one (P.law k) _

/-- Scalarization at the query attaining the next maximum. This theorem
constructs the scalar law and proves its physical entropy bound. -/
theorem controlledMarginPath_scalar_step (P : ControlledMarginPath d H t f)
    (j : ℕ) (hj : j<H) :
    ∃p : ℝ, ∃R : Measure ℝ, 0<p ∧ p≤physicalMaxVariance P j ∧
      IsProbabilityMeasure R ∧ klDiv R (gaussianReal 0 (physicalVariance P))≠∞ ∧
      (klDiv R (gaussianReal 0 (physicalVariance P))).toReal≤physicalLayerCost P j ∧
      physicalMaxVariance P (j+1)=scalarTransition p R := by
  letI := P.probability j hj
  let x := featureMaximizer (P.feature (j+1))
  let p := ‖P.feature j x‖^2
  have hnext : 0<physicalMaxVariance P (j+1) :=
    controlledMarginPath_variance_positive P _ (by omega)
  have hmoment : physicalMaxVariance P (j+1)=∫z,(Real.tanh (z x))^2 ∂P.law j :=
    controlledMarginPath_diagonal P j hj x
  have hsource := controlled_field_positive_source
    (scaledFeatureCoefficients t (P.feature j)) x (P.law j) (P.finiteKL j hj)
    (by rwa [← hmoment])
  rw [scaled_source_variance_eq] at hsource
  have hp : 0<p := by dsimp [p]; nlinarith [sq_nonneg t,sq_nonneg ‖P.feature j x‖]
  obtain ⟨R,hR,hf,hc,ht⟩ := controlled_field_subcritical_step
    (scaledFeatureCoefficients t (P.feature j)) x (P.law j) (P.finiteKL j hj)
    (physicalVariance P) hp (by rw [physicalVariance_coe]; exact scaled_source_variance_eq _ _ _)
  exact ⟨p,R,hp,feature_variance_le_max _ x,hR,hf,hc,hmoment.trans ht.symm⟩

/-- Every actual layer has nonnegative adjusted charge, Bellman domination,
and the two sharp physical gain estimates. No surrogate scalar-control
hypothesis remains in this statement. -/
theorem controlledMarginPath_adjusted_step (P : ControlledMarginPath d H t f)
    (j : ℕ) (hj : j<H) :
    0≤physicalAdjustedCost P j ∧
      scalarValue (physicalMaxVariance P j)≤physicalAdjustedCost P j+
        scalarValue (physicalMaxVariance P (j+1)) ∧
      physicalPathLogGain P j≤2*Real.sqrt (physicalAdjustedCost P j) ∧
      (0<(physicalVariance P:ℝ)⁻¹-1 → physicalPathLogGain P j≤
        Real.log (physicalMaxVariance P (j+1)/physicalMaxVariance P j)/2+
        physicalAdjustedCost P j/((physicalVariance P:ℝ)⁻¹-1)) := by
  obtain ⟨p,R,hp,hpq,hR,hf,hc,ht⟩ := controlledMarginPath_scalar_step P j hj
  letI := hR
  have hqn := controlledMarginPath_variance_positive P (j+1) (by omega)
  have hgain := actual_adjusted_gain R (physicalVariance P) (physicalVariance_ne_zero P)
    (physicalVariance_le_one P) hf hp hpq hqn ht.le hc
  have hcrit := (scalar_subcritical_reference_change R (physicalVariance P)
    (physicalVariance_ne_zero P) (physicalVariance_le_one P) hf).1
  have hcost := adjusted_subcritical_scalar_cost R (physicalVariance P)
    (physicalVariance_ne_zero P) (physicalVariance_le_one P) hf hp hpq hqn ht.le
  have hbell := scalarValue_controlled_step (hp.trans_le hpq) hqn hp.le hpq R hR hcrit ht.le
  refine ⟨hgain.1,?_,hgain.2⟩
  unfold physicalAdjustedCost adjustedLayerCost
  linarith

/-- The scalar drift holds after the first bounded activation. -/
theorem controlledMarginPath_adjusted_drift (P : ControlledMarginPath d H t f)
    (j : ℕ) (hj : j<H) (hjpos : 1≤j) :
    driftRate*(physicalMaxVariance P (j+1)-physicalMaxVariance P j+
      driftDissipation*(physicalMaxVariance P j)^2)≤physicalAdjustedCost P j := by
  obtain ⟨p,R,hp,hpq,hR,hf,hc,ht⟩ := controlledMarginPath_scalar_step P j hj
  letI := hR
  have hh := adjusted_subcritical_scalar_properties R (physicalVariance P)
    (physicalVariance_ne_zero P) (physicalVariance_le_one P) hf hp hpq
    (controlledMarginPath_variance_positive P (j+1) (by omega))
    (controlledMarginPath_variance_le_one P j (by omega) hjpos) ht.le
  dsimp only at hh
  unfold physicalAdjustedCost adjustedLayerCost
  linarith [hh.2.2]


/-- The logarithmic correction telescopes exactly along the actual path. -/
theorem physical_log_ratio_sum (P : ControlledMarginPath d H t f) :
    (∑j∈Finset.range H,Real.log (physicalMaxVariance P (j+1)/physicalMaxVariance P j))=
      Real.log (physicalMaxVariance P H/physicalMaxVariance P 0) := by
  have hq := controlledMarginPath_variance_positive P
  calc
    _ = ∑j∈Finset.range H,(Real.log (physicalMaxVariance P (j+1))-
        Real.log (physicalMaxVariance P j)) := by
      apply Finset.sum_congr rfl
      intro j hj
      have hj' := Finset.mem_range.mp hj
      exact Real.log_div (hq (j+1) (by omega)).ne' (hq j (by omega)).ne'
    _ = Real.log (physicalMaxVariance P H)-Real.log (physicalMaxVariance P 0) :=
      Finset.sum_range_sub (fun j => Real.log (physicalMaxVariance P j)) H
    _ = _ := (Real.log_div (hq H le_rfl).ne' (hq 0 (Nat.zero_le _)).ne').symm

/-- Exact adjusted budget, including the scaled original readout cost. -/
theorem physical_adjusted_action_identity (P : ControlledMarginPath d H t f) :
    (∑j∈Finset.range H,physicalAdjustedCost P j)+‖P.readout‖^2/2=
      P.action-H*subcriticalCostBaseline (physicalVariance P)-
        ((physicalVariance P:ℝ)⁻¹-1)*
          (Real.log (physicalMaxVariance P H/physicalMaxVariance P 0)/2+‖P.readout‖^2/2) := by
  have hsum : (∑j∈Finset.range H,physicalAdjustedCost P j)=
      (∑j∈Finset.range H,physicalLayerCost P j)-H*subcriticalCostBaseline (physicalVariance P)-
        ((physicalVariance P:ℝ)⁻¹-1)/2*
          Real.log (physicalMaxVariance P H/physicalMaxVariance P 0) := by
    simp only [physicalAdjustedCost,adjustedLayerCost,Finset.sum_sub_distrib,
      ← Finset.mul_sum,Finset.sum_const,Finset.card_range,nsmul_eq_mul,physical_log_ratio_sum]
  have haction : P.action=(∑j∈Finset.range H,physicalLayerCost P j)+
      (physicalVariance P:ℝ)⁻¹*(‖P.readout‖^2/2) := by
    rw [ControlledMarginPath.action]
    change (∑j : Fin H,physicalLayerCost P j)+‖P.readout‖^2/(2*t^2)=_
    rw [Fin.sum_univ_eq_sum_range (physicalLayerCost P) H,physicalVariance_coe]
    field_simp
  rw [hsum,haction]
  ring

lemma log_ratio_readout_lower {q q0 r : ℝ} (hq : 0<q) (hq0 : 0<q0)
    (hq02 : q0≤2) (hr : 1/(8*q)≤r) :
    -1≤Real.log (q/q0)/2+r := by
  have hlog := Real.log_le_sub_one_of_pos (inv_pos.mpr (show (0:ℝ)<4*q by positivity))
  rw [Real.log_inv,Real.log_mul (by norm_num : (4:ℝ)≠0) hq.ne'] at hlog
  have hlog2 : Real.log (2:ℝ)≤1 := by
    have h := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<2)
    linarith
  have hlog4 : Real.log (4:ℝ)≤2 := by
    have he : Real.log (4:ℝ)=2*Real.log 2 := by
      rw [show (4:ℝ)=2*2 by norm_num,Real.log_mul (by norm_num) (by norm_num)]
      ring
    rw [he]
    linarith
  have hlog0 : Real.log q0≤1 :=
    (Real.log_le_log hq0 hq02).trans hlog2
  have hinv : (4*q)⁻¹=2*(1/(8*q)) := by field_simp; ring
  rw [hinv] at hlog
  rw [Real.log_div hq.ne' hq0.ne']
  linarith

/-- The only loss in the global adjusted budget is the explicit additive
parameter a=t⁻²−1. In particular this estimate does not lose a factor H. -/
theorem physical_adjusted_action_bound (P : ControlledMarginPath d H t f) (hd : 1≤d) :
    (∑j∈Finset.range H,physicalAdjustedCost P j)+‖P.readout‖^2/2≤
      P.action-H*subcriticalCostBaseline (physicalVariance P)+((physicalVariance P:ℝ)⁻¹-1) := by
  have hq := controlledMarginPath_variance_positive P
  have hq0 : physicalMaxVariance P 0≤2 := by
    unfold physicalMaxVariance maxFeatureVariance
    rw [← real_inner_self_eq_norm_sq,P.initial,real_inner_self_eq_norm_sq]
    exact normalizedInputFeature_norm_sq_le_two hd _
  have hl := log_ratio_readout_lower (hq H le_rfl) (hq 0 (Nat.zero_le _)) hq0
    (controlledMarginPath_readout P).2
  have hvp : 0<(physicalVariance P:ℝ) := by
    exact_mod_cast (pos_iff_ne_zero.mpr (physicalVariance_ne_zero P))
  have hvr : (physicalVariance P:ℝ)≤1 := by exact_mod_cast physicalVariance_le_one P
  have ha : 0≤(physicalVariance P:ℝ)⁻¹-1 := by
    linarith [(one_le_inv₀ hvp).mpr hvr]
  rw [physical_adjusted_action_identity]
  have hh := mul_le_mul_of_nonneg_left hl ha
  linarith

/-- Prefix control for the full adjusted layer charges, not merely their
one-dimensional marginal entropies. -/
theorem physical_adjusted_prefix_bound (P : ControlledMarginPath d H t f)
    {ε : ℝ}
    (hnear : (∑j∈Finset.range H,physicalAdjustedCost P j)+‖P.readout‖^2/2≤
      scalarBaseline.toReal+ε) :
    ∀i≤H,(∑j∈Finset.range i,physicalAdjustedCost P j)≤ε+526336*physicalMaxVariance P i := by
  intro i hi
  have htel : (∑j∈Finset.range i,physicalAdjustedCost P j)+scalarValue (physicalMaxVariance P i)≤
      (∑j∈Finset.range H,physicalAdjustedCost P j)+scalarValue (physicalMaxVariance P H) := by
    apply Nat.le_induction (P := fun n _ => n≤H →
      (∑j∈Finset.range i,physicalAdjustedCost P j)+scalarValue (physicalMaxVariance P i)≤
        (∑j∈Finset.range n,physicalAdjustedCost P j)+scalarValue (physicalMaxVariance P n))
      (fun _ => le_rfl) ?_ H hi le_rfl
    intro n hn ih hnH
    have hnlt : n<H := by omega
    have hb := (controlledMarginPath_adjusted_step P n hnlt).2.1
    have hh := ih (by omega)
    rw [Finset.sum_range_succ]
    linarith
  have hr := (scalarValue_le_readout (controlledMarginPath_variance_positive P H le_rfl)).trans
    (controlledMarginPath_readout P).2
  have hb := (scalarBaseline_global_bridge (controlledMarginPath_variance_positive P i hi)).2
  linarith

#print axioms controlledMarginPath_adjusted_step
#print axioms controlledMarginPath_adjusted_drift
#print axioms physical_adjusted_action_bound
#print axioms physical_adjusted_prefix_bound
end ConditionalNonpolynomial.Analytic
