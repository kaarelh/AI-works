import NeuralGeneralization.GaussianBandEnergy
import NeuralGeneralization.GaussianWalshHeadBound

/-! # The fixed-margin posterior head from sampled squared coercivity -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.GaussianMarginHeadBound
open GaussianBandEnergy GaussianWalshHeadBound GaussianFieldTilt
variable {d : ℕ} {J : Type*} [Fintype J] [Nonempty J]

def sampleBandEnergy (H : Finset (Finset (Fin d))) (s : J → ClippingCube d)
    (z : ClippingCube d → ℝ) : ℝ := ∑ j, walshProjection H z (s j)^2

lemma projection_residual (H : Finset (Finset (Fin d))) (z : ClippingCube d → ℝ)
    (x : ClippingCube d) : z x-walshProjection H z x = walshProjection (Finset.univ\H) z x := by
  have hh := walshProjection_decomposition H z x
  linarith

/-- This deterministic inequality holds for each training-consistent draw,
with no claim of independence under conditioning. -/
theorem draw_head_le_sample_tail (s : J → ClippingCube d) (H : Finset (Finset (Fin d)))
    (hcoercivity : ∀ c : Finset (Fin d) → ℝ, (∀ S, c S ≠ 0 → S ∈ H) →
      (1/4:ℝ)*uniformCubeMean (fun x => walshExpansion c x^2) ≤
        (∑ j, (max 0 (-(fullParity (s j)*walshExpansion c (s j))))^2)/Fintype.card J)
    (z : ClippingCube d → ℝ) (htrain : ∀ j, 0 ≤ fullParity (s j)*z (s j)) :
    bandEnergy H z ≤ (4/(Fintype.card J:ℝ))*sampleBandEnergy (Finset.univ\H) s z := by
  classical
  let c := maskCoefficients H (walshCoefficients z)
  have hc : ∀ S, c S ≠ 0 → S ∈ H := by
    intro S hS
    by_contra hh
    exact hS (by simp [c, maskCoefficients, hh])
  have hh := hcoercivity c hc
  have he : (∑ j, (max 0 (-(fullParity (s j)*walshExpansion c (s j))))^2) ≤
      sampleBandEnergy (Finset.univ\H) s z := by
    apply Finset.sum_le_sum
    intro j hj
    have hi := signed_negativePart_sq_le_residual (fullParity (s j)) (z (s j))
      (walshProjection H z (s j)) (fullParity_sign _) (htrain j)
    rw [projection_residual] at hi
    exact hi
  have hn : (0:ℝ) < Fintype.card J := Nat.cast_pos.mpr Fintype.card_pos
  have ha := div_le_div_of_nonneg_right he hn.le
  change (1/4:ℝ)*bandEnergy H z ≤ _ at hh
  calc
    bandEnergy H z ≤ 4*(sampleBandEnergy (Finset.univ\H) s z/(Fintype.card J:ℝ)) := by linarith
    _ = _ := by ring

lemma bandEnergy_le_split (H U : Finset (Finset (Fin d))) (z : ClippingCube d → ℝ) :
    bandEnergy U z ≤ bandEnergy H z+bandEnergy (Finset.univ\H) z := by
  have hm := mean_square_mask_le (walshCoefficients z) U
  rw [mean_square_decomposition (walshCoefficients z) H] at hm
  exact hm

/-- Integrating the sampled coercivity estimate under the actual Gaussian
conditioning event yields the head second-moment bound. -/
theorem conditional_headEnergy_le
    (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 ≤ w S)
    (s : J → ClippingCube d) (H : Finset (Finset (Fin d)))
    (hcoercivity : ∀ c : Finset (Fin d) → ℝ, (∀ S, c S ≠ 0 → S ∈ H) →
      (1/4:ℝ)*uniformCubeMean (fun x => walshExpansion c x^2) ≤
        (∑ j, (max 0 (-(fullParity (s j)*walshExpansion c (s j))))^2)/Fintype.card J)
    (E : Set (ClippingCube d → ℝ)) (hE : MeasurableSet E)
    (hEpos : fieldLaw (WalshGaussianEnergy.matrix w) E ≠ 0)
    (htrain : ∀ z ∈ E, ∀ j, 0 ≤ fullParity (s j)*z (s j))
    (hi : Integrable (sampleBandEnergy (Finset.univ\H) s)
      (cond (fieldLaw (WalshGaussianEnergy.matrix w)) E))
    (B : ℝ) (hbound : (∫ z, sampleBandEnergy (Finset.univ\H) s z
      ∂cond (fieldLaw (WalshGaussianEnergy.matrix w)) E) ≤ B) :
    (∫ z, bandEnergy H z ∂cond (fieldLaw (WalshGaussianEnergy.matrix w)) E) ≤
      (4/(Fintype.card J:ℝ))*B := by
  have hh := integral_mono_ae (integrable_bandEnergy_cond w hw H E hE hEpos)
    (hi.const_mul (4/(Fintype.card J:ℝ)))
    (ae_cond_of_forall_mem hE (fun z hz => draw_head_le_sample_tail s H hcoercivity z (htrain z hz)))
  rw [integral_const_mul] at hh
  exact hh.trans (mul_le_mul_of_nonneg_left hbound (by positivity))

end NeuralGeneralization.GaussianMarginHeadBound
