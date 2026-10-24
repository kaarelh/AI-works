import NeuralGeneralization.BatchTwoOnlineMeanFieldExactBudgets

/-! Sampling probabilities for the literal finite-description budgets. -/
noncomputable section
set_option maxHeartbeats 1000000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineMeanFieldExact
open ConcreteModel

theorem compressedWidth_pos (d r : ℕ) {K : ℝ} (hK : 0<K) :
    0<compressedWidth d r K := by
  have he:=covariancePrecision_pos r hK
  have hpow:1≤(2:ℝ)^(2*d):=one_le_pow₀ (by norm_num)
  have harg:1<8*(r+1:ℝ)*(2:ℝ)^(2*d):=by nlinarith [Nat.cast_nonneg r (α:=ℝ)]
  unfold compressedWidth
  apply Nat.ceil_pos.mpr
  exact mul_pos (by positivity) (Real.log_pos harg)

theorem compressedBound_ge_one (d r : ℕ) (K : ℝ) : 1≤compressedBound d r K :=
  (le_max_left _ _).trans (le_max_left _ _)

theorem compressedBound_readout (d r : ℕ) (K : ℝ) :
    4*K/(compressedWidth d r K:ℝ)≤compressedBound d r K :=le_max_right _ _

theorem covariance_sampling_probability (d r : ℕ) {K : ℝ} (hK : 0<K) :
    2*(Fintype.card (Cube d):ℝ)^2*
      Real.exp (-(compressedWidth d r K:ℝ)*(covariancePrecision r K)^2/2)≤1/4 := by
  have hη:=covariancePrecision_pos r hK
  let V:ℝ:=(2:ℝ)^(2*d)
  have hV:0<V:=by dsimp [V];positivity
  have hvcard:(Fintype.card (Cube d):ℝ)^2=V:=by
    simp [Cube,Fintype.card_fun,V,←pow_mul,Nat.mul_comm]
  have harg:0<8*(r+1:ℝ)*V:=by positivity
  have hc:2*(covariancePrecision r K)⁻¹^2*Real.log (8*(r+1:ℝ)*V)≤
      (compressedWidth d r K:ℝ):=Nat.le_ceil _
  have hscale:Real.log (8*(r+1:ℝ)*V)≤
      (compressedWidth d r K:ℝ)*(covariancePrecision r K)^2/2:=by
    have hh:=mul_le_mul_of_nonneg_right hc (sq_nonneg (covariancePrecision r K))
    have heq:2*(covariancePrecision r K)⁻¹^2*Real.log (8*(r+1:ℝ)*V)*
        (covariancePrecision r K)^2=2*Real.log (8*(r+1:ℝ)*V):=by field_simp
    rw [heq] at hh
    linarith
  rw [hvcard]
  calc
    _ ≤ 2*V*Real.exp (-Real.log (8*(r+1:ℝ)*V)):=by
      gcongr
      linarith
    _ = 1/(4*(r+1:ℝ)):=by rw [Real.exp_neg,Real.exp_log harg];field_simp;ring
    _ ≤ 1/4:=by
      apply (div_le_div_iff₀ (by positivity) (by norm_num)).mpr
      nlinarith [Nat.cast_nonneg r (α:=ℝ)]

theorem coordinate_sampling_probability (d r : ℕ) {K : ℝ} (hK : 0<K)
    {M : ℝ} (hM : 0≤M)
    (hMD : M≤max (hiddenParameterCount d (compressedWidth d r K) r:ℝ) 1) :
    2*M*Real.exp (2*maxTilt r K-(compressedBound d r K)^2/2)≤1/4 := by
  let D:ℝ:=max (hiddenParameterCount d (compressedWidth d r K) r:ℝ) 1
  have hD:1≤D:=le_max_right _ _
  have hD0:0<D:=by linarith
  have hg:0<maxTilt r K:=layerBudget_pos r hK 1
  have hlog:0≤Real.log (8*D):=Real.log_nonneg (by linarith)
  have hb:Real.sqrt (4*maxTilt r K+2*Real.log (8*D))≤compressedBound d r K:=
    (le_max_right _ _).trans (le_max_left _ _)
  have hB:0≤compressedBound d r K:=(by linarith [compressedBound_ge_one d r K])
  have hsq:4*maxTilt r K+2*Real.log (8*D)≤(compressedBound d r K)^2:=by
    have hh:=sq_le_sq₀ (Real.sqrt_nonneg _) hB |>.mpr hb
    rwa [Real.sq_sqrt (by positivity)] at hh
  calc
    _ ≤ 2*M*Real.exp (-Real.log (8*D)):=by gcongr;nlinarith
    _ = M/(4*D):=by rw [Real.exp_neg,Real.exp_log (by positivity)];field_simp;ring
    _ ≤ 1/4:=by
      apply (div_le_div_iff₀ (by positivity) (by norm_num)).mpr
      change M≤D at hMD
      nlinarith

theorem input_sampling_budget (d r : ℕ) {K : ℝ} (hK : 0<K) :
    2*(Fintype.card (Cube d):ℝ)^2*
      Real.exp (-(compressedWidth d r K:ℝ)*(covariancePrecision r K)^2/2)+
    2*(compressedWidth d r K:ℝ)*(d+1:ℝ)*
      Real.exp (2*maxTilt r K-(compressedBound d r K)^2/2)<1 := by
  have hMD:(compressedWidth d r K:ℝ)*(d+1:ℝ)≤
      max (hiddenParameterCount d (compressedWidth d r K) r:ℝ) 1:=by
    apply le_trans _ (le_max_left _ _)
    unfold hiddenParameterCount
    push_cast
    have hh:0≤(r:ℝ)*(compressedWidth d r K:ℝ)^2:=by positivity
    linarith
  have hcov:=covariance_sampling_probability d r hK
  have hrow:=coordinate_sampling_probability d r hK (by positivity) hMD
  have heq:2*(compressedWidth d r K:ℝ)*(d+1:ℝ)=
      2*((compressedWidth d r K:ℝ)*(d+1:ℝ)):=by ring
  rw [heq]
  linarith

theorem hidden_sampling_budget (d r : ℕ) (hr : 1≤r) {K : ℝ} (hK : 0<K) :
    2*(Fintype.card (Cube d):ℝ)^2*
      Real.exp (-(compressedWidth d r K:ℝ)*(covariancePrecision r K)^2/2)+
    2*(compressedWidth d r K:ℝ)*(compressedWidth d r K:ℝ)*
      Real.exp (2*maxTilt r K-(compressedBound d r K)^2/2)<1 := by
  have hMD:(compressedWidth d r K:ℝ)*(compressedWidth d r K:ℝ)≤
      max (hiddenParameterCount d (compressedWidth d r K) r:ℝ) 1:=by
    apply le_trans _ (le_max_left _ _)
    unfold hiddenParameterCount
    push_cast
    have hrR:(1:ℝ)≤r:=by exact_mod_cast hr
    have hh:=mul_le_mul_of_nonneg_right hrR (sq_nonneg (compressedWidth d r K:ℝ))
    nlinarith [Nat.cast_nonneg (compressedWidth d r K) (α:=ℝ),Nat.cast_nonneg d (α:=ℝ)]
  have hcov:=covariance_sampling_probability d r hK
  have hrow:=coordinate_sampling_probability d r hK (by positivity) hMD
  have heq:2*(compressedWidth d r K:ℝ)*(compressedWidth d r K:ℝ)=
      2*((compressedWidth d r K:ℝ)*(compressedWidth d r K:ℝ)):=by ring
  rw [heq]
  linarith

end NeuralGeneralization.BatchTwoOnlineMeanFieldExact
