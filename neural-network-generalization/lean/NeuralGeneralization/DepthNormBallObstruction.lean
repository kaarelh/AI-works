import NeuralGeneralization.DepthNormBallMain
import Mathlib.Analysis.SpecificLimits.Normed

/-! The appendix's obstruction to a jointly polynomial, width-uniform counting bound. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators Topology
namespace NeuralGeneralization.DepthNormBall
open Classical ConcreteModel Filter

def linearDepthBudget (d : ℕ) : ℝ := 1000*(d:ℝ)^3*(Real.log (2*(d:ℝ)))^2

lemma log_dimension_lower {d : ℕ} (hd : 2 ≤ d) : (1/2:ℝ)≤Real.log (2*(d:ℝ)) := by
  have hdR : (2:ℝ)≤d := by exact_mod_cast hd
  have hh := Real.one_sub_inv_le_log_of_pos (by norm_num : (0:ℝ)<2)
  norm_num at hh
  exact hh.trans (Real.log_le_log (by norm_num) (by linarith))

lemma linearDepthBudget_sufficient {d : ℕ} (hd : 2 ≤ d) :
    200*((d:ℝ)^3*(Real.log (2*(d:ℝ)))^2+4*d) ≤ linearDepthBudget d := by
  have hdR : (2:ℝ)≤d := by exact_mod_cast hd
  have hlog := log_dimension_lower hd
  have hsq : (1:ℝ)≤(d:ℝ)^2*(Real.log (2*(d:ℝ)))^2 := by
    have hd2 : (4:ℝ)≤(d:ℝ)^2 := by nlinarith
    have hl2 : (1/4:ℝ)≤(Real.log (2*(d:ℝ)))^2 := by nlinarith
    nlinarith [mul_le_mul hd2 hl2 (by norm_num) (sq_nonneg (d:ℝ))]
  have hm := mul_le_mul_of_nonneg_left hsq (Nat.cast_nonneg d : (0:ℝ)≤d)
  unfold linearDepthBudget
  nlinarith

lemma linearDepthBudget_nonneg (d : ℕ) : 0 ≤ linearDepthBudget d := by
  unfold linearDepthBudget
  positivity

lemma linearDepthBudget_polynomial {d : ℕ} (hd : 2 ≤ d) :
    linearDepthBudget d ≤ 4000*(d:ℝ)^5 := by
  have hdR : (2:ℝ)≤d := by exact_mod_cast hd
  have hl : Real.log (2*(d:ℝ)) ≤ 2*d := by
    have hh := Real.log_le_sub_one_of_pos (show 0<2*(d:ℝ) by positivity)
    linarith
  have hl0 : 0 ≤ Real.log (2*(d:ℝ)) := by linarith [log_dimension_lower hd]
  have hs := (sq_le_sq₀ hl0 (by positivity)).mpr hl
  have hm := mul_le_mul_of_nonneg_left hs (show 0≤1000*(d:ℝ)^3 by positivity)
  unfold linearDepthBudget
  nlinarith

/-- Every function is represented at the exact asymptotic budget printed in the paper. -/
theorem all_functions_logarithmic_budget {d N : ℕ} (hd : 2 ≤ d) (hN : 2^(d+1) ≤ N)
    (f : BooleanFunction d) :
    ∃ w : Weights d N d, (∀ x,networkOutput Real.tanh w x=labelReal (f x)) ∧
      weightedSquaredNorm w ≤ linearDepthBudget d := by
  obtain ⟨w,hw,hcost⟩ := all_functions_linear_depth hd hN f
  exact ⟨w,hw,hcost.trans (linearDepthBudget_sufficient hd)⟩

lemma logarithmic_budget_card {d N : ℕ} (hd : 2 ≤ d) (hN : 2^(d+1) ≤ N) :
    (ParameterSensitivity.normBallFunctions d N d Real.tanh (Real.sqrt (linearDepthBudget d))).card=2^(2^d) := by
  have he : ParameterSensitivity.normBallFunctions d N d Real.tanh (Real.sqrt (linearDepthBudget d))=Finset.univ := by
    apply Finset.eq_univ_of_forall
    intro f
    obtain ⟨w,hw,hcost⟩ := all_functions_logarithmic_budget hd hN f
    exact exact_network_mem_normBall w f hw hcost
  rw [he]
  simp [BooleanFunction,Cube]

lemma logarithmic_budget_log_card {d N : ℕ} (hd : 2 ≤ d) (hN : 2^(d+1) ≤ N) :
    Real.log ((ParameterSensitivity.normBallFunctions d N d Real.tanh
      (Real.sqrt (linearDepthBudget d))).card:ℝ)=(2:ℝ)^d*Real.log 2 := by
  rw [logarithmic_budget_card hd hN]
  push_cast
  rw [Real.log_pow]
  push_cast
  rfl

lemma joint_budget_polynomial {d : ℕ} (hd : 2 ≤ d) :
    (d:ℝ)+linearDepthBudget d+((d:ℝ)+2)+1 ≤ 4004*(d:ℝ)^5 := by
  have hdR : (2:ℝ)≤d := by exact_mod_cast hd
  have hp : (d:ℝ)≤(d:ℝ)^5 := by
    simpa only [pow_one] using pow_le_pow_right₀ (show (1:ℝ)≤d by linarith) (by norm_num : 1≤5)
  have hcost := linearDepthBudget_polynomial hd
  nlinarith

/-- Every proposed total-degree polynomial bound is violated, at arbitrarily
large dimensions, by genuine tanh networks in the paper's norm ball. -/
theorem superpolynomial_log_card (k : ℕ) (C : ℝ) (hC : 0 < C) (d₀ : ℕ) :
    ∃ d : ℕ, max 2 d₀ ≤ d ∧
      C*((d:ℝ)+linearDepthBudget d+((d:ℝ)+2)+1)^k <
        Real.log ((ParameterSensitivity.normBallFunctions d (2^(d+1)) d Real.tanh
          (Real.sqrt (linearDepthBudget d))).card:ℝ) := by
  have hlog : 0 < Real.log (2:ℝ) := Real.log_pos (by norm_num)
  have hlim := tendsto_pow_const_div_const_pow_of_one_lt (5*k) (by norm_num : (1:ℝ)<2)
  have he := hlim.eventually (gt_mem_nhds (show (0:ℝ)<Real.log 2/(C*4004^k) by positivity))
  obtain ⟨d,hd,hsmall⟩ := ((eventually_ge_atTop (max 2 d₀)).and he).exists
  have hd2 : 2≤d := (le_max_left _ _).trans hd
  have hscale : 0 < C*(4004:ℝ)^k := by positivity
  have hp : (0:ℝ)<2^d := by positivity
  have hpoly : C*((d:ℝ)+linearDepthBudget d+((d:ℝ)+2)+1)^k ≤ C*4004^k*(d:ℝ)^(5*k) := by
    have hh := pow_le_pow_left₀ (show 0≤(d:ℝ)+linearDepthBudget d+((d:ℝ)+2)+1 by
      have hb := linearDepthBudget_nonneg d
      positivity) (joint_budget_polynomial hd2) k
    have hh' := mul_le_mul_of_nonneg_left hh hC.le
    simpa only [mul_pow,← pow_mul,mul_assoc] using hh'
  have hstrict : C*(4004:ℝ)^k*(d:ℝ)^(5*k)<(2:ℝ)^d*Real.log 2 := by
    have hh := (div_lt_div_iff₀ hp hscale).mp hsmall
    nlinarith
  refine ⟨d,hd,?_⟩
  rw [logarithmic_budget_log_card hd2 le_rfl]
  exact hpoly.trans_lt hstrict

/-- No polynomial in the three scalar parameters can bound log cardinality
uniformly in network width. This is a counting obstruction, not a posterior
mistake lower bound for a simple target. -/
theorem no_joint_polynomial_counting_bound :
    ¬ ∃ (C : ℝ) (k : ℕ), 0 < C ∧ ∀ (d L N : ℕ) (K : ℝ),
      2 ≤ d → 4 ≤ L → 2^(d+1) ≤ N → 0 ≤ K →
      Real.log ((ParameterSensitivity.normBallFunctions d N (L-2) Real.tanh (Real.sqrt K)).card:ℝ) ≤
        C*((d:ℝ)+K+(L:ℝ)+1)^k := by
  rintro ⟨C,k,hC,hbound⟩
  obtain ⟨d,hd,hbad⟩ := superpolynomial_log_card k C hC 0
  have hd2 : 2≤d := (le_max_left _ _).trans hd
  have hh := hbound d (d+2) (2^(d+1)) (linearDepthBudget d) hd2 (by omega) le_rfl
    (linearDepthBudget_nonneg d)
  norm_num only [Nat.add_sub_cancel,Nat.cast_add,Nat.cast_ofNat] at hh
  exact (not_lt_of_ge hh) hbad

end NeuralGeneralization.DepthNormBall
