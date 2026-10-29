import FiniteChannelConstruction

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace ConditionalNonpolynomial.Analytic

def standardizedScalar {Ω : Type*} (t : ℝ) (Z : Ω→ℝ) : Ω→ℝ := fun z=>Z z/t

theorem standardizedScalar_measurable {Ω : Type*} [MeasurableSpace Ω]
    (t : ℝ) (Z : Ω→ℝ) (hZ : Measurable Z) : Measurable (standardizedScalar t Z) := hZ.div_const t

/-- The same physical scalar control can be used at every subcritical
reference variance, after exact standardization of its reference law. -/
theorem standardizedScalar_reference {Ω : Type*} [MeasurableSpace Ω]
    (P : Measure Ω) (Z : Ω→ℝ) (hZ : Measurable Z) {t : ℝ} (ht : 0<t)
    (hP : P.map Z=gaussianReal 0 (t^2).toNNReal) :
    P.map (standardizedScalar t Z)=gaussianReal 0 1 := by
  change P.map ((fun z : ℝ=>z/t) ∘ Z)=_
  rw [←Measure.map_map (by fun_prop) hZ,hP,gaussianReal_map_div_const,zero_div]
  congr 1
  apply NNReal.coe_injective
  simp only [NNReal.coe_div,Real.coe_toNNReal _ (sq_nonneg t),NNReal.coe_mk,NNReal.coe_one]
  exact div_self (sq_pos_of_pos ht).ne'

theorem uniform_first_variance {N : ℕ} (hN : 0<N) (d : ℕ) (t : ℝ) :
    ((N:ℝ)/d)*(t/Real.sqrt N)^2=t^2/d := by
  have hn : (N:ℝ)≠0 := by exact_mod_cast hN.ne'
  rw [div_pow,Real.sq_sqrt (Nat.cast_nonneg N)]
  by_cases hd : (d:ℝ)=0
  · simp [hd]
  · field_simp

#print axioms standardizedScalar_reference
end ConditionalNonpolynomial.Analytic
