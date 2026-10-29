import IndependentControlEntropy
import AdaptiveGaussianEntropy

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators NNReal ENNReal
namespace ConditionalNonpolynomial.Analytic

/-- The auxiliary history retains every score and noise variable; only the
final deterministic pushforward forgets them. -/
def ControlHistory (H R : Type) : ℕ→Type
  | 0 => H
  | n+1 => ControlHistory H R n × R

instance controlHistoryMeasurable (H R : Type) [MeasurableSpace H] [MeasurableSpace R] :
    (n : ℕ)→MeasurableSpace (ControlHistory H R n)
  | 0 => inferInstanceAs (MeasurableSpace H)
  | n+1 => by
      change MeasurableSpace (ControlHistory H R n × R)
      letI := controlHistoryMeasurable H R n
      infer_instance

instance controlHistoryStandardBorel (H R : Type)
    [MeasurableSpace H] [MeasurableSpace R] [StandardBorelSpace H] [StandardBorelSpace R] :
    (n : ℕ)→StandardBorelSpace (ControlHistory H R n)
  | 0 => inferInstanceAs (StandardBorelSpace H)
  | n+1 => by
      change StandardBorelSpace (ControlHistory H R n × R)
      letI := controlHistoryStandardBorel H R n
      infer_instance

instance controlHistoryNonempty (H R : Type) [Nonempty H] [Nonempty R] :
    (n : ℕ)→Nonempty (ControlHistory H R n)
  | 0 => inferInstanceAs (Nonempty H)
  | n+1 => by
      change Nonempty (ControlHistory H R n × R)
      letI := controlHistoryNonempty H R n
      infer_instance

def controlHistoryLaw {H R : Type} [MeasurableSpace H] [MeasurableSpace R]
    (μ : Measure H) (ρ : ℕ→Measure R) : (n : ℕ)→Measure (ControlHistory H R n)
  | 0 => μ
  | n+1 => (controlHistoryLaw μ ρ n).prod (ρ n)

instance controlHistoryLaw_probability {H R : Type} [MeasurableSpace H] [MeasurableSpace R]
    (μ : Measure H) (ρ : ℕ→Measure R) [IsProbabilityMeasure μ] [∀n,IsProbabilityMeasure (ρ n)] :
    (n : ℕ)→IsProbabilityMeasure (controlHistoryLaw μ ρ n)
  | 0 => inferInstanceAs (IsProbabilityMeasure μ)
  | n+1 => by
      change IsProbabilityMeasure ((controlHistoryLaw μ ρ n).prod (ρ n))
      letI := controlHistoryLaw_probability μ ρ n
      infer_instance

attribute [reducible] ControlHistory

/-- Exact entropy additivity for an entire finite control program. -/
theorem controlHistory_kl {H R : Type}
    [MeasurableSpace H] [MeasurableSpace R] [StandardBorelSpace H] [StandardBorelSpace R]
    [Nonempty H] [Nonempty R]
    (μQ μP : Measure H) (ρQ ρP : ℕ→Measure R)
    [IsProbabilityMeasure μQ] [IsProbabilityMeasure μP]
    [∀n,IsProbabilityMeasure (ρQ n)] [∀n,IsProbabilityMeasure (ρP n)] (n : ℕ) :
    klDiv (controlHistoryLaw μQ ρQ n) (controlHistoryLaw μP ρP n)=
      klDiv μQ μP + ∑j : Fin n,klDiv (ρQ j) (ρP j) := by
  induction n with
  | zero =>
      change klDiv μQ μP = klDiv μQ μP + ∑j : Fin 0, klDiv (ρQ j) (ρP j)
      simp
  | succ n ih =>
      change klDiv ((controlHistoryLaw μQ ρQ n).prod (ρQ n))
        ((controlHistoryLaw μP ρP n).prod (ρP n)) = _
      rw [product_control_kl,ih,Fin.sum_univ_castSucc]
      simp only [Fin.val_castSucc,Fin.val_last]
      exact add_assoc _ _ _

end ConditionalNonpolynomial.Analytic
