import NeuralGeneralization.OnlineLowerTanhCodeGain

/-! # Actual competitiveness forces one retained compact resonance -/
noncomputable section
open scoped BigOperators
open MeasureTheory Set
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLowerRelu

theorem exists_competitive_code_peak_parameters (c K : ℝ) (hc:0<c) (hK:0<K) :
    ∃M h T μ : ℝ,0<M ∧ 0<h ∧ h≤1 ∧ 1≤T ∧ 0<μ ∧ μ≤1/4 ∧
      ∀p r:ℕ,2≤p → 1≤r → 6≤p*(2*r) →
      ∀size:Fin p→Bool→ℕ,∀hR:∀i s,2*r≤size i s,
      (∀i s,Even (size i s)) →
      ∀A:Finset (Fin p→Bool),∀w:(Fin p→Bool)→ℝ,
      (∀θ∈A,0≤w θ) → (∀θ∈A,w θ≤K*(p*(2*r):ℕ)) →
      ∀bias:ℝ,∀u:Fin (carrierDimension size)→ℝ,
      0<bias^2+incomingEnergy u →
      c*Real.sqrt (bias^2+incomingEnergy u)≤carrierCodeMass size A w bias u →
      (p:ℝ)*(1/2:ℝ)^(2*r)≤μ/2 →
      incomingEnergy u≤(p*(2*r):ℕ)*M^2 ∧
        ∃t∈Ioc h T,∃θ∈A,μ/2≤|trigProduct (carrierTransversal size θ) (fun j=>t*u j)| := by
  let B : ℝ := Real.sqrt (c/(2*K*codeLowerScaleConstant))
  let M : ℝ := 8*K^2*codeUpperScaleConstant^2/c^2
  let β : ℝ := c*B/(2*K)
  have hB : 0<B := Real.sqrt_pos.mpr (by positivity [codeLowerScaleConstant_pos])
  have hM : 0<M := by dsimp [M];positivity [codeUpperScaleConstant_pos]
  have hβ : 0<β := by dsimp [β];positivity
  obtain ⟨h,T,μ,hh,hh1,hT,hμ,hμ1,hres⟩ := exists_physical_retained_peak_parameters M β hM hβ
  refine ⟨M,h,T,μ,hM,hh,hh1,hT,hμ,hμ1,?_⟩
  intro p r hp hr hD size hR heven A w hw0 hw bias u hpos hcomp hsmall
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
  have hbounds := carrierCodeMass_competitive_scale hp hr hD size hR heven A w c K hc hK hw0 hw bias u hpos hcomp
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
  have henv := carrierCodeMass_le_retained_envelope size heven A w (K*(p*(2*r):ℕ)) hw0 hw bias u
  have hmass : β≤Real.sqrt ((p*r:ℕ):ℝ)*(∫t:ℝ in Ioi 0,
      retainedCarrierProduct size A u t/Real.sinh (Real.pi*t/2)) := by
    let I : ℝ := ∫t:ℝ in Ioi 0,retainedCarrierProduct size A u t/Real.sinh (Real.pi*t/2)
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
  exact ⟨henergy,hres p r hp hr hD size hR heven A u henergy hmass hsmall⟩

end NeuralGeneralization.OnlineLowerTanh
