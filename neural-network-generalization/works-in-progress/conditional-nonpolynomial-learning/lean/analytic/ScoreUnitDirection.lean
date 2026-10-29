import AdaptiveGaussianEntropy
import Mathlib.Tactic.FieldSimp

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators NNReal ENNReal
namespace ConditionalNonpolynomial.Analytic

/-- Normalize the empirical score vector, with a fixed unit-vector fallback
on the zero-score event. The reference Gaussian law therefore holds globally,
not merely on the high-probability empirical-moment event. -/
def scoreUnit {N : ℕ} (hN : 0<N) (b : Fin N→ℝ) : Fin N→ℝ :=
  if (∑i,b i^2)=0 then fun i=>if i=⟨0,hN⟩ then 1 else 0
  else fun i=>b i/Real.sqrt (∑j,b j^2)

theorem scoreUnit_measurable {N : ℕ} (hN : 0<N) : Measurable (scoreUnit hN) := by
  unfold scoreUnit
  apply Measurable.ite
  · exact measurableSet_eq_fun (by fun_prop) measurable_const
  · fun_prop
  · fun_prop

theorem scoreUnit_squared {N : ℕ} (hN : 0<N) (b : Fin N→ℝ) :
    ∑i,(scoreUnit hN b i)^2=1 := by
  classical
  by_cases hb : (∑i,b i^2)=0
  · simp [scoreUnit,hb]
  · have hs : 0≤∑i,b i^2 := Finset.sum_nonneg fun i _=>sq_nonneg _
    simp only [scoreUnit,hb,if_false,div_pow,←Finset.sum_div,Real.sq_sqrt hs,div_self hb]

theorem scoreUnit_eq {N : ℕ} (hN : 0<N) (b : Fin N→ℝ) (hb : 0<∑i,b i^2) (i : Fin N) :
    scoreUnit hN b i=b i/Real.sqrt (∑j,b j^2) := by simp [scoreUnit,hb.ne']

/-- The coefficient seen by the next scalar channel is exactly the empirical
score-feature moment divided by the empirical score RMS. -/
theorem scoreUnit_pairing {N : ℕ} (hN : 0<N) (b h : Fin N→ℝ)
    (hb : 0<(∑i,b i^2)/(N:ℝ)) :
    (∑i,scoreUnit hN b i*h i)/Real.sqrt N=
      ((∑i,b i*h i)/(N:ℝ))/Real.sqrt ((∑i,b i^2)/(N:ℝ)) := by
  have hn : (0:ℝ)<N := by exact_mod_cast hN
  have hsum : 0<∑i,b i^2 := (div_pos_iff_of_pos_right hn).mp hb
  simp_rw [scoreUnit_eq hN b hsum,div_mul_eq_mul_div]
  rw [←Finset.sum_div,Real.sqrt_div hsum.le]
  have hs : Real.sqrt (∑i,b i^2)≠0 := (Real.sqrt_pos.mpr hsum).ne'
  have hns : Real.sqrt (N:ℝ)≠0 := (Real.sqrt_pos.mpr hn).ne'
  field_simp
  rw [Real.sq_sqrt hn.le]

end ConditionalNonpolynomial.Analytic
