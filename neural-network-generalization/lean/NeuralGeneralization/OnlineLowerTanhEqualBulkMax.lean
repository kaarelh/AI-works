import NeuralGeneralization.OnlineLowerTanhNaturalLocal
import NeuralGeneralization.OnlineLowerTanhCentralValues
import NeuralGeneralization.OnlineLowerTanhPeakComparison

/-! # Global arbitrary-bias bounds for actual equal-bulk tanh coefficients -/
noncomputable section
open scoped BigOperators Topology Classical
namespace NeuralGeneralization.OnlineLowerTanh

lemma abs_parityCorrelation_abs_bias {n : ℕ} (u : Fin n → ℝ) (B : ℝ) :
    |parityCorrelation u (|B|)| = |parityCorrelation u B| := by
  by_cases hB : 0 ≤ B
  · rw [abs_of_nonneg hB]
  · rw [abs_of_neg (lt_of_not_ge hB), abs_parityCorrelation_bias_neg]

/-- All noncentral periodic peaks are excluded for a coefficient competitive
with the canonical central candidate. This is a finite comparison of literal
coefficients, after the global compactness and local saddle estimates. -/
theorem equalBulk_competitive_central_neighborhood :
    ∃ N₀ : ℕ, 0 < N₀ ∧ ∀ r : ℕ, N₀ ≤ 2*r → ∀ a : ℝ, 1 ≤ a → a ≤ 2 →
      (∀ B : ℝ, 0 ≤ B → balancedParity r a ≤
        |parityCorrelation (fun _ : Fin (2*r+1) => a) B| → |B| ≤ periodicLocalRadius) ∧
      (∀ B : ℝ, 0 ≤ B → balancedParity r a ≤
        |parityCorrelation (fun _ : Fin (2*r) => a) B| → |B-a| ≤ periodicLocalRadius) := by
  obtain ⟨J, hloc⟩ := equalBulk_competitive_natural_peak_neighborhood
  let δ := min periodicLocalRadius (1/2)
  have hδ : 0 < δ := lt_min periodicLocalRadius_pos (by norm_num)
  have hδ1 : δ < 1 := lt_of_le_of_lt (min_le_right _ _) (by norm_num)
  have hδrad : δ ≤ periodicLocalRadius := min_le_left _ _
  obtain ⟨N₁, hN₁, hnear⟩ := hloc δ hδ hδ1
  obtain ⟨α, hα, N₂, hN₂, hreference⟩ := equalBulk_reference_normalized_lower
  obtain ⟨N₃, hN₃, hlocal⟩ := equalBulk_natural_local_improvement J
  let K := balancedBiasImprovementConstant (naturalPeakCompactRadius J)
  have hK : 0 ≤ K := (balancedBiasImprovementConstant_pos (naturalPeakCompactRadius_pos J).le).le
  obtain ⟨N₄, hN₄, hstrict⟩ := finite_noncentral_peaks_strict J K α hK hα
  refine ⟨max N₁ (max N₂ (max N₃ N₄)), by omega, ?_⟩
  intro r hr a ha ha2
  have hr1 : N₁ ≤ 2*r := le_trans (le_max_left _ _) hr
  have hr2 : N₂ ≤ 2*r := le_trans (le_max_left _ _) (le_trans (le_max_right _ _) hr)
  have hr3 : N₃ ≤ 2*r := le_trans (le_max_left _ _) (le_trans (le_max_right _ _) (le_trans (le_max_right _ _) hr))
  have hr4 : N₄ ≤ 2*r := le_trans (le_max_right _ _) (le_trans (le_max_right _ _) (le_trans (le_max_right _ _) hr))
  have href := hreference r hr2 a ha ha2
  constructor
  · intro B hB hcomp
    have hcentral : |parityCorrelation (fun _ : Fin (2*r+1) => a)
        (bulkCentralBias (2*r+1) a)| ≤ |parityCorrelation (fun _ : Fin (2*r+1) => a) B| := by
      rw [show bulkCentralBias (2*r+1) a = 0 by simp [bulkCentralBias],
        odd_central_abs_eq_balancedParity r ha]
      exact hcomp
    obtain ⟨l, hlJ, hdist⟩ := hnear (2*r+1) (by omega) a ha ha2 B hB hcentral
    have hdist' := hdist.trans hδrad
    have hlocalB := hlocal (2*r+1) (by omega) a ha ha2 l hlJ B hdist'
    have hcenter : bulkPeakCenter (2*r+1) l a = 2*(l : ℝ)*a := by
      simp only [bulkPeakCenter, show (2*r+1)%2=1 by omega, Nat.cast_one]
      ring
    have hdiv : (2*r+1)/2=r := by omega
    rw [hcenter, hdiv] at hlocalB
    have hlzero : l=0 := by
      by_contra hl
      have hsl := (hstrict r l (by omega) hlJ a ha).1 (by omega)
        (by simpa only [Nat.cast_add, Nat.cast_mul, Nat.cast_ofNat, Nat.cast_one] using href.2)
      have hc := mul_le_mul_of_nonneg_left hcomp (Real.sqrt_nonneg ((2*r+1 : ℕ) : ℝ))
      simp only [Nat.cast_add, Nat.cast_mul, Nat.cast_ofNat, Nat.cast_one] at hlocalB hc
      exact (not_lt_of_ge hc) (lt_of_le_of_lt hlocalB hsl)
    simpa [hlzero, bulkPeakCenter] using hdist'
  · intro B hB hcomp
    have hcentral : |parityCorrelation (fun _ : Fin (2*r) => a)
        (bulkCentralBias (2*r) a)| ≤ |parityCorrelation (fun _ : Fin (2*r) => a) B| := by
      simpa only [bulkCentralBias, show (2*r)%2=0 by omega, show ¬(0 : ℕ)=1 by omega,
        if_false, even_central_abs_eq_balancedParity r ha] using hcomp
    obtain ⟨l, hlJ, hdist⟩ := hnear (2*r) hr1 a ha ha2 B hB hcentral
    have hdist' := hdist.trans hδrad
    have hlocalB := hlocal (2*r) hr3 a ha ha2 l hlJ B hdist'
    have hcenter : bulkPeakCenter (2*r) l a = (2*(l : ℝ)+1)*a := by
      simp only [bulkPeakCenter, show (2*r)%2=0 by omega, Nat.cast_zero, sub_zero]
    have hdiv : (2*r)/2=r := by omega
    rw [hcenter, hdiv] at hlocalB
    have hlzero : l=0 := by
      by_contra hl
      have hsl := (hstrict r l (by omega) hlJ a ha).2 hr4
        (by simpa only [Nat.cast_mul, Nat.cast_ofNat] using href.1)
      have hc := mul_le_mul_of_nonneg_left hcomp (Real.sqrt_nonneg ((2*r : ℕ) : ℝ))
      simp only [Nat.cast_mul, Nat.cast_ofNat] at hlocalB hc
      exact (not_lt_of_ge hc) (lt_of_le_of_lt hlocalB hsl)
    simpa [hlzero, bulkPeakCenter] using hdist'

/-- At every sufficiently large odd bulk degree, zero bias is an exact
absolute maximizer for all gains in `[1,2]`. -/
theorem odd_equalBulk_arbitrary_bias :
    ∃ N₀ : ℕ, 0 < N₀ ∧ ∀ r : ℕ, N₀ ≤ 2*r+1 →
      ∀ a : ℝ, 1 ≤ a → a ≤ 2 → ∀ B : ℝ,
      |parityCorrelation (fun _ : Fin (2*r+1) => a) B| ≤ balancedParity r a := by
  obtain ⟨N₁, hN₁, hnear⟩ := equalBulk_competitive_central_neighborhood
  obtain ⟨N₂, hN₂, hlocal⟩ := equalBulk_odd_central_local_max
  refine ⟨max (N₁+1) N₂, by omega, ?_⟩
  intro r hr a ha ha2 B
  by_cases hcomp : balancedParity r a ≤ |parityCorrelation (fun _ : Fin (2*r+1) => a) B|
  · have hc : balancedParity r a ≤ |parityCorrelation (fun _ : Fin (2*r+1) => a) (|B|)| := by
      simpa only [abs_parityCorrelation_abs_bias] using hcomp
    have hdist := (hnear r (by omega) a ha ha2).1 |B| (abs_nonneg B) hc
    have hh := hlocal (2*r+1) (by omega) (by exact ⟨r, by omega⟩) a ha ha2 |B| hdist
    simpa only [abs_parityCorrelation_abs_bias, odd_central_abs_eq_balancedParity r ha] using hh
  · exact le_of_lt (lt_of_not_ge hcomp)

/-- At every sufficiently large even bulk degree, arbitrary bias can improve
on the next odd balanced coefficient by at most a uniform relative `O(n⁻²)`.
No claim that bias `a` is an exact finite-degree optimizer is used. -/
theorem even_equalBulk_arbitrary_bias :
    ∃ K : ℝ, 0 < K ∧ ∃ N₀ : ℕ, 0 < N₀ ∧ ∀ r : ℕ, N₀ ≤ 2*r →
      ∀ a : ℝ, 1 ≤ a → a ≤ 2 → ∀ B : ℝ,
      |parityCorrelation (fun _ : Fin (2*r) => a) B| ≤
        balancedParity r a*(1+K/(2*(r : ℝ))^2) := by
  obtain ⟨N₁, hN₁, hnear⟩ := equalBulk_competitive_central_neighborhood
  obtain ⟨N₂, hN₂, hlocal⟩ := equalBulk_natural_local_improvement 0
  obtain ⟨α, hα, N₃, hN₃, href⟩ := equalBulk_reference_normalized_lower
  let K₀ := balancedBiasImprovementConstant (naturalPeakCompactRadius 0)
  have hK₀ : 0 < K₀ := balancedBiasImprovementConstant_pos (naturalPeakCompactRadius_pos 0).le
  refine ⟨K₀/α, div_pos hK₀ hα, max N₁ (max N₂ N₃), by omega, ?_⟩
  intro r hr a ha ha2 B
  have hr1 : N₁ ≤ 2*r := le_trans (le_max_left _ _) hr
  have hr2 : N₂ ≤ 2*r := le_trans (le_max_left _ _) (le_trans (le_max_right _ _) hr)
  have hr3 : N₃ ≤ 2*r := le_trans (le_max_right _ _) (le_trans (le_max_right _ _) hr)
  have hn0 : 0 < 2*r := lt_of_lt_of_le hN₁ hr1
  have hnR : (0 : ℝ) < 2*(r : ℝ) := by exact_mod_cast hn0
  have hq := balancedParity_pos_of_one_le r a ha
  have hgrowth : balancedParity r a ≤ balancedParity r a*(1+(K₀/α)/(2*(r : ℝ))^2) := by
    have hh : 0 ≤ (K₀/α)/(2*(r : ℝ))^2 := by positivity
    nlinarith
  by_cases hcomp : balancedParity r a ≤ |parityCorrelation (fun _ : Fin (2*r) => a) B|
  · have hc : balancedParity r a ≤ |parityCorrelation (fun _ : Fin (2*r) => a) (|B|)| := by
      simpa only [abs_parityCorrelation_abs_bias] using hcomp
    have hdist := (hnear r hr1 a ha ha2).2 |B| (abs_nonneg B) hc
    have hcenter : bulkPeakCenter (2*r) 0 a = a := by simp [bulkPeakCenter]
    have hi := hlocal (2*r) hr2 a ha ha2 0 le_rfl |B| (by simpa only [hcenter] using hdist)
    rw [hcenter, show (2*r)/2+0=r by omega, even_central_signed_eq_balancedParity] at hi
    simp only [abs_parityCorrelation_abs_bias, Nat.cast_mul, Nat.cast_ofNat] at hi
    have hreference := (href r hr3 a ha ha2).1
    simp only [Nat.cast_mul, Nat.cast_ofNat] at hreference
    have hm := mul_le_mul_of_nonneg_right hreference
      (show 0 ≤ (K₀/α)/(2*(r : ℝ))^2 by positivity)
    have he : α*((K₀/α)/(2*(r : ℝ))^2) = K₀/(2*(r : ℝ))^2 := by
      field_simp
    rw [he] at hm
    have htotal : Real.sqrt (2*(r : ℝ))*|parityCorrelation (fun _ : Fin (2*r) => a) B| ≤
        Real.sqrt (2*(r : ℝ))*(balancedParity r a*(1+(K₀/α)/(2*(r : ℝ))^2)) := by
      dsimp [K₀] at *
      nlinarith
    exact (mul_le_mul_iff_right₀ (Real.sqrt_pos.2 hnR)).mp htotal
  · exact (le_of_lt (lt_of_not_ge hcomp)).trans hgrowth

end NeuralGeneralization.OnlineLowerTanh
