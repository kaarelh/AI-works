import NeuralGeneralization.OnlineLowerTanhResidualFinite

/-! # Every fixed Fourier moment of the residual leading response -/
noncomputable section
open scoped BigOperators Topology
open MeasureTheory Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

def smoothedMoment (j : ℕ) (a E b δ : ℝ) : ℝ :=
  ∑' l : ℕ, smoothedCoefficient a E l*(residualPeak a l)^j*
    Real.sin (residualPeak a l*b+δ)

def residualMomentLeading {n : ℕ} (j : ℕ) (q : Fin n → ℕ)
    (d : Fin n → ℝ) (A B δ : ℝ) : ℝ :=
  residualPhaseSign q*Real.sqrt (2/(Real.pi*residualVariance q))*
    Real.exp (-B^2/(2*A^2*residualVariance q))*
      smoothedMoment j A (∑ i, (d i)^2) (B+(n%2:ℕ)*A) δ

def momentMajorant (j : ℕ) (lo hi : ℝ) (l : ℕ) : ℝ :=
  ((Real.pi/lo)/Real.sinh (periodicDecay hi))*(2*periodicFrequency lo)^j*
    ((l:ℝ)+1)^j*periodicRatio hi^l

lemma momentMajorant_nonneg (j : ℕ) {lo hi : ℝ} (hlo : 0 < lo) (hhi : 0 < hi) (l : ℕ) :
    0 ≤ momentMajorant j lo hi l := by
  unfold momentMajorant
  positivity [Real.sinh_pos_iff.mpr (periodicDecay_pos hhi), periodicFrequency_pos hlo,
    (periodicRatio_mem hhi).1]

lemma momentMajorant_summable (j : ℕ) {lo hi : ℝ} (hhi : 0 < hi) :
    Summable (momentMajorant j lo hi) := by
  have hq : |periodicRatio hi| < 1 := by
    rw [abs_of_pos (periodicRatio_mem hhi).1]
    exact (periodicRatio_mem hhi).2
  have hp := (summable_pow_mul_geometric_of_norm_lt_one j (r:=periodicRatio hi) hq).comp_injective
    (fun i k (h:i+1=k+1) => Nat.add_right_cancel h)
  have hqne : periodicRatio hi ≠ 0 := (periodicRatio_mem hhi).1.ne'
  have hs : Summable (fun l:ℕ => ((l:ℝ)+1)^j*periodicRatio hi^l) := by
    apply (hp.mul_right (periodicRatio hi)⁻¹).congr
    intro l
    change (((l+1:ℕ):ℝ)^j*periodicRatio hi^(l+1))*(periodicRatio hi)⁻¹ = _
    simp only [Nat.cast_add,Nat.cast_one,pow_succ]
    field_simp [hqne]
  apply (hs.mul_left (((Real.pi/lo)/Real.sinh (periodicDecay hi))*(2*periodicFrequency lo)^j)).congr
  intro l
  unfold momentMajorant
  ring

lemma smoothedMoment_coefficient_bound (j : ℕ) {A E lo hi : ℝ}
    (hlo : 0 < lo) (hAlo : lo ≤ A) (hAhi : A ≤ hi) (hE : 0 ≤ E) (l : ℕ) :
    smoothedCoefficient A E l*(residualPeak A l)^j ≤ momentMajorant j lo hi l := by
  have hA := hlo.trans_le hAlo
  have hhi := hA.trans_le hAhi
  have hw : periodicFrequency A ≤ periodicFrequency lo := by
    unfold periodicFrequency
    exact div_le_div_of_nonneg_left Real.pi_pos.le (by positivity) (by linarith)
  have hp : (residualPeak A l)^j ≤ (2*periodicFrequency lo)^j*((l:ℝ)+1)^j := by
    rw [← mul_pow]
    apply pow_le_pow_left₀ (residual_peak_pos hA l).le
    unfold residualPeak
    have h1:=mul_le_mul_of_nonneg_left hw (show 0≤2*(l:ℝ)+1 by positivity)
    nlinarith [periodicFrequency_pos hlo]
  have hh := mul_le_mul (smoothedCoefficient_compact_bound hlo hAlo hAhi hE l) hp
    (pow_nonneg (residual_peak_pos hA l).le j)
    (by positivity [Real.sinh_pos_iff.mpr (periodicDecay_pos hhi), (periodicRatio_mem hhi).1])
  unfold momentMajorant
  nlinarith

lemma smoothedMoment_summable (j : ℕ) {A E : ℝ} (hA : 0 < A) (hE : 0 ≤ E) (b δ : ℝ) :
    Summable (fun l : ℕ => smoothedCoefficient A E l*(residualPeak A l)^j*
      Real.sin (residualPeak A l*b+δ)) := by
  apply (momentMajorant_summable j (lo:=A) hA).of_norm_bounded
  intro l
  rw [Real.norm_eq_abs,abs_mul,abs_mul,abs_of_pos (smoothedCoefficient_pos hA E l),
    abs_of_nonneg (pow_nonneg (residual_peak_pos hA l).le j)]
  exact (mul_le_of_le_one_right
    (mul_nonneg (smoothedCoefficient_pos hA E l).le (pow_nonneg (residual_peak_pos hA l).le j))
    (Real.abs_sin_le_one _)).trans
      (smoothedMoment_coefficient_bound j hA (le_refl _) (le_refl _) hE l)

lemma smoothedMoment_partial_error (j : ℕ) {A E lo hi : ℝ}
    (hlo : 0 < lo) (hAlo : lo ≤ A) (hAhi : A ≤ hi) (hE : 0 ≤ E) (L : ℕ) (b δ : ℝ) :
    |(∑ l ∈ Finset.range L, smoothedCoefficient A E l*(residualPeak A l)^j*
      Real.sin (residualPeak A l*b+δ))-smoothedMoment j A E b δ| ≤
        ∑' l : ℕ, momentMajorant j lo hi (l+L) := by
  have hA := hlo.trans_le hAlo
  have hhi := hA.trans_le hAhi
  let f : ℕ → ℝ := fun l => smoothedCoefficient A E l*(residualPeak A l)^j*
    Real.sin (residualPeak A l*b+δ)
  have hs : Summable f := smoothedMoment_summable j hA hE b δ
  have hsplit := hs.sum_add_tsum_nat_add L
  have he : (∑ l ∈ Finset.range L, f l)-smoothedMoment j A E b δ = -(∑' l : ℕ, f (l+L)) := by
    change _-(∑' l, f l)=_
    linarith
  change |(∑ l ∈ Finset.range L,f l)-smoothedMoment j A E b δ|≤_
  rw [he,abs_neg]
  have hm : Summable (fun l : ℕ => momentMajorant j lo hi (l+L)) :=
    (momentMajorant_summable j (lo:=lo) hhi).comp_injective (fun i k h => Nat.add_right_cancel h)
  have hbound (l : ℕ) : ‖f (l+L)‖ ≤ momentMajorant j lo hi (l+L) := by
    dsimp [f]
    rw [abs_mul,abs_mul,abs_of_pos (smoothedCoefficient_pos hA E _),
      abs_of_nonneg (pow_nonneg (residual_peak_pos hA _).le j)]
    exact (mul_le_of_le_one_right
      (mul_nonneg (smoothedCoefficient_pos hA E _).le (pow_nonneg (residual_peak_pos hA _).le j))
      (Real.abs_sin_le_one _)).trans (smoothedMoment_coefficient_bound j hlo hAlo hAhi hE _)
  have hn := hm.of_nonneg_of_le (fun l => norm_nonneg (f (l+L))) hbound
  have ht := (norm_tsum_le_tsum_norm hn).trans (Summable.tsum_le_tsum hbound hn hm)
  simpa only [Real.norm_eq_abs] using ht

lemma residual_peak_moment_model_coefficient {n : ℕ} (hn : 0 < n) (q : Fin n → ℕ)
    (hq : ∀ i, 0 < q i) (d : Fin n → ℝ) {A : ℝ} (hA : 0 < A) (B δ : ℝ) (l j : ℕ) :
    residualPeakModel q d A B ((n:ℝ)*Real.pi/2+δ) l j =
      (residualPhaseSign q*Real.sqrt (2/(Real.pi*residualVariance q))*
        Real.exp (-B^2/(2*A^2*residualVariance q))) *
      (smoothedCoefficient A (∑ i, (d i)^2) l*(residualPeak A l)^j *
        Real.sin (residualPeak A l*(B+(n%2:ℕ)*A)+δ)) := by
  have hphase := residual_peak_signed_phase hA.ne' q l B δ
  have hcoef := residual_peak_coefficient hA.ne' (∑ i,(d i)^2) l
  unfold residualPeakModel residualDerivativeKernel
  rw [show B*residualPeak A l+((n:ℝ)*Real.pi/2+δ) =
    B*residualPeak A l+(n:ℝ)*Real.pi/2+δ by ring]
  have he : residualScale A q * (-1:ℝ)^((∑ i, (q i-1)/2)+n*l) *
      (Real.sqrt (2*Real.pi)*Real.exp (-(B*residualScale A q)^2/2)*
        Real.sin (B*residualPeak A l+(n:ℝ)*Real.pi/2+δ)*
          Real.exp (-(∑ i, (d i)^2)*(residualPeak A l)^2/2)*
          ((residualPeak A l)^j/Real.sinh (Real.pi*residualPeak A l/2))) =
      (residualScale A q*Real.sqrt (2*Real.pi)*(A/Real.pi))*
      Real.exp (-(B*residualScale A q)^2/2)*residualPhaseSign q*
      smoothedCoefficient A (∑ i, (d i)^2) l*(residualPeak A l)^j *
        Real.sin (residualPeak A l*(B+(n%2:ℕ)*A)+δ) := by
    calc
      _ = (residualScale A q*Real.sqrt (2*Real.pi)*Real.exp (-(B*residualScale A q)^2/2))*
          ((-1:ℝ)^((∑ i, (q i-1)/2)+n*l)*Real.sin (B*residualPeak A l+(n:ℝ)*Real.pi/2+δ))*
          (Real.exp (-(∑ i, (d i)^2)*(residualPeak A l)^2/2)/Real.sinh (Real.pi*residualPeak A l/2))*
          (residualPeak A l)^j := by ring
      _ = _ := by rw [hphase,hcoef]; ring
  rw [he,residual_gaussian_normalization hn q hq hA,residual_gaussian_exponent hn q hq hA]
  ring

lemma residual_moment_model_tail {n : ℕ} (hn : 0 < n) (q : Fin n → ℕ)
    (hq : ∀ i, 0 < q i) (d : Fin n → ℝ) {A lo hi : ℝ}
    (hlo : 0 < lo) (hAlo : lo ≤ A) (hAhi : A ≤ hi) (B δ : ℝ) (L j : ℕ) :
    Real.sqrt (residualVariance q)*
      |(∑ l ∈ Finset.range L, residualPeakModel q d A B ((n:ℝ)*Real.pi/2+δ) l j)-
        residualMomentLeading j q d A B δ| ≤
      (Real.sqrt (2*Real.pi)/Real.pi)*(∑' l : ℕ, momentMajorant j lo hi (l+L)) := by
  have hA := hlo.trans_le hAlo
  have hE : 0 ≤ ∑ i, (d i)^2 := Finset.sum_nonneg (fun i _ => sq_nonneg _)
  simp_rw [residual_peak_moment_model_coefficient hn q hq d hA B δ]
  rw [← Finset.mul_sum]
  unfold residualMomentLeading
  rw [← mul_sub,abs_mul,abs_mul,abs_mul,residualPhaseSign_abs,one_mul,
    abs_of_nonneg (Real.sqrt_nonneg _),abs_of_pos (Real.exp_pos _)]
  have he : Real.exp (-B^2/(2*A^2*residualVariance q)) ≤ 1 := by
    apply Real.exp_le_one_iff.mpr
    have hden : 0 < 2*A^2*residualVariance q := by
      have hV := residualVariance_pos hn q hq
      positivity
    exact div_nonpos_of_nonpos_of_nonneg (neg_nonpos.mpr (sq_nonneg _)) hden.le
  have htail := smoothedMoment_partial_error j hlo hAlo hAhi hE L (B+(n%2:ℕ)*A) δ
  have hm := mul_le_mul_of_nonneg_left htail
    (Real.sqrt_nonneg (2/(Real.pi*residualVariance q)))
  have hbound : Real.sqrt (2/(Real.pi*residualVariance q))*
      Real.exp (-B^2/(2*A^2*residualVariance q))*
        |(∑ l ∈ Finset.range L, smoothedCoefficient A (∑ i, (d i)^2) l * (residualPeak A l)^j *
          Real.sin (residualPeak A l*(B+(n%2:ℕ)*A)+δ)) -
          smoothedMoment j A (∑ i, (d i)^2) (B+(n%2:ℕ)*A) δ| ≤
      Real.sqrt (2/(Real.pi*residualVariance q))*
        (∑' l : ℕ, momentMajorant j lo hi (l+L)) := by
    apply le_trans _ hm
    exact mul_le_mul_of_nonneg_right
      (mul_le_of_le_one_right (Real.sqrt_nonneg (2/(Real.pi*residualVariance q))) he)
      (abs_nonneg _)
  have hmul := mul_le_mul_of_nonneg_left hbound (Real.sqrt_nonneg (residualVariance q))
  apply hmul.trans_eq
  rw [← mul_assoc,residual_sqrt_normalization hn q hq]

end NeuralGeneralization.OnlineLowerTanh
