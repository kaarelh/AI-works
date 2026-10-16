import NeuralGeneralization.GammaHalfBounds

/-! An unconditional two-sided Poisson-integral comparison for the actual
first arcsine layer, proved by its actual Taylor coefficients. -/
noncomputable section
namespace NeuralGeneralization
open MeasureTheory Set
open scoped BigOperators

/-- Explicit odd-exponent reindexing of the proved Gamma-weighted walk. -/
theorem halfGamma_power_spectrum_hasSum (d : ℕ) (S : Finset (Fin d)) :
    HasSum (fun n : ℕ => halfGammaCoefficient (2*n+1)*
      walshCoefficients (biasedProfile (fun t => t^(2*n+1))) S)
      (((d : ℝ)+1)^(-(1/2 : ℝ))*
        (∫ u : ℝ in Ioi 0,u^(-1-(1/2 : ℝ))*oddPoissonEndpoint d u S)) := by
  let f : ℕ → ℝ := fun m => if Odd m then
    halfGammaCoefficient m*((biasedPathCount m S : ℝ)/((d : ℝ)+1)^m) else 0
  have h : HasSum f (((d : ℝ)+1)^(-(1/2 : ℝ))*
      (∫ u : ℝ in Ioi 0,u^(-1-(1/2 : ℝ))*oddPoissonEndpoint d u S)) :=
    normalized_gamma_weighted_odd_biased_walk_hasSum d (by norm_num) (by norm_num) S
  have hodd : Summable (fun n => f (2*n+1)) := by
    exact h.summable.comp_injective (fun n m hnm => by omega)
  have heven : HasSum (fun n => f (2*n)) 0 := by
    have he : (fun n => f (2*n)) = fun _ : ℕ => (0 : ℝ) := by
      funext n
      simp [f,Nat.odd_mul]
    rw [he]
    exact hasSum_zero
  have heq := (heven.even_add_odd hodd.hasSum).unique h
  simp only [zero_add] at heq
  have hh := hodd.hasSum
  rw [heq] at hh
  convert hh using 1
  funext n
  rw [biasedDot_power_coefficient_walk]
  simp [f,show Odd (2*n+1) from ⟨n,rfl⟩]

/-- The actual first-layer Walsh coefficient is the convergent sum of its
actual nonnegative Taylor contributions. -/
theorem first_arcsine_power_spectrum_hasSum (d : ℕ) (S : Finset (Fin d)) :
    HasSum (fun n => arcsineLinkCoefficient n*
      walshCoefficients (biasedProfile (fun t => t^(2*n+1))) S)
      (walshCoefficients (arcsineProfile d 1) S) := by
  have h := walshCoefficients_hasSum
    (fun n x => arcsineLinkCoefficient n*(biasedProfile id x)^(2*n+1))
    (arcsineProfile d 1)
    (fun x => hasSum_arcsineLink_closed (abs_biasedProfile_id_le_one x)) S
  convert h using 1
  funext n
  rw [walshCoefficients_const_mul]
  rfl

/-- Full first-layer Poissonization, including both constants, the actual
biased kernel, and the parity-correct bias factor. -/
theorem first_arcsine_poisson_integral_comparison (d : ℕ) (S : Finset (Fin d)) :
    (((d : ℝ)+1)^(-(1/2 : ℝ))*
      (∫ u : ℝ in Ioi 0,u^(-1-(1/2 : ℝ))*oddPoissonEndpoint d u S))/8 ≤
      walshCoefficients (arcsineProfile d 1) S ∧
    walshCoefficients (arcsineProfile d 1) S ≤
      ((d : ℝ)+1)^(-(1/2 : ℝ))*
        (∫ u : ℝ in Ioi 0,u^(-1-(1/2 : ℝ))*oddPoissonEndpoint d u S) := by
  have ha := first_arcsine_power_spectrum_hasSum d S
  have hg := halfGamma_power_spectrum_hasSum d S
  constructor
  · apply hasSum_le _ (hg.div_const 8) ha
    intro n
    have h := mul_le_mul_of_nonneg_right (arcsineLinkCoefficient_gamma_comparison n).1
      (biasedDot_power_coefficient_nonneg (2*n+1) S)
    simpa only [div_mul_eq_mul_div] using h
  · apply hasSum_le _ ha hg
    intro n
    exact mul_le_mul_of_nonneg_right (arcsineLinkCoefficient_gamma_comparison n).2
      (biasedDot_power_coefficient_nonneg (2*n+1) S)

end NeuralGeneralization
