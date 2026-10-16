import NeuralGeneralization.IteratedArcsineSeries
import NeuralGeneralization.CovarianceFactor

/-! Elementary coefficient regularity consequences of positive Hankel
matrices. These are finite algebraic lemmas, not an assumption that the
iterated arcsine coefficients have the property. -/
noncomputable section
open scoped BigOperators Topology
open Filter
namespace NeuralGeneralization.HankelCoefficientBounds

/-- Every finite coefficient Hankel matrix is positive semidefinite. -/
def PositiveHankel (a : ℕ → ℝ) : Prop :=
  ∀ N : ℕ, Matrix.PosSemidef (fun i j : Fin N => a (i.val+j.val+1))

/-- The required log-convexity follows just from two rows of a finite
positive Hankel matrix. -/
theorem PositiveHankel.odd_logconvex {a : ℕ → ℝ} (ha : PositiveHankel a) (n : ℕ) :
    a (2*(n+1)+1) ^ 2 ≤ a (2*n+1) * a (2*(n+2)+1) := by
  let i : Fin (n+3) := ⟨n, by omega⟩
  let j : Fin (n+3) := ⟨n+2, by omega⟩
  obtain ⟨A,hA⟩ := CovarianceFactor.exists_gram_factor _ (ha (n+3))
  have h := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ (A i) (A j)
  have hii : (∑ k, A i k ^ 2) = a (2*n+1) := by
    simpa [GaussianAngularPrice.gram, i, pow_two, two_mul] using hA i i
  have hjj : (∑ k, A j k ^ 2) = a (2*(n+2)+1) := by
    simpa [GaussianAngularPrice.gram, j, pow_two, two_mul] using hA j j
  have hij : (∑ k, A i k * A j k) = a (2*(n+1)+1) := by
    convert hA i j using 1 <;> simp [GaussianAngularPrice.gram, i, j] <;> congr 1 <;> omega
  rwa [hii,hjj,hij] at h

/-- A nonnegative summable log-convex sequence is decreasing. A strict
increase would propagate indefinitely and contradict convergence to zero. -/
theorem antitone_of_summable_logconvex {a : ℕ → ℝ} (ha : ∀ n, 0 ≤ a n)
    (hs : Summable a) (hl : ∀ n, a (n+1)^2 ≤ a n * a (n+2)) : Antitone a := by
  apply antitone_nat_of_succ_le
  intro n
  by_contra! hinc
  have hstep {q : ℕ} (hq : a q < a (q+1)) : a (q+1) < a (q+2) := by
    by_contra! hle
    have hp : 0 < a (q+1) := (ha q).trans_lt hq
    have hmul := mul_nonneg (ha q) (sub_nonneg.mpr hle)
    have hstrict := mul_pos hp (sub_pos.mpr hq)
    nlinarith [hl q]
  have hincAll (m : ℕ) : a (n+m) < a (n+m+1) := by
    induction m with
    | zero => simpa using hinc
    | succ m ih => simpa [Nat.add_assoc] using hstep ih
  have hlower (m : ℕ) : a (n+1) ≤ a (n+m+1) := by
    induction m with
    | zero => simp
    | succ m ih => exact ih.trans (by simpa [Nat.add_assoc] using (hincAll (m+1)).le)
  have hp : 0 < a (n+1) := (ha n).trans_lt hinc
  have hev : ∀ᶠ q in atTop, a q < a (n+1) :=
    (tendsto_order.mp hs.tendsto_atTop_zero).2 _ hp
  obtain ⟨M,hM⟩ := eventually_atTop.mp hev
  exact not_lt_of_ge (hlower M) (hM (n+M+1) (by omega))

/-- Positive coefficient Hankel matrices and summability imply the
odd-subsequence monotonicity used by a real monotone-density argument. -/
theorem PositiveHankel.odd_antitone {a : ℕ → ℝ} (ha : PositiveHankel a)
    (hnonneg : ∀ n, 0 ≤ a n) (hs : Summable a) : Antitone (fun n => a (2*n+1)) := by
  apply antitone_of_summable_logconvex (fun n => hnonneg _)
    (hs.comp_injective (fun n m h => by omega))
  exact ha.odd_logconvex

end NeuralGeneralization.HankelCoefficientBounds
