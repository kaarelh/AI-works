import NeuralGeneralization.BatchTwoOnlineMeanFieldExactTail
import NeuralGeneralization.BatchTwoOnlineSharpFiniteBridge

/-! Exact boxed mean-field online budgets conditional only on the separately
proved target-cylinder estimate. This bridge is not advertised as a new
cylinder theorem. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators ENNReal
open MeasureTheory
namespace NeuralGeneralization.BatchTwoOnlineMeanFieldExact
open ConcreteModel BatchTwoOnline BatchTwoOnlineSharp

theorem capacity_nonneg (d r : ℕ) {K : ℝ} (hK : 0<K) : 0≤capacity d r K := by
  have hB:0≤compressedBound d r K:=by linarith [compressedBound_ge_one d r K]
  have hS:0≤sensitivity d (compressedWidth d r K) r (compressedBound d r K):=by
    unfold sensitivity
    positivity
  unfold capacity
  apply mul_nonneg (Nat.cast_nonneg _) (Real.log_nonneg _)
  have hh:=mul_nonneg hB hS
  nlinarith

theorem meanField_large_online_of_mass {d N r : ℕ} {A : ℝ}
    (hd : 1≤d) (hA : 1≤A) (f : BooleanFunction d)
    (hTN : learnerThreshold d r (onlineEnergy d r A)≤N)
    (hmass : Real.exp (-A*(N:ℝ)/2)≤functionMass Real.tanh (1/2) (powerPrior d N r 1) f) :
    NetworkOnlineBounds Real.tanh (1/2) (powerPrior d N r 1) f
      (capacity d r (onlineEnergy d r A)) := by
  have hK:=onlineEnergy_ge_four d r hA
  have hK0:0<onlineEnergy d r A:=by linarith
  have hN:0<N:=(learnerThreshold_pos d r (onlineEnergy d r A)).trans_le hTN
  have htail:=aggregate_tail (by omega : 0<d) hK hTN
  have ht : (∑f∈Finset.univ\functions d r (onlineEnergy d r A),
      functionMass Real.tanh (1/2) (powerPrior d N r 1) f)≤
      ((r:ℝ)+2)*Real.exp (-onlineEnergy d r A*(N:ℝ)/8):=by
    convert htail using 1 <;> congr 2 <;> ring
  have hratio:=online_tail_ratio ht hmass (by exact_mod_cast hN)
  have hpos:0<functionMass Real.tanh (1/2) (powerPrior d N r 1) f:=(Real.exp_pos _).trans_le hmass
  apply network_online_of_randomOrder hd Real.tanh (1/2) _ f _ (capacity_nonneg d r hK0) hpos
  exact bounds_of_relevant_class Fintype.card_pos _ (functionMass_nonneg Real.tanh (1/2) _) _ f
    (fun _=>rfl) hpos (functions d r (onlineEnergy d r A)) _ _
    (capacity_nonneg d r hK0) (by positivity) (functions_card_le_exp d r hK0) hratio

theorem meanField_small_prior_cost {d N r : ℕ} {A : ℝ} (hA : 1≤A)
    (f : BooleanFunction d) (hNT : N≤learnerThreshold d r (onlineEnergy d r A))
    (hmass : Real.exp (-A*(N:ℝ)/2)≤functionMass Real.tanh (1/2) (powerPrior d N r 1) f) :
    -Real.log (functionMass Real.tanh (1/2) (powerPrior d N r 1) f)≤
      A*(learnerThreshold d r (onlineEnergy d r A):ℝ)/2 := by
  have hh:=Real.log_le_log (Real.exp_pos _) hmass
  rw [Real.log_exp] at hh
  have hNR:(N:ℝ)≤learnerThreshold d r (onlineEnergy d r A):=by exact_mod_cast hNT
  have hmul:=mul_le_mul_of_nonneg_left hNR (show 0≤A by linarith)
  linarith

theorem meanField_small_total_of_mass {d N r : ℕ} {A : ℝ} (hA : 1≤A)
    (f : BooleanFunction d) (hNT : N≤learnerThreshold d r (onlineEnergy d r A))
    (hmass : Real.exp (-A*(N:ℝ)/2)≤functionMass Real.tanh (1/2) (powerPrior d N r 1) f)
    (query : ℕ→Cube d) :
    totalError (functionMass Real.tanh (1/2) (powerPrior d N r 1)) (fun g x=>g x=f x) query≤
      ENNReal.ofReal (A*(learnerThreshold d r (onlineEnergy d r A):ℝ)/2) := by
  apply (network_totalError_le_prior_cost tanh_continuous (1/2) (by norm_num) _ f
    ((Real.exp_pos _).trans_le hmass) query).trans
  exact ENNReal.ofReal_le_ofReal (meanField_small_prior_cost hA f hNT hmass)

theorem meanField_small_online_of_mass {d N r : ℕ} {A : ℝ}
    (hd : 1≤d) (hA : 1≤A) (f : BooleanFunction d)
    (hNT : N≤learnerThreshold d r (onlineEnergy d r A))
    (hmass : Real.exp (-A*(N:ℝ)/2)≤functionMass Real.tanh (1/2) (powerPrior d N r 1) f) :
    NetworkOnlineBounds Real.tanh (1/2) (powerPrior d N r 1) f
      (A*(learnerThreshold d r (onlineEnergy d r A):ℝ)/2) := by
  have hA0:0≤A:=by linarith
  have hP:0≤A*(learnerThreshold d r (onlineEnergy d r A):ℝ)/2:=by positivity
  have hmass':Real.exp (-(A*(learnerThreshold d r (onlineEnergy d r A):ℝ)/2))≤
      functionMass Real.tanh (1/2) (powerPrior d N r 1) f:=by
    apply le_trans _ hmass
    apply Real.exp_le_exp.mpr
    have hh:=mul_le_mul_of_nonneg_left (show (N:ℝ)≤learnerThreshold d r (onlineEnergy d r A) by exact_mod_cast hNT) hA0
    linarith
  exact network_online_of_randomOrder hd Real.tanh (1/2) _ f _ hP
    ((Real.exp_pos _).trans_le hmass') (network_bounds_of_prior_mass hd tanh_continuous _ f _ hP hmass')

end NeuralGeneralization.BatchTwoOnlineMeanFieldExact
