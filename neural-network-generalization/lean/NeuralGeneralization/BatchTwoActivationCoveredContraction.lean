import NeuralGeneralization.BatchTwoActivationBoundedContraction
import NeuralGeneralization.BatchTwoActivationScalarCover

/-!
# Exponential contraction with neuron-dependent activations

A finite cover of scalar activations costs its cardinality once, rather than
once per neuron. The cover representatives retain the actual contraction
property. This is the key step permitting arbitrarily heterogeneous auxiliary
activations without a width-dependent description cost.
-/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.BatchTwoActivation
open SquaredSampling

theorem exp_finiteMax_le_sum {K : Type*} [Fintype K] [Nonempty K]
    (f : K → ℝ) (a : ℝ) :
    Real.exp (a * finiteMax f) ≤ ∑ k, Real.exp (a * f k) := by
  classical
  obtain ⟨k,hk⟩ := exists_finiteMax f
  rw [hk]
  exact Finset.single_le_sum (fun j _ => (Real.exp_pos (a*f j)).le) (Finset.mem_univ k)

/-- Contraction for a class with a different scalar activation at every
member. The finite net is shared across the entire class. -/
theorem covered_rademacher_exp_contraction {U K : Type*} [Nonempty U]
    [Fintype K] [Nonempty K] (n : ℕ) (ψ : U → ℝ → ℝ)
    (Φ : K → ℝ → ℝ) (hzero : ∀ k, Φ k 0 = 0)
    (hLip : ∀ k x y, |Φ k x - Φ k y| ≤ |x-y|)
    (t : U → Fin n → ℝ) {R η : ℝ} (ht : ∀ u i, |t u i| ≤ R)
    (code : U → K) (hclose : ∀ u i, |ψ u (t u i) - Φ (code u) (t u i)| ≤ η)
    (a : ℝ) (ha : 0 ≤ a) :
    finiteMean (fun ε : Fin n → Bool =>
      Real.exp (a * envelope (fun u => ∑ i, cubeCoordinateSign (ε i) * ψ u (t u i)))) ≤
    2 * (Fintype.card K : ℝ) * Real.exp (a * ((n : ℝ)*η)) *
      finiteMean (fun ε : Fin n → Bool =>
        Real.exp (a * envelope (fun u => ∑ i, cubeCoordinateSign (ε i) * t u i))) := by
  let Z : (Fin n → Bool) → K → ℝ := fun ε k =>
    envelope (fun u => ∑ i, cubeCoordinateSign (ε i) * Φ k (t u i))
  have hbound (k : K) (u : U) (i : Fin n) : |Φ k (t u i)| ≤ R := by
    have h := hLip k (t u i) 0
    simp only [hzero, sub_zero] at h
    exact h.trans (ht u i)
  have happrox (ε : Fin n → Bool) :
      envelope (fun u => ∑ i, cubeCoordinateSign (ε i) * ψ u (t u i)) ≤
        (n : ℝ)*η + finiteMax (Z ε) := by
    apply envelope_le
    intro u
    let orig : ℝ := ∑ i, cubeCoordinateSign (ε i) * ψ u (t u i)
    let net : ℝ := ∑ i, cubeCoordinateSign (ε i) * Φ (code u) (t u i)
    have hdiff : |orig - net| ≤ (n : ℝ)*η := by
      have h := signed_sum_abs_le (fun i => ψ u (t u i) - Φ (code u) (t u i))
        (hclose u) ε
      simpa only [mul_sub, Finset.sum_sub_distrib] using h
    have hnet : |net| ≤ Z ε (code u) :=
      le_envelope _ (fun v => signed_sum_abs_le _ (hbound (code u) v) ε) u
    have hz := le_finiteMax (Z ε) (code u)
    have htriangle : |orig| ≤ |orig-net| + |net| := by
      simpa only [sub_zero] using abs_sub_le orig net 0
    change |orig| ≤ _
    linarith
  have hpoint (ε : Fin n → Bool) :
      Real.exp (a * envelope (fun u => ∑ i, cubeCoordinateSign (ε i) * ψ u (t u i))) ≤
        Real.exp (a*((n : ℝ)*η)) * ∑ k, Real.exp (a * Z ε k) := by
    calc
      _ ≤ Real.exp (a*((n : ℝ)*η + finiteMax (Z ε))) :=
        Real.exp_le_exp.mpr (mul_le_mul_of_nonneg_left (happrox ε) ha)
      _ = Real.exp (a*((n : ℝ)*η)) * Real.exp (a * finiteMax (Z ε)) := by
        rw [mul_add, Real.exp_add]
      _ ≤ _ := mul_le_mul_of_nonneg_left (exp_finiteMax_le_sum (Z ε) a)
        (Real.exp_pos _).le
  have hmean := finiteMean_mono hpoint
  rw [finiteMean_mul, finiteMean_sum] at hmean
  let V := finiteMean (fun ε : Fin n → Bool =>
    Real.exp (a * envelope (fun u => ∑ i, cubeCoordinateSign (ε i) * t u i)))
  have hterm (k : K) : finiteMean (fun ε : Fin n → Bool => Real.exp (a * Z ε k)) ≤ 2*V :=
    bounded_rademacher_exp_contraction n (fun _ => Φ k) (fun _ => hzero k)
      (fun _ => hLip k) t ht a ha
  have hsum := Finset.sum_le_sum (fun k (_ : k ∈ Finset.univ) => hterm k)
  have hlast := mul_le_mul_of_nonneg_left hsum (Real.exp_pos (a*((n : ℝ)*η))).le
  simp only [Finset.sum_const, Finset.card_univ, nsmul_eq_mul] at hlast
  calc
    _ ≤ _ := hmean.trans hlast
    _ = _ := by ring

end NeuralGeneralization.BatchTwoActivation
