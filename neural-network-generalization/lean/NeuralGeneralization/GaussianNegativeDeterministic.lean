import NeuralGeneralization.GaussianWalshHeadBound

/-! Full deterministic Gaussian-sign-posterior endpoint for the negative
exponent theorem. Only explicit sampled coercivity, sampled tail Gram, and
spectral cutoff budgets remain; all Gaussian/posterior facts are proved. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.GaussianNegativeDeterministic
open GaussianSignCone GaussianPosteriorFeatures GaussianWalshHeadBound GaussianParityConfidence
variable {d u : ℕ} {J : Type*} [Fintype J] [Nonempty J]

/-- On the paper's two explicit sample events, the actual parity sign
posterior has buffered-confidence failure at least three eighths whenever
the displayed numerical cutoff budgets hold. -/
theorem confidence_failure_lower (hd : 0 < d)
    (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 < w S) (s : J → ClippingCube d)
    (hprob : (Measure.pi (fun _ : Finset (Fin d) => gaussianReal 0 1))
      (signCone (trainingMatrix (fun S x => walshCharacter S x) w s (fun j => fullParity (s j)))) ≠ 0)
    (H U : Finset (Finset (Fin d))) (hdegree : ∀ S ∈ U, S.card ≤ u)
    (hcoercivity : ∀ c : Finset (Fin d) → ℝ, (∀ S, c S ≠ 0 → S ∈ H) →
      (1 / 4 : ℝ) * uniformCubeMean (fun x => walshExpansion c x ^ 2) ≤
        (∑ j, (max 0 (-(fullParity (s j) * walshExpansion c (s j)))) ^ 2) / Fintype.card J)
    (G ellH ellU b : ℝ) (hG : 0 ≤ G) (hellH : 0 ≤ ellH) (hellU : 0 ≤ ellU) (hb : 0 < b)
    (hmaxH : ∀ S ∈ Finset.univ \ H, w S ≤ ellH)
    (hmaxU : ∀ S ∈ Finset.univ \ U, w S ≤ ellU)
    (hGram : ∀ a : J → ℝ,
      finiteQuadratic (fun i j => walshTailKernel (Finset.univ \ H) w (s i) (s j)) a ≤
        G * ∑ i, a i ^ 2)
    (htau : 0 < ∑ S ∈ Finset.univ \ U, w S)
    (hmargin : 2 * b ≤ Real.sqrt (Real.pi * (∑ S ∈ Finset.univ \ U, w S)) *
      (Real.exp (-1) - 7 / 20))
    (hvariance : 2 * Fintype.card J * ellU / (∑ S ∈ Finset.univ \ U, w S) ≤ 1 / 32)
    (htail : Fintype.card J * ellU ≤ b ^ 2 / 32)
    (hhead : (u : ℝ) ^ 2 * (4 * G + Fintype.card J * ellH) ≤
      (b * (d : ℝ)) ^ 2 / 64) :
    (3 : ℝ) / 8 ≤ ConfidenceClipping.failure
      (confidence w (trainingMatrix (fun S x => walshCharacter S x) w s (fun j => fullParity (s j))))
      (13 / 20) := by
  apply failure_lower_of_spectral_budgets hd w hw _ hprob U hdegree ellU b hellU hb
    hmaxU htau hmargin hvariance htail
  exact (mul_le_mul_of_nonneg_left
    (posterior_projected_mean_square_le w hw s hprob H U hcoercivity G ellH hG hellH hmaxH hGram)
    (sq_nonneg (u : ℝ))).trans hhead

end NeuralGeneralization.GaussianNegativeDeterministic
