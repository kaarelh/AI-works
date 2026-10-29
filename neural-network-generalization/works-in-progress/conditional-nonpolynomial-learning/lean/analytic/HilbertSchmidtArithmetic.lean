import TwoBallGeometry
import Mathlib.Analysis.InnerProductSpace.Adjoint
import Mathlib.Analysis.Real.Sqrt
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
noncomputable section
open scoped BigOperators RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open BooleanDepthResearch
variable {E F G : Type*}
  [NormedAddCommGroup E] [InnerProductSpace ℝ E] [FiniteDimensional ℝ E]
  [NormedAddCommGroup F] [InnerProductSpace ℝ F] [FiniteDimensional ℝ F]
  [NormedAddCommGroup G] [InnerProductSpace ℝ G] [FiniteDimensional ℝ G]

lemma frobeniusNorm_nonneg (A : E→ₗ[ℝ] F) : 0≤frobeniusNorm A := Real.sqrt_nonneg _

lemma frobeniusSq_adjoint (A : E→ₗ[ℝ] F) : frobeniusSq A.adjoint=frobeniusSq A := by
  unfold frobeniusSq
  rw [LinearMap.adjoint_adjoint]
  exact LinearMap.trace_comp_comm' A.adjoint A

lemma frobeniusNorm_adjoint (A : E→ₗ[ℝ] F) : frobeniusNorm A.adjoint=frobeniusNorm A := by
  unfold frobeniusNorm
  rw [frobeniusSq_adjoint]

lemma frobeniusNorm_comp_left (A : E→ₗ[ℝ] F) (B : F→ₗ[ℝ] G)
    {K : ℝ} (hK : 0≤K) (hB : ∀x,‖B x‖≤K*‖x‖) :
    frobeniusNorm (B.comp A)≤K*frobeniusNorm A := by
  apply (sq_le_sq₀ (frobeniusNorm_nonneg _) (mul_nonneg hK (frobeniusNorm_nonneg A))).mp
  rw [mul_pow,frobeniusNorm_sq,frobeniusNorm_sq]
  let b := stdOrthonormalBasis ℝ E
  rw [frobeniusSq_eq_sum_norm_sq _ b,frobeniusSq_eq_sum_norm_sq _ b,Finset.mul_sum]
  apply Finset.sum_le_sum
  intro i _
  have hh := pow_le_pow_left₀ (norm_nonneg (B (A (b i)))) (hB (A (b i))) 2
  simpa only [LinearMap.comp_apply,mul_pow] using hh

lemma linear_adjoint_bound (B : E→ₗ[ℝ] F) {K : ℝ}
    (hK : 0≤K) (hB : ∀x,‖B x‖≤K*‖x‖) : ∀y,‖B.adjoint y‖≤K*‖y‖ := by
  have hop : ‖B.toContinuousLinearMap‖≤K :=
    B.toContinuousLinearMap.opNorm_le_bound hK hB
  intro y
  have hn : ‖B.toContinuousLinearMap.adjoint‖=‖B.toContinuousLinearMap‖ :=
    ContinuousLinearMap.adjoint.norm_map B.toContinuousLinearMap
  have hh := B.toContinuousLinearMap.adjoint.le_opNorm y
  rw [hn] at hh
  have hmap : B.adjoint y=B.toContinuousLinearMap.adjoint y := by
    rw [←LinearMap.adjoint_toContinuousLinearMap]
    rfl
  rw [hmap]
  exact hh.trans (mul_le_mul_of_nonneg_right hop (norm_nonneg y))

lemma frobeniusNorm_comp_right (A : E→ₗ[ℝ] F) (B : F→ₗ[ℝ] G)
    {K : ℝ} (hK : 0≤K) (hA : ∀x,‖A x‖≤K*‖x‖) :
    frobeniusNorm (B.comp A)≤frobeniusNorm B*K := by
  rw [←frobeniusNorm_adjoint,LinearMap.adjoint_comp]
  have hh := frobeniusNorm_comp_left B.adjoint A.adjoint hK (linear_adjoint_bound A hK hA)
  simpa only [frobeniusNorm_adjoint,mul_comm] using hh

lemma frobeniusNorm_add (A B : E→ₗ[ℝ] F) :
    frobeniusNorm (A+B)≤frobeniusNorm A+frobeniusNorm B := by
  let b := stdOrthonormalBasis ℝ E
  have hpoint (i : Fin (Module.finrank ℝ E)) :
      ‖(A+B) (b i)‖^2≤‖A (b i)‖^2+2*(‖A (b i)‖*‖B (b i)‖)+‖B (b i)‖^2 := by
    have h := norm_add_le (A (b i)) (B (b i))
    have h2 := pow_le_pow_left₀ (norm_nonneg _) h 2
    simp only [LinearMap.add_apply]
    nlinarith
  have hsum := Finset.sum_le_sum (fun i (_ : i∈Finset.univ)=>hpoint i)
  have hcs := Real.sum_mul_le_sqrt_mul_sqrt Finset.univ (fun i=>‖A (b i)‖) (fun i=>‖B (b i)‖)
  simp only [Finset.sum_add_distrib,←Finset.mul_sum] at hsum
  rw [←frobeniusSq_eq_sum_norm_sq (A+B) b,←frobeniusSq_eq_sum_norm_sq A b,
    ←frobeniusSq_eq_sum_norm_sq B b] at hsum
  rw [←frobeniusSq_eq_sum_norm_sq A b,←frobeniusSq_eq_sum_norm_sq B b] at hcs
  change _≤frobeniusNorm A*frobeniusNorm B at hcs
  apply (sq_le_sq₀ (frobeniusNorm_nonneg _) (add_nonneg (frobeniusNorm_nonneg A) (frobeniusNorm_nonneg B))).mp
  rw [frobeniusNorm_sq]
  have hA := frobeniusNorm_sq A
  have hB := frobeniusNorm_sq B
  nlinarith

lemma frobeniusNorm_zero : frobeniusNorm (0:E→ₗ[ℝ] F)=0 := by
  unfold frobeniusNorm
  rw [frobeniusSq_eq_sum_norm_sq _ (stdOrthonormalBasis ℝ E)]
  simp

lemma frobeniusNorm_smul (t : ℝ) (A : E→ₗ[ℝ] F) :
    frobeniusNorm (t • A)=|t| *frobeniusNorm A := by
  have hs : frobeniusSq (t • A)=t^2*frobeniusSq A := by
    rw [frobeniusSq_eq_sum_norm_sq _ (stdOrthonormalBasis ℝ E),
      frobeniusSq_eq_sum_norm_sq _ (stdOrthonormalBasis ℝ E),Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro i _
    simp only [LinearMap.smul_apply,norm_smul,Real.norm_eq_abs,mul_pow,sq_abs]
  apply (sq_eq_sq₀ (frobeniusNorm_nonneg _) (mul_nonneg (abs_nonneg t) (frobeniusNorm_nonneg A))).mp
  rw [frobeniusNorm_sq,mul_pow,sq_abs,frobeniusNorm_sq,hs]

#print axioms frobeniusNorm_comp_left
#print axioms frobeniusNorm_comp_right
#print axioms frobeniusNorm_add
end ConditionalNonpolynomial.Analytic
