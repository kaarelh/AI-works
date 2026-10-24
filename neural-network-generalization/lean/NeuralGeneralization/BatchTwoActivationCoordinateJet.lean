import NeuralGeneralization.BatchTwoActivationBoundedJet

/-! Coordinate observables for an actual bounded scalar C² function. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open FiniteDifferential TanhDifferential
variable {I : Type*} [Fintype I] [DecidableEq I]

def coordinateFirst (ψ' : ℝ→ℝ) (p : I) (z : I→ℝ) (i : I) : ℝ :=
  coordinateIndicator p i*ψ' (z p)

def coordinateSecond (ψ'' : ℝ→ℝ) (p : I) (z : I→ℝ) (i j : I) : ℝ :=
  coordinateIndicator p i*coordinateIndicator p j*ψ'' (z p)

theorem coordinate_derivative (ψ ψ' : ℝ→ℝ) (hψ : ∀t,HasDerivAt ψ (ψ' t) t)
    (p : I) (z : I→ℝ) : HasFDerivAt (fun y=>ψ (y p))
      (gradientLinear (coordinateFirst ψ' p z)) z := by
  apply ((hψ (z p)).comp_hasFDerivAt z
    (ContinuousLinearMap.proj p : (I→ℝ)→L[ℝ] ℝ).hasFDerivAt).congr_fderiv
  ext v
  simp [coordinateFirst,coordinateIndicator,gradientLinear_apply,ite_mul]

theorem coordinateFirst_derivative (ψ' ψ'' : ℝ→ℝ) (hψ' : ∀t,HasDerivAt ψ' (ψ'' t) t)
    (p : I) (z : I→ℝ) (i : I) : HasFDerivAt (fun y=>coordinateFirst ψ' p y i)
      (gradientLinear (coordinateSecond ψ'' p z i)) z := by
  apply ((coordinate_derivative ψ' ψ'' hψ' p z).const_mul (coordinateIndicator p i)).congr_fderiv
  ext v
  simp only [smul_apply,smul_eq_mul,gradientLinear_apply,coordinateFirst,coordinateSecond,
    Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j hj
  ring

def coordinateJet (ψ ψ' ψ'' : ℝ→ℝ) {B₀ B₁ B₂ : ℝ}
    (hψ : ∀t,HasDerivAt ψ (ψ' t) t) (hψ' : ∀t,HasDerivAt ψ' (ψ'' t) t)
    (hc : Continuous ψ'') (hb₀ : ∀t,|ψ t|≤B₀)
    (hb₁ : ∀t,|ψ' t|≤B₁) (hb₂ : ∀t,|ψ'' t|≤B₂) (p : I) :
    BoundedJet I B₀ B₁ B₂ where
  value := fun z=>ψ (z p)
  grad := coordinateFirst ψ' p
  hess := coordinateSecond ψ'' p
  derivative := coordinate_derivative ψ ψ' hψ p
  grad_derivative := coordinateFirst_derivative ψ' ψ'' hψ' p
  hess_continuous := fun i j=>by unfold coordinateSecond; fun_prop
  value_bound := fun z=>hb₀ _
  grad_bound := fun z=>by
    simpa only [coordinateFirst,abs_mul,abs_coordinateIndicator,←Finset.sum_mul,
      sum_coordinateIndicator,one_mul] using hb₁ (z p)
  hess_bound := fun z=>by
    simpa only [coordinateSecond,abs_mul,abs_coordinateIndicator,←Finset.mul_sum,
      ←Finset.sum_mul,sum_coordinateIndicator,mul_one,one_mul] using hb₂ (z p)

end NeuralGeneralization.BatchTwoActivation
