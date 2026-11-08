import NeuralGeneralization.OnlineLowerTanhCodeRetainedPeak

/-! # Compact gain from actual weighted-code competitiveness -/
noncomputable section
open scoped BigOperators
open MeasureTheory Set
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLowerRelu

lemma gain_bounds_of_mass_bounds (c K A B s z Q : ℝ)
    (hc : 0<c) (hK : 0<K) (hA : 0<A) (hB : 0<B) (hs : 0<s) (hz : 0<z)
    (hcomp : c*z*s≤Q)
    (hlow : s*Q≤2*K*s^2*A*z^3)
    (hhigh : s*Q≤2*K*s^2*B*Real.sqrt (2*z)) :
    c≤2*K*A*z^2 ∧ z≤8*K^2*B^2/c^2 := by
  have hcomp' := mul_le_mul_of_nonneg_left hcomp hs.le
  have hcancel (X : ℝ) (h : s*Q≤s^2*X) : c*z≤X := by
    apply (mul_le_mul_iff_right₀ (sq_pos_of_pos hs)).mp
    nlinarith only [hcomp',h]
  have hcl : c*z≤2*K*A*z^3 := hcancel _ (by nlinarith only [hlow])
  have hch : c*z≤2*K*B*Real.sqrt (2*z) := hcancel _ (by nlinarith only [hhigh])
  have hlo : c≤2*K*A*z^2 := by
    apply (mul_le_mul_iff_left₀ hz).mp
    nlinarith only [hcl]
  have hsquare := (sq_le_sq₀ (mul_nonneg hc.le hz.le) (by positivity : 0≤2*K*B*Real.sqrt (2*z))).mpr hch
  have hroot := Real.sq_sqrt (show 0≤2*z by positivity)
  simp only [mul_pow,hroot] at hsquare
  have hhi : c^2*z≤8*K^2*B^2 := by
    apply (mul_le_mul_iff_left₀ hz).mp
    nlinarith only [hsquare,hroot]
  refine ⟨hlo,(le_div_iff₀ (sq_pos_of_pos hc)).mpr ?_⟩
  nlinarith only [hhi]

def codeLowerScaleConstant : ℝ := 65536/Real.pi^3

def codeUpperScaleConstant : ℝ := 4*Real.pi*codeCschMomentConstant

theorem codeLowerScaleConstant_pos : 0<codeLowerScaleConstant := by
  unfold codeLowerScaleConstant;positivity

theorem codeUpperScaleConstant_pos : 0<codeUpperScaleConstant := by
  unfold codeUpperScaleConstant
  exact mul_pos (by positivity) codeCschMomentConstant_pos

/-- Literal neuron-level compact scale estimates. The radius includes both
bias and every physical incoming coordinate. -/
theorem carrierCodeMass_competitive_scale {p r : ℕ} (hp : 2≤p) (hr : 1≤r) (hD : 6≤p*(2*r))
    (size : Fin p→Bool→ℕ) (hR : ∀i s,2*r≤size i s) (heven : ∀i s,Even (size i s))
    (A : Finset (Fin p→Bool)) (w : (Fin p→Bool)→ℝ) (c K : ℝ) (hc:0<c) (hK:0<K)
    (hw0 : ∀θ∈A,0≤w θ) (hw : ∀θ∈A,w θ≤K*(p*(2*r):ℕ))
    (bias : ℝ) (u : Fin (carrierDimension size)→ℝ)
    (hpos : 0<bias^2+incomingEnergy u)
    (hcomp : c*Real.sqrt (bias^2+incomingEnergy u)≤carrierCodeMass size A w bias u) :
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
  have hb := carrierCodeMass_scale_bounds hp hr hD size hR heven A w
    (K*(p*(2*r):ℕ)) hw0 hw (by positivity) bias u z hz.le henergy
  rw [hdeq] at hb
  have hc' : c*z*s≤carrierCodeMass size A w bias u := by
    rw [mul_assoc,hzs]
    exact hcomp
  have hlow : s*carrierCodeMass size A w bias u≤2*K*s^2*codeLowerScaleConstant*z^3 := by
    simpa only [s,hdeq,codeLowerScaleConstant,mul_assoc,mul_comm,mul_left_comm] using hb.1
  have hhigh : s*carrierCodeMass size A w bias u≤2*K*s^2*codeUpperScaleConstant*Real.sqrt (2*z) := by
    simpa only [s,hdeq,codeUpperScaleConstant,mul_assoc,mul_comm,mul_left_comm] using hb.2
  exact gain_bounds_of_mass_bounds c K _ _ s z _ hc hK codeLowerScaleConstant_pos
    codeUpperScaleConstant_pos hs hz hc' hlow hhigh


def codeMinimumGain (c K : ℝ) : ℝ := Real.sqrt (c/(2*K*codeLowerScaleConstant))

theorem codeMinimumGain_pos (c K : ℝ) (hc:0<c) (hK:0<K) : 0<codeMinimumGain c K := by
  unfold codeMinimumGain
  exact Real.sqrt_pos.mpr (by positivity [codeLowerScaleConstant_pos])

theorem carrierCodeMass_competitive_radius_lower {p r : ℕ} (hp : 2≤p) (hr : 1≤r) (hD : 6≤p*(2*r))
    (size : Fin p→Bool→ℕ) (hR : ∀i s,2*r≤size i s) (heven : ∀i s,Even (size i s))
    (A : Finset (Fin p→Bool)) (w : (Fin p→Bool)→ℝ) (c K : ℝ) (hc:0<c) (hK:0<K)
    (hw0 : ∀θ∈A,0≤w θ) (hw : ∀θ∈A,w θ≤K*(p*(2*r):ℕ))
    (bias : ℝ) (u : Fin (carrierDimension size)→ℝ)
    (hpos : 0<bias^2+incomingEnergy u)
    (hcomp : c*Real.sqrt (bias^2+incomingEnergy u)≤carrierCodeMass size A w bias u) :
    codeMinimumGain c K*Real.sqrt ((p*r:ℕ):ℝ)≤Real.sqrt (bias^2+incomingEnergy u) := by
  let z := Real.sqrt (bias^2+incomingEnergy u)/Real.sqrt ((p*r:ℕ):ℝ)
  have hs:0<Real.sqrt ((p*r:ℕ):ℝ) := by positivity
  have hz:0≤z := by dsimp [z];positivity
  have hbounds := carrierCodeMass_competitive_scale hp hr hD size hR heven A w c K hc hK hw0 hw bias u hpos hcomp
  have hsq : c/(2*K*codeLowerScaleConstant)≤z^2 :=
    (div_le_iff₀ (by positivity [codeLowerScaleConstant_pos] : 0<2*K*codeLowerScaleConstant)).mpr (by nlinarith only [hbounds.1])
  have hroot := Real.sqrt_le_sqrt hsq
  rw [Real.sqrt_sq hz] at hroot
  exact (le_div_iff₀ hs).mp hroot

end NeuralGeneralization.OnlineLowerTanh
