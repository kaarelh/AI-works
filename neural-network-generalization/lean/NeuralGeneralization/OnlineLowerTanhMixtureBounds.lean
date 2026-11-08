import NeuralGeneralization.OnlineLowerTanhResidualBiasSecond
import NeuralGeneralization.OnlineLowerTanhSmoothedCurvature
import NeuralGeneralization.OnlineLowerTanhResidualBalanced

/-! # Uniform bounds needed to average the residual theorem over outside signs -/
noncomputable section
open scoped BigOperators Topology
open MeasureTheory Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

lemma smoothedResponse_compact_abs_le_one {a E : ℝ} (ha : 0 < a) (ha2 : a ≤ 2)
    (hE : 0 ≤ E) (b : ℝ) : |smoothedResponse a E b| ≤ 1 := by
  have hh := smoothedResponse_energy_deficit ha ha2 hE b
  have hexp : Real.exp (-E*periodicFrequency a^2/2) ≤ 1 :=
    Real.exp_le_one_iff.mpr (by nlinarith [mul_nonneg hE (sq_nonneg (periodicFrequency a))])
  have hp : 0 ≤ periodicCoefficient a 0/100*(1-Real.exp (-E*periodicFrequency a^2/2)) :=
    mul_nonneg (div_nonneg (periodicCoefficient_pos ha 0).le (by norm_num)) (by linarith)
  have hm : periodicFourierMaximum a ≤ 1 := by
    exact (le_abs_self _).trans (periodicFourierResponse_abs_le_one a ha a)
  linarith

lemma smoothedSecondMoment_abs_le_majorant {a E lo hi : ℝ}
    (hlo : 0 < lo) (haLo : lo ≤ a) (haHi : a ≤ hi) (hE : 0 ≤ E) (b : ℝ) :
    |smoothedSecondMoment a E b| ≤ ∑' l : ℕ, secondMomentMajorant lo hi l := by
  have h := smoothedSecondMoment_partial_error hlo haLo haHi hE 0 b
  simpa only [Finset.range_zero,Finset.sum_empty,zero_sub,abs_neg,Nat.add_zero] using h

def firstMomentMajorant (lo hi : ℝ) (l : ℕ) : ℝ :=
  ((Real.pi/lo)/Real.sinh (periodicDecay hi))*periodicRatio hi^l + secondMomentMajorant lo hi l

lemma firstMomentMajorant_summable {lo hi : ℝ} (hhi : 0 < hi) :
    Summable (firstMomentMajorant lo hi) := by
  have hq := periodicRatio_mem hhi
  exact ((summable_geometric_of_lt_one hq.1.le hq.2).mul_left _).add
    (secondMomentMajorant_summable hhi)

lemma smoothedFirstMoment_coefficient_bound {a E lo hi : ℝ}
    (hlo : 0 < lo) (haLo : lo ≤ a) (haHi : a ≤ hi) (hE : 0 ≤ E) (l : ℕ) :
    smoothedCoefficient a E l*residualPeak a l ≤ firstMomentMajorant lo hi l := by
  have ha := hlo.trans_le haLo
  have hp := smoothedCoefficient_pos ha E l
  have hw : residualPeak a l ≤ 1+(residualPeak a l)^2 := by nlinarith [sq_nonneg (residualPeak a l-1/2)]
  have hm := mul_le_mul_of_nonneg_left hw hp.le
  have h0 := smoothedCoefficient_compact_bound hlo haLo haHi hE l
  have h2 := smoothedSecondMoment_coefficient_bound hlo haLo haHi hE l
  unfold firstMomentMajorant
  nlinarith

/-- A uniform Lipschitz constant in the phase for compact gains and all
nonnegative residual energies. -/
lemma smoothedResponse_lipschitz_compact {a E lo hi : ℝ}
    (hlo : 0 < lo) (haLo : lo ≤ a) (haHi : a ≤ hi) (hE : 0 ≤ E) (b c : ℝ) :
    |smoothedResponse a E b-smoothedResponse a E c| ≤
      (∑' l : ℕ, firstMomentMajorant lo hi l)*|b-c| := by
  have ha := hlo.trans_le haLo
  have hhi := ha.trans_le haHi
  let f := fun l : ℕ => smoothedCoefficient a E l*
    (Real.sin (residualPeak a l*b)-Real.sin (residualPeak a l*c))
  have hs : Summable f := by
    apply ((smoothed_sine_summable ha hE b).sub (smoothed_sine_summable ha hE c)).congr
    intro l
    dsimp [f]
    unfold residualPeak
    ring
  have he : smoothedResponse a E b-smoothedResponse a E c = ∑' l, f l := by
    unfold smoothedResponse
    rw [← (smoothed_sine_summable ha hE b).tsum_sub (smoothed_sine_summable ha hE c)]
    apply tsum_congr
    intro l
    dsimp [f]
    unfold residualPeak
    ring
  rw [he]
  have hb (l : ℕ) : ‖f l‖ ≤ firstMomentMajorant lo hi l*|b-c| := by
    dsimp [f]
    rw [abs_mul,abs_of_pos (smoothedCoefficient_pos ha E l)]
    have ht := Real.abs_sin_sub_sin_le (residualPeak a l*b) (residualPeak a l*c)
    rw [← mul_sub,abs_mul,abs_of_pos (residual_peak_pos ha l)] at ht
    have h1 := mul_le_mul_of_nonneg_left ht (smoothedCoefficient_pos ha E l).le
    have h2 := mul_le_mul_of_nonneg_right
      (smoothedFirstMoment_coefficient_bound hlo haLo haHi hE l) (abs_nonneg (b-c))
    nlinarith
  have hmajor := (firstMomentMajorant_summable (lo:=lo) hhi).mul_right |b-c|
  have habs := hmajor.of_nonneg_of_le (fun l => norm_nonneg (f l)) hb
  have ht := (norm_tsum_le_tsum_norm habs).trans (Summable.tsum_le_tsum hb habs hmajor)
  rw [(firstMomentMajorant_summable (lo:=lo) hhi).tsum_mul_right] at ht
  simpa only [Real.norm_eq_abs] using ht

lemma weighted_gaussian_envelope_loss {m : ℕ} (p β : Fin m → ℝ)
    (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i, p i=1) (s b D : ℝ) (hb : |b| ≤ D) :
    (∑ i, p i*(1-Real.exp (-((β i+b)*s)^2/2))) ≤
      s^2*((∑ i, p i*(β i)^2)+D^2) := by
  have hb2 : b^2 ≤ D^2 := by
    simpa only [sq_abs] using (sq_le_sq₀ (abs_nonneg b) (le_trans (abs_nonneg b) hb)).mpr hb
  have hpoint (i : Fin m) :
      p i*(1-Real.exp (-((β i+b)*s)^2/2)) ≤ p i*(s^2*((β i)^2+D^2)) := by
    have he := Real.add_one_le_exp (-((β i+b)*s)^2/2)
    have hquad : ((β i+b)*s)^2/2 ≤ s^2*((β i)^2+D^2) := by
      nlinarith [mul_le_mul_of_nonneg_left hb2 (sq_nonneg s),sq_nonneg (s*(β i-b))]
    exact mul_le_mul_of_nonneg_left (by linarith) (hp i)
  have h := Finset.sum_le_sum (fun i (_ : i ∈ Finset.univ) => hpoint i)
  apply h.trans_eq
  simp_rw [mul_add,Finset.sum_add_distrib]
  rw [show (∑ i, p i*(s^2*(β i)^2))=s^2*∑ i,p i*(β i)^2 by
    rw [Finset.mul_sum]; apply Finset.sum_congr rfl; intro i _; ring]
  rw [show (∑ i,p i*(s^2*D^2))=(s^2*D^2)*(∑ i,p i) by
    rw [Finset.mul_sum]; apply Finset.sum_congr rfl; intro i _; ring,hsum]
  ring

lemma weighted_gaussian_removal {m : ℕ} (p β v : Fin m → ℝ)
    (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i,p i=1) {M : ℝ} (hM : 0 ≤ M)
    (hv : ∀ i, |v i| ≤ M) (s b D : ℝ) (hb : |b| ≤ D) :
    |(∑ i, p i*Real.exp (-((β i+b)*s)^2/2)*v i)-(∑ i,p i*v i)| ≤
      M*(s^2*((∑ i,p i*(β i)^2)+D^2)) := by
  rw [← Finset.sum_sub_distrib]
  have hh := Finset.abs_sum_le_sum_abs (s:=Finset.univ)
    (f:=fun i => p i*Real.exp (-((β i+b)*s)^2/2)*v i-p i*v i)
  have hpoint (i : Fin m) :
      |p i*Real.exp (-((β i+b)*s)^2/2)*v i-p i*v i| ≤
        M*(p i*(1-Real.exp (-((β i+b)*s)^2/2))) := by
    have he : Real.exp (-((β i+b)*s)^2/2) ≤ 1 := Real.exp_le_one_iff.mpr (by nlinarith [sq_nonneg ((β i+b)*s)])
    rw [show p i*Real.exp (-((β i+b)*s)^2/2)*v i-p i*v i =
      -(p i*(1-Real.exp (-((β i+b)*s)^2/2))*v i) by ring,
      abs_neg,abs_mul,abs_of_nonneg (mul_nonneg (hp i) (by linarith))]
    have hm := mul_le_mul_of_nonneg_left (hv i) (mul_nonneg (hp i) (by linarith : 0≤1-Real.exp (-((β i+b)*s)^2/2)))
    nlinarith
  have hsum' := Finset.sum_le_sum (fun i (_ : i ∈ Finset.univ) => hpoint i)
  rw [← Finset.mul_sum] at hsum'
  exact (hh.trans hsum').trans (mul_le_mul_of_nonneg_left (weighted_gaussian_envelope_loss p β hp hsum s b D hb) hM)

lemma weighted_uniform_error {m : ℕ} (p f g : Fin m → ℝ)
    (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i,p i=1) {ε : ℝ} (herr : ∀ i, |f i-g i| ≤ ε) :
    |(∑ i,p i*f i)-(∑ i,p i*g i)| ≤ ε := by
  rw [← Finset.sum_sub_distrib]
  have hh := Finset.abs_sum_le_sum_abs (s:=Finset.univ) (f:=fun i => p i*f i-p i*g i)
  have hb := Finset.sum_le_sum (fun i (_ : i ∈ Finset.univ) =>
    mul_le_mul_of_nonneg_left (herr i) (hp i))
  simp_rw [← mul_sub,abs_mul,abs_of_nonneg (hp _)] at hh
  rw [← Finset.sum_mul,hsum,one_mul] at hb
  simpa only [mul_sub] using hh.trans hb

end NeuralGeneralization.OnlineLowerTanh
