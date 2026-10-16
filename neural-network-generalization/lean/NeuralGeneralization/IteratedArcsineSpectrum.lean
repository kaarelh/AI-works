import NeuralGeneralization.IteratedArcsineHankel
import NeuralGeneralization.KernelPoissonIntegral
import NeuralGeneralization.OddCoefficientTail

/-! Actual all-depth scalar coefficients and their exact Walsh/Poisson
transport. The optional coefficient comparison below is an elementary
transport lemma; sharp actual comparison is proved separately. -/
noncomputable section
namespace NeuralGeneralization.IteratedArcsineSpectrum
open MeasureTheory Set
open scoped BigOperators
open IteratedArcsineSeries

/-- The actual scalar series reindexed over its odd powers. -/
theorem hasSum_odd_iteratedArcsine (k : ℕ) {x : ℝ} (hx : |x| ≤ 1) :
    HasSum (fun n => coefficient k (2*n+1) * x^(2*n+1)) (iteratedArcsine k x) := by
  let f : ℕ → ℝ := fun m => coefficient k m * x^m
  have h : HasSum f (iteratedArcsine k x) := hasSum_iteratedArcsine k hx
  have hodd : Summable (fun n => f (2*n+1)) :=
    h.summable.comp_injective (fun n m hnm => by omega)
  have hezero (n : ℕ) : f (2*n) = 0 := by
    dsimp [f]
    rw [coefficient_even k (2*n) (by omega), zero_mul]
  have heven : HasSum (fun n => f (2*n)) 0 := by simpa only [hezero] using hasSum_zero
  have heq := (heven.even_add_odd hodd.hasSum).unique h
  simp only [zero_add] at heq
  have hh := hodd.hasSum
  rw [heq] at hh
  exact hh

theorem hasSum_odd_coefficient (k : ℕ) : HasSum (fun n => coefficient k (2*n+1)) 1 := by
  have h1 : iteratedArcsine k 1 = 1 := by
    induction k with
    | zero => rfl
    | succ k ih => simp [iteratedArcsine, ih, arcsineLink_one]
  have h := hasSum_odd_iteratedArcsine k (x := 1) (by norm_num)
  simpa only [one_pow, mul_one, h1] using h


/-- The abstract odd-series exponential deficit is exactly the endpoint
cusp of the actual neural scalar iterate. -/
theorem oddSeriesDeficit_eq (k : ℕ) {t : ℝ} (ht : 0 ≤ t) :
    oddSeriesDeficit (fun n => coefficient k (2*n+1)) t =
      1 - iteratedArcsine k (Real.exp (-t)) := by
  have hx : |Real.exp (-t)| ≤ 1 := by
    rw [abs_of_pos (Real.exp_pos _), Real.exp_le_one_iff]
    linarith
  have hs := hasSum_odd_iteratedArcsine k hx
  have hexp (n : ℕ) : Real.exp (-t)^(2*n+1) = Real.exp (-((2*n+1 : ℕ) : ℝ)*t) := by
    rw [← Real.exp_nat_mul]
    congr 1
    ring
  simp_rw [hexp] at hs
  have h := ((hasSum_odd_coefficient k).sub hs).tsum_eq
  change (∑' n, coefficient k (2*n+1)*(1-Real.exp (-((2*n+1 : ℕ) : ℝ)*t))) = _
  simpa only [mul_sub, mul_one] using h

/-- Exact all-depth Walsh expansion through actual nonnegative power
coefficients. -/
theorem power_spectrum_hasSum (d k : ℕ) (S : Finset (Fin d)) :
    HasSum (fun m => coefficient k m *
      walshCoefficients (biasedProfile (fun t => t^m)) S)
      (walshCoefficients (arcsineProfile d k) S) := by
  have h := walshCoefficients_hasSum
    (fun m x => coefficient k m * (biasedProfile id x)^m)
    (arcsineProfile d k)
    (fun x => hasSum_iteratedArcsine k (abs_biasedProfile_id_le_one x)) S
  convert h using 1
  funext m
  rw [walshCoefficients_const_mul]
  rfl

/-- Odd-power form needed for the parity-correct Poisson transform. -/
theorem odd_power_spectrum_hasSum (d k : ℕ) (S : Finset (Fin d)) :
    HasSum (fun n => coefficient k (2*n+1) *
      walshCoefficients (biasedProfile (fun t => t^(2*n+1))) S)
      (walshCoefficients (arcsineProfile d k) S) := by
  have h := walshCoefficients_hasSum
    (fun n x => coefficient k (2*n+1) * (biasedProfile id x)^(2*n+1))
    (arcsineProfile d k)
    (fun x => hasSum_odd_iteratedArcsine k (abs_biasedProfile_id_le_one x)) S
  convert h using 1
  funext n
  rw [walshCoefficients_const_mul]
  rfl

/-- Reference Gamma coefficients after odd-power reindexing. -/
theorem gamma_power_spectrum_hasSum (d : ℕ) {β : ℝ} (hβ0 : 0 < β) (hβ1 : β < 1)
    (S : Finset (Fin d)) :
    HasSum (fun n => (Real.Gamma (((2*n+1 : ℕ) : ℝ)-β)/((2*n+1).factorial : ℝ)) *
      walshCoefficients (biasedProfile (fun t => t^(2*n+1))) S)
      (((d : ℝ)+1)^(-β) *
        (∫ u : ℝ in Ioi 0, u^(-1-β) * oddPoissonEndpoint d u S)) := by
  let f : ℕ → ℝ := fun m => if Odd m then
    (Real.Gamma ((m : ℝ)-β)/(m.factorial : ℝ))*
      ((biasedPathCount m S : ℝ)/((d : ℝ)+1)^m) else 0
  have h : HasSum f _ := normalized_gamma_weighted_odd_biased_walk_hasSum d hβ0 hβ1 S
  have hodd : Summable (fun n => f (2*n+1)) :=
    h.summable.comp_injective (fun n m hnm => by omega)
  have heven : HasSum (fun n => f (2*n)) 0 := by
    have he : (fun n => f (2*n)) = fun _ : ℕ => (0 : ℝ) := by
      funext n
      simp [f, Nat.odd_mul]
    rw [he]
    exact hasSum_zero
  have heq := (heven.even_add_odd hodd.hasSum).unique h
  simp only [zero_add] at heq
  have hh := hodd.hasSum
  rw [heq] at hh
  convert hh using 1
  funext n
  rw [biasedDot_power_coefficient_walk]
  simp [f, show Odd (2*n+1) from ⟨n,rfl⟩]

/-- Transport of an actual coefficient comparison to the actual neural
Walsh eigenvalues, with no spectral comparison assumption. -/
theorem poisson_integral_comparison (d k : ℕ) {β c C : ℝ}
    (hβ0 : 0 < β) (hβ1 : β < 1)
    (hcoeff : ∀ n : ℕ,
      c * (Real.Gamma (((2*n+1 : ℕ) : ℝ)-β)/((2*n+1).factorial : ℝ)) ≤ coefficient k (2*n+1) ∧
      coefficient k (2*n+1) ≤ C *
        (Real.Gamma (((2*n+1 : ℕ) : ℝ)-β)/((2*n+1).factorial : ℝ)))
    (S : Finset (Fin d)) :
    c * (((d : ℝ)+1)^(-β) *
      (∫ u : ℝ in Ioi 0, u^(-1-β) * oddPoissonEndpoint d u S)) ≤
        walshCoefficients (arcsineProfile d k) S ∧
    walshCoefficients (arcsineProfile d k) S ≤
      C * (((d : ℝ)+1)^(-β) *
        (∫ u : ℝ in Ioi 0, u^(-1-β) * oddPoissonEndpoint d u S)) := by
  have ha := odd_power_spectrum_hasSum d k S
  have hg := gamma_power_spectrum_hasSum d hβ0 hβ1 S
  constructor
  · apply hasSum_le _ (hg.mul_left c) ha
    intro n
    simpa only [mul_assoc] using mul_le_mul_of_nonneg_right (hcoeff n).1
      (biasedDot_power_coefficient_nonneg (2*n+1) S)
  · apply hasSum_le _ ha (hg.mul_left C)
    intro n
    simpa only [mul_assoc] using mul_le_mul_of_nonneg_right (hcoeff n).2
      (biasedDot_power_coefficient_nonneg (2*n+1) S)

end NeuralGeneralization.IteratedArcsineSpectrum
