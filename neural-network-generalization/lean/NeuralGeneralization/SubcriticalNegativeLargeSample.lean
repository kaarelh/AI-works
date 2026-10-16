import NeuralGeneralization.NegativeLargeSampleScalars
import NeuralGeneralization.LargeSampleEvents
import NeuralGeneralization.SubcriticalNeuralEndpoints
import NeuralGeneralization.Statements

/-! The complete negative-exponent neural lower bound in the adaptive
large-sample interval, with the actual strict-confidence prediction rule. -/
noncomputable section
open Filter MeasureTheory ProbabilityTheory
open scoped Topology BigOperators
namespace NeuralGeneralization.SubcriticalNegativeLargeSample
open ConcreteModel AdaptiveCutoff SmallSampleCutoff SubcriticalNeuralEndpoints
open GaussianSignCone GaussianPosteriorFeatures GaussianSignPosteriorBridge

/-- For every negative exponent the actual neural posterior has confidence
failure bounded below throughout a fixed exponential sample interval. The
dimension threshold and exponential constant are independent of gamma. -/
theorem eventually_negative_large_sample_lower_bound (k : ℕ) (a : ℝ) :
    ∃ c : ℝ, 0<c ∧ ∀ᶠ d : ℕ in atTop, ∀ n : ℕ,
      Real.exp (logDimension d^3)≤(n:ℝ) → (n:ℝ)≤Real.exp (c*(d:ℝ)) →
      ∀ γ : ℝ, γ<0 →
      (3/4:ℝ)≤sampleProbability (uniformLaw d) n (fun s =>
        (1/16:ℝ)≤Filter.liminf (MainStatements.parityFailure d k n a γ s) atTop) := by
  classical
  let A : ℝ := (2:ℝ)^79
  have hA : (2:ℝ)^79≤A := le_rfl
  have hA0 : 0≤A := by dsimp [A]; positivity
  obtain ⟨U,hU,hspec⟩ := actual_spectral_budget k
  have hU0 : 0≤U := by linarith
  obtain ⟨Cg,hCg,hgood⟩ := eventually_largeSampleGood_probability k A hA0
  have hCg0 : 0≤Cg := by linarith
  let C : ℝ := Cg+2*A*U+1/marginFactor+1
  have hκinv : 0≤1/marginFactor := (one_div_pos.mpr marginFactor_pos).le
  have hAU : 0≤2*A*U := by positivity
  have hC : 1≤C := by dsimp [C]; linarith
  have hCG : Cg≤C := by dsimp [C]; linarith
  have hCe : 2*A*U≤C := by dsimp [C]; linarith
  have hCB : 1/marginFactor≤C := by dsimp [C]; linarith
  obtain ⟨c₀,hc₀,hcutoff⟩ := eventually_large_head_and_tail A C U (1/64) tailTolerance
    hA hC hU0 (by norm_num) tailTolerance_pos
  let c : ℝ := min c₀ (1/128)
  have hc : 0<c := lt_min hc₀ (by norm_num)
  refine ⟨c,hc,?_⟩
  filter_upwards [hcutoff,hgood,logDimension_tendsto.eventually_ge_atTop 2,
    eventually_ge_atTop 1] with d hcutoff hgood hlog hd n hmin hmax γ hγ
  have hd0 : 0<d := by omega
  have hn4 : 4≤n := by
    have hh := pow_le_pow_left₀ (by norm_num : (0:ℝ)≤2) hlog 3
    norm_num at hh
    have hnR : (4:ℝ)≤n := by linarith [Real.add_one_le_exp (logDimension d^3)]
    exact_mod_cast hnR
  have hn : 0<n := by omega
  letI : Nonempty (Fin n) := Fin.pos_iff_nonempty.mp hn
  have hn0 : 0<(n:ℝ) := Nat.cast_pos.mpr hn
  have hnmax : (n:ℝ)≤Real.exp (c₀*(d:ℝ)) := hmax.trans
    (Real.exp_le_exp.mpr (mul_le_mul_of_nonneg_right (min_le_left _ _) (Nat.cast_nonneg d)))
  have hn128 : (n:ℝ)≤Real.exp ((d:ℝ)/128) := hmax.trans
    (Real.exp_le_exp.mpr (by
      have hh := mul_le_mul_of_nonneg_right (min_le_right c₀ (1/128:ℝ)) (Nat.cast_nonneg d : (0:ℝ)≤d)
      change c*(d:ℝ)≤_ at hh
      linarith))
  obtain ⟨r,hcut,htail,hhead⟩ := hcutoff n hmin hnmax
  let u := r+additionalBand d
  let β : ℝ := 1/(2:ℝ)^(k+1)
  let T : ℝ := (r:ℝ)^(-β)
  let W : ℝ := (r:ℝ)^β
  let ellH := U*T/((r:ℝ)*((d+1).choose (r+2):ℝ))
  let ellU := U/((d+1).choose (u+2):ℝ)
  let G := normalizedGram Cg d k r n
  let τ := walshSpectralTail (arcsineProfile d (k+1)) (u+1)
  let b := Real.sqrt (Real.pi*τ)*(Real.exp (-1)-7/20)/2
  have hr : (1:ℝ)≤r := by exact_mod_cast hcut.positive
  have hr0 : (0:ℝ)<r := by linarith
  have hrd : (r:ℝ)≤d := by exact_mod_cast (show r≤d by have := hcut.degree_le; omega)
  have hT : 0≤T := Real.rpow_nonneg hr0.le _
  have hW := negative_weight_bounds hr hrd (neural_exponent_pos k).le
    ((neural_exponent_le_half k).trans (by norm_num))
  change 0≤W ∧ W*T≤(d:ℝ)/(r:ℝ) ∧ W≤d at hW
  have hellH : 0≤ellH := by dsimp [ellH]; positivity
  have hellU : 0≤ellU := by dsimp [ellU]; positivity
  have hG : 0≤G := normalizedGram_nonneg hCg0 d k r hn
  obtain ⟨heigen,_,_,_⟩ := hspec d r hcut.positive hcut.odd (by have := hcut.degree_le; omega)
  have huodd : Odd u := hcut.odd.add_even (additionalBand_even d)
  obtain ⟨_,_,_,heigenU⟩ := hspec d u (by dsimp [u]; have := hcut.positive; omega)
    huodd (by dsimp [u]; have := hcut.degree_le; omega)
  have hmaxH : ∀ S∈Finset.univ \ adaptiveLowBand d r,
      walshCoefficients (arcsineProfile d (k+1)) S≤ellH := by
    intro S hS
    have hs : r<S.card := by simpa [adaptiveLowBand] using hS
    exact heigen S hs
  have hmaxU : ∀ S∈Finset.univ \ adaptiveLowBand d u,
      walshCoefficients (arcsineProfile d (k+1)) S≤ellU := by
    intro S hS
    have hs : u<S.card := by simpa [adaptiveLowBand] using hS
    exact heigenU S hs
  obtain ⟨hτ,hb,_,hB,hvariance,htailU⟩ := negative_margin_scalar_budgets k hcut hellU htail
  change 0<τ at hτ
  change 0<b at hb
  change (n:ℝ)/b^2≤(1/marginFactor)*(n:ℝ)*W at hB
  change 2*(n:ℝ)*ellU/τ≤1/32 at hvariance
  change (n:ℝ)*ellU≤b^2/32 at htailU
  have hL : 0≤Real.log (8*(n:ℝ)) := (by norm_num : (0:ℝ)≤1).trans (log_eight_sample_ge_one hn)
  have hK : 0<((d+1).choose (r+2):ℝ) := by
    apply Nat.cast_pos.mpr (Nat.choose_pos _)
    have := hcut.degree_le
    omega
  have hnext := next_threshold_binomial hA0 hn (by have := hcut.degree_le; omega) hcut.next_threshold
  have heigenBudget := sampled_eigenvalue_budget hL hA0 hU0 hT hr0 hK
    (Nat.cast_nonneg n) hnext (le_refl ellH)
  have heigenBudget' : (n:ℝ)*ellH≤C*Real.log (8*(n:ℝ))*T/(r:ℝ) := by
    apply heigenBudget.trans
    have hh := mul_le_mul_of_nonneg_right hCe (show 0≤Real.log (8*(n:ℝ))*T/(r:ℝ) by positivity)
    convert hh using 1 <;> ring
  have hGramBudget : G≤C*T*(1+Real.sqrt ((d:ℝ)*Real.log (8*(n:ℝ)))/(r:ℝ)+Real.log (8*(n:ℝ))/(r:ℝ)) :=
    normalizedGram_mono hCG d k r hn
  have hBBudget : (n:ℝ)/b^2≤C*(n:ℝ)*W := hB.trans (by
    have hh := mul_le_mul_of_nonneg_right hCB (show 0≤(n:ℝ)*W by positivity)
    nlinarith only [hh])
  have hheadBound := hhead G ((n:ℝ)/b^2) ellH W T hG (by positivity) hellH hW.1 hT hW.2.1
    hGramBudget heigenBudget' hBBudget
  have hheadActual : (u:ℝ)^2*(4*G+(n:ℝ)*ellH)≤(b*(d:ℝ))^2/64 := by
    have he : ((r+additionalBand d:ℕ):ℝ)^2*(4*G*((n:ℝ)/b^2)/(n:ℝ)+ellH*((n:ℝ)/b^2))=
        (u:ℝ)^2*(4*G+(n:ℝ)*ellH)/b^2 := by
      dsimp [u]
      field_simp
      <;> ring
    rw [he] at hheadBound
    have hh := (div_le_iff₀ (sq_pos_of_pos hb)).mp hheadBound
    nlinarith only [hh]
  have hp := hgood n r _ hn4 hn128 hcut
  apply (show (3/4:ℝ)≤7/8 by norm_num).trans (hp.trans ?_)
  apply sampleProbability_mono
  intro s hs
  have hprob := training_probability_ne_zero (walshCoefficients (arcsineProfile d (k+1)))
    (iterated_arcsine_coefficient_pos d k) (parity d) s
  simp only [trainingCoefficients,labelReal_parity] at hprob
  have hlow := GaussianNegativeDeterministic.confidence_failure_lower (u:=u) hd0
    (walshCoefficients (arcsineProfile d (k+1))) (iterated_arcsine_coefficient_pos d k) s hprob
    (adaptiveLowBand d r) (adaptiveLowBand d u) (fun S hS=>(mem_adaptiveLowBand S).mp hS)
    (by simpa only [Fintype.card_fin] using hs.coercivity)
    G ellH ellU b hG hellH hellU hb hmaxH hmaxU hs.gram
    (by simpa only [adaptive_tail_trace] using hτ)
    (by rw [adaptive_tail_trace]; change 2*b≤Real.sqrt (Real.pi*τ)*(Real.exp (-1)-7/20); dsimp [b]; linarith)
    (by simpa only [Fintype.card_fin,adaptive_tail_trace] using hvariance)
    (by simpa only [Fintype.card_fin] using htailU)
    (by simpa only [Fintype.card_fin] using hheadActual)
  have hlim := negative_confidence_liminf_of_gaussian_failure hd0 k hγ a s (13/20) (by norm_num)
  exact (show (1/16:ℝ)≤3/8 by norm_num).trans (hlow.trans hlim)

end NeuralGeneralization.SubcriticalNegativeLargeSample
