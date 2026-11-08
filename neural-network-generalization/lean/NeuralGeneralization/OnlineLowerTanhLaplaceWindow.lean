import NeuralGeneralization.OnlineLowerTanhAbsoluteDiagonal

/-! # Frequency-uniform exponentially weighted sine moments

Unlike a compact-frequency estimate, this bound applies to every real
incoming weight. It allows localization tails to be bounded directly by
Hölder under an exponential measure.
-/
noncomputable section
open MeasureTheory Set
namespace NeuralGeneralization.OnlineLowerTanh

theorem laplaceAbsSinePower_le_inv (p : ℕ) (c a : ℝ) (hc : 0 < c) :
    laplaceAbsSinePower p c a ≤ 1/c := by
  have h := integral_mono (integrable_laplace_absSinePower p c a hc)
    (integrableOn_exp_mul_Ioi (show -c<0 by linarith) 0)
    (fun t => mul_le_of_le_one_right (Real.exp_pos _).le
      (pow_le_one₀ (abs_nonneg _) (Real.abs_sin_le_one _)))
  have he := integral_exp_mul_Ioi (show -c<0 by linarith) 0
  simp only [mul_zero, Real.exp_zero, neg_div_neg_eq, one_div] at he
  simpa only [laplaceAbsSinePower, he, one_div] using h

theorem laplaceAbsSinePower_antitone (c a : ℝ) (hc : 0<c) :
    Antitone (fun p => laplaceAbsSinePower p c a) := by
  intro p q hpq
  apply integral_mono (integrable_laplace_absSinePower q c a hc)
    (integrable_laplace_absSinePower p c a hc)
  intro t
  exact mul_le_mul_of_nonneg_left
    (pow_le_pow_of_le_one (abs_nonneg _) (Real.abs_sin_le_one _) hpq) (Real.exp_pos _).le

@[simp] theorem laplaceAbsSinePower_abs (p : ℕ) (c a : ℝ) :
    laplaceAbsSinePower p c |a| = laplaceAbsSinePower p c a := by
  by_cases ha : 0≤a
  · rw [abs_of_nonneg ha]
  · simp [laplaceAbsSinePower, abs_of_neg (lt_of_not_ge ha), Real.sin_neg]

theorem laplace_abs_odd_first (k : ℕ) (c a : ℝ) (hc : 0<c) (ha : 0<a) :
    2*laplaceAbsSinePower (2*k+1) c a ≤ sinePowerMass (2*k+1)*laplaceAbsSinePower 1 c a := by
  induction k with
  | zero => simp
  | succ k ih =>
    have hp : Odd (2*k+1) := ⟨k, rfl⟩
    have hs := laplace_abs_step_le (2*k+1) hp c a hc ha
    have hi := mul_le_mul_of_nonneg_left ih
      (show 0 ≤ (((2*k+1:ℕ):ℝ)+1)/(((2*k+1:ℕ):ℝ)+2) by positivity)
    have hm := mul_le_mul_of_nonneg_left hs (show (0:ℝ)≤2 by norm_num)
    have he : 2*(k+1)+1=(2*k+1)+2 := by omega
    rw [he,sinePowerMass_recurrence (2*k+1)]
    nlinarith only [hm,hi]

theorem laplace_abs_odd_sqrt (k : ℕ) (c a : ℝ) (hc : 0<c) (ha : 0<a) :
    Real.sqrt (2*k+1:ℕ)*laplaceAbsSinePower (2*k+1) c a ≤ Real.pi/(2*c) := by
  have hfirst := laplace_abs_odd_first k c a hc ha
  have hbase := laplaceAbsSinePower_le_inv 1 c a hc
  have hnorm := sqrt_mul_sinePowerMass_le_pi (2*k+1)
  have hmul := mul_le_mul_of_nonneg_left hfirst (Real.sqrt_nonneg (2*k+1:ℕ))
  have hbase' := mul_le_mul_of_nonneg_left hbase
    (mul_nonneg (Real.sqrt_nonneg (2*k+1:ℕ)) (sinePowerMass_pos (2*k+1)).le)
  have hnorm' := mul_le_mul_of_nonneg_right hnorm (show 0≤1/c by positivity)
  apply (le_div_iff₀ (show 0<2*c by positivity)).mpr
  have hc' := mul_le_mul_of_nonneg_right (show
      2*(Real.sqrt (2*k+1:ℕ)*laplaceAbsSinePower (2*k+1) c a) ≤ Real.pi*(1/c) by
        nlinarith) hc.le
  have hcancel : (1/c)*c=1 := div_mul_cancel₀ 1 hc.ne'
  rw [mul_assoc Real.pi, hcancel, mul_one] at hc'
  nlinarith only [hc']

/-- Uniform in the frequency, in both parities of the natural exponent. -/
theorem laplace_abs_sqrt_bound (p : ℕ) (hp : 1≤p) (c a : ℝ) (hc : 0<c) :
    Real.sqrt (p:ℝ)*laplaceAbsSinePower p c a ≤ Real.pi/c := by
  suffices h : ∀a:ℝ,0≤a→Real.sqrt (p:ℝ)*laplaceAbsSinePower p c a≤Real.pi/c by
    simpa using h |a| (abs_nonneg a)
  intro a ha
  rcases ha.eq_or_lt with he | ha
  · subst a
    simp [laplaceAbsSinePower, zero_pow (by omega : p≠0)]
    positivity
  rcases Nat.even_or_odd' p with ⟨k,hk|hk⟩
  · have hkpos : 1≤k := by omega
    let j := k-1
    have hpform : p=(2*j+1)+1 := by dsimp [j]; omega
    have hprev := laplace_abs_odd_sqrt j c a hc ha
    have hm := laplaceAbsSinePower_antitone c a hc (show 2*j+1≤p by omega)
    have hroot : Real.sqrt (p:ℝ) ≤ 2*Real.sqrt (2*j+1:ℕ) := by
      have h1 := Real.sq_sqrt (show (0:ℝ)≤p by positivity)
      have h2 := Real.sq_sqrt (show (0:ℝ)≤(2*j+1:ℕ) by positivity)
      have hpn : (p:ℝ)≤4*(2*j+1:ℕ) := by exact_mod_cast (show p≤4*(2*j+1) by omega)
      have hpos := Real.sqrt_nonneg (2*j+1:ℕ)
      nlinarith [Real.sqrt_nonneg (p:ℝ)]
    have h := mul_le_mul hroot hm (laplaceAbsSinePower_nonneg p c a) (by positivity)
    calc
      _ ≤ 2*(Real.sqrt (2*j+1:ℕ)*laplaceAbsSinePower (2*j+1) c a) := by nlinarith [h]
      _ ≤ 2*(Real.pi/(2*c)) := mul_le_mul_of_nonneg_left hprev (by norm_num)
      _ = Real.pi/c := by field_simp
  · rw [hk]
    exact (laplace_abs_odd_sqrt k c a hc ha).trans (by
      have hp := Real.pi_pos
      apply (div_le_div_iff₀ (by positivity) hc).mpr
      nlinarith)

end NeuralGeneralization.OnlineLowerTanh
