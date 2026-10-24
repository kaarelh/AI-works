import NeuralGeneralization.BatchTwoContinuousDepthCriticalControlLLN

/-! Independent, non-identically distributed row laws for the deterministic
mixture seed. The underlying source coordinates remain genuinely Gaussian. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
variable {Ω:Type*} [MeasurableSpace Ω] {N:ℕ}

def rowFamilyAverage (F:Fin N→Ω→ℝ) (w:Fin N→Ω):ℝ:=(∑i,F i (w i))/(N:ℝ)

theorem independent_rowFamily_integral (μ:Measure Ω) [IsProbabilityMeasure μ]
    {F:Fin N→Ω→ℝ} (hF:∀i,MemLp (F i) 2 μ):
    (∫w,rowFamilyAverage F w ∂(Measure.pi fun _ : Fin N=>μ))=
      (∑i,∫z,F i z ∂μ)/(N:ℝ):=by
  have hi (i:Fin N):Integrable (fun w:Fin N→Ω=>F i (w i)) (Measure.pi fun _ : Fin N=>μ):=
    (measurePreserving_eval _ i).integrable_comp_of_integrable ((hF i).integrable (by norm_num))
  rw [show (fun w:Fin N→Ω=>rowFamilyAverage F w)=(fun w=>(∑i,F i (w i))/(N:ℝ)) from rfl,
    integral_div,integral_finsetSum _ (fun i _=>hi i)]
  congr 1
  apply Finset.sum_congr rfl
  intro i _
  exact integral_comp_eval (μ:=fun _ : Fin N=>μ) (i:=i) (hF i).aestronglyMeasurable

theorem independent_rowFamily_variance (μ:Measure Ω) [IsProbabilityMeasure μ]
    {F:Fin N→Ω→ℝ} (hF:∀i,MemLp (F i) 2 μ):
    variance (rowFamilyAverage F) (Measure.pi fun _ : Fin N=>μ)=
      (∑i,variance (F i) μ)/(N:ℝ)^2:=by
  have hs:=variance_sum_pi (μ:=fun _ : Fin N=>μ) hF
  have he:rowFamilyAverage F=(fun w:Fin N→Ω=>(∑i,F i (w i))*(N:ℝ)⁻¹):=by
    funext w
    exact div_eq_mul_inv _ _
  rw [he,variance_mul_const]
  have heSum:(fun w:Fin N→Ω=>∑i,F i (w i))=∑i:Fin N,fun w:Fin N→Ω=>F i (w i):=by
    funext w
    simp only [Finset.sum_apply]
  rw [heSum,hs]
  simp only [div_eq_mul_inv,inv_pow]

theorem independent_rowFamily_tail (μ:Measure Ω) [IsProbabilityMeasure μ]
    {F:Fin N→Ω→ℝ} (hF:∀i,MemLp (F i) 2 μ) {V ε:ℝ}
    (hV:∀i,(∫z,(F i z)^2 ∂μ)≤V) (hN:0<N) (hε:0<ε):
    (Measure.pi fun _ : Fin N=>μ).real
      {w|ε≤|rowFamilyAverage F w-(∑i,∫z,F i z ∂μ)/(N:ℝ)|}≤V/((N:ℝ)*ε^2):=by
  have hi (i:Fin N):MemLp (fun w:Fin N→Ω=>F i (w i)) 2 (Measure.pi fun _ : Fin N=>μ):=
    (hF i).comp_measurePreserving (measurePreserving_eval _ i)
  have ha:MemLp (rowFamilyAverage F) 2 (Measure.pi fun _ : Fin N=>μ):=by
    change MemLp (fun w:Fin N→Ω=>(∑i,F i (w i))/(N:ℝ)) 2 _
    simpa only [div_eq_mul_inv] using
      (memLp_finsetSum Finset.univ (fun i _=>hi i)).mul_const (N:ℝ)⁻¹
  have ht:=meas_ge_le_variance_div_sq ha hε
  rw [independent_rowFamily_integral μ hF,independent_rowFamily_variance μ hF] at ht
  have hn:(0:ℝ)<N:=by exact_mod_cast hN
  have hvar:0≤∑i,variance (F i) μ:=Finset.sum_nonneg (fun i _=>variance_nonneg _ _)
  have htr:=ENNReal.toReal_mono (by simp : ENNReal.ofReal ((∑i,variance (F i) μ)/(N:ℝ)^2/ε^2)≠⊤) ht
  rw [ENNReal.toReal_ofReal (div_nonneg (div_nonneg hvar (sq_nonneg _)) (sq_nonneg ε))] at htr
  have hv:(∑i,variance (F i) μ)≤(N:ℝ)*V:=by
    have hh:=Finset.sum_le_sum (fun i (_:i∈Finset.univ)=>
      (variance_le_expectation_sq (hF i).aestronglyMeasurable).trans (hV i))
    simpa only [Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul] using hh
  apply htr.trans
  rw [div_div]
  apply (div_le_iff₀ (mul_pos (sq_pos_of_pos hn) (sq_pos_of_pos hε))).mpr
  have he:V/((N:ℝ)*ε^2)*((N:ℝ)^2*ε^2)=(N:ℝ)*V:=by field_simp
  rw [he]
  exact hv

end NeuralGeneralization.BatchTwoContinuousDepthCritical
