import NeuralGeneralization.SquaredSamplingBound
import Mathlib.Logic.Equiv.Fintype

/-! Finite permutation coupling between IID samples and independent selectors. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.SquaredSampling
open Classical
attribute [local instance] Classical.propDecidable

variable {V α : Type*} [Fintype V] [DecidableEq V] [Fintype α] [Nonempty α]

def finiteEvent (E : α → Prop) : ℝ := finiteMean (fun x => if E x then 1 else 0)

lemma finiteEvent_nonneg (E : α → Prop) : 0 ≤ finiteEvent E :=
  finiteMean_nonneg (fun x => by split_ifs <;> norm_num)

lemma finiteEvent_le_one (E : α → Prop) : finiteEvent E ≤ 1 := by
  simpa only [finiteEvent, finiteMean_const] using finiteMean_mono (fun x => show (if E x then (1:ℝ) else 0) ≤ 1 by split_ifs <;> norm_num)

lemma finiteEvent_compl (E : α → Prop) : finiteEvent (fun x => ¬ E x)=1-finiteEvent E := by
  unfold finiteEvent
  calc
    _ = finiteMean (fun x => 1-(if E x then (1:ℝ) else 0)) := by
      congr 1
      funext x
      by_cases h : E x <;> simp [h]
    _ = _ := by rw [finiteMean_sub, finiteMean_const]

def permutedEvent (bad : Finset V → Prop) (S : Finset V) : ℝ :=
  finiteEvent (fun π : Equiv.Perm V => bad (S.image π))

lemma permutedEvent_nonneg (bad : Finset V → Prop) (S : Finset V) : 0 ≤ permutedEvent bad S :=
  finiteEvent_nonneg _

lemma permutedEvent_same_card (bad : Finset V → Prop) (S T : Finset V) (hcard : S.card=T.card) :
    permutedEvent bad S=permutedEvent bad T := by
  obtain ⟨σ, hσ⟩ := Equiv.Perm.exists_map_finset_eq S T hcard
  have hσ' : S.image σ=T := by
    calc S.image σ = S.map σ.toEmbedding := by
           ext v
           simp only [Finset.mem_image, Finset.mem_map, Equiv.toEmbedding_apply]
         _ = T := hσ
  have he (π : Equiv.Perm V) : S.image (π*σ) = T.image π := by
    rw [← hσ', Finset.image_image]
    rfl
  have h := finiteMean_equiv (Equiv.mulRight σ)
    (fun π : Equiv.Perm V => if bad (S.image π) then (1:ℝ) else 0)
  change finiteMean (fun π : Equiv.Perm V => if bad (S.image (π*σ)) then (1:ℝ) else 0) = _ at h
  simp_rw [he] at h
  exact h.symm

lemma permutedEvent_mono (bad : Finset V → Prop)
    (hbad : ∀ S T : Finset V, S ⊆ T → bad S → bad T) {S T : Finset V} (hST : S ⊆ T) :
    permutedEvent bad S ≤ permutedEvent bad T := by
  apply finiteMean_mono
  intro π
  by_cases h : bad (S.image π)
  · rw [if_pos h, if_pos (hbad _ _ (Finset.image_subset_image hST) h)]
  · rw [if_neg h]
    split_ifs <;> norm_num

def selectedSet (choose : α → Bool) (ω : V → α) : Finset V :=
  Finset.univ.filter (fun v => choose (ω v)=true)

lemma selectedSet_permute (choose : α → Bool) (ω : V → α) (π : Equiv.Perm V) :
    (selectedSet choose ω).image π=selectedSet choose (fun v => ω (π.symm v)) := by
  ext v
  simp only [selectedSet, Finset.mem_image, Finset.mem_filter, Finset.mem_univ, true_and]
  constructor
  · rintro ⟨u, hu, rfl⟩
    simpa only [Equiv.symm_apply_apply] using hu
  · intro hv
    exact ⟨π.symm v, hv, π.apply_symm_apply v⟩

lemma selectedEvent_permutation_invariant (choose : α → Bool) (bad : Finset V → Prop)
    (π : Equiv.Perm V) :
    finiteEvent (fun ω : V → α => bad ((selectedSet choose ω).image π)) =
      finiteEvent (fun ω : V → α => bad (selectedSet choose ω)) := by
  have h := finiteMean_equiv (Equiv.arrowCongr π (Equiv.refl α))
    (fun ω : V → α => if bad (selectedSet choose ω) then (1:ℝ) else 0)
  change finiteMean (fun ω : V → α => if bad (selectedSet choose (fun v => ω (π.symm v))) then (1:ℝ) else 0) = _ at h
  simpa only [finiteEvent, selectedSet_permute] using h

lemma selectedEvent_eq_average_permuted (choose : α → Bool) (bad : Finset V → Prop) :
    finiteEvent (fun ω : V → α => bad (selectedSet choose ω)) =
      finiteMean (fun ω : V → α => permutedEvent bad (selectedSet choose ω)) := by
  change _ = finiteMean (fun ω : V → α => finiteMean (fun π : Equiv.Perm V => if bad ((selectedSet choose ω).image π) then 1 else 0))
  rw [finiteMean_comm]
  simp_rw [show ∀ π : Equiv.Perm V,
    finiteMean (fun ω : V → α => if bad ((selectedSet choose ω).image π) then (1:ℝ) else 0)=
      finiteEvent (fun ω : V → α => bad (selectedSet choose ω)) from
    fun π => selectedEvent_permutation_invariant choose bad π]
  rw [finiteMean_const]

/-- Permutation averaging avoids conditioning on the selector cardinality.
Every sufficiently large chosen set contains a uniformly permuted n-subset. -/
theorem selector_dominates_permuted_subset (choose : α → Bool) (bad : Finset V → Prop)
    (hbad : ∀ S T : Finset V, S ⊆ T → bad S → bad T) (T : Finset V) :
    finiteEvent (fun ω : V → α => T.card ≤ (selectedSet choose ω).card) * permutedEvent bad T ≤
      finiteEvent (fun ω : V → α => bad (selectedSet choose ω)) := by
  have hpoint (ω : V → α) :
      (if T.card ≤ (selectedSet choose ω).card then (1:ℝ) else 0)*permutedEvent bad T ≤
        permutedEvent bad (selectedSet choose ω) := by
    by_cases hsize : T.card ≤ (selectedSet choose ω).card
    · rw [if_pos hsize, one_mul]
      obtain ⟨A, hAS, hcard⟩ := Finset.exists_subset_card_eq hsize
      rw [permutedEvent_same_card bad T A hcard.symm]
      exact permutedEvent_mono bad hbad hAS
    · rw [if_neg hsize, zero_mul]
      exact permutedEvent_nonneg bad _
  have hh := finiteMean_mono hpoint
  rw [← selectedEvent_eq_average_permuted choose bad] at hh
  have he : finiteMean (fun ω : V → α =>
      (if T.card ≤ (selectedSet choose ω).card then (1:ℝ) else 0)*permutedEvent bad T) =
      finiteEvent (fun ω : V → α => T.card ≤ (selectedSet choose ω).card)*permutedEvent bad T := by
    simp only [finiteEvent, mul_comm _ (permutedEvent bad T), finiteMean_mul]
    congr 1
    congr 1
    funext ω
    split_ifs <;> rfl
  rwa [he] at hh

variable [Nonempty V]

def sampleRange {n : ℕ} (s : Fin n → V) : Finset V := Finset.univ.image s

lemma sampleRange_permute {n : ℕ} (s : Fin n → V) (π : Equiv.Perm V) :
    sampleRange (fun i => π (s i))=(sampleRange s).image π := by
  simp only [sampleRange, Finset.image_image, Function.comp_def]

lemma iidRangeEvent_permutation_invariant (n : ℕ) (bad : Finset V → Prop) (π : Equiv.Perm V) :
    finiteEvent (fun s : Fin n → V => bad ((sampleRange s).image π)) =
      finiteEvent (fun s : Fin n → V => bad (sampleRange s)) := by
  have h := finiteMean_equiv (Equiv.arrowCongr (Equiv.refl (Fin n)) π)
    (fun s : Fin n → V => if bad (sampleRange s) then (1:ℝ) else 0)
  change finiteMean (fun s : Fin n → V => if bad (sampleRange (fun i => π (s i))) then (1:ℝ) else 0) = _ at h
  simpa only [sampleRange_permute, finiteEvent] using h

lemma iidRangeEvent_eq_average_permuted (n : ℕ) (bad : Finset V → Prop) :
    finiteEvent (fun s : Fin n → V => bad (sampleRange s)) =
      finiteMean (fun s : Fin n → V => permutedEvent bad (sampleRange s)) := by
  change _ = finiteMean (fun s : Fin n → V => finiteMean (fun π : Equiv.Perm V => if bad ((sampleRange s).image π) then 1 else 0))
  rw [finiteMean_comm]
  simp_rw [show ∀ π : Equiv.Perm V,
    finiteMean (fun s : Fin n → V => if bad ((sampleRange s).image π) then (1:ℝ) else 0)=
      finiteEvent (fun s : Fin n → V => bad (sampleRange s)) from
    fun π => iidRangeEvent_permutation_invariant n bad π]
  rw [finiteMean_const]

lemma sampleRange_card_of_injective {n : ℕ} (s : Fin n → V) (hs : Function.Injective s) :
    (sampleRange s).card=n := by
  rw [sampleRange, Finset.card_image_of_injective _ hs, Finset.card_univ, Fintype.card_fin]

/-- Averaging a permutation after an IID sample isolates the collision
error, without any conditional uniform-distribution premise. -/
theorem iidRangeEvent_le_permuted_add_collision (n : ℕ) (bad : Finset V → Prop)
    (T : Finset V) (hT : T.card=n) :
    finiteEvent (fun s : Fin n → V => bad (sampleRange s)) ≤ permutedEvent bad T+
      finiteEvent (fun s : Fin n → V => ¬ Function.Injective s) := by
  have hp (s : Fin n → V) : permutedEvent bad (sampleRange s) ≤ permutedEvent bad T+
      (if ¬ Function.Injective s then (1:ℝ) else 0) := by
    by_cases hs : Function.Injective s
    · rw [if_neg (not_not_intro hs), add_zero,
        permutedEvent_same_card bad (sampleRange s) T ((sampleRange_card_of_injective s hs).trans hT.symm)]
    · rw [if_pos hs]
      have hh : permutedEvent bad (sampleRange s) ≤ 1 := finiteEvent_le_one _
      linarith only [hh, permutedEvent_nonneg bad T]
  rw [iidRangeEvent_eq_average_permuted]
  have hh := finiteMean_mono hp
  rw [finiteMean_add, finiteMean_const] at hh
  have he : finiteMean (fun s : Fin n → V => if ¬ Function.Injective s then (1:ℝ) else 0) =
      finiteEvent (fun s : Fin n → V => ¬ Function.Injective s) := by
    unfold finiteEvent
    congr 1
    funext s
    by_cases h : Function.Injective s <;> simp [h]
  rw [he] at hh
  exact hh

/-- Generic monotone-event comparison. The remaining collision term is
separated so it can be specialized to the exact finite birthday bound. -/
theorem iidRangeEvent_le_twice_selector_add_collision (n : ℕ) (choose : α → Bool)
    (bad : Finset V → Prop) (hbad : ∀ S T : Finset V, S ⊆ T → bad S → bad T)
    (hnV : n ≤ Fintype.card V)
    (hsize : (1:ℝ)/2 ≤ finiteEvent (fun ω : V → α => n ≤ (selectedSet choose ω).card)) :
    finiteEvent (fun s : Fin n → V => bad (sampleRange s)) ≤
      2*finiteEvent (fun ω : V → α => bad (selectedSet choose ω))+
        finiteEvent (fun s : Fin n → V => ¬ Function.Injective s) := by
  obtain ⟨T, hTsub, hT⟩ := Finset.exists_subset_card_eq
    (show n ≤ (Finset.univ : Finset V).card by simpa using hnV)
  have hd := selector_dominates_permuted_subset choose bad hbad T
  rw [hT] at hd
  have hm := mul_le_mul_of_nonneg_right hsize (permutedEvent_nonneg bad T)
  have hi := iidRangeEvent_le_permuted_add_collision n bad T hT
  nlinarith only [hd, hm, hi]

end NeuralGeneralization.SquaredSampling
