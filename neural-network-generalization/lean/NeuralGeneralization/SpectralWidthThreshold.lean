import NeuralGeneralization.MatrixEntropyAsymptotics
import NeuralGeneralization.SpectralTruncation

/-! # Polynomial width sufficient for the actual truncation error -/

noncomputable section
namespace NeuralGeneralization

theorem matrixTruncationScale_le_inverse {N : ℕ} (hN : 0 < N)
    (γ D : ℝ) (hγ : 1 < γ) (hD : 1 ≤ D) (m : ℕ)
    (hm : 2 ≤ (m : ℝ) * ((γ - 1) / 2))
    (hwidth : D ^ m ≤ (N : ℝ)) :
    matrixTruncationScale N γ ≤ D⁻¹ := by
  have hD0 : 0 < D := by linarith
  have hδ : 0 ≤ (γ - 1) / 2 := by linarith
  have hpow : D ^ 2 ≤ (N : ℝ) ^ ((γ - 1) / 2) := by
    calc
      _ = D ^ (2 : ℝ) := (Real.rpow_natCast D 2).symm
      _ ≤ D ^ ((m : ℝ) * ((γ - 1) / 2)) :=
        Real.rpow_le_rpow_of_exponent_le hD hm
      _ = (D ^ m) ^ ((γ - 1) / 2) := by
        rw [Real.rpow_mul hD0.le, Real.rpow_natCast]
      _ ≤ _ := Real.rpow_le_rpow (pow_nonneg hD0.le _) hwidth hδ
  have hsqrt : D ≤ Real.sqrt ((N : ℝ) ^ ((γ - 1) / 2)) := by
    simpa only [Real.sqrt_sq_eq_abs, abs_of_pos hD0] using Real.sqrt_le_sqrt hpow
  exact inv_anti₀ hD0 hsqrt

namespace ConcreteModel

def spectralInverseRadius (r K : ℕ) : ℕ := 12 * (K * (2 * K + 3) ^ r + 1)

theorem spectralInverseRadius_pos (r K : ℕ) : 0 < spectralInverseRadius r K := by
  unfold spectralInverseRadius
  positivity

theorem spectralTruncationRadius_eq_inverse (r K : ℕ) :
    spectralTruncationRadius r K = (spectralInverseRadius r K : ℝ)⁻¹ := by
  unfold spectralTruncationRadius spectralInverseRadius
  push_cast
  rfl

theorem matrixTruncationScale_le_radius {N : ℕ} (hN : 0 < N)
    (γ : ℝ) (hγ : 1 < γ) (r K m : ℕ)
    (hm : 2 ≤ (m : ℝ) * ((γ - 1) / 2))
    (hwidth : (spectralInverseRadius r K) ^ m ≤ N) :
    matrixTruncationScale N γ ≤ spectralTruncationRadius r K := by
  rw [spectralTruncationRadius_eq_inverse]
  exact matrixTruncationScale_le_inverse hN γ _ hγ
    (by exact_mod_cast spectralInverseRadius_pos r K) m hm (by exact_mod_cast hwidth)

theorem exists_truncation_polynomial_degree (γ : ℝ) (hγ : 1 < γ) :
    ∃ m : ℕ, 2 ≤ (m : ℝ) * ((γ - 1) / 2) := by
  have hδ : 0 < (γ - 1) / 2 := by linarith
  obtain ⟨m, hm⟩ := exists_nat_ge (2 / ((γ - 1) / 2))
  exact ⟨m, (div_le_iff₀ hδ).mp hm⟩

end ConcreteModel
end NeuralGeneralization
