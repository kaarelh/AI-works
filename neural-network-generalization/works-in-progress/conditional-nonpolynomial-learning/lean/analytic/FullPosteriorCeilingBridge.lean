import UniformMarginPathWidth

/-! The finite-event contradiction for the actual original posterior.
The remaining structural input is stated directly for genuine controlled
paths, rather than for an abstract approximation or statistical oracle. -/
noncomputable section
attribute [local instance] Classical.propDecidable
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel

theorem posterior_ceiling_of_margin_path_class {d N r n : ℕ}
    (hd : 0<d) (hN : 0<N) {σ A τ U h : ℝ} (hσ : 0<σ)
    (hscale : Real.sqrt N*σ≤1) (hA : 0≤A) (hτ : 0<τ)
    (f : BooleanFunction d) (sample : Fin n→Cube d) (B : Set (BooleanFunction d))
    (hZ : Real.exp (-(N:ℝ)*A)≤posteriorDenominator Real.tanh (1/2)
      (smallPrior d N r σ) f sample)
    (hlog : Real.log 6/(N:ℝ)≤τ)
    (hNorm : (Real.sqrt N*σ)^2*(A+2*τ)≤U)
    (hslack : 1≤(Real.sqrt N*σ)^2*τ*h)
    (hwidth : normalizedCertificateWidth d r U h (normalizedRepairLog d r U h)≤N)
    (hclass : ∀g : BooleanFunction d,
      ∀P : ControlledMarginPath d (r+1) (Real.sqrt N*σ) g,
        P.action≤A+3*τ → g∈B) :
    (5/6:ℝ)≤∑g : BooleanFunction d,if g∈B then
      networkPosterior Real.tanh (1/2) (smallPrior d N r σ) f sample g else 0 := by
  by_contra hbad
  have hbad' := lt_of_not_ge hbad
  have ht : 0<Real.sqrt N*σ := by
    have hn : (0:ℝ)<N := by exact_mod_cast hN
    positivity
  have hA' : 0≤A+Real.log 6/(N:ℝ) := by
    have hlog0 : 0≤Real.log (6:ℝ) := Real.log_nonneg (by norm_num)
    positivity
  have hNorm' : (Real.sqrt N*σ)^2*(A+Real.log 6/(N:ℝ)+τ)≤U := by
    apply le_trans ?_ hNorm
    apply mul_le_mul_of_nonneg_left _ (sq_nonneg _)
    linarith
  have hwidth' : sharpMarginPathWidth d r (A+Real.log 6/(N:ℝ)) τ U≤N :=
    (sharpMarginPathWidth_uniform d r (sq_pos_of_pos ht) (by nlinarith)
      hA' hτ hNorm' hslack).trans hwidth
  obtain ⟨g,hg,_,P,hP⟩ := posterior_failure_contains_margin_path_sharp
    hd hN hσ hscale hA hτ f sample B hZ hbad' hNorm' hwidth'
  exact hg (hclass g P (by linarith))

theorem posterior_ceiling_log_slack {N r : ℕ} (hr : 1≤r)
    (hNr : 2*r≤N) {t : ℝ} (ht : 0<t) (ht1 : t≤1) :
    Real.log 6/(N:ℝ)≤1/(t^2*(r:ℝ)) := by
  have hrR : (0:ℝ)<r := by exact_mod_cast (show 0<r by omega)
  have hnR : (0:ℝ)<N := by exact_mod_cast (show 0<N by omega)
  have hNrR : 2*(r:ℝ)≤N := by exact_mod_cast hNr
  have ht2 : t^2≤1 := by nlinarith
  have hl : Real.log (6:ℝ)≤2 := by
    have hexp : (6:ℝ)≤Real.exp 2 := by
      have he := Real.quadratic_le_exp_of_nonneg (by norm_num : (0:ℝ)≤1)
      have he1 := Real.add_one_lt_exp (by norm_num : (1:ℝ)≠0)
      have he2 := Real.exp_add (1:ℝ) 1
      norm_num at he he1 he2
      nlinarith [Real.exp_pos (1:ℝ)]
    exact (Real.log_le_log (by norm_num) hexp).trans_eq (Real.log_exp 2)
  apply (div_le_div_of_nonneg_right hl hnR.le).trans
  apply (div_le_div_of_nonneg_left (by norm_num : (0:ℝ)≤2)
    (by positivity : (0:ℝ)<2*r) hNrR).trans
  have htpos : 0<t^2*(r:ℝ) := by positivity
  apply (le_div_iff₀ htpos).mpr
  have htwo : (2:ℝ)/(2*(r:ℝ))*(t^2*(r:ℝ))=t^2 := by field_simp
  rw [htwo]
  exact ht2

#print axioms posterior_ceiling_of_margin_path_class
#print axioms posterior_ceiling_log_slack
end ConditionalNonpolynomial.Analytic
