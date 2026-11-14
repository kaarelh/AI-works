import NeuralGeneralization.OnlineLowerTanhFiniteParitySlices
import NeuralGeneralization.OnlineLowerTanhPairReindex

/-! Actual pair-difference curvature at every finite odd degree. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1200000
open scoped BigOperators Topology
namespace NeuralGeneralization.OnlineLowerTanh

def balancedPairNumerator (r:ℕ) (a t:ℝ) : ℝ :=
  (-1:ℝ)^(r+1)/2*(parityCorrelation (fun _:Fin (2*r+1)=>a) (2*a)-
    parityCorrelation (fun _:Fin (2*r+1)=>a) (Real.sqrt 2*t))

def balancedPairNumeratorFirst (r:ℕ) (a t:ℝ) : ℝ :=
  -((-1:ℝ)^(r+1)/2)*(parityBiasFirst (fun _:Fin (2*r+1)=>a) (Real.sqrt 2*t)*Real.sqrt 2)

def balancedAffinePairSlice (r:ℕ) (a t:ℝ) : ℝ :=
  balancedPairNumerator r a t/Real.sqrt ((2*r+3:ℕ)*a^2+t^2)

lemma balancedPairNumerator_eq_actual (r:ℕ) (a t:ℝ) :
    balancedPairNumerator r a t=(-1:ℝ)^(r+1)*
      parityCorrelation (pairIncoming (fun _:Fin (2*r+1)=>a) a (t/Real.sqrt 2)) 0 := by
  rw [parityCorrelation_pair (by exact ⟨r,by omega⟩)]
  have hs:2*(t/Real.sqrt 2)=Real.sqrt 2*t:=by
    have h2:Real.sqrt 2^2=(2:ℝ):=Real.sq_sqrt (by norm_num)
    have hn:Real.sqrt 2≠0:=by positivity
    calc
      2*(t/Real.sqrt 2)=(Real.sqrt 2)^2*(t/Real.sqrt 2):=by rw [h2]
      _=Real.sqrt 2*t:=by field_simp
  rw [hs]
  unfold balancedPairNumerator
  ring

lemma balancedAffinePairSlice_eq_actual (r:ℕ) (a t:ℝ) :
    balancedAffinePairSlice r a t=
      ((-1:ℝ)^(r+1)*parityCorrelation (pairIncoming (fun _:Fin (2*r+1)=>a) a (t/Real.sqrt 2)) 0)/
        Real.sqrt (incomingEnergy (pairIncoming (fun _:Fin (2*r+1)=>a) a (t/Real.sqrt 2))) := by
  rw [balancedAffinePairSlice,balancedPairNumerator_eq_actual,incomingEnergy_pair]
  congr 2
  simp only [incomingEnergy,Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul]
  rw [div_pow,Real.sq_sqrt (by norm_num : (0:ℝ)≤2)]
  push_cast
  ring

lemma balancedPairNumerator_zero (r:ℕ) (a:ℝ) :
    balancedPairNumerator r a 0=balancedParity (r+1) a := by
  rw [balancedPairNumerator_eq_actual]
  have he:pairIncoming (fun _:Fin (2*r+1)=>a) a (0/Real.sqrt 2)=
      (fun _:Fin ((2*r+1)+2)=>a):=by
    funext i
    refine Fin.cases ?_ (fun j=>Fin.cases ?_ (fun k=>?_) j) i <;> simp [pairIncoming] <;> rfl
  rw [he]
  have hnat:(2*r+1)+2=2*(r+1)+1:=by omega
  have hc:=parityCorrelation_equiv (finCongr hnat) (fun _:Fin (2*(r+1)+1)=>a) 0
  change (-1:ℝ)^(r+1)*parityCorrelation (fun _:Fin ((2*r+1)+2)=>a) 0=_
  rw [hc]
  rfl

lemma hasDerivAt_balancedPairNumerator (r:ℕ) (a t:ℝ) :
    HasDerivAt (balancedPairNumerator r a) (balancedPairNumeratorFirst r a t) t := by
  have h:=(((hasDerivAt_parityCorrelation (fun _:Fin (2*r+1)=>a) (Real.sqrt 2*t)).comp t
    ((hasDerivAt_id t).const_mul (Real.sqrt 2))).const_sub
      (parityCorrelation (fun _:Fin (2*r+1)=>a) (2*a))).const_mul ((-1:ℝ)^(r+1)/2)
  convert h using 1 <;> (try rfl)
  simp only [balancedPairNumeratorFirst,mul_one]
  ring

lemma hasDerivAt_balancedPairNumeratorFirst_zero (r:ℕ) (a:ℝ) :
    HasDerivAt (balancedPairNumeratorFirst r a) (balancedBiasCurvature r a) 0 := by
  have h:=((((hasDerivAt_parityBiasFirst (fun _:Fin (2*r+1)=>a) (Real.sqrt 2*0)).comp 0
    ((hasDerivAt_id (0:ℝ)).const_mul (Real.sqrt 2))).mul_const (Real.sqrt 2)).const_mul
      (-((-1:ℝ)^(r+1)/2)))
  convert h using 1 <;> (try rfl)
  simp only [balancedBiasCurvature,mul_zero,mul_one,pow_succ,mul_neg_one,neg_div,neg_neg]
  have h2:Real.sqrt 2^2=(2:ℝ):=Real.sq_sqrt (by norm_num)
  have hm:=congrArg (fun z:ℝ=>(-1:ℝ)^r/2*parityBiasSecond (fun _:Fin (2*r+1)=>a) 0*z) h2
  nlinarith only [hm]

/-- The unit pair-difference direction has precisely the normalized transverse
curvature in the paper; both sides concern the actual tanh correlation. -/
theorem balancedAffinePairSlice_second (r:ℕ) (a:ℝ) (ha:0<a) :
    HasDerivAt (deriv (balancedAffinePairSlice r a))
      (balancedBiasCurvature r a/Real.sqrt ((2*r+3:ℕ)*a^2)-
        balancedParity (r+1) a/(Real.sqrt ((2*r+3:ℕ)*a^2))^3) 0 := by
  have h:=hasDerivAt_deriv_normalized_zero (E:=((2*r+3:ℕ):ℝ)*a^2) (by positivity)
    (balancedPairNumerator r a) (balancedPairNumeratorFirst r a) (balancedBiasCurvature r a)
    (hasDerivAt_balancedPairNumerator r a) (hasDerivAt_balancedPairNumeratorFirst_zero r a)
  convert h using 1 <;> (try rfl)
  rw [balancedPairNumerator_zero]

/-- Strict negative transverse curvature at every finite odd degree at least
three and every gain at least one. -/
theorem balancedAffinePairSlice_second_neg (r:ℕ) (a:ℝ) (ha:1≤a) :
    deriv (deriv (balancedAffinePairSlice r a)) 0<0 := by
  rw [(balancedAffinePairSlice_second r a (by linarith)).deriv]
  have hs:0<Real.sqrt ((2*r+3:ℕ)*a^2):=by positivity
  have hcurv:=balancedBiasCurvature_neg r a ha
  have hq:0<balancedParity (r+1) a:=by
    have hh:=balancedParity_lower (r+1) a (by linarith)
    have ht:3/4<Real.tanh a:=tanh_one_gt_three_quarters.trans_le (scalar_tanh_monotone ha)
    exact lt_of_lt_of_le (mul_pos (oddParityKappa_pos (r+1)) (by linarith)) hh
  exact sub_neg.mpr ((div_neg_of_neg_of_pos hcurv hs).trans (div_pos hq (by positivity)))

end NeuralGeneralization.OnlineLowerTanh
