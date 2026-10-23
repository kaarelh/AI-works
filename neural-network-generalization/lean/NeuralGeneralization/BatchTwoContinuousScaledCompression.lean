import NeuralGeneralization.BatchTwoContinuousInputStability

/-! Arbitrary-accuracy real-input compression by rescaling only the readout. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous
open ConcreteModel CompressionSampling

@[simp] theorem output_rescaleReadout {d N r : ℕ} (c : ℝ) (φ : ℝ → ℝ)
    (w : Weights d N r) (x : RealInput d) :
    output φ (rescaleReadout c w) x = c*output φ w x := by
  have hh : finalHidden φ (rescaleReadout c w) x=finalHidden φ w x := rfl
  simp only [output,hh,rescaleReadout,mul_assoc,Finset.mul_sum]

theorem rescaleReadout_cost_le_self {d N r : ℕ} {c : ℝ} (hc : |c| ≤ 1)
    (w : Weights d N r) : weightedSquaredNorm (rescaleReadout c w) ≤ weightedSquaredNorm w := by
  have hc2 : c^2 ≤ 1 := by
    have h := (sq_le_sq₀ (abs_nonneg c) (by norm_num : (0 : ℝ) ≤ 1)).mpr hc
    simpa using h
  have ho : 0 ≤ (N : ℝ)*∑ i, w (Sum.inr (Sum.inr i))^2 := by positivity
  have hm := mul_le_mul_of_nonneg_right hc2 ho
  simp only [weightedSquaredNorm,rescaleReadout,mul_pow,← Finset.mul_sum]
  nlinarith

theorem rescaleReadout_bounded {d N r : ℕ} {c B : ℝ} (hc : |c| ≤ 1)
    (w : Weights d N r) (hw : boundedWeights B w) : boundedWeights B (rescaleReadout c w) := by
  intro a
  rcases a with a | (a | i)
  · exact hw _
  · exact hw _
  · change |c*w (Sum.inr (Sum.inr i))| ≤ B
    rw [abs_mul]
    exact (mul_le_mul_of_nonneg_right hc (abs_nonneg _)).trans (by simpa using hw (Sum.inr (Sum.inr i)))

theorem finite_real_input_compression_scaled {ι : Type*} [Fintype ι] {d N r K R : ℕ}
    (hd : 1 ≤ d) (hN : 0 < N) (hK : 1 ≤ K) (hR : 1 ≤ R)
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (w : Weights d N r) (hw : weightedSquaredNorm w ≤ (K : ℝ))
    (input : ι → RealInput d) (hinput : ∀ x, ∑ j, input x j^2 ≤ 1) :
    let M := compressionWidth (netDimension d ι) r (2*(R^2*K))
    ∃ v : Weights d M r, weightedSquaredNorm v ≤ 4*((R^2*K : ℕ) : ℝ) ∧
      boundedWeights M v ∧ ∀ x, |output φ v (input x)-output φ w (input x)| ≤ 1/(12*(R : ℝ)) := by
  let Q := R^2*K
  have hRR : 1 ≤ (R : ℝ) := by exact_mod_cast hR
  have hRp : 0 < (R : ℝ) := by linarith
  have hQ : 1 ≤ Q := Nat.mul_pos (pow_pos (by omega : 0 < R) _) (by omega)
  have he : weightedSquaredNorm (rescaleReadout (R : ℝ) w) ≤ (Q : ℝ) := by
    apply (rescaleReadout_cost_le hRR w).trans
    simpa [Q] using mul_le_mul_of_nonneg_left hw (sq_nonneg (R : ℝ))
  obtain ⟨v,hv,hb,he⟩ := finite_real_input_compression hd hN hQ φ hφ
    (rescaleReadout (R : ℝ) w) he input hinput
  have hinv : |(R : ℝ)⁻¹| ≤ 1 := by rw [abs_of_pos (inv_pos.mpr hRp)]; exact inv_le_one_of_one_le₀ hRR
  refine ⟨rescaleReadout (R : ℝ)⁻¹ v,(rescaleReadout_cost_le_self hinv v).trans hv,
    rescaleReadout_bounded hinv v hb,?_⟩
  intro x
  have h := mul_le_mul_of_nonneg_left (he x) (inv_nonneg.mpr hRp.le)
  rw [output_rescaleReadout] at h
  rw [output_rescaleReadout]
  have hid : (R : ℝ)⁻¹*output φ v (input x)-output φ w (input x)=
      (R : ℝ)⁻¹*(output φ v (input x)-(R : ℝ)*output φ w (input x)) := by field_simp
  rw [hid,abs_mul,abs_of_pos (inv_pos.mpr hRp)]
  calc
    _ ≤ (R : ℝ)⁻¹*(1/12) := h
    _ = _ := by field_simp

end NeuralGeneralization.BatchTwoContinuous
