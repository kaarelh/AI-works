import NeuralGeneralization.OnlineLowerTanhPeriodicExactBinomial

/-! Identification with the manuscript's paired real-space series, at every
positive gain and every real phase. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh

def pairedPeriodicResponse (a b : ℝ) : ℝ :=
  Real.tanh b + ∑' j : ℕ, (-1:ℝ)^(j+1)*
    (Real.tanh (b+2*a*((j+1:ℕ):ℝ))+Real.tanh (b-2*a*((j+1:ℕ):ℝ)))

lemma signed_tanh_tail_summable {a : ℝ} (ha : 0<a) (b : ℝ) :
    Summable (fun j : ℕ => (-1:ℝ)^j*(Real.tanh (b+2*a*j)-1)) := by
  have hs : Summable (fun j : ℕ => 2*Real.exp (-2*b)*Real.exp (-4*a)^j) := by
    apply (summable_geometric_of_abs_lt_one _).mul_left
    rw [abs_of_pos (Real.exp_pos _)]
    exact Real.exp_lt_one_iff.mpr (by linarith)
  apply hs.of_norm_bounded
  intro j
  rw [Real.norm_eq_abs,abs_mul,abs_neg_one_pow,one_mul]
  have he : 2*Real.exp (-2*(b+2*a*j)) = 2*Real.exp (-2*b)*Real.exp (-4*a)^j := by
    rw [←Real.exp_nat_mul]
    calc
      2*Real.exp (-2*(b+2*a*j)) = 2*Real.exp (-2*b+(j:ℝ)*(-4*a)) := by congr 1;congr 1;ring
      _ = _ := by rw [Real.exp_add];ring
  exact (tanh_positive_saturation _).trans_eq he

lemma pairedPeriodicResponse_summable {a : ℝ} (ha : 0<a) (b : ℝ) :
    Summable (fun j : ℕ => (-1:ℝ)^(j+1)*
      (Real.tanh (b+2*a*((j+1:ℕ):ℝ))+Real.tanh (b-2*a*((j+1:ℕ):ℝ)))) := by
  have hp := (signed_tanh_tail_summable ha b).comp_injective Nat.succ_injective
  have hn := (signed_tanh_tail_summable ha (-b)).comp_injective Nat.succ_injective
  apply (hp.sub hn).congr
  intro j
  simp only [Function.comp_apply,Nat.succ_eq_add_one,Nat.cast_add,Nat.cast_one]
  rw [show b-2*a*((j:ℝ)+1) = -(-b+2*a*((j:ℝ)+1)) by ring,Real.tanh_neg]
  ring

/-- The original paired-tanh definition and the Fourier definition are
exactly equal, with no upper or lower compactness restriction on the gain. -/
theorem periodicFourierResponse_eq_paired {a : ℝ} (ha : 0<a) (b : ℝ) :
    periodicFourierResponse a b = pairedPeriodicResponse a b := by
  have hp := signed_tanh_tail_summable ha b
  have hn := signed_tanh_tail_summable ha (-b)
  have hns := hn.comp_injective Nat.succ_injective
  have hps := hp.comp_injective Nat.succ_injective
  have hterm (j : ℕ) : (-1:ℝ)^j*oddPairedTail a (b-a) j =
      (-1:ℝ)^j*(Real.tanh (b+2*a*j)-1) -
        (-1:ℝ)^(j+1)*(Real.tanh (-b+2*a*((j+1:ℕ):ℝ))-1) := by
    unfold oddPairedTail
    rw [show b-a+a*(2*(j:ℝ)+1)=b+2*a*j by ring,
      show b-a-a*(2*(j:ℝ)+1)=-(-b+2*a*((j:ℝ)+1)) by ring,Real.tanh_neg]
    push_cast
    rw [pow_succ]
    ring
  have hs := periodicFourierResponse_eq_odd_paired ha (b-a)
  rw [sub_add_cancel] at hs
  rw [hs]
  simp_rw [hterm]
  have hd := hp.tsum_sub hns
  simp only [Function.comp_def,Nat.succ_eq_add_one] at hd
  rw [hd,hp.tsum_eq_zero_add]
  unfold pairedPeriodicResponse
  have hpair : (∑' j : ℕ, (-1:ℝ)^(j+1)*
      (Real.tanh (b+2*a*((j+1:ℕ):ℝ))+Real.tanh (b-2*a*((j+1:ℕ):ℝ)))) =
      (∑' j : ℕ, (-1:ℝ)^(j+1)*(Real.tanh (b+2*a*((j+1:ℕ):ℝ))-1)) -
      (∑' j : ℕ, (-1:ℝ)^(j+1)*(Real.tanh (-b+2*a*((j+1:ℕ):ℝ))-1)) := by
    have hd := hps.tsum_sub hns
    simp only [Function.comp_def,Nat.succ_eq_add_one] at hd
    rw [←hd]
    apply tsum_congr
    intro j
    push_cast
    rw [show b-2*a*((j:ℝ)+1)=-(-b+2*a*((j:ℝ)+1)) by ring,Real.tanh_neg]
    ring
  rw [hpair]
  simp only [Nat.cast_zero,mul_zero,add_zero,pow_zero,one_mul]
  ring

end NeuralGeneralization.OnlineLowerTanh
