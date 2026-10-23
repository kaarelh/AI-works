import NeuralGeneralization.BatchTwoImprovedWeightedExpectation

/-! # Exact scalar and vector Monte Carlo second moments -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoImprovedWeightedSampling
open SquaredSampling Classical
variable {α : Type*} [Fintype α]

theorem mean_iidWeight_mul_eval (w : α → ℝ) (hw : ∑ x, w x = 1)
    (n : ℕ) (i j : Fin n) (hij : i ≠ j) (f g : α → ℝ) :
    mean (iidWeight w n) (fun s => f (s i)*g (s j)) = mean w f*mean w g := by
  let F := fun k : Fin n => fun x : α => (if k=i then f x else 1)*(if k=j then g x else 1)
  have h := mean_iidWeight_prod w n F
  have hp (s : Fin n → α) : (∏ k, F k (s k)) = f (s i)*g (s j) := by
    simp only [F, Finset.prod_mul_distrib]
    simp
  have hm (k : Fin n) : mean w (F k) =
      (if k=i then mean w f else 1)*(if k=j then mean w g else 1) := by
    by_cases hki : k=i <;> by_cases hkj : k=j
    · exact False.elim (hij (hki.symm.trans hkj))
    · simp [F, hki, hkj, hij, Ne.symm hij]
    · simp [F, hki, hkj, hij, Ne.symm hij]
    · simp [F, hki, hkj, hij, Ne.symm hij, mean_const w hw]
  simp_rw [hp, hm] at h
  simpa only [Finset.prod_mul_distrib, Finset.prod_ite_eq', Finset.mem_univ, if_true] using h

theorem mean_centered_square (w : α → ℝ) (hw : ∑ x, w x = 1) (f : α → ℝ) :
    mean w (fun x => (f x-mean w f)^2) = mean w (fun x => (f x)^2)-(mean w f)^2 := by
  have he (x : α) : (f x-mean w f)^2 = (f x)^2-2*mean w f*f x+(mean w f)^2 := by ring
  simp_rw [he]
  rw [mean_add, mean_sub, mean_mul, mean_const w hw]
  ring

theorem mean_centered_zero (w : α → ℝ) (hw : ∑ x, w x = 1) (f : α → ℝ) :
    mean w (fun x => f x-mean w f) = 0 := by rw [mean_sub, mean_const w hw, sub_self]

theorem mean_iid_sum_variance (w : α → ℝ) (hw : ∑ x, w x = 1) (n : ℕ) (f : α → ℝ) :
    mean (iidWeight w n) (fun s => ((∑ i, f (s i))-(n:ℝ)*mean w f)^2) =
      n*(mean w (fun x => (f x)^2)-(mean w f)^2) := by
  let g := fun x => f x-mean w f
  have he (s : Fin n → α) : (∑ i, f (s i))-(n:ℝ)*mean w f = ∑ i, g (s i) := by
    simp [g, Finset.sum_sub_distrib]
  have hpair (i j : Fin n) : mean (iidWeight w n) (fun s => g (s i)*g (s j)) =
      if i=j then mean w (fun x => (f x)^2)-(mean w f)^2 else 0 := by
    by_cases hij : i=j
    · subst j
      rw [if_pos rfl]
      simp_rw [← pow_two]
      rw [mean_iidWeight_eval w hw n i (fun x => (g x)^2)]
      exact mean_centered_square w hw f
    · rw [if_neg hij, mean_iidWeight_mul_eval w hw n i j hij g g]
      simp only [g, mean_centered_zero w hw, mul_zero]
  simp_rw [he, pow_two, Finset.sum_mul, Finset.mul_sum]
  rw [mean_sum]
  simp_rw [mean_sum, hpair]
  simp
  ring

theorem mean_div (w : α → ℝ) (f : α → ℝ) (c : ℝ) :
    mean w (fun x => f x/c) = mean w f/c := by
  simp [mean, ← mul_div_assoc, ← Finset.sum_div]

theorem mean_iid_average_variance (w : α → ℝ) (hw : ∑ x, w x = 1)
    (n : ℕ) (hn : 0 < n) (f : α → ℝ) :
    mean (iidWeight w n) (fun s => ((∑ i, f (s i))/(n:ℝ)-mean w f)^2) =
      (mean w (fun x => (f x)^2)-(mean w f)^2)/(n:ℝ) := by
  have hn' : (n:ℝ) ≠ 0 := by exact_mod_cast hn.ne'
  have he (s : Fin n → α) : ((∑ i, f (s i))/(n:ℝ)-mean w f)^2 =
      ((∑ i, f (s i))-(n:ℝ)*mean w f)^2/(n:ℝ)^2 := by field_simp
  simp_rw [he]
  rw [mean_div, mean_iid_sum_variance w hw]
  field_simp

theorem mean_iid_average_variance_le (w : α → ℝ) (hw : ∑ x, w x = 1)
    (n : ℕ) (hn : 0 < n) (f : α → ℝ) :
    mean (iidWeight w n) (fun s => ((∑ i, f (s i))/(n:ℝ)-mean w f)^2) ≤
      mean w (fun x => (f x)^2)/(n:ℝ) := by
  rw [mean_iid_average_variance w hw n hn]
  exact div_le_div_of_nonneg_right (sub_le_self _ (sq_nonneg _)) (Nat.cast_nonneg n)

end NeuralGeneralization.BatchTwoImprovedWeightedSampling
