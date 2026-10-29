import ProductControlEntropy
import Mathlib.Probability.Distributions.Bernoulli
import Mathlib.MeasureTheory.Integral.Prod

/-! Exact zero-entropy reduction of a tracked component by an independent
bounded centered sign. Both the controlled and reference laws get the same tag. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal
namespace ConditionalNonpolynomial.Analytic

def scoreSignLaw : Measure Bool := bernoulliMeasure true false ⟨1/2,by constructor <;> norm_num⟩
instance scoreSignLaw_probability : IsProbabilityMeasure scoreSignLaw := by
  unfold scoreSignLaw
  infer_instance

def scoreSign (s : Bool) : ℝ := if s then 1 else -1

def downgradedScore {Ω : Type*} (α : ℝ) (b : Ω→ℝ) (p : Ω×Bool) : ℝ :=
  α*b p.1+Real.sqrt (1-α^2)*scoreSign p.2

theorem downgradedScore_measurable {Ω : Type*} [MeasurableSpace Ω]
    (α : ℝ) (b : Ω→ℝ) (hb : Measurable b) : Measurable (downgradedScore α b) := by
  have hs : Measurable scoreSign := measurable_of_countable _
  unfold downgradedScore
  fun_prop

theorem downgradedScore_bound {Ω : Type*} {α B : ℝ} (b : Ω→ℝ)
    (hα : 0≤α) (hα1 : α≤1) (hB : 0≤B) (hb : ∀z,|b z|≤B) (p : Ω×Bool) :
    |downgradedScore α b p|≤B+1 := by
  have hρ : Real.sqrt (1-α^2)≤1 := (Real.sqrt_le_iff).mpr ⟨by norm_num,by nlinarith⟩
  have hs : |scoreSign p.2|=1 := by cases p.2 <;> norm_num [scoreSign]
  have ha := mul_le_mul hα1 (hb p.1) (abs_nonneg _) (by norm_num : (0:ℝ)≤1)
  have ht := abs_add_le (α*b p.1) (Real.sqrt (1-α^2)*scoreSign p.2)
  simp only [abs_mul,abs_of_nonneg hα,abs_of_nonneg (Real.sqrt_nonneg _),hs,mul_one] at ht
  unfold downgradedScore
  nlinarith

lemma downgradedScore_sign_square_integral {Ω : Type*} {α : ℝ} (b : Ω→ℝ)
    (hα : 0≤α) (hα1 : α≤1) (z : Ω) :
    (∫s,downgradedScore α b (z,s)^2 ∂scoreSignLaw)=α^2*(b z)^2+(1-α^2) := by
  rw [scoreSignLaw,integral_bernoulliMeasure]
  norm_num only [downgradedScore,scoreSign,if_true,Bool.false_eq_true,if_false,
    smul_eq_mul]
  have hρ := Real.sq_sqrt (show 0≤1-α^2 by nlinarith)
  nlinarith

theorem downgradedScore_unit {Ω : Type*} [MeasurableSpace Ω]
    (Q : Measure Ω) [IsProbabilityMeasure Q] {α B : ℝ} (b : Ω→ℝ)
    (hα : 0≤α) (hα1 : α≤1) (hB : 0≤B) (hb : Measurable b)
    (hbB : ∀z,|b z|≤B) (hunit : (∫z,(b z)^2 ∂Q)=1) :
    (∫p,(downgradedScore α b p)^2 ∂Q.prod scoreSignLaw)=1 := by
  have hLp : MemLp b 2 Q := MemLp.of_bound hb.aestronglyMeasurable B
    (Filter.Eventually.of_forall fun z=>by simpa only [Real.norm_eq_abs] using hbB z)
  have hi : Integrable (fun p=>(downgradedScore α b p)^2) (Q.prod scoreSignLaw) := by
    apply Integrable.of_bound ((downgradedScore_measurable α b hb).pow_const 2).aestronglyMeasurable ((B+1)^2)
    apply Filter.Eventually.of_forall
    intro p
    rw [Real.norm_eq_abs,abs_of_nonneg (sq_nonneg _)]
    simpa only [sq_abs] using (sq_le_sq₀ (abs_nonneg _) (by positivity)).mpr
      (downgradedScore_bound b hα hα1 hB hbB p)
  rw [integral_prod _ hi]
  simp_rw [downgradedScore_sign_square_integral b hα hα1]
  rw [integral_add (hLp.integrable_sq.const_mul _) (integrable_const _),integral_const_mul,hunit]
  simp

theorem downgradedScore_correlation {Ω : Type*} [MeasurableSpace Ω]
    (Q : Measure Ω) [IsProbabilityMeasure Q] {α B : ℝ} (b f : Ω→ℝ)
    (hα : 0≤α) (hα1 : α≤1) (hB : 0≤B) (hb : Measurable b) (hf : Measurable f)
    (hbB : ∀z,|b z|≤B) (hfB : ∀z,|f z|≤1) :
    (∫p,downgradedScore α b p*f p.1 ∂Q.prod scoreSignLaw)=α*(∫z,b z*f z ∂Q) := by
  have hi : Integrable (fun p=>downgradedScore α b p*f p.1) (Q.prod scoreSignLaw) := by
    apply Integrable.of_bound ((downgradedScore_measurable α b hb).mul
      (hf.comp measurable_fst)).aestronglyMeasurable (B+1)
    apply Filter.Eventually.of_forall
    intro p
    change |downgradedScore α b p*f p.1|≤B+1
    rw [abs_mul]
    exact (mul_le_mul (downgradedScore_bound b hα hα1 hB hbB p) (hfB p.1)
      (abs_nonneg _) (by positivity)).trans_eq (mul_one _)
  rw [integral_prod _ hi]
  have heq (z : Ω) : (∫s,downgradedScore α b (z,s)*f z ∂scoreSignLaw)=α*(b z*f z) := by
    rw [scoreSignLaw,integral_bernoulliMeasure]
    norm_num only [downgradedScore,scoreSign,if_true,Bool.false_eq_true,if_false,
      smul_eq_mul]
    ring
  simp_rw [heq]
  exact integral_const_mul _ _

theorem score_downgrade_kl {Ω : Type*} [MeasurableSpace Ω]
    (Q P : Measure Ω) [IsProbabilityMeasure Q] [IsProbabilityMeasure P] :
    klDiv (Q.prod scoreSignLaw) (P.prod scoreSignLaw)=klDiv Q P := by
  rw [product_control_kl,klDiv_self,add_zero]

#print axioms downgradedScore_unit
#print axioms downgradedScore_correlation
#print axioms score_downgrade_kl
end ConditionalNonpolynomial.Analytic
