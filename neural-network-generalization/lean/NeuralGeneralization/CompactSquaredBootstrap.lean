import NeuralGeneralization.CompactSymmetrization
import NeuralGeneralization.EmpiricalSquareBootstrap

/-! The self-normalizing quadratic bootstrap under arbitrary probability
laws. This is an integral argument; the observations need not be finite. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory
open scoped BigOperators
namespace NeuralGeneralization.SquaredSampling
variable {X E : Type*}
variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
variable [MeasurableSpace X] [BorelSpace X] [SecondCountableTopology X]
variable [NormedAddCommGroup E] [NormedSpace ℝ E] [CompleteSpace E]

lemma continuous_finiteMean {I Y : Type*} [Fintype I] [TopologicalSpace Y]
    {f : I → Y → ℝ} (hf : ∀ i,Continuous (f i)) :
    Continuous (fun y => finiteMean (fun i => f i y)) := by
  unfold finiteMean
  fun_prop

lemma compact_integral_square_jensen (μ : Measure X) [IsProbabilityMeasure μ]
    {f : X → ℝ} (hf : Continuous f) :
    (∫ x,f x ∂μ)^2 ≤ ∫ x,(f x)^2 ∂μ := by
  let a := ∫ x,f x ∂μ
  have h0 : 0 ≤ ∫ x,(f x-a)^2 ∂μ := integral_nonneg (fun x => sq_nonneg (f x-a))
  have he : (∫ x,(f x-a)^2 ∂μ) = (∫ x,f x^2 ∂μ)-a^2 := by
    simp_rw [show ∀ x,(f x-a)^2=f x^2-2*a*f x+a^2 by intro x; ring]
    have hs : Integrable (fun x => f x^2) μ := compact_integrable μ (hf.pow 2)
    have hm : Integrable (fun x => 2*a*f x) μ := compact_integrable μ (continuous_const.mul hf)
    have hsub : Integrable (fun x => f x^2-2*a*f x) μ := hs.sub hm
    rw [integral_add hsub (integrable_const _), integral_sub hs hm,integral_const_mul]
    simp only [integral_const,measureReal_univ_eq_one,smul_eq_mul,one_mul]
    change (∫ x,f x^2 ∂μ)-2*a*a+a^2 = _
    ring
  rw [he] at h0
  change a^2 ≤ _
  linarith

lemma compact_integral_sqrt_square (μ : Measure X) [IsProbabilityMeasure μ]
    {f : X → ℝ} (hf : Continuous f) (h0 : ∀ x,0 ≤ f x) :
    (∫ x,Real.sqrt (f x) ∂μ)^2 ≤ ∫ x,f x ∂μ := by
  have hh := compact_integral_square_jensen μ (Real.continuous_sqrt.comp hf)
  simpa only [Function.comp_apply,Real.sq_sqrt (h0 _)] using hh

/-- Exact counterpart of the empirical-covariance bootstrap in the paper;
there is no artificial +1 inside the conditional empirical norm. -/
theorem compact_squared_process_bootstrap (μ : Measure X) [IsProbabilityMeasure μ]
    {F G : X → E} (hF : Continuous F) (hG : Continuous G) (n : ℕ) (A : ℝ)
    (hA : 0 ≤ A) (hpop : ‖∫ x,G x ∂μ‖ ≤ 1)
    (hradG : ∀ s : Fin n → X,
      finiteMean (fun ε : Fin n → Bool => ‖signedSum G ε s‖) ≤
        A*Real.sqrt ‖sampleSum G s‖)
    (hradF : ∀ s : Fin n → X,
      finiteMean (fun ε : Fin n → Bool => ‖signedSum F ε s‖) ≤
        A*Real.sqrt ‖sampleSum G s‖) :
    (∫ s : Fin n → X,‖sampleSum F s-(n:ℝ) • ∫ x,F x ∂μ‖ ∂Measure.pi (fun _ => μ)) ≤
      4*A^2+2*A*Real.sqrt (n:ℝ) := by
  let ν := Measure.pi (fun _ : Fin n => μ)
  let S := fun s : Fin n → X => ‖sampleSum G s‖
  let Y := ∫ s,Real.sqrt (S s) ∂ν
  let Z := fun s : Fin n → X => ‖sampleSum G s-(n:ℝ) • ∫ x,G x ∂μ‖
  have hcS : Continuous S := (continuous_sampleSum hG).norm
  have hcZ : Continuous Z := ((continuous_sampleSum hG).sub continuous_const).norm
  have hY : 0 ≤ Y := integral_nonneg (fun _ => Real.sqrt_nonneg _)
  have hYsq : Y^2 ≤ ∫ s,S s ∂ν := compact_integral_sqrt_square ν hcS (fun _ => norm_nonneg _)
  have hS : (∫ s,S s ∂ν) ≤ (n:ℝ)+∫ s,Z s ∂ν := by
    have hb (s : Fin n → X) : S s ≤ (n:ℝ)+Z s := by
      have hh := norm_sub_le (sampleSum G s) ((n:ℝ) • ∫ x,G x ∂μ)
      have hh' := norm_add_le (sampleSum G s-(n:ℝ) • ∫ x,G x ∂μ) ((n:ℝ) • ∫ x,G x ∂μ)
      rw [sub_add_cancel,norm_smul,Real.norm_eq_abs,abs_of_nonneg (Nat.cast_nonneg n)] at hh'
      have hm := mul_le_mul_of_nonneg_left hpop (Nat.cast_nonneg n)
      dsimp [S,Z]
      linarith
    have hi := integral_mono (compact_integrable ν hcS)
      (compact_integrable ν (continuous_const.add hcZ)) hb
    simpa only [Pi.add_apply,integral_add (integrable_const _) (compact_integrable ν hcZ),
      integral_const,measureReal_univ_eq_one,smul_eq_mul,one_mul] using hi
  have hbound {H : X → E} (hH : Continuous H)
      (hrad : ∀ s : Fin n → X,
        finiteMean (fun ε : Fin n → Bool => ‖signedSum H ε s‖) ≤ A*Real.sqrt (S s)) :
      (∫ s,‖sampleSum H s-(n:ℝ) • ∫ x,H x ∂μ‖ ∂ν) ≤ 2*A*Y := by
    have hs := compact_rademacher_symmetrization μ hH n
    have hi := integral_mono (compact_integrable ν
      (continuous_finiteMean (fun ε => (continuous_signedSum hH ε).norm)))
      (compact_integrable ν (continuous_const.mul (Real.continuous_sqrt.comp hcS))) hrad
    simp only [Pi.mul_apply,Function.comp_apply] at hi
    rw [integral_const_mul] at hi
    dsimp only [Y,ν] at *
    linarith
  have hZ : (∫ s,Z s ∂ν) ≤ 2*A*Y := hbound hG hradG
  have hy := square_bootstrap A n Y hA (Nat.cast_nonneg n) hY
    (hYsq.trans (hS.trans (by linarith)))
  have hf := hbound hF hradF
  have hh := mul_le_mul_of_nonneg_left hy (show 0 ≤ 2*A by positivity)
  nlinarith only [hf,hh]

end NeuralGeneralization.SquaredSampling
