import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Data.Fin.Tuple.Basic
import Mathlib.Algebra.BigOperators.Fin
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Positivity

noncomputable section
set_option linter.unusedSectionVars false
open scoped BigOperators
namespace ConditionalNonpolynomial

variable {X : Type*} [Fintype X]

/-- The weighted error, before normalizing the weights. -/
def weightedError (f g : X → Bool) (w : X → ℝ) : ℝ :=
  ∑ x, if g x = f x then 0 else w x

/-- A weak learner can answer every nonnegative weighting. The zero weighting
is included, so the hypothesis also states that the class is nonempty. -/
def WeakClass (f : X → Bool) (H : Set (X → Bool)) : Prop :=
  ∀ w : X → ℝ, (∀ x, 0 ≤ w x) →
    ∃ g ∈ H, weightedError f g w ≤ (9 / 20 : ℝ) * ∑ x, w x

/-- The signed vote of a predictor: +1 when correct, -1 when wrong. -/
def signedVote (f g : X → Bool) (x : X) : ℝ :=
  if g x = f x then 1 else -1

/-- Exponential weights for a finite list of predictions. -/
def voteWeight (f : X → Bool) {m : ℕ} (gs : Fin m → (X → Bool)) (x : X) : ℝ :=
  Real.exp (-Real.log (10 / 9 : ℝ) * ∑ i, signedVote f (gs i) x)

lemma voteWeight_nonneg (f : X → Bool) {m : ℕ} (gs : Fin m → (X → Bool)) (x : X) :
    0 ≤ voteWeight f gs x := Real.exp_nonneg _

lemma voteWeight_cons (f g : X → Bool) {m : ℕ} (gs : Fin m → (X → Bool)) (x : X) :
    voteWeight f (Fin.cons g gs) x =
      (if g x = f x then (9 / 10 : ℝ) else (10 / 9 : ℝ)) * voteWeight f gs x := by
  classical
  unfold voteWeight
  rw [Fin.sum_univ_succ]
  simp only [Fin.cons_zero, Fin.cons_succ]
  rw [mul_add, Real.exp_add]
  congr 1
  unfold signedVote
  split_ifs
  · simp only [mul_one, Real.exp_neg, Real.exp_log (by norm_num : (0:ℝ) < 10/9)]
    norm_num
  · simp only [mul_neg_one, neg_neg, Real.exp_log (by norm_num : (0:ℝ) < 10/9)]

lemma voteWeight_cons_sum (f g : X → Bool) {m : ℕ} (gs : Fin m → (X → Bool)) :
    (∑ x, voteWeight f (Fin.cons g gs) x) =
      (9 / 10 : ℝ) * (∑ x, voteWeight f gs x) +
        (19 / 90 : ℝ) * weightedError f g (voteWeight f gs) := by
  classical
  simp only [weightedError, Finset.mul_sum, ← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro x hx
  rw [voteWeight_cons]
  split_ifs <;> ring

/-- The constructive boosting recurrence. No minimax or concentration theorem
is assumed: the next predictor is chosen using the current exponential weights. -/
theorem exists_voters_with_small_potential (f : X → Bool) (H : Set (X → Bool))
    (hweak : WeakClass f H) (m : ℕ) :
    ∃ gs : Fin m → (X → Bool), (∀ i, gs i ∈ H) ∧
      (∑ x, voteWeight f gs x) ≤ (Fintype.card X : ℝ) * (199 / 200 : ℝ)^m := by
  classical
  induction m with
  | zero =>
      refine ⟨Fin.elim0, ?_, ?_⟩
      · intro i; exact Fin.elim0 i
      · simp [voteWeight]
  | succ m ih =>
      obtain ⟨gs, hgs, hpot⟩ := ih
      obtain ⟨g, hg, herr⟩ := hweak (voteWeight f gs) (voteWeight_nonneg f gs)
      refine ⟨Fin.cons g gs, ?_, ?_⟩
      · intro i
        refine Fin.cases hg (fun j => ?_) i
        simpa using hgs j
      · rw [voteWeight_cons_sum]
        have hstep : (9 / 10 : ℝ) * (∑ x, voteWeight f gs x) +
            (19 / 90 : ℝ) * weightedError f g (voteWeight f gs) ≤
            (199 / 200 : ℝ) * (∑ x, voteWeight f gs x) := by linarith
        calc
          _ ≤ (199 / 200 : ℝ) * (∑ x, voteWeight f gs x) := hstep
          _ ≤ (199 / 200 : ℝ) * ((Fintype.card X : ℝ) * (199 / 200 : ℝ)^m) :=
            mul_le_mul_of_nonneg_left hpot (by norm_num)
          _ = (Fintype.card X : ℝ) * (199 / 200 : ℝ)^(m+1) := by rw [pow_succ]; ring

lemma boosting_decay (d : ℕ) :
    (2 : ℝ)^d * (199 / 200 : ℝ)^(400 * (d+1)) < 1 := by
  have hblock : (199 / 200 : ℝ)^400 < 1/2 := by
    have hb := one_add_mul_le_pow (a := (1/199:ℝ)) (by norm_num) 400
    norm_num at hb
    have hm := mul_le_mul_of_nonneg_right hb
      (by positivity : 0 ≤ (199/200:ℝ)^400)
    rw [← mul_pow] at hm
    norm_num at hm
    have hy : (199/200:ℝ)^400 ≤ (1:ℝ)/(599/199) :=
      (le_div_iff₀ (by norm_num : (0:ℝ) < 599/199)).mpr (by simpa [mul_comm] using hm)
    exact hy.trans_lt (by norm_num)
  have hnonneg : 0 ≤ (199 / 200 : ℝ)^400 := by positivity
  have hsmall : (199 / 200 : ℝ)^400 ≤ 1/2 := le_of_lt hblock
  rw [pow_mul]
  have hp := pow_le_pow_left₀ hnonneg hsmall (d+1)
  have hm := mul_le_mul_of_nonneg_left hp (by positivity : 0 ≤ (2:ℝ)^d)
  calc
    (2 : ℝ)^d * ((199 / 200 : ℝ)^400)^(d+1) ≤ (2:ℝ)^d * (1/2:ℝ)^(d+1) := hm
    _ = 1/2 := by
      rw [pow_succ, ← mul_assoc, ← mul_pow]
      norm_num
    _ < 1 := by norm_num

/-- A weak class on at most 2^d points contains a list of O(d) voters whose
strict majority agrees exactly with the target on every input. -/
theorem weakClass_exact_majority (f : X → Bool) (H : Set (X → Bool))
    (hweak : WeakClass f H) (d : ℕ) (hcard : Fintype.card X ≤ 2^d) :
    ∃ gs : Fin (400 * (d+1)) → (X → Bool),
      (∀ i, gs i ∈ H) ∧ ∀ x, 0 < ∑ i, signedVote f (gs i) x := by
  classical
  obtain ⟨gs, hgs, hpot⟩ := exists_voters_with_small_potential f H hweak (400*(d+1))
  refine ⟨gs, hgs, ?_⟩
  have hcardR : (Fintype.card X : ℝ) ≤ (2:ℝ)^d := by exact_mod_cast hcard
  have htotal : (∑ x, voteWeight f gs x) < 1 :=
    lt_of_le_of_lt (hpot.trans (mul_le_mul_of_nonneg_right hcardR (by positivity)))
      (boosting_decay d)
  intro x
  by_contra h
  have hscore : (∑ i, signedVote f (gs i) x) ≤ 0 := le_of_not_gt h
  have hlog : 0 < Real.log (10/9:ℝ) := Real.log_pos (by norm_num)
  have hw : 1 ≤ voteWeight f gs x := by
    unfold voteWeight
    exact Real.one_le_exp_iff.mpr (mul_nonneg_of_nonpos_of_nonpos (by linarith) hscore)
  have hx := Finset.single_le_sum (fun y _ => voteWeight_nonneg f gs y) (Finset.mem_univ x)
  linarith

#print axioms weakClass_exact_majority
end ConditionalNonpolynomial
