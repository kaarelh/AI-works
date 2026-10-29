import NetworkReadoutPlanting
import ProductControlEntropy

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators NNReal ENNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel

/-- Literal raw NN prior mass from a successful source-history/readout
construction. Both entropy and success refer to actual probability laws. -/
theorem finite_network_channel_mass {H : Type*}
    [MeasurableSpace H] [StandardBorelSpace H] [Nonempty H]
    {d N r : ℕ} (hN : 0<N) (σ μ : ℝ)
    (Q P : Measure H) [IsProbabilityMeasure Q] [IsProbabilityMeasure P]
    (F : H→Weights d N r) (hF : MeasurePreserving F P (smallPrior d N r σ))
    (u : H→Fin N→ℝ) (hu : Measurable u) (hnorm : ∀h,∑i,u h i^2=1)
    (E : Set (Weights d N r)) (hE : MeasurableSet E)
    (hKL : klDiv Q P≠∞) {κ D : ℝ} (hκ : κ<1)
    (hsuccess : 1-κ≤(Q.prod (readoutControlLaw N μ)).real
      (networkWithReadoutChannel σ F u ⁻¹' E))
    (hcost : (klDiv Q P).toReal+μ^2/2≤D) :
    Real.exp (-(D+Real.log 2)/(1-κ))≤(smallPrior d N r σ).real E := by
  have href := networkWithReadoutChannel_reference hN σ P F hF u hu hnorm
  have hsource : klDiv (Q.prod (readoutControlLaw N μ))
      (P.prod (readoutControlLaw N 0))=klDiv Q P+ENNReal.ofReal (μ^2/2) := by
    rw [product_control_kl,readoutControlLaw_kl]
  have hsourcefin : klDiv (Q.prod (readoutControlLaw N μ))
      (P.prod (readoutControlLaw N 0))≠∞ := by
    rw [hsource]
    exact ENNReal.add_ne_top.mpr ⟨hKL,ENNReal.ofReal_ne_top⟩
  have hsourcecost : (klDiv (Q.prod (readoutControlLaw N μ))
      (P.prod (readoutControlLaw N 0))).toReal≤D := by
    rw [hsource,ENNReal.toReal_add hKL ENNReal.ofReal_ne_top,
      ENNReal.toReal_ofReal (by positivity : 0≤μ^2/2)]
    exact hcost
  have h := raw_mass_of_controlled_success (Q.prod (readoutControlLaw N μ))
    (P.prod (readoutControlLaw N 0)) hsourcefin
    (networkWithReadoutChannel σ F u ⁻¹' E) (hE.preimage href.measurable)
    κ D hκ hsuccess hsourcecost
  have heq : (P.prod (readoutControlLaw N 0)).real
      (networkWithReadoutChannel σ F u ⁻¹' E)=(smallPrior d N r σ).real E := by
    rw [←href.map_eq]
    simp only [Measure.real,Measure.map_apply href.measurable hE]
  rwa [heq] at h

/-- The probability slack can be made small enough that the leading
energy coefficient remains exactly one. -/
theorem channel_entropy_slack {A τ κ D n : ℝ} (hA : 0≤A) (hτ : 0<τ)
    (hn : 0<n) (hκ0 : 0≤κ) (hκ : κ≤τ/(4*(A+τ)))
    (hD : D≤n*(A+τ/4)) (hlog : Real.log 2≤n*τ/4) :
    κ<1 ∧ (D+Real.log 2)/(1-κ)≤n*(A+τ) := by
  have hden : 0<4*(A+τ) := by positivity
  have hkprod := (le_div_iff₀ hden).mp hκ
  have hkquarter : κ≤1/4 := by nlinarith [mul_nonneg hκ0 hA]
  have hk1 : κ<1 := by linarith
  refine ⟨hk1,?_⟩
  apply (div_le_iff₀ (by linarith : 0<1-κ)).mpr
  have hmult := mul_le_mul_of_nonneg_left hkprod hn.le
  nlinarith

theorem finite_network_channel_mass_with_slack {H : Type*}
    [MeasurableSpace H] [StandardBorelSpace H] [Nonempty H]
    {d N r : ℕ} (hN : 0<N) (σ μ : ℝ)
    (Q P : Measure H) [IsProbabilityMeasure Q] [IsProbabilityMeasure P]
    (F : H→Weights d N r) (hF : MeasurePreserving F P (smallPrior d N r σ))
    (u : H→Fin N→ℝ) (hu : Measurable u) (hnorm : ∀h,∑i,u h i^2=1)
    (E : Set (Weights d N r)) (hE : MeasurableSet E)
    (hKL : klDiv Q P≠∞) {A τ κ : ℝ} (hA : 0≤A) (hτ : 0<τ)
    (hκ0 : 0≤κ) (hκ : κ≤τ/(4*(A+τ)))
    (hsuccess : 1-κ≤(Q.prod (readoutControlLaw N μ)).real
      (networkWithReadoutChannel σ F u ⁻¹' E))
    (hcost : (klDiv Q P).toReal+μ^2/2≤(N:ℝ)*(A+τ/4))
    (hwidth : Real.log 2≤(N:ℝ)*τ/4) :
    Real.exp (-(N:ℝ)*(A+τ))≤(smallPrior d N r σ).real E := by
  have hn : (0:ℝ)<N := by exact_mod_cast hN
  obtain ⟨hk1,hfrac⟩ := channel_entropy_slack hA hτ hn hκ0 hκ hcost hwidth
  have hh := finite_network_channel_mass hN σ μ Q P F hF u hu hnorm E hE hKL hk1
    hsuccess (le_refl ((klDiv Q P).toReal+μ^2/2))
  apply le_trans _ hh
  apply Real.exp_le_exp.mpr
  simpa only [neg_div,neg_mul] using neg_le_neg hfrac

#print axioms finite_network_channel_mass_with_slack
end ConditionalNonpolynomial.Analytic
