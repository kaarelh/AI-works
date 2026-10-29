import SharpRepairPrecisionLog
noncomputable section
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel

def normalizedRepairLog (d r : ℕ) (U h : ℝ) : ℝ :=
  2*(Real.log ((r+1:ℕ)+1)+(r+1:ℕ)*Real.log (2+Real.sqrt (2*U))+
    Real.log (1+Real.sqrt (2*U))+Real.log (16*U*h)+
    4*Real.log (Fintype.card (Cube d):ℝ))

/-- Both covariance precision and finite-event width are uniform as the
physical prior variance tends to zero. No lower bound on that scale is used. -/
theorem sharpMarginPathWidth_uniform (d r : ℕ) {x A τ U h : ℝ}
    (hx : 0<x) (hx1 : x≤1) (hA : 0≤A) (hτ : 0<τ)
    (hU : x*(A+τ)≤U) (hh : 1≤x*τ*h) :
    sharpMarginPathWidth d r A τ U≤
      normalizedCertificateWidth d r U h (normalizedRepairLog d r U h) := by
  have hepos := sharpPathRepairEpsilon_pos d r (U:=U) hA hτ
  have hele := sharpPathRepairEpsilon_le_one d r (U:=U) hA hτ
  exact certificateWidth_normalized d r hx hx1 hA hτ hU hh
    (sq_pos_of_pos hepos) (by nlinarith)
    (sharpPathRepairEpsilon_normalized_log d r hx hA hτ hU hh)

/-- Fully explicit, scale-independent width bound for extracting a genuine
low-action controlled path from an event of the original network prior. -/
theorem event_contains_margin_paths_uniform {d N r : ℕ} (hd : 0<d) (hN : 0<N)
    {σ A τ U h : ℝ} (hσ : 0<σ) (hscale : Real.sqrt N*σ≤1)
    (hA : 0≤A) (hτ : 0<τ)
    (hNorm : (Real.sqrt N*σ)^2*(A+τ)≤U)
    (hslack : 1≤(Real.sqrt N*σ)^2*τ*h)
    (hwidth : normalizedCertificateWidth d r U h (normalizedRepairLog d r U h)≤N)
    (E : Set (Weights d N r))
    (hMass : Real.exp (-(N:ℝ)*A)≤(smallPrior d N r σ).real E) :
    ∃w∈E,∀f : BooleanFunction d,w∈marginEvent Real.tanh (1/2) f →
      ∃P : ControlledMarginPath d (r+1) (Real.sqrt N*σ) f,P.action≤A+2*τ := by
  have hn : (0:ℝ)<N := by exact_mod_cast hN
  have ht : 0<Real.sqrt N*σ := by positivity
  apply event_contains_margin_paths_sharp hd hN hσ hscale hA hτ hNorm
    ((sharpMarginPathWidth_uniform d r (sq_pos_of_pos ht) (by nlinarith) hA hτ hNorm hslack).trans hwidth)
    E hMass

#print axioms event_contains_margin_paths_uniform
end ConditionalNonpolynomial.Analytic
