import NeuralGeneralization.BatchTwoContinuousDepthCriticalControlFree

/-! Normalization of the auxiliary Gaussian channel preserves exact RMS norm
and changes the finite-input projected correlations by only the sampling error. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
set_option maxHeartbeats 1000000

/-- A scalar normalization bound with constants independent of width. -/
theorem normalized_scalar_error {u v b ε:ℝ} (hε:0<ε) (hεhalf:ε≤1/2)
    (hu:|u-1|<ε) (hv:|v-b|<ε) (hb:|b|≤1):
    0<u ∧ |v/Real.sqrt u-b|<4*ε:=by
  have hu0:0<u:=by have hh:=abs_lt.mp hu;linarith
  have hs:0<Real.sqrt u:=Real.sqrt_pos.mpr hu0
  have hs2:(Real.sqrt u)^2=u:=Real.sq_sqrt hu0.le
  have hslo:(1:ℝ)/2<Real.sqrt u:=by
    have hh:=abs_lt.mp hu
    nlinarith [Real.sqrt_nonneg u]
  have hsclose:|Real.sqrt u-1|<ε:=by
    have hh:=abs_lt.mp hu
    apply abs_lt.mpr
    constructor <;> nlinarith [sq_nonneg ε]
  have hn:|v-b*Real.sqrt u|<2*ε:=by
    calc
      _=|(v-b)+b*(1-Real.sqrt u)|:=by congr 1;ring
      _≤|v-b|+|b*(1-Real.sqrt u)|:=abs_add_le _ _
      _≤|v-b|+|1-Real.sqrt u|:=by
        rw [abs_mul]
        exact add_le_add_right ((mul_le_mul_of_nonneg_right hb (abs_nonneg _)).trans_eq (one_mul _)) _
      _<2*ε:=by rw [abs_sub_comm 1];linarith
  refine ⟨hu0,?_⟩
  rw [div_sub' hs.ne',abs_div,abs_of_pos hs]
  apply (div_lt_iff₀ hs).mpr
  rw [mul_comm (Real.sqrt u) b]
  nlinarith

variable {I:Type*} [Fintype I] {M:ℕ}

def normalizedRowProjection (t:I→ℝ) (w:Fin M→I→ℝ) (i:Fin M):ℝ:=
  rowLinear t (w i)/Real.sqrt (rowAverage (fun z=>(rowLinear t z)^2) w)

theorem normalizedRowProjection_squared (t:I→ℝ) (w:Fin M→I→ℝ)
    (hpos:0<rowAverage (fun z=>(rowLinear t z)^2) w):
    (∑i,(normalizedRowProjection t w i)^2)/(M:ℝ)=1:=by
  have hm:(M:ℝ)≠0:=by
    intro hh
    simp only [rowAverage,hh,div_zero] at hpos
    linarith
  unfold rowAverage at hpos
  simp only [normalizedRowProjection,div_pow,←Finset.sum_div,rowAverage]
  rw [Real.sq_sqrt hpos.le]
  have hn:(∑i,rowLinear t (w i)^2)≠0:=by
    intro hh
    rw [hh,zero_div] at hpos
    linarith
  field_simp

theorem normalizedRowProjection_pairing (c t:I→ℝ) (w:Fin M→I→ℝ):
    (∑i,normalizedRowProjection t w i*Real.tanh (rowLinear c (w i)))/(M:ℝ)=
      rowAverage (fun z=>rowLinear t z*Real.tanh (rowLinear c z)) w/
        Real.sqrt (rowAverage (fun z=>(rowLinear t z)^2) w):=by
  simp only [normalizedRowProjection,rowAverage,div_mul_eq_mul_div,←Finset.sum_div]
  ring

theorem freeRowEvent_normalized {J:Type*} [Fintype J] (c:J→I→ℝ) (t:I→ℝ)
    {ε:ℝ} (hε:0<ε) (hεhalf:ε≤1/2) (w:Fin M→I→ℝ)
    (hw:w∈freeRowEvent c t ε M)
    (hmean:∀j,|(∑i,t i*c j i)*coolingDerivative (∑i,(c j i)^2)|≤1):
    (∑i,(normalizedRowProjection t w i)^2)/(M:ℝ)=1 ∧
    ∀j,|(∑i,normalizedRowProjection t w i*Real.tanh (rowLinear (c j) (w i)))/(M:ℝ)-
      (∑i,t i*c j i)*coolingDerivative (∑i,(c j i)^2)|<4*ε:=by
  have hpos:0<rowAverage (fun z=>(rowLinear t z)^2) w:=by
    have hh:=abs_lt.mp hw.1
    linarith
  refine ⟨normalizedRowProjection_squared t w hpos,fun j=>?_⟩
  rw [normalizedRowProjection_pairing]
  exact (normalized_scalar_error hε hεhalf hw.1 (hw.2 j).2 (hmean j)).2

end NeuralGeneralization.BatchTwoContinuousDepthCritical
