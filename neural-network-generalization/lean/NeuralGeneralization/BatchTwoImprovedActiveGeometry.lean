import NeuralGeneralization.RobustGaussianGeometrySourceBank
import NeuralGeneralization.BatchTwoImprovedRankSafeLeverage

/-! # Exact active-coordinate geometry, including zero Gram--Schmidt slots -/
noncomputable section
open MeasureTheory ProbabilityTheory InnerProductSpace Submodule WithLp
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoImprovedActiveGeometry
open RobustGaussianGeometry BatchTwoImprovedWeightedSampling SquaredSampling
variable {N q : ℕ}

def activeSlots (b : Fin q → EuclideanSpace ℝ (Fin N)) : Finset (Fin q) :=
  Finset.univ.filter (fun k => gramSchmidtNormed ℝ b k ≠ 0)
def onActiveSlots (b : Fin q → EuclideanSpace ℝ (Fin N)) (v : Fin q → ℝ) : Prop :=
  ∀ k, k ∉ activeSlots b → v k = 0

theorem active_combination_norm (b : Fin q → EuclideanSpace ℝ (Fin N)) (v : Fin q → ℝ) :
    ‖∑ k, v k • gramSchmidtNormed ℝ b k‖^2 =
      ∑ k, (v k)^2*‖gramSchmidtNormed ℝ b k‖^2 := by
  rw [← real_inner_self_eq_norm_sq,sum_inner]
  simp_rw [inner_sum,inner_smul_left,inner_smul_right,active_inner_eq_diagonal]
  simp only [RCLike.conj_to_real,mul_ite,ite_mul,mul_zero,zero_mul,
    Finset.sum_ite_eq,Finset.mem_univ,if_true]
  congr 1
  ext k
  ring

theorem sourceRows_covariance_exact (b : Fin q → EuclideanSpace ℝ (Fin N))
    (hN : 0 < N) (v : Fin q → ℝ) :
    (∑ i, (linearEvaluation (fun k => sourceRows b i k) v)^2)/(N:ℝ) =
      ∑ k, (v k)^2*‖gramSchmidtNormed ℝ b k‖^2 := by
  have hn : (N:ℝ) ≠ 0 := by exact_mod_cast hN.ne'
  have he (i : Fin N) : linearEvaluation (fun k => sourceRows b i k) v =
      Real.sqrt (N:ℝ)*(∑ k, v k • gramSchmidtNormed ℝ b k) i := by
    have hs : (∑ k, v k • gramSchmidtNormed ℝ b k) i =
        ∑ k, v k*gramSchmidtNormed ℝ b k i := by
      change (EuclideanSpace.proj i) (∑ k, v k • gramSchmidtNormed ℝ b k) = _
      simp
    rw [hs]
    simp [linearEvaluation,sourceRows,Finset.mul_sum,mul_comm,mul_left_comm]
  simp_rw [he,mul_pow,Real.sq_sqrt (Nat.cast_nonneg N)]
  rw [← Finset.mul_sum,mul_div_cancel_left₀ _ hn,← EuclideanSpace.real_norm_sq_eq]
  exact active_combination_norm b v

theorem sourceRows_covariance_active (b : Fin q → EuclideanSpace ℝ (Fin N))
    (hN : 0 < N) (v : Fin q → ℝ) (hv : onActiveSlots b v) :
    (∑ i, (linearEvaluation (fun k => sourceRows b i k) v)^2)/(N:ℝ) = ∑ k, (v k)^2 := by
  rw [sourceRows_covariance_exact b hN v]
  apply Finset.sum_congr rfl
  intro k hk
  by_cases hb : gramSchmidtNormed ℝ b k = 0
  · have hz := hv k (by simp [activeSlots,hb])
    simp [hb,hz]
  · rw [gramSchmidtNormed_unit_length' hb]
    ring

theorem sourceRows_zero_off_active (b : Fin q → EuclideanSpace ℝ (Fin N))
    (k : Fin q) (hk : k ∉ activeSlots b) (j : Fin N) : sourceRows b j k = 0 := by
  have hb : gramSchmidtNormed ℝ b k = 0 := by simpa [activeSlots] using hk
  simp [sourceRows,hb]

/-- An active vector has no contribution from zero slots. -/
theorem active_feature_on_slots (b : Fin q → EuclideanSpace ℝ (Fin N))
    (x : EuclideanSpace ℝ (Fin N)) : onActiveSlots b (evaluations (gramSchmidtNormed ℝ b) x) := by
  intro k hk
  have hb : gramSchmidtNormed ℝ b k = 0 := by simpa [activeSlots] using hk
  simp [evaluations,hb]

end NeuralGeneralization.BatchTwoImprovedActiveGeometry
