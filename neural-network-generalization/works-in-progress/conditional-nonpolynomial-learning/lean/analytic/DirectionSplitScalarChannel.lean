import GaussianDirectionSplit
import ScoreUnitDirection
import GaussianFieldScalarization

noncomputable section
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators NNReal ENNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.GaussianAngularFields
open NeuralGeneralization.GaussianAngularPrice

def directionCoefficient {N : ℕ} (u h : Fin N → ℝ) : ℝ := ∑ i, u i*h i
def directionResidual {N : ℕ} (u h : Fin N → ℝ) : Fin N → ℝ :=
  fun i => h i-directionCoefficient u h*u i

theorem directionResidual_squared {N : ℕ} (u h : Fin N → ℝ)
    (hu : ∑ i, u i^2=1) :
    ∑ i, (directionResidual u h i)^2 = (∑ i, h i^2)-(directionCoefficient u h)^2 := by
  unfold directionResidual
  have he (i : Fin N) : (h i-directionCoefficient u h*u i)^2 =
      (h i)^2-2*directionCoefficient u h*(u i*h i)+(directionCoefficient u h)^2*(u i)^2 := by ring
  simp_rw [he]
  rw [Finset.sum_add_distrib,Finset.sum_sub_distrib,← Finset.mul_sum,← Finset.mul_sum,hu]
  change (∑ i,h i^2)-2*directionCoefficient u h*directionCoefficient u h+(directionCoefficient u h)^2*1 = _
  ring

theorem directionSplit_pairing {N : ℕ} (u h : Fin N → ℝ) (z : ℝ) (ξ : Fin N → ℝ) :
    (∑ i, directionSplit u z ξ i*h i) =
      directionCoefficient u h*z+∑ i,directionResidual u h i*ξ i := by
  unfold directionSplit directionResidual directionCoefficient
  simp_rw [sub_mul,add_mul]
  rw [Finset.sum_sub_distrib,Finset.sum_add_distrib,Finset.sum_sub_distrib]
  simp_rw [show ∀ i : Fin N, z*u i*h i=z*(u i*h i) from fun i => by ring]
  rw [← Finset.mul_sum]
  have h1 : (∑i, u i*(∑j,u j*ξ j)*h i)=(∑i,u i*h i)*(∑j,u j*ξ j) := by
    rw [Finset.sum_mul]
    apply Finset.sum_congr rfl
    intro i _
    ring
  have h2 : (∑ i, ((∑ j,u j*h j)*u i)*ξ i)=(∑j,u j*h j)*(∑i,u i*ξ i) := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro i _
    ring
  rw [h1,h2]
  have he : (∑ i,ξ i*h i) = ∑ i,h i*ξ i := Finset.sum_congr rfl (fun i _ => mul_comm _ _)
  rw [he]
  ring

theorem scoreUnit_reconstruction {N : ℕ} (hN : 0<N) (b : Fin N → ℝ) (i : Fin N) :
    Real.sqrt (∑ j,b j^2)*scoreUnit hN b i=b i := by
  have hnon : 0 ≤ ∑ j,b j^2 := Finset.sum_nonneg fun j _ => sq_nonneg _
  by_cases hz : (∑ j,b j^2)=0
  · have hi : (b i)^2 ≤ ∑ j,b j^2 := Finset.single_le_sum (fun j _ => sq_nonneg _) (Finset.mem_univ i)
    have hbi : b i=0 := by nlinarith
    simp [hz,hbi]
  · rw [scoreUnit_eq hN b (lt_of_le_of_ne hnon (Ne.symm hz))]
    exact mul_div_cancel₀ _ (Real.sqrt_ne_zero'.mpr (lt_of_le_of_ne hnon (Ne.symm hz)))

theorem gaussian_unit_row_map {N : ℕ} (u : Fin N → ℝ) (hu : ∑ i,u i^2=1) :
    (standardLaw (Fin N)).map (fun ξ => ∑ i,u i*ξ i) = gaussianReal 0 1 := by
  have hnorm : ‖WithLp.toLp 2 u‖^2=1 := by
    rw [EuclideanSpace.norm_sq_eq]
    simpa only [WithLp.ofLp_toLp,Real.norm_eq_abs,sq_abs] using hu
  have h := (gaussianLinearForm_hasLaw (WithLp.toLp 2 u)).map_eq
  rw [hnorm] at h
  have he : gaussianLinearForm (WithLp.toLp 2 u) = (fun ξ => ∑ i,u i*ξ i) := by
    funext ξ
    simp only [gaussianLinearForm,PiLp.inner_apply,WithLp.ofLp_toLp,Real.inner_apply]
  rw [he] at h
  simpa only [Real.toNNReal_one,standardLaw] using h

def directionNoise {N : ℕ} (hN : 0<N) (u h : Fin N → ℝ) (ξ : Fin N → ℝ) : ℝ :=
  ∑ i, scoreUnit hN (directionResidual u h) i*ξ i

theorem directionNoise_law {N : ℕ} (hN : 0<N) (u h : Fin N → ℝ) :
    (standardLaw (Fin N)).map (directionNoise hN u h)=gaussianReal 0 1 :=
  gaussian_unit_row_map _ (scoreUnit_squared hN _)

theorem directionSplit_scalar_identity {N : ℕ} (hN : 0<N) (u h : Fin N → ℝ)
    (hu : ∑ i,u i^2=1) (z : ℝ) (ξ : Fin N → ℝ) :
    (∑ i,directionSplit u z ξ i*h i) = directionCoefficient u h*z+
      Real.sqrt ((∑ i,h i^2)-(directionCoefficient u h)^2)*directionNoise hN u h ξ := by
  rw [directionSplit_pairing,← directionResidual_squared u h hu]
  unfold directionNoise
  rw [Finset.mul_sum]
  congr 1
  apply Finset.sum_congr rfl
  intro i _
  rw [← mul_assoc,scoreUnit_reconstruction]

/-- The auxiliary source is retained exactly; the query's residual noise is
an independent standard Gaussian, including the zero-residual case. -/
theorem directionNoise_product_map {Ω : Type*} [MeasurableSpace Ω]
    (Q : Measure Ω) [SFinite Q] {N : ℕ} (hN : 0<N) (u h : Fin N → ℝ) :
    (Q.prod (standardLaw (Fin N))).map (fun p : Ω × (Fin N → ℝ) =>
      (p.1,directionNoise hN u h p.2)) = Q.prod (gaussianReal 0 1) := by
  have hh := Measure.map_prod_map Q (standardLaw (Fin N))
    measurable_id (show Measurable (directionNoise hN u h) from by unfold directionNoise; fun_prop)
  rw [Measure.map_id,directionNoise_law] at hh
  exact hh.symm

#print axioms directionSplit_scalar_identity
#print axioms directionNoise_product_map
end ConditionalNonpolynomial.Analytic
