import NeuralGeneralization.OnlineLowerTanhInverseLaplaceContour

/-! # The causal, continuous inverse-Laplace kernel -/
noncomputable section
open scoped Topology FourierTransform
open Filter Set MeasureTheory Complex
namespace NeuralGeneralization.OnlineLowerTanh.HalfPlaneQuadraticRemainder
variable {E : ℂ → ℂ} {a K : ℝ} (H : HalfPlaneQuadraticRemainder E a K)

def fourierLine (_ : HalfPlaneQuadraticRemainder E a K) (c y : ℝ) : ℂ :=
  E ((c:ℂ)+((2*Real.pi*y:ℝ):ℂ)*I)

lemma integrable_fourierLine {c : ℝ} (hc : a<c) (hc0 : 0<c) :
    Integrable (H.fourierLine c) := by
  have hi : Integrable (fun y:ℝ=>E ((c:ℂ)+y*I)) := by
    apply (H.integrable_vertical hc hc0 0).congr
    filter_upwards with y
    simp [HalfPlaneQuadraticRemainder.vertical]
  change Integrable (fun y:ℝ=> E ((c:ℂ)+((2*Real.pi*y:ℝ):ℂ)*I))
  exact (integrable_comp_mul_left_iff _ (show (2*Real.pi:ℝ)≠0 by positivity)).2 hi

lemma continuous_fourierLine {c : ℝ} (hc : a<c) : Continuous (H.fourierLine c) := by
  unfold fourierLine
  exact H.holomorphic.continuousOn.comp_continuous (by fun_prop) (by intro y; simpa using hc)

lemma bromwich_eq_fourierInv (c t : ℝ) :
    H.bromwich c t=Complex.exp (c*t) * (𝓕⁻ (H.fourierLine c)) t := by
  have hp : (2*Real.pi:ℝ)≠0 := by positivity
  rw [Real.fourierInv_eq']
  have heq : (fun y:ℝ=>Complex.exp ((↑(2*Real.pi*inner ℝ y t))*I) • H.fourierLine c y) =
      (fun y:ℝ=> E ((c:ℂ)+((2*Real.pi*y:ℝ):ℂ)*I)*
        Complex.exp (((2*Real.pi*y:ℝ):ℂ)*I*t)) := by
    funext y
    simp only [fourierLine, RCLike.inner_apply, conj_trivial, smul_eq_mul]
    rw [mul_comm]
    congr 2 <;> push_cast <;> ring
  rw [heq]
  have hs := Measure.integral_comp_mul_left
    (fun y:ℝ=>E ((c:ℂ)+y*I)*Complex.exp ((y:ℂ)*I*t)) (2*Real.pi)
  rw [hs]
  simp only [abs_of_pos (inv_pos.mpr (by positivity : (0:ℝ)<2*Real.pi)),
    Complex.real_smul, Complex.ofReal_inv, Complex.ofReal_mul, Complex.ofReal_ofNat]
  unfold bromwich vertical
  have hexp (y:ℝ) : Complex.exp (((c:ℂ)+y*I)*t)=
      Complex.exp (c*t)*Complex.exp ((y:ℂ)*I*t) := by
    rw [← Complex.exp_add]
    congr 1
    ring
  simp_rw [hexp]
  calc
    _ = (2*(Real.pi:ℂ))⁻¹ * (Complex.exp (c*t)*
        ∫y:ℝ,E ((c:ℂ)+y*I)*Complex.exp ((y:ℂ)*I*t)) := by
      congr 1
      rw [← integral_const_mul]
      congr 1
      funext y
      ring
    _ = _ := by ring

lemma continuous_bromwich {c : ℝ} (hc : a<c) (hc0 : 0<c) :
    Continuous (H.bromwich c) := by
  have hi := H.integrable_fourierLine hc hc0
  have hf : Continuous (𝓕⁻ (H.fourierLine c)) := by
    exact VectorFourier.fourierIntegral_continuous Real.continuous_fourierChar
      (by fun_prop) hi
  have he : H.bromwich c = fun t:ℝ=>Complex.exp (c*t)*(𝓕⁻ (H.fourierLine c)) t := by
    funext t; exact H.bromwich_eq_fourierInv c t
  rw [he]
  exact (by fun_prop : Continuous (fun t:ℝ=>Complex.exp ((c:ℂ)*t))).mul hf

lemma bromwich_zero_of_nonpos {c t : ℝ} (hc : a<c) (hc0 : 0<c) (ht : t≤0) :
    H.bromwich c t=0 := by
  have hle : ∀ᶠd:ℝ in atTop, ‖H.bromwich c t‖≤K/(2*d) := by
    filter_upwards [eventually_gt_atTop (max a 0)] with d hd
    have hd0 : 0<d := (le_max_right _ _).trans_lt hd
    have hda : a<d := (le_max_left _ _).trans_lt hd
    rw [H.bromwich_independent hc hc0 hda hd0 t]
    calc
      _ ≤ K*Real.exp (d*t)/(2*d) := H.norm_bromwich_le hda hd0 t
      _ ≤ K/(2*d) := by
        apply div_le_div_of_nonneg_right _ (by positivity)
        exact mul_le_of_le_one_right H.constant_nonneg
          (Real.exp_le_one_iff.mpr (mul_nonpos_of_nonneg_of_nonpos hd0.le ht))
  have hz : Tendsto (fun d:ℝ=>K/(2*d)) atTop (𝓝 0) := by
    have hi := tendsto_inv_atTop_zero.const_mul (K/2)
    convert hi using 1 <;> ext d <;> ring
  have hn := le_of_tendsto_of_tendsto tendsto_const_nhds hz hle
  exact norm_eq_zero.mp (le_antisymm hn (norm_nonneg _))

lemma bromwich_small_time_bound {c t : ℝ} (hc : a<c) (hc0 : 0<c)
    (ht : 0<t) (hat : a<t⁻¹) :
    ‖H.bromwich c t‖ ≤ Real.exp 1*K*t/2 := by
  rw [H.bromwich_independent hc hc0 hat (inv_pos.mpr ht) t]
  calc
    _ ≤ K*Real.exp (t⁻¹*t)/(2*t⁻¹) := H.norm_bromwich_le hat (inv_pos.mpr ht) t
    _ = _ := by rw [inv_mul_cancel₀ ht.ne']; field_simp

end NeuralGeneralization.OnlineLowerTanh.HalfPlaneQuadraticRemainder
