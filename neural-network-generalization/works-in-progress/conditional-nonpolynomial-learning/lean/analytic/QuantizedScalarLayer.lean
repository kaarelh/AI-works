import ParallelScalarLayers
import BoundedRidgeCircuit

/-! Actual finite-grid compilation of a complete real affine/scalar layer.
The theorem handles arbitrary finite-dimensional state, without one-hot
encoding the entire state space. A modulus controls each scalar operation. -/
noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic

lemma scalarDecode_bound (Q N : ℕ) (hQ : 0 < Q) (a : ScalarCode Q N) :
    |scalarDecode Q N a| ≤ (N:ℝ)+1 := by
  have hh : |scalarNumerator Q N a| ≤ ((Q*N+1:ℕ):ℤ) := by
    rw [← Int.natCast_natAbs]
    exact_mod_cast scalarNumerator_bound Q N a
  have hhR : |(scalarNumerator Q N a:ℝ)| ≤ ((Q*N+1:ℕ):ℝ) := by exact_mod_cast hh
  have hQreal : (1:ℝ) ≤ Q := by exact_mod_cast hQ
  unfold scalarDecode
  rw [abs_div, abs_of_nonneg (by positivity : (0:ℝ) ≤ Q)]
  apply (div_le_iff₀ (Nat.cast_pos.mpr hQ)).mpr
  push_cast at hhR
  nlinarith

lemma affine_absolute_bound {d : ℕ} (c x : Fin d → ℝ) (B U : ℝ)
    (hB : 0 ≤ B) (hc : ∀ i, |c i| ≤ B) (hx : ∀ i, |x i| ≤ U) :
    |∑ i, c i*x i| ≤ (d:ℝ)*B*U := by
  calc
    _ ≤ ∑ i, |c i*x i| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ _i : Fin d, B*U := Finset.sum_le_sum fun i _ => by
      rw [abs_mul]
      exact mul_le_mul (hc i) (hx i) (abs_nonneg _) hB
    _ = (d:ℝ)*B*U := by simp; ring

def quantizedLayer {d m : ℕ} (c : Fin m → Fin d → ℝ) (φ : Fin m → ℝ → ℝ)
    (Q Ni No : ℕ) :=
  oneHotLayer (fun j => roundedCoefficients (c j) Q) (scalarNumerator Q Ni)
    (fun j z => scalarEncode Q No (φ j ((z:ℝ)/(Q*Q:ℕ))))

def quantizedUpdate {d m : ℕ} (c : Fin m → Fin d → ℝ) (φ : Fin m → ℝ → ℝ)
    (Q Ni No : ℕ) (a : Fin d → ScalarCode Q Ni) : Fin m → ScalarCode Q No :=
  fun j => scalarEncode Q No (φ j (∑ i, gridRound Q (c j i)*scalarDecode Q Ni (a i)))

@[simp] theorem quantizedLayer_eval {d m : ℕ} (c : Fin m → Fin d → ℝ)
    (φ : Fin m → ℝ → ℝ) (Q Ni No : ℕ) (a : Fin d → ScalarCode Q Ni) :
    (quantizedLayer c φ Q Ni No).eval (oneHotState a) = oneHotState (quantizedUpdate c φ Q Ni No a) := by
  rw [quantizedLayer, oneHotLayer_eval]
  congr 1
  funext j
  unfold quantizedUpdate
  congr 2
  have hh := coordinateTerms_decode (roundedCoefficients (c j) Q) Q Q Ni a
  rw [coordinateTerms_eval] at hh
  exact hh

/-- Accuracy of the actual finite circuit layer. `ω` is a genuine continuity
modulus for the supplied scalar functions on the explicitly bounded affine
range; it is not an assumed circuit-evaluation property. -/
theorem quantizedLayer_accuracy {d m : ℕ} (c : Fin m → Fin d → ℝ)
    (φ : Fin m → ℝ → ℝ) (Q B Ni No : ℕ) (hQ : 0 < Q)
    (hc : ∀ j i, |c j i| ≤ (B:ℝ))
    (x : Fin d → ℝ) (hx : ∀ i, |x i| ≤ (Ni:ℝ))
    (a : Fin d → ScalarCode Q Ni) (η : ℝ) (hη : 0 ≤ η)
    (hprecision : 1/(2*(Q:ℝ)) ≤ η)
    (hinput : ∀ i, |x i-scalarDecode Q Ni (a i)| ≤ η)
    (ω : ℝ → ℝ) (hω : Monotone ω)
    (hφrange : ∀ j s, |s| ≤ (d:ℝ)*((B:ℝ)+1)*((Ni:ℝ)+1) → |φ j s| ≤ (No:ℝ))
    (hφmodulus : ∀ j s t,
      |s| ≤ (d:ℝ)*((B:ℝ)+1)*((Ni:ℝ)+1) →
      |t| ≤ (d:ℝ)*((B:ℝ)+1)*((Ni:ℝ)+1) → |φ j s-φ j t| ≤ ω |s-t|)
    (j : Fin m) :
    |φ j (∑ i, c j i*x i)-scalarDecode Q No (quantizedUpdate c φ Q Ni No a j)| ≤
      ω ((d:ℝ)*η*((B:ℝ)+Ni+η))+1/(2*(Q:ℝ)) := by
  let z := ∑ i, gridRound Q (c j i)*scalarDecode Q Ni (a i)
  have hrounded : |z| ≤ (d:ℝ)*((B:ℝ)+1)*((Ni:ℝ)+1) :=
    affine_absolute_bound _ _ _ _ (by positivity)
      (fun i => gridRound_range Q B hQ (c j i) (hc j i)) (fun i => scalarDecode_bound Q Ni hQ (a i))
  have htrue : |∑ i, c j i*x i| ≤ (d:ℝ)*((B:ℝ)+1)*((Ni:ℝ)+1) := by
    have hh := affine_absolute_bound (c j) x B Ni (Nat.cast_nonneg _) (hc j) hx
    nlinarith [Nat.cast_nonneg d (α:=ℝ), Nat.cast_nonneg B (α:=ℝ), Nat.cast_nonneg Ni (α:=ℝ)]
  have hround := scalarEncode_error Q No hQ (φ j z) (hφrange j z hrounded)
  have herr := affine_perturbation (c j) (fun i => gridRound Q (c j i)) x
    (fun i => scalarDecode Q Ni (a i)) B Ni η (Nat.cast_nonneg _) (Nat.cast_nonneg _) hη
    (hc j) hx (fun i => (gridRound_error Q hQ (c j i)).trans hprecision) hinput
  simp only [Fintype.card_fin] at herr
  have hscalar := (hφmodulus j (∑ i, c j i*x i) z htrue hrounded).trans (hω herr)
  have htri := abs_sub_le (φ j (∑ i, c j i*x i)) (φ j z)
    (scalarDecode Q No (scalarEncode Q No (φ j z)))
  change |φ j (∑ i, c j i*x i)-scalarDecode Q No (scalarEncode Q No (φ j z))| ≤ _
  linarith

theorem quantizedLayer_depth {d m : ℕ} (c : Fin m → Fin d → ℝ)
    (φ : Fin m → ℝ → ℝ) (Q Ni No : ℕ) : (quantizedLayer c φ Q Ni No).depth ≤ 5 :=
  oneHotLayer_depth _ _ _

theorem quantizedLayer_size {d m : ℕ} (c : Fin m → Fin d → ℝ)
    (φ : Fin m → ℝ → ℝ) (Q B Ni No : ℕ) (hc : ∀ j i, |c j i| ≤ (B:ℝ)) :
    let qi := 2*(Q*Ni+1)+1
    let qo := 2*(Q*No+1)+1
    let W := (d*qi)*((Q*B+1)*(Q*Ni+1))
    (quantizedLayer c φ Q Ni No).size ≤ (m*qo)*(qo*((8*W+9)*(2*W+1)+1)) := by
  simpa only [quantizedLayer, scalarGrid_card] using
    oneHotLayer_size (fun j => roundedCoefficients (c j) Q) (scalarNumerator Q Ni)
      (fun j z => scalarEncode Q No (φ j ((z:ℝ)/(Q*Q:ℕ)))) (Q*B+1) (Q*Ni+1)
      (fun j => roundedCoefficients_bound (c j) Q B (hc j)) (scalarNumerator_bound Q Ni)

#print axioms quantizedLayer_eval
#print axioms quantizedLayer_accuracy
#print axioms quantizedLayer_size
#print axioms quantizedLayer_depth
end ConditionalNonpolynomial.AnalyticLookup
