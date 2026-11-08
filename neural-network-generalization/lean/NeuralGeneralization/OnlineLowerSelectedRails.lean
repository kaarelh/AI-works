import NeuralGeneralization.OnlineLowerSamplerEquiv

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerRelu

def nativeSelectedInclusion {p : ℕ} (P : Fin p→ℕ) (i : Fin p) :
    Fin (P i) ↪ SelectedCoord P where
  toFun k := ⟨i,k⟩
  inj' := by intro k l h; simpa only [Sigma.mk.inj_iff,heq_eq_eq,true_and] using h

def nativeSelectedRail {p : ℕ} (P : Fin p→ℕ) (i : Fin p) : Finset (SelectedCoord P) :=
  Finset.univ.map (nativeSelectedInclusion P i)

@[simp] theorem mem_nativeSelectedRail {p : ℕ} (P : Fin p→ℕ)
    (i : Fin p) (a : SelectedCoord P) : a∈nativeSelectedRail P i ↔ a.1=i := by
  rcases a with ⟨j,k⟩
  simp only [nativeSelectedRail,Finset.mem_map,Finset.mem_univ,true_and]
  constructor
  · rintro ⟨l,h⟩
    exact (congrArg Sigma.fst h).symm
  · intro h
    subst j
    exact ⟨k,rfl⟩

@[simp] theorem nativeSelectedRail_card {p : ℕ} (P : Fin p→ℕ) (i : Fin p) :
    (nativeSelectedRail P i).card=P i := by simp [nativeSelectedRail]

theorem nativeSelectedRail_disjoint {p : ℕ} (P : Fin p→ℕ)
    {i j : Fin p} (h:i≠j) : Disjoint (nativeSelectedRail P i) (nativeSelectedRail P j) := by
  rw [Finset.disjoint_left]
  intro a ha hb
  rw [mem_nativeSelectedRail] at ha hb
  exact h (ha.symm.trans hb)

theorem nativeSelectedRail_cover {p : ℕ} (P : Fin p→ℕ) :
    Finset.univ.biUnion (nativeSelectedRail P)=Finset.univ := by
  ext a
  simp only [Finset.mem_biUnion,Finset.mem_univ,true_and,mem_nativeSelectedRail,iff_true]
  exact ⟨a.1,rfl⟩

def nativeDistinguished {p : ℕ} (P : Fin p→ℕ) (hP:∀i,0<P i) (i:Fin p) : SelectedCoord P :=
  ⟨i,⟨0,hP i⟩⟩

def nativeBlocks {p : ℕ} (P : Fin p→ℕ) (hP:∀i,0<P i) (i:Fin p) : Finset (SelectedCoord P) :=
  (nativeSelectedRail P i).erase (nativeDistinguished P hP i)

@[simp] theorem nativeDistinguished_mem {p : ℕ} (P : Fin p→ℕ) (hP:∀i,0<P i) (i:Fin p) :
    nativeDistinguished P hP i ∈nativeSelectedRail P i := by simp [nativeDistinguished]

@[simp] theorem nativeDistinguished_not_mem_blocks {p : ℕ}
    (P : Fin p→ℕ) (hP:∀i,0<P i) (i:Fin p) :
    nativeDistinguished P hP i ∉nativeBlocks P hP i := by simp [nativeBlocks]

@[simp] theorem nativeBlocks_insert {p : ℕ} (P : Fin p→ℕ) (hP:∀i,0<P i) (i:Fin p) :
    insert (nativeDistinguished P hP i) (nativeBlocks P hP i)=nativeSelectedRail P i := by
  exact Finset.insert_erase (nativeDistinguished_mem P hP i)

theorem nativeBlocks_card {p : ℕ} (P : Fin p→ℕ) (hP:∀i,0<P i) (i:Fin p) :
    (nativeBlocks P hP i).card=P i-1 := by
  rw [nativeBlocks,Finset.card_erase_of_mem (nativeDistinguished_mem P hP i),nativeSelectedRail_card]

theorem nativeSelectedRail_sum {p : ℕ} (P : Fin p→ℕ) (i:Fin p)
    (f:SelectedCoord P→ℝ) :
    (∑ a∈nativeSelectedRail P i,f a)=∑ k:Fin (P i),f ⟨i,k⟩ := by
  simp [nativeSelectedRail,nativeSelectedInclusion]

theorem nativeSelectedRail_prod {p : ℕ} (P : Fin p→ℕ) (i:Fin p)
    (f:SelectedCoord P→ℝ) :
    (∏ a∈nativeSelectedRail P i,f a)=∏ k:Fin (P i),f ⟨i,k⟩ := by
  simp [nativeSelectedRail,nativeSelectedInclusion]

theorem nativeBlocks_sum {p : ℕ} (P : Fin p→ℕ) (hP:∀i,0<P i) (i:Fin p)
    (f:SelectedCoord P→ℝ) :
    f (nativeDistinguished P hP i)+(∑ a∈nativeBlocks P hP i,f a)=
      ∑ k:Fin (P i),f ⟨i,k⟩ := by
  rw [←Finset.sum_insert (nativeDistinguished_not_mem_blocks P hP i),
    nativeBlocks_insert,nativeSelectedRail_sum]

theorem nativeBlocks_prod {p : ℕ} (P : Fin p→ℕ) (hP:∀i,0<P i) (i:Fin p)
    (f:SelectedCoord P→ℝ) :
    f (nativeDistinguished P hP i)*(∏ a∈nativeBlocks P hP i,f a)=
      ∏ k:Fin (P i),f ⟨i,k⟩ := by
  rw [←Finset.prod_insert (nativeDistinguished_not_mem_blocks P hP i),
    nativeBlocks_insert,nativeSelectedRail_prod]

end NeuralGeneralization.OnlineLowerRelu
