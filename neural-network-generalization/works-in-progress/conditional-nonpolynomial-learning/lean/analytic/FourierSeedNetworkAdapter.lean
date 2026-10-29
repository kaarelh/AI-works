import InitialSeedMoments
import GaussianFourierSeedKL

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization NeuralGeneralization.ConcreteModel

def optionInputWeights {d : ℕ} (w : Option (Fin d)→ℝ) : Fin (d+1)→ℝ :=
  fun j=>w (finSuccEquiv' (0 : Fin (d+1)) j)

theorem optionInputWeights_measurable {d : ℕ} :
    Measurable (optionInputWeights (d:=d)) := by unfold optionInputWeights; fun_prop

theorem optionInputWeights_gaussian {d : ℕ} (v : ℝ≥0) :
    MeasurePreserving (optionInputWeights (d:=d))
      (Measure.pi fun _ : Option (Fin d)=>gaussianReal 0 v)
      (Measure.pi fun _ : Fin (d+1)=>gaussianReal 0 v) := by
  exact (measurePreserving_piCongrLeft (fun _ : Option (Fin d)=>gaussianReal 0 v)
    (finSuccEquiv' (0 : Fin (d+1)))).symm

theorem seedFeature_optionInputWeights {d : ℕ} (x : Cube d) (w : Option (Fin d)→ℝ) :
    seedFeature optionInputWeights x w=tanhCubeFeature w x := by
  unfold seedFeature tanhCubeFeature
  congr 1
  rw [Fin.sum_univ_succ]
  simp only [optionInputWeights,finSuccEquiv'_at,inputVector,Fin.cases_zero,mul_one,
    Fin.cases_succ]
  congr 1

def taggedSeedInput {d : ℕ} (p : Bool×(Option (Fin d)→ℝ)) : Fin (d+1)→ℝ :=
  optionInputWeights p.2

theorem taggedSeedInput_measurable {d : ℕ} :
    Measurable (taggedSeedInput (d:=d)) := optionInputWeights_measurable.comp measurable_snd

theorem taggedSeedInput_reference {d : ℕ} (θ : ℝ) (hθ0 : 0≤θ) (hθ1 : θ≤1) (v : ℝ≥0) :
    (rareSeedLaw θ (Measure.pi fun _ : Option (Fin d)=>gaussianReal 0 v)
      (Measure.pi fun _ : Option (Fin d)=>gaussianReal 0 v)).map taggedSeedInput=
      Measure.pi fun _ : Fin (d+1)=>gaussianReal 0 v := by
  change Measure.map (optionInputWeights ∘ Prod.snd) _=_
  rw [←Measure.map_map optionInputWeights_measurable measurable_snd]
  have hh : (rareSeedLaw θ (Measure.pi fun _ : Option (Fin d)=>gaussianReal 0 v)
      (Measure.pi fun _ : Option (Fin d)=>gaussianReal 0 v)).map Prod.snd=
      Measure.pi fun _ : Option (Fin d)=>gaussianReal 0 v :=
    rareSeedLaw_reference_snd θ _ hθ0 hθ1
  rw [hh,(optionInputWeights_gaussian v).map_eq]

theorem seedFeature_taggedSeedInput {d : ℕ} (x : Cube d) (p : Bool×(Option (Fin d)→ℝ)) :
    seedFeature taggedSeedInput x p=tanhCubeFeature p.2 x :=
  seedFeature_optionInputWeights x p.2

#print axioms taggedSeedInput_reference
#print axioms seedFeature_taggedSeedInput
end ConditionalNonpolynomial.Analytic
