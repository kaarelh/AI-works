import NeuralGeneralization.BatchTwoOnlinePosterior
import NeuralGeneralization.FiniteProcessMax

/-!
# Relevant-class expected online risk

The abstract lemma below takes the survival probabilities of each individual
hypothesis, and derives a bound on the actual consistency posterior. It does
not assume a posterior-risk or a cumulative-mistake bound. The exponential
envelope avoids any layer-cake integration and allows arbitrary prior weights.
-/

noncomputable section
open scoped BigOperators
open Classical

namespace NeuralGeneralization.BatchTwoOnline

variable {H Ω : Type*} [Fintype H] [Fintype Ω]

def survivorEnvelope (A : Finset H) (keep : Ω → H → Prop)
    (err : H → ℝ) (h t : ℝ) (ω : Ω) : ℝ :=
  (h + ∑ g ∈ A, if keep ω g then Real.exp (t * err g - h) else 0) / t

lemma survivorEnvelope_nonneg (A : Finset H) (keep : Ω → H → Prop)
    (err : H → ℝ) (h t : ℝ) (hh : 0 ≤ h) (ht : 0 < t) (ω : Ω) :
    0 ≤ survivorEnvelope A keep err h t ω := by
  apply div_nonneg _ ht.le
  apply add_nonneg hh
  apply Finset.sum_nonneg
  intro g _
  split_ifs
  · exact (Real.exp_pos _).le
  · exact le_rfl

lemma error_le_survivorEnvelope (A : Finset H) (keep : Ω → H → Prop)
    (err : H → ℝ) (h t : ℝ) (ht : 0 < t) (ω : Ω)
    (g : H) (hg : g ∈ A) (hkeep : keep ω g) :
    err g ≤ survivorEnvelope A keep err h t ω := by
  apply (le_div_iff₀ ht).mpr
  have hexp := Real.add_one_le_exp (t * err g - h)
  have hterm : Real.exp (t * err g - h) ≤
      ∑ g ∈ A, if keep ω g then Real.exp (t * err g - h) else 0 := by
    calc
      _ = (if keep ω g then Real.exp (t * err g - h) else 0) := by rw [if_pos hkeep]
      _ ≤ _ := Finset.single_le_sum
        (f := fun j => if keep ω j then Real.exp (t * err j - h) else 0) (fun j _ => by
        split_ifs
        · exact (Real.exp_pos _).le
        · exact le_rfl) hg
  nlinarith

/-- Individual exponential survival bounds imply the logarithmic expected
survivor envelope. The sampling law is a literal finite probability vector. -/
theorem expected_survivorEnvelope_le
    (p : Ω → ℝ) (hp : ∀ ω, 0 ≤ p ω) (hpsum : ∑ ω, p ω = 1)
    (A : Finset H) (keep : Ω → H → Prop) (err : H → ℝ)
    (h t : ℝ) (ht : 0 < t) (hcard : (A.card : ℝ) ≤ Real.exp h)
    (hsurvive : ∀ g ∈ A,
      (∑ ω, if keep ω g then p ω else 0) ≤ Real.exp (-t * err g)) :
    (∑ ω, p ω * survivorEnvelope A keep err h t ω) ≤ (h+1)/t := by
  have hsingle (g : H) (hg : g ∈ A) :
      (∑ ω, p ω * (if keep ω g then Real.exp (t * err g - h) else 0)) ≤
        Real.exp (-h) := by
    have heq : (∑ ω, p ω * (if keep ω g then Real.exp (t * err g - h) else 0)) =
        Real.exp (t * err g - h) * (∑ ω, if keep ω g then p ω else 0) := by
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro ω _
      split_ifs <;> simp [mul_comm]
    rw [heq]
    calc
      _ ≤ Real.exp (t * err g - h) * Real.exp (-t * err g) :=
        mul_le_mul_of_nonneg_left (hsurvive g hg) (Real.exp_pos _).le
      _ = Real.exp (-h) := by rw [← Real.exp_add]; congr 1; ring
  have hsum : (∑ g ∈ A, ∑ ω,
      p ω * (if keep ω g then Real.exp (t * err g - h) else 0)) ≤ 1 := by
    calc
      _ ≤ ∑ _g ∈ A, Real.exp (-h) := Finset.sum_le_sum hsingle
      _ = (A.card : ℝ) * Real.exp (-h) := by simp
      _ ≤ Real.exp h * Real.exp (-h) :=
        mul_le_mul_of_nonneg_right hcard (Real.exp_pos _).le
      _ = 1 := by rw [← Real.exp_add, add_neg_cancel, Real.exp_zero]
  unfold survivorEnvelope
  simp_rw [← mul_div_assoc, mul_add, Finset.mul_sum]
  rw [← Finset.sum_div, Finset.sum_add_distrib, ← Finset.sum_mul, hpsum, one_mul,
    Finset.sum_comm]
  exact div_le_div_of_nonneg_right (by linarith) ht.le

variable [DecidableEq H]

/-- Expected one-step risk of the actual posterior. The loss after a history
may be the mean over the remaining inputs. Its transfer factor to full-domain
error is supplied separately; no conditional-risk conclusion is assumed. -/
theorem expected_posterior_risk_le_of_survival
    (p : Ω → ℝ) (hp : ∀ ω, 0 ≤ p ω) (hpsum : ∑ ω, p ω = 1)
    (w : H → ℝ) (hw : ∀ g, 0 ≤ w g) (keep : Ω → H → Prop)
    (target : H) (htarget : ∀ ω, keep ω target) (hwt : 0 < w target)
    (err : H → ℝ) (loss : Ω → H → ℝ)
    (hloss : ∀ ω g, 0 ≤ loss ω g ∧ loss ω g ≤ 1)
    (A : Finset H) (h t c β : ℝ) (hh : 0 ≤ h) (ht : 0 < t) (hc : 0 ≤ c)
    (hcard : (A.card : ℝ) ≤ Real.exp h)
    (hsurvive : ∀ g ∈ A,
      (∑ ω, if keep ω g then p ω else 0) ≤ Real.exp (-t * err g))
    (htransfer : ∀ ω g, keep ω g → loss ω g ≤ c * err g)
    (htail : (∑ g ∈ Finset.univ \ A, w g) / w target ≤ β) :
    (∑ ω, p ω * ∑ g, posterior w (keep ω) g * loss ω g) ≤ c * ((h+1)/t) + β := by
  have hpoint (ω : Ω) : (∑ g, posterior w (keep ω) g * loss ω g) ≤
      c * survivorEnvelope A keep err h t ω + β := by
    apply posterior_risk_le w (keep ω) hw target (htarget ω) hwt
      (loss ω) (hloss ω) A (c * survivorEnvelope A keep err h t ω) β
      (mul_nonneg hc (survivorEnvelope_nonneg A keep err h t hh ht ω)) _ htail
    intro g hg hk
    exact (htransfer ω g hk).trans
      (mul_le_mul_of_nonneg_left (error_le_survivorEnvelope A keep err h t ht ω g hg hk) hc)
  calc
    _ ≤ ∑ ω, p ω * (c * survivorEnvelope A keep err h t ω + β) :=
      Finset.sum_le_sum fun ω _ => mul_le_mul_of_nonneg_left (hpoint ω) (hp ω)
    _ = c * (∑ ω, p ω * survivorEnvelope A keep err h t ω) + β := by
      simp_rw [mul_add]
      rw [Finset.sum_add_distrib, ← Finset.sum_mul, hpsum, one_mul, Finset.mul_sum]
      congr 1
      apply Finset.sum_congr rfl
      intro ω _
      ring
    _ ≤ c * ((h+1)/t) + β := by
      exact add_le_add (mul_le_mul_of_nonneg_left
        (expected_survivorEnvelope_le p hp hpsum A keep err h t ht hcard hsurvive) hc) le_rfl

end NeuralGeneralization.BatchTwoOnline
