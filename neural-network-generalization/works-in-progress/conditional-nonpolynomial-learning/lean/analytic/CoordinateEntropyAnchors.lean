import FiniteEnergyAnchors
import NeuralGeneralization.RobustEntropyChain

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal
namespace ConditionalAnalytic
open NeuralGeneralization

variable {X : Type*} [Fintype X] [DecidableEq X]

def maskCoordinates (S : Finset X) (z : X → ℝ) : X → ℝ :=
  fun x => if x∈S then z x else 0

@[fun_prop] theorem measurable_maskCoordinates (S : Finset X) :
    Measurable (maskCoordinates S) := by
  apply measurable_pi_lambda
  intro x
  by_cases hx : x∈S <;> simp only [maskCoordinates,hx,ite_true,ite_false] <;> fun_prop

lemma maskCoordinates_comp {S T : Finset X} (hST : S⊆T) :
    maskCoordinates S ∘ maskCoordinates T = maskCoordinates S := by
  funext z x
  by_cases hx : x∈S
  · simp [maskCoordinates,hx,hST hx]
  · simp [maskCoordinates,hx]

def coordinateEntropy (Q G : Measure (X → ℝ)) (S : Finset X) : ℝ :=
  (klDiv (Q.map (maskCoordinates S)) (G.map (maskCoordinates S))).toReal

theorem coordinateKL_le (Q G : Measure (X → ℝ))
    [IsProbabilityMeasure Q] [IsProbabilityMeasure G] (S : Finset X) :
    klDiv (Q.map (maskCoordinates S)) (G.map (maskCoordinates S)) ≤ klDiv Q G :=
  RobustEntropy.klDiv_map_le Q G (measurable_maskCoordinates S)

theorem coordinateEntropy_le (Q G : Measure (X → ℝ))
    [IsProbabilityMeasure Q] [IsProbabilityMeasure G]
    (hKL : klDiv Q G ≠ ∞) (S : Finset X) :
    coordinateEntropy Q G S ≤ (klDiv Q G).toReal :=
  ENNReal.toReal_mono hKL (coordinateKL_le Q G S)

theorem coordinateEntropy_monotone (Q G : Measure (X → ℝ))
    [IsProbabilityMeasure Q] [IsProbabilityMeasure G]
    (hKL : klDiv Q G ≠ ∞) : Monotone (coordinateEntropy Q G) := by
  intro S T hST
  have hmS := measurable_maskCoordinates S
  have hmT := measurable_maskCoordinates T
  letI : IsProbabilityMeasure (Q.map (maskCoordinates T)) :=
    Measure.isProbabilityMeasure_map hmT.aemeasurable
  letI : IsProbabilityMeasure (G.map (maskCoordinates T)) :=
    Measure.isProbabilityMeasure_map hmT.aemeasurable
  have hh := RobustEntropy.klDiv_map_le (Q.map (maskCoordinates T))
    (G.map (maskCoordinates T)) hmS
  rw [Measure.map_map hmS hmT,Measure.map_map hmS hmT,maskCoordinates_comp hST] at hh
  exact ENNReal.toReal_mono (ne_top_of_le_ne_top hKL (coordinateKL_le Q G T)) hh

/-- For actual finite-KL row laws, one common finite anchor set has small
marginal entropy for every layer and every additional query. -/
theorem actual_entropy_anchors {J : Type*} [Fintype J]
    (Q G : J → Measure (X → ℝ))
    (hQ : ∀ j,IsProbabilityMeasure (Q j)) (hG : ∀ j,IsProbabilityMeasure (G j))
    (hKL : ∀ j,klDiv (Q j) (G j) ≠ ∞)
    (δ : J → ℝ) (hδ : ∀ j,0<δ j) :
    ∃ S : Finset X, (S.card:ℝ)≤∑ j,(klDiv (Q j) (G j)).toReal/δ j ∧
      ∀ j x,coordinateEntropy (Q j) (G j) (insert x S)-coordinateEntropy (Q j) (G j) S≤δ j := by
  apply finite_multi_energy_anchors (fun j => coordinateEntropy (Q j) (G j)) δ
    (fun j => (klDiv (Q j) (G j)).toReal) hδ
  · intro j
    exact ENNReal.toReal_nonneg
  · intro j S
    letI := hQ j
    letI := hG j
    exact coordinateEntropy_le (Q j) (G j) (hKL j) S
  · intro j
    letI := hQ j
    letI := hG j
    exact coordinateEntropy_monotone (Q j) (G j) (hKL j)

#print axioms actual_entropy_anchors
end ConditionalAnalytic
