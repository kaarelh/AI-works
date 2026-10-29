import PhysicalEntropyModels
import PhysicalCanonicalRadii
import PhysicalCanonicalGoodCover

/-! Per-layer data of the actual entropy-split path, ready for disjoint
block accounting. All selected models come from the proved construction. -/
noncomputable section
set_option maxHeartbeats 2200000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel
variable {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
local instance (B : CanonicalProgramState d) : DecidableEq B.Index := Classical.decEq _
variable {P : ControlledMarginPath d H t f} {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

def pathNongaussianCost
    (hstep : ∀j<H,PhysicalEntropySplitStep P S j (states j) (states (j+1))) (j : ℕ) : ℝ := by
  classical
  exact if hj:j<H then (hstep j hj).model.nongaussianCost else 0

def pathPositiveRadius (states : ℕ→CanonicalProgramState d) (ε : ℝ) (j : ℕ) : ℝ :=
  Real.sqrt (maxFeatureVariance (states j).feature)+ε

def pathNonlinearCost
    (hstep : ∀j<H,PhysicalEntropySplitStep P S j (states j) (states (j+1))) (ε : ℝ) (j : ℕ) : ℝ :=
  (pathPositiveRadius states ε j)^2+Real.sqrt (pathNongaussianCost hstep j)

lemma pathNongaussianCost_le
    (hstep : ∀j<H,PhysicalEntropySplitStep P S j (states j) (states (j+1)))
    (j : ℕ) (hj : j<H) : pathNongaussianCost hstep j≤physicalAdjustedCost P j := by
  classical
  simpa only [pathNongaussianCost,dif_pos hj] using (hstep j hj).model_nongaussian

lemma pathPositiveRadius_pos (states : ℕ→CanonicalProgramState d) {ε : ℝ} (hε : 0<ε) (j : ℕ) :
    0<pathPositiveRadius states ε j := add_pos_of_nonneg_of_pos (Real.sqrt_nonneg _) hε

lemma pathPositiveRadius_contains (states : ℕ→CanonicalProgramState d) {ε : ℝ} (hε : 0≤ε)
    (j : ℕ) (x : Cube d) : ‖(states j).feature x‖≤pathPositiveRadius states ε j := by
  have hh : ‖(states j).feature x‖≤Real.sqrt (maxFeatureVariance (states j).feature) :=
    (Real.le_sqrt (norm_nonneg _) (maxFeatureVariance_nonneg _)).mpr (feature_variance_le_max _ _)
  unfold pathPositiveRadius
  linarith

lemma pathPositiveRadius_square (states : ℕ→CanonicalProgramState d) (ε : ℝ) (j : ℕ) :
    (pathPositiveRadius states ε j)^2≤2*maxFeatureVariance (states j).feature+2*ε^2 := by
  have hh := Real.sq_sqrt (maxFeatureVariance_nonneg (states j).feature)
  have hs := sq_nonneg (Real.sqrt (maxFeatureVariance (states j).feature)-ε)
  unfold pathPositiveRadius
  nlinarith

/-- The genuine canonical nonlinear prefix has only square-root forcing
cost. In particular the coefficient of the prefix length is not linear. -/
theorem pathNonlinearCost_prefix
    (hstep : ∀j<H,PhysicalEntropySplitStep P S j (states j) (states (j+1)))
    (hd : 1≤d) {J : ℕ} (hJ : J≤H) {ε : ℝ} (hε : 0≤ε)
    (hquery : ∀j<J,∀x,QueryFeatureClose (P.feature j) (states j).feature S x ε) :
    (∑j∈Finset.range J,pathNonlinearCost hstep ε j)≤
      8+4*(physicalPrefixOccupationConstant+1)*(Real.log ((J:ℝ)+2)+
        Real.sqrt ((J:ℝ)*(∑j∈Finset.range J,physicalAdjustedCost P j)))+6*(J:ℝ)*ε^2 := by
  have hpoint (j : ℕ) (hj : j∈Finset.range J) :
      pathNonlinearCost hstep ε j≤
        2*(maxFeatureVariance (states j).feature+Real.sqrt (pathNongaussianCost hstep j))+2*ε^2 := by
    have hh := pathPositiveRadius_square states ε j
    unfold pathNonlinearCost
    nlinarith [Real.sqrt_nonneg (pathNongaussianCost hstep j)]
  have hs := Finset.sum_le_sum hpoint
  simp only [←Finset.mul_sum,Finset.sum_add_distrib,Finset.sum_const,Finset.card_range,nsmul_eq_mul] at hs
  have ho := physical_canonical_prefix_nonlinear_budget P hd S states hJ hε hquery
    (pathNongaussianCost hstep) (fun j hj=>pathNongaussianCost_le hstep j (by omega))
  rw [Finset.sum_add_distrib] at ho
  nlinarith only [hs,ho]

/-- Restrict the actual chosen models to one finite block. -/
def pathBlockModel
    (hstep : ∀j<H,PhysicalEntropySplitStep P S j (states j) (states (j+1)))
    (offset b : ℕ) (hfit : offset+b≤H) (j : ℕ) (hj : j<b) :
    CanonicalLayerModel (J:=(states (offset+(j+1))).Index)
      (fun s:S=>t • (states (offset+j)).feature s) (physicalLayerCost P (offset+j)) :=
  (hstep (offset+j) (by omega)).model

lemma pathBlockModel_gaussian_cost
    (hstep : ∀j<H,PhysicalEntropySplitStep P S j (states j) (states (j+1)))
    (offset b : ℕ) (hfit : offset+b≤H) :
    (∑j∈Finset.range b,finiteGaussianCost (pathBlockModel hstep offset b hfit) j)≤
      ∑j∈Finset.range b,physicalLayerCost P (offset+j) := by
  classical
  apply Finset.sum_le_sum
  intro j hj
  have hbj := Finset.mem_range.mp hj
  simp only [finiteGaussianCost,dif_pos hbj,pathBlockModel]
  exact (hstep (offset+j) (by omega)).model_gaussian

lemma pathBlockModel_nonlinear_cost
    (hstep : ∀j<H,PhysicalEntropySplitStep P S j (states j) (states (j+1)))
    (offset b : ℕ) (hfit : offset+b≤H) (ε : ℝ) :
    (∑j∈Finset.range b,((pathPositiveRadius states ε (offset+j))^2+
      Real.sqrt (finiteNongaussianCost (pathBlockModel hstep offset b hfit) j)))=
      ∑j∈Finset.range b,pathNonlinearCost hstep ε (offset+j) := by
  classical
  apply Finset.sum_congr rfl
  intro j hj
  have hbj := Finset.mem_range.mp hj
  have hHj : offset+j<H := by omega
  simp only [finiteNongaussianCost,pathNonlinearCost,pathNongaussianCost,pathBlockModel,dif_pos hbj,dif_pos hHj]

#print axioms pathNonlinearCost_prefix
#print axioms pathBlockModel_gaussian_cost
end ConditionalNonpolynomial.Analytic
