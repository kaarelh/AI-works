import NeuralGeneralization.RobustCompressionGaussian

/-! Exponential Gaussian clipping at the manuscript's cutoff B >= 2.
Only marginal variances are used; correlated residual coordinates are allowed. -/
noncomputable section
set_option autoImplicit false
set_option maxHeartbeats 1000000
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoManuscriptClipping
open RobustCompressionGaussian

theorem square_le_exp_nonneg {r : ℝ} (hr : 0≤r) : r^2≤Real.exp r := by
  have hh : r/2≤Real.exp (r/2-1) := by linarith only [Real.add_one_le_exp (r/2-1)]
  have hs := pow_le_pow_left₀ (by positivity : 0≤r/2) hh 2
  have he : Real.exp (r/2-1)^2=Real.exp (r-2) := by
    rw [←Real.exp_nat_mul]
    congr 1
    norm_num
    ring
  rw [he] at hs
  have hc : (4:ℝ)≤Real.exp 2 := by
    have hh : (2:ℝ)≤Real.exp 1 := by linarith only [Real.add_one_le_exp 1]
    have hs := pow_le_pow_left₀ (by norm_num : (0:ℝ)≤2) hh 2
    rw [←Real.exp_nat_mul] at hs
    norm_num at hs
    exact hs
  calc
    _ ≤4*Real.exp (r-2) := by nlinarith only [hs]
    _ ≤Real.exp 2*Real.exp (r-2) := mul_le_mul_of_nonneg_right hc (Real.exp_pos _).le
    _ =_ := by rw [←Real.exp_add]; congr 1; ring

theorem positive_clip_exp {B z : ℝ} (hB : 2≤B) (hz : B≤z) :
    (z-B)^2≤Real.exp ((z^2-B^2)/4) := by
  have hr : 0≤z-B := sub_nonneg.mpr hz
  have hb : z-B≤(z^2-B^2)/4 := by
    nlinarith [sq_nonneg (z-B),mul_nonneg hr (show 0≤B-2 by linarith)]
  exact (square_le_exp_nonneg hr).trans (Real.exp_le_exp.mpr hb)

theorem gaussianClip_error_exp (B z : ℝ) (hB : 2≤B) :
    (z-gaussianClip B z)^2≤Real.exp (-(B^2)/4)*Real.exp (z^2/4) := by
  have he : Real.exp ((z^2-B^2)/4)=Real.exp (-(B^2)/4)*Real.exp (z^2/4) := by
    rw [←Real.exp_add]
    congr 1
    ring
  rw [←he]
  by_cases hz : B≤z
  · rw [gaussianClip,min_eq_left hz,max_eq_right (by linarith)]
    exact positive_clip_exp hB hz
  · rw [gaussianClip,min_eq_right (le_of_not_ge hz)]
    by_cases hz' : -B≤z
    · rw [max_eq_right hz',sub_self,zero_pow (by decide : (2:ℕ)≠0)]
      exact (Real.exp_pos _).le
    · rw [max_eq_left (le_of_not_ge hz')]
      have hh := positive_clip_exp hB (show B≤ -z by linarith)
      convert hh using 1 <;> ring

theorem gaussian_clip_error_exp_le (v : ℝ≥0) (hv : (v:ℝ)≤1)
    (B : ℝ) (hB : 2≤B) :
    (∫ z : ℝ,(z-gaussianClip B z)^2 ∂gaussianReal 0 v)≤3*Real.exp (-(B^2)/4) := by
  have hB0 : 0<B := by linarith
  have hi : Integrable (fun z : ℝ=>Real.exp (z^2/4)) (gaussianReal 0 v) := by
    apply Integrable.of_integral_ne_zero
    have hp : 0<1-2*(1/4:ℝ)*v := by linarith
    have he : (fun z : ℝ=>Real.exp (z^2/4))=(fun z=>Real.exp ((1/4)*z^2)) := by
      funext z
      congr 1
      ring
    rw [he,GaussianTail.integral_exp_mul_sq_gaussianReal v (1/4) hp]
    exact inv_ne_zero (Real.sqrt_pos.mpr hp).ne'
  calc
    _ ≤∫ z : ℝ,Real.exp (-(B^2)/4)*Real.exp (z^2/4) ∂gaussianReal 0 v :=
      integral_mono (gaussian_clip_error_integrable v B hB0)
        (hi.const_mul _) (fun z=>gaussianClip_error_exp B z hB)
    _ =Real.exp (-(B^2)/4)*(∫ z : ℝ,Real.exp (z^2/4) ∂gaussianReal 0 v) := integral_const_mul _ _
    _ ≤Real.exp (-(B^2)/4)*2 :=
      mul_le_mul_of_nonneg_left (gaussian_exp_square_le_two v hv) (Real.exp_pos _).le
    _ ≤_ := by nlinarith [Real.exp_pos (-(B^2)/4)]

variable {Ω : Type*} [MeasurableSpace Ω] {m : ℕ}

theorem correlated_clip_error_sum_exp (μ : Measure Ω) (Z : Fin m→Ω→ℝ)
    (hZ : ∀i,Measurable (Z i)) (v : Fin m→ℝ≥0)
    (hlaw : ∀i,μ.map (Z i)=gaussianReal 0 (v i))
    (hv : ∀i,(v i:ℝ)≤1) (B : ℝ) (hB : 2≤B) :
    (∫ ω,∑i,(Z i ω-gaussianClip B (Z i ω))^2 ∂μ)≤
      3*(m:ℝ)*Real.exp (-(B^2)/4) := by
  have hint (i : Fin m) : Integrable (fun ω=>(Z i ω-gaussianClip B (Z i ω))^2) μ := by
    have hh := gaussian_clip_error_integrable (v i) B (by linarith)
    rw [←hlaw i] at hh
    exact (integrable_map_measure
      ((measurable_id.sub (measurable_gaussianClip B)).pow_const 2).aestronglyMeasurable
      (hZ i).aemeasurable).mp hh
  rw [integral_finsetSum Finset.univ (fun i _=>hint i)]
  calc
    _ ≤∑i : Fin m,3*Real.exp (-(B^2)/4) := by
      apply Finset.sum_le_sum
      intro i _
      have hh := integral_map (μ:=μ) (hZ i).aemeasurable
        ((measurable_id.sub (measurable_gaussianClip B)).pow_const 2).aestronglyMeasurable
      rw [hlaw i] at hh
      simp only [Pi.sub_apply,id_eq] at hh
      rw [←hh]
      exact gaussian_clip_error_exp_le (v i) (hv i) B hB
    _ =_ := by simp only [Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul]; ring

end NeuralGeneralization.BatchTwoManuscriptClipping
