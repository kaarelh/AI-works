import NeuralGeneralization.GaussianMarginGeometry

/-! Uniform small-variance rates for actual finite Gaussian linear-margin
probabilities. The event's linear map is allowed to vary with the variance. -/
noncomputable section
open Filter MeasureTheory ProbabilityTheory
open scoped BigOperators Topology NNReal
namespace NeuralGeneralization.UniformGaussianMarginRate
open GaussianRate GaussianMarginGeometry
variable {I J : Type*} [Fintype I] [Fintype J]

theorem uniform_lower (P : J → I → ℝ) (a : ℝ)
    (hne : (linearMargin P a).Nonempty) {ε : ℝ} (hε : 0 < ε) :
    ∃ δ : ℝ, 0 < δ ∧ ∃ c : ℝ, 0 < c ∧
      ∀ Q : J → I → ℝ, dist Q P < δ → ∀ t : ℝ, 0 < t → t ≤ 1 →
      c * Real.exp (-(squareInf (linearMargin P a) / 2 + ε) * (1 / t)) ≤
        isotropicMass (linearMargin Q a) t := by
  obtain ⟨δ, hδ, z, r, hr, hrect, henergy⟩ := uniform_margin_rectangle P a hne
    (show 0 < 2 * ε by positivity)
  let c : ℝ := ((2 * r) * (Real.sqrt (2 * Real.pi))⁻¹) ^ Fintype.card I
  have hc : 0 < c := by dsimp [c]; positivity
  refine ⟨δ, hδ, c, hc, fun Q hQ t ht ht1 => ?_⟩
  have hexp : -(squareInf (linearMargin P a) / 2 + ε) * (1 / t) ≤
      -(∑ i, (|z i| + r) ^ 2) / (2 * t) := by
    have he : -(squareInf (linearMargin P a) / 2 + ε) ≤ -(∑ i, (|z i| + r) ^ 2) / 2 := by
      linarith
    have he' := div_le_div_of_nonneg_right he ht.le
    convert he' using 1 <;> first | rfl | ring
  calc
    _ ≤ c * Real.exp (-(∑ i, (|z i| + r) ^ 2) / (2 * t)) :=
      mul_le_mul_of_nonneg_left (Real.exp_le_exp.mpr hexp) hc.le
    _ ≤ isotropicMass (Set.pi Set.univ fun i => Set.Icc (z i - r) (z i + r)) t :=
      rectangle_mass_lower_fixed_prefactor z r hr t ht ht1
    _ ≤ isotropicMass (linearMargin Q a) t := measureReal_mono (hrect Q hQ)

theorem uniform_upper (P : J → I → ℝ) {a : ℝ} (ha : 0 < a)
    {ε : ℝ} (hε : 0 < ε) :
    ∃ δ : ℝ, 0 < δ ∧ ∃ C : ℝ, 0 < C ∧
      ∀ Q : J → I → ℝ, dist Q P < δ → ∀ t : ℝ, 0 < t →
      isotropicMass (linearMargin Q a) t ≤
        C * Real.exp (-(squareInf (linearMargin P a) / 2 - ε) * (1 / t)) := by
  let b : ℝ := squareInf (linearMargin P a) - ε
  obtain ⟨δ, hδ, henergy⟩ := uniform_margin_energy_lower P ha
    (show b < squareInf (linearMargin P a) by dsimp [b]; linarith)
  let θ : ℝ := min 1 (ε / (|b| + 1))
  have hθ0 : 0 < θ := lt_min zero_lt_one (div_pos hε (by positivity))
  have hθ1 : θ ≤ 1 := min_le_left _ _
  have hθb : θ * b ≤ ε := by
    have hh : θ * (|b| + 1) ≤ ε :=
      (le_div_iff₀ (by positivity : 0 < |b| + 1)).mp (min_le_right _ _)
    have hab := le_abs_self b
    nlinarith
  let C : ℝ := (Real.sqrt θ)⁻¹ ^ Fintype.card I
  have hC : 0 < C := by dsimp [C]; positivity
  refine ⟨δ, hδ, C, hC, fun Q hQ t ht => ?_⟩
  have htv : (t.toNNReal : ℝ) = t := Real.coe_toNNReal t ht.le
  have htail := GaussianTail.gaussian_squaredNorm_rate_upper (ι := I)
    t.toNNReal (by rwa [htv]) b θ hθ0 hθ1
  simp only [htv] at htail
  have hexp : -((1 - θ) * b) / (2 * t) ≤
      -(squareInf (linearMargin P a) / 2 - ε) * (1 / t) := by
    have he : -((1 - θ) * b) / 2 ≤ -(squareInf (linearMargin P a) / 2 - ε) := by
      dsimp [b] at hθb ⊢
      nlinarith
    have he' := div_le_div_of_nonneg_right he ht.le
    convert he' using 1 <;> first | rfl | ring
  calc
    _ ≤ isotropicMass {z : I → ℝ | b ≤ ∑ i, z i ^ 2} t :=
      measureReal_mono (henergy Q hQ)
    _ ≤ Real.exp (-((1 - θ) * b) / (2 * t)) * C := htail
    _ ≤ Real.exp (-(squareInf (linearMargin P a) / 2 - ε) * (1 / t)) * C :=
      mul_le_mul_of_nonneg_right (Real.exp_le_exp.mpr hexp) hC.le
    _ = _ := mul_comm _ _

/-- The actual Gaussian margin mass has the limiting quadratic rate even
when its linear map varies along an arbitrary convergent family. -/
theorem varying_linear_margin_rate {T : Type*} {l : Filter T}
    {P : J → I → ℝ} {Q : T → J → I → ℝ} {t : T → ℝ} {a : ℝ}
    (ha : 0 < a) (hne : (linearMargin P a).Nonempty)
    (hQ : Tendsto Q l (𝓝 P)) (ht : Tendsto t l (𝓝[>] (0 : ℝ))) :
    HasExponentialRate l (fun n => 1 / t n)
      (fun n => isotropicMass (linearMargin (Q n) a) (t n))
      (squareInf (linearMargin P a) / 2) := by
  have hs : Tendsto (fun n => 1 / t n) l atTop := by
    simpa only [one_div, Function.comp_def] using tendsto_inv_nhdsGT_zero.comp ht
  have htpos : ∀ᶠ n in l, 0 < t n := ht.eventually self_mem_nhdsWithin
  have ht1 : ∀ᶠ n in l, t n ≤ 1 := by
    exact ((ht.mono_right nhdsWithin_le_nhds).eventually_lt_const zero_lt_one).mono fun _ h => h.le
  apply hasExponentialRate_of_prefactors _ _ _ hs
  · intro ε hε
    obtain ⟨δ, hδ, c, hc, hlo⟩ := uniform_lower P a hne hε
    refine ⟨c, hc, ?_⟩
    filter_upwards [hQ.eventually (Metric.ball_mem_nhds P hδ), htpos, ht1] with n hn htn ht1n
    exact hlo (Q n) hn (t n) htn ht1n
  · intro ε hε
    obtain ⟨δ, hδ, C, hC, hhi⟩ := uniform_upper P ha hε
    refine ⟨C, hC, ?_⟩
    filter_upwards [hQ.eventually (Metric.ball_mem_nhds P hδ), htpos] with n hn htn
    exact hhi (Q n) hn (t n) htn

end NeuralGeneralization.UniformGaussianMarginRate
