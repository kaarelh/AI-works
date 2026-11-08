import NeuralGeneralization.OnlineLowerTanhAbsoluteDiagonal
import NeuralGeneralization.OnlineLowerTanhSine

/-! # The positive csch mixture and the uniform diagonal comparison -/
noncomputable section
open scoped BigOperators Topology
open MeasureTheory Set Filter
namespace NeuralGeneralization.OnlineLowerTanh

def absoluteSinePartial (p : ℕ) (a : ℝ) (N : ℕ) (t : ℝ) : ℝ :=
  ∑ n ∈ Finset.range N, sineKernelTerm t n * |Real.sin (a*t)|^p

theorem absoluteSinePartial_nonneg (p : ℕ) (a : ℝ) (N : ℕ) (t : ℝ) :
    0 ≤ absoluteSinePartial p a N t := by
  unfold absoluteSinePartial sineKernelTerm
  positivity

theorem absoluteSinePartial_le (p : ℕ) (a : ℝ) (N : ℕ) (t : ℝ) (ht : 0 < t) :
    absoluteSinePartial p a N t ≤ absoluteSineKernel p a t := by
  have hs := sineKernelTerm_hasSum t ht
  have hnon (n : ℕ) : 0 ≤ sineKernelTerm t n := by unfold sineKernelTerm; positivity
  have hsum := hs.summable.sum_le_tsum (Finset.range N) (fun n _ => hnon n)
  rw [hs.tsum_eq] at hsum
  unfold absoluteSinePartial absoluteSineKernel
  rw [← Finset.sum_mul]
  have h := mul_le_mul_of_nonneg_right hsum (pow_nonneg (abs_nonneg (Real.sin (a*t))) p)
  simpa only [one_div,div_eq_mul_inv,mul_comm,one_mul] using h

theorem absoluteSinePartial_tendsto (p : ℕ) (a t : ℝ) (ht : 0 < t) :
    Tendsto (fun N => absoluteSinePartial p a N t) atTop (𝓝 (absoluteSineKernel p a t)) := by
  have h := ((sineKernelTerm_hasSum t ht).mul_right (|Real.sin (a*t)|^p)).tendsto_sum_nat
  simpa only [absoluteSinePartial,absoluteSineKernel,one_div,mul_comm,div_eq_mul_inv,one_mul] using h

/-- Literal absolute moments are sums of positive Laplace integrals. -/
theorem absoluteSineMoment_hasSum (p : ℕ) (hp : 1 ≤ p) (a : ℝ) :
    HasSum (fun n => 2*laplaceAbsSinePower p (sineDecay n) a) (absoluteSineMoment p a) := by
  have hd := tendsto_integral_of_dominated_convergence (absoluteSineKernel p a)
    (fun N => (show Continuous (absoluteSinePartial p a N) by
      unfold absoluteSinePartial sineKernelTerm; fun_prop).aestronglyMeasurable)
    (absoluteSineKernel_integrable p hp a)
    (fun N => by
      filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
      simpa only [Real.norm_eq_abs,abs_of_nonneg (absoluteSinePartial_nonneg p a N t)] using
        absoluteSinePartial_le p a N t ht)
    (by
      filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
      exact absoluteSinePartial_tendsto p a t ht)
  have hfin (N : ℕ) : (∫ t : ℝ in Ioi 0, absoluteSinePartial p a N t) =
      ∑ n ∈ Finset.range N, 2*laplaceAbsSinePower p (sineDecay n) a := by
    unfold absoluteSinePartial
    rw [integral_finset_sum]
    · apply Finset.sum_congr rfl
      intro n _
      unfold sineKernelTerm laplaceAbsSinePower
      simp_rw [mul_assoc]
      rw [integral_const_mul]
    · intro n _
      simpa only [sineKernelTerm,mul_assoc] using
        (integrable_laplace_absSinePower p (sineDecay n) a (sineDecay_pos n)).const_mul 2
  simp_rw [hfin] at hd
  exact (hasSum_iff_tendsto_nat_of_nonneg (fun n =>
    mul_nonneg (by norm_num) (laplaceAbsSinePower_nonneg p (sineDecay n) a)) _).mpr hd

/-- The inverse-lattice proof's diagonal comparison, with no unproved
integral or Holder hypotheses. -/
theorem absoluteSineMoment_odd_diagonal (k : ℕ) (a : ℝ) (ha : 0 < a) :
    absoluteSineMoment (2*k+3) a * sinePowerMass 3 ≤
      sinePowerMass (2*k+3) * absoluteSineMoment 3 a := by
  have hleft := (absoluteSineMoment_hasSum (2*k+3) (by omega) a).mul_right (sinePowerMass 3)
  have hright := (absoluteSineMoment_hasSum 3 (by norm_num) a).mul_left (sinePowerMass (2*k+3))
  have hpoint (n : ℕ) :
      (2*laplaceAbsSinePower (2*k+3) (sineDecay n) a)*sinePowerMass 3 ≤
        sinePowerMass (2*k+3)*(2*laplaceAbsSinePower 3 (sineDecay n) a) := by
    have h := laplace_abs_odd_diagonal k (sineDecay n) a (sineDecay_pos n) ha
    linarith
  exact le_of_tendsto_of_tendsto' hleft.tendsto_sum_nat hright.tendsto_sum_nat
    (fun N => Finset.sum_le_sum (fun n _ => hpoint n))


/-- Square-root normalization for every odd exponent at least three. -/
theorem absoluteSineMoment_odd_sqrt_bound (k : ℕ) (a : ℝ) (ha : 0 < a) :
    Real.sqrt (2*k+3:ℕ) * absoluteSineMoment (2*k+3) a * sinePowerMass 3 ≤
      Real.pi * absoluteSineMoment 3 a := by
  have hd := mul_le_mul_of_nonneg_left (absoluteSineMoment_odd_diagonal k a ha)
    (Real.sqrt_nonneg (2*k+3:ℕ))
  have hs := mul_le_mul_of_nonneg_right (sqrt_mul_sinePowerMass_le_pi (2*k+3))
    (absoluteSineMoment_nonneg 3 a)
  calc
    _ ≤ (Real.sqrt (2*k+3:ℕ) * sinePowerMass (2*k+3)) * absoluteSineMoment 3 a := by
      simpa only [mul_assoc] using hd
    _ ≤ _ := hs

/-- The absolute diagonal estimate is uniform in degree, with no parity
restriction. Even exponents are bounded by the preceding odd exponent. -/
theorem absoluteSineMoment_sqrt_bound (p : ℕ) (hp : 3 ≤ p) (a : ℝ) (ha : 0 < a) :
    Real.sqrt (p:ℝ) * absoluteSineMoment p a * sinePowerMass 3 ≤
      2*Real.pi * absoluteSineMoment 3 a := by
  obtain ⟨k,hk|hk⟩ := Nat.even_or_odd' (p-3)
  · have he : p = 2*k+3 := by omega
    rw [he]
    have hh := absoluteSineMoment_odd_sqrt_bound k a ha
    have hn := mul_nonneg Real.pi_pos.le (absoluteSineMoment_nonneg 3 a)
    nlinarith
  · have he : p = 2*k+4 := by omega
    rw [he]
    have hm := absoluteSineMoment_antitone a (p:=2*k+3) (q:=2*k+4) (by omega) (by omega)
    have hr : Real.sqrt (2*k+4:ℕ) ≤ 2*Real.sqrt (2*k+3:ℕ) := by
      have h₁ := Real.sq_sqrt (Nat.cast_nonneg (α:=ℝ) (2*k+4))
      have h₂ := Real.sq_sqrt (Nat.cast_nonneg (α:=ℝ) (2*k+3))
      have hn₁ := Real.sqrt_nonneg (2*k+4:ℕ)
      have hn₂ := Real.sqrt_nonneg (2*k+3:ℕ)
      push_cast at h₁ h₂ hn₁ hn₂ ⊢
      nlinarith [Nat.cast_nonneg (α:=ℝ) k]
    calc
      _ ≤ (2*Real.sqrt (2*k+3:ℕ)) * absoluteSineMoment (2*k+3) a * sinePowerMass 3 := by
        gcongr
        · exact (sinePowerMass_pos _).le
        · exact absoluteSineMoment_nonneg _ _
      _ ≤ _ := by
        have h := absoluteSineMoment_odd_sqrt_bound k a ha
        nlinarith

end NeuralGeneralization.OnlineLowerTanh
