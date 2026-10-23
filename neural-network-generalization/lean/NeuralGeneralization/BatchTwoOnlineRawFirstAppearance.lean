import NeuralGeneralization.BatchTwoOnlineIIDFinite

/-! Duplicate deletion and finite IID domination for arbitrary set-dependent
posterior risks. Only consistency on previously queried points is used. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open Classical
namespace NeuralGeneralization.BatchTwoOnlineRaw
open BatchTwoOnline SquaredSampling
variable {m n : ℕ}

def seenSet (s : Fin n → Fin m) (i : Fin n) : Finset (Fin m) :=
  (Finset.univ.filter (fun j : Fin n=>j.val < i.val)).image s

def permutationSeen (π : Equiv.Perm (Fin m)) (i : Fin m) : Finset (Fin m) :=
  (Finset.univ.filter (fun j : Fin m=>j.val < i.val)).image π

def setCumulativeRisk (R : Finset (Fin m) → Fin m → ℝ) (s : Fin n → Fin m) : ℝ :=
  ∑i,R (seenSet s i) (s i)

def setPermutationRisk (R : Finset (Fin m) → Fin m → ℝ) (π : Equiv.Perm (Fin m)) : ℝ :=
  ∑i,R (permutationSeen π i) (π i)

theorem mem_seenSet (s : Fin n → Fin m) (i : Fin n) (x : Fin m) :
    x∈seenSet s i ↔ ∃j : Fin n,j.val < i.val ∧ s j=x := by
  simp [seenSet]

theorem mem_permutationSeen (π : Equiv.Perm (Fin m)) (i : Fin m) (x : Fin m) :
    x∈permutationSeen π i ↔ (π.symm x).val < i.val := by
  simp only [permutationSeen,Finset.mem_image,Finset.mem_filter,Finset.mem_univ,true_and]
  constructor
  · rintro ⟨j,hj,rfl⟩
    simpa using hj
  · intro hx
    exact ⟨π.symm x,hx,π.apply_symm_apply x⟩

theorem seenSet_firstAppearance (s : Fin n → Fin m) (σ : Equiv.Perm (Fin m))
    (hσ : ∀ x y : Fin m,(σ.symm x).val < (σ.symm y).val ↔ firstKey s x < firstKey s y)
    (i : Fin n) (hi : i∈firstPositions s) : seenSet s i=permutationSeen σ (σ.symm (s i)) := by
  have hkey := (mem_firstPositions s i).mp hi
  ext x
  rw [mem_seenSet,mem_permutationSeen,hσ,hkey]
  constructor
  · rintro ⟨j,hj,rfl⟩
    exact (firstKey_le s j).trans_lt hj
  · intro hx
    exact ⟨⟨firstKey s x,hx.trans i.isLt⟩,hx,firstKey_hit s x (hx.trans i.isLt)⟩

theorem setCumulativeRisk_le_firstAppearance (s : Fin n → Fin m) (σ : Equiv.Perm (Fin m))
    (hσ : ∀ x y : Fin m,(σ.symm x).val < (σ.symm y).val ↔ firstKey s x < firstKey s y)
    (R : Finset (Fin m) → Fin m → ℝ) (hR : ∀S x,0≤R S x) (hrepeat : ∀S x,x∈S→R S x=0) :
    setCumulativeRisk R s≤setPermutationRisk R σ := by
  have hzero (i : Fin n) (hi : i∉firstPositions s) : R (seenSet s i) (s i)=0 := by
    apply hrepeat
    rw [mem_seenSet]
    have hk : firstKey s (s i) < i.val := lt_of_le_of_ne (firstKey_le s i)
      (fun he=>hi ((mem_firstPositions s i).mpr he))
    exact ⟨⟨firstKey s (s i),hk.trans i.isLt⟩,hk,firstKey_hit s (s i) (hk.trans i.isLt)⟩
  have he : setCumulativeRisk R s=∑i∈firstPositions s,R (permutationSeen σ (σ.symm (s i))) (σ (σ.symm (s i))) := by
    unfold setCumulativeRisk
    rw [←Finset.sum_subset (Finset.subset_univ (firstPositions s)) (fun i _ hi=>hzero i hi)]
    apply Finset.sum_congr rfl
    intro i hi
    rw [seenSet_firstAppearance s σ hσ i hi,σ.apply_symm_apply]
  rw [he]
  have hinj : Set.InjOn (fun i=>σ.symm (s i)) (firstPositions s) :=
    fun i hi j hj hij=>firstPositions_injective s hi hj (σ.symm.injective hij)
  rw [←Finset.sum_image (f:=fun j=>R (permutationSeen σ j) (σ j)) hinj]
  exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
    (fun i _ _=>hR _ _)

def relabelSetRisk (R : Finset (Fin m) → Fin m → ℝ) (π : Equiv.Perm (Fin m))
    (S : Finset (Fin m)) (x : Fin m) : ℝ := R (S.image π) (π x)

theorem seenSet_relabel (s : Fin n → Fin m) (π : Equiv.Perm (Fin m)) (i : Fin n) :
    seenSet (fun j=>π (s j)) i=(seenSet s i).image π := by
  simp [seenSet,Finset.image_image,Function.comp_def]

theorem permutationSeen_relabel (σ π : Equiv.Perm (Fin m)) (i : Fin m) :
    permutationSeen (π*σ) i=(permutationSeen σ i).image π := by
  simp [permutationSeen,Finset.image_image,Equiv.Perm.mul_apply,Function.comp_def]

theorem setCumulativeRisk_relabel (R : Finset (Fin m) → Fin m → ℝ)
    (s : Fin n → Fin m) (π : Equiv.Perm (Fin m)) :
    setCumulativeRisk R (fun j=>π (s j))=setCumulativeRisk (relabelSetRisk R π) s := by
  simp [setCumulativeRisk,seenSet_relabel,relabelSetRisk]

theorem setPermutationRisk_relabel (R : Finset (Fin m) → Fin m → ℝ) (σ π : Equiv.Perm (Fin m)) :
    setPermutationRisk (relabelSetRisk R π) σ=setPermutationRisk R (π*σ) := by
  simp [setPermutationRisk,relabelSetRisk,permutationSeen_relabel,Equiv.Perm.mul_apply]

theorem relabeled_setCumulativeRisk_le (R : Finset (Fin m) → Fin m → ℝ)
    (hR : ∀S x,0≤R S x) (hrepeat : ∀S x,x∈S→R S x=0) (s : Fin n → Fin m) :
    ∃σ : Equiv.Perm (Fin m),∀π,setCumulativeRisk R (fun j=>π (s j))≤setPermutationRisk R (π*σ) := by
  obtain ⟨σ,hσ⟩:=exists_firstAppearance_permutation s
  refine ⟨σ,fun π=>?_⟩
  rw [setCumulativeRisk_relabel,←setPermutationRisk_relabel]
  apply setCumulativeRisk_le_firstAppearance s σ hσ
  · intro S x
    exact hR _ _
  · intro S x hx
    exact hrepeat _ _ (Finset.mem_image.mpr ⟨x,hx,rfl⟩)

theorem expected_setCumulativeRisk_le_permutation (hm : 0 < m)
    (R : Finset (Fin m) → Fin m → ℝ) (hR : ∀S x,0≤R S x) (hrepeat : ∀S x,x∈S→R S x=0)
    (n : ℕ) : finiteMean (setCumulativeRisk (n:=n) R)≤finiteMean (setPermutationRisk R) := by
  letI : Nonempty (Fin m):=⟨⟨0,hm⟩⟩
  calc
    _ = finiteMean (fun π : Equiv.Perm (Fin m)=>finiteMean (fun s : Fin n→Fin m=>setCumulativeRisk R (fun j=>π (s j)))) := by
      simp only [finiteMean_relabel_samples,finiteMean_const]
    _ = finiteMean (fun s : Fin n→Fin m=>finiteMean (fun π : Equiv.Perm (Fin m)=>setCumulativeRisk R (fun j=>π (s j)))) := finiteMean_comm _
    _ ≤ finiteMean (fun _s : Fin n→Fin m=>finiteMean (setPermutationRisk R)) := by
      apply finiteMean_mono
      intro s
      obtain ⟨σ,hσ⟩:=relabeled_setCumulativeRisk_le R hR hrepeat s
      exact (finiteMean_mono hσ).trans_eq (finiteMean_equiv (Equiv.mulRight σ) _)
    _ = _ := finiteMean_const _

theorem setCumulativeRisk_tail_le_permutation (hm : 0 < m)
    (R : Finset (Fin m) → Fin m → ℝ) (hR : ∀S x,0≤R S x) (hrepeat : ∀S x,x∈S→R S x=0)
    (n : ℕ) (U : ℝ) :
    finiteEvent (fun s : Fin n→Fin m=>U < setCumulativeRisk R s)≤
      finiteEvent (fun π : Equiv.Perm (Fin m)=>U < setPermutationRisk R π) := by
  letI : Nonempty (Fin m):=⟨⟨0,hm⟩⟩
  unfold finiteEvent
  calc
    _ = finiteMean (fun π : Equiv.Perm (Fin m)=>finiteMean (fun s : Fin n→Fin m=>if U < setCumulativeRisk R (fun j=>π (s j)) then (1:ℝ) else 0)) := by
      have he (π : Equiv.Perm (Fin m)):=finiteMean_relabel_samples π
        (fun s : Fin n→Fin m=>if U < setCumulativeRisk R s then (1:ℝ) else 0)
      simp_rw [he]
      exact (finiteMean_const _).symm
    _ = finiteMean (fun s : Fin n→Fin m=>finiteMean (fun π : Equiv.Perm (Fin m)=>if U < setCumulativeRisk R (fun j=>π (s j)) then (1:ℝ) else 0)) := finiteMean_comm _
    _ ≤ finiteMean (fun _s : Fin n→Fin m=>finiteMean (fun π : Equiv.Perm (Fin m)=>if U < setPermutationRisk R π then (1:ℝ) else 0)) := by
      apply finiteMean_mono
      intro s
      obtain ⟨σ,hσ⟩:=relabeled_setCumulativeRisk_le R hR hrepeat s
      calc
        _ ≤ finiteMean (fun π=>if U < setPermutationRisk R (π*σ) then (1:ℝ) else 0) := by
          apply finiteMean_mono
          intro π
          by_cases he : U < setCumulativeRisk R (fun j=>π (s j))
          · simp only [if_pos he,if_pos (he.trans_le (hσ π))];exact le_rfl
          · simp only [if_neg he];split_ifs <;> norm_num
        _ = _ := finiteMean_equiv (Equiv.mulRight σ) (fun π=>if U < setPermutationRisk R π then (1:ℝ) else 0)
    _ = _ := finiteMean_const _

end NeuralGeneralization.BatchTwoOnlineRaw
