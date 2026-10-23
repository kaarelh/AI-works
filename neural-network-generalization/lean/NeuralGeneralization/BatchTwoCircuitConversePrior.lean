import NeuralGeneralization.BatchTwoCircuitConverseDescriptions
import NeuralGeneralization.BatchTwoCircuitConverseDeterministic
import Mathlib.Probability.ProbabilityMassFunction.Constructions
import Mathlib.Analysis.SpecificLimits.Basic

/-!
# The concrete geometric NAND-description prior

Gate counts have probabilities 2^(-(n+1)); conditional on n, all ordered
NAND wiring lists are equiprobable. This file constructs an actual normalized
countable PMF, rather than assuming an abstract complexity-prior comparison.
-/

namespace NeuralGeneralization.BatchTwoCircuitConverse

open scoped ENNReal BigOperators
noncomputable section
open Classical

instance Gates.fintype (d : ℕ) : (n : ℕ) → Fintype (Gates d n)
  | 0 => inferInstanceAs (Fintype Unit)
  | n + 1 => @instFintypeProd (Gates d n) _ (Gates.fintype d n) inferInstance

instance Gates.nonempty (d : ℕ) : (n : ℕ) → Nonempty (Gates d n)
  | 0 => ⟨()⟩
  | n + 1 => by
    obtain ⟨g⟩ := Gates.nonempty d n
    exact ⟨g, ⟨0, by omega⟩, ⟨0, by omega⟩⟩

def Circuit.equivSigma (d : ℕ) : Circuit d ≃ (n : ℕ) × Gates d n where
  toFun c := ⟨c.size, c.gates⟩
  invFun c := ⟨c.1, c.2⟩
  left_inv c := by cases c; rfl
  right_inv c := by cases c; rfl

@[simp] theorem Gates.card_zero (d : ℕ) : Fintype.card (Gates d 0) = 1 := by
  simp [Gates]

@[simp] theorem Gates.card_succ (d n : ℕ) :
    Fintype.card (Gates d (n + 1)) =
      Fintype.card (Gates d n) * (d + 2 + n)^2 := by
  simp [Gates, Fintype.card_prod, pow_two, Nat.mul_assoc]

theorem Gates.card_pos (d n : ℕ) : 0 < Fintype.card (Gates d n) :=
  Fintype.card_pos

/-- Probability of one particular NAND wiring description. -/
def circuitMass {d : ℕ} (c : Circuit d) : ℝ≥0∞ :=
  (2⁻¹ : ℝ≥0∞) ^ (c.size + 1) / Fintype.card (Gates d c.size)

@[simp] theorem circuitMass_mk (d n : ℕ) (g : Gates d n) :
    circuitMass (Circuit.mk n g) =
      (2⁻¹ : ℝ≥0∞) ^ (n + 1) / Fintype.card (Gates d n) := rfl

theorem sum_circuitMass_size (d n : ℕ) :
    ∑ g : Gates d n, circuitMass (Circuit.mk n g) = (2⁻¹ : ℝ≥0∞) ^ (n + 1) := by
  simp only [circuitMass_mk, Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  apply ENNReal.mul_div_cancel
  · exact_mod_cast (Gates.card_pos d n).ne'
  · exact ENNReal.natCast_ne_top _

theorem tsum_circuitMass (d : ℕ) : ∑' c : Circuit d, circuitMass c = 1 := by
  rw [← (Circuit.equivSigma d).symm.tsum_eq]
  change (∑' c : (n : ℕ) × Gates d n, circuitMass (Circuit.mk c.1 c.2)) = 1
  rw [ENNReal.tsum_sigma (fun n g => circuitMass (Circuit.mk n g))]
  simp only [tsum_fintype, sum_circuitMass_size]
  rw [ENNReal.tsum_geometric_add_one, ENNReal.one_sub_inv_two, inv_inv]
  exact ENNReal.inv_mul_cancel (by norm_num) (by norm_num)

/-- The normalized geometric gate-count/uniform-wiring prior. -/
def circuitPrior (d : ℕ) : PMF (Circuit d) :=
  ⟨circuitMass, ENNReal.summable.hasSum_iff.mpr (tsum_circuitMass d)⟩

@[simp] theorem circuitPrior_apply (d : ℕ) (c : Circuit d) :
    circuitPrior d c = circuitMass c := rfl


theorem Gates.card_le (d n : ℕ) :
    Fintype.card (Gates d n) ≤ (d + n + 1) ^ (2 * n) := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [Gates.card_succ]
    calc
      Fintype.card (Gates d n) * (d + 2 + n)^2 ≤
          (d + n + 1)^(2*n) * (d + 2 + n)^2 := Nat.mul_le_mul_right _ ih
      _ ≤ (d + (n+1) + 1)^(2*n) * (d + 2 + n)^2 :=
        Nat.mul_le_mul_right _ (Nat.pow_le_pow_left (by omega) _)
      _ = (d + (n+1) + 1)^(2*(n+1)) := by
        have he : d + 2 + n = d + (n+1) + 1 := by omega
        rw [he, ← pow_add]
        congr 1

/-- Push the actual countable circuit prior to the finite set of Boolean functions. -/
def circuitFunctionPrior (d : ℕ) : PMF (Input d → Bool) :=
  (circuitPrior d).map Circuit.eval

/-- Real-valued function weights for the exact consistency posterior. -/
def functionWeight (d : ℕ) (f : Input d → Bool) : ℝ :=
  (circuitFunctionPrior d f).toReal

theorem functionWeight_nonneg (d : ℕ) (f : Input d → Bool) :
    0 ≤ functionWeight d f := ENNReal.toReal_nonneg

theorem functionWeight_sum (d : ℕ) : ∑ f, functionWeight d f = 1 := by
  unfold functionWeight
  rw [← ENNReal.toReal_sum (fun f _ => (circuitFunctionPrior d).apply_ne_top f)]
  have h : ∑ f, circuitFunctionPrior d f = 1 := by
    simpa only [tsum_fintype] using (circuitFunctionPrior d).tsum_coe
  rw [h, ENNReal.toReal_one]

theorem circuitMass_le_functionPrior {d : ℕ} (c : Circuit d) :
    circuitMass c ≤ circuitFunctionPrior d c.eval := by
  unfold circuitFunctionPrior
  rw [PMF.map_apply]
  simpa only [ite_true, circuitPrior_apply] using
    ENNReal.le_tsum (f := fun a : Circuit d =>
      if c.eval = a.eval then circuitPrior d a else 0) c

@[simp] theorem circuitMass_toReal {d : ℕ} (c : Circuit d) :
    (circuitMass c).toReal = (2 : ℝ)⁻¹ ^ (c.size+1) / Fintype.card (Gates d c.size) := by
  simp [circuitMass, ENNReal.toReal_div, ENNReal.toReal_pow, ENNReal.toReal_inv]

theorem circuitMass_toReal_pos {d : ℕ} (c : Circuit d) :
    0 < (circuitMass c).toReal := by
  rw [circuitMass_toReal]
  exact div_pos (pow_pos (by norm_num) _) (by exact_mod_cast Gates.card_pos d c.size)

theorem circuitMass_toReal_le_weight {d : ℕ} (c : Circuit d) :
    (circuitMass c).toReal ≤ functionWeight d c.eval :=
  ENNReal.toReal_mono ((circuitFunctionPrior d).apply_ne_top _)
    (circuitMass_le_functionPrior c)

theorem functionWeight_pos {d : ℕ} (f : Input d → Bool) : 0 < functionWeight d f := by
  obtain ⟨c, hc⟩ := exists_fitting_circuit f Finset.univ
  have he : c.eval = f := funext (fun x => hc x (Finset.mem_univ x))
  rw [← he]
  exact (circuitMass_toReal_pos c).trans_le (circuitMass_toReal_le_weight c)

end
end NeuralGeneralization.BatchTwoCircuitConverse
