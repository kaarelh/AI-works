import NeuralGeneralization.OnlineLowerTanhFiniteParityLocalCode
import NeuralGeneralization.OnlineLowerTanhFiniteParityCodeSigns
import NeuralGeneralization.OnlineLowerTanhFiniteParityAmbientGap

/-! The literal finite-degree local weighted-code corollary, including input flips. -/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLower OnlineLowerRelu ConcreteModel

/-- Any finite family whose competing supports have three inactive
coordinates has a strict local balanced optimum at every odd support of
size at least five. The weights are the actual optimized balanced costs. -/
theorem finite_family_balanced_code_strict_local_maximum {d : ℕ}
    (C : Finset (Finset (Fin d))) (A : Finset (Fin d)) (hA : A∈C)
    (hcard : 5≤A.card) (hodd : Odd A.card)
    (hthree : ∀B∈C.erase A,3≤(B\A).card) :
    let z₀:=supportedAffinePoint A (balancedGain (A.card/2))
    let weight:=fun B:Finset (Fin d)=>balancedCost (B.card/2)
    weightedAffineCodeRatio C weight z₀=1 ∧
      ∀ᶠ z in 𝓝 z₀,z≠z₀ → weightedAffineCodeRatio C weight z<1 := by
  let z₀:=supportedAffinePoint A (balancedGain (A.card/2))
  let weight:=fun B:Finset (Fin d)=>balancedCost (B.card/2)
  have hz₀ : ∀i,i∉A → z₀ i.succ=0 := by intro i hi;simp [z₀,supportedAffinePoint,hi]
  have hgap : ∃c>0,∀ᶠ z in 𝓝 z₀,
      |affineSupportCoefficient A z|/affineEuclideanRadius z ≤
        |affineSupportCoefficient A z₀|/affineEuclideanRadius z₀-c*‖z-z₀‖^2 :=
    selectedAbsoluteRatio_quadratic_gap A hcard hodd
  have hmax:=weightedAffineCodeRatio_strict_local_maximum_of_gap C A hA weight
    (fun B _=>(balancedCost_pos _).le) (balancedCost_pos _) hthree z₀ hz₀
    (supportedAffinePoint_radius_pos A (by omega) _ (balancedGain_pos _)) hgap
  have hoff : (∑B∈C.erase A,weight B*|affineSupportCoefficient B z₀|)=0 := by
    apply Finset.sum_eq_zero
    intro B hB
    have hh:=affine_walsh_cubic_offsupport A B (hthree B hB) z₀ z₀ hz₀
    have hz : |affineSupportCoefficient B z₀|=0 := by
      apply le_antisymm _ (abs_nonneg _)
      simpa only [affineSupportCoefficient,sub_self,norm_zero,zero_pow (by norm_num : (3:ℕ)≠0),mul_zero] using hh
    rw [hz,mul_zero]
  have hvalue : weightedAffineCodeRatio C weight z₀=1 := by
    rw [weightedAffineCodeRatio_selected_add C A hA weight z₀,hoff,zero_div,add_zero]
    change balancedCost (A.card/2)*selectedAbsoluteRatio A z₀=1
    rw [selectedAbsoluteRatio_at_supported A hodd]
    exact mul_inv_cancel₀ (balancedCost_pos _).ne'
  refine ⟨hvalue,?_⟩
  simpa only [hvalue] using hmax

/-- Value one and strict locality hold at every independent input flip. -/
theorem finite_family_balanced_code_strict_local_maximum_signed {d : ℕ}
    (C : Finset (Finset (Fin d))) (A : Finset (Fin d)) (hA : A∈C)
    (hcard : 5≤A.card) (hodd : Odd A.card)
    (hthree : ∀B∈C.erase A,3≤(B\A).card) (t : Cube d) :
    let z₀:=orbitIncoming (supportedAffinePoint A (balancedGain (A.card/2))) t
    let weight:=fun B:Finset (Fin d)=>balancedCost (B.card/2)
    weightedAffineCodeRatio C weight z₀=1 ∧
      ∀ᶠ z in 𝓝 z₀,z≠z₀ → weightedAffineCodeRatio C weight z<1 := by
  obtain ⟨hvalue,hmax⟩:=finite_family_balanced_code_strict_local_maximum C A hA hcard hodd hthree
  have hmax' := weightedAffineCodeRatio_strict_local_maximum_signs C
    (fun B:Finset (Fin d)=>balancedCost (B.card/2))
    (supportedAffinePoint A (balancedGain (A.card/2))) (by simpa only [hvalue] using hmax) t
  have hv : weightedAffineCodeRatio C (fun B:Finset (Fin d)=>balancedCost (B.card/2))
      (orbitIncoming (supportedAffinePoint A (balancedGain (A.card/2))) t)=1 := by
    rw [weightedAffineCodeRatio_orbitIncoming,hvalue]
  exact ⟨hv,by simpa only [hv] using hmax'⟩

def oddRailCodeRatio {m d : ℕ} (B : Fin m→Bool→Finset (Fin d)) (z : Fin (d+1)→ℝ) : ℝ :=
  (∑s:Fin m→Bool,balancedCost ((oddRailTransversal B s).card/2)*
    |affineSupportCoefficient (oddRailTransversal B s) z|)/affineEuclideanRadius z

lemma oddRailTransversal_injective {m d : ℕ}
    (B : Fin m→Bool→Finset (Fin d)) (hdisj : PairwiseDisjointRails B)
    (hsize : ∀i a,3≤(B i a).card) : Function.Injective (oddRailTransversal B) := by
  intro s t he
  by_contra hne
  have hh:=oddRailTransversal_difference_three B hdisj hsize s t hne
  rw [he,Finset.sdiff_self,Finset.card_empty] at hh
  omega

lemma oddRailCodeRatio_eq_family {m d : ℕ}
    (B : Fin m→Bool→Finset (Fin d)) (hdisj : PairwiseDisjointRails B)
    (hsize : ∀i a,3≤(B i a).card) :
    oddRailCodeRatio B=weightedAffineCodeRatio (Finset.univ.image (oddRailTransversal B))
      (fun A=>balancedCost (A.card/2)) := by
  funext z
  unfold oddRailCodeRatio weightedAffineCodeRatio
  rw [Finset.sum_image]
  intro s _ t _ he
  exact oddRailTransversal_injective B hdisj hsize he

/-- The paper's local weighted-code corollary for arbitrary physical rails:
odd number of disjoint pairs, each rail odd and of size at least three,
all transversal sizes at least five, and every signed balanced point. -/
theorem odd_rail_local_weighted_code_paper {m d : ℕ}
    (B : Fin m→Bool→Finset (Fin d)) (hdisj : PairwiseDisjointRails B)
    (hm : Odd m) (hodd : ∀i a,Odd (B i a).card) (hsize : ∀i a,3≤(B i a).card)
    (hcard : ∀s:Fin m→Bool,5≤(oddRailTransversal B s).card)
    (s : Fin m→Bool) (t : Cube d) :
    let z₀:=orbitIncoming (supportedAffinePoint (oddRailTransversal B s)
      (balancedGain ((oddRailTransversal B s).card/2))) t
    oddRailCodeRatio B z₀=1 ∧ ∀ᶠ z in 𝓝 z₀,z≠z₀ → oddRailCodeRatio B z<1 := by
  rw [oddRailCodeRatio_eq_family B hdisj hsize]
  apply finite_family_balanced_code_strict_local_maximum_signed
    (Finset.univ.image (oddRailTransversal B)) (oddRailTransversal B s)
    (Finset.mem_image.mpr ⟨s,Finset.mem_univ _,rfl⟩) (hcard s)
    (oddRailTransversal_odd B hdisj hm hodd s) _ t
  intro A hA
  obtain ⟨hne,hmem⟩:=Finset.mem_erase.mp hA
  obtain ⟨s',hs',rfl⟩:=Finset.mem_image.mp hmem
  exact oddRailTransversal_difference_three B hdisj hsize s' s (fun he=>hne (congrArg _ he))

end NeuralGeneralization.OnlineLowerTanh
