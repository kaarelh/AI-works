import Mathlib

/-!
Finite algebra behind the normalized spectral-order argument. The main lemma
proves preservation of likelihood-ratio order by a matrix with nonnegative
ordered two-by-two minors. Neither the analytic Fourier integrals, the cube
adjacency identification, nor the infinite-series limits are formalized here.
-/
namespace IndependentResearch
open scoped BigOperators

/-- Symmetrized two-by-two Cauchy--Binet expansion for two finite rows. -/
theorem spectral_minor_double_sum {ι : Type*} [Fintype ι]
    (v w a b : ι → ℝ) :
    (∑ i, ∑ j, (v i * w j - v j * w i) * (a i * b j - a j * b i)) =
      2 * ((∑ i, v i * a i) * (∑ j, w j * b j) -
        (∑ i, v i * b i) * (∑ j, w j * a j)) := by
  have hp : ∀ i j, (v i * w j - v j * w i) * (a i * b j - a j * b i) =
      (v i * a i) * (w j * b j) - (v i * b i) * (w j * a j) -
        (w i * a i) * (v j * b j) + (w i * b i) * (v j * a j) := by
    intro i j
    ring
  simp_rw [hp, Finset.sum_add_distrib, Finset.sum_sub_distrib,
    ← Finset.mul_sum, ← Finset.sum_mul]
  ring

/-- A matrix with nonnegative ordered minors preserves row likelihood-ratio
order; no stochastic normalization is necessary. -/
theorem spectral_likelihood_ratio_preserved {ι κ : Type*}
    [Fintype ι] [LinearOrder ι] [LinearOrder κ]
    (v w : ι → ℝ) (T : ι → κ → ℝ)
    (hvw : ∀ i j, i ≤ j → v j * w i ≤ v i * w j)
    (hT : ∀ i j a b, i ≤ j → a ≤ b → T i b * T j a ≤ T i a * T j b)
    (a b : κ) (hab : a ≤ b) :
    (∑ i, v i * T i b) * (∑ j, w j * T j a) ≤
      (∑ i, v i * T i a) * (∑ j, w j * T j b) := by
  have hn : 0 ≤ ∑ i, ∑ j,
      (v i * w j - v j * w i) * (T i a * T j b - T j a * T i b) := by
    apply Finset.sum_nonneg
    intro i _
    apply Finset.sum_nonneg
    intro j _
    rcases le_total i j with hij | hji
    · apply mul_nonneg (sub_nonneg.mpr (hvw i j hij))
      have h := hT i j a b hij hab
      nlinarith
    · apply mul_nonneg_of_nonpos_of_nonpos
      · have h := hvw j i hji
        linarith
      · have h := hT j i a b hji hab
        nlinarith
  rw [spectral_minor_double_sum v w (fun i => T i a) (fun i => T i b)] at hn
  linarith

/-- Reweighting coefficient rows by the same nonnegative sequence preserves
all their ordered cross products. This covers the tangent multiplier 1+2n. -/
theorem spectral_common_coefficient_reweighting {ι : Type*} [LinearOrder ι]
    (a b c : ι → ℝ) (hc : ∀ i, 0 ≤ c i)
    (hab : ∀ i j, i ≤ j → a j * b i ≤ a i * b j) :
    ∀ i j, i ≤ j → (c j * a j) * (c i * b i) ≤
      (c i * a i) * (c j * b j) := by
  intro i j hij
  have h := mul_le_mul_of_nonneg_left (hab i j hij) (mul_nonneg (hc i) (hc j))
  nlinarith [h]

/-- Ordered cross products imply a comparison of normalized upper-tail mass.
The two finite sets represent the upper and lower degree blocks. -/
theorem spectral_normalized_tail_order {ι : Type*}
    (high low : Finset ι) (f g : ι → ℝ)
    (hf : 0 < (∑ i ∈ high, f i) + ∑ i ∈ low, f i)
    (hg : 0 < (∑ i ∈ high, g i) + ∑ i ∈ low, g i)
    (hcross : ∀ i ∈ high, ∀ j ∈ low, f i * g j ≤ g i * f j) :
    (∑ i ∈ high, f i) / ((∑ i ∈ high, f i) + ∑ i ∈ low, f i) ≤
      (∑ i ∈ high, g i) / ((∑ i ∈ high, g i) + ∑ i ∈ low, g i) := by
  have hsum : (∑ i ∈ high, f i) * (∑ j ∈ low, g j) ≤
      (∑ i ∈ high, g i) * (∑ j ∈ low, f j) := by
    simp_rw [Finset.sum_mul, Finset.mul_sum]
    exact Finset.sum_le_sum (fun i hi => Finset.sum_le_sum (fun j hj => hcross i hi j hj))
  apply (div_le_div_iff₀ hf hg).mpr
  nlinarith [hsum]

/-- The adjacent minor of the squared cube radial adjacency has a
nonnegative polynomial expression in the two distances to its endpoints. -/
theorem spectral_radial_adjacent_minor (a b : ℝ) (ha : 0 ≤ a) (hb : 0 ≤ b) :
    (a + 1) * (a + 2) * (b + 1) * (b + 2) ≤
      (2*a*b + 5*a + b + 2) * (2*a*b + a + 5*b + 2) := by
  have hid : (2*a*b + 5*a + b + 2) * (2*a*b + a + 5*b + 2) -
      (a + 1) * (a + 2) * (b + 1) * (b + 2) =
      3*a^2*b^2 + 9*a^2*b + 3*a^2 + 9*a*b^2 + 25*a*b + 6*a + 3*b^2 + 6*b := by
    ring
  apply sub_nonneg.mp
  rw [hid]
  positivity

/-- For a nonnegative tridiagonal matrix, adjacent principal minors are
sufficient for every ordered two-by-two minor to be nonnegative. -/
theorem spectral_tridiagonal_minors (T : ℕ → ℕ → ℝ)
    (hn : ∀ i j, 0 ≤ T i j)
    (hband : ∀ i j, i + 1 < j ∨ j + 1 < i → T i j = 0)
    (hadj : ∀ i, T i (i+1) * T (i+1) i ≤ T i i * T (i+1) (i+1)) :
    ∀ i j a b, i ≤ j → a ≤ b → T i b * T j a ≤ T i a * T j b := by
  intro i j a b hij hab
  by_cases heq : i = j
  · subst j
    nlinarith
  by_cases heq' : a = b
  · subst b
    exact le_rfl
  by_cases hib : T i b = 0
  · rw [hib, zero_mul]
    exact mul_nonneg (hn i a) (hn j b)
  by_cases hja : T j a = 0
  · rw [hja, mul_zero]
    exact mul_nonneg (hn i a) (hn j b)
  have hbi : b ≤ i + 1 := by
    by_contra h
    exact hib (hband i b (Or.inl (by omega)))
  have haj : j ≤ a + 1 := by
    by_contra h
    exact hja (hband j a (Or.inr (by omega)))
  have hai : a = i := by omega
  have hbj : b = i + 1 := by omega
  have hji : j = i + 1 := by omega
  subst a
  subst b
  subst j
  exact hadj i

/-- Once the first two rows are likelihood-ratio ordered, repeated application
of a matrix with ordered nonnegative minors preserves consecutive-time order. -/
theorem spectral_iterated_row_order {ι : Type*} [Fintype ι] [LinearOrder ι]
    (T : ι → ι → ℝ) (R : ℕ → ι → ℝ)
    (hstep : ∀ n j, R (n+1) j = ∑ i, R n i * T i j)
    (hT : ∀ i j a b, i ≤ j → a ≤ b → T i b * T j a ≤ T i a * T j b)
    (hbase : ∀ a b, a ≤ b → R 0 b * R 1 a ≤ R 0 a * R 1 b) :
    ∀ n a b, a ≤ b → R n b * R (n+1) a ≤ R n a * R (n+1) b := by
  intro n
  induction n with
  | zero => exact hbase
  | succ n ih =>
    intro a b hab
    have h := spectral_likelihood_ratio_preserved (R n) (R (n+1)) T ih hT a b hab
    simpa only [← hstep] using h

end IndependentResearch
