import NeuralGeneralization.BatchTwoOnlineExpectation
import NeuralGeneralization.BatchTwoPermutationSurvival
import Mathlib.Data.Finset.Interval

/-!
# Expected mistakes under an actual uniform random permutation

The input order is sampled uniformly from the finite permutation group.
Swapping two unseen positions proves the next-point averaging identity.
-/
noncomputable section
open scoped BigOperators
open Classical
attribute [local instance] Classical.propDecidable

namespace NeuralGeneralization.BatchTwoOnline
open SquaredSampling BatchTwoPermutation

variable {H : Type*} [Fintype H] [DecidableEq H] {m : ℕ}

def prefixKeep (good : H → Fin m → Prop) (π : Equiv.Perm (Fin m)) (n : ℕ)
    (g : H) : Prop := ∀ i : Fin m, i.val < n → good g (π i)

def pointLoss (good : H → Fin m → Prop) (g : H) (x : Fin m) : ℝ :=
  if good g x then 0 else 1

def domainError (good : H → Fin m → Prop) (g : H) : ℝ :=
  finiteMean (pointLoss good g)

def permutationRound (w : H → ℝ) (good : H → Fin m → Prop)
    (π : Equiv.Perm (Fin m)) (i : Fin m) : ℝ :=
  ∑ g, posterior w (prefixKeep good π i.val) g * pointLoss good g (π i)

def remainingLoss (good : H → Fin m → Prop) (π : Equiv.Perm (Fin m))
    (n : ℕ) (g : H) : ℝ :=
  (∑ i : Fin m, if n ≤ i.val then pointLoss good g (π i) else 0) / (m-n : ℕ)

lemma pointLoss_nonneg (good : H → Fin m → Prop) (g : H) (x : Fin m) :
    0 ≤ pointLoss good g x := by unfold pointLoss; split_ifs <;> norm_num

lemma pointLoss_le_one (good : H → Fin m → Prop) (g : H) (x : Fin m) :
    pointLoss good g x ≤ 1 := by unfold pointLoss; split_ifs <;> norm_num

lemma prefixKeep_swap (good : H → Fin m → Prop) (π : Equiv.Perm (Fin m))
    (i j : Fin m) (hij : i.val ≤ j.val) :
    prefixKeep good (π * Equiv.swap i j) i.val = prefixKeep good π i.val := by
  funext g
  apply propext
  have he (k : Fin m) (hk : k.val < i.val) : Equiv.swap i j k = k := by
    apply Equiv.swap_apply_of_ne_of_ne
    · intro h; subst k; omega
    · intro h; subst k; omega
  constructor <;> intro h k hk
  · simpa only [Equiv.Perm.mul_apply, he k hk] using h k hk
  · simpa only [Equiv.Perm.mul_apply, he k hk] using h k hk

lemma permutationRound_swap (w : H → ℝ) (good : H → Fin m → Prop)
    (i j : Fin m) (hij : i.val ≤ j.val) :
    finiteMean (fun π : Equiv.Perm (Fin m) => permutationRound w good π i) =
      finiteMean (fun π : Equiv.Perm (Fin m) =>
        ∑ g, posterior w (prefixKeep good π i.val) g * pointLoss good g (π j)) := by
  have he := finiteMean_equiv (Equiv.mulRight (Equiv.swap i j))
    (fun π : Equiv.Perm (Fin m) => permutationRound w good π i)
  change finiteMean (fun π : Equiv.Perm (Fin m) =>
    permutationRound w good (π * Equiv.swap i j) i) = _ at he
  symm
  convert he using 1
  congr 1
  funext π
  unfold permutationRound
  rw [prefixKeep_swap good π i j hij]
  simp only [Equiv.Perm.mul_apply, Equiv.swap_apply_left]

lemma remaining_count (n : ℕ) (hn : n ≤ m) :
    (∑ i : Fin m, if n ≤ i.val then (1 : ℝ) else 0) = (m-n : ℕ) := by
  rw [Fin.sum_univ_eq_sum_range (fun i => if n ≤ i then (1 : ℝ) else 0) m]
  rw [← Finset.sum_filter]
  simp only [Finset.sum_const, nsmul_eq_mul, mul_one]
  congr 1
  have he : (Finset.range m).filter (fun i => n ≤ i) = Finset.Ico n m := by
    ext i
    simp only [Finset.mem_filter, Finset.mem_range, Finset.mem_Ico]
    tauto
  rw [he, Nat.card_Ico]

lemma remainingLoss_nonneg (good : H → Fin m → Prop)
    (π : Equiv.Perm (Fin m)) (n : ℕ) (g : H) : 0 ≤ remainingLoss good π n g := by
  apply div_nonneg _ (Nat.cast_nonneg _)
  apply Finset.sum_nonneg
  intro i _
  split_ifs
  · exact pointLoss_nonneg good g _
  · exact le_rfl

lemma remainingLoss_le_one (good : H → Fin m → Prop)
    (π : Equiv.Perm (Fin m)) (n : ℕ) (hn : n < m) (g : H) :
    remainingLoss good π n g ≤ 1 := by
  have hd : (0 : ℝ) < (m-n : ℕ) := by exact_mod_cast Nat.sub_pos_of_lt hn
  apply (div_le_iff₀ hd).mpr
  rw [one_mul, ← remaining_count n hn.le]
  apply Finset.sum_le_sum
  intro i _
  split_ifs
  · exact pointLoss_le_one good g _
  · exact le_rfl

lemma remainingLoss_eq (good : H → Fin m → Prop)
    (π : Equiv.Perm (Fin m)) (n : ℕ) (hn : n < m) (g : H)
    (hk : prefixKeep good π n g) :
    remainingLoss good π n g = (m : ℝ) / (m-n : ℕ) * domainError good g := by
  have hm : (m : ℝ) ≠ 0 := by exact_mod_cast (Nat.ne_zero_of_lt hn)
  have hsum : (∑ i : Fin m, if n ≤ i.val then pointLoss good g (π i) else 0) =
      ∑ i : Fin m, pointLoss good g (π i) := by
    apply Finset.sum_congr rfl
    intro i _
    by_cases hi : n ≤ i.val
    · simp [hi]
    · simp [hi, pointLoss, hk i (by omega)]
  have hperm : (∑ i : Fin m, pointLoss good g (π i)) = ∑ x, pointLoss good g x :=
    Equiv.sum_comp π _
  unfold remainingLoss domainError finiteMean
  rw [hsum, hperm, Fintype.card_fin]
  field_simp

lemma permutationRound_average_remaining (w : H → ℝ) (good : H → Fin m → Prop)
    (i : Fin m) :
    finiteMean (fun π : Equiv.Perm (Fin m) => permutationRound w good π i) =
      finiteMean (fun π : Equiv.Perm (Fin m) =>
        ∑ g, posterior w (prefixKeep good π i.val) g * remainingLoss good π i.val g) := by
  let R := finiteMean (fun π : Equiv.Perm (Fin m) => permutationRound w good π i)
  have hd : (0 : ℝ) < (m-i.val : ℕ) := by exact_mod_cast Nat.sub_pos_of_lt i.isLt
  have he : (m-i.val : ℕ) * R =
      ∑ j : Fin m, if i.val ≤ j.val then
        finiteMean (fun π : Equiv.Perm (Fin m) =>
          ∑ g, posterior w (prefixKeep good π i.val) g * pointLoss good g (π j)) else 0 := by
    calc
      _ = (∑ j : Fin m, if i.val ≤ j.val then (1 : ℝ) else 0) * R := by
        rw [remaining_count i.val i.isLt.le]
      _ = _ := by
        rw [Finset.sum_mul]
        apply Finset.sum_congr rfl
        intro j _
        split_ifs with hj
        · simpa only [one_mul] using permutationRound_swap w good i j hj
        · simp
  have hright : (∑ j : Fin m, if i.val ≤ j.val then
        finiteMean (fun π : Equiv.Perm (Fin m) =>
          ∑ g, posterior w (prefixKeep good π i.val) g * pointLoss good g (π j)) else 0) =
      (m-i.val : ℕ) * finiteMean (fun π : Equiv.Perm (Fin m) =>
        ∑ g, posterior w (prefixKeep good π i.val) g * remainingLoss good π i.val g) := by
    have hif (j : Fin m) :
        (if i.val ≤ j.val then finiteMean (fun π : Equiv.Perm (Fin m) =>
          ∑ g, posterior w (prefixKeep good π i.val) g * pointLoss good g (π j)) else 0) =
        finiteMean (fun π : Equiv.Perm (Fin m) => if i.val ≤ j.val then
          ∑ g, posterior w (prefixKeep good π i.val) g * pointLoss good g (π j) else 0) := by
      split_ifs <;> simp [finiteMean_const]
    simp_rw [hif]
    rw [← finiteMean_mul, ← finiteMean_sum]
    congr 1
    funext π
    unfold remainingLoss
    simp_rw [← mul_div_assoc, ← Finset.sum_div]
    rw [mul_div_cancel₀ _ (ne_of_gt hd)]
    simp_rw [Finset.mul_sum]
    rw [Finset.sum_comm]
    apply Finset.sum_congr rfl
    intro j _
    by_cases hj : i.val ≤ j.val
    · simp only [hj, if_true, Finset.mul_sum]
    · simp only [hj, if_false, mul_zero, Finset.sum_const_zero]
  exact mul_left_cancel₀ (ne_of_gt hd) (he.trans hright)

lemma domainError_eq (good : H → Fin m → Prop) (g : H) (hm : 0 < m) :
    domainError good g =
      1 - (((Finset.univ.filter (good g)).card : ℕ) : ℝ) / m := by
  have hmR : (m : ℝ) ≠ 0 := by exact_mod_cast (Nat.ne_of_gt hm)
  have hs : (∑ x : Fin m, pointLoss good g x) +
      (∑ x : Fin m, if good g x then (1 : ℝ) else 0) = m := by
    rw [← Finset.sum_add_distrib]
    calc
      _ = ∑ _x : Fin m, (1 : ℝ) := by
        apply Finset.sum_congr rfl
        intro x _
        unfold pointLoss
        split_ifs <;> norm_num
      _ = _ := by simp
  have hc : (∑ x : Fin m, if good g x then (1 : ℝ) else 0) =
      ((Finset.univ.filter (good g)).card : ℝ) := by
    rw [← Finset.sum_filter]
    simp
  rw [hc] at hs
  unfold domainError finiteMean
  rw [Fintype.card_fin]
  field_simp
  linarith

lemma prefix_survival (good : H → Fin m → Prop) (g : H) (n : ℕ)
    (hn : n ≤ m) (hm : 0 < m) :
    finiteEvent (fun π : Equiv.Perm (Fin m) => prefixKeep good π n g) ≤
      Real.exp (-(n : ℝ) * domainError good g) := by
  letI : Nonempty (Fin m) := ⟨⟨0, hm⟩⟩
  let s : Fin n ↪ Fin m := ⟨fun i => ⟨i.val, lt_of_lt_of_le i.isLt hn⟩,
    fun _ _ h => Fin.ext (congrArg (fun i : Fin m => i.val) h)⟩
  have he (π : Equiv.Perm (Fin m)) :
      (∀ i, π (s i) ∈ Finset.univ.filter (good g)) ↔ prefixKeep good π n g := by
    constructor
    · intro h i hi
      simpa [s] using h ⟨i.val, hi⟩
    · intro h i
      simp only [Finset.mem_filter, Finset.mem_univ, true_and]
      exact h (s i) i.isLt
  have hb := permutation_prefix_survival_le_exp s (Finset.univ.filter (good g))
  simp_rw [he] at hb
  simpa only [Fintype.card_fin, domainError_eq good g hm] using hb

/-- Expected error at one position under a literal uniform random
permutation, from the finite relevant class and its actual prior tail. -/
theorem expected_permutationRound_le
    (w : H → ℝ) (hw : ∀ g, 0 ≤ w g) (good : H → Fin m → Prop)
    (target : H) (htarget : ∀ x, good target x) (hwt : 0 < w target)
    (A : Finset H) (h β : ℝ) (hh : 0 ≤ h)
    (hcard : (A.card : ℝ) ≤ Real.exp h)
    (htail : (∑ g ∈ Finset.univ \ A, w g) / w target ≤ β)
    (i : Fin m) (hi : 0 < i.val) :
    finiteMean (fun π : Equiv.Perm (Fin m) => permutationRound w good π i) ≤
      (m : ℝ) / (m-i.val : ℕ) * ((h+1)/i.val) + β := by
  let p : Equiv.Perm (Fin m) → ℝ := fun _ => 1 / Fintype.card (Equiv.Perm (Fin m))
  have hp : ∀ π, 0 ≤ p π := by intro π; dsimp [p]; positivity
  have hpsum : ∑ π, p π = 1 := by
    simp [p, ne_of_gt (Fintype.card_pos : 0 < Fintype.card (Equiv.Perm (Fin m)))]
  have hsurvive (g : H) (_hg : g ∈ A) :
      (∑ π, if prefixKeep good π i.val g then p π else 0) ≤
        Real.exp (-(i.val : ℝ) * domainError good g) := by
    have hb := prefix_survival good g i.val i.isLt.le (Nat.zero_lt_of_lt i.isLt)
    convert hb using 1
    unfold finiteEvent finiteMean p
    rw [Finset.sum_div]
    apply Finset.sum_congr rfl
    intro π _
    split_ifs <;> simp
  have hb := expected_posterior_risk_le_of_survival p hp hpsum w hw
    (fun π => prefixKeep good π i.val) target (fun π j _ => htarget (π j)) hwt
    (domainError good) (fun π => remainingLoss good π i.val)
    (fun π g => ⟨remainingLoss_nonneg good π i.val g,
      remainingLoss_le_one good π i.val i.isLt g⟩)
    A h i.val ((m : ℝ)/(m-i.val : ℕ)) β hh (by exact_mod_cast hi) (by positivity)
    hcard hsurvive (fun π g hg => (remainingLoss_eq good π i.val i.isLt g hg).le) htail
  rw [permutationRound_average_remaining]
  convert hb using 1
  unfold finiteMean p
  rw [Finset.sum_div]
  apply Finset.sum_congr rfl
  intro π _
  ring

end NeuralGeneralization.BatchTwoOnline
