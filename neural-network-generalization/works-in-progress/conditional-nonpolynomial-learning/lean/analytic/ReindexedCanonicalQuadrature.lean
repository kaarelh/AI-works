import NormalizedCanonicalApproximation
import ActualCanonicalLayer

/-! Reindex only the finite arithmetic inputs. The controlled probability law
and its actual L² projection subspace are left unchanged. -/
noncomputable section
set_option maxHeartbeats 3000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory ConditionalAnalytic
open scoped BigOperators RealInnerProductSpace ENNReal
namespace ConditionalNonpolynomial.Analytic
variable {I : Type*} [Fintype I] {d : ℕ}

def reindexedCube (e : Fin d≃I) {U : ℝ} (v : ParameterCube (Fin d) U) : ParameterCube I U :=
  ⟨fun i=>v.val (e.symm i),fun i=>v.property (e.symm i)⟩

def reindexedVector (e : Fin d≃I) : EuclideanSpace ℝ (Fin d) ≃ₗᵢ[ℝ] EuclideanSpace ℝ I :=
  LinearIsometryEquiv.piLpCongrLeft 2 ℝ ℝ e

lemma reindexedVector_cube (e : Fin d≃I) {U : ℝ} (v : ParameterCube (Fin d) U) :
    reindexedVector e (WithLp.toLp 2 v.val)=WithLp.toLp 2 (reindexedCube e v).val := rfl

lemma reindexed_ridgeInput (e : Fin d≃I) (w : I→ℝ) {U : ℝ} (v : ParameterCube (Fin d) U) :
    ridgeInput (fun i=>w (e i)) v=ridgeInput w (reindexedCube e v) := by
  unfold ridgeInput reindexedCube
  simpa only [Equiv.symm_apply_apply] using e.sum_comp (fun i=>w i*v.val (e.symm i))

variable (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (V : Submodule ℝ (Lp ℝ 2 Q)) [FiniteDimensional ℝ V]

lemma reindexedCanonicalJoint (e : Fin d≃I) {U : ℝ} (S α : ℝ)
    (v : ParameterCube (Fin d) U) :
    jointRidge (canonicalBasisValues Q V) (fun z=>gaussianRowNorm z/α)
      (fun z=>S*gaussianRowNorm z) (fun z i=>gaussianRowDirection z (e i)) v =
    jointRidge (canonicalBasisValues Q V) (fun z=>gaussianRowNorm z/α)
      (fun z=>S*gaussianRowNorm z) gaussianRowDirection (reindexedCube e v) := by
  funext z
  unfold jointRidge
  rw [reindexed_ridgeInput]

lemma reindexedCanonicalJoint_measurable (e : Fin d≃I) {U : ℝ} (S α : ℝ)
    (hS : S≠0) (hα : α≠0) (v : ParameterCube (Fin d) U) :
    AEStronglyMeasurable
      (jointRidge (canonicalBasisValues Q V) (fun z=>gaussianRowNorm z/α)
        (fun z=>S*gaussianRowNorm z) (fun z i=>gaussianRowDirection z (e i)) v) Q := by
  rw [reindexedCanonicalJoint]
  let f := normalizedTanhL2 Q S α (WithLp.toLp 2 (reindexedCube e v).val)
  have hf : Measurable (fun z=>f z) := (Lp.stronglyMeasurable f).measurable
  have he := canonicalBasisValues_measurable Q V
  have hm : Measurable (fun z=>WithLp.toLp 2 (f z • canonicalBasisValues Q V z,(f z)^2)) := by
    fun_prop
  exact hm.aestronglyMeasurable.congr (normalizedCanonicalJoint_ae Q V S α hS hα (reindexedCube e v)).symm

lemma reindexedCanonicalNormalizer_bound (e : Fin d≃I) (α : ℝ)
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞) :
    canonicalNormalizer Q (canonicalBasisValues Q V) (fun z=>gaussianRowNorm z/α) ≤
      1+(Module.finrank ℝ V:ℝ)+(2*(d:ℝ)+4*(klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)).toReal)/α^2 := by
  unfold canonicalNormalizer
  rw [canonicalBasisValues_norm_sq_integral]
  simp only [div_pow,integral_div]
  have hh := gaussianRowNorm_sq_integral_le Q hKL
  have hc : Fintype.card I=d := by simpa using (Fintype.card_congr e).symm
  rw [hc] at hh
  linarith [div_le_div_of_nonneg_right hh (sq_nonneg α)]

theorem reindexed_canonical_quadrature (e : Fin d≃I)
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞)
    (S α : ℝ) (hS : S≠0) (hα : α≠0) (U : ℝ) (hU : 0<U)
    (T : ℕ) (hT : 0<T) (δ : ℝ) (hδ : 0<δ) (n : ℕ) (hn : 0<n)
    (hmesh : let Z := canonicalNormalizer Q (canonicalBasisValues Q V) (fun z=>gaussianRowNorm z/α)
      4*(Z*((d+1:ℝ)*(1+2*((d+1:ℝ)*U))))*U≤(T:ℝ)*δ)
    (hbudget : let Z := canonicalNormalizer Q (canonicalBasisValues Q V) (fun z=>gaussianRowNorm z/α)
      1024*(Z*(((d+1:ℝ)*U)+((d+1:ℝ)*U)^2))^2*
        (1+(d:ℝ)*Real.log (2*(T:ℝ)+1))≤(n:ℝ)*δ^2) :
    ∃s:Fin n→(I→ℝ),∀v:ParameterCube (Fin d) U,
      ‖quadratureJointValue Q (canonicalBasisValues Q V) (fun z=>gaussianRowNorm z/α)
          (fun z=>S*gaussianRowNorm z) (fun z i=>gaussianRowDirection z (e i)) s v.val-
        WithLp.toLp 2 (projectionCoefficients V (normalizedTanhL2 Q S α (reindexedVector e (WithLp.toLp 2 v.val))),
          ‖normalizedTanhL2 Q S α (reindexedVector e (WithLp.toLp 2 v.val))‖^2)‖<δ := by
  have heMeas : Measurable (fun z=>‖canonicalBasisValues Q V z‖^2) :=
    (canonicalBasisValues_measurable Q V).norm.pow_const 2
  have hkMeas : Measurable (fun z=>(gaussianRowNorm z/α)^2) :=
    ((gaussianRowNorm_measurable (I:=I)).div_const α).pow_const 2
  have hkInt : Integrable (fun z=>(gaussianRowNorm z/α)^2) Q := by
    simp only [div_pow]
    exact (gaussianRowNorm_sq_integrable Q hKL).div_const _
  obtain ⟨s,hs⟩ := normalized_ridge_quadrature Q (canonicalBasisValues Q V)
    (fun z=>gaussianRowNorm z/α) (fun z=>S*gaussianRowNorm z)
    (fun z i=>gaussianRowDirection z (e i)) heMeas hkMeas
    (canonicalBasisValues_norm_sq_integrable Q V) hkInt (fun z i=>gaussianRowDirection_bound z (e i))
    U hU (reindexedCanonicalJoint_measurable Q V e S α hS hα) T hT δ hδ n hn
    (by simpa only [Fintype.card_fin] using hmesh)
    (by simpa only [Fintype.card_fin] using hbudget)
  refine ⟨s,?_⟩
  intro v
  have hh := hs v
  rw [reindexedCanonicalJoint Q V e S α v,
    normalizedCanonicalJoint_integral Q V S α hS hα (reindexedCube e v)] at hh
  rw [← reindexedCanonicalJoint Q V e S α v] at hh
  rw [reindexedVector_cube]
  exact hh

#print axioms reindexed_canonical_quadrature
end ConditionalNonpolynomial.Analytic
