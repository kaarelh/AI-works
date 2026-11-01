import NeuralGeneralization.BatchTwoContinuousClassification

/-! The manuscript's score-to-sign corollary. Training still uses real scores;
this does not change a regression likelihood into a binary likelihood. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory
namespace NeuralGeneralization.BatchTwoContinuous
open ConcreteModel

def scoreLabel {d : ℕ} (f : RealInput d→ℝ) (x : RealInput d) : Bool :=
  if 0<f x then true else false

theorem regression_fit_has_correct_sign {d N r : ℕ} (φ : ℝ→ℝ) (f : RealInput d→ℝ)
    {τ : ℝ} (hτ : 0≤τ) (w : Weights d N r) (x : RealInput d)
    (hx : τ < |f x|) (hw : |output φ w x-f x|≤τ) :
    0<labelReal (scoreLabel f x)*output φ w x := by
  have hb := abs_le.mp hw
  unfold scoreLabel
  split_ifs with h
  · rw [abs_of_pos h] at hx
    simp only [labelReal_true,one_mul]
    linarith
  · rw [abs_of_nonpos (le_of_not_gt h)] at hx
    simp only [labelReal_false,neg_one_mul]
    linarith

theorem score_to_sign_confidence {d N r : ℕ} (φ : ℝ→ℝ)
    (D : Measure (RealInput d)) [IsFiniteMeasure D]
    (Q : Measure (Weights d N r)) [IsFiniteMeasure Q] (f : RealInput d→ℝ)
    {τ : ℝ} (hτ : 0≤τ) :
    Classification.confidenceFailure φ D Q (scoreLabel f)≤
      confidenceFailure φ D Q f τ+D.real {x | |f x|≤τ} := by
  have hsub : {x | Q.real {w | 0<labelReal (scoreLabel f x)*output φ w x}≤2/3} ⊆
      {x | correctProbability φ Q f τ x≤2/3} ∪ {x | |f x|≤τ} := by
    intro x hx
    change Q.real {w | 0<labelReal (scoreLabel f x)*output φ w x}≤2/3 at hx
    by_cases hz : |f x|≤τ
    · exact Or.inr hz
    · left
      change correctProbability φ Q f τ x≤2/3
      apply le_trans _ hx
      apply measureReal_mono
      · intro w hw
        exact regression_fit_has_correct_sign φ f hτ w x (lt_of_not_ge hz) hw
      · exact measure_ne_top _ _
  unfold Classification.confidenceFailure confidenceFailure
  exact (measureReal_mono hsub).trans (measureReal_union_le _ _)

#print axioms score_to_sign_confidence
end NeuralGeneralization.BatchTwoContinuous
