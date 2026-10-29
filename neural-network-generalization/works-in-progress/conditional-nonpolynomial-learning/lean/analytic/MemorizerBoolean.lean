import WalshPointExceptions
import NeuralGeneralization.Network

noncomputable section
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization NeuralGeneralization.ConcreteModel

def pointExceptionBoolean {d : ℕ} (A : Finset (ClippingCube d)) (x : ClippingCube d) : Bool :=
  if x ∈ A then false else true

theorem pointExceptionBoolean_label {d : ℕ} (A : Finset (ClippingCube d)) (x : ClippingCube d) :
    labelReal (pointExceptionBoolean A x)=pointExceptionFunction A x := by
  classical
  by_cases hx : x ∈ A <;> simp [pointExceptionBoolean,pointExceptionFunction,labelReal,hx]

theorem pointExceptionBoolean_fits_sample {d n : ℕ} (sample : Fin n → ClippingCube d)
    (f : ClippingCube d → Bool) (i : Fin n) :
    pointExceptionBoolean (negativeSamplePoints sample f) (sample i)=f (sample i) := by
  have hh := pointExceptionFunction_fits_sample sample f i
  rw [← pointExceptionBoolean_label] at hh
  have he (b : Bool) : cubeCoordinateSign b=labelReal b := by cases b <;> rfl
  rw [he] at hh
  cases h₁ : pointExceptionBoolean (negativeSamplePoints sample f) (sample i) <;>
    cases h₂ : f (sample i)
  all_goals first | rfl | norm_num [h₁,h₂,labelReal] at hh

end ConditionalNonpolynomial.Analytic
