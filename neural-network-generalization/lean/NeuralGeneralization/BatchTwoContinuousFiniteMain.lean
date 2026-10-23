import NeuralGeneralization.BatchTwoContinuousFiniteMeanFieldMain
import NeuralGeneralization.BatchTwoContinuousAboveMain

/-! The complete literal finite-scale continuous-domain regression main theorem,
including the critical mean-field exponent and every supercritical exponent. -/
noncomputable section
namespace NeuralGeneralization.BatchTwoContinuous

theorem finiteScaleRegression : FiniteScaleRegression := by
  intro r ν γ hγ
  rcases hγ.eq_or_lt with he | hgt
  · subst γ
    exact FiniteMeanField.meanField r ν
  · exact Above.aboveMeanField r ν γ hgt

#print axioms finiteScaleRegression
end NeuralGeneralization.BatchTwoContinuous
