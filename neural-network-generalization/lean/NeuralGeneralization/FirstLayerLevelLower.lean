import NeuralGeneralization.PoissonLevelLower
import NeuralGeneralization.FirstLayerPoissonComparison

/-! Sharp level lower estimates for the actual first normalized-arcsine
kernel, including the exact bias pairing. -/
noncomputable section
namespace NeuralGeneralization
open MeasureTheory Set

/-- The full-cube odd degree corresponding to a reduced-cube character. -/
def pairedWalshDegree {d : ℕ} (S : Finset (Fin d)) : ℕ :=
  if Even S.card then S.card+1 else S.card

lemma pairedWalshDegree_bounds {d : ℕ} (S : Finset (Fin d)) :
    1 ≤ pairedWalshDegree S ∧ pairedWalshDegree S ≤ d+1 := by
  have hcard : S.card ≤ d := (Finset.card_le_univ S).trans_eq (Fintype.card_fin d)
  unfold pairedWalshDegree
  split_ifs with he
  · omega
  · have hn : S.card ≠ 0 := by intro hz; apply he; rw [hz]; decide
    omega

lemma oddPoissonEndpoint_eq_paired {d : ℕ} (S : Finset (Fin d)) (u : ℝ) :
    oddPoissonEndpoint d u S =
      (poissonFlipProbability u)^(pairedWalshDegree S)*
        (1-poissonFlipProbability u)^(d+1-pairedWalshDegree S) := by
  have hcard : S.card ≤ d := (Finset.card_le_univ S).trans_eq (Fintype.card_fin d)
  unfold oddPoissonEndpoint pairedWalshDegree
  split_ifs with he
  · rw [show d+1-(S.card+1)=d-S.card by omega,pow_succ]
    ring
  · rw [show d+1-S.card=(d-S.card)+1 by omega,pow_succ]
    ring

/-- A sharp paired-level lower estimate for the actual first-layer
kernel. Only the geometric cutoff, not a spectral assumption, is required. -/
theorem first_arcsine_paired_level_lower {d : ℕ} (S : Finset (Fin d))
    {ρ a : ℝ} (hρ0 : 0 ≤ ρ) (hρ1 : ρ ≤ 1) (ha : 0 < a)
    (hρp : ρ < poissonFlipProbability a)
    (hjρ : (pairedWalshDegree S : ℝ) ≤ ρ*((d : ℝ)+1)) :
    Real.exp (-3*a)*(1-ρ/poissonFlipProbability a)/16 ≤
      (pairedWalshDegree S : ℝ)^(3/2 : ℝ)*((d+1).choose (pairedWalshDegree S) : ℝ)*
        walshCoefficients (arcsineProfile d 1) S := by
  let j := pairedWalshDegree S
  have hj := pairedWalshDegree_bounds S
  have h := poisson_level_normalized_lower hj.1 hj.2
    (β := (1/2 : ℝ)) (by norm_num) (by norm_num) hρ0 hρ1 ha hρp
    (by simpa only [Nat.cast_add,Nat.cast_one] using hjρ)
  have hc := (first_arcsine_poisson_integral_comparison d S).1
  have he : (fun u : ℝ => u^(-1-(1/2 : ℝ))*(poissonFlipProbability u)^j*
      (1-poissonFlipProbability u)^(d+1-j)) =
      fun u : ℝ => u^(-(3/2 : ℝ))*oddPoissonEndpoint d u S := by
    funext u
    rw [oddPoissonEndpoint_eq_paired]
    dsimp [j]
    norm_num only
    ring
  rw [he] at h
  norm_num only [Nat.cast_add,Nat.cast_one] at h
  rw [show -2*a*(3/2)=-3*a by ring] at h
  norm_num only at hc
  have hw : 0 ≤ (pairedWalshDegree S : ℝ)^(3/2 : ℝ)*
      ((d+1).choose (pairedWalshDegree S) : ℝ) := by positivity
  have hc' := mul_le_mul_of_nonneg_left hc hw
  nlinarith only [h,hc']


lemma pairedWalshMultiplicity_lower {d : ℕ} (S : Finset (Fin d))
    (hjhalf : 2*pairedWalshDegree S ≤ d+1) :
    (pairedWalshDegree S : ℝ)*((d+1).choose (pairedWalshDegree S) : ℝ) ≤
      ((d : ℝ)+1)*(d.choose S.card : ℝ) := by
  have hcard : S.card ≤ d := (Finset.card_le_univ S).trans_eq (Fintype.card_fin d)
  unfold pairedWalshDegree at *
  by_cases he : Even S.card
  · simp only [if_pos he] at *
    have h := Nat.add_one_mul_choose_eq d S.card
    exact le_of_eq (by exact_mod_cast (by simpa only [Nat.mul_comm] using h.symm :
      (S.card+1)*((d+1).choose (S.card+1))=(d+1)*(d.choose S.card)))
  · simp only [if_neg he] at *
    have h := Nat.choose_mul_succ_eq d S.card
    have hc : S.card ≤ d+1-S.card := by omega
    have hm := Nat.mul_le_mul_left ((d+1).choose S.card) hc
    rw [← h] at hm
    exact_mod_cast (by simpa only [Nat.mul_comm] using hm :
      S.card*((d+1).choose S.card) ≤ (d+1)*(d.choose S.card))

/-- A dimension-uniform lower floor for every reduced low-degree level.
This is weaker than the sharp paired estimate but convenient for bump energy. -/
theorem first_arcsine_reduced_level_lower {d : ℕ} (S : Finset (Fin d))
    {ρ a : ℝ} (hρ0 : 0 ≤ ρ) (hρ1 : ρ ≤ 1) (ha : 0 < a)
    (hρp : ρ < poissonFlipProbability a)
    (hjρ : (pairedWalshDegree S : ℝ) ≤ ρ*((d : ℝ)+1))
    (hjhalf : 2*pairedWalshDegree S ≤ d+1) :
    (Real.exp (-3*a)*(1-ρ/poissonFlipProbability a)/16)/((d : ℝ)+1)^(3/2 : ℝ) ≤
      (d.choose S.card : ℝ)*walshCoefficients (arcsineProfile d 1) S := by
  let j := pairedWalshDegree S
  let lam := walshCoefficients (arcsineProfile d 1) S
  have hlam : 0 ≤ lam := arcsineProfile_coefficient_nonneg d 1 S
  have hj := pairedWalshDegree_bounds S
  have hj0 : 0 < (j : ℝ) := by exact_mod_cast (show 0 < j by dsimp [j]; omega)
  have hD0 : 0 < (d : ℝ)+1 := by positivity
  have hp : (j : ℝ)^(1/2 : ℝ) ≤ ((d : ℝ)+1)^(1/2 : ℝ) := by
    apply Real.rpow_le_rpow hj0.le _ (by norm_num)
    exact_mod_cast hj.2
  have hm := pairedWalshMultiplicity_lower S hjhalf
  have hh := first_arcsine_paired_level_lower S hρ0 hρ1 ha hρp hjρ
  apply (div_le_iff₀ (Real.rpow_pos_of_pos hD0 (3/2 : ℝ))).mpr
  apply hh.trans
  have he (x : ℝ) (hx : 0 < x) : x^(3/2 : ℝ)=x^(1/2 : ℝ)*x := by
    conv_rhs => rhs; rw [← Real.rpow_one x]
    rw [← Real.rpow_add hx]
    norm_num
  rw [he (j : ℝ) hj0,he ((d : ℝ)+1) hD0]
  calc
    _ = (j : ℝ)^(1/2 : ℝ)*
      ((j : ℝ)*((d+1).choose j : ℝ))*lam := by ring
    _ ≤ ((d : ℝ)+1)^(1/2 : ℝ)*
      (((d : ℝ)+1)*(d.choose S.card : ℝ))*lam := by gcongr
    _ = _ := by ring


/-- An explicit dimension-independent constant for the low-mode floor. -/
def firstLayerLowLevelConstant : ℝ :=
  Real.exp (-3*(Real.log 200/2))/3184

lemma firstLayerLowLevelConstant_pos : 0 < firstLayerLowLevelConstant := by
  unfold firstLayerLowLevelConstant
  positivity

/-- Every reduced Fourier level below 49 percent has polynomial mass,
for the actual first-layer kernel. -/
theorem first_arcsine_low_level_floor {d : ℕ} (hd : 101 ≤ d)
    (S : Finset (Fin d)) (hdeg : 100*S.card < 49*d) :
    firstLayerLowLevelConstant/((d : ℝ)+1)^(3/2 : ℝ) ≤
      (d.choose S.card : ℝ)*walshCoefficients (arcsineProfile d 1) S := by
  let a : ℝ := Real.log 200/2
  have ha : 0 < a := div_pos (Real.log_pos (by norm_num)) (by norm_num)
  have hp : poissonFlipProbability a=(199/400 : ℝ) := by
    unfold poissonFlipProbability
    rw [show -2*a= -Real.log 200 by dsimp [a]; ring,Real.exp_neg,
      Real.exp_log (by norm_num : (0 : ℝ) < 200)]
    norm_num
  have hjle : pairedWalshDegree S ≤ S.card+1 := by
    unfold pairedWalshDegree
    split_ifs <;> omega
  have hnat : 200*pairedWalshDegree S ≤ 99*(d+1) := by omega
  have hhalf : 2*pairedWalshDegree S ≤ d+1 := by omega
  have hjρ : (pairedWalshDegree S : ℝ) ≤ (99/200 : ℝ)*((d : ℝ)+1) := by
    have hh : (200 : ℝ)*pairedWalshDegree S ≤ 99*((d : ℝ)+1) := by exact_mod_cast hnat
    linarith
  have h := first_arcsine_reduced_level_lower S (ρ := (99/200 : ℝ))
    (by norm_num) (by norm_num) ha (by rw [hp]; norm_num) hjρ hhalf
  rw [hp] at h
  norm_num only at h
  change firstLayerLowLevelConstant/((d : ℝ)+1)^(3/2 : ℝ) ≤ _
  convert h using 1
  unfold firstLayerLowLevelConstant
  dsimp [a]
  ring

end NeuralGeneralization
