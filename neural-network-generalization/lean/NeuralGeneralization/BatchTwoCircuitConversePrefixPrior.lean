import NeuralGeneralization.BatchTwoCircuitConversePrefixKraft

/-!
# The normalized squared-code-length prior and its exact exception cost
-/

namespace NeuralGeneralization.BatchTwoCircuitConverse.Prefix

open scoped ENNReal BigOperators
noncomputable section
open Classical

/-- Unnormalized weight 2^(-2 length), as in the manuscript. -/
def rawWeight {d : ℕ} (p : Program d) : ℝ≥0∞ := (2⁻¹ : ℝ≥0∞)^(2*p.length)

def partition (d : ℕ) : ℝ≥0∞ := ∑' p : Program d, rawWeight p

def rawEvent {d : ℕ} (P : Program d → Prop) : ℝ≥0∞ :=
  ∑' p : Program d, if P p then rawWeight p else 0

theorem partition_le_one (d : ℕ) : partition d ≤ 1 := by
  apply le_trans _ (program_kraft_le_one d)
  apply ENNReal.tsum_le_tsum
  intro p
  exact pow_le_pow_of_le_one zero_le (by norm_num) (by omega : p.length ≤ 2*p.length)

theorem partition_ge_inv_sixteen (d : ℕ) : (16 : ℝ≥0∞)⁻¹ ≤ partition d := by
  have h := ENNReal.le_tsum (f := fun p : Program d => rawWeight p)
    (Program.base (Circuit.empty d))
  have he : rawWeight (Program.base (Circuit.empty d)) = (16:ℝ≥0∞)⁻¹ := by
    unfold rawWeight
    rw [Program.length_base, Circuit.size_empty]
    norm_num [baseLength, ← ENNReal.inv_pow]
  rw [he] at h
  exact h

theorem partition_pos (d : ℕ) : 0 < partition d :=
  (ENNReal.inv_pos.mpr (by norm_num : (16:ℝ≥0∞) ≠ ⊤)).trans_le (partition_ge_inv_sixteen d)

theorem partition_ne_top (d : ℕ) : partition d ≠ ⊤ :=
  ne_top_of_le_ne_top ENNReal.one_ne_top (partition_le_one d)

def prior (d : ℕ) : PMF (Program d) := by
  refine ⟨fun p => rawWeight p / partition d, ENNReal.summable.hasSum_iff.mpr ?_⟩
  simp only [div_eq_mul_inv, ENNReal.tsum_mul_right]
  exact ENNReal.mul_inv_cancel (partition_pos d).ne' (partition_ne_top d)

@[simp] theorem prior_apply {d : ℕ} (p : Program d) :
    prior d p = rawWeight p / partition d := rfl

def eventMass {d : ℕ} (P : Program d → Prop) : ℝ≥0∞ := rawEvent P / partition d

theorem eventMass_eq_tsum {d : ℕ} (P : Program d → Prop) :
    eventMass P = ∑' p : Program d, if P p then prior d p else 0 := by
  unfold eventMass rawEvent
  simp_rw [prior_apply, div_eq_mul_inv]
  rw [← ENNReal.tsum_mul_right]
  apply tsum_congr
  intro p
  split_ifs <;> simp

theorem eventMass_le_one {d : ℕ} (P : Program d → Prop) : eventMass P ≤ 1 := by
  rw [eventMass_eq_tsum, ← (prior d).tsum_coe]
  apply ENNReal.tsum_le_tsum
  intro p
  split_ifs <;> simp

theorem eventMass_ne_top {d : ℕ} (P : Program d → Prop) : eventMass P ≠ ⊤ :=
  ne_top_of_le_ne_top ENNReal.one_ne_top (eventMass_le_one P)

theorem rawWeight_pos {d : ℕ} (p : Program d) : 0 < rawWeight p := by
  unfold rawWeight
  exact ENNReal.pow_pos (ENNReal.inv_pos.mpr (by norm_num)) _

theorem prior_pos {d : ℕ} (p : Program d) : 0 < prior d p := by
  rw [prior_apply]
  exact ENNReal.div_pos (rawWeight_pos p).ne' (partition_ne_top d)

theorem prior_le_eventMass {d : ℕ} (P : Program d → Prop) (p : Program d) (hp : P p) :
    prior d p ≤ eventMass P := by
  rw [eventMass_eq_tsum]
  simpa only [hp, ↓reduceIte] using
    ENNReal.le_tsum (f := fun q : Program d => if P q then prior d q else 0) p

theorem eventMass_real_pos {d : ℕ} (P : Program d → Prop) (p : Program d) (hp : P p) :
    0 < (eventMass P).toReal :=
  ENNReal.toReal_pos (ne_of_gt ((prior_pos p).trans_le (prior_le_eventMass P p hp)))
    (eventMass_ne_top P)

/-- Constant prior ratio of an exception constructor. -/
def exceptionRatio (d : ℕ) : ℝ≥0∞ := (2⁻¹ : ℝ≥0∞)^(2*(d+2))

theorem rawWeight_exception {d : ℕ} (x : Input d) (y : Bool) (p : Program d) :
    rawWeight (Program.exception x y p) = exceptionRatio d * rawWeight p := by
  simp only [rawWeight, Program.length_exception, exceptionRatio]
  rw [Nat.mul_add, pow_add]
  exact mul_comm _ _

theorem prior_exception {d : ℕ} (x : Input d) (y : Bool) (p : Program d) :
    prior d (Program.exception x y p) = exceptionRatio d * prior d p := by
  simp only [prior_apply, rawWeight_exception, div_eq_mul_inv, mul_assoc]

theorem rawEvent_length_tail (d K : ℕ) :
    rawEvent (fun p : Program d => K ≤ p.length) ≤ (2⁻¹ : ℝ≥0∞)^K := by
  calc
    rawEvent (fun p : Program d => K ≤ p.length) ≤
        ∑' p : Program d, (2⁻¹ : ℝ≥0∞)^K * (2⁻¹ : ℝ≥0∞)^p.length := by
      apply ENNReal.tsum_le_tsum
      intro p
      by_cases hK : K ≤ p.length
      · simp only [hK, ↓reduceIte, rawWeight, show 2*p.length = p.length+p.length by omega, pow_add]
        exact mul_le_mul_left
          (pow_le_pow_of_le_one (a := (2⁻¹:ℝ≥0∞)) zero_le (by norm_num) hK) _
      · simp only [hK, ↓reduceIte]
        exact zero_le
    _ = (2⁻¹ : ℝ≥0∞)^K * ∑' p : Program d, (2⁻¹ : ℝ≥0∞)^p.length := ENNReal.tsum_mul_left
    _ ≤ (2⁻¹ : ℝ≥0∞)^K * 1 := mul_le_mul_right (program_kraft_le_one d) _
    _ = (2⁻¹ : ℝ≥0∞)^K := mul_one _

theorem eventMass_length_tail (d K : ℕ) :
    eventMass (fun p : Program d => K ≤ p.length) ≤ 16*(2⁻¹ : ℝ≥0∞)^K := by
  have h := ENNReal.div_le_div (rawEvent_length_tail d K) (partition_ge_inv_sixteen d)
  simpa only [eventMass, div_eq_mul_inv, inv_inv, mul_comm] using h

def Program.Fits {d : ℕ} (p : Program d) (f : Input d → Bool) (A : Finset (Input d)) : Prop :=
  p.compile.Fits f A

theorem exists_fitting_program {d : ℕ} (f : Input d → Bool) (A : Finset (Input d)) :
    ∃ p : Program d, p.Fits f A := by
  obtain ⟨c, hc⟩ := exists_fitting_circuit f A
  exact ⟨Program.base c, hc⟩

theorem exists_fitting_length {d : ℕ} (f : Input d → Bool) (A : Finset (Input d)) :
    ∃ n : ℕ, ∃ p : Program d, p.length = n ∧ p.Fits f A := by
  obtain ⟨p, hp⟩ := exists_fitting_program f A
  exact ⟨p.length, p, rfl, hp⟩

/-- K_A(f), the minimum bit length in the explicitly specified grammar. -/
def codeComplexity {d : ℕ} (f : Input d → Bool) (A : Finset (Input d)) : ℕ :=
  Nat.find (exists_fitting_length f A)

theorem exists_shortest_program {d : ℕ} (f : Input d → Bool) (A : Finset (Input d)) :
    ∃ p : Program d, p.length = codeComplexity f A ∧ p.Fits f A :=
  Nat.find_spec (exists_fitting_length f A)

theorem codeComplexity_le {d : ℕ} (f : Input d → Bool) (A : Finset (Input d))
    (p : Program d) (hp : p.Fits f A) : codeComplexity f A ≤ p.length :=
  Nat.find_min' (exists_fitting_length f A) ⟨p, rfl, hp⟩

theorem circuit_complexity_le_code {d : ℕ} (f : Input d → Bool) (A : Finset (Input d)) :
    complexity f A ≤ 3*codeComplexity f A := by
  obtain ⟨p, hs, hp⟩ := exists_shortest_program f A
  have h := (complexity_le f A p.compile hp).trans p.compile_size_le
  simpa only [hs] using h

end
end NeuralGeneralization.BatchTwoCircuitConverse.Prefix
