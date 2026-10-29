import GaussianOrthogonalReplacement
import FeatureGramGluing
import Mathlib.Analysis.Normed.Lp.MeasurableSpace

noncomputable section
set_option maxHeartbeats 1500000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators RealInnerProductSpace NNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.FiniteDifferential NeuralGeneralization.GaussianAngularFields
open NeuralGeneralization.GaussianAngularPrice NeuralGeneralization.GaussianFieldTilt

variable {I X : Type*} [Fintype I] [Fintype X]

def subspaceCoordinateMatrix (K : Submodule ℝ (EuclideanSpace ℝ I)) :
    Fin (Module.finrank ℝ K)→I→ℝ :=
  fun j i=>((stdOrthonormalBasis ℝ K j : K) : EuclideanSpace ℝ I) i

def splitSubspaceBasis (K : Submodule ℝ (EuclideanSpace ℝ I)) :
    OrthonormalBasis (Fin (Module.finrank ℝ K)⊕Fin (Module.finrank ℝ Kᗮ))
      ℝ (EuclideanSpace ℝ I) :=
  ((stdOrthonormalBasis ℝ K).prod (stdOrthonormalBasis ℝ Kᗮ)).map
    K.orthogonalDecomposition.symm

@[simp] theorem splitSubspaceBasis_left (K : Submodule ℝ (EuclideanSpace ℝ I))
    (j : Fin (Module.finrank ℝ K)) :
    splitSubspaceBasis K (.inl j)=((stdOrthonormalBasis ℝ K j : K) : EuclideanSpace ℝ I) := by
  simp [splitSubspaceBasis,OrthonormalBasis.prod_apply]

@[simp] theorem splitSubspaceBasis_right (K : Submodule ℝ (EuclideanSpace ℝ I))
    (j : Fin (Module.finrank ℝ Kᗮ)) :
    splitSubspaceBasis K (.inr j)=((stdOrthonormalBasis ℝ Kᗮ j : Kᗮ) : EuclideanSpace ℝ I) := by
  simp [splitSubspaceBasis,OrthonormalBasis.prod_apply]

def subspaceSplitEquiv (K : Submodule ℝ (EuclideanSpace ℝ I)) :
    (I→ℝ)≃ᵐ((Fin (Module.finrank ℝ K)→ℝ)×(Fin (Module.finrank ℝ Kᗮ)→ℝ)) :=
  (MeasurableEquiv.toLp 2 (I→ℝ)).trans
    ((splitSubspaceBasis K).repr.toHomeomorph.toMeasurableEquiv.trans
      ((MeasurableEquiv.toLp 2 ((Fin (Module.finrank ℝ K)⊕Fin (Module.finrank ℝ Kᗮ))→ℝ)).symm.trans
        (MeasurableEquiv.sumPiEquivProdPi (fun _ : Fin (Module.finrank ℝ K)⊕Fin (Module.finrank ℝ Kᗮ)=>ℝ))))

theorem subspaceSplitEquiv_apply (K : Submodule ℝ (EuclideanSpace ℝ I)) (z : I→ℝ) :
    subspaceSplitEquiv K z=
      (fieldLinear (subspaceCoordinateMatrix K) z,fieldLinear (subspaceCoordinateMatrix Kᗮ) z) := by
  apply Prod.ext <;> funext j
  · change ((splitSubspaceBasis K).repr (WithLp.toLp 2 z)) (.inl j)=_
    rw [OrthonormalBasis.repr_apply_apply,splitSubspaceBasis_left]
    simp only [fieldLinear_apply,subspaceCoordinateMatrix,PiLp.inner_apply,WithLp.ofLp_toLp,Real.inner_apply,mul_comm]
  · change ((splitSubspaceBasis K).repr (WithLp.toLp 2 z)) (.inr j)=_
    rw [OrthonormalBasis.repr_apply_apply,splitSubspaceBasis_right]
    simp only [fieldLinear_apply,subspaceCoordinateMatrix,PiLp.inner_apply,WithLp.ofLp_toLp,Real.inner_apply,mul_comm]

theorem subspaceSplitEquiv_standard (K : Submodule ℝ (EuclideanSpace ℝ I)) :
    (standardLaw I).map (subspaceSplitEquiv K)=
      (standardLaw (Fin (Module.finrank ℝ K))).prod
        (standardLaw (Fin (Module.finrank ℝ Kᗮ))) := by
  classical
  let J := Fin (Module.finrank ℝ K)⊕Fin (Module.finrank ℝ Kᗮ)
  let B : J→I→ℝ := fun j i=>splitSubspaceBasis K j i
  let e := MeasurableEquiv.sumPiEquivProdPi (fun _ : J=>ℝ)
  have horth : ∀i j,NeuralGeneralization.GaussianAngularPrice.gram B i j=if i=j then 1 else 0 := by
    intro i j
    have hh := (orthonormal_iff_ite.mp (splitSubspaceBasis K).orthonormal) i j
    simpa only [B,NeuralGeneralization.GaussianAngularPrice.gram,PiLp.inner_apply,Real.inner_apply,mul_comm] using hh
  have he : subspaceSplitEquiv K=e ∘ fieldLinear B := by
    funext z
    apply Prod.ext <;> funext j
    · rw [subspaceSplitEquiv_apply]
      change (fieldLinear (subspaceCoordinateMatrix K) z) j=(fieldLinear B z) (.inl j)
      simp [fieldLinear_apply,B,subspaceCoordinateMatrix]
    · rw [subspaceSplitEquiv_apply]
      change (fieldLinear (subspaceCoordinateMatrix Kᗮ) z) j=(fieldLinear B z) (.inr j)
      simp [fieldLinear_apply,B,subspaceCoordinateMatrix]
  rw [he,←Measure.map_map e.measurable (fieldLinear B).continuous.measurable]
  change (fieldLaw B).map e=_
  rw [orthogonalRows_fieldLaw B horth]
  exact (measurePreserving_sumPiEquivProdPi (fun _ : J=>gaussianReal (0:ℝ) (1:ℝ≥0))).map_eq

def gaussianRowSpan (A : X→I→ℝ) : Submodule ℝ (EuclideanSpace ℝ I) :=
  (Fintype.linearCombination ℝ (fun x=>WithLp.toLp 2 (A x))).range

theorem gaussianRowSpan_mem (A : X→I→ℝ) (x : X) : WithLp.toLp 2 (A x)∈gaussianRowSpan A := by
  classical
  refine ⟨Pi.single x 1,?_⟩
  simp

def rowSpanDecoderMatrix (A : X→I→ℝ) : X→Fin (Module.finrank ℝ (gaussianRowSpan A))→ℝ :=
  fun x j=>inner ℝ (WithLp.toLp 2 (A x))
    ((stdOrthonormalBasis ℝ (gaussianRowSpan A) j : gaussianRowSpan A) : EuclideanSpace ℝ I)

theorem fieldLinear_rowSpan_decode (A : X→I→ℝ) (z : I→ℝ) :
    fieldLinear (rowSpanDecoderMatrix A) (fieldLinear (subspaceCoordinateMatrix (gaussianRowSpan A)) z)=
      fieldLinear A z := by
  classical
  let K := gaussianRowSpan A
  let B := splitSubspaceBasis K
  funext x
  have hh := B.sum_inner_mul_inner (WithLp.toLp 2 (A x)) (WithLp.toLp 2 z)
  have horth (j : Fin (Module.finrank ℝ Kᗮ)) :
      inner ℝ (WithLp.toLp 2 (A x)) (B (.inr j))=0 := by
    rw [show B (.inr j)=((stdOrthonormalBasis ℝ Kᗮ j : Kᗮ) : EuclideanSpace ℝ I) from splitSubspaceBasis_right K j]
    exact (stdOrthonormalBasis ℝ Kᗮ j).property _ (gaussianRowSpan_mem A x)
  rw [Fintype.sum_sum_type] at hh
  simp only [horth,zero_mul,Finset.sum_const_zero,add_zero] at hh
  rw [fieldLinear_apply]
  convert hh using 1
  · apply Finset.sum_congr rfl
    intro j _
    rw [show B (.inl j)=((stdOrthonormalBasis ℝ K j : K) : EuclideanSpace ℝ I) from splitSubspaceBasis_left K j]
    simp only [rowSpanDecoderMatrix,fieldLinear_apply,subspaceCoordinateMatrix,PiLp.inner_apply,Real.inner_apply,mul_comm]
    rfl
  · simp only [fieldLinear_apply,PiLp.inner_apply,WithLp.ofLp_toLp,Real.inner_apply,mul_comm]

theorem exists_rowSpan_extractor (A : X→I→ℝ) :
    ∃D : Fin (Module.finrank ℝ (gaussianRowSpan A))→X→ℝ,
      ∀z : I→ℝ,fieldLinear D (fieldLinear A z)=
        fieldLinear (subspaceCoordinateMatrix (gaussianRowSpan A)) z := by
  classical
  let K := gaussianRowSpan A
  have hex (j : Fin (Module.finrank ℝ K)) : ∃c : X→ℝ,
      Fintype.linearCombination ℝ (fun x=>WithLp.toLp 2 (A x)) c=
        ((stdOrthonormalBasis ℝ K j : K) : EuclideanSpace ℝ I) :=
    (stdOrthonormalBasis ℝ K j).property
  choose D hD using hex
  refine ⟨D,?_⟩
  intro z
  funext j
  have hh := congrArg (fun v : EuclideanSpace ℝ I=>inner ℝ v (WithLp.toLp 2 z)) (hD j)
  simp only [Fintype.linearCombination_apply,sum_inner,real_inner_smul_left,
    PiLp.inner_apply,WithLp.ofLp_toLp,Real.inner_apply,WithLp.ofLp_smul,Pi.smul_apply,smul_eq_mul] at hh
  simpa only [fieldLinear_apply,subspaceCoordinateMatrix,Finset.mul_sum,mul_comm,mul_left_comm,mul_assoc] using hh

/-- Exact sufficient-statistic coordinates for an arbitrary, possibly singular,
finite Gaussian observation. Both directions are genuine finite linear maps. -/
theorem gaussian_rowSpan_factorization (A : X→I→ℝ) :
    ∃D : Fin (Module.finrank ℝ (gaussianRowSpan A))→X→ℝ,
      (∀z : I→ℝ,fieldLinear A z=
        fieldLinear (rowSpanDecoderMatrix A) (subspaceSplitEquiv (gaussianRowSpan A) z).1) ∧
      (∀z : I→ℝ,(subspaceSplitEquiv (gaussianRowSpan A) z).1=fieldLinear D (fieldLinear A z)) := by
  obtain ⟨D,hD⟩ := exists_rowSpan_extractor A
  refine ⟨D,?_,?_⟩
  · intro z
    rw [subspaceSplitEquiv_apply]
    exact (fieldLinear_rowSpan_decode A z).symm
  · intro z
    rw [subspaceSplitEquiv_apply]
    exact (hD z).symm

def subspaceSplitMatrix (K : Submodule ℝ (EuclideanSpace ℝ I)) :
    (Fin (Module.finrank ℝ K)⊕Fin (Module.finrank ℝ Kᗮ))→I→ℝ :=
  fun j i=>splitSubspaceBasis K j i

def subspaceJoinMatrix (K : Submodule ℝ (EuclideanSpace ℝ I)) :
    I→(Fin (Module.finrank ℝ K)⊕Fin (Module.finrank ℝ Kᗮ))→ℝ :=
  fun i j=>splitSubspaceBasis K j i

theorem subspaceSplitMatrix_standard (K : Submodule ℝ (EuclideanSpace ℝ I)) :
    fieldLaw (subspaceSplitMatrix K)=
      standardLaw (Fin (Module.finrank ℝ K)⊕Fin (Module.finrank ℝ Kᗮ)) := by
  classical
  apply orthogonalRows_fieldLaw
  intro i j
  have hh := (orthonormal_iff_ite.mp (splitSubspaceBasis K).orthonormal) i j
  simpa only [subspaceSplitMatrix,NeuralGeneralization.GaussianAngularPrice.gram,
    PiLp.inner_apply,Real.inner_apply,mul_comm] using hh

theorem subspaceSplitMatrix_left (K : Submodule ℝ (EuclideanSpace ℝ I)) :
    (fun j i=>subspaceSplitMatrix K (.inl j) i)=subspaceCoordinateMatrix K := by
  funext j i
  simp [subspaceSplitMatrix,subspaceCoordinateMatrix]

theorem subspaceJoin_split (K : Submodule ℝ (EuclideanSpace ℝ I)) (z : I→ℝ) :
    fieldLinear (subspaceJoinMatrix K) (fieldLinear (subspaceSplitMatrix K) z)=z := by
  classical
  have hh := (splitSubspaceBasis K).sum_repr' (WithLp.toLp 2 z)
  funext i
  have hi := congrArg (fun v : EuclideanSpace ℝ I=>inner ℝ (EuclideanSpace.single i 1) v) hh
  simp only [inner_sum,inner_smul_right,EuclideanSpace.inner_single_left,map_one,one_mul] at hi
  simpa only [fieldLinear_apply,subspaceJoinMatrix,subspaceSplitMatrix,PiLp.inner_apply,
    WithLp.ofLp_toLp,Real.inner_apply,mul_comm] using hi

#print axioms subspaceSplitEquiv_standard
#print axioms gaussian_rowSpan_factorization
#print axioms subspaceJoin_split
end ConditionalNonpolynomial.Analytic
