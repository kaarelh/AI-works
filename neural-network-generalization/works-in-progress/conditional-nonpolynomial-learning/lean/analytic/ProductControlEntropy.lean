import NeuralGeneralization.RobustEntropyKernel
import NeuralGeneralization.RobustEntropyMoments
import Mathlib.InformationTheory.KullbackLeibler.ChainRule
import Mathlib.MeasureTheory.Measure.Prod
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.FieldSimp

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal ProbabilityTheory
namespace ConditionalNonpolynomial.Analytic

/-- Independent controls have exactly additive relative entropy. This permits
history-dependent deterministic planting without a conditional-density axiom. -/
theorem product_control_kl {Ω Ξ : Type*} [MeasurableSpace Ω] [MeasurableSpace Ξ]
    [MeasurableSpace.CountableOrCountablyGenerated Ω Ξ]
    (Q P : Measure Ω) (R S : Measure Ξ)
    [IsProbabilityMeasure Q] [IsProbabilityMeasure P]
    [IsProbabilityMeasure R] [IsProbabilityMeasure S] :
    klDiv (Q.prod R) (P.prod S)=klDiv Q P+klDiv R S := by
  have h := klDiv_compProd_eq_add Q P (Kernel.const Ω R) (Kernel.const Ω S)
  rw [NeuralGeneralization.RobustEntropy.klDiv_compProd_same_left_eq_lintegral] at h
  simpa only [Measure.compProd_const,Kernel.const_apply,lintegral_const,measure_univ,mul_one] using h

/-- The relative entropy of a controlled construction stays bounded after
all auxiliary variables are discarded through the actual measurable map. -/
theorem mapped_product_control_kl {Ω Ξ Y : Type*}
    [MeasurableSpace Ω] [MeasurableSpace Ξ] [MeasurableSpace Y]
    [StandardBorelSpace Ω] [StandardBorelSpace Ξ] [StandardBorelSpace Y]
    [Nonempty Ω] [Nonempty Ξ]
    (Q P : Measure Ω) (R S : Measure Ξ)
    [IsProbabilityMeasure Q] [IsProbabilityMeasure P]
    [IsProbabilityMeasure R] [IsProbabilityMeasure S]
    (F : Ω×Ξ→Y) (hF : Measurable F) :
    klDiv ((Q.prod R).map F) ((P.prod S).map F)≤klDiv Q P+klDiv R S := by
  rw [← product_control_kl Q P R S]
  exact NeuralGeneralization.RobustEntropy.klDiv_map_le _ _ hF

/-- Binary-event entropy inequality, derived from the actual Mathlib KL and
an exponential test. No likelihood ratio bound is assumed. -/
theorem event_log_mass_entropy {Ω : Type*} [MeasurableSpace Ω]
    (Q P : Measure Ω) [IsProbabilityMeasure Q] [IsProbabilityMeasure P]
    (hKL : klDiv Q P≠∞) (E : Set Ω) (hE : MeasurableSet E)
    (hp : 0<P.real E) :
    Q.real E*(-Real.log (P.real E))≤(klDiv Q P).toReal+Real.log 2 := by
  let p := P.real E
  let a := -Real.log p
  have hp1 : p≤1 := measureReal_le_one
  have ha : 0≤a := neg_nonneg.mpr (Real.log_nonpos hp.le hp1)
  have hexpa : Real.exp a=1/p := by
    rw [show a= -Real.log p from rfl,Real.exp_neg,Real.exp_log hp]
    simp only [one_div,p]
  let f := E.indicator (fun _ => a)
  have hf : Measurable f := measurable_const.indicator hE
  have hf0 : ∀ x, 0≤f x := by intro x; exact Set.indicator_nonneg (fun _ _=>ha) x
  have hfiP : Integrable f P := (integrable_const a).indicator hE
  have hExpEq : (fun x => Real.exp (f x))=
      (fun _ : Ω => 1)+(E.indicator (fun _ => Real.exp a-1)) := by
    funext x
    by_cases hx:x∈E <;> simp [f,hx]
  have hExp : Integrable (fun x => Real.exp (f x)) P := by
    rw [hExpEq]
    exact (integrable_const 1).add ((integrable_const _).indicator hE)
  have hmgf : (∫ x,Real.exp (f x) ∂P)≤Real.exp (Real.log 2) := by
    rw [hExpEq]
    change (∫ x,(1:ℝ)+(E.indicator (fun _ => Real.exp a-1)) x ∂P)≤_
    rw [integral_add (integrable_const (1:ℝ)) ((integrable_const (Real.exp a-1)).indicator hE)]
    simp only [integral_const,probReal_univ,integral_indicator_const _ hE,smul_eq_mul,one_mul,
      Real.exp_log (by norm_num : (0:ℝ)<2)]
    change 1+p*(Real.exp a-1)≤2
    rw [hexpa]
    have he : p*(1/p)=1 := by field_simp [show p≠0 from hp.ne']
    nlinarith
  have hh := NeuralGeneralization.RobustEntropyMoments.integral_le_kl_add_exponential_bound
    Q P hKL f hf hf0 hExp (Real.log 2) hmgf
  simpa only [f,integral_indicator_const _ hE,smul_eq_mul,a,p] using hh

/-- If the controlled law succeeds with probability at least 1−κ, its entropy
cost produces a raw prior-mass lower bound with leading coefficient 1/(1−κ). -/
theorem raw_mass_of_controlled_success {Ω : Type*} [MeasurableSpace Ω]
    (Q P : Measure Ω) [IsProbabilityMeasure Q] [IsProbabilityMeasure P]
    (hKL : klDiv Q P≠∞) (E : Set Ω) (hE : MeasurableSet E)
    (κ D : ℝ) (hκ : κ<1) (hsuccess : 1-κ≤Q.real E)
    (hcost : (klDiv Q P).toReal≤D) :
    Real.exp (-(D+Real.log 2)/(1-κ))≤P.real E := by
  have hqpos : 0<Q.real E := lt_of_lt_of_le (by linarith) hsuccess
  have hp : 0<P.real E := by
    by_contra hn
    have hp0 : P E=0 := (measureReal_eq_zero_iff).mp (le_antisymm (le_of_not_gt hn) measureReal_nonneg)
    have hq0 := (klDiv_ne_top_iff.mp hKL).1 hp0
    have : Q.real E=0 := by simp [Measure.real,hq0]
    linarith
  have hp1 : P.real E≤1 := measureReal_le_one
  have hl : 0≤ -Real.log (P.real E) := neg_nonneg.mpr (Real.log_nonpos hp.le hp1)
  have h := (mul_le_mul_of_nonneg_right hsuccess hl).trans (event_log_mass_entropy Q P hKL E hE hp)
  have hden : 0<1-κ := by linarith
  have hh : -(D+Real.log 2)/(1-κ)≤Real.log (P.real E) := by
    apply (div_le_iff₀ hden).mpr
    nlinarith
  exact (Real.exp_le_exp.mpr hh).trans_eq (Real.exp_log hp)

end ConditionalNonpolynomial.Analytic
