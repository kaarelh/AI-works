import OneHotCoordinates
import FiniteGridEncoding

/-! Actual threshold-circuit evaluation of rounded scalar activations after
integer affine forms, together with real numerical accuracy. -/
noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic

def decodeScalarState (Q N : ℕ) (b : Input (Fintype.card (ScalarGrid Q N))) : ℝ :=
  ∑ i, if b i then scalarDecode Q N i else 0

@[simp] theorem decodeScalarState_oneHot (Q N : ℕ) (a : ScalarCode Q N) :
    decodeScalarState Q N (fun i => decide (a=i)) = scalarDecode Q N a := by
  simp [decodeScalarState]

def roundedAffineCircuit {d : ℕ} (ts : List (Fin d × ℤ)) (φ : ℝ → ℝ)
    (den Q N : ℕ) : CircuitMap d (Fintype.card (ScalarGrid Q N)) :=
  oneHotAffine ts (fun z => scalarEncode Q N (φ ((z:ℝ)/den)))

@[simp] theorem roundedAffineCircuit_decode {d : ℕ} (ts : List (Fin d × ℤ))
    (φ : ℝ → ℝ) (den Q N : ℕ) (x : Input d) :
    decodeScalarState Q N ((roundedAffineCircuit ts φ den Q N).eval x) =
      scalarDecode Q N (scalarEncode Q N (φ ((integerValue ts x:ℝ)/den))) := by
  have heq : (roundedAffineCircuit ts φ den Q N).eval x =
      fun i => decide (scalarEncode Q N (φ ((integerValue ts x:ℝ)/den))=i) := by
    funext i
    exact oneHotAffine_eval _ _ x i
  rw [heq, decodeScalarState_oneHot]

lemma integerValue_real_bound {d : ℕ} (ts : List (Fin d × ℤ)) (x : Input d) :
    |(integerValue ts x:ℝ)| ≤ (integerWeight ts:ℝ) := by
  have hh : |integerValue ts x| ≤ (integerWeight ts:ℤ) := by
    rw [← Int.natCast_natAbs]
    exact_mod_cast integerValue_bound ts x
  exact_mod_cast hh

/-- Numerical correctness of a genuine constant-depth threshold circuit for
any bounded scalar lookup. The input is an actual integer affine form. -/
theorem roundedAffineCircuit_error {d : ℕ} (ts : List (Fin d × ℤ))
    (φ : ℝ → ℝ) (den Q N : ℕ) (hden : 0 < den) (hQ : 0 < Q)
    (hφ : ∀ z, |z| ≤ (integerWeight ts:ℝ) → |φ z| ≤ (N:ℝ)) (x : Input d) :
    |φ ((integerValue ts x:ℝ)/den)-
      decodeScalarState Q N ((roundedAffineCircuit ts φ den Q N).eval x)| ≤ 1/(2*(Q:ℝ)) := by
  rw [roundedAffineCircuit_decode]
  apply scalarEncode_error Q N hQ
  apply hφ
  rw [abs_div, abs_of_nonneg (Nat.cast_nonneg den : (0:ℝ) ≤ den)]
  apply (div_le_iff₀ (Nat.cast_pos.mpr hden)).mpr
  have h0 := integerValue_real_bound ts x
  have h1 : (1:ℝ) ≤ den := by exact_mod_cast hden
  have h2 : (0:ℝ) ≤ integerWeight ts := Nat.cast_nonneg _
  nlinarith

/-- Scale-independent numerical correctness for normalized tanh. -/
theorem roundedNormalizedTanh_error {d : ℕ} (ts : List (Fin d × ℤ))
    (a : ℝ) (den Q : ℕ) (hden : 0 < den) (hQ : 0 < Q) (x : Input d) :
    |normalizedTanh a ((integerValue ts x:ℝ)/den)-
      decodeScalarState Q (integerWeight ts)
        ((roundedAffineCircuit ts (normalizedTanh a) den Q (integerWeight ts)).eval x)|
      ≤ 1/(2*(Q:ℝ)) := by
  exact roundedAffineCircuit_error ts (normalizedTanh a) den Q (integerWeight ts) hden hQ
    (fun z hz => (normalizedTanh_bound a z).trans hz) x

theorem roundedAffineCircuit_depth {d : ℕ} (ts : List (Fin d × ℤ))
    (φ : ℝ → ℝ) (den Q N : ℕ) : (roundedAffineCircuit ts φ den Q N).depth ≤ 5 :=
  oneHotAffine_depth _ _

theorem roundedAffineCircuit_size {d : ℕ} (ts : List (Fin d × ℤ))
    (φ : ℝ → ℝ) (den Q N : ℕ) :
    (roundedAffineCircuit ts φ den Q N).size ≤
      (2*(Q*N+1)+1)*((8*integerWeight ts+9)*(2*integerWeight ts+1)+1) := by
  simpa only [roundedAffineCircuit, scalarGrid_card] using oneHotAffine_size ts
    (fun z => scalarEncode Q N (φ ((z:ℝ)/den)))

#print axioms roundedNormalizedTanh_error
#print axioms roundedAffineCircuit_error
#print axioms roundedAffineCircuit_size
#print axioms roundedAffineCircuit_depth
end ConditionalNonpolynomial.AnalyticLookup
