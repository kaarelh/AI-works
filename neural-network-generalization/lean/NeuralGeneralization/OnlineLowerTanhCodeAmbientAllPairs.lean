import NeuralGeneralization.OnlineLowerTanhCodeAmbientPaper

/-! The orientation-localization rate for every number of rail pairs m≥2. -/
noncomputable section
open scoped BigOperators Classical
open MeasureTheory Set
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLower OnlineLowerRelu OnlineLowerGeometry ConcreteModel

lemma log_shift_le_multiple (p n : ℕ) :
    Real.log (((p+n:ℕ):ℝ)+2)≤(n+1:ℕ)*Real.log ((p:ℝ)+2) := by
  have hpow : p+n+2≤(p+2)^(n+1) := by
    induction n with
    | zero => simp
    | succ n ih =>
      rw [show n+1+1=(n+1)+1 by omega,pow_succ]
      have hpos : 0<(p+2)^(n+1) := Nat.pow_pos (by omega)
      nlinarith
  have hcast : (((p+n:ℕ):ℝ)+2)≤(((p+2:ℕ):ℝ))^(n+1) := by exact_mod_cast hpow
  have hlog := Real.log_le_log (by positivity : 0<((p+n:ℕ):ℝ)+2) hcast
  rw [Real.log_pow] at hlog
  simpa only [Nat.cast_add,Nat.cast_ofNat,Nat.cast_one] using hlog

lemma shifted_logSquare_threshold (q n p R : ℕ)
    (hR : ((q*(n+1)^2:ℕ):ℝ)*(Real.log ((p:ℝ)+2))^2≤R) :
    (q:ℝ)*(Real.log (((p+n:ℕ):ℝ)+2))^2≤R := by
  have hlog := log_shift_le_multiple p n
  have hpos : 0≤Real.log (((p+n:ℕ):ℝ)+2) := Real.log_nonneg (by have hh : (0:ℝ)≤(p+n:ℕ):=Nat.cast_nonneg (p+n);linarith)
  have hh := mul_le_mul_of_nonneg_left (pow_le_pow_left₀ hpos hlog 2) (Nat.cast_nonneg q)
  apply hh.trans
  simpa only [Nat.cast_mul,Nat.cast_pow,mul_pow,mul_assoc] using hR

theorem ambientWeightedCarrierCodeMass_unweighted_exponential_all_pairs
    (c K : ℝ) (hc : 0<c) (hK : 0<K) :
    ∃M a b:ℝ,0<M ∧ 0<a ∧ 0<b ∧ ∃k₀:ℕ,1≤k₀ ∧
      ∀p r:ℕ,2≤p → (k₀:ℝ)*(Real.log ((p:ℝ)+2))^2≤(2*r:ℕ) →
      ∀size:Fin p→Bool→ℕ,(∀i s,2*r≤size i s) → (∀i s,Even (size i s)) →
      ∀A:Finset (Fin p→Bool),∀w:(Fin p→Bool)→ℝ,
      (∀θ∈A,0≤w θ) → (∀θ∈A,w θ≤K*(p*(2*r):ℕ)) →
      ∀d k:ℕ,∀e:Fin d ≃ Fin (carrierDimension size) ⊕ Fin k,
      ∀bias:ℝ,∀u:Fin d→ℝ,
      0<bias^2+incomingEnergy u →
      c*Real.sqrt (bias^2+incomingEnergy u)≤ambientWeightedCarrierCodeMass size e A w bias u →
      ∃θ∈A,ambientWeightedCarrierCodeMass size e (Finset.univ.erase θ) (fun _=>1) bias u≤
        (Real.sqrt (4*M)*sqrtFrequencyKernelConstant)*
          Real.sqrt ((p:ℝ)*Real.exp (-(a/2)*(2*r:ℕ))) +
        ((32/Real.pi)*Real.exp (-((Real.pi/8)*b)*Real.sqrt (2*r:ℕ)))/
          Real.sqrt ((p*r:ℕ):ℝ) := by
  obtain ⟨M,h,T,μ,hM,hh,hh1,hT,hμ,hμ1,hpeak⟩ := exists_ambient_competitive_code_peak_parameters c K hc hK
  have hμhalf:0<μ/2 := by positivity
  have hμhalf1:μ/2≤1 := by linarith
  obtain ⟨J,a,b,hJ,ha,hb,hJa,hba,hphase⟩ := exists_code_phase_parameters M h T (μ/2)
    hM hh (hh1.trans hT) hμhalf hμhalf1
  let B:=codeMinimumGain c K
  have hB:0<B := codeMinimumGain_pos c K hc hK
  let C:=codeOffConstant K B M
  have hC:0<C := codeOffConstant_pos K B M hK hB hM.le
  let Rmin:ℝ:=max 16 (1/b^2)
  obtain ⟨kt,pt,hkt,htail⟩ := polynomial_tails_logSquare (a/2) ((Real.pi/8)*b) C Rmin
    (by positivity) (by positivity) hC.le 1 0
  obtain ⟨ke,pe,hke,hexp⟩ := exponential_small_logSquare (a/2) (1/2) (by positivity) (by norm_num)
  obtain ⟨kh,ph,hkh,hhalf⟩ := half_power_small_logSquare (μ/2) hμhalf
  let k₀:=max (kt*(pt+1)^2) (max (ke*(pe+1)^2) (kh*(ph+1)^2))
  have hkkt:kt*(pt+1)^2≤k₀ := le_max_left _ _
  have hkke:ke*(pe+1)^2≤k₀ := (le_max_left _ _).trans (le_max_right _ _)
  have hkkh:kh*(ph+1)^2≤k₀ := (le_max_right _ _).trans (le_max_right _ _)
  have hkpos : 1≤kt*(pt+1)^2 := by
    have hp : 1≤(pt+1)^2 := by
      have hh : 0<(pt+1)^2 := by positivity
      omega
    nlinarith
  refine ⟨M,a,b,hM,ha,hb,k₀,hkpos.trans hkkt,?_⟩
  intro p r hp2 hR size hsize heven A w hw0 hw d k e bias u hpos hcomp
  have hthreshold (q n:ℕ) (hq:q*(n+1)^2≤k₀) :
      (q:ℝ)*(Real.log (((p+n:ℕ):ℝ)+2))^2≤(2*r:ℕ) := by
    apply shifted_logSquare_threshold q n p (2*r)
    exact (mul_le_mul_of_nonneg_right (by exact_mod_cast hq) (sq_nonneg _)).trans hR
  obtain ⟨hRmin,hnum⟩ := htail (p+pt) (2*r) (by omega) (hthreshold kt pt hkkt)
  have h16:(16:ℝ)≤(2*r:ℕ) := (le_max_left _ _).trans hRmin
  have hr:1≤r := by
    have hnat:16≤2*r := by exact_mod_cast h16
    omega
  have hD:6≤p*(2*r) := by
    have hn:16≤2*r := by exact_mod_cast h16
    nlinarith
  have hsmall : (p:ℝ)*(1/2:ℝ)^(2*r)≤μ/2 := by
    have hh:=hhalf (p+ph) (2*r) (by omega) (hthreshold kh ph hkkh)
    exact (mul_le_mul_of_nonneg_right (show (p:ℝ)≤((p+ph:ℕ):ℝ) by exact_mod_cast Nat.le_add_right p ph)
      (by positivity : 0≤(1/2:ℝ)^(2*r))).trans hh
  obtain ⟨henergy,s,hs,θ,hθ,hθpeak⟩ := hpeak p r hp2 hr hD size hsize heven A w hw0 hw d k e bias u hpos hcomp hsmall
  let v := ambientActiveWeights e u
  let ρ:=Real.sqrt (bias^2+incomingEnergy u)
  let E:ℝ:=(p:ℝ)*Real.exp (-(a/2)*(2*r:ℕ))
  let cutoff:ℝ:=b*Real.sqrt (2*r:ℕ)
  have hE:0≤E := by dsimp [E];positivity
  have hcut:1≤cutoff := by
    have hR2:1/b^2≤(2*r:ℕ) := (le_max_right _ _).trans hRmin
    have hm:1≤((2*r:ℕ):ℝ)*b^2 := (div_le_iff₀ (sq_pos_of_pos hb)).mp hR2
    have hsq : cutoff^2=b^2*(2*r:ℕ) := by dsimp [cutoff];rw [mul_pow,Real.sq_sqrt (by positivity)]
    have h0:0≤cutoff := by dsimp [cutoff];positivity
    nlinarith
  have hphaseE:8*s^2*incomingEnergy v/Real.pi^2-4*Real.log (μ/2)≤J*(p*(2*r):ℕ) :=
    hphase (p*(2*r):ℕ) (incomingEnergy v) s (by exact_mod_cast (show 1≤p*(2*r) by nlinarith))
      (incomingEnergy_nonneg v) henergy hs.1.le hs.2
  have hshellbase:(p:ℝ)*Real.exp (-a*(2*r:ℕ)/2)≤1/2 := by
    have hearg : -a*(2*r:ℕ)/2=-(a/2)*(2*r:ℕ) := by ring
    rw [hearg]
    have hh:=hexp (p+pe) (2*r) (by omega) (hthreshold ke pe hkke)
    exact (mul_le_mul_of_nonneg_right (show (p:ℝ)≤((p+pe:ℕ):ℝ) by exact_mod_cast Nat.le_add_right p pe)
      (Real.exp_pos _).le).trans hh
  have hheight:∀t∈Ioc 0 cutoff,retainedCarrierProduct size (Finset.univ.erase θ) v t≤2*E := by
    intro t ht
    have hshell:=carrier_switch_sum_bound (by omega : 0<p) (by omega : 0<2*r) size hsize
      v θ Finset.univ s t h (μ/2) J a b hs.1.le hh ht.1.le hμhalf hμhalf1 hJ ha hb.le
      hθpeak hphaseE hJa hba ht.2
    have hbin:=local_switch_sum_bound (Real.exp (-a*(2*r:ℕ)/2)) p (Real.exp_pos _).le hshellbase
    apply hshell.trans
    have hearg : -a*(2*r:ℕ)/2=-(a/2)*(2*r:ℕ) := by ring
    rw [hearg] at hbin
    simpa only [E, hearg, mul_assoc] using hbin
  have hoff := ambientWeightedCarrierCodeMass_height_tail hp2 hr size e hsize heven
    (Finset.univ.erase θ) (fun _=>1) 1 (by intro; norm_num)
    (by intro; norm_num) (by norm_num) bias u M (2*E) cutoff hM.le
    (by positivity) hcut henergy hheight
  have hs:0<Real.sqrt ((p*r:ℕ):ℝ) := by positivity
  have hroot : Real.sqrt (2*M*(2*E))=Real.sqrt (4*M)*Real.sqrt E := by
    rw [show 2*M*(2*E)=(4*M)*E by ring,Real.sqrt_mul (by positivity : 0≤4*M)]
  rw [one_mul,hroot] at hoff
  refine ⟨θ,hθ,?_⟩
  have hearg : -((Real.pi/8)*b)*Real.sqrt (2*r:ℕ)=-(Real.pi/8)*cutoff := by
    dsimp [cutoff]; ring
  rw [hearg]
  apply (mul_le_mul_iff_right₀ hs).mp
  convert hoff using 1 <;> (try simp only [E]) <;> (try field_simp [hs.ne']) <;> (try ring) <;> rfl




theorem ambientWeightedCarrierCodeMass_unweighted_paper_rate_all_pairs
    (c K : ℝ) (hc : 0<c) (hK : 0<K) :
    ∃C a:ℝ,0<C ∧ 0<a ∧ ∃k₀:ℕ,1≤k₀ ∧
      ∀p r:ℕ,2≤p → (k₀:ℝ)*(Real.log ((p:ℝ)+2))^2≤(2*r:ℕ) →
      ∀size:Fin p→Bool→ℕ,(∀i s,2*r≤size i s) → (∀i s,Even (size i s)) →
      ∀A:Finset (Fin p→Bool),∀w:(Fin p→Bool)→ℝ,
      (∀θ∈A,0≤w θ) → (∀θ∈A,w θ≤K*(p*(2*r):ℕ)) →
      ∀d k:ℕ,∀e:Fin d ≃ Fin (carrierDimension size) ⊕ Fin k,
      ∀bias:ℝ,∀u:Fin d→ℝ,
      0<bias^2+incomingEnergy u →
      c*Real.sqrt (bias^2+incomingEnergy u)≤ambientWeightedCarrierCodeMass size e A w bias u →
      ∃θ∈A,ambientWeightedCarrierCodeMass size e (Finset.univ.erase θ) (fun _=>1) bias u≤
        C*(p:ℝ)*Real.exp (-a*(2*r:ℕ))+
        C*(1+Real.sqrt (2*r:ℕ))*Real.exp (-a*Real.sqrt (2*r:ℕ))/
          Real.sqrt ((p*(2*r):ℕ):ℝ) := by
  obtain ⟨M,a,b,hM,ha,hb,k₀,hk,hmain⟩ :=
    ambientWeightedCarrierCodeMass_unweighted_exponential_all_pairs c K hc hK
  let C:=1+Real.sqrt (4*M)*sqrtFrequencyKernelConstant+2*(32/Real.pi)
  let a':=min (a/4) ((Real.pi/8)*b)
  have hC:0<C := by
    have hA:=mul_nonneg (Real.sqrt_nonneg (4*M)) sqrtFrequencyKernelConstant_nonneg
    have hB:(0:ℝ)<32/Real.pi:=by positivity
    dsimp [C];linarith
  have ha':0<a':=lt_min (by positivity) (by positivity)
  refine ⟨C,a',hC,ha',k₀,hk,?_⟩
  intro p r hpp hR size hsize heven A w hw0 hw d k e bias u hpos hcomp
  have hlog:0<Real.log ((p:ℝ)+2):=Real.log_pos (by exact_mod_cast (show 1<p+2 by omega))
  have hkpos:(0:ℝ)<k₀:=by exact_mod_cast (show 0<k₀ by omega)
  have hrpos:(0:ℝ)<(2*r:ℕ):=(mul_pos hkpos (sq_pos_of_pos hlog)).trans_le hR
  have hr:1≤r:=by
    have hn:0<2*r:=by exact_mod_cast hrpos
    omega
  obtain ⟨θ,hθ,hbound⟩:=hmain p r hpp hR size hsize heven A w hw0 hw d k e bias u hpos hcomp
  exact ⟨θ,hθ,hbound.trans (exponential_rate_comparison (by omega) hr hM ha hb)⟩



end NeuralGeneralization.OnlineLowerTanh
