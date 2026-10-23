import NeuralGeneralization.BatchTwoOnlineAdapted

/-!
# The predictable stopping rule for random-order cumulative errors
-/
noncomputable section
open scoped BigOperators
open Classical
attribute [local instance] Classical.propDecidable

namespace NeuralGeneralization.BatchTwoOnline
open SquaredSampling

variable {H : Type*} [Fintype H] [DecidableEq H] {m : ℕ}

lemma prefixKeep_swap_later (good : H → Fin m → Prop) (π : Equiv.Perm (Fin m))
    (n : ℕ) (i j : Fin m) (hni : n ≤ i.val) (hij : i.val ≤ j.val) :
    prefixKeep good (π*Equiv.swap i j) n = prefixKeep good π n := by
  funext g
  apply propext
  have he (k : Fin m) (hk : k.val < n) : Equiv.swap i j k=k := by
    apply Equiv.swap_apply_of_ne_of_ne  <;> intro h  <;> subst k  <;> omega
  constructor  <;> intro h k hk  <;>
    simpa only [Equiv.Perm.mul_apply, he k hk] using h k hk

def goodUpTo (A : Finset H) (good : H → Fin m → Prop) (a : ℝ)
    (n : ℕ) (π : Equiv.Perm (Fin m)) : Prop :=
  ∀ k : Fin m, 0 < k.val → k.val ≤ n → ∀ g∈A,
    prefixKeep good π k.val g → domainError good g  ≤  a/k.val

lemma goodUpTo_zero (A : Finset H) (good : H → Fin m → Prop) (a : ℝ) (π) :
    goodUpTo A good a 0 π := by intro k hk hkn; omega

lemma goodUpTo_mono (A : Finset H) (good : H → Fin m → Prop) (a : ℝ)
    {n t : ℕ} (hnt : n ≤ t) (π) (h : goodUpTo A good a t π) : goodUpTo A good a n π :=
  fun k hk hkn => h k hk (hkn.trans hnt)

lemma goodUpTo_swap (A : Finset H) (good : H → Fin m → Prop) (a : ℝ)
    (n : ℕ) (π : Equiv.Perm (Fin m)) (i j : Fin m) (hni : n ≤ i.val) (hij : i.val ≤ j.val) :
    goodUpTo A good a n (π*Equiv.swap i j) ↔ goodUpTo A good a n π := by
  constructor
  · intro h k hk hkn g hg hkeep
    apply h k hk hkn g hg
    simpa only [prefixKeep_swap_later good π k.val i j (hkn.trans hni) hij] using hkeep
  · intro h k hk hkn g hg hkeep
    apply h k hk hkn g hg
    simpa only [prefixKeep_swap_later good π k.val i j (hkn.trans hni) hij] using hkeep

def stoppedRound (w : H → ℝ) (A : Finset H) (good : H → Fin m → Prop) (a : ℝ)
    (i : Fin m) (π : Equiv.Perm (Fin m)) : ℝ :=
  if goodUpTo A good a i.val π then permutationRound w good π i else 0

lemma permutationRound_nonneg (w : H → ℝ) (hw : ∀ g, 0 ≤ w g) (good : H → Fin m → Prop)
    (target : H) (htarget : ∀ x, good target x) (hwt : 0 < w target)
    (π : Equiv.Perm (Fin m)) (i : Fin m) : 0 ≤ permutationRound w good π i :=
  Finset.sum_nonneg fun g _ => mul_nonneg (posterior_nonneg w _ hw target
    (fun j _ => htarget (π j)) hwt g) (pointLoss_nonneg good g _)

lemma stoppedRound_range (w : H → ℝ) (hw : ∀ g, 0 ≤ w g) (good : H → Fin m → Prop)
    (target : H) (htarget : ∀ x, good target x) (hwt : 0 < w target)
    (A : Finset H) (a : ℝ) (i : Fin m) (π) :
    0 ≤ stoppedRound w A good a i π ∧ stoppedRound w A good a i π ≤ 1 := by
  unfold stoppedRound
  split_ifs
  · exact ⟨permutationRound_nonneg w hw good target htarget hwt π i,
      permutationRound_le_one w hw good target htarget hwt π i⟩
  · norm_num

lemma stoppedRound_adapted (w : H → ℝ) (A : Finset H) (good : H → Fin m → Prop)
    (a : ℝ) (i k j : Fin m) (π) (hik : i.val < k.val) (hkj : k.val ≤ j.val) :
    stoppedRound w A good a i (π*Equiv.swap k j)=stoppedRound w A good a i π := by
  have he : Equiv.swap k j i=i := by
    apply Equiv.swap_apply_of_ne_of_ne  <;> intro h  <;> subst i  <;> omega
  unfold stoppedRound permutationRound
  simp only [goodUpTo_swap A good a i.val π k j hik.le hkj,
    prefixKeep_swap_later good π i.val k j hik.le hkj, Equiv.Perm.mul_apply, he]

lemma remainingAverage_round (w : H → ℝ) (good : H → Fin m → Prop)
    (i : Fin m) (π : Equiv.Perm (Fin m)) :
    remainingAverage (fun ρ => permutationRound w good ρ i) i π =
      ∑ g, posterior w (prefixKeep good π i.val) g * remainingLoss good π i.val g := by
  unfold remainingAverage remainingLoss permutationRound
  simp_rw [← mul_div_assoc, ← Finset.sum_div]
  congr 1
  simp_rw [Finset.mul_sum]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro j _
  by_cases hj : i.val ≤ j.val
  · simp only [hj, if_true, prefixKeep_swap good π i j hj,
      Equiv.Perm.mul_apply, Equiv.swap_apply_left]
  · simp [hj]

lemma remainingAverage_stopped (w : H → ℝ) (A : Finset H)
    (good : H → Fin m → Prop) (a : ℝ) (i : Fin m) (π) :
    remainingAverage (stoppedRound w A good a i) i π =
      if goodUpTo A good a i.val π then
        ∑ g, posterior w (prefixKeep good π i.val) g * remainingLoss good π i.val g else 0 := by
  by_cases hgood : goodUpTo A good a i.val π
  · rw [if_pos hgood, ← remainingAverage_round]
    unfold remainingAverage
    congr 1
    apply Finset.sum_congr rfl
    intro j _
    by_cases hj : i.val ≤ j.val
    · have hg := (goodUpTo_swap A good a i.val π i j le_rfl hj).mpr hgood
      simp [hj, stoppedRound, hg]
    · simp [hj]
  · rw [if_neg hgood]
    unfold remainingAverage
    have hs : (∑ j : Fin m, if i.val ≤ j.val then stoppedRound w A good a i (π*Equiv.swap i j) else 0)=0 := by
      apply Finset.sum_eq_zero
      intro j _
      by_cases hj : i.val ≤ j.val
      · have hg : ¬goodUpTo A good a i.val (π*Equiv.swap i j) := by
          intro h
          exact hgood ((goodUpTo_swap A good a i.val π i j le_rfl hj).mp h)
        simp [hj, stoppedRound, hg]
      · simp [hj]
    rw [hs, zero_div]

def stoppingBudget (m : ℕ) (a β : ℝ) (i : Fin m) : ℝ :=
  if i.val=0 then 1+β else (m : ℝ)/(m-i.val : ℕ)*(a/i.val)+β

lemma remainingAverage_stopped_le
    (w : H → ℝ) (hw : ∀ g, 0 ≤ w g) (good : H → Fin m → Prop)
    (target : H) (htarget : ∀ x, good target x) (hwt : 0 < w target)
    (A : Finset H) (a β : ℝ) (ha : 0 ≤ a) (hβ : 0 ≤ β)
    (htail : (∑ g∈Finset.univ \ A, w g)/w target ≤ β)
    (i : Fin m) (π) :
    remainingAverage (stoppedRound w A good a i) i π  ≤  stoppingBudget m a β i := by
  by_cases hi : i.val=0
  · calc
      _  ≤  remainingAverage (fun _ => (1 : ℝ)) i π :=
        remainingAverage_mono (fun ρ => (stoppedRound_range w hw good target htarget hwt A a i ρ).2) i π
      _  ≤  _ := by rw [remainingAverage_const]; simp [stoppingBudget, hi, hβ]
  · have hi0 : (0 : ℝ) < i.val := by exact_mod_cast (Nat.pos_of_ne_zero hi)
    rw [remainingAverage_stopped]
    unfold stoppingBudget
    rw [if_neg hi]
    split_ifs with hg
    · apply posterior_risk_le w _ hw target (fun j _ => htarget (π j)) hwt
        (remainingLoss good π i.val)
        (fun g => ⟨remainingLoss_nonneg good π i.val g, remainingLoss_le_one good π i.val i.isLt g⟩)
        A ((m : ℝ)/(m-i.val : ℕ)*(a/i.val)) β (by positivity) _ htail
      intro g hAg hk
      rw [remainingLoss_eq good π i.val i.isLt g hk]
      exact mul_le_mul_of_nonneg_left (hg i (Nat.pos_of_ne_zero hi) le_rfl g hAg hk) (by positivity)
    · positivity

lemma stoppingBudget_sum (m : ℕ) (a β : ℝ) :
    (∑ i : Fin (m+1), stoppingBudget (m+1) a β i) =
      1+2*a*harmonicSum m+(m+1 : ℕ)*β := by
  rw [Fin.sum_univ_succ]
  simp only [stoppingBudget, Fin.val_zero, if_pos rfl, Fin.val_succ, Nat.add_eq_zero_iff,
    Nat.one_ne_zero, and_false, if_false]
  rw [Finset.sum_add_distrib]
  have hh := harmonic_decomposition m a
  simp only [Fin.val_succ] at hh
  rw [hh]
  simp
  ring

lemma stopped_exponential_bound (m : ℕ)
    (w : H → ℝ) (hw : ∀ g, 0 ≤ w g) (good : H → Fin (m+1) → Prop)
    (target : H) (htarget : ∀ x, good target x) (hwt : 0 < w target)
    (A : Finset H) (a β : ℝ) (ha : 0 ≤ a) (hβ : 0 ≤ β)
    (htail : (∑ g∈Finset.univ \ A, w g)/w target ≤ β) :
    finiteMean (fun π => Real.exp (∑ i, stoppedRound w A good a i π))  ≤ 
      Real.exp ((Real.exp 1-1)*(1+2*a*harmonicSum m+(m+1 : ℕ)*β)) := by
  have hb := adapted_exponential_bound (stoppedRound w A good a) (stoppingBudget (m+1) a β)
    (stoppedRound_range w hw good target htarget hwt A a)
    (fun i k j π hi hj => stoppedRound_adapted w A good a i k j π hi hj)
    (remainingAverage_stopped_le w hw good target htarget hwt A a β ha hβ htail)
  simpa only [stoppingBudget_sum] using hb

end NeuralGeneralization.BatchTwoOnline
