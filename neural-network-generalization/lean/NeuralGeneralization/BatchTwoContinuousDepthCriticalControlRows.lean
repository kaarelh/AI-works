import NeuralGeneralization.BatchTwoContinuousDepthCriticalControlLLN

/-! The free-layer empirical observables have dimension-independent second
moments, even though the projected Gaussian feature is unbounded. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal ENNReal
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
open RobustCompressionGaussian
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
variable {I:Type*} [Fintype I]

def rowLinear (t:I→ℝ) (z:I→ℝ):ℝ:=∑i,t i*z i

theorem rowLinear_memLp (t:I→ℝ) (p:ℝ≥0∞) (hp:p≠∞):
    MemLp (rowLinear t) p (Measure.pi fun _ : I=>gaussianReal 0 1):=by
  have hi (i:I):MemLp (fun z:I→ℝ=>t i*z i) p (Measure.pi fun _ : I=>gaussianReal 0 1):=by
    simpa only [Function.comp_def,id_eq] using
      ((memLp_id_gaussianReal' p hp).comp_measurePreserving (measurePreserving_eval _ i)).const_mul (t i)
  exact memLp_finsetSum Finset.univ (fun i _=>hi i)

theorem rowLinear_square_integral (t:I→ℝ):
    (∫z:I→ℝ,(rowLinear t z)^2 ∂(Measure.pi fun _ : I=>gaussianReal 0 1))=∑i,t i^2:=by
  have he:=gaussian_row_integral t (fun z:ℝ=>z^2) (by fun_prop)
  simp only [mul_pow] at he
  rw [integral_const_mul,standard_gaussian_square,mul_one,
    Real.sq_sqrt (Finset.sum_nonneg fun i _=>sq_nonneg (t i))] at he
  exact he

theorem rowLinear_fourth_integral_le (t:I→ℝ) (ht:∑i,t i^2=1):
    (∫z:I→ℝ,(rowLinear t z)^4 ∂(Measure.pi fun _ : I=>gaussianReal 0 1))≤64:=by
  have he:=gaussian_row_integral t (fun z:ℝ=>z^4) (by fun_prop)
  rw [ht,Real.sqrt_one] at he
  simp only [one_mul] at he
  exact he.le.trans (gaussian_fourth_moment_le 1 (by norm_num))

theorem rowLinear_square_memLp (t:I→ℝ):
    MemLp (fun z:I→ℝ=>(rowLinear t z)^2) 2 (Measure.pi fun _ : I=>gaussianReal 0 1):=by
  have hi:Integrable (fun z:I→ℝ=>‖rowLinear t z‖^4) (Measure.pi fun _ : I=>gaussianReal 0 1):=
    (rowLinear_memLp t 4 (by norm_num)).integrable_norm_pow (by norm_num)
  apply (memLp_two_iff_integrable_sq ((show Measurable _ by unfold rowLinear; fun_prop).aestronglyMeasurable)).mpr
  convert hi using 1
  ext z
  rw [Real.norm_eq_abs,show ((rowLinear t z)^2)^2=(rowLinear t z)^4 by ring,
    show |rowLinear t z|^4=(|rowLinear t z|^2)^2 by ring,sq_abs]
  ring

theorem tanh_square_memLp (c:I→ℝ):
    MemLp (fun z:I→ℝ=>(Real.tanh (rowLinear c z))^2) 2 (Measure.pi fun _ : I=>gaussianReal 0 1):=by
  apply (memLp_const (1:ℝ)).mono' ((show Measurable _ by unfold rowLinear; fun_prop).aestronglyMeasurable)
  filter_upwards [] with z
  rw [Real.norm_eq_abs,abs_of_nonneg (sq_nonneg _)]
  exact (sq_lt_one_iff_abs_lt_one _).mpr (Real.abs_tanh_lt_one _) |>.le

theorem tanh_square_secondMoment_le (c:I→ℝ):
    (∫z:I→ℝ,((Real.tanh (rowLinear c z))^2)^2 ∂(Measure.pi fun _ : I=>gaussianReal 0 1))≤1:=by
  have hi:Integrable (fun z:I→ℝ=>((Real.tanh (rowLinear c z))^2)^2)
      (Measure.pi fun _ : I=>gaussianReal 0 1):=(tanh_square_memLp c).integrable_sq
  have hh:=integral_mono hi (integrable_const (1:ℝ)) (fun z=>by
    have hs:0≤(Real.tanh (rowLinear c z))^2:=sq_nonneg _
    have hs1:(Real.tanh (rowLinear c z))^2≤1:=
      ((sq_lt_one_iff_abs_lt_one _).mpr (Real.abs_tanh_lt_one _)).le
    nlinarith)
  simpa using hh

theorem rowLinear_mul_tanh_memLp (c t:I→ℝ):
    MemLp (fun z:I→ℝ=>rowLinear t z*Real.tanh (rowLinear c z)) 2
      (Measure.pi fun _ : I=>gaussianReal 0 1):=by
  apply (rowLinear_memLp t 2 (by norm_num)).mono ((show Measurable _ by unfold rowLinear; fun_prop).aestronglyMeasurable)
  filter_upwards [] with z
  simp only [Real.norm_eq_abs,abs_mul]
  exact (mul_le_mul_of_nonneg_left (Real.abs_tanh_lt_one _).le (abs_nonneg _)).trans_eq (mul_one _)

theorem rowLinear_mul_tanh_secondMoment_le (c t:I→ℝ) (ht:∑i,t i^2=1):
    (∫z:I→ℝ,(rowLinear t z*Real.tanh (rowLinear c z))^2
      ∂(Measure.pi fun _ : I=>gaussianReal 0 1))≤1:=by
  have hh:=integral_mono (rowLinear_mul_tanh_memLp c t).integrable_sq
    (rowLinear_memLp t 2 (by norm_num)).integrable_sq (fun z=>by
      rw [mul_pow]
      exact (mul_le_mul_of_nonneg_left
        (((sq_lt_one_iff_abs_lt_one _).mpr (Real.abs_tanh_lt_one _)).le)
        (sq_nonneg _)).trans_eq (mul_one _))
  rwa [rowLinear_square_integral,ht] at hh

end NeuralGeneralization.BatchTwoContinuousDepthCritical
