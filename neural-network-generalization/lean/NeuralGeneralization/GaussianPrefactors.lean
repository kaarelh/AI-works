import NeuralGeneralization.RatePosterior

/-!
# Fixed prefactors at exponential scale

This file proves the absorption of fixed positive prefactors into arbitrarily
small exponential rate errors. It is used by the actual Gaussian event proof.
-/

noncomputable section
open Filter
open scoped Topology
namespace NeuralGeneralization.GaussianRate

/-- Fixed positive multiplicative constants disappear at exponential scale.
Both inequalities are proved here for an arbitrary indexing filter. -/
theorem hasExponentialRate_of_prefactors {I : Type*} {l : Filter I}
    (speed w : I → ℝ) (E : ℝ) (hs : Tendsto speed l atTop)
    (hlower : ∀ δ : ℝ, 0 < δ → ∃ c : ℝ, 0 < c ∧
      ∀ᶠ n in l, c * Real.exp (-(E + δ) * speed n) ≤ w n)
    (hupper : ∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 < C ∧
      ∀ᶠ n in l, w n ≤ C * Real.exp (-(E - δ) * speed n)) :
    HasExponentialRate l speed w E := by
  intro ε hε
  have hδ : 0 < ε / 2 := by linarith
  obtain ⟨c, hc, hlo⟩ := hlower (ε / 2) hδ
  obtain ⟨C, hC, hhi⟩ := hupper (ε / 2) hδ
  have hsmall : Tendsto (fun n => Real.exp (-(ε / 2) * speed n)) l (𝓝 0) := by
    simpa only [Function.comp_def, neg_mul] using
      Real.tendsto_exp_neg_atTop_nhds_zero.comp (hs.const_mul_atTop hδ)
  have hlarge : Tendsto (fun n => Real.exp ((ε / 2) * speed n)) l atTop :=
    Real.tendsto_exp_atTop.comp (hs.const_mul_atTop hδ)
  have hcl := (tendsto_order.mp hsmall).2 c hc
  have hCu := hlarge.eventually_ge_atTop C
  filter_upwards [hlo, hhi, hcl, hCu] with n hln hun hcn hCn
  constructor
  · calc
      Real.exp (-(E + ε) * speed n) =
          Real.exp (-(ε / 2) * speed n) *
            Real.exp (-(E + ε / 2) * speed n) := by
        rw [← Real.exp_add]
        congr 1
        ring
      _ ≤ c * Real.exp (-(E + ε / 2) * speed n) :=
        mul_le_mul_of_nonneg_right hcn.le (Real.exp_pos _).le
      _ ≤ w n := hln
  · calc
      w n ≤ C * Real.exp (-(E - ε / 2) * speed n) := hun
      _ ≤ Real.exp ((ε / 2) * speed n) *
          Real.exp (-(E - ε / 2) * speed n) :=
        mul_le_mul_of_nonneg_right hCn (Real.exp_pos _).le
      _ = Real.exp (-(E - ε) * speed n) := by
        rw [← Real.exp_add]
        congr 1
        ring

end NeuralGeneralization.GaussianRate
