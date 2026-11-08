import NeuralGeneralization.OnlineLowerTanhResidualPeak
import NeuralGeneralization.OnlineLowerTanhPeriodicTail

/-! # The exact periodic series obtained by summing the lattice saddles -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh

lemma residual_peak_phase {A : ℝ} (hA : A ≠ 0) (n l : ℕ) (B θ : ℝ) :
    (-1:ℝ)^(n*l)*Real.sin (B*residualPeak A l+(n:ℝ)*Real.pi/2+θ) =
      (-1:ℝ)^(n/2)*Real.sin (residualPeak A l*(B+(n%2:ℕ)*A)+θ) := by
  have hn : n%2 = 0 ∨ n%2 = 1 := by omega
  rcases hn with hn | hn
  · have hneven : n = 2*(n/2) := by omega
    have hpow : (-1:ℝ)^(n*l) = 1 := by
      rw [hneven,pow_mul,pow_mul]
      norm_num
    have he : B*residualPeak A l+(n:ℝ)*Real.pi/2+θ =
        (B*residualPeak A l+θ)+(n/2:ℕ)*Real.pi := by
      have hnreal : (n:ℝ)=2*(n/2:ℕ) := by exact_mod_cast hneven
      rw [hnreal]
      ring
    rw [hpow,one_mul,he,Real.sin_add_nat_mul_pi,hn]
    simp only [Nat.cast_zero,zero_mul,add_zero]
    congr 2
    ring
  · have hnodd : n = 2*(n/2)+1 := by omega
    have hpow : (-1:ℝ)^(n*l) = (-1:ℝ)^l := by
      rw [hnodd,add_mul,pow_add,pow_mul,pow_mul]
      norm_num
    have he : B*residualPeak A l+(n:ℝ)*Real.pi/2+θ =
        (B*residualPeak A l+θ+Real.pi/2)+(n/2:ℕ)*Real.pi := by
      have hnreal : (n:ℝ)=2*(n/2:ℕ)+1 := by exact_mod_cast hnodd
      rw [hnreal]
      ring
    have hphase : residualPeak A l*(B+(n%2:ℕ)*A)+θ =
        (B*residualPeak A l+θ+Real.pi/2)+(l:ℝ)*Real.pi := by
      rw [hn]
      norm_num only [Nat.cast_one,one_mul]
      unfold residualPeak
      have hw := periodicFrequency_mul_gain hA
      nlinarith
    rw [hpow,he,hphase,Real.sin_add_nat_mul_pi,Real.sin_add_nat_mul_pi]
    ring

def residualPhaseSign {n : ℕ} (q : Fin n → ℕ) : ℝ :=
  (-1:ℝ)^((∑ i, (q i-1)/2)+n/2)

lemma residualPhaseSign_abs {n : ℕ} (q : Fin n → ℕ) : |residualPhaseSign q| = 1 := by
  simp [residualPhaseSign]

lemma residual_peak_signed_phase {n : ℕ} {A : ℝ} (hA : A ≠ 0)
    (q : Fin n → ℕ) (l : ℕ) (B θ : ℝ) :
    (-1:ℝ)^((∑ i, (q i-1)/2)+n*l)*Real.sin (B*residualPeak A l+(n:ℝ)*Real.pi/2+θ) =
      residualPhaseSign q*Real.sin (residualPeak A l*(B+(n%2:ℕ)*A)+θ) := by
  rw [pow_add,mul_assoc,residual_peak_phase hA]
  unfold residualPhaseSign
  rw [pow_add]
  ring

lemma residual_peak_coefficient {A : ℝ} (hA : A ≠ 0) (E : ℝ) (l : ℕ) :
    Real.exp (-E*(residualPeak A l)^2/2)/Real.sinh (Real.pi*residualPeak A l/2) =
      (A/Real.pi)*smoothedCoefficient A E l := by
  have he : Real.pi*residualPeak A l/2 = (2*(l:ℝ)+1)*periodicDecay A := by
    unfold residualPeak periodicFrequency periodicDecay
    field_simp
    <;> norm_num
  unfold smoothedCoefficient periodicCoefficient
  rw [he]
  unfold residualPeak
  field_simp
  <;> norm_num

/-- The infinite signed Gaussian saddle sum is exactly the periodic
response with Gaussian Fourier damping. -/
theorem residual_peak_series {n : ℕ} {A : ℝ} (hA : A ≠ 0)
    (q : Fin n → ℕ) (E B : ℝ) :
    (∑' l : ℕ, (-1:ℝ)^((∑ i, (q i-1)/2)+n*l)*
      (Real.exp (-E*(residualPeak A l)^2/2)/Real.sinh (Real.pi*residualPeak A l/2))*
      Real.sin (B*residualPeak A l+(n:ℝ)*Real.pi/2)) =
      (A/Real.pi)*residualPhaseSign q*smoothedResponse A E (B+(n%2:ℕ)*A) := by
  have he (l : ℕ) : (-1:ℝ)^((∑ i, (q i-1)/2)+n*l)*
      (Real.exp (-E*(residualPeak A l)^2/2)/Real.sinh (Real.pi*residualPeak A l/2))*
      Real.sin (B*residualPeak A l+(n:ℝ)*Real.pi/2) =
      ((A/Real.pi)*residualPhaseSign q)*
        (smoothedCoefficient A E l*Real.sin ((2*(l:ℝ)+1)*periodicFrequency A*(B+(n%2:ℕ)*A))) := by
    rw [residual_peak_coefficient hA]
    have hh := residual_peak_signed_phase hA q l B 0
    simp only [add_zero] at hh
    unfold residualPeak at hh ⊢
    linear_combination (A/Real.pi)*smoothedCoefficient A E l*hh
  simp_rw [he]
  rw [tsum_mul_left]
  rfl

end NeuralGeneralization.OnlineLowerTanh
