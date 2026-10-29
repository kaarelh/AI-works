import GaussianCovarianceCost

noncomputable section
set_option maxHeartbeats 1600000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal NNReal
namespace ConditionalNonpolynomial.Analytic
variable {I : Type*} [Fintype I] [DecidableEq I]

/-- A block of nonnegative linear gains with Gaussian-cost envelopes. -/
theorem product_gain_le_exp_sqrt_cost (b : ℕ) (g c : ℕ→ℝ)
    (hg : ∀j<b,0≤g j) (hc : ∀j<b,0≤c j)
    (hbound : ∀j<b,g j≤Real.exp (Real.sqrt (2*c j))) :
    (∏j∈Finset.range b,g j)≤Real.exp (Real.sqrt (2*(b:ℝ)*(∑j∈Finset.range b,c j))) := by
  have hp : (∏j∈Finset.range b,g j)≤∏j∈Finset.range b,Real.exp (Real.sqrt (2*c j)) :=
    Finset.prod_le_prod (fun j hj=>hg j (Finset.mem_range.mp hj))
      (fun j hj=>hbound j (Finset.mem_range.mp hj))
  have hs := sum_sqrt_sq_le b (fun j=>2*c j) (fun j hj=>by positivity [hc j hj])
  rw [←Finset.mul_sum] at hs
  have hsum : (∑j∈Finset.range b,Real.sqrt (2*c j))≤
      Real.sqrt (2*(b:ℝ)*(∑j∈Finset.range b,c j)) := by
    apply Real.le_sqrt_of_sq_le
    nlinarith only [hs]
  calc
    _ ≤ ∏j∈Finset.range b,Real.exp (Real.sqrt (2*c j)) := hp
    _ = Real.exp (∑j∈Finset.range b,Real.sqrt (2*c j)) := (Real.exp_sum _ _).symm
    _ ≤ _ := Real.exp_le_exp.mpr hsum

theorem gaussian_preconditioner_block_product (Q : ℕ→Measure (I→ℝ)) (b : ℕ)
    (hprob : ∀j<b,IsProbabilityMeasure (Q j))
    (hKL : ∀j<b,klDiv (Q j) (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞) :
    (∏j∈Finset.range b,‖gaussianFeaturePreconditioner (Q j)‖)≤
      Real.exp (Real.sqrt (2*(b:ℝ)*(∑j∈Finset.range b,gaussianCovarianceCost (Q j)))) := by
  apply product_gain_le_exp_sqrt_cost b _ _ (fun _ _=>norm_nonneg _)
  · intro j hj
    letI := hprob j hj
    exact gaussianCovarianceCost_nonneg (Q j) (hKL j hj)
  · intro j hj
    letI := hprob j hj
    exact gaussianFeaturePreconditioner_norm_exp_covarianceCost (Q j) (hKL j hj)

theorem gaussian_scaled_preconditioner_block_product (Q : ℕ→Measure (I→ℝ)) (b : ℕ)
    (hprob : ∀j<b,IsProbabilityMeasure (Q j))
    (hKL : ∀j<b,klDiv (Q j) (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞)
    {t : ℝ} (ht : 0≤t) :
    (∏j∈Finset.range b,(t*‖gaussianFeaturePreconditioner (Q j)‖))≤
      t^b*Real.exp (Real.sqrt (2*(b:ℝ)*(∑j∈Finset.range b,gaussianCovarianceCost (Q j)))) := by
  rw [Finset.prod_mul_distrib]
  simp only [Finset.prod_const,Finset.card_range]
  exact mul_le_mul_of_nonneg_left (gaussian_preconditioner_block_product Q b hprob hKL) (pow_nonneg ht _)

theorem gaussian_scaled_preconditioner_small_cost (Q : ℕ→Measure (I→ℝ)) (b : ℕ)
    (hprob : ∀j<b,IsProbabilityMeasure (Q j))
    (hKL : ∀j<b,klDiv (Q j) (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞)
    {t η : ℝ} (ht : 0≤t)
    (hcost : (b:ℝ)*(∑j∈Finset.range b,gaussianCovarianceCost (Q j))≤η) :
    (∏j∈Finset.range b,(t*‖gaussianFeaturePreconditioner (Q j)‖))≤
      t^b*Real.exp (Real.sqrt (2*η)) := by
  apply (gaussian_scaled_preconditioner_block_product Q b hprob hKL ht).trans
  apply mul_le_mul_of_nonneg_left _ (pow_nonneg ht _)
  apply Real.exp_le_exp.mpr
  apply Real.sqrt_le_sqrt
  linarith only [hcost]

/-- Every eigenvalue in a good block is bounded by its total Gaussian cost. -/
theorem gaussian_eigenvalue_block_bound (Q : ℕ→Measure (I→ℝ)) (b : ℕ)
    (hprob : ∀j<b,IsProbabilityMeasure (Q j))
    (hKL : ∀j<b,klDiv (Q j) (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞)
    {E : ℝ} (hcost : (∑j∈Finset.range b,gaussianCovarianceCost (Q j))≤E)
    (j : ℕ) (hj : j<b) (i : I) :
    Real.sqrt ((secondMomentMatrix_isHermitian (Q j)).eigenvalues i)≤1+Real.sqrt (2*E) := by
  letI := hprob j hj
  have hc (k : ℕ) (hk : k∈Finset.range b) : 0≤gaussianCovarianceCost (Q k) := by
    letI := hprob k (Finset.mem_range.mp hk)
    exact gaussianCovarianceCost_nonneg (Q k) (hKL k (Finset.mem_range.mp hk))
  have hsingle := (Finset.single_le_sum hc (Finset.mem_range.mpr hj)).trans hcost
  apply (gaussian_eigenvalue_sqrt_le (Q j) (hKL j hj) i).trans
  have hh := Real.sqrt_le_sqrt (show 2*gaussianCovarianceCost (Q j)≤2*E by linarith only [hsingle])
  linarith only [hh]

#print axioms product_gain_le_exp_sqrt_cost
#print axioms gaussian_scaled_preconditioner_block_product
#print axioms gaussian_scaled_preconditioner_small_cost
#print axioms gaussian_eigenvalue_block_bound
end ConditionalNonpolynomial.Analytic
