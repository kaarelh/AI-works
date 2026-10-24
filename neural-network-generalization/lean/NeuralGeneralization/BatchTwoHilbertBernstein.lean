import NeuralGeneralization.BatchTwoHilbertConcentration

/-! A Bernstein-form bound sufficient for the manuscript's sharp robust
compression width. No dimension factor occurs. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoHilbert
open CompressionSampling
variable {Ω E : Type*} [Fintype Ω] [MeasurableSpace Ω] [MeasurableSingletonClass Ω]
  [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]

theorem bernstein_parameter_bound {V b t : ℝ} (hV : 0 < V) (hb : 0 < b) (ht : 0 ≤ t) :
    let θ := min (t/(3*V)) (1/b)
    0 ≤ θ ∧ θ*b ≤ 1 ∧
      1+(3/2 : ℝ)*θ^2*V-θ*t ≤ 1-min (t^2/(6*V)) (t/(2*b)) := by
  let θ := min (t/(3*V)) (1/b)
  have hθ : 0 ≤ θ := le_min (by positivity) (by positivity)
  have hbθ : θ*b ≤ 1 := (le_div_iff₀ hb).mp (min_le_right _ _)
  have hθV : θ*(3*V) ≤ t := (le_div_iff₀ (by positivity : 0 < 3*V)).mp (min_le_left _ _)
  have hq : (3/2 : ℝ)*θ^2*V ≤ θ*t/2 := by
    have hh := mul_le_mul_of_nonneg_left hθV hθ
    nlinarith only [hh]
  have he : θ*t/2 = min (t^2/(6*V)) (t/(2*b)) := by
    change min (t/(3*V)) (1/b)*t/2 = _
    rw [show min (t/(3*V)) (1/b)*t/2 = min (t/(3*V)) (1/b)*(t/2) by ring,
      min_mul_of_nonneg _ _ (show 0 ≤ t/2 by positivity)]
    congr 1 <;> field_simp <;> ring
  exact ⟨hθ,hbθ,by rw [← he]; linarith only [hq]⟩

theorem iid_hilbert_bernstein (μ : Measure Ω) [IsProbabilityMeasure μ]
    (X : Ω → E) (hmean : (∫ ω, X ω ∂μ) = 0)
    {b v t : ℝ} (hb : 0 < b) (hbound : ∀ ω, ‖X ω‖ ≤ b)
    (hv : 0 < v) (hvariance : (∫ ω, ‖X ω‖^2 ∂μ) ≤ v)
    (ht : 0 ≤ t) (M : ℕ) (hM : 0 < M) :
    (iidSamples μ M).real {ω | t ≤ ‖∑ i : Fin M, X (ω i)‖} ≤
      Real.exp (1-min (t^2/(6*(M:ℝ)*v)) (t/(2*b))) := by
  have hV : 0 < (M:ℝ)*v := mul_pos (by exact_mod_cast hM) hv
  let θ := min (t/(3*((M:ℝ)*v))) (1/b)
  obtain ⟨hθ,hθb,hexp⟩ := bernstein_parameter_bound hV hb ht
  have h := iid_hilbert_chernoff μ X hmean hb.le hbound hvariance hθ hθb M (t := t)
  refine h.trans (Real.exp_le_exp.mpr ?_)
  convert hexp using 1 <;> ring

#print axioms iid_hilbert_bernstein

end NeuralGeneralization.BatchTwoHilbert
