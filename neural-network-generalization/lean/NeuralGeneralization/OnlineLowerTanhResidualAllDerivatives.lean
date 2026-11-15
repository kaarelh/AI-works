import NeuralGeneralization.OnlineLowerTanhResidualMomentCLT
import Mathlib.Analysis.Calculus.IteratedDeriv.Lemmas

/-! # Literal arbitrary bias derivatives of the residual approximation -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators Topology
open MeasureTheory Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

lemma residualMomentIntegral_hasDerivAt {n:ℕ} (hn:0<n) (j:ℕ)
    (u:Fin n → ℝ) (B δ:ℝ) :
    HasDerivAt (fun b => residualMomentIntegral j u b δ)
      (residualMomentIntegral (j+1) u B (δ+Real.pi/2)) B := by
  simpa only [residualMomentIntegral,add_assoc] using
    residualRawIntegral_hasDerivAt hn u B ((n:ℝ)*Real.pi/2+δ) j

/-- The actual classical iterated bias derivative is the corresponding
weighted sine integral, at every finite positive dimension. -/
theorem iteratedDeriv_parityCorrelation_integral {n:ℕ} (hn:0<n)
    (u:Fin n → ℝ) (j:ℕ) (B:ℝ) :
    iteratedDeriv j (parityCorrelation u) B =
      residualMomentIntegral j u B ((j:ℝ)*Real.pi/2) := by
  induction j generalizing B with
  | zero =>
    simp only [iteratedDeriv_zero,Nat.cast_zero,zero_mul,zero_div]
    simpa only [residualMomentIntegral,add_zero] using residualRawKernel_parity u B
  | succ j ih =>
    rw [iteratedDeriv_succ,show iteratedDeriv j (parityCorrelation u)=
      (fun B=>residualMomentIntegral j u B ((j:ℝ)*Real.pi/2)) from funext ih]
    rw [(residualMomentIntegral_hasDerivAt hn j u B ((j:ℝ)*Real.pi/2)).deriv]
    congr 1
    push_cast
    ring

/-- All fixed derivative orders have a uniform actual-correlation
asymptotic. The Gaussian envelope is held outside the periodic derivative
here; its derivative corrections are handled separately. -/
theorem ResidualSequence.uniform_residual_all_derivatives
    {ι:Type*} [Fintype ι] [DecidableEq ι] (S:ResidualSequence ι) (j:ℕ) :
    ∀ ε > 0, ∀ᶠ k in atTop, ∀ B:ℝ,
      Real.sqrt (residualVariance (S.alphabet k))*
        |iteratedDeriv j (parityCorrelation (S.incoming k)) B-
          residualMomentLeading j (S.alphabet k) (S.d k) (S.A k) B ((j:ℝ)*Real.pi/2)| < ε := by
  intro ε hε
  filter_upwards [S.uniform_residual_moment_clt j ε hε] with k hk B
  rw [iteratedDeriv_parityCorrelation_integral (S.N_pos k)]
  exact hk B _

lemma smoothedMoment_hasDerivAt (j:ℕ) {a E:ℝ} (ha:0<a) (hE:0≤E) (b δ:ℝ) :
    HasDerivAt (fun y=>smoothedMoment j a E y δ)
      (smoothedMoment (j+1) a E b (δ+Real.pi/2)) b := by
  unfold smoothedMoment
  apply hasDerivAt_tsum
    (g:=fun l y => smoothedCoefficient a E l*(residualPeak a l)^j*
      Real.sin (residualPeak a l*y+δ))
    (g':=fun l y => smoothedCoefficient a E l*(residualPeak a l)^(j+1)*
      Real.sin (residualPeak a l*y+(δ+Real.pi/2)))
    (momentMajorant_summable (j+1) (lo:=a) ha)
    _ _ (smoothedMoment_summable j ha hE 0 δ) b
  · intro l y
    have hd := (((hasDerivAt_id y).const_mul (residualPeak a l)).add_const δ).sin.const_mul
      (smoothedCoefficient a E l*(residualPeak a l)^j)
    convert! hd using 1
    change _ = smoothedCoefficient a E l * residualPeak a l ^ j *
      (Real.cos (residualPeak a l * y + δ) * (residualPeak a l * 1))
    simp only [one_mul,mul_one,pow_succ]
    rw [show residualPeak a l*y+(δ+Real.pi/2) =
      (residualPeak a l*y+δ)+Real.pi/2 by ring,Real.sin_add_pi_div_two]
    ring
  · intro l y
    rw [Real.norm_eq_abs,abs_mul,abs_mul,abs_of_pos (smoothedCoefficient_pos ha E l),
      abs_of_nonneg (pow_nonneg (residual_peak_pos ha l).le _)]
    exact (mul_le_of_le_one_right
      (mul_nonneg (smoothedCoefficient_pos ha E l).le (pow_nonneg (residual_peak_pos ha l).le _))
      (Real.abs_sin_le_one _)).trans
        (smoothedMoment_coefficient_bound (j+1) ha le_rfl le_rfl hE l)

lemma smoothedMoment_zero (a E b : ℝ) : smoothedMoment 0 a E b 0 = smoothedResponse a E b := by
  simp only [smoothedMoment,pow_zero,mul_one,add_zero,smoothedResponse,residualPeak]

/-- The periodic factors themselves are literal iterated derivatives of
the Gaussian-smoothed periodic response. -/
theorem iteratedDeriv_smoothedResponse {a E:ℝ} (ha:0<a) (hE:0≤E) (j:ℕ) (b:ℝ) :
    iteratedDeriv j (smoothedResponse a E) b = smoothedMoment j a E b ((j:ℝ)*Real.pi/2) := by
  induction j generalizing b with
  | zero => simpa only [iteratedDeriv_zero,Nat.cast_zero,zero_mul,zero_div] using
      (smoothedMoment_zero a E b).symm
  | succ j ih =>
    rw [iteratedDeriv_succ,show iteratedDeriv j (smoothedResponse a E)=
      (fun b=>smoothedMoment j a E b ((j:ℝ)*Real.pi/2)) from funext ih]
    rw [(smoothedMoment_hasDerivAt j ha hE b ((j:ℝ)*Real.pi/2)).deriv]
    congr 1
    push_cast
    ring

lemma contDiff_smoothedResponse {a E:ℝ} (ha:0<a) (hE:0≤E) (n:ℕ) :
    ContDiff ℝ n (smoothedResponse a E) := by
  apply contDiff_of_differentiable_iteratedDeriv (n := (n:ℕ∞))
  intro j hj b
  rw [show iteratedDeriv j (smoothedResponse a E) =
    (fun b=>smoothedMoment j a E b ((j:ℝ)*Real.pi/2)) from
      funext (iteratedDeriv_smoothedResponse ha hE j)]
  exact (smoothedMoment_hasDerivAt j ha hE b _).differentiableAt

end NeuralGeneralization.OnlineLowerTanh
