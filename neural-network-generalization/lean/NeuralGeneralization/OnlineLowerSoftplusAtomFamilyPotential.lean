import NeuralGeneralization.OnlineLowerSoftplusAtomPotential
import NeuralGeneralization.OnlineLowerSoftplusMixture

noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerSoftplus
open OnlineLowerRelu OnlineLower OnlineLowerGeometry

def fullPotential {p : ℕ} (size : Fin p→Bool→ℕ)
    (u : Fin (railDimension size)→ℝ) : ℝ :=
  ∑ τ, fullRailCost size τ*supportFourierPotential (fullRailSupport size τ) u

theorem full_rail_potential_norm_of_size {p : ℕ} (hp : 2 ≤ p)
    (size : Fin p → Bool → ℕ) (htwo : ∀ i side, 2 ≤ size i side)
    (heven : ∀ i side, Even (size i side))
    (R Δ : ℝ) (hΔ : 0 ≤ Δ) (hR : 6 * Δ ≤ R)
    (hmin : ∀ i side, R ≤ (size i side : ℝ))
    (hdiff : ∀ i, |(size i true : ℝ) - size i false| ≤ Δ)
    (u : Fin (railDimension size) → ℝ) :
    fullPotential size u ≤ Real.sqrt (∑ i, u i ^ 2) := by
  have hrepresentation : ∃ P r : Fin p → ℕ, size = samplerSize P r := by
    refine ⟨(fun i => size i false), (fun i => size i true - 2), ?_⟩
    funext i side
    cases side
    · rfl
    · change size i true = size i true - 2 + 2
      have := htwo i true
      omega
  obtain ⟨P,r,rfl⟩ := hrepresentation
  have hPtwo (i) : 2 ≤ P i := htwo i false
  have hPeven (i) : Even (P i) := heven i false
  have hreven (i) : Even (r i) := by
    obtain ⟨v,hv⟩ := heven i true
    change r i + 2 = v + v at hv
    refine ⟨v-1, ?_⟩
    omega
  have hcost (τ : Finset (Fin p)) : fullRailCost (samplerSize P r) τ =
      samplerTransversalCost P r τ := by
    have hc := samplerSupport_card_half P r hPeven hreven τ
    have hs := samplerSupport_two_le (by omega) P r τ hPtwo
    unfold fullRailCost samplerTransversalCost
    change evenReluCost (((samplerSupport P r τ).card - 2) / 2) = _
    congr 1
    omega
  have h := full_rail_potential_norm hp P r hPtwo hPeven hreven R Δ hΔ hR
    (fun i => hmin i false) (fun i => by simpa only [samplerSize, Nat.cast_add, Nat.cast_ofNat] using hmin i true)
    (fun i => by simpa only [samplerSize, Nat.cast_add, Nat.cast_ofNat] using hdiff i) u
  unfold fullPotential
  simp only [hcost]
  exact h

theorem full_rail_potential_stability_of_size {p:ℕ} (hp:2≤p)
    (size:Fin p→Bool→ℕ) (htwo:∀i side,2≤size i side)
    (heven:∀i side,Even (size i side))
    (R Δ U:ℝ) (hΔ:0≤Δ) (hR:6*Δ≤R)
    (hRpos:0<R) (hU:2≤U) (hUR:U≤2*R)
    (hmin:∀i side,R≤(size i side:ℝ))
    (hmax:∀i side,(size i side:ℝ)≤U)
    (hdiff:∀i,|(size i true:ℝ)-size i false|≤Δ)
    (u:Fin (railDimension size)→ℝ) :
    ∃(τ:Finset (Fin p)) (c:ℝ) (v:Fin (railDimension size)→ℝ),
      0≤c∧(∀i,|v i|=if i∈fullRailSupport size τ then c else 0)∧
      (∑i,(u i-v i)^2)≤
        48*U*Real.sqrt (∑i,u i^2)*
          (Real.sqrt (∑i,u i^2)-
            fullPotential size u) := by
  have hrepresentation:∃P r:Fin p→ℕ,size=samplerSize P r := by
    refine ⟨(fun i=>size i false),(fun i=>size i true-2),?_⟩
    funext i side
    cases side
    · rfl
    · change size i true=size i true-2+2
      have:=htwo i true
      omega
  obtain ⟨P,r,rfl⟩:=hrepresentation
  have hPtwo(i):2≤P i:=htwo i false
  have hPeven(i):Even (P i):=heven i false
  have hreven(i):Even (r i):=by
    obtain ⟨v,hv⟩:=heven i true
    change r i+2=v+v at hv
    exact ⟨v-1,by omega⟩
  have hcost(τ:Finset (Fin p)):fullRailCost (samplerSize P r) τ=samplerTransversalCost P r τ:=by
    have hc:=samplerSupport_card_half P r hPeven hreven τ
    have hs:=samplerSupport_two_le (by omega) P r τ hPtwo
    unfold fullRailCost samplerTransversalCost
    change evenReluCost (((samplerSupport P r τ).card-2)/2)=_
    congr 1
    omega
  obtain ⟨τ,c,v,hc,hv,hd⟩:=full_rail_potential_stability hp P r hPtwo hPeven hreven
    R Δ U hΔ hR hRpos hU hUR
    (fun i=>hmin i false)
    (fun i=>by simpa only [samplerSize,Nat.cast_add,Nat.cast_ofNat] using hmin i true)
    (fun i=>hmax i false)
    (fun i=>by simpa only [samplerSize,Nat.cast_add,Nat.cast_ofNat] using hmax i true)
    (fun i=>by simpa only [samplerSize,Nat.cast_add,Nat.cast_ofNat] using hdiff i) u
  refine ⟨τ,c,v,hc,hv,?_⟩
  unfold fullPotential
  simp only [hcost]
  exact hd

namespace Family
open OnlineLowerRelu.Family

def retainedPotential (R k : ℕ) (u : Fin (railDimension (size R k))→ℝ) : ℝ :=
  ∑ s, weight R k s*supportFourierPotential (targetSupport R k s) u

theorem retainedPotential_image (R k : ℕ) (hR : 2≤R) (heven : Even R)
    (u : Fin (railDimension (size R k))→ℝ) :
    (∑ τ∈retainedTransversals k,fullRailCost (size R k) τ*
      supportFourierPotential (fullRailSupport (size R k) τ) u) = retainedPotential R k u := by
  unfold retainedTransversals retainedPotential
  rw [Finset.sum_image]
  · apply Finset.sum_congr rfl
    intro s _
    rw [targetSupport_eq_transversal,weight_eq_transversalCost R k hR heven]
  · intro s _ t _ h
    exact transversalIndex_injective R k (by omega) h

theorem retainedPotential_nonneg (R k : ℕ) (hR : 2≤R) (heven : Even R)
    (u : Fin (railDimension (size R k))→ℝ) : 0 ≤ retainedPotential R k u :=
  Finset.sum_nonneg (fun s _ => mul_nonneg (weight_pos R k hR heven s).le
    (supportFourierPotential_nonneg _ _))

theorem retainedPotential_le_full (R k : ℕ) (hR : 2≤R) (heven : Even R)
    (u : Fin (railDimension (size R k))→ℝ) :
    retainedPotential R k u ≤ fullPotential (size R k) u := by
  rw [← retainedPotential_image R k hR heven u]
  exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
    (fun τ _ _ => mul_nonneg (fullRailCost_nonneg _ _) (supportFourierPotential_nonneg _ _))

theorem fullPotential_norm (R k : ℕ) (hR : 36≤R) (heven : Even R)
    (u : Fin (railDimension (size R k))→ℝ) :
    fullPotential (size R k) u ≤ Real.sqrt (∑i,u i^2) := by
  exact full_rail_potential_norm_of_size (by rw [pairDim_eq];omega) (size R k)
    (family_size_two R k (by omega)) (size_even R k heven) (R:ℝ) 6
    (by norm_num) (by exact_mod_cast hR) (family_size_min R k)
    (family_size_difference R k) u

theorem fullPotential_stability (R k : ℕ) (hR : 36≤R) (heven : Even R)
    (u : Fin (railDimension (size R k))→ℝ) :
    ∃(τ:Finset (Fin (pairDim k))) (c:ℝ)
      (v:Fin (railDimension (size R k))→ℝ),
      0≤c ∧ (∀i,|v i|=if i∈fullRailSupport (size R k) τ then c else 0) ∧
      (∑i,(u i-v i)^2) ≤
        48*((R:ℝ)+6)*Real.sqrt (∑i,u i^2)*
          (Real.sqrt (∑i,u i^2)-fullPotential (size R k) u) := by
  have hRr : (36:ℝ)≤R := by exact_mod_cast hR
  exact full_rail_potential_stability_of_size (by rw [pairDim_eq];omega) (size R k)
    (family_size_two R k (by omega)) (size_even R k heven) (R:ℝ) 6 ((R:ℝ)+6)
    (by norm_num) (by exact_mod_cast hR) (by linarith) (by linarith) (by linarith)
    (family_size_min R k) (family_size_max R k) (family_size_difference R k) u

end Family
end NeuralGeneralization.OnlineLowerSoftplus
