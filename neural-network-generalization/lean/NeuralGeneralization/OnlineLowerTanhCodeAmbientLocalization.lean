import NeuralGeneralization.OnlineLowerTanhCodeAmbientCoordinates
import NeuralGeneralization.OnlineLowerTanhCodeQuantitativeLocalization
import NeuralGeneralization.OnlineLowerTanhCodeLocalSharp

/-! # Quantitative code localization in arbitrary ambient dimension

Conditioning removes unused coordinates while keeping the same physical code
product. A single retained peak and hence a single orientation is selected
before applying the off-orientation bounds.
-/
noncomputable section
open scoped BigOperators Classical
open MeasureTheory Set
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLower OnlineLowerRelu OnlineLowerGeometry ConcreteModel

def ambientWeightedCarrierCodeMass {p d k : ℕ} (size : Fin p→Bool→ℕ)
    (e : Fin d ≃ Fin (carrierDimension size) ⊕ Fin k)
    (A : Finset (Fin p→Bool)) (w : (Fin p→Bool)→ℝ) (bias : ℝ) (u : Fin d→ℝ) : ℝ :=
  ∑θ∈A,w θ*|walshCoefficients (fun x=>Real.tanh (bias+incomingLinear u x))
    (ambientSupport e (carrierTransversal size θ))|

lemma ambientWeightedCarrierCodeMass_balanced {p d k : ℕ} (size : Fin p→Bool→ℕ)
    (e : Fin d ≃ Fin (carrierDimension size) ⊕ Fin k)
    (A : Finset (Fin p→Bool)) (bias : ℝ) (u : Fin d→ℝ) :
    ambientWeightedCarrierCodeMass size e A (carrierBalancedCost size) bias u =
      ambientCarrierCodeMass size e A bias u := rfl

lemma ambient_weighted_codeMass_le_conditioned {p d k : ℕ} (size : Fin p→Bool→ℕ)
    (e : Fin d ≃ Fin (carrierDimension size) ⊕ Fin k)
    (A : Finset (Fin p→Bool)) (w : (Fin p→Bool)→ℝ) (hw : ∀θ∈A,0≤w θ)
    (b : ℝ) (u : Fin d→ℝ) :
    ambientWeightedCarrierCodeMass size e A w b u ≤ finiteAverage (fun y:Cube k=>
      carrierCodeMass size A w
        (b+incomingLinear (ambientExtraWeights e u) y) (ambientActiveWeights e u)) := by
  unfold ambientWeightedCarrierCodeMass carrierCodeMass
  simp_rw [ambient_coefficient_conditioned]
  have ha (f : Cube k→ℝ) : |finiteAverage f|≤finiteAverage (fun y=>|f y|) := by
    unfold finiteAverage
    rw [abs_div,abs_of_nonneg (by positivity : 0≤(Fintype.card (Cube k):ℝ))]
    exact div_le_div_of_nonneg_right (Finset.abs_sum_le_sum_abs _ _) (by positivity)
  have hh:=Finset.sum_le_sum (s:=A) (fun θ hθ=>mul_le_mul_of_nonneg_left
    (ha (fun y=>walshCoefficients (fun z=>Real.tanh
      ((b+incomingLinear (ambientExtraWeights e u) y)+incomingLinear (ambientActiveWeights e u) z))
      (carrierTransversal size θ))) (hw θ hθ))
  refine hh.trans_eq ?_
  simp_rw [←finiteAverage_mul_left]
  unfold finiteAverage
  simp only [Finset.sum_div]
  rw [Finset.sum_comm]

/-- Every bound independent of the affine bias transfers with its literal
constant to arbitrary unused coordinates and arbitrary coordinate placement. -/
lemma ambient_weighted_codeMass_lift_bound {p d k : ℕ} (size : Fin p→Bool→ℕ)
    (e : Fin d ≃ Fin (carrierDimension size) ⊕ Fin k)
    (A : Finset (Fin p→Bool)) (w : (Fin p→Bool)→ℝ) (hw : ∀θ∈A,0≤w θ)
    (a B : ℝ) (ha : 0≤a) (b : ℝ) (u : Fin d→ℝ)
    (hbound : ∀bias:ℝ,a*carrierCodeMass size A w bias (ambientActiveWeights e u)≤B) :
    a*ambientWeightedCarrierCodeMass size e A w b u≤B := by
  have hfirst := mul_le_mul_of_nonneg_left
    (ambient_weighted_codeMass_le_conditioned size e A w hw b u) ha
  rw [←finiteAverage_mul_left] at hfirst
  have hsecond := finiteAverage_mono
    (fun y:Cube k=>a*carrierCodeMass size A w
      (b+incomingLinear (ambientExtraWeights e u) y) (ambientActiveWeights e u))
    (fun _=>B) (fun y=>hbound _)
  rw [finiteAverage_const] at hsecond
  exact hfirst.trans hsecond

lemma ambient_active_energy_le {d n k : ℕ} (e : Fin d ≃ Fin n ⊕ Fin k)
    (u : Fin d→ℝ) : incomingEnergy (ambientActiveWeights e u) ≤ incomingEnergy u := by
  rw [ambient_energy_split e]
  exact le_add_of_nonneg_right (incomingEnergy_nonneg _)

theorem ambientWeightedCarrierCodeMass_le_retained_envelope {p d k : ℕ}
    (size : Fin p→Bool→ℕ) (e : Fin d ≃ Fin (carrierDimension size) ⊕ Fin k)
    (heven : ∀i s,Even (size i s)) (A : Finset (Fin p→Bool))
    (w : (Fin p→Bool)→ℝ) (W : ℝ) (hw0 : ∀θ∈A,0≤w θ) (hw : ∀θ∈A,w θ≤W)
    (bias : ℝ) (u : Fin d→ℝ) :
    ambientWeightedCarrierCodeMass size e A w bias u ≤ W*(∫t:ℝ in Ioi 0,
      retainedCarrierProduct size A (ambientActiveWeights e u) t/Real.sinh (Real.pi*t/2)) := by
  simpa only [one_mul] using ambient_weighted_codeMass_lift_bound size e A w hw0 1 _
    (by norm_num) bias u (fun b=>by simpa only [one_mul] using
      carrierCodeMass_le_retained_envelope size heven A w W hw0 hw b (ambientActiveWeights e u))

theorem ambientWeightedCarrierCodeMass_scale_bounds {p r d k : ℕ}
    (hp : 2≤p) (hr : 1≤r) (hD : 6≤p*(2*r))
    (size : Fin p→Bool→ℕ) (e : Fin d ≃ Fin (carrierDimension size) ⊕ Fin k)
    (hR : ∀i s,2*r≤size i s) (heven : ∀i s,Even (size i s))
    (A : Finset (Fin p→Bool)) (w : (Fin p→Bool)→ℝ) (W : ℝ)
    (hw0 : ∀θ∈A,0≤w θ) (hw : ∀θ∈A,w θ≤W) (hW : 0≤W)
    (bias : ℝ) (u : Fin d→ℝ) (z : ℝ) (hz : 0≤z)
    (he : incomingEnergy (ambientActiveWeights e u)≤(p*(2*r):ℕ)*z^2) :
    Real.sqrt ((p*r:ℕ):ℝ)*ambientWeightedCarrierCodeMass size e A w bias u ≤ W*(65536/Real.pi^3)*z^3 ∧
    Real.sqrt ((p*r:ℕ):ℝ)*ambientWeightedCarrierCodeMass size e A w bias u ≤
      W*(4*Real.pi*codeCschMomentConstant)*Real.sqrt (2*z) := by
  constructor
  · exact ambient_weighted_codeMass_lift_bound size e A w hw0 _ _ (Real.sqrt_nonneg _) bias u
      (fun b=>(carrierCodeMass_scale_bounds hp hr hD size hR heven A w W hw0 hw hW
        b (ambientActiveWeights e u) z hz he).1)
  · exact ambient_weighted_codeMass_lift_bound size e A w hw0 _ _ (Real.sqrt_nonneg _) bias u
      (fun b=>(carrierCodeMass_scale_bounds hp hr hD size hR heven A w W hw0 hw hW
        b (ambientActiveWeights e u) z hz he).2)

theorem ambientWeightedCarrierCodeMass_height_tail {p r d k:ℕ} (hp:2≤p) (hr:1≤r)
    (size:Fin p→Bool→ℕ) (e : Fin d ≃ Fin (carrierDimension size) ⊕ Fin k)
    (hR:∀i s,2*r≤size i s) (heven:∀i s,Even (size i s))
    (A:Finset (Fin p→Bool)) (w:(Fin p→Bool)→ℝ) (W:ℝ)
    (hw0:∀θ∈A,0≤w θ) (hw:∀θ∈A,w θ≤W) (hW:0≤W)
    (bias:ℝ) (u:Fin d→ℝ)
    (M E T:ℝ) (hM:0≤M) (hE:0≤E) (hT:1≤T)
    (henergy:incomingEnergy (ambientActiveWeights e u)≤(p*(2*r):ℕ)*M^2)
    (hheight:∀t∈Ioc 0 T,retainedCarrierProduct size A (ambientActiveWeights e u) t≤E) :
    Real.sqrt ((p*r:ℕ):ℝ)*ambientWeightedCarrierCodeMass size e A w bias u ≤
      W*(Real.sqrt ((p*r:ℕ):ℝ)*Real.sqrt (2*M*E)*sqrtFrequencyKernelConstant+
        (32/Real.pi)*Real.exp (-(Real.pi/8)*T)) := by
  exact ambient_weighted_codeMass_lift_bound size e A w hw0 _ _ (Real.sqrt_nonneg _) bias u
    (fun b=>carrierCodeMass_height_tail hp hr size hR heven A w W hw0 hw hW
      b (ambientActiveWeights e u) M E T hM hE hT henergy hheight)

theorem ambientWeightedCarrierCodeMass_competitive_scale {p r d k : ℕ} (hp : 2≤p) (hr : 1≤r) (hD : 6≤p*(2*r))
    (size : Fin p→Bool→ℕ) (e : Fin d ≃ Fin (carrierDimension size) ⊕ Fin k) (hR : ∀i s,2*r≤size i s) (heven : ∀i s,Even (size i s))
    (A : Finset (Fin p→Bool)) (w : (Fin p→Bool)→ℝ) (c K : ℝ) (hc:0<c) (hK:0<K)
    (hw0 : ∀θ∈A,0≤w θ) (hw : ∀θ∈A,w θ≤K*(p*(2*r):ℕ))
    (bias : ℝ) (u : Fin d→ℝ)
    (hpos : 0<bias^2+incomingEnergy u)
    (hcomp : c*Real.sqrt (bias^2+incomingEnergy u)≤ambientWeightedCarrierCodeMass size e A w bias u) :
    let z := Real.sqrt (bias^2+incomingEnergy u)/Real.sqrt ((p*r:ℕ):ℝ)
    c≤2*K*codeLowerScaleConstant*z^2 ∧
      z≤8*K^2*codeUpperScaleConstant^2/c^2 := by
  let s : ℝ := Real.sqrt ((p*r:ℕ):ℝ)
  let ρ : ℝ := Real.sqrt (bias^2+incomingEnergy u)
  let z : ℝ := ρ/s
  have hs : 0<s := by dsimp [s];positivity
  have hρ : 0<ρ := Real.sqrt_pos.mpr hpos
  have hz : 0<z := div_pos hρ hs
  have hs2 : s^2=(p*r:ℕ) := Real.sq_sqrt (by positivity)
  have hρ2 : ρ^2=bias^2+incomingEnergy u := Real.sq_sqrt hpos.le
  have hzs : z*s=ρ := div_mul_cancel₀ _ hs.ne'
  have hdeq : ((p*(2*r):ℕ):ℝ)=2*s^2 := by rw [hs2];push_cast;ring
  have henergy : incomingEnergy u≤(p*(2*r):ℕ)*z^2 := by
    rw [hdeq]
    have he : (z*s)^2=ρ^2 := congrArg (fun x:ℝ=>x^2) hzs
    nlinarith [sq_nonneg bias,sq_nonneg ρ]
  have hb := ambientWeightedCarrierCodeMass_scale_bounds hp hr hD size e hR heven A w
    (K*(p*(2*r):ℕ)) hw0 hw (by positivity) bias u z hz.le ((ambient_active_energy_le e u).trans henergy)
  rw [hdeq] at hb
  have hc' : c*z*s≤ambientWeightedCarrierCodeMass size e A w bias u := by
    rw [mul_assoc,hzs]
    exact hcomp
  have hlow : s*ambientWeightedCarrierCodeMass size e A w bias u≤2*K*s^2*codeLowerScaleConstant*z^3 := by
    simpa only [s,hdeq,codeLowerScaleConstant,mul_assoc,mul_comm,mul_left_comm] using hb.1
  have hhigh : s*ambientWeightedCarrierCodeMass size e A w bias u≤2*K*s^2*codeUpperScaleConstant*Real.sqrt (2*z) := by
    simpa only [s,hdeq,codeUpperScaleConstant,mul_assoc,mul_comm,mul_left_comm] using hb.2
  exact gain_bounds_of_mass_bounds c K _ _ s z _ hc hK codeLowerScaleConstant_pos
    codeUpperScaleConstant_pos hs hz hc' hlow hhigh


theorem exists_ambient_competitive_code_peak_parameters (c K : ℝ) (hc:0<c) (hK:0<K) :
    ∃M h T μ : ℝ,0<M ∧ 0<h ∧ h≤1 ∧ 1≤T ∧ 0<μ ∧ μ≤1/4 ∧
      ∀p r:ℕ,2≤p → 1≤r → 6≤p*(2*r) →
      ∀size:Fin p→Bool→ℕ,∀hR:∀i s,2*r≤size i s,
      (∀i s,Even (size i s)) →
      ∀A:Finset (Fin p→Bool),∀w:(Fin p→Bool)→ℝ,
      (∀θ∈A,0≤w θ) → (∀θ∈A,w θ≤K*(p*(2*r):ℕ)) →
      ∀d k:ℕ,∀e:Fin d ≃ Fin (carrierDimension size) ⊕ Fin k,
      ∀bias:ℝ,∀u:Fin d→ℝ,
      0<bias^2+incomingEnergy u →
      c*Real.sqrt (bias^2+incomingEnergy u)≤ambientWeightedCarrierCodeMass size e A w bias u →
      (p:ℝ)*(1/2:ℝ)^(2*r)≤μ/2 →
      incomingEnergy (ambientActiveWeights e u)≤(p*(2*r):ℕ)*M^2 ∧
        ∃t∈Ioc h T,∃θ∈A,μ/2≤|trigProduct (carrierTransversal size θ) (fun j=>t*ambientActiveWeights e u j)| := by
  let B : ℝ := Real.sqrt (c/(2*K*codeLowerScaleConstant))
  let M : ℝ := 8*K^2*codeUpperScaleConstant^2/c^2
  let β : ℝ := c*B/(2*K)
  have hB : 0<B := Real.sqrt_pos.mpr (by positivity [codeLowerScaleConstant_pos])
  have hM : 0<M := by dsimp [M];positivity [codeUpperScaleConstant_pos]
  have hβ : 0<β := by dsimp [β];positivity
  obtain ⟨h,T,μ,hh,hh1,hT,hμ,hμ1,hres⟩ := exists_physical_retained_peak_parameters M β hM hβ
  refine ⟨M,h,T,μ,hM,hh,hh1,hT,hμ,hμ1,?_⟩
  intro p r hp hr hD size hR heven A w hw0 hw d k e bias u hpos hcomp hsmall
  let s : ℝ := Real.sqrt ((p*r:ℕ):ℝ)
  let ρ : ℝ := Real.sqrt (bias^2+incomingEnergy u)
  let z : ℝ := ρ/s
  have hs : 0<s := by dsimp [s];positivity
  have hρ : 0<ρ := Real.sqrt_pos.mpr hpos
  have hz : 0<z := div_pos hρ hs
  have hs2 : s^2=(p*r:ℕ) := Real.sq_sqrt (by positivity)
  have hρ2 : ρ^2=bias^2+incomingEnergy u := Real.sq_sqrt hpos.le
  have hzs : z*s=ρ := div_mul_cancel₀ _ hs.ne'
  have hdeq : ((p*(2*r):ℕ):ℝ)=2*s^2 := by rw [hs2];push_cast;ring
  have hbounds := ambientWeightedCarrierCodeMass_competitive_scale hp hr hD size e hR heven A w c K hc hK hw0 hw bias u hpos hcomp
  change c≤2*K*codeLowerScaleConstant*z^2 ∧ z≤M at hbounds
  have hBz : B≤z := by
    have hh : c/(2*K*codeLowerScaleConstant)≤z^2 :=
      (div_le_iff₀ (by positivity [codeLowerScaleConstant_pos] : 0<2*K*codeLowerScaleConstant)).mpr (by nlinarith only [hbounds.1])
    have hroot := Real.sqrt_le_sqrt hh
    simpa only [B,Real.sqrt_sq hz.le] using hroot
  have henergy : incomingEnergy u≤(p*(2*r):ℕ)*M^2 := by
    rw [hdeq]
    have he := congrArg (fun x:ℝ=>x^2) hzs
    have hpow := pow_le_pow_left₀ hz.le hbounds.2 2
    have hscaled := mul_le_mul_of_nonneg_right hpow (sq_nonneg s)
    nlinarith [sq_nonneg bias,sq_nonneg (M*s)]
  have henv := ambientWeightedCarrierCodeMass_le_retained_envelope size e heven A w (K*(p*(2*r):ℕ)) hw0 hw bias u
  have hmass : β≤Real.sqrt ((p*r:ℕ):ℝ)*(∫t:ℝ in Ioi 0,
      retainedCarrierProduct size A (ambientActiveWeights e u) t/Real.sinh (Real.pi*t/2)) := by
    let I : ℝ := ∫t:ℝ in Ioi 0,retainedCarrierProduct size A (ambientActiveWeights e u) t/Real.sinh (Real.pi*t/2)
    have hbq : c*z*s≤K*(2*s^2)*I := by
      have hh := hcomp.trans henv
      change c*ρ≤K*(p*(2*r):ℕ)*I at hh
      rw [hdeq,←hzs] at hh
      nlinarith only [hh]
    have hzI : c*z≤2*K*(s*I) := by
      apply (mul_le_mul_iff_left₀ hs).mp
      nlinarith only [hbq]
    have hBI := (mul_le_mul_of_nonneg_left hBz hc.le).trans hzI
    exact (div_le_iff₀ (by positivity : 0<2*K)).mpr (by nlinarith only [hBI])
  have hactive := (ambient_active_energy_le e u).trans henergy
  exact ⟨hactive,hres p r hp hr hD size hR heven A (ambientActiveWeights e u) hactive hmass hsmall⟩

theorem ambientWeightedCarrierCodeMass_unweighted_exponential_localization
    (c K : ℝ) (hc : 0<c) (hK : 0<K) :
    ∃M a b:ℝ,0<M ∧ 0<a ∧ 0<b ∧ ∃k₀ p₀:ℕ,1≤k₀ ∧ 3≤p₀ ∧
      ∀p r:ℕ,p₀≤p → (k₀:ℝ)*(Real.log ((p:ℝ)+2))^2≤(2*r:ℕ) →
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
  let k₀:=max kt (max ke kh)
  let p₀:=max 3 (max pt (max pe ph))
  have hkkt:kt≤k₀ := le_max_left _ _
  have hkke:ke≤k₀ := (le_max_left _ _).trans (le_max_right _ _)
  have hkkh:kh≤k₀ := (le_max_right _ _).trans (le_max_right _ _)
  refine ⟨M,a,b,hM,ha,hb,k₀,p₀,hkt.trans hkkt,le_max_left _ _,?_⟩
  intro p r hp hR size hsize heven A w hw0 hw d k e bias u hpos hcomp
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
    exact hexp p (2*r) hpe (hthreshold ke hkke)
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



theorem ambientWeightedCarrierCodeMass_competitive_radius_lower {p r d k : ℕ} (hp : 2≤p) (hr : 1≤r) (hD : 6≤p*(2*r))
    (size : Fin p→Bool→ℕ) (e : Fin d ≃ Fin (carrierDimension size) ⊕ Fin k) (hR : ∀i s,2*r≤size i s) (heven : ∀i s,Even (size i s))
    (A : Finset (Fin p→Bool)) (w : (Fin p→Bool)→ℝ) (c K : ℝ) (hc:0<c) (hK:0<K)
    (hw0 : ∀θ∈A,0≤w θ) (hw : ∀θ∈A,w θ≤K*(p*(2*r):ℕ))
    (bias : ℝ) (u : Fin d→ℝ)
    (hpos : 0<bias^2+incomingEnergy u)
    (hcomp : c*Real.sqrt (bias^2+incomingEnergy u)≤ambientWeightedCarrierCodeMass size e A w bias u) :
    codeMinimumGain c K*Real.sqrt ((p*r:ℕ):ℝ)≤Real.sqrt (bias^2+incomingEnergy u) := by
  let z := Real.sqrt (bias^2+incomingEnergy u)/Real.sqrt ((p*r:ℕ):ℝ)
  have hs:0<Real.sqrt ((p*r:ℕ):ℝ) := by positivity
  have hz:0≤z := by dsimp [z];positivity
  have hbounds := ambientWeightedCarrierCodeMass_competitive_scale hp hr hD size e hR heven A w c K hc hK hw0 hw bias u hpos hcomp
  have hsq : c/(2*K*codeLowerScaleConstant)≤z^2 :=
    (div_le_iff₀ (by positivity [codeLowerScaleConstant_pos] : 0<2*K*codeLowerScaleConstant)).mpr (by nlinarith only [hbounds.1])
  have hroot := Real.sqrt_le_sqrt hsq
  rw [Real.sqrt_sq hz] at hroot
  exact (le_div_iff₀ hs).mp hroot

theorem ambientWeightedCarrierCodeMass_relative_height_tail {p r d k:ℕ} (hp:2≤p) (hr:1≤r)
    (size:Fin p→Bool→ℕ) (e : Fin d ≃ Fin (carrierDimension size) ⊕ Fin k)
    (hR:∀i s,2*r≤size i s) (heven:∀i s,Even (size i s))
    (A:Finset (Fin p→Bool)) (w:(Fin p→Bool)→ℝ) (K B M E T ρ:ℝ)
    (hK:0<K) (hB:0<B) (hM:0≤M) (hE:0≤E) (hT:1≤T)
    (hw0:∀θ∈A,0≤w θ) (hw:∀θ∈A,w θ≤K*(p*(2*r):ℕ))
    (bias:ℝ) (u:Fin d→ℝ)
    (henergy:incomingEnergy (ambientActiveWeights e u)≤(p*(2*r):ℕ)*M^2)
    (hheight:∀t∈Ioc 0 T,retainedCarrierProduct size A (ambientActiveWeights e u) t≤2*E)
    (hρ:B*Real.sqrt ((p*r:ℕ):ℝ)≤ρ) :
    ambientWeightedCarrierCodeMass size e A w bias u≤codeOffConstant K B M*ρ*
      (((p*(2*r):ℕ):ℝ)*Real.sqrt E+Real.exp (-(Real.pi/8)*T)) := by
  simpa only [one_mul] using ambient_weighted_codeMass_lift_bound size e A w hw0 1 _
    (by norm_num) bias u (fun b=>by simpa only [one_mul] using
      (carrierCodeMass_relative_height_tail hp hr size hR heven A w K B M E T ρ
        hK hB hM hE hT hw0 hw b (ambientActiveWeights e u) henergy hheight hρ))

theorem actual_tanh_ambient_code_orientation_localization (c K:ℝ) (hc:0<c) (hK:0<K) (L:ℕ) :
    ∃k₀ p₀:ℕ,1≤k₀ ∧ 3≤p₀ ∧
      ∀p r:ℕ,p₀≤p → (k₀:ℝ)*(Real.log ((p:ℝ)+2))^2≤(2*r:ℕ) →
      ∀size:Fin p→Bool→ℕ,(∀i s,2*r≤size i s) → (∀i s,Even (size i s)) →
      ∀A:Finset (Fin p→Bool),∀w:(Fin p→Bool)→ℝ,
      (∀θ∈A,0≤w θ) → (∀θ∈A,w θ≤K*(p*(2*r):ℕ)) →
      ∀d k:ℕ,∀e:Fin d ≃ Fin (carrierDimension size) ⊕ Fin k,
      ∀bias:ℝ,∀u:Fin d→ℝ,
      0<bias^2+incomingEnergy u →
      c*Real.sqrt (bias^2+incomingEnergy u)≤ambientWeightedCarrierCodeMass size e A w bias u →
      ∃θ∈A,ambientWeightedCarrierCodeMass size e (A.erase θ) w bias u≤
        ((((p*(2*r):ℕ):ℝ)^L)⁻¹)*Real.sqrt (bias^2+incomingEnergy u) := by
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
    (by positivity) (by positivity) hC.le 1 L
  obtain ⟨ke,pe,hke,hexp⟩ := exponential_small_logSquare (a/2) (1/2) (by positivity) (by norm_num)
  obtain ⟨kh,ph,hkh,hhalf⟩ := half_power_small_logSquare (μ/2) hμhalf
  let k₀:=max kt (max ke kh)
  let p₀:=max 3 (max pt (max pe ph))
  have hkkt:kt≤k₀ := le_max_left _ _
  have hkke:ke≤k₀ := (le_max_left _ _).trans (le_max_right _ _)
  have hkkh:kh≤k₀ := (le_max_right _ _).trans (le_max_right _ _)
  refine ⟨k₀,p₀,hkt.trans hkkt,le_max_left _ _,?_⟩
  intro p r hp hR size hsize heven A w hw0 hw d k e bias u hpos hcomp
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
    exact hexp p (2*r) hpe (hthreshold ke hkke)
  have hheight:∀t∈Ioc 0 cutoff,retainedCarrierProduct size (A.erase θ) v t≤2*E := by
    intro t ht
    have hshell:=carrier_switch_sum_bound (by omega : 0<p) (by omega : 0<2*r) size hsize
      v θ A s t h (μ/2) J a b hs.1.le hh ht.1.le hμhalf hμhalf1 hJ ha hb.le
      hθpeak hphaseE hJa hba ht.2
    have hbin:=local_switch_sum_bound (Real.exp (-a*(2*r:ℕ)/2)) p (Real.exp_pos _).le hshellbase
    apply hshell.trans
    have hearg : -a*(2*r:ℕ)/2=-(a/2)*(2*r:ℕ) := by ring
    rw [hearg] at hbin
    simpa only [E, hearg, mul_assoc] using hbin
  have hρ:=ambientWeightedCarrierCodeMass_competitive_radius_lower hp2 hr hD size e hsize heven A w c K hc hK hw0 hw bias u hpos hcomp
  have hoff:=ambientWeightedCarrierCodeMass_relative_height_tail hp2 hr size e hsize heven (A.erase θ) w K B M E cutoff ρ
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



/-- The manuscript's finite local-vanishing coefficient on arbitrary ambient
cubes. Only the actual outside energy is assumed small. -/
theorem ambient_tanh_local_offmass_paper {p R d k : ℕ} (hp : 1≤p) (hR : 2≤R)
    (size : Fin p → Bool → ℕ) (e : Fin d ≃ Fin (carrierDimension size) ⊕ Fin k)
    (hsize : ∀i b,R≤size i b) (s : Fin p→Bool) (J : Finset (Fin p→Bool))
    (weight : (Fin p→Bool)→ℝ) (W : ℝ)
    (hw : ∀t∈J,0≤weight t) (hW : ∀t∈J,weight t≤W) (hW0 : 0≤W)
    (u : Fin d→ℝ) (b τ : ℝ)
    (hτ : 0≤τ) (hτρ : τ≤(((p*R:ℕ):ℝ)^2)⁻¹)
    (henergy : (∑i∈(ambientSupport e (carrierTransversal size s))ᶜ,u i^2)≤τ^2) :
    ambientWeightedCarrierCodeMass size e (J.erase s) weight b u ≤
      2*W*(p:ℝ)*((p*R:ℕ):ℝ)^4*
        (4*Real.sqrt ((p*R:ℕ):ℝ)/(Real.pi*((p*R:ℕ):ℝ)^2))^R*τ^2 := by
  have hactive : (∑i∈(carrierTransversal size s)ᶜ,(ambientActiveWeights e u i)^2)≤τ^2 := by
    rw [ambient_outside_energy] at henergy
    linarith [incomingEnergy_nonneg (ambientExtraWeights e u)]
  simpa only [one_mul] using ambient_weighted_codeMass_lift_bound size e (J.erase s) weight
    (fun t ht=>hw t (Finset.mem_erase.mp ht).2) 1 _ (by norm_num) b u (fun b'=>by
      simpa only [one_mul,carrierCodeMass] using
        tanh_local_offmass_paper hp hR size hsize s J weight W hw hW hW0
          (ambientActiveWeights e u) b' τ hτ hτρ hactive)

end NeuralGeneralization.OnlineLowerTanh
