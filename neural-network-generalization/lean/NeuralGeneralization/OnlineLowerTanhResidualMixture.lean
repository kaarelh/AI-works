import NeuralGeneralization.OnlineLowerTanhMixtureBounds

/-! # Averaging actual residual correlations over outside signs -/
noncomputable section
open scoped BigOperators Topology
open MeasureTheory Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

lemma residualPhaseSign_sq {n : ℕ} (q : Fin n → ℕ) : residualPhaseSign q*residualPhaseSign q=1 := by
  have h := congrArg (fun x : ℝ => x^2) (residualPhaseSign_abs q)
  rw [sq_abs] at h
  nlinarith

lemma signed_scaled_error (σ R x y z : ℝ) (hσ : |σ|=1) (hR : 0 ≤ R)
    (hz : σ*R*y=z) : |σ*R*x-z|=R*|x-y| := by
  rw [← hz,← mul_sub,abs_mul,abs_mul,hσ,abs_of_nonneg hR,one_mul]

lemma residual_signed_height {n : ℕ} (hn : 0 < n) (q : Fin n → ℕ)
    (hq : ∀ i, 0 < q i) {A : ℝ} (hA : 0 < A) (B v : ℝ) :
    residualPhaseSign q*Real.sqrt (residualVariance q)*
      (residualPhaseSign q*Real.sqrt (2/(Real.pi*residualVariance q))*
        Real.exp (-B^2/(2*A^2*residualVariance q))*v) =
      Real.sqrt (2/Real.pi)*Real.exp (-(B*residualScale A q)^2/2)*v := by
  rw [← residual_gaussian_exponent hn q hq hA]
  have he := residual_sqrt_normalization hn q hq
  rw [gaussian_height_identity] at he
  have hσ := residualPhaseSign_sq q
  calc
    _ = (residualPhaseSign q*residualPhaseSign q)*
        (Real.sqrt (residualVariance q)*Real.sqrt (2/(Real.pi*residualVariance q)))*
          Real.exp (-(B*residualScale A q)^2/2)*v := by ring
    _ = _ := by rw [hσ,one_mul,he]

namespace ResidualSequence
variable {ι : Type*} [Fintype ι] [DecidableEq ι] (S : ResidualSequence ι)

def phaseResponse (k : ℕ) (B : ℝ) : ℝ :=
  smoothedResponse (S.A k) (∑ i,(S.d k i)^2) (B+(S.N k%2:ℕ)*S.A k)
def phaseSecondMoment (k : ℕ) (B : ℝ) : ℝ :=
  smoothedSecondMoment (S.A k) (∑ i,(S.d k i)^2) (B+(S.N k%2:ℕ)*S.A k)
def normalization (k : ℕ) : ℝ :=
  residualPhaseSign (S.alphabet k)*Real.sqrt (residualVariance (S.alphabet k))

theorem uniform_normalized_clt :
    ∀ ε > 0, ∀ᶠ k in atTop, ∀ B : ℝ,
      |S.normalization k*parityCorrelation (S.incoming k) B-
        Real.sqrt (2/Real.pi)*Real.exp (-(B*residualScale (S.A k) (S.alphabet k))^2/2)*S.phaseResponse k B| < ε := by
  intro ε hε
  filter_upwards [S.uniform_residual_clt ε hε] with k hk B
  have he := residual_signed_height (S.N_pos k) (S.alphabet k) (S.alphabet_pos k) (S.gain_pos k)
    B (S.phaseResponse k B)
  have h := signed_scaled_error (residualPhaseSign (S.alphabet k))
    (Real.sqrt (residualVariance (S.alphabet k))) (parityCorrelation (S.incoming k) B)
    (residualLeading (S.alphabet k) (S.d k) (S.A k) B) _
    (residualPhaseSign_abs _) (Real.sqrt_nonneg _) he
  change |S.normalization k*parityCorrelation (S.incoming k) B-_|=_ at h
  rw [h]
  exact hk B

theorem uniform_normalized_second_clt :
    ∀ ε > 0, ∀ᶠ k in atTop, ∀ B : ℝ,
      |S.normalization k*(-parityBiasSecond (S.incoming k) B)-
        Real.sqrt (2/Real.pi)*Real.exp (-(B*residualScale (S.A k) (S.alphabet k))^2/2)*S.phaseSecondMoment k B| < ε := by
  intro ε hε
  filter_upwards [S.uniform_residual_bias_second ε hε] with k hk B
  have he := residual_signed_height (S.N_pos k) (S.alphabet k) (S.alphabet_pos k) (S.gain_pos k)
    B (S.phaseSecondMoment k B)
  have h := signed_scaled_error (residualPhaseSign (S.alphabet k))
    (Real.sqrt (residualVariance (S.alphabet k))) (-parityBiasSecond (S.incoming k) B)
    (residualSecondLeading (S.alphabet k) (S.d k) (S.A k) B) _
    (residualPhaseSign_abs _) (Real.sqrt_nonneg _) he
  change |S.normalization k*(-parityBiasSecond (S.incoming k) B)-_|=_ at h
  rw [h]
  have heq : -parityBiasSecond (S.incoming k) B-residualSecondLeading (S.alphabet k) (S.d k) (S.A k) B =
      -(parityBiasSecond (S.incoming k) B+residualSecondLeading (S.alphabet k) (S.d k) (S.A k) B) := by ring
  rw [heq,abs_neg]
  exact hk B

lemma scale_tendsto :
    Tendsto (fun k => residualScale (S.A k) (S.alphabet k)) atTop (𝓝 0) :=
  residualScale_tendsto S.N S.alphabet S.N_tendsto S.alphabet_pos S.A S.A_tendsto
    (S.lo_pos.trans_le S.A₀_lo).ne'

/-- An outside-sign second moment negligible compared with the bulk
variance makes the Gaussian envelope uniformly negligible on bounded bias windows. -/
lemma envelope_loss_tendsto (P : ℕ → ℕ) (p β : (k : ℕ) → Fin (P k) → ℝ)
    (hmoment : Tendsto (fun k => (residualScale (S.A k) (S.alphabet k))^2*
      (∑ i,p k i*(β k i)^2)) atTop (𝓝 0)) (D : ℝ) :
    Tendsto (fun k => (residualScale (S.A k) (S.alphabet k))^2*
      ((∑ i,p k i*(β k i)^2)+D^2)) atTop (𝓝 0) := by
  have ht := hmoment.add ((S.scale_tendsto.pow 2).mul_const (D^2))
  simp only [zero_pow (by decide : 2≠0),zero_mul,add_zero] at ht
  convert ht using 1
  funext k
  ring

end ResidualSequence
end NeuralGeneralization.OnlineLowerTanh
