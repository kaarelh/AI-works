import NeuralGeneralization.BatchTwoGramPowerSubspace
import NeuralGeneralization.BatchTwoImprovedSourceGood

/-! The exact manuscript sampling allocation controls the actual measurable
source-index kernel, including singular and empty active spaces. -/
noncomputable section
set_option autoImplicit false
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators RealInnerProductSpace
open MeasureTheory ProbabilityTheory InnerProductSpace WithLp
namespace NeuralGeneralization.BatchTwoGramPower
open BatchTwoImprovedWeightedSampling BatchTwoImprovedActiveGeometry SquaredSampling
open RobustGaussianGeometry Classical
variable {N q m : ℕ}

theorem manuscript_gram_allocation {η : ℝ} (hη : 0<η) (hη1 : η≤1)
    (q m : ℕ) (hbudget : 64*((q:ℝ)+1)*Real.log (4*((q:ℝ)+1)/η)≤m) :
    (q:ℝ)*Real.exp (-(m:ℝ)/(16*((q:ℝ)+1)))≤η/4 := by
  have hq : (0:ℝ)<(q:ℝ)+1 := by positivity
  have hx : 0<4*((q:ℝ)+1)/η := by positivity
  have hx1 : 1≤4*((q:ℝ)+1)/η := (le_div_iff₀ hη).mpr (by nlinarith [show (0:ℝ)≤q by positivity])
  have hlog : 0≤Real.log (4*((q:ℝ)+1)/η) := Real.log_nonneg hx1
  have hh : Real.log (4*((q:ℝ)+1)/η)≤(m:ℝ)/(16*((q:ℝ)+1)) := by
    apply (le_div_iff₀ (by positivity)).mpr
    nlinarith [mul_nonneg hlog hq.le]
  have he := Real.exp_le_exp.mpr (neg_le_neg hh)
  rw [Real.exp_neg (Real.log (4*((q:ℝ)+1)/η)),Real.exp_log hx] at he
  calc
    _ ≤(q:ℝ)*(4*((q:ℝ)+1)/η)⁻¹ := by
      simpa only [neg_div] using mul_le_mul_of_nonneg_left he (Nat.cast_nonneg q)
    _ ≤η/4 := by
      rw [inv_div,←mul_div_assoc]
      apply (div_le_iff₀ (by positivity : 0<4*((q:ℝ)+1))).mpr
      nlinarith

theorem leverage_badGram_exponential (hN : 0<N) (hq : 0<q)
    (u : Fin N→Fin q→ℝ) (htrace : ∑j,rowEnergy u j=(N:ℝ)*q)
    (hiso : ∀v : Fin q→ℝ,(∑j,(linearEvaluation (u j) v)^2)/(N:ℝ)=∑k,v k^2)
    (hm : 0<m) :
    mean (iidWeight (leverageProbability u) m)
      (fun s=>if badGram (leverageRow u) s then (1:ℝ) else 0)≤
      (q:ℝ)*Real.exp (-(m:ℝ)/(16*((q:ℝ)+1))) := by
  exact weighted_badGram_exponential (leverageProbability u)
    (fun j=>(leverageProbability_pos hN hq u j).le)
    (leverageProbability_mass hN hq u htrace) hm (leverageRow u)
    (leverageRow_isotropy hN hq u hiso) (leverageRow_energy_le hN hq u)

theorem sourceBank_failure_exponential (hN : 0<N) (hq : 0<q) (hm : 0<m)
    (b : Fin q→EuclideanSpace ℝ (Fin N)) :
    (sourceIndicesKernel hN hq m (fun j k=>sourceRows b j k)).real {s | sourceBad b s}≤
      ((activeSlots b).card:ℝ)*Real.exp (-(m:ℝ)/(16*((q:ℝ)+1))) := by
  let u := fun j k=>sourceRows b j k
  let p := sourceProbability u
  have hiso (v : Fin q→ℝ) (hv : onActiveSlots b v) :
      mean p (fun j=>(sourceSampleRow u j ⬝ᵥv)^2)=∑k,v k^2 := by
    rw [show mean p (fun j=>(sourceSampleRow u j ⬝ᵥv)^2)=
        mean p (fun j=>(linearEvaluation (sourceSampleRow u j) v)^2) from rfl,
      sourceSampleRow_covariance hN hq]
    exact sourceRows_covariance_active b hN v hv
  have hp := fun j=>(sourceProbability_pos hN hq u j).le
  have hpm := sourceProbability_mass hN hq u
  have hh := weighted_badGramOn_exponential p hp hpm hm hq (sourceSampleRow u)
    (activeSlots b) hiso (sourceSampleRow_energy_le hN hq u (sourceRows_trace b hN))
  change (finiteLaw (iidWeight p m) (iidWeight_nonneg p hp m) (iidWeight_mass p hpm m)).real _≤_
  rw [finiteLaw_real_apply]
  exact hh

theorem sourceBank_failure_manuscript (hN : 0<N) (hq : 0<q) (hm : 0<m)
    (b : Fin q→EuclideanSpace ℝ (Fin N)) {η : ℝ} (hη : 0<η) (hη1 : η≤1)
    (hbudget : 64*((q:ℝ)+1)*Real.log (4*((q:ℝ)+1)/η)≤m) :
    (sourceIndicesKernel hN hq m (fun j k=>sourceRows b j k)).real {s | sourceBad b s}≤η := by
  have hc : ((activeSlots b).card:ℝ)≤q := by
    exact_mod_cast ((Finset.card_le_card (Finset.subset_univ (activeSlots b))).trans_eq (by simp))
  calc
    _ ≤((activeSlots b).card:ℝ)*Real.exp (-(m:ℝ)/(16*((q:ℝ)+1))) := sourceBank_failure_exponential hN hq hm b
    _ ≤(q:ℝ)*Real.exp (-(m:ℝ)/(16*((q:ℝ)+1))) := mul_le_mul_of_nonneg_right hc (Real.exp_pos _).le
    _ ≤η/4 := manuscript_gram_allocation hη hη1 q m hbudget
    _ ≤η := by linarith

end NeuralGeneralization.BatchTwoGramPower
