import NeuralGeneralization.BatchTwoContinuousDepthCriticalControlIndependent
import NeuralGeneralization.BatchTwoContinuousDepthCriticalControlMean
import NeuralGeneralization.BatchTwoContinuousDepthCriticalSeedRows

/-! Deterministic dilution of finitely many Gaussian shifts. Integer blocks
avoid an auxiliary mixture measure and give a literal width-N parameter event. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
variable {R I:Type*} [Fintype R] [Fintype I]

def dilutionEquiv (N q:ℕ) (hq:Fintype.card R*q≤N):
    Fin N≃(R×Fin q)⊕Fin (N-Fintype.card R*q):=
  Fintype.equivOfCardEq (by simp only [Fintype.card_fin,Fintype.card_sum,Fintype.card_prod];omega)

def dilutedControl (N q:ℕ) (hq:Fintype.card R*q≤N) (c:R→I→ℝ):Fin N→I→ℝ:=
  fun i=>Sum.elim (fun p:R×Fin q=>c p.1) (fun _=>0) (dilutionEquiv N q hq i)

theorem dilutedControl_sum (N q:ℕ) (hq:Fintype.card R*q≤N) (c:R→I→ℝ)
    (g:(I→ℝ)→ℝ) (hg:g 0=0):
    (∑i,g (dilutedControl N q hq c i))=(q:ℝ)*∑a,g (c a):=by
  have he: (∑i,g (dilutedControl N q hq c i))=
      ∑p:(R×Fin q)⊕Fin (N-Fintype.card R*q),
        g (Sum.elim (fun p:R×Fin q=>c p.1) (fun _=>0) p):=
    by
      simpa only [dilutedControl] using (dilutionEquiv N q hq).sum_comp
        (fun p:(R×Fin q)⊕Fin (N-Fintype.card R*q)=>
          g (Sum.elim (fun p:R×Fin q=>c p.1) (fun _=>0) p))
  rw [he,Fintype.sum_sum_type,Fintype.sum_prod_type]
  simp only [Sum.elim_inl,Sum.elim_inr,hg,Finset.sum_const_zero,add_zero,
    Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul,←Finset.mul_sum]

theorem dilutedControl_energy (N q:ℕ) (hq:Fintype.card R*q≤N) (c:R→I→ℝ)
    {D:ℝ} (hc:∀a,∑i,(c a i)^2≤D):
    (∑j,∑i,(dilutedControl N q hq c j i)^2)≤(q:ℝ)*(Fintype.card R:ℝ)*D:=by
  rw [dilutedControl_sum N q hq c (fun z=>∑i,z i^2) (by simp)]
  have hh:=Finset.sum_le_sum (fun a (_:a∈Finset.univ)=>hc a)
  simp only [Finset.sum_const,Finset.card_univ,nsmul_eq_mul] at hh
  exact (mul_le_mul_of_nonneg_left hh (Nat.cast_nonneg _)).trans_eq (by ring)

theorem integer_dilution_upper (m P N:ℕ) (hP:0<P):m*(N/(m*P))≤N:=by
  have hh:=Nat.div_mul_le_self N (m*P)
  have hP1:1≤P:=hP
  nlinarith

theorem integer_dilution_lower {m P N:ℕ} (hm:0<m) (hP:0<P) (hN:2*(m*P)≤N):
    (1:ℝ)/(2*(P:ℝ))≤((N/(m*P):ℕ):ℝ)*(m:ℝ)/(N:ℝ):=by
  have hp:0<m*P:=Nat.mul_pos hm hP
  have hple:m*P≤N:=by omega
  have hq:0<N/(m*P):=Nat.div_pos hple hp
  have hr:=Nat.mod_lt N hp
  have hd:=Nat.mod_add_div N (m*P)
  have hn:0<N:=by omega
  have hh:N≤2*(m*P)*(N/(m*P)):=by nlinarith
  have hhR:(N:ℝ)≤2*(m:ℝ)*(P:ℝ)*((N/(m*P):ℕ):ℝ):=by exact_mod_cast (show N≤2*m*P*(N/(m*P)) by nlinarith [hh])
  apply (div_le_div_iff₀ (by positivity : (0:ℝ)<2*(P:ℝ)) (by exact_mod_cast hn)).mpr
  nlinarith

theorem dilutedControl_unit_budget {P N:ℕ} (hP:0<P) (c:R→I→ℝ)
    {D:ℝ} (hD:0≤D) (hc:∀a,∑i,(c a i)^2≤D) (hDP:D≤(P:ℝ)):
    (∑j,∑i,(dilutedControl N (N/(Fintype.card R*P))
      (integer_dilution_upper (Fintype.card R) P N hP) c j i)^2)≤(N:ℝ):=by
  have hh:=dilutedControl_energy N (N/(Fintype.card R*P))
    (integer_dilution_upper (Fintype.card R) P N hP) c hc
  have hb:((N/(Fintype.card R*P):ℕ):ℝ)*(Fintype.card R:ℝ)*(P:ℝ)≤(N:ℝ):=by
    exact_mod_cast (show N/(Fintype.card R*P)*Fintype.card R*P≤N by
      simpa only [mul_assoc] using Nat.div_mul_le_self N (Fintype.card R*P))
  exact hh.trans ((mul_le_mul_of_nonneg_left hDP (by positivity)).trans hb)

end NeuralGeneralization.BatchTwoContinuousDepthCritical
