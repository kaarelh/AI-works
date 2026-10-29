import GaussianWhitenedResidual
import PolarHilbertSchmidt

/-! An actual polar isometry for the unchanged canonical linear map, using
the original Gaussian coefficient law's covariance eigenbasis. -/
noncomputable section
set_option maxHeartbeats 400000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory Matrix
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open BooleanDepthResearch
variable {I J : Type*} [Fintype I] [DecidableEq I] [Fintype J]

lemma canonicalGaussianLinear_inner (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞)
    (anchors : J→EuclideanSpace ℝ I) (a b : EuclideanSpace ℝ I) :
    inner ℝ (canonicalGaussianLinear Q hKL anchors a) (canonicalGaussianLinear Q hKL anchors b)=
      (WithLp.ofLp a) ⬝ᵥ (secondMomentMatrix Q *ᵥ (WithLp.ofLp b)) := by
  have hip : inner ℝ (canonicalGaussianLinear Q hKL anchors a) (canonicalGaussianLinear Q hKL anchors b)=
      inner ℝ (linearL2Map Q hKL a) (linearL2Map Q hKL b) := by
    rw [real_inner_eq_norm_add_mul_self_sub_norm_mul_self_sub_norm_mul_self_div_two,
      real_inner_eq_norm_add_mul_self_sub_norm_mul_self_sub_norm_mul_self_div_two]
    simp only [←map_add,canonicalGaussianLinear_norm]
  rw [hip,L2.inner_def,←gaussian_integral_dotProduct_mul Q hKL]
  apply integral_congr_ae
  filter_upwards [linearL2Map_ae Q hKL a,linearL2Map_ae Q hKL b] with z ha hb
  simp only [ha,hb,Real.inner_apply,gaussianLinearForm,PiLp.inner_apply,WithLp.ofLp_toLp,dotProduct]

lemma canonicalGaussianLinear_eigen_inner (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞)
    (anchors : J→EuclideanSpace ℝ I) (i j:I) :
    inner ℝ (canonicalGaussianLinear Q hKL anchors ((secondMomentMatrix_isHermitian Q).eigenvectorBasis i))
      (canonicalGaussianLinear Q hKL anchors ((secondMomentMatrix_isHermitian Q).eigenvectorBasis j))=
      if i=j then (secondMomentMatrix_isHermitian Q).eigenvalues i else 0 := by
  rw [canonicalGaussianLinear_inner,(secondMomentMatrix_isHermitian Q).mulVec_eigenvectorBasis,dotProduct_smul]
  have he : ((secondMomentMatrix_isHermitian Q).eigenvectorBasis i) ⬝ᵥ
      ((secondMomentMatrix_isHermitian Q).eigenvectorBasis j)=if i=j then 1 else 0 := by
    have hh := (secondMomentMatrix_isHermitian Q).eigenvectorBasis.inner_eq_ite i j
    rw [dotProduct_comm]
    simpa only [EuclideanSpace.inner_eq_star_dotProduct,star_trivial] using hh
  rw [he]
  split_ifs with hij
  · subst j; simp
  · simp

/-- Polar construction in any specified orthonormal eigenbasis. -/
theorem basis_polar_isometry {F : Type*} [NormedAddCommGroup F]
    [InnerProductSpace ℝ F] [FiniteDimensional ℝ F]
    (A : EuclideanSpace ℝ I→ₗ[ℝ] F) (b : OrthonormalBasis I ℝ (EuclideanSpace ℝ I))
    (eig : I→ℝ) (hpos : ∀i,0<eig i)
    (hip : ∀i j,inner ℝ (A (b i)) (A (b j))=if i=j then eig i else 0) :
    ∃U : EuclideanSpace ℝ I→ₗᵢ[ℝ] F,
      ∀t:ℝ,frobeniusSq (t • A-t • U.toLinearMap)=
        t^2*∑i,(Real.sqrt (eig i)-1)^2 := by
  let v : I→F := fun i=>(Real.sqrt (eig i))⁻¹ • A (b i)
  have hroot (i:I) : 0<Real.sqrt (eig i) := Real.sqrt_pos.mpr (hpos i)
  have hv : Orthonormal ℝ v := by
    rw [orthonormal_iff_ite]
    intro i j
    simp only [v,real_inner_smul_left,real_inner_smul_right,hip]
    by_cases hij : i=j
    · subst j
      simp only [ite_true]
      have hs : (Real.sqrt (eig i))^2=eig i := Real.sq_sqrt (hpos i).le
      field_simp [(hroot i).ne']
      nlinarith only [hs]
    · simp [hij]
  let Ulin : EuclideanSpace ℝ I→ₗ[ℝ] F := b.toBasis.constr ℝ v
  have hub (i:I) : Ulin (b i)=v i := by simp [Ulin]
  have hUorth : Orthonormal ℝ (Ulin ∘ b.toBasis) := by
    convert hv using 1
    funext i
    exact hub i
  let U : EuclideanSpace ℝ I→ₗᵢ[ℝ] F := Ulin.isometryOfOrthonormal (v:=b.toBasis) b.orthonormal hUorth
  refine ⟨U,?_⟩
  intro t
  rw [frobeniusSq_eq_sum_norm_sq _ b,Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i _
  have hdecomp : A (b i)=Real.sqrt (eig i) • U (b i) := by
    change A (b i)=Real.sqrt (eig i) • Ulin (b i)
    rw [hub]
    dsimp [v]
    rw [smul_smul,mul_inv_cancel₀ (hroot i).ne',one_smul]
  have hdiff : (t • A-t • U.toLinearMap) (b i)=(t*(Real.sqrt (eig i)-1)) • U (b i) := by
    simp only [LinearMap.sub_apply,LinearMap.smul_apply,LinearIsometry.coe_toLinearMap]
    rw [hdecomp]
    simp only [smul_smul,sub_smul]
    rw [←sub_smul]
    congr 1
    ring
  change ‖(t • A-t • U.toLinearMap) (b i)‖^2=_
  rw [hdiff,norm_smul,U.norm_map,b.norm_eq_one,mul_one,Real.norm_eq_abs,sq_abs,mul_pow]

/-- The canonical linear map is within covariance-entropy-controlled
Hilbert--Schmidt distance of one fixed isometry. -/
theorem canonicalGaussianLinear_polar (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞)
    (anchors : J→EuclideanSpace ℝ I) :
    ∃U : EuclideanSpace ℝ I→ₗᵢ[ℝ] EuclideanSpace ℝ (CanonicalIndex Q hKL anchors),
      ∀t:ℝ,frobeniusSq (t • canonicalGaussianLinear Q hKL anchors-t • U.toLinearMap)=
        t^2*∑i,(Real.sqrt ((secondMomentMatrix_isHermitian Q).eigenvalues i)-1)^2 := by
  exact basis_polar_isometry (canonicalGaussianLinear Q hKL anchors)
    (secondMomentMatrix_isHermitian Q).eigenvectorBasis
    (secondMomentMatrix_isHermitian Q).eigenvalues
    (secondMomentMatrix_eigenvalues_pos Q hKL)
    (canonicalGaussianLinear_eigen_inner Q hKL anchors)

/-- The Gaussian part of the entropy, and not raw total entropy, pays for
linear departures from the free physical contraction. -/
theorem canonicalGaussianLinear_entropy_polar (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞)
    (anchors : J→EuclideanSpace ℝ I) {C : ℝ}
    (hC : (∑i,((secondMomentMatrix_isHermitian Q).eigenvalues i-1-
      Real.log ((secondMomentMatrix_isHermitian Q).eigenvalues i)))/2≤C) :
    ∃U : EuclideanSpace ℝ I→ₗᵢ[ℝ] EuclideanSpace ℝ (CanonicalIndex Q hKL anchors),
      ∀t:ℝ,frobeniusSq (t • canonicalGaussianLinear Q hKL anchors-t • U.toLinearMap)≤2*t^2*C := by
  obtain ⟨U,hU⟩ := canonicalGaussianLinear_polar Q hKL anchors
  refine ⟨U,?_⟩
  intro t
  rw [hU]
  have hh := Finset.sum_le_sum fun i (_:i∈Finset.univ)=>
    sqrt_deviation_sq_le_gaussian_cost _ (secondMomentMatrix_eigenvalues_pos Q hKL i)
  have hsum : (∑i,(Real.sqrt ((secondMomentMatrix_isHermitian Q).eigenvalues i)-1)^2)≤2*C := by
    linarith
  have hm := mul_le_mul_of_nonneg_left hsum (sq_nonneg t)
  nlinarith only [hm]

#print axioms canonicalGaussianLinear_entropy_polar
end ConditionalNonpolynomial.Analytic
