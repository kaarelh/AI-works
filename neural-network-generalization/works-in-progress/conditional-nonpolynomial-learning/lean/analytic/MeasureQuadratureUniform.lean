import MeasureQuadratureFinite

/-! Uniform empirical quadrature for a Lipschitz family. The finite input
concentration bound is extended across an actual finite metric cover. -/

noncomputable section
open MeasureTheory
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic

variable {Ω T E : Type*} [MeasurableSpace Ω] [PseudoMetricSpace T]
  [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]

lemma empirical_lipschitz (v : T → Ω → E) (L : ℝ)
    (hLip : ∀ t u x, ‖v t x-v u x‖ ≤ L*dist t u)
    {m : ℕ} (hm : 0 < m) (s : Fin m → Ω) (t u : T) :
    ‖(m:ℝ)⁻¹ • (∑ j, v t (s j)) - (m:ℝ)⁻¹ • (∑ j, v u (s j))‖ ≤ L*dist t u := by
  have hmR : 0 < (m:ℝ) := Nat.cast_pos.mpr hm
  rw [← smul_sub, ← Finset.sum_sub_distrib, norm_smul, Real.norm_eq_abs,
    abs_of_nonneg (inv_nonneg.mpr hmR.le)]
  calc
    (m:ℝ)⁻¹ * ‖∑ j, (v t (s j)-v u (s j))‖
      ≤ (m:ℝ)⁻¹ * ∑ j, ‖v t (s j)-v u (s j)‖ :=
        mul_le_mul_of_nonneg_left (norm_sum_le _ _) (inv_nonneg.mpr hmR.le)
    _ ≤ (m:ℝ)⁻¹ * ∑ _j : Fin m, L*dist t u :=
      mul_le_mul_of_nonneg_left (Finset.sum_le_sum fun j _ => hLip t u (s j))
        (inv_nonneg.mpr hmR.le)
    _ = L*dist t u := by simp [hmR.ne', mul_assoc]

lemma expectation_lipschitz (μ : Measure Ω) [IsProbabilityMeasure μ]
    (v : T → Ω → E) (hInt : ∀ t, Integrable (v t) μ) (L : ℝ)
    (hLip : ∀ t u x, ‖v t x-v u x‖ ≤ L*dist t u) (t u : T) :
    ‖(∫ x, v t x ∂μ) - ∫ x, v u x ∂μ‖ ≤ L*dist t u := by
  rw [← integral_sub (hInt t) (hInt u)]
  simpa using norm_integral_le_of_norm_le_const
    (μ:=μ) (Filter.Eventually.of_forall (hLip t u))

/-- A genuine common sample uniformly approximates a bounded Lipschitz family
on a finitely covered metric parameter space. -/
theorem measure_uniform_quadrature {K : Type*} [Fintype K] [Nonempty K]
    (μ : Measure Ω) [IsProbabilityMeasure μ]
    (v : T → Ω → E) (hInt : ∀ t, Integrable (v t) μ)
    (J L ε δ : ℝ) (hJ : 0 < J) (hL : 0 ≤ L) (hε : 0 < ε)
    (hv : ∀ t x, ‖v t x‖ ≤ J)
    (hLip : ∀ t u x, ‖v t x-v u x‖ ≤ L*dist t u)
    (centers : K → T) (hcover : ∀ t, ∃ k, dist t (centers k) ≤ δ)
    (m : ℕ) (hm : 0 < m)
    (hbudget : 256*J^2*(1+Real.log (Fintype.card K)) ≤ (m:ℝ)*ε^2) :
    ∃ s : Fin m → Ω, ∀ t,
      ‖(m:ℝ)⁻¹ • (∑ j, v t (s j)) - ∫ x, v t x ∂μ‖ < ε+2*L*δ := by
  obtain ⟨s,hs⟩ := measure_finite_input_maurey μ (fun k => v (centers k))
    (fun k => hInt (centers k)) J ε hJ hε (fun k x => hv (centers k) x) m hm hbudget
  refine ⟨s,fun t => ?_⟩
  obtain ⟨k,hk⟩ := hcover t
  have hEmp := (empirical_lipschitz v L hLip hm s t (centers k)).trans
    (mul_le_mul_of_nonneg_left hk hL)
  have hMean := (expectation_lipschitz μ v hInt L hLip t (centers k)).trans
    (mul_le_mul_of_nonneg_left hk hL)
  have h0 := norm_sub_le_norm_sub_add_norm_sub
    ((m:ℝ)⁻¹ • (∑ j, v t (s j)))
    ((m:ℝ)⁻¹ • (∑ j, v (centers k) (s j))) (∫ x, v t x ∂μ)
  have h1 := norm_sub_le_norm_sub_add_norm_sub
    ((m:ℝ)⁻¹ • (∑ j, v (centers k) (s j)))
    (∫ x, v (centers k) x ∂μ) (∫ x, v t x ∂μ)
  rw [norm_sub_rev (∫ x, v (centers k) x ∂μ)] at h1
  linarith [hs k]

#print axioms measure_uniform_quadrature
end ConditionalNonpolynomial.Analytic
