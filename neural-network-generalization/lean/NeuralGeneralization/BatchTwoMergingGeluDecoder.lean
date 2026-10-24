import NeuralGeneralization.BatchTwoMergingGeluAnalytic

/-! Exact two-neuron decoding of Boolean ReLU gates by GELU. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory Set
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel

theorem normalPDF_one_gt_sixth : (1:ℝ)/6<normalPDF 1 := by
  have hspos : 0<Real.sqrt (2*Real.pi) := by positivity
  have hssq := Real.sq_sqrt (show 0≤2*Real.pi by positivity)
  have hs : Real.sqrt (2*Real.pi)<3 := by nlinarith [Real.pi_lt_four]
  have hepos := Real.exp_pos ((1:ℝ)/2)
  have he : Real.exp ((1:ℝ)/2)<2 := by
    have heq : Real.exp ((1:ℝ)/2)^2=Real.exp 1 := by
      rw [←Real.exp_nat_mul]
      norm_num
    nlinarith [Real.exp_one_lt_three]
  have hp : Real.sqrt (2*Real.pi)*Real.exp ((1:ℝ)/2)<6 := by nlinarith
  rw [normalPDF_formula]
  norm_num only [one_pow]
  rw [Real.exp_neg,←mul_inv]
  have h := (one_div_lt_one_div_of_lt (by positivity : 0<Real.sqrt (2*Real.pi)*Real.exp ((1:ℝ)/2)) hp)
  simpa only [one_div] using h

theorem normalPDF_ge_one_on_unit {x : ℝ} (hx : x∈Icc (0:ℝ) 1) : normalPDF 1≤normalPDF x := by
  rw [normalPDF_formula,normalPDF_formula]
  apply mul_le_mul_of_nonneg_left _ (by positivity)
  apply Real.exp_le_exp.mpr
  nlinarith [hx.1,hx.2]

theorem normalCDF_one_gt_two_thirds : (2:ℝ)/3<normalCDF 1 := by
  have hi := intervalIntegral.integral_mono_on (by norm_num : (0:ℝ)≤1)
    (intervalIntegrable_const : IntervalIntegrable (fun _:ℝ=>normalPDF 1) volume 0 1)
    (continuous_normalPDF.intervalIntegrable 0 1)
    (fun x hx=>normalPDF_ge_one_on_unit hx)
  simp only [intervalIntegral.integral_const,sub_zero,one_smul] at hi
  have hc := normalCDF_interval 0 1
  rw [normalCDF_zero] at hc
  linarith [normalPDF_one_gt_sixth]

def geluDecodeA : ℝ := normalCDF 1/(2*normalCDF 1-1)
def geluDecodeB : ℝ := (1-normalCDF 1)/(2*normalCDF 1-1)

theorem geluDecode_bounds : 0≤geluDecodeA ∧ geluDecodeA≤2 ∧
    0≤geluDecodeB ∧ geluDecodeB≤1 := by
  have ht := normalCDF_one_gt_two_thirds
  have hu := (normalCDF_bounds 1).2
  have hden : 0<2*normalCDF 1-1 := by linarith
  unfold geluDecodeA geluDecodeB
  refine ⟨div_nonneg (normalCDF_bounds 1).1 hden.le,?_,div_nonneg (by linarith) hden.le,?_⟩
  · apply (div_le_iff₀ hden).mpr; linarith
  · apply (div_le_iff₀ hden).mpr; linarith

theorem geluDecode_identity {u : ℝ} (hu : u=-1 ∨ u=0 ∨ u=1) :
    geluDecodeA*gelu u+geluDecodeB*gelu (-u)=relu u := by
  have hden : 2*normalCDF 1-1≠0 := by linarith [normalCDF_one_gt_two_thirds]
  rcases hu with rfl|rfl|rfl
  · simp only [gelu,neg_neg,normalCDF_neg]
    unfold geluDecodeA geluDecodeB relu
    norm_num
    ring
  · simp [gelu_zero,relu_zero]
  · simp only [gelu,one_mul,normalCDF_neg]
    unfold geluDecodeA geluDecodeB relu
    norm_num
    convert div_self hden using 1 <;> ring

end NeuralGeneralization.BatchTwoMerging
