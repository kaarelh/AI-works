import NeuralGeneralization.GaussianFieldTilt
import Mathlib.Analysis.Matrix.PosDef

/-! Every actual finite second-moment matrix has a finite Gaussian Gram
representation, including singular matrices. -/
noncomputable section
open MeasureTheory ProbabilityTheory Matrix
open scoped BigOperators
namespace NeuralGeneralization.CovarianceFactor
open GaussianAngularPrice GaussianFieldTilt TanhDifferential
variable {I Ω : Type*} [Fintype I] [DecidableEq I] [MeasurableSpace Ω]

def covariance (μ : Measure Ω) (h : I → Ω → ℝ) : Matrix I I ℝ :=
  fun i j => ∫ z, h i z * h j z ∂μ

theorem covariance_posSemidef (μ : Measure Ω) (h : I → Ω → ℝ)
    (hint : ∀ i j, Integrable (fun z => h i z * h j z) μ) :
    (covariance μ h).PosSemidef := by
  apply Matrix.PosSemidef.of_dotProduct_mulVec_nonneg
  · apply Matrix.IsHermitian.ext_iff.mpr
    intro i j
    simp only [star_trivial, covariance, mul_comm]
  intro c
  have heq (z : Ω) : (∑ i, c i * h i z) ^ 2 =
      ∑ i, ∑ j, c i * (h i z * h j z) * c j := by
    rw [pow_two, Finset.sum_mul]
    apply Finset.sum_congr rfl
    intro i hi
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro j hj
    ring
  have hident : (∫ z, (∑ i, c i * h i z) ^ 2 ∂μ) =
      star c ⬝ᵥ (covariance μ h *ᵥ c) := by
    simp_rw [heq]
    rw [integral_finsetSum Finset.univ (fun i _ =>
      integrable_finsetSum Finset.univ (fun j _ => ((hint i j).const_mul (c i)).mul_const (c j)))]
    simp only [dotProduct, Matrix.mulVec, star_trivial, Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro i hi
    rw [integral_finsetSum Finset.univ (fun j _ => ((hint i j).const_mul (c i)).mul_const (c j))]
    apply Finset.sum_congr rfl
    intro j hj
    rw [integral_mul_const, integral_const_mul]
    dsimp only [covariance]
    ring
  rw [← hident]
  exact integral_nonneg (fun z => sq_nonneg _)

omit [MeasurableSpace Ω] in
/-- Square roots of the nonnegative eigenvalues give an explicit finite Gram
factor. Zero eigenvalues require no regularization or inverse. -/
theorem exists_gram_factor (Q : Matrix I I ℝ) (hQ : Q.PosSemidef) :
    ∃ A : I → I → ℝ, ∀ i j, gram A i j = Q i j := by
  let U : Matrix I I ℝ := hQ.1.eigenvectorUnitary
  let a := hQ.1.eigenvalues
  refine ⟨fun i j => U i j * Real.sqrt (a j), ?_⟩
  intro i j
  have hs : Q = U * Matrix.diagonal a * star U := by
    simpa only [Unitary.conjStarAlgAut_apply, RCLike.ofReal_real_eq_id, Function.comp_def, id_eq]
      using hQ.1.spectral_theorem
  have hentry : Q i j = ∑ k, (U i k * a k) * U j k := by
    rw [hs, Matrix.mul_apply]
    simp only [Matrix.mul_diagonal, Matrix.star_apply, star_trivial]
  rw [hentry]
  apply Finset.sum_congr rfl
  intro k hk
  have hsq : Real.sqrt (a k) ^ 2 = a k := Real.sq_sqrt (hQ.eigenvalues_nonneg k)
  dsimp only
  calc
    U i k * Real.sqrt (a k) * (U j k * Real.sqrt (a k)) =
        (U i k * U j k) * Real.sqrt (a k) ^ 2 := by ring
    _ = _ := by rw [hsq]; ring

theorem covariance_has_gram_factor (μ : Measure Ω) (h : I → Ω → ℝ)
    (hint : ∀ i j, Integrable (fun z => h i z * h j z) μ) :
    ∃ A : I → I → ℝ, ∀ i j, gram A i j = ∫ z, h i z * h j z ∂μ :=
  exists_gram_factor (covariance μ h) (covariance_posSemidef μ h hint)

variable {J : Type*} [Fintype J]

omit [MeasurableSpace Ω] in
theorem gram_has_square_factor (A : I → J → ℝ) :
    ∃ B : I → I → ℝ, ∀ p q, gram B p q = gram A p q := by
  let M : Matrix I J ℝ := Matrix.of A
  have h := exists_gram_factor (M * M.conjTranspose)
    (Matrix.posSemidef_self_mul_conjTranspose M)
  simpa only [GaussianAngularPrice.gram, Matrix.mul_apply, Matrix.conjTranspose_apply,
    star_trivial, M, Matrix.of_apply] using h

omit [MeasurableSpace Ω] in
/-- Every actual tilted Gaussian tanh covariance has a finite Gaussian field
representation. This supplies the next ideal stage of a tilted covariance tower. -/
theorem tiltedMoment_has_gram_factor (A : I → J → ℝ) (Γ : I → I → ℝ) :
    ∃ B : I → I → ℝ, ∀ p q, gram B p q = tiltedMoment A Γ p q := by
  let V := potentialValue Real.tanh Γ
  let μ := (fieldLaw A).tilted V
  have hVmeas : Measurable V := (continuous_tanhPotentialValue Γ).measurable
  have hVbound : ∀ z, |V z| ≤ couplingMass Γ :=
    abs_potentialValue_le_mass _ (fun x => (Real.abs_tanh_lt_one x).le) Γ
  letI : IsProbabilityMeasure μ := BoundedTilt.tilted_probability (fieldLaw A) V hVmeas hVbound
  have hint (i j : I) : Integrable (fun z : I → ℝ => Real.tanh (z i) * Real.tanh (z j)) μ := by
    apply (integrable_const (1 : ℝ)).mono' (by fun_prop)
    apply ae_of_all
    intro z
    rw [Real.norm_eq_abs]
    exact abs_pairValue_le_one _ (fun x => (Real.abs_tanh_lt_one x).le) i j z
  exact covariance_has_gram_factor μ (fun i z => Real.tanh (z i)) hint

end NeuralGeneralization.CovarianceFactor
end
