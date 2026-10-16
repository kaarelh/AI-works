import NeuralGeneralization.IteratedArcsineCoefficientBounds
import NeuralGeneralization.FirstLayerLevelUpper

/-! Sharp paired Fourier level masses of the actual arcsine neural
kernel at every positive finite depth. -/
noncomputable section
namespace NeuralGeneralization
open MeasureTheory Set

/-- Uniform sharp paired-level masses, throughout a fixed range reaching
49.5 percent of the full biased dimension. -/
theorem iteratedArcsine_paired_level_bounds (k : ℕ) :
    ∃ l U : ℝ,0 < l ∧ 0 < U ∧ ∀ (d : ℕ) (S : Finset (Fin d)),
      200*pairedWalshDegree S ≤ 99*(d+1) →
      l ≤ (pairedWalshDegree S : ℝ)^(1+1/(2 : ℝ)^(k+1))*
        ((d+1).choose (pairedWalshDegree S) : ℝ)*walshCoefficients (arcsineProfile d (k+1)) S ∧
      (pairedWalshDegree S : ℝ)^(1+1/(2 : ℝ)^(k+1))*
        ((d+1).choose (pairedWalshDegree S) : ℝ)*walshCoefficients (arcsineProfile d (k+1)) S ≤ U := by
  let β : ℝ := 1/(2 : ℝ)^(k+1)
  let ρ : ℝ := 99/200
  let a : ℝ := Real.log 200/2
  have hβ := arcsineDepthExponent_bounds k
  have ha : 0 < a := div_pos (Real.log_pos (by norm_num)) (by norm_num)
  have hp : poissonFlipProbability a=(199/400 : ℝ) := by
    unfold poissonFlipProbability
    rw [show -2*a= -Real.log 200 by dsimp [a]; ring,Real.exp_neg,
      Real.exp_log (by norm_num : (0 : ℝ) < 200)]
    norm_num
  have hρp : ρ < poissonFlipProbability a := by rw [hp]; norm_num [ρ]
  have hρ0 : 0 < ρ := by norm_num [ρ]
  have hρ1 : ρ < 1 := by norm_num [ρ]
  obtain ⟨c,C,hc,hC,hcoeff⟩ := iteratedArcsine_coefficient_gamma_bounds k
  let L := (1-β)*Real.exp (-2*a*(1+β))*(1-ρ/poissonFlipProbability a)
  let V := 2*(Real.exp (2*a)+a^(-β)/(β*(poissonFlipProbability a-ρ)))/(1-β)
  have hL : 0 < L := by
    dsimp [L]
    apply mul_pos (mul_pos (by dsimp [β]; linarith [hβ.2]) (Real.exp_pos _))
    exact sub_pos.mpr ((div_lt_one (poissonFlipProbability_pos ha)).mpr hρp)
  have hV : 0 < V := by
    have hb0 : 0 < β := hβ.1
    have hb1 : 0 < 1-β := by dsimp [β]; linarith [hβ.2]
    have hg : 0 < poissonFlipProbability a-ρ := sub_pos.mpr hρp
    dsimp [V]
    positivity
  refine ⟨c*L,C*V,mul_pos hc hL,mul_pos hC hV,?_⟩
  intro d S hcut
  let j := pairedWalshDegree S
  let w := (j : ℝ)^(1+β)*((d+1).choose j : ℝ)
  let R := ((d : ℝ)+1)^(-β)*
    (∫ u : ℝ in Ioi 0,u^(-1-β)*oddPoissonEndpoint d u S)
  have hw : 0 ≤ w := by dsimp [w]; positivity
  have hj := pairedWalshDegree_bounds S
  have hjρ : (j : ℝ) ≤ ρ*((d : ℝ)+1) := by
    have hh : (200 : ℝ)*j ≤ 99*((d : ℝ)+1) := by exact_mod_cast hcut
    dsimp [ρ]
    linarith
  have hjD : j < d+1 := by
    have hD : 0 < (d : ℝ)+1 := by positivity
    have hh := mul_lt_mul_of_pos_right hρ1 hD
    have hlt : (j : ℝ) < (d : ℝ)+1 := by linarith
    exact_mod_cast hlt
  have hlo := poisson_level_normalized_lower hj.1 hj.2 hβ.1 hβ.2 hρ0.le hρ1.le ha hρp
    (by simpa only [Nat.cast_add,Nat.cast_one] using hjρ)
  have hup := poisson_level_normalized_upper hj.1 hjD hβ.1 hβ.2 hρ0 ha hρp
    (by simpa only [Nat.cast_add,Nat.cast_one,mul_comm] using hjρ)
  have he : (fun u : ℝ => u^(-1-β)*(poissonFlipProbability u)^j*
      (1-poissonFlipProbability u)^(d+1-j)) =
      fun u : ℝ => u^(-1-β)*oddPoissonEndpoint d u S := by
    funext u
    rw [oddPoissonEndpoint_eq_paired]
    dsimp [j]
    ring
  rw [he] at hlo hup
  simp only [Nat.cast_add,Nat.cast_one] at hlo hup
  have hRlo : L ≤ w*R := hlo
  have hRup : w*R ≤ V := hup
  have hcR := IteratedArcsineSpectrum.poisson_integral_comparison d (k+1) hβ.1 hβ.2 hcoeff S
  change c*L ≤ w*walshCoefficients (arcsineProfile d (k+1)) S ∧
    w*walshCoefficients (arcsineProfile d (k+1)) S ≤ C*V
  constructor
  · calc
      c*L ≤ c*(w*R) := mul_le_mul_of_nonneg_left hRlo hc.le
      _ = w*(c*R) := by ring
      _ ≤ _ := mul_le_mul_of_nonneg_left hcR.1 hw
  · calc
      _ ≤ w*(C*R) := mul_le_mul_of_nonneg_left hcR.2 hw
      _ = C*(w*R) := by ring
      _ ≤ C*V := mul_le_mul_of_nonneg_left hRup hC.le

/-- Every actual low reduced Fourier level has the polynomial mass needed
for localized comparison fields, at every finite positive depth. -/
theorem iteratedArcsine_low_level_floor (k : ℕ) :
    ∃ c : ℝ,0 < c ∧ ∀ (d : ℕ),101 ≤ d → ∀ S : Finset (Fin d),
      100*S.card < 49*d →
      c/((d : ℝ)+1)^(1+1/(2 : ℝ)^(k+1)) ≤
        (d.choose S.card : ℝ)*walshCoefficients (arcsineProfile d (k+1)) S := by
  obtain ⟨c,C,hc,hC,hlevels⟩ := iteratedArcsine_paired_level_bounds k
  refine ⟨c,hc,?_⟩
  intro d hd S hdeg
  let β : ℝ := 1/(2 : ℝ)^(k+1)
  let j := pairedWalshDegree S
  let lam := walshCoefficients (arcsineProfile d (k+1)) S
  have hβ := arcsineDepthExponent_bounds k
  have hlam : 0 ≤ lam := arcsineProfile_coefficient_nonneg d (k+1) S
  have hj := pairedWalshDegree_bounds S
  have hjle : j ≤ S.card+1 := by dsimp [j,pairedWalshDegree]; split_ifs <;> omega
  have hcut : 200*j ≤ 99*(d+1) := by omega
  have hhalf : 2*j ≤ d+1 := by omega
  have hj0 : 0 < (j : ℝ) := by exact_mod_cast (show 0 < j by dsimp [j]; omega)
  have hD0 : 0 < (d : ℝ)+1 := by positivity
  have hp : (j : ℝ)^β ≤ ((d : ℝ)+1)^β := by
    apply Real.rpow_le_rpow hj0.le _ hβ.1.le
    exact_mod_cast hj.2
  have hm := pairedWalshMultiplicity_lower S hhalf
  have hh := (hlevels d S hcut).1
  apply (div_le_iff₀ (Real.rpow_pos_of_pos hD0 (1+β))).mpr
  apply hh.trans
  have he (x : ℝ) (hx : 0 < x) : x^(1+β)=x^β*x := by
    rw [Real.rpow_add hx,Real.rpow_one]
    ring
  rw [he (j : ℝ) hj0,he ((d : ℝ)+1) hD0]
  calc
    _ = (j : ℝ)^β*((j : ℝ)*((d+1).choose j : ℝ))*lam := by ring
    _ ≤ ((d : ℝ)+1)^β*(((d : ℝ)+1)*(d.choose S.card : ℝ))*lam := by gcongr
    _ = _ := by ring

end NeuralGeneralization
