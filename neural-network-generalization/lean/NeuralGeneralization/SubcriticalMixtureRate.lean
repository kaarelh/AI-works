import NeuralGeneralization.UniformGaussianMarginRate
import NeuralGeneralization.ProductEventBound
import Mathlib.Analysis.SpecialFunctions.Pow.Asymptotics

/-! Exponential-width exceptional events are negligible at every subcritical
positive speed, and uniform section estimates give the actual mixture rate. -/
noncomputable section
open Filter MeasureTheory ProbabilityTheory
open scoped BigOperators Topology NNReal
namespace NeuralGeneralization.SubcriticalMixtureRate
open GaussianRate

/-- Every fixed exponential-in-width bound is smaller than any prescribed
exponential at speed `N^gamma`, for `0 < gamma < 1`. -/
theorem exponential_width_tail_absorbed {γ : ℝ} (hγ0 : 0 < γ) (hγ1 : γ < 1)
    (A C : ℝ) {c : ℝ} (hc : 0 < c) :
    ∀ᶠ N : ℕ in atTop, C * Real.exp (-c * N) ≤ Real.exp (-A * (N : ℝ) ^ γ) := by
  have hs : Tendsto (fun N : ℕ => (N : ℝ) ^ γ) atTop atTop :=
    (tendsto_rpow_atTop hγ0).comp tendsto_natCast_atTop_atTop
  have hr : Tendsto (fun N : ℕ => (N : ℝ) ^ (1 - γ)) atTop atTop :=
    (tendsto_rpow_atTop (by linarith : 0 < 1 - γ)).comp tendsto_natCast_atTop_atTop
  filter_upwards [hr.eventually_ge_atTop ((A + 1) / c),
    (Real.tendsto_exp_atTop.comp hs).eventually_ge_atTop C,
    eventually_gt_atTop (0 : ℕ)] with N hn hC hN
  have hNp : (0 : ℝ) < N := by exact_mod_cast hN
  have hpow : (N : ℝ) ^ (1 - γ) * (N : ℝ) ^ γ = N := by
    rw [← Real.rpow_add hNp]
    norm_num
  have hex : (A + 1) * (N : ℝ) ^ γ ≤ c * N := by
    have hh : A + 1 ≤ c * (N : ℝ) ^ (1 - γ) := by
      exact (div_le_iff₀ hc).mp hn |>.trans_eq (mul_comm _ _)
    have hm := mul_le_mul_of_nonneg_right hh (Real.rpow_nonneg hNp.le γ)
    simpa only [mul_assoc, hpow] using hm
  calc
    C * Real.exp (-c * N) ≤ Real.exp ((N : ℝ) ^ γ) * Real.exp (-c * N) :=
      mul_le_mul_of_nonneg_right hC (Real.exp_pos _).le
    _ ≤ Real.exp ((N : ℝ) ^ γ) * Real.exp (-(A + 1) * (N : ℝ) ^ γ) := by
      apply mul_le_mul_of_nonneg_left _ (Real.exp_pos _).le
      apply Real.exp_le_exp.mpr
      nlinarith
    _ = Real.exp (-A * (N : ℝ) ^ γ) := by
      rw [← Real.exp_add]
      congr 1
      ring

/-- A varying numeric quantity with an eventual exponential-width bound
converges to zero. -/
theorem tendsto_zero_of_exponential_width_bound {f : ℕ → ℝ}
    (h0 : ∀ N, 0 ≤ f N) {C c : ℝ} (hc : 0 < c)
    (hbound : ∀ᶠ N : ℕ in atTop, f N ≤ C * Real.exp (-c * N)) :
    Tendsto f atTop (𝓝 (0 : ℝ)) := by
  have hlim : Tendsto (fun N : ℕ => C * Real.exp (-c * N)) atTop (𝓝 (0 : ℝ)) := by
    have h := (Real.tendsto_exp_neg_atTop_nhds_zero.comp
      (tendsto_natCast_atTop_atTop.const_mul_atTop hc)).const_mul C
    simpa only [Function.comp_def, neg_mul, mul_zero] using h
  exact squeeze_zero' (Eventually.of_forall h0) hbound hlim

/-- Uniform conditional Gaussian bounds survive integration over hidden
weights when their exceptional covariance event has exponential-width mass.
All measures and all events here are the actual finite-width product laws. -/
theorem product_mixture_hasExponentialRate
    {α β : ℕ → Type*} [∀ N, MeasurableSpace (α N)] [∀ N, MeasurableSpace (β N)]
    (μ : (N : ℕ) → Measure (α N)) (ν : (N : ℕ) → Measure (β N))
    [∀ N, IsProbabilityMeasure (μ N)] [∀ N, IsProbabilityMeasure (ν N)]
    (V : (N : ℕ) → Set (α N × β N)) (hV : ∀ N, MeasurableSet (V N))
    (A : (N : ℕ) → ℝ → Set (α N)) (hA : ∀ N δ, MeasurableSet (A N δ))
    {γ E : ℝ} (hγ0 : 0 < γ) (hγ1 : γ < 1)
    (hfreeze : ∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 < C ∧ ∃ c : ℝ, 0 < c ∧
      ∀ᶠ N : ℕ in atTop, (μ N).real (A N δ) ≤ C * Real.exp (-c * N))
    (hlower : ∀ ε : ℝ, 0 < ε → ∃ δ : ℝ, 0 < δ ∧ ∃ c : ℝ, 0 < c ∧
      ∀ᶠ N : ℕ in atTop, ∀ x ∉ A N δ,
        c * Real.exp (-(E + ε) * (N : ℝ) ^ γ) ≤ (ν N).real {y | (x,y) ∈ V N})
    (hupper : ∀ ε : ℝ, 0 < ε → ∃ δ : ℝ, 0 < δ ∧ ∃ C : ℝ, 0 < C ∧
      ∀ᶠ N : ℕ in atTop, ∀ x ∉ A N δ,
        (ν N).real {y | (x,y) ∈ V N} ≤ C * Real.exp (-(E - ε) * (N : ℝ) ^ γ)) :
    HasExponentialRate atTop (fun N : ℕ => (N : ℝ) ^ γ)
      (fun N => ((μ N).prod (ν N)).real (V N)) E := by
  have hs : Tendsto (fun N : ℕ => (N : ℝ) ^ γ) atTop atTop :=
    (tendsto_rpow_atTop hγ0).comp tendsto_natCast_atTop_atTop
  apply hasExponentialRate_of_prefactors _ _ _ hs
  · intro ε hε
    obtain ⟨δ, hδ, c, hc, hlo⟩ := hlower ε hε
    obtain ⟨C₀, _, c₀, hc₀, hbad⟩ := hfreeze δ hδ
    have hzero := tendsto_zero_of_exponential_width_bound
      (fun N => show 0 ≤ (μ N).real (A N δ) from measureReal_nonneg) hc₀ hbad
    refine ⟨c / 2, by positivity, ?_⟩
    filter_upwards [hlo, hzero.eventually_lt_const (by norm_num : (0 : ℝ) < 1 / 2)] with N hn hhalf
    have hm := product_event_mass_ge (μ N) (ν N) (A N δ) (hA N δ) (V N) (hV N)
      (c * Real.exp (-(E + ε) * (N : ℝ) ^ γ)) (by positivity) hn
    calc
      (c / 2) * Real.exp (-(E + ε) * (N : ℝ) ^ γ) ≤
          (c * Real.exp (-(E + ε) * (N : ℝ) ^ γ)) * (1 - (μ N).real (A N δ)) := by
        calc
          _ = (c * Real.exp (-(E + ε) * (N : ℝ) ^ γ)) * (1 / 2) := by ring
          _ ≤ _ := mul_le_mul_of_nonneg_left (by linarith)
            (mul_nonneg hc.le (Real.exp_pos _).le)
      _ ≤ _ := hm
  · intro ε hε
    obtain ⟨δ, hδ, C, hC, hhi⟩ := hupper ε hε
    obtain ⟨C₀, _, c₀, hc₀, hbad⟩ := hfreeze δ hδ
    refine ⟨1 + C, by positivity, ?_⟩
    filter_upwards [hhi, hbad, exponential_width_tail_absorbed hγ0 hγ1 (E - ε) C₀ hc₀]
      with N hn hb htail
    have hm := product_event_mass_le (μ N) (ν N) (A N δ) (hA N δ) (V N) (hV N)
      (C * Real.exp (-(E - ε) * (N : ℝ) ^ γ)) (by positivity) hn
    calc
      _ ≤ (μ N).real (A N δ) + C * Real.exp (-(E - ε) * (N : ℝ) ^ γ) := hm
      _ ≤ C₀ * Real.exp (-c₀ * N) + C * Real.exp (-(E - ε) * (N : ℝ) ^ γ) :=
        add_le_add hb le_rfl
      _ ≤ Real.exp (-(E - ε) * (N : ℝ) ^ γ) + C * Real.exp (-(E - ε) * (N : ℝ) ^ γ) :=
        add_le_add htail le_rfl
      _ = _ := by ring

end NeuralGeneralization.SubcriticalMixtureRate
