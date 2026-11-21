import Mathlib

/-!
The arithmetic/harmonic recursion for next constant-prefix interpolation.
The checked conclusions prove its sign and a uniform margin from an ordered positive spectrum.
The identification with cube kernel block elimination, activation spectra,
Gaussian conditioning, and random-feature limits remains outside this file.
-/
namespace IndependentResearch
noncomputable section

def arithmeticSpectrum (μ : ℕ → ℝ) (n : ℕ) : ℝ := (μ n + μ (n + 1)) / 2

def harmonicSpectrum (μ : ℕ → ℝ) (n : ℕ) : ℝ :=
  2 * μ n * μ (n + 1) / (μ n + μ (n + 1))

def prefixPrediction : List Bool → (ℕ → ℝ) → ℝ
  | [], _ => 0
  | false :: bs, μ => prefixPrediction bs (arithmeticSpectrum μ)
  | true :: bs, μ =>
      (μ 0 - μ 1) / (μ 0 + μ 1) +
        (1 - (μ 0 - μ 1) / (μ 0 + μ 1)) * prefixPrediction bs (harmonicSpectrum μ)

private lemma harmonic_le {a b c d : ℝ}
    (ha : 0 < a) (hb : 0 < b) (hac : a ≤ c) (hbd : b ≤ d) :
    2 * a * b / (a + b) ≤ 2 * c * d / (c + d) := by
  have hc : 0 < c := lt_of_lt_of_le ha hac
  have hd : 0 < d := lt_of_lt_of_le hb hbd
  apply (div_le_div_iff₀ (by positivity) (by positivity)).2
  have h1 := mul_nonneg (mul_nonneg ha.le hc.le) (sub_nonneg.mpr hbd)
  have h2 := mul_nonneg (mul_nonneg hb.le hd.le) (sub_nonneg.mpr hac)
  nlinarith

private lemma arithmetic_positive (μ : ℕ → ℝ) (hp : ∀ n, 0 < μ n) :
    ∀ n, 0 < arithmeticSpectrum μ n := by
  intro n
  unfold arithmeticSpectrum
  have h0 := hp n
  have h1 := hp (n + 1)
  positivity

private lemma arithmetic_monotone (μ : ℕ → ℝ) (hm : Monotone μ) :
    Monotone (arithmeticSpectrum μ) := by
  intro i j hij
  unfold arithmeticSpectrum
  have h0 := hm hij
  have h1 := hm (Nat.add_le_add_right hij 1)
  linarith

private lemma harmonic_positive (μ : ℕ → ℝ) (hp : ∀ n, 0 < μ n) :
    ∀ n, 0 < harmonicSpectrum μ n := by
  intro n
  unfold harmonicSpectrum
  have h0 := hp n
  have h1 := hp (n + 1)
  positivity

private lemma harmonic_monotone (μ : ℕ → ℝ)
    (hp : ∀ n, 0 < μ n) (hm : Monotone μ) :
    Monotone (harmonicSpectrum μ) := by
  intro i j hij
  exact harmonic_le (hp i) (hp (i + 1)) (hm hij) (hm (Nat.add_le_add_right hij 1))

/-- Every next-prefix interpolation value from an increasing positive spectrum
is nonpositive under the arithmetic/harmonic block recursion. -/
theorem ordered_spectrum_prefix_nonpositive (bits : List Bool) (μ : ℕ → ℝ)
    (hp : ∀ n, 0 < μ n) (hm : Monotone μ) : prefixPrediction bits μ ≤ 0 := by
  induction bits generalizing μ with
  | nil => simp [prefixPrediction]
  | cons b bs ih =>
    cases b with
    | false =>
      exact ih _ (arithmetic_positive μ hp) (arithmetic_monotone μ hm)
    | true =>
      have hr : (μ 0 - μ 1) / (μ 0 + μ 1) ≤ 0 :=
        div_nonpos_of_nonpos_of_nonneg (sub_nonpos.mpr (hm (by omega))) (le_of_lt (add_pos (hp 0) (hp 1)))
      have hh := ih _ (harmonic_positive μ hp) (harmonic_monotone μ hp hm)
      change (μ 0 - μ 1) / (μ 0 + μ 1) +
        (1 - (μ 0 - μ 1) / (μ 0 + μ 1)) * prefixPrediction bs (harmonicSpectrum μ) ≤ 0
      exact add_nonpos hr (mul_nonpos_of_nonneg_of_nonpos (by linarith) hh)

/-- A positive binary prefix and a strict first spectral rise make every
next-prefix prediction strictly negative. -/
theorem ordered_spectrum_prefix_negative (bits : List Bool) (μ : ℕ → ℝ)
    (hp : ∀ n, 0 < μ n) (hm : Monotone μ) (hs : μ 0 < μ 1)
    (hbits : true ∈ bits) : prefixPrediction bits μ < 0 := by
  induction bits generalizing μ with
  | nil => simp at hbits
  | cons b bs ih =>
    cases b with
    | false =>
      have hs' : arithmeticSpectrum μ 0 < arithmeticSpectrum μ 1 := by
        unfold arithmeticSpectrum
        have h12 : μ 1 ≤ μ 2 := hm (by omega)
        norm_num
        linarith
      exact ih _ (arithmetic_positive μ hp) (arithmetic_monotone μ hm) hs' (by simpa using hbits)
    | true =>
      have hr : (μ 0 - μ 1) / (μ 0 + μ 1) < 0 :=
        div_neg_of_neg_of_pos (sub_neg.mpr hs) (add_pos (hp 0) (hp 1))
      have hh := ordered_spectrum_prefix_nonpositive bs (harmonicSpectrum μ)
        (harmonic_positive μ hp) (harmonic_monotone μ hp hm)
      have hprod := mul_nonpos_of_nonneg_of_nonpos (show 0 ≤ 1 - (μ 0 - μ 1) / (μ 0 + μ 1) by linarith) hh
      change (μ 0 - μ 1) / (μ 0 + μ 1) +
        (1 - (μ 0 - μ 1) / (μ 0 + μ 1)) * prefixPrediction bs (harmonicSpectrum μ) < 0
      linarith


private def spectrumRelativeGap (μ : ℕ → ℝ) : ℝ :=
  (μ 1 - μ 0) / (μ 0 + μ 1)

private lemma arithmetic_gap_lower (μ : ℕ → ℝ)
    (hp : ∀ n, 0 < μ n) (hm : Monotone μ) :
    spectrumRelativeGap μ / 3 ≤ spectrumRelativeGap (arithmeticSpectrum μ) := by
  have ha := hp 0
  have hb := hp 1
  have hc := hp 2
  have hab : μ 0 ≤ μ 1 := hm (by omega)
  have hbc : μ 1 ≤ μ 2 := hm (by omega)
  have hform : spectrumRelativeGap (arithmeticSpectrum μ) =
      (μ 2 - μ 0) / (μ 0 + 2 * μ 1 + μ 2) := by
    unfold spectrumRelativeGap arithmeticSpectrum
    norm_num
    field_simp
    ring
  rw [hform]
  unfold spectrumRelativeGap
  rw [div_div]
  apply (div_le_div_iff₀ (by positivity) (by positivity)).2
  have h1 := mul_nonneg (sub_nonneg.mpr hbc) (show 0 ≤ μ 0 + 2 * μ 1 by positivity)
  have h2 := mul_nonneg (sub_nonneg.mpr hab) (show 0 ≤ μ 1 + μ 0 by positivity)
  nlinarith

private def firstTrueDepth : List Bool → ℕ
  | [] => 0
  | true :: _ => 0
  | false :: bs => firstTrueDepth bs + 1

private lemma firstTrueDepth_le (bits : List Bool) (hbits : true ∈ bits) :
    firstTrueDepth bits ≤ bits.length - 1 := by
  induction bits with
  | nil => simp at hbits
  | cons b bs ih =>
    cases b with
    | true => simp [firstTrueDepth]
    | false =>
      have hb : true ∈ bs := by simpa using hbits
      have hi := ih hb
      have hn : bs.length > 0 := List.length_pos_iff.mpr (by
        intro he
        simp [he] at hb)
      simp only [firstTrueDepth, List.length_cons]
      omega

private lemma prefix_depth_margin (bits : List Bool) (μ : ℕ → ℝ)
    (hp : ∀ n, 0 < μ n) (hm : Monotone μ) (hbits : true ∈ bits) :
    prefixPrediction bits μ ≤ -spectrumRelativeGap μ / 3 ^ firstTrueDepth bits := by
  induction bits generalizing μ with
  | nil => simp at hbits
  | cons b bs ih =>
    cases b with
    | false =>
      have hi := ih (arithmeticSpectrum μ) (arithmetic_positive μ hp)
        (arithmetic_monotone μ hm) (by simpa using hbits)
      have hg := arithmetic_gap_lower μ hp hm
      have hd : (0 : ℝ) < 3 ^ firstTrueDepth bs := by positivity
      have hdiv := div_le_div_of_nonneg_right (neg_le_neg hg) hd.le
      change prefixPrediction bs (arithmeticSpectrum μ) ≤
        -spectrumRelativeGap μ / 3 ^ (firstTrueDepth bs + 1)
      calc
        prefixPrediction bs (arithmeticSpectrum μ) ≤
            -spectrumRelativeGap (arithmeticSpectrum μ) / 3 ^ firstTrueDepth bs := hi
        _ ≤ -(spectrumRelativeGap μ / 3) / 3 ^ firstTrueDepth bs := hdiv
        _ = -spectrumRelativeGap μ / 3 ^ (firstTrueDepth bs + 1) := by
          rw [pow_succ]
          ring
    | true =>
      have hr : (μ 0 - μ 1) / (μ 0 + μ 1) ≤ 0 :=
        div_nonpos_of_nonpos_of_nonneg (sub_nonpos.mpr (hm (by omega)))
          (le_of_lt (add_pos (hp 0) (hp 1)))
      have hh := ordered_spectrum_prefix_nonpositive bs (harmonicSpectrum μ)
        (harmonic_positive μ hp) (harmonic_monotone μ hp hm)
      have hprod := mul_nonpos_of_nonneg_of_nonpos
        (show 0 ≤ 1 - (μ 0 - μ 1) / (μ 0 + μ 1) by linarith) hh
      simp only [prefixPrediction, firstTrueDepth, pow_zero, div_one]
      unfold spectrumRelativeGap
      have he : (μ 0 - μ 1) / (μ 0 + μ 1) = -((μ 1 - μ 0) / (μ 0 + μ 1)) := by ring
      linarith

/-- A nonempty binary prefix has a quantitative wrong-sign margin. This is
formula (Q1) of the kernel note, with the first relative spectral gap explicit. -/
theorem ordered_spectrum_prefix_quantitative (bits : List Bool) (μ : ℕ → ℝ)
    (hp : ∀ n, 0 < μ n) (hm : Monotone μ) (hbits : true ∈ bits) :
    prefixPrediction bits μ ≤
      -((μ 1 - μ 0) / (μ 0 + μ 1)) / 3 ^ (bits.length - 1) := by
  have hi := prefix_depth_margin bits μ hp hm hbits
  have hg : 0 ≤ spectrumRelativeGap μ := by
    unfold spectrumRelativeGap
    exact div_nonneg (sub_nonneg.mpr (hm (by omega))) (le_of_lt (add_pos (hp 0) (hp 1)))
  have hd := firstTrueDepth_le bits hbits
  have hpow : (3 : ℝ) ^ firstTrueDepth bits ≤ 3 ^ (bits.length - 1) :=
    pow_le_pow_right₀ (by norm_num) hd
  have hdiv := div_le_div_of_nonneg_left hg (show (0 : ℝ) < 3 ^ firstTrueDepth bits by positivity) hpow
  have hneg := neg_le_neg hdiv
  simp only [neg_div] at hi ⊢
  exact le_trans hi hneg

end
end IndependentResearch
