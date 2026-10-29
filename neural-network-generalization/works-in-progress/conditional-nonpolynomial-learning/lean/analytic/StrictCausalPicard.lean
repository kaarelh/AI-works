import Mathlib.Analysis.Normed.Operator.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Data.Nat.Factorial.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Positivity

/-! # Strictly causal Picard iteration

Actual Volterra maps with contractive linear propagators and Lipschitz
nonlinear residuals. The factorial estimate is derived, not hypothesized.
-/
noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic

/-- Tangent-line lower bound for a nonnegative integral power. -/
theorem power_increment_lower (k : ℕ) {x y : ℝ} (hx : 0 ≤ x) (hy : 0 ≤ y) :
    x^(k+1)+((k+1:ℕ):ℝ)*y*x^k ≤ (x+y)^(k+1) := by
  induction k with
  | zero => simp
  | succ k ih =>
    have hm := mul_le_mul_of_nonneg_right ih (add_nonneg hx hy)
    have hp : 0 ≤ ((k+1:ℕ):ℝ)*y^2*x^k := by positivity
    simp only [Nat.cast_add, Nat.cast_one, pow_succ] at hm hp ⊢
    nlinarith

/-- A discrete integral estimate with the strict prefix, which is precisely
where the factorial gain in causal iteration originates. -/
theorem weighted_prefix_power (w : ℕ → ℝ) (hw : ∀ i, 0 ≤ w i) (j k : ℕ) :
    ((k+1:ℕ):ℝ) * (∑ i ∈ Finset.range j, w i*(∑ a ∈ Finset.range i, w a)^k)
      ≤ (∑ a ∈ Finset.range j, w a)^(k+1) := by
  induction j with
  | zero => simp
  | succ j ih =>
    have hs : 0 ≤ ∑ a ∈ Finset.range j, w a := Finset.sum_nonneg fun i _ => hw i
    have hp := power_increment_lower k hs (hw j)
    simp only [Finset.sum_range_succ] at *
    nlinarith

/-- Scalar error propagation for any strictly causal recurrence. -/
theorem causal_factorial_bound (w : ℕ → ℝ) (hw : ∀ i, 0 ≤ w i)
    (e : ℕ → ℕ → ℝ) {M : ℝ} (hM : 0 ≤ M)
    (hzero : ∀ j, e 0 j ≤ M)
    (hstep : ∀ k j, e (k+1) j ≤ ∑ i ∈ Finset.range j, w i*e k i) :
    ∀ k j, e k j ≤ M*(∑ i ∈ Finset.range j, w i)^k/(k.factorial:ℝ) := by
  intro k
  induction k with
  | zero => intro j; simpa using hzero j
  | succ k ih =>
    intro j
    have hk : (0:ℝ) < k.factorial := by exact_mod_cast Nat.factorial_pos k
    have hk1 : (0:ℝ) < ((k+1:ℕ):ℝ) := by positivity
    have hs := weighted_prefix_power w hw j k
    calc
      e (k+1) j ≤ ∑ i ∈ Finset.range j, w i*e k i := hstep k j
      _ ≤ ∑ i ∈ Finset.range j,
          w i*(M*(∑ a ∈ Finset.range i, w a)^k/(k.factorial:ℝ)) := by
        exact Finset.sum_le_sum fun i hi => mul_le_mul_of_nonneg_left (ih i) (hw i)
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

/-- The discrete resolvent identity for nonnegative causal weights. -/
theorem prefix_product_identity (w : ℕ → ℝ) (j : ℕ) :
    1+(∑ i ∈ Finset.range j, w i*(∏ a ∈ Finset.range i, (1+w a))) =
      ∏ a ∈ Finset.range j, (1+w a) := by
  induction j with
  | zero => simp
  | succ j ih =>
    simp only [Finset.sum_range_succ, Finset.prod_range_succ]
    rw [← ih]
    ring

theorem prefix_product_le_exp (w : ℕ → ℝ) (hw : ∀ i, 0 ≤ w i) (j : ℕ) :
    (∏ a ∈ Finset.range j, (1+w a)) ≤ Real.exp (∑ a ∈ Finset.range j, w a) := by
  induction j with
  | zero => simp
  | succ j ih =>
    simp only [Finset.prod_range_succ, Finset.sum_range_succ, Real.exp_add]
    exact mul_le_mul ih (by simpa [add_comm] using Real.add_one_le_exp (w j))
      (by linarith [hw j]) (Real.exp_nonneg _)

/-- Any number of inexact causal iterations amplifies a uniform additive
error by at most the product resolvent. This proof inducts on time, not on the
iteration count, so it has no factor growing with the number of iterations. -/
theorem causal_uniform_forcing (w : ℕ → ℝ) (hw : ∀ i, 0 ≤ w i)
    (e : ℕ → ℕ → ℝ) {δ : ℝ} (hδ : 0 ≤ δ)
    (hzero : ∀ j, e 0 j ≤ 0)
    (hstep : ∀ k j, e (k+1) j ≤ δ+∑ i ∈ Finset.range j, w i*e k i) :
    ∀ k j, e k j ≤ δ*(∏ i ∈ Finset.range j, (1+w i)) := by
  intro k j
  induction j using Nat.strong_induction_on generalizing k with
  | h j ih =>
    cases k with
    | zero =>
      exact (hzero j).trans (mul_nonneg hδ
        (Finset.prod_nonneg fun i hi => by linarith [hw i]))
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

/-- The exact product of linear transitions from time i to time j.
Only i≤j is used. Empty products are the identity. -/
def propagation (A : ℕ → E →L[ℝ] E) : ℕ → ℕ → E →L[ℝ] E
  | 0, _ => ContinuousLinearMap.id ℝ E
  | j+1, i => if i≤j then (A j).comp (propagation A j i)
      else ContinuousLinearMap.id ℝ E

@[simp] theorem propagation_self (A : ℕ → E →L[ℝ] E) (j : ℕ) :
    propagation A j j = ContinuousLinearMap.id ℝ E := by
  cases j <;> simp [propagation]

theorem propagation_contracts (A : ℕ → E →L[ℝ] E)
    (hA : ∀ i, ‖A i‖ ≤ 1) (j i : ℕ) : ‖propagation A j i‖ ≤ 1 := by
  induction j with
  | zero => exact ContinuousLinearMap.norm_id_le
  | succ j ih =>
    simp only [propagation]
    split_ifs
    · exact ((A j).opNorm_comp_le _).trans
        ((mul_le_mul (hA j) ih (norm_nonneg _) (by norm_num)).trans_eq (by ring))
    · exact ContinuousLinearMap.norm_id_le

/-- All coordinates of one Picard update are evaluated simultaneously. -/
def volterra (a : ℕ → E) (C : ℕ → ℕ → E →L[ℝ] E)
    (r : ℕ → E → E) (v : ℕ → E) (j : ℕ) : E :=
  a j + ∑ i ∈ Finset.range j, C j i (r i (v i))

/-- The ordinary sequential recurrence unrolls into the actual Volterra
system used by the parallel iteration. No independent solution assumption is
needed when this lemma supplies it. -/
theorem sequential_eq_volterra (A : ℕ → E →L[ℝ] E) (r : ℕ → E → E)
    (v : ℕ → E) (hv : ∀ j, v (j+1) = A j (v j)+r j (v j)) :
    ∀ j, v j = volterra (fun j => propagation A j 0 (v 0))
      (fun j i => propagation A j (i+1)) r v j := by
  intro j
  induction j with
  | zero => simp [volterra, propagation]
  | succ j ih =>
    simp only [volterra, Finset.sum_range_succ, propagation_self,
      ContinuousLinearMap.id_apply]
    rw [hv j, ← add_assoc]
    congr 1
    rw [ih]
    simp only [volterra, map_add, map_sum]
    have hfirst : propagation A (j+1) 0 (v 0) = A j (propagation A j 0 (v 0)) := by
      simp [propagation]
    rw [hfirst]
    congr 1
    apply Finset.sum_congr rfl
    intro i hi
    have hij : i+1≤j := Nat.succ_le_iff.mpr (Finset.mem_range.mp hi)
    simp [propagation, hij]

def picard (a : ℕ → E) (C : ℕ → ℕ → E →L[ℝ] E)
    (r : ℕ → E → E) : ℕ → (ℕ → E)
  | 0 => a
  | k+1 => volterra a C r (picard a C r k)

theorem volterra_distance (a : ℕ → E) (C : ℕ → ℕ → E →L[ℝ] E)
    (r : ℕ → E → E) (w : ℕ → ℝ)
    (hC : ∀ j i, i<j → ‖C j i‖ ≤ 1)
    (hr : ∀ i x y, ‖r i x-r i y‖ ≤ w i*‖x-y‖)
    (v z : ℕ → E) (j : ℕ) :
    ‖volterra a C r v j-volterra a C r z j‖ ≤
      ∑ i ∈ Finset.range j, w i*‖v i-z i‖ := by
  simp only [volterra, add_sub_add_left_eq_sub, ← Finset.sum_sub_distrib,
    ← map_sub]
  apply (norm_sum_le _ _).trans
  apply Finset.sum_le_sum
  intro i hi
  calc
    ‖C j i (r i (v i)-r i (z i))‖ ≤ ‖C j i‖ * ‖r i (v i)-r i (z i)‖ :=
      (C j i).le_opNorm _
    _ ≤ 1*‖r i (v i)-r i (z i)‖ :=
      mul_le_mul_of_nonneg_right (hC j i (Finset.mem_range.mp hi)) (norm_nonneg _)
    _ ≤ w i*‖v i-z i‖ := by simpa using hr i (v i) (z i)

/-- Actual nonlinear Picard iterates have a factorial error bound against an
actual solution of the Volterra equation. The initial discrepancy is the only
error hypothesis; later errors are proved from contractivity and Lipschitzness. -/
theorem picard_factorial_error (a : ℕ → E) (C : ℕ → ℕ → E →L[ℝ] E)
    (r : ℕ → E → E) (w : ℕ → ℝ) (hw : ∀ i, 0 ≤ w i)
    (hC : ∀ j i, i<j → ‖C j i‖ ≤ 1)
    (hr : ∀ i x y, ‖r i x-r i y‖ ≤ w i*‖x-y‖)
    (v : ℕ → E) (hv : ∀ j, v j = volterra a C r v j)
    {M : ℝ} (hM : 0 ≤ M) (hinit : ∀ j, ‖a j-v j‖ ≤ M) :
    ∀ k j, ‖picard a C r k j-v j‖ ≤
      M*(∑ i ∈ Finset.range j, w i)^k/(k.factorial:ℝ) := by
  apply causal_factorial_bound w hw (fun k j => ‖picard a C r k j-v j‖) hM
  · exact hinit
  · intro k j
    rw [picard, hv j]
    exact volterra_distance a C r w hC hr _ _ j

omit [NormedSpace ℝ E] in
theorem norm_three (x y z : E) : ‖x-z‖ ≤ ‖x-y‖+‖y-z‖ := by
  simpa only [dist_eq_norm] using dist_triangle x y z

/-- Uniform update errors are measured against the exact nonlinear maps;
the approximate maps need not satisfy a Lipschitz bound. -/
theorem inexact_picard_stability (a : ℕ → E) (C : ℕ → ℕ → E →L[ℝ] E)
    (r : ℕ → E → E) (w : ℕ → ℝ) (hw : ∀ i, 0 ≤ w i)
    (hC : ∀ j i, i<j → ‖C j i‖ ≤ 1)
    (hr : ∀ i x y, ‖r i x-r i y‖ ≤ w i*‖x-y‖)
    (u : ℕ → ℕ → E) {δ : ℝ} (hδ : 0 ≤ δ)
    (hinit : ∀ j, u 0 j = a j)
    (hupdate : ∀ k j, ‖u (k+1) j-volterra a C r (u k) j‖ ≤ δ) :
    ∀ k j, ‖u k j-picard a C r k j‖ ≤
      δ*Real.exp (∑ i ∈ Finset.range j, w i) := by
  have he := causal_uniform_forcing w hw
    (fun k j => ‖u k j-picard a C r k j‖) hδ
    (by intro j; simp [picard, hinit])
    (by
      intro k j
      change ‖u (k+1) j-volterra a C r (picard a C r k) j‖ ≤ _
      exact (norm_three (u (k+1) j) (volterra a C r (u k) j)
        (volterra a C r (picard a C r k) j)).trans
        (add_le_add (hupdate k j) (volterra_distance a C r w hC hr _ _ j)))
  intro k j
  exact (he k j).trans (mul_le_mul_of_nonneg_left (prefix_product_le_exp w hw j) hδ)

/-- The full error estimate used for finite quadrature and rounded arithmetic. -/
theorem inexact_picard_factorial_error (a : ℕ → E) (C : ℕ → ℕ → E →L[ℝ] E)
    (r : ℕ → E → E) (w : ℕ → ℝ) (hw : ∀ i, 0 ≤ w i)
    (hC : ∀ j i, i<j → ‖C j i‖ ≤ 1)
    (hr : ∀ i x y, ‖r i x-r i y‖ ≤ w i*‖x-y‖)
    (v : ℕ → E) (hv : ∀ j, v j = volterra a C r v j)
    {M δ : ℝ} (hM : 0 ≤ M) (hδ : 0 ≤ δ)
    (hbase : ∀ j, ‖a j-v j‖ ≤ M)
    (u : ℕ → ℕ → E) (hinit : ∀ j, u 0 j = a j)
    (hupdate : ∀ k j, ‖u (k+1) j-volterra a C r (u k) j‖ ≤ δ) :
    ∀ k j, ‖u k j-v j‖ ≤
      M*(∑ i ∈ Finset.range j, w i)^k/(k.factorial:ℝ)+
      δ*Real.exp (∑ i ∈ Finset.range j, w i) := by
  intro k j
  have h1 := inexact_picard_stability a C r w hw hC hr u hδ hinit hupdate k j
  have h2 := picard_factorial_error a C r w hw hC hr v hv hM hbase k j
  have h3 := norm_three (u k j) (picard a C r k j) (v j)
  linarith

/-- Bounded residual ranges give one fixed evaluation range for every
parallel update, independent of the supplied approximate state. -/
theorem volterra_range_bound (a : ℕ → E) (C : ℕ → ℕ → E →L[ℝ] E)
    (r : ℕ → E → E) (B : ℕ → ℝ)
    (hC : ∀ j i, i<j → ‖C j i‖ ≤ 1)
    (hr : ∀ i x, ‖r i x‖ ≤ B i) (v : ℕ → E) (j : ℕ) :
    ‖volterra a C r v j‖ ≤ ‖a j‖+∑ i ∈ Finset.range j, B i := by
  apply (norm_add_le _ _).trans
  apply add_le_add le_rfl
  apply (norm_sum_le _ _).trans
  apply Finset.sum_le_sum
  intro i hi
  calc
    ‖C j i (r i (v i))‖ ≤ ‖C j i‖*‖r i (v i)‖ := (C j i).le_opNorm _
    _ ≤ 1*‖r i (v i)‖ := mul_le_mul_of_nonneg_right
      (hC j i (Finset.mem_range.mp hi)) (norm_nonneg _)
    _ ≤ B i := by simpa using hr i (v i)

/-- Every exact Picard iterate remains in the same bounded evaluation range. -/
theorem picard_range_bound (a : ℕ → E) (C : ℕ → ℕ → E →L[ℝ] E)
    (r : ℕ → E → E) (B : ℕ → ℝ)
    (hC : ∀ j i, i<j → ‖C j i‖ ≤ 1)
    (hr : ∀ i x, ‖r i x‖ ≤ B i) (k j : ℕ) :
    ‖picard a C r k j‖ ≤ ‖a j‖+∑ i ∈ Finset.range j, B i := by
  cases k with
  | zero =>
    simp only [picard]
    have hB : 0 ≤ ∑ i ∈ Finset.range j, B i :=
      Finset.sum_nonneg fun i hi => (norm_nonneg _).trans (hr i 0)
    linarith
  | succ k => exact volterra_range_bound a C r B hC hr _ j

/-- The same range enlarged by the per-update error also contains inexact
updates; no Lipschitz property of the approximate evaluator is assumed. -/
theorem inexact_update_range (a : ℕ → E) (C : ℕ → ℕ → E →L[ℝ] E)
    (r : ℕ → E → E) (B : ℕ → ℝ)
    (hC : ∀ j i, i<j → ‖C j i‖ ≤ 1)
    (hr : ∀ i x, ‖r i x‖ ≤ B i)
    (v : ℕ → E) (j : ℕ) (z : E) {δ : ℝ}
    (hz : ‖z-volterra a C r v j‖ ≤ δ) :
    ‖z‖ ≤ δ+‖a j‖+∑ i ∈ Finset.range j, B i := by
  have h := volterra_range_bound a C r B hC hr v j
  have ht := norm_three z (volterra a C r v j) 0
  simp only [sub_zero] at ht
  linarith

/-- A convenient explicit geometric estimate: O(Λ+log(1/η)) iterations
suffice once M is fixed. It avoids invoking a separate Stirling estimate. -/
theorem factorial_tail_le_exponential {Λ M : ℝ} (hΛ : 0 ≤ Λ) (hM : 0 ≤ M) (k : ℕ) :
    M*Λ^k/(k.factorial:ℝ) ≤ M*Real.exp (2*Λ-(k:ℝ)*Real.log 2) := by
  have hf : (0:ℝ) < k.factorial := by exact_mod_cast Nat.factorial_pos k
  have hp : (0:ℝ) < (2:ℝ)^k := by positivity
  have h := Real.pow_div_factorial_le_exp (2*Λ) (by linarith : 0 ≤ 2*Λ) k
  have he : Real.exp ((k:ℝ)*Real.log 2) = (2:ℝ)^k := by
    rw [Real.exp_nat_mul, Real.exp_log (by norm_num : (0:ℝ)<2)]
  rw [Real.exp_sub, he, ← mul_div_assoc]
  have hm := mul_le_mul_of_nonneg_left h hM
  apply (le_div_iff₀ hp).mpr
  calc
    M*Λ^k/(k.factorial:ℝ)*(2:ℝ)^k = M*((2*Λ)^k/(k.factorial:ℝ)) := by
      rw [mul_pow]
      ring
    _ ≤ M*Real.exp (2*Λ) := hm

end ActualMaps
#print axioms picard_factorial_error
#print axioms inexact_picard_stability
#print axioms inexact_picard_factorial_error
#print axioms sequential_eq_volterra
#print axioms factorial_tail_le_exponential
#print axioms picard_range_bound
#print axioms inexact_update_range
end ConditionalNonpolynomial.Analytic
