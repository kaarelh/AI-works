import NeuralGeneralization.OnlineLowerTanhCodeKernel

/-! # Positive-kernel domination of literal tanh Walsh coefficients -/

noncomputable section
open scoped BigOperators
open MeasureTheory Set
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLowerRelu ConcreteModel

theorem tanhTrigKernel_measurable {d : ℕ} (S : Finset (Fin d)) (u : Fin d → ℝ) :
    Measurable (tanhTrigKernel S u) := by
  unfold tanhTrigKernel trigProduct
  apply Measurable.div
  · apply Finset.measurable_prod
    intro i _
    by_cases hi : i∈S
    · simp only [if_pos hi]
      fun_prop
    · simp only [if_neg hi]
      fun_prop
  · fun_prop

theorem cos_tanhTrigKernel_abs_le {d : ℕ} (S : Finset (Fin d))
    (u : Fin d → ℝ) (b t : ℝ) :
    |Real.cos (t*b)*tanhTrigKernel S u t| ≤ |tanhTrigKernel S u t| := by
  rw [abs_mul]
  exact mul_le_of_le_one_left (abs_nonneg _) (Real.abs_cos_le_one _)

theorem integrable_cos_tanhTrigKernel {d r : ℕ} (S : Finset (Fin d))
    (hcard : S.card=2*r+1) (b : ℝ) (u : Fin d → ℝ) :
    IntegrableOn (fun t => Real.cos (t*b)*tanhTrigKernel S u t) (Ioi 0) := by
  apply (integrable_tanhTrigKernel S hcard u).norm.mono'
  · exact ((by fun_prop : Measurable (fun t : ℝ => Real.cos (t*b))).mul
      (tanhTrigKernel_measurable S u)).aestronglyMeasurable
  · exact Filter.Eventually.of_forall (fun t => by
      simpa only [Real.norm_eq_abs] using cos_tanhTrigKernel_abs_le S u b t)

/-- Absolute value, integrability and bias removal are all proved for the
actual coefficient, rather than asserted as analytic premises. -/
theorem tanh_walsh_abs_le_integral_kernel {d r : ℕ} (S : Finset (Fin d))
    (hcard : S.card=2*r+1) (b : ℝ) (u : Fin d → ℝ) :
    |walshCoefficients (fun x => Real.tanh (b+incomingLinear u x)) S| ≤
      ∫ t : ℝ in Ioi 0, |tanhTrigKernel S u t| := by
  rw [tanh_walsh_integral_odd S hcard,abs_mul,abs_pow]
  norm_num only [abs_neg,abs_one,one_pow,one_mul]
  have hn := norm_integral_le_integral_norm
    (f := fun t : ℝ => Real.cos (t*b)*tanhTrigKernel S u t)
    (μ := volume.restrict (Ioi 0))
  simp only [Real.norm_eq_abs] at hn
  exact hn.trans (integral_mono (integrable_cos_tanhTrigKernel S hcard b u).norm
    (integrable_tanhTrigKernel S hcard u).norm
    (cos_tanhTrigKernel_abs_le S u b))

/-- The absolute kernel has the expected positive product form on positive
frequencies, including all unused-coordinate cosine factors. -/
theorem abs_tanhTrigKernel_positive {d : ℕ} (S : Finset (Fin d))
    (u : Fin d → ℝ) (t : ℝ) (ht : 0<t) :
    |tanhTrigKernel S u t| =
      (∏ i, if i∈S then |Real.sin (t*u i)| else |Real.cos (t*u i)|)/
        Real.sinh (Real.pi*t/2) := by
  have hs : 0<Real.sinh (Real.pi*t/2) := Real.sinh_pos_iff.mpr (by positivity)
  unfold tanhTrigKernel trigProduct
  rw [abs_div,abs_of_pos hs,Finset.abs_prod]
  congr 1
  apply Finset.prod_congr rfl
  intro i _
  split_ifs <;> rfl

end NeuralGeneralization.OnlineLowerTanh
