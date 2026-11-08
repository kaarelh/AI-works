import NeuralGeneralization.OnlineLowerTanhOptimizerEfficiency
import NeuralGeneralization.OnlineLowerTanhEmpiricalCompact

/-! The actual limiting scalar maximum forces an empirical lattice law to
be a point mass and forbids escaped second moment. Finite-prefix bounds
are explicit inputs, supplied by actual conditioning and residual CLT. -/
noncomputable section
open scoped Topology BigOperators
open Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

/-- Classification from the two finite-prefix efficiency inequalities. The
universal monotone cap first puts the effective gain below two; the sharp
periodic cap then forces every inequality to be an equality. -/
theorem empirical_efficiency_classification
    (p : ℕ → ℝ) (hp : ∀j,0≤p j) (hsum : HasSum p 1)
    (hmoment : Summable (fun j => p j*(j:ℝ)^2))
    (g : ℕ) (hg : 0<g)
    (hpositive : ∀j,0<p j→0<j) (hdiv : ∀j,0<p j→g∣j)
    (Q a : ℝ) (ha : 0<a) (hQ : (∑' j,p j*(j:ℝ)^2)≤Q)
    (hmono : ∀ᶠ J in atTop,limitingParityEfficiency ≤
      Real.sqrt (2/Real.pi)/Real.sqrt ((∑j∈Finset.range J,p j)*(a^2*Q)))
    (hsharp : a*g<2 → ∀ᶠ J in atTop,limitingParityEfficiency ≤
      Real.sqrt (2/Real.pi)*(scalarF0 (a*g)/(a*g))*(g:ℝ)^2/
        Real.sqrt ((∑j∈Finset.range J,p j*(j:ℝ)^2)*Q)) :
    a*g<2 ∧ Q=(g:ℝ)^2 ∧ (∑'j,p j*(j:ℝ)^2)=(g:ℝ)^2 ∧
      a*g=limitingGain ∧ p=(fun j=>if j=g then 1 else 0) := by
  let M := ∑'j,p j*(j:ℝ)^2
  change M≤Q at hQ
  have hgR : (0:ℝ)<g := by exact_mod_cast hg
  have hg2 : (0:ℝ)<(g:ℝ)^2 := sq_pos_of_pos hgR
  have hM : (g:ℝ)^2≤M := support_gcd_moment_lower p g hp hsum hmoment hpositive hdiv
  have hMp : 0<M := hg2.trans_le hM
  have hQp : 0<Q := hMp.trans_le hQ
  have hrootQ : (g:ℝ)≤Real.sqrt Q := by
    have hs:=Real.sq_sqrt hQp.le
    nlinarith [Real.sqrt_nonneg Q]
  have hmonoLimit : limitingParityEfficiency≤Real.sqrt (2/Real.pi)/Real.sqrt (a^2*Q) := by
    apply ge_of_tendsto (tendsto_const_nhds.div
      (Real.continuous_sqrt.continuousAt.tendsto.comp
        (by simpa only [one_mul] using hsum.tendsto_sum_nat.mul_const (a^2*Q)))
      (by positivity)) hmono
  have hag : a*g<2 := by
    by_contra hh
    have hag2 : 2≤a*g := le_of_not_gt hh
    have hden : 2≤Real.sqrt (a^2*Q) := by
      rw [Real.sqrt_mul (sq_nonneg a),Real.sqrt_sq ha.le]
      nlinarith
    have hup := div_le_div_of_nonneg_left (Real.sqrt_nonneg (2/Real.pi))
      (by norm_num : (0:ℝ)<2) hden
    exact (not_le_of_gt limitingParityEfficiency_gt_half) (hmonoLimit.trans hup)
  have hsharpLimit : limitingParityEfficiency≤
      Real.sqrt (2/Real.pi)*(scalarF0 (a*g)/(a*g))*(g:ℝ)^2/Real.sqrt (M*Q) := by
    apply ge_of_tendsto (tendsto_const_nhds.div
      (Real.continuous_sqrt.continuousAt.tendsto.comp
        (hmoment.hasSum.tendsto_sum_nat.mul_const Q))
      (by positivity)) (hsharp hag)
  have hscalar : Real.sqrt (2/Real.pi)*(scalarF0 (a*g)/(a*g))≤limitingParityEfficiency := by
    have hm := mul_le_mul_of_nonneg_left (scalarRatio_global_max (a*g) (mul_pos ha hgR))
      (Real.sqrt_nonneg (2/Real.pi))
    simpa only [limitingParityEfficiency,mul_div_assoc] using hm
  have hroot : 0<Real.sqrt (M*Q) := Real.sqrt_pos.mpr (mul_pos hMp hQp)
  have hcompare : limitingParityEfficiency≤limitingParityEfficiency*(g:ℝ)^2/Real.sqrt (M*Q) :=
    hsharpLimit.trans (div_le_div_of_nonneg_right
      (mul_le_mul_of_nonneg_right hscalar (sq_nonneg (g:ℝ))) hroot.le)
  have hrootUpper : Real.sqrt (M*Q)≤(g:ℝ)^2 := by
    have hh := (le_div_iff₀ hroot).mp hcompare
    nlinarith [limitingParityEfficiency_pos]
  have hrootSq := Real.sq_sqrt (mul_nonneg hMp.le hQp.le)
  have hprodUpper : M*Q≤((g:ℝ)^2)^2 := by nlinarith [sq_nonneg (Real.sqrt (M*Q)-(g:ℝ)^2)]
  have hMeq : M=(g:ℝ)^2 := by
    have hh := mul_nonneg hMp.le (sub_nonneg.mpr hQ)
    nlinarith [sq_nonneg (M-(g:ℝ)^2)]
  have hQeq : Q=(g:ℝ)^2 := by
    rw [hMeq] at hprodUpper hQ
    nlinarith
  have hrootEq : Real.sqrt (M*Q)=(g:ℝ)^2 := by
    rw [hMeq,hQeq,←pow_two,Real.sqrt_sq (sq_nonneg (g:ℝ))]
  have hscalarLower : limitingParityEfficiency≤Real.sqrt (2/Real.pi)*(scalarF0 (a*g)/(a*g)) := by
    rw [hrootEq] at hsharpLimit
    have he : Real.sqrt (2/Real.pi)*(scalarF0 (a*g)/(a*g))*(g:ℝ)^2/(g:ℝ)^2 =
      Real.sqrt (2/Real.pi)*(scalarF0 (a*g)/(a*g)) := by field_simp
    rwa [he] at hsharpLimit
  have hgain : a*g=limitingGain := by
    by_contra hne
    have hh := mul_lt_mul_of_pos_left (scalarRatio_global_strict_max (a*g) (mul_pos ha hgR) hne)
      (show (0:ℝ)<Real.sqrt (2/Real.pi) by positivity [Real.pi_pos])
    have he : Real.sqrt (2/Real.pi)*(scalarF0 limitingGain/limitingGain)=limitingParityEfficiency := by
      unfold limitingParityEfficiency
      ring
    rw [he] at hh
    linarith
  exact ⟨hag,hQeq,hMeq,hgain,support_gcd_moment_equality p g hp hsum hmoment hpositive hdiv hMeq⟩

end NeuralGeneralization.OnlineLowerTanh
