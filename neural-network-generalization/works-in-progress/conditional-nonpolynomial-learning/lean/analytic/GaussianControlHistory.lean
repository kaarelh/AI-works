import ControlHistory
import ScoreUnitDirection

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators NNReal ENNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.GaussianAngularFields

abbrev GaussianControlRow (Ω I : Type) (N : ℕ) := Fin N→Ω×(I→ℝ)
abbrev GaussianRawRows (I : Type) (N : ℕ) := Fin N→I→ℝ

def gaussianControlRowLaw {Ω I : Type} [MeasurableSpace Ω] [Fintype I]
    (N : ℕ) (P : Measure Ω) : Measure (GaussianControlRow Ω I N) :=
  Measure.pi (fun _ : Fin N=>P.prod (standardLaw I))

instance gaussianControlRowLaw_probability {Ω I : Type} [MeasurableSpace Ω] [Fintype I]
    (N : ℕ) (P : Measure Ω) [IsProbabilityMeasure P] :
    IsProbabilityMeasure (gaussianControlRowLaw (I:=I) N P) := by
  unfold gaussianControlRowLaw
  infer_instance

def gaussianRawRowsLaw (I : Type) [Fintype I] (N : ℕ) : Measure (GaussianRawRows I N) :=
  Measure.pi (fun _ : Fin N=>standardLaw I)

instance gaussianRawRowsLaw_probability (I : Type) [Fintype I] (N : ℕ) :
    IsProbabilityMeasure (gaussianRawRowsLaw I N) := by unfold gaussianRawRowsLaw; infer_instance

/-- The full deterministic planting map. Its direction at each stage may use
all past scalar controls, scores, and residual noises. -/
def gaussianHistoryMap {Ω I H Y : Type} [Fintype I] {N : ℕ}
    (F : H→Y) (Z : ℕ→Ω→ℝ)
    (u : (n : ℕ)→ControlHistory H (GaussianControlRow Ω I N) n→I→ℝ) :
    (n : ℕ)→ControlHistory H (GaussianControlRow Ω I N) n→
      ControlHistory Y (GaussianRawRows I N) n
  | 0 => F
  | n+1 => fun p=>(gaussianHistoryMap F Z u n p.1,directionSplitRows (Z n) (u n p.1) p.2)

theorem gaussianHistoryMap_measurable {Ω I H Y : Type} [Fintype I] {N : ℕ}
    [MeasurableSpace Ω] [MeasurableSpace H] [MeasurableSpace Y]
    (F : H→Y) (hF : Measurable F) (Z : ℕ→Ω→ℝ) (hZ : ∀n,Measurable (Z n))
    (u : (n : ℕ)→ControlHistory H (GaussianControlRow Ω I N) n→I→ℝ)
    (hu : ∀n,Measurable (u n)) (n : ℕ) : Measurable (gaussianHistoryMap F Z u n) := by
  induction n with
  | zero => exact hF
  | succ n ih =>
      change Measurable (fun p : ControlHistory H (GaussianControlRow Ω I N) n × GaussianControlRow Ω I N=>
        (gaussianHistoryMap F Z u n p.1,directionSplitRows (Z n) (u n p.1) p.2))
      apply (ih.comp measurable_fst).prodMk
      unfold directionSplitRows directionSplit
      fun_prop

/-- The full adaptive planting map sends the product reference controls to
independent Gaussian incoming-weight matrices, exactly at every finite width. -/
theorem gaussianHistory_reference {Ω I H Y : Type} [Fintype I] [DecidableEq I] {N : ℕ}
    [MeasurableSpace Ω] [MeasurableSpace H] [MeasurableSpace Y]
    (P : ℕ→Measure Ω) [∀n,IsProbabilityMeasure (P n)]
    (μ : Measure H) [IsProbabilityMeasure μ] (ν : Measure Y) [IsProbabilityMeasure ν]
    (F : H→Y) (hF : MeasurePreserving F μ ν)
    (Z : ℕ→Ω→ℝ) (hZ : ∀n,Measurable (Z n)) (hP : ∀n,(P n).map (Z n)=gaussianReal 0 1)
    (u : (n : ℕ)→ControlHistory H (GaussianControlRow Ω I N) n→I→ℝ)
    (hu : ∀n,Measurable (u n)) (hnorm : ∀n a,∑i,(u n a i)^2=1) (n : ℕ) :
    MeasurePreserving (gaussianHistoryMap F Z u n)
      (controlHistoryLaw μ (fun j=>gaussianControlRowLaw N (P j)) n)
      (controlHistoryLaw ν (fun _=>gaussianRawRowsLaw I N) n) := by
  induction n with
  | zero => exact hF
  | succ n ih =>
      change MeasurePreserving
        (fun p=>(gaussianHistoryMap F Z u n p.1,directionSplitRows (Z n) (u n p.1) p.2))
        ((controlHistoryLaw μ (fun j=>gaussianControlRowLaw N (P j)) n).prod
          (gaussianControlRowLaw N (P n)))
        ((controlHistoryLaw ν (fun _=>gaussianRawRowsLaw I N) n).prod (gaussianRawRowsLaw I N))
      exact adaptive_gaussian_rows_reference (J:=Fin N) (P n) _ _ (Z n) (hZ n) (hP n)
        _ ih (u n) (hu n) (hnorm n)

/-- The source entropy of the entire program is exactly the sum of its actual
scalar entropies, multiplied by width. Gaussian residuals cost nothing. -/
theorem gaussianControlHistory_kl {Ω I H : Type} [Fintype I] {N : ℕ}
    [MeasurableSpace Ω] [MeasurableSpace H] [StandardBorelSpace Ω] [StandardBorelSpace H]
    [Nonempty Ω] [Nonempty H]
    (Q P : ℕ→Measure Ω) [∀n,IsProbabilityMeasure (Q n)] [∀n,IsProbabilityMeasure (P n)]
    (μQ μP : Measure H) [IsProbabilityMeasure μQ] [IsProbabilityMeasure μP] (n : ℕ) :
    klDiv (controlHistoryLaw μQ (fun j=>gaussianControlRowLaw (I:=I) N (Q j)) n)
      (controlHistoryLaw μP (fun j=>gaussianControlRowLaw (I:=I) N (P j)) n)=
      klDiv μQ μP + N*(∑j : Fin n,klDiv (Q j) (P j)) := by
  rw [controlHistory_kl]
  simp only [gaussianControlRowLaw,iid_control_kl,product_control_kl,klDiv_self,add_zero]
  rw [Finset.mul_sum]

/-- Actual finite-program entropy after the network-weight pushforward. -/
theorem gaussianHistory_kl {Ω I H Y : Type} [Fintype I] [DecidableEq I] {N : ℕ}
    [MeasurableSpace Ω] [MeasurableSpace H] [MeasurableSpace Y]
    [StandardBorelSpace Ω] [StandardBorelSpace H] [StandardBorelSpace Y]
    [Nonempty Ω] [Nonempty H]
    (Q P : ℕ→Measure Ω) [∀n,IsProbabilityMeasure (Q n)] [∀n,IsProbabilityMeasure (P n)]
    (μQ μP : Measure H) [IsProbabilityMeasure μQ] [IsProbabilityMeasure μP]
    (ν : Measure Y) [IsProbabilityMeasure ν]
    (F : H→Y) (hF : MeasurePreserving F μP ν)
    (Z : ℕ→Ω→ℝ) (hZ : ∀n,Measurable (Z n)) (hP : ∀n,(P n).map (Z n)=gaussianReal 0 1)
    (u : (n : ℕ)→ControlHistory H (GaussianControlRow Ω I N) n→I→ℝ)
    (hu : ∀n,Measurable (u n)) (hnorm : ∀n a,∑i,(u n a i)^2=1) (n : ℕ) :
    klDiv ((controlHistoryLaw μQ (fun j=>gaussianControlRowLaw (I:=I) N (Q j)) n).map
      (gaussianHistoryMap F Z u n))
      (controlHistoryLaw ν (fun _=>gaussianRawRowsLaw I N) n)
      ≤ klDiv μQ μP + N*(∑j : Fin n,klDiv (Q j) (P j)) := by
  have href := gaussianHistory_reference P μP ν F hF Z hZ hP u hu hnorm n
  rw [←href.map_eq]
  exact (NeuralGeneralization.RobustEntropy.klDiv_map_le _ _ href.measurable).trans_eq
    (gaussianControlHistory_kl Q P μQ μP n)

end ConditionalNonpolynomial.Analytic
