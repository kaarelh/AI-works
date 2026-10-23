import NeuralGeneralization.BatchTwoCircuitConverseMass
import NeuralGeneralization.BatchTwoCircuitConverseBayesForward

/-!
# Predictive probabilities for the concrete geometric circuit posterior
-/

namespace NeuralGeneralization.BatchTwoCircuitConverse

open scoped ENNReal BigOperators
noncomputable section
open Classical

variable {d : ℕ}

def versionMass (f : Input d → Bool) (A : Finset (Input d)) : ℝ :=
  (descriptionMass (fun c => c.Fits f A)).toReal

def versionLoss (f : Input d → Bool) (A : Finset (Input d)) : ℝ :=
  -Real.log (versionMass f A)

def correctProbability (f : Input d → Bool) (A : Finset (Input d)) (x : Input d) : ℝ :=
  versionMass f (insert x A) / versionMass f A

theorem versionMass_pos (f : Input d → Bool) (A : Finset (Input d)) :
    0 < versionMass f A := by
  obtain ⟨c, hc⟩ := exists_fitting_circuit f A
  exact descriptionMass_real_pos _ c hc

theorem versionMass_le_one (f : Input d → Bool) (A : Finset (Input d)) :
    versionMass f A ≤ 1 := by
  simpa only [versionMass, ENNReal.toReal_one] using
    ENNReal.toReal_mono ENNReal.one_ne_top (descriptionMass_le_one (fun c => c.Fits f A))

theorem versionLoss_nonneg (f : Input d → Bool) (A : Finset (Input d)) :
    0 ≤ versionLoss f A := by
  have hl := Real.log_le_log (versionMass_pos f A) (versionMass_le_one f A)
  simp only [Real.log_one] at hl
  exact neg_nonneg.mpr hl

theorem versionMass_antitone (f : Input d → Bool) {A B : Finset (Input d)} (hAB : A ⊆ B) :
    versionMass f B ≤ versionMass f A := by
  apply ENNReal.toReal_mono (descriptionMass_ne_top _)
  exact descriptionMass_mono (fun c hc x hx => hc x (hAB hx))

theorem correctProbability_pos (f : Input d → Bool) (A : Finset (Input d)) (x : Input d) :
    0 < correctProbability f A x := div_pos (versionMass_pos _ _) (versionMass_pos _ _)

theorem correctProbability_le_one (f : Input d → Bool) (A : Finset (Input d)) (x : Input d) :
    correctProbability f A x ≤ 1 := by
  apply (div_le_one (versionMass_pos f A)).mpr
  exact versionMass_antitone f (Finset.subset_insert _ _)

theorem complexity_le_versionLoss (f : Input d → Bool) (A : Finset (Input d)) :
    (complexity f A : ℝ) * Real.log 2 ≤ versionLoss f A := by
  have hb := ENNReal.toReal_mono
    (ENNReal.pow_ne_top (by norm_num : (2⁻¹ : ℝ≥0∞) ≠ ⊤))
    (fitting_mass_le_complexity_tail f A)
  simp only [ENNReal.toReal_pow, ENNReal.toReal_inv, ENNReal.toReal_ofNat] at hb
  have hl := Real.log_le_log (versionMass_pos f A) hb
  rw [Real.log_pow, Real.log_inv] at hl
  unfold versionLoss
  linarith

theorem versionLoss_le_budget (f : Input d → Bool) (A : Finset (Input d)) :
    versionLoss f A ≤ gateBudget d (complexity f A) := by
  obtain ⟨c, hs, hc⟩ := exists_minimizer f A
  have hm := ENNReal.toReal_mono (descriptionMass_ne_top (fun a => a.Fits f A))
    (circuitMass_le_descriptionMass _ c hc)
  have hl := Real.log_le_log (circuitMass_toReal_pos c) hm
  have hb := neg_log_circuitMass_le_budget c
  rw [hs] at hb
  exact (neg_le_neg hl).trans hb

/-- Every history has a uniformly positive predictive label mass once K contains
at least three quarters of its unnormalized posterior mass. The tail premise is
an explicit geometric scalar inequality, not a prior or learning assumption. -/
theorem correctProbability_ge_truncated_repair (f : Input d → Bool)
    (A : Finset (Input d)) (x : Input d) (K : ℕ)
    (htail : (2 : ℝ)⁻¹^(K+1) ≤ versionMass f A / 4) :
    (3/4 : ℝ) * (repairRatio d K).toReal ≤ correctProbability f A x := by
  let P : Circuit d → Prop := fun c => c.Fits f A
  let Zs := descriptionMass (fun c => P c ∧ c.size ≤ K)
  let Zb := descriptionMass (fun c => P c ∧ K < c.size)
  have hs : versionMass f A = Zs.toReal + Zb.toReal := by
    unfold versionMass
    rw [descriptionMass_split_size _ K,
      ENNReal.toReal_add (descriptionMass_ne_top _) (descriptionMass_ne_top _)]
  have hb : Zb.toReal ≤ (2 : ℝ)⁻¹^(K+1) := by
    have h := ENNReal.toReal_mono
      (ENNReal.pow_ne_top (by norm_num : (2⁻¹ : ℝ≥0∞) ≠ ⊤))
      (descriptionMass_large_size_le P K)
    simpa only [ENNReal.toReal_pow, ENNReal.toReal_inv, ENNReal.toReal_ofNat] using h
  have hsmall : (3/4 : ℝ) * versionMass f A ≤ Zs.toReal := by linarith
  have hrep := ENNReal.toReal_mono (descriptionMass_ne_top _)
    (geometric_repair_mass d K f A x)
  rw [ENNReal.toReal_mul] at hrep
  have hm : (repairRatio d K).toReal * ((3/4 : ℝ) * versionMass f A) ≤
      versionMass f (insert x A) :=
    (mul_le_mul_of_nonneg_left hsmall ENNReal.toReal_nonneg).trans hrep
  apply (le_div_iff₀ (versionMass_pos f A)).mpr
  nlinarith

end
end NeuralGeneralization.BatchTwoCircuitConverse
