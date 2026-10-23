import NeuralGeneralization.EmpiricalSquareBootstrap

/-! # Finite expectation with arbitrary sampling probabilities

The neuron sampling law need not have rational probabilities. These elementary
finite-sum identities provide the exact weighted symmetrization interface.
-/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoImprovedWeightedSampling
open SquaredSampling
variable {α β ι : Type*} [Fintype α] [Fintype β] [Fintype ι]

def mean (w : α → ℝ) (f : α → ℝ) : ℝ := ∑ x, w x*f x

theorem mean_mono (w : α → ℝ) (hw : ∀ x, 0 ≤ w x) {f g : α → ℝ}
    (h : ∀ x, f x ≤ g x) : mean w f ≤ mean w g :=
  Finset.sum_le_sum (fun x _ => mul_le_mul_of_nonneg_left (h x) (hw x))

theorem mean_nonneg (w : α → ℝ) (hw : ∀ x, 0 ≤ w x) {f : α → ℝ}
    (h : ∀ x, 0 ≤ f x) : 0 ≤ mean w f :=
  Finset.sum_nonneg (fun x _ => mul_nonneg (hw x) (h x))

theorem mean_const (w : α → ℝ) (hw : ∑ x, w x = 1) (c : ℝ) :
    mean w (fun _ => c) = c := by simp [mean, ← Finset.sum_mul, hw]

theorem mean_add (w : α → ℝ) (f g : α → ℝ) :
    mean w (fun x => f x+g x) = mean w f+mean w g := by
  simp [mean, mul_add, Finset.sum_add_distrib]

theorem mean_sub (w : α → ℝ) (f g : α → ℝ) :
    mean w (fun x => f x-g x) = mean w f-mean w g := by
  simp [mean, mul_sub, Finset.sum_sub_distrib]

theorem mean_mul (w : α → ℝ) (c : ℝ) (f : α → ℝ) :
    mean w (fun x => c*f x) = c*mean w f := by
  simp [mean, Finset.mul_sum, mul_left_comm]

theorem mean_sum (w : α → ℝ) (f : ι → α → ℝ) :
    mean w (fun x => ∑ i, f i x) = ∑ i, mean w (f i) := by
  simp only [mean, Finset.mul_sum]
  rw [Finset.sum_comm]

theorem abs_mean_le (w : α → ℝ) (hw : ∀ x, 0 ≤ w x) (f : α → ℝ) :
    |mean w f| ≤ mean w (fun x => |f x|) := by
  have h := Finset.abs_sum_le_sum_abs (fun x => w x*f x) Finset.univ
  simpa only [mean, abs_mul, abs_of_nonneg (hw _)] using h

theorem mean_comm (w : α → ℝ) (v : β → ℝ) (f : α → β → ℝ) :
    mean w (fun x => mean v (f x)) = mean v (fun y => mean w (fun x => f x y)) := by
  simp only [mean, Finset.mul_sum]
  rw [Finset.sum_comm]
  simp only [mul_left_comm]

theorem mean_prod (w : α → ℝ) (v : β → ℝ) (f : α × β → ℝ) :
    mean (fun p : α × β => w p.1*v p.2) f = mean w (fun x => mean v (fun y => f (x,y))) := by
  simp [mean, Fintype.sum_prod_type, Finset.mul_sum, mul_assoc]

theorem mean_equiv (w : α → ℝ) (e : α ≃ α) (hw : ∀ x, w (e x) = w x)
    (f : α → ℝ) : mean w (fun x => f (e x)) = mean w f := by
  have h := e.sum_comp (fun x => w x*f x)
  simpa only [mean, hw] using h

theorem mean_finiteMean_comm (w : α → ℝ) (f : α → β → ℝ) :
    mean w (fun x => finiteMean (f x)) = finiteMean (fun y => mean w (fun x => f x y)) := by
  simp only [mean, finiteMean, ← mul_div_assoc, Finset.mul_sum, ← Finset.sum_div]
  rw [Finset.sum_comm]

def iidWeight (w : α → ℝ) (n : ℕ) (s : Fin n → α) : ℝ := ∏ i, w (s i)

theorem iidWeight_nonneg (w : α → ℝ) (hw : ∀ x, 0 ≤ w x) (n : ℕ) (s) :
    0 ≤ iidWeight w n s := Finset.prod_nonneg (fun i _ => hw (s i))

theorem iidWeight_mass (w : α → ℝ) (hw : ∑ x, w x = 1) (n : ℕ) :
    ∑ s : Fin n → α, iidWeight w n s = 1 := by
  simp only [iidWeight, ← Fintype.prod_sum, hw, Finset.prod_const_one]

theorem mean_iidWeight_prod (w : α → ℝ) (n : ℕ) (f : Fin n → α → ℝ) :
    mean (iidWeight w n) (fun s => ∏ i, f i (s i)) = ∏ i, mean w (f i) := by
  simp only [mean, iidWeight, ← Finset.prod_mul_distrib]
  exact (Fintype.prod_sum (fun i x => w x*f i x)).symm

theorem mean_iidWeight_eval (w : α → ℝ) (hw : ∑ x, w x = 1) (n : ℕ)
    (i : Fin n) (f : α → ℝ) : mean (iidWeight w n) (fun s => f (s i)) = mean w f := by
  classical
  have h := mean_iidWeight_prod w n (fun j x => if j=i then f x else 1)
  have hp (s : Fin n → α) : (∏ j, if j=i then f (s j) else (1:ℝ)) = f (s i) := by simp
  have hm (j : Fin n) : mean w (fun x => if j=i then f x else 1) =
      if j=i then mean w f else 1 := by
    by_cases hj : j=i <;> simp [hj, mean_const w hw]
  simp_rw [hp, hm] at h
  simpa using h

theorem iidWeight_signSwap (w : α → ℝ) (n : ℕ) (ε : Fin n → Bool)
    (p : (Fin n → α) × (Fin n → α)) :
    iidWeight w n ((signSwap ε p).1) * iidWeight w n ((signSwap ε p).2) =
      iidWeight w n p.1 * iidWeight w n p.2 := by
  simp only [iidWeight, ← Finset.prod_mul_distrib]
  apply Finset.prod_congr rfl
  intro i _
  cases h : ε i <;> simp [signSwap, h, mul_comm]

theorem mean_square_jensen (w : α → ℝ) (hw : ∀ x, 0 ≤ w x)
    (hm : ∑ x, w x = 1) (f : α → ℝ) : (mean w f)^2 ≤ mean w (fun x => (f x)^2) :=
  weighted_square_jensen w f hw hm

theorem mean_sqrt_square (w : α → ℝ) (hw : ∀ x, 0 ≤ w x)
    (hm : ∑ x, w x = 1) (f : α → ℝ) (hf : ∀ x, 0 ≤ f x) :
    (mean w (fun x => Real.sqrt (f x)))^2 ≤ mean w f := by
  simpa only [Real.sq_sqrt (hf _)] using mean_square_jensen w hw hm (fun x => Real.sqrt (f x))

end NeuralGeneralization.BatchTwoImprovedWeightedSampling
