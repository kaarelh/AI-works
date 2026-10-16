import NeuralGeneralization.WalshLaplacian

/-!
# From low-degree energy bounds to actual parity classification error

This is the deterministic closing step of the positive-subcritical argument.
The spectral and sampling estimates supplying its two explicit energy bounds
are separate obligations. The clipping, Fourier and norm comparisons used
here are proved, rather than assumed.
-/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization

def uniformParityError {d : ℕ} (z : ClippingCube d → ℝ) : ℝ :=
  uniformCubeMean (fun x => if binarySign (z x) = fullParity x then 0 else 1)

theorem parity_correlation_error_identity {d : ℕ} (z : ClippingCube d → ℝ) :
    uniformCubeMean (fun x => fullParity x * binarySign (z x)) =
      1 - 2 * uniformParityError z := by
  have hpoint (x : ClippingCube d) : fullParity x * binarySign (z x) =
      1 - 2 * (if binarySign (z x) = fullParity x then (0 : ℝ) else 1) := by
    rcases fullParity_sign x with h | h <;> rw [h] <;>
      unfold binarySign <;> split_ifs <;> norm_num at *
  have hM : (Fintype.card (ClippingCube d) : ℝ) ≠ 0 :=
    ne_of_gt (Nat.cast_pos.mpr Fintype.card_pos)
  simp_rw [hpoint]
  unfold uniformParityError uniformCubeMean
  rw [Finset.sum_sub_distrib, ← Finset.mul_sum]
  simp only [Finset.sum_const, Finset.card_univ, nsmul_eq_mul, mul_one]
  field_simp

theorem cube_margin_parity_mean_bound {d : ℕ} (hd : 0 < d)
    (P z : ClippingCube d → ℝ) (b : ℝ) (hb : 0 < b)
    (hmargin : ∀ x, b ≤ |z x|) :
    |uniformCubeMean (fun x => fullParity x * binarySign (z x))| ≤
      uniformCubeMean (fun x => |cubeLaplacian P x|) / (b * d) +
        uniformCubeMean (fun x => |z x - P x|) / b := by
  have hc : (0 : ℝ) ≤ Fintype.card (ClippingCube d) := Nat.cast_nonneg _
  have h := div_le_div_of_nonneg_right
    (cube_margin_parity_laplacian_bound hd P z b hb hmargin) hc
  simpa only [uniformCubeMean, abs_div, abs_of_nonneg hc,
    add_div, div_div, mul_comm] using h

/-- Exact `3/8` classification-error conclusion from the two estimates used
in the paper. The hypotheses involve actual Fourier coefficients, actual
global margin and actual squared residual under the uniform cube law. -/
theorem parity_error_lower_of_low_degree_approximation {d u : ℕ} (hd : 0 < d)
    (a : Finset (Fin d) → ℝ) (hdegree : ∀ S, a S ≠ 0 → S.card ≤ u)
    (z : ClippingCube d → ℝ) (b : ℝ) (hb : 0 < b)
    (hmargin : ∀ x, b ≤ |z x|)
    (hhead : (u : ℝ) ^ 2 * uniformCubeMean (fun x => walshExpansion a x ^ 2) ≤
      (b * (d : ℝ)) ^ 2 / 64)
    (htail : uniformCubeMean (fun x => (z x - walshExpansion a x) ^ 2) ≤ b ^ 2 / 64) :
    (3 / 8 : ℝ) ≤ uniformParityError z := by
  have hbd : 0 < b * (d : ℝ) := mul_pos hb (Nat.cast_pos.mpr hd)
  have hdeg : uniformCubeMean (fun x => cubeLaplacian (walshExpansion a) x ^ 2) ≤
      (u : ℝ) ^ 2 * uniformCubeMean (fun x => walshExpansion a x ^ 2) := by
    have h := div_le_div_of_nonneg_right (cubeLaplacian_degree_bound a hdegree)
      (Nat.cast_nonneg (Fintype.card (ClippingCube d)) :
        (0 : ℝ) ≤ Fintype.card (ClippingCube d))
    simpa only [uniformCubeMean, mul_div_assoc] using h
  have hL2 := uniformCubeMean_sq_le (fun x => |cubeLaplacian (walshExpansion a) x|)
  simp only [sq_abs] at hL2
  have hLnonneg := uniformCubeMean_nonneg
    (fun x => |cubeLaplacian (walshExpansion a) x|) (fun x => abs_nonneg _)
  have hL : uniformCubeMean (fun x => |cubeLaplacian (walshExpansion a) x|) ≤
      (b * (d : ℝ)) / 8 := by
    have hh := hL2.trans (hdeg.trans hhead)
    nlinarith
  have ht2 := uniformCubeMean_sq_le (fun x => |z x - walshExpansion a x|)
  simp only [sq_abs] at ht2
  have htnonneg := uniformCubeMean_nonneg
    (fun x => |z x - walshExpansion a x|) (fun x => abs_nonneg _)
  have ht : uniformCubeMean (fun x => |z x - walshExpansion a x|) ≤ b / 8 := by
    have hh := ht2.trans htail
    nlinarith
  have hcorr := cube_margin_parity_mean_bound hd (walshExpansion a) z b hb hmargin
  have hLdiv : uniformCubeMean (fun x => |cubeLaplacian (walshExpansion a) x|) /
      (b * (d : ℝ)) ≤ (1 / 8 : ℝ) := by
    apply (div_le_iff₀ hbd).mpr
    nlinarith
  have htdiv : uniformCubeMean (fun x => |z x - walshExpansion a x|) / b ≤ (1 / 8 : ℝ) := by
    apply (div_le_iff₀ hb).mpr
    nlinarith
  have habs : |uniformCubeMean (fun x => fullParity x * binarySign (z x))| ≤ (1 / 4 : ℝ) := by
    linarith
  have hupper := (le_abs_self (uniformCubeMean (fun x => fullParity x * binarySign (z x)))).trans habs
  rw [parity_correlation_error_identity] at hupper
  linarith

end NeuralGeneralization
