import NeuralGeneralization.OnlineLowerSoftplusBasic
import NeuralGeneralization.OnlineLowerSoftplusMixtureHinge
import NeuralGeneralization.OnlineLowerCostSigns

noncomputable section
open scoped BigOperators Classical
open MeasureTheory Set
namespace NeuralGeneralization.OnlineLowerSoftplus
open OnlineLowerRelu OnlineLower OnlineLowerGeometry

/-- Fourier coefficients commute with an integrable finite-interval mixture. -/
theorem walsh_interval_integral {d : ℕ} (F : ClippingCube d → ℝ → ℝ)
    (a b : ℝ) (hi : ∀ x, IntervalIntegrable (F x) volume a b)
    (S : Finset (Fin d)) :
    walshCoefficients (fun x => ∫ s in a..b, F x s) S =
      ∫ s in a..b, walshCoefficients (fun x => F x s) S := by
  unfold walshCoefficients uniformCubeMean
  rw [intervalIntegral.integral_div, intervalIntegral.integral_finsetSum
    (fun x _ => (hi x).mul_const (walshCharacter S x))]
  simp_rw [intervalIntegral.integral_mul_const]

/-- On an interval containing all actual affine scores, the constant and
linear terms of the positive hinge representation vanish at degree >=2. -/
theorem softplus_walsh_hinge {d : ℕ} (S : Finset (Fin d)) (hS : 2 ≤ S.card)
    (bias a b : ℝ) (u : Fin d → ℝ)
    (hbounds : ∀ x, a ≤ cubeAffine bias u x ∧ cubeAffine bias u x ≤ b) :
    walshCoefficients (fun x => softplus (cubeAffine bias u x)) S =
      ∫ s in a..b, curvature s *
        walshCoefficients (fun x => max (cubeAffine (bias-s) u x) 0) S := by
  let F : ClippingCube d → ℝ → ℝ :=
    fun x s => max (cubeAffine bias u x-s) 0 * curvature s
  have hi : ∀ x, IntervalIntegrable (F x) volume a b := by
    intro x
    exact (((continuous_const.sub continuous_id).max continuous_const).mul
      continuous_curvature).intervalIntegrable a b
  have hrep (x : ClippingCube d) : softplus (cubeAffine bias u x) =
      softplus a+sigmoid a*(cubeAffine bias u x-a)+(∫ s in a..b,F x s) := by
    have h := hinge_integral_representation softplus sigmoid curvature
      hasDerivAt_softplus hasDerivAt_sigmoid continuous_curvature a b
      (cubeAffine bias u x) (hbounds x).1 (hbounds x).2
    change (∫ s in a..b,F x s)=_ at h
    linarith
  have hzero : walshCoefficients
      (fun x => softplus a+sigmoid a*(cubeAffine bias u x-a)) S = 0 := by
    have hz := sum_walsh_affine_eq_zero S hS
      (softplus a+sigmoid a*(bias-a)) (fun i => sigmoid a*u i)
    have he (x : ClippingCube d) : softplus a+sigmoid a*(cubeAffine bias u x-a) =
        cubeAffine (softplus a+sigmoid a*(bias-a)) (fun i => sigmoid a*u i) x := by
      simp only [cubeAffine]
      simp_rw [mul_assoc (sigmoid a)]
      rw [← Finset.mul_sum]
      ring
    simp_rw [he]
    unfold walshCoefficients uniformCubeMean
    simp_rw [mul_comm (cubeAffine _ _ _)]
    rw [hz,zero_div]
  simp_rw [hrep]
  rw [walshCoefficients_add,hzero,zero_add,walsh_interval_integral F a b hi S]
  apply intervalIntegral.integral_congr
  intro s _
  have he (x : ClippingCube d) : F x s = curvature s*max (cubeAffine (bias-s) u x) 0 := by
    dsimp [F]
    have ha : cubeAffine bias u x-s = cubeAffine (bias-s) u x := by
      simp only [cubeAffine];ring
    rw [ha,mul_comm]
  simp_rw [he]
  exact coefficient_const_mul _ _ _

/-- Standard softplus has the same bias-independent even-support Fourier
potential bound as ReLU. -/
theorem softplus_walsh_abs_le_potential {d r : ℕ} (S : Finset (Fin d))
    (hS : 2 ≤ S.card) (hcard : S.card=2*r) (bias : ℝ) (u : Fin d → ℝ) :
    |walshCoefficients (fun x => softplus (cubeAffine bias u x)) S| ≤
      supportFourierPotential S u := by
  let M : ℝ := ∑ x : ClippingCube d, |cubeAffine bias u x|
  have hM : 0 ≤ M := Finset.sum_nonneg (fun _ _ => abs_nonneg _)
  have hb (x : ClippingCube d) : -M ≤ cubeAffine bias u x ∧ cubeAffine bias u x ≤ M := by
    have hh : |cubeAffine bias u x| ≤ M :=
      Finset.single_le_sum (f:=fun y : ClippingCube d => |cubeAffine bias u y|) (fun _ _ => abs_nonneg _) (Finset.mem_univ x)
    exact abs_le.mp hh
  rw [softplus_walsh_hinge S hS bias (-M) M u hb]
  let C : ℝ → ℝ := fun s => walshCoefficients
    (fun x => max (cubeAffine (bias-s) u x) 0) S
  have hC : Continuous C := by
    unfold C walshCoefficients uniformCubeMean cubeAffine
    fun_prop
  have hcont : Continuous (fun s => curvature s*C s) := continuous_curvature.mul hC
  have hP : 0 ≤ supportFourierPotential S u := supportFourierPotential_nonneg S u
  have hpoint (s : ℝ) : |curvature s*C s| ≤
      curvature s*supportFourierPotential S u := by
    rw [abs_mul,abs_of_nonneg (curvature_nonneg s)]
    exact mul_le_mul_of_nonneg_left (relu_walsh_abs_le_potential S hS hcard (bias-s) u)
      (curvature_nonneg s)
  have hm := intervalIntegral.integral_mono_on (μ:=volume) (show -M ≤ M by linarith)
    (hcont.abs.intervalIntegrable (-M) M)
    ((continuous_curvature.mul continuous_const).intervalIntegrable (-M) M)
    (fun s _ => hpoint s)
  have hmass := curvature_integral_le_one sigmoid curvature hasDerivAt_sigmoid
    continuous_curvature sigmoid_nonneg sigmoid_le_one (-M) M
  have hi := intervalIntegral.abs_integral_le_integral_abs (μ:=volume) (f := fun s => curvature s*C s)
    (show -M ≤ M by linarith)
  simp only [Pi.mul_apply] at hm
  rw [intervalIntegral.integral_mul_const] at hm
  exact hi.trans (hm.trans (by nlinarith))

end NeuralGeneralization.OnlineLowerSoftplus
