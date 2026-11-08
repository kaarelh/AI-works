import NeuralGeneralization.OnlineLowerTanhPathBudget
import NeuralGeneralization.OnlineLowerTanhPrefixEnvelope
import Mathlib.Analysis.SpecificLimits.Normed

/-! # Prefix suppression beats every polynomial physical calibration cost

The estimate uses the actual logarithmic rails and all repeated physical
columns. No asymptotic premise remains in the exported statements.
-/

noncomputable section
open scoped BigOperators Topology
open Filter
namespace NeuralGeneralization.OnlineLowerTanh.Family
open OnlineLower

def constructionPrefixEnvelope (K k : ℕ) : ℝ :=
  tanhPrefixEnvelope (OnlineLowerRelu.Family.prefixDim k)
    ((pairDim (constructionBaseline K k) (constructionIncrement k) k : ℝ)*
      constructionBaseline K k+1+constructionIncrement k)

theorem constructionPrefixEnvelope_pos (K k : ℕ) :
    0<constructionPrefixEnvelope K k := by
  apply tanhPrefixEnvelope_pos
  positivity

theorem family_prefix_fixed_geometric (R H k : ℕ) (hR : 16≤R) :
    tanhPrefixEnvelope (OnlineLowerRelu.Family.prefixDim k) ((pairDim R H k : ℝ)*R+1+H)≤
      (3*optimizedCostCurvature/2)*(1/8 : ℝ)^(OnlineLowerRelu.Family.prefixDim k) := by
  let n : ℝ := (pairDim R H k : ℝ)*R+1+H
  have hn : 1≤n := by
    dsimp [n]
    have hp : (0 : ℝ)≤(pairDim R H k : ℝ)*R := by positivity
    linarith [Nat.cast_nonneg (α:=ℝ) H]
  have hn0 : 0<n := by linarith
  have hC := optimizedCostCurvature_pos
  have hRR : (16 : ℝ)≤R := by exact_mod_cast hR
  have hratio : 2/(R : ℝ)≤1/8 := by
    apply (div_le_iff₀ (by linarith : (0 : ℝ)<R)).mpr
    linarith
  have hpre : 3*optimizedCostCurvature/(2*n)≤3*optimizedCostCurvature/2 := by
    apply (div_le_iff₀ (by positivity : 0<2*n)).mpr
    nlinarith [mul_nonneg hC.le (sub_nonneg.mpr hn)]
  exact (tanhPrefixEnvelope_family_geometric R H k (by omega)).trans
    (mul_le_mul hpre (pow_le_pow_left₀ (by positivity) hratio _)
      (by positivity) (by positivity))

/-- The factor `2^m` from finite rounding is fully included. -/
theorem construction_prefix_polynomial_absorption (K : ℕ) (hK : 1≤K)
    (A : ℝ) (hA : 0≤A) (q : ℕ) :
    ∀ᶠ k : ℕ in atTop,
      constructionPrefixEnvelope K k * (2 : ℝ)^(logicalDim k) * (A*(k : ℝ)^q)<1 := by
  let C : ℝ := 3*optimizedCostCurvature*A/16
  have hlim : Tendsto (fun k : ℕ => C*((k : ℝ)^q*(1/64 : ℝ)^k)) atTop (𝓝 0) := by
    have hs := (summable_pow_mul_geometric_of_norm_lt_one q
      (show ‖(1/64 : ℝ)‖<1 by norm_num)).tendsto_atTop_zero.const_mul C
    simpa using hs
  have hsmall : ∀ᶠ k : ℕ in atTop, C*((k : ℝ)^q*(1/64 : ℝ)^k)<1 :=
    hlim.eventually (gt_mem_nhds (by norm_num : (0 : ℝ)<1))
  filter_upwards [hsmall, constructionBaseline_eventually_ge K hK 16] with k hk hR
  have hbase : 16≤constructionBaseline K k := by exact_mod_cast hR
  have henv := family_prefix_fixed_geometric (constructionBaseline K k) (constructionIncrement k) k hbase
  change constructionPrefixEnvelope K k≤_ at henv
  have hp : (1/8 : ℝ)^(OnlineLowerRelu.Family.prefixDim k)=
      (1/8 : ℝ)^3*((1/8 : ℝ)^4)^k := by
    unfold OnlineLowerRelu.Family.prefixDim
    rw [pow_add, pow_mul]
    ring
  have hm : (2 : ℝ)^(logicalDim k)=64*(64 : ℝ)^k := by
    rw [logicalDim_eq, pow_add, pow_mul]
    norm_num
    ring
  have he : (3*optimizedCostCurvature/2)*(1/8 : ℝ)^(OnlineLowerRelu.Family.prefixDim k)*
      (2 : ℝ)^(logicalDim k)*(A*(k : ℝ)^q)=C*((k : ℝ)^q*(1/64 : ℝ)^k) := by
    rw [hp, hm]
    have hc : ((1/8 : ℝ)^4)^k*(64 : ℝ)^k=(1/64 : ℝ)^k := by
      rw [← mul_pow]
      norm_num
    calc
      _ = (3*optimizedCostCurvature*A/16)*(k : ℝ)^q*
        (((1/8 : ℝ)^4)^k*(64 : ℝ)^k) := by ring
      _ = _ := by rw [hc]; dsimp [C]; ring
  have hprod := mul_le_mul_of_nonneg_right
    (mul_le_mul_of_nonneg_right henv (by positivity : (0 : ℝ)≤2^(logicalDim k)))
    (mul_nonneg hA (pow_nonneg (Nat.cast_nonneg k) q))
  rw [he] at hprod
  exact hprod.trans_lt hk

theorem constructionDimension_le_cubic_eventually (K : ℕ) (hK : 1≤K) :
    ∀ᶠ k : ℕ in atTop, (constructionDimension K k : ℝ)≤20000*(K : ℝ)*(k : ℝ)^3 := by
  filter_upwards [log_nat_eventually_ge 1, eventually_ge_atTop 2] with k hlog hk
  have hb := (construction_resource_bounds K k hK hk hlog).2.1
  have hkn : (0 : ℝ)<k := Nat.cast_pos.mpr (by omega)
  have hlogle : Real.log (k : ℝ)≤k := (Real.log_le_sub_one_of_pos hkn).trans (by linarith)
  have hsq : Real.log (k : ℝ)^2≤(k : ℝ)^2 := by nlinarith
  have hm := mul_le_mul_of_nonneg_left hsq (by positivity : (0 : ℝ)≤20000*K*k)
  nlinarith only [hb,hm]

/-- A dimension-polynomial rounding multiplier is absorbed by the actual
all-prefix Fourier envelope. This applies to the physical variance budget. -/
theorem construction_prefix_dimension_absorption (K : ℕ) (hK : 1≤K)
    (A : ℝ) (hA : 0≤A) (q : ℕ) :
    ∀ᶠ k : ℕ in atTop,
      constructionPrefixEnvelope K k * (2 : ℝ)^(logicalDim k) *
        (A*(constructionDimension K k : ℝ)^q)<1 := by
  filter_upwards [construction_prefix_polynomial_absorption K hK
    (A*(20000*(K : ℝ))^q) (by positivity) (3*q),
    constructionDimension_le_cubic_eventually K hK] with k hsmall hd
  have hp := pow_le_pow_left₀ (Nat.cast_nonneg (α:=ℝ) (constructionDimension K k)) hd q
  have hbound : A*(constructionDimension K k : ℝ)^q≤
      (A*(20000*(K : ℝ))^q)*(k : ℝ)^(3*q) := by
    have hh := mul_le_mul_of_nonneg_left hp hA
    simpa only [mul_pow, ← pow_mul, mul_assoc] using hh
  exact (mul_le_mul_of_nonneg_left hbound
    (mul_nonneg (constructionPrefixEnvelope_pos K k).le (by positivity))).trans_lt hsmall

end NeuralGeneralization.OnlineLowerTanh.Family
