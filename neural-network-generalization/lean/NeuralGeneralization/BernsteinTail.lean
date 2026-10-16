import NeuralGeneralization.BetaTruncation

/-! Elementary monotonicity of a binomial monomial above its mode. -/
noncomputable section
namespace NeuralGeneralization
open MeasureTheory Set

lemma binomial_monomial_hasDerivAt {D j : ℕ} (hj : 1 ≤ j) (hjD : j < D) (p : ℝ) :
    HasDerivAt (fun x : ℝ => x^j*(1-x)^(D-j))
      (((j : ℝ)-(D : ℝ)*p)*p^(j-1)*(1-p)^(D-j-1)) p := by
  have h := ((hasDerivAt_id p).pow j).mul
    (((hasDerivAt_const p (1 : ℝ)).sub (hasDerivAt_id p)).pow (D-j))
  convert h using 1 <;> try rfl
  dsimp only [id_eq,Pi.pow_apply,Pi.sub_apply]
  have hpowj : p^j=p^(j-1)*p := by rw [← pow_succ]; congr 1; omega
  have hpowD : (1-p)^(D-j)=(1-p)^(D-j-1)*(1-p) := by
    rw [← pow_succ]; congr 1; omega
  rw [hpowj,hpowD,Nat.cast_sub hjD.le]
  ring

/-- Above its mode, the individual binomial monomial decreases. -/
theorem binomial_monomial_antitone {D j : ℕ} (hj : 1 ≤ j) (hjD : j < D)
    {a : ℝ} (ha : 0 ≤ a) (hmode : (j : ℝ) ≤ D*a) :
    AntitoneOn (fun p : ℝ => p^j*(1-p)^(D-j)) (Icc a 1) := by
  apply antitoneOn_of_hasDerivWithinAt_nonpos (convex_Icc a 1) (by fun_prop)
    (fun p _ => (binomial_monomial_hasDerivAt hj hjD p).hasDerivWithinAt)
  intro p hp
  rw [interior_Icc] at hp
  have hp0 : 0 ≤ p := ha.trans hp.1.le
  have hq0 : 0 ≤ 1-p := by linarith [hp.2]
  have hd0 : (0 : ℝ) ≤ D := by positivity
  have hx : (j : ℝ)-(D : ℝ)*p ≤ 0 := by
    nlinarith [mul_le_mul_of_nonneg_left hp.1.le hd0]
  exact mul_nonpos_of_nonpos_of_nonneg
    (mul_nonpos_of_nonpos_of_nonneg hx (pow_nonneg hp0 _)) (pow_nonneg hq0 _)

/-- A short interval above the mode controls the binomial monomial at its
right endpoint by the complete beta mass. -/
theorem binomial_monomial_le_beta {D j : ℕ} (hj : 1 ≤ j) (hjD : j < D)
    {β a b : ℝ} (hβ0 : 0 < β) (hβ1 : β < 1)
    (ha : 0 < a) (hab : a < b) (hb : b < 1) (hmode : (j : ℝ) ≤ D*a) :
    (b-a)*(b^j*(1-b)^(D-j)) ≤
      ∫ p : ℝ in Ioo 0 1,p^((j : ℝ)-β-1)*(1-p)^(D-j) := by
  let g : ℝ → ℝ := fun p => p^((j : ℝ)-β-1)*(1-p)^(D-j)
  have hjR : (1 : ℝ) ≤ j := by exact_mod_cast hj
  have hg : IntegrableOn g (Ioo 0 1) := by
    simpa only [add_sub_cancel_right,Real.rpow_natCast] using
      real_beta_integrable (by linarith : 0 < (j : ℝ)-β)
        (by positivity : 0 < ((D-j : ℕ) : ℝ)+1)
  have hsub : Ioo a b ⊆ Ioo (0 : ℝ) 1 := by
    intro p hp
    exact ⟨ha.trans hp.1,hp.2.trans hb⟩
  have hmono := binomial_monomial_antitone hj hjD ha.le hmode
  have hpoint (p : ℝ) (hp : p ∈ Ioo a b) : b^j*(1-b)^(D-j) ≤ g p := by
    have hp0 : 0 < p := ha.trans hp.1
    have hp1 : p < 1 := hp.2.trans hb
    have h := hmono ⟨hp.1.le,hp1.le⟩ ⟨hab.le,hb.le⟩ hp.2.le
    have hpj : p^j ≤ p^((j : ℝ)-β-1) := by
      rw [← Real.rpow_natCast p j]
      exact Real.rpow_le_rpow_of_exponent_ge hp0 hp1.le (by linarith)
    exact h.trans (mul_le_mul_of_nonneg_right hpj (pow_nonneg (by linarith) _))
  have hsmall : (b-a)*(b^j*(1-b)^(D-j)) ≤ ∫ p in Ioo a b,g p := by
    have h := setIntegral_mono_on (integrableOn_const (by simp)) (hg.mono_set hsub)
      measurableSet_Ioo hpoint
    simpa only [integral_const,smul_eq_mul,Measure.real,Measure.restrict_apply_univ,Real.volume_Ioo,ENNReal.toReal_ofReal
      (sub_nonneg.mpr hab.le)] using h
  apply hsmall.trans
  apply setIntegral_mono_set hg _ (Filter.Eventually.of_forall hsub)
  filter_upwards [ae_restrict_mem measurableSet_Ioo] with p hp
  dsimp [g]
  exact mul_nonneg (Real.rpow_nonneg hp.1.le _) (pow_nonneg (by linarith [hp.2]) _)

end NeuralGeneralization
