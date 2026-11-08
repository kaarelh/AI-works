import NeuralGeneralization.OnlineLowerTanhResidualFinite

/-! # The periodic second-moment response and its uniform summable tail -/
noncomputable section
open scoped BigOperators Topology
open MeasureTheory Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

def smoothedSecondMoment (a E b : ℝ) : ℝ :=
  ∑' l : ℕ, smoothedCoefficient a E l*(residualPeak a l)^2*Real.sin (residualPeak a l*b)

def residualSecondLeading {n : ℕ} (q : Fin n → ℕ) (d : Fin n → ℝ) (A B : ℝ) : ℝ :=
  residualPhaseSign q*Real.sqrt (2/(Real.pi*residualVariance q))*
    Real.exp (-B^2/(2*A^2*residualVariance q))*
      smoothedSecondMoment A (∑ i, (d i)^2) (B+(n%2:ℕ)*A)

def secondMomentMajorant (lo hi : ℝ) (l : ℕ) : ℝ :=
  ((Real.pi/lo)/Real.sinh (periodicDecay hi))*periodicFrequency lo^2*
    (2*(l:ℝ)+1)^2*periodicRatio hi^l

lemma secondMomentMajorant_nonneg {lo hi : ℝ} (hlo : 0 < lo) (hhi : 0 < hi) (l : ℕ) :
    0 ≤ secondMomentMajorant lo hi l := by
  unfold secondMomentMajorant
  have hs := Real.sinh_pos_iff.mpr (periodicDecay_pos hhi)
  positivity [periodicRatio_mem hhi |>.1]

lemma secondMomentMajorant_summable {lo hi : ℝ} (hhi : 0 < hi) :
    Summable (secondMomentMajorant lo hi) := by
  have hq : |periodicRatio hi| < 1 := by
    rw [abs_of_pos (periodicRatio_mem hhi).1]
    exact (periodicRatio_mem hhi).2
  have h0 := summable_geometric_of_abs_lt_one hq
  have h1 := summable_pow_mul_geometric_of_norm_lt_one 1 (r := periodicRatio hi) hq
  have h2 := summable_pow_mul_geometric_of_norm_lt_one 2 (r := periodicRatio hi) hq
  have hp : Summable (fun l : ℕ => (2*(l:ℝ)+1)^2*periodicRatio hi^l) := by
    apply (((h2.mul_left (4:ℝ)).add (h1.mul_left (4:ℝ))).add h0).congr
    intro l
    ring
  apply (hp.mul_left (((Real.pi/lo)/Real.sinh (periodicDecay hi))*periodicFrequency lo^2)).congr
  intro l
  unfold secondMomentMajorant
  ring

lemma smoothedSecondMoment_coefficient_bound {A E lo hi : ℝ}
    (hlo : 0 < lo) (hAlo : lo ≤ A) (hAhi : A ≤ hi) (hE : 0 ≤ E) (l : ℕ) :
    smoothedCoefficient A E l*(residualPeak A l)^2 ≤ secondMomentMajorant lo hi l := by
  have hA := hlo.trans_le hAlo
  have hhi := hA.trans_le hAhi
  have hw : periodicFrequency A ≤ periodicFrequency lo := by
    unfold periodicFrequency
    exact div_le_div_of_nonneg_left Real.pi_pos.le (by positivity) (by linarith)
  have hp : (residualPeak A l)^2 ≤ (2*(l:ℝ)+1)^2*periodicFrequency lo^2 := by
    unfold residualPeak
    rw [mul_pow]
    apply mul_le_mul_of_nonneg_left _ (sq_nonneg _)
    exact (sq_le_sq₀ (periodicFrequency_pos hA).le (periodicFrequency_pos hlo).le).mpr hw
  have hh := mul_le_mul (smoothedCoefficient_compact_bound hlo hAlo hAhi hE l) hp
    (sq_nonneg _) (by positivity [Real.sinh_pos_iff.mpr (periodicDecay_pos hhi), (periodicRatio_mem hhi).1])
  unfold secondMomentMajorant
  nlinarith

lemma smoothedSecondMoment_summable {A E : ℝ} (hA : 0 < A) (hE : 0 ≤ E) (b : ℝ) :
    Summable (fun l : ℕ => smoothedCoefficient A E l*(residualPeak A l)^2*Real.sin (residualPeak A l*b)) := by
  apply (secondMomentMajorant_summable (lo:=A) hA).of_norm_bounded
  intro l
  rw [Real.norm_eq_abs,abs_mul,abs_mul,abs_of_pos (smoothedCoefficient_pos hA E l),
    abs_of_nonneg (sq_nonneg _)]
  exact (mul_le_of_le_one_right (mul_nonneg (smoothedCoefficient_pos hA E l).le (sq_nonneg _))
    (Real.abs_sin_le_one _)).trans
      (smoothedSecondMoment_coefficient_bound hA (le_refl _) (le_refl _) hE l)

lemma smoothedSecondMoment_partial_error {A E lo hi : ℝ}
    (hlo : 0 < lo) (hAlo : lo ≤ A) (hAhi : A ≤ hi) (hE : 0 ≤ E) (L : ℕ) (b : ℝ) :
    |(∑ l ∈ Finset.range L, smoothedCoefficient A E l*(residualPeak A l)^2*Real.sin (residualPeak A l*b))-
      smoothedSecondMoment A E b| ≤ ∑' l : ℕ, secondMomentMajorant lo hi (l+L) := by
  have hA := hlo.trans_le hAlo
  have hhi := hA.trans_le hAhi
  let f : ℕ → ℝ := fun l => smoothedCoefficient A E l*(residualPeak A l)^2*Real.sin (residualPeak A l*b)
  have hs : Summable f := smoothedSecondMoment_summable hA hE b
  have hsplit := hs.sum_add_tsum_nat_add L
  have he : (∑ l ∈ Finset.range L, f l)-smoothedSecondMoment A E b = -(∑' l : ℕ, f (l+L)) := by
    change _-(∑' l, f l)=_
    linarith
  rw [show (∑ l ∈ Finset.range L, smoothedCoefficient A E l*(residualPeak A l)^2*Real.sin (residualPeak A l*b)) =
    ∑ l ∈ Finset.range L, f l from rfl,he,abs_neg]
  have hm : Summable (fun l : ℕ => secondMomentMajorant lo hi (l+L)) :=
    (secondMomentMajorant_summable (lo:=lo) hhi).comp_injective (fun i j h => Nat.add_right_cancel h)
  have hbound (l : ℕ) : ‖f (l+L)‖ ≤ secondMomentMajorant lo hi (l+L) := by
    dsimp [f]
    rw [abs_mul,abs_mul,abs_of_pos (smoothedCoefficient_pos hA E _),abs_of_nonneg (sq_nonneg _)]
    exact (mul_le_of_le_one_right (mul_nonneg (smoothedCoefficient_pos hA E _).le (sq_nonneg _))
      (Real.abs_sin_le_one _)).trans (smoothedSecondMoment_coefficient_bound hlo hAlo hAhi hE _)
  have hn := hm.of_nonneg_of_le (fun l => norm_nonneg (f (l+L))) hbound
  have ht := (norm_tsum_le_tsum_norm hn).trans (Summable.tsum_le_tsum hbound hn hm)
  simpa only [Real.norm_eq_abs] using ht

lemma residual_peak_second_model_coefficient {n : ℕ} (hn : 0 < n) (q : Fin n → ℕ)
    (hq : ∀ i, 0 < q i) (d : Fin n → ℝ) {A : ℝ} (hA : 0 < A) (B : ℝ) (l : ℕ) :
    residualPeakModel q d A B ((n:ℝ)*Real.pi/2) l 2 =
      (residualPhaseSign q*Real.sqrt (2/(Real.pi*residualVariance q))*
        Real.exp (-B^2/(2*A^2*residualVariance q))) *
      (smoothedCoefficient A (∑ i, (d i)^2) l*(residualPeak A l)^2 *
        Real.sin (residualPeak A l*(B+(n%2:ℕ)*A))) := by
  have he : residualPeakModel q d A B ((n:ℝ)*Real.pi/2) l 2 =
      residualPeakModel q d A B ((n:ℝ)*Real.pi/2) l 0*(residualPeak A l)^2 := by
    unfold residualPeakModel residualDerivativeKernel
    simp only [pow_zero]
    ring
  rw [he,residual_peak_model_coefficient hn q hq d hA]
  unfold residualPeak
  ring

lemma residual_second_model_tail {n : ℕ} (hn : 0 < n) (q : Fin n → ℕ)
    (hq : ∀ i, 0 < q i) (d : Fin n → ℝ) {A lo hi : ℝ}
    (hlo : 0 < lo) (hAlo : lo ≤ A) (hAhi : A ≤ hi) (B : ℝ) (L : ℕ) :
    Real.sqrt (residualVariance q)*
      |(∑ l ∈ Finset.range L, residualPeakModel q d A B ((n:ℝ)*Real.pi/2) l 2)-
        residualSecondLeading q d A B| ≤
      (Real.sqrt (2*Real.pi)/Real.pi)*
        (∑' l : ℕ, secondMomentMajorant lo hi (l+L)) := by
  have hA := hlo.trans_le hAlo
  have hE : 0 ≤ ∑ i, (d i)^2 := Finset.sum_nonneg (fun i _ => sq_nonneg _)
  simp_rw [residual_peak_second_model_coefficient hn q hq d hA B]
  rw [← Finset.mul_sum]
  unfold residualSecondLeading
  rw [← mul_sub,abs_mul,abs_mul,abs_mul,residualPhaseSign_abs,one_mul,
    abs_of_nonneg (Real.sqrt_nonneg _),abs_of_pos (Real.exp_pos _)]
  have he : Real.exp (-B^2/(2*A^2*residualVariance q)) ≤ 1 := by
    apply Real.exp_le_one_iff.mpr
    have hden : 0 < 2*A^2*residualVariance q := by
      have hV := residualVariance_pos hn q hq
      positivity
    exact div_nonpos_of_nonpos_of_nonneg (neg_nonpos.mpr (sq_nonneg _)) hden.le
  have htail := smoothedSecondMoment_partial_error hlo hAlo hAhi hE L (B+(n%2:ℕ)*A)
  have hm := mul_le_mul_of_nonneg_left htail
    (Real.sqrt_nonneg (2/(Real.pi*residualVariance q)))
  have hbound : Real.sqrt (2/(Real.pi*residualVariance q))*
      Real.exp (-B^2/(2*A^2*residualVariance q))*
        |(∑ l ∈ Finset.range L, smoothedCoefficient A (∑ i, (d i)^2) l * (residualPeak A l)^2 *
          Real.sin (residualPeak A l*(B+(n%2:ℕ)*A))) -
          smoothedSecondMoment A (∑ i, (d i)^2) (B+(n%2:ℕ)*A)| ≤
      Real.sqrt (2/(Real.pi*residualVariance q))*
        (∑' l : ℕ, secondMomentMajorant lo hi (l+L)) := by
    apply le_trans _ hm
    have hprod := mul_le_mul_of_nonneg_right
      (mul_le_of_le_one_right (Real.sqrt_nonneg (2/(Real.pi*residualVariance q))) he)
      (abs_nonneg ((∑ l ∈ Finset.range L, smoothedCoefficient A (∑ i, (d i)^2) l * (residualPeak A l)^2 *
          Real.sin (residualPeak A l*(B+(n%2:ℕ)*A))) -
          smoothedSecondMoment A (∑ i, (d i)^2) (B+(n%2:ℕ)*A)))
    exact hprod
  have hmul := mul_le_mul_of_nonneg_left hbound (Real.sqrt_nonneg (residualVariance q))
  apply hmul.trans_eq
  rw [← mul_assoc,residual_sqrt_normalization hn q hq]

end NeuralGeneralization.OnlineLowerTanh
