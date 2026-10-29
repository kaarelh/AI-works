import PhysicalNormalizedRepresentativeCover

noncomputable section
set_option maxHeartbeats 2400000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
attribute [local instance] Classical.propDecidable
open NeuralGeneralization.ConcreteModel

def longCoverEnergy : ℝ := longBlockSpan*longBlockGaussianThreshold
def longCoverNonlinearThreshold : ℝ :=
  longBlockMinimumGain/(16*canonicalBlockNonlinearBound longCoverEnergy)
lemma longCoverNonlinearThreshold_pos : 0<longCoverNonlinearThreshold :=
  div_pos longBlockMinimumGain_pos (mul_pos (by norm_num) (canonicalBlockNonlinearBound_pos _))

def longCoverGridT : ℕ := Classical.choose
  (physical_good_block_grid_exists longCoverEnergy longBlockMinimumGain longBlockMinimumGain_pos)
def longCoverGridK : ℕ := Classical.choose (Classical.choose_spec
  (physical_good_block_grid_exists longCoverEnergy longBlockMinimumGain longBlockMinimumGain_pos))
lemma longCoverGrid_spec : 0<longCoverGridT ∧
    (canonicalBlockHSBound longCoverEnergy)^2≤(longBlockMinimumGain/64)^2*longCoverGridK ∧
    ∀Q:ℝ,0≤Q→Q≤(canonicalBlockHSBound longCoverEnergy)^2→
      Real.sqrt (Q/(longCoverGridT:ℝ)^2+(longBlockMinimumGain/64)^2)≤longBlockMinimumGain/32 :=
  Classical.choose_spec (Classical.choose_spec
    (physical_good_block_grid_exists longCoverEnergy longBlockMinimumGain longBlockMinimumGain_pos))
def longCoverCardFactor : ℕ := (2*longCoverGridT+1)^longCoverGridK
lemma longCoverCardFactor_one_le : 1≤longCoverCardFactor := one_le_pow₀ (by omega)

variable {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
variable {P : ControlledMarginPath d H t f} {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}
def longPhysicalBlockLength (P : ControlledMarginPath d H t f) : ℕ :=
  ⌈longBlockContraction/((physicalVariance P:ℝ)⁻¹-1)⌉₊
def longPhysicalGoodBlock
    (hstep : ∀j<H,PhysicalEntropySplitStep P S j (states j) (states (j+1))) (ε : ℝ) (i : ℕ) : Prop :=
  disjointBlockCost (physicalLayerCost P) 0 (longPhysicalBlockLength P) i≤
    longBlockGaussianThreshold*((physicalVariance P:ℝ)⁻¹-1) ∧
  disjointBlockCost (pathNonlinearCost hstep ε) 0 (longPhysicalBlockLength P) i≤longCoverNonlinearThreshold

 theorem physical_long_block_normalized_cover
    (hd : 1≤d)
    (hzero : ∀x y,inner ℝ ((states 0).feature x) ((states 0).feature y)=
      inner ℝ (normalizedInputFeature d x) (normalizedInputFeature d y))
    (hstep : ∀j<H,PhysicalEntropySplitStep P S j (states j) (states (j+1)))
    {ε : ℝ} (hε : 0<ε) (n : ℕ) (hfit : n*longPhysicalBlockLength P≤H)
    (ha : 0<(physicalVariance P:ℝ)⁻¹-1) (ha1 : (physicalVariance P:ℝ)⁻¹-1≤1/4)
    {E : ℝ} (hE : (∑j∈Finset.range (n*longPhysicalBlockLength P),physicalAdjustedCost P j)≤E) :
    IndexedActualBallCover
      (fun x=>(physicalGainProduct P (n*longPhysicalBlockLength P))⁻¹ •
        (states (n*longPhysicalBlockLength P)).feature x)
      (longCoverCardFactor^n)
      (2*Real.sqrt 2*Real.exp (E/((physicalVariance P:ℝ)⁻¹-1)-
        (((Finset.range n).filter (longPhysicalGoodBlock hstep ε)).card:ℝ))) := by
  classical
  let a := (physicalVariance P:ℝ)⁻¹-1
  let b := longPhysicalBlockLength P
  have hc : 0<longBlockContraction := by norm_num [longBlockContraction]
  obtain ⟨hb,_,hba⟩ := ceiling_block_length ha hc
  have hspan : a*(b:ℝ)≤longBlockSpan := by
    dsimp only [b,longPhysicalBlockLength]
    unfold longBlockSpan
    linarith
  have hcost : ∀i<n,longPhysicalGoodBlock hstep ε i→
      (b:ℝ)*disjointBlockCost (physicalLayerCost P) 0 b i≤longCoverEnergy := by
    intro i hi hg
    have hh := mul_le_mul_of_nonneg_left hg.1 (Nat.cast_nonneg b)
    have hs := mul_le_mul_of_nonneg_left hspan
      (show 0≤longBlockGaussianThreshold by norm_num [longBlockGaussianThreshold,longBlockSpan,longBlockContraction])
    dsimp only [longCoverEnergy]
    nlinarith only [hh,hs]
  have hfree : t^b≤longBlockMinimumGain/32 :=
    longBlock_actual_free P.scale_positive ha ha1 (by simp [a])
  have hminimum : ∀i<n,longBlockMinimumGain≤Real.exp
      ((disjointBlockCost (physicalLayerCost P) 0 b i-(b:ℝ)*subcriticalCostBaseline (physicalVariance P))/a-1) := by
    intro i hi
    apply longBlock_actual_minimum_gain ha ha1
      (subcriticalCostBaseline_quarter (physicalVariance_ne_zero P) (physicalVariance_le_one P))
    exact Finset.sum_nonneg (fun j hj=>ENNReal.toReal_nonneg)
  have hcover := physical_indexed_block_cover hd hzero hstep hε b n (by simpa only [b,longPhysicalBlockLength] using (Nat.succ_le_iff.mpr hb)) hfit ha
    (longPhysicalGoodBlock hstep ε) longBlockMinimumGain_pos longCoverGridT longCoverGridK
    longCoverGrid_spec.1 longCoverGrid_spec.2.1 longCoverGrid_spec.2.2 hcost hfree
    (fun i hi hg=>hg.2) hminimum
  exact (hcover.normalized (physicalGainProduct_pos P _)).radius_mono
    (physical_representativeRadius_normalized P b n hfit ha (longPhysicalGoodBlock hstep ε) hE)

#print axioms physical_long_block_normalized_cover
end ConditionalNonpolynomial.Analytic
