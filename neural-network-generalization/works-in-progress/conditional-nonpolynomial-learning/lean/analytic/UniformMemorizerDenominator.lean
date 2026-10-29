import CriticalWidthResources
import TaggedFourierPathNetworkMass
import UniformSeedCalibration
import UniformMemorizerSeed
import UniformTargetPolynomial
import TaggedTrackingEntropy
import NeuralGeneralization.FunctionPrior

noncomputable section
set_option maxHeartbeats 5000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization NeuralGeneralization.ConcreteModel

/-- Arithmetic budget estimates suffice to turn the actual uniform program
into a denominator theorem with one width threshold independent of t. -/
theorem uniform_memorizer_denominator_of_budgets (C Cw : ℝ) (hC : 0<C) (hCw : 1≤Cw)
    (hbudgets : ∀(t v R : ℝ) (H : ℕ),0<t→t≤1→0<v→v≤1→2≤R→1≤H→(H:ℝ)+1≤R→
      targetLogBudget v H≤26*Real.log R→6656*targetProgramConstant*Real.log R≤(H:ℝ)→
      uniformTargetPhysicalBudget t v H+2/((H:ℝ)*t^2)≤
        (H:ℝ)*subcriticalCostBaseline (t^2).toNNReal+scalarBaseline.toReal+
          C*(((t^2)⁻¹-1)*Real.log R+(Real.log R)^2/(H:ℝ)) ∧
      t^2*uniformTargetPhysicalBudget t v H+2/(H:ℝ)+1≤Cw*R^2 ∧
      8*uniformTargetCriticalBudget v H≤Cw*R^2) :
    ∃W : ℕ,1≤W ∧
    ∀(d n H N : ℕ) (sample : Fin n→Cube d) (f : BooleanFunction d) (R t : ℝ),
      1≤d→1≤H→2≤R→(d:ℝ)+1≤R→(n:ℝ)≤R→(H:ℝ)+1≤R→
      0<t→t≤1→6656*targetProgramConstant*Real.log R≤(H:ℝ)→
      (2:ℝ)^d*R^W≤(N:ℝ)→
      Real.exp (-(N:ℝ)*((H:ℝ)*subcriticalCostBaseline (t^2).toNNReal+scalarBaseline.toReal+
        C*(((t^2)⁻¹-1)*Real.log R+(Real.log R)^2/(H:ℝ))))≤
        posteriorDenominator Real.tanh (1/2) (smallPrior d N H (t/Real.sqrt N)) f sample := by
  let K := 26*Real.sqrt 2*targetEntropyConstant
  obtain ⟨k,hk,hkD,hkK,hkC,_⟩ := exists_common_natural_exponent targetSignalExponent K (2*Cw) 1
  let q := k+7
  let W := 20*q+28
  refine ⟨W,by dsimp [W]; omega,?_⟩
  intro d n H N sample f R t hd hH hR hdR hnR hHR ht ht1 hdepth hwidth
  have hR0 : 0<R := by linarith
  have hR1 : 1≤R := by linarith
  have hH0 : (0:ℝ)<H := by exact_mod_cast (show 0<H by omega)
  have hHr : (1:ℝ)≤H := by exact_mod_cast hH
  have hN0 : (0:ℝ)<N := (mul_pos (pow_pos (by norm_num : (0:ℝ)<2) _) (pow_pos hR0 _)).trans_le hwidth
  have hN : 0<N := by exact_mod_cast hN0
  let G : BooleanFunction d := pointExceptionBoolean (negativeSamplePoints sample f)
  let g : Cube d→ℝ := fun x=>labelReal (G x)
  have hfun : pointExceptionFunction (negativeSamplePoints sample f)=g := by
    funext x
    exact (pointExceptionBoolean_label _ x).symm
  have hseed := uniform_memorizer_seed_state sample f hd hH t ht ht1 hR hdR hnR hHR
  rw [hfun] at hseed
  rcases hseed with ⟨hθ,hθ1,hv,hr,hq,hvR,hT,hscore⟩
  let θ := rareCalibration (seedEntropyBudget d (1/Real.sqrt d)) H
  let v := rareSeedSignal g (t/Real.sqrt d) θ
  let r := rareSeedResidual g (t/Real.sqrt d) θ
  have hv1 : v≤1 := by linarith
  have hprep : 256*targetProgramConstant*targetLogBudget v H≤(H:ℝ) := by
    have hm := mul_le_mul_of_nonneg_left hT (show 0≤256*targetProgramConstant by positivity [targetProgramConstant_ge])
    nlinarith
  obtain ⟨P,Comp,hPLen,hCLen,hControl,hPBound,hCompCost,hRead,hsqrt,hPCost,hterm⟩ :=
    exists_exact_uniform_target_program hv (show 0≤1-v by linarith) (by linarith : v+(1-v)≤1)
      ht ht1 hr (by linarith : r≤1-v) H hprep
  let B := Real.exp (targetSignalExponent*Real.log R)+1
  let S := K*Real.log R
  let A := t^2*uniformTargetPhysicalBudget t v H+1/(H:ℝ)
  let τ : ℝ := 1/(H:ℝ)
  have hτ : 0<τ := by dsimp [τ]; positivity
  have hPnonneg : 0≤P.cost := by
    have hvp := (P.state_pos P.length).1
    rw [P.state_terminal] at hvp
    rw [TaggedScalarPath.cost,P.priorHiddenCost_eq_sum]
    positivity
  have hA : 0≤A := by dsimp [A]; linarith
  have hB : 1≤B := by dsimp [B]; linarith [Real.exp_pos (targetSignalExponent*Real.log R)]
  have hBseed : 1/Real.sqrt θ≤B := by
    have hDpoly := critical_seed_entropy_polynomial hd hR hdR
    have hh := (calibrated_score_polynomial (seedEntropyBudget_nonneg d (1/Real.sqrt d))
      hHr hR hDpoly (by linarith : (H:ℝ)≤R)).trans (thirteenth_power_le_targetBound hR)
    dsimp [B]
    linarith
  have hf : Real.exp (-targetSignalExponent*Real.log R)≤cooledSeedFloor v H/2 :=
    cooledSeedFloor_polynomial hv hR hvR H hHR
  have hBpath : P.bound≤B := by
    have hsi := Real.sqrt_le_sqrt hf
    have hpos : 0<Real.sqrt (Real.exp (-targetSignalExponent*Real.log R)) := by positivity
    have hi := (one_div_le_one_div_of_le hpos hsi).trans (inverse_sqrt_polynomialFloor_le hR)
    dsimp [B]
    linarith
  have hS : channelEntropyPrefix (fun j=>(klDiv (P.control j) (taggedGaussianReference 1)).toReal) P.length≤S := by
    rw [hPLen]
    have hh := tagged_reused_tracking_entropy P Comp.control H (fun j _=>Comp.control_probability j) hControl hsqrt
    have hlog := uniformTargetSqrtBudget_logarithmic hv hv1 H (by omega)
    have hm := mul_le_mul_of_nonneg_left hT targetEntropyConstant_nonneg
    have hsm := mul_le_mul_of_nonneg_left (hlog.trans hm) (Real.sqrt_nonneg 2)
    dsimp [S,K]
    nlinarith only [hh,hsm]
  have hbase : t^2*(θ*seedEntropyBudget d (t/Real.sqrt d))+P.cost≤A := by
    have hh := calibrated_uniform_seed_cost hd ht hHr
    dsimp [A]
    linarith
  have hvp := (P.state_pos P.length).1
  rw [P.state_terminal] at hvp
  obtain ⟨hfinal,hAnorm,hKnorm⟩ := hbudgets t v R H ht ht1 hv hv1 hR hH hHR hT hdepth
  have hkq : k≤q := by dsimp [q]; omega
  have hpow : R^k≤R^q := pow_le_pow_right₀ hR1 hkq
  have hEpoly : Real.exp (targetSignalExponent*Real.log R)≤R^k := exp_log_bound_to_power hR1 le_rfl hkD
  have hBpoly : B≤R^q := by
    have h1 : 1≤R^k := one_le_pow₀ hR1
    have hh : B≤R^(k+1) := by dsimp [B]; rw [pow_succ]; nlinarith
    exact hh.trans (pow_le_pow_right₀ hR1 (by dsimp [q]; omega))
  have hSpoly : Real.exp S≤R^q := (exp_log_bound_to_power hR1 le_rfl hkK).trans hpow
  have hconst : Cw≤R^k := constant_le_power hR hkC
  have hpoly2 : Cw*R^2≤R^(k+2) := by rw [pow_add]; exact mul_le_mul_of_nonneg_right hconst (sq_nonneg R)
  have hAp : A+τ+1≤R^(k+2) := by
    calc
      _ = t^2*uniformTargetPhysicalBudget t v H+2/(H:ℝ)+1 := by dsimp [A,τ]; ring
      _ ≤ _ := hAnorm.trans hpoly2
  have hCompNonneg : 0≤Comp.hiddenCost := by rw [Comp.hiddenCost_eq_sum]; positivity
  have hvinv : 1/P.terminal.1≤8*uniformTargetCriticalBudget v H := by
    have he : 1/P.terminal.1=8*(1/(8*P.terminal.1)) := by ring
    rw [he]
    linarith
  have hvpoly : 1/P.terminal.1≤R^q := (hvinv.trans (hKnorm.trans hpoly2)).trans
    (pow_le_pow_right₀ hR1 (by dsimp [q]; omega))
  have hκpoly : 1/channelSlackProbability A τ≤R^q :=
    critical_slack_inverse_polynomial hH hR (by linarith) hAp
  have hq : 1≤q := by dsimp [q]; omega
  have hRq : R≤R^q := by simpa only [pow_one] using pow_le_pow_right₀ hR1 hq
  have hτpoly : 1/τ≤R^q := by dsimp [τ]; simpa using (show (H:ℝ)≤R^q by linarith)
  have hM : (Fintype.card (Cube d):ℝ)=(2:ℝ)^d := by simp [Cube]
  have hwidth' : finiteChannelWidthBudget (Fintype.card (Cube d)) P.length B S P.terminal.1
      (channelSlackProbability A τ) τ≤(N:ℝ) := by
    apply (finiteChannelWidthBudget_polynomial hR (by rw [hM]; exact one_le_pow₀ (by norm_num))
      (by dsimp [B]; positivity) hvp (channelSlackProbability_pos hA hτ) hτ
      (by rw [hPLen]; linarith) hBpoly hSpoly hvpoly hκpoly hτpoly).trans
    simpa only [hM,W] using hwidth
  have hraw := taggedFourierPathNetwork_raw_mass hd hN ht ht1 G hθ hθ1 P hterm hB hBseed hBpath
    hS hA hτ hbase hwidth'
  rw [hPLen] at hraw
  have he : (A+τ)/t^2=uniformTargetPhysicalBudget t v H+2/((H:ℝ)*t^2) := by
    dsimp [A,τ]
    field_simp
    ring
  have hexp : Real.exp (-(N:ℝ)*((H:ℝ)*subcriticalCostBaseline (t^2).toNNReal+scalarBaseline.toReal+
        C*(((t^2)⁻¹-1)*Real.log R+(Real.log R)^2/(H:ℝ))))≤
      Real.exp (-(N:ℝ)*(A+τ)/t^2) := by
    have hh : (A+τ)/t^2≤_ := he.le.trans hfinal
    apply Real.exp_le_exp.mpr
    calc
      _ ≤ -(N:ℝ)*((A+τ)/t^2) := mul_le_mul_of_nonpos_left hh (by linarith)
      _ = _ := by ring
  have hconsistent : consistent f sample G := pointExceptionBoolean_fits_sample sample f
  have hmass : (smallPrior d N H (t/Real.sqrt N)).real (marginEvent Real.tanh (1/2) G)≤
      posteriorDenominator Real.tanh (1/2) (smallPrior d N H (t/Real.sqrt N)) f sample := by
    exact weight_le_normalizer _ _ (functionMass_nonneg _ _ _) G hconsistent
  exact (hexp.trans hraw).trans hmass

#print axioms uniform_memorizer_denominator_of_budgets
end ConditionalNonpolynomial.Analytic
