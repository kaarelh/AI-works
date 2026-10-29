import PhysicalCanonicalLayerModel

noncomputable section
set_option maxHeartbeats 2000000
open MeasureTheory ProbabilityTheory InformationTheory Matrix
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
variable {I : Type*} [Fintype I] [DecidableEq I]

theorem secondMomentMatrix_spectral_quadratic (Q : Measure (I→ℝ)) (a : EuclideanSpace ℝ I) :
    (a:I→ℝ) ⬝ᵥ (secondMomentMatrix Q *ᵥ (a:I→ℝ))=
      ∑i,(secondMomentMatrix_isHermitian Q).eigenvalues i*
        ((secondMomentMatrix_isHermitian Q).eigenvectorBasis.repr a i)^2 := by
  let b := (secondMomentMatrix_isHermitian Q).eigenvectorBasis
  let T := Matrix.toLpLin 2 2 (secondMomentMatrix Q)
  have hT (i:I) : T (b i)=(secondMomentMatrix_isHermitian Q).eigenvalues i • b i := by
    dsimp only [T]
    rw [Matrix.toLpLin_apply,(secondMomentMatrix_isHermitian Q).mulVec_eigenvectorBasis]
    rfl
  have hTa : T a=∑i,((b.repr a i)*((secondMomentMatrix_isHermitian Q).eigenvalues i)) • b i := by
    conv_lhs => rw [←b.sum_repr a]
    simp only [map_sum,map_smul,hT,smul_smul]
  have hid : (a:I→ℝ) ⬝ᵥ (secondMomentMatrix Q *ᵥ (a:I→ℝ))=inner ℝ a (T a) := by
    simp only [T,Matrix.toLpLin_apply,EuclideanSpace.inner_eq_star_dotProduct,star_trivial,
      WithLp.ofLp_toLp]
    exact dotProduct_comm _ _
  rw [hid,hTa,inner_sum]
  apply Finset.sum_congr rfl
  intro i _
  rw [inner_smul_right,real_inner_comm,←OrthonormalBasis.repr_apply_apply]
  change (b.repr a i*_) * b.repr a i= _*(b.repr a i)^2
  ring

theorem linearL2Map_spectral_norm_sq (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞) (a : EuclideanSpace ℝ I) :
    ‖linearL2Map Q hKL a‖^2=
      ∑i,(secondMomentMatrix_isHermitian Q).eigenvalues i*
        ((secondMomentMatrix_isHermitian Q).eigenvectorBasis.repr a i)^2 := by
  rw [linearL2Map_norm_sq]
  have heq : gaussianLinearForm a=(fun x:I→ℝ=>(a:I→ℝ) ⬝ᵥ x) := by
    funext x
    simp only [gaussianLinearForm,EuclideanSpace.inner_eq_star_dotProduct,star_trivial,
      WithLp.ofLp_toLp]
    exact dotProduct_comm _ _
  rw [heq,gaussian_integral_dotProduct_sq Q hKL]
  exact secondMomentMatrix_spectral_quadratic Q a

#print axioms linearL2Map_spectral_norm_sq
end ConditionalNonpolynomial.Analytic
