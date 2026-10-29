import RoundedRidgeCircuit

/-! A rounded ridge circuit with a prescribed output range. The valid-state
range is bounded from the real coefficient/input bounds, independently of mesh
precision; invalid one-hot states need not satisfy the approximation guarantee. -/
noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic

lemma gridRound_range (Q N : ℕ) (hQ : 0 < Q) (x : ℝ) (hx : |x| ≤ (N:ℝ)) :
    |gridRound Q x| ≤ (N:ℝ)+1 := by
  have he := gridRound_error Q hQ x
  have hQreal : (1:ℝ) ≤ Q := by exact_mod_cast hQ
  have hh : 1/(2*(Q:ℝ)) ≤ 1 := (div_le_one (by positivity)).mpr (by linarith)
  have ht := abs_sub_le (gridRound Q x) x 0
  simp only [sub_zero, abs_sub_comm (gridRound Q x) x] at ht
  linarith

lemma rounded_affine_range {d : ℕ} (c x : Fin d → ℝ) (Q Nc Nx : ℕ)
    (hQ : 0 < Q) (hc : ∀ i, |c i| ≤ (Nc:ℝ)) (hx : ∀ i, |x i| ≤ (Nx:ℝ)) :
    |∑ i, gridRound Q (c i)*gridRound Q (x i)| ≤ (d:ℝ)*((Nc:ℝ)+1)*((Nx:ℝ)+1) := by
  calc
    _ ≤ ∑ i, |gridRound Q (c i)*gridRound Q (x i)| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ _i : Fin d, ((Nc:ℝ)+1)*((Nx:ℝ)+1) := Finset.sum_le_sum fun i _ => by
      rw [abs_mul]
      exact mul_le_mul (gridRound_range Q Nc hQ (c i) (hc i))
        (gridRound_range Q Nx hQ (x i) (hx i)) (abs_nonneg _) (by positivity)
    _ = (d:ℝ)*((Nc:ℝ)+1)*((Nx:ℝ)+1) := by simp; ring

def boundedRidgeCircuit {d : ℕ} (c : Fin d → ℝ) (a : ℝ) (Q Nx Qo No : ℕ) :=
  roundedAffineCircuit (ridgeTerms c Q Nx) (normalizedTanh a) (Q*Q) Qo No

theorem boundedRidgeCircuit_error {d : ℕ} (c x : Fin d → ℝ) (a : ℝ)
    (Q Nc Nx Qo No : ℕ) (hQ : 0 < Q) (hQo : 0 < Qo)
    (hc : ∀ i, |c i| ≤ (Nc:ℝ)) (hx : ∀ i, |x i| ≤ (Nx:ℝ))
    (hNo : d*(Nc+1)*(Nx+1) ≤ No) :
    |normalizedTanh a (∑ i, c i*x i) - decodeScalarState Qo No
      ((boundedRidgeCircuit c a Q Nx Qo No).eval
        (oneHotState (fun i => scalarEncode Q Nx (x i))))| ≤
      (d:ℝ)*(1/(2*(Q:ℝ)))*((Nc:ℝ)+Nx+1/(2*(Q:ℝ)))+1/(2*(Qo:ℝ)) := by
  let codes := fun i => scalarEncode Q Nx (x i)
  have hdecode := coordinateTerms_decode (roundedCoefficients c Q) Q Q Nx codes
  have hsum : (integerValue (ridgeTerms c Q Nx) (oneHotState codes):ℝ)/(Q*Q:ℕ) =
      ∑ i, gridRound Q (c i)*gridRound Q (x i) := by
    rw [show (integerValue (ridgeTerms c Q Nx) (oneHotState codes):ℝ)/(Q*Q:ℕ) =
      ∑ i, ((roundedCoefficients c Q i:ℝ)/Q)*scalarDecode Q Nx (codes i) from hdecode]
    apply Finset.sum_congr rfl
    intro i hi
    rw [show scalarDecode Q Nx (codes i) = gridRound Q (x i) from scalarDecode_encode Q Nx (x i) (hx i)]
    rfl
  have hNoR : (d:ℝ)*((Nc:ℝ)+1)*((Nx:ℝ)+1) ≤ No := by exact_mod_cast hNo
  have hrange := (normalizedTanh_bound a (∑ i, gridRound Q (c i)*gridRound Q (x i))).trans
    ((rounded_affine_range c x Q Nc Nx hQ hc hx).trans hNoR)
  have heval := scalarEncode_error Qo No hQo
    (normalizedTanh a (∑ i, gridRound Q (c i)*gridRound Q (x i))) hrange
  have hcircuit : decodeScalarState Qo No ((boundedRidgeCircuit c a Q Nx Qo No).eval (oneHotState codes)) =
      scalarDecode Qo No (scalarEncode Qo No
        (normalizedTanh a (∑ i, gridRound Q (c i)*gridRound Q (x i)))) := by
    rw [boundedRidgeCircuit, roundedAffineCircuit_decode, hsum]
  rw [← hcircuit] at heval
  have herr := affine_perturbation c (fun i => gridRound Q (c i)) x (fun i => gridRound Q (x i))
    Nc Nx (1/(2*(Q:ℝ))) (Nat.cast_nonneg _) (Nat.cast_nonneg _) (by positivity)
    hc hx (fun i => gridRound_error Q hQ (c i)) (fun i => gridRound_error Q hQ (x i))
  simp only [Fintype.card_fin] at herr
  have hL := normalizedTanh_lipschitz a (∑ i, c i*x i) (∑ i, gridRound Q (c i)*gridRound Q (x i))
  have ht := abs_sub_le (normalizedTanh a (∑ i, c i*x i))
    (normalizedTanh a (∑ i, gridRound Q (c i)*gridRound Q (x i)))
    (decodeScalarState Qo No ((boundedRidgeCircuit c a Q Nx Qo No).eval (oneHotState codes)))
  change |normalizedTanh a (∑ i, c i*x i)-
    decodeScalarState Qo No ((boundedRidgeCircuit c a Q Nx Qo No).eval (oneHotState codes))| ≤ _
  linarith

theorem boundedRidgeCircuit_depth {d : ℕ} (c : Fin d → ℝ) (a : ℝ) (Q Nx Qo No : ℕ) :
    (boundedRidgeCircuit c a Q Nx Qo No).depth ≤ 5 := roundedAffineCircuit_depth _ _ _ _ _

theorem boundedRidgeCircuit_size {d : ℕ} (c : Fin d → ℝ) (a : ℝ) (Q Nx Qo No : ℕ) :
    let W := integerWeight (ridgeTerms c Q Nx)
    (boundedRidgeCircuit c a Q Nx Qo No).size ≤
      (2*(Qo*No+1)+1)*((8*W+9)*(2*W+1)+1) := roundedAffineCircuit_size _ _ _ _ _

#print axioms boundedRidgeCircuit_error
#print axioms boundedRidgeCircuit_size
#print axioms boundedRidgeCircuit_depth
end ConditionalNonpolynomial.AnalyticLookup
