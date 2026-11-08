import NeuralGeneralization.OnlineLowerTanhResidualCLT
import NeuralGeneralization.OnlineLowerTanhMonotone
import NeuralGeneralization.OnlineLowerTanhAllGainLimit
import NeuralGeneralization.OnlineLowerCentralBinomialLimit

/-! # Identifying the periodic response from actual balanced tanh correlations -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators Topology
open MeasureTheory Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

noncomputable def balancedResidualSequence (a : ℝ) (ha : 0 < a) : ResidualSequence Unit where
  N := fun r => 2*r+1
  N_pos := fun r => by omega
  N_tendsto := StrictMono.tendsto_atTop (fun i j hij => by omega)
  label := fun _ _ => ()
  q := fun _ => 1
  q_odd := fun _ => by decide
  c := fun _ => 1
  bezout := by simp
  α := 1
  Q := 1
  lo := a
  hi := a
  K := 0
  α_pos := by norm_num
  Q_pos := by norm_num
  lo_pos := ha
  K_nonneg := by norm_num
  freq := by intro k j; cases j; simp
  q_bound := fun _ => by norm_num
  A := fun _ => a
  D := fun _ => 0
  A₀ := a
  E := 0
  A_lo := fun _ => le_refl _
  A_hi := fun _ => le_refl _
  A₀_lo := le_refl _
  A₀_hi := le_refl _
  A_tendsto := tendsto_const_nhds
  D_tendsto := tendsto_const_nhds
  d := fun _ _ => 0
  d_bound := fun _ _ => by simp
  orthogonal := fun _ => by simp
  energy_tendsto := by simpa using (tendsto_const_nhds (x := (0:ℝ)))
  energy_bound := fun _ => by simp

lemma residualVariance_one (n : ℕ) : residualVariance (fun _ : Fin n => 1) = n := by
  simp [residualVariance]

lemma residualPhaseSign_one (r : ℕ) : residualPhaseSign (fun _ : Fin (2*r+1) => 1) = (-1:ℝ)^r := by
  have hr : (2*r+1)/2=r := by omega
  simp [residualPhaseSign,hr]

lemma smoothedResponse_zero (a b : ℝ) : smoothedResponse a 0 b = periodicFourierResponse a b := by
  simp [smoothedResponse,smoothedCoefficient,periodicFourierResponse]

lemma gaussian_height_identity : Real.sqrt (2*Real.pi)/Real.pi = Real.sqrt (2/Real.pi) := by
  rw [Real.sqrt_div (by norm_num : (0:ℝ)≤2),Real.sqrt_mul (by norm_num : (0:ℝ)≤2)]
  have hp := Real.sqrt_pos.mpr Real.pi_pos
  field_simp
  nlinarith [Real.sq_sqrt Real.pi_pos.le]

lemma balanced_periodic_approximation (a : ℝ) (ha : 0 < a) :
    ∀ ε > 0, ∀ᶠ r : ℕ in atTop, ∀ B : ℝ,
      |(-1:ℝ)^r*Real.sqrt (2*(r:ℝ)+1)*parityCorrelation (fun _ : Fin (2*r+1) => a) B -
        Real.sqrt (2/Real.pi)*Real.exp (-(B*residualScale a (fun _ : Fin (2*r+1) => 1))^2/2)*
          periodicFourierResponse a (B+a)| < ε := by
  intro ε hε
  have ht := (balancedResidualSequence a ha).uniform_residual_clt ε hε
  filter_upwards [ht] with r hr B
  have hh := hr B
  unfold ResidualSequence.incoming ResidualSequence.alphabet at hh
  dsimp only [balancedResidualSequence] at hh
  simp only [Nat.cast_one,mul_one,add_zero,residualVariance_one] at hh
  have hsg : (-1:ℝ)^r*((-1:ℝ)^r) = 1 := by rw [← pow_add,← two_mul,pow_mul]; norm_num
  have hn : ((2*r+1:ℕ):ℝ) = 2*(r:ℝ)+1 := by push_cast; ring
  have hlead : Real.sqrt ((2*r+1:ℕ):ℝ)*residualLeading (fun _ : Fin (2*r+1) => 1)
      (fun _ => 0) a B =
      (-1:ℝ)^r*Real.sqrt (2/Real.pi)*
        Real.exp (-(B*residualScale a (fun _ : Fin (2*r+1) => 1))^2/2)*periodicFourierResponse a (B+a) := by
    unfold residualLeading
    rw [residualPhaseSign_one]
    simp only [zero_pow (by decide : 2≠0),Finset.sum_const_zero,smoothedResponse_zero]
    have hmod : (2*r+1)%2=1 := by omega
    rw [hmod,Nat.cast_one,one_mul]
    rw [← residual_gaussian_exponent (by omega) _ (fun _ => by norm_num) ha]
    have hnorm := residual_sqrt_normalization (by omega : 0<2*r+1)
      (fun _ : Fin (2*r+1) => 1) (fun _ => by norm_num)
    rw [residualVariance_one,gaussian_height_identity] at hnorm
    rw [residualVariance_one]
    linear_combination ((-1:ℝ)^r*Real.exp (-(B*residualScale a (fun _ : Fin (2*r+1) => 1))^2/2)*
      periodicFourierResponse a (B+a))*hnorm
  have he : |(-1:ℝ)^r*Real.sqrt (2*(r:ℝ)+1)*parityCorrelation (fun _ : Fin (2*r+1) => a) B -
      Real.sqrt (2/Real.pi)*Real.exp (-(B*residualScale a (fun _ : Fin (2*r+1) => 1))^2/2)*
        periodicFourierResponse a (B+a)| =
      Real.sqrt ((2*r+1:ℕ):ℝ)*|parityCorrelation (fun _ : Fin (2*r+1) => a) B-
        residualLeading (fun _ : Fin (2*r+1) => 1) (fun _ => 0) a B| := by
    have heq : (-1:ℝ)^r*Real.sqrt (2*(r:ℝ)+1)*parityCorrelation (fun _ : Fin (2*r+1) => a) B -
        Real.sqrt (2/Real.pi)*Real.exp (-(B*residualScale a (fun _ : Fin (2*r+1) => 1))^2/2)*
          periodicFourierResponse a (B+a) =
        (-1:ℝ)^r*(Real.sqrt ((2*r+1:ℕ):ℝ)*(parityCorrelation (fun _ : Fin (2*r+1) => a) B-
          residualLeading (fun _ : Fin (2*r+1) => 1) (fun _ => 0) a B)) := by
      rw [mul_sub,hlead,hn]
      linear_combination (Real.sqrt (2/Real.pi)*
        Real.exp (-(B*residualScale a (fun _ : Fin (2*r+1) => 1))^2/2)*
        periodicFourierResponse a (B+a))*hsg
    rw [heq,abs_mul,abs_mul,abs_pow,abs_neg,abs_one,one_pow,one_mul,
      abs_of_nonneg (Real.sqrt_nonneg _)]
  rw [he]
  exact hh

lemma balanced_residualScale_tendsto (a : ℝ) (ha : 0 < a) :
    Tendsto (fun r : ℕ => residualScale a (fun _ : Fin (2*r+1) => 1)) atTop (𝓝 0) :=
  residualScale_tendsto (fun r => 2*r+1) (fun _ _ => 1)
    (StrictMono.tendsto_atTop (fun i j hij => by omega)) (fun _ _ => by norm_num)
    (fun _ => a) tendsto_const_nhds ha.ne'

theorem balanced_biased_scaled_tendsto (a : ℝ) (ha : 0 < a) (B : ℝ) :
    Tendsto (fun r : ℕ => (-1:ℝ)^r*Real.sqrt (2*(r:ℝ)+1)*
      parityCorrelation (fun _ : Fin (2*r+1) => a) B) atTop
      (𝓝 (Real.sqrt (2/Real.pi)*periodicFourierResponse a (B+a))) := by
  have hs := balanced_residualScale_tendsto a ha
  have harg := ((hs.const_mul B).pow 2).neg.div_const 2
  simp only [mul_zero,zero_pow (by decide : 2≠0),neg_zero,zero_div] at harg
  have hexp := Real.continuous_exp.continuousAt.tendsto.comp harg
  simp only [Real.exp_zero] at hexp
  have hm := (hexp.const_mul (Real.sqrt (2/Real.pi))).mul_const
    (periodicFourierResponse a (B+a))
  simp only [mul_one] at hm
  have herr : Tendsto (fun r : ℕ => (-1:ℝ)^r*Real.sqrt (2*(r:ℝ)+1)*
      parityCorrelation (fun _ : Fin (2*r+1) => a) B -
      Real.sqrt (2/Real.pi)*Real.exp (-(B*residualScale a (fun _ : Fin (2*r+1) => 1))^2/2)*
        periodicFourierResponse a (B+a)) atTop (𝓝 0) := by
    rw [Metric.tendsto_nhds]
    intro ε hε
    filter_upwards [balanced_periodic_approximation a ha ε hε] with r hr
    simpa only [Real.dist_eq,sub_zero] using hr B
  simpa only [Function.comp_apply,sub_add_cancel,zero_add] using herr.add hm

/-- The Fourier-defined periodic maximum is the same scalar F₀ obtained
independently from the exact binomial/hyperbolic representation. -/
theorem periodicFourierMaximum_eq_scalarF0 (a : ℝ) (ha : 0 < a) :
    periodicFourierMaximum a = scalarF0 a := by
  have hp := balanced_biased_scaled_tendsto a ha 0
  simp only [zero_add] at hp
  have hp' : Tendsto (fun r : ℕ => Real.sqrt (2*(r:ℝ)+1)*balancedParity r a)
      atTop (𝓝 (Real.sqrt (2/Real.pi)*periodicFourierMaximum a)) := by
    unfold periodicFourierMaximum
    convert hp using 1
    funext r
    unfold balancedParity
    ring
  have hf := scaled_oddParityKappa_tendsto.mul (balancedParity_normalized_tendsto a ha)
  have hf' : Tendsto (fun r : ℕ => Real.sqrt (2*(r:ℝ)+1)*balancedParity r a)
      atTop (𝓝 (Real.sqrt (2/Real.pi)*scalarF0 a)) := by
    convert hf using 1
    funext r
    field_simp [(oddParityKappa_pos r).ne']
  have he := tendsto_nhds_unique hp' hf'
  exact (mul_left_cancel₀ (Real.sqrt_pos.mpr (by positivity : 0 < 2/Real.pi)).ne') he

/-- The periodic response is globally bounded by one at every positive
gain, including gains outside the compact interval used for sharp maxima. -/
theorem periodicFourierResponse_abs_le_one (a : ℝ) (ha : 0 < a) (b : ℝ) :
    |periodicFourierResponse a b| ≤ 1 := by
  have ht := (balanced_biased_scaled_tendsto a ha (b-a)).abs
  have hbound (r : ℕ) :
      |(-1:ℝ)^r*Real.sqrt (2*(r:ℝ)+1)*parityCorrelation (fun _ : Fin (2*r+1) => a) (b-a)| ≤
      Real.sqrt (2*(r:ℝ)+1)*oddParityKappa r := by
    rw [abs_mul,abs_mul,abs_pow,abs_neg,abs_one,one_pow,one_mul,
      abs_of_nonneg (Real.sqrt_nonneg _)]
    exact mul_le_mul_of_nonneg_left (parityCorrelation_monotone_cap r _ _)
      (Real.sqrt_nonneg _)
  have hh := le_of_tendsto_of_tendsto' ht scaled_oddParityKappa_tendsto hbound
  rw [sub_add_cancel,abs_mul,abs_of_nonneg (Real.sqrt_nonneg _)] at hh
  have hc : 0 < Real.sqrt (2/Real.pi) := Real.sqrt_pos.mpr (by positivity)
  nlinarith

end NeuralGeneralization.OnlineLowerTanh
