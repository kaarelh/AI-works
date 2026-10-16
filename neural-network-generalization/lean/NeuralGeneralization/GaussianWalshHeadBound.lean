import NeuralGeneralization.GaussianParityConfidence

/-! The Gaussian posterior head norm follows from the explicit sample
coercivity event and the actual Fourier-tail sample Gram bound. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.GaussianWalshHeadBound
open GaussianSignCone GaussianPosteriorFeatures GaussianWalshMeanTail
variable {d : ℕ} {J : Type*} [Fintype J]

theorem signed_negativePart_sq_le_residual (f m p : ℝ) (hf : f = 1 ∨ f = -1)
    (hfm : 0 ≤ f * m) : (max 0 (-(f * p))) ^ 2 ≤ (m - p) ^ 2 := by
  have hh : max 0 (-(f * p)) ≤ |m-p| := by
    apply max_le (abs_nonneg _)
    rcases hf with hf | hf <;> rw [hf] at hfm ⊢ <;>
      nlinarith [le_abs_self (m-p), neg_le_abs (m-p)]
  simpa only [sq_abs] using pow_le_pow_left₀ (le_max_left _ _) hh 2

theorem mean_square_mask_le (a : Finset (Fin d) → ℝ) (H : Finset (Finset (Fin d))) :
    uniformCubeMean (fun x => walshExpansion (maskCoefficients H a) x ^ 2) ≤
      uniformCubeMean (fun x => walshExpansion a x ^ 2) := by
  classical
  rw [uniformCubeMean_walshExpansion_sq, uniformCubeMean_walshExpansion_sq]
  apply Finset.sum_le_sum
  intro S hS
  by_cases h : S ∈ H <;> simp [maskCoefficients, h, sq_nonneg]

theorem mean_square_decomposition (a : Finset (Fin d) → ℝ) (H : Finset (Finset (Fin d))) :
    uniformCubeMean (fun x => walshExpansion a x ^ 2) =
      uniformCubeMean (fun x => walshExpansion (maskCoefficients H a) x ^ 2) +
      uniformCubeMean (fun x => walshExpansion (maskCoefficients (Finset.univ \ H) a) x ^ 2) := by
  classical
  simp only [uniformCubeMean_walshExpansion_sq]
  rw [← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro S hS
  by_cases h : S ∈ H <;> simp [maskCoefficients, h]

/-- Actual conditional-mean low-frequency norm bound. The two sampling
hypotheses are explicit deterministic inequalities on the sampled inputs. -/
theorem posterior_low_mean_square_le [Nonempty J]
    (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 < w S) (s : J → ClippingCube d)
    (hprob : (Measure.pi (fun _ : Finset (Fin d) => gaussianReal 0 1))
      (signCone (trainingMatrix (fun S x => walshCharacter S x) w s (fun j => fullParity (s j)))) ≠ 0)
    (H : Finset (Finset (Fin d)))
    (hcoercivity : ∀ c : Finset (Fin d) → ℝ, (∀ S, c S ≠ 0 → S ∈ H) →
      (1 / 4 : ℝ) * uniformCubeMean (fun x => walshExpansion c x ^ 2) ≤
        (∑ j, (max 0 (-(fullParity (s j) * walshExpansion c (s j)))) ^ 2) / Fintype.card J)
    (G : ℝ) (hG : 0 ≤ G)
    (hGram : ∀ b : J → ℝ,
      finiteQuadratic (fun i j => walshTailKernel (Finset.univ \ H) w (s i) (s j)) b ≤
        G * ∑ i, b i ^ 2) :
    uniformCubeMean (fun x => walshExpansion (maskCoefficients H
      (posteriorCoefficients (trainingMatrix (fun S x => walshCharacter S x) w s
        (fun j => fullParity (s j))) w)) x ^ 2) ≤ 4 * G := by
  classical
  let A := trainingMatrix (fun S x => walshCharacter S x) w s (fun j => fullParity (s j))
  let a := posteriorCoefficients A w
  let p := walshExpansion (maskCoefficients H a)
  let m := walshExpansion a
  let t := walshExpansion (maskCoefficients (Finset.univ \ H) a)
  have hsupport : ∀ S, maskCoefficients H a S ≠ 0 → S ∈ H := by
    intro S hS
    by_contra h
    exact hS (by simp [maskCoefficients, h])
  have hcoer := hcoercivity (maskCoefficients H a) hsupport
  have hm (j : J) : 0 < fullParity (s j) * m (s j) :=
    signed_training_mean_pos (fun S x => walshCharacter S x) w s (fun j => fullParity (s j)) hprob j
  have ht (x : ClippingCube d) : m x - p x = t x := by
    have h := featureField_decomposition (fun S x => walshCharacter S x) a H x
    change m x = p x + t x at h
    linarith
  have hwrong : (∑ j, (max 0 (-(fullParity (s j) * p (s j)))) ^ 2) ≤ ∑ j, t (s j) ^ 2 := by
    apply Finset.sum_le_sum
    intro j hj
    rw [← ht]
    exact signed_negativePart_sq_le_residual _ _ _ (fullParity_sign _) (hm j).le
  have hsample := walsh_tail_sample_square_le w a hw (Finset.univ \ H) s G hG hGram
  have hE := posterior_feature_energy_le_sample_count w (fun S => (hw S).le) A hprob
  have htail : (∑ j, t (s j) ^ 2) ≤ G * Fintype.card J :=
    hsample.trans (mul_le_mul_of_nonneg_left hE hG)
  have hn : (0 : ℝ) < Fintype.card J := Nat.cast_pos.mpr Fintype.card_pos
  have havg : (∑ j, (max 0 (-(fullParity (s j) * p (s j)))) ^ 2) / Fintype.card J ≤ G :=
    (div_le_iff₀ hn).mpr (by simpa only [mul_comm] using hwrong.trans htail)
  change uniformCubeMean (fun x => p x ^ 2) ≤ 4 * G
  change (1 / 4 : ℝ) * uniformCubeMean (fun x => p x ^ 2) ≤ _ at hcoer
  linarith

/-- Every Fourier projection of the actual posterior mean is controlled by
the first cutoff's sampled Gram bound and population tail eigenvalue. -/
theorem posterior_projected_mean_square_le [Nonempty J]
    (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 < w S) (s : J → ClippingCube d)
    (hprob : (Measure.pi (fun _ : Finset (Fin d) => gaussianReal 0 1))
      (signCone (trainingMatrix (fun S x => walshCharacter S x) w s (fun j => fullParity (s j)))) ≠ 0)
    (H U : Finset (Finset (Fin d)))
    (hcoercivity : ∀ c : Finset (Fin d) → ℝ, (∀ S, c S ≠ 0 → S ∈ H) →
      (1 / 4 : ℝ) * uniformCubeMean (fun x => walshExpansion c x ^ 2) ≤
        (∑ j, (max 0 (-(fullParity (s j) * walshExpansion c (s j)))) ^ 2) / Fintype.card J)
    (G ell : ℝ) (hG : 0 ≤ G) (hell : 0 ≤ ell)
    (hmax : ∀ S ∈ Finset.univ \ H, w S ≤ ell)
    (hGram : ∀ b : J → ℝ,
      finiteQuadratic (fun i j => walshTailKernel (Finset.univ \ H) w (s i) (s j)) b ≤
        G * ∑ i, b i ^ 2) :
    uniformCubeMean (fun x => walshExpansion (maskCoefficients U
      (posteriorCoefficients (trainingMatrix (fun S x => walshCharacter S x) w s
        (fun j => fullParity (s j))) w)) x ^ 2) ≤ 4 * G + Fintype.card J * ell := by
  let A := trainingMatrix (fun S x => walshCharacter S x) w s (fun j => fullParity (s j))
  let a := posteriorCoefficients A w
  apply (mean_square_mask_le a U).trans
  rw [mean_square_decomposition a H]
  exact add_le_add (posterior_low_mean_square_le w hw s hprob H hcoercivity G hG hGram)
    (posterior_tail_mean_square_le w hw A hprob (Finset.univ \ H) ell hell hmax)

end NeuralGeneralization.GaussianWalshHeadBound
