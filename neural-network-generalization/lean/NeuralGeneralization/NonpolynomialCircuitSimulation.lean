import NeuralGeneralization.NonpolynomialCircuitModel

/-! The exact semantic invariant for the actual network weights. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.NonpolynomialInterpolation
open ConcreteModel
namespace GateDictionary
variable {φ : ℝ → ℝ} {q d S r : ℕ}

/-- Reading a previously encoded gate gives its exact Boolean value. -/
theorem read_feature (D : GateDictionary φ q) (g : BooleanFunction q) (p : Cube q) :
    (∑ j, D.readout g j * D.feature p j) = labelReal (g p) := D.exact_gate g p

/-- Routing may reuse a signal. The sum has only `q` terms per individual
weight, independently of the number of carried signals. -/
theorem routed_features (D : GateDictionary φ q) (g : Fin S → BooleanFunction q)
    (p : Fin S → Cube q) (src : Fin q → Fin S) (k : Cube q) :
    (∑ v, ∑ j, (∑ a, if src a = v then D.input k a * D.readout (g v) j else 0) *
      D.feature (p v) j) =
    ∑ a, D.input k a * labelReal (g (src a) (p (src a))) := by
  classical
  simp_rw [Finset.sum_mul, ite_mul, zero_mul]
  calc
    (∑ v, ∑ j, ∑ a, if src a = v then D.input k a * D.readout (g v) j *
        D.feature (p v) j else 0) =
        ∑ a, ∑ v, ∑ j, if src a = v then D.input k a * D.readout (g v) j *
          D.feature (p v) j else 0 := by
      simp_rw [Finset.sum_comm (s := (Finset.univ : Finset (Cube q)))
        (t := (Finset.univ : Finset (Fin q)))]
      rw [Finset.sum_comm]
    _ = ∑ a, D.input k a * labelReal (g (src a) (p (src a))) := by
      apply Finset.sum_congr rfl
      intro a _
      rw [Finset.sum_eq_single (src a)]
      · simp only [↓reduceIte, mul_assoc, ← Finset.mul_sum, read_feature]
      · intro v _ hv
        simp [Ne.symm hv]
      · simp

/-- Each internal weight matrix implements the next layer of Boolean gates. -/
theorem hiddenStep_circuit (D : GateDictionary φ q) (C : LayeredCircuit q d S r)
    (p : Fin S → Cube q) (t : Fin r) :
    hiddenStep φ (D.circuitWeights C) (D.encoding p) t =
      D.encoding (fun s a => C.gate t.castSucc (C.source t s a) (p (C.source t s a))) := by
  classical
  funext i
  unfold hiddenStep
  rw [← (circuitNeurons q S).sum_comp]
  simp only [encoding, Equiv.symm_apply_apply, Fintype.sum_sum_type, Fintype.sum_prod_type]
  cases hi : (circuitNeurons q S).symm i with
  | inl u =>
    simp [circuitWeights, hi, D.constant_ne_zero]
  | inr p' =>
    rcases p' with ⟨s, k⟩
    simp only [circuitWeights, hi, Equiv.symm_apply_apply, Fintype.sum_unique,
      div_mul_cancel₀ _ D.constant_ne_zero]
    rw [D.routed_features]
    simp only [feature, add_comm]

/-- Hidden states after a literal prefix of the network's layer list. -/
def circuitAfter (D : GateDictionary φ q) (C : LayeredCircuit q d S r)
    (x : Cube d) (n : ℕ) : Fin (circuitWidth q S) → ℝ :=
  ((List.finRange r).take n).foldl (hiddenStep φ (D.circuitWeights C))
    (firstHidden φ (D.circuitWeights C) x)

theorem circuitAfter_succ (D : GateDictionary φ q) (C : LayeredCircuit q d S r)
    (x : Cube d) (s : Fin r) :
    D.circuitAfter C x (s.val + 1) =
      hiddenStep φ (D.circuitWeights C) (D.circuitAfter C x s.val) s := by
  unfold circuitAfter
  rw [List.take_succ_eq_append_getElem (by simp [s.isLt]), List.foldl_append]
  simp only [List.foldl_cons, List.foldl_nil, List.getElem_finRange]
  rfl

/-- Every carried signal retains its exact Boolean decoding at every layer. -/
theorem circuitAfter_encoding (D : GateDictionary φ q) (C : LayeredCircuit q d S r)
    (x : Cube d) (n : ℕ) (hn : n ≤ r) :
    D.circuitAfter C x n = D.encoding (C.patterns x n) := by
  induction n with
  | zero => simpa [circuitAfter] using D.firstHidden_circuit C x
  | succ n ih =>
    rw [show n + 1 = (⟨n, by omega⟩ : Fin r).val + 1 by rfl, D.circuitAfter_succ,
      ih (by omega), D.hiddenStep_circuit, LayeredCircuit.patterns_succ]

/-- The constructed network has exactly the same signed output as the circuit. -/
theorem networkOutput_circuit (D : GateDictionary φ q) (C : LayeredCircuit q d S r)
    (x : Cube d) : networkOutput φ (D.circuitWeights C) x = labelReal (C.computes x) := by
  classical
  have hf : finalHidden φ (D.circuitWeights C) x = D.encoding (C.patterns x r) := by
    have htake : (List.finRange r).take r = List.finRange r := by simp
    simpa only [circuitAfter, htake, finalHidden]
      using D.circuitAfter_encoding C x r le_rfl
  unfold networkOutput
  rw [hf, ← (circuitNeurons q S).sum_comp]
  simp only [circuitWeights, encoding, Equiv.symm_apply_apply, Fintype.sum_sum_type,
    Fintype.sum_prod_type, zero_mul, Finset.sum_const_zero, zero_add, ite_mul]
  rw [Finset.sum_eq_single C.output]
  · simp only [↓reduceIte, read_feature, LayeredCircuit.computes]
  · intro s _ hs
    simp [hs]
  · simp

end GateDictionary
end NeuralGeneralization.NonpolynomialInterpolation
