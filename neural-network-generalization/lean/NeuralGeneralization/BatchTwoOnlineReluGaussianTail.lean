import NeuralGeneralization.BatchTwoGaussianNormMoments
import NeuralGeneralization.BatchTwoOnlineReluGaussianBox

/-! Exact Gaussian energy tail at the literal online ReLU threshold. -/
noncomputable section
set_option autoImplicit false
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoOnlineReluFinite
variable {ι : Type*} [Fintype ι]

theorem gaussian_energy_tail (v : ℝ≥0) (hv : 0<(v:ℝ)) (T : ℝ) :
    (Measure.pi fun _i:ι=>gaussianReal 0 v).real {x | T≤∑i,(x i)^2} ≤
      Real.exp ((Fintype.card ι:ℝ)/2*Real.log 2-T/(4*(v:ℝ))) := by
  let s : ℝ := 1/(4*(v:ℝ))
  have hs : 0≤s := by dsimp [s]; positivity
  have he : 1-2*s*(v:ℝ)=1/2 := by dsimp [s]; field_simp; ring
  have hh := measure_ge_le_exp_mul_mgf T hs
    (GaussianNormMoments.gaussian_norm_square_mgf_integrable (ι:=ι) v s (by rw [he]; norm_num))
  change _ ≤ Real.exp (-s*T)*(∫x:ι→ℝ,Real.exp (s*∑i,(x i)^2) ∂(Measure.pi fun _=>gaussianReal 0 v)) at hh
  rw [GaussianNormMoments.gaussian_norm_square_mgf v s (by rw [he]; norm_num),he] at hh
  have hpow : (Real.sqrt (1/2))⁻¹^(Fintype.card ι)=
      Real.exp ((Fintype.card ι:ℝ)/2*Real.log 2) := by
    apply Real.log_injOn_pos (show (0:ℝ)<(Real.sqrt (1/2))⁻¹^(Fintype.card ι) by positivity) (Real.exp_pos _)
    rw [Real.log_pow,Real.log_inv,Real.log_sqrt (by norm_num),Real.log_exp]
    rw [Real.log_div (by norm_num) (by norm_num),Real.log_one]
    ring
  rw [hpow,← Real.exp_add] at hh
  convert hh using 1 <;> dsimp [s] <;> congr 1 <;> ring

def reluGaussianThreshold (B S m : ℝ) : ℝ :=
  4*(B+S/2*Real.log 2+Real.log m)

theorem gaussian_relative_energy_tail (v : ℝ≥0) (hv : 0<(v:ℝ))
    (hvone : (v:ℝ)≤1) {S B m : ℝ} (hdim : (Fintype.card ι:ℝ)*(v:ℝ)≤S)
    (hm : 1≤m) {A : Set (ι→ℝ)}
    (hA : Real.exp (-B/(v:ℝ))≤(Measure.pi fun _i:ι=>gaussianReal 0 v).real A) :
    (Measure.pi fun _i:ι=>gaussianReal 0 v).real
      {x | reluGaussianThreshold B S m≤∑i,(x i)^2} ≤
        (Measure.pi fun _i:ι=>gaussianReal 0 v).real A/m := by
  have hmp : 0<m := lt_of_lt_of_le zero_lt_one hm
  have hlog : 0≤Real.log m := Real.log_nonneg hm
  have htwo : 0≤Real.log 2 := Real.log_nonneg (by norm_num)
  have hdim' : (Fintype.card ι:ℝ)≤S/(v:ℝ) := (le_div_iff₀ hv).mpr hdim
  have he : (Fintype.card ι:ℝ)/2*Real.log 2-reluGaussianThreshold B S m/(4*(v:ℝ))≤
      -B/(v:ℝ)-Real.log m := by
    have hh := mul_le_mul_of_nonneg_right hdim' htwo
    have hm' : Real.log m≤Real.log m/(v:ℝ) := (le_div_iff₀ hv).mpr (mul_le_of_le_one_right hlog hvone)
    unfold reluGaussianThreshold
    field_simp
    nlinarith
  calc
    _ ≤ Real.exp ((Fintype.card ι:ℝ)/2*Real.log 2-reluGaussianThreshold B S m/(4*(v:ℝ))) :=
      gaussian_energy_tail v hv _
    _ ≤ Real.exp (-B/(v:ℝ)-Real.log m) := Real.exp_le_exp.mpr he
    _ = Real.exp (-B/(v:ℝ))/m := by rw [Real.exp_sub,Real.exp_log hmp]
    _ ≤ _ := div_le_div_of_nonneg_right hA hmp.le

end NeuralGeneralization.BatchTwoOnlineReluFinite
