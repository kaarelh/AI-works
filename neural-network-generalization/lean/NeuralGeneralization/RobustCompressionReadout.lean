import NeuralGeneralization.RobustCompressionClipping
import NeuralGeneralization.RobustModel

/-!
# Actual readout truncation and source-index sampling

The bounds hold for every bounded virtual feature field and every fixed original
readout.  Thus they remain available after arbitrary preceding couplings that
preserve the original readout marginal.
-/

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators

namespace NeuralGeneralization.RobustCompressionReadout
open RobustCompressionSampling RobustCompressionClipping CompressionSampling ConcreteModel

variable {N M d r : ℕ} {X : Type*}

def readoutValue (a : Fin N → ℝ) (h : X → Fin N → ℝ) (x : X) : ℝ :=
  populationMean (fun i => a i * h x i)

def clippedReadout (a : Fin N → ℝ) (h : X → Fin N → ℝ) (B : ℝ) (x : X) : ℝ :=
  populationMean (fun i => wholeClip B (a i) * h x i)

def sampledReadout (a : Fin N → ℝ) (h : X → Fin N → ℝ) (B : ℝ)
    (I : Fin M → Fin N) (x : X) : ℝ :=
  empiricalMean (fun i => wholeClip B (a i) * h x i) I

theorem readout_clipping_error (a : Fin N → ℝ) (h : X → Fin N → ℝ)
    (hh : ∀ x i, |h x i| ≤ 1) (B : ℝ) (hB : 0 < B) (x : X) :
    |readoutValue a h x - clippedReadout a h B x| ≤
      populationMean (fun i => a i ^ 2) / B := by
  have he := clipped_average_error a (h x) (hh x) B hB
  simpa [finiteAverage, populationMean, readoutValue, clippedReadout,
    smul_eq_mul, Real.norm_eq_abs, sq_abs, mul_comm, div_eq_mul_inv] using he

theorem readout_sampling_tail [Fintype X] (N M : ℕ) [NeZero N] (hM : 0 < M)
    (a : Fin N → ℝ) (h : X → Fin N → ℝ) (hh : ∀ x i, |h x i| ≤ 1)
    {B η K : ℝ} (hB : 0 < B) (hη : 0 ≤ η)
    (henergy : populationMean (fun i => a i ^ 2) ≤ K) :
    (iidSamples (uniformIndexLaw N) M).real
      {I | ∃ x, K / B + η ≤ |sampledReadout a h B I x - readoutValue a h x|} ≤
      (Fintype.card X : ℝ) * (2 * Real.exp (-(M : ℝ) * η ^ 2 / (2 * B ^ 2))) := by
  have hbound (x : X) (i : Fin N) : |wholeClip B (a i) * h x i| ≤ B := by
    rw [abs_mul]
    have hc := wholeClip_norm_le B hB.le (a i)
    rw [Real.norm_eq_abs] at hc
    calc
      _ ≤ B * 1 := mul_le_mul hc (hh x i) (abs_nonneg _) hB.le
      _ = B := mul_one _
  have htail := finite_bank_tail N M hM (fun x i => wholeClip B (a i) * h x i)
    hB hbound hη
  refine (measureReal_mono (μ := iidSamples (uniformIndexLaw N) M) ?_).trans htail
  intro I hI
  obtain ⟨x, hx⟩ := hI
  refine ⟨x, ?_⟩
  have hc := (readout_clipping_error a h hh B hB x).trans
    (div_le_div_of_nonneg_right henergy hB.le)
  have ht := abs_sub_le (sampledReadout a h B I x) (clippedReadout a h B x)
    (readoutValue a h x)
  rw [abs_sub_comm (clippedReadout a h B x) (readoutValue a h x)] at ht
  change η ≤ |sampledReadout a h B I x - clippedReadout a h B x|
  linarith

/-- The unnormalized physical readout coefficients used by source sampling. -/
def physicalReadout (w : Weights d N r) (i : Fin N) : ℝ :=
  (N : ℝ) * w (Sum.inr (Sum.inr i))

theorem physicalReadout_energy (hN : 0 < N) (w : Weights d N r) :
    populationMean (fun i => physicalReadout w i ^ 2) = readoutEnergy w := by
  have hNR : (N : ℝ) ≠ 0 := (Nat.cast_pos.mpr hN).ne'
  unfold physicalReadout populationMean readoutEnergy
  simp_rw [mul_pow]
  rw [← Finset.mul_sum]
  field_simp

theorem physicalReadout_value (hN : 0 < N) (w : Weights d N r)
    (h : X → Fin N → ℝ) (x : X) :
    readoutValue (physicalReadout w) h x = ∑ i, w (Sum.inr (Sum.inr i)) * h x i := by
  have hNR : (N : ℝ) ≠ 0 := (Nat.cast_pos.mpr hN).ne'
  unfold readoutValue physicalReadout populationMean
  simp_rw [mul_assoc]
  rw [← Finset.mul_sum]
  field_simp

/-- Concrete original weights, with no probabilistic or independence premise
on how the bounded virtual features were obtained. -/
theorem actual_readout_sampling_tail [Fintype X] (N M : ℕ) [NeZero N]
    (hN : 0 < N) (hM : 0 < M) (w : Weights d N r)
    (h : X → Fin N → ℝ) (hh : ∀ x i, |h x i| ≤ 1)
    {B η K : ℝ} (hB : 0 < B) (hη : 0 ≤ η) (henergy : readoutEnergy w ≤ K) :
    (iidSamples (uniformIndexLaw N) M).real
      {I | ∃ x, K / B + η ≤
        |sampledReadout (physicalReadout w) h B I x -
          ∑ i, w (Sum.inr (Sum.inr i)) * h x i|} ≤
      (Fintype.card X : ℝ) * (2 * Real.exp (-(M : ℝ) * η ^ 2 / (2 * B ^ 2))) := by
  have he : populationMean (fun i => physicalReadout w i ^ 2) ≤ K := by
    rwa [physicalReadout_energy hN]
  simpa only [physicalReadout_value hN] using
    readout_sampling_tail N M hM (physicalReadout w) h hh hB hη he

end NeuralGeneralization.RobustCompressionReadout
