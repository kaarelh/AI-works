import NeuralGeneralization.CubeFarPairs
import Mathlib.Analysis.SpecialFunctions.Pow.Asymptotics

/-! Uniform exponential sample ranges absorb actual IID near pairs and collisions. -/
noncomputable section
namespace NeuralGeneralization.CubeFarPairs
open Filter
open scoped Topology

lemma nearProbabilityBound_le_exp (d : ℕ) :
    nearProbabilityBound d≤2*Real.exp (-(d:ℝ)/16) := by
  have hl : Real.log (15/16:ℝ)≤ -(1/16:ℝ) := by
    have hh := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<15/16)
    norm_num at hh ⊢
    exact hh
  have he : (15/16:ℝ)^d≤Real.exp (-(d:ℝ)/16) := by
    rw [←Real.exp_log (by norm_num : (0:ℝ)<15/16),←Real.exp_nat_mul]
    apply Real.exp_le_exp.mpr
    nlinarith only [mul_le_mul_of_nonneg_left hl (Nat.cast_nonneg d (α:=ℝ))]
  exact (nearProbabilityBound_le d).trans (mul_le_mul_of_nonneg_left he (by norm_num))

lemma inverse_cube_card_le_exp (d : ℕ) :
    1/(Fintype.card (ClippingCube d):ℝ)≤Real.exp (-(d:ℝ)/16) := by
  have hl : (1:ℝ)/16≤Real.log 2 := by
    have hh := Real.one_sub_inv_le_log_of_pos (by norm_num : (0:ℝ)<2)
    norm_num at hh ⊢
    linarith
  simp only [ClippingCube,Fintype.card_fun,Fintype.card_bool,Fintype.card_fin,Nat.cast_pow,Nat.cast_ofNat]
  rw [←Real.exp_log (by norm_num : (0:ℝ)<2),←Real.exp_nat_mul,one_div,←Real.exp_neg]
  apply Real.exp_le_exp.mpr
  nlinarith only [mul_le_mul_of_nonneg_left hl (Nat.cast_nonneg d (α:=ℝ))]

/-- The estimate is uniform over every natural sample count in this
exponential range. In particular it retains actual IID collisions. -/
theorem eventually_near_and_collision_small :
    ∀ᶠ d : ℕ in atTop,∀ n : ℕ,4≤n →(n:ℝ)≤Real.exp ((d:ℝ)/128) →
      2*n≤Fintype.card (ClippingCube d) ∧
      (n:ℝ)*nearProbabilityBound d≤1 ∧
      (n:ℝ)*((n:ℝ)-1)/(Fintype.card (ClippingCube d):ℝ)+
        (n:ℝ)^2*nearProbabilityBound d≤1/32 := by
  have ht : Tendsto (fun d : ℕ=>Real.exp (-((3/64:ℝ)*(d:ℝ)))) atTop (nhds 0) :=
    Real.tendsto_exp_neg_atTop_nhds_zero.comp
      ((tendsto_natCast_atTop_atTop : Tendsto (fun d : ℕ=>(d:ℝ)) atTop atTop).const_mul_atTop (by norm_num))
  filter_upwards [ht.eventually (gt_mem_nhds (by norm_num : (0:ℝ)<1/128))] with d hd n hn hnmax
  have hn0 : (0:ℝ)≤n := Nat.cast_nonneg n
  have hn4 : (4:ℝ)≤n := by exact_mod_cast hn
  have hn2 : (n:ℝ)^2≤Real.exp ((d:ℝ)/64) := by
    have hh := (sq_le_sq₀ hn0 (Real.exp_pos _).le).mpr hnmax
    rw [←Real.exp_nat_mul] at hh
    convert hh using 1
    congr 1
    norm_num
    ring
  have hprod : (n:ℝ)^2*Real.exp (-(d:ℝ)/16)≤Real.exp (-((3/64:ℝ)*(d:ℝ))) := by
    calc
      _ ≤ Real.exp ((d:ℝ)/64)*Real.exp (-(d:ℝ)/16) :=
        mul_le_mul_of_nonneg_right hn2 (Real.exp_pos _).le
      _ = _ := by rw [←Real.exp_add]; congr 1 <;> ring
  have hcol : (n:ℝ)^2/(Fintype.card (ClippingCube d):ℝ)≤1/128 := by
    calc
      _ = (n:ℝ)^2*(1/(Fintype.card (ClippingCube d):ℝ)) := by ring
      _ ≤ (n:ℝ)^2*Real.exp (-(d:ℝ)/16) := mul_le_mul_of_nonneg_left (inverse_cube_card_le_exp d) (sq_nonneg _)
      _ ≤ _ := hprod.trans hd.le
  have hnear : (n:ℝ)^2*nearProbabilityBound d≤1/64 := by
    have hh := mul_le_mul_of_nonneg_left (nearProbabilityBound_le_exp d) (sq_nonneg (n:ℝ))
    nlinarith only [hh,hprod,hd]
  have hM : (0:ℝ)<Fintype.card (ClippingCube d) := by positivity
  have hnmR : 2*(n:ℝ)≤Fintype.card (ClippingCube d) := by
    have hh := (div_le_iff₀ hM).mp hcol
    nlinarith only [hh,hn4]
  have hnear1 : (n:ℝ)*nearProbabilityBound d≤1 := by
    have hh := mul_le_mul_of_nonneg_right (show (n:ℝ)≤(n:ℝ)^2 by nlinarith only [hn4])
      (nearProbabilityBound_nonneg d)
    linarith only [hh,hnear]
  refine ⟨by exact_mod_cast hnmR,hnear1,?_⟩
  have hcol' : (n:ℝ)*((n:ℝ)-1)/(Fintype.card (ClippingCube d):ℝ)≤1/128 := by
    exact (div_le_div_of_nonneg_right (by nlinarith only [hn0] :
      (n:ℝ)*((n:ℝ)-1)≤(n:ℝ)^2) hM.le).trans hcol
  linarith only [hcol',hnear]

end NeuralGeneralization.CubeFarPairs
