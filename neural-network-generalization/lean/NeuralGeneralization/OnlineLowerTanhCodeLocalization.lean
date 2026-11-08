import NeuralGeneralization.OnlineLowerTanhCodeCompetitivePeak
import NeuralGeneralization.OnlineLowerTanhCodePhaseParameters
import NeuralGeneralization.OnlineLowerTanhCodeOffRelative
import NeuralGeneralization.OnlineLowerTanhCodeVanishing
import NeuralGeneralization.OnlineLowerLogSquareTails

/-! # Uniform localization of the actual weighted tanh transversal code

All Fourier, integral, phase, finite-shell and threshold estimates in this
module are derived for literal tanh neurons. No sharp intrinsic parity
hypothesis is needed for orientation localization itself.
-/
noncomputable section
open scoped BigOperators
open MeasureTheory Set
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLowerRelu

theorem actual_tanh_code_orientation_localization (c K:ℝ) (hc:0<c) (hK:0<K) (L:ℕ) :
    ∃k₀ p₀:ℕ,1≤k₀ ∧ 3≤p₀ ∧
      ∀p r:ℕ,p₀≤p → (k₀:ℝ)*(Real.log ((p:ℝ)+2))^2≤(2*r:ℕ) →
      ∀size:Fin p→Bool→ℕ,(∀i s,2*r≤size i s) → (∀i s,Even (size i s)) →
      ∀A:Finset (Fin p→Bool),∀w:(Fin p→Bool)→ℝ,
      (∀θ∈A,0≤w θ) → (∀θ∈A,w θ≤K*(p*(2*r):ℕ)) →
      ∀bias:ℝ,∀u:Fin (carrierDimension size)→ℝ,
      0<bias^2+incomingEnergy u →
      c*Real.sqrt (bias^2+incomingEnergy u)≤carrierCodeMass size A w bias u →
      ∃θ∈A,carrierCodeMass size (A.erase θ) w bias u≤
        ((((p*(2*r):ℕ):ℝ)^L)⁻¹)*Real.sqrt (bias^2+incomingEnergy u) := by
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
    (by positivity) (by positivity) hC.le 1 L
  obtain ⟨ke,pe,hke,hexp⟩ := exponential_small_logSquare (a/2) (1/2) (by positivity) (by norm_num)
  obtain ⟨kh,ph,hkh,hhalf⟩ := half_power_small_logSquare (μ/2) hμhalf
  let k₀:=max kt (max ke kh)
  let p₀:=max 3 (max pt (max pe ph))
  have hkkt:kt≤k₀ := le_max_left _ _
  have hkke:ke≤k₀ := (le_max_left _ _).trans (le_max_right _ _)
  have hkkh:kh≤k₀ := (le_max_right _ _).trans (le_max_right _ _)
  refine ⟨k₀,p₀,hkt.trans hkkt,le_max_left _ _,?_⟩
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
  have hheight:∀t∈Ioc 0 cutoff,retainedCarrierProduct size (A.erase θ) u t≤2*E := by
    intro t ht
    have hshell:=carrier_switch_sum_bound (by omega : 0<p) (by omega : 0<2*r) size hsize
      u θ A s t h (μ/2) J a b hs.1.le hh ht.1.le hμhalf hμhalf1 hJ ha hb.le
      hθpeak hphaseE hJa hba ht.2
    have hbin:=local_switch_sum_bound (Real.exp (-a*(2*r:ℕ)/2)) p (Real.exp_pos _).le hshellbase
    apply hshell.trans
    have hearg : -a*(2*r:ℕ)/2=-(a/2)*(2*r:ℕ) := by ring
    rw [hearg] at hbin
    simpa only [E, hearg, mul_assoc] using hbin
  have hρ:=carrierCodeMass_competitive_radius_lower hp2 hr hD size hsize heven A w c K hc hK hw0 hw bias u hpos hcomp
  have hoff:=carrierCodeMass_relative_height_tail hp2 hr size hsize heven (A.erase θ) w K B M E cutoff ρ
    hK hB hM.le hE hcut (fun τ hτ=>hw0 τ (Finset.mem_erase.mp hτ).2)
    (fun τ hτ=>hw τ (Finset.mem_erase.mp hτ).2) bias u henergy hheight hρ
  have hnum' : C*(((p*(2*r):ℕ):ℝ)*Real.sqrt E+Real.exp (-(Real.pi/8)*cutoff))≤
      ((((p*(2*r):ℕ):ℝ)^L)⁻¹) := by
    have hearg : -((Real.pi/8)*b)*Real.sqrt (2*r:ℕ)=-(Real.pi/8)*cutoff := by dsimp [cutoff];ring
    rw [hearg] at hnum
    simpa only [pow_one,E,Nat.cast_mul] using hnum
  have hmul:=mul_le_mul_of_nonneg_right hnum' (show 0≤ρ by dsimp [ρ];positivity)
  refine ⟨θ,hθ,?_⟩
  exact hoff.trans (by simpa only [C,mul_assoc,mul_comm,mul_left_comm] using hmul)

end NeuralGeneralization.OnlineLowerTanh
