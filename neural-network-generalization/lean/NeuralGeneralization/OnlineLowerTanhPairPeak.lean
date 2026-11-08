import NeuralGeneralization.OnlineLowerTanhPairRestoring

/-! # A near-maximal pair difference forces a near-maximal rest peak -/
noncomputable section
open scoped BigOperators Topology
open MeasureTheory Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

lemma smoothedResponse_abs_le_originalMaximum {a E : ℝ} (ha : 0 < a) (ha2 : a ≤ 2)
    (hE : 0 ≤ E) (b : ℝ) : |smoothedResponse a E b| ≤ periodicFourierMaximum a := by
  have hh := smoothedResponse_energy_deficit ha ha2 hE b
  have he : Real.exp (-E*periodicFrequency a^2/2) ≤ 1 := Real.exp_le_one_iff.mpr
    (by nlinarith [mul_nonneg hE (sq_nonneg (periodicFrequency a))])
  have hn : 0 ≤ periodicCoefficient a 0/100*(1-Real.exp (-E*periodicFrequency a^2/2)) := by
    apply mul_nonneg (div_nonneg (periodicCoefficient_pos ha 0).le (by norm_num))
    linarith
  linarith

namespace ResidualSequence
variable {ι : Type*} [Fintype ι] [DecidableEq ι] (S : ResidualSequence ι)

def externalCorrelation {m : ℕ} (k : ℕ) (p β ν : Fin m → ℝ) (b : ℝ) : ℝ :=
  ∑ i,p i*(ν i*parityCorrelation (S.incoming k) (β i+b))
def externalResponse {m : ℕ} (k : ℕ) (p β ν : Fin m → ℝ) (b : ℝ) : ℝ :=
  ∑ i,p i*(ν i*S.phaseResponse k (β i+b))

lemma externalResponse_cap {m : ℕ} (k : ℕ) (p β ν : Fin m → ℝ)
    (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i,p i=1) (hν : ∀ i, |ν i| ≤ 1)
    (hhi2 : S.hi ≤ 2) (b : ℝ) :
    |S.externalResponse k p β ν b| ≤ periodicFourierMaximum (S.A k) := by
  have hpoint (i : Fin m) : |ν i*S.phaseResponse k (β i+b)-0| ≤ periodicFourierMaximum (S.A k) := by
    rw [sub_zero,abs_mul]
    exact (mul_le_of_le_one_left (abs_nonneg (S.phaseResponse k (β i+b))) (hν i)).trans
      (smoothedResponse_abs_le_originalMaximum (S.gain_pos k) ((S.A_hi k).trans hhi2)
        (Finset.sum_nonneg (fun i _ => sq_nonneg _)) _)
  have hh := weighted_uniform_error p (fun i => ν i*S.phaseResponse k (β i+b)) (fun _ => 0) hp hsum hpoint
  simpa only [mul_zero,Finset.sum_const_zero,sub_zero,externalResponse] using hh

lemma externalResponse_lipschitz {m : ℕ} (k : ℕ) (p β ν : Fin m → ℝ)
    (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i,p i=1) (hν : ∀ i, |ν i| ≤ 1) (b c : ℝ) :
    |S.externalResponse k p β ν b-S.externalResponse k p β ν c| ≤
      (∑' l : ℕ, firstMomentMajorant S.lo S.hi l)*|b-c| := by
  apply weighted_uniform_error p _ _ hp hsum
  intro i
  rw [← mul_sub,abs_mul]
  have h1 := mul_le_of_le_one_left
    (abs_nonneg (S.phaseResponse k (β i+b)-S.phaseResponse k (β i+c))) (hν i)
  have h2 := smoothedResponse_lipschitz_compact (E:=∑ j,(S.d k j)^2) S.lo_pos (S.A_lo k) (S.A_hi k)
    (Finset.sum_nonneg (fun i _ => sq_nonneg _))
    ((β i+b)+(S.N k%2:ℕ)*S.A k) ((β i+c)+(S.N k%2:ℕ)*S.A k)
  rw [show ((β i+b)+(S.N k%2:ℕ)*S.A k)-((β i+c)+(S.N k%2:ℕ)*S.A k)=b-c by ring] at h2
  exact h1.trans h2

/-- The pair identity needs only a cap on the other endpoint and continuity
near zero. Both are proved here for the actual signed outside mixture. -/
theorem pair_difference_forces_rest_peak (P : ℕ → ℕ) (p β ν : (k : ℕ) → Fin (P k) → ℝ)
    (hν : ∀ k i, |ν k i| ≤ 1) (σ μ h : ℕ → ℝ) (hσ : ∀ k, |σ k| ≤ 1)
    (hp : ∀ k i, 0 ≤ p k i) (hsum : ∀ k, ∑ i,p k i=1)
    (hmoment : Tendsto (fun k => (residualScale (S.A k) (S.alphabet k))^2*
      (∑ i,p k i*(β k i)^2)) atTop (𝓝 0)) (hhi2 : S.hi ≤ 2)
    (hh : Tendsto h atTop (𝓝 0)) {D : ℝ} (hD : 0 < D)
    (hμ : ∀ᶠ k in atTop, |2*μ k| ≤ D)
    (hnear : ∀ ε > 0, ∀ᶠ k in atTop,
      Real.sqrt (2/Real.pi)*periodicFourierMaximum (S.A k)-ε ≤
        σ k*S.normalization k*
          ((S.externalCorrelation k (p k) (β k) (ν k) (2*μ k)-
            S.externalCorrelation k (p k) (β k) (ν k) (2*h k))/2)) :
    ∀ ε > 0, ∀ᶠ k in atTop,
      Real.sqrt (2/Real.pi)*periodicFourierMaximum (S.A k)-ε ≤
        (-σ k)*S.normalization k*S.externalCorrelation k (p k) (β k) (ν k) 0 := by
  intro ε hε
  let H := Real.sqrt (2/Real.pi)
  let M := ∑' l : ℕ, firstMomentMajorant S.lo S.hi l
  have hH : 0 ≤ H := Real.sqrt_nonneg _
  have hmoving := ((hh.const_mul 2).abs).const_mul (H*M)
  simp only [mul_zero,abs_zero] at hmoving
  have hsmall := (hh.const_mul 2).abs
  simp only [mul_zero,abs_zero] at hsmall
  filter_upwards [S.uniform_signed_external_average P p β ν hν hp hsum hmoment hhi2 D
      (ε/10) (by linarith),hnear (ε/10) (by linarith),hμ,
      hsmall.eventually (gt_mem_nhds hD),hmoving.eventually (gt_mem_nhds (by linarith : (0:ℝ)<ε/4))]
    with k havg hn hμk hhk hmove
  let R := fun b => S.externalCorrelation k (p k) (β k) (ν k) b
  let T := fun b => S.externalResponse k (p k) (β k) (ν k) b
  let X := fun b => S.normalization k*R b
  let Y := fun b => H*T b
  have h0 : |X 0-Y 0| < ε/10 := havg 0 (by simpa only [abs_zero] using hD.le)
  have hμval : |X (2*μ k)-Y (2*μ k)| < ε/10 := havg _ hμk
  have hhval : |X (2*h k)-Y (2*h k)| < ε/10 := havg _ hhk.le
  have hcap := mul_le_mul_of_nonneg_left (S.externalResponse_cap k (p k) (β k) (ν k)
    (hp k) (hsum k) (hν k) hhi2 (2*μ k)) hH
  have hcap' : |Y (2*μ k)| ≤ H*periodicFourierMaximum (S.A k) := by
    simpa only [Y,abs_mul,abs_of_nonneg hH] using hcap
  have hxc : |X (2*μ k)| ≤ H*periodicFourierMaximum (S.A k)+ε/10 := by
    have ht := abs_add_le (X (2*μ k)-Y (2*μ k)) (Y (2*μ k))
    rw [sub_add_cancel] at ht
    linarith
  have hsigcap : σ k*X (2*μ k) ≤ H*periodicFourierMaximum (S.A k)+ε/10 := by
    have hh' := mul_le_of_le_one_left (abs_nonneg (X (2*μ k))) (hσ k)
    have hself := le_abs_self (σ k*X (2*μ k))
    rw [abs_mul] at hself
    linarith
  have htmove := S.externalResponse_lipschitz k (p k) (β k) (ν k) (hp k) (hsum k) (hν k) (2*h k) 0
  simp only [sub_zero] at htmove
  have hymove : |Y (2*h k)-Y 0| ≤ H*M*|2*h k| := by
    have ht := mul_le_mul_of_nonneg_left htmove hH
    simpa only [Y,← mul_sub,abs_mul,abs_of_nonneg hH,mul_assoc] using ht
  have hxmove : |X 0-X (2*h k)| ≤ 2*(ε/10)+H*M*|2*h k| := by
    have ht1 := abs_sub_le (X 0) (Y 0) (X (2*h k))
    have ht2 := abs_sub_le (Y 0) (Y (2*h k)) (X (2*h k))
    rw [abs_sub_comm (Y 0) (Y (2*h k)),abs_sub_comm (Y (2*h k)) (X (2*h k))] at ht2
    linarith
  have hsigmove : σ k*(X 0-X (2*h k)) ≤ 2*(ε/10)+H*M*|2*h k| := by
    have ht := mul_le_of_le_one_left (abs_nonneg (X 0-X (2*h k))) (hσ k)
    have hs := le_abs_self (σ k*(X 0-X (2*h k)))
    rw [abs_mul] at hs
    linarith
  change H*periodicFourierMaximum (S.A k)-ε ≤ (-σ k)*S.normalization k*R 0
  change H*periodicFourierMaximum (S.A k)-ε/10 ≤ σ k*S.normalization k*((R (2*μ k)-R (2*h k))/2) at hn
  dsimp [X] at hsigcap hsigmove
  nlinarith

/-- Direct analytic route from the actual pair-difference near optimum to
restoring curvature, retaining the individual outside Walsh signs. -/
theorem pair_difference_eventual_restoring (P : ℕ → ℕ) (p β ν : (k : ℕ) → Fin (P k) → ℝ)
    (hν : ∀ k i, |ν k i| ≤ 1) (σ μ h : ℕ → ℝ) (hσ : ∀ k, |σ k| ≤ 1)
    (hp : ∀ k i, 0 ≤ p k i) (hsum : ∀ k, ∑ i,p k i=1)
    (hmoment : Tendsto (fun k => (residualScale (S.A k) (S.alphabet k))^2*
      (∑ i,p k i*(β k i)^2)) atTop (𝓝 0)) (hhi2 : S.hi ≤ 2)
    (hh : Tendsto h atTop (𝓝 0)) {D : ℝ} (hD : 0 < D)
    (hμ : ∀ᶠ k in atTop, |2*μ k| ≤ D)
    (hnear : ∀ ε > 0, ∀ᶠ k in atTop,
      Real.sqrt (2/Real.pi)*periodicFourierMaximum (S.A k)-ε ≤
        σ k*S.normalization k*
          ((S.externalCorrelation k (p k) (β k) (ν k) (2*μ k)-
            S.externalCorrelation k (p k) (β k) (ν k) (2*h k))/2)) :
    ∃ δ c : ℝ, 0 < δ ∧ 0 < c ∧ ∀ᶠ k in atTop, ∀ b : ℝ, |b| ≤ δ →
      (-σ k)*S.normalization k*(∑ i,p k i*(ν k i*parityBiasSecond (S.incoming k) (β k i+b))) ≤ -c := by
  apply S.eventual_signed_restoring_window P p β ν hν (fun k => -σ k)
    (fun k => by simpa only [abs_neg] using hσ k) hp hsum hmoment hhi2
  have ht := S.pair_difference_forces_rest_peak P p β ν hν σ μ h hσ hp hsum hmoment hhi2 hh hD hμ hnear
  simpa only [externalCorrelation,add_zero] using ht

end ResidualSequence
end NeuralGeneralization.OnlineLowerTanh
