import NeuralGeneralization.BatchTwoOnlineTotal

/-!
# Actual posterior draws and expected sampled mistakes

The learner draws one hypothesis from each consistency posterior. Because
all true labels are revealed, the posterior at a fixed input sequence does
not depend on those draws. Its joint law is the product explicitly below.
-/
noncomputable section
open scoped BigOperators
open Classical
attribute [local instance] Classical.propDecidable

namespace NeuralGeneralization.BatchTwoOnline
open SquaredSampling

variable {I H : Type*} [Fintype I] [DecidableEq I] [Fintype H]

def independentWeight (p : I → H → ℝ) (draw : I → H) : ℝ := ∏ i, p i (draw i)

lemma independentWeight_sum (p : I → H → ℝ) (hp : ∀ i, ∑ g, p i g = 1) :
    ∑ draw, independentWeight p draw = 1 := by
  unfold independentWeight
  rw [← Fintype.prod_sum]
  simp_rw [hp]
  simp

lemma independentWeight_nonneg (p : I → H → ℝ) (hp : ∀ i g, 0 ≤ p i g)
    (draw : I → H) : 0 ≤ independentWeight p draw :=
  Finset.prod_nonneg fun i _ => hp i (draw i)

lemma independent_expected_coordinate (p : I → H → ℝ) (hp : ∀ i, ∑ g, p i g = 1)
    (L : H → ℝ) (i : I) :
    (∑ draw : I → H, independentWeight p draw * L (draw i)) = ∑ g, p i g * L g := by
  have hterm (draw : I → H) : independentWeight p draw * L (draw i) =
      ∏ j, p j (draw j) * (if j=i then L (draw j) else 1) := by
    rw [Finset.prod_mul_distrib]
    simp [independentWeight]
  simp_rw [hterm]
  rw [← Fintype.prod_sum (fun j g => p j g * (if j=i then L g else 1))]
  have hs (j : I) : (∑ g, p j g * (if j=i then L g else 1)) =
      if j=i then ∑ g, p i g * L g else 1 := by
    by_cases hji : j=i
    · subst j; simp
    · simp [hji, hp]
  simp_rw [hs]
  simp

/-- Linearity of expectation for independent, non-identically distributed
posterior draws, with the actual finite product probability vector. -/
theorem independent_expected_sum (p : I → H → ℝ) (hp : ∀ i, ∑ g, p i g = 1)
    (L : I → H → ℝ) :
    (∑ draw : I → H, independentWeight p draw * ∑ i, L i (draw i)) =
      ∑ i, ∑ g, p i g * L i g := by
  simp_rw [Finset.mul_sum]
  rw [Finset.sum_comm]
  exact Finset.sum_congr rfl fun i _ => independent_expected_coordinate p hp (L i) i

variable [DecidableEq H] {m : ℕ}

def permutationDrawWeight (w : H → ℝ) (good : H → Fin m → Prop)
    (π : Equiv.Perm (Fin m)) : (Fin m → H) → ℝ :=
  independentWeight (fun i => posterior w (prefixKeep good π i.val))

def sampledMistakes (good : H → Fin m → Prop) (π : Equiv.Perm (Fin m))
    (draw : Fin m → H) : ℝ := ∑ i, pointLoss good (draw i) (π i)

lemma permutationDrawWeight_sum
    (w : H → ℝ) (hw : ∀ g, 0 ≤ w g) (good : H → Fin m → Prop)
    (target : H) (htarget : ∀ x, good target x) (hwt : 0 < w target)
    (π : Equiv.Perm (Fin m)) : ∑ draw, permutationDrawWeight w good π draw = 1 :=
  independentWeight_sum _ fun i => posterior_sum w _ hw target
    (fun j _ => htarget (π j)) hwt

/-- Conditional on any complete input order, the expected number of actual
posterior-sampling mistakes equals cumulative posterior error. -/
theorem expected_sampledMistakes_eq
    (w : H → ℝ) (hw : ∀ g, 0 ≤ w g) (good : H → Fin m → Prop)
    (target : H) (htarget : ∀ x, good target x) (hwt : 0 < w target)
    (π : Equiv.Perm (Fin m)) :
    (∑ draw, permutationDrawWeight w good π draw * sampledMistakes good π draw) =
      permutationTotal w good π :=
  independent_expected_sum _ (fun i => posterior_sum w _ hw target
    (fun j _ => htarget (π j)) hwt) (fun i g => pointLoss good g (π i))

/-- The manuscript's expected total sampled-mistake bound on the actual
joint law: a uniform permutation followed by independent posterior draws. -/
theorem expected_sampledMistakes_le (m : ℕ) (hm : 0 < m)
    (w : H → ℝ) (hw : ∀ g, 0 ≤ w g) (good : H → Fin m → Prop)
    (target : H) (htarget : ∀ x, good target x) (hwt : 0 < w target)
    (A : Finset H) (h β : ℝ) (hh : 0 ≤ h)
    (hcard : (A.card : ℝ) ≤ Real.exp h)
    (htail : (∑ g ∈ Finset.univ \ A, w g) / w target ≤ β) :
    finiteMean (fun π : Equiv.Perm (Fin m) =>
      ∑ draw, permutationDrawWeight w good π draw * sampledMistakes good π draw) ≤
      1 + 2*(h+1)*harmonicSum (m-1) + m*β := by
  simp_rw [expected_sampledMistakes_eq w hw good target htarget hwt]
  exact expected_permutationTotal_le_general m hm w hw good target htarget hwt A h β hh hcard htail

end NeuralGeneralization.BatchTwoOnline
