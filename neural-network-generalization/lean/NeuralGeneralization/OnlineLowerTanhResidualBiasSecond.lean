import NeuralGeneralization.OnlineLowerTanhResidualSecondCLT
import NeuralGeneralization.OnlineLowerTanhBiasIntegral

/-! # The uniform residual asymptotic for actual second bias derivatives -/
noncomputable section
open scoped BigOperators Topology
open Filter
namespace NeuralGeneralization.OnlineLowerTanh
namespace ResidualSequence
variable {ι : Type*} [Fintype ι] [DecidableEq ι] (S : ResidualSequence ι)

/-- The second derivative is the literal normalized cube average of
`TanhDifferential.tanhSecond`, as well as the classical derivative of the
actual tanh correlation. Its leading periodic curvature is uniform in bias. -/
theorem uniform_residual_bias_second :
    ∀ ε > 0, ∀ᶠ k in atTop, ∀ B : ℝ,
      Real.sqrt (residualVariance (S.alphabet k))*
        |parityBiasSecond (S.incoming k) B+
          residualSecondLeading (S.alphabet k) (S.d k) (S.A k) B| < ε := by
  intro ε hε
  filter_upwards [S.uniform_residual_second_clt ε hε] with k hk B
  rw [parityBiasSecond_integral (S.N_pos k)]
  have he : -(∫ t : ℝ in Set.Ioi 0,
      residualRawKernel (S.incoming k) B ((S.N k:ℝ)*Real.pi/2) (residualDerivativeKernel 2) t)+
      residualSecondLeading (S.alphabet k) (S.d k) (S.A k) B =
      -(residualSecondIntegral (S.incoming k) B-
        residualSecondLeading (S.alphabet k) (S.d k) (S.A k) B) := by
    unfold residualSecondIntegral
    ring
  rw [he,abs_neg]
  exact hk B

end ResidualSequence
end NeuralGeneralization.OnlineLowerTanh
