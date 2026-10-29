import PhysicalEntropySplitCompression
import PhysicalNormalizedLayer
import DisjointBlockAccounting

/-! Actual feature radii for uniform canonical paths. Original state occupation
controls physical radii, while sharp gain normalization controls every
normalized state independently of tiny physical scales. -/
noncomputable section
set_option maxHeartbeats 2200000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel
variable {d H : ℕ} {t : ℝ} {f : BooleanFunction d}

lemma PhysicalCanonicalProgramStep.norm_le_physical_gain
    {P : ControlledMarginPath d H t f} {S : Finset (Cube d)} {j : ℕ}
    {B C : CanonicalProgramState d} (hstep : PhysicalCanonicalProgramStep P S j B C) (x : Cube d) :
    ‖C.feature x‖≤physicalLayerGain P j*‖B.feature x‖ := by
  classical
  obtain ⟨M,hM⟩ := hstep.layerModel
  have hzero : M.value 0=0 := by simp [CanonicalLayerModel.value,canonicalGaussianMap_zero]
  have hh := M.physical_value_lipschitz P.scale_positive.le M.preconditioner_sharp_bound (B.feature x) 0
  simp only [smul_zero,hzero,sub_zero] at hh
  rw [hM,physicalLayerGain_eq]
  exact hh

lemma physical_canonical_norm_gain (P : ControlledMarginPath d H t f) (hd : 1≤d)
    (S : Finset (Cube d)) (states : ℕ→CanonicalProgramState d)
    (hzero : ∀x y,inner ℝ ((states 0).feature x) ((states 0).feature y)=
      inner ℝ (normalizedInputFeature d x) (normalizedInputFeature d y))
    (hstep : ∀j<H,PhysicalCanonicalProgramStep P S j (states j) (states (j+1))) :
    ∀j≤H,∀x,‖(states j).feature x‖≤Real.sqrt 2*physicalGainProduct P j := by
  intro j
  induction j with
  | zero=>
    intro hj x
    rw [physicalGainProduct_zero,mul_one]
    apply Real.le_sqrt_of_sq_le
    rw [←real_inner_self_eq_norm_sq,hzero,real_inner_self_eq_norm_sq]
    exact normalizedInputFeature_norm_sq_le_two hd x
  | succ j ih=>
    intro hj x
    have hh := (hstep j (by omega)).norm_le_physical_gain x
    have hm := mul_le_mul_of_nonneg_left (ih (by omega) x) (physicalLayerGain_pos P j).le
    rw [physicalGainProduct_succ]
    nlinarith only [hh,hm]

lemma physical_canonical_max_variance_gain (P : ControlledMarginPath d H t f) (hd : 1≤d)
    (S : Finset (Cube d)) (states : ℕ→CanonicalProgramState d)
    (hzero : ∀x y,inner ℝ ((states 0).feature x) ((states 0).feature y)=
      inner ℝ (normalizedInputFeature d x) (normalizedInputFeature d y))
    (hstep : ∀j<H,PhysicalCanonicalProgramStep P S j (states j) (states (j+1)))
    (j : ℕ) (hj : j≤H) :
    maxFeatureVariance (states j).feature≤2*(physicalGainProduct P j)^2 := by
  have hh := pow_le_pow_left₀ (norm_nonneg _)
    (physical_canonical_norm_gain P hd S states hzero hstep j hj (featureMaximizer (states j).feature)) 2
  simpa only [maxFeatureVariance,real_inner_self_eq_norm_sq,mul_pow,Real.sq_sqrt (by norm_num : (0:ℝ)≤2)] using hh

lemma queryFeatureClose_variance {I J : Type*} [Fintype I] [Fintype J]
    (A : Cube d→EuclideanSpace ℝ I) (B : Cube d→EuclideanSpace ℝ J) (S : Finset (Cube d)) {ε : ℝ} (hε : 0≤ε)
    (hquery : ∀x,QueryFeatureClose A B S x ε) :
    maxFeatureVariance B≤2*maxFeatureVariance A+2*ε^2 := by
  let x := featureMaximizer B
  have hn := (hquery x).norm_le
  have hsq := pow_le_pow_left₀ (norm_nonneg (B x)) hn 2
  have hv := feature_variance_le_max A x
  simp only [maxFeatureVariance,real_inner_self_eq_norm_sq] at hv ⊢
  change ‖B x‖^2≤_
  nlinarith [sq_nonneg (‖A x‖-ε)]

/-- Query compression transfers the original prefix occupation to the
actual canonical states without paying raw Gaussian row cost. -/
theorem physical_canonical_prefix_nonlinear_budget
    (P : ControlledMarginPath d H t f) (hd : 1≤d)
    (S : Finset (Cube d)) (states : ℕ→CanonicalProgramState d)
    {J : ℕ} (hJ : J≤H) {ε : ℝ} (hε : 0≤ε)
    (hquery : ∀j<J,∀x,QueryFeatureClose (P.feature j) (states j).feature S x ε)
    (ng : ℕ→ℝ) (hng : ∀j<J,ng j≤physicalAdjustedCost P j) :
    (∑j∈Finset.range J,(maxFeatureVariance (states j).feature+Real.sqrt (ng j)))≤
      4+2*(physicalPrefixOccupationConstant+1)*(Real.log ((J:ℝ)+2)+
        Real.sqrt ((J:ℝ)*(∑j∈Finset.range J,physicalAdjustedCost P j)))+2*(J:ℝ)*ε^2 := by
  have hpoint (j : ℕ) (hj : j∈Finset.range J) :
      maxFeatureVariance (states j).feature+Real.sqrt (ng j)≤
        2*(physicalMaxVariance P j+Real.sqrt (physicalAdjustedCost P j))+2*ε^2 := by
    have hv := queryFeatureClose_variance (P.feature j) (states j).feature S hε
      (hquery j (Finset.mem_range.mp hj))
    have hn := Real.sqrt_le_sqrt (hng j (Finset.mem_range.mp hj))
    change _≤2*(maxFeatureVariance (P.feature j)+Real.sqrt (physicalAdjustedCost P j))+2*ε^2
    nlinarith [Real.sqrt_nonneg (physicalAdjustedCost P j)]
  have hs := Finset.sum_le_sum hpoint
  simp only [Finset.sum_add_distrib,←Finset.mul_sum,Finset.sum_const,Finset.card_range,nsmul_eq_mul] at hs
  have ho := physical_prefix_nonlinear_occupation P hd hJ
  rw [Finset.sum_add_distrib] at ho ⊢
  nlinarith only [hs,ho]

#print axioms physical_canonical_prefix_nonlinear_budget
#print axioms physical_canonical_norm_gain
end ConditionalNonpolynomial.Analytic
