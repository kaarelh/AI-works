import NeuralGeneralization.BatchTwoActivationGaussianConcentration

/-! A tunable Gaussian concentration bound, proved from the actual T2 coupling.
As the Young parameter tends to zero its exponent tends to the sharp 1/2.
This permits additive-energy posterior ceilings at finite prior scales. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal
namespace NeuralGeneralization.BatchTwoContinuousDepthPower
open BatchTwoActivation RobustPosterior

theorem gaussian_secondMoment_transport_weighted {n:ℕ}
    (F:(Fin n→ℝ)→ℝ) (hF:Measurable F) (hLip:SquareLipschitz F)
    (Q:Measure (Fin n→ℝ)) [IsProbabilityMeasure Q] {θ:ℝ} (hθ:0<θ):
    (∫⁻x,ENNReal.ofReal (F x^2) ∂Q)≤
      ENNReal.ofReal (1+θ⁻¹)*(∫⁻x,ENNReal.ofReal (F x^2) ∂standardGaussian n)+
      ENNReal.ofReal (2*(1+θ))*klDiv Q (standardGaussian n) := by
  let Γ:=gaussianTransport n Q
  have hm:Measurable (fun x=>ENNReal.ofReal (F x^2)):=(hF.pow_const 2).ennreal_ofReal
  have hcost:Measurable (fun p:(Fin n→ℝ)×(Fin n→ℝ)=>ENNReal.ofReal (euclideanSquaredDistance p.1 p.2)):=by
    unfold euclideanSquaredDistance
    fun_prop
  have ha:0≤1+θ⁻¹:=by positivity
  have hb:0≤1+θ:=by positivity
  have hpoint (p:(Fin n→ℝ)×(Fin n→ℝ)):
      ENNReal.ofReal (F p.1^2)≤ENNReal.ofReal (1+θ⁻¹)*ENNReal.ofReal (F p.2^2)+
        ENNReal.ofReal (1+θ)*ENNReal.ofReal (euclideanSquaredDistance p.1 p.2) := by
    have hsq:0≤(θ*(F p.1-F p.2)-F p.2)^2/θ:=by positivity
    have he:(1+θ⁻¹)*(F p.2)^2+(1+θ)*(F p.1-F p.2)^2-(F p.1)^2=
        (θ*(F p.1-F p.2)-F p.2)^2/θ:=by field_simp;ring
    have hLip':=(mul_le_mul_of_nonneg_left (hLip p.1 p.2) hb)
    have hc:0≤euclideanSquaredDistance p.1 p.2:=by unfold euclideanSquaredDistance;positivity
    have hh:(F p.1)^2≤(1+θ⁻¹)*(F p.2)^2+(1+θ)*euclideanSquaredDistance p.1 p.2:=by
      nlinarith
    simpa only [ENNReal.ofReal_add (mul_nonneg ha (sq_nonneg _)) (mul_nonneg hb hc),
      ENNReal.ofReal_mul ha,ENNReal.ofReal_mul hb] using ENNReal.ofReal_le_ofReal hh
  have hid1:(∫⁻x,ENNReal.ofReal (F x^2) ∂Q)=∫⁻p,ENNReal.ofReal (F p.1^2) ∂Γ:=by
    rw [←gaussianTransport_fst n Q,lintegral_map hm measurable_fst]
  have hid2:(∫⁻x,ENNReal.ofReal (F x^2) ∂standardGaussian n)=∫⁻p,ENNReal.ofReal (F p.2^2) ∂Γ:=by
    rw [←gaussianTransport_snd n Q,lintegral_map hm measurable_snd]
  rw [hid1,hid2]
  calc
    _ ≤ ∫⁻p,ENNReal.ofReal (1+θ⁻¹)*ENNReal.ofReal (F p.2^2)+
        ENNReal.ofReal (1+θ)*ENNReal.ofReal (euclideanSquaredDistance p.1 p.2) ∂Γ:=lintegral_mono hpoint
    _ = ENNReal.ofReal (1+θ⁻¹)*(∫⁻p,ENNReal.ofReal (F p.2^2) ∂Γ)+
        ENNReal.ofReal (1+θ)*(∫⁻p,ENNReal.ofReal (euclideanSquaredDistance p.1 p.2) ∂Γ):=by
      rw [lintegral_add_left (by fun_prop),lintegral_const_mul _ (by fun_prop),lintegral_const_mul _ hcost]
    _ ≤ ENNReal.ofReal (1+θ⁻¹)*(∫⁻p,ENNReal.ofReal (F p.2^2) ∂Γ)+
        ENNReal.ofReal (1+θ)*(2*klDiv Q (standardGaussian n)):=
      add_le_add le_rfl (mul_le_mul' le_rfl (gaussianTransport_cost n Q))
    _ = _:=by
      rw [ENNReal.ofReal_mul (by norm_num : (0:ℝ)≤2)]
      norm_num
      ring

theorem gaussian_zeroSet_square_tail_weighted {n:ℕ}
    (F:(Fin n→ℝ)→ℝ) (hF:Measurable F) (hLip:SquareLipschitz F)
    (A:Set (Fin n→ℝ)) (hA:MeasurableSet A)
    (hmass:(1/2:ℝ)≤(standardGaussian n).real A) (hzero:∀x∈A,F x=0)
    (s:ℝ) {θ:ℝ} (hθ:0<θ):
    (standardGaussian n).real {x|s≤F x^2}≤
      Real.exp (Real.log 2/θ-s/(2*(1+θ))) := by
  classical
  let B:Set (Fin n→ℝ):={x|s≤F x^2}
  have hB:MeasurableSet B:=measurableSet_le measurable_const (hF.pow_const 2)
  by_cases hpz:(standardGaussian n).real B=0
  · change (standardGaussian n).real B≤_
    rw [hpz]
    positivity
  have hp:0<(standardGaussian n).real B:=lt_of_le_of_ne measureReal_nonneg (Ne.symm hpz)
  have hB0:standardGaussian n B≠0:=by
    intro h
    simp only [Measure.real,h,ENNReal.toReal_zero] at hp
    linarith
  let Q:=cond (standardGaussian n) B
  letI:IsProbabilityMeasure Q:=cond_isProbabilityMeasure hB0
  have hlow:ENNReal.ofReal s≤∫⁻x,ENNReal.ofReal (F x^2) ∂Q:=by
    calc
      _ = ∫⁻_x,ENNReal.ofReal s ∂Q:=by simp
      _ ≤ _:=by
        apply lintegral_mono_ae
        filter_upwards [ae_cond_mem (μ:=standardGaussian n) hB] with x hx
        exact ENNReal.ofReal_le_ofReal hx
  have hbase:=gaussian_zeroSet_secondMoment_le_log_two F hF hLip A hA hmass hzero
  have htran:=gaussian_secondMoment_transport_weighted F hF hLip Q hθ
  have hkl:klDiv Q (standardGaussian n)=ENNReal.ofReal (-Real.log ((standardGaussian n).real B)):=
    klDiv_cond_eq (standardGaussian n) B hB hB0
  rw [hkl] at htran
  have htotal:=hlow.trans (htran.trans (add_le_add (mul_le_mul' le_rfl hbase) le_rfl))
  have hl2:0≤Real.log 2:=Real.log_nonneg (by norm_num)
  have hp1:(standardGaussian n).real B≤1:=(measureReal_mono (Set.subset_univ B)).trans_eq probReal_univ
  have hlp:0≤-Real.log ((standardGaussian n).real B):=neg_nonneg.mpr (Real.log_nonpos hp.le hp1)
  have ha:0≤1+θ⁻¹:=by positivity
  have hb:0≤2*(1+θ):=by positivity
  have he:ENNReal.ofReal (1+θ⁻¹)*ENNReal.ofReal (2*Real.log 2)+
      ENNReal.ofReal (2*(1+θ))*ENNReal.ofReal (-Real.log ((standardGaussian n).real B))=
      ENNReal.ofReal ((1+θ⁻¹)*(2*Real.log 2)+2*(1+θ)*(-Real.log ((standardGaussian n).real B))):=by
    rw [←ENNReal.ofReal_mul ha,←ENNReal.ofReal_mul hb,←ENNReal.ofReal_add (by positivity) (by positivity)]
  rw [he] at htotal
  have hreal: s≤(1+θ⁻¹)*(2*Real.log 2)+2*(1+θ)*(-Real.log ((standardGaussian n).real B)):=
    (ENNReal.ofReal_le_ofReal_iff (by positivity)).mp htotal
  have hlog:Real.log ((standardGaussian n).real B)≤Real.log 2/θ-s/(2*(1+θ)):=by
    apply (mul_le_mul_iff_right₀ (by positivity : 0<2*(1+θ))).mp
    have heq:(2*(1+θ))*(Real.log 2/θ-s/(2*(1+θ)))=
        (1+θ⁻¹)*(2*Real.log 2)-s:=by field_simp;ring
    rw [heq]
    linarith
  have he:=Real.exp_le_exp.mpr hlog
  rw [Real.exp_log hp] at he
  exact he

end NeuralGeneralization.BatchTwoContinuousDepthPower
