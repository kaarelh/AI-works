import NeuralGeneralization.OnlineLowerTanhCodeExactSharp
import NeuralGeneralization.OnlineLowerTanhBalancedCode
import NeuralGeneralization.OnlineLowerTanhOddProjection
import NeuralGeneralization.OnlineLowerTanhSharpParity

/-! Exact 2S stability of the literal odd-downward orthogonal projection. -/
noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLower OnlineLowerRelu OnlineLowerGeometry ConcreteModel

def retainedCarrierOddSupports {p:ℕ} (size:Fin p→Bool→ℕ)
    (A:Finset (Fin p→Bool)) : Finset (Finset (Fin (carrierDimension size))) :=
  Finset.univ.filter (fun S=>Odd S.card ∧ ∃θ∈A,S⊆carrierTransversal size θ)

lemma retainedCarrier_projection_le_support_energy {p:ℕ}
    (size:Fin p→Bool→ℕ) (A:Finset (Fin p→Bool)) (θ:Fin p→Bool) (hθ:θ∈A)
    (bias:ℝ) (u:Fin (carrierDimension size)→ℝ) :
    uniformCubeMean (fun x=>(Real.tanh (cubeAffine bias u x)-
      fourierProject (retainedCarrierOddSupports size A)
        (fun x=>Real.tanh (cubeAffine bias u x)) x)^2)≤
      bias^2+∑i∈(carrierTransversal size θ)ᶜ,u i^2 := by
  let T:=carrierTransversal size θ
  let v:Fin (carrierDimension size)→ℝ:=fun i=>if i∈T then u i else 0
  have hv:∀i,i∉T→v i=0:=by intro i hi;simp [v,hi]
  have hface:∀S,S∉retainedCarrierOddSupports size A→
      walshCoefficients (fun x=>Real.tanh (cubeAffine 0 v x)) S=0 := by
    intro S hS
    by_cases ho:Odd S.card
    · apply tanh_walsh_zero_outside v T S hv
      intro hsub
      exact hS (Finset.mem_filter.mpr ⟨Finset.mem_univ _,ho,θ,hθ,hsub⟩)
    · exact tanh_walsh_zero_even v S (Nat.not_odd_iff_even.mp ho)
  have hh:=(projection_residual_le_comparison (retainedCarrierOddSupports size A)
    (fun x=>Real.tanh (cubeAffine bias u x)) (fun x=>Real.tanh (cubeAffine 0 v x)) hface).trans
      (tanh_neuron_l2_difference_le bias 0 u v)
  have he:(∑i,(u i-v i)^2)=∑i∈Tᶜ,u i^2 := by
    simp only [v]
    simp_rw [sub_ite,sub_self,sub_zero,ite_pow,zero_pow (by norm_num : 2≠0)]
    rw [Finset.sum_ite]
    simp only [Finset.sum_const_zero,zero_add]
    congr 1;ext i;simp
  simpa only [sub_zero,he] using hh

/-- No intrinsic-parity certificate is assumed: the balanced cost is the
literal optimized tanh cost and its global theorem is instantiated. -/
theorem retainedCarrier_code_projection_paper :
    ∃k₀ p₀:ℕ,1≤k₀ ∧ 3≤p₀ ∧
      ∀p r:ℕ,p₀≤p → (k₀:ℝ)*(Real.log ((p:ℝ)+2))^2≤(2*r:ℕ) →
      ∀size:Fin p→Bool→ℕ,(∀i s,2*r≤size i s) → (∀i s,size i s≤4*r) →
      (∀i s,Even (size i s)) →
      ∀A:Finset (Fin p→Bool),A.Nonempty →
      ∀W:ℝ,(∀θ∈A,carrierBalancedCost size θ≤W) →
      ∀bias:ℝ,∀u:Fin (carrierDimension size)→ℝ,
      carrierCodeMass size A (carrierBalancedCost size) bias u≤Real.sqrt (bias^2+incomingEnergy u) ∧
      (∃θ∈A,bias^2+(∑i∈(carrierTransversal size θ)ᶜ,u i^2)≤
        2*max 2 (96*Real.sqrt 6*W^2)*Real.sqrt (bias^2+incomingEnergy u)*
          (Real.sqrt (bias^2+incomingEnergy u)-carrierCodeMass size A (carrierBalancedCost size) bias u)) ∧
      uniformCubeMean (fun x=>(Real.tanh (cubeAffine bias u x)-
        fourierProject (retainedCarrierOddSupports size A) (fun x=>Real.tanh (cubeAffine bias u x)) x)^2)≤
        2*max 2 (96*Real.sqrt 6*W^2)*Real.sqrt (bias^2+incomingEnergy u)*
          (Real.sqrt (bias^2+incomingEnergy u)-carrierCodeMass size A (carrierBalancedCost size) bias u) := by
  obtain ⟨k₀,p₀,hk,hp,hcode⟩:=carrierCodeMass_exact_of_intrinsic_paper 12 (by norm_num)
  obtain ⟨n₀,hn₀⟩:=exists_intrinsicParityBound_threshold
  refine ⟨k₀,max p₀ n₀,hk,hp.trans (le_max_left _ _),?_⟩
  intro p r hpp hR size hlo hhi heven A hA W hW bias u
  have hpp₀:p₀≤p:=(le_max_left _ _).trans hpp
  have hp3:3≤p:=hp.trans hpp₀
  have hlog:0<Real.log ((p:ℝ)+2):=Real.log_pos (by exact_mod_cast (show 1<p+2 by omega))
  have hkR:(0:ℝ)<k₀:=by exact_mod_cast (show 0<k₀ by omega)
  have hrR:(0:ℝ)<(2*r:ℕ):=lt_of_lt_of_le (mul_pos hkR (sq_pos_of_pos hlog)) hR
  have hrnat:0<2*r:=by exact_mod_cast hrR
  have hr:0<r:=by omega
  have hsharp:∀θ∈A,IntrinsicParityBound (carrierTransversal size θ).card (carrierBalancedCost size θ):=by
    intro θ _
    have hs:p*(2*r)≤∑i:Fin p,size i (θ i):=by
      have hh:=Finset.sum_le_sum (s:=Finset.univ) (fun i _=>hlo i (θ i))
      simpa using hh
    have hcard:n₀≤(carrierTransversal size θ).card:=by
      rw [carrierTransversal_card]
      have hn:n₀≤p:=(le_max_right _ _).trans hpp
      nlinarith
    exact hn₀ _ hcard (carrierTransversal_odd size heven θ)
  have hh:=hcode p r hpp₀ hR size hlo heven A hA (carrierBalancedCost size)
    (fun θ _=>(carrierBalancedCost_pos size θ).le)
    (fun θ _=>carrierBalancedCost_le_twelve (by omega) hr size hhi heven θ)
    hsharp W hW bias u
  refine ⟨hh.1,hh.2,?_⟩
  obtain ⟨θ,hθ,hbound⟩:=hh.2
  exact (retainedCarrier_projection_le_support_energy size A θ hθ bias u).trans hbound
end NeuralGeneralization.OnlineLowerTanh
