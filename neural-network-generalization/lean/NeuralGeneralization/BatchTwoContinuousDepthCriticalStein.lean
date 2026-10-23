import NeuralGeneralization.BatchTwoContinuousDepthCriticalSeedMean
import NeuralGeneralization.BatchTwoContinuousDepthCriticalScalar
import NeuralGeneralization.FiniteDifferential

/-! The exact projected-feature identity for an actual finite Gaussian row. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
open GaussianProductStein TanhDifferential FiniteDifferential
variable {I:Type*} [Fintype I] [DecidableEq I]

theorem gaussian_coordinate_tanh (c:I→ℝ) (m:ℝ) (i:I) :
    (∫z:I→ℝ,z i*Real.tanh (m+∑j,c j*z j) ∂(Measure.pi fun _ : I=>gaussianReal 0 1))=
      c i*∫z:I→ℝ,tanhFirst (m+∑j,c j*z j) ∂(Measure.pi fun _ : I=>gaussianReal 0 1) := by
  have hi : Integrable (fun z:I→ℝ=>tanhFirst (m+∑j,c j*z j))
      (Measure.pi fun _ : I=>gaussianReal 0 1) := by
    apply integrable_of_bounded (fun _ : I=>(1:NNReal)) _ (by fun_prop) 1
    intro z
    exact abs_tanhFirst_le_one _
  have hd (z:I→ℝ) : HasDerivAt (fun t=>Real.tanh (m+∑j,c j*Function.update z i t j))
      (c i*tanhFirst (m+∑j,c j*z j)) (z i) := by
    have hfield := hasDerivAt_field_update (fun _ : Unit=>c) z i (z i)
    have hs := (hasDerivAt_pi.mp hfield) ()
    have hs' : HasDerivAt (fun t=>m+∑j,c j*Function.update z i t j) (c i) (z i) := by
      simpa only [fieldLinear_apply] using hs.const_add m
    have ht := (hasDerivAt_tanh_first (m+∑j,c j*Function.update z i (z i) j)).comp (z i) hs'
    simpa only [Function.comp_def,Function.update_eq_self,mul_comm] using ht
  have hs := gaussian_integral_coord_mul_eq_integral_partial_standard i
    (fun z:I→ℝ=>Real.tanh (m+∑j,c j*z j))
    (fun z:I→ℝ=>c i*tanhFirst (m+∑j,c j*z j)) (by fun_prop) (by fun_prop) hd
    1 |c i| (fun _ => (Real.abs_tanh_lt_one _).le) (fun z=>by
      rw [abs_mul]
      exact (mul_le_mul_of_nonneg_left (abs_tanhFirst_le_one _) (abs_nonneg _)).trans_eq (mul_one _))
  rw [integral_const_mul] at hs
  exact hs

theorem gaussian_projected_tanh (c t:I→ℝ) (m:ℝ) :
    (∫z:I→ℝ,(∑i,t i*z i)*Real.tanh (m+∑j,c j*z j) ∂(Measure.pi fun _ : I=>gaussianReal 0 1))=
      (∑i,t i*c i)*(∫z:I→ℝ,tanhFirst (m+∑j,c j*z j) ∂(Measure.pi fun _ : I=>gaussianReal 0 1)) := by
  have hi (i:I) : Integrable (fun z:I→ℝ=>t i*(z i*Real.tanh (m+∑j,c j*z j)))
      (Measure.pi fun _ : I=>gaussianReal 0 1) := by
    apply Integrable.const_mul
    apply integrable_coord_mul_of_bounded (fun _ : I=>(1:NNReal)) i _ (by fun_prop) 1
    intro z
    exact (Real.abs_tanh_lt_one _).le
  have he (z:I→ℝ) : (∑i,t i*z i)*Real.tanh (m+∑j,c j*z j)=
      ∑i,t i*(z i*Real.tanh (m+∑j,c j*z j)) := by rw [Finset.sum_mul];apply Finset.sum_congr rfl;intro i _;ring
  simp_rw [he]
  rw [integral_finsetSum _ (fun i _=>hi i)]
  simp_rw [integral_const_mul,gaussian_coordinate_tanh]
  rw [Finset.sum_mul]
  apply Finset.sum_congr rfl
  intro i _
  ring

end NeuralGeneralization.BatchTwoContinuousDepthCritical
