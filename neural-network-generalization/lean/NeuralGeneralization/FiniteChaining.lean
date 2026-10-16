import NeuralGeneralization.FiniteProcessMax

/-!
# Finite chaining for actual Rademacher linear processes

Every increment is an actual difference of coefficient vectors. The bound
uses the cardinalities of the actual finite edge sets in a chain. It does
not assume a generic-chaining theorem or the geometric estimate for Lee's
rank-one metric.
-/

noncomputable section
namespace NeuralGeneralization.SquaredSampling
open scoped BigOperators

variable {U : Type*} [Fintype U] [Nonempty U]

lemma le_envelope_finite (f : U → ℝ) (u : U) : |f u| ≤ envelope f := by
  obtain ⟨v, hv⟩ := Finite.exists_max (fun v => |f v|)
  exact le_envelope f hv u

lemma finiteMean_finsetSum {ι α : Type*} [Fintype α]
    (s : Finset ι) (f : ι → α → ℝ) :
    finiteMean (fun x => ∑ i ∈ s, f i x) = ∑ i ∈ s, finiteMean (f i) := by
  unfold finiteMean
  rw [Finset.sum_comm, Finset.sum_div]

/-- The genuine edges used between two successive approximations. -/
def chainEdges (π : ℕ → U → U) (k : ℕ) : Finset (U × U) := by
  classical
  exact Finset.univ.image (fun u => (π (k+1) u, π k u))

abbrev ChainEdge (π : ℕ → U → U) (k : ℕ) := {p : U × U // p ∈ chainEdges π k}

instance chainEdge_nonempty (π : ℕ → U → U) (k : ℕ) : Nonempty (ChainEdge π k) := by
  classical
  obtain ⟨u⟩ := ‹Nonempty U›
  exact ⟨⟨(π (k+1) u, π k u), Finset.mem_image.mpr ⟨u, Finset.mem_univ _, rfl⟩⟩⟩

/-- A finite chain of genuine coefficient approximations gives this
explicit expected-supremum bound. The energy hypotheses are literal
sums of squares of the approximation increments. -/
theorem finite_rademacher_chaining (m L : ℕ) (a : U → Fin m → ℝ)
    (π : ℕ → U → U) (hroot : ∀ u i, a (π 0 u) i = 0)
    (hlast : ∀ u, π L u = u) (V t : ℕ → ℝ)
    (ht : ∀ k < L, 0 < t k)
    (henergy : ∀ k < L, ∀ u,
      (∑ i, (a (π (k+1) u) i - a (π k u) i) ^ 2) ≤ V k) :
    finiteMean (fun ε : Fin m → Bool =>
      envelope (fun u => ∑ i, cubeCoordinateSign (ε i) * a u i)) ≤
      ∑ k ∈ Finset.range L,
        (Real.log (2 * (chainEdges π k).card) + (t k) ^ 2 * V k / 2) / t k := by
  classical
  let X := fun ε : Fin m → Bool => fun u : U => ∑ i, cubeCoordinateSign (ε i) * a u i
  let inc := fun k : ℕ => fun e : ChainEdge π k => fun i : Fin m => a e.val.1 i - a e.val.2 i
  let Z := fun k : ℕ => fun ε : Fin m → Bool => fun e : ChainEdge π k =>
    ∑ i, cubeCoordinateSign (ε i) * inc k e i
  have htel (ε : Fin m → Bool) (u : U) :
      X ε u = ∑ k ∈ Finset.range L, ∑ i,
        cubeCoordinateSign (ε i) * (a (π (k+1) u) i - a (π k u) i) := by
    have hstep (k : ℕ) : (∑ i, cubeCoordinateSign (ε i) *
        (a (π (k+1) u) i - a (π k u) i)) = X ε (π (k+1) u) - X ε (π k u) := by
      simp only [X, mul_sub, Finset.sum_sub_distrib]
    simp_rw [hstep]
    rw [Finset.sum_range_sub (fun k => X ε (π k u)) L, hlast]
    have hz : X ε (π 0 u) = 0 := by simp [X, hroot]
    rw [hz, sub_zero]
  have hpoint (ε : Fin m → Bool) : envelope (X ε) ≤
      ∑ k ∈ Finset.range L, envelope (Z k ε) := by
    apply envelope_le
    intro u
    rw [htel]
    apply (Finset.abs_sum_le_sum_abs _ _).trans
    apply Finset.sum_le_sum
    intro k _
    let e : ChainEdge π k := ⟨(π (k+1) u, π k u),
      Finset.mem_image.mpr ⟨u, Finset.mem_univ _, rfl⟩⟩
    exact le_envelope_finite (Z k ε) e
  have havg := finiteMean_mono hpoint
  rw [finiteMean_finsetSum] at havg
  apply havg.trans
  apply Finset.sum_le_sum
  intro k hk
  have hE (e : ChainEdge π k) : (∑ i, inc k e i ^ 2) ≤ V k := by
    obtain ⟨u, _, hu⟩ := Finset.mem_image.mp e.property
    have hpair : e.val = (π (k+1) u, π k u) := hu.symm
    simpa only [inc, hpair] using henergy k (Finset.mem_range.mp hk) u
  have hmax := finite_rademacher_expected_max m (inc k) (V k) (t k)
    (ht k (Finset.mem_range.mp hk)) hE
  simpa only [Z, Fintype.card_coe] using hmax

end NeuralGeneralization.SquaredSampling
