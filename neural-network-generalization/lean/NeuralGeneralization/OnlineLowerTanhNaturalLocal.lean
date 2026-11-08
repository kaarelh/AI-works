import NeuralGeneralization.OnlineLowerTanhNaturalPeaks
import NeuralGeneralization.OnlineLowerTanhLocalBias
import NeuralGeneralization.OnlineLowerTanhBiasSymmetry

/-! # Actual absolute-value comparisons near the finite natural bias peaks -/
noncomputable section
open scoped BigOperators Topology Classical
namespace NeuralGeneralization.OnlineLowerTanh

def naturalPeakCompactRadius (J : ℕ) : ℝ := 2*(2*(J : ℝ)+1)+periodicLocalRadius

lemma naturalPeakCompactRadius_pos (J : ℕ) : 0 < naturalPeakCompactRadius J := by
  unfold naturalPeakCompactRadius
  positivity [periodicLocalRadius_pos]

lemma bulkPeakCenter_compact {a : ℝ} (ha : 1 ≤ a) (ha2 : a ≤ 2)
    (n : ℕ) {l J : ℕ} (hl : l ≤ J) :
    |bulkPeakCenter n l a|+periodicLocalRadius ≤ naturalPeakCompactRadius J := by
  rw [abs_of_nonneg (bulkPeakCenter_nonneg (by linarith) n l)]
  have hm : (0 : ℝ) ≤ (n%2 : ℕ) := by positivity
  have hlR : (l : ℝ) ≤ J := by exact_mod_cast hl
  unfold bulkPeakCenter naturalPeakCompactRadius
  nlinarith

lemma signedBalancedBias_eq_abs {n : ℕ} (a s B : ℝ) (hs : |s|=1)
    (hf : 0 ≤ signedBalancedBias n a s B) :
    signedBalancedBias n a s B =
      Real.sqrt (n : ℝ)*|parityCorrelation (fun _ : Fin n => a) B| := by
  calc
    _ = |signedBalancedBias n a s B| := (abs_of_nonneg hf).symm
    _ = _ := by
      simp only [signedBalancedBias, abs_mul, hs, abs_pow, abs_neg, abs_one, one_pow,
        one_mul, abs_of_nonneg (Real.sqrt_nonneg _)]

lemma signedBalancedBias_natural_center (n l : ℕ) (a : ℝ) :
    signedBalancedBias n a ((-1 : ℝ)^l) (bulkPeakCenter n l a) =
      Real.sqrt (n : ℝ)*((-1 : ℝ)^(n/2+l)*
        parityCorrelation (fun _ : Fin n => a) (bulkPeakCenter n l a)) := by
  unfold signedBalancedBias
  rw [pow_add]
  ring

/-- A single uniform constant controls the possible improvement at every
natural peak in a fixed finite range. The finite parity coefficient is
literal, and the absolute value is justified by local signed positivity. -/
theorem equalBulk_natural_local_improvement (J : ℕ) :
    ∃ N₀ : ℕ, 0 < N₀ ∧ ∀ n : ℕ, N₀ ≤ n →
      ∀ a : ℝ, 1 ≤ a → a ≤ 2 → ∀ l : ℕ, l ≤ J → ∀ B : ℝ,
      |B-bulkPeakCenter n l a| ≤ periodicLocalRadius →
      Real.sqrt (n : ℝ)*|parityCorrelation (fun _ : Fin n => a) B| ≤
        Real.sqrt (n : ℝ)*((-1 : ℝ)^(n/2+l)*
          parityCorrelation (fun _ : Fin n => a) (bulkPeakCenter n l a))+
          balancedBiasImprovementConstant (naturalPeakCompactRadius J)/(n : ℝ)^2 := by
  let L := naturalPeakCompactRadius J
  have hL : 0 ≤ L := (naturalPeakCompactRadius_pos J).le
  obtain ⟨N₁, hN₁, himprove⟩ := signedBalancedBias_local_improvement L hL
  obtain ⟨N₂, hN₂, hpositive⟩ := signedBalancedBias_local_positive L hL
  refine ⟨max N₁ N₂, lt_of_lt_of_le hN₁ (le_max_left _ _), ?_⟩
  intro n hn a ha ha2 l hl B hB
  have ha0 : 0 < a := by linarith
  have hs : |(-1 : ℝ)^l|=1 := by simp
  have hc := bulkPeakCenter_compact ha ha2 n hl
  have hp := bulkPeakCenter_signed_periodic ha0 n l
  have hd := bulkPeakCenter_periodic_stationary ha0 n l
  have hi := himprove n ((le_max_left _ _).trans hn) a ha ha2 ((-1 : ℝ)^l) hs
    (bulkPeakCenter n l a) hc hp hd B hB
  have hb := hpositive n ((le_max_right _ _).trans hn) a ha ha2 ((-1 : ℝ)^l) hs
    (bulkPeakCenter n l a) hc hp B hB
  rw [signedBalancedBias_eq_abs a _ B hs hb.le, signedBalancedBias_natural_center] at hi
  exact hi

/-- Odd degree has an exact local maximum at zero bias, with no asymptotic
value error: the finite derivative vanishes by cube reflection. -/
theorem equalBulk_odd_central_local_max :
    ∃ N₀ : ℕ, 0 < N₀ ∧ ∀ n : ℕ, N₀ ≤ n → Odd n →
      ∀ a : ℝ, 1 ≤ a → a ≤ 2 → ∀ B : ℝ, |B| ≤ periodicLocalRadius →
      |parityCorrelation (fun _ : Fin n => a) B| ≤
        |parityCorrelation (fun _ : Fin n => a) 0| := by
  let L := naturalPeakCompactRadius 0
  have hL : 0 ≤ L := (naturalPeakCompactRadius_pos 0).le
  obtain ⟨N₁, hN₁, hmax⟩ := signedBalancedBias_local_stationary_max L hL
  obtain ⟨N₂, hN₂, hpositive⟩ := signedBalancedBias_local_positive L hL
  refine ⟨max N₁ N₂, lt_of_lt_of_le hN₁ (le_max_left _ _), ?_⟩
  intro n hn hnodd a ha ha2 B hB
  have hn0 : 0 < n := lt_of_lt_of_le hN₁ ((le_max_left _ _).trans hn)
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn0
  have hs : |(1 : ℝ)|=1 := by norm_num
  have hmod : n%2=1 := Nat.odd_iff.mp hnodd
  have hc0 : bulkPeakCenter n 0 a = 0 := by simp [bulkPeakCenter, hmod]
  have hc : |(0 : ℝ)|+periodicLocalRadius ≤ L := by
    simpa only [hc0] using bulkPeakCenter_compact ha ha2 n (show 0≤(0:ℕ) by omega)
  have hp : 1*periodicFourierResponse a (0+(n%2 : ℕ)*a)=periodicFourierMaximum a := by
    simp [hmod, periodicFourierMaximum]
  have hdist : |B-0|≤periodicLocalRadius := by simpa using hB
  have hi := hmax n ((le_max_left _ _).trans hn) a ha ha2 1 hs 0 hc hp
    (parityBiasFirst_zero_of_odd hnodd (fun _ : Fin n => a)) B hdist
  have hb := hpositive n ((le_max_right _ _).trans hn) a ha ha2 1 hs 0 hc hp B hdist
  have hz := hpositive n ((le_max_right _ _).trans hn) a ha ha2 1 hs 0 hc hp 0
    (by simpa using periodicLocalRadius_pos.le)
  rw [signedBalancedBias_eq_abs a 1 B hs hb.le, signedBalancedBias_eq_abs a 1 0 hs hz.le] at hi
  exact (mul_le_mul_iff_right₀ (Real.sqrt_pos.2 hnR)).mp hi

end NeuralGeneralization.OnlineLowerTanh
