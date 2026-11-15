import NeuralGeneralization.OnlineLowerTanhFiniteParityOffSupport

/-! Arbitrary physical odd-rail families for the local code theorem. -/
noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerTanh

/-- Unlike the global carrier code, this is the union of selected odd rails
with no common carrier, exactly as in the paper's local-code corollary. -/
def oddRailTransversal {m d : ℕ} (B : Fin m→Bool→Finset (Fin d))
    (s : Fin m→Bool) : Finset (Fin d) := Finset.univ.biUnion (fun i=>B i (s i))

def PairwiseDisjointRails {m d : ℕ} (B : Fin m→Bool→Finset (Fin d)) : Prop :=
  ∀i a j b,(i,a)≠(j,b) → Disjoint (B i a) (B j b)

lemma oddRailTransversal_difference_three {m d : ℕ}
    (B : Fin m→Bool→Finset (Fin d)) (hdisj : PairwiseDisjointRails B)
    (hsize : ∀i a,3≤(B i a).card) (s t : Fin m→Bool) (hne : s≠t) :
    3≤(oddRailTransversal B s\oddRailTransversal B t).card := by
  obtain ⟨i,hi⟩ : ∃i,s i≠t i := by
    by_contra h
    push_neg at h
    exact hne (funext h)
  have hsub : B i (s i)⊆oddRailTransversal B s\oddRailTransversal B t := by
    intro j hj
    refine Finset.mem_sdiff.mpr ⟨Finset.mem_biUnion.mpr ⟨i,Finset.mem_univ _,hj⟩,?_⟩
    intro hmem
    obtain ⟨l,hl,hjl⟩ := Finset.mem_biUnion.mp hmem
    have hne' : (i,s i)≠(l,t l) := by
      intro he
      have hil := congrArg Prod.fst he
      have hst := congrArg Prod.snd he
      simp only [Prod.fst] at hil
      subst l
      exact hi hst
    exact Finset.disjoint_left.mp (hdisj i (s i) l (t l) hne') hj hjl
  exact (hsize i (s i)).trans (Finset.card_le_card hsub)

lemma oddRailTransversal_card {m d : ℕ} (B : Fin m→Bool→Finset (Fin d))
    (hdisj : PairwiseDisjointRails B) (s : Fin m→Bool) :
    (oddRailTransversal B s).card=∑i,(B i (s i)).card := by
  apply Finset.card_biUnion
  intro i hi j hj hne
  exact hdisj i (s i) j (s j) (fun he=>hne (congrArg Prod.fst he))

lemma oddRailTransversal_odd {m d : ℕ} (B : Fin m→Bool→Finset (Fin d))
    (hdisj : PairwiseDisjointRails B) (hm : Odd m)
    (hodd : ∀i a,Odd (B i a).card) (s : Fin m→Bool) :
    Odd (oddRailTransversal B s).card := by
  rw [oddRailTransversal_card B hdisj,Nat.odd_iff,Finset.sum_nat_mod]
  have hmod (i : Fin m) : (B i (s i)).card%2=1 := Nat.odd_iff.mp (hodd i (s i))
  simp_rw [hmod]
  simpa only [Finset.sum_const,Finset.card_univ,Fintype.card_fin,smul_eq_mul,mul_one] using Nat.odd_iff.mp hm

end NeuralGeneralization.OnlineLowerTanh
