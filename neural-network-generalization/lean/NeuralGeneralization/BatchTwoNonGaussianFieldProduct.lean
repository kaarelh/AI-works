import NeuralGeneralization.BatchTwoNonGaussianReplacement
import NeuralGeneralization.CoordinateSplit

/-! A quadratic tanh field under the actual independent coordinate product.
The coordinate split and its Fubini identity are proved for these laws. -/

noncomputable section
open MeasureTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoNonGaussian
open TanhDifferential
variable {I J : Type*} [Fintype I] [Fintype J]

def fieldExp (Γ : I → I → ℝ) (a : J → I → ℝ) (x : J → ℝ) : ℝ :=
  Real.exp (potentialValue Real.tanh Γ (fun i => ∑ j, a j i * x j))

@[fun_prop] theorem continuous_fieldExp (Γ : I → I → ℝ) (a : J → I → ℝ) :
    Continuous (fieldExp Γ a) := by
  unfold fieldExp potentialValue pairValue
  fun_prop

theorem fieldExp_bounds (Γ : I → I → ℝ) (a : J → I → ℝ) (x : J → ℝ) (G : ℝ)
    (hΓ : couplingMass Γ ≤ G) :
    Real.exp (-G) ≤ fieldExp Γ a x ∧ fieldExp Γ a x ≤ Real.exp G := by
  have h := abs_le.mp ((abs_potentialValue_le_mass Real.tanh
    (fun t => (Real.abs_tanh_lt_one t).le) Γ (fun i => ∑ j, a j i * x j)).trans hΓ)
  exact ⟨Real.exp_le_exp.mpr h.1, Real.exp_le_exp.mpr h.2⟩

theorem fieldExp_integrable (laws : J → CoordinateLaw) (Γ : I → I → ℝ) (a : J → I → ℝ) :
    Integrable (fieldExp Γ a) (Measure.pi fun j => (laws j).law) := by
  apply Integrable.of_bound (continuous_fieldExp Γ a).aestronglyMeasurable (Real.exp (couplingMass Γ))
  filter_upwards [] with x
  change |fieldExp Γ a x| ≤ _
  rw [abs_of_pos (show 0 < fieldExp Γ a x from Real.exp_pos _)]
  exact (fieldExp_bounds Γ a x _ le_rfl).2

def fieldPartition (laws : J → CoordinateLaw) (Γ : I → I → ℝ) (a : J → I → ℝ) : ℝ :=
  ∫ x, fieldExp Γ a x ∂Measure.pi (fun j => (laws j).law)

theorem fieldPartition_bounds (laws : J → CoordinateLaw) (Γ : I → I → ℝ)
    (a : J → I → ℝ) (G : ℝ) (hΓ : couplingMass Γ ≤ G) :
    Real.exp (-G) ≤ fieldPartition laws Γ a ∧ fieldPartition laws Γ a ≤ Real.exp G := by
  have hlo := integral_mono (integrable_const (Real.exp (-G)))
    (fieldExp_integrable laws Γ a) (fun x => (fieldExp_bounds Γ a x G hΓ).1)
  have hhi := integral_mono (fieldExp_integrable laws Γ a)
    (integrable_const (Real.exp G)) (fun x => (fieldExp_bounds Γ a x G hΓ).2)
  simpa only [integral_const, probReal_univ, smul_eq_mul, one_mul, fieldPartition] using And.intro hlo hhi

theorem fieldPartition_pos (laws : J → CoordinateLaw) (Γ : I → I → ℝ) (a : J → I → ℝ) :
    0 < fieldPartition laws Γ a :=
  (Real.exp_pos _).trans_le (fieldPartition_bounds laws Γ a _ le_rfl).1

section Split
variable [DecidableEq J]

def residualField (a : J → I → ℝ) (j : J) (y : {k : J // k ≠ j} → ℝ) (i : I) : ℝ :=
  ∑ k : {k : J // k ≠ j}, a k i * y k

theorem fieldExp_split (Γ : I → I → ℝ) (a : J → I → ℝ) (j : J)
    (t : ℝ) (y : {k : J // k ≠ j} → ℝ) :
    fieldExp Γ a ((CoordinateSplit.split j).symm (t, y)) =
      expPotential Γ (residualField a j y) (a j) t := by
  unfold fieldExp expPotential
  rw [potentialLine_eq_quadratic]
  congr 2
  funext i
  rw [Fintype.sum_eq_add_sum_subtype_ne _ j]
  simp only [CoordinateSplit.split_symm_self, residualField]
  rw [add_comm]
  congr 1
  apply Finset.sum_congr rfl
  intro k _
  rw [CoordinateSplit.split_symm_ne j t y k.1 k.2]

theorem fieldPartition_split (laws : J → CoordinateLaw) (Γ : I → I → ℝ) (a : J → I → ℝ) (j : J) :
    fieldPartition laws Γ a =
      ∫ y, (∫ t, expPotential Γ (residualField a j y) (a j) t ∂(laws j).law)
        ∂Measure.pi (fun k : {k : J // k ≠ j} => (laws k).law) := by
  have hs := (CoordinateSplit.measurePreserving_split (fun k => (laws k).law) j).symm
  have hi := hs.integrable_comp_of_integrable (fieldExp_integrable laws Γ a)
  calc
    _ = ∫ p, fieldExp Γ a ((CoordinateSplit.split j).symm p)
        ∂((laws j).law.prod (Measure.pi fun k : {k : J // k ≠ j} => (laws k).law)) :=
      (hs.integral_comp' (fieldExp Γ a)).symm
    _ = _ := by simpa only [Function.comp_def, fieldExp_split] using integral_prod_symm _ hi

theorem fieldMarginal_integrable (laws : J → CoordinateLaw) (Γ : I → I → ℝ)
    (a : J → I → ℝ) (j : J) :
    Integrable (fun y => ∫ t, expPotential Γ (residualField a j y) (a j) t ∂(laws j).law)
      (Measure.pi fun k : {k : J // k ≠ j} => (laws k).law) := by
  have hs := (CoordinateSplit.measurePreserving_split (fun k => (laws k).law) j).symm
  have hi := hs.integrable_comp_of_integrable (fieldExp_integrable laws Γ a)
  simpa only [Function.comp_def, fieldExp_split] using hi.integral_prod_right

end Split
end NeuralGeneralization.BatchTwoNonGaussian
