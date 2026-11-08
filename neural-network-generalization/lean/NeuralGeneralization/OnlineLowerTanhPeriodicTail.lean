import NeuralGeneralization.OnlineLowerTanhPeriodicSmoothing

/-! # Uniform tails of the residual periodic model -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh

lemma periodicCoefficient_compact_bound {a lo hi : ℝ} (hlo : 0 < lo)
    (haLo : lo ≤ a) (haHi : a ≤ hi) (j : ℕ) :
    periodicCoefficient a j ≤
      ((Real.pi/lo)/Real.sinh (periodicDecay hi))*periodicRatio hi^j := by
  have ha : 0 < a := hlo.trans_le haLo
  have hhi : 0 < hi := ha.trans_le haHi
  have hdec : periodicDecay hi ≤ periodicDecay a := by
    unfold periodicDecay
    exact div_le_div_of_nonneg_left (sq_nonneg _) (by positivity) (by linarith)
  have hsinh : Real.sinh (periodicDecay hi) ≤ Real.sinh (periodicDecay a) :=
    Real.sinh_le_sinh.mpr hdec
  have hbase : periodicCoefficient a 0 ≤ (Real.pi/lo)/Real.sinh (periodicDecay hi) := by
    simp only [periodicCoefficient,Nat.cast_zero,mul_zero,zero_add,one_mul]
    calc
      _ ≤ (Real.pi/lo)/Real.sinh (periodicDecay a) :=
        div_le_div_of_nonneg_right (div_le_div_of_nonneg_left Real.pi_pos.le hlo haLo)
          (Real.sinh_pos_iff.mpr (periodicDecay_pos ha)).le
      _ ≤ _ := div_le_div_of_nonneg_left (by positivity)
        (Real.sinh_pos_iff.mpr (periodicDecay_pos hhi)) hsinh
  have hratio : periodicRatio a ≤ periodicRatio hi := by
    unfold periodicRatio
    exact Real.exp_le_exp.mpr (by linarith)
  have hpow := pow_le_pow_left₀ (Real.exp_pos (-2*periodicDecay a)).le hratio j
  have hbound := periodicCoefficient_le_geometric ha j
  apply hbound.trans
  apply mul_le_mul hbase hpow
  · exact pow_nonneg (Real.exp_pos _).le _
  · exact div_nonneg (div_nonneg Real.pi_pos.le hlo.le)
      (Real.sinh_pos_iff.mpr (periodicDecay_pos hhi)).le

lemma smoothedCoefficient_compact_bound {a lo hi E : ℝ} (hlo : 0 < lo)
    (haLo : lo ≤ a) (haHi : a ≤ hi) (hE : 0 ≤ E) (j : ℕ) :
    smoothedCoefficient a E j ≤
      ((Real.pi/lo)/Real.sinh (periodicDecay hi))*periodicRatio hi^j :=
  (smoothedCoefficient_le (hlo.trans_le haLo) hE j).trans
    (periodicCoefficient_compact_bound hlo haLo haHi j)

lemma smoothedCoefficient_tail_bound {a lo hi E : ℝ} (hlo : 0 < lo)
    (haLo : lo ≤ a) (haHi : a ≤ hi) (hE : 0 ≤ E) (L : ℕ) :
    (∑' j : ℕ, smoothedCoefficient a E (L+j)) ≤
      ((Real.pi/lo)/Real.sinh (periodicDecay hi))*periodicRatio hi^L/(1-periodicRatio hi) := by
  have ha := hlo.trans_le haLo
  have hhi := ha.trans_le haHi
  have hq := periodicRatio_mem hhi
  have hge := (hasSum_geometric_of_lt_one hq.1.le hq.2).summable
  have hs : Summable (fun j : ℕ => smoothedCoefficient a E (L+j)) := by
    apply (smoothedCoefficient_summable ha hE).comp_injective
    intro i j h
    omega
  have ht := Summable.tsum_le_tsum
    (fun j => smoothedCoefficient_compact_bound hlo haLo haHi hE (L+j)) hs
    (by simpa only [pow_add] using
      (hge.mul_left (periodicRatio hi^L)).mul_left ((Real.pi/lo)/Real.sinh (periodicDecay hi)))
  simp_rw [pow_add] at ht
  rw [Summable.tsum_mul_left, Summable.tsum_mul_left, tsum_geometric_of_lt_one hq.1.le hq.2] at ht
  · simpa only [div_eq_mul_inv,mul_assoc] using ht
  · exact hge
  · exact hge.mul_left _

lemma smoothed_sine_summable {a E : ℝ} (ha : 0 < a) (hE : 0 ≤ E) (b : ℝ) :
    Summable (fun j : ℕ => smoothedCoefficient a E j*Real.sin ((2*(j:ℝ)+1)*periodicFrequency a*b)) := by
  apply (smoothedCoefficient_summable ha hE).of_norm_bounded
  intro j
  rw [Real.norm_eq_abs,abs_mul,abs_of_pos (smoothedCoefficient_pos ha E j)]
  exact mul_le_of_le_one_right (smoothedCoefficient_pos ha E j).le (Real.abs_sin_le_one _)

lemma smoothedResponse_partial_error {a lo hi E : ℝ} (hlo : 0 < lo)
    (haLo : lo ≤ a) (haHi : a ≤ hi) (hE : 0 ≤ E) (L : ℕ) (b : ℝ) :
    |smoothedResponse a E b-
      ∑ j ∈ Finset.range L, smoothedCoefficient a E j*Real.sin ((2*(j:ℝ)+1)*periodicFrequency a*b)| ≤
      ((Real.pi/lo)/Real.sinh (periodicDecay hi))*periodicRatio hi^L/(1-periodicRatio hi) := by
  have ha := hlo.trans_le haLo
  let f : ℕ → ℝ := fun j => smoothedCoefficient a E j*Real.sin ((2*(j:ℝ)+1)*periodicFrequency a*b)
  have hs : Summable f := smoothed_sine_summable ha hE b
  have hsplit := hs.sum_add_tsum_nat_add L
  have ht : smoothedResponse a E b-(∑ j ∈ Finset.range L, f j) = ∑' j : ℕ, f (j+L) := by
    unfold smoothedResponse
    change (∑' j, f j)-(∑ j ∈ Finset.range L, f j) = _
    linarith
  change |smoothedResponse a E b-(∑ j ∈ Finset.range L, f j)| ≤ _
  rw [ht]
  have hc : Summable (fun j : ℕ => smoothedCoefficient a E (j+L)) :=
    (smoothedCoefficient_summable ha hE).comp_injective (fun i j h => Nat.add_right_cancel h)
  have hh : Summable (fun j : ℕ => ‖f (j+L)‖) := by
    apply hc.of_nonneg_of_le (fun j => norm_nonneg _)
    intro j
    dsimp [f]
    rw [abs_mul,abs_of_pos (smoothedCoefficient_pos ha E (j+L))]
    exact mul_le_of_le_one_right (smoothedCoefficient_pos ha E (j+L)).le (Real.abs_sin_le_one _)
  have hcomp := Summable.tsum_le_tsum (fun j => by
    dsimp [f]
    rw [abs_mul,abs_of_pos (smoothedCoefficient_pos ha E (j+L))]
    exact mul_le_of_le_one_right (smoothedCoefficient_pos ha E (j+L)).le (Real.abs_sin_le_one _)) hh hc
  have hn := norm_tsum_le_tsum_norm hh
  rw [Real.norm_eq_abs] at hn
  apply (hn.trans hcomp).trans
  simpa only [Nat.add_comm] using smoothedCoefficient_tail_bound hlo haLo haHi hE L

end NeuralGeneralization.OnlineLowerTanh
