import NeuralGeneralization.ArcsineNoiseLower

/-! Comparing two actual noise scales isolates the high-degree spectral tail. -/

noncomputable section
namespace NeuralGeneralization
open scoped BigOperators

theorem one_sub_pow_le_nat_mul {t : ℝ} (ht0 : 0 ≤ t) (ht1 : t ≤ 1) (n : ℕ) :
    1-(1-t)^n ≤ (n : ℝ)*t := by
  induction n with
  | zero => simp
  | succ n ih =>
    have hp := pow_le_one₀ (n := n) (show 0 ≤ 1-t by linarith) (show 1-t ≤ 1 by linarith)
    have hm := mul_le_mul_of_nonneg_left hp ht0
    rw [pow_succ,Nat.cast_add,Nat.cast_one]
    nlinarith

theorem noise_power_gap_compare {r n : ℕ} (hr : 0 < r) (hn : n ≤ r)
    {η : ℝ} (hη0 : 0 ≤ η) (hη1 : η ≤ 1) :
    1-(1-η/(r : ℝ))^n ≤ 2*η*(1-(1-1/(r : ℝ))^n) := by
  have hr0 : (0 : ℝ) < r := Nat.cast_pos.mpr hr
  have hr1 : (1 : ℝ) ≤ r := by exact_mod_cast hr
  have hn1 : (n : ℝ)/r ≤ 1 := (div_le_one hr0).mpr (by exact_mod_cast hn)
  have ht0 : 0 ≤ 1/(r : ℝ) := by positivity
  have ht1 : 1/(r : ℝ) ≤ 1 := (div_le_one hr0).mpr hr1
  have hg : 0 ≤ 1-(1-1/(r : ℝ))^n :=
    sub_nonneg.mpr (pow_le_one₀ (n := n) (by linarith) (by linarith))
  have hb := one_sub_pow_mul_le_one ht1 n
  have hfrac : (n : ℝ)*(1/(r : ℝ)) = n/r := by ring
  rw [hfrac] at hb
  have hsmall : (n : ℝ)/r ≤ 2*(1-(1-1/(r : ℝ))^n) := by
    have hh := mul_nonneg hg (sub_nonneg.mpr hn1)
    nlinarith
  have hup := one_sub_pow_le_nat_mul
    (div_nonneg hη0 hr0.le) ((div_le_one hr0).mpr (hη1.trans hr1)) n
  have hh := mul_le_mul_of_nonneg_left hsmall hη0
  rw [show (n : ℝ)*(η/(r : ℝ)) = η*((n : ℝ)/r) by ring] at hup
  nlinarith

theorem arcsineNoiseGap_eq_spectral_sum (d k : ℕ) (ρ : ℝ) :
    arcsineNoiseGap d k ρ = ∑ S : Finset (Fin d),
      walshCoefficients (arcsineProfile d k) S*(1-ρ^S.card) := by
  have hsum : (∑ S : Finset (Fin d),walshCoefficients (arcsineProfile d k) S) = 1 := by
    have h := walshExpansion_coefficients (arcsineProfile d k) (fun _ => true)
    simpa [walshExpansion,walshCharacter,cubeCoordinateSign,arcsineProfile_one] using h
  unfold arcsineNoiseGap
  conv_lhs => rw [cubeNoiseMean_sub,cubeNoiseMean_const,cubeNoiseMean_walsh,← hsum,
    ← Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl
  intro S hS
  ring

/-- The low-frequency contribution at a finer noise scale is at most
`2η` times the coarser deficit. Every high-frequency contribution is bounded
by its actual spectral mass. -/
theorem arcsineNoiseGap_two_scale (d k : ℕ) {r : ℕ} (hr : 0 < r)
    {η : ℝ} (hη0 : 0 ≤ η) (hη1 : η ≤ 1) :
    arcsineNoiseGap d k (1-η/(r : ℝ)) ≤
      2*η*arcsineNoiseGap d k (1-1/(r : ℝ))+
        walshSpectralTail (arcsineProfile d k) r := by
  classical
  have hr0 : (0 : ℝ) < r := Nat.cast_pos.mpr hr
  have hr1 : (1 : ℝ) ≤ r := by exact_mod_cast hr
  have hρ00 : 0 ≤ 1-1/(r : ℝ) := by
    have := (div_le_one hr0).mpr hr1
    linarith
  have hρ01 : 1-1/(r : ℝ) ≤ 1 := by have := (one_div_pos.mpr hr0).le; linarith
  have hρ10 : 0 ≤ 1-η/(r : ℝ) := by
    have := (div_le_one hr0).mpr (hη1.trans hr1)
    linarith
  have hpoint (S : Finset (Fin d)) :
      walshCoefficients (arcsineProfile d k) S*(1-(1-η/(r : ℝ))^S.card) ≤
      2*η*(walshCoefficients (arcsineProfile d k) S*(1-(1-1/(r : ℝ))^S.card))+
        (if r ≤ S.card then walshCoefficients (arcsineProfile d k) S else 0) := by
    have hw := arcsineProfile_coefficient_nonneg d k S
    have hgap := sub_nonneg.mpr (pow_le_one₀ (n := S.card) hρ00 hρ01)
    by_cases hS : r ≤ S.card
    · rw [if_pos hS]
      have hp : 0 ≤ (1-η/(r : ℝ))^S.card := pow_nonneg hρ10 _
      nlinarith [mul_nonneg hw hp,mul_nonneg (mul_nonneg (by positivity : 0 ≤ 2*η) hw) hgap]
    · rw [if_neg hS]
      have hh := mul_le_mul_of_nonneg_left
        (noise_power_gap_compare hr (by omega : S.card ≤ r) hη0 hη1) hw
      nlinarith
  rw [arcsineNoiseGap_eq_spectral_sum,arcsineNoiseGap_eq_spectral_sum]
  have hh := Finset.sum_le_sum (fun S (_hS : S ∈ Finset.univ) => hpoint S)
  simpa only [Finset.sum_add_distrib,← Finset.mul_sum,← Finset.sum_filter,
    walshSpectralTail] using hh

end NeuralGeneralization
