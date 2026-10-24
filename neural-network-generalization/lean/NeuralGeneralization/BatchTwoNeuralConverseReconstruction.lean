import NeuralGeneralization.BatchTwoNeuralConverseCompressionExistence
import NeuralGeneralization.BatchTwoNeuralConverseConventions
import NeuralGeneralization.MarginRescaling

/-! Reconstruction with the exact polynomial-depth circuit width. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
open Classical Set MeasureTheory
open ConcreteModel CompressionSampling
variable {d N r : ℕ}

def converseWidth (d r : ℕ) (K Λ : ℝ) : ℕ :=
  ⌈65536*Λ^2*K*(1+((r:ℝ)+1)*K)*((d:ℝ)+Real.log (400*((r:ℝ)+2)))⌉₊

theorem certifiedCompressionRadius_le_robustRadius {K Λ : ℝ} (hK : 1≤K) (hΛ : 1<Λ)
    (w : Weights d N r) (hw : weightedSquaredNorm w≤K) :
    certifiedCompressionRadius r K Λ≤robustRadius (1/(16*Λ)) w := by
  have hEv : readoutEnergy w≤K := (output_squaredNorm_mul_width_le_cost w).trans hw
  have hEv0 := readoutEnergy_nonneg w
  have hden0 : 0<1+((r:ℝ)+1)*readoutEnergy w := by positivity
  have hden : 1+((r:ℝ)+1)*readoutEnergy w≤1+((r:ℝ)+1)*K := by
    have hmul := mul_le_mul_of_nonneg_left hEv (by positivity : (0:ℝ)≤(r:ℝ)+1)
    linarith
  have hh := div_le_div_of_nonneg_left (by positivity : 0≤1/(16*Λ))
    (Real.sqrt_pos.mpr hden0) (Real.sqrt_le_sqrt hden)
  unfold certifiedCompressionRadius robustRadius
  convert hh using 1 <;> first | ring | rfl

theorem rescaleReadout_preserves_clipped_margin {M : ℕ} (f : BooleanFunction d)
    (w : Weights d N r) (v : Weights d M r) (hw : w∈marginEvent Real.tanh (1/2) f)
    (herr : ∀ x,|clippedScore (networkOutput Real.tanh v x)-clippedScore (networkOutput Real.tanh w x)|≤1/16) :
    rescaleReadout 2 v∈marginEvent Real.tanh (1/2) f := by
  intro x
  have he := herr x
  rw [clippedScore_eq_label_of_margin (f x) _ (hw x).le] at he
  have hmargin : (1:ℝ)/4<labelReal (f x)*networkOutput Real.tanh v x := by
    by_contra hbad
    have hc := RobustStatistics.signed_clippedScore_le_quarter (f x) (networkOutput Real.tanh v x)
      (le_of_not_gt hbad)
    have hinterval := abs_le.mp he
    cases hb : f x <;> simp only [hb,labelReal_false,labelReal_true,neg_one_mul,one_mul] at hc hinterval <;> linarith
  rw [rescaleReadout_output]
  nlinarith only [hmargin]

/-- Every supported energy-K network gives an actual same-depth bounded-weight
implementation at the exact width displayed in the paper. -/
theorem supported_energy_reconstruction (hd : 0<d) (hN : 0<N) {K Λ U : ℝ}
    (hK : 1≤K) (hΛ : 1<Λ) (f : BooleanFunction d)
    (w : Weights d N r) (hw : w∈functionSupport Λ U f) (henergy : weightedSquaredNorm w≤K) :
    realizesAtComplexity (r:=r) Real.tanh f (converseWidth d r K Λ) := by
  let ρ := certifiedCompressionRadius r K Λ
  have hρ := certifiedCompressionRadius_bounds (r:=r) hK hΛ
  have hrad := certifiedCompressionRadius_le_robustRadius hK hΛ w henergy
  have hrob := gain_support_subset_robust hN hΛ hw.1
  have hrobρ : ∀ x η,noiseBudgetSq η≤ρ^2 →
      |clippedScore (noisyNetworkOutput Real.tanh w x η)-clippedScore (networkOutput Real.tanh w x)|≤1/16 := by
    intro x η hη
    apply hrob x η
    have hs : ρ^2≤(robustRadius (1/(16*Λ)) w)^2 :=
      (sq_le_sq₀ hρ.1.le (hρ.1.le.trans hrad)).mpr hrad
    exact hη.trans hs
  obtain ⟨v,hvcost,hvbound,hvclose⟩ := robust_energy_compression hd hN hρ.1 hρ.2 hK w henergy hrobρ
  have hresources := compressionWidth_resources (r:=r) hd hK hρ.1 hρ.2
  have hcost : weightedSquaredNorm (rescaleReadout 2 v)≤(compressionWidth d r K ρ:ℝ) := by
    have hc := rescaleReadout_cost_le (by norm_num : (1:ℝ)≤2) v
    have hm := hresources.2
    nlinarith only [hc,hvcost,hm]
  have hresult : realizesAtComplexity (r:=r) Real.tanh f (compressionWidth d r K ρ) :=
    ⟨hresources.1,rescaleReadout 2 v,rescaleReadout_preserves_clipped_margin f w v hw.2 hvclose,
      boundedWeights_of_cost hd hresources.1 _ hcost⟩
  simpa only [ρ,certifiedCompressionWidth_eq hK hΛ,converseWidth] using hresult

/-- The displayed fourth-power mistake dependence, from an actual neural-action
bound and the proved sharp finite-network compressor. -/
theorem neural_action_reconstruction (hd : 0<d) (r : ℕ) {Λ U : ℝ} (hΛ : 1<Λ) (hU : 1<U)
    (f : BooleanFunction d) {m : ℝ} (hm : 0≤m)
    (hbound : neuralSqrtAction r Λ U f≤Real.sqrt (repairBudget d r U)*(m+1)) :
    realizesAtComplexity (r:=r) Real.tanh f
      (converseWidth d r (1+repairBudget d r U*(m+1)^2) Λ) := by
  obtain ⟨N,hN,w,hw,henergy⟩ := exists_supported_energy_of_action_bound hd r hΛ hU f hm hbound
  apply supported_energy_reconstruction hd hN _ hΛ f w hw henergy.le
  have hp := repairBudget_pos d r U
  nlinarith [sq_nonneg (m+1)]

end
end NeuralGeneralization.BatchTwoNeuralConverse
