import NeuralGeneralization.OnlineLowerTanhResidualMixture
import NeuralGeneralization.OnlineLowerTanhGaussianMixture

/-! # Actual conditional tanh correlations with negligible outside energy -/
noncomputable section
open scoped BigOperators Topology
open MeasureTheory Filter Set
namespace NeuralGeneralization.OnlineLowerTanh
namespace ResidualSequence
variable {ι : Type*} [Fintype ι] [DecidableEq ι] (S : ResidualSequence ι)

lemma scaled_external_moment_of_variance (moment : ℕ → ℝ)
    (h : Tendsto (fun k => moment k/residualVariance (S.alphabet k)) atTop (𝓝 0)) :
    Tendsto (fun k => (residualScale (S.A k) (S.alphabet k))^2*moment k) atTop (𝓝 0) := by
  have hA₀ : 0 < S.A₀ := S.lo_pos.trans_le S.A₀_lo
  have ht := h.div (S.A_tendsto.pow 2) (by positivity : S.A₀^2≠0)
  simp only [zero_div] at ht
  convert ht using 1
  funext k
  have hV := residualVariance_pos (S.N_pos k) (S.alphabet k) (S.alphabet_pos k)
  unfold residualScale
  rw [inv_pow,mul_pow,Real.sq_sqrt hV.le]
  simp only [Pi.div_apply]
  ring

/-- Actual conditional values after averaging over an arbitrary finite
outside distribution with negligible scaled second moment. -/
theorem uniform_external_average (P : ℕ → ℕ) (p β : (k : ℕ) → Fin (P k) → ℝ)
    (hp : ∀ k i, 0 ≤ p k i) (hsum : ∀ k, ∑ i,p k i=1)
    (hmoment : Tendsto (fun k => (residualScale (S.A k) (S.alphabet k))^2*
      (∑ i,p k i*(β k i)^2)) atTop (𝓝 0)) (hhi2 : S.hi ≤ 2) (D : ℝ) :
    ∀ ε > 0, ∀ᶠ k in atTop, ∀ b : ℝ, |b| ≤ D →
      |S.normalization k*(∑ i,p k i*parityCorrelation (S.incoming k) (β k i+b))-
        Real.sqrt (2/Real.pi)*(∑ i,p k i*S.phaseResponse k (β k i+b))| < ε := by
  have hg (k : ℕ) (B : ℝ) : |S.phaseResponse k B| ≤ 1 :=
    smoothedResponse_compact_abs_le_one (S.gain_pos k) ((S.A_hi k).trans hhi2)
      (Finset.sum_nonneg (fun i _ => sq_nonneg _)) _
  have ht := uniform_average_of_gaussian_approx P p β
    (fun k => residualScale (S.A k) (S.alphabet k))
    (fun k B => S.normalization k*parityCorrelation (S.incoming k) B) S.phaseResponse
    (Real.sqrt_nonneg (2/Real.pi)) (by norm_num : (0:ℝ)≤1) hp hsum hg S.scale_tendsto
    hmoment S.uniform_normalized_clt D
  intro ε hε
  filter_upwards [ht ε hε] with k hk b hb
  have he : (∑ i,p k i*(S.normalization k*parityCorrelation (S.incoming k) (β k i+b))) =
      S.normalization k*(∑ i,p k i*parityCorrelation (S.incoming k) (β k i+b)) := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro i _
    ring
  simpa only [he] using hk b hb

/-- The same averaging conclusion for the literal second bias derivative. -/
theorem uniform_external_second_average (P : ℕ → ℕ) (p β : (k : ℕ) → Fin (P k) → ℝ)
    (hp : ∀ k i, 0 ≤ p k i) (hsum : ∀ k, ∑ i,p k i=1)
    (hmoment : Tendsto (fun k => (residualScale (S.A k) (S.alphabet k))^2*
      (∑ i,p k i*(β k i)^2)) atTop (𝓝 0)) (D : ℝ) :
    ∀ ε > 0, ∀ᶠ k in atTop, ∀ b : ℝ, |b| ≤ D →
      |S.normalization k*(∑ i,p k i*parityBiasSecond (S.incoming k) (β k i+b))+
        Real.sqrt (2/Real.pi)*(∑ i,p k i*S.phaseSecondMoment k (β k i+b))| < ε := by
  let M := ∑' l : ℕ, secondMomentMajorant S.lo S.hi l
  have hM : 0 ≤ M := tsum_nonneg (secondMomentMajorant_nonneg S.lo_pos S.hi_pos)
  have hg (k : ℕ) (B : ℝ) : |S.phaseSecondMoment k B| ≤ M :=
    smoothedSecondMoment_abs_le_majorant S.lo_pos (S.A_lo k) (S.A_hi k)
      (Finset.sum_nonneg (fun i _ => sq_nonneg _)) _
  have ht := uniform_average_of_gaussian_approx P p β
    (fun k => residualScale (S.A k) (S.alphabet k))
    (fun k B => S.normalization k*(-parityBiasSecond (S.incoming k) B)) S.phaseSecondMoment
    (Real.sqrt_nonneg (2/Real.pi)) hM hp hsum hg S.scale_tendsto
    hmoment S.uniform_normalized_second_clt D
  intro ε hε
  filter_upwards [ht ε hε] with k hk b hb
  have he : (∑ i,p k i*(S.normalization k*(-parityBiasSecond (S.incoming k) (β k i+b))))-
      Real.sqrt (2/Real.pi)*(∑ i,p k i*S.phaseSecondMoment k (β k i+b)) =
      -(S.normalization k*(∑ i,p k i*parityBiasSecond (S.incoming k) (β k i+b))+
        Real.sqrt (2/Real.pi)*(∑ i,p k i*S.phaseSecondMoment k (β k i+b))) := by
    have he' : (∑ i,p k i*(S.normalization k*(-parityBiasSecond (S.incoming k) (β k i+b)))) =
        (-S.normalization k)*(∑ i,p k i*parityBiasSecond (S.incoming k) (β k i+b)) := by
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro i _
      ring
    rw [he']
    ring
  have hh := hk b hb
  rw [he,abs_neg] at hh
  exact hh

theorem uniform_signed_external_average (P : ℕ → ℕ) (p β ν : (k : ℕ) → Fin (P k) → ℝ)
    (hν : ∀ k i, |ν k i| ≤ 1)
    (hp : ∀ k i, 0 ≤ p k i) (hsum : ∀ k, ∑ i,p k i=1)
    (hmoment : Tendsto (fun k => (residualScale (S.A k) (S.alphabet k))^2*
      (∑ i,p k i*(β k i)^2)) atTop (𝓝 0)) (hhi2 : S.hi ≤ 2) (D : ℝ) :
    ∀ ε > 0, ∀ᶠ k in atTop, ∀ b : ℝ, |b| ≤ D →
      |S.normalization k*(∑ i,p k i*(ν k i*parityCorrelation (S.incoming k) (β k i+b)))-
        Real.sqrt (2/Real.pi)*(∑ i,p k i*(ν k i*S.phaseResponse k (β k i+b)))| < ε := by
  have hg (k : ℕ) (B : ℝ) : |S.phaseResponse k B| ≤ 1 :=
    smoothedResponse_compact_abs_le_one (S.gain_pos k) ((S.A_hi k).trans hhi2)
      (Finset.sum_nonneg (fun i _ => sq_nonneg _)) _
  have ht := uniform_signed_average_of_gaussian_approx P p β ν hν
    (fun k => residualScale (S.A k) (S.alphabet k))
    (fun k B => S.normalization k*parityCorrelation (S.incoming k) B) S.phaseResponse
    (Real.sqrt_nonneg (2/Real.pi)) (by norm_num : (0:ℝ)≤1) hp hsum hg S.scale_tendsto
    hmoment S.uniform_normalized_clt D
  intro ε hε
  filter_upwards [ht ε hε] with k hk b hb
  have he : (∑ i,p k i*(ν k i*(S.normalization k*parityCorrelation (S.incoming k) (β k i+b)))) =
      S.normalization k*(∑ i,p k i*(ν k i*parityCorrelation (S.incoming k) (β k i+b))) := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro i _
    ring
  simpa only [he] using hk b hb

/-- The same averaging conclusion for the literal second bias derivative. -/
theorem uniform_signed_external_second_average (P : ℕ → ℕ) (p β ν : (k : ℕ) → Fin (P k) → ℝ)
    (hν : ∀ k i, |ν k i| ≤ 1)
    (hp : ∀ k i, 0 ≤ p k i) (hsum : ∀ k, ∑ i,p k i=1)
    (hmoment : Tendsto (fun k => (residualScale (S.A k) (S.alphabet k))^2*
      (∑ i,p k i*(β k i)^2)) atTop (𝓝 0)) (D : ℝ) :
    ∀ ε > 0, ∀ᶠ k in atTop, ∀ b : ℝ, |b| ≤ D →
      |S.normalization k*(∑ i,p k i*(ν k i*parityBiasSecond (S.incoming k) (β k i+b)))+
        Real.sqrt (2/Real.pi)*(∑ i,p k i*(ν k i*S.phaseSecondMoment k (β k i+b)))| < ε := by
  let M := ∑' l : ℕ, secondMomentMajorant S.lo S.hi l
  have hM : 0 ≤ M := tsum_nonneg (secondMomentMajorant_nonneg S.lo_pos S.hi_pos)
  have hg (k : ℕ) (B : ℝ) : |S.phaseSecondMoment k B| ≤ M :=
    smoothedSecondMoment_abs_le_majorant S.lo_pos (S.A_lo k) (S.A_hi k)
      (Finset.sum_nonneg (fun i _ => sq_nonneg _)) _
  have ht := uniform_signed_average_of_gaussian_approx P p β ν hν
    (fun k => residualScale (S.A k) (S.alphabet k))
    (fun k B => S.normalization k*(-parityBiasSecond (S.incoming k) B)) S.phaseSecondMoment
    (Real.sqrt_nonneg (2/Real.pi)) hM hp hsum hg S.scale_tendsto
    hmoment S.uniform_normalized_second_clt D
  intro ε hε
  filter_upwards [ht ε hε] with k hk b hb
  have he : (∑ i,p k i*(ν k i*(S.normalization k*(-parityBiasSecond (S.incoming k) (β k i+b)))))-
      Real.sqrt (2/Real.pi)*(∑ i,p k i*(ν k i*S.phaseSecondMoment k (β k i+b))) =
      -(S.normalization k*(∑ i,p k i*(ν k i*parityBiasSecond (S.incoming k) (β k i+b)))+
        Real.sqrt (2/Real.pi)*(∑ i,p k i*(ν k i*S.phaseSecondMoment k (β k i+b)))) := by
    have he' : (∑ i,p k i*(ν k i*(S.normalization k*(-parityBiasSecond (S.incoming k) (β k i+b))))) =
        (-S.normalization k)*(∑ i,p k i*(ν k i*parityBiasSecond (S.incoming k) (β k i+b))) := by
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro i _
      ring
    rw [he']
    ring
  have hh := hk b hb
  rw [he,abs_neg] at hh
  exact hh

end ResidualSequence
end NeuralGeneralization.OnlineLowerTanh
