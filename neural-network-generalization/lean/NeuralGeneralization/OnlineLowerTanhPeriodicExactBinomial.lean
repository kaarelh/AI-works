import NeuralGeneralization.OnlineLowerTanhResidualBalanced
import NeuralGeneralization.OnlineLowerTanhBulkKernel
import NeuralGeneralization.OnlineLowerTanhTeacherGrid

/-! Exact binomial route from the finite Boolean correlation to the paired
real-space periodic response. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators Topology
open Filter Set
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel OnlineLowerRelu

lemma odd_hamming_pair (r : ℕ) (f : ℝ → ℝ) :
    (∑ j ∈ Finset.range (2*r+2), (-1:ℝ)^j*((2*r+1).choose j:ℝ)*
      f ((2*r+1:ℕ)-2*j)) =
      ∑ j ∈ Finset.range (r+1), (-1:ℝ)^j*((2*r+1).choose j:ℝ)*
        (f ((2*r+1:ℕ)-2*j)-f (-((2*r+1:ℕ)-2*j))) := by
  let g : ℕ → ℝ := fun j => (-1:ℝ)^j*((2*r+1).choose j:ℝ)*f ((2*r+1:ℕ)-2*j)
  have htail : (∑ j ∈ Finset.range (r+1), g (r+1+j)) =
      ∑ j ∈ Finset.range (r+1), -((-1:ℝ)^j*((2*r+1).choose j:ℝ)*
        f (-((2*r+1:ℕ)-2*j))) := by
    rw [←Finset.sum_range_reflect (fun j => g (r+1+j)) (r+1)]
    apply Finset.sum_congr rfl
    intro j hj
    have hjr : j ≤ 2*r+1 := by have := Finset.mem_range.mp hj; omega
    have hs : (-1:ℝ)^(2*r+1-j) = -(-1:ℝ)^j := by
      have hh := neg_one_pow_center (2*r+1) j hjr
      have ho : (-1:ℝ)^(2*r+1) = -1 := by rw [pow_add,pow_mul];norm_num
      rw [ho] at hh
      linarith
    have hc := Nat.choose_symm hjr
    have hx : ((2*r+1:ℕ):ℝ)-2*((2*r+1-j:ℕ):ℝ) =
        -(((2*r+1:ℕ):ℝ)-2*(j:ℝ)) := by rw [Nat.cast_sub hjr];ring
    rw [show r+1+(r+1-1-j)=2*r+1-j by have := Finset.mem_range.mp hj;omega]
    simp only [g,hs,hc,hx]
    ring
  change (∑ j ∈ Finset.range (2*r+2), g j) = _
  rw [show 2*r+2=(r+1)+(r+1) by omega,Finset.sum_range_add,htail]
  rw [←Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro j hj
  dsimp [g]
  ring

lemma biasedParity_centered (r : ℕ) (a B : ℝ) :
    (-1:ℝ)^r*parityCorrelation (fun _ : Fin (2*r+1) => a) B =
      (1:ℝ)/(2*4^r)*∑ j ∈ Finset.range (r+1),
        (-1:ℝ)^j*((2*r+1).choose (r-j):ℝ)*
        (Real.tanh (B+a*(2*j+1))-Real.tanh (B-a*(2*j+1))) := by
  rw [←ridgeParity_tanh,ridgeParity_constant_hamming]
  have hp := odd_hamming_pair r (fun x => Real.tanh (B+a*x))
  simp only [show 2*r+1+1=2*r+2 by omega] at *
  rw [hp,←Finset.sum_range_reflect (fun j => (-1:ℝ)^j*((2*r+1).choose j:ℝ)*
    (Real.tanh (B+a*((2*r+1:ℕ)-2*j))-Real.tanh (B+a*(-((2*r+1:ℕ)-2*j)))))]
  have hscale : (2:ℝ)^(2*r+1)=2*4^r := by rw [pow_add,pow_mul];norm_num;ring
  rw [hscale,←mul_assoc,mul_comm ((-1:ℝ)^r),mul_assoc,Finset.mul_sum]
  congr 1
  apply Finset.sum_congr rfl
  intro j hj
  have hjr : j ≤ r := Nat.lt_succ_iff.mp (Finset.mem_range.mp hj)
  simp only [Nat.add_sub_cancel]
  have hx : ((2*r+1:ℕ):ℝ)-2*((r-j:ℕ):ℝ)=2*(j:ℝ)+1 := by
    rw [Nat.cast_sub hjr];push_cast;ring
  rw [hx]
  rw [show B+a*(-(2*(j:ℝ)+1))=B-a*(2*(j:ℝ)+1) by ring]
  rw [←mul_assoc,←mul_assoc,neg_one_pow_center r j hjr]

def realCenteredRatio (r j : ℕ) : ℝ :=
  (prefactoredRatio j ((2*r+1:ℕ):ℂ)).re

lemma realCenteredRatio_choose (r j : ℕ) (hj : j ≤ r) :
    ((2*r+1).choose (r-j):ℝ)=2*(Nat.centralBinom r:ℝ)*realCenteredRatio r j := by
  have h := congrArg Complex.re (centered_choose_prefactored r j hj)
  simpa [realCenteredRatio,Complex.mul_re,Complex.mul_im] using h

lemma realCenteredRatio_zero (r j : ℕ) (hj : r < j) : realCenteredRatio r j = 0 := by
  unfold realCenteredRatio prefactoredRatio
  rw [hammingRatio_odd_zero r j hj,mul_zero,Complex.zero_re]

lemma realCenteredRatio_abs_le_one (r j : ℕ) : |realCenteredRatio r j| ≤ 1 := by
  exact (Complex.abs_re_le_norm _).trans (prefactoredRatio_norm_le_one j
    (by simp only [Complex.natCast_re];positivity))

lemma realCenteredRatio_tendsto (j : ℕ) :
    Tendsto (fun r => realCenteredRatio r j) atTop (𝓝 1) := by
  exact (Complex.continuous_re.tendsto 1).comp (prefactoredRatio_odd_tendsto j)

def oddPairedTail (a B : ℝ) (j : ℕ) : ℝ :=
  Real.tanh (B+a*(2*j+1))-Real.tanh (B-a*(2*j+1))-2

lemma biasedParity_normalized_series (r : ℕ) (a B : ℝ) :
    ((-1:ℝ)^r*parityCorrelation (fun _ : Fin (2*r+1) => a) B)/oddParityKappa r =
      1 + ∑' j : ℕ, (-1:ℝ)^j*realCenteredRatio r j*oddPairedTail a B j := by
  have htrunc : (∑' j : ℕ, (-1:ℝ)^j*realCenteredRatio r j*oddPairedTail a B j) =
      ∑ j ∈ Finset.range (r+1), (-1:ℝ)^j*realCenteredRatio r j*oddPairedTail a B j := by
    apply tsum_eq_sum
    intro j hj
    have hrj : r < j := by
      have : ¬j<r+1 := by simpa only [Finset.mem_range] using hj
      omega
    rw [realCenteredRatio_zero r j hrj,mul_zero,zero_mul]
  rw [htrunc,biasedParity_centered]
  have hchoose := centered_choose_alternating r
  have hk : (Nat.centralBinom r:ℝ) ≠ 0 := by exact_mod_cast (Nat.centralBinom_pos r).ne'
  have hscale : (1:ℝ)/(2*4^r)/oddParityKappa r = 1/(2*(Nat.centralBinom r:ℝ)) := by
    unfold oddParityKappa
    field_simp
  rw [show (1:ℝ)/(2*4^r)*
    (∑ j ∈ Finset.range (r+1), (-1:ℝ)^j*((2*r+1).choose (r-j):ℝ)*
      (Real.tanh (B+a*(2*j+1))-Real.tanh (B-a*(2*j+1))))/oddParityKappa r =
    ((1:ℝ)/(2*4^r)/oddParityKappa r)*
      (∑ j ∈ Finset.range (r+1), (-1:ℝ)^j*((2*r+1).choose (r-j):ℝ)*
        (Real.tanh (B+a*(2*j+1))-Real.tanh (B-a*(2*j+1)))) by ring,hscale]
  have hsum : (∑ j ∈ Finset.range (r+1), (-1:ℝ)^j*((2*r+1).choose (r-j):ℝ)*
      (Real.tanh (B+a*(2*j+1))-Real.tanh (B-a*(2*j+1)))) =
      2*(Nat.centralBinom r:ℝ) + 2*(Nat.centralBinom r:ℝ)*
        ∑ j ∈ Finset.range (r+1), (-1:ℝ)^j*realCenteredRatio r j*oddPairedTail a B j := by
    nth_rw 1 [←hchoose]
    rw [Finset.mul_sum,Finset.mul_sum,←Finset.sum_add_distrib]
    apply Finset.sum_congr rfl
    intro j hj
    have hc := realCenteredRatio_choose r j (Nat.lt_succ_iff.mp (Finset.mem_range.mp hj))
    rw [hc]
    unfold oddPairedTail
    ring
  rw [hsum]
  field_simp

lemma oddPairedTail_abs_bound (a B : ℝ) (j : ℕ) :
    |oddPairedTail a B j| ≤ 4*Real.exp (2*|B|-2*a)*Real.exp (-4*a)^j := by
  have heq : oddPairedTail a B j =
      (Real.tanh (B+a*(2*j+1))-1)+(Real.tanh (a*(2*j+1)-B)-1) := by
    unfold oddPairedTail
    rw [show B-a*(2*(j:ℝ)+1)=-(a*(2*(j:ℝ)+1)-B) by ring,Real.tanh_neg]
    ring
  rw [heq]
  have h1 := tanh_positive_saturation (B+a*(2*j+1))
  have h2 := tanh_positive_saturation (a*(2*j+1)-B)
  have he1 : Real.exp (-2*(B+a*(2*j+1))) ≤ Real.exp (2*|B|-2*a)*Real.exp (-4*a)^j := by
    rw [←Real.exp_nat_mul,←Real.exp_add]
    apply Real.exp_le_exp.mpr
    linarith [neg_abs_le B]
  have he2 : Real.exp (-2*(a*(2*j+1)-B)) ≤ Real.exp (2*|B|-2*a)*Real.exp (-4*a)^j := by
    rw [←Real.exp_nat_mul,←Real.exp_add]
    apply Real.exp_le_exp.mpr
    linarith [le_abs_self B]
  have hs := abs_add_le (Real.tanh (B+a*(2*j+1))-1) (Real.tanh (a*(2*j+1)-B)-1)
  nlinarith

lemma oddPairedTail_bound_summable {a : ℝ} (ha : 0<a) (B : ℝ) :
    Summable (fun j : ℕ => 4*Real.exp (2*|B|-2*a)*Real.exp (-4*a)^j) := by
  apply (summable_geometric_of_abs_lt_one _).mul_left
  rw [abs_of_pos (Real.exp_pos _)]
  exact Real.exp_lt_one_iff.mpr (by linarith)

lemma oddPairedTail_summable {a : ℝ} (ha : 0<a) (B : ℝ) :
    Summable (fun j : ℕ => (-1:ℝ)^j*oddPairedTail a B j) := by
  apply (oddPairedTail_bound_summable ha B).of_norm_bounded
  intro j
  simpa only [Real.norm_eq_abs,abs_mul,abs_neg_one_pow,one_mul] using oddPairedTail_abs_bound a B j

lemma biasedParity_normalized_paired_tendsto {a : ℝ} (ha : 0<a) (B : ℝ) :
    Tendsto (fun r : ℕ =>
      ((-1:ℝ)^r*parityCorrelation (fun _ : Fin (2*r+1) => a) B)/oddParityKappa r)
      atTop (𝓝 (1+∑' j : ℕ, (-1:ℝ)^j*oddPairedTail a B j)) := by
  simp_rw [biasedParity_normalized_series]
  apply tendsto_const_nhds.add
  apply tendsto_tsum_of_dominated_convergence (oddPairedTail_bound_summable ha B)
  · intro j
    simpa only [mul_one] using ((realCenteredRatio_tendsto j).const_mul ((-1:ℝ)^j)).mul_const
      (oddPairedTail a B j)
  · apply Filter.Eventually.of_forall
    intro r j
    rw [Real.norm_eq_abs,abs_mul,abs_mul,abs_neg_one_pow,one_mul]
    exact (mul_le_mul_of_nonneg_right (realCenteredRatio_abs_le_one r j)
      (abs_nonneg _)).trans (by simpa only [one_mul] using oddPairedTail_abs_bound a B j)

lemma biasedParity_normalized_fourier_tendsto {a : ℝ} (ha : 0<a) (B : ℝ) :
    Tendsto (fun r : ℕ =>
      ((-1:ℝ)^r*parityCorrelation (fun _ : Fin (2*r+1) => a) B)/oddParityKappa r)
      atTop (𝓝 (periodicFourierResponse a (B+a))) := by
  have hc : Real.sqrt (2/Real.pi) ≠ 0 := ne_of_gt (by positivity)
  have ht := (balanced_biased_scaled_tendsto a ha B).div scaled_oddParityKappa_tendsto hc
  convert ht using 1
  · funext r
    have hn : Real.sqrt (2*(r:ℝ)+1) ≠ 0 := ne_of_gt (by positivity)
    simp only [Pi.div_apply]
    field_simp
  · field_simp

/-- The Fourier response equals the actual paired hyperbolic-tangent limit
at every positive gain and arbitrary real phase. -/
theorem periodicFourierResponse_eq_odd_paired {a : ℝ} (ha : 0<a) (B : ℝ) :
    periodicFourierResponse a (B+a) =
      1+∑' j : ℕ, (-1:ℝ)^j*oddPairedTail a B j :=
  tendsto_nhds_unique (biasedParity_normalized_fourier_tendsto ha B)
    (biasedParity_normalized_paired_tendsto ha B)

end NeuralGeneralization.OnlineLowerTanh
