import NeuralGeneralization.OnlineLowerTanhResidualCellIntegral
import NeuralGeneralization.TanhScalarJet
import Mathlib.Analysis.Calculus.ParametricIntegral

/-! # Literal external-bias derivatives of actual tanh parity coefficients -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped Topology BigOperators
open MeasureTheory Filter Set
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel TanhDifferential

def parityBiasFirst {n:ℕ} (u:Fin n → ℝ) (B:ℝ) : ℝ :=
  (Fintype.card (Cube n):ℝ)⁻¹*∑x:Cube n,paritySign x*tanhFirst (B+incomingLinear u x)
def parityBiasSecond {n:ℕ} (u:Fin n → ℝ) (B:ℝ) : ℝ :=
  (Fintype.card (Cube n):ℝ)⁻¹*∑x:Cube n,paritySign x*tanhSecond (B+incomingLinear u x)

lemma hasDerivAt_parityCorrelation {n:ℕ} (u:Fin n → ℝ) (B:ℝ) :
    HasDerivAt (parityCorrelation u) (parityBiasFirst u B) B := by
  have hs:=HasDerivAt.sum (u:=Finset.univ) (fun (x:Cube n) (_:x∈Finset.univ)=>
    (((hasDerivAt_tanh_first (B+incomingLinear u x)).comp B
      ((hasDerivAt_id B).add_const (incomingLinear u x))).const_mul (paritySign x)))
  convert! hs.const_mul (Fintype.card (Cube n):ℝ)⁻¹ using 1
  · funext y
    simp [parityCorrelation,Finset.sum_apply,Function.comp_def]
  · simp [parityBiasFirst]

lemma hasDerivAt_parityBiasFirst {n:ℕ} (u:Fin n → ℝ) (B:ℝ) :
    HasDerivAt (parityBiasFirst u) (parityBiasSecond u B) B := by
  have hs:=HasDerivAt.sum (u:=Finset.univ) (fun (x:Cube n) (_:x∈Finset.univ)=>
    (((hasDerivAt_tanhFirst (B+incomingLinear u x)).comp B
      ((hasDerivAt_id B).add_const (incomingLinear u x))).const_mul (paritySign x)))
  convert! hs.const_mul (Fintype.card (Cube n):ℝ)⁻¹ using 1
  · funext y
    simp [parityBiasFirst,Finset.sum_apply,Function.comp_def]
  · simp [parityBiasSecond]

lemma residualRawKernel_deriv {n:ℕ} (u:Fin n → ℝ) (B θ t:ℝ) (j:ℕ) :
    HasDerivAt (fun b:ℝ=>residualRawKernel u b θ (residualDerivativeKernel j) t)
      (residualRawKernel u B (θ+Real.pi/2) (residualDerivativeKernel (j+1)) t) B := by
  have hd:= (((((hasDerivAt_id B).mul_const t).add_const θ).sin.mul_const
    (∏i,Real.sin (u i*t))).mul_const (residualDerivativeKernel j t))
  convert! hd using 1
  simp only [residualRawKernel,residualDerivativeKernel,pow_succ,one_mul,id_eq]
  rw [show B*t+(θ+Real.pi/2)=(B*t+θ)+Real.pi/2 by ring,Real.sin_add_pi_div_two]
  ring

lemma residualRawKernel_abs_le_moment {n:ℕ} (u:Fin n → ℝ) (B θ:ℝ) (j:ℕ)
    {t:ℝ} (ht:0<t) :
    |residualRawKernel u B θ (residualDerivativeKernel j) t|≤
      t^j*paritySineProduct u t/Real.sinh ((Real.pi/2)*t) := by
  have hsin:0<Real.sinh (Real.pi*t/2):=Real.sinh_pos_iff.mpr (by positivity)
  simp only [residualRawKernel,residualDerivativeKernel,abs_mul,abs_div,Finset.abs_prod,
    abs_of_pos hsin,abs_of_nonneg (pow_nonneg ht.le j)]
  have hp:(∏i,|Real.sin (u i*t)|)=paritySineProduct u t:=by
    unfold paritySineProduct
    apply Finset.prod_congr rfl
    intro i hi
    rw [mul_comm]
  rw [hp]
  have hh:=mul_le_of_le_one_left (paritySineProduct_nonneg u t) (Real.abs_sin_le_one (B*t+θ))
  have hm:=mul_le_mul_of_nonneg_right hh (div_nonneg (pow_nonneg ht.le j) hsin.le)
  convert! hm using 1 <;> first | ring | rfl

/-- Every external phase derivative is justified directly under the actual
parity integral, with an integrable all-frequency dominating moment. -/
lemma residualRawIntegral_hasDerivAt {n:ℕ} (hn:0<n) (u:Fin n → ℝ) (B θ:ℝ) (j:ℕ) :
    HasDerivAt (fun b:ℝ=>∫t:ℝ in Ioi 0,residualRawKernel u b θ (residualDerivativeKernel j) t)
      (∫t:ℝ in Ioi 0,residualRawKernel u B (θ+Real.pi/2) (residualDerivativeKernel (j+1)) t) B := by
  apply (hasDerivAt_integral_of_dominated_loc_of_deriv_le
    (F:=fun b t:ℝ=>residualRawKernel u b θ (residualDerivativeKernel j) t)
    (F':=fun b t:ℝ=>residualRawKernel u b (θ+Real.pi/2) (residualDerivativeKernel (j+1)) t)
    (x₀:=B) (μ:=volume.restrict (Ioi 0)) (s:=Set.univ)
    (bound:=fun t:ℝ=>t^(j+1)*paritySineProduct u t/Real.sinh ((Real.pi/2)*t)) (by simp)
    ?_ ?_ ?_ ?_ ?_ ?_).2
  · exact Eventually.of_forall (fun b=>(residualRawKernel_integrable hn u b θ j).aestronglyMeasurable)
  · exact residualRawKernel_integrable hn u B θ j
  · exact (residualRawKernel_integrable hn u B (θ+Real.pi/2) (j+1)).aestronglyMeasurable
  · filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht b hb
    simpa only [Real.norm_eq_abs] using residualRawKernel_abs_le_moment u b (θ+Real.pi/2) (j+1) ht
  · exact integrable_parity_kernel_moment hn u (j+1) (by positivity)
  · exact Eventually.of_forall (fun t b hb=>residualRawKernel_deriv u b θ t j)

lemma parityBiasFirst_integral {n:ℕ} (hn:0<n) (u:Fin n → ℝ) (B:ℝ) :
    parityBiasFirst u B=∫t:ℝ in Ioi 0,
      residualRawKernel u B ((n:ℝ)*Real.pi/2+Real.pi/2) (residualDerivativeKernel 1) t := by
  have h1:=hasDerivAt_parityCorrelation u B
  have h2:=residualRawIntegral_hasDerivAt hn u B ((n:ℝ)*Real.pi/2) 0
  have he:(parityCorrelation u)=(fun b:ℝ=>∫t:ℝ in Ioi 0,
    residualRawKernel u b ((n:ℝ)*Real.pi/2) (residualDerivativeKernel 0) t):=funext (residualRawKernel_parity u)
  rw [he] at h1
  exact h1.unique h2

/-- The actual normalized cube average of tanhSecond equals the signed
second-moment kernel, not an abstract derivative placeholder. -/
theorem parityBiasSecond_integral {n:ℕ} (hn:0<n) (u:Fin n → ℝ) (B:ℝ) :
    parityBiasSecond u B=-(∫t:ℝ in Ioi 0,
      residualRawKernel u B ((n:ℝ)*Real.pi/2) (residualDerivativeKernel 2) t) := by
  have h1:=hasDerivAt_parityBiasFirst u B
  have h2:=residualRawIntegral_hasDerivAt hn u B ((n:ℝ)*Real.pi/2+Real.pi/2) 1
  have he:(parityBiasFirst u)=(fun b:ℝ=>∫t:ℝ in Ioi 0,
    residualRawKernel u b ((n:ℝ)*Real.pi/2+Real.pi/2) (residualDerivativeKernel 1) t):=
    funext (parityBiasFirst_integral hn u)
  rw [he] at h1
  have hh:=h1.unique h2
  rw [hh,←integral_neg]
  apply integral_congr_ae
  exact Eventually.of_forall (fun t=>by
    simp only [residualRawKernel]
    rw [show B*t+((n:ℝ)*Real.pi/2+Real.pi/2+Real.pi/2)=
      (B*t+(n:ℝ)*Real.pi/2)+Real.pi by ring,Real.sin_add_pi]
    ring)

end NeuralGeneralization.OnlineLowerTanh
