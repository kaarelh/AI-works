import NeuralGeneralization.RobustCompressionGrid

/-! Exact logarithmic entropy of the actual robust output parameter grid. -/
noncomputable section
namespace NeuralGeneralization.ConcreteModel
open ParameterGrid

def improvedGridLogFactor (d M r B R:ℕ):ℝ :=
  Real.log 3+Real.log B+Real.log R+Real.log ((d:ℝ)+1)+
    ((r:ℝ)+1)*Real.log ((M:ℝ)*((B:ℝ)+1)+1)

def improvedGridEntropy (d M r B R:ℕ):ℝ :=
  (robustParameterCount d M r:ℝ)*improvedGridLogFactor d M r B R

theorem robustOutputMesh_log_sharp (d M r:ℕ) {B R:ℕ} (hB:0<B) (hR:0<R):
    Real.log (2*(robustOutputMesh d M r B R:ℝ)+1)≤ improvedGridLogFactor d M r B R := by
  have hBR:(0:ℝ)<B := Nat.cast_pos.mpr hB
  have hRR:(0:ℝ)<R := Nat.cast_pos.mpr hR
  have hT:=robustOutputMesh_pos d M r hB hR
  have hTR:(0:ℝ)<robustOutputMesh d M r B R := Nat.cast_pos.mpr hT
  have hTone:(1:ℝ)≤robustOutputMesh d M r B R := by exact_mod_cast hT
  have hd:(0:ℝ)<(d:ℝ)+1 := by positivity
  have hb:(0:ℝ)<(M:ℝ)*((B:ℝ)+1)+1 := by positivity
  calc
    _ ≤ Real.log (3*(robustOutputMesh d M r B R:ℝ)) :=
      Real.log_le_log (by positivity) (by linarith)
    _ = improvedGridLogFactor d M r B R := by
      rw [Real.log_mul (by norm_num) hTR.ne']
      unfold robustOutputMesh parameterMesh improvedGridLogFactor
      push_cast
      rw [Real.log_mul (by positivity) (by positivity),Real.log_mul hBR.ne' hRR.ne',
        Real.log_mul hd.ne' (pow_ne_zero _ hb.ne'),Real.log_pow]
      push_cast
      ring

theorem robustOutputCode_log_card_sharp (d M r:ℕ) {B R:ℕ} (hB:0<B) (hR:0<R):
    Real.log (Fintype.card (RobustOutputCode d M r B R):ℝ)≤ improvedGridEntropy d M r B R := by
  rw [robustOutputCode_card]
  push_cast
  rw [Real.log_pow]
  exact mul_le_mul_of_nonneg_left (robustOutputMesh_log_sharp d M r hB hR)
    (Nat.cast_nonneg (robustParameterCount d M r))

theorem improvedGridLogFactor_nonneg (d M r:ℕ) {B R:ℕ} (hB:0<B) (hR:0<R):
    0≤ improvedGridLogFactor d M r B R := by
  have hB1:(1:ℝ)≤B := by exact_mod_cast hB
  have hR1:(1:ℝ)≤R := by exact_mod_cast hR
  have hd:1≤(d:ℝ)+1 := by linarith [Nat.cast_nonneg (α:=ℝ) d]
  have hm:1≤(M:ℝ)*((B:ℝ)+1)+1 := by nlinarith [Nat.cast_nonneg (α:=ℝ) M,Nat.cast_nonneg (α:=ℝ) B]
  unfold improvedGridLogFactor
  exact add_nonneg (add_nonneg (add_nonneg (add_nonneg
    (Real.log_nonneg (by norm_num)) (Real.log_nonneg hB1)) (Real.log_nonneg hR1))
    (Real.log_nonneg hd)) (mul_nonneg (by positivity) (Real.log_nonneg hm))

end NeuralGeneralization.ConcreteModel
