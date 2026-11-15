import NeuralGeneralization.OnlineLowerTanhCodeLocalization

/-! # Quantitative unweighted off-orientation error

The sum is over the full transversal code, not only the retained subfamily.
The explicit square-root/exponential rate implies the manuscript's displayed
unweighted bound and is independent of any sharp intrinsic-parity certificate.
-/
noncomputable section
open scoped BigOperators
open MeasureTheory Set
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLowerRelu

theorem carrierCodeMass_unweighted_exponential_localization
    (c K : ℝ) (hc : 0<c) (hK : 0<K) :
    ∃M a b:ℝ,0<M ∧ 0<a ∧ 0<b ∧ ∃k₀ p₀:ℕ,1≤k₀ ∧ 3≤p₀ ∧
      ∀p r:ℕ,p₀≤p → (k₀:ℝ)*(Real.log ((p:ℝ)+2))^2≤(2*r:ℕ) →
      ∀size:Fin p→Bool→ℕ,(∀i s,2*r≤size i s) → (∀i s,Even (size i s)) →
      ∀A:Finset (Fin p→Bool),∀w:(Fin p→Bool)→ℝ,
      (∀θ∈A,0≤w θ) → (∀θ∈A,w θ≤K*(p*(2*r):ℕ)) →
      ∀bias:ℝ,∀u:Fin (carrierDimension size)→ℝ,
      0<bias^2+incomingEnergy u →
      c*Real.sqrt (bias^2+incomingEnergy u)≤carrierCodeMass size A w bias u →
      ∃θ∈A,carrierCodeMass size (Finset.univ.erase θ) (fun _=>1) bias u≤
        (Real.sqrt (4*M)*sqrtFrequencyKernelConstant)*
          Real.sqrt ((p:ℝ)*Real.exp (-(a/2)*(2*r:ℕ))) +
        ((32/Real.pi)*Real.exp (-((Real.pi/8)*b)*Real.sqrt (2*r:ℕ)))/
          Real.sqrt ((p*r:ℕ):ℝ) := by
  obtain ⟨M,h,T,μ,hM,hh,hh1,hT,hμ,hμ1,hpeak⟩ := exists_competitive_code_peak_parameters c K hc hK
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
  let k₀:=max kt (max ke kh)
  let p₀:=max 3 (max pt (max pe ph))
  have hkkt:kt≤k₀ := le_max_left _ _
  have hkke:ke≤k₀ := (le_max_left _ _).trans (le_max_right _ _)
  have hkkh:kh≤k₀ := (le_max_right _ _).trans (le_max_right _ _)
  refine ⟨M,a,b,hM,ha,hb,k₀,p₀,hkt.trans hkkt,le_max_left _ _,?_⟩
  intro p r hp hR size hsize heven A w hw0 hw bias u hpos hcomp
  have hp3:3≤p := (le_max_left _ _).trans hp
  have hpt:pt≤p := ((le_max_left _ _).trans (le_max_right _ _)).trans hp
  have hpe:pe≤p := ((le_max_left _ _).trans ((le_max_right _ _).trans (le_max_right _ _))).trans hp
  have hph:ph≤p := ((le_max_right _ _).trans ((le_max_right _ _).trans (le_max_right _ _))).trans hp
  have hthreshold (k:ℕ) (hk:k≤k₀) : (k:ℝ)*(Real.log ((p:ℝ)+2))^2≤(2*r:ℕ) :=
    (mul_le_mul_of_nonneg_right (by exact_mod_cast hk) (sq_nonneg _)).trans hR
  obtain ⟨hRmin,hnum⟩ := htail p (2*r) hpt (hthreshold kt hkkt)
  have h16:(16:ℝ)≤(2*r:ℕ) := (le_max_left _ _).trans hRmin
  have hr:1≤r := by
    have hnat:16≤2*r := by exact_mod_cast h16
    omega
  have hp2:2≤p := by omega
  have hD:6≤p*(2*r) := by nlinarith
  have hsmall := hhalf p (2*r) hph (hthreshold kh hkkh)
  obtain ⟨henergy,s,hs,θ,hθ,hθpeak⟩ := hpeak p r hp2 hr hD size hsize heven A w hw0 hw bias u hpos hcomp hsmall
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
  have hphaseE:8*s^2*incomingEnergy u/Real.pi^2-4*Real.log (μ/2)≤J*(p*(2*r):ℕ) :=
    hphase (p*(2*r):ℕ) (incomingEnergy u) s (by exact_mod_cast (show 1≤p*(2*r) by nlinarith))
      (incomingEnergy_nonneg u) henergy hs.1.le hs.2
  have hshellbase:(p:ℝ)*Real.exp (-a*(2*r:ℕ)/2)≤1/2 := by
    have hearg : -a*(2*r:ℕ)/2=-(a/2)*(2*r:ℕ) := by ring
    rw [hearg]
    exact hexp p (2*r) hpe (hthreshold ke hkke)
  have hheight:∀t∈Ioc 0 cutoff,retainedCarrierProduct size (Finset.univ.erase θ) u t≤2*E := by
    intro t ht
    have hshell:=carrier_switch_sum_bound (by omega : 0<p) (by omega : 0<2*r) size hsize
      u θ Finset.univ s t h (μ/2) J a b hs.1.le hh ht.1.le hμhalf hμhalf1 hJ ha hb.le
      hθpeak hphaseE hJa hba ht.2
    have hbin:=local_switch_sum_bound (Real.exp (-a*(2*r:ℕ)/2)) p (Real.exp_pos _).le hshellbase
    apply hshell.trans
    have hearg : -a*(2*r:ℕ)/2=-(a/2)*(2*r:ℕ) := by ring
    rw [hearg] at hbin
    simpa only [E, hearg, mul_assoc] using hbin
  have hoff := carrierCodeMass_height_tail hp2 hr size hsize heven
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

end NeuralGeneralization.OnlineLowerTanh
