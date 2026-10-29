import HilbertSchmidtArithmetic
import GaussianCovarianceEntropy
noncomputable section
open scoped BigOperators RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open BooleanDepthResearch
variable {E F : Type*}
  [NormedAddCommGroup E] [InnerProductSpace ℝ E] [FiniteDimensional ℝ E]
  [NormedAddCommGroup F] [InnerProductSpace ℝ F] [FiniteDimensional ℝ F]

/-- The actual rectangular polar isometry, constructed from the spectral
basis of A* A. Positivity is later supplied by finite Gaussian entropy. -/
theorem exists_polar_isometry (A : E→ₗ[ℝ] F)
    (hEig : ∀i,A.isSymmetric_adjoint_comp_self.eigenvalues rfl i>0) :
    ∃U : E→ₗᵢ[ℝ] F,∀t : ℝ,
      frobeniusSq (A-t • U.toLinearMap)=
        ∑i,(Real.sqrt (A.isSymmetric_adjoint_comp_self.eigenvalues rfl i)-t)^2 := by
  classical
  let b := A.isSymmetric_adjoint_comp_self.eigenvectorBasis rfl
  let eig := A.isSymmetric_adjoint_comp_self.eigenvalues rfl
  let v : Fin (Module.finrank ℝ E)→F := fun i=>(Real.sqrt (eig i))⁻¹ • A (b i)
  have hroot (i) : 0<Real.sqrt (eig i) := Real.sqrt_pos.mpr (hEig i)
  have hip (i j) : inner ℝ (A (b i)) (A (b j))=if i=j then eig i else 0 := by
    rw [image_inner_spectral_axis]
    change eig j*(b.repr (b i) j)=_
    rw [OrthonormalBasis.repr_self]
    by_cases hij : i=j
    · subst j; simp
    · simp [PiLp.single_apply,hij,Ne.symm hij]
  have hv : Orthonormal ℝ v := by
    rw [orthonormal_iff_ite]
    intro i j
    simp only [v,real_inner_smul_left,real_inner_smul_right,hip]
    by_cases hij : i=j
    · subst j
      simp only [ite_true]
      have hs : (Real.sqrt (eig i))^2=eig i := Real.sq_sqrt (hEig i).le
      field_simp [(hroot i).ne']
      nlinarith only [hs]
    · simp [hij]
  let Ulin : E→ₗ[ℝ] F := b.toBasis.constr ℝ v
  have hub (i) : Ulin (b i)=v i := by simp [Ulin]
  have hUorth : Orthonormal ℝ (Ulin ∘ b.toBasis) := by
    convert hv using 1
    funext i
    exact hub i
  let U := Ulin.isometryOfOrthonormal b.orthonormal hUorth
  refine ⟨U,?_⟩
  intro t
  rw [frobeniusSq_eq_sum_norm_sq _ b]
  apply Finset.sum_congr rfl
  intro i _
  have hUbi : U (b i)=v i := hub i
  have hdecomp : A (b i)=Real.sqrt (eig i) • U (b i) := by
    rw [hUbi]
    dsimp [v]
    rw [smul_smul,mul_inv_cancel₀ (hroot i).ne',one_smul]
  have hdiff : (A-t • U.toLinearMap) (b i)=(Real.sqrt (eig i)-t) • U (b i) := by
    simp only [LinearMap.sub_apply,LinearMap.smul_apply,LinearIsometry.coe_toLinearMap,sub_smul]
    rw [←hdecomp]
  rw [hdiff,norm_smul,U.norm_map,b.norm_eq_one,mul_one,Real.norm_eq_abs,sq_abs]

lemma scaled_sqrt_deviation {eig t : ℝ} (hEig : 0<eig) (ht : 0<t) :
    (Real.sqrt eig-t)^2≤t^2*(eig/t^2-1-Real.log (eig/t^2)) := by
  have hh := sqrt_deviation_sq_le_gaussian_cost (eig/t^2) (by positivity)
  have hs : Real.sqrt (eig/t^2)=Real.sqrt eig/t := by
    rw [Real.sqrt_div hEig.le,Real.sqrt_sq ht.le]
  rw [hs] at hh
  have hm := mul_le_mul_of_nonneg_left hh (sq_nonneg t)
  have hid : t^2*(Real.sqrt eig/t-1)^2=(Real.sqrt eig-t)^2 := by field_simp
  rw [hid] at hm
  exact hm

/-- Gaussian spectral entropy bounds the Hilbert--Schmidt distance to a
scaled isometry without depending on either ambient dimension. -/
theorem exists_entropy_polar_isometry (A : E→ₗ[ℝ] F)
    (hEig : ∀i,A.isSymmetric_adjoint_comp_self.eigenvalues rfl i>0)
    {t C : ℝ} (ht : 0<t)
    (hC : (∑i,(A.isSymmetric_adjoint_comp_self.eigenvalues rfl i/t^2-1-
      Real.log (A.isSymmetric_adjoint_comp_self.eigenvalues rfl i/t^2)))/2≤C) :
    ∃U : E→ₗᵢ[ℝ] F,frobeniusSq (A-t • U.toLinearMap)≤2*t^2*C := by
  obtain ⟨U,hU⟩ := exists_polar_isometry A hEig
  refine ⟨U,?_⟩
  rw [hU]
  have hh := Finset.sum_le_sum (fun i (_ : i∈Finset.univ)=>scaled_sqrt_deviation (hEig i) ht)
  rw [←Finset.mul_sum] at hh
  have hc := mul_le_mul_of_nonneg_left hC (show 0≤2*t^2 by positivity)
  linarith

#print axioms exists_polar_isometry
#print axioms exists_entropy_polar_isometry
end ConditionalNonpolynomial.Analytic
