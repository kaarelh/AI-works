import DenseDualGrid
import NeuralGeneralization.GaussianDualLayer

/-! Actual positive-event extraction from dense finite tests. These statements
select a realization in the supplied event; they do not assume an entropy
certificate or an exponential-family optimizer. -/
noncomputable section
set_option linter.unusedSectionVars false
open MeasureTheory
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic

variable {Ω : Type*} [MeasurableSpace Ω]

/-- Markov's inequality guarantees a point of the actual event with small cost.
No measurability of an optimizer is involved. -/
theorem exists_mem_cost_le (μ : Measure Ω) [IsFiniteMeasure μ]
    (cost : Ω → ℝ) {N : ℕ} (hN : 0 < N) (E : Set Ω) (B C : ℝ)
    (hInt : Integrable (fun w => Real.exp ((N:ℝ)*cost w)) μ)
    (hMoment : (∫ w, Real.exp ((N:ℝ)*cost w) ∂μ) ≤ C)
    (hMass : C / Real.exp ((N:ℝ)*B) < μ.real E) :
    ∃ w ∈ E, cost w ≤ B := by
  by_contra h
  have hall : ∀ w ∈ E, B < cost w := by
    simpa only [not_exists, not_and, not_le] using h
  have hNr : (0:ℝ) < N := by exact_mod_cast hN
  have hMarkov := mul_meas_ge_le_integral_of_nonneg
    (μ := μ) (f := fun w => Real.exp ((N:ℝ)*cost w))
    (ae_of_all _ (fun _ => (Real.exp_pos _).le)) hInt (Real.exp ((N:ℝ)*B))
  have hupper : μ.real E ≤ C / Real.exp ((N:ℝ)*B) := by
    apply (le_div_iff₀ (Real.exp_pos _)).mpr
    have hmono : μ.real E ≤ μ.real
        {w | Real.exp ((N:ℝ)*B) ≤ Real.exp ((N:ℝ)*cost w)} := by
      apply measureReal_mono _ (measure_ne_top _ _)
      intro w hw
      exact Real.exp_le_exp.mpr (mul_le_mul_of_nonneg_left (hall w hw).le hNr.le)
    have hm : μ.real {w | Real.exp ((N:ℝ)*B) ≤ Real.exp ((N:ℝ)*cost w)} *
        Real.exp ((N:ℝ)*B) ≤ C := by
      calc
        _ ≤ ∫ w, Real.exp ((N:ℝ)*cost w) ∂μ := by
          simpa only [mul_comm] using hMarkov
        _ ≤ C := hMoment
    exact (mul_le_mul_of_nonneg_right hmono (Real.exp_pos _).le).trans hm
  exact (not_lt_of_ge hupper) hMass

open NeuralGeneralization.BoundedDual NeuralGeneralization.BoundedTilt
open NeuralGeneralization.ActualBoundedDual NeuralGeneralization.DualCertificate
open NeuralGeneralization.CompressionSampling

variable {ι : Type*} [Fintype ι] [DecidableEq ι] [Nonempty ι]
variable (μ : Measure Ω) [IsProbabilityMeasure μ]

lemma empirical_abs_le_one (T : ι → Ω → ℝ)
    (hbound : ∀ i x, |T i x| ≤ 1) {N : ℕ} (hN : 0 < N)
    (a : Fin N → Ω) (i : ι) : |empirical T a i| ≤ 1 := by
  have hNr : (0:ℝ) < N := by exact_mod_cast hN
  rw [empirical, abs_div, abs_of_pos hNr]
  apply (div_le_one hNr).mpr
  calc
    |∑ j, T i (a j)| ≤ ∑ j, |T i (a j)| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ _j : Fin N, (1:ℝ) := Finset.sum_le_sum (fun j _ => hbound i (a j))
    _ = N := by simp

/-- The quantitative one-layer positive-event entropy certificate. The rate
bound depends on log of a dense grid's cardinality, not a reciprocal-square
moment tolerance. -/
theorem event_contains_actual_tilt
    (T : ι → Ω → ℝ) (hT : ∀ i, Measurable (T i))
    (hbound : ∀ i x, |T i x| ≤ 1)
    {G : ℝ} (hG : 0 < G) {M N : ℕ} (hM : 0 < M) (hN : 0 < N)
    (E : Set (Fin N → Ω)) (B : ℝ)
    (hMass :
      (Real.exp ((N:ℝ)*(2*(Fintype.card ι:ℝ)*G/M))*
        (((2*M+1)^(Fintype.card ι):ℕ):ℝ)) / Real.exp ((N:ℝ)*B)
          < (iidSamples μ N).real E) :
    ∃ a ∈ E, ∃ star : ι → ℝ, entryL1 star ≤ G ∧
      entropy μ T star ≤ B ∧ maxAbs (empirical T a-mean μ T star) ≤ B/G := by
  obtain ⟨a,ha,hcost⟩ := exists_mem_cost_le (iidSamples μ N)
    (fun a => denseCost μ T G M N (empirical T a)) hN E B _
    (integrable_exp_denseCost μ T hT hbound G M hN)
    (integral_exp_denseCost μ T hT hbound G M hN).le hMass
  obtain ⟨star,hstar,hent,herr⟩ := exists_tilt_of_denseCost μ T hT hbound hG hM hN
    (empirical T a) (empirical_abs_le_one T hbound hN a)
  exact ⟨a,ha,star,hstar,hent.trans hcost,
    herr.trans (div_le_div_of_nonneg_right hcost hG.le)⟩

#print axioms exists_mem_cost_le
#print axioms event_contains_actual_tilt
end ConditionalNonpolynomial.Analytic
