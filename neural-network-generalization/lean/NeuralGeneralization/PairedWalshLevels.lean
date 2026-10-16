import NeuralGeneralization.FirstLayerLevelLower

/-! Finite multiplicities of the bias-paired odd Walsh levels. -/
noncomputable section
namespace NeuralGeneralization

lemma pairedWalshDegree_odd {d : ℕ} (S : Finset (Fin d)) :
    Odd (pairedWalshDegree S) := by
  unfold pairedWalshDegree
  split_ifs with he
  · exact he.add_odd (by decide : Odd 1)
  · exact Nat.not_even_iff_odd.mp he

lemma card_le_pairedWalshDegree {d : ℕ} (S : Finset (Fin d)) :
    S.card ≤ pairedWalshDegree S := by
  unfold pairedWalshDegree
  split_ifs <;> omega

lemma pairedWalshDegree_le_card_add_one {d : ℕ} (S : Finset (Fin d)) :
    pairedWalshDegree S ≤ S.card+1 := by
  unfold pairedWalshDegree
  split_ifs <;> omega

lemma odd_cutoff_le_pairedWalshDegree {d r : ℕ} (S : Finset (Fin d))
    (hr : Odd r) (hSr : r < S.card) : r+2 ≤ pairedWalshDegree S := by
  have hle := card_le_pairedWalshDegree S
  have hodd := pairedWalshDegree_odd S
  obtain ⟨a,ha⟩ := hr
  obtain ⟨b,hb⟩ := hodd
  omega

lemma pairedWalshDegree_ge_of_odd {d k : ℕ} (S : Finset (Fin d))
    (hk : Odd k) (hS : k-1 ≤ S.card) : k ≤ pairedWalshDegree S := by
  have hle := card_le_pairedWalshDegree S
  have hodd := pairedWalshDegree_odd S
  obtain ⟨a,ha⟩ := hk
  obtain ⟨b,hb⟩ := hodd
  omega

lemma pairedWalshDegree_fiber_card_le (d j : ℕ) :
    (Finset.univ.filter (fun S : Finset (Fin d) => pairedWalshDegree S=j)).card ≤
      (d+1).choose j := by
  classical
  cases j with
  | zero =>
    have hz : (Finset.univ.filter
        (fun S : Finset (Fin d) => pairedWalshDegree S=0)) = ∅ := by
      ext S
      simp only [Finset.mem_filter,Finset.mem_univ,true_and,Finset.notMem_empty,iff_false]
      have h := (pairedWalshDegree_bounds S).1
      omega
    rw [hz]
    simp
  | succ j =>
    have hsub : (Finset.univ.filter
        (fun S : Finset (Fin d) => pairedWalshDegree S=j+1)) ⊆
        (Finset.univ.powersetCard j ∪ Finset.univ.powersetCard (j+1)) := by
      intro S hS
      have heq : pairedWalshDegree S=j+1 := (Finset.mem_filter.mp hS).2
      unfold pairedWalshDegree at heq
      split_ifs at heq with he
      · apply Finset.mem_union_left
        simp only [Finset.mem_powersetCard,Finset.subset_univ,true_and]
        omega
      · apply Finset.mem_union_right
        simp only [Finset.mem_powersetCard,Finset.subset_univ,true_and]
        exact heq
    calc
      _ ≤ (Finset.univ.powersetCard j ∪ Finset.univ.powersetCard (j+1)).card :=
        Finset.card_le_card hsub
      _ ≤ (Finset.univ.powersetCard j : Finset (Finset (Fin d))).card +
          (Finset.univ.powersetCard (j+1) : Finset (Finset (Fin d))).card :=
        Finset.card_union_le _ _
      _ = (d+1).choose (j+1) := by
        simp only [Finset.card_powersetCard,Finset.card_univ,Fintype.card_fin]
        exact (Nat.choose_succ_succ' d j).symm

end NeuralGeneralization
