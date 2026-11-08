import NeuralGeneralization.OnlineLowerTanhCompetitivePeaks

/-! # Concrete nonnegative bias peaks and finite competitive peak indices -/
noncomputable section
open scoped BigOperators Topology Classical
namespace NeuralGeneralization.OnlineLowerTanh

def bulkPeakCenter (n l : ℕ) (a : ℝ) : ℝ :=
  (2*(l : ℝ)+1-(n%2 : ℕ))*a

lemma periodic_response_nat_peak {a : ℝ} (ha : 0 < a) (l : ℕ) :
    periodicFourierResponse a ((2*(l : ℝ)+1)*a) =
      (-1 : ℝ)^l*periodicFourierMaximum a := by
  induction l with
  | zero => simp [periodicFourierMaximum]
  | succ l ih =>
    rw [show (2*((l+1 : ℕ) : ℝ)+1)*a = (2*(l : ℝ)+1)*a+2*a by push_cast; ring]
    rw [periodicFourierResponse_antiperiod ha, ih, pow_succ]
    ring

lemma periodic_derivative_nat_peak {a : ℝ} (ha : 0 < a) (l : ℕ) :
    periodicFourierDerivative a ((2*(l : ℝ)+1)*a) = 0 := by
  unfold periodicFourierDerivative
  rw [show (0 : ℝ) = ∑' _j : ℕ, (0 : ℝ) by simp]
  apply tsum_congr
  intro j
  have he : (2*(j : ℝ)+1)*periodicFrequency a*((2*(l : ℝ)+1)*a) =
      ((j+(2*j+1)*l : ℕ) : ℝ)*Real.pi+Real.pi/2 := by
    have hh := periodicFrequency_mul_gain ha.ne'
    push_cast
    calc
      _ = (2*(j : ℝ)+1)*(2*(l : ℝ)+1)*(periodicFrequency a*a) := by ring
      _ = _ := by rw [hh]; ring
  rw [he, Real.cos_add_pi_div_two, Real.sin_nat_mul_pi]
  simp

lemma bulkPeakCenter_signed_periodic {a : ℝ} (ha : 0 < a) (n l : ℕ) :
    (-1 : ℝ)^l*periodicFourierResponse a (bulkPeakCenter n l a+(n%2 : ℕ)*a) =
      periodicFourierMaximum a := by
  rw [show bulkPeakCenter n l a+(n%2 : ℕ)*a = (2*(l : ℝ)+1)*a by unfold bulkPeakCenter; ring,
    periodic_response_nat_peak ha]
  have hs : (-1 : ℝ)^l*(-1 : ℝ)^l=1 := by rw [← pow_add, ← two_mul, pow_mul]; norm_num
  rw [← mul_assoc, hs, one_mul]

lemma bulkPeakCenter_periodic_stationary {a : ℝ} (ha : 0 < a) (n l : ℕ) :
    periodicFourierDerivative a (bulkPeakCenter n l a+(n%2 : ℕ)*a) = 0 := by
  rw [show bulkPeakCenter n l a+(n%2 : ℕ)*a = (2*(l : ℝ)+1)*a by unfold bulkPeakCenter; ring]
  exact periodic_derivative_nat_peak ha l

lemma bulkPeakCenter_nonneg {a : ℝ} (ha : 0 ≤ a) (n l : ℕ) :
    0 ≤ bulkPeakCenter n l a := by
  have hm : ((n%2 : ℕ) : ℝ) ≤ 1 := by exact_mod_cast (show n%2≤1 by omega)
  unfold bulkPeakCenter
  exact mul_nonneg (by positivity [show 0 ≤ 2*(l : ℝ)+1-(n%2 : ℕ) by nlinarith]) ha

/-- Bias reflection allows the eventual comparison to use only a fixed finite
set of nonnegative natural-index peaks. This statement uses actual finite
coefficients and is uniform in gain. -/
theorem equalBulk_competitive_natural_peak_neighborhood :
    ∃ J : ℕ, ∀ δ : ℝ, 0 < δ → δ < 1 → ∃ N₀ : ℕ, 0 < N₀ ∧
      ∀ n : ℕ, N₀ ≤ n → ∀ a : ℝ, 1 ≤ a → a ≤ 2 → ∀ B : ℝ, 0 ≤ B →
      |parityCorrelation (fun _ : Fin n => a) (bulkCentralBias n a)| ≤
        |parityCorrelation (fun _ : Fin n => a) B| →
      ∃ l : ℕ, l ≤ J ∧ |B-bulkPeakCenter n l a| ≤ δ := by
  obtain ⟨R, hR, hloc⟩ := equalBulk_competitive_peak_neighborhood
  refine ⟨⌈R⌉₊, ?_⟩
  intro δ hδ hδ1
  obtain ⟨N₀, hN₀, hN⟩ := hloc δ hδ
  refine ⟨N₀, hN₀, ?_⟩
  intro n hn a ha ha2 B hB hcomp
  obtain ⟨q, hq, hqR, hdist⟩ := hN n hn a ha ha2 B hcomp
  obtain ⟨z, hz⟩ := hq
  have hqpos : 1 ≤ q := by
    by_contra h
    have hqneg : q ≤ -1 := by omega
    have hqRneg : (q : ℝ) ≤ -1 := by exact_mod_cast hqneg
    have hm : (0 : ℝ) ≤ (n%2 : ℕ) := by positivity
    have harg : a*((q : ℝ)-(n%2 : ℕ)) ≤ -1 := by nlinarith
    have hh := (abs_le.mp hdist).2
    linarith
  have hz0 : 0 ≤ z := by omega
  let l := z.toNat
  have hzl : (l : ℤ)=z := Int.toNat_of_nonneg hz0
  have hql : q = 2*(l : ℤ)+1 := by omega
  have hqreal : (q : ℝ) = 2*(l : ℝ)+1 := by exact_mod_cast hql
  refine ⟨l, ?_, ?_⟩
  · have hRbound := (abs_le.mp hqR).2
    rw [hqreal] at hRbound
    have hlR : (l : ℝ) ≤ R := by nlinarith
    have hlceil : (l : ℝ) ≤ (⌈R⌉₊ : ℕ) := hlR.trans (Nat.le_ceil R)
    exact_mod_cast hlceil
  · simpa only [hqreal, bulkPeakCenter, mul_comm a] using hdist

end NeuralGeneralization.OnlineLowerTanh
