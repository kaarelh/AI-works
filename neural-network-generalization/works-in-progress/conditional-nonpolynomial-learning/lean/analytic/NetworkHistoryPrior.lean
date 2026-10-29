import GaussianControlHistory
import NeuralGeneralization.BatchTwoActivationFullNetworkEventsLaw

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators NNReal ENNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel NeuralGeneralization.BatchTwoActivation
open NeuralGeneralization.NetworkLayerSplit NeuralGeneralization.GaussianAngularFields

/-- Convert standardized Gaussian rows to their physical hidden-layer weights. -/
def physicalMatrix {N : ℕ} (σ : ℝ) (z : GaussianRawRows (Fin N) N) : Fin N×Fin N→ℝ :=
  fun ij=>σ*z ij.1 ij.2

theorem physicalMatrix_reference {N : ℕ} {σ : ℝ} (hσ : 0<σ) :
    MeasurePreserving (physicalMatrix (N:=N) σ) (gaussianRawRowsLaw (Fin N) N)
      (activationMatrixPrior N σ) := by
  have hm : Measurable (physicalMatrix (N:=N) σ) := by unfold physicalMatrix; fun_prop
  refine ⟨hm,?_⟩
  have hrows := activationMatrixRows_law (N:=N) hσ
  change (activationMatrixPrior N σ).map (activationMatrixRows σ)=gaussianRawRowsLaw (Fin N) N at hrows
  rw [←hrows,Measure.map_map hm (measurable_activationMatrixRows σ)]
  have hi : physicalMatrix σ ∘ activationMatrixRows (N:=N) σ=id := by
    funext a ij
    change σ*(a ij/σ)=a ij
    field_simp
  rw [hi,Measure.map_id]

/-- Join the standardized Gaussian matrix history into the actual coordinates
of the finite network. The initial object contains the first layer and the
readout; every subsequent step appends one hidden-to-hidden matrix. -/
def networkHistoryWeights {d N : ℕ} (σ : ℝ) :
    (r : ℕ)→ControlHistory (Weights d N 0) (GaussianRawRows (Fin N) N) r→Weights d N r
  | 0 => id
  | r+1 => fun p=>(split d N r).symm
      (networkHistoryWeights σ r p.1,physicalMatrix σ p.2)

theorem networkHistoryWeights_measurable {d N : ℕ} (σ : ℝ) (r : ℕ) :
    Measurable (networkHistoryWeights (d:=d) (N:=N) σ r) := by
  induction r with
  | zero => exact measurable_id
  | succ r ih =>
      change Measurable (fun p : ControlHistory (Weights d N 0) (GaussianRawRows (Fin N) N) r×
        GaussianRawRows (Fin N) N=> (split d N r).symm
          (networkHistoryWeights σ r p.1,physicalMatrix σ p.2))
      apply (split d N r).symm.measurable.comp
      apply (ih.comp measurable_fst).prodMk
      unfold physicalMatrix
      fun_prop

/-- Literal original Gaussian network prior, not a surrogate row-history law. -/
theorem networkHistoryWeights_reference {d N : ℕ} {σ : ℝ} (hσ : 0<σ) (r : ℕ) :
    MeasurePreserving (networkHistoryWeights (d:=d) (N:=N) σ r)
      (controlHistoryLaw (smallPrior d N 0 σ) (fun _=>gaussianRawRowsLaw (Fin N) N) r)
      (smallPrior d N r σ) := by
  induction r with
  | zero => exact MeasurePreserving.id _
  | succ r ih =>
      have hp := ih.prod (physicalMatrix_reference (N:=N) hσ)
      have hj := (activationSmallPrior_split d N r σ).symm
      exact hj.comp hp

/-- The actual planted finite-network weights, including arbitrary measurable
history-dependent unit directions, have the original NN prior as reference. -/
theorem gaussianNetwork_reference {Ω H : Type} {d N : ℕ}
    [MeasurableSpace Ω] [MeasurableSpace H]
    (P : ℕ→Measure Ω) [∀n,IsProbabilityMeasure (P n)]
    (μ : Measure H) [IsProbabilityMeasure μ] {σ : ℝ} (hσ : 0<σ)
    (F : H→Weights d N 0) (hF : MeasurePreserving F μ (smallPrior d N 0 σ))
    (Z : ℕ→Ω→ℝ) (hZ : ∀n,Measurable (Z n)) (hP : ∀n,(P n).map (Z n)=gaussianReal 0 1)
    (u : (n : ℕ)→ControlHistory H (GaussianControlRow Ω (Fin N) N) n→Fin N→ℝ)
    (hu : ∀n,Measurable (u n)) (hnorm : ∀n a,∑i,(u n a i)^2=1) (r : ℕ) :
    MeasurePreserving
      (networkHistoryWeights σ r ∘ gaussianHistoryMap F Z u r)
      (controlHistoryLaw μ (fun j=>gaussianControlRowLaw N (P j)) r)
      (smallPrior d N r σ) :=
  (networkHistoryWeights_reference hσ r).comp
    (gaussianHistory_reference P μ (smallPrior d N 0 σ) F hF Z hZ hP u hu hnorm r)

/-- Finite-width target planting costs the exact width times the control
entropy sum, even after mapping to the actual original network parameters. -/
theorem gaussianNetwork_kl {Ω H : Type} {d N : ℕ}
    [MeasurableSpace Ω] [MeasurableSpace H] [StandardBorelSpace Ω] [StandardBorelSpace H]
    [Nonempty Ω] [Nonempty H]
    (Q P : ℕ→Measure Ω) [∀n,IsProbabilityMeasure (Q n)] [∀n,IsProbabilityMeasure (P n)]
    (μQ μP : Measure H) [IsProbabilityMeasure μQ] [IsProbabilityMeasure μP]
    {σ : ℝ} (hσ : 0<σ)
    (F : H→Weights d N 0) (hF : MeasurePreserving F μP (smallPrior d N 0 σ))
    (Z : ℕ→Ω→ℝ) (hZ : ∀n,Measurable (Z n)) (hP : ∀n,(P n).map (Z n)=gaussianReal 0 1)
    (u : (n : ℕ)→ControlHistory H (GaussianControlRow Ω (Fin N) N) n→Fin N→ℝ)
    (hu : ∀n,Measurable (u n)) (hnorm : ∀n a,∑i,(u n a i)^2=1) (r : ℕ) :
    klDiv ((controlHistoryLaw μQ (fun j=>gaussianControlRowLaw (I:=Fin N) N (Q j)) r).map
      (networkHistoryWeights σ r ∘ gaussianHistoryMap F Z u r)) (smallPrior d N r σ)
      ≤ klDiv μQ μP + N*(∑j : Fin r,klDiv (Q j) (P j)) := by
  have href := gaussianNetwork_reference P μP hσ F hF Z hZ hP u hu hnorm r
  rw [←href.map_eq]
  exact (NeuralGeneralization.RobustEntropy.klDiv_map_le _ _ href.measurable).trans_eq
    (gaussianControlHistory_kl Q P μQ μP r)

end ConditionalNonpolynomial.Analytic
