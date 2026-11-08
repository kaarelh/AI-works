import NeuralGeneralization.OnlineLowerTanhCodeExact
import NeuralGeneralization.OnlineLowerTanhScalarBounds

/-! The exact carrier-code theorem specialized to the literal optimized
balanced tanh costs. Only the sharp intrinsic single-parity theorem remains
as an explicit input to this intermediate bridge. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh

/-- The optimized variation cost of the actual odd selected support. -/
def carrierBalancedCost {p:ℕ} (size:Fin p→Bool→ℕ) (θ:Fin p→Bool) : ℝ :=
  balancedCost ((carrierTransversal size θ).card/2)

lemma carrierBalancedCost_pos {p:ℕ} (size:Fin p→Bool→ℕ) (θ:Fin p→Bool) :
    0<carrierBalancedCost size θ := balancedCost_pos _

lemma carrierTransversal_odd_degree {p:ℕ} (size:Fin p→Bool→ℕ)
    (heven:∀i s,Even (size i s)) (θ:Fin p→Bool) :
    2*((carrierTransversal size θ).card/2)+1=(carrierTransversal size θ).card := by
  obtain ⟨j,hj⟩:=carrierTransversal_odd size heven θ
  omega

lemma carrierBalancedCost_le_twelve {p r:ℕ} (hp:0<p) (hr:0<r)
    (size:Fin p→Bool→ℕ) (hsize:∀i s,size i s≤4*r)
    (heven:∀i s,Even (size i s)) (θ:Fin p→Bool) :
    carrierBalancedCost size θ≤12*(p*(2*r):ℕ) := by
  have hc:(carrierTransversal size θ).card≤1+p*(4*r) := by
    rw [carrierTransversal_card]
    have hh:=Finset.sum_le_sum (s:=Finset.univ) (fun i _=>hsize i (θ i))
    simpa using Nat.add_le_add_left hh 1
  have hn:(carrierTransversal size θ).card≤3*(p*(2*r)) := by nlinarith
  have hnR:((carrierTransversal size θ).card:ℝ)≤3*(p*(2*r):ℕ) := by exact_mod_cast hn
  have hb:=balancedCost_le_four_degree ((carrierTransversal size θ).card/2)
  rw [carrierTransversal_odd_degree size heven θ] at hb
  exact hb.trans (by nlinarith)

/-- A single polynomial support-stability constant works for every retained
orientation and every physical neuron under the logarithmic-square rail threshold. -/
theorem carrierBalancedCode_exact_of_intrinsic :
    ∃k₀ p₀:ℕ,1≤k₀ ∧ 3≤p₀ ∧
      ∀p r:ℕ,p₀≤p → (k₀:ℝ)*(Real.log ((p:ℝ)+2))^2≤(2*r:ℕ) →
      ∀size:Fin p→Bool→ℕ,(∀i s,2*r≤size i s) → (∀i s,size i s≤4*r) →
      (∀i s,Even (size i s)) →
      ∀A:Finset (Fin p→Bool),A.Nonempty →
      (∀θ∈A,IntrinsicParityBound (carrierTransversal size θ).card (carrierBalancedCost size θ)) →
      ∀bias:ℝ,∀u:Fin (carrierDimension size)→ℝ,
      carrierCodeMass size A (carrierBalancedCost size) bias u≤Real.sqrt (bias^2+incomingEnergy u) ∧
      ∃θ∈A,bias^2+(∑i∈(carrierTransversal size θ)ᶜ,u i^2)≤
        82948*((p*(2*r):ℕ):ℝ)^2*Real.sqrt (bias^2+incomingEnergy u)*
          (Real.sqrt (bias^2+incomingEnergy u)-carrierCodeMass size A (carrierBalancedCost size) bias u) := by
  obtain ⟨k₀,p₀,hk,hp,h⟩:=carrierCodeMass_exact_of_intrinsic 12 (by norm_num)
  refine ⟨k₀,p₀,hk,hp,?_⟩
  intro p r hpp hR size hlo hhi heven A hA hsharp bias u
  have hp3:3≤p:=hp.trans hpp
  have hlog:0<Real.log ((p:ℝ)+2):=Real.log_pos (by exact_mod_cast (show 1<p+2 by omega))
  have hkR:(0:ℝ)<k₀:=by exact_mod_cast (show 0<k₀ by omega)
  have hrR:(0:ℝ)<(2*r:ℕ):=lt_of_lt_of_le (mul_pos hkR (sq_pos_of_pos hlog)) hR
  have hrnat:0<2*r:=by exact_mod_cast hrR
  have hr:0<r:=by omega
  have ht:=h p r hpp hR size hlo heven A hA (carrierBalancedCost size)
    (fun θ _=>(carrierBalancedCost_pos size θ).le)
    (fun θ _=>carrierBalancedCost_le_twelve (by omega) hr size hhi heven θ) hsharp bias u
  norm_num only at ht
  exact ht

end NeuralGeneralization.OnlineLowerTanh
