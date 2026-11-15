import NeuralGeneralization.OnlineLowerTanhFiniteParityLocalMaximum
import Mathlib.Analysis.Calculus.FDeriv.CompCLM
import Mathlib.Analysis.Calculus.ContDiff.Basic
import Mathlib.Analysis.Calculus.ContDiff.Comp

/-! The actual normalized affine Hessian, including every mixed direction. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1600000
open scoped BigOperators Topology
open Filter Set
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel TanhDifferential

def inverseAffineNorm (E L K t:ℝ):ℝ := (Real.sqrt (E+2*L*t+K*t^2))⁻¹
def inverseAffineSlope (E L K t:ℝ):ℝ := -(L+K*t)/(Real.sqrt (E+2*L*t+K*t^2))^3

lemma hasDerivAt_inverseAffineNorm (E L K t:ℝ) (hE:0<E+2*L*t+K*t^2) :
    HasDerivAt (inverseAffineNorm E L K) (inverseAffineSlope E L K t) t := by
  have hs:0<Real.sqrt (E+2*L*t+K*t^2):=Real.sqrt_pos.mpr hE
  have hp:=((((hasDerivAt_id t).const_mul (2*L)).const_add E).add
    (((hasDerivAt_id t).pow 2).const_mul K))
  have hh:=(hp.sqrt hE.ne').inv hs.ne'
  convert hh using 1 <;> (try rfl)
  simp only [inverseAffineSlope,id_eq,Pi.pow_apply,Pi.add_apply,mul_one,Nat.cast_ofNat,Nat.reduceSub,pow_one]
  field_simp
  <;> ring

lemma hasDerivAt_inverseAffineSlope_zero (E L K:ℝ) (hE:0<E) :
    HasDerivAt (inverseAffineSlope E L K)
      (-K/(Real.sqrt E)^3+3*L^2/(Real.sqrt E)^5) 0 := by
  have hs:0<Real.sqrt E:=Real.sqrt_pos.mpr hE
  have hp:=((((hasDerivAt_id (0:ℝ)).const_mul (2*L)).const_add E).add
    (((hasDerivAt_id (0:ℝ)).pow 2).const_mul K))
  have hE':E+2*L*0+K*0^2≠0:=by simpa using hE.ne'
  have hh:=((((hasDerivAt_id (0:ℝ)).const_mul K).const_add L).neg).div
    ((hp.sqrt hE').pow 3) (by simpa using pow_ne_zero 3 hs.ne')
  convert hh using 1 <;> (try rfl)
  simp only [Pi.pow_apply,Pi.add_apply,Pi.neg_apply,id_eq,mul_zero,zero_add,add_zero,zero_pow (by norm_num : (2:ℕ)≠0),
    mul_one,Nat.cast_ofNat,Nat.reduceSub,pow_one,sub_zero,zero_div]
  field_simp
  <;> ring

lemma normalized_affine_line_second (E L K:ℝ) (hE:0<E) (f f':ℝ→ℝ) (fpp:ℝ)
    (hf:∀t,HasDerivAt f (f' t) t) (hf':HasDerivAt f' fpp 0)
    (hstat:f' 0=f 0*L/E) :
    HasDerivAt (deriv (fun t=>f t/Real.sqrt (E+2*L*t+K*t^2)))
      (fpp/Real.sqrt E-f 0*(K*E-L^2)/(Real.sqrt E)^5) 0 := by
  have hs:0<Real.sqrt E:=Real.sqrt_pos.mpr hE
  have hev:∀ᶠ t in 𝓝 (0:ℝ),0<E+2*L*t+K*t^2:=by
    have hc:Continuous (fun t:ℝ=>E+2*L*t+K*t^2):=by fun_prop
    exact (isOpen_Ioi.preimage hc).mem_nhds (by simpa using hE)
  have heq:deriv (fun t=>f t/Real.sqrt (E+2*L*t+K*t^2)) =ᶠ[𝓝 (0:ℝ)]
      (fun t=>f' t*inverseAffineNorm E L K t+f t*inverseAffineSlope E L K t):=by
    filter_upwards [hev] with t ht
    exact ((hf t).mul (hasDerivAt_inverseAffineNorm E L K t ht)).deriv
  have hE':0<E+2*L*0+K*0^2:=by simpa using hE
  have hh:=(hf'.mul (hasDerivAt_inverseAffineNorm E L K 0 hE')).add
    ((hf 0).mul (hasDerivAt_inverseAffineSlope_zero E L K hE))
  apply HasDerivAt.congr_of_eventuallyEq _ heq
  convert hh using 1 <;> (try rfl)
  simp only [inverseAffineNorm,inverseAffineSlope,mul_zero,add_zero,zero_pow (by norm_num : (2:ℕ)≠0),
    hstat]
  have he:=Real.sq_sqrt hE.le
  field_simp
  rw [show (Real.sqrt E)^4=((Real.sqrt E)^2)^2 by ring]
  simp only [he]
  ring

lemma balancedAffinePoint_line_energy (r:ℕ) (a t:ℝ) (v:Fin ((2*r+1)+1)→ℝ) :
    (∑i,(balancedAffinePoint r a i+t*v i)^2)=
      ((2*r+1:ℕ):ℝ)*a^2+2*(a*(∑i:Fin (2*r+1),v i.succ))*t+
        (∑i,v i^2)*t^2 := by
  simp only [Fin.sum_univ_succ,balancedAffinePoint,Fin.cases_zero,Fin.cases_succ,zero_add]
  simp_rw [add_sq,mul_pow,Finset.sum_add_distrib]
  simp only [Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul]
  simp only [←Finset.mul_sum,←Finset.sum_mul]
  push_cast
  ring

lemma affine_direction_nonzero' {n:ℕ} (v:Fin (n+1)→ℝ) (hv:v≠0) :
    v 0≠0 ∨ (fun i:Fin n=>v i.succ)≠0 := by
  by_contra h
  push Not at h
  apply hv
  funext i
  refine Fin.cases ?_ (fun j=>?_) i
  · exact h.1
  · exact congrFun h.2 j

/-- The normalized objective has strictly negative second derivative in
every nonzero affine direction at its stationary balanced point. -/
theorem signedAffineParityRatio_line_second_negative (r:ℕ) (hr:2≤r)
    (v:Fin ((2*r+1)+1)→ℝ) (hv:v≠0) :
    deriv (deriv (fun t:ℝ=>signedAffineParityRatio r
      (balancedAffinePoint r (balancedGain r)+t • v))) 0<0 := by
  let a:=balancedGain r
  let q:=balancedParity r a
  let n:ℝ:=(2*r+1:ℕ)
  let S:=∑i:Fin (2*r+1),v i.succ
  let K:=∑i,v i^2
  let E:=n*a^2
  let L:=a*S
  let f:=signedAffineNumeratorLine ((-1:ℝ)^r) a (v 0) (fun i=>v i.succ)
  let f':=signedAffineNumeratorLineFirst ((-1:ℝ)^r) a (v 0) (fun i=>v i.succ)
  let fpp:=signedAffineNumeratorLineSecond ((-1:ℝ)^r) a (v 0) (fun i=>v i.succ) 0
  have ha:0<a:=balancedGain_pos r
  have hn:0<n:=by dsimp [n];positivity
  have hE:0<E:=by dsimp [E];positivity
  have hq:0<q:=balancedParity_gain_pos r
  have hf0:f 0=q:=by
    dsimp [f]
    rw [signedAffineNumeratorLine_eq_actual]
    simp [q,balancedParity]
  have hf'0:f' 0=q/(n*a)*S:=signedAffineNumeratorLineFirst_at_gain r hr _ _
  have hstat:f' 0=f 0*L/E:=by
    rw [hf'0,hf0]
    dsimp [L,E]
    field_simp
    <;> ring
  have hd:=normalized_affine_line_second E L K hE f f' fpp
    (fun t=>hasDerivAt_signedAffineNumeratorLine _ _ _ _ t)
    (hasDerivAt_signedAffineNumeratorLineFirst _ _ _ _ 0) hstat
  have he:(fun t:ℝ=>signedAffineParityRatio r (balancedAffinePoint r a+t • v))=
      (fun t=>f t/Real.sqrt (E+2*L*t+K*t^2)):=by
    funext t
    unfold signedAffineParityRatio affineParityCoefficient
    simp only [Pi.add_apply,Pi.smul_apply,smul_eq_mul]
    rw [balancedAffinePoint_line_energy]
    congr 1
    dsimp [f]
    rw [signedAffineNumeratorLine_eq_actual]
    simp [balancedAffinePoint]
  rw [he,hd.deriv,hf0]
  have hpp:fpp<0:=signedAffineNumeratorLineSecond_negative r (by omega) a
    (balancedGain_mem r).1 _ _ (affine_direction_nonzero' v hv)
  have hvar:=incomingVariance_nonneg (by omega : 0<2*r+1) (fun i=>v i.succ)
  have hS:S^2≤n*incomingEnergy (fun i:Fin (2*r+1)=>v i.succ):=by
    have hh:S^2/n ≤ incomingEnergy (fun i:Fin (2*r+1)=>v i.succ):=by
      dsimp [S,n] at *
      linarith only [hvar]
    exact ((div_le_iff₀ hn).mp hh).trans_eq (mul_comm _ _)
  have hK:K=(v 0)^2+incomingEnergy (fun i:Fin (2*r+1)=>v i.succ):=by
    simp [K,Fin.sum_univ_succ,incomingEnergy]
  have hnon:0≤K*E-L^2:=by
    have hh:=mul_le_mul_of_nonneg_left hS (sq_nonneg a)
    have hp:=mul_nonneg (mul_nonneg hn.le (sq_nonneg a)) (sq_nonneg (v 0))
    dsimp [E,L]
    rw [hK]
    nlinarith only [hh,hp]
  have hh:=div_neg_of_neg_of_pos hpp (Real.sqrt_pos.mpr hE)
  have hp:0≤q*(K*E-L^2)/(Real.sqrt E)^5:=div_nonneg (mul_nonneg hq.le hnon) (by positivity)
  linarith

lemma second_line_eq_hessian {E:Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
    (F:E→ℝ) (x v:E) (hf:ContDiffAt ℝ 2 F x) :
    deriv (deriv (fun t:ℝ=>F (x+t • v))) 0=fderiv ℝ (fderiv ℝ F) x v v := by
  have hp (t:ℝ):HasDerivAt (fun t:ℝ=>x+t • v) v t:=by
    simpa using ((hasDerivAt_id t).smul_const v).const_add x
  have hcont:Tendsto (fun t:ℝ=>x+t • v) (𝓝 0) (𝓝 x):=by
    simpa only [zero_smul,add_zero] using (hp 0).continuousAt.tendsto
  have hev:deriv (fun t:ℝ=>F (x+t • v)) =ᶠ[𝓝 (0:ℝ)]
      (fun t=>fderiv ℝ F (x+t • v) v):=by
    filter_upwards [hcont.eventually (hf.eventually (by norm_num))] with t ht
    exact (ht.differentiableAt (by norm_num)).hasFDerivAt.comp_hasDerivAt t (hp t) |>.deriv
  have hfd:DifferentiableAt ℝ (fderiv ℝ F) x:=
    (hf.fderiv_right (m:=1) (by norm_num)).differentiableAt (by norm_num)
  have hd:=hfd.hasFDerivAt.comp_hasDerivAt_of_eq (0:ℝ) (hp 0) (by simp)
  have hh:=hd.clm_apply (hasDerivAt_const (0:ℝ) v)
  rw [hev.deriv_eq]
  simpa using hh.deriv

lemma contDiffAt_signedAffineParityRatio (r:ℕ) :
    ContDiffAt ℝ 2 (signedAffineParityRatio r) (balancedAffinePoint r (balancedGain r)) := by
  have ha:=balancedGain_pos r
  have henergy:0<∑i,(balancedAffinePoint r (balancedGain r) i)^2:=by
    rw [balancedAffinePoint_energy]
    positivity
  have hsqrt:Real.sqrt (∑i,(balancedAffinePoint r (balancedGain r) i)^2)≠0:=
    (Real.sqrt_pos.mpr henergy).ne'
  have hc:ContDiff ℝ 2 (affineParityCoefficient (2*r+1)):=by
    unfold affineParityCoefficient parityCorrelation incomingLinear
    simp_rw [Real.tanh_eq_sinh_div_cosh]
    fun_prop (disch := intro z; exact (Real.cosh_pos _).ne')
  unfold signedAffineParityRatio
  exact (contDiffAt_const.mul hc.contDiffAt).div
    ((by fun_prop : ContDiffAt ℝ 2 (fun z:Fin ((2*r+1)+1)→ℝ=>∑i,z i^2)
      (balancedAffinePoint r (balancedGain r))).sqrt henergy.ne') hsqrt

/-- Negative definiteness of the actual Fréchet Hessian of the paper's
normalized affine objective, at every finite odd degree at least five. -/
theorem signedAffineParityRatio_hessian_negative_definite (r:ℕ) (hr:2≤r)
    (v:Fin ((2*r+1)+1)→ℝ) (hv:v≠0) :
    fderiv ℝ (fderiv ℝ (signedAffineParityRatio r))
      (balancedAffinePoint r (balancedGain r)) v v<0 := by
  rw [←second_line_eq_hessian _ _ _ (contDiffAt_signedAffineParityRatio r)]
  exact signedAffineParityRatio_line_second_negative r hr v hv

end NeuralGeneralization.OnlineLowerTanh
