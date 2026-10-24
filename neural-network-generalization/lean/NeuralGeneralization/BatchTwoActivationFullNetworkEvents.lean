import NeuralGeneralization.BatchTwoActivationFullNetworkEventsTail
import NeuralGeneralization.BatchTwoActivationFullNetworkEventsReadout

/-! An actual full-network exponential tail, with adaptive covariance inputs
and a common finite-width threshold. No Gaussian event is assumed. -/
noncomputable section
set_option maxHeartbeats 1200000
set_option maxRecDepth 10000
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel GaussianAngularFields CompressionSampling FiniteDifferential
open RobustCompressionBlockMoments NetworkLayerSplit TowerNetwork

variable {b d K H N r : ℕ} {σ ℓ B : ℝ} {φ : ℝ→ℝ}

theorem ActivationGoodHidden.compl_tail (hd : 0<d) (hN : 0<N) (hb : 1≤b) (hK : 1≤K)
    (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1)
    (hφ : zeroLipschitzActivation ℓ φ) (hℓ0 : 0≤ℓ) (hB0 : 0≤B)
    (hℓ : ℓ≤b) (hB : B≤b) (hder : ∀t,|deriv scalarCutoff t|≤B)
    (hder2 : ∀t,|deriv (deriv scalarCutoff) t|≤B)
    (hwidth : activationLearnerThreshold b d K H≤N) :
    ∀r,r≤H→(smallPrior d N r σ).real {w | ¬ActivationGoodHidden b d K H N φ σ r w}≤
      2*((r:ℝ)+1)*Real.exp (-(N:ℝ)*(K:ℝ)) := by
  classical
  intro r
  induction r with
  | zero =>
    intro _
    have ht:=activationInputBad_tail hd hN hb hK hσ hscale hφ hℓ0 hB0 hℓ hB hder hder2 hwidth
    simpa only [ActivationGoodHidden,not_not,Nat.cast_zero,zero_add,mul_one,Set.setOf_mem_eq] using ht
  | succ r ih =>
    intro hr
    have hprev:=ih (by omega)
    have hp : MeasurePreserving (@previousWeights d N r) (smallPrior d N (r+1) σ)
        (smallPrior d N r σ) := measurePreserving_fst.comp (activationSmallPrior_split d N r σ)
    have hprevmeas : MeasurableSet {w : Weights d N r | ¬ActivationGoodHidden b d K H N φ σ r w} :=
      (measurableSet_ActivationGoodHidden (d:=d) (H:=H) (N:=N) (σ:=σ) hb hK hφ hℓ0 hB0 hℓ hB hder hder2 r (by omega)).compl
    have heq : (smallPrior d N (r+1) σ).real
        {w | ¬ActivationGoodHidden b d K H N φ σ r (previousWeights w)}=
        (smallPrior d N r σ).real {w | ¬ActivationGoodHidden b d K H N φ σ r w} := by
      rw [←hp.map_eq]
      simp only [Measure.real]
      rw [Measure.map_apply hp.measurable hprevmeas]
      rfl
    have hlast:=activationNewBad_tail (d:=d) (H:=H) (N:=N) (r:=r) hd hN hb hK hr hσ hscale hφ hℓ0 hB0 hℓ hB hder hder2 hwidth
    have hset : {w | ¬ActivationGoodHidden b d K H N φ σ (r+1) w}=
        {w | ¬ActivationGoodHidden b d K H N φ σ r (previousWeights w)} ∪
          activationNewBad b d K H N r φ σ := by
      ext w
      simp only [Set.mem_setOf_eq,ActivationGoodHidden,Set.mem_union,activationNewBad]
      by_cases hprev : ActivationGoodHidden b d K H N φ σ r (previousWeights w)
      · simp only [hprev,true_and,not_true,false_or,not_not]
      · simp only [hprev,false_and,not_false_eq_true,true_or]
    rw [hset]
    calc
      _≤(smallPrior d N (r+1) σ).real {w | ¬ActivationGoodHidden b d K H N φ σ r (previousWeights w)}+
          (smallPrior d N (r+1) σ).real (activationNewBad b d K H N r φ σ) := measureReal_union_le _ _
      _≤2*((r:ℝ)+1)*Real.exp (-(N:ℝ)*(K:ℝ))+2*Real.exp (-(N:ℝ)*(K:ℝ)) := by
        rw [heq]
        exact add_le_add hprev hlast
      _=_ := by push_cast; ring

def ActivationGoodNetwork (b d K H N r : ℕ) (φ : ℝ→ℝ) (σ : ℝ) (w : Weights d N r) : Prop :=
  ActivationGoodHidden b d K H N φ σ r w ∧ readoutEnergy w≤8*(K:ℝ)

theorem measurableSet_ActivationGoodNetwork (hb : 1≤b) (hK : 1≤K) (hr : r≤H)
    (hφ : zeroLipschitzActivation ℓ φ) (hℓ0 : 0≤ℓ) (hB0 : 0≤B)
    (hℓ : ℓ≤b) (hB : B≤b) (hder : ∀t,|deriv scalarCutoff t|≤B)
    (hder2 : ∀t,|deriv (deriv scalarCutoff) t|≤B) :
    MeasurableSet {w | ActivationGoodNetwork b d K H N r φ σ w} := by
  apply (measurableSet_ActivationGoodHidden hb hK hφ hℓ0 hB0 hℓ hB hder hder2 r hr).inter
  have hm : Measurable (fun w : Weights d N r=>readoutEnergy w) := by
    unfold readoutEnergy
    fun_prop
  exact measurableSet_le hm measurable_const

theorem ActivationGoodNetwork.compl_tail (hd : 0<d) (hN : 0<N) (hb : 1≤b) (hK : 1≤K)
    (hr : r≤H) (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1)
    (hφ : zeroLipschitzActivation ℓ φ) (hℓ0 : 0≤ℓ) (hB0 : 0≤B)
    (hℓ : ℓ≤b) (hB : B≤b) (hder : ∀t,|deriv scalarCutoff t|≤B)
    (hder2 : ∀t,|deriv (deriv scalarCutoff) t|≤B)
    (hwidth : activationLearnerThreshold b d K H≤N) :
    (smallPrior d N r σ).real {w | ¬ActivationGoodNetwork b d K H N r φ σ w}≤
      (2*((r:ℝ)+1)+1)*Real.exp (-(N:ℝ)*(K:ℝ)) := by
  have hh:=ActivationGoodHidden.compl_tail hd hN hb hK hσ hscale
    hφ hℓ0 hB0 hℓ hB hder hder2 hwidth r hr
  have ht:=activationReadout_bad_tail (r:=r) hd hN hK hσ hscale
  have heq : {w | ¬ActivationGoodNetwork b d K H N r φ σ w}=
      {w | ¬ActivationGoodHidden b d K H N φ σ r w} ∪ {w | 8*(K:ℝ)<readoutEnergy w} := by
    ext w
    simp only [ActivationGoodNetwork,Set.mem_setOf_eq,Set.mem_union,not_and_or,not_le]
  rw [heq]
  exact (measureReal_union_le _ _).trans ((add_le_add hh ht).trans_eq (by ring))

end NeuralGeneralization.BatchTwoActivation
