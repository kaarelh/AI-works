import NeuralGeneralization.BatchTwoShallowSharpMain

/-! Exact identities with the manuscript's two-stage conditioning and scales. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory Set
namespace NeuralGeneralization.BatchTwoShallow
open ConcreteModel

theorem posterior_eq_twoStage {d N n : ℕ} {c : ℝ} (hc : 0 < c) (σ : ℝ)
    (robust global : Bool) (f : BooleanFunction d) (sample : Fin n → Cube d) :
    posterior (N := N) σ c robust global f sample =
      cond (cond (smallPrior d N 0 σ) (priorSupport d N c robust global)) (trainingEvent f sample) := by
  exact (cond_cond_eq_cond_inter (measurable_priorSupport d N hc robust global)
    (measurable_trainingEvent f sample) (smallPrior d N 0 σ)).symm

theorem width_mul_tScale_sq_le_one {N : ℕ} (hN : 0 < N) {t : ℝ}
    (ht : 0 < t) (ht1 : t ≤ 1) : (N : ℝ)*(t/Real.sqrt N)^2 ≤ 1 := by
  have hN0 : (N : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hN.ne'
  rw [div_pow, Real.sq_sqrt (Nat.cast_nonneg N), mul_div_cancel₀ _ hN0]
  nlinarith

/-- This identity includes the initial prior restriction followed by likelihood
conditioning; the learned measure is not replaced by a uniform version space. -/
theorem power_posterior_identity {d N n : ℕ} (hN : 0 < N) {c : ℝ}
    (hc : 0 < c) (γ : ℝ) (robust global : Bool)
    (f : BooleanFunction d) (sample : Fin n → Cube d) :
    cond (cond (powerPrior d N 0 γ) (priorSupport d N c robust global)) (trainingEvent f sample) =
      posterior (powerStandardDeviation N γ) c robust global f sample := by
  rw [powerPrior_eq_smallPrior_standardDeviation hN γ, posterior_eq_twoStage hc]

theorem good_event_all_power_priors {d C n : ℕ} (hC : 0 < C)
    {c ε : ℝ} (hc : 0 < c) (robust global : Bool) (D : Measure (Cube d))
    (f : BooleanFunction d) (sample : Fin n → Cube d)
    (hgood : ∀ N : ℕ, C ≤ N → ∀ σ : ℝ, 0 < σ → (N : ℝ)*σ^2 ≤ 1 →
      RobustConfidence.gibbsMarginRisk D (posterior (N := N) σ c robust global f sample)
        (fun x => labelReal (f x)) (networkOutput Real.tanh) (1/4) ≤ ε) :
    ∀ N : ℕ, C ≤ N → ∀ γ : ℝ, 1 ≤ γ →
      RobustConfidence.gibbsMarginRisk D
        (cond (cond (powerPrior d N 0 γ) (priorSupport d N c robust global)) (trainingEvent f sample))
        (fun x => labelReal (f x)) (networkOutput Real.tanh) (1/4) ≤ ε := by
  intro N hCN γ hγ
  have hN : 0 < N := hC.trans_le hCN
  rw [power_posterior_identity hN hc]
  exact hgood N hCN _ (powerStandardDeviation_pos hN γ)
    (width_mul_powerStandardDeviation_sq_le_one hN hγ)

theorem good_event_all_t_scales {d C n : ℕ} (hC : 0 < C)
    {c ε : ℝ} (hc : 0 < c) (robust global : Bool) (D : Measure (Cube d))
    (f : BooleanFunction d) (sample : Fin n → Cube d)
    (hgood : ∀ N : ℕ, C ≤ N → ∀ σ : ℝ, 0 < σ → (N : ℝ)*σ^2 ≤ 1 →
      RobustConfidence.gibbsMarginRisk D (posterior (N := N) σ c robust global f sample)
        (fun x => labelReal (f x)) (networkOutput Real.tanh) (1/4) ≤ ε) :
    ∀ N : ℕ, C ≤ N → ∀ t : ℝ, 0 < t → t ≤ 1 →
      RobustConfidence.gibbsMarginRisk D
        (cond (cond (smallPrior d N 0 (t/Real.sqrt N)) (priorSupport d N c robust global))
          (trainingEvent f sample))
        (fun x => labelReal (f x)) (networkOutput Real.tanh) (1/4) ≤ ε := by
  intro N hCN t ht ht1
  have hN : 0 < N := hC.trans_le hCN
  rw [← posterior_eq_twoStage hc]
  exact hgood N hCN _ (div_pos ht (Real.sqrt_pos.mpr (Nat.cast_pos.mpr hN)))
    (width_mul_tScale_sq_le_one hN ht ht1)

end NeuralGeneralization.BatchTwoShallow
