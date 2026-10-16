import NeuralGeneralization.EmpiricalSquareBootstrap

/-! Literal finite product averages and Bernoulli sum moments. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.SquaredSampling
open Classical
attribute [local instance] Classical.propDecidable

variable {I α : Type*} [Fintype I] [DecidableEq I] [Fintype α] [Nonempty α]

lemma finiteMean_pi_mul_eval (i j : I) (hij : i ≠ j) (f g : α → ℝ) :
    finiteMean (fun s : I → α => f (s i)*g (s j)) = finiteMean f*finiteMean g := by
  let F := fun k : I => fun x : α => (if k=i then f x else 1)*(if k=j then g x else 1)
  have h := finiteMean_pi_prod F
  have hp (s : I → α) : (∏ k, F k (s k))=f (s i)*g (s j) := by
    simp only [F, Finset.prod_mul_distrib]
    simp
  have hm (k : I) : finiteMean (F k)=
      (if k=i then finiteMean f else 1)*(if k=j then finiteMean g else 1) := by
    by_cases hki : k=i <;> by_cases hkj : k=j
    · exact False.elim (hij (hki.symm.trans hkj))
    · simp [F, hki, hkj, hij, Ne.symm hij]
    · simp [F, hki, hkj, hij, Ne.symm hij]
    · simp [F, hki, hkj, hij, Ne.symm hij]
  simp_rw [hp, hm] at h
  simpa only [Finset.prod_mul_distrib, Finset.prod_ite_eq', Finset.mem_univ, if_true] using h

lemma finiteMean_centered_square (f : α → ℝ) :
    finiteMean (fun x => (f x-finiteMean f)^2) =
      finiteMean (fun x => f x^2)-(finiteMean f)^2 := by
  have he (x : α) : (f x-finiteMean f)^2 = f x^2-2*finiteMean f*f x+(finiteMean f)^2 := by ring
  simp_rw [he]
  rw [finiteMean_add, finiteMean_sub, finiteMean_mul, finiteMean_const]
  ring

lemma finiteMean_centered_zero (f : α → ℝ) :
    finiteMean (fun x => f x-finiteMean f)=0 := by rw [finiteMean_sub, finiteMean_const, sub_self]

/-- Pairwise independence is derived from the finite product average. -/
theorem finiteMean_product_sum_variance (f : α → ℝ) :
    finiteMean (fun s : I → α => ((∑ i, f (s i))-(Fintype.card I:ℝ)*finiteMean f)^2) =
      (Fintype.card I:ℝ)*(finiteMean (fun x => f x^2)-(finiteMean f)^2) := by
  let g := fun x : α => f x-finiteMean f
  have he (s : I → α) : (∑ i, f (s i))-(Fintype.card I:ℝ)*finiteMean f = ∑ i, g (s i) := by
    simp only [g, Finset.sum_sub_distrib, Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  have hpair (i j : I) : finiteMean (fun s : I → α => g (s i)*g (s j)) =
      if i=j then finiteMean (fun x => f x^2)-(finiteMean f)^2 else 0 := by
    by_cases hij : i=j
    · subst j
      rw [if_pos rfl]
      simp_rw [← pow_two]
      rw [finiteMean_pi_eval i (fun x => g x^2)]
      exact finiteMean_centered_square f
    · rw [if_neg hij, finiteMean_pi_mul_eval i j hij g g]
      simp only [g, finiteMean_centered_zero, mul_zero]
  simp_rw [he, pow_two, Finset.sum_mul, Finset.mul_sum]
  rw [finiteMean_sum]
  simp_rw [finiteMean_sum, hpair]
  simp
  ring

lemma finiteMean_product_sum (f : α → ℝ) :
    finiteMean (fun s : I → α => ∑ i, f (s i)) = (Fintype.card I:ℝ)*finiteMean f := by
  rw [finiteMean_sum]
  simp_rw [finiteMean_pi_eval]
  simp

end NeuralGeneralization.SquaredSampling
