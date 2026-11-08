import NeuralGeneralization.OnlineLowerTanhPrefixPositive
import NeuralGeneralization.OnlineLowerTanhPathRoundingBudget

/-! # Actual logarithmic rail thresholds for every live scalar coefficient -/
noncomputable section
open scoped BigOperators Classical Topology
open Filter
namespace NeuralGeneralization.OnlineLowerTanh.Family
open OnlineLower OnlineLowerGeometry

/-- The actual rail baseline eventually dominates every fixed linear
threshold in the complete number of physical columns. -/
theorem construction_scalar_dimension_budget (K:ℕ) (hK:1≤K) (T S:ℝ) (hS:0<S) :
    ∀ᶠk:ℕ in atTop,
      T<((pairDim (constructionBaseline K k) (constructionIncrement k) k*
        constructionBaseline K k+1:ℕ):ℝ) ∧
      S*(pairDim (constructionBaseline K k) (constructionIncrement k) k+1:ℕ)≤
        (pairDim (constructionBaseline K k) (constructionIncrement k) k:ℝ)*
          constructionBaseline K k+1 := by
  filter_upwards [constructionBaseline_eventually_ge K hK (max (2*S) (T+1))] with k hk
  let R:=constructionBaseline K k
  let H:=constructionIncrement k
  let p:=pairDim R H k
  have hp:1≤p:=by
    dsimp [p,pairDim]
    rw [OnlineLowerRelu.Family.pairDim_eq]
    omega
  have hpR:(1:ℝ)≤p:=by exact_mod_cast hp
  have hR:2*S≤(R:ℝ):=(le_max_left _ _).trans hk
  have hT:T+1≤(R:ℝ):=(le_max_right _ _).trans hk
  have hRp:(R:ℝ)≤(p:ℝ)*R:=by
    nlinarith [mul_nonneg (sub_nonneg.mpr hpR) (Nat.cast_nonneg (α:=ℝ) R)]
  constructor
  · change T<((p*R+1:ℕ):ℝ)
    push_cast
    linarith
  · change S*(p+1:ℕ)≤(p:ℝ)*R+1
    push_cast
    have hh:=mul_le_mul_of_nonneg_left hR (Nat.cast_nonneg (α:=ℝ) p)
    nlinarith

/-- All live-coset signs and the uniform prefix envelope hold for the
literal balanced neural costs at every sufficiently large family index. -/
theorem construction_live_scalar_eventually (b:ActualGainBranch) (K:ℕ) (hK:1≤K) :
    ∀ᶠk:ℕ in atTop,∀endpoint:Bool,∀z:ClippingCube (logicalDim k),
      cubeTranslation (referencePoint k endpoint) z∈(calibrationSubgroup k).carrier →
      let w:=familyCost (constructionBaseline K k) (constructionIncrement k) k
        (constructionBaseline_pos K k (by omega)) (constructionIncrement_pos k)
      0<rectangleWeightTransform w z ∧
      rectangleWeightTransform w z<rectangleWeightTransform w (cubeTranslation (shiftPoint k) z) ∧
      rectangleEffectiveCost w (shiftPoint k) z<0 ∧
      |rectangleEffectiveCost w (shiftPoint k) z|≤constructionPrefixEnvelope K k := by
  obtain ⟨S₁,hS₁,horder⟩:=codeBalancedCost_live_order b
  obtain ⟨S₂,hS₂,henvelope⟩:=codeBalancedCost_live_envelope b
  filter_upwards [construction_scalar_dimension_budget K hK b.threshold S₁ hS₁,
    construction_scalar_dimension_budget K hK b.threshold S₂ hS₂,
    constructionBaseline_eventually_ge K hK 6] with k ho he hR6
  intro endpoint z hz
  dsimp only
  let R:=constructionBaseline K k
  let H:=constructionIncrement k
  have hR:0<R:=constructionBaseline_pos K k (by omega)
  have hH:0<H:=constructionIncrement_pos k
  have hR6':6≤R:=by exact_mod_cast hR6
  have hsign:=horder R H k hR hH hR6' (constructionBaseline_even K k)
    (constructionIncrement_even k) ho.1 ho.2 endpoint z hz
  refine ⟨hsign.1,hsign.2,?_,?_⟩
  · change rectangleEffectiveCost (codeBalancedCost (physicalCode R H k hR hH)) (shiftPoint k) z<0
    have hh:rectangleEffectiveCost (codeBalancedCost (physicalCode R H k hR hH)) (shiftPoint k) z=
      rectangleWeightTransform (codeBalancedCost (physicalCode R H k hR hH)) z-
      rectangleWeightTransform (codeBalancedCost (physicalCode R H k hR hH))
        (cubeTranslation (shiftPoint k) z):=by
      unfold rectangleEffectiveCost rectangleWeightTransform
      ring
    rw [hh]
    linarith [hsign.2]
  · apply henvelope R H k hR hH (constructionBaseline_even K k)
      (constructionIncrement_even k) he.1 _ endpoint z hz
    have hp:OnlineLowerRelu.Family.prefixDim k+1≤pairDim R H k+1:=by
      have hh:=prefixDim_le_pairDim R H k
      omega
    have hpR:((OnlineLowerRelu.Family.prefixDim k+1:ℕ):ℝ)≤(pairDim R H k+1:ℕ):=by
      exact_mod_cast hp
    have hh:=mul_le_mul_of_nonneg_left hpR hS₂.le
    have hH0:(0:ℝ)≤H:=Nat.cast_nonneg _
    have hb:S₂*(pairDim R H k+1:ℕ)≤(pairDim R H k:ℝ)*R+1:=he.2
    linarith

end NeuralGeneralization.OnlineLowerTanh.Family
