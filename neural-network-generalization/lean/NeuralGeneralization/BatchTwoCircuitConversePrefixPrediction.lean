import NeuralGeneralization.BatchTwoCircuitConversePrefixPrior
import NeuralGeneralization.BatchTwoCircuitConverseLower

/-!
# The prefix prior's constant predictive floor and code-complexity cost
-/

namespace NeuralGeneralization.BatchTwoCircuitConverse.Prefix

open scoped ENNReal BigOperators
noncomputable section
open Classical

variable {d : ℕ}

theorem eventMass_mono {P Q : Program d → Prop} (h : ∀ p, P p → Q p) :
    eventMass P ≤ eventMass Q := by
  rw [eventMass_eq_tsum, eventMass_eq_tsum]
  apply ENNReal.tsum_le_tsum
  intro p
  by_cases hp : P p
  · simp only [hp, h p hp, ↓reduceIte]; exact le_rfl
  · simp only [hp, ↓reduceIte]; exact zero_le

theorem Program.fits_exception (p : Program d) (f : Input d → Bool)
    (A : Finset (Input d)) (hp : p.Fits f A) (x : Input d) :
    (Program.exception x (f x) p).Fits f (insert x A) := by
  unfold Program.Fits
  rw [Program.compile_exception]
  exact p.compile.fits_overwrite f A hp x

theorem prefix_repair_mass (f : Input d → Bool) (A : Finset (Input d)) (x : Input d) :
    exceptionRatio d * eventMass (fun p => p.Fits f A) ≤
      eventMass (fun p => p.Fits f (insert x A)) := by
  rw [eventMass_eq_tsum, eventMass_eq_tsum, ← ENNReal.tsum_mul_left]
  calc
    (∑' p : Program d, exceptionRatio d * (if p.Fits f A then prior d p else 0)) ≤
      ∑' p : Program d, if (Program.exception x (f x) p).Fits f (insert x A)
        then prior d (Program.exception x (f x) p) else 0 := by
      apply ENNReal.tsum_le_tsum
      intro p
      by_cases hp : p.Fits f A
      · simp only [hp, p.fits_exception f A hp x, ↓reduceIte, prior_exception]; exact le_rfl
      · simp only [hp, ↓reduceIte, mul_zero]; exact zero_le
    _ ≤ ∑' p : Program d, if p.Fits f (insert x A) then prior d p else 0 :=
      ENNReal.tsum_comp_le_tsum_of_injective (Program.exception_injective x (f x)) _

def versionMass (f : Input d → Bool) (A : Finset (Input d)) : ℝ :=
  (eventMass (fun p => p.Fits f A)).toReal

def versionLoss (f : Input d → Bool) (A : Finset (Input d)) : ℝ := -Real.log (versionMass f A)

def correctProbability (f : Input d → Bool) (A : Finset (Input d)) (x : Input d) : ℝ :=
  versionMass f (insert x A) / versionMass f A

def beta (d : ℕ) : ℝ := (2:ℝ)⁻¹^(2*(d+2))

theorem beta_pos (d : ℕ) : 0 < beta d := by unfold beta; positivity

theorem beta_lt_one (d : ℕ) : beta d < 1 := by
  unfold beta
  exact pow_lt_one₀ (by norm_num) (by norm_num) (by omega)

@[simp] theorem exceptionRatio_toReal (d : ℕ) : (exceptionRatio d).toReal = beta d := by
  simp [exceptionRatio, beta, ENNReal.toReal_pow, ENNReal.toReal_inv]

theorem versionMass_pos (f : Input d → Bool) (A : Finset (Input d)) : 0 < versionMass f A := by
  obtain ⟨p, hp⟩ := exists_fitting_program f A
  exact eventMass_real_pos _ p hp

theorem versionMass_le_one (f : Input d → Bool) (A : Finset (Input d)) : versionMass f A ≤ 1 := by
  simpa only [versionMass, ENNReal.toReal_one] using
    ENNReal.toReal_mono ENNReal.one_ne_top (eventMass_le_one (fun p => p.Fits f A))

theorem versionLoss_nonneg (f : Input d → Bool) (A : Finset (Input d)) : 0 ≤ versionLoss f A := by
  have hl := Real.log_le_log (versionMass_pos f A) (versionMass_le_one f A)
  simp only [Real.log_one] at hl
  exact neg_nonneg.mpr hl

theorem correctProbability_pos (f : Input d → Bool) (A : Finset (Input d)) (x : Input d) :
    0 < correctProbability f A x := div_pos (versionMass_pos _ _) (versionMass_pos _ _)

theorem correctProbability_le_one (f : Input d → Bool) (A : Finset (Input d)) (x : Input d) :
    correctProbability f A x ≤ 1 := by
  apply (div_le_one (versionMass_pos f A)).mpr
  exact ENNReal.toReal_mono (eventMass_ne_top _)
    (eventMass_mono (fun p hp z hz => hp z (Finset.mem_insert_of_mem hz)))

theorem correctProbability_ge_beta (f : Input d → Bool) (A : Finset (Input d)) (x : Input d) :
    beta d ≤ correctProbability f A x := by
  have h := ENNReal.toReal_mono (eventMass_ne_top _) (prefix_repair_mass f A x)
  rw [ENNReal.toReal_mul, exceptionRatio_toReal] at h
  exact (le_div_iff₀ (versionMass_pos f A)).mpr h

/-- The sharp chord inequality for negative logarithmic loss. -/
theorem neg_log_le_chord {p b : ℝ} (hb : 0 < b) (hb1 : b < 1)
    (hbp : b ≤ p) (hp1 : p ≤ 1) :
    -Real.log p ≤ (-Real.log b)/(1-b)*(1-p) := by
  have hden : 0 < 1-b := by linarith
  have hc := strictConcaveOn_log_Ioi.concaveOn.2 hb (by norm_num : (0:ℝ)<1)
    (div_nonneg (sub_nonneg.mpr hp1) hden.le)
    (div_nonneg (sub_nonneg.mpr hbp) hden.le)
    (show (1-p)/(1-b)+(p-b)/(1-b)=1 by field_simp; ring)
  simp only [smul_eq_mul, Real.log_one, mul_zero, add_zero] at hc
  have he : (1-p)/(1-b)*b+(p-b)/(1-b)*1 = p := by field_simp; ring
  rw [he] at hc
  have hr : (-Real.log b)/(1-b)*(1-p) = -((1-p)/(1-b)*Real.log b) := by ring
  rw [hr]
  linarith

theorem neg_log_beta (d : ℕ) : -Real.log (beta d) = 2*(d+2)*Real.log 2 := by
  unfold beta
  rw [Real.log_pow, Real.log_inv]
  push_cast
  ring

def cost (d : ℕ) : ℝ := (2*(d+2)*Real.log 2)/(1-beta d)

theorem cost_pos (d : ℕ) : 0 < cost d := by
  unfold cost
  exact div_pos (mul_pos (by positivity) (Real.log_pos (by norm_num)))
    (sub_pos.mpr (beta_lt_one d))

theorem neg_log_correctProbability_le_error (f : Input d → Bool)
    (A : Finset (Input d)) (x : Input d) :
    -Real.log (correctProbability f A x) ≤ cost d*(1-correctProbability f A x) := by
  have h := neg_log_le_chord (beta_pos d) (beta_lt_one d)
    (correctProbability_ge_beta f A x) (correctProbability_le_one f A x)
  simpa only [neg_log_beta, cost] using h

theorem fitting_mass_le_code_tail (f : Input d → Bool) (A : Finset (Input d)) :
    eventMass (fun p => p.Fits f A) ≤ 16*(2⁻¹:ℝ≥0∞)^(codeComplexity f A) :=
  (eventMass_mono (fun p hp => codeComplexity_le f A p hp)).trans
    (eventMass_length_tail d (codeComplexity f A))

theorem code_log_lower (f : Input d → Bool) (A : Finset (Input d)) :
    (codeComplexity f A : ℝ)*Real.log 2 ≤ versionLoss f A + 4*Real.log 2 := by
  have hb := ENNReal.toReal_mono (by finiteness) (fitting_mass_le_code_tail f A)
  simp only [ENNReal.toReal_mul, ENNReal.toReal_pow, ENNReal.toReal_inv, ENNReal.toReal_ofNat] at hb
  have hl := Real.log_le_log (versionMass_pos f A) hb
  rw [Real.log_mul (by norm_num) (by positivity), Real.log_pow, Real.log_inv] at hl
  have hl16 : Real.log (16:ℝ) = 4*Real.log 2 := by
    rw [show (16:ℝ)=2^4 by norm_num, Real.log_pow]
    norm_num
  rw [hl16] at hl
  unfold versionLoss
  linarith

theorem versionLoss_le_code (f : Input d → Bool) (A : Finset (Input d)) :
    versionLoss f A ≤ 2*(codeComplexity f A)*Real.log 2 := by
  obtain ⟨p, hs, hp⟩ := exists_shortest_program f A
  have hraw : rawWeight p ≤ prior d p := by
    have h := ENNReal.div_le_div_left (partition_le_one d) (rawWeight p)
    simpa only [div_one, prior_apply] using h
  have hm := ENNReal.toReal_mono (eventMass_ne_top _) (hraw.trans (prior_le_eventMass (fun q => q.Fits f A) p hp))
  have hrawpos : 0 < (rawWeight p).toReal := by
    unfold rawWeight
    simp only [ENNReal.toReal_pow, ENNReal.toReal_inv, ENNReal.toReal_ofNat]
    positivity
  have hl := neg_le_neg (Real.log_le_log hrawpos hm)
  have he : -Real.log (rawWeight p).toReal = 2*(codeComplexity f A)*Real.log 2 := by
    unfold rawWeight
    simp only [ENNReal.toReal_pow, ENNReal.toReal_inv, ENNReal.toReal_ofNat]
    rw [Real.log_pow, Real.log_inv, hs]
    push_cast
    ring
  rw [he] at hl
  exact hl

end
end NeuralGeneralization.BatchTwoCircuitConverse.Prefix
