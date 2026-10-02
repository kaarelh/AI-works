import Paulsen.ExceptionalGraph
import Paulsen.DiagonalDominance

/-!
# Dense cores with small exceptional leverage

The large exceptional set is controlled by its total projection leverage.
The final Poisson estimate has no exceptional-cardinality factor and assumes
no global spectral gap.
-/

namespace Paulsen

open Matrix
open scoped BigOperators

variable {ι κ : Type*} [Fintype ι] [Fintype κ] [DecidableEq ι] [DecidableEq κ]

/-- An exceptional block with uniformly positive boundary mass has no
cardinality loss in the Poisson estimate. -/
theorem boundedPoisson_of_boundary_mass [Nonempty ι]
    (w : Matrix (ι ⊕ κ) (ι ⊕ κ) ℝ) (γ r degree : ℝ)
    (hγ : 0 < γ) (hr : 0 < r) (hdegree0 : 0 ≤ degree)
    (hw : ∀ i j, 0 ≤ w i j) (hsymm : ∀ i j, w i j = w j i)
    (_hmass : ∀ i, (∑ j, w i j) ≤ 1)
    (hdegree : ∀ i : ι, (∑ j, w (Sum.inl i) j) ≤ degree)
    (hrowlower : ∀ i : κ, r ≤ ∑ j,
      (graphLaplacian w) (Sum.inr i) (Sum.inr j))
    (hoverlap : ∀ i k : ι, γ ≤ ∑ j : ι,
      min (w (Sum.inl i) (Sum.inl j)) (w (Sum.inl k) (Sum.inl j))) :
    BoundedPoissonSolvability w
      ((1 + degree / r) * (2 / γ) + 1 / r) := by
  let D := (graphLaplacian w).submatrix Sum.inr Sum.inr
  have hDoff : ∀ i j, i ≠ j → D i j ≤ 0 := by
    intro i j hij
    simpa [D, graphLaplacian, Matrix.submatrix, Matrix.diagonal_apply, hij] using
      neg_nonpos.mpr (hw (Sum.inr i) (Sum.inr j))
  obtain ⟨hDR, _hRD, hRn⟩ := zMatrix_row_lower_inverse D r hr hDoff hrowlower
  have hRrows := zMatrix_inverse_row_bound D r hr hDoff hrowlower
  apply (boundedPoisson_of_exceptional_inverse w γ (1 / r) degree hγ
    (one_div_pos.mpr hr).le hdegree0 hw hsymm hdegree hDR hRn hRrows hoverlap).mono
  have hmin : min (Fintype.card κ : ℝ) (degree * (1 / r)) ≤ degree / r := by
    simpa only [mul_one_div] using min_le_right (Fintype.card κ : ℝ) (degree * (1 / r))
  have hfirst : (1 + min (Fintype.card κ : ℝ) (degree * (1 / r))) / γ ≤
      (1 + degree / r) / γ := div_le_div_of_nonneg_right (by linarith) hγ.le
  have hnonneg : 0 ≤ (1 + degree / r) / γ := by positivity
  calc
    _ ≤ (1 + degree / r) / γ + 1 / r := by linarith
    _ ≤ (1 + degree / r) * (2 / γ) + 1 / r := by
      nlinarith [show (1 + degree / r) * (2 / γ) =
        2 * ((1 + degree / r) / γ) by ring]

section Projection

variable {ν : Type*} [Fintype ν] [DecidableEq ν]

omit [DecidableEq ν] in
theorem projection_diagonal_nonneg
    (P : Matrix ν ν ℝ) (hsymm : ∀ i j, P i j = P j i) (hproj : P * P = P) (i : ν) :
    0 ≤ P i i := by
  rw [← projection_row_squares P hsymm hproj i]
  exact Finset.sum_nonneg (fun j _ => sq_nonneg _)

omit [DecidableEq ν] in
/-- Cauchy-Schwarz on two projection rows bounds an entry by the leverages. -/
theorem projection_entry_sq_le_diagonal_mul
    (P : Matrix ν ν ℝ) (hsymm : ∀ i j, P i j = P j i) (hproj : P * P = P) (i j : ν) :
    (P i j) ^ 2 ≤ P i i * P j j := by
  have hentry : (∑ k, P i k * P j k) = P i j := by
    have hij := congrArg (fun M : Matrix ν ν ℝ => M i j) hproj
    rw [Matrix.mul_apply] at hij
    simpa only [hsymm j] using hij
  have hCS := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ (P i) (P j)
  rw [hentry, projection_row_squares P hsymm hproj i,
    projection_row_squares P hsymm hproj j] at hCS
  exact hCS

omit [DecidableEq ν] in
theorem projection_diagonal_le_one
    (P : Matrix ν ν ℝ) (hsymm : ∀ i j, P i j = P j i) (hproj : P * P = P) (i : ν) :
    P i i ≤ 1 := by
  have hdiag : (P i i) ^ 2 ≤ ∑ j, (P i j) ^ 2 :=
    Finset.single_le_sum (fun j _ => sq_nonneg _) (Finset.mem_univ i)
  rw [projection_row_squares P hsymm hproj i] at hdiag
  nlinarith [projection_diagonal_nonneg P hsymm hproj i]

end Projection

/-- Small total exceptional leverage gives a uniform amount of boundary
mass at every exceptional vertex. -/
theorem projection_killed_row_lower_of_leverage
    (P : Matrix (ι ⊕ κ) (ι ⊕ κ) ℝ) (a : ℝ)
    (hsymm : ∀ i j, P i j = P j i) (hproj : P * P = P)
    (hlower : ∀ i : κ, a / 2 ≤ P (Sum.inr i) (Sum.inr i))
    (htrace : (∑ j : κ, P (Sum.inr j) (Sum.inr j)) ≤ 1 / 4) (i : κ) :
    3 * a / 8 ≤ ∑ j : κ, projectionLaplacian P (Sum.inr i) (Sum.inr j) := by
  have hpi := projection_diagonal_nonneg P hsymm hproj (Sum.inr i)
  have hsum : (∑ j : κ, (P (Sum.inr i) (Sum.inr j)) ^ 2) ≤
      P (Sum.inr i) (Sum.inr i) * (∑ j : κ, P (Sum.inr j) (Sum.inr j)) := by
    rw [Finset.mul_sum]
    exact Finset.sum_le_sum (fun j _ =>
      projection_entry_sq_le_diagonal_mul P hsymm hproj _ _)
  have hsmall := mul_le_mul_of_nonneg_left htrace hpi
  have hrows : (∑ j : κ, projectionLaplacian P (Sum.inr i) (Sum.inr j)) =
      P (Sum.inr i) (Sum.inr i) - ∑ j : κ, (P (Sum.inr i) (Sum.inr j)) ^ 2 := by
    simp [projectionLaplacian, Matrix.diagonal_apply, Finset.sum_sub_distrib]
  rw [hrows]
  linarith [hlower i]

/-- The projection graph estimate used by the very-large-frame seed.
There is no global spectral-gap hypothesis and no cardinality factor in the
bound: the exceptional set is controlled by its total leverage. -/
theorem boundedPoisson_of_small_exceptional_leverage [Nonempty ι]
    (P : Matrix (ι ⊕ κ) (ι ⊕ κ) ℝ) (a γ : ℝ)
    (ha : 0 < a) (hγ : 0 < γ)
    (hsymm : ∀ i j, P i j = P j i) (hproj : P * P = P)
    (hlower : ∀ i, a / 2 ≤ P i i) (hupper : ∀ i, P i i ≤ 2 * a)
    (htrace : (∑ j : κ, P (Sum.inr j) (Sum.inr j)) ≤ 1 / 4)
    (hsmall : 10 * Fintype.card κ ≤ Fintype.card (ι ⊕ κ))
    (hdense : ∀ i : ι, 4 * Fintype.card (ι ⊕ κ) ≤
      5 * (largeNeighbors (fun i j => (P i j) ^ 2) γ (Sum.inl i)).card) :
    BoundedPoissonSolvability (fun i j => (P i j) ^ 2)
      (76 / (3 * γ) + 8 / (3 * a)) := by
  let w : Matrix (ι ⊕ κ) (ι ⊕ κ) ℝ := Matrix.of (fun i j => (P i j) ^ 2)
  have hw : ∀ i j, 0 ≤ w i j := fun i j => sq_nonneg _
  have hwsymm : ∀ i j, w i j = w j i := by
    intro i j
    change (P i j) ^ 2 = (P j i) ^ 2
    rw [hsymm]
  have hmass : ∀ i, (∑ j, w i j) ≤ 1 := by
    intro i
    change (∑ j, (P i j) ^ 2) ≤ 1
    rw [projection_row_squares P hsymm hproj i]
    exact projection_diagonal_le_one P hsymm hproj i
  have hdegree : ∀ i : ι, (∑ j, w (Sum.inl i) j) ≤ 2 * a := by
    intro i
    change (∑ j, (P (Sum.inl i) j) ^ 2) ≤ 2 * a
    rw [projection_row_squares P hsymm hproj]
    exact hupper _
  have hrowlower : ∀ i : κ, 3 * a / 8 ≤ ∑ j : κ,
      graphLaplacian w (Sum.inr i) (Sum.inr j) := by
    intro i
    have hL : projectionLaplacian P = graphLaplacian w :=
      projectionLaplacian_eq_graph P hsymm hproj
    rw [← hL]
    exact projection_killed_row_lower_of_leverage P a hsymm hproj
      (fun j => hlower (Sum.inr j)) htrace i
  have hoverlap := dense_good_neighbors_overlap w γ hγ hw hsmall hdense
  have hsolve := boundedPoisson_of_boundary_mass w (γ / 2) (3 * a / 8) (2 * a)
    (by positivity) (by positivity) (by positivity) hw hwsymm hmass hdegree hrowlower hoverlap
  have hconst : (1 + 2 * a / (3 * a / 8)) * (2 / (γ / 2)) + 1 / (3 * a / 8) =
      76 / (3 * γ) + 8 / (3 * a) := by
    field_simp
    ring
  rwa [hconst] at hsolve

/-- A single-scale version of the small-leverage graph theorem. -/
theorem boundedPoisson_of_small_exceptional_leverage_uniform [Nonempty ι]
    (P : Matrix (ι ⊕ κ) (ι ⊕ κ) ℝ) (a γ : ℝ)
    (ha : 0 < a) (hγ : 0 < γ) (hγa : γ ≤ a)
    (hsymm : ∀ i j, P i j = P j i) (hproj : P * P = P)
    (hlower : ∀ i, a / 2 ≤ P i i) (hupper : ∀ i, P i i ≤ 2 * a)
    (htrace : (∑ j : κ, P (Sum.inr j) (Sum.inr j)) ≤ 1 / 4)
    (hsmall : 10 * Fintype.card κ ≤ Fintype.card (ι ⊕ κ))
    (hdense : ∀ i : ι, 4 * Fintype.card (ι ⊕ κ) ≤
      5 * (largeNeighbors (fun i j => (P i j) ^ 2) γ (Sum.inl i)).card) :
    BoundedPoissonSolvability (fun i j => (P i j) ^ 2) (28 / γ) := by
  apply (boundedPoisson_of_small_exceptional_leverage P a γ ha hγ
    hsymm hproj hlower hupper htrace hsmall hdense).mono
  have hdiv : 8 / (3 * a) ≤ 8 / (3 * γ) :=
    div_le_div_of_nonneg_left (by norm_num) (by positivity) (by linarith)
  calc
    76 / (3 * γ) + 8 / (3 * a) ≤ 76 / (3 * γ) + 8 / (3 * γ) := by linarith
    _ = 28 / γ := by ring

end Paulsen
