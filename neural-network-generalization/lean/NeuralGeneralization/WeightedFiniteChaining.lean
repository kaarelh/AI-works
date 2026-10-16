import NeuralGeneralization.FiniteChaining
import NeuralGeneralization.RademacherExcess

/-!
# Chaining with edge-dependent scales

This is a finite, path-dependent chaining bound for actual Rademacher
processes. Unlike a sum of expected maxima at each level, its geometric
term is the largest total cost along a single path. The proof constructs
one nonnegative excess variable from actual normalized increments.
-/

noncomputable section
namespace NeuralGeneralization.SquaredSampling
open scoped BigOperators

variable {U : Type*} [Fintype U] [Nonempty U]

def chainEdgeOf (π : ℕ → U → U) (k : ℕ) (u : U) : ChainEdge π k := by
  classical
  exact ⟨(π (k+1) u, π k u), Finset.mem_image.mpr ⟨u, Finset.mem_univ _, rfl⟩⟩

/-- A genuine path-dependent finite chaining inequality. Each edge scale
is an upper bound on the square root of its actual coefficient energy.
The last hypothesis bounds complete path costs, without taking separate
suprema at each level. -/
theorem finite_rademacher_weighted_chaining_coefficients (m L : ℕ) (a : U → Fin m → ℝ)
    (π : ℕ → U → U) (hroot : ∀ u i, a (π 0 u) i = 0)
    (hlast : ∀ u i, a (π L u) i = a u i) (p : ℕ → ℝ)
    (σ : (k : ℕ) → ChainEdge π k → ℝ)
    (hp : ∀ k < L, 0 < p k)
    (hσ : ∀ k < L, ∀ e, 0 < σ k e)
    (henergy : ∀ k < L, ∀ e : ChainEdge π k,
      (∑ i, (a e.val.1 i - a e.val.2 i) ^ 2) ≤ σ k e ^ 2)
    (G : ℝ) (hG : ∀ u,
      (∑ k ∈ Finset.range L, p k * σ k (chainEdgeOf π k u)) ≤ G) :
    finiteMean (fun ε : Fin m → Bool =>
      envelope (fun u => ∑ i, cubeCoordinateSign (ε i) * a u i)) ≤
      G * (1 + ∑ k ∈ Finset.range L,
        (chainEdges π k).card * (2 * Real.exp (-(p k ^ 2) / 2) / p k ^ 2)) := by
  classical
  let X := fun ε : Fin m → Bool => fun u : U => ∑ i, cubeCoordinateSign (ε i) * a u i
  let inc := fun k : ℕ => fun e : ChainEdge π k => fun i : Fin m => a e.val.1 i - a e.val.2 i
  let E := fun k : ℕ => fun ε : Fin m → Bool => fun e : ChainEdge π k =>
    relativeExcess (p k) ((∑ i, cubeCoordinateSign (ε i) * inc k e i) / σ k e)
  let Z := fun ε : Fin m → Bool => ∑ k ∈ Finset.range L, ∑ e : ChainEdge π k, E k ε e
  have hEnonneg (k : ℕ) (hk : k < L) (ε : Fin m → Bool) (e : ChainEdge π k) :
      0 ≤ E k ε e := relativeExcess_nonneg (hp k hk) _
  have hZnonneg (ε : Fin m → Bool) : 0 ≤ Z ε := by
    apply Finset.sum_nonneg
    intro k hk
    exact Finset.sum_nonneg (fun e _ => hEnonneg k (Finset.mem_range.mp hk) ε e)
  have hEle (k : ℕ) (hk : k < L) (ε : Fin m → Bool) (e : ChainEdge π k) :
      E k ε e ≤ Z ε := by
    have hinner : E k ε e ≤ ∑ e' : ChainEdge π k, E k ε e' :=
      Finset.single_le_sum (fun e' _ => hEnonneg k hk ε e') (Finset.mem_univ e)
    apply hinner.trans
    exact Finset.single_le_sum (f := fun j => ∑ e' : ChainEdge π j, E j ε e')
      (fun j hj => Finset.sum_nonneg (fun e' _ => hEnonneg j (Finset.mem_range.mp hj) ε e'))
      (Finset.mem_range.mpr hk)
  have hinc (k : ℕ) (hk : k < L) (ε : Fin m → Bool) (e : ChainEdge π k) :
      |∑ i, cubeCoordinateSign (ε i) * inc k e i| ≤ p k * σ k e * (1 + Z ε) := by
    have h := abs_le_threshold_excess (hp k hk)
      ((∑ i, cubeCoordinateSign (ε i) * inc k e i) / σ k e)
    have h' := mul_le_mul_of_nonneg_left h (hσ k hk e).le
    rw [abs_div, abs_of_pos (hσ k hk e), mul_div_cancel₀ _ (ne_of_gt (hσ k hk e))] at h'
    have he := mul_le_mul_of_nonneg_left (hEle k hk ε e)
      (mul_nonneg (hp k hk).le (hσ k hk e).le)
    dsimp only [E] at he
    nlinarith only [h', he]
  have hGnonneg : 0 ≤ G := by
    obtain ⟨u⟩ := ‹Nonempty U›
    apply le_trans _ (hG u)
    exact Finset.sum_nonneg (fun k hk => mul_nonneg (hp k (Finset.mem_range.mp hk)).le
      (hσ k (Finset.mem_range.mp hk) _).le)
  have htel (ε : Fin m → Bool) (u : U) :
      X ε u = ∑ k ∈ Finset.range L, ∑ i,
        cubeCoordinateSign (ε i) * inc k (chainEdgeOf π k u) i := by
    have hstep (k : ℕ) : (∑ i, cubeCoordinateSign (ε i) * inc k (chainEdgeOf π k u) i) =
        X ε (π (k+1) u) - X ε (π k u) := by
      simp only [inc, chainEdgeOf, X, mul_sub, Finset.sum_sub_distrib]
    simp_rw [hstep]
    rw [Finset.sum_range_sub (fun k => X ε (π k u)) L]
    have hlastX : X ε (π L u) = X ε u := by simp only [X, hlast]
    rw [hlastX]
    have hz : X ε (π 0 u) = 0 := by simp [X, hroot]
    rw [hz, sub_zero]
  have hpoint (ε : Fin m → Bool) : envelope (X ε) ≤ G * (1 + Z ε) := by
    apply envelope_le
    intro u
    rw [htel]
    apply (Finset.abs_sum_le_sum_abs _ _).trans
    calc
      _ ≤ ∑ k ∈ Finset.range L, p k * σ k (chainEdgeOf π k u) * (1 + Z ε) :=
        Finset.sum_le_sum (fun k hk => hinc k (Finset.mem_range.mp hk) ε _)
      _ = (∑ k ∈ Finset.range L, p k * σ k (chainEdgeOf π k u)) * (1 + Z ε) := by
        rw [Finset.sum_mul]
      _ ≤ G * (1 + Z ε) := mul_le_mul_of_nonneg_right (hG u) (by linarith [hZnonneg ε])
  have hEZ : finiteMean Z ≤ ∑ k ∈ Finset.range L,
      (chainEdges π k).card * (2 * Real.exp (-(p k ^ 2) / 2) / p k ^ 2) := by
    rw [show Z = (fun ε : Fin m → Bool => ∑ k ∈ Finset.range L,
      ∑ e : ChainEdge π k, E k ε e) from rfl, finiteMean_finsetSum]
    apply Finset.sum_le_sum
    intro k hk
    rw [finiteMean_sum]
    have hbound (e : ChainEdge π k) : finiteMean (fun ε => E k ε e) ≤
        2 * Real.exp (-(p k ^ 2) / 2) / p k ^ 2 :=
      finite_rademacher_relativeExcess_scaled m (inc k e) (σ k e)
        (hσ k (Finset.mem_range.mp hk) e) (henergy k (Finset.mem_range.mp hk) e)
        (p k) (hp k (Finset.mem_range.mp hk))
    have hsum := Finset.sum_le_sum (fun e (_ : e ∈ Finset.univ) => hbound e)
    simpa only [Finset.sum_const, Finset.card_univ, Fintype.card_coe, nsmul_eq_mul] using hsum
  have havg := finiteMean_mono hpoint
  rw [finiteMean_mul, finiteMean_add, finiteMean_const] at havg
  exact havg.trans (mul_le_mul_of_nonneg_left (add_le_add_right hEZ 1) hGnonneg)

/-- Exact endpoint interpolation is a special case of coefficient
interpolation. The latter also permits pseudometric chains. -/
theorem finite_rademacher_weighted_chaining (m L : ℕ) (a : U → Fin m → ℝ)
    (π : ℕ → U → U) (hroot : ∀ u i, a (π 0 u) i = 0)
    (hlast : ∀ u, π L u = u) (p : ℕ → ℝ)
    (σ : (k : ℕ) → ChainEdge π k → ℝ)
    (hp : ∀ k < L, 0 < p k)
    (hσ : ∀ k < L, ∀ e, 0 < σ k e)
    (henergy : ∀ k < L, ∀ e : ChainEdge π k,
      (∑ i, (a e.val.1 i-a e.val.2 i)^2) ≤ σ k e^2)
    (G : ℝ) (hG : ∀ u,
      (∑ k ∈ Finset.range L, p k*σ k (chainEdgeOf π k u)) ≤ G) :
    finiteMean (fun ε : Fin m → Bool =>
      envelope (fun u => ∑ i, cubeCoordinateSign (ε i)*a u i)) ≤
      G*(1+∑ k ∈ Finset.range L,
        (chainEdges π k).card*(2*Real.exp (-(p k^2)/2)/p k^2)) :=
  finite_rademacher_weighted_chaining_coefficients m L a π hroot
    (fun u i => by rw [hlast]) p σ hp hσ henergy G hG

end NeuralGeneralization.SquaredSampling
