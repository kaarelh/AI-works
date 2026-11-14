import NeuralGeneralization.OnlineLowerTanhPeriodicExactPeriodization

/-! The literal real-space derivative series for all positive gains. -/
noncomputable section
set_option maxHeartbeats 800000
open scoped BigOperators
open Set
namespace NeuralGeneralization.OnlineLowerTanh
open TanhDifferential

lemma tanhFirst_exp_tail (x : ℝ) : tanhFirst x ≤ 4*Real.exp (-2*x) := by
  have h := tanh_positive_saturation x
  rw [abs_of_nonpos (by linarith [Real.tanh_lt_one x])] at h
  unfold tanhFirst
  nlinarith [sq_nonneg (Real.tanh x-1)]

lemma first_tanh_tail_summable {a : ℝ} (ha : 0<a) (b : ℝ) :
    Summable (fun j : ℕ => (-1:ℝ)^j*tanhFirst (b+2*a*j)) := by
  have hs : Summable (fun j : ℕ => 4*Real.exp (-2*b)*Real.exp (-4*a)^j) := by
    apply (summable_geometric_of_abs_lt_one _).mul_left
    rw [abs_of_pos (Real.exp_pos _)]
    exact Real.exp_lt_one_iff.mpr (by linarith)
  apply hs.of_norm_bounded
  intro j
  rw [Real.norm_eq_abs,abs_mul,abs_neg_one_pow,one_mul,abs_of_nonneg (tanhFirst_nonneg _)]
  have he : 4*Real.exp (-2*(b+2*a*j)) = 4*Real.exp (-2*b)*Real.exp (-4*a)^j := by
    rw [←Real.exp_nat_mul]
    calc
      4*Real.exp (-2*(b+2*a*j)) = 4*Real.exp (-2*b+(j:ℝ)*(-4*a)) := by congr 1;congr 1;ring
      _ = _ := by rw [Real.exp_add];ring
  exact (tanhFirst_exp_tail _).trans_eq he

def signedTanhTailSum (a b : ℝ) : ℝ :=
  ∑' j : ℕ, (-1:ℝ)^j*(Real.tanh (b+2*a*j)-1)
def signedFirstTailSum (a b : ℝ) : ℝ :=
  ∑' j : ℕ, (-1:ℝ)^j*tanhFirst (b+2*a*j)

lemma signedTanhTailSum_hasDerivAt {a : ℝ} (ha : 0<a) (b : ℝ) :
    HasDerivAt (signedTanhTailSum a) (signedFirstTailSum a b) b := by
  let u : ℕ → ℝ := fun j => 4*Real.exp (-2*(b-1))*Real.exp (-4*a)^j
  have hu : Summable u := by
    apply (summable_geometric_of_abs_lt_one _).mul_left
    rw [abs_of_pos (Real.exp_pos _)]
    exact Real.exp_lt_one_iff.mpr (by linarith)
  unfold signedTanhTailSum signedFirstTailSum
  apply hasDerivAt_tsum_of_isPreconnected
    (g:=fun (j : ℕ) y => (-1:ℝ)^j*(Real.tanh (y+2*a*j)-1))
    (g':=fun (j : ℕ) y => (-1:ℝ)^j*tanhFirst (y+2*a*j))
    (t:=Ioi (b-1)) (y₀:=b)
    hu isOpen_Ioi (convex_Ioi _).isPreconnected _ _ (by simp) (signed_tanh_tail_summable ha b) (by simp)
  · intro j y hy
    convert (((hasDerivAt_tanh_first (y+2*a*j)).comp y
      ((hasDerivAt_id y).add_const (2*a*j))).sub_const 1).const_mul ((-1:ℝ)^j) using 1 <;> first | rfl | simp
  · intro j y hy
    rw [Real.norm_eq_abs,abs_mul,abs_neg_one_pow,one_mul,abs_of_nonneg (tanhFirst_nonneg _)]
    have he : u j = 4*Real.exp (-2*(b-1)+(j:ℝ)*(-4*a)) := by
      dsimp [u]
      rw [←Real.exp_nat_mul,Real.exp_add]
      ring
    rw [he]
    apply (tanhFirst_exp_tail _).trans
    apply mul_le_mul_of_nonneg_left _ (by norm_num)
    apply Real.exp_le_exp.mpr
    simp only [mem_Ioi] at hy
    linarith

lemma periodicFourierResponse_eq_two_tails {a : ℝ} (ha : 0<a) (b : ℝ) :
    periodicFourierResponse a b = 1+signedTanhTailSum a b+signedTanhTailSum a (2*a-b) := by
  have hs := periodicFourierResponse_eq_odd_paired ha (b-a)
  rw [sub_add_cancel] at hs
  rw [hs]
  have hterm (j : ℕ) : (-1:ℝ)^j*oddPairedTail a (b-a) j =
      (-1:ℝ)^j*(Real.tanh (b+2*a*j)-1)+
        (-1:ℝ)^j*(Real.tanh (2*a-b+2*a*j)-1) := by
    unfold oddPairedTail
    rw [show b-a+a*(2*(j:ℝ)+1)=b+2*a*j by ring,
      show b-a-a*(2*(j:ℝ)+1)=-(2*a-b+2*a*j) by ring,Real.tanh_neg]
    ring
  simp_rw [hterm]
  rw [(signed_tanh_tail_summable ha b).tsum_add (signed_tanh_tail_summable ha (2*a-b))]
  unfold signedTanhTailSum
  ring

/-- Real-space periodization of sech squared, expressed as a convergent
one-sided paired sum. It is the actual derivative of the Fourier response. -/
theorem periodicFourierDerivative_eq_real_paired {a : ℝ} (ha : 0<a) (b : ℝ) :
    periodicFourierDerivative a b = ∑' j : ℕ, (-1:ℝ)^j*
      (tanhFirst (b+2*a*j)-tanhFirst (2*a-b+2*a*j)) := by
  have h1 := signedTanhTailSum_hasDerivAt ha b
  have h2 := (signedTanhTailSum_hasDerivAt ha (2*a-b)).comp b ((hasDerivAt_id b).const_sub (2*a))
  have hd := (h1.const_add 1).add h2
  have hf : (fun y => 1+signedTanhTailSum a y+signedTanhTailSum a (2*a-y)) = periodicFourierResponse a := by
    funext y
    exact (periodicFourierResponse_eq_two_tails ha y).symm
  change HasDerivAt (fun y => 1+signedTanhTailSum a y+signedTanhTailSum a (2*a-y))
    (signedFirstTailSum a b + signedFirstTailSum a (2*a-b)*(-1)) b at hd
  rw [hf] at hd
  have hval := (periodicFourierResponse_hasDerivAt ha b).unique hd
  rw [hval]
  simp only [mul_neg_one,←sub_eq_add_neg]
  unfold signedFirstTailSum
  rw [←(first_tanh_tail_summable ha b).tsum_sub (first_tanh_tail_summable ha (2*a-b))]
  apply tsum_congr
  intro j
  ring

end NeuralGeneralization.OnlineLowerTanh
