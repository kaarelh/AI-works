import NeuralGeneralization.BatchTwoActivationGaussianBulk
import Mathlib.Probability.Independence.Integration
import Mathlib.MeasureTheory.Integral.Lebesgue.Markov

/-!
# Independent Gaussian projection residuals

The scalar exponential residual estimate is tensorized under the actual product
law. This gives an exponentially small failure probability for the empirical
squared residual, without any source-dimension dependence.
-/

noncomputable section
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators ENNReal
namespace NeuralGeneralization.BatchTwoActivation

variable {Ω : Type*} [MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]

/-- Tensorization of a nonnegative exponential moment under independent rows. -/
theorem iid_exp_sum_moment (N : ℕ) (F : Ω→ℝ) (hF : Measurable F)
    {c : ℝ≥0∞} (h : (∫⁻ x, ENNReal.ofReal (Real.exp (F x)) ∂μ)≤c) :
    (∫⁻ x : Fin N→Ω, ENNReal.ofReal (Real.exp (∑ i, F (x i)))
      ∂Measure.pi (fun _ : Fin N => μ))≤c^N := by
  classical
  let g := fun x => ENNReal.ofReal (Real.exp (F x))
  have hg : Measurable g := ENNReal.measurable_ofReal.comp hF.exp
  have hprod (x : Fin N→Ω) : ENNReal.ofReal (Real.exp (∑ i, F (x i)))=
      ∏ i, g (x i) := by
    rw [Real.exp_sum]
    exact ENNReal.ofReal_prod_of_nonneg (fun i _ => (Real.exp_pos _).le)
  simp_rw [hprod]
  have hind := iIndepFun_pi (μ := fun _ : Fin N => μ)
    (X := fun _ : Fin N => g) (fun _ => hg.aemeasurable)
  have hp := lintegral_prod_eq_prod_lintegral_of_indepFun (μ := Measure.pi (fun _ : Fin N => μ))
    Finset.univ (fun (i : Fin N) (x : Fin N→Ω) => g (x i)) hind
    (fun i => hg.comp (measurable_pi_apply i))
  rw [hp]
  have hm (i : Fin N) : (∫⁻ x : Fin N→Ω, g (x i)
      ∂Measure.pi (fun _ : Fin N => μ))=(∫⁻ x, g x ∂μ) := by
    exact (measurePreserving_eval (fun _ : Fin N => μ) i).lintegral_comp hg
  simp_rw [hm]
  simpa using pow_le_pow_left' h N

/-- Exponential Markov inequality with the finite-dimensional product law. -/
theorem iid_exp_sum_tail (N : ℕ) (F : Ω→ℝ) (hF : Measurable F)
    {c : ℝ} (hc : 0<c)
    (h : (∫⁻ x, ENNReal.ofReal (Real.exp (F x)) ∂μ)≤ENNReal.ofReal c)
    (K : ℝ) :
    (Measure.pi (fun _ : Fin N => μ)).real
      {x : Fin N→Ω | (N : ℝ)*(K+Real.log c)≤∑ i, F (x i)}≤
      Real.exp (-(N : ℝ)*K) := by
  classical
  let ν := Measure.pi (fun _ : Fin N => μ)
  let A := (N : ℝ)*(K+Real.log c)
  let G := fun x : Fin N→Ω => ENNReal.ofReal (Real.exp (∑ i, F (x i)))
  have hG : Measurable G := ENNReal.measurable_ofReal.comp
    ((Finset.measurable_sum Finset.univ (fun i _ => hF.comp (measurable_pi_apply i))).exp)
  have hb := (mul_meas_ge_le_lintegral (μ := ν) hG (ENNReal.ofReal (Real.exp A))).trans
    (iid_exp_sum_moment N F hF h)
  have hset : {x : Fin N→Ω | ENNReal.ofReal (Real.exp A)≤G x}=
      {x | A≤∑ i, F (x i)} := by
    ext x
    simp only [Set.mem_setOf_eq, G, ENNReal.ofReal_le_ofReal_iff (Real.exp_pos _).le,
      Real.exp_le_exp]
  rw [hset] at hb
  have hfin : (ENNReal.ofReal c)^N≠⊤ := ENNReal.pow_ne_top ENNReal.ofReal_ne_top
  have hb' := ENNReal.toReal_mono hfin hb
  simp only [ENNReal.toReal_mul, ENNReal.toReal_ofReal (Real.exp_pos _).le,
    ENNReal.toReal_pow, ENNReal.toReal_ofReal hc.le] at hb'
  change Real.exp A*ν.real {x | A≤∑ i, F (x i)}≤c^N at hb'
  have heq : Real.exp A*Real.exp (-(N : ℝ)*K)=c^N := by
    rw [←Real.exp_add]
    have he : A + -(N : ℝ)*K=(N : ℝ)*Real.log c := by dsimp [A]; ring
    rw [he, Real.exp_nat_mul, Real.exp_log hc]
  apply (mul_le_mul_iff_right₀ (Real.exp_pos A)).mp
  rw [heq]
  exact hb'

/-- Empirical projection energy has an exponentially small upper tail. -/
theorem iid_square_residual_tail (N : ℕ) (F : Ω→ℝ) (hF : Measurable F)
    (h : (∫⁻ x, ENNReal.ofReal (Real.exp ((F x)^2/8)) ∂μ)≤3) (K : ℝ) :
    (Measure.pi (fun _ : Fin N => μ)).real
      {x : Fin N→Ω | 8*(N : ℝ)*(K+Real.log 3)≤∑ i, (F (x i))^2}≤
      Real.exp (-(N : ℝ)*K) := by
  have ht := iid_exp_sum_tail N (fun x => (F x)^2/8)
    (hF.pow_const 2 |>.div_const 8) (by norm_num : (0:ℝ)<3) (by simpa using h) K
  convert ht using 2
  ext x
  simp only [Set.mem_setOf_eq, ←Finset.sum_div]
  constructor <;> intro hh <;> nlinarith

end NeuralGeneralization.BatchTwoActivation
