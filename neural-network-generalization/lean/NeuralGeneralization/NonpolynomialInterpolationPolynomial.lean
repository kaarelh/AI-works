import Mathlib.Analysis.Calculus.IteratedDeriv.Lemmas
import Mathlib.Analysis.Calculus.MeanValue
import Mathlib.Analysis.Calculus.Deriv.Polynomial
import Mathlib.Topology.Algebra.Module.FiniteDimension
import Mathlib.LinearAlgebra.Finsupp.LinearCombination

/-! The finite-dimensional polynomial obstruction used in exact interpolation.
The topology on real functions is pointwise convergence. -/
noncomputable section
open scoped BigOperators Topology ContDiff
open Filter
namespace NeuralGeneralization.NonpolynomialInterpolation

/-- Functions representable by polynomials of degree strictly less than `n`. -/
def powerSpan (n : ℕ) : Submodule ℝ (ℝ → ℝ) :=
  Submodule.span ℝ (Set.range (fun i : Fin n => fun x : ℝ => x ^ i.val))

instance powerSpan_finiteDimensional (n : ℕ) : FiniteDimensional ℝ (powerSpan n) :=
  FiniteDimensional.span_of_finite ℝ (Set.finite_range _)

theorem powerSpan_closed (n : ℕ) : IsClosed (powerSpan n : Set (ℝ → ℝ)) :=
  (powerSpan n).closed_of_finiteDimensional

theorem mem_powerSpan_iff {n : ℕ} {f : ℝ → ℝ} :
    f ∈ powerSpan n ↔ ∃ c : Fin n → ℝ, ∀ x, f x = ∑ i, c i * x ^ i.val := by
  rw [powerSpan, Submodule.mem_span_range_iff_exists_fun]
  constructor
  · rintro ⟨c, hc⟩
    exact ⟨c, fun x => by simpa using (congrFun hc x).symm⟩
  · rintro ⟨c, hc⟩
    exact ⟨c, funext (fun x => by simpa using (hc x).symm)⟩

/-- This notion of polynomial function is the usual evaluation of a real polynomial. -/
theorem mem_powerSpan_polynomial {n : ℕ} {f : ℝ → ℝ} (hf : f ∈ powerSpan n) :
    ∃ p : Polynomial ℝ, ∀ x, f x = p.eval x := by
  obtain ⟨c, hc⟩ := mem_powerSpan_iff.mp hf
  refine ⟨∑ i : Fin n, Polynomial.C (c i) * Polynomial.X ^ i.val, ?_⟩
  intro x
  simpa [Polynomial.eval_finsetSum] using hc x

/-- Integrating a bounded-degree polynomial increases the degree bound by one. -/
theorem powerSpan_primitive {n : ℕ} {f : ℝ → ℝ} (hf : f ∈ powerSpan n) :
    ∃ g : ℝ → ℝ, g ∈ powerSpan (n + 1) ∧ ∀ x, HasDerivAt g (f x) x := by
  obtain ⟨c, hc⟩ := mem_powerSpan_iff.mp hf
  let g : ℝ → ℝ := fun x => ∑ i : Fin n, c i / (i.val + 1) * x ^ (i.val + 1)
  refine ⟨g, ?_, ?_⟩
  · have hm (i : Fin n) : (fun x : ℝ => x ^ (i.val + 1)) ∈ powerSpan (n + 1) :=
      Submodule.subset_span ⟨i.succ, rfl⟩
    simpa only [g, Finset.sum_fn, Pi.smul_apply, smul_eq_mul] using
      (powerSpan (n + 1)).sum_mem (t := Finset.univ) (fun i _ =>
        (powerSpan (n + 1)).smul_mem (c i / (i.val + 1)) (hm i))
  · intro x
    have hd (i : Fin n) : HasDerivAt (fun x : ℝ => c i / (i.val + 1) * x ^ (i.val + 1))
        (c i * x ^ i.val) x := by
      convert! (hasDerivAt_pow (i.val + 1) x).const_mul (c i / (i.val + 1)) using 1
      simp only [Nat.add_sub_cancel, Nat.cast_add, Nat.cast_one]
      field_simp
    simpa [g, Finset.sum_fn, ← hc x] using HasDerivAt.sum (fun i (_ : i ∈ Finset.univ) => hd i)

/-- A globally smooth function with zero `n`th derivative is a polynomial of degree `< n`. -/
theorem mem_powerSpan_of_iteratedDeriv_zero {n : ℕ} {f : ℝ → ℝ}
    (hf : ContDiff ℝ ∞ f) (hz : ∀ x, iteratedDeriv n f x = 0) : f ∈ powerSpan n := by
  induction n generalizing f with
  | zero =>
      have : f = 0 := funext (fun x => by simpa using hz x)
      rw [this]
      exact (powerSpan 0).zero_mem
  | succ n ih =>
      have hdf := (contDiff_infty_iff_deriv.mp hf).1
      have hderiv : deriv f ∈ powerSpan n :=
        ih (contDiff_infty_iff_deriv.mp hf).2 (fun x => by simpa [iteratedDeriv_succ'] using hz x)
      obtain ⟨g, hg, hgd⟩ := powerSpan_primitive hderiv
      have hconst : ∀ x, f x - g x = f 0 - g 0 := by
        intro x
        apply is_const_of_deriv_eq_zero (hdf.sub (fun x => (hgd x).differentiableAt)) _ x 0
        intro x
        rw [deriv_sub (hdf x) (hgd x).differentiableAt, (hgd x).deriv, sub_self]
      have hc : (fun _ : ℝ => f 0 - g 0) ∈ powerSpan (n + 1) := by
        have h1 : (fun _ : ℝ => (1 : ℝ)) ∈ powerSpan (n + 1) := by
          simpa [powerSpan] using (Submodule.subset_span (R := ℝ)
            (s := Set.range (fun i : Fin (n + 1) => fun x : ℝ => x ^ i.val)) ⟨0, rfl⟩)
        simpa only [Pi.smul_def, smul_eq_mul, mul_one] using (powerSpan (n + 1)).smul_mem (f 0 - g 0) h1
      convert (powerSpan (n + 1)).add_mem hg hc using 1
      ext x
      simpa only [Pi.add_apply, add_comm] using (sub_eq_iff_eq_add.mp (hconst x))

/-- A pointwise limit of polynomials with a common degree bound has the same bound. -/
theorem mem_powerSpan_of_tendsto {ι : Type*} {l : Filter ι} [l.NeBot]
    {n : ℕ} {f : ι → ℝ → ℝ} {g : ℝ → ℝ}
    (hf : ∀ᶠ i in l, f i ∈ powerSpan n)
    (hg : ∀ x, Tendsto (fun i => f i x) l (𝓝 (g x))) : g ∈ powerSpan n :=
  (powerSpan_closed n).mem_of_tendsto (tendsto_pi_nhds.mpr hg) hf

end NeuralGeneralization.NonpolynomialInterpolation
