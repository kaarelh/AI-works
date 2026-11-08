import NeuralGeneralization.OnlineLowerTanhPathAbsorption
import NeuralGeneralization.OnlineLowerTanhPathCap
import NeuralGeneralization.OnlineLowerTanhFamilyAssembly

/-! # Polynomial domination of the exact physical rectangle rounding budget -/

noncomputable section
open scoped BigOperators Classical Topology
open Filter
namespace NeuralGeneralization.OnlineLowerTanh.Family
open OnlineLower OnlineLowerGeometry

theorem pairBaseline_le_dimension (R H k : ℕ) :
    pairDim R H k*R≤dimension R H k := by
  have hl := support_card_lower R H k ∅
  have hu : (carrierSupport (size R H k) (column R H k) ∅).card≤dimension R H k := by
    simpa only [Fintype.card_fin] using Finset.card_le_univ
      (carrierSupport (size R H k) (column R H k) ∅)
  omega

theorem rectangleVarianceBudget_le_cubic (R H k : ℕ) (hR : 0<R) (hH : 0<H)
    (hc : RectangleCostConditions (familyCost R H k hR hH) (shiftPoint k)) :
    rectangleVarianceBudget R H k hR hH (20*(dimension R H k : ℝ))≤
      8295440*(dimension R H k : ℝ)^3 := by
  let d : ℝ := dimension R H k
  let a := rectangleCommonA (familyCost R H k hR hH) (shiftPoint k)
  have hd1 : 1≤d := by
    dsimp [d]
    exact_mod_cast (show 1≤dimension R H k from Nat.succ_le_iff.mpr (Nat.succ_pos _))
  have ha : 1≤a := rectangleCommonA_ge_one R H k hR hH hc
  have ha0 : 0<a := by linarith
  have hsqrt : Real.sqrt d≤d := by
    have hs := Real.sq_sqrt (show 0≤d by linarith)
    nlinarith [Real.sqrt_nonneg d]
  have hpr : ((pairDim R H k*R : ℕ) : ℝ)≤d := by
    dsimp [d]
    exact_mod_cast pairBaseline_le_dimension R H k
  have hpr2 : (((pairDim R H k*R : ℕ) : ℝ))^2≤d^2 := by
    nlinarith [Nat.cast_nonneg (α:=ℝ) (pairDim R H k*R)]
  have hd23 : d^2≤d^3 := by nlinarith [mul_nonneg (sq_nonneg d) (sub_nonneg.mpr hd1)]
  have hnum : 0≤16*((2*Real.sqrt d)*(20*d)) := by positivity
  have hdiv : 16*((2*Real.sqrt d)*(20*d))/a≤16*((2*Real.sqrt d)*(20*d)) := by
    apply (div_le_iff₀ ha0).mpr
    nlinarith [mul_nonneg hnum (sub_nonneg.mpr ha)]
  have hsqrtd : Real.sqrt d*d≤d^2 := by nlinarith [mul_le_mul_of_nonneg_right hsqrt (by linarith : 0≤d)]
  have hpr3 : (((pairDim R H k*R : ℕ) : ℝ))^2*d≤d^3 := by
    nlinarith [mul_le_mul_of_nonneg_right hpr2 (by linarith : 0≤d)]
  change 16*((2*Real.sqrt d)*(20*d))/a+5*(82948*(((pairDim R H k*R : ℕ) : ℝ))^2)*(20*d)≤8295440*d^3
  nlinarith only [hdiv,hsqrtd,hpr3,hd23]

theorem rectangle_rounding_polynomial_bound (R H k : ℕ) (hR : 0<R) (hH : 0<H)
    (hc : RectangleCostConditions (familyCost R H k hR hH) (shiftPoint k))
    (c : ℝ) (hc0 : 0≤c)
    (hstar : 1/rectangleWeightTransform (familyCost R H k hR hH) (shiftPoint k)≤
      c*(dimension R H k : ℝ)^3) :
    44*Fintype.card (ClippingCube (logicalDim k))*
      (1/rectangleWeightTransform (familyCost R H k hR hH) (shiftPoint k)+
        1/rectangleCommonA (familyCost R H k hR hH) (shiftPoint k))+
      4*(Fintype.card (ClippingCube (logicalDim k))*
        rectangleVarianceBudget R H k hR hH (20*(dimension R H k : ℝ)))≤
      (2 : ℝ)^(logicalDim k)*((44*c+34000000)*(dimension R H k : ℝ)^3) := by
  let d : ℝ := dimension R H k
  have hd1 : 1≤d := by
    dsimp [d]
    exact_mod_cast (show 1≤dimension R H k from Nat.succ_le_iff.mpr (Nat.succ_pos _))
  have hd3 : 1≤d^3 := by nlinarith [mul_nonneg (sq_nonneg (d-1)) (by linarith : 0≤d+2)]
  have ha := rectangleCommonA_ge_one R H k hR hH hc
  have hainv : 1/rectangleCommonA (familyCost R H k hR hH) (shiftPoint k)≤1 := by
    apply (div_le_iff₀ (by linarith : 0<rectangleCommonA _ _)).mpr
    linarith
  have hv := rectangleVarianceBudget_le_cubic R H k hR hH hc
  have hinner : 44*(1/rectangleWeightTransform (familyCost R H k hR hH) (shiftPoint k)+
        1/rectangleCommonA (familyCost R H k hR hH) (shiftPoint k))+
      4*rectangleVarianceBudget R H k hR hH (20*d)≤(44*c+34000000)*d^3 := by
    change rectangleVarianceBudget R H k hR hH (20*d)≤8295440*d^3 at hv
    change 1/rectangleWeightTransform _ _≤c*d^3 at hstar
    nlinarith
  have hh := mul_le_mul_of_nonneg_left hinner (by positivity : (0 : ℝ)≤2^(logicalDim k))
  simp only [ClippingCube, Fintype.card_fun, Fintype.card_bool, Fintype.card_fin,
    Nat.cast_pow, Nat.cast_ofNat]
  nlinarith only [hh]

end NeuralGeneralization.OnlineLowerTanh.Family
