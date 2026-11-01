import FullPosteriorCeilingBridge

/-! The actual posterior-to-controlled-path argument at every exceptional
mass beta in (0,1), with the precise log(1/beta)/N overhead. -/
noncomputable section
open scoped BigOperators
attribute [local instance] Classical.propDecidable
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel
open MeasureTheory

theorem posterior_ceiling_failure_raw_mass_beta {d N r n : ℕ}
    {φ : ℝ→ℝ} (hφ : Continuous φ) {a : ℝ} (ha : 0≤a)
    (μ : Measure (Weights d N r)) [IsFiniteMeasure μ]
    (f : BooleanFunction d) (sample : Fin n→Cube d) (B : Set (BooleanFunction d))
    (hZ : 0<posteriorDenominator φ a μ f sample) {β : ℝ} (hβ : 0≤β)
    (hbad : (∑g : BooleanFunction d,if g∈B then networkPosterior φ a μ f sample g else 0)<1-β) :
    posteriorDenominator φ a μ f sample*β≤μ.real (compatibleClassEvent φ a f sample Bᶜ) := by
  have htotal := networkPosterior_sum_of_denominator_pos φ a μ f sample hZ
  have hsum : (∑g : BooleanFunction d,if g∈B then networkPosterior φ a μ f sample g else 0)+
      (∑g : BooleanFunction d,if g∈Bᶜ then networkPosterior φ a μ f sample g else 0)=1 := by
    rw [←Finset.sum_add_distrib]
    convert htotal using 1
    apply Finset.sum_congr rfl
    intro g hg
    by_cases h : g∈B <;> simp [h]
  have hc : β≤∑g : BooleanFunction d,if g∈Bᶜ then networkPosterior φ a μ f sample g else 0 := by
    linarith
  exact posterior_class_raw_mass_lower hφ ha μ f sample Bᶜ hZ hβ le_rfl (by simpa using hc)

theorem posterior_ceiling_failure_exp_mass_beta {d N r n : ℕ}
    {φ : ℝ→ℝ} (hφ : Continuous φ) {a : ℝ} (ha : 0≤a)
    (μ : Measure (Weights d N r)) [IsFiniteMeasure μ]
    (f : BooleanFunction d) (sample : Fin n→Cube d) (B : Set (BooleanFunction d))
    (hN : 0<N) (A : ℝ) {β : ℝ} (hβ : 0<β)
    (hZ : Real.exp (-(N:ℝ)*A)≤posteriorDenominator φ a μ f sample)
    (hbad : (∑g : BooleanFunction d,if g∈B then networkPosterior φ a μ f sample g else 0)<1-β) :
    Real.exp (-(N:ℝ)*(A+Real.log (1/β)/N))≤
      μ.real (compatibleClassEvent φ a f sample Bᶜ) := by
  have hZ0 := (Real.exp_pos _).trans_le hZ
  have hh := posterior_ceiling_failure_raw_mass_beta hφ ha μ f sample B hZ0 hβ.le hbad
  have hn : (N:ℝ)≠0 := by exact_mod_cast hN.ne'
  calc
    _ = Real.exp (-(N:ℝ)*A)*β := by
      rw [show -(N:ℝ)*(A+Real.log (1/β)/N)=-(N:ℝ)*A-Real.log (1/β) by field_simp; ring,
        Real.exp_sub,Real.exp_log (one_div_pos.mpr hβ)]
      field_simp
    _ ≤ posteriorDenominator φ a μ f sample*β := mul_le_mul_of_nonneg_right hZ hβ.le
    _ ≤ _ := hh

theorem posterior_failure_contains_margin_path_beta {d N r n : ℕ}
    (hd : 0<d) (hN : 0<N) {σ A τ U β : ℝ} (hσ : 0<σ)
    (hscale : Real.sqrt N*σ≤1) (hA : 0≤A) (hτ : 0<τ) (hβ : 0<β) (hβ1 : β≤1)
    (f : BooleanFunction d) (sample : Fin n→Cube d) (B : Set (BooleanFunction d))
    (hZ : Real.exp (-(N:ℝ)*A)≤posteriorDenominator Real.tanh (1/2) (smallPrior d N r σ) f sample)
    (hbad : (∑g : BooleanFunction d,if g∈B then
      networkPosterior Real.tanh (1/2) (smallPrior d N r σ) f sample g else 0)<1-β)
    (hNorm : (Real.sqrt N*σ)^2*(A+Real.log (1/β)/N+τ)≤U)
    (hwidth : sharpMarginPathWidth d r (A+Real.log (1/β)/N) τ U≤N) :
    ∃g : BooleanFunction d,g∉B ∧ consistent f sample g ∧
      ∃P : ControlledMarginPath d (r+1) (Real.sqrt N*σ) g,
        P.action≤A+Real.log (1/β)/N+2*τ := by
  have hraw := posterior_ceiling_failure_exp_mass_beta tanh_continuous (by norm_num : (0:ℝ)≤1/2)
    (smallPrior d N r σ) f sample B hN A hβ hZ hbad
  have hA' : 0≤A+Real.log (1/β)/N := by
    have hh : 0≤Real.log (1/β) := Real.log_nonneg ((one_le_div hβ).mpr hβ1)
    positivity
  obtain ⟨w,hw,hpaths⟩ := event_contains_margin_paths_sharp hd hN hσ hscale hA' hτ hNorm hwidth
    (compatibleClassEvent Real.tanh (1/2) f sample Bᶜ) hraw
  obtain ⟨g,hg,hc,hm⟩ := (mem_compatibleClassEvent Real.tanh (1/2) f sample Bᶜ w).mp hw
  exact ⟨g,hg,hc,hpaths g hm⟩

theorem posterior_ceiling_of_margin_path_class_beta {d N r n : ℕ}
    (hd : 0<d) (hN : 0<N) {σ A τ U h β : ℝ} (hσ : 0<σ)
    (hscale : Real.sqrt N*σ≤1) (hA : 0≤A) (hτ : 0<τ) (hβ : 0<β) (hβ1 : β≤1)
    (f : BooleanFunction d) (sample : Fin n→Cube d) (B : Set (BooleanFunction d))
    (hZ : Real.exp (-(N:ℝ)*A)≤posteriorDenominator Real.tanh (1/2)
      (smallPrior d N r σ) f sample)
    (hlog : Real.log (1/β)/(N:ℝ)≤τ)
    (hNorm : (Real.sqrt N*σ)^2*(A+2*τ)≤U)
    (hslack : 1≤(Real.sqrt N*σ)^2*τ*h)
    (hwidth : normalizedCertificateWidth d r U h (normalizedRepairLog d r U h)≤N)
    (hclass : ∀g : BooleanFunction d,
      ∀P : ControlledMarginPath d (r+1) (Real.sqrt N*σ) g,
        P.action≤A+3*τ → g∈B) :
    (1-β:ℝ)≤∑g : BooleanFunction d,if g∈B then
      networkPosterior Real.tanh (1/2) (smallPrior d N r σ) f sample g else 0 := by
  by_contra hbad
  have ht : 0<Real.sqrt N*σ := by
    have hn : (0:ℝ)<N := by exact_mod_cast hN
    positivity
  have hA' : 0≤A+Real.log (1/β)/(N:ℝ) := by
    have hlog0 : 0≤Real.log (1/β) := Real.log_nonneg ((one_le_div hβ).mpr hβ1)
    positivity
  have hNorm' : (Real.sqrt N*σ)^2*(A+Real.log (1/β)/(N:ℝ)+τ)≤U := by
    apply le_trans ?_ hNorm
    apply mul_le_mul_of_nonneg_left _ (sq_nonneg _)
    linarith
  have hwidth' : sharpMarginPathWidth d r (A+Real.log (1/β)/(N:ℝ)) τ U≤N :=
    (sharpMarginPathWidth_uniform d r (sq_pos_of_pos ht) (by nlinarith)
      hA' hτ hNorm' hslack).trans hwidth
  obtain ⟨g,hg,_,P,hP⟩ := posterior_failure_contains_margin_path_beta
    hd hN hσ hscale hA hτ hβ hβ1 f sample B hZ (lt_of_not_ge hbad) hNorm' hwidth'
  exact hg (hclass g P (by linarith))

theorem posterior_ceiling_log_slack_beta {N r : ℕ} (hr : 1≤r) (hN : 0<N)
    {t β : ℝ} (ht : 0<t) (ht1 : t≤1) (hβ : 0<β) (hβ1 : β≤1)
    (hwidth : (r:ℝ)*Real.log (1/β)≤N) :
    Real.log (1/β)/(N:ℝ)≤1/(t^2*(r:ℝ)) := by
  have hrR : (0:ℝ)<r := by exact_mod_cast (show 0<r by omega)
  have hnR : (0:ℝ)<N := by exact_mod_cast hN
  have ht2 : t^2≤1 := by nlinarith
  have hl : 0≤Real.log (1/β) := Real.log_nonneg ((one_le_div hβ).mpr hβ1)
  apply (div_le_iff₀ hnR).mpr
  rw [show 1/(t^2*(r:ℝ))*(N:ℝ)=(N:ℝ)/(t^2*(r:ℝ)) by ring]
  apply (le_div_iff₀ (by positivity : 0<t^2*(r:ℝ))).mpr
  have hh := mul_le_mul_of_nonneg_right ht2 (mul_nonneg hrR.le hl)
  nlinarith

#print axioms posterior_ceiling_of_margin_path_class_beta
end ConditionalNonpolynomial.Analytic
