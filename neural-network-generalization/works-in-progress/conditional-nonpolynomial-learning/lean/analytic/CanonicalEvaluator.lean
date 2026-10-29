import CanonicalCircuit
import ArithmeticPrecision

/-! Fully instantiated finite-grid evaluator: ranges and precision are chosen
constructively from the bounded canonical quadrature coefficients. -/
noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic

def arithmeticRanges (d : ℕ→ℕ) (B U : ℕ) : ℕ→ℕ
  | 0 => U
  | h+1 => layerNextRange (d h) B (arithmeticRanges d B U h)

def fiveStageAmplification (d : ℕ→ℕ) (B U : ℕ) : ℕ :=
  1+∑j∈Finset.range 5,layerAmplification (d j) B (arithmeticRanges d B U j)

lemma fiveStageAmplification_one_le (d : ℕ→ℕ) (B U : ℕ) : 1≤fiveStageAmplification d B U :=
  Nat.le_add_right _ _

lemma layerAmplification_le_fiveStage (d : ℕ→ℕ) (B U j : ℕ) (hj : j<5) :
    layerAmplification (d j) B (arithmeticRanges d B U j)≤fiveStageAmplification d B U := by
  have hh := Finset.single_le_sum (f:=fun i=>layerAmplification (d i) B (arithmeticRanges d B U i))
    (fun i _=>Nat.zero_le _) (Finset.mem_range.mpr hj)
  exact hh.trans (Nat.le_add_left _ _)

def fiveStageMesh (K : ℕ) (ε : ℝ) : ℕ := ⌈(K:ℝ)^62/ε^32⌉₊+1

lemma fiveStageMesh_pos (K : ℕ) (ε : ℝ) : 0<fiveStageMesh K ε := Nat.zero_lt_succ _

lemma fiveStageMesh_suffices (K : ℕ) {ε : ℝ} (hε : 0<ε) :
    (K:ℝ)^62≤2*(fiveStageMesh K ε:ℝ)*ε^32 := by
  have hh := Nat.le_ceil ((K:ℝ)^62/ε^32)
  have hp : 0<ε^32 := pow_pos hε 32
  have hdiv : (K:ℝ)^62/ε^32≤(fiveStageMesh K ε:ℝ) := by
    unfold fiveStageMesh
    push_cast
    linarith
  have hm := (div_le_iff₀ hp).mp hdiv
  have hn : 0≤(fiveStageMesh K ε:ℝ)*ε^32 := by positivity
  nlinarith

lemma fiveStageMesh_upper (K : ℕ) {ε : ℝ} (hε : 0<ε) :
    (fiveStageMesh K ε:ℝ)<(K:ℝ)^62/ε^32+2 := by
  have hh := Nat.ceil_lt_add_one (show 0≤(K:ℝ)^62/ε^32 by positivity)
  unfold fiveStageMesh
  push_cast
  linarith

/-- For a bounded selected-node canonical program, this constructs a genuine
threshold DAG and a genuine finite output code agreeing exactly with its
Boolean output. The numerical error is uniform over the entire input cube.
No circuit-evaluation or finite-precision certificate is a hypothesis. -/
theorem canonical_finite_evaluator {d n m : ℕ} (w : Fin n → Fin d → ℝ)
    (scale : Fin n → ℝ) (A : Fin m → Fin n → ℝ) (b : Fin n → ℝ)
    (B U : ℕ) (hB : 1≤B) (hw : ∀j i,|w j i|≤(B:ℝ))
    (hA : ∀j i,|A j i|≤(B:ℝ)) (hb : ∀i,|b i|≤(B:ℝ))
    (ε : ℝ) (hε : 0<ε) (hεone : ε≤1) :
    let dims := fun h=>Fintype.card (canonicalCoordinates d n m h)
    let N := arithmeticRanges dims B U
    let K := fiveStageAmplification dims B U
    let Q := fiveStageMesh K ε
    ∃ c : CircuitMap (Fintype.card (Fin d)*Fintype.card (ScalarGrid Q U))
        (Fintype.card (Fin m ⊕ Unit)*Fintype.card (ScalarGrid Q (N 5))),
      c.depth≤25 ∧
      c.size≤∑j∈Finset.range 5,arithmeticLayerSize (dims j) (dims (j+1)) Q B (N j) (N (j+1)) ∧
      ∀x:Fin d→ℝ,(∀i,|x i|≤(U:ℝ))→
        ∃a:(Fin m ⊕ Unit)→ScalarCode Q (N 5),
          c.eval (encodeCoordinateState Q U (fun i=>scalarEncode Q U (x i))) =
            encodeCoordinateState Q (N 5) a ∧
          ∀j,|canonicalArithmeticProgram w scale A b x j-scalarDecode Q (N 5) (a j)|≤ε := by
  dsimp only
  let dims := fun h=>Fintype.card (canonicalCoordinates d n m h)
  let N := arithmeticRanges dims B U
  let K := fiveStageAmplification dims B U
  let Q := fiveStageMesh K ε
  refine ⟨canonicalCircuit w scale A b Q N,canonicalCircuit_depth _ _ _ _ _ _,
    canonicalCircuit_size _ _ _ _ Q B N hB hw hA hb,?_⟩
  intro x hx
  refine ⟨finiteGridRun (canonicalCoordinates d n m) (canonicalLayers w scale A b) Q N
    (fun i=>scalarEncode Q U (x i)) 5,?_,?_⟩
  · exact compileFiniteRun_eval _ _ _ _ _ _
  · intro j
    have he := canonicalCircuit_accuracy w scale A b Q B N (fiveStageMesh_pos _ _) hB hw hA hb
      (fun h=>le_rfl) x hx j
    apply he.trans
    apply fiveLayer_polynomial_precision dims Q B N (K := (K:ℝ))
      (by exact_mod_cast fiveStageAmplification_one_le dims B U) hε hεone
    · intro h hh
      exact_mod_cast layerAmplification_le_fiveStage dims B U h hh
    · exact fiveStageMesh_suffices K hε

#print axioms canonical_finite_evaluator
end ConditionalNonpolynomial.AnalyticLookup
