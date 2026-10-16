import NeuralGeneralization.LargePositiveComparator
import NeuralGeneralization.LargeSampleEvents
import NeuralGeneralization.PositiveSubcriticalDeterministic
import NeuralGeneralization.Statements

/-! The actual exponential lower bound for every positive subcritical
exponent, in the adaptive large-sample regime. -/
noncomputable section
open Filter
open scoped BigOperators Topology
namespace NeuralGeneralization.SubcriticalPositiveLargeSample
open ConcreteModel AdaptiveCutoff LocalizedCubeBump SmallSampleCutoff
  WalshMarginMinimizers PositiveSubcriticalDeterministic

lemma outside_adaptiveLowBand {d r : ℕ} {S : Finset (Fin d)}
    (hS : S∈Finset.univ \ adaptiveLowBand d r) : r<S.card := by
  classical
  have hh := (Finset.mem_sdiff.mp hS).2
  rw [mem_adaptiveLowBand] at hh
  omega

lemma positive_upper_weight_le_polynomial {d : ℕ} (hd : 1≤d) (k : ℕ) :
    (d:ℝ)^dampingExponent k≤((d:ℝ)+1)^10 := by
  have hd1 : (1:ℝ)≤d := by exact_mod_cast hd
  have hβ : dampingExponent k≤1 := (neural_exponent_le_half k).trans (by norm_num)
  have hW : (d:ℝ)^dampingExponent k≤d := by
    simpa only [Real.rpow_one] using Real.rpow_le_rpow_of_exponent_le hd1 hβ
  have hD1 : (1:ℝ)≤(d:ℝ)+1 := by linarith
  have hp := pow_le_pow_right₀ hD1 (by norm_num : (1:ℕ)≤10)
  norm_num only [pow_one] at hp
  exact hW.trans ((by linarith : (d:ℝ)≤(d:ℝ)+1).trans hp)

/-- The constants and the dimension threshold are uniform over every
positive subcritical exponent. The sample law and confidence failure are
those of the original finite-width neural network. -/
theorem eventually_positive_large_sample_lower_bound (k : ℕ) (a : ℝ) (ha : 0<a) :
    ∃ c : ℝ,0<c ∧ ∀ᶠ d : ℕ in atTop,∀ n : ℕ,
      Real.exp (logDimension d^3)≤(n:ℝ) →(n:ℝ)≤Real.exp (c*(d:ℝ)) →
      ∀ γ : ℝ,0<γ →γ<1 →
      (3/4:ℝ)≤sampleProbability (uniformLaw d) n (fun s=>
        (1/16:ℝ)≤Filter.liminf (MainStatements.parityFailure d k n a γ s) atTop) := by
  classical
  let A : ℝ := (2:ℝ)^79
  have hA : 0≤A := by dsimp [A]; positivity
  obtain ⟨U,hU,hspec⟩ := actual_spectral_budget k
  have hU0 : 0≤U := by linarith
  obtain ⟨Cg,hCg,hevents⟩ := eventually_largeSampleGood_probability k A hA
  let Cp := largePositiveConstant k a
  have hCp : 0<Cp := largePositiveConstant_pos k ha
  let C := max 1 (max Cg (max (2*A*U) Cp))
  have hC : 1≤C := le_max_left _ _
  have hC0 : 0<C := by linarith only [hC]
  have hCCg : Cg≤C := (le_max_left _ _).trans (le_max_right _ _)
  have hCA : 2*A*U≤C := (le_max_left _ _).trans ((le_max_right _ _).trans (le_max_right _ _))
  have hCCp : Cp≤C := (le_max_right _ _).trans ((le_max_right _ _).trans (le_max_right _ _))
  let η : ℝ := a^2/64
  let δ : ℝ := a^2/(64*C)
  have hη : 0<η := by dsimp [η]; positivity
  have hδ : 0<δ := by dsimp [δ]; positivity
  obtain ⟨c₀,hc₀,hbudgets⟩ := eventually_large_head_and_tail A C U η δ le_rfl hC hU0 hη hδ
  let c := min c₀ (1/1000)
  have hc : 0<c := lt_min hc₀ (by norm_num)
  refine ⟨c,hc,?_⟩
  filter_upwards [hbudgets,hevents,eventually_large_positive_comparator k ha,
    eventually_neuralComparatorGood_probability k (1/16) (by norm_num),
    logDimension_tendsto.eventually_ge_atTop 2,eventually_ge_atTop 1]
    with d hbudget hevent hcomp hcompprob hlog hd n hmin hmax γ hγ0 hγ1
  have hd0 : (0:ℝ)≤d := Nat.cast_nonneg d
  have hmax₀ : (n:ℝ)≤Real.exp (c₀*(d:ℝ)) := hmax.trans
    (Real.exp_le_exp.mpr (mul_le_mul_of_nonneg_right (min_le_left _ _) hd0))
  have hmax1000 : (n:ℝ)≤Real.exp ((d:ℝ)/1000) := by
    have hh := hmax.trans (Real.exp_le_exp.mpr
      (mul_le_mul_of_nonneg_right (min_le_right c₀ (1/1000)) hd0))
    simpa only [one_div,mul_comm,div_eq_mul_inv,one_mul] using hh
  have hmax128 : (n:ℝ)≤Real.exp ((d:ℝ)/128) := hmax1000.trans
    (Real.exp_le_exp.mpr (by linarith only [hd0]))
  have hn4 : 4≤n := by
    have hpow := pow_le_pow_left₀ (by norm_num : (0:ℝ)≤2) hlog 3
    norm_num at hpow
    have hexp := Real.add_one_le_exp (logDimension d^3)
    exact_mod_cast (show (4:ℝ)≤n by linarith only [hpow,hexp,hmin])
  have hn : 0<n := by omega
  obtain ⟨r,hcut,htailnum,hheadnum⟩ := hbudget n hmin hmax₀
  let u := r+additionalBand d
  let β := dampingExponent k
  let W : ℝ := (d:ℝ)^β
  let T : ℝ := (r:ℝ)^(-β)
  let K : ℝ := ((d+1).choose (r+2):ℝ)
  let Ku : ℝ := ((d+1).choose (u+2):ℝ)
  let ellH : ℝ := U*T/((r:ℝ)*K)
  let ellU : ℝ := U/Ku
  let B : ℝ := Cp*(n:ℝ)*W
  let G := normalizedGram C d k r n
  have hr : 1≤r := hcut.positive
  have hdim : 131072*(u+1)≤d := hcut.degree_le
  have hr0 : (0:ℝ)<r := Nat.cast_pos.mpr (by omega)
  have hK : 0<K := Nat.cast_pos.mpr (Nat.choose_pos (by omega))
  have hKu : 0<Ku := Nat.cast_pos.mpr (Nat.choose_pos (by dsimp [u] at hdim ⊢; omega))
  have hW : 0≤W := Real.rpow_nonneg hd0 _
  have hT : 0≤T := Real.rpow_nonneg (Nat.cast_nonneg r) _
  have hellH : 0≤ellH := by dsimp [ellH]; positivity
  have hellU : 0≤ellU := by dsimp [ellU]; positivity
  have hB : 0≤B := by dsimp [B]; positivity
  have hG : 0≤G := normalizedGram_nonneg hC0.le d k r hn
  have hrd : (r:ℝ)≤d := by exact_mod_cast (show r≤d by dsimp [u] at hdim; omega)
  have hweights := positive_weight_bounds (by exact_mod_cast hr : (1:ℝ)≤r) hrd
    (neural_exponent_pos k).le ((neural_exponent_le_half k).trans (by norm_num))
  have hWT : W*T≤(d:ℝ)/(r:ℝ) := hweights.2.1
  obtain ⟨heigen,_,_,_⟩ := hspec d r hr hcut.odd (by dsimp [u] at hdim; omega)
  change ∀ S : Finset (Fin d),r<S.card →walshCoefficients (arcsineProfile d (k+1)) S≤ellH at heigen
  have hu : 1≤u := by dsimp [u]; omega
  have huodd : Odd u := hcut.odd.add_even (additionalBand_even d)
  obtain ⟨_,_,_,heigenU⟩ := hspec d u hu huodd (by omega)
  change ∀ S : Finset (Fin d),u<S.card →walshCoefficients (arcsineProfile d (k+1)) S≤ellU at heigenU
  have hnext := next_threshold_binomial hA hn (by dsimp [u] at hdim; omega) hcut.next_threshold
  have hL : 0≤Real.log (8*(n:ℝ)) := (show (0:ℝ)≤1 by norm_num).trans (log_eight_sample_ge_one hn)
  have hnell := sampled_eigenvalue_budget hL hA hU0 hT hr0 hK (Nat.cast_nonneg n) hnext (le_refl ellH)
  have hnellC : (n:ℝ)*ellH≤C*Real.log (8*(n:ℝ))*T/(r:ℝ) := by
    have hh := mul_le_mul_of_nonneg_right hCA (show 0≤Real.log (8*(n:ℝ))*T/(r:ℝ) by positivity)
    calc
      _ ≤ 2*A*U*Real.log (8*(n:ℝ))*T/(r:ℝ) := hnell
      _ = (2*A*U)*(Real.log (8*(n:ℝ))*T/(r:ℝ)) := by ring
      _ ≤ C*(Real.log (8*(n:ℝ))*T/(r:ℝ)) := hh
      _ = _ := by ring
  have hBC : B≤C*(n:ℝ)*W := by
    have hh := mul_le_mul_of_nonneg_right hCCp (show 0≤(n:ℝ)*W by positivity)
    dsimp only [B]
    nlinarith only [hh]
  have hhead := hheadnum G B ellH W T hG hB hellH hW hT hWT (le_refl G) hnellC hBC
  have htail : ellU*B≤a^2/64 := by
    have hWpoly : W≤((d:ℝ)+1)^10 := positive_upper_weight_le_polynomial hd k
    have hnum : (n:ℝ)*ellU*((d:ℝ)+1)^10≤δ := htailnum
    have hsmall : (n:ℝ)*ellU*W≤δ :=
      (mul_le_mul_of_nonneg_left hWpoly (by positivity : 0≤(n:ℝ)*ellU)).trans hnum
    have hh := mul_le_mul_of_nonneg_left hsmall hC0.le
    have hh' := mul_le_mul_of_nonneg_right hCCp (by positivity : 0≤(n:ℝ)*ellU*W)
    have heq : C*δ=a^2/64 := by dsimp [δ]; field_simp
    dsimp only [B]
    nlinarith only [hh,hh',heq]
  have hevent' := hevent n r _ hn4 hmax128 hcut
  have heventC : 7/8≤sampleProbability (uniformLaw d) n (LargeSampleGood d k r n G) := by
    apply hevent'.trans
    apply sampleProbability_mono
    intro s hs
    exact hs.mono (normalizedGram_mono hCCg d k r hn)
  have hcp := (hcompprob n hmax1000).2.2
  have hj := sampleProbability_inter_lower (uniformLaw d)
    (LargeSampleGood d k r n G) (neuralComparatorGood d k n)
  have hprob : (3/4:ℝ)≤sampleProbability (uniformLaw d) n
      (fun s=>LargeSampleGood d k r n G s ∧ neuralComparatorGood d k n s) := by
    linarith only [heventC,hcp,hj]
  apply hprob.trans
  apply sampleProbability_mono
  intro s hs
  apply confidence_liminf_of_comparator_budgets (u:=u) (r:=k) (by omega) hn hγ0 hγ1 ha s
    (adaptiveLowBand d r) (adaptiveLowBand d u)
    (fun S hS=>(mem_adaptiveLowBand S).mp hS) hs.1.coercivity G B ellH ellU hG hellH hellU
    (hcomp n hmin hmax1000 s hs.2 (parity d))
    (fun S hS=>heigen S (outside_adaptiveLowBand hS))
    (fun S hS=>heigenU S (outside_adaptiveLowBand hS)) hs.1.gram
  · change (u:ℝ)^2*(4*G*B/(n:ℝ)+ellH*B)≤(a*(d:ℝ))^2/64
    dsimp only [η] at hhead
    nlinarith only [hhead]
  · exact htail

end NeuralGeneralization.SubcriticalPositiveLargeSample
