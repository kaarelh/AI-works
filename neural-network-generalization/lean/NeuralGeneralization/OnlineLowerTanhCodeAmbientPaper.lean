import NeuralGeneralization.OnlineLowerTanhCodeAmbient
import NeuralGeneralization.OnlineLowerTanhCodeAmbientLocalization
import NeuralGeneralization.OnlineLowerTanhCodeQuantitativePaper

/-! The literal manuscript code rate in arbitrary ambient coordinates. -/
noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLower OnlineLowerRelu OnlineLowerGeometry ConcreteModel

/-- The manuscript's unweighted full-code exponential estimate, with the
actual ambient neuron and a single retained orientation, uniformly over every
number and placement of unused coordinates. -/
theorem ambientWeightedCarrierCodeMass_unweighted_paper_rate
    (c K : ℝ) (hc : 0<c) (hK : 0<K) :
    ∃C a:ℝ,0<C ∧ 0<a ∧ ∃k₀ p₀:ℕ,1≤k₀ ∧ 3≤p₀ ∧
      ∀p r:ℕ,p₀≤p → (k₀:ℝ)*(Real.log ((p:ℝ)+2))^2≤(2*r:ℕ) →
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
  obtain ⟨M,a,b,hM,ha,hb,k₀,p₀,hk,hp,hmain⟩ :=
    ambientWeightedCarrierCodeMass_unweighted_exponential_localization c K hc hK
  let C:=1+Real.sqrt (4*M)*sqrtFrequencyKernelConstant+2*(32/Real.pi)
  let a':=min (a/4) ((Real.pi/8)*b)
  have hC:0<C := by
    have hA:=mul_nonneg (Real.sqrt_nonneg (4*M)) sqrtFrequencyKernelConstant_nonneg
    have hB:(0:ℝ)<32/Real.pi:=by positivity
    dsimp [C];linarith
  have ha':0<a':=lt_min (by positivity) (by positivity)
  refine ⟨C,a',hC,ha',k₀,p₀,hk,hp,?_⟩
  intro p r hpp hR size hsize heven A w hw0 hw d k e bias u hpos hcomp
  have hp3:3≤p:=hp.trans hpp
  have hlog:0<Real.log ((p:ℝ)+2):=Real.log_pos (by exact_mod_cast (show 1<p+2 by omega))
  have hkpos:(0:ℝ)<k₀:=by exact_mod_cast (show 0<k₀ by omega)
  have hrpos:(0:ℝ)<(2*r:ℕ):=(mul_pos hkpos (sq_pos_of_pos hlog)).trans_le hR
  have hr:1≤r:=by
    have hn:0<2*r:=by exact_mod_cast hrpos
    omega
  obtain ⟨θ,hθ,hbound⟩:=hmain p r hpp hR size hsize heven A w hw0 hw d k e bias u hpos hcomp
  exact ⟨θ,hθ,hbound.trans (exponential_rate_comparison (by omega) hr hM ha hb)⟩


end NeuralGeneralization.OnlineLowerTanh
