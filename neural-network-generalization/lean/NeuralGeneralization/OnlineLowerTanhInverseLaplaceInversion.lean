import NeuralGeneralization.OnlineLowerTanhInverseLaplaceKernel

/-! # Laplace inversion from causal Fourier inversion -/
noncomputable section
open scoped Topology FourierTransform
open Filter Set MeasureTheory Complex
namespace NeuralGeneralization.OnlineLowerTanh.HalfPlaneQuadraticRemainder
variable {E : ℂ → ℂ} {a K : ℝ} (H : HalfPlaneQuadraticRemainder E a K)

lemma fourierInv_eq_bromwich (c t : ℝ) :
    (𝓕⁻ (H.fourierLine c)) t = Complex.exp (-c*t)*H.bromwich c t := by
  rw [H.bromwich_eq_fourierInv]
  rw [← mul_assoc, ← Complex.exp_add]
  simp

lemma fourierInv_eq_shifted_bromwich {c n : ℝ} (hc : a<c) (hc0 : 0<c)
    (hn : a<n) (hn0 : 0<n) (t : ℝ) :
    (𝓕⁻ (H.fourierLine n)) t = Complex.exp (-n*t)*H.bromwich c t := by
  rw [H.fourierInv_eq_bromwich, H.bromwich_independent hn hn0 hc hc0 t]

lemma integrable_fourierInv {c n : ℝ} (hc : a<c) (hc0 : 0<c) (hcn : c<n) :
    Integrable (𝓕⁻ (H.fourierLine n)) := by
  have hn := hc.trans hcn
  have hn0 := hc0.trans hcn
  have hcont : Continuous (𝓕⁻ (H.fourierLine n)) := by
    exact VectorFourier.fourierIntegral_continuous Real.continuous_fourierChar
      (by fun_prop) (H.integrable_fourierLine hn hn0)
  have hi : IntegrableOn (𝓕⁻ (H.fourierLine n)) (Ioi 0) := by
    apply ((integrableOn_exp_mul_Ioi (sub_neg.mpr hcn) 0).const_mul (K/(2*c))).mono'
      hcont.aestronglyMeasurable
    filter_upwards with t
    rw [H.fourierInv_eq_shifted_bromwich hc hc0 hn hn0 t, norm_mul, Complex.norm_exp]
    simp only [mul_re, neg_re, ofReal_re, ofReal_im, neg_im, neg_zero, mul_zero, sub_zero]
    calc
      _ ≤ Real.exp (-n*t)*(K*Real.exp (c*t)/(2*c)) :=
        mul_le_mul_of_nonneg_left (H.norm_bromwich_le hc hc0 t) (by positivity)
      _ = K/(2*c)*Real.exp ((c-n)*t) := by
        rw [show (c-n)*t=c*t+(-n*t) by ring, Real.exp_add]
        ring
  have hz (t:ℝ) (ht:t≤0) : (𝓕⁻ (H.fourierLine n)) t=0 := by
    rw [H.fourierInv_eq_bromwich, H.bromwich_zero_of_nonpos hn hn0 ht, mul_zero]
  have hid : (Ioi (0:ℝ)).indicator (𝓕⁻ (H.fourierLine n)) = (𝓕⁻ (H.fourierLine n)) := by
    funext t
    by_cases ht:0<t
    · simp [ht]
    · simp [ht,hz t (le_of_not_gt ht)]
  rw [←hid]
  exact hi.integrable_indicator measurableSet_Ioi

lemma integral_fourierInv {c n : ℝ} (hc : a<c) (hc0 : 0<c) (hcn : c<n) :
    (∫t:ℝ,(𝓕⁻ (H.fourierLine n)) t)=E (n:ℂ) := by
  have hi := H.integrable_fourierInv hc hc0 hcn
  have hf : Integrable (𝓕 (H.fourierLine n)) := by
    simpa only [Real.fourierInv_eq_fourier_neg, neg_neg] using hi.comp_neg
  have hv := (H.integrable_fourierLine (hc.trans hcn) (hc0.trans hcn)).fourier_fourierInv_eq
    hf (H.continuous_fourierLine (hc.trans hcn)).continuousAt (v:=0)
  simpa [Real.fourier_eq', fourierLine] using hv

lemma inverse_laplace_integrable {c n : ℝ} (hc : a<c) (hc0 : 0<c) (hcn : c<n) :
    IntegrableOn (fun t:ℝ=>Complex.exp (-n*t)*H.bromwich c t) (Ioi 0) := by
  have hi := (H.integrable_fourierInv hc hc0 hcn).integrableOn (s:=Ioi 0)
  apply hi.congr
  filter_upwards with t
  exact H.fourierInv_eq_shifted_bromwich hc hc0 (hc.trans hcn) (hc0.trans hcn) t

lemma inverse_laplace_identity {c n : ℝ} (hc : a<c) (hc0 : 0<c) (hcn : c<n) :
    (∫t:ℝ in Ioi 0,Complex.exp (-n*t)*H.bromwich c t)=E (n:ℂ) := by
  rw [←H.integral_fourierInv hc hc0 hcn]
  rw [←integral_indicator measurableSet_Ioi]
  apply integral_congr_ae
  filter_upwards with t
  by_cases ht:0<t
  · change (Ioi (0:ℝ)).indicator (fun t:ℝ=>Complex.exp (-n*t)*H.bromwich c t) t = _
    rw [Set.indicator_of_mem (show t∈Ioi (0:ℝ) from ht)]
    exact (H.fourierInv_eq_shifted_bromwich hc hc0 (hc.trans hcn) (hc0.trans hcn) t).symm
  · change (Ioi (0:ℝ)).indicator (fun t:ℝ=>Complex.exp (-n*t)*H.bromwich c t) t = _
    rw [Set.indicator_of_notMem (show t∉Ioi (0:ℝ) from ht)]
    rw [H.fourierInv_eq_bromwich, H.bromwich_zero_of_nonpos (hc.trans hcn)
      (hc0.trans hcn) (le_of_not_gt ht), mul_zero]

end NeuralGeneralization.OnlineLowerTanh.HalfPlaneQuadraticRemainder
