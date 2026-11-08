import NeuralGeneralization.OnlineLowerTanhCodeDerivatives
import NeuralGeneralization.OnlineLowerTanhCodeSupport
import Mathlib.Analysis.Calculus.MeanValue

/-!
# Actual high-order parity cancellation for smooth ridge functions

Repeated centered finite differences give a product-of-coordinates bound on
a literal Boolean parity coefficient. The tanh specialization uses the proved
global factorial derivative bound, uniformly in the incoming bias.
-/

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel

/-- A normalized centered difference. -/
def centeredDifference (f : ℝ → ℝ) (a : ℝ) : ℝ → ℝ :=
  fun x => (f (x+a)-f (x-a))/2

@[fun_prop] theorem contDiff_centeredDifference {n : WithTop ℕ∞}
    (f : ℝ → ℝ) (hf : ContDiff ℝ n f) (a : ℝ) :
    ContDiff ℝ n (centeredDifference f a) := by
  exact ((hf.comp (contDiff_id.add contDiff_const)).sub
    (hf.comp (contDiff_id.sub contDiff_const))).div_const 2

theorem iteratedDeriv_centeredDifference (f : ℝ → ℝ)
    (hf : ContDiff ℝ ⊤ f) (n : ℕ) (a x : ℝ) :
    iteratedDeriv n (centeredDifference f a) x =
      centeredDifference (iteratedDeriv n f) a x := by
  unfold centeredDifference
  simp only [div_eq_mul_inv, iteratedDeriv_mul_const_field]
  have hp : ContDiff ℝ (n : WithTop ℕ∞) (fun y => f (y+a)) :=
    (hf.comp (contDiff_id.add contDiff_const)).of_le le_top
  have hm : ContDiff ℝ (n : WithTop ℕ∞) (fun y => f (y-a)) :=
    (hf.comp (contDiff_id.sub contDiff_const)).of_le le_top
  rw [iteratedDeriv_fun_sub hp.contDiffAt hm.contDiffAt]
  rw [iteratedDeriv_comp_add_const, iteratedDeriv_comp_sub_const]

theorem centeredDifference_iteratedDeriv_bound (f : ℝ → ℝ)
    (hf : ContDiff ℝ ⊤ f) (n : ℕ) (M a x : ℝ)
    (hbound : ∀ t, |iteratedDeriv (n+1) f t| ≤ M) :
    |iteratedDeriv n (centeredDifference f a) x| ≤ |a| *M := by
  rw [iteratedDeriv_centeredDifference f hf]
  have hdiff : Differentiable ℝ (iteratedDeriv n f) :=
    hf.differentiable_iteratedDeriv n (by simp)
  have hb (t : ℝ) (_ : t ∈ Set.univ) : ‖deriv (iteratedDeriv n f) t‖ ≤ M := by
    rw [← iteratedDeriv_succ]
    exact hbound t
  have hm := Convex.norm_image_sub_le_of_norm_deriv_le
    (fun t (_ : t ∈ Set.univ) => hdiff t) hb (convex_univ : Convex ℝ (Set.univ : Set ℝ))
    (Set.mem_univ (x-a)) (Set.mem_univ (x+a))
  have he : (x+a)-(x-a) = 2*a := by ring
  simp only [Real.norm_eq_abs, he, abs_mul] at hm
  norm_num at hm
  unfold centeredDifference
  rw [abs_div]
  norm_num
  nlinarith

/-- The normalized full-parity coefficient of a general real ridge function. -/
def ridgeParity {n : ℕ} (f : ℝ → ℝ) (u : Fin n → ℝ) (b : ℝ) : ℝ :=
  cubeMean (fun x => paritySign x * f (b + incomingLinear u x))

@[simp] theorem ridgeParity_zero (f : ℝ → ℝ) (u : Fin 0 → ℝ) (b : ℝ) :
    ridgeParity f u b = f b := by
  simp [ridgeParity,paritySign,incomingLinear]

theorem ridgeParity_succ {n : ℕ} (f : ℝ → ℝ) (u : Fin (n+1) → ℝ) (b : ℝ) :
    ridgeParity f u b = ridgeParity (centeredDifference f (u 0)) (fun i => u i.succ) b := by
  unfold ridgeParity
  rw [cubeMean_succ]
  have hp (z : Bool) (x : Cube n) :
      paritySign (Fin.cons z x) = labelReal z * paritySign x := by
    simp [paritySign, Fin.prod_univ_succ]
  simp only [hp, incomingLinear_cons, labelReal,
    if_true, Bool.false_eq_true, if_false, one_mul, mul_one, neg_one_mul, mul_neg_one]
  change ((cubeMean fun x => paritySign x *
      f (b + (u 0 + incomingLinear (fun i => u i.succ) x))) +
      (cubeMean fun x => -paritySign x *
      f (b + (-u 0 + incomingLinear (fun i => u i.succ) x)))) / 2 = _
  rw [← cubeMean_add]
  have hd : ∀ g : Cube n → ℝ, cubeMean g / 2 = cubeMean (fun x => g x / 2) := by
    intro g
    simp [cubeMean, Finset.sum_div, mul_div_assoc]
  rw [hd]
  apply cubeMean_congr
  intro x
  unfold centeredDifference
  have he1 : b + (u 0 + incomingLinear (fun i => u i.succ) x) =
      b + incomingLinear (fun i => u i.succ) x + u 0 := by ring
  have he2 : b + (-u 0 + incomingLinear (fun i => u i.succ) x) =
      b + incomingLinear (fun i => u i.succ) x - u 0 := by ring
  rw [he1,he2]
  ring

/-- The exact kth parity cancellation bound, uniformly in the bias. -/
theorem ridgeParity_abs_le_derivative_product (n : ℕ) (f : ℝ → ℝ)
    (hf : ContDiff ℝ ⊤ f) (M : ℝ)
    (hbound : ∀ t, |iteratedDeriv n f t| ≤ M)
    (u : Fin n → ℝ) (b : ℝ) :
    |ridgeParity f u b| ≤ M * ∏ i, |u i| := by
  induction n generalizing f M b with
  | zero => simpa using hbound b
  | succ n ih =>
    rw [ridgeParity_succ]
    have hg := ih (centeredDifference f (u 0)) (contDiff_centeredDifference f hf (u 0))
      (|u 0| *M) (fun t => centeredDifference_iteratedDeriv_bound f hf n M (u 0) t hbound)
      (fun i => u i.succ) b
    simpa only [Fin.prod_univ_succ, mul_assoc, mul_left_comm, mul_comm] using hg

/-- Ordinary tanh has a factorial high-order parity bound for arbitrary
weights and arbitrary bias. This is a statement about the literal finite cube. -/
theorem tanh_ridgeParity_abs_le_factorial_product {n : ℕ}
    (u : Fin n → ℝ) (b : ℝ) :
    |ridgeParity Real.tanh u b| ≤ (n.factorial : ℝ) * ∏ i, |u i| :=
  ridgeParity_abs_le_derivative_product n Real.tanh contDiff_tanh_all _
    (abs_iteratedDeriv_tanh_le_factorial n) u b

end NeuralGeneralization.OnlineLowerTanh
