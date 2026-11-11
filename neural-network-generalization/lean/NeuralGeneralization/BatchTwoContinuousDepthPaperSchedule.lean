import NeuralGeneralization.BatchTwoContinuousDepthTentRadii
import NeuralGeneralization.BatchTwoContinuousDepthPaperCeiling

/-! The exact choice of q and its conversion to the manuscript's K_n(L). -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
namespace NeuralGeneralization.BatchTwoContinuousDepthPaper

def paperChannelQ (k : ℕ) (T : ℝ) : ℝ := (T/2)^(1/(2*((k : ℝ)+2)))

theorem paperChannelQ_ge_one (k : ℕ) {T : ℝ} (hT : 2 ≤ T) :
    1 ≤ paperChannelQ k T := by
  apply Real.one_le_rpow (by linarith : 1 ≤ T/2)
  positivity

theorem paperChannelQ_square_power (k : ℕ) {T : ℝ} (hT : 2 ≤ T) :
    ((paperChannelQ k T)^(k+2))^2=T/2 := by
  have hb : 0 ≤ T/2 := by linarith
  unfold paperChannelQ
  rw [← pow_mul,← Real.rpow_natCast,← Real.rpow_mul hb]
  have he : (1/(2*((k : ℝ)+2)))*(((k+2)*2 : ℕ) : ℝ)=1 := by
    push_cast
    field_simp
  rw [he,Real.rpow_one]

theorem paperChannelQ_readout (k : ℕ) {T : ℝ} (hT : 2 ≤ T) :
    channelReadoutBudget k (paperChannelQ k T)=2*T := by
  unfold channelReadoutBudget
  rw [paperChannelQ_square_power k hT]
  ring

theorem paperChannelQ_square (k : ℕ) {T : ℝ} (hT : 2 ≤ T) :
    (paperChannelQ k T)^2 = (T/2)^(1/((k : ℝ)+2)) := by
  unfold paperChannelQ
  rw [← Real.rpow_natCast,← Real.rpow_mul (by linarith : 0 ≤ T/2)]
  congr 1
  norm_num
  field_simp

theorem paperChannelQ_energy (k : ℕ) {T : ℝ} (hT : 2 ≤ T) :
    2+((k : ℝ)+17)*(paperChannelQ k T)^2 ≤ energyBudget (k+3) T := by
  rw [paperChannelQ_square k hT]
  have hp : (T/2)^(1/((k : ℝ)+2)) ≤ T^(1/((k : ℝ)+2)) :=
    Real.rpow_le_rpow (by linarith) (by linarith) (by positivity)
  unfold energyBudget
  norm_num only [Nat.cast_add,Nat.cast_ofNat]
  have he : (k : ℝ)+3-1=(k : ℝ)+2 := by ring
  rw [he]
  have h := mul_le_mul_of_nonneg_left hp (show 0 ≤ (k : ℝ)+17 by positivity)
  linarith

end NeuralGeneralization.BatchTwoContinuousDepthPaper
