import Mathlib.Analysis.MeanInequalities
import Mathlib.MeasureTheory.Integral.Prod
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Positivity

/-!
# Square-mean block balancing

Squaring the integral permits a direct finite AM--GM proof on a product
measure. This proves the block-replacement estimate without logarithms,
zero-ratio cases, or an assumed neural block-balancing theorem.
-/

noncomputable section

namespace NeuralGeneralization.OnlineLowerRelu

open MeasureTheory
open scoped BigOperators

section ArithmeticMean

variable {ι : Type*} [Fintype ι] [Nonempty ι]

/-- The finite equal-weight Young inequality in the natural-power form
needed after squaring the Fourier potential. -/
theorem prod_le_mean_pow_card (z : ι → ℝ) (hz : ∀ i, 0 ≤ z i) :
    (∏ i, z i) ≤ (Fintype.card ι : ℝ)⁻¹ * ∑ i, z i ^ Fintype.card ι := by
  classical
  have hc : (Fintype.card ι : ℝ) ≠ 0 := by exact_mod_cast Fintype.card_ne_zero
  have hcpos : (0 : ℝ) < Fintype.card ι := by exact_mod_cast Fintype.card_pos
  have hs : (∑ _ : ι, (Fintype.card ι : ℝ)⁻¹) = 1 := by simp [hc]
  have hroot (i : ι) : (z i ^ Fintype.card ι) ^ ((Fintype.card ι : ℝ)⁻¹) = z i := by
    rw [← Real.rpow_natCast, ← Real.rpow_mul (hz i), mul_inv_cancel₀ hc, Real.rpow_one]
  have h := Real.geom_mean_le_arith_mean_weighted Finset.univ
    (fun _ : ι => (Fintype.card ι : ℝ)⁻¹)
    (fun i => z i ^ Fintype.card ι)
    (fun _ _ => inv_nonneg.mpr hcpos.le) hs
    (fun i _ => pow_nonneg (hz i) _)
  simp_rw [hroot] at h
  simpa only [← Finset.mul_sum] using h

/-- Pointwise AM--GM comparison for the squared-integral tensor. -/
theorem blockReplacement_tensor_le {α : Type*} (g : α → ℝ) (f : ι → α → ℝ)
    (hg : ∀ x, 0 ≤ g x) (hf : ∀ i x, 0 ≤ f i x) (x y : α) :
    (g x * ∏ i, f i x) * (g y * ∏ i, f i y) ≤
      (Fintype.card ι : ℝ)⁻¹ *
        ∑ i, (g x * f i x ^ Fintype.card ι) * (g y * f i y ^ Fintype.card ι) := by
  have hmean := prod_le_mean_pow_card (fun i => f i x * f i y)
    (fun i => mul_nonneg (hf i x) (hf i y))
  have hmul := mul_le_mul_of_nonneg_left hmean (mul_nonneg (hg x) (hg y))
  calc
    (g x * ∏ i, f i x) * (g y * ∏ i, f i y) =
        (g x * g y) * ∏ i, f i x * f i y := by
      rw [Finset.prod_mul_distrib]
      ring
    _ ≤ (g x * g y) * ((Fintype.card ι : ℝ)⁻¹ *
        ∑ i, (f i x * f i y) ^ Fintype.card ι) := hmul
    _ = (Fintype.card ι : ℝ)⁻¹ *
        ∑ i, (g x * f i x ^ Fintype.card ι) *
          (g y * f i y ^ Fintype.card ι) := by
      simp_rw [mul_pow, Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro i _
      ring

end ArithmeticMean

section SquareIntegral

variable {α ι : Type*} [MeasurableSpace α] [Fintype ι] [Nonempty ι]
variable {μ : Measure α} [SFinite μ]

/-- Exact one-block quadratic replacement inequality. The common factor
includes the coefficient weight, every other block, and the Fourier kernel.
The index type may therefore be a disjoint union of coefficient copies of
the integration line. -/
theorem square_integral_block_replacement
    (g : α → ℝ) (f : ι → α → ℝ)
    (hg : ∀ x, 0 ≤ g x) (hf : ∀ i x, 0 ≤ f i x)
    (hbase : Integrable (fun x => g x * ∏ i, f i x) μ)
    (hreplace : ∀ i, Integrable (fun x => g x * f i x ^ Fintype.card ι) μ) :
    (∫ x, g x * ∏ i, f i x ∂μ) ^ 2 ≤
      (Fintype.card ι : ℝ)⁻¹ *
        ∑ i, (∫ x, g x * f i x ^ Fintype.card ι ∂μ) ^ 2 := by
  classical
  let G := fun x => g x * ∏ i, f i x
  let H := fun i x => g x * f i x ^ Fintype.card ι
  have hpoint (z : α × α) : G z.1 * G z.2 ≤
      (Fintype.card ι : ℝ)⁻¹ * ∑ i, H i z.1 * H i z.2 := by
    exact blockReplacement_tensor_le g f hg hf z.1 z.2

  have hleft : Integrable (fun z : α × α => G z.1 * G z.2) (μ.prod μ) :=
    hbase.mul_prod hbase
  have hterms (i : ι) : Integrable (fun z : α × α => H i z.1 * H i z.2) (μ.prod μ) :=
    (hreplace i).mul_prod (hreplace i)
  have hright : Integrable (fun z : α × α =>
      (Fintype.card ι : ℝ)⁻¹ * ∑ i, H i z.1 * H i z.2) (μ.prod μ) :=
    (integrable_finsetSum Finset.univ (fun i _ => hterms i)).const_mul _
  have hmain := integral_mono hleft hright hpoint
  rw [integral_prod_mul, integral_const_mul, integral_finsetSum] at hmain
  · simp_rw [integral_prod_mul, ← pow_two] at hmain
    exact hmain
  · intro i _
    exact hterms i

end SquareIntegral

section SimultaneousBlocks

variable {κ : Type*} [Fintype κ] [DecidableEq κ] {β : κ → Type*}
variable [∀ j, Fintype (β j)] [∀ j, Nonempty (β j)]

/-- Independent AM--GM in every block, expanded into the literal dependent
finite sampling law. -/
theorem prod_blocks_le_mean_replacements (z : (j : κ) → β j → ℝ)
    (hz : ∀ j k, 0 ≤ z j k) :
    (∏ j, ∏ k, z j k) ≤
      (∏ j, (Fintype.card (β j) : ℝ)⁻¹) *
        ∑ pick : (j : κ) → β j, ∏ j, z j (pick j) ^ Fintype.card (β j) := by
  classical
  calc
    _ ≤ ∏ j, (Fintype.card (β j) : ℝ)⁻¹ *
        ∑ k, z j k ^ Fintype.card (β j) :=
      Finset.prod_le_prod (fun j _ => Finset.prod_nonneg (fun k _ => hz j k))
        (fun j _ => prod_le_mean_pow_card (z j) (hz j))
    _ = _ := by rw [Finset.prod_mul_distrib, Fintype.prod_sum]

/-- Simultaneous tensor comparison for all coordinate blocks. -/
theorem allBlocks_tensor_le {α : Type*} (g : α → ℝ)
    (f : (j : κ) → β j → α → ℝ)
    (hg : ∀ x, 0 ≤ g x) (hf : ∀ j k x, 0 ≤ f j k x) (x y : α) :
    (g x * ∏ j, ∏ k, f j k x) * (g y * ∏ j, ∏ k, f j k y) ≤
      (∏ j, (Fintype.card (β j) : ℝ)⁻¹) *
        ∑ pick : (j : κ) → β j,
          (g x * ∏ j, f j (pick j) x ^ Fintype.card (β j)) *
          (g y * ∏ j, f j (pick j) y ^ Fintype.card (β j)) := by
  have h := prod_blocks_le_mean_replacements (fun j k => f j k x * f j k y)
    (fun j k => mul_nonneg (hf j k x) (hf j k y))
  have hm := mul_le_mul_of_nonneg_left h (mul_nonneg (hg x) (hg y))
  calc
    _ = (g x * g y) * ∏ j, ∏ k, f j k x * f j k y := by
      simp_rw [Finset.prod_mul_distrib]
      ring
    _ ≤ (g x * g y) * ((∏ j, (Fintype.card (β j) : ℝ)⁻¹) *
        ∑ pick : (j : κ) → β j,
          ∏ j, (f j (pick j) x * f j (pick j) y) ^ Fintype.card (β j)) := hm
    _ = _ := by
      simp_rw [mul_pow, Finset.prod_mul_distrib, Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro pick _
      ring

variable {α : Type*} [MeasurableSpace α] {μ : Measure α} [SFinite μ]

/-- All rails may be balanced in one step. The conclusion averages over
actual independent coordinate choices, with their exact product weights. -/
theorem square_integral_all_blocks_replacement
    (g : α → ℝ) (f : (j : κ) → β j → α → ℝ)
    (hg : ∀ x, 0 ≤ g x) (hf : ∀ j k x, 0 ≤ f j k x)
    (hbase : Integrable (fun x => g x * ∏ j, ∏ k, f j k x) μ)
    (hreplace : ∀ pick : (j : κ) → β j,
      Integrable (fun x => g x * ∏ j, f j (pick j) x ^ Fintype.card (β j)) μ) :
    (∫ x, g x * ∏ j, ∏ k, f j k x ∂μ) ^ 2 ≤
      (∏ j, (Fintype.card (β j) : ℝ)⁻¹) *
        ∑ pick : (j : κ) → β j,
          (∫ x, g x * ∏ j, f j (pick j) x ^ Fintype.card (β j) ∂μ) ^ 2 := by
  classical
  let G := fun x => g x * ∏ j, ∏ k, f j k x
  let H := fun (pick : (j : κ) → β j) x =>
    g x * ∏ j, f j (pick j) x ^ Fintype.card (β j)
  have hpoint (z : α × α) : G z.1 * G z.2 ≤
      (∏ j, (Fintype.card (β j) : ℝ)⁻¹) *
        ∑ pick, H pick z.1 * H pick z.2 :=
    allBlocks_tensor_le g f hg hf z.1 z.2
  have hleft : Integrable (fun z : α × α => G z.1 * G z.2) (μ.prod μ) :=
    hbase.mul_prod hbase
  have hterms (pick : (j : κ) → β j) :
      Integrable (fun z : α × α => H pick z.1 * H pick z.2) (μ.prod μ) :=
    (hreplace pick).mul_prod (hreplace pick)
  have hright : Integrable (fun z : α × α =>
      (∏ j, (Fintype.card (β j) : ℝ)⁻¹) * ∑ pick, H pick z.1 * H pick z.2)
        (μ.prod μ) :=
    (integrable_finsetSum Finset.univ (fun pick _ => hterms pick)).const_mul _
  have hmain := integral_mono hleft hright hpoint
  rw [integral_prod_mul, integral_const_mul, integral_finsetSum] at hmain
  · simp_rw [integral_prod_mul, ← pow_two] at hmain
    exact hmain
  · intro pick _
    exact hterms pick

end SimultaneousBlocks

end NeuralGeneralization.OnlineLowerRelu
