import NeuralGeneralization.RobustEntropyMoments
import NeuralGeneralization.Activation
import NeuralGeneralization.GaussianFieldTilt
import Mathlib.Tactic.Linarith

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators NNReal ENNReal
namespace ConditionalAnalytic
open NeuralGeneralization NeuralGeneralization.ConcreteModel
open NeuralGeneralization.GaussianAngularFields NeuralGeneralization.FiniteDifferential

variable {I : Type*} [Fintype I]

/-- A deliberately coarse dimension-polynomial estimate. The repair argument
uses its logarithm when choosing covariance precision. -/
theorem linear_difference_pointwise (a b g : I → ℝ) {δ : ℝ} (hδ : 0 ≤ δ)
    (hab : ∑ i, (a i-b i)^2 ≤ δ^2) :
    |∑ i, (a i-b i)*g i| ≤ δ*(1+∑ i, (g i)^2) := by
  have hcs := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ
    (fun i => a i-b i) g
  have hG : 0 ≤ ∑ i, (g i)^2 := Finset.sum_nonneg (fun i _ => sq_nonneg _)
  have hmul := mul_le_mul_of_nonneg_right hab hG
  have hsq : (∑ i, (a i-b i)*g i)^2 ≤ δ^2*(1+∑ i, (g i)^2)^2 := by
    have hlast : (∑ i, (g i)^2) ≤ (1+∑ i, (g i)^2)^2 := by nlinarith
    exact hcs.trans (hmul.trans (mul_le_mul_of_nonneg_left hlast (sq_nonneg δ)))
  have hp : 0 ≤ δ*(1+∑ i, (g i)^2) := by positivity
  exact (sq_le_sq₀ (abs_nonneg _) hp).mp (by simpa only [sq_abs,mul_pow] using hsq)

theorem tanh_difference_pointwise (a b g : I → ℝ) {δ : ℝ} (hδ : 0 ≤ δ)
    (hab : ∑ i, (a i-b i)^2 ≤ δ^2) :
    |Real.tanh (∑ i, a i*g i)-Real.tanh (∑ i, b i*g i)| ≤
      δ*(1+∑ i, (g i)^2) := by
  have ht := tanh_lipschitzWith.dist_le_mul (∑ i, a i*g i) (∑ i, b i*g i)
  simp only [Real.dist_eq, NNReal.coe_one, one_mul] at ht
  have hid : (∑ i, a i*g i)-(∑ i, b i*g i)=∑ i, (a i-b i)*g i := by
    simp only [sub_mul, Finset.sum_sub_distrib]
  rw [hid] at ht
  exact ht.trans (linear_difference_pointwise a b g hδ hab)

/-- Actual finite-KL changes of a common Gaussian coordinate law transport tanh
features when their coefficient vectors are close. No covariance nondegeneracy
or density bound is required. -/
theorem tanh_feature_repair (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (standardLaw I) ≠ ∞) (a b : I → ℝ)
    {δ : ℝ} (hδ : 0 ≤ δ) (hab : ∑ i, (a i-b i)^2 ≤ δ^2) :
    (∫ g, |Real.tanh (∑ i, a i*g i)-Real.tanh (∑ i, b i*g i)| ∂Q) ≤
      δ*(1+4*(klDiv Q (standardLaw I)).toReal+2*Fintype.card I) := by
  obtain ⟨hint,hbound⟩ := RobustEntropyMoments.standard_gaussian_entropy_second_moment Q hKL
  have hright : Integrable (fun g : I → ℝ => δ*(1+∑ i, (g i)^2)) Q :=
    ((integrable_const 1).add hint).const_mul δ
  have hleft : Integrable (fun g : I → ℝ =>
      |Real.tanh (∑ i, a i*g i)-Real.tanh (∑ i, b i*g i)|) Q := by
    apply hright.mono' (by fun_prop)
    filter_upwards [] with g
    simpa only [Real.norm_eq_abs, abs_abs] using tanh_difference_pointwise a b g hδ hab
  have h := integral_mono hleft hright (fun g => tanh_difference_pointwise a b g hδ hab)
  rw [integral_const_mul, integral_add (integrable_const 1) hint] at h
  simp only [integral_const, probReal_univ, one_smul] at h
  exact h.trans (mul_le_mul_of_nonneg_left (by
    simpa only [standardLaw, add_assoc, add_comm, add_left_comm] using add_le_add_left hbound 1) hδ)

theorem tanh_pair_difference_pointwise (a b c e g : I → ℝ) {δ : ℝ} (hδ : 0 ≤ δ)
    (hab : ∑ i, (a i-b i)^2 ≤ δ^2) (hce : ∑ i, (c i-e i)^2 ≤ δ^2) :
    |Real.tanh (∑ i, a i*g i)*Real.tanh (∑ i, c i*g i)-
      Real.tanh (∑ i, b i*g i)*Real.tanh (∑ i, e i*g i)| ≤
      2*δ*(1+∑ i, (g i)^2) := by
  let A := Real.tanh (∑ i, a i*g i)
  let B := Real.tanh (∑ i, b i*g i)
  let C := Real.tanh (∑ i, c i*g i)
  let E := Real.tanh (∑ i, e i*g i)
  have h1 := tanh_difference_pointwise a b g hδ hab
  have h2 := tanh_difference_pointwise c e g hδ hce
  change |A*C-B*E| ≤ _
  have halg : A*C-B*E=(A-B)*C+B*(C-E) := by ring
  rw [halg]
  calc
    _ ≤ |(A-B)*C| +|B*(C-E)| := abs_add_le _ _
    _ = |A-B| *|C| +|B| *|C-E| := by rw [abs_mul,abs_mul]
    _ ≤ |A-B| +|C-E| := by
      have hc := mul_le_mul_of_nonneg_left (Real.abs_tanh_lt_one (∑ i,c i*g i)).le (abs_nonneg (A-B))
      have hb := mul_le_mul_of_nonneg_right (Real.abs_tanh_lt_one (∑ i,b i*g i)).le (abs_nonneg (C-E))
      dsimp [C,B] at *
      nlinarith
    _ ≤ _ := by dsimp [A,B,C,E] at *; linarith

theorem tanh_pair_repair (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (standardLaw I) ≠ ∞) (a b c e : I → ℝ)
    {δ : ℝ} (hδ : 0 ≤ δ) (hab : ∑ i, (a i-b i)^2 ≤ δ^2)
    (hce : ∑ i, (c i-e i)^2 ≤ δ^2) :
    |(∫ g, Real.tanh (∑ i, a i*g i)*Real.tanh (∑ i,c i*g i) ∂Q)-
      (∫ g, Real.tanh (∑ i,b i*g i)*Real.tanh (∑ i,e i*g i) ∂Q)| ≤
      2*δ*(1+4*(klDiv Q (standardLaw I)).toReal+2*Fintype.card I) := by
  obtain ⟨hint,hbound⟩ := RobustEntropyMoments.standard_gaussian_entropy_second_moment Q hKL
  have hp (a c : I → ℝ) : Integrable (fun g : I → ℝ =>
      Real.tanh (∑ i,a i*g i)*Real.tanh (∑ i,c i*g i)) Q := by
    apply Integrable.of_bound (by fun_prop) 1
    filter_upwards [] with g
    rw [Real.norm_eq_abs, abs_mul]
    exact (mul_le_mul (Real.abs_tanh_lt_one _).le (Real.abs_tanh_lt_one _).le (abs_nonneg _) (by norm_num)).trans_eq (one_mul _)
  rw [← integral_sub (hp a c) (hp b e)]
  have hnorm := norm_integral_le_integral_norm (f := fun g : I → ℝ =>
    Real.tanh (∑ i,a i*g i)*Real.tanh (∑ i,c i*g i)-
      Real.tanh (∑ i,b i*g i)*Real.tanh (∑ i,e i*g i)) (μ := Q)
  simp only [Real.norm_eq_abs] at hnorm
  apply hnorm.trans
  have hr : Integrable (fun g : I → ℝ => 2*δ*(1+∑ i,(g i)^2)) Q :=
    ((integrable_const 1).add hint).const_mul _
  have h := integral_mono ((hp a c).sub (hp b e)).abs hr
    (fun g => tanh_pair_difference_pointwise a b c e g hδ hab hce)
  rw [integral_const_mul,integral_add (integrable_const 1) hint] at h
  simp only [integral_const,probReal_univ,one_smul] at h
  apply h.trans
  apply mul_le_mul_of_nonneg_left _ (by positivity)
  simpa only [standardLaw, add_assoc, add_comm, add_left_comm] using add_le_add_left hbound 1

/-- L² feature transport, which is the linear recurrence metric needed across
many layers. Iterating a square-root covariance-entry bound would be too weak. -/
theorem tanh_feature_repair_squared (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (standardLaw I) ≠ ∞) (a b : I → ℝ)
    {δ : ℝ} (hab : ∑ i, (a i-b i)^2 ≤ δ^2) :
    (∫ g, (Real.tanh (∑ i,a i*g i)-Real.tanh (∑ i,b i*g i))^2 ∂Q) ≤
      δ^2*(4*(klDiv Q (standardLaw I)).toReal+2*Fintype.card I) := by
  obtain ⟨hint,hbound⟩ := RobustEntropyMoments.standard_gaussian_entropy_second_moment Q hKL
  have hpoint (g : I → ℝ) :
      (Real.tanh (∑ i,a i*g i)-Real.tanh (∑ i,b i*g i))^2 ≤ δ^2*∑ i,(g i)^2 := by
    have ht := tanh_lipschitzWith.dist_le_mul (∑ i,a i*g i) (∑ i,b i*g i)
    simp only [Real.dist_eq, NNReal.coe_one, one_mul] at ht
    have hid : (∑ i,a i*g i)-(∑ i,b i*g i)=∑ i,(a i-b i)*g i := by
      simp only [sub_mul,Finset.sum_sub_distrib]
    rw [hid] at ht
    have ht2 := pow_le_pow_left₀ (abs_nonneg _) ht 2
    simp only [sq_abs] at ht2
    exact ht2.trans ((Finset.sum_mul_sq_le_sq_mul_sq Finset.univ
      (fun i => a i-b i) g).trans (mul_le_mul_of_nonneg_right hab
        (Finset.sum_nonneg fun i _ => sq_nonneg _)))
  have hr := hint.const_mul (δ^2)
  have hl : Integrable (fun g : I → ℝ =>
      (Real.tanh (∑ i,a i*g i)-Real.tanh (∑ i,b i*g i))^2) Q := by
    apply hr.mono' (by fun_prop)
    filter_upwards [] with g
    simpa only [Real.norm_eq_abs,abs_pow,sq_abs] using hpoint g
  have hi := integral_mono hl hr hpoint
  rw [integral_const_mul] at hi
  exact hi.trans (mul_le_mul_of_nonneg_left hbound (sq_nonneg δ))

#print axioms tanh_feature_repair_squared
#print axioms tanh_pair_repair
#print axioms tanh_feature_repair
end ConditionalAnalytic
