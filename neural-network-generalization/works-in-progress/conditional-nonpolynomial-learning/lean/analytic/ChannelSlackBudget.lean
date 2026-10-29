import FiniteChannelPolynomialWidth

noncomputable section
namespace ConditionalNonpolynomial.Analytic

def channelSlackProbability (A τ : ℝ) : ℝ := τ/(16*(A+τ+1))

theorem channelSlackProbability_pos {A τ : ℝ} (hA : 0≤A) (hτ : 0<τ) :
    0<channelSlackProbability A τ := by unfold channelSlackProbability; positivity

theorem channelSlackProbability_le_one {A τ : ℝ} (hA : 0≤A) (hτ : 0<τ) :
    channelSlackProbability A τ≤1 := by
  unfold channelSlackProbability
  apply (div_le_iff₀ (by positivity : 0<16*(A+τ+1))).mpr
  linarith

theorem channelSlackProbability_entropy {A τ : ℝ} (hA : 0≤A) (hτ : 0<τ) :
    channelSlackProbability A τ≤τ/(4*(A+τ)) := by
  unfold channelSlackProbability
  apply div_le_div_of_nonneg_left hτ.le (by positivity)
  linarith

theorem channelSlackProbability_readout {A τ : ℝ} (hA : 0≤A) (hτ : 0<τ) :
    3*channelSlackProbability A τ*A≤τ/4 := by
  unfold channelSlackProbability
  have hd : 0<16*(A+τ+1) := by positivity
  apply (mul_le_mul_iff_right₀ hd).mp
  field_simp
  nlinarith

theorem channelSlackProbability_inverse {A τ : ℝ} (hτ : 0<τ) :
    1/channelSlackProbability A τ=16*(A+τ+1)/τ := by
  unfold channelSlackProbability
  field_simp

theorem channelMetricBudget_of_entropy_bound (D : ℕ→ℝ) (H : ℕ) {S v κ : ℝ}
    (hv : 0≤v) (hκ : 0≤κ) (hS : channelEntropyPrefix D H≤S) :
    channelMetricBudget D (channelMomentPrecision H S v κ) H≤κ*Real.sqrt v/8 := by
  apply (channelMetricBudget_bound D (channelMomentPrecision H S v κ) H).trans
  calc
    _ ≤ ((H:ℝ)+1)*8*Real.sqrt (channelMomentPrecision H S v κ)*Real.exp S := by
      gcongr
    _ = _ := channelMomentPrecision_error H S hv hκ

#print axioms channelSlackProbability_readout
#print axioms channelMetricBudget_of_entropy_bound
end ConditionalNonpolynomial.Analytic
