import NeuralGeneralization.ConfidenceClipping
import NeuralGeneralization.GaussianAmplitudePopulation

/-! # Deterministic fixed-margin endpoint closing inequalities

These estimates use the actual random field, its actual posterior sign
probabilities, and explicit polynomial-head, residual and amplitude moments.
No posterior-mean substitution is made.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.GaussianMarginClipping
open ConfidenceClipping
variable {d u : ℕ}

lemma abs_le_small_add_square (z : ℝ) : |z| ≤ 1/16+4*z^2 := by
  nlinarith [sq_nonneg (|z|-1/8), sq_abs z]

lemma abs_symmetricClip_le_one (b t : ℝ) (hb : 0 < b) : |symmetricClip b t| ≤ 1 := by
  rw [symmetricClip_eq_max_min b t hb, abs_le]
  exact ⟨le_max_left _ _, max_le (by norm_num) (min_le_left _ _)⟩

lemma binarySign_clip_error (b t : ℝ) (hb : 0 < b) :
    |binarySign t-symmetricClip b t| ≤ 2*(if |t| ≤ b then (1:ℝ) else 0) := by
  by_cases ht : |t| ≤ b
  · rw [if_pos ht, mul_one]
    have hs : |binarySign t| = 1 := by unfold binarySign; split_ifs <;> norm_num
    exact (abs_sub _ _).trans (by rw [hs]; linarith [abs_symmetricClip_le_one b t hb])
  · rw [if_neg ht, mul_zero, symmetricClip_eq_binarySign b t hb (lt_of_not_ge ht).le]
    simp

lemma mean_binarySign_le_clip_residual (z P : ClippingCube d → ℝ) (b : ℝ) (hb : 0 < b) :
    uniformCubeMean (fun x => fullParity x*binarySign (z x)) ≤
      uniformCubeMean (fun x => fullParity x*symmetricClip b (P x))+
      uniformCubeMean (fun x => |z x-P x|/b)+
      2*uniformCubeMean (fun x => if |z x| ≤ b then (1:ℝ) else 0) := by
  have hpoint (x : ClippingCube d) : fullParity x*binarySign (z x) ≤
      fullParity x*symmetricClip b (P x)+|z x-P x|/b+2*(if |z x| ≤ b then (1:ℝ) else 0) := by
    have h1 := binarySign_clip_error b (z x) hb
    have h2 := symmetricClip_lipschitz b (z x) (P x) hb
    have hp : |fullParity x| = 1 := by rcases fullParity_sign x with h | h <;> rw [h] <;> norm_num
    have hdiff : |fullParity x*(binarySign (z x)-symmetricClip b (P x))| ≤
        2*(if |z x| ≤ b then (1:ℝ) else 0)+|z x-P x|/b := by
      rw [abs_mul, hp, one_mul]
      have htri := abs_sub_le (binarySign (z x)) (symmetricClip b (z x)) (symmetricClip b (P x))
      linarith
    have hl := le_abs_self (fullParity x*(binarySign (z x)-symmetricClip b (P x)))
    nlinarith
  have hh := mean_mono _ _ hpoint
  convert! hh using 1
  unfold uniformCubeMean
  simp only [Finset.sum_add_distrib, ← Finset.mul_sum]
  ring

/-- Pointwise draw-risk bound from a polynomial approximation. This is
purely deterministic and remains valid when the field has zeros. -/
theorem draw_risk_lower (hd : 0 < d) (c : Finset (Fin d) → ℝ)
    (hdegree : ∀ S, c S ≠ 0 → S.card ≤ u)
    (z : ClippingCube d → ℝ) (b : ℝ) (hb : 0 < b) :
    (1-(1/8+4*((u:ℝ)^2/((b*(d:ℝ))^2))*uniformCubeMean (fun x => walshExpansion c x^2)+
      (4/b^2)*uniformCubeMean (fun x => (z x-walshExpansion c x)^2)+
      2*uniformCubeMean (fun x => if |z x| ≤ b then (1:ℝ) else 0)))/2 ≤
      uniformCubeMean (fun x => if 0 < fullParity x*z x then (0:ℝ) else 1) := by
  let P := walshExpansion c
  let C := uniformCubeMean (fun x => fullParity x*symmetricClip b (P x))
  have hclip := cube_clipped_parity_degree_bound_squared hd c hdegree b hb
  have hbd : 0 < (b*(d:ℝ))^2 := by positivity
  have hc2 : C^2 ≤ ((u:ℝ)^2/((b*(d:ℝ))^2))*uniformCubeMean (fun x => P x^2) := by
    rw [div_mul_eq_mul_div]
    apply (le_div_iff₀ hbd).mpr
    simpa only [C, P, mul_comm] using hclip
  have hc : C ≤ 1/16+4*((u:ℝ)^2/((b*(d:ℝ))^2))*uniformCubeMean (fun x => P x^2) := by
    have hh := abs_le_small_add_square C
    have ha := le_abs_self C
    nlinarith
  have hr : uniformCubeMean (fun x => |z x-P x|/b) ≤
      1/16+(4/b^2)*uniformCubeMean (fun x => (z x-P x)^2) := by
    have hh := mean_mono (fun x => |z x-P x|/b)
      (fun x => 1/16+(4/b^2)*(z x-P x)^2) (fun x => by
        have h := abs_le_small_add_square ((z x-P x)/b)
        rw [abs_div, abs_of_pos hb, div_pow] at h
        convert! h using 1 <;> ring)
    convert! hh using 1
    unfold uniformCubeMean
    simp only [Finset.sum_add_distrib, ← Finset.mul_sum, Finset.sum_const,
      Finset.card_univ, nsmul_eq_mul]
    field_simp
  have hsign := mean_binarySign_le_clip_residual z P b hb
  have herr (x : ClippingCube d) :
      1-2*(if 0 < fullParity x*z x then (0:ℝ) else 1) ≤ fullParity x*binarySign (z x) := by
    rcases fullParity_sign x with hf | hf <;> rw [hf] <;>
      unfold binarySign <;> split_ifs <;> simp_all <;> linarith
  have hm := mean_mono _ _ herr
  have heq : uniformCubeMean (fun x => 1-2*(if 0 < fullParity x*z x then (0:ℝ) else 1)) =
      1-2*uniformCubeMean (fun x => if 0 < fullParity x*z x then (0:ℝ) else 1) := by
    unfold uniformCubeMean
    simp only [Finset.sum_sub_distrib, ← Finset.mul_sum, Finset.sum_const,
      Finset.card_univ, nsmul_eq_mul, mul_one]
    field_simp
  rw [heq] at hm
  change uniformCubeMean (fun x => fullParity x*binarySign (z x)) ≤ C+_+_ at hsign
  dsimp only [P] at hc hr hsign
  linarith

end NeuralGeneralization.GaussianMarginClipping
