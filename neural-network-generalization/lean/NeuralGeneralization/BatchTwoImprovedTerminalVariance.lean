import NeuralGeneralization.BatchTwoImprovedFiniteLaw
import NeuralGeneralization.BatchTwoImprovedWeightedMoments
import NeuralGeneralization.RobustCompressionTerminalSampling

/-! Exact second-moment terminal sampling: the clipping bias and the variance
are controlled by the readout energy, without a square of the clipping level. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ENNReal BigOperators
namespace NeuralGeneralization.BatchTwoImprovedTerminal
open Classical ConcreteModel CompressionSampling RobustCompressionSampling
  RobustCompressionClipping RobustCompressionReadout RobustCompressionInduction
  BatchTwoImprovedWeightedSampling

variable {N M : ℕ} {X : Type*}

theorem uniformIndexLaw_eq_finiteLaw (N : ℕ) [NeZero N] :
    uniformIndexLaw N = finiteLaw (fun _ : Fin N => (N : ℝ)⁻¹)
      (fun _ => inv_nonneg.mpr (Nat.cast_nonneg _)) (by
        simp [NeZero.ne N]) := by
  apply Measure.ext_of_singleton
  intro i
  rw [finiteLaw_singleton]
  change (PMF.uniformOfFintype (Fin N)).toMeasure {i} = _
  rw [PMF.toMeasure_apply_singleton _ _ (measurableSet_singleton i)]
  simp [PMF.uniformOfFintype_apply, ENNReal.ofReal_inv_of_pos
    (by exact_mod_cast NeZero.pos N : (0 : ℝ) < N)]

theorem uniform_weighted_mean [NeZero N] (f : Fin N → ℝ) :
    mean (fun _ : Fin N => (N : ℝ)⁻¹) f = populationMean f := by
  simp only [mean, populationMean, ← Finset.mul_sum]
  ring

theorem iid_uniform_average_variance [NeZero N] (hM : 0 < M) (f : Fin N → ℝ) :
    (∫ I, (empiricalMean f I - populationMean f)^2
      ∂iidSamples (uniformIndexLaw N) M) ≤ populationMean (fun i => (f i)^2) / M := by
  rw [uniformIndexLaw_eq_finiteLaw]
  change (∫ I : Fin M → Fin N, ((∑ j, f (I j))/(M : ℝ)-populationMean f)^2
      ∂Measure.pi (fun _ : Fin M => finiteLaw _ _ _)) ≤ _
  rw [iid_finiteLaw_integral]
  have h := mean_iid_average_variance_le (fun _ : Fin N => (N : ℝ)⁻¹)
    (by simp [NeZero.ne N]) M hM f
  simpa only [uniform_weighted_mean] using h

theorem readout_sampling_variance_tail [NeZero N] (hM : 0 < M)
    (a : Fin N → ℝ) (h : X → Fin N → ℝ) (hh : ∀ x i, |h x i| ≤ 1)
    {B η K : ℝ} (hB : 0 < B) (hη : 0 < η)
    (henergy : populationMean (fun i => a i ^ 2) ≤ K) (x : X) :
    (iidSamples (uniformIndexLaw N) M).real
      {I | K/B+η ≤ |sampledReadout a h B I x-readoutValue a h x|} ≤
      K/((M : ℝ)*η^2) := by
  let f : Fin N → ℝ := fun i => wholeClip B (a i)*h x i
  let μ := iidSamples (uniformIndexLaw N) M
  have hf (i : Fin N) : (f i)^2 ≤ (a i)^2 := by
    dsimp [f]
    unfold wholeClip
    split_ifs
    · have hs : (h x i)^2 ≤ 1 := (sq_le_one_iff_abs_le_one _).mpr (hh x i)
      nlinarith [mul_nonneg (sq_nonneg (a i)) (sub_nonneg.mpr hs)]
    · simpa using sq_nonneg (a i)
  have he : populationMean (fun i => (f i)^2) ≤ K := by
    apply le_trans _ henergy
    exact div_le_div_of_nonneg_right (Finset.sum_le_sum (fun i _ => hf i))
      (Nat.cast_nonneg N)
  have hv := (iid_uniform_average_variance hM f).trans
    (div_le_div_of_nonneg_right he (Nat.cast_nonneg M))
  have hm := mul_meas_ge_le_integral_of_nonneg (μ := μ)
    (ae_of_all _ (fun I => sq_nonneg (empiricalMean f I-populationMean f)))
    Integrable.of_finite (η^2)
  have ht : μ.real {I | η ≤ |empiricalMean f I-populationMean f|} ≤
      K/((M : ℝ)*η^2) := by
    have hs : {I : Fin M → Fin N | η ≤ |empiricalMean f I-populationMean f|} ⊆
        {I | η^2 ≤ (empiricalMean f I-populationMean f)^2} := by
      intro I hI
      change η ≤ |empiricalMean f I-populationMean f| at hI
      exact (pow_le_pow_left₀ hη.le hI 2).trans_eq (sq_abs _)
    have hmono := measureReal_mono (μ := μ) hs
    have hM' : (0 : ℝ) < M := by exact_mod_cast hM
    apply (le_div_iff₀ (by positivity : 0 < (M : ℝ)*η^2)).mpr
    have hmain : η^2 * μ.real {I | η ≤ |empiricalMean f I-populationMean f|} ≤
        K/(M : ℝ) := (mul_le_mul_of_nonneg_left hmono (sq_nonneg η)).trans (hm.trans hv)
    have hh := (le_div_iff₀ hM').mp hmain
    nlinarith
  apply (measureReal_mono (μ := μ) ?_).trans ht
  intro I hI
  have hc := (readout_clipping_error a h hh B hB x).trans
    (div_le_div_of_nonneg_right henergy hB.le)
  have htri := abs_sub_le (sampledReadout a h B I x) (clippedReadout a h B x)
    (readoutValue a h x)
  rw [abs_sub_comm (clippedReadout a h B x) (readoutValue a h x)] at htri
  change η ≤ |sampledReadout a h B I x-clippedReadout a h B x|
  change K/B+η ≤ |sampledReadout a h B I x-readoutValue a h x| at hI
  linarith

end NeuralGeneralization.BatchTwoImprovedTerminal
