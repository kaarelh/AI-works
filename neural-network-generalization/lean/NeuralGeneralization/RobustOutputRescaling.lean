import NeuralGeneralization.RobustSpectralCertificate
import NeuralGeneralization.MarginRescaling

/-! The paper's output-rescaling proposition, at the radius recomputed from
the rescaled readout. The finite-domain minimum margin is not assumed attained
at a parameter-energy infimum. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.RobustCertificates
open ConcreteModel CompressionSampling
variable {d N r : ℕ}

def spectralScale (w : Weights d N r) : ℝ :=
  max 1 (Real.sqrt (suffixSquareSum (internalNorm w)/((r:ℝ)+1)))

theorem spectralScale_one_le (w : Weights d N r) : 1 ≤ spectralScale w := le_max_left _ _

theorem spectralScale_bound (w : Weights d N r) :
    suffixSquareSum (internalNorm w) ≤ ((r:ℝ)+1)*(spectralScale w)^2 := by
  have hH : 0 < (r:ℝ)+1 := by positivity
  have hS : 0 ≤ suffixSquareSum (internalNorm w) := by unfold suffixSquareSum; positivity
  have hs := Real.sq_sqrt (div_nonneg hS hH.le)
  have hm := (sq_le_sq₀ (Real.sqrt_nonneg _) (show 0 ≤ spectralScale w by
    have hh := spectralScale_one_le w; linarith)).mpr (le_max_right 1 _)
  rw [hs] at hm
  simpa only [mul_comm] using (div_le_iff₀ hH).mp hm

/-- The raw change at the calibrated radius is bounded independently of the
readout scale, with the exact suffix-product constant in the manuscript. -/
theorem calibrated_spectral_change (hN : 0 < N) (w : Weights d N r)
    {c : ℝ} (hc : 0 ≤ c) (x : Cube d) (η : NetworkDisturbance N r)
    (hη : noiseBudgetSq η ≤ (robustRadius c w)^2) :
    |noisyNetworkOutput Real.tanh w x η-networkOutput Real.tanh w x| ≤ c*spectralScale w := by
  have hE := readoutEnergy_nonneg w
  have hden : 0 < 1+((r:ℝ)+1)*readoutEnergy w := by positivity
  have hS : 0 ≤ suffixSquareSum (internalNorm w) := by unfold suffixSquareSum; positivity
  have hscale := spectralScale_one_le w
  have hcoeff : 1+readoutEnergy w*suffixSquareSum (internalNorm w) ≤
      (spectralScale w)^2*(1+((r:ℝ)+1)*readoutEnergy w) := by
    have hh := mul_le_mul_of_nonneg_left (spectralScale_bound w) hE
    nlinarith
  have hnoise := spectral_noise_sq hN w x η
  have hb := hnoise.trans (mul_le_mul_of_nonneg_left hη (by positivity))
  have hh := mul_le_mul_of_nonneg_right hcoeff (sq_nonneg (robustRadius c w))
  have he : (spectralScale w)^2*(1+((r:ℝ)+1)*readoutEnergy w)*(robustRadius c w)^2 =
      (c*spectralScale w)^2 := by
    rw [robustRadius, div_pow, Real.sq_sqrt hden.le]
    field_simp
  rw [he] at hh
  apply (sq_le_sq₀ (abs_nonneg _) (by positivity)).mp
  rw [sq_abs]
  exact hb.trans hh

@[simp] theorem internalNorm_rescaleReadout (q : ℝ) (w : Weights d N r) :
    internalNorm (rescaleReadout q w) = internalNorm w := rfl

@[simp] theorem spectralScale_rescaleReadout (q : ℝ) (w : Weights d N r) :
    spectralScale (rescaleReadout q w) = spectralScale w := rfl

@[simp] theorem readoutEnergy_rescale (q : ℝ) (w : Weights d N r) :
    readoutEnergy (rescaleReadout q w) = q^2*readoutEnergy w := by
  simp [readoutEnergy, rescaleReadout, mul_pow, ← Finset.mul_sum]
  ring

theorem clippedScore_eq_of_margin_buffer {z z' B : ℝ} (hB : 0 ≤ B)
    (hz : 1/2+B < |z|) (he : |z'-z| ≤ B) : clippedScore z' = clippedScore z := by
  have he' := abs_le.mp he
  by_cases hp : 0 ≤ z
  · rw [abs_of_nonneg hp] at hz
    have hz0 : (1:ℝ)/2 ≤ z := by linarith
    have hz1 : (1:ℝ)/2 ≤ z' := by linarith
    simp only [clippedScore, min_eq_left hz0, min_eq_left hz1]
  · rw [abs_of_neg (lt_of_not_ge hp)] at hz
    have hz0 : z ≤ -((1:ℝ)/2) := by linarith
    have hz1 : z' ≤ -((1:ℝ)/2) := by linarith
    have hz2 : z ≤ (1:ℝ)/2 := by linarith
    have hz3 : z' ≤ (1:ℝ)/2 := by linarith
    simp only [clippedScore, min_eq_right hz2, min_eq_right hz3,
      max_eq_left hz0, max_eq_left hz1]

/-- Literal sufficient scale: q a > 1/2 + c max(1,sqrt(S/H)). The score
change is exactly zero, not merely at most the support tolerance. -/
theorem output_rescaling_zero_change (hN : 0 < N) (w : Weights d N r)
    {c a q : ℝ} (hc : 0 ≤ c) (ha : 0 < a)
    (hmargin : ∀ x,a ≤ |networkOutput Real.tanh w x|)
    (hscale : 1/2+c*spectralScale w < q*a) :
    ∀ x η,noiseBudgetSq η ≤ (robustRadius c (rescaleReadout q w))^2 →
      clippedScore (noisyNetworkOutput Real.tanh (rescaleReadout q w) x η) =
        clippedScore (networkOutput Real.tanh (rescaleReadout q w) x) := by
  have hS := spectralScale_one_le w
  have hB : 0 ≤ c*spectralScale w := by positivity
  have hq : 0 ≤ q := by nlinarith
  intro x η hη
  apply clippedScore_eq_of_margin_buffer hB
  · rw [rescaleReadout_output, abs_mul, abs_of_nonneg hq]
    exact hscale.trans_le (mul_le_mul_of_nonneg_left (hmargin x) hq)
  · simpa only [spectralScale_rescaleReadout] using
      calibrated_spectral_change hN (rescaleReadout q w) hc x η hη

theorem output_rescaling_support (hN : 0 < N) (w : Weights d N r)
    {c a q : ℝ} (hc : 0 ≤ c) (ha : 0 < a)
    (hmargin : ∀ x,a ≤ |networkOutput Real.tanh w x|)
    (hscale : 1/2+c*spectralScale w < q*a) :
    rescaleReadout q w ∈ robustEvent Real.tanh c := by
  intro x η hη
  rw [output_rescaling_zero_change hN w hc ha hmargin hscale x η hη, sub_self, abs_zero]
  norm_num

/-- Every strictly signed finite-cube network admits such a rescaling. -/
theorem exists_output_rescaling (hN : 0 < N) (w : Weights d N r)
    {c : ℝ} (hc : 0 ≤ c) (hstrict : ∀ x,0 < |networkOutput Real.tanh w x|) :
    ∃ q : ℝ,0 < q ∧ rescaleReadout q w ∈ robustEvent Real.tanh c := by
  classical
  obtain ⟨x,_,hx⟩ := Finset.exists_min_image Finset.univ
    (fun x : Cube d => |networkOutput Real.tanh w x|) Finset.univ_nonempty
  let a := |networkOutput Real.tanh w x|
  have ha : 0 < a := hstrict x
  let q := (1+c*spectralScale w)/a
  have hS := spectralScale_one_le w
  have hpos : 0 < q := by dsimp [q]; positivity
  refine ⟨q,hpos,output_rescaling_support hN w hc ha (fun y => hx y (Finset.mem_univ _)) ?_⟩
  dsimp [q]
  rw [div_mul_cancel₀ _ ha.ne']
  linarith

end NeuralGeneralization.RobustCertificates
