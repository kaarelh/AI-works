import NeuralGeneralization.GaussianPairMoments
import Mathlib.Tactic.FinCases
import Mathlib.Analysis.SpecificLimits.Basic

/-!
# Saturating Gaussian moment limits in varying ambient dimension

Only the three scalar Gram entries need converge. The number of underlying
independent Gaussian coordinates may grow arbitrarily with width. The proof
uses the exact two-coordinate reduction and the actual Gaussian sign formula.
-/

noncomputable section
open Filter MeasureTheory ProbabilityTheory
open scoped Topology BigOperators NNReal

namespace NeuralGeneralization.GaussianMomentLimits
open GaussianPairMoments GaussianTanhSaturation

theorem tendsto_tanhCovariance_of_gram
    {I : ℕ → Type*} [∀ n, Fintype (I n)]
    {c d : (n : ℕ) → I n → ℝ} {s : ℕ → ℝ} {A B C : ℝ}
    (hs : Tendsto s atTop atTop)
    (hA : Tendsto (fun n => ∑ i, c n i ^ 2) atTop (𝓝 A))
    (hB : Tendsto (fun n => ∑ i, d n i ^ 2) atTop (𝓝 B))
    (hC : Tendsto (fun n => ∑ i, c n i * d n i) atTop (𝓝 C))
    (hApos : 0 < A) (hBpos : 0 < B) :
    Tendsto (fun n => tanhCovariance 1 (s n) (c n) (d n)) atTop
      (𝓝 ((2 / Real.pi) * Real.arcsin (C / (Real.sqrt A * Real.sqrt B)))) := by
  let a : ℕ → ℝ := fun n => ∑ i, c n i ^ 2
  let b : ℕ → ℝ := fun n => ∑ i, d n i ^ 2
  let e : ℕ → ℝ := fun n => ∑ i, c n i * d n i
  have hpsd : C ^ 2 ≤ A * B := by
    apply le_of_tendsto_of_tendsto (hC.pow 2) (hA.mul hB)
    exact Eventually.of_forall (fun n => Finset.sum_mul_sq_le_sq_mul_sq Finset.univ (c n) (d n))
  have hleft : ∀ i : Fin 2, Tendsto (fun n => leftCoefficients (a n) i) atTop
      (𝓝 (leftCoefficients A i)) := by
    intro i
    fin_cases i
    · simp [leftCoefficients]
    · simpa [leftCoefficients, a, Function.comp_def] using (Real.continuous_sqrt.tendsto A).comp hA
  have hright : ∀ i : Fin 2, Tendsto (fun n => rightCoefficients (a n) (b n) (e n) i) atTop
      (𝓝 (rightCoefficients A B C i)) := by
    intro i
    fin_cases i
    · simpa [rightCoefficients, a, b, e, Function.comp_def, Pi.div_def] using
        ((Real.continuous_sqrt.tendsto (B - C ^ 2 / A)).comp
          (hB.sub ((hC.pow 2).div hA hApos.ne'))).neg
    · simpa [rightCoefficients, a, b, e, Function.comp_def, Pi.div_def] using
        hC.div ((Real.continuous_sqrt.tendsto A).comp hA) (Real.sqrt_pos.mpr hApos).ne'
  have hlim := GaussianTanhSaturation.tendsto_covariance 1 hs hleft hright
    (by simpa only [NNReal.coe_one, one_mul, leftCoefficients_energy hApos.le] using hApos)
    (by simpa only [NNReal.coe_one, one_mul, rightCoefficients_energy hApos hpsd] using hBpos)
  have hsign : signCovariance 1 (leftCoefficients A) (rightCoefficients A B C) =
      (2 / Real.pi) * Real.arcsin (C / (Real.sqrt A * Real.sqrt B)) := by
    rw [GaussianSignKernel.signCovariance_arcsin
      _ _ (by simpa only [leftCoefficients_energy hApos.le] using hApos)
      (by simpa only [rightCoefficients_energy hApos hpsd] using hBpos),
      leftCoefficients_energy hApos.le, rightCoefficients_energy hApos hpsd,
      coefficient_pairing hApos]
  rw [hsign] at hlim
  apply hlim.congr'
  filter_upwards [hA.eventually (Ioi_mem_nhds hApos)] with n hn
  symm
  exact pairMoment_canonical
    (ConcreteModel.tanh_lipschitzWith.continuous.measurable.comp (measurable_const.mul measurable_id))
    (c n) (d n) 1 hn

/-- Uniformity over every width and every feature pair in a sufficiently
small Gram neighborhood. The proof is sequential and uses the exact varying-
dimension limit above, so no unproved matrix square-root modulus is needed. -/
theorem uniform_tanhCovariance_gram_neighborhood {A B C ε : ℝ}
    (hApos : 0 < A) (hBpos : 0 < B) (hε : 0 < ε) :
    ∃ δ : ℝ, 0 < δ ∧ ∃ T : ℝ,
      ∀ N : ℕ, ∀ c d : Fin N → ℝ, ∀ s : ℝ, T ≤ s →
        |(∑ i, c i ^ 2) - A| < δ →
        |(∑ i, d i ^ 2) - B| < δ →
        |(∑ i, c i * d i) - C| < δ →
        |tanhCovariance 1 s c d -
          (2 / Real.pi) * Real.arcsin (C / (Real.sqrt A * Real.sqrt B))| < ε := by
  classical
  by_contra hnot
  push Not at hnot
  choose N c d s hs ha hb hc herr using
    fun n : ℕ => hnot (1 / ((n : ℝ) + 1)) (by positivity) (n : ℝ)
  have hnear {u : ℕ → ℝ} {x : ℝ}
      (hu : ∀ n, |u n - x| < 1 / ((n : ℝ) + 1)) : Tendsto u atTop (𝓝 x) := by
    have hz : Tendsto (fun n => |u n - x|) atTop (𝓝 (0 : ℝ)) :=
      squeeze_zero (fun n => abs_nonneg _) (fun n => (hu n).le)
        tendsto_one_div_add_atTop_nhds_zero_nat
    exact tendsto_iff_dist_tendsto_zero.mpr (by simpa only [Real.dist_eq] using hz)
  have hsTop : Tendsto s atTop atTop :=
    tendsto_atTop_mono hs tendsto_natCast_atTop_atTop
  have hlim := tendsto_tanhCovariance_of_gram (I := fun n => Fin (N n))
    hsTop (hnear ha) (hnear hb) (hnear hc) hApos hBpos
  have hz : Tendsto (fun n => |tanhCovariance 1 (s n) (c n) (d n) -
      (2 / Real.pi) * Real.arcsin (C / (Real.sqrt A * Real.sqrt B))|)
      atTop (𝓝 (0 : ℝ)) := by
    simpa only [sub_self, abs_zero] using (hlim.sub_const ((2 / Real.pi) * Real.arcsin (C / (Real.sqrt A * Real.sqrt B)))).abs
  obtain ⟨n, hn⟩ := (hz.eventually (Iio_mem_nhds hε)).exists
  exact (not_lt_of_ge (herr n)) hn

end NeuralGeneralization.GaussianMomentLimits
