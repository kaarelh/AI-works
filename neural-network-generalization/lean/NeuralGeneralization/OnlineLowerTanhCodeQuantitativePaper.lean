import NeuralGeneralization.OnlineLowerTanhCodeQuantitativeLocalization

/-! # The manuscript's unweighted exponential orientation bound -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLowerRelu

private lemma sqrt_exp_product_le {p a R : ℝ} (hp : 1≤p) :
    Real.sqrt (p*Real.exp (-(a/2)*R)) ≤ p*Real.exp (-(a/4)*R) := by
  have he:0<Real.exp (-(a/4)*R) := Real.exp_pos _
  have hs:0≤p*Real.exp (-(a/2)*R) := mul_nonneg (by linarith) (Real.exp_pos _).le
  have hexp:Real.exp (-(a/2)*R)=(Real.exp (-(a/4)*R))^2 := by
    rw [pow_two,←Real.exp_add]
    congr 1
    ring
  have hh:=Real.sq_sqrt hs
  rw [hexp] at hh
  have hpp:p≤p^2 := by nlinarith
  have hx:=mul_le_mul_of_nonneg_right hpp (sq_nonneg (Real.exp (-(a/4)*R)))
  rw [hexp]
  nlinarith [Real.sqrt_nonneg (p*(Real.exp (-(a/4)*R))^2),mul_pos (by linarith : 0<p) he]

lemma exponential_rate_comparison {p r : ℕ} (hp:1≤p) (hr:1≤r)
    {M a b : ℝ} (hM:0<M) (ha:0<a) (hb:0<b) :
    let A:=Real.sqrt (4*M)*sqrtFrequencyKernelConstant
    let B:=32/Real.pi
    let c:=min (a/4) ((Real.pi/8)*b)
    let C:=1+A+2*B
    A*Real.sqrt ((p:ℝ)*Real.exp (-(a/2)*(2*r:ℕ)))+
      B*Real.exp (-((Real.pi/8)*b)*Real.sqrt (2*r:ℕ))/Real.sqrt ((p*r:ℕ):ℝ) ≤
    C*(p:ℝ)*Real.exp (-c*(2*r:ℕ))+
      C*(1+Real.sqrt (2*r:ℕ))*Real.exp (-c*Real.sqrt (2*r:ℕ))/
        Real.sqrt ((p*(2*r):ℕ):ℝ) := by
  dsimp only
  let A:=Real.sqrt (4*M)*sqrtFrequencyKernelConstant
  let B:ℝ:=32/Real.pi
  let c:=min (a/4) ((Real.pi/8)*b)
  let C:=1+A+2*B
  have hA:0≤A := mul_nonneg (Real.sqrt_nonneg _) sqrtFrequencyKernelConstant_nonneg
  have hB:0<B := by dsimp [B]; positivity
  have hC:0<C := by dsimp [C]; linarith
  have hAC:A≤C := by dsimp [C]; linarith
  have hBC:2*B≤C := by dsimp [C]; linarith
  have hpR:1≤(p:ℝ) := by exact_mod_cast hp
  have hR:0≤((2*r:ℕ):ℝ) := by positivity
  have he1:Real.exp (-(a/4)*(2*r:ℕ))≤Real.exp (-c*(2*r:ℕ)) := by
    apply Real.exp_le_exp.mpr
    have hc:c≤a/4 := min_le_left _ _
    nlinarith [mul_le_mul_of_nonneg_right hc hR]
  have he2:Real.exp (-((Real.pi/8)*b)*Real.sqrt (2*r:ℕ))≤
      Real.exp (-c*Real.sqrt (2*r:ℕ)) := by
    apply Real.exp_le_exp.mpr
    have hc:c≤(Real.pi/8)*b := min_le_right _ _
    nlinarith [mul_le_mul_of_nonneg_right hc (Real.sqrt_nonneg ((2*r:ℕ):ℝ))]
  have hlo: A*Real.sqrt ((p:ℝ)*Real.exp (-(a/2)*(2*r:ℕ)))≤
      C*(p:ℝ)*Real.exp (-c*(2*r:ℕ)) := by
    calc
      _≤ A*((p:ℝ)*Real.exp (-(a/4)*(2*r:ℕ))) :=
        mul_le_mul_of_nonneg_left (sqrt_exp_product_le hpR) hA
      _≤ C*(p:ℝ)*Real.exp (-c*(2*r:ℕ)) := by
        have h1:=mul_le_mul_of_nonneg_left he1 (mul_nonneg hA (by positivity : 0≤(p:ℝ)))
        have h2:=mul_le_mul_of_nonneg_right hAC (show 0≤(p:ℝ)*Real.exp (-c*(2*r:ℕ)) by positivity)
        nlinarith only [h1,h2]
  have hs:0<Real.sqrt ((p*r:ℕ):ℝ) := by positivity
  have hv:0<Real.sqrt ((p*(2*r):ℕ):ℝ) := by positivity
  have hvs:Real.sqrt ((p*(2*r):ℕ):ℝ)≤2*Real.sqrt ((p*r:ℕ):ℝ) := by
    have hs2:=Real.sq_sqrt (show 0≤((p*r:ℕ):ℝ) by positivity)
    have hv2:=Real.sq_sqrt (show 0≤((p*(2*r):ℕ):ℝ) by positivity)
    have hd : ((p*(2*r):ℕ):ℝ)=2*((p*r:ℕ):ℝ) := by push_cast; ring
    have hdeq:Real.sqrt ((p*(2*r):ℕ):ℝ)^2=2*((p*r:ℕ):ℝ):=hv2.trans hd
    nlinarith [hs.le,hv.le]
  have hhi: B*Real.exp (-((Real.pi/8)*b)*Real.sqrt (2*r:ℕ))/Real.sqrt ((p*r:ℕ):ℝ) ≤
      C*(1+Real.sqrt (2*r:ℕ))*Real.exp (-c*Real.sqrt (2*r:ℕ))/
        Real.sqrt ((p*(2*r):ℕ):ℝ) := by
    apply (div_le_div_iff₀ hs hv).mpr
    have hbv:=mul_le_mul_of_nonneg_left hvs hB.le
    have hnum: B*Real.sqrt ((p*(2*r):ℕ):ℝ)≤
        C*(1+Real.sqrt (2*r:ℕ))*Real.sqrt ((p*r:ℕ):ℝ) := by
      have h1:=mul_le_mul_of_nonneg_right hBC hs.le
      have h2:0≤C*Real.sqrt (2*r:ℕ)*Real.sqrt ((p*r:ℕ):ℝ) := by positivity
      nlinarith only [hbv,h1,h2]
    have h1:=mul_le_mul_of_nonneg_left he2 (show 0≤B*Real.sqrt ((p*(2*r):ℕ):ℝ) by positivity)
    have h2:=mul_le_mul_of_nonneg_right hnum (Real.exp_pos (-c*Real.sqrt (2*r:ℕ))).le
    nlinarith only [h1,h2]
  exact add_le_add hlo hhi

/-- The exact displayed unweighted rate, uniformly over the literal carrier
code and every retained orientation family. -/
theorem carrierCodeMass_unweighted_paper_rate
    (c K : ℝ) (hc : 0<c) (hK : 0<K) :
    ∃C a:ℝ,0<C ∧ 0<a ∧ ∃k₀ p₀:ℕ,1≤k₀ ∧ 3≤p₀ ∧
      ∀p r:ℕ,p₀≤p → (k₀:ℝ)*(Real.log ((p:ℝ)+2))^2≤(2*r:ℕ) →
      ∀size:Fin p→Bool→ℕ,(∀i s,2*r≤size i s) → (∀i s,Even (size i s)) →
      ∀A:Finset (Fin p→Bool),∀w:(Fin p→Bool)→ℝ,
      (∀θ∈A,0≤w θ) → (∀θ∈A,w θ≤K*(p*(2*r):ℕ)) →
      ∀bias:ℝ,∀u:Fin (carrierDimension size)→ℝ,
      0<bias^2+incomingEnergy u →
      c*Real.sqrt (bias^2+incomingEnergy u)≤carrierCodeMass size A w bias u →
      ∃θ∈A,carrierCodeMass size (Finset.univ.erase θ) (fun _=>1) bias u≤
        C*(p:ℝ)*Real.exp (-a*(2*r:ℕ))+
        C*(1+Real.sqrt (2*r:ℕ))*Real.exp (-a*Real.sqrt (2*r:ℕ))/
          Real.sqrt ((p*(2*r):ℕ):ℝ) := by
  obtain ⟨M,a,b,hM,ha,hb,k₀,p₀,hk,hp,hmain⟩ :=
    carrierCodeMass_unweighted_exponential_localization c K hc hK
  let C:=1+Real.sqrt (4*M)*sqrtFrequencyKernelConstant+2*(32/Real.pi)
  let a':=min (a/4) ((Real.pi/8)*b)
  have hC:0<C := by
    have hA:=mul_nonneg (Real.sqrt_nonneg (4*M)) sqrtFrequencyKernelConstant_nonneg
    have hB:(0:ℝ)<32/Real.pi:=by positivity
    dsimp [C];linarith
  have ha':0<a':=lt_min (by positivity) (by positivity)
  refine ⟨C,a',hC,ha',k₀,p₀,hk,hp,?_⟩
  intro p r hpp hR size hsize heven A w hw0 hw bias u hpos hcomp
  have hp3:3≤p:=hp.trans hpp
  have hlog:0<Real.log ((p:ℝ)+2):=Real.log_pos (by exact_mod_cast (show 1<p+2 by omega))
  have hkpos:(0:ℝ)<k₀:=by exact_mod_cast (show 0<k₀ by omega)
  have hrpos:(0:ℝ)<(2*r:ℕ):=(mul_pos hkpos (sq_pos_of_pos hlog)).trans_le hR
  have hr:1≤r:=by
    have hn:0<2*r:=by exact_mod_cast hrpos
    omega
  obtain ⟨θ,hθ,hbound⟩:=hmain p r hpp hR size hsize heven A w hw0 hw bias u hpos hcomp
  exact ⟨θ,hθ,hbound.trans (exponential_rate_comparison (by omega) hr hM ha hb)⟩

end NeuralGeneralization.OnlineLowerTanh
