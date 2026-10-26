import FiniteReductionPosterior
import Mathlib.Algebra.BigOperators.Field

noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial

variable {X I : Type*} [Fintype X] [Fintype I]

/-- Normalized distributional weak learning implies the homogeneous weighting
hypothesis used by the constructive boosting algorithm. -/
theorem weakClass_of_normalized [Nonempty X] (f : X → Bool) (H : Set (X → Bool))
    (h : ∀ D : X → ℝ, (∀ x, 0 ≤ D x) → (∑ x, D x = 1) →
      ∃ g ∈ H, weightedError f g D ≤ (9/20:ℝ)) : WeakClass f H := by
  classical
  have hH : H.Nonempty := by
    let x0 : X := Classical.arbitrary X
    obtain ⟨g,hg,_⟩ := h (fun x => if x=x0 then 1 else 0)
      (fun x => by split_ifs <;> norm_num) (by simp)
    exact ⟨g,hg⟩
  intro w hw
  let s : ℝ := ∑ x, w x
  have hs : 0 ≤ s := Finset.sum_nonneg (fun x _ => hw x)
  by_cases hz : s=0
  · obtain ⟨g,hg⟩ := hH
    refine ⟨g,hg,?_⟩
    have hwz (x:X) : w x=0 := by
      have hx := Finset.single_le_sum (fun y _ => hw y) (Finset.mem_univ x)
      have hs' : ∑ x, w x=0 := hz
      rw [hs'] at hx
      exact le_antisymm hx (hw x)
    simp [weightedError, hwz]
  · have hspos : 0 < s := lt_of_le_of_ne hs (Ne.symm hz)
    obtain ⟨g,hg,hgerr⟩ := h (fun x => w x/s)
      (fun x => div_nonneg (hw x) hs)
      (by rw [← Finset.sum_div]; exact div_self hz)
    refine ⟨g,hg,?_⟩
    have herr : weightedError f g (fun x => w x/s)=weightedError f g w / s := by
      unfold weightedError
      rw [Finset.sum_div]
      apply Finset.sum_congr rfl
      intro x hx
      split_ifs <;> simp
    rw [herr] at hgerr
    exact (div_le_iff₀ hspos).mp hgerr

/-- Entire finite posterior-to-majority reduction. A posterior may depend on the
input distribution; the predictor class and the enumeration g are fixed first.
No posterior algorithm and no concentration on a single function is assumed. -/
theorem posterior_family_exact_majority [Nonempty X]
    (f : X → Bool) (g : I → (X → Bool)) (H : I → Prop) [DecidablePred H]
    (hsuccess : ∀ D : X → ℝ, (∀ x, 0 ≤ D x) → (∑ x, D x = 1) →
      ∃ p : I → ℝ, (∀ i, 0 ≤ p i) ∧ (∑ i, p i = 1) ∧
        (5/6:ℝ) ≤ (∑ i, if H i then p i else 0) ∧
        confidenceFailureMass f g p D ≤ (1/16:ℝ))
    (d : ℕ) (hcard : Fintype.card X ≤ 2^d) :
    ∃ gs : Fin (400*(d+1)) → (X → Bool),
      (∀ j, ∃ i, H i ∧ gs j=g i) ∧
      ∀ x, 0 < ∑ j, signedVote f (gs j) x := by
  classical
  let K : Set (X → Bool) := {h | ∃ i, H i ∧ h=g i}
  have hweak : WeakClass f K := by
    apply weakClass_of_normalized
    intro D hD hsum
    obtain ⟨p,hp,hpsum,hmass,hfail⟩ := hsuccess D hD hsum
    obtain ⟨i,hi,herr⟩ := posterior_extract_weak f g p D H hp hD hmass
      (risk_le_three_eighths f g p D hp hpsum hD hsum hfail)
    exact ⟨g i, ⟨i,hi,rfl⟩, herr⟩
  obtain ⟨gs,hgs,hvote⟩ := weakClass_exact_majority f K hweak d hcard
  exact ⟨gs,hgs,hvote⟩

/-- Contrapositive of the finite reduction. If no short majority from the fixed
class represents f, a single input distribution defeats EVERY normalized
posterior carrying at least5/6 mass on that class. Thus the failure is stronger
than a small success probability over samples. -/
theorem exists_distribution_defeating_posteriors [Nonempty X]
    (f : X → Bool) (g : I → (X → Bool)) (H : I → Prop) [DecidablePred H]
    (d : ℕ) (hcard : Fintype.card X ≤ 2^d)
    (hno : ¬ ∃ gs : Fin (400*(d+1)) → (X → Bool),
      (∀ j, ∃ i, H i ∧ gs j=g i) ∧
      ∀ x, 0 < ∑ j, signedVote f (gs j) x) :
    ∃ D : X → ℝ, (∀ x, 0 ≤ D x) ∧ (∑ x, D x = 1) ∧
      ∀ p : I → ℝ, (∀ i, 0 ≤ p i) → (∑ i, p i = 1) →
        ((5/6:ℝ) ≤ ∑ i, if H i then p i else 0) →
        (1/16:ℝ) < confidenceFailureMass f g p D := by
  classical
  by_contra h
  apply hno
  apply posterior_family_exact_majority f g H ?_ d hcard
  intro D hD hsum
  have hh : ¬ ∀ p : I → ℝ, (∀ i, 0 ≤ p i) → (∑ i, p i = 1) →
      ((5/6:ℝ) ≤ ∑ i, if H i then p i else 0) →
      (1/16:ℝ) < confidenceFailureMass f g p D := by
    intro hh
    exact h ⟨D,hD,hsum,hh⟩
  push Not at hh
  exact hh

#print axioms exists_distribution_defeating_posteriors

#print axioms weakClass_of_normalized
#print axioms posterior_family_exact_majority
end ConditionalNonpolynomial
