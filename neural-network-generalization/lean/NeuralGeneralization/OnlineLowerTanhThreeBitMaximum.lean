import NeuralGeneralization.OnlineLowerTanhThreeBitHolder

/-! All global three-bit maximizers are balanced: a finite exact argument. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1200000
open scoped BigOperators
open Set
namespace NeuralGeneralization.OnlineLowerTanh

lemma incomingEnergy_three (a b c:ℝ) : incomingEnergy ![a,b,c]=a^2+b^2+c^2 := by
  simp [incomingEnergy,Fin.sum_univ_succ]
  ring

lemma threeBit_scalar_cap_of_global (u:Fin 3→ℝ) (hu:IsIntrinsicMaximizer u)
    (a:ℝ) (ha:0≤a) : threeBitQ a≤(Real.sqrt 3*intrinsicGain u)*a := by
  by_cases hz:a=0
  · simp [hz,threeBitQ]
  have ha':0<a := lt_of_le_of_ne ha (Ne.symm hz)
  have hs:Real.sqrt (incomingEnergy ![a,a,a])=Real.sqrt 3*a := by
    rw [incomingEnergy_three,show a^2+a^2+a^2=3*a^2 by ring,
      Real.sqrt_mul (by norm_num : (0:ℝ)≤3),Real.sqrt_sq_eq_abs,abs_of_nonneg ha]
  have hm:=hu ![a,a,a]
  rw [intrinsicGain,parityCorrelation_three_balanced,abs_neg,
    abs_of_nonneg (threeBitQ_nonneg ha),hs] at hm
  have hh:=(div_le_iff₀ (by positivity : 0<Real.sqrt 3*a)).mp hm
  nlinarith only [hh]

lemma threeBit_maximizer_gain_pos (u:Fin 3→ℝ) (hu:IsIntrinsicMaximizer u) :
    0 < intrinsicGain u := by
  exact (intrinsicGain_balanced_pos 1).trans_le (hu (fun _=>balancedGain 1))

/-- Every unrestricted three-bit intrinsic maximizer has equal nonzero
absolute incoming coordinates. -/
theorem threeBit_maximizer_balanced (u:Fin 3→ℝ) (hu:IsIntrinsicMaximizer u) :
    ∃a:ℝ,0<a ∧ ∀i,|u i|=a := by
  let v:Fin 3→ℝ:=fun i=>|u i|
  have hv:IsIntrinsicMaximizer v:=IsIntrinsicMaximizer_abs_weights u hu
  let G:=intrinsicGain v
  have hG:0<G:=threeBit_maximizer_gain_pos v hv
  have hn:v≠0:=by intro h;simp only [G,h,intrinsicGain_zero,lt_self_iff_false] at hG
  let R:=Real.sqrt (incomingEnergy v)
  have hR:0<R:=Real.sqrt_pos.mpr (incomingEnergy_pos_of_ne_zero v hn)
  have hr:|parityCorrelation v 0|=G*R:=by
    dsimp [G,R]
    exact (div_mul_cancel₀ _ hR.ne').symm
  have he:v=![v 0,v 1,v 2]:=by funext i;fin_cases i <;> rfl
  have hs:=threeBit_of_scalar_bound (Real.sqrt 3*G) (v 0) (v 1) (v 2)
    (by positivity) (abs_nonneg _) (abs_nonneg _) (abs_nonneg _)
    (threeBit_scalar_cap_of_global v hv _ (abs_nonneg _))
    (threeBit_scalar_cap_of_global v hv _ (abs_nonneg _))
    (threeBit_scalar_cap_of_global v hv _ (abs_nonneg _))
  rw [←he,hr] at hs
  have hlin:G*(3*R)≤G*(Real.sqrt 3*(v 0+v 1+v 2)):=by nlinarith only [hs]
  have hlin':3*R≤Real.sqrt 3*(v 0+v 1+v 2):=(mul_le_mul_iff_right₀ hG).mp (by simpa only [mul_comm G] using hlin)
  have hsq:=pow_le_pow_left₀ (show 0≤3*R by positivity) hlin' 2
  have hrsq:R^2=incomingEnergy v:=Real.sq_sqrt (incomingEnergy_nonneg v)
  have h3:(Real.sqrt 3)^2=(3:ℝ):=Real.sq_sqrt (by norm_num)
  rw [mul_pow,mul_pow,hrsq,h3,he,incomingEnergy_three] at hsq
  change 3^2*(v 0^2+v 1^2+v 2^2)≤3*(v 0+v 1+v 2)^2 at hsq
  have h01:v 0=v 1:=by nlinarith [sq_nonneg (v 0-v 1),sq_nonneg (v 1-v 2),sq_nonneg (v 2-v 0)]
  have h12:v 1=v 2:=by nlinarith [sq_nonneg (v 0-v 1),sq_nonneg (v 1-v 2),sq_nonneg (v 2-v 0)]
  have hvpos:0<v 0:=by
    have hnon:0≤v 0:=abs_nonneg _
    by_contra hnot
    have hz:v 0=0:=le_antisymm (le_of_not_gt hnot) hnon
    apply hn
    funext i
    fin_cases i
    · exact hz
    · exact h01.symm.trans hz
    · exact h12.symm.trans (h01.symm.trans hz)
  refine ⟨v 0,hvpos,?_⟩
  intro i
  change v i=v 0
  fin_cases i
  · rfl
  · exact h01.symm
  · exact h12.symm.trans h01.symm

/-- A positive balanced gain attains the global unrestricted three-bit gain. -/
theorem exists_threeBit_balanced_maximizer :
    ∃a:ℝ,0<a ∧ IsIntrinsicMaximizer (fun _:Fin 3=>a) := by
  obtain ⟨u,hu,hmax⟩:=exists_intrinsic_maximizer 1 (by norm_num)
  obtain ⟨a,ha,heq⟩:=threeBit_maximizer_balanced u hmax
  have hv:=IsIntrinsicMaximizer_abs_weights u hmax
  have hf:(fun i=>|u i|)=(fun _:Fin 3=>a):=funext heq
  rw [hf] at hv
  exact ⟨a,ha,hv⟩

end NeuralGeneralization.OnlineLowerTanh
