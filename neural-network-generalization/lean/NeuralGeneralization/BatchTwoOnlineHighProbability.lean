import NeuralGeneralization.BatchTwoOnlineStopping

/-!
# Exact high-probability cumulative posterior-error theorem
-/
noncomputable section
open scoped BigOperators
open Classical
attribute [local instance] Classical.propDecidable

namespace NeuralGeneralization.BatchTwoOnline
open SquaredSampling

variable {Ω I H : Type*} [Fintype Ω] [Nonempty Ω] [Fintype H] [DecidableEq H]

lemma finiteMean_finset_sum (s : Finset I) (F : I → Ω → ℝ) :
    finiteMean (fun ω => ∑ i ∈ s, F i ω) = ∑ i ∈ s, finiteMean (F i) := by
  unfold finiteMean
  rw [Finset.sum_comm, Finset.sum_div]

lemma finiteEvent_mono {E F : Ω → Prop} (h : ∀ ω, E ω → F ω) :
    finiteEvent E ≤ finiteEvent F :=
  finiteMean_mono fun ω => by
    by_cases he : E ω
    · simp [he, h ω he]
    · simp only [he, if_false]; split_ifs <;> norm_num

lemma finiteEvent_union (E F : Ω → Prop) :
    finiteEvent (fun ω => E ω ∨ F ω) ≤ finiteEvent E+finiteEvent F := by
  unfold finiteEvent
  rw [← finiteMean_add]
  apply finiteMean_mono
  intro ω
  by_cases he : E ω <;> by_cases hf : F ω <;> simp [he, hf]

lemma finiteEvent_exists_finset [DecidableEq I] (s : Finset I) (E : I → Ω → Prop) :
    finiteEvent (fun ω => ∃ i∈s, E i ω) ≤ ∑ i∈s, finiteEvent (E i) := by
  unfold finiteEvent
  rw [← finiteMean_finset_sum]
  apply finiteMean_mono
  intro ω
  by_cases hex : ∃ i∈s, E i ω
  · obtain ⟨i,hi,he⟩ := hex
    rw [if_pos ⟨i,hi,he⟩]
    calc
      (1 : ℝ) = (if E i ω then (1 : ℝ) else 0) := by simp [he]
      _ ≤ _ := Finset.single_le_sum (f := fun j => if E j ω then (1 : ℝ) else 0)
        (fun j _ => by split_ifs <;> norm_num) hi
  · rw [if_neg hex]
    apply Finset.sum_nonneg
    intro i _
    split_ifs <;> norm_num

variable {m : ℕ}

lemma bad_prefix_probability (A : Finset H) (good : H → Fin m → Prop)
    (h a : ℝ) (hcard : (A.card : ℝ) ≤ Real.exp h)
    (i : Fin m) (hi : 0 < i.val) :
    finiteEvent (fun π : Equiv.Perm (Fin m) => ∃ g∈A,
      prefixKeep good π i.val g ∧ a/i.val < domainError good g) ≤ Real.exp (h-a) := by
  have hiR : (0 : ℝ) < i.val := by exact_mod_cast hi
  have hsingle (g : H) (_hg : g∈A) :
      finiteEvent (fun π : Equiv.Perm (Fin m) =>
        prefixKeep good π i.val g ∧ a/i.val < domainError good g) ≤ Real.exp (-a) := by
    by_cases he : a/i.val < domainError good g
    · apply (finiteEvent_mono (fun π hπ => hπ.1)).trans
      apply (prefix_survival good g i.val i.isLt.le (Nat.zero_lt_of_lt i.isLt)).trans
      apply Real.exp_le_exp.mpr
      have ht := (div_lt_iff₀ hiR).mp he
      nlinarith
    · simp [he, finiteEvent, (Real.exp_pos (-a)).le]
  calc
    _ ≤ ∑ g∈A, finiteEvent (fun π : Equiv.Perm (Fin m) =>
        prefixKeep good π i.val g ∧ a/i.val < domainError good g) := finiteEvent_exists_finset A _
    _ ≤ ∑ _g∈A, Real.exp (-a) := Finset.sum_le_sum hsingle
    _ = (A.card : ℝ)*Real.exp (-a) := by simp
    _ ≤ Real.exp h*Real.exp (-a) := mul_le_mul_of_nonneg_right hcard (Real.exp_pos _).le
    _ = _ := by rw [← Real.exp_add, sub_eq_add_neg]

lemma bad_any_prefix_probability (A : Finset H) (good : H → Fin m → Prop)
    (h a : ℝ) (hcard : (A.card : ℝ) ≤ Real.exp h) :
    finiteEvent (fun π : Equiv.Perm (Fin m) => ¬goodUpTo A good a (m-1) π) ≤
      m*Real.exp (h-a) := by
  have he (π : Equiv.Perm (Fin m)) : ¬goodUpTo A good a (m-1) π →
      ∃ i∈(Finset.univ : Finset (Fin m)), 0 < i.val ∧ ∃ g∈A,
        prefixKeep good π i.val g ∧ a/i.val < domainError good g := by
    intro h
    unfold goodUpTo at h
    push_neg at h
    obtain ⟨i,hi,_,g,hg,hk,he⟩ := h
    exact ⟨i, Finset.mem_univ i, hi, g, hg, hk, he⟩
  apply (finiteEvent_mono he).trans
  apply (finiteEvent_exists_finset Finset.univ _).trans
  calc
    _ ≤ ∑ _i : Fin m, Real.exp (h-a) := by
      apply Finset.sum_le_sum
      intro i _
      by_cases hi : 0 < i.val
      · simpa only [hi, true_and] using bad_prefix_probability A good h a hcard i hi
      · simp [hi, finiteEvent, (Real.exp_pos (h-a)).le]
    _ = _ := by simp

lemma stopped_total_eq (w : H → ℝ) (A : Finset H) (good : H → Fin m → Prop)
    (a : ℝ) (π : Equiv.Perm (Fin m)) (hg : goodUpTo A good a (m-1) π) :
    (∑ i, stoppedRound w A good a i π) = permutationTotal w good π := by
  apply Finset.sum_congr rfl
  intro i _
  have hgi := goodUpTo_mono A good a (show i.val ≤ m-1 by omega) π hg
  simp [stoppedRound, hgi]

/-- Exact displayed high-probability bound for cumulative posterior error.
All constants match the finite relevant-class theorem in the manuscript. -/
theorem permutationTotal_high_probability (m : ℕ)
    (w : H → ℝ) (hw : ∀ g, 0 ≤ w g) (good : H → Fin (m+1) → Prop)
    (target : H) (htarget : ∀ x, good target x) (hwt : 0 < w target)
    (A : Finset H) (h β δ : ℝ) (hh : 0 ≤ h) (hβ : 0 ≤ β)
    (hδ : 0 < δ) (hδ1 : δ < 1) (hcard : (A.card : ℝ) ≤ Real.exp h)
    (htail : (∑ g∈Finset.univ \ A, w g)/w target ≤ β) :
    let a := h+Real.log (2*(m+1 : ℕ)/δ)
    let B := 1+2*a*harmonicSum m+(m+1 : ℕ)*β
    finiteEvent (fun π : Equiv.Perm (Fin (m+1)) =>
      (Real.exp 1-1)*B+Real.log (2/δ) < permutationTotal w good π) ≤ δ := by
  dsimp only
  let a := h+Real.log (2*(m+1 : ℕ)/δ)
  let B := 1+2*a*harmonicSum m+(m+1 : ℕ)*β
  have ha : 0 ≤ a := by
    apply add_nonneg hh
    apply Real.log_nonneg
    apply (one_le_div hδ).mpr
    have hm : (1 : ℝ) ≤ (m+1 : ℕ) := by exact_mod_cast Nat.succ_pos m
    linarith
  have hbad : finiteEvent (fun π : Equiv.Perm (Fin (m+1)) =>
      ¬goodUpTo A good a m π) ≤ δ/2 := by
    have hb := bad_any_prefix_probability A good h a hcard
    simp only [Nat.add_sub_cancel] at hb
    apply hb.trans
    have harg : 0 < (2 : ℝ)*(m+1 : ℕ)/δ := by positivity
    have he : h-a = -Real.log ((2 : ℝ)*(m+1 : ℕ)/δ) := by dsimp [a]; ring
    rw [he, Real.exp_neg, Real.exp_log harg]
    have hm : ((m+1 : ℕ) : ℝ) ≠ 0 := by positivity
    field_simp
    norm_num
  have hstop : finiteEvent (fun π : Equiv.Perm (Fin (m+1)) =>
      (Real.exp 1-1)*B+Real.log (2/δ) < ∑ i, stoppedRound w A good a i π) ≤ δ/2 := by
    have hb := finiteEvent_tail_of_moment (fun π => ∑ i, stoppedRound w A good a i π)
      ((Real.exp 1-1)*B) (δ/2) (by linarith)
      (stopped_exponential_bound m w hw good target htarget hwt A a β ha hβ htail)
    have he : 1/(δ/2) = 2/δ := by ring
    simpa only [he] using hb
  have he (π : Equiv.Perm (Fin (m+1))) :
      (Real.exp 1-1)*B+Real.log (2/δ) < permutationTotal w good π →
      ¬goodUpTo A good a m π ∨
        (Real.exp 1-1)*B+Real.log (2/δ) < ∑ i, stoppedRound w A good a i π := by
    intro hp
    by_cases hg : goodUpTo A good a m π
    · right
      rwa [stopped_total_eq w A good a π (by simpa using hg)]
    · exact Or.inl hg
  apply (finiteEvent_mono he).trans
  apply (finiteEvent_union _ _).trans
  linarith

end NeuralGeneralization.BatchTwoOnline
