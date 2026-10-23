import NeuralGeneralization.BatchTwoContinuousDepthPowerMain
import NeuralGeneralization.BatchTwoContinuousDepthPowerWidthGrowth

/-! The original manuscript depth index and an explicit polynomial sufficient
width, with no unproved width-growth premise. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1200000
open MeasureTheory ProbabilityTheory Set
namespace NeuralGeneralization.BatchTwoContinuousDepthPower
open ConcreteModel BatchTwoContinuous BatchTwoContinuousDepthLower

theorem finite_power_sample_probability {r n N : ℕ}
    (hr : max 59 sharpInterpolationDepthThreshold≤r) (hn : 0<n)
    (hnr : (n : ℝ)≤Real.exp (((r : ℝ)+2)/100)) {ζ σ : ℝ} (hζ : 0<ζ)
    (hN : widthThreshold (interpolationWidth n) r (1/8) ζ≤N)
    (hσ : 0<σ) (hscale : σ^2≤(N : ℝ)^(-(1+ζ))) :
    (49/50 : ℝ)≤(Measure.pi (fun _ : Fin n=>inputLaw)).real
      {s | (1/2 : ℝ)≤BatchTwoContinuous.confidenceFailure Real.tanh inputLaw
        (BatchTwoContinuous.posterior Real.tanh (smallPrior 2 N (r+1) σ)
          (depthTarget (r+2)) (1/8) s) (depthTarget (r+2)) (1/4)} := by
  apply (powerInterpolationSamples_probability hn r).trans
  apply measureReal_mono ?_ (measure_ne_top _ _)
  intro s hs
  exact (finite_power_failure_on_sample_event hr hn hnr hζ hN hσ hscale s hs).2

/-- Literal finite-exponent main theorem: fixed input law and teacher family,
exponential sample range, and a sufficient width polynomial in n and depth.
The degree is explicitly 161⌈1/ζ⌉. -/
theorem finite_power_manuscript_depth_lower_bound :
    ∃ R₀ : ℕ, ∀ ζ : ℝ, 0<ζ → ∃ B : ℝ, 0<B ∧
      ∀ R n N : ℕ, R₀≤R → 0<n → (n : ℝ)≤Real.exp ((R : ℝ)/100) →
      B*((n : ℝ)+(R : ℝ))^(161*widthExponent ζ)≤(N : ℝ) →
      ∀ σ : ℝ, 0<σ → σ^2≤(N : ℝ)^(-(1+ζ)) →
      (49/50 : ℝ)≤(Measure.pi (fun _ : Fin n=>inputLaw)).real
        {s | (1/2 : ℝ)≤BatchTwoContinuous.confidenceFailure Real.tanh inputLaw
          (BatchTwoContinuous.posterior Real.tanh (smallPrior 2 N (R-1) σ)
            (depthTarget R) (1/8) s) (depthTarget R) (1/4)} := by
  refine ⟨max 59 sharpInterpolationDepthThreshold+2,?_⟩
  intro ζ hζ
  obtain ⟨B,hB,hpoly⟩ := widthThreshold_polynomial hζ
  refine ⟨B,hB,?_⟩
  intro R n N hR hn hnr hN σ hσ hscale
  have hR2 : 2≤R := by omega
  obtain ⟨r,hr⟩ := Nat.exists_eq_add_of_le hR2
  have he : R=r+2 := by omega
  cases he
  have hp := hpoly n r hn
  have hm : B*((n : ℝ)+(r : ℝ)+1)^(161*widthExponent ζ)≤
      B*((n : ℝ)+((r+2 : ℕ) : ℝ))^(161*widthExponent ζ) := by
    apply mul_le_mul_of_nonneg_left _ hB.le
    apply pow_le_pow_left₀ (by positivity)
    push_cast
    linarith
  have hwidth : widthThreshold (interpolationWidth n) r (1/8) ζ≤N := by
    exact_mod_cast hp.trans (hm.trans hN)
  have hh := finite_power_sample_probability (r := r) (by omega) hn
    (by simpa only [Nat.cast_add,Nat.cast_ofNat] using hnr) hζ hwidth hσ hscale
  have hi : r+2-1=r+1 := by omega
  have heq := congrArg (fun q : ℕ => (Measure.pi (fun _ : Fin n=>inputLaw)).real
    {s | (1/2 : ℝ)≤BatchTwoContinuous.confidenceFailure Real.tanh inputLaw
      (BatchTwoContinuous.posterior Real.tanh (smallPrior 2 N q σ)
        (depthTarget (r+2)) (1/8) s) (depthTarget (r+2)) (1/4)}) hi
  rw [heq]
  exact hh

end NeuralGeneralization.BatchTwoContinuousDepthPower
