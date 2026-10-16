import NeuralGeneralization.CovarianceFactor
import NeuralGeneralization.GaussianFieldCovariance

/-! # Actual Gaussian marginal decomposition from a covariance floor -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.GaussianAmplitude
open FiniteDifferential GaussianAngularFields GaussianAngularPrice GaussianFieldTilt

variable {I J : Type*} [Fintype I] [Fintype J] [DecidableEq I]

/-- Appending an independent isotropic noise block adds its variance to the
actual covariance diagonal. -/
theorem gram_noise_append (B : I → J → ℝ) (σ : ℝ) (i j : I) :
    gram (fun i => Sum.elim (B i) (fun k : I => if i=k then σ else 0)) i j =
      gram B i j + if i=j then σ^2 else 0 := by
  classical
  simp only [gram, Fintype.sum_sum_type, Sum.elim_inl, Sum.elim_inr]
  congr 1
  by_cases hij : i=j
  · subst j
    simp [pow_two]
  · simp [hij]

/-- A concrete sum of independent Gaussian blocks has the law of its appended
coefficient matrix, including when the residual covariance is singular. -/
theorem noise_product_map (B : I → J → ℝ) (σ : ℝ) :
    ((standardLaw J).prod (standardLaw I)).map
      (fun x : (J → ℝ) × (I → ℝ) => fun i => fieldLinear B x.1 i+σ*x.2 i) =
    fieldLaw (fun i => Sum.elim (B i) (fun k : I => if i=k then σ else 0)) := by
  classical
  let e := MeasurableEquiv.sumPiEquivProdPi (fun _ : J ⊕ I => ℝ)
  let F : (J → ℝ) × (I → ℝ) → (I → ℝ) :=
    fun x i => fieldLinear B x.1 i+σ*x.2 i
  have hF : Measurable F := by unfold F; fun_prop
  have he : (standardLaw (J ⊕ I)).map e = (standardLaw J).prod (standardLaw I) :=
    (measurePreserving_sumPiEquivProdPi
      (fun _ : J ⊕ I => gaussianReal (0:ℝ) (1:ℝ≥0))).map_eq
  change ((standardLaw J).prod (standardLaw I)).map F = _
  rw [← he, Measure.map_map hF e.measurable]
  unfold fieldLaw
  congr 1
  funext z i
  simp [F, fieldLinear_apply, Fintype.sum_sum_type, e,
    MeasurableEquiv.coe_sumPiEquivProdPi]

/-- An actual centered finite Gaussian field with a positive covariance floor
can be represented as a residual Gaussian field plus independent scalar noise. -/
theorem exists_noise_representation (A : I → J → ℝ) (σ : ℝ)
    (hfloor : Matrix.PosSemidef (fun i j => gram A i j-(if i=j then σ^2 else 0))) :
    ∃ B : I → I → ℝ,
      ((standardLaw I).prod (standardLaw I)).map
        (fun x : (I → ℝ) × (I → ℝ) => fun i => fieldLinear B x.1 i+σ*x.2 i) =
      fieldLaw A := by
  obtain ⟨B,hB⟩ := CovarianceFactor.exists_gram_factor _ hfloor
  refine ⟨B, ?_⟩
  rw [noise_product_map]
  apply GaussianFieldCovariance.fieldLaw_eq_of_gram_eq
  intro i j
  rw [gram_noise_append, hB]
  exact sub_add_cancel _ _

end NeuralGeneralization.GaussianAmplitude
