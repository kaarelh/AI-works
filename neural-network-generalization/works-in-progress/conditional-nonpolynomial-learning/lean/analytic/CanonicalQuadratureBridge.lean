import ActualCanonicalLayer
import CanonicalCompletion
import CanonicalRidgeQuadrature
import Mathlib.MeasureTheory.SpecificCodomains.WithLp

noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators RealInnerProductSpace
open MeasureTheory ConditionalAnalytic
namespace ConditionalNonpolynomial.Analytic

variable {ι : Type*} [Fintype ι]

/-- Identifies the product-valued completion used by quadrature with the actual
canonical layer's retained coordinates and residual-norm coordinate. -/
def completionToVector : WithLp 2 (EuclideanSpace ℝ ι × ℝ) →ₗᵢ[ℝ]
    EuclideanSpace ℝ (ι ⊕ Unit) where
  toFun z := WithLp.toLp 2 (Sum.elim (fun i => z.ofLp.1 i) (fun _ => z.ofLp.2))
  map_add' x y := by ext i; cases i <;> rfl
  map_smul' c x := by ext i; cases i <;> rfl
  norm_map' z := by
    apply (sq_eq_sq₀ (norm_nonneg _) (norm_nonneg _)).mp
    rw [EuclideanSpace.real_norm_sq_eq, WithLp.prod_norm_sq_eq_of_L2]
    simp only [WithLp.ofLp_toLp, Fintype.sum_sum_type, Sum.elim_inl, Sum.elim_inr,
      Fintype.sum_unique, Real.norm_eq_abs, sq_abs, EuclideanSpace.real_norm_sq_eq]
    rfl

section Abstract
variable {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℝ H]
    [CompleteSpace H] (V : Submodule ℝ H) [FiniteDimensional ℝ V]

def projectionCoefficients (f : H) : EuclideanSpace ℝ (Fin (Module.finrank ℝ V)) :=
  WithLp.toLp 2 (fun i => ⟪((stdOrthonormalBasis ℝ V i : V) : H), f⟫)

lemma projectionCoefficients_norm_sq (f : H) :
    ‖projectionCoefficients V f‖^2 = ‖V.starProjection f‖^2 := by
  rw [EuclideanSpace.real_norm_sq_eq, projection_norm_sq_basis]
  rfl

lemma canonicalVector_eq_completion (f : H) :
    canonicalVector V f = completionToVector
      (canonicalCompletion (projectionCoefficients V f) (‖f‖^2)) := by
  have hpy := Submodule.norm_sq_eq_add_norm_sq_starProjection f V
  have hres : ‖f‖^2-‖projectionCoefficients V f‖^2 = ‖Vᗮ.starProjection f‖^2 := by
    rw [projectionCoefficients_norm_sq]
    linarith
  ext i
  cases i with
  | inl j => rfl
  | inr u =>
      simp only [canonicalVector, completionToVector, LinearIsometry.coe_mk,
        LinearMap.coe_mk, AddHom.coe_mk, canonicalCompletion, WithLp.ofLp_toLp,
        Sum.elim_inr, hres, max_eq_right (sq_nonneg _), Real.sqrt_sq (norm_nonneg _)]

lemma canonicalVector_smul_nonneg (f : H) {c : ℝ} (hc : 0 ≤ c) :
    canonicalVector V (c • f) = c • canonicalVector V f := by
  ext i
  cases i <;> simp [canonicalVector, inner_smul_right, map_smul,
    norm_smul, Real.norm_eq_abs, abs_of_nonneg hc]

end Abstract

section L2
variable {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω)
    (V : Submodule ℝ (Lp ℝ 2 μ)) [FiniteDimensional ℝ V]

/-- Actual measurable representatives of an orthonormal basis in the retained
L² span. They are not assumed bounded. -/
def canonicalBasisValues (x : Ω) : EuclideanSpace ℝ (Fin (Module.finrank ℝ V)) :=
  WithLp.toLp 2 (fun i => (((stdOrthonormalBasis ℝ V i : V) : Lp ℝ 2 μ) x))

lemma canonicalBasisValues_measurable : Measurable (canonicalBasisValues μ V) := by
  apply (PiLp.continuous_toLp 2 _).measurable.comp
  exact measurable_pi_lambda _ (fun i => (Lp.stronglyMeasurable _).measurable)

lemma canonicalBasisValues_norm_sq_integrable :
    Integrable (fun x => ‖canonicalBasisValues μ V x‖^2) μ := by
  simp only [EuclideanSpace.real_norm_sq_eq, canonicalBasisValues, WithLp.ofLp_toLp]
  exact integrable_finset_sum _ (fun i _ => (Lp.memLp _).integrable_sq)

lemma canonicalBasisValues_norm_sq_integral :
    (∫ x, ‖canonicalBasisValues μ V x‖^2 ∂μ) = Module.finrank ℝ V := by
  simp only [EuclideanSpace.real_norm_sq_eq, canonicalBasisValues, WithLp.ofLp_toLp]
  rw [integral_finset_sum _ (fun i _ => (Lp.memLp _).integrable_sq)]
  have heach (i : Fin (Module.finrank ℝ V)) :
      (∫ x, (((stdOrthonormalBasis ℝ V i : V) : Lp ℝ 2 μ) x)^2 ∂μ) = 1 := by
    have heq := real_inner_self_eq_norm_sq ((stdOrthonormalBasis ℝ V i : V) : Lp ℝ 2 μ)
    rw [L2.inner_def] at heq
    have hn : ‖((stdOrthonormalBasis ℝ V i : V) : Lp ℝ 2 μ)‖ = 1 :=
      (stdOrthonormalBasis ℝ V).norm_eq_one i
    simpa only [Real.inner_apply, ← pow_two, hn, one_pow] using heq
  simp only [heach, Finset.sum_const, Finset.card_univ, Fintype.card_fin,
    nsmul_eq_mul, mul_one, Nat.cast_id]

lemma canonicalProjection_integrable (f : Lp ℝ 2 μ) :
    Integrable (fun x => f x • canonicalBasisValues μ V x) μ := by
  apply Integrable.of_eval_piLp
  intro i
  simpa only [canonicalBasisValues, WithLp.ofLp_smul, WithLp.ofLp_toLp,
    Pi.smul_apply, smul_eq_mul, Real.inner_apply, mul_comm] using
    L2.integrable_inner (𝕜 := ℝ) ((stdOrthonormalBasis ℝ V i : V) : Lp ℝ 2 μ) f

lemma projectionCoefficients_eq_integral (f : Lp ℝ 2 μ) :
    projectionCoefficients V f = ∫ x, f x • canonicalBasisValues μ V x ∂μ := by
  ext i
  rw [eval_integral_piLp (fun j => (canonicalProjection_integrable μ V f).eval_piLp j)]
  change ⟪((stdOrthonormalBasis ℝ V i : V) : Lp ℝ 2 μ),f⟫ = _
  rw [L2.inner_def]
  rfl

lemma l2_norm_sq_eq_integral (f : Lp ℝ 2 μ) :
    ‖f‖^2 = ∫ x, (f x)^2 ∂μ := by
  rw [← real_inner_self_eq_norm_sq, L2.inner_def]
  simp only [Real.inner_apply, pow_two]

/-- The joint moments in finite quadrature are precisely the retained L²
projection and the full squared norm, for the actual feature function. -/
lemma canonicalJointMoment_eq (f : Lp ℝ 2 μ) :
    (∫ x, WithLp.toLp 2 (f x • canonicalBasisValues μ V x, (f x)^2) ∂μ) =
      WithLp.toLp 2 (projectionCoefficients V f, ‖f‖^2) := by
  have hi : Integrable (fun x => WithLp.toLp 2
      (f x • canonicalBasisValues μ V x, (f x)^2)) μ := by
    exact Integrable.of_fst_of_snd_prodLp
      ⟨canonicalProjection_integrable μ V f, (Lp.memLp f).integrable_sq⟩
  apply WithLp.ofLp_injective 2
  apply Prod.ext
  · exact (fst_integral_withLp hi).trans (projectionCoefficients_eq_integral μ V f).symm
  · exact (snd_integral_withLp hi).trans (l2_norm_sq_eq_integral μ f).symm

#print axioms canonicalVector_eq_completion
#print axioms canonicalBasisValues_norm_sq_integral
#print axioms canonicalJointMoment_eq
end L2
end ConditionalNonpolynomial.Analytic
