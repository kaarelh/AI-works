import DenseWidthArithmetic
import ProjectedReadoutFeasibility

/-! Explicit nonasymptotic finite-event entropy certificate for the original
Gaussian tanh network. The width bound is polynomial in depth, number of
queries, inverse entropy slack, and log inverse moment tolerance. -/
noncomputable section
set_option linter.unusedSectionVars false
open MeasureTheory InformationTheory
open scoped BigOperators ENNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel NeuralGeneralization.CovarianceDualLift
open NeuralGeneralization.ActualBoundedDual NeuralGeneralization.BoundedDual
open NeuralGeneralization.BoundedTilt

def certificateWidth (d r : ℕ) (A τ Δ : ℝ) : ℝ :=
  denseWidthBudget d r ((A+τ)/Δ) (τ/(4*(A+τ))) (τ/2)

lemma certificate_slack_bounds {A τ : ℝ} (hA : 0≤A) (hτ : 0<τ) :
    0<τ/(4*(A+τ)) ∧ τ/(4*(A+τ))≤1/4 := by
  have hB : 0<A+τ := by linarith
  constructor
  · positivity
  · apply (div_le_iff₀ (show 0<4*(A+τ) by positivity)).mpr
    linarith

lemma remove_readout_slack {A τ D R : ℝ} (hA : 0≤A) (hτ : 0<τ)
    (hD : 0≤D) (hbudget : D+(1-τ/(4*(A+τ)))*R≤A+τ/2) :
    D+R≤A+τ := by
  let s := τ/(4*(A+τ))
  have hs := certificate_slack_bounds hA hτ
  have hid : s*(A+τ)=τ/4 := by dsimp [s]; field_simp
  have hnonneg : 0≤s*D := mul_nonneg hs.1.le hD
  change D+(1-s)*R≤A+τ/2 at hbudget
  by_contra h
  have hgt : A+τ<D+R := lt_of_not_ge h
  have hs1 : 0<1-s := by dsimp [s]; linarith [hs.2]
  have hh := mul_lt_mul_of_pos_left hgt hs1
  nlinarith

/-- The complete actual finite-width entropy certificate. The constructed
row laws have total relative entropy plus feasible readout action ≤A+τ,
and every empirical covariance coordinate is approximated within Δ. -/
theorem finite_width_entropy_certificate (d N r : ℕ) (hd : 0<d) (hN : 0<N)
    (σ A τ Δ : ℝ) (hσ : 0<σ) (hA : 0≤A) (hτ : 0<τ) (hΔ : 0<Δ)
    (hwidth : certificateWidth d r A τ Δ≤N)
    (E : Set (Weights d N r))
    (hMass : Real.exp (-(N:ℝ)*A)≤(smallPrior d N r σ).real E) :
    ∃ w∈E,∃ star : Fin (r+1) → Cube d × Cube d → ℝ,
      (∀ j,entryL1 (star j)≤(A+τ)/Δ) ∧
      (∀ j,IsProbabilityMeasure ((hiddenReferences d N σ r w j).tilted
        (potential (features Real.tanh) (star j)))) ∧
      (∀ j,klDiv ((hiddenReferences d N σ r w j).tilted
        (potential (features Real.tanh) (star j))) (hiddenReferences d N σ r w j)≠∞) ∧
      (∑ j,(klDiv ((hiddenReferences d N σ r w j).tilted
        (potential (features Real.tanh) (star j))) (hiddenReferences d N σ r w j)).toReal)
          +projectedReadoutSquared σ w/(2*N)≤A+τ ∧
      ∀ j,maxAbs (hiddenMoments d N σ r w j-
        mean (hiddenReferences d N σ r w j) (features Real.tanh) (star j))≤Δ := by
  let G := (A+τ)/Δ
  let s := τ/(4*(A+τ))
  have hB : 0<A+τ := by linarith
  have hG : 0<G := div_pos hB hΔ
  have hs := certificate_slack_bounds hA hτ
  have hs1 : s≤1 := by dsimp [s]; linarith [hs.2]
  have htail := prefactor_tail_lt d r N hN hG.le hs.1 hs1
    (show 0<τ/2 by positivity) hwidth A
  obtain ⟨w,hw,star,hstar,hprob,hfinite,hkl,herr⟩ :=
    actual_network_event_controlled_path d N r hd hN σ G s (A+τ/2)
      hσ hG hs.1 hs1 (denseGrid_pos hN hG.le) E (htail.trans_le hMass)
  refine ⟨w,hw,star,hstar,hprob,hfinite,?_,?_⟩
  · apply remove_readout_slack hA hτ
    · exact Finset.sum_nonneg (fun _ _=>ENNReal.toReal_nonneg)
    · convert hkl using 1
      dsimp [s]
      ring
  · intro j
    apply (herr j).trans
    change (A+τ/2)/((A+τ)/Δ)≤Δ
    apply (div_le_iff₀ hG).mpr
    have hid : Δ*((A+τ)/Δ)=A+τ := by field_simp
    rw [hid]
    linarith

#print axioms finite_width_entropy_certificate
end ConditionalNonpolynomial.Analytic
