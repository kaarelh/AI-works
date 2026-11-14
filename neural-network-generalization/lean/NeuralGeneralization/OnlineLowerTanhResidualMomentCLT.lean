import NeuralGeneralization.OnlineLowerTanhResidualMomentTruncation

/-! # Uniform signed residual central limit theorem for actual tanh correlations -/
noncomputable section
open scoped BigOperators Topology
open MeasureTheory Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

lemma residualActualMomentTailBound_tendsto (j : ℕ) {Q hi : ℝ} (hhi : 0 < hi) :
    Tendsto (residualActualMomentTailBound j Q hi) atTop (𝓝 0) := by
  let r : ℝ := Real.exp (-(Real.pi/2/8)*(Real.pi/hi))
  have hr : 0 < r := Real.exp_pos _
  have hr1 : r < 1 := Real.exp_lt_one_iff.mpr (by
    have hh : 0 < (Real.pi/2/8)*(Real.pi/hi) := by positivity
    nlinarith)
  have ht := (tendsto_pow_atTop_nhds_zero_of_lt_one hr.le hr1).const_mul
    (Q*(((2/(Real.pi/2))*((j.factorial:ℝ)/((Real.pi/2)/4)^j))*(Real.pi/((Real.pi/2)/8))))
  simp only [mul_zero] at ht
  convert ht using 1
  funext L
  unfold residualActualMomentTailBound r
  rw [← Real.exp_nat_mul]
  congr 2
  ring

lemma residualMomentModelTailBound_tendsto (j : ℕ) (lo hi : ℝ) :
    Tendsto (residualMomentModelTailBound j lo hi) atTop (𝓝 0) := by
  have ht := (tendsto_sum_nat_add (momentMajorant j lo hi)).const_mul (Real.sqrt (2*Real.pi)/Real.pi)
  change Tendsto (fun L => (Real.sqrt (2*Real.pi)/Real.pi)*(∑' l : ℕ, momentMajorant j lo hi (l+L))) atTop (𝓝 0)
  simpa only [mul_zero] using ht

namespace ResidualSequence
variable {ι : Type*} [Fintype ι] [DecidableEq ι] (S : ResidualSequence ι)

lemma finite_moment_error_tendsto (j : ℕ) {ρ : ℝ} (hρ : 0 < ρ) (hρhi : ρ < Real.pi/(2*S.hi)) (L : ℕ) :
    Tendsto (fun k => (1/S.lo)*
      (∑ l ∈ Finset.range L, residualCellError (S.alphabet k) (S.d k) (S.A k) ρ l j))
      atTop (𝓝 0) := by
  have ht := tendsto_finset_sum (Finset.range L) (fun l _ => S.cell_error_tendsto hρ hρhi l j)
  simpa only [Finset.sum_const_zero,mul_zero] using ht.const_mul (1/S.lo)

/-- The asymptotic error is uniform over every real external bias, with the
actual finite-cube tanh correlation on the left. -/
theorem uniform_residual_moment_clt_of_cutoff (j : ℕ) {ρ : ℝ} (hρ : 0 < ρ)
    (hρhi : ρ < Real.pi/(2*S.hi)) (hsmall : (S.hi*S.Q+1)*ρ < 1) :
    ∀ ε > 0, ∀ᶠ k in atTop, ∀ B δ : ℝ,
      Real.sqrt (residualVariance (S.alphabet k))*
        |residualMomentIntegral j (S.incoming k) B δ-residualMomentLeading j (S.alphabet k) (S.d k) (S.A k) B δ| < ε := by
  intro ε hε
  have hM : 0 < S.hi*S.Q+1 := by positivity [S.hi_pos,S.Q_pos]
  have htail := (residualActualMomentTailBound_tendsto j (Q:=S.Q) S.hi_pos).add
    (residualMomentModelTailBound_tendsto j S.lo S.hi)
  simp only [add_zero] at htail
  have hlength : Tendsto (fun L : ℕ => (L:ℝ)*Real.pi/S.hi) atTop atTop := by
    have ht := tendsto_natCast_atTop_atTop.atTop_mul_const (div_pos Real.pi_pos S.hi_pos)
    simpa only [mul_div_assoc] using ht
  obtain ⟨L,hLt,hLρ,hL1⟩ := (htail.eventually (gt_mem_nhds (by linarith : (0:ℝ)<ε/3)) |>.and
    ((hlength.eventually (eventually_ge_atTop ρ)).and
      (hlength.eventually (eventually_ge_atTop 1)))).exists
  have hz := (S.zero_bound_tendsto (mul_pos hM hρ) hsmall).const_mul (ρ^j)
  simp only [mul_zero] at hz
  have hf := S.finite_moment_error_tendsto j hρ hρhi L
  have he := hz.add hf
  simp only [add_zero] at he
  filter_upwards [S.incoming_eventually_bounded,
    he.eventually (gt_mem_nhds (by linarith : (0:ℝ)<ε/3))] with k hbound herr B δ
  have hH : ρ ≤ (L:ℝ)*(Real.pi/S.A k) := by
    apply hLρ.trans
    simpa only [mul_div_assoc] using div_le_div_of_nonneg_left
      (mul_nonneg (Nat.cast_nonneg L) Real.pi_pos.le) (S.gain_pos k) (S.A_hi k)
  have hh := S.moment_approximation_bound j k L hρ hM.le hbound hH hL1 B δ
  linarith

/-- For every fixed finite positive-frequency odd alphabet of gcd one,
orthogonal residuals with vanishing maximum coordinate and bounded energy
obey the signed Gaussian-times-periodic asymptotic, uniformly in bias. -/
theorem uniform_residual_moment_clt (j : ℕ) :
    ∀ ε > 0, ∀ᶠ k in atTop, ∀ B δ : ℝ,
      Real.sqrt (residualVariance (S.alphabet k))*
        |residualMomentIntegral j (S.incoming k) B δ-residualMomentLeading j (S.alphabet k) (S.d k) (S.A k) B δ| < ε := by
  let M : ℝ := S.hi*S.Q+1
  have hM : 0 < M := by dsimp [M]; positivity [S.hi_pos,S.Q_pos]
  let ρ : ℝ := min (Real.pi/(4*S.hi)) (1/(2*M))
  have hρ : 0 < ρ := by dsimp [ρ]; positivity [S.hi_pos]
  have hρhi : ρ < Real.pi/(2*S.hi) := by
    apply (min_le_left _ _).trans_lt
    apply div_lt_div_of_pos_left Real.pi_pos (by positivity [S.hi_pos])
    nlinarith [S.hi_pos]
  have hsmall : M*ρ < 1 := by
    have hh := mul_le_mul_of_nonneg_left (min_le_right (Real.pi/(4*S.hi)) (1/(2*M))) hM.le
    have he : M*(1/(2*M)) = 1/2 := by field_simp
    rw [he] at hh
    exact lt_of_le_of_lt hh (by norm_num)
  exact S.uniform_residual_moment_clt_of_cutoff j hρ hρhi hsmall

end ResidualSequence
end NeuralGeneralization.OnlineLowerTanh
