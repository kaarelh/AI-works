import StrictCausalPicardRounded

/-! Causal finite-precision bounds on a finite time horizon. No hypotheses
are imposed on nonexistent evaluator coordinates after the horizon. -/
noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic
theorem causal_factorial_bound_finite (H : ℕ) (w : ℕ → ℝ) (hw : ∀ i, 0 ≤ w i)
    (e : ℕ → ℕ → ℝ) {M : ℝ} (hM : 0 ≤ M)
    (hzero : ∀ j≤H, e 0 j ≤ M)
    (hstep : ∀ k j, j≤H → e (k+1) j ≤ ∑ i ∈ Finset.range j, w i*e k i) :
    ∀ k j, j≤H → e k j ≤ M*(∑ i ∈ Finset.range j, w i)^k/(k.factorial:ℝ) := by
  intro k
  induction k with
  | zero => intro j hj; simpa using hzero j hj
  | succ k ih =>
    intro j hj
    have hk : (0:ℝ) < k.factorial := by exact_mod_cast Nat.factorial_pos k
    have hk1 : (0:ℝ) < ((k+1:ℕ):ℝ) := by positivity
    have hs := weighted_prefix_power w hw j k
    calc
      e (k+1) j ≤ ∑ i ∈ Finset.range j, w i*e k i := hstep k j hj
      _ ≤ ∑ i ∈ Finset.range j,
          w i*(M*(∑ a ∈ Finset.range i, w a)^k/(k.factorial:ℝ)) := by
        exact Finset.sum_le_sum fun i hi => mul_le_mul_of_nonneg_left (ih i (by have := Finset.mem_range.mp hi; omega)) (hw i)
      _ = M/(k.factorial:ℝ) *
          (∑ i ∈ Finset.range j, w i*(∑ a ∈ Finset.range i, w a)^k) := by
        rw [Finset.mul_sum]
        apply Finset.sum_congr rfl
        intro i hi
        ring
      _ ≤ M/(k.factorial:ℝ) *
          ((∑ a ∈ Finset.range j, w a)^(k+1)/((k+1:ℕ):ℝ)) := by
        apply mul_le_mul_of_nonneg_left _ (div_nonneg hM hk.le)
        exact (le_div_iff₀ hk1).mpr (by nlinarith)
      _ = M*(∑ a ∈ Finset.range j, w a)^(k+1)/((k+1).factorial:ℝ) := by
        rw [Nat.factorial_succ, Nat.cast_mul]
        field_simp

theorem causal_uniform_forcing_rounded_finite (H : ℕ) (w : ℕ → ℝ) (hw : ∀ i, 0 ≤ w i)
    (e : ℕ → ℕ → ℝ) {δ : ℝ} (hδ : 0 ≤ δ)
    (hzero : ∀ j≤H, e 0 j ≤ δ)
    (hstep : ∀ k j, j≤H → e (k+1) j ≤ δ+∑ i ∈ Finset.range j, w i*e k i) :
    ∀ k j, j≤H → e k j ≤ δ*(∏ i ∈ Finset.range j, (1+w i)) := by
  intro k j hj
  induction j using Nat.strong_induction_on generalizing k with
  | h j ih =>
    cases k with
    | zero =>
      have hp : (1:ℝ)≤∏i∈Finset.range j,(1+w i) := by
        clear ih hj
        induction j with
        | zero => simp
        | succ j hj =>
          rw [Finset.prod_range_succ]
          nlinarith [hw j]
      exact (hzero j hj).trans (by nlinarith [mul_le_mul_of_nonneg_left hp hδ])
    | succ k =>
      calc
        e (k+1) j ≤ δ+∑ i ∈ Finset.range j, w i*e k i := hstep k j hj
        _ ≤ δ+∑ i ∈ Finset.range j, w i*(δ*(∏ a ∈ Finset.range i, (1+w a))) := by
          apply add_le_add le_rfl
          exact Finset.sum_le_sum fun i hi =>
            mul_le_mul_of_nonneg_left (ih i (Finset.mem_range.mp hi) k (by have := Finset.mem_range.mp hi; omega)) (hw i)
        _ = δ*(1+∑ i ∈ Finset.range j, w i*(∏ a ∈ Finset.range i, (1+w a))) := by
          rw [mul_add, mul_one, Finset.mul_sum]
          congr 1
          apply Finset.sum_congr rfl
          intro i hi
          ring
        _ = δ*(∏ i ∈ Finset.range j, (1+w i)) := by rw [prefix_product_identity]

section ActualMaps
variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
theorem picard_factorial_error_finite (H : ℕ) (a : ℕ → E) (C : ℕ → ℕ → E →L[ℝ] E)
    (r : ℕ → E → E) (w : ℕ → ℝ) (hw : ∀ i, 0 ≤ w i)
    (hC : ∀ j i, i<j → ‖C j i‖ ≤ 1)
    (hr : ∀ i x y, ‖r i x-r i y‖ ≤ w i*‖x-y‖)
    (v : ℕ → E) (hv : ∀ j≤H, v j = volterra a C r v j)
    {M : ℝ} (hM : 0 ≤ M) (hinit : ∀ j≤H, ‖a j-v j‖ ≤ M) :
    ∀ k j, j≤H → ‖picard a C r k j-v j‖ ≤
      M*(∑ i ∈ Finset.range j, w i)^k/(k.factorial:ℝ) := by
  apply causal_factorial_bound_finite H w hw (fun k j => ‖picard a C r k j-v j‖) hM
  · exact hinit
  · intro k j hj
    rw [picard, hv j hj]
    exact volterra_distance a C r w hC hr _ _ j

theorem inexact_picard_stability_rounded_finite (H : ℕ) (a : ℕ → E) (C : ℕ → ℕ → E →L[ℝ] E)
    (r : ℕ → E → E) (w : ℕ → ℝ) (hw : ∀ i, 0 ≤ w i)
    (hC : ∀ j i, i<j → ‖C j i‖ ≤ 1)
    (hr : ∀ i x y, ‖r i x-r i y‖ ≤ w i*‖x-y‖)
    (u : ℕ → ℕ → E) {δ : ℝ} (hδ : 0 ≤ δ)
    (hinit : ∀ j≤H, ‖u 0 j-a j‖≤δ)
    (hupdate : ∀ k j, j≤H → ‖u (k+1) j-volterra a C r (u k) j‖ ≤ δ) :
    ∀ k j, j≤H → ‖u k j-picard a C r k j‖ ≤
      δ*Real.exp (∑ i ∈ Finset.range j, w i) := by
  have he := causal_uniform_forcing_rounded_finite H w hw
    (fun k j => ‖u k j-picard a C r k j‖) hδ
    (by intro j hj; simpa only [picard] using hinit j hj)
    (by
      intro k j hj
      change ‖u (k+1) j-volterra a C r (picard a C r k) j‖ ≤ _
      exact (norm_three (u (k+1) j) (volterra a C r (u k) j)
        (volterra a C r (picard a C r k) j)).trans
        (add_le_add (hupdate k j hj) (volterra_distance a C r w hC hr _ _ j)))
  intro k j hj
  exact (he k j hj).trans (mul_le_mul_of_nonneg_left (prefix_product_le_exp w hw j) hδ)

/-- The full error estimate used for finite quadrature and rounded arithmetic. -/
theorem inexact_picard_factorial_error_rounded_finite (H : ℕ) (a : ℕ → E) (C : ℕ → ℕ → E →L[ℝ] E)
    (r : ℕ → E → E) (w : ℕ → ℝ) (hw : ∀ i, 0 ≤ w i)
    (hC : ∀ j i, i<j → ‖C j i‖ ≤ 1)
    (hr : ∀ i x y, ‖r i x-r i y‖ ≤ w i*‖x-y‖)
    (v : ℕ → E) (hv : ∀ j≤H, v j = volterra a C r v j)
    {M δ : ℝ} (hM : 0 ≤ M) (hδ : 0 ≤ δ)
    (hbase : ∀ j≤H, ‖a j-v j‖ ≤ M)
    (u : ℕ → ℕ → E) (hinit : ∀ j≤H, ‖u 0 j-a j‖≤δ)
    (hupdate : ∀ k j, j≤H → ‖u (k+1) j-volterra a C r (u k) j‖ ≤ δ) :
    ∀ k j, j≤H → ‖u k j-v j‖ ≤
      M*(∑ i ∈ Finset.range j, w i)^k/(k.factorial:ℝ)+
      δ*Real.exp (∑ i ∈ Finset.range j, w i) := by
  intro k j hj
  have h1 := inexact_picard_stability_rounded_finite H a C r w hw hC hr u hδ hinit hupdate k j hj
  have h2 := picard_factorial_error_finite H a C r w hw hC hr v hv hM hbase k j hj
  have h3 := norm_three (u k j) (picard a C r k j) (v j)
  linarith

end ActualMaps
#print axioms inexact_picard_factorial_error_rounded_finite
end ConditionalNonpolynomial.Analytic
