import PhysicalPathBlockData
import IndexedCoverIteration

/-! Actual good and bad block steps for entropy-split paths. Good blocks use
the Gaussian/non-Gaussian decomposition; arbitrary blocks use the exact
physical logarithmic gain inequality. -/
noncomputable section
set_option maxHeartbeats 2400000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel
variable {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
local instance (B : CanonicalProgramState d) : DecidableEq B.Index := Classical.decEq _
variable {P : ControlledMarginPath d H t f} {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

 theorem physical_path_good_block_cover
    (hstep : ∀j<H,PhysicalEntropySplitStep P S j (states j) (states (j+1)))
    {ε : ℝ} (hε : 0<ε) (offset b : ℕ) (hfit : offset+b≤H) (hb : 1≤b)
    {E B : ℝ} (hB : 0<B) (T k : ℕ) (hT : 0<T)
    (hgridSize : (canonicalBlockHSBound E)^2≤(B/64)^2*k)
    (hgridError : ∀Q:ℝ,0≤Q→Q≤(canonicalBlockHSBound E)^2→
      Real.sqrt (Q/(T:ℝ)^2+(B/64)^2)≤B/32)
    (hcost : (b:ℝ)*(∑j∈Finset.range b,physicalLayerCost P (offset+j))≤E)
    (hfree : t^b≤B/32)
    (hnonlinear : (∑j∈Finset.range b,pathNonlinearCost hstep ε (offset+j))≤
      B/(16*canonicalBlockNonlinearBound E))
    (C : Set (Cube d)) (z : EuclideanSpace ℝ (states offset).Index) {r : ℝ} (hr : 0<r)
    (hC : ∀x∈C,dist ((states offset).feature x) z≤r) :
    ∃Y:Finset (Cube d),(↑Y:Set (Cube d))⊆C ∧Y.card≤(2*T+1)^k ∧
      ∀x∈C,∃y∈Y,dist ((states (offset+b)).feature x) ((states (offset+b)).feature y)≤B*r/2 := by
  classical
  let M := pathBlockModel hstep offset b hfit
  apply actual_physical_good_block_cover hB T k hT hgridSize hgridError M
    P.scale_positive P.scale_le_one hb
    (fun j=>(states (offset+j)).feature) (fun j=>pathPositiveRadius states ε (offset+j))
  · intro j hj
    exact pathPositiveRadius_pos states hε _
  · intro j hj x
    exact pathPositiveRadius_contains states hε.le _ x
  · intro j hj x
    exact (hstep (offset+j) (by omega)).model_recursion x
  · exact (mul_le_mul_of_nonneg_left (pathBlockModel_gaussian_cost hstep offset b hfit)
      (Nat.cast_nonneg b)).trans hcost
  · exact hfree
  · change (∑j∈Finset.range b,((pathPositiveRadius states ε (offset+j))^2+
        Real.sqrt (finiteNongaussianCost (pathBlockModel hstep offset b hfit) j)))≤_
    rw [pathBlockModel_nonlinear_cost]
    exact hnonlinear
  · exact hr
  · exact hC

lemma physicalLayerGain_le_raw_exp (P : ControlledMarginPath d H t f)
    (j : ℕ) (hj : j<H) (ha : 0<(physicalVariance P:ℝ)⁻¹-1) :
    physicalLayerGain P j≤Real.exp ((physicalLayerCost P j-subcriticalCostBaseline (physicalVariance P))/
      ((physicalVariance P:ℝ)⁻¹-1)) := by
  have hh := (physicalGaussianRemainder_bounds P j hj).1
  unfold physicalGaussianRemainder at hh
  have hg : physicalPathLogGain P j≤
      (physicalLayerCost P j-subcriticalCostBaseline (physicalVariance P))/((physicalVariance P:ℝ)⁻¹-1) :=
    (le_div_iff₀ ha).mpr (by nlinarith only [hh])
  have he : Real.exp (physicalPathLogGain P j)=physicalLayerGain P j :=
    Real.exp_log (physicalLayerGain_pos P j)
  rw [←he]
  exact Real.exp_le_exp.mpr hg

lemma PhysicalEntropySplitStep.pair_gain {j : ℕ} {B C : CanonicalProgramState d}
    (h : PhysicalEntropySplitStep P S j B C) (x y : Cube d) :
    ‖C.feature x-C.feature y‖≤physicalLayerGain P j*‖B.feature x-B.feature y‖ := by
  classical
  rw [h.model_recursion x,h.model_recursion y,physicalLayerGain_eq]
  exact h.model.physical_value_lipschitz P.scale_positive.le h.model.preconditioner_sharp_bound _ _

 theorem physical_path_block_pair_gain
    (hstep : ∀j<H,PhysicalEntropySplitStep P S j (states j) (states (j+1)))
    (offset b : ℕ) (hfit : offset+b≤H) (ha : 0<(physicalVariance P:ℝ)⁻¹-1)
    (x y : Cube d) :
    dist ((states (offset+b)).feature x) ((states (offset+b)).feature y)≤
      Real.exp (((∑j∈Finset.range b,physicalLayerCost P (offset+j))-
        (b:ℝ)*subcriticalCostBaseline (physicalVariance P))/((physicalVariance P:ℝ)⁻¹-1))*
      dist ((states offset).feature x) ((states offset).feature y) := by
  have hh := actual_state_product_gain (fun j=>(states (offset+j)).feature)
    (fun j=>physicalLayerGain P (offset+j)) b
    (fun j hj=>(physicalLayerGain_pos P _).le)
    (fun j hj x y=>(hstep (offset+j) (by omega)).pair_gain x y) x y
  have hprod : (∏j∈Finset.range b,physicalLayerGain P (offset+j))≤
      Real.exp (((∑j∈Finset.range b,physicalLayerCost P (offset+j))-
        (b:ℝ)*subcriticalCostBaseline (physicalVariance P))/((physicalVariance P:ℝ)⁻¹-1)) := by
    have hp := Finset.prod_le_prod (s:=Finset.range b)
      (f:=fun j=>physicalLayerGain P (offset+j))
      (g:=fun j=>Real.exp ((physicalLayerCost P (offset+j)-subcriticalCostBaseline (physicalVariance P))/
        ((physicalVariance P:ℝ)⁻¹-1)))
      (fun j _=>(physicalLayerGain_pos P _).le)
      (fun j hj=>physicalLayerGain_le_raw_exp P (offset+j) (by have:=Finset.mem_range.mp hj;omega) ha)
    rw [←Real.exp_sum] at hp
    simpa only [←Finset.sum_div,Finset.sum_sub_distrib,Finset.sum_const,Finset.card_range,nsmul_eq_mul] using hp
  simp only [Nat.add_zero] at hh
  simpa only [dist_eq_norm] using hh.trans (mul_le_mul_of_nonneg_right hprod (norm_nonneg _))

#print axioms physical_path_good_block_cover
#print axioms physical_path_block_pair_gain
end ConditionalNonpolynomial.Analytic
