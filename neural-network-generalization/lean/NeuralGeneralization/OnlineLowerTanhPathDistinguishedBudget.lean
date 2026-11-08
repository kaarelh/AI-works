import NeuralGeneralization.OnlineLowerTanhPathDistinguished
import NeuralGeneralization.OnlineLowerTanhPathRoundingBudget

/-! # Distinguished-coefficient budgets at the actual logarithmic rails -/

noncomputable section
open scoped BigOperators Classical Topology
open Filter
namespace NeuralGeneralization.OnlineLowerTanh.Family
open OnlineLower OnlineLowerGeometry

theorem construction_dimension_polynomial_lt_cube (K : ℕ) (hK : 1≤K)
    (A : ℝ) (hA : 0≤A) (q : ℕ) :
    ∀ᶠ k : ℕ in atTop, A*(constructionDimension K k : ℝ)^q<(2 : ℝ)^(logicalDim k) := by
  let B : ℝ := A*(20000*(K : ℝ))^q
  have hlim : Tendsto (fun k : ℕ => B*((k : ℝ)^(3*q)*(1/64 : ℝ)^k)) atTop (𝓝 0) := by
    have hs := (summable_pow_mul_geometric_of_norm_lt_one (3*q)
      (show ‖(1/64 : ℝ)‖<1 by norm_num)).tendsto_atTop_zero.const_mul B
    simpa using hs
  have hsmall : ∀ᶠ k : ℕ in atTop, B*((k : ℝ)^(3*q)*(1/64 : ℝ)^k)<64 :=
    hlim.eventually (gt_mem_nhds (by norm_num : (0 : ℝ)<64))
  filter_upwards [hsmall, constructionDimension_le_cubic_eventually K hK] with k hk hd
  have hpoly : A*(constructionDimension K k : ℝ)^q≤B*(k : ℝ)^(3*q) := by
    have hp := pow_le_pow_left₀ (Nat.cast_nonneg (α:=ℝ) (constructionDimension K k)) hd q
    have hm := mul_le_mul_of_nonneg_left hp hA
    simpa only [B, mul_pow, ← pow_mul, mul_assoc] using hm
  have hpow : B*(k : ℝ)^(3*q)<64*(64 : ℝ)^k := by
    apply (div_lt_iff₀ (by positivity : (0 : ℝ)<64^k)).mp
    simpa only [div_pow, one_pow, div_eq_mul_inv, one_mul, mul_assoc, inv_pow] using hk
  have hm : (2 : ℝ)^(logicalDim k)=64*(64 : ℝ)^k := by
    rw [logicalDim_eq, pow_add, pow_mul]
    norm_num
    ring
  rw [hm]
  exact hpoly.trans_lt hpow

theorem construction_distinguished_bounds_eventually (b : ActualGainBranch)
    (K : ℕ) (hK : 1≤K) :
    ∀ᶠ k : ℕ in atTop,
      let R := constructionBaseline K k
      let H := constructionIncrement k
      let w := codeBalancedCost (physicalCode R H k
        (constructionBaseline_pos K k (by omega)) (constructionIncrement_pos k))
      let W := rectangleWeightTransform w (shiftPoint k)
      optimizedCostCurvature*(H : ℝ)^2/(4*(constructionDimension K k : ℝ)^3)≤W ∧
      W≤3*optimizedCostCurvature*(H : ℝ)^2/(4*((pairDim R H k : ℝ)*R+1)^3) ∧
      0<W ∧ 1/W≤(4/optimizedCostCurvature)*(constructionDimension K k : ℝ)^3 := by
  obtain ⟨S,hS,hbounds⟩ := codeBalancedCost_distinguished_bounds b
  filter_upwards [construction_path_order_budget K hK (max b.threshold (3*S)) 1 (by norm_num)] with k hk
  dsimp only
  apply hbounds _ _ k _ _ (constructionBaseline_even K k) (constructionIncrement_even k)
  · exact (le_max_left _ _).trans_lt hk.1
  · have hh := (le_max_right b.threshold (3*S)).trans_lt hk.1
    exact (by simpa only [Nat.cast_add, Nat.cast_mul, Nat.cast_one] using hh.le)

/-- The distinguished unnormalized transform eventually dominates sixteen
times the actual empty-support cost, including the exact cube cardinal. -/
theorem construction_distinguished_scale_eventually (b : ActualGainBranch)
    (K : ℕ) (hK : 1≤K) :
    ∀ᶠ k : ℕ in atTop,
      let R := constructionBaseline K k
      let H := constructionIncrement k
      let w := codeBalancedCost (physicalCode R H k
        (constructionBaseline_pos K k (by omega)) (constructionIncrement_pos k))
      16*w ∅≤walshExpansion w (shiftPoint k) := by
  have hC := optimizedCostCurvature_pos
  filter_upwards [construction_distinguished_bounds_eventually b K hK,
    construction_dimension_polynomial_lt_cube K hK (256/optimizedCostCurvature) (by positivity) 4] with k hw hpoly
  dsimp only at hw ⊢
  let R := constructionBaseline K k
  let H := constructionIncrement k
  let C := physicalCode R H k (constructionBaseline_pos K k (by omega)) (constructionIncrement_pos k)
  let w := codeBalancedCost C
  let d : ℝ := constructionDimension K k
  let M : ℝ := (2 : ℝ)^(logicalDim k)
  let W := rectangleWeightTransform w (shiftPoint k)
  have hd0 : 0<d := by dsimp [d]; exact_mod_cast constructionDimension_pos K k
  have hM0 : 0<M := by dsimp [M]; positivity
  have hweak : optimizedCostCurvature/(4*d^3)≤W := by
    have hH1 : (1 : ℝ)≤H := by
      exact_mod_cast Nat.succ_le_iff.mpr (constructionIncrement_pos k)
    have hsq : (1 : ℝ)≤(H : ℝ)^2 := by nlinarith
    have hnum := mul_le_mul_of_nonneg_left hsq hC.le
    have hh := div_le_div_of_nonneg_right hnum (show 0≤4*d^3 by positivity)
    simp only [mul_one] at hh
    exact hh.trans hw.1
  have hw0 : w ∅≤4*d := codeBalancedCost_le_four_dimension R H k _ _
    (constructionBaseline_even K k) (constructionIncrement_even k) ∅
  have hpoly' : 256*d^4≤M*optimizedCostCurvature := by
    have hh : (256*d^4)/optimizedCostCurvature<M := by
      change (256/optimizedCostCurvature)*d^4<M at hpoly
      convert hpoly using 1 <;> ring
    exact ((div_lt_iff₀ hC).mp hh).le
  have hscale : 64*d≤M*(optimizedCostCurvature/(4*d^3)) := by
    rw [← mul_div_assoc]
    apply (le_div_iff₀ (by positivity : 0<4*d^3)).mpr
    nlinarith only [hpoly']
  have hMW := mul_le_mul_of_nonneg_left hweak hM0.le
  have hMcard : M=(Fintype.card (ClippingCube (logicalDim k)) : ℝ) := by simp [M, ClippingCube]
  have hid : M*W=walshExpansion w (shiftPoint k) := by
    dsimp [W]
    rw [rectangleWeightTransform, ← hMcard, mul_div_cancel₀ _ hM0.ne']
  change 16*w ∅≤walshExpansion w (shiftPoint k)
  rw [← hid]
  linarith

end NeuralGeneralization.OnlineLowerTanh.Family
