import NeuralGeneralization.IIDHoeffding
import NeuralGeneralization.Model
import Mathlib.Tactic.FieldSimp

/-!
# Exponential concentration of an actual Gaussian hidden layer

After fixing the incoming features, rows of the actual weight matrix are
independent. Hoeffding's inequality therefore controls each empirical Gram
entry with exponent proportional to width, uniformly in the variance and in
the incoming features. This is the concentration step in kernel freezing.
-/

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal

namespace NeuralGeneralization.LayerGramConcentration
open CompressionSampling

variable {I J X : Type*} [Fintype I] [Fintype J] [Fintype X]

/-- Flattening rows of independent coordinate vectors gives the original
product measure on the matrix coordinates. -/
theorem measurePreserving_uncurry (μ : I → J → Measure ℝ)
    [∀ i j, IsProbabilityMeasure (μ i j)] :
    MeasurePreserving (MeasurableEquiv.curry I J ℝ).symm
      (Measure.pi fun i => Measure.pi (μ i))
      (Measure.pi fun ij : I × J => μ ij.1 ij.2) := by
  refine ⟨(MeasurableEquiv.curry I J ℝ).symm.measurable, ?_⟩
  refine (Measure.pi_eq fun s _ => ?_).symm
  rw [MeasurableEquiv.map_apply]
  have heq : (MeasurableEquiv.curry I J ℝ).symm ⁻¹' Set.univ.pi s =
      Set.univ.pi (fun i => Set.univ.pi (fun j => s (i, j))) := by
    ext a
    simp only [Set.mem_preimage, Set.mem_pi, Set.mem_univ, forall_true_left]
    exact ⟨fun h i j => h (i, j), fun h ij => h ij.1 ij.2⟩
  rw [heq, Measure.pi_pi]
  simp_rw [Measure.pi_pi]
  rw [Fintype.prod_prod_type]

def rowFeature (φ : ℝ → ℝ) (H : J → X → ℝ) (w : J → ℝ) (x : X) : ℝ :=
  φ (∑ j, w j * H j x)

def covariance (φ : ℝ → ℝ) (H : J → X → ℝ) (v : ℝ≥0) (x y : X) : ℝ :=
  ∫ w, rowFeature φ H w x * rowFeature φ H w y
    ∂Measure.pi (fun _ : J => gaussianReal 0 v)

def empiricalGram (N : ℕ) (φ : ℝ → ℝ) (H : J → X → ℝ)
    (w : Fin N × J → ℝ) (x y : X) : ℝ :=
  (∑ i, rowFeature φ H (fun j => w (i, j)) x *
    rowFeature φ H (fun j => w (i, j)) y) / N

omit [Fintype X] in
theorem rowFeature_product_bound {φ : ℝ → ℝ} (hφ : ∀ t, |φ t| ≤ 1)
    (H : J → X → ℝ) (w : J → ℝ) (x y : X) :
    |rowFeature φ H w x * rowFeature φ H w y| ≤ 1 := by
  rw [abs_mul]
  exact (mul_le_mul (hφ _) (hφ _) (abs_nonneg _) (by norm_num)).trans_eq (one_mul _)

omit [Fintype X] in
/-- Actual finite-width Gaussian layer concentration for each Gram entry.
No limit theorem, Gaussian approximation, or conditional-independence premise
is assumed. -/
theorem gaussian_layer_gram_tail (N : ℕ) (hN : 0 < N) {φ : ℝ → ℝ}
    (hφ : Continuous φ) (hbound : ∀ t, |φ t| ≤ 1)
    (H : J → X → ℝ) (v : ℝ≥0) (x y : X) (ε : ℝ) (hε : 0 ≤ ε) :
    (Measure.pi fun _ : Fin N × J => gaussianReal 0 v).real
      {w | ε ≤ |empiricalGram N φ H w x y - covariance φ H v x y|} ≤
      2 * Real.exp (-(N : ℝ) * ε ^ 2 / 2) := by
  let ν : Measure (J → ℝ) := Measure.pi fun _ => gaussianReal 0 v
  let f : (J → ℝ) → ℝ := fun w => rowFeature φ H w x * rowFeature φ H w y
  have hf : Measurable f := by
    dsimp [f, rowFeature]
    fun_prop
  have ht := iid_bounded_sum_tail ν N f hf (B := 1) (by norm_num)
    (fun w => rowFeature_product_bound hbound H w x y)
    (ε := (N : ℝ) * ε) (mul_nonneg (Nat.cast_nonneg _) hε)
  have hNp : (0 : ℝ) < N := by exact_mod_cast hN
  have hexp : -((N : ℝ) * ε) ^ 2 / (2 * (N : ℝ) * 1 ^ 2) =
      -(N : ℝ) * ε ^ 2 / 2 := by field_simp
  rw [hexp] at ht
  have hs := measurePreserving_uncurry
    (fun (_ : Fin N) (_ : J) => gaussianReal 0 v)
  have hevent : (MeasurableEquiv.curry (Fin N) J ℝ).symm ⁻¹'
      {w | ε ≤ |empiricalGram N φ H w x y - covariance φ H v x y|} =
      {a | (N : ℝ) * ε ≤ |(∑ i, f (a i)) - (N : ℝ) * ∫ w, f w ∂ν|} := by
    ext a
    change ε ≤ |(∑ i, f (a i)) / (N : ℝ) - ∫ w, f w ∂ν| ↔ _
    have hid : (∑ i, f (a i)) / (N : ℝ) - ∫ w, f w ∂ν =
        ((∑ i, f (a i)) - (N : ℝ) * ∫ w, f w ∂ν) / N := by
      field_simp
    rw [hid, abs_div, abs_of_pos hNp, le_div_iff₀ hNp, mul_comm ε]
    rfl
  rw [← hs.map_eq, Measure.real, Measure.map_apply hs.measurable (by
    apply measurableSet_le measurable_const
    apply Measurable.abs
    apply Measurable.sub _ measurable_const
    unfold empiricalGram rowFeature
    fun_prop), hevent]
  exact ht

/-- All entries of the actual empirical covariance matrix concentrate
simultaneously; the only prefactor is twice the number of matrix entries. -/
theorem gaussian_layer_all_entries_tail (N : ℕ) (hN : 0 < N) {φ : ℝ → ℝ}
    (hφ : Continuous φ) (hbound : ∀ t, |φ t| ≤ 1)
    (H : J → X → ℝ) (v : ℝ≥0) (ε : ℝ) (hε : 0 ≤ ε) :
    (Measure.pi fun _ : Fin N × J => gaussianReal 0 v).real
      {w | ∃ x y, ε ≤ |empiricalGram N φ H w x y - covariance φ H v x y|} ≤
      2 * (Fintype.card X : ℝ) ^ 2 * Real.exp (-(N : ℝ) * ε ^ 2 / 2) := by
  classical
  let μ : Measure (Fin N × J → ℝ) := Measure.pi fun _ => gaussianReal 0 v
  let A : X × X → Set (Fin N × J → ℝ) := fun xy =>
    {w | ε ≤ |empiricalGram N φ H w xy.1 xy.2 - covariance φ H v xy.1 xy.2|}
  have heq : {w | ∃ x y, ε ≤ |empiricalGram N φ H w x y - covariance φ H v x y|} =
      ⋃ xy, A xy := by
    ext w
    simp only [Set.mem_setOf_eq, Set.mem_iUnion, A]
    exact ⟨fun ⟨x, y, h⟩ => ⟨(x, y), h⟩, fun ⟨⟨x, y⟩, h⟩ => ⟨x, y, h⟩⟩
  rw [heq]
  calc
    μ.real (⋃ xy, A xy) ≤ ∑ xy, μ.real (A xy) := measureReal_iUnion_fintype_le A
    _ ≤ ∑ _xy : X × X, 2 * Real.exp (-(N : ℝ) * ε ^ 2 / 2) := by
      apply Finset.sum_le_sum
      intro xy hxy
      exact gaussian_layer_gram_tail N hN hφ hbound H v xy.1 xy.2 ε hε
    _ = _ := by simp only [Finset.sum_const, Finset.card_univ, Fintype.card_prod,
        nsmul_eq_mul, Nat.cast_mul]; ring

end NeuralGeneralization.LayerGramConcentration
