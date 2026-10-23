import NeuralGeneralization.BatchTwoHilbertPotential
import NeuralGeneralization.IIDLaw
import Mathlib.MeasureTheory.Function.L2Space
import Mathlib.MeasureTheory.Integral.Pi
import Mathlib.MeasureTheory.Integral.Prod

/-! Dimension-free concentration for actual independent finite-source
Hilbert-valued samples, with variance rather than ambient dimension in the
exponent. All integrals and product laws below are the concrete ones. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoHilbert
open CompressionSampling
variable {Ω E : Type*} [Fintype Ω] [MeasurableSpace Ω] [MeasurableSingletonClass Ω]
  [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]

theorem centered_potential_step (μ : Measure Ω) [IsProbabilityMeasure μ]
    (X : Ω → E) (hmean : (∫ ω, X ω ∂μ) = 0) (hbound : ∀ ω, ‖X ω‖ ≤ 1)
    {v : ℝ} (hv : (∫ ω, ‖X ω‖^2 ∂μ) ≤ v) (x : E) :
    (∫ ω, potential (x+X ω) ∂μ) ≤ potential x * Real.exp ((3/2 : ℝ)*v) := by
  have h := integral_mono (μ := μ) (f := fun ω => potential (x+X ω))
    (g := fun ω => potential x + potential x/radialNorm x*inner ℝ x (X ω) +
      (3/2 : ℝ)*potential x*‖X ω‖^2)
    Integrable.of_finite Integrable.of_finite (fun ω => potential_add_le x (X ω) (hbound ω))
  rw [integral_add Integrable.of_finite Integrable.of_finite,
    integral_add Integrable.of_finite Integrable.of_finite,
    integral_const, integral_const_mul, integral_inner Integrable.of_finite,
    hmean, inner_zero_right, mul_zero, add_zero, integral_const_mul] at h
  simp only [probReal_univ, one_smul] at h
  calc
    _ ≤ potential x + (3/2 : ℝ)*potential x*(∫ ω, ‖X ω‖^2 ∂μ) := h
    _ ≤ potential x * (1+(3/2 : ℝ)*v) := by
      have hm := mul_le_mul_of_nonneg_left hv
        (show 0 ≤ (3/2 : ℝ)*potential x by positivity [potential_pos x])
      nlinarith only [hm]
    _ ≤ potential x * Real.exp ((3/2 : ℝ)*v) :=
      mul_le_mul_of_nonneg_left (by linarith only [Real.add_one_le_exp ((3/2 : ℝ)*v)])
        (potential_pos x).le

theorem iid_potential_bound (μ : Measure Ω) [IsProbabilityMeasure μ]
    (X : Ω → E) (hmean : (∫ ω, X ω ∂μ) = 0) (hbound : ∀ ω, ‖X ω‖ ≤ 1)
    {v : ℝ} (hv : (∫ ω, ‖X ω‖^2 ∂μ) ≤ v) (M : ℕ) (x : E) :
    (∫ ω, potential (x+∑ i : Fin M, X (ω i)) ∂iidSamples μ M) ≤
      potential x * Real.exp ((3/2 : ℝ)*M*v) := by
  induction M generalizing x with
  | zero => simp
  | succ M ih =>
    have heq : (∫ ω, potential (x+∑ i : Fin (M+1), X (ω i)) ∂iidSamples μ (M+1)) =
        ∫ z : Ω × (Fin M → Ω), potential (x+X z.1+∑ i, X (z.2 i))
          ∂μ.prod (iidSamples μ M) := by
      unfold iidSamples
      rw [← ((measurePreserving_piFinSuccAbove (fun _ : Fin (M+1) => μ) 0).symm).integral_comp']
      simp only [Function.comp_def,MeasurableEquiv.piFinSuccAbove_symm_apply,
        Fin.insertNthEquiv,Fin.sum_univ_succ,Fin.insertNth_zero,Equiv.coe_fn_mk,
        Fin.cons_succ,Fin.zero_succAbove,Fin.cons_zero,cast_eq,add_assoc]
    rw [heq,integral_prod _ Integrable.of_finite]
    calc
      _ ≤ ∫ a, potential (x+X a)*Real.exp ((3/2 : ℝ)*M*v) ∂μ :=
        integral_mono Integrable.of_finite Integrable.of_finite (fun a => ih (x+X a))
      _ = (∫ a, potential (x+X a) ∂μ)*Real.exp ((3/2 : ℝ)*M*v) := integral_mul_const _ _
      _ ≤ (potential x*Real.exp ((3/2 : ℝ)*v))*Real.exp ((3/2 : ℝ)*M*v) :=
        mul_le_mul_of_nonneg_right (centered_potential_step μ X hmean hbound hv x) (Real.exp_nonneg _)
      _ = potential x*Real.exp ((3/2 : ℝ)*(↑(M+1):ℝ)*v) := by
        rw [mul_assoc,← Real.exp_add]
        congr 2
        push_cast
        ring

theorem iid_hilbert_chernoff (μ : Measure Ω) [IsProbabilityMeasure μ]
    (X : Ω → E) (hmean : (∫ ω, X ω ∂μ) = 0)
    {b v θ t : ℝ} (hb : 0 ≤ b) (hbound : ∀ ω, ‖X ω‖ ≤ b)
    (hv : (∫ ω, ‖X ω‖^2 ∂μ) ≤ v) (hθ : 0 ≤ θ) (hθb : θ*b ≤ 1)
    (M : ℕ) :
    (iidSamples μ M).real {ω | t ≤ ‖∑ i : Fin M, X (ω i)‖} ≤
      Real.exp (1+(3/2 : ℝ)*M*θ^2*v-θ*t) := by
  let Y := fun ω => θ • X ω
  have hmeanY : (∫ ω, Y ω ∂μ) = 0 := by simp [Y,integral_smul,hmean]
  have hboundY : ∀ ω, ‖Y ω‖ ≤ 1 := by
    intro ω
    simp only [Y,norm_smul,Real.norm_eq_abs,abs_of_nonneg hθ]
    exact (mul_le_mul_of_nonneg_left (hbound ω) hθ).trans hθb
  have hvY : (∫ ω, ‖Y ω‖^2 ∂μ) ≤ θ^2*v := by
    simp only [Y,norm_smul,Real.norm_eq_abs,abs_of_nonneg hθ,mul_pow]
    rw [integral_const_mul]
    exact mul_le_mul_of_nonneg_left hv (sq_nonneg θ)
  have hpot := iid_potential_bound μ Y hmeanY hboundY hvY M (0:E)
  simp only [zero_add,potential_zero,← Real.exp_add] at hpot
  have hm := mul_meas_ge_le_integral_of_nonneg (μ := iidSamples μ M)
    (f := fun ω => potential (∑ i : Fin M, Y (ω i)))
    (ae_of_all _ fun _ => (potential_pos _).le) Integrable.of_finite (Real.exp (θ*t))
  have hsub : {ω : Fin M → Ω | t ≤ ‖∑ i, X (ω i)‖} ⊆
      {ω | Real.exp (θ*t) ≤ potential (∑ i, Y (ω i))} := by
    intro ω hω
    apply le_trans _ (exp_norm_le_potential _)
    apply Real.exp_le_exp.mpr
    simp only [Y,← Finset.smul_sum,norm_smul,Real.norm_eq_abs,abs_of_nonneg hθ]
    exact mul_le_mul_of_nonneg_left hω hθ
  have htail : (iidSamples μ M).real {ω | t ≤ ‖∑ i : Fin M, X (ω i)‖} ≤
      Real.exp (1+(3/2 : ℝ)*M*(θ^2*v))/Real.exp (θ*t) :=
    (measureReal_mono hsub).trans ((le_div_iff₀ (Real.exp_pos (θ*t))).mpr (by
    nlinarith only [hm,hpot]))
  calc
    _ ≤ Real.exp (1+(3/2 : ℝ)*M*(θ^2*v))/Real.exp (θ*t) := htail
    _ = _ := by rw [← Real.exp_sub]; congr 1; ring

end NeuralGeneralization.BatchTwoHilbert
