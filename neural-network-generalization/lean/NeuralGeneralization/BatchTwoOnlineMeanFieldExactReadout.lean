import NeuralGeneralization.MeanFieldReadoutTail

/-! The appendix uses K≥4; the weaker NK/8 rate holds already there. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoOnlineMeanFieldExact
open ConcreteModel

theorem gaussian_squaredNorm_tail_eighth {ι : Type*} [Fintype ι]
    (v : ℝ≥0) (hv : 0<(v:ℝ)) (u : ℝ)
    (hu : 4*(Fintype.card ι:ℝ)*(v:ℝ)≤u) :
    (Measure.pi (fun _:ι=>gaussianReal 0 v)).real {x:ι→ℝ|u≤∑i,x i^2}≤
      Real.exp (-u/(8*(v:ℝ))) := by
  have h:=GaussianTail.gaussian_squaredNorm_rate_upper (ι:=ι) v hv u (1/4)
    (by norm_num) (by norm_num)
  have hsqrt:(Real.sqrt (1/4:ℝ))⁻¹=2:=by
    rw [show (1/4:ℝ)=(1/2:ℝ)^2 by norm_num,Real.sqrt_sq_eq_abs]
    norm_num
  rw [hsqrt] at h
  have hpow:(2:ℝ)^Fintype.card ι≤Real.exp (Fintype.card ι:ℝ):=by
    have he:(2:ℝ)≤Real.exp 1:=by linarith [Real.add_one_le_exp (1:ℝ)]
    simpa only [←Real.exp_nat_mul,mul_one] using
      pow_le_pow_left₀ (by norm_num: (0:ℝ)≤2) he (Fintype.card ι)
  apply h.trans
  calc
    _ ≤ Real.exp (-((1-1/4)*u)/(2*(v:ℝ)))*Real.exp (Fintype.card ι:ℝ):=
      mul_le_mul_of_nonneg_left hpow (Real.exp_pos _).le
    _ = Real.exp (-((1-1/4)*u)/(2*(v:ℝ))+Fintype.card ι):=(Real.exp_add _ _).symm
    _ ≤ _:=by
      apply Real.exp_le_exp.mpr
      apply (le_div_iff₀ (by positivity:0<8*(v:ℝ))).mpr
      have he:(-((1-1/4)*u)/(2*(v:ℝ))+Fintype.card ι)*(8*(v:ℝ))=
          -3*u+8*Fintype.card ι*(v:ℝ):=by field_simp;ring
      rw [he]
      linarith

theorem readout_bad_tail {d N r : ℕ} (hd : 0<d) (hN : 0<N)
    (K : ℝ) (hK : 4≤K) :
    (powerPrior d N r 1).real {w|K<(N:ℝ)*(∑i,w (.inr (.inr i))^2)}≤
      Real.exp (-(N:ℝ)*K/8) := by
  let e:Fin N→WeightIndex d N r:=fun i=>Sum.inr (Sum.inr i)
  have he:Function.Injective e:=Sum.inr_injective.comp Sum.inr_injective
  have hmap:=map_powerPrior_whiten_subfamily hd hN 1 e he
  have hmeas:Measurable (fun w:Weights d N r=>fun j=>whiten w (e j)):=
    measurable_pi_lambda _ fun j=>(measurable_pi_apply (e j)).comp (continuous_whiten d N r).measurable
  have hm:=Measure.le_map_apply (μ:=powerPrior d N r 1) hmeas.aemeasurable
    {z:Fin N→ℝ|K≤∑j,z j^2}
  rw [hmap] at hm
  have hNR:0<(N:ℝ):=by exact_mod_cast hN
  have hv:(((N:ℝ)^(-(1:ℝ))).toNNReal:ℝ)=(N:ℝ)⁻¹:=by
    rw [Real.rpow_neg_one,Real.toNNReal_of_nonneg (by positivity)]
    rfl
  have ht:=gaussian_squaredNorm_tail_eighth (ι:=Fin N) ((N:ℝ)^(-(1:ℝ))).toNNReal
    (by rw [hv];positivity) K (by simp only [Fintype.card_fin,hv];field_simp;linarith)
  have hh: -K/(8*((((N:ℝ)^(-(1:ℝ))).toNNReal):ℝ))=-(N:ℝ)*K/8:=by rw [hv];field_simp
  rw [hh] at ht
  apply le_trans _ ((ENNReal.toReal_mono (measure_ne_top _ _) hm).trans ht)
  apply measureReal_mono _ (measure_ne_top _ _)
  intro w hw
  change K≤∑j,whiten w (e j)^2
  rw [←readout_energy_eq_whitened hd hN]
  exact hw.le

end NeuralGeneralization.BatchTwoOnlineMeanFieldExact
