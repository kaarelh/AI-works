import NeuralGeneralization.OnlineLowerFamilyNorm
import NeuralGeneralization.OnlineLowerReluRailStability

/-! # Full affine stability for arbitrary physical rail-size enumerations -/

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerRelu
open OnlineLower OnlineLowerGeometry

/-- The actual finite-coordinate stability theorem without imposing the
canonical first/free/last sampler enumeration on the rail sizes. -/
theorem full_rail_stability_of_size {p:ℕ} (hp:2≤p)
    (size:Fin p→Bool→ℕ) (htwo:∀i side,2≤size i side)
    (heven:∀i side,Even (size i side))
    (R Δ U:ℝ) (hΔ:0≤Δ) (hR:6*Δ≤R)
    (hRpos:0<R) (hU:2≤U) (hUR:U≤2*R)
    (hmin:∀i side,R≤(size i side:ℝ))
    (hmax:∀i side,(size i side:ℝ)≤U)
    (hdiff:∀i,|(size i true:ℝ)-size i false|≤Δ)
    (u:Fin (railDimension size)→ℝ) (bias:ℝ) :
    ∃(τ:Finset (Fin p)) (c:ℝ) (v:Fin (railDimension size)→ℝ),
      0≤c∧(∀i,|v i|=if i∈fullRailSupport size τ then c else 0)∧
      bias^2+(∑i,(u i-v i)^2)≤
        48*U*Real.sqrt (bias^2+∑i,u i^2)*
          (Real.sqrt (bias^2+∑i,u i^2)-
            retainedFourierMass (fullRailSupport size) (fullRailCost size)
              (fun x=>max (cubeAffine bias u x) 0)) := by
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
  obtain ⟨τ,c,v,hc,hv,hd⟩:=full_rail_atom_stability hp P r hPtwo hPeven hreven
    R Δ U hΔ hR hRpos hU hUR
    (fun i=>hmin i false)
    (fun i=>by simpa only [samplerSize,Nat.cast_add,Nat.cast_ofNat] using hmin i true)
    (fun i=>hmax i false)
    (fun i=>by simpa only [samplerSize,Nat.cast_add,Nat.cast_ofNat] using hmax i true)
    (fun i=>by simpa only [samplerSize,Nat.cast_add,Nat.cast_ofNat] using hdiff i) u bias
  refine ⟨τ,c,v,hc,hv,?_⟩
  unfold retainedFourierMass
  simp only [hcost]
  exact hd

theorem fullRailSupport_card {p:ℕ} (size:Fin p→Bool→ℕ) (τ:Finset (Fin p)) :
    (fullRailSupport size τ).card=∑i,size i (decide (i∈τ)) := by
  unfold fullRailSupport
  rw [Finset.card_biUnion]
  · simp only [physicalRail_card]
  · intro i _ j _ hij
    exact physicalRail_disjoint size (Or.inl hij)

theorem fullRailSupport_even {p:ℕ} (size:Fin p→Bool→ℕ)
    (heven:∀i side,Even (size i side)) (τ:Finset (Fin p)) :
    Even (fullRailSupport size τ).card := by
  rw [fullRailSupport_card]
  exact Finset.even_sum _ (fun i _=>heven i _)

theorem fullRailSupport_two_le {p:ℕ} (hp:0<p) (size:Fin p→Bool→ℕ)
    (htwo:∀i side,2≤size i side) (τ:Finset (Fin p)) :
    2≤(fullRailSupport size τ).card := by
  rw [fullRailSupport_card]
  let i:Fin p:=⟨0,hp⟩
  exact (htwo i (decide (i∈τ))).trans (Finset.single_le_sum
    (f:=fun j=>size j (decide (j∈τ))) (fun _ _=>Nat.zero_le _) (Finset.mem_univ i))

theorem fullRailSupport_card_le {p:ℕ} (size:Fin p→Bool→ℕ)
    (U:ℝ) (hmax:∀i side,(size i side:ℝ)≤U) (τ:Finset (Fin p)) :
    ((fullRailSupport size τ).card:ℝ)≤(p:ℝ)*U := by
  rw [fullRailSupport_card,Nat.cast_sum]
  have hh:=Finset.sum_le_sum (fun i (_:i∈Finset.univ)=>hmax i (decide (i∈τ)))
  simpa only [Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul] using hh

theorem fullRailCost_le_three_card {p:ℕ} (hp:0<p)
    (size:Fin p→Bool→ℕ) (htwo:∀i side,2≤size i side)
    (heven:∀i side,Even (size i side)) (τ:Finset (Fin p)) :
    fullRailCost size τ≤3*((fullRailSupport size τ).card:ℝ) := by
  have htwo':=fullRailSupport_two_le hp size htwo τ
  obtain ⟨n,hn⟩:=fullRailSupport_even size heven τ
  have hcard:(fullRailSupport size τ).card=2*(((fullRailSupport size τ).card-2)/2)+2:=by omega
  have hh:=evenReluCost_le_three (((fullRailSupport size τ).card-2)/2)
  unfold fullRailCost
  have hcast:((fullRailSupport size τ).card:ℝ)=
      2*((((fullRailSupport size τ).card-2)/2:ℕ):ℝ)+2:=by exact_mod_cast hcard
  rw [hcast]
  linarith

namespace Family

/-- Explicit full-transversal stability for the concrete fixed-rail family.
The selected ray may initially be outside the retained logical subcode; the
separate omitted-ray argument handles that case. -/
theorem affine_atom_full_stability (R k:ℕ) (hR:36≤R) (heven:Even R)
    (u:Fin (railDimension (size R k))→ℝ) (bias:ℝ) :
    ∃(τ:Finset (Fin (pairDim k))) (c:ℝ)
      (v:Fin (railDimension (size R k))→ℝ),
      0≤c∧(∀i,|v i|=if i∈fullRailSupport (size R k) τ then c else 0)∧
      bias^2+(∑i,(u i-v i)^2)≤
        48*((R:ℝ)+6)*Real.sqrt (bias^2+∑i,u i^2)*
          (Real.sqrt (bias^2+∑i,u i^2)-
            retainedFourierMass (fullRailSupport (size R k)) (fullRailCost (size R k))
              (fun x=>max (cubeAffine bias u x) 0)) := by
  have hRr:(36:ℝ)≤R:=by exact_mod_cast hR
  apply full_rail_stability_of_size (show 2≤pairDim k by rw [pairDim_eq]; omega)
    (size R k) (fun i side=>?_) (size_even R k heven) (R:ℝ) 6 ((R:ℝ)+6)
    (by norm_num) (by exact_mod_cast hR) (by exact_mod_cast (show 0<R by omega))
    (by linarith)
    (by linarith)
    (fun i side=>?_) (fun i side=>?_) (fun i=>?_) u bias
  · cases side <;> simp only [size_false,size_true] <;> omega
  · cases side
    · rfl
    · simp only [size_true,Nat.cast_add]
      exact le_add_of_nonneg_right (Nat.cast_nonneg _)
  · cases side
    · simp only [size_false]; linarith
    · simp only [size_true,Nat.cast_add]
      have hh:((increment k i):ℝ)≤6:=by exact_mod_cast (increment_bounds k i).2
      linarith
  · simp only [size_true,size_false,Nat.cast_add,add_sub_cancel_left,
      abs_of_nonneg (Nat.cast_nonneg (α:=ℝ) (increment k i))]
    exact_mod_cast (increment_bounds k i).2

end Family
end NeuralGeneralization.OnlineLowerRelu
