import NeuralGeneralization.OnlineLowerTanhResidualUniformTheorem
import NeuralGeneralization.OnlineLowerTanhPeriodicExactPeriodization
import NeuralGeneralization.OnlineLowerTanhPeriodicExactGaussian

/-! # The uniform residual theorem with the manuscript's paired-tanh response

This is a statement wrapper only: the periodic response is the literal paired
real-space tanh series, Gaussian smoothing is the standard Gaussian integral,
and derivatives apply to the complete displayed leading expression.
-/
noncomputable section
open scoped BigOperators
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.OnlineLowerTanh

/-- The leading term exactly as defined in the residual-CLT manuscript. -/
def residualPaperLeading {n : ℕ} (q : Fin n → ℕ) (d : Fin n → ℝ) (A B : ℝ) : ℝ :=
  residualPhaseSign q * Real.sqrt (2/(Real.pi*residualVariance q)) *
    Real.exp (-B^2/(2*A^2*residualVariance q)) *
      ∫ z : ℝ, pairedPeriodicResponse A
        (B+(n%2:ℕ)*A+Real.sqrt (∑ i, (d i)^2)*z) ∂gaussianReal 0 1

theorem residualLeading_eq_paper {n : ℕ} (q : Fin n → ℕ) (d : Fin n → ℝ)
    {A : ℝ} (hA : 0<A) : residualLeading q d A = residualPaperLeading q d A := by
  funext B
  unfold residualLeading residualPaperLeading
  congr 1
  rw [←periodicFourierResponse_gaussian_convolution hA
    (Finset.sum_nonneg (fun i _=>sq_nonneg (d i)))]
  apply integral_congr_ae
  exact Filter.Eventually.of_forall (fun z=>periodicFourierResponse_eq_paired hA _)

/-- Full compact-uniform residual approximation, at every fixed derivative
order and every real bias, stated using the original paired-tanh series and
its literal standard-Gaussian convolution. -/
theorem residual_uniform_derivative_estimate_paper
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    (q : ι→ℕ) (c : ι→ℤ) (hq : ∀i,Odd (q i)) (hc : ∑i,c i*(q i:ℤ)=1)
    {α Q lo hi K : ℝ} (hα : 0<α) (hQ : 0<Q) (hlo : 0<lo) (hK : 0≤K)
    (hqQ : ∀i,(q i:ℝ)≤Q) (j : ℕ) :
    ∀ ε>0, ∃N₀:ℕ, ∃δ:ℝ, 0<δ ∧
      ∀P:ResidualSample ι q α lo hi K, N₀≤P.N →
        (∀i,|P.d i|≤δ) → ∀B:ℝ,
          Real.sqrt (residualVariance P.alphabet) *
            |iteratedDeriv j (parityCorrelation P.incoming) B -
              iteratedDeriv j (residualPaperLeading P.alphabet P.d P.A) B| < ε := by
  intro ε hε
  obtain ⟨N₀,δ,hδ,hbound⟩ := residual_uniform_derivative_estimate q c hq hc
    hα hQ hlo hK hqQ j ε hε
  refine ⟨N₀,δ,hδ,?_⟩
  intro P hN hd B
  have h := hbound P hN hd B
  unfold ResidualSample.fullDerivativeError at h
  rw [residualLeading_eq_paper P.alphabet P.d (hlo.trans_le P.A_lo)] at h
  exact h

end NeuralGeneralization.OnlineLowerTanh
