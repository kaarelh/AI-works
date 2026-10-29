import StrictCausalPicard

/-! Uniform finite-precision initialization costs the same resolvent factor
as one inexact update, without a factor depending on the iteration count. -/
noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic
theorem causal_uniform_forcing_rounded (w : ℕ → ℝ) (hw : ∀ i, 0 ≤ w i)
    (e : ℕ → ℕ → ℝ) {δ : ℝ} (hδ : 0 ≤ δ)
    (hzero : ∀ j, e 0 j ≤ δ)
    (hstep : ∀ k j, e (k+1) j ≤ δ+∑ i ∈ Finset.range j, w i*e k i) :
    ∀ k j, e k j ≤ δ*(∏ i ∈ Finset.range j, (1+w i)) := by
  intro k j
  induction j using Nat.strong_induction_on generalizing k with
  | h j ih =>
    cases k with
    | zero =>
      have hp : (1:ℝ)≤∏i∈Finset.range j,(1+w i) := by
        clear ih
        induction j with
        | zero => simp
        | succ j hj =>
          rw [Finset.prod_range_succ]
          nlinarith [hw j]
      exact (hzero j).trans (by nlinarith [mul_le_mul_of_nonneg_left hp hδ])
    | succ k =>
      calc
        e (k+1) j ≤ δ+∑ i ∈ Finset.range j, w i*e k i := hstep k j
        _ ≤ δ+∑ i ∈ Finset.range j, w i*(δ*(∏ a ∈ Finset.range i, (1+w a))) := by
          apply add_le_add le_rfl
          exact Finset.sum_le_sum fun i hi =>
            mul_le_mul_of_nonneg_left (ih i (Finset.mem_range.mp hi) k) (hw i)
        _ = δ*(1+∑ i ∈ Finset.range j, w i*(∏ a ∈ Finset.range i, (1+w a))) := by
          rw [mul_add, mul_one, Finset.mul_sum]
          congr 1
          apply Finset.sum_congr rfl
          intro i hi
          ring
        _ = δ*(∏ i ∈ Finset.range j, (1+w i)) := by rw [prefix_product_identity]

section ActualMaps
variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
theorem inexact_picard_stability_rounded (a : ℕ → E) (C : ℕ → ℕ → E →L[ℝ] E)
    (r : ℕ → E → E) (w : ℕ → ℝ) (hw : ∀ i, 0 ≤ w i)
    (hC : ∀ j i, i<j → ‖C j i‖ ≤ 1)
    (hr : ∀ i x y, ‖r i x-r i y‖ ≤ w i*‖x-y‖)
    (u : ℕ → ℕ → E) {δ : ℝ} (hδ : 0 ≤ δ)
    (hinit : ∀ j, ‖u 0 j-a j‖≤δ)
    (hupdate : ∀ k j, ‖u (k+1) j-volterra a C r (u k) j‖ ≤ δ) :
    ∀ k j, ‖u k j-picard a C r k j‖ ≤
      δ*Real.exp (∑ i ∈ Finset.range j, w i) := by
  have he := causal_uniform_forcing_rounded w hw
    (fun k j => ‖u k j-picard a C r k j‖) hδ
    (by intro j; simpa only [picard] using hinit j)
    (by
      intro k j
      change ‖u (k+1) j-volterra a C r (picard a C r k) j‖ ≤ _
      exact (norm_three (u (k+1) j) (volterra a C r (u k) j)
        (volterra a C r (picard a C r k) j)).trans
        (add_le_add (hupdate k j) (volterra_distance a C r w hC hr _ _ j)))
  intro k j
  exact (he k j).trans (mul_le_mul_of_nonneg_left (prefix_product_le_exp w hw j) hδ)

/-- The full error estimate used for finite quadrature and rounded arithmetic. -/
theorem inexact_picard_factorial_error_rounded (a : ℕ → E) (C : ℕ → ℕ → E →L[ℝ] E)
    (r : ℕ → E → E) (w : ℕ → ℝ) (hw : ∀ i, 0 ≤ w i)
    (hC : ∀ j i, i<j → ‖C j i‖ ≤ 1)
    (hr : ∀ i x y, ‖r i x-r i y‖ ≤ w i*‖x-y‖)
    (v : ℕ → E) (hv : ∀ j, v j = volterra a C r v j)
    {M δ : ℝ} (hM : 0 ≤ M) (hδ : 0 ≤ δ)
    (hbase : ∀ j, ‖a j-v j‖ ≤ M)
    (u : ℕ → ℕ → E) (hinit : ∀ j, ‖u 0 j-a j‖≤δ)
    (hupdate : ∀ k j, ‖u (k+1) j-volterra a C r (u k) j‖ ≤ δ) :
    ∀ k j, ‖u k j-v j‖ ≤
      M*(∑ i ∈ Finset.range j, w i)^k/(k.factorial:ℝ)+
      δ*Real.exp (∑ i ∈ Finset.range j, w i) := by
  intro k j
  have h1 := inexact_picard_stability_rounded a C r w hw hC hr u hδ hinit hupdate k j
  have h2 := picard_factorial_error a C r w hw hC hr v hv hM hbase k j
  have h3 := norm_three (u k j) (picard a C r k j) (v j)
  linarith

end ActualMaps
#print axioms inexact_picard_factorial_error_rounded
end ConditionalNonpolynomial.Analytic
