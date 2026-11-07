import NeuralGeneralization.BatchTwoCircuitConverseDecoderSound
import NeuralGeneralization.BatchTwoCircuitConversePrefixPosterior

/-! The existing circuit prior is exactly the paper's prior on valid finite bitstrings. -/
namespace NeuralGeneralization.BatchTwoCircuitConverse.Prefix
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped ENNReal BigOperators
open Classical

abbrev ValidCode (d : ℕ) := Set.range (@serialize d)

/-- No syntax is identified modulo its computed function: distinct programs
are distinct finite strings, including distinct descriptions of the same function. -/
def codeEquiv (d : ℕ) : Program d ≃ ValidCode d := Equiv.ofInjective serialize (serialize_injective d)

@[simp] lemma codeEquiv_val {d : ℕ} (p : Program d) : (codeEquiv d p).val=serialize p := rfl

lemma deserialize_valid {d : ℕ} (b : ValidCode d) :
    deserialize d b.val=some ((codeEquiv d).symm b) := by
  apply (deserialize_eq_some_iff _ _).mpr
  exact (Equiv.apply_ofInjective_symm (serialize_injective d) b).symm

lemma validCode_prefix_free {d : ℕ} (a b : ValidCode d) (suffix : List Bool)
    (h : a.val++suffix=b.val) : a=b ∧ suffix=[] := by
  obtain ⟨p,rfl⟩ := (codeEquiv d).surjective a
  obtain ⟨q,rfl⟩ := (codeEquiv d).surjective b
  obtain ⟨hp,hs⟩ := serialize_prefix_free p q suffix h
  exact ⟨congrArg (codeEquiv d) hp,hs⟩

lemma string_kraft (d : ℕ) :
    (∑' b : ValidCode d, (2⁻¹:ℝ≥0∞)^b.val.length) ≤ 1 := by
  rw [← (codeEquiv d).tsum_eq]
  simpa only [codeEquiv_val,serialize_length] using program_kraft_le_one d

lemma string_partition (d : ℕ) :
    (∑' b : ValidCode d, (2⁻¹:ℝ≥0∞)^(2*b.val.length))=partition d := by
  rw [← (codeEquiv d).tsum_eq]
  simp only [codeEquiv_val,serialize_length,partition,rawWeight]

/-- A normalized probability mass function on the literal valid strings. -/
def stringPrior (d : ℕ) : PMF (ValidCode d) := (prior d).map (codeEquiv d)

lemma stringPrior_encoded {d : ℕ} (p : Program d) :
    stringPrior d (codeEquiv d p)=prior d p := by
  rw [stringPrior,PMF.map_apply]
  simp only [(codeEquiv d).injective.eq_iff]
  simp

/-- Exactly the manuscript's normalized squared-bit-length formula. -/
theorem stringPrior_formula {d : ℕ} (b : ValidCode d) :
    stringPrior d b=(2⁻¹:ℝ≥0∞)^(2*b.val.length)/
      (∑' c : ValidCode d, (2⁻¹:ℝ≥0∞)^(2*c.val.length)) := by
  obtain ⟨p,rfl⟩ := (codeEquiv d).surjective b
  rw [stringPrior_encoded,string_partition,codeEquiv_val,serialize_length]
  rfl

/-- The exact overwrite prior ratio survives literal serialization. -/
theorem stringPrior_exception {d : ℕ} (x : Input d) (y : Bool) (p : Program d) :
    stringPrior d (codeEquiv d (Program.exception x y p))=
      (2⁻¹:ℝ≥0∞)^(2*(d+2))*stringPrior d (codeEquiv d p) := by
  simp only [stringPrior_encoded]
  exact prior_exception x y p

/-- The paper's normalization bounds now refer to actual strings. -/
theorem string_partition_bounds (d : ℕ) :
    (16:ℝ≥0∞)⁻¹≤(∑' b : ValidCode d, (2⁻¹:ℝ≥0∞)^(2*b.val.length)) ∧
      (∑' b : ValidCode d, (2⁻¹:ℝ≥0∞)^(2*b.val.length))≤1 := by
  rw [string_partition]
  exact ⟨partition_ge_inv_sixteen d,partition_le_one d⟩

/-- Every event of descriptions has the same mass under the literal string prior. -/
theorem stringPrior_event {d : ℕ} (P : Program d → Prop) :
    (∑' b : ValidCode d, if P ((codeEquiv d).symm b) then stringPrior d b else 0)=eventMass P := by
  rw [← (codeEquiv d).tsum_eq]
  simp only [Equiv.symm_apply_apply,stringPrior_encoded]
  exact (eventMass_eq_tsum P).symm

/-- Serialization preserves the entire induced function prior, hence every
consistency posterior and all established online-converse endpoints. -/
theorem string_functionPrior (d : ℕ) :
    (stringPrior d).map (fun b => ((codeEquiv d).symm b).eval)=functionPrior d := by
  rw [stringPrior,PMF.map_comp]
  congr 1
  funext p
  simp only [Function.comp_apply,Equiv.symm_apply_apply]

/-- Literal conditioned string masses give the same next-label probability. -/
theorem string_correctProbability {d : ℕ} (f : Input d → Bool) (A : Finset (Input d))
    (x : Input d) :
    ((∑' b : ValidCode d, if ((codeEquiv d).symm b).Fits f (insert x A)
        then stringPrior d b else 0).toReal)/
      ((∑' b : ValidCode d, if ((codeEquiv d).symm b).Fits f A
        then stringPrior d b else 0).toReal)=correctProbability f A x := by
  rw [stringPrior_event (fun p => p.Fits f (insert x A)),stringPrior_event (fun p => p.Fits f A)]
  rfl

end
end NeuralGeneralization.BatchTwoCircuitConverse.Prefix
