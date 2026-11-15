import NeuralGeneralization.OnlineLowerTanhPeriodicCurvature
import NeuralGeneralization.OnlineLowerTanhNaturalPeaks

/-! # Strict periodic shape throughout the Fourier-dominated gain range -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh

/-- Quantitative positivity of the literal derivative on the central
half-wave. The only gain restriction is `0<a≤2`. -/
theorem periodic_derivative_central_lower {a b:ℝ} (ha:0<a) (ha2:a≤2)
    (hb:b∈Set.Icc (-a) a) :
    periodicCoefficient a 0*periodicFrequency a*Real.cos (periodicFrequency a*b)/100 ≤
      periodicFourierDerivative a b := by
  let w:=periodicFrequency a
  have hw:0<w:=periodicFrequency_pos ha
  have hwa:w*a=Real.pi/2:=periodicFrequency_mul_gain ha.ne'
  have hx:w*b∈Set.Icc (-Real.pi/2) (Real.pi/2):=by
    constructor <;> nlinarith [hb.1,hb.2]
  have hcos:0≤Real.cos (w*b):=Real.cos_nonneg_of_mem_Icc (by simpa only [neg_div] using hx)
  let t:ℕ→ℝ:=fun j=>periodicCoefficient a j*((2*(j:ℝ)+1)*w)*Real.cos ((2*(j:ℝ)+1)*w*b)
  have ht:Summable t:=periodic_derivative_summable ha b
  have hpoint (j:ℕ) :
      -(w*Real.cos (w*b))*(periodicCoefficient a (j+1)*(2*(j:ℝ)+3)^2)≤t (j+1):=by
    have hh:=abs_cos_odd_mul_le (j+1) (w*b) hx
    simp only [Nat.cast_add,Nat.cast_one] at hh
    have hlo:= (abs_le.mp hh).1
    have hm:=mul_le_mul_of_nonneg_left hlo
      (show 0≤periodicCoefficient a (j+1)*((2*((j:ℝ)+1)+1)*w) by positivity [periodicCoefficient_pos ha (j+1)])
    dsimp [t]
    push_cast
    have he:(2*((j:ℝ)+1)+1)*(w*b)=(2*((j:ℝ)+1)+1)*w*b:=by ring
    rw [he] at hm
    convert hm using 1 <;> first | rfl | ring
  have hsum:=Summable.tsum_le_tsum hpoint
    ((periodicSquareTail_summable ha).mul_left (-(w*Real.cos (w*b))))
    (ht.comp_injective Nat.succ_injective)
  rw [(periodicSquareTail_summable ha).tsum_mul_left] at hsum
  have hsplit:=ht.tsum_eq_zero_add
  have hzero:t 0=periodicCoefficient a 0*w*Real.cos (w*b):=by simp [t]
  have htotal:(∑'j,t j)=periodicFourierDerivative a b:=rfl
  rw [hzero,htotal] at hsplit
  have htail:=mul_le_mul_of_nonneg_left (periodicSquareTail_bound ha ha2).2
    (mul_nonneg hw.le hcos)
  change -(w*Real.cos (w*b))*periodicSquareTail a≤_ at hsum
  dsimp [w] at *
  nlinarith [hsplit,hsum,htail]

theorem periodic_derivative_pos_small_gain {a b:ℝ} (ha:0<a) (ha2:a≤2)
    (hb:b∈Set.Ioo (-a) a) : 0<periodicFourierDerivative a b := by
  have hw:=periodicFrequency_pos ha
  have hwa:=periodicFrequency_mul_gain ha.ne'
  have hx:periodicFrequency a*b∈Set.Ioo (-Real.pi/2) (Real.pi/2):=by
    constructor <;> nlinarith [hb.1,hb.2]
  have hcos:=Real.cos_pos_of_mem_Ioo (by simpa only [neg_div] using hx)
  have hbound:=periodic_derivative_central_lower ha ha2 ⟨hb.1.le,hb.2.le⟩
  exact lt_of_lt_of_le (by positivity [periodicCoefficient_pos ha 0]) hbound

theorem periodic_peak_second_neg_small_gain {a:ℝ} (ha:0<a) (ha2:a≤2) :
    periodicFourierDerivative a a=0 ∧ periodicFourierSecond a a<0 := by
  constructor
  · simpa using periodic_derivative_nat_peak ha 0
  · have h:=periodic_restoring_pointwise ha ha2 a
    change periodicFourierSecond a a≤-periodicFrequency a^2*periodicFourierMaximum a+
      (89/100)*periodicFrequency a^2*periodicCoefficient a 0 at h
    have hf:=mul_le_mul_of_nonneg_left (periodicFourierMaximum_lower ha ha2)
      (sq_nonneg (periodicFrequency a))
    have hp:0<periodicFrequency a^2*periodicCoefficient a 0:=
      mul_pos (sq_pos_of_pos (periodicFrequency_pos ha)) (periodicCoefficient_pos ha 0)
    nlinarith

end NeuralGeneralization.OnlineLowerTanh
