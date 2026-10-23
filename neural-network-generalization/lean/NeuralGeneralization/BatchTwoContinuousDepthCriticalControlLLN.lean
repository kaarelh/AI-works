import NeuralGeneralization.BatchTwoContinuousDepthCriticalRowLaw
import NeuralGeneralization.RobustCompressionGaussian
import Mathlib.Probability.Moments.Variance

/-! Uniform finite-sample laws for the actual independent Gaussian rows. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false

variable {Ω:Type*} [MeasurableSpace Ω]

def rowAverage {N:ℕ} (F:Ω→ℝ) (w:Fin N→Ω):ℝ := (∑i,F (w i))/(N:ℝ)

theorem iid_rowAverage_integral (μ:Measure Ω) [IsProbabilityMeasure μ]
    {F:Ω→ℝ} (hF:MemLp F 2 μ) {N:ℕ} (hN:0<N):
    (∫w,rowAverage F w ∂(Measure.pi fun _ : Fin N=>μ))=∫z,F z ∂μ:=by
  have hFi:Integrable F μ:=hF.integrable (by norm_num)
  have hi (i:Fin N):Integrable (fun w:Fin N→Ω=>F (w i)) (Measure.pi fun _ : Fin N=>μ):=
    (measurePreserving_eval _ i).integrable_comp_of_integrable hFi
  rw [show (fun w:Fin N→Ω=>rowAverage F w)=(fun w=>(∑i,F (w i))/(N:ℝ)) from rfl,
    integral_div,integral_finsetSum _ (fun i _=>hi i)]
  simp_rw [integral_comp_eval (μ:=fun _ : Fin N=>μ) (f:=F) hF.aestronglyMeasurable]
  simp only [Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul]
  exact mul_div_cancel_left₀ _ (by exact_mod_cast Nat.ne_of_gt hN)

theorem iid_rowAverage_variance (μ:Measure Ω) [IsProbabilityMeasure μ]
    {F:Ω→ℝ} (hF:MemLp F 2 μ) {N:ℕ} (hN:0<N):
    variance (rowAverage (N:=N) F) (Measure.pi fun _ : Fin N=>μ)=variance F μ/(N:ℝ):=by
  have hs:=variance_sum_pi (μ:=fun _ : Fin N=>μ) (X:=fun _ : Fin N=>F) (fun _=>hF)
  have he:(fun w:Fin N→Ω=>rowAverage F w)=fun w=>(∑i,F (w i))*(N:ℝ)⁻¹:=by
    funext w; exact div_eq_mul_inv _ _
  change variance (fun w:Fin N→Ω=>rowAverage F w) _=_
  rw [he,variance_mul_const]
  have heSum:(fun w:Fin N→Ω=>∑i,F (w i))=∑i:Fin N,fun w:Fin N→Ω=>F (w i):=by
    funext w
    simp only [Finset.sum_apply]
  rw [heSum,hs]
  simp only [Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul]
  have hn:(N:ℝ)≠0:=by exact_mod_cast Nat.ne_of_gt hN
  field_simp

/-- Chebyshev with a row second-moment bound; uniform in the row's source
space, which may itself depend on the width. -/
theorem iid_rowAverage_tail (μ:Measure Ω) [IsProbabilityMeasure μ]
    {F:Ω→ℝ} (hF:MemLp F 2 μ) {V ε:ℝ} (hV:(∫z,(F z)^2 ∂μ)≤V)
    {N:ℕ} (hN:0<N) (hε:0<ε):
    (Measure.pi fun _ : Fin N=>μ).real {w|ε≤|rowAverage F w-∫z,F z ∂μ|}≤
      V/((N:ℝ)*ε^2):=by
  have hi (i:Fin N):MemLp (fun w:Fin N→Ω=>F (w i)) 2 (Measure.pi fun _ : Fin N=>μ):=
    hF.comp_measurePreserving (measurePreserving_eval _ i)
  have ha:MemLp (rowAverage (N:=N) F) 2 (Measure.pi fun _ : Fin N=>μ):=by
    change MemLp (fun w:Fin N→Ω=>(∑i,F (w i))/(N:ℝ)) 2 _
    simpa only [rowAverage,div_eq_mul_inv] using
      (memLp_finsetSum Finset.univ (fun i _=>hi i)).mul_const (N:ℝ)⁻¹
  have ht:=meas_ge_le_variance_div_sq ha hε
  rw [iid_rowAverage_integral μ hF hN,iid_rowAverage_variance μ hF hN] at ht
  have htr:=ENNReal.toReal_mono (by simp : ENNReal.ofReal (variance F μ/(N:ℝ)/ε^2)≠⊤) ht
  rw [ENNReal.toReal_ofReal (div_nonneg (div_nonneg (variance_nonneg F μ) (Nat.cast_nonneg N)) (sq_nonneg ε))] at htr
  have hv:variance F μ≤V:=(variance_le_expectation_sq hF.aestronglyMeasurable).trans hV
  exact htr.trans (by rw [div_div]; exact div_le_div_of_nonneg_right hv (by positivity))

end NeuralGeneralization.BatchTwoContinuousDepthCritical
