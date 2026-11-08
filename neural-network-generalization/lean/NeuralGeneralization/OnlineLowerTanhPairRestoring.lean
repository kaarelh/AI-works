import NeuralGeneralization.OnlineLowerTanhExternalAverage
import NeuralGeneralization.OnlineLowerTanhRestoringWindow

/-! # Actual negative rest curvature from near-optimal residual mixtures -/
noncomputable section
open scoped BigOperators Topology
open MeasureTheory Filter Set
namespace NeuralGeneralization.OnlineLowerTanh
namespace ResidualSequence
variable {ι : Type*} [Fintype ι] [DecidableEq ι] (S : ResidualSequence ι)

/-- The analytic input to strict pair balancing. The rest response is an
actual finite mixture of tanh parity coefficients; the outside second moment
is negligible on the bulk variance scale. Near-maximal signed value at zero
forces uniformly negative signed second derivative on a fixed bias window. -/
theorem eventual_restoring_window (P : ℕ → ℕ) (p β : (k : ℕ) → Fin (P k) → ℝ)
    (σ : ℕ → ℝ) (hσ : ∀ k, |σ k| ≤ 1)
    (hp : ∀ k i, 0 ≤ p k i) (hsum : ∀ k, ∑ i,p k i=1)
    (hmoment : Tendsto (fun k => (residualScale (S.A k) (S.alphabet k))^2*
      (∑ i,p k i*(β k i)^2)) atTop (𝓝 0)) (hhi2 : S.hi ≤ 2)
    (hnear : ∀ ε > 0, ∀ᶠ k in atTop,
      Real.sqrt (2/Real.pi)*periodicFourierMaximum (S.A k)-ε ≤
        σ k*S.normalization k*(∑ i,p k i*parityCorrelation (S.incoming k) (β k i))) :
    ∃ δ c : ℝ, 0 < δ ∧ 0 < c ∧ ∀ᶠ k in atTop, ∀ b : ℝ, |b| ≤ δ →
      σ k*S.normalization k*(∑ i,p k i*parityBiasSecond (S.incoming k) (β k i+b)) ≤ -c := by
  let c₀ : ℝ := (Real.pi/S.hi)/Real.sinh (periodicDecay S.lo)
  let M : ℝ := ∑' l : ℕ, firstMomentMajorant S.lo S.hi l
  let δ : ℝ := c₀/(1000*(M+1))
  let H : ℝ := Real.sqrt (2/Real.pi)
  let K : ℝ := (1/1000)*periodicFrequency S.hi^2*c₀
  let c : ℝ := H*K/2
  let ε₀ : ℝ := H*c₀/10000
  have hc₀ : 0 < c₀ := by dsimp [c₀]; positivity [S.hi_pos,Real.sinh_pos_iff.mpr (periodicDecay_pos S.lo_pos)]
  have hM : 0 ≤ M := tsum_nonneg (firstMomentMajorant_nonneg S.lo_pos S.hi_pos)
  have hδ : 0 < δ := by dsimp [δ]; positivity
  have hH : 0 < H := by dsimp [H]; positivity
  have hK : 0 < K := by dsimp [K]; positivity [periodicFrequency_pos S.hi_pos]
  have hc : 0 < c := by dsimp [c]; positivity
  have hε : 0 < ε₀ := by dsimp [ε₀]; positivity
  refine ⟨δ,c,hδ,hc,?_⟩
  filter_upwards [S.uniform_external_average P p β hp hsum hmoment hhi2 δ ε₀ hε,
    S.uniform_external_second_average P p β hp hsum hmoment δ c hc,hnear ε₀ hε]
    with k hv hd hn b hb
  have hvalue := hv 0 (by simpa only [abs_zero] using hδ.le)
  simp only [add_zero] at hvalue
  have hmult := mul_le_of_le_one_left
    (abs_nonneg (S.normalization k*(∑ i,p k i*parityCorrelation (S.incoming k) (β k i))-
      H*(∑ i,p k i*S.phaseResponse k (β k i)))) (hσ k)
  have hval : |σ k*S.normalization k*(∑ i,p k i*parityCorrelation (S.incoming k) (β k i))-
      H*(∑ i,p k i*(σ k*S.phaseResponse k (β k i)))| < ε₀ := by
    have he : σ k*S.normalization k*(∑ i,p k i*parityCorrelation (S.incoming k) (β k i))-
        H*(∑ i,p k i*(σ k*S.phaseResponse k (β k i))) =
        σ k*(S.normalization k*(∑ i,p k i*parityCorrelation (S.incoming k) (β k i))-
          H*(∑ i,p k i*S.phaseResponse k (β k i))) := by
      have hs : (∑ i,p k i*(σ k*S.phaseResponse k (β k i))) =
          σ k*(∑ i,p k i*S.phaseResponse k (β k i)) := by
        rw [Finset.mul_sum]
        apply Finset.sum_congr rfl
        intro i _
        ring
      rw [hs]
      ring
    rw [he,abs_mul]
    exact hmult.trans_lt hvalue
  have hclower : c₀ ≤ periodicCoefficient (S.A k) 0 :=
    periodicCoefficient_zero_lower S.lo_pos (S.A_lo k) (S.A_hi k)
  have hF := periodicFourierMaximum_lower (S.gain_pos k) ((S.A_hi k).trans hhi2)
  have hFmul := mul_le_mul_of_nonneg_left hF hH.le
  have hcMul := mul_le_mul_of_nonneg_left hclower hH.le
  have hnearPhase : (999/1000)*periodicFourierMaximum (S.A k) ≤
      ∑ i,p k i*(σ k*S.phaseResponse k (β k i)) := by
    have hvlow := (abs_lt.mp hval).2
    by_contra hnot
    have hstrict := mul_lt_mul_of_pos_left (lt_of_not_ge hnot) hH
    dsimp [ε₀,H] at hn hval hvlow hFmul hcMul hstrict
    nlinarith
  have hE : 0 ≤ ∑ i,(S.d k i)^2 := Finset.sum_nonneg (fun i _ => sq_nonneg _)
  have hrest := smoothed_restoring_window (p k)
    (fun i => β k i+(S.N k%2:ℕ)*S.A k) S.lo_pos (S.A_lo k) (S.A_hi k)
    hhi2 hE (hσ k) (hp k) (hsum k) hc₀ hclower hnearPhase b hb
  have hω : periodicFrequency S.hi ≤ periodicFrequency (S.A k) := by
    unfold periodicFrequency
    exact div_le_div_of_nonneg_left Real.pi_pos.le (by positivity [S.gain_pos k])
      (by linarith [S.A_hi k])
  have hω2 := (sq_le_sq₀ (periodicFrequency_pos S.hi_pos).le (periodicFrequency_pos (S.gain_pos k)).le).mpr hω
  have hprod := mul_le_mul hω2 hclower hc₀.le (sq_nonneg _)
  have hrest' : -(σ k*(∑ i,p k i*S.phaseSecondMoment k (β k i+b))) ≤ -K := by
    have he : (∑ i,p k i*(σ k*(-smoothedSecondMoment (S.A k) (∑ i,(S.d k i)^2)
        ((β k i+(S.N k%2:ℕ)*S.A k)+b)))) =
        -(σ k*(∑ i,p k i*S.phaseSecondMoment k (β k i+b))) := by
      rw [Finset.mul_sum,← Finset.sum_neg_distrib]
      apply Finset.sum_congr rfl
      intro i _
      unfold phaseSecondMoment
      rw [show (β k i+(S.N k%2:ℕ)*S.A k)+b=(β k i+b)+(S.N k%2:ℕ)*S.A k by ring]
      ring
    rw [he] at hrest
    dsimp [K]
    nlinarith
  have hder := hd b hb
  have hderMul := mul_le_of_le_one_left
    (abs_nonneg (S.normalization k*(∑ i,p k i*parityBiasSecond (S.incoming k) (β k i+b))+
      H*(∑ i,p k i*S.phaseSecondMoment k (β k i+b)))) (hσ k)
  have hder' : |σ k*S.normalization k*(∑ i,p k i*parityBiasSecond (S.incoming k) (β k i+b))+
      H*(σ k*(∑ i,p k i*S.phaseSecondMoment k (β k i+b)))| < c := by
    rw [show σ k*S.normalization k*(∑ i,p k i*parityBiasSecond (S.incoming k) (β k i+b))+
      H*(σ k*(∑ i,p k i*S.phaseSecondMoment k (β k i+b))) =
      σ k*(S.normalization k*(∑ i,p k i*parityBiasSecond (S.incoming k) (β k i+b))+
        H*(∑ i,p k i*S.phaseSecondMoment k (β k i+b))) by ring,abs_mul]
    exact hderMul.trans_lt hder
  have hdUpper := (abs_lt.mp hder').2
  have hrestMul := mul_le_mul_of_nonneg_left hrest' hH.le
  dsimp [c] at hdUpper ⊢
  nlinarith

theorem eventual_signed_restoring_window (P : ℕ → ℕ) (p β ν : (k : ℕ) → Fin (P k) → ℝ)
    (hν : ∀ k i, |ν k i| ≤ 1)
    (σ : ℕ → ℝ) (hσ : ∀ k, |σ k| ≤ 1)
    (hp : ∀ k i, 0 ≤ p k i) (hsum : ∀ k, ∑ i,p k i=1)
    (hmoment : Tendsto (fun k => (residualScale (S.A k) (S.alphabet k))^2*
      (∑ i,p k i*(β k i)^2)) atTop (𝓝 0)) (hhi2 : S.hi ≤ 2)
    (hnear : ∀ ε > 0, ∀ᶠ k in atTop,
      Real.sqrt (2/Real.pi)*periodicFourierMaximum (S.A k)-ε ≤
        σ k*S.normalization k*(∑ i,p k i*(ν k i*parityCorrelation (S.incoming k) (β k i)))) :
    ∃ δ c : ℝ, 0 < δ ∧ 0 < c ∧ ∀ᶠ k in atTop, ∀ b : ℝ, |b| ≤ δ →
      σ k*S.normalization k*(∑ i,p k i*(ν k i*parityBiasSecond (S.incoming k) (β k i+b))) ≤ -c := by
  let c₀ : ℝ := (Real.pi/S.hi)/Real.sinh (periodicDecay S.lo)
  let M : ℝ := ∑' l : ℕ, firstMomentMajorant S.lo S.hi l
  let δ : ℝ := c₀/(1000*(M+1))
  let H : ℝ := Real.sqrt (2/Real.pi)
  let K : ℝ := (1/1000)*periodicFrequency S.hi^2*c₀
  let c : ℝ := H*K/2
  let ε₀ : ℝ := H*c₀/10000
  have hc₀ : 0 < c₀ := by dsimp [c₀]; positivity [S.hi_pos,Real.sinh_pos_iff.mpr (periodicDecay_pos S.lo_pos)]
  have hM : 0 ≤ M := tsum_nonneg (firstMomentMajorant_nonneg S.lo_pos S.hi_pos)
  have hδ : 0 < δ := by dsimp [δ]; positivity
  have hH : 0 < H := by dsimp [H]; positivity
  have hK : 0 < K := by dsimp [K]; positivity [periodicFrequency_pos S.hi_pos]
  have hc : 0 < c := by dsimp [c]; positivity
  have hε : 0 < ε₀ := by dsimp [ε₀]; positivity
  refine ⟨δ,c,hδ,hc,?_⟩
  filter_upwards [S.uniform_signed_external_average P p β ν hν hp hsum hmoment hhi2 δ ε₀ hε,
    S.uniform_signed_external_second_average P p β ν hν hp hsum hmoment δ c hc,hnear ε₀ hε]
    with k hv hd hn b hb
  have hvalue := hv 0 (by simpa only [abs_zero] using hδ.le)
  simp only [add_zero] at hvalue
  have hmult := mul_le_of_le_one_left
    (abs_nonneg (S.normalization k*(∑ i,p k i*(ν k i*parityCorrelation (S.incoming k) (β k i)))-
      H*(∑ i,p k i*(ν k i*S.phaseResponse k (β k i))))) (hσ k)
  have hval : |σ k*S.normalization k*(∑ i,p k i*(ν k i*parityCorrelation (S.incoming k) (β k i)))-
      H*(∑ i,p k i*((σ k*ν k i)*S.phaseResponse k (β k i)))| < ε₀ := by
    have he : σ k*S.normalization k*(∑ i,p k i*(ν k i*parityCorrelation (S.incoming k) (β k i)))-
        H*(∑ i,p k i*((σ k*ν k i)*S.phaseResponse k (β k i))) =
        σ k*(S.normalization k*(∑ i,p k i*(ν k i*parityCorrelation (S.incoming k) (β k i)))-
          H*(∑ i,p k i*(ν k i*S.phaseResponse k (β k i)))) := by
      have hs : (∑ i,p k i*((σ k*ν k i)*S.phaseResponse k (β k i))) =
          σ k*(∑ i,p k i*(ν k i*S.phaseResponse k (β k i))) := by
        rw [Finset.mul_sum]
        apply Finset.sum_congr rfl
        intro i _
        ring
      rw [hs]
      ring
    rw [he,abs_mul]
    exact hmult.trans_lt hvalue
  have hclower : c₀ ≤ periodicCoefficient (S.A k) 0 :=
    periodicCoefficient_zero_lower S.lo_pos (S.A_lo k) (S.A_hi k)
  have hF := periodicFourierMaximum_lower (S.gain_pos k) ((S.A_hi k).trans hhi2)
  have hFmul := mul_le_mul_of_nonneg_left hF hH.le
  have hcMul := mul_le_mul_of_nonneg_left hclower hH.le
  have hnearPhase : (999/1000)*periodicFourierMaximum (S.A k) ≤
      ∑ i,p k i*((σ k*ν k i)*S.phaseResponse k (β k i)) := by
    have hvlow := (abs_lt.mp hval).2
    by_contra hnot
    have hstrict := mul_lt_mul_of_pos_left (lt_of_not_ge hnot) hH
    dsimp [ε₀,H] at hn hval hvlow hFmul hcMul hstrict
    nlinarith
  have hE : 0 ≤ ∑ i,(S.d k i)^2 := Finset.sum_nonneg (fun i _ => sq_nonneg _)
  have hsign (i : Fin (P k)) : |σ k*ν k i| ≤ 1 := by
    rw [abs_mul]
    have h := mul_le_mul (hσ k) (hν k i) (abs_nonneg (ν k i)) (by norm_num : (0:ℝ)≤1)
    simpa only [mul_one] using h
  have hrest := smoothed_restoring_window_signs (p k)
    (fun i => β k i+(S.N k%2:ℕ)*S.A k) (fun i => σ k*ν k i) S.lo_pos (S.A_lo k) (S.A_hi k)
    hhi2 hE hsign (hp k) (hsum k) hc₀ hclower hnearPhase b hb
  have hω : periodicFrequency S.hi ≤ periodicFrequency (S.A k) := by
    unfold periodicFrequency
    exact div_le_div_of_nonneg_left Real.pi_pos.le (by positivity [S.gain_pos k])
      (by linarith [S.A_hi k])
  have hω2 := (sq_le_sq₀ (periodicFrequency_pos S.hi_pos).le (periodicFrequency_pos (S.gain_pos k)).le).mpr hω
  have hprod := mul_le_mul hω2 hclower hc₀.le (sq_nonneg _)
  have hrest' : -(σ k*(∑ i,p k i*(ν k i*S.phaseSecondMoment k (β k i+b)))) ≤ -K := by
    have he : (∑ i,p k i*((σ k*ν k i)*(-smoothedSecondMoment (S.A k) (∑ i,(S.d k i)^2)
        ((β k i+(S.N k%2:ℕ)*S.A k)+b)))) =
        -(σ k*(∑ i,p k i*(ν k i*S.phaseSecondMoment k (β k i+b)))) := by
      rw [Finset.mul_sum,← Finset.sum_neg_distrib]
      apply Finset.sum_congr rfl
      intro i _
      unfold phaseSecondMoment
      rw [show (β k i+(S.N k%2:ℕ)*S.A k)+b=(β k i+b)+(S.N k%2:ℕ)*S.A k by ring]
      ring
    rw [he] at hrest
    dsimp [K]
    nlinarith
  have hder := hd b hb
  have hderMul := mul_le_of_le_one_left
    (abs_nonneg (S.normalization k*(∑ i,p k i*(ν k i*parityBiasSecond (S.incoming k) (β k i+b)))+
      H*(∑ i,p k i*(ν k i*S.phaseSecondMoment k (β k i+b))))) (hσ k)
  have hder' : |σ k*S.normalization k*(∑ i,p k i*(ν k i*parityBiasSecond (S.incoming k) (β k i+b)))+
      H*(σ k*(∑ i,p k i*(ν k i*S.phaseSecondMoment k (β k i+b))))| < c := by
    rw [show σ k*S.normalization k*(∑ i,p k i*(ν k i*parityBiasSecond (S.incoming k) (β k i+b)))+
      H*(σ k*(∑ i,p k i*(ν k i*S.phaseSecondMoment k (β k i+b)))) =
      σ k*(S.normalization k*(∑ i,p k i*(ν k i*parityBiasSecond (S.incoming k) (β k i+b)))+
        H*(∑ i,p k i*(ν k i*S.phaseSecondMoment k (β k i+b)))) by ring,abs_mul]
    exact hderMul.trans_lt hder
  have hdUpper := (abs_lt.mp hder').2
  have hrestMul := mul_le_mul_of_nonneg_left hrest' hH.le
  dsimp [c] at hdUpper ⊢
  nlinarith

end ResidualSequence
end NeuralGeneralization.OnlineLowerTanh
