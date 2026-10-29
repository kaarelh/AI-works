import ScalarChannelEmpirical
import Mathlib.Analysis.SpecialFunctions.Exp

/-! Quantitative error propagation for the actual empirical channel update. -/
noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic

def channelEntropyPrefix (D : ℕ→ℝ) (n : ℕ) : ℝ :=
  ∑j : Fin n,Real.sqrt (2*D j)

lemma channelEntropyPrefix_nonneg (D : ℕ→ℝ) (n : ℕ) : 0≤channelEntropyPrefix D n :=
  Finset.sum_nonneg fun j _=>Real.sqrt_nonneg _

lemma channelEntropyPrefix_succ (D : ℕ→ℝ) (n : ℕ) :
    channelEntropyPrefix D (n+1)=channelEntropyPrefix D n+Real.sqrt (2*D n) := by
  unfold channelEntropyPrefix
  rw [Fin.sum_univ_castSucc]
  simp only [Fin.val_castSucc,Fin.val_last]

theorem channel_error_recurrence (D e : ℕ→ℝ) {e₀ δ : ℝ}
    (he₀ : 0≤e₀) (hδ : 0≤δ) (hinit : e 0≤e₀)
    (hstep : ∀j,e (j+1)≤δ+Real.exp (Real.sqrt (2*D j))*e j) (n : ℕ) :
    e n≤(e₀+n*δ)*Real.exp (channelEntropyPrefix D n) := by
  induction n with
  | zero => simpa [channelEntropyPrefix] using hinit
  | succ n ih =>
      have hi := mul_le_mul_of_nonneg_left ih (Real.exp_pos (Real.sqrt (2*D n))).le
      have hexp : 1≤Real.exp (channelEntropyPrefix D (n+1)) :=
        Real.one_le_exp (channelEntropyPrefix_nonneg D _)
      have hδ' := mul_le_mul_of_nonneg_left hexp hδ
      rw [channelEntropyPrefix_succ,Real.exp_add] at hδ' ⊢
      push_cast
      nlinarith [hstep n]

def channelMomentPrecision (H : ℕ) (S v κ : ℝ) : ℝ :=
  (κ*Real.sqrt v/(64*(H+1)*Real.exp S))^2

theorem channelMomentPrecision_pos (H : ℕ) (S : ℝ) {v κ : ℝ}
    (hv : 0<v) (hκ : 0<κ) : 0<channelMomentPrecision H S v κ := by
  unfold channelMomentPrecision
  positivity

theorem channelMomentPrecision_error (H : ℕ) (S : ℝ) {v κ : ℝ}
    (hv : 0≤v) (hκ : 0≤κ) :
    ((H:ℝ)+1)*8*Real.sqrt (channelMomentPrecision H S v κ)*Real.exp S=
      κ*Real.sqrt v/8 := by
  unfold channelMomentPrecision
  rw [Real.sqrt_sq (by positivity : 0≤κ*Real.sqrt v/(64*((H:ℝ)+1)*Real.exp S))]
  have hH : (H:ℝ)+1≠0 := by positivity
  have hS : Real.exp S≠0 := (Real.exp_pos S).ne'
  field_simp
  ring

theorem canonicalCompletion_first_error (c c' q q' : ℝ) :
    |c-c'|≤‖canonicalCompletion c q-canonicalCompletion c' q'‖ := by
  have h := WithLp.norm_fst_le ℝ (canonicalCompletion c q-canonicalCompletion c' q')
  exact h

/-- Terminal metric accuracy implies the exact signed correlation hypothesis
used by the finite Gaussian readout. -/
theorem canonicalCompletion_signed_correlation {c q v r κ f : ℝ}
    (hf : f=1 ∨ f= -1)
    (herr : ‖canonicalCompletion c q-canonicalCompletion (f*Real.sqrt v) (v+r)‖≤
      κ*Real.sqrt v/8) :
    Real.sqrt v*(1-κ/8)≤f*c := by
  have h := (canonicalCompletion_first_error c (f*Real.sqrt v) q (v+r)).trans herr
  have ha := abs_le.mp h
  rcases hf with hf | hf <;> subst f <;> norm_num at ha ⊢ <;> nlinarith

#print axioms channel_error_recurrence
#print axioms channelMomentPrecision_error
#print axioms canonicalCompletion_signed_correlation
end ConditionalNonpolynomial.Analytic
