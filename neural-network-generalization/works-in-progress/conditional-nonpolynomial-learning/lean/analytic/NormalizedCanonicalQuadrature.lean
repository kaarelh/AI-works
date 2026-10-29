import NormalizedCanonicalRidge
import QuadratureArithmeticBridge

/-! The uniform quadrature theorem instantiated for the actual normalized
Gaussian controlled layer and the actual L² orthonormal basis. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators RealInnerProductSpace ENNReal
namespace ConditionalNonpolynomial.Analytic

variable {d : ℕ} (Q : Measure (Fin d→ℝ)) [IsProbabilityMeasure Q]
variable (V : Submodule ℝ (Lp ℝ 2 Q)) [FiniteDimensional ℝ V]

lemma normalizedCanonicalJoint_measurable {U : ℝ} (S α : ℝ) (hS : S≠0) (hα : α≠0)
    (v : ParameterCube (Fin d) U) :
    AEStronglyMeasurable
      (jointRidge (canonicalBasisValues Q V) (fun z=>gaussianRowNorm z/α)
        (fun z=>S*gaussianRowNorm z) gaussianRowDirection v) Q := by
  let f := normalizedTanhL2 Q S α (WithLp.toLp 2 v.val)
  have hf : Measurable (fun z=>f z) := (Lp.stronglyMeasurable f).measurable
  have he := canonicalBasisValues_measurable Q V
  have hm : Measurable (fun z=>WithLp.toLp 2 (f z • canonicalBasisValues Q V z,(f z)^2)) := by
    fun_prop
  exact hm.aestronglyMeasurable.congr (normalizedCanonicalJoint_ae Q V S α hS hα v).symm

lemma normalizedCanonicalWeight_integrable (α : ℝ)
    (hKL : klDiv Q (Measure.pi fun _ : Fin d=>gaussianReal 0 1)≠∞) :
    Integrable (fun z=>(gaussianRowNorm z/α)^2) Q := by
  simp only [div_pow]
  exact (gaussianRowNorm_sq_integrable Q hKL).div_const _

lemma normalizedCanonicalNormalizer_bound (α : ℝ)
    (hKL : klDiv Q (Measure.pi fun _ : Fin d=>gaussianReal 0 1)≠∞) :
    canonicalNormalizer Q (canonicalBasisValues Q V) (fun z=>gaussianRowNorm z/α) ≤
      1+(Module.finrank ℝ V:ℝ)+
        (2*(d:ℝ)+4*(klDiv Q (Measure.pi fun _ : Fin d=>gaussianReal 0 1)).toReal)/α^2 := by
  unfold canonicalNormalizer
  rw [canonicalBasisValues_norm_sq_integral]
  simp only [div_pow,integral_div]
  have hh := gaussianRowNorm_sq_integral_le Q hKL
  simp only [Fintype.card_fin] at hh
  linarith [div_le_div_of_nonneg_right hh (sq_nonneg α)]

/-- No bounded basis, density regularity, conditioning number, or variance-scale
certificate is assumed. Every observable is the actual Gaussian L² feature. -/
theorem actual_normalized_canonical_quadrature
    (hKL : klDiv Q (Measure.pi fun _ : Fin d=>gaussianReal 0 1)≠∞)
    (S α : ℝ) (hS : S≠0) (hα : α≠0) (U : ℝ) (hU : 0<U)
    (T : ℕ) (hT : 0<T) (δ : ℝ) (hδ : 0<δ) (n : ℕ) (hn : 0<n)
    (hmesh : let Z := canonicalNormalizer Q (canonicalBasisValues Q V) (fun z=>gaussianRowNorm z/α)
      4*(Z*((d+1:ℝ)*(1+2*((d+1:ℝ)*U))))*U≤(T:ℝ)*δ)
    (hbudget : let Z := canonicalNormalizer Q (canonicalBasisValues Q V) (fun z=>gaussianRowNorm z/α)
      1024*(Z*(((d+1:ℝ)*U)+((d+1:ℝ)*U)^2))^2*
        (1+(d:ℝ)*Real.log (2*(T:ℝ)+1))≤(n:ℝ)*δ^2) :
    ∃s:Fin n→(Fin d→ℝ),∀v:ParameterCube (Fin d) U,
      ‖quadratureJointValue Q (canonicalBasisValues Q V) (fun z=>gaussianRowNorm z/α)
          (fun z=>S*gaussianRowNorm z) gaussianRowDirection s v.val-
        WithLp.toLp 2 (projectionCoefficients V (normalizedTanhL2 Q S α (WithLp.toLp 2 v.val)),
          ‖normalizedTanhL2 Q S α (WithLp.toLp 2 v.val)‖^2)‖<δ := by
  have heMeas : Measurable (fun z=>‖canonicalBasisValues Q V z‖^2) :=
    (canonicalBasisValues_measurable Q V).norm.pow_const 2
  have hkMeas : Measurable (fun z=>(gaussianRowNorm z/α)^2) :=
    ((gaussianRowNorm_measurable (I:=Fin d)).div_const α).pow_const 2
  obtain ⟨s,hs⟩ := normalized_ridge_quadrature Q (canonicalBasisValues Q V)
    (fun z=>gaussianRowNorm z/α) (fun z=>S*gaussianRowNorm z) gaussianRowDirection
    heMeas hkMeas (canonicalBasisValues_norm_sq_integrable Q V)
    (normalizedCanonicalWeight_integrable Q α hKL) gaussianRowDirection_bound U hU
    (normalizedCanonicalJoint_measurable Q V S α hS hα) T hT δ hδ n hn
    (by simpa only [Fintype.card_fin] using hmesh)
    (by simpa only [Fintype.card_fin] using hbudget)
  refine ⟨s,?_⟩
  intro v
  have hh := hs v
  rw [normalizedCanonicalJoint_integral Q V S α hS hα v] at hh
  exact hh

#print axioms actual_normalized_canonical_quadrature
#print axioms normalizedCanonicalNormalizer_bound
end ConditionalNonpolynomial.Analytic
