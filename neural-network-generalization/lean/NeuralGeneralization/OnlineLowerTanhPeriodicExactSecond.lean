import NeuralGeneralization.OnlineLowerTanhPeriodicExactRealDerivative

/-! Twice differentiating the actual paired real-space response. -/
noncomputable section
set_option maxHeartbeats 800000
open scoped BigOperators
open Set
namespace NeuralGeneralization.OnlineLowerTanh
open TanhDifferential

lemma tanhSecond_exp_tail (x : ℝ) : |tanhSecond x| ≤ 8*Real.exp (-2*x) := by
  have h := tanhFirst_exp_tail x
  have ht := (Real.abs_tanh_lt_one x).le
  have hp := mul_le_mul_of_nonneg_right ht (tanhFirst_nonneg x)
  unfold tanhSecond
  rw [abs_mul,abs_mul,abs_of_nonneg (tanhFirst_nonneg x)]
  norm_num
  simp only [neg_mul] at h
  nlinarith

lemma second_tanh_tail_summable {a : ℝ} (ha : 0<a) (b : ℝ) :
    Summable (fun j : ℕ => (-1:ℝ)^j*tanhSecond (b+2*a*j)) := by
  have hs : Summable (fun j : ℕ => 8*Real.exp (-2*b)*Real.exp (-4*a)^j) := by
    apply (summable_geometric_of_abs_lt_one _).mul_left
    rw [abs_of_pos (Real.exp_pos _)]
    exact Real.exp_lt_one_iff.mpr (by linarith)
  apply hs.of_norm_bounded
  intro j
  rw [Real.norm_eq_abs,abs_mul,abs_neg_one_pow,one_mul]
  have he : 8*Real.exp (-2*(b+2*a*j)) = 8*Real.exp (-2*b)*Real.exp (-4*a)^j := by
    rw [←Real.exp_nat_mul]
    calc
      8*Real.exp (-2*(b+2*a*j)) = 8*Real.exp (-2*b+(j:ℝ)*(-4*a)) := by congr 1;congr 1;ring
      _ = _ := by rw [Real.exp_add];ring
  exact (tanhSecond_exp_tail _).trans_eq he

def signedSecondTailSum (a b : ℝ) : ℝ :=
  ∑' j : ℕ, (-1:ℝ)^j*tanhSecond (b+2*a*j)

lemma signedFirstTailSum_hasDerivAt {a : ℝ} (ha : 0<a) (b : ℝ) :
    HasDerivAt (signedFirstTailSum a) (signedSecondTailSum a b) b := by
  let u : ℕ → ℝ := fun j => 8*Real.exp (-2*(b-1))*Real.exp (-4*a)^j
  have hu : Summable u := by
    apply (summable_geometric_of_abs_lt_one _).mul_left
    rw [abs_of_pos (Real.exp_pos _)]
    exact Real.exp_lt_one_iff.mpr (by linarith)
  unfold signedFirstTailSum signedSecondTailSum
  apply hasDerivAt_tsum_of_isPreconnected
    (g:=fun (j : ℕ) y => (-1:ℝ)^j*tanhFirst (y+2*a*j))
    (g':=fun (j : ℕ) y => (-1:ℝ)^j*tanhSecond (y+2*a*j))
    (t:=Ioi (b-1)) (y₀:=b)
    hu isOpen_Ioi (convex_Ioi _).isPreconnected _ _ (by simp) (first_tanh_tail_summable ha b) (by simp)
  · intro j y hy
    convert (((hasDerivAt_tanhFirst (y+2*a*j)).comp y
      ((hasDerivAt_id y).add_const (2*a*j)))).const_mul ((-1:ℝ)^j) using 1 <;> first | rfl | simp
  · intro j y hy
    rw [Real.norm_eq_abs,abs_mul,abs_neg_one_pow,one_mul]
    have he : u j = 8*Real.exp (-2*(b-1)+(j:ℝ)*(-4*a)) := by
      dsimp [u]
      rw [←Real.exp_nat_mul,Real.exp_add]
      ring
    rw [he]
    apply (tanhSecond_exp_tail _).trans
    apply mul_le_mul_of_nonneg_left _ (by norm_num)
    apply Real.exp_le_exp.mpr
    simp only [mem_Ioi] at hy
    linarith

theorem periodicFourierSecond_eq_real_paired {a : ℝ} (ha : 0<a) (b : ℝ) :
    periodicFourierSecond a b = ∑' j : ℕ, (-1:ℝ)^j*
      (tanhSecond (b+2*a*j)+tanhSecond (2*a-b+2*a*j)) := by
  have h1 := signedFirstTailSum_hasDerivAt ha b
  have h2 := (signedFirstTailSum_hasDerivAt ha (2*a-b)).comp b ((hasDerivAt_id b).const_sub (2*a))
  have hd := h1.sub h2
  have hf : (fun y => signedFirstTailSum a y-signedFirstTailSum a (2*a-y)) = periodicFourierDerivative a := by
    funext y
    rw [periodicFourierDerivative_eq_real_paired ha]
    unfold signedFirstTailSum
    rw [←(first_tanh_tail_summable ha y).tsum_sub (first_tanh_tail_summable ha (2*a-y))]
    apply tsum_congr
    intro j
    ring
  change HasDerivAt (fun y => signedFirstTailSum a y-signedFirstTailSum a (2*a-y))
    (signedSecondTailSum a b - signedSecondTailSum a (2*a-b)*(-1)) b at hd
  rw [hf] at hd
  have hval := (periodicFourierDerivative_hasDerivAt ha b).unique hd
  rw [hval]
  simp only [mul_neg_one,sub_neg_eq_add]
  unfold signedSecondTailSum
  rw [←(second_tanh_tail_summable ha b).tsum_add (second_tanh_tail_summable ha (2*a-b))]
  apply tsum_congr
  intro j
  ring

end NeuralGeneralization.OnlineLowerTanh
