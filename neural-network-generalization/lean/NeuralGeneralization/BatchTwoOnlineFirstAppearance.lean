import NeuralGeneralization.BatchTwoOnlineFiniteMain
import Mathlib.Data.Fintype.Order
import Mathlib.Data.Finset.Sort

/-! # Deterministic first-appearance reduction for finite query sequences -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open Classical
attribute [local instance] Classical.propDecidable

namespace NeuralGeneralization.BatchTwoOnline
variable {m n : ℕ}

def hitSet (s : Fin n → Fin m) (x : Fin m) : Finset (Fin n) :=
  Finset.univ.filter (fun i => s i=x)

def firstKey (s : Fin n → Fin m) (x : Fin m) : ℕ :=
  if h : (hitSet s x).Nonempty then ((hitSet s x).min' h).val else n+x.val

lemma hitSet_mem (s : Fin n → Fin m) (x : Fin m) (i : Fin n) :
    i∈hitSet s x ↔ s i=x := by simp [hitSet]

lemma firstKey_le (s : Fin n → Fin m) (i : Fin n) : firstKey s (s i)  ≤  i.val := by
  have hi : i∈hitSet s (s i) := (hitSet_mem s (s i) i).mpr rfl
  have hn : (hitSet s (s i)).Nonempty := ⟨i,hi⟩
  simp only [firstKey, dif_pos hn]
  exact (hitSet s (s i)).min'_le i hi

lemma firstKey_hit (s : Fin n → Fin m) (x : Fin m) (hk : firstKey s x  <  n) :
    s ⟨firstKey s x,hk⟩=x := by
  by_cases hh : (hitSet s x).Nonempty
  · simp only [firstKey, dif_pos hh] at hk ⊢
    exact (hitSet_mem s x _).mp ((hitSet s x).min'_mem hh)
  · simp only [firstKey, dif_neg hh] at hk
    omega

lemma firstKey_injective (s : Fin n → Fin m) : Function.Injective (firstKey s) := by
  intro x y hxy
  by_cases hx : firstKey s x  <  n
  · have hy : firstKey s y  <  n := by omega
    have hxv := firstKey_hit s x hx
    have hyv := firstKey_hit s y hy
    have he : (⟨firstKey s x,hx⟩ : Fin n)=⟨firstKey s y,hy⟩ := Fin.ext hxy
    rw [he, hyv] at hxv
    exact hxv.symm
  · have hy : ¬firstKey s y  <  n := by omega
    have hxnone : ¬(hitSet s x).Nonempty := by
      intro hh
      apply hx
      simp only [firstKey, dif_pos hh]
      exact ((hitSet s x).min' hh).isLt
    have hynone : ¬(hitSet s y).Nonempty := by
      intro hh
      apply hy
      simp only [firstKey, dif_pos hh]
      exact ((hitSet s y).min' hh).isLt
    simp only [firstKey, dif_neg hxnone, dif_neg hynone] at hxy
    exact Fin.ext (Nat.add_left_cancel hxy)

/-- Every finite sequence has a complete permutation extending its first
appearance order. The choice depends only on inputs, never on the prior. -/
theorem exists_firstAppearance_permutation (s : Fin n → Fin m) :
    ∃ σ : Equiv.Perm (Fin m), ∀ x y : Fin m,
      (σ.symm x).val  <  (σ.symm y).val ↔ firstKey s x  <  firstKey s y := by
  let ord := LinearOrder.lift' (firstKey s) (firstKey_injective s)
  let e := @Fintype.orderIsoFinOfCardEq (Fin m) ord inferInstance m (Fintype.card_fin m)
  refine ⟨e.toEquiv, ?_⟩
  intro x y
  have he := @OrderIso.lt_iff_lt (Fin m) (Fin m) inferInstance ord.toPreorder e (e.toEquiv.symm x) (e.toEquiv.symm y)
  change (firstKey s (e.toEquiv (e.toEquiv.symm x)) <
    firstKey s (e.toEquiv (e.toEquiv.symm y)) ↔
    (e.toEquiv.symm x).val < (e.toEquiv.symm y).val) at he
  simpa only [Equiv.apply_symm_apply] using he.symm

def firstPositions (s : Fin n → Fin m) : Finset (Fin n) :=
  Finset.univ.filter (fun i => ∀ j : Fin n, j.val  <  i.val → s j≠s i)

lemma mem_firstPositions (s : Fin n → Fin m) (i : Fin n) :
    i∈firstPositions s ↔ firstKey s (s i)=i.val := by
  simp only [firstPositions, Finset.mem_filter, Finset.mem_univ, true_and]
  constructor
  · intro h
    have hle := firstKey_le s i
    by_contra he
    have hlt : firstKey s (s i) < i.val := lt_of_le_of_ne hle he
    have hk := firstKey_hit s (s i) (hlt.trans i.isLt)
    exact h ⟨firstKey s (s i), hlt.trans i.isLt⟩ hlt hk
  · intro he j hj hji
    have hle := firstKey_le s j
    rw [hji,he] at hle
    omega

lemma firstPositions_injective (s : Fin n → Fin m) :
    Set.InjOn s (firstPositions s) := by
  intro i hi j hj hij
  apply Fin.ext
  rw [← (mem_firstPositions s i).mp hi, ← (mem_firstPositions s j).mp hj, hij]

/-- Extend a finite IID sample by a harmless fixed input; only the first
`n` values are used in its cumulative error. -/
def extendSample (m : ℕ) (hm : 0  <  m) {n : ℕ} (s : Fin n → Fin m) (j : ℕ) : Fin m :=
  if hj : j < n then s ⟨j,hj⟩ else ⟨0,hm⟩

variable {H : Type*} [Fintype H] [DecidableEq H]

lemma history_eq_firstAppearance_prefix
    (hm : 0  <  m) (s : Fin n → Fin m) (σ : Equiv.Perm (Fin m))
    (hσ : ∀ x y : Fin m, (σ.symm x).val  <  (σ.symm y).val ↔ firstKey s x  <  firstKey s y)
    (good : H → Fin m → Prop) (i : Fin n) (hi : i∈firstPositions s) :
    history good (extendSample m hm s) i.val = prefixKeep good σ (σ.symm (s i)).val := by
  have hkey := (mem_firstPositions s i).mp hi
  funext g
  apply propext
  constructor
  · intro h k hk
    have hlt : firstKey s (σ k) < i.val := by
      have hh := (hσ (σ k) (s i)).mp (by simpa using hk)
      simpa only [hkey] using hh
    have hjn := hlt.trans i.isLt
    have hh := h (firstKey s (σ k)) hlt
    simpa only [extendSample, dif_pos hjn, firstKey_hit s (σ k) hjn] using hh
  · intro h j hj
    have hjn := hj.trans i.isLt
    have hlt : firstKey s (s ⟨j,hjn⟩) < firstKey s (s i) := by
      rw [hkey]
      exact (firstKey_le s ⟨j,hjn⟩).trans_lt hj
    have hh := h (σ.symm (s ⟨j,hjn⟩)) ((hσ _ _).mpr hlt)
    simpa only [extendSample, dif_pos hjn, σ.apply_symm_apply] using hh

lemma onlineError_eq_firstAppearance_round
    (hm : 0  <  m) (s : Fin n → Fin m) (σ : Equiv.Perm (Fin m))
    (hσ : ∀ x y : Fin m, (σ.symm x).val  <  (σ.symm y).val ↔ firstKey s x  <  firstKey s y)
    (w : H → ℝ) (good : H → Fin m → Prop) (i : Fin n) (hi : i∈firstPositions s) :
    onlineError w good (extendSample m hm s) i.val = permutationRound w good σ (σ.symm (s i)) := by
  unfold onlineError onlinePosterior permutationRound
  simp only [history_eq_firstAppearance_prefix hm s σ hσ good i hi,
    extendSample, dif_pos i.isLt, σ.apply_symm_apply]
  apply Finset.sum_congr rfl
  intro g _
  unfold pointLoss
  split_ifs  <;> simp

lemma onlineError_zero_of_not_first
    (hm : 0  <  m) (s : Fin n → Fin m) (w : H → ℝ) (good : H → Fin m → Prop)
    (i : Fin n) (hi : i∉firstPositions s) : onlineError w good (extendSample m hm s) i.val=0 := by
  have hk : firstKey s (s i) < i.val := by
    have hle := firstKey_le s i
    have hne : firstKey s (s i)≠i.val := fun he => hi ((mem_firstPositions s i).mpr he)
    exact lt_of_le_of_ne hle hne
  apply onlineError_eq_zero_of_repeated w good (extendSample m hm s) hk
  have hkn := hk.trans i.isLt
  simp only [extendSample, dif_pos hkn, dif_pos i.isLt, firstKey_hit s (s i) hkn]

/-- Duplicate deletion preserves every incurred posterior error; completing
with unobserved inputs only adds nonnegative error. -/
theorem cumulativeError_le_firstAppearance_permutation
    (hm : 0  <  m) (s : Fin n → Fin m) (σ : Equiv.Perm (Fin m))
    (hσ : ∀ x y : Fin m, (σ.symm x).val  <  (σ.symm y).val ↔ firstKey s x  <  firstKey s y)
    (w : H → ℝ) (hw : ∀ g, 0  ≤  w g) (good : H → Fin m → Prop)
    (target : H) (htarget : ∀ x, good target x) (hwt : 0  <  w target) :
    cumulativeError w good (extendSample m hm s) n  ≤  permutationTotal w good σ := by
  have he : cumulativeError w good (extendSample m hm s) n =
      ∑ i∈firstPositions s, permutationRound w good σ (σ.symm (s i)) := by
    unfold cumulativeError
    rw [← Fin.sum_univ_eq_sum_range (onlineError w good (extendSample m hm s)) n]
    rw [← Finset.sum_subset (Finset.subset_univ (firstPositions s))
      (fun i _ hi => onlineError_zero_of_not_first hm s w good i hi)]
    exact Finset.sum_congr rfl fun i hi => onlineError_eq_firstAppearance_round hm s σ hσ w good i hi
  rw [he]
  have hinj : Set.InjOn (fun i => σ.symm (s i)) (firstPositions s) :=
    fun i hi j hj hij => firstPositions_injective s hi hj (σ.symm.injective hij)
  rw [← Finset.sum_image hinj]
  exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
    (fun i _ _ => permutationRound_nonneg w hw good target htarget hwt σ i)

end NeuralGeneralization.BatchTwoOnline
