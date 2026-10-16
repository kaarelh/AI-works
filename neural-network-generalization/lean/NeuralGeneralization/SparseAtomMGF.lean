import NeuralGeneralization.SparseAtomLaw
import NeuralGeneralization.IIDHoeffding

/-! # Hoeffding MGF for the actual IID sparse-atom average -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators ENNReal NNReal
namespace NeuralGeneralization.SparseAtoms
open BoundedDual CompressionSampling
variable {ι : Type*} [Fintype ι] [DecidableEq ι]
variable [MeasurableSpace (Atom ι)] [MeasurableSingletonClass (Atom ι)]

/-- Hoeffding's exact exponential penalty for the average of s sparse atoms. -/
theorem average_exp_centered_le {G : ℝ} (hG : 0 < G) (lam z : ι → ℝ)
    (hlam : entryL1 lam ≤ G) (hz : ∀ i, |z i| ≤ 1) {s : ℕ} (hs : 0 < s) :
    (∫ a, Real.exp (pairing (average G s a - lam) z)
      ∂iidSamples (law hG lam hlam) s) ≤ Real.exp (G ^ 2 / (2 * (s : ℝ))) := by
  have hsR : (s : ℝ) ≠ 0 := by exact_mod_cast hs.ne'
  have hsub := iid_bounded_centeredSum_subGaussian (law hG lam hlam) s
    (fun a => pairing (vector G a) z) (measurable_of_finite _)
    hG.le (abs_pairing_vector_le hG.le z hz)
  have h := hsub.mgf_le (1 / (s : ℝ))
  rw [integral_pairing hG lam z hlam] at h
  have hexponent :
      (((s : ℝ≥0) * (Real.toNNReal G) ^ 2 : ℝ≥0) : ℝ) *
        (1 / (s : ℝ)) ^ 2 / 2 = G ^ 2 / (2 * (s : ℝ)) := by
    simp only [NNReal.coe_mul, NNReal.coe_natCast, NNReal.coe_pow, Real.coe_toNNReal G hG.le]
    field_simp [hsR]
  rw [hexponent] at h
  simpa only [mgf, pairing_average_sub G hs, one_div, div_eq_inv_mul, mul_one] using h

end NeuralGeneralization.SparseAtoms

end
