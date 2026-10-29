import RoundedAffineCircuits

/-! A genuine threshold evaluator for an arbitrary normalized tanh ridge on a
bounded real domain. Both coefficient and input rounding are included in the
proved error, and the scalar normalization has no resource cost. -/
noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic

lemma coordinateTerms_decode {d : ℕ} (c : Fin d → ℤ) (Qc Qx Nx : ℕ)
    (a : Fin d → ScalarCode Qx Nx) :
    (integerValue (coordinateTerms c (scalarNumerator Qx Nx)) (oneHotState a):ℝ)/(Qc*Qx:ℕ) =
      ∑ i, ((c i:ℝ)/Qc)*scalarDecode Qx Nx (a i) := by
  rw [coordinateTerms_eval]
  push_cast
  rw [Finset.sum_div]
  apply Finset.sum_congr rfl
  intro i hi
  unfold scalarDecode
  ring

def roundedCoefficients {d : ℕ} (c : Fin d → ℝ) (Q : ℕ) : Fin d → ℤ :=
  fun i => round ((Q:ℝ)*c i)

def ridgeTerms {d : ℕ} (c : Fin d → ℝ) (Q Nx : ℕ) :
    List (Fin (d*Fintype.card (ScalarGrid Q Nx)) × ℤ) :=
  coordinateTerms (roundedCoefficients c Q) (scalarNumerator Q Nx)

def roundedRidgeCircuit {d : ℕ} (c : Fin d → ℝ) (a : ℝ) (Q Nx Qo : ℕ) :=
  roundedAffineCircuit (ridgeTerms c Q Nx) (normalizedTanh a) (Q*Q) Qo
    (integerWeight (ridgeTerms c Q Nx))

/-- Uniform numerical accuracy of the actual finite circuit, on one-hot
encodings of separately rounded real coordinates. -/
theorem roundedRidgeCircuit_error {d : ℕ} (c x : Fin d → ℝ) (a : ℝ)
    (Q Nc Nx Qo : ℕ) (hQ : 0 < Q) (hQo : 0 < Qo)
    (hc : ∀ i, |c i| ≤ (Nc:ℝ)) (hx : ∀ i, |x i| ≤ (Nx:ℝ)) :
    |normalizedTanh a (∑ i, c i*x i) -
      decodeScalarState Qo (integerWeight (ridgeTerms c Q Nx))
        ((roundedRidgeCircuit c a Q Nx Qo).eval
          (oneHotState (fun i => scalarEncode Q Nx (x i))))| ≤
      (d:ℝ)*(1/(2*(Q:ℝ)))*((Nc:ℝ)+Nx+1/(2*(Q:ℝ))) + 1/(2*(Qo:ℝ)) := by
  let codes := fun i => scalarEncode Q Nx (x i)
  have heval := roundedNormalizedTanh_error (ridgeTerms c Q Nx) a (Q*Q) Qo
    (Nat.mul_pos hQ hQ) hQo (oneHotState codes)
  have hdecode := coordinateTerms_decode (roundedCoefficients c Q) Q Q Nx codes
  change (integerValue (ridgeTerms c Q Nx) (oneHotState codes):ℝ)/(Q*Q:ℕ) =
    ∑ i, ((roundedCoefficients c Q i:ℝ)/Q)*scalarDecode Q Nx (codes i) at hdecode
  have hsum : (integerValue (ridgeTerms c Q Nx) (oneHotState codes):ℝ)/(Q*Q:ℕ) =
      ∑ i, gridRound Q (c i)*gridRound Q (x i) := by
    rw [hdecode]
    apply Finset.sum_congr rfl
    intro i hi
    rw [show scalarDecode Q Nx (codes i) = gridRound Q (x i) from scalarDecode_encode Q Nx (x i) (hx i)]
    rfl
  have herr := affine_perturbation c (fun i => gridRound Q (c i)) x (fun i => gridRound Q (x i))
    Nc Nx (1/(2*(Q:ℝ))) (Nat.cast_nonneg _) (Nat.cast_nonneg _) (by positivity)
    hc hx (fun i => gridRound_error Q hQ (c i)) (fun i => gridRound_error Q hQ (x i))
  simp only [Fintype.card_fin] at herr
  have hL := normalizedTanh_lipschitz a (∑ i, c i*x i) (∑ i, gridRound Q (c i)*gridRound Q (x i))
  rw [hsum] at heval
  have htri := abs_sub_le (normalizedTanh a (∑ i, c i*x i))
    (normalizedTanh a (∑ i, gridRound Q (c i)*gridRound Q (x i)))
    (decodeScalarState Qo (integerWeight (ridgeTerms c Q Nx))
      ((roundedRidgeCircuit c a Q Nx Qo).eval (oneHotState codes)))
  change |normalizedTanh a (∑ i, c i*x i) -
      decodeScalarState Qo (integerWeight (ridgeTerms c Q Nx))
        ((roundedRidgeCircuit c a Q Nx Qo).eval (oneHotState codes))| ≤ _
  dsimp only [roundedRidgeCircuit] at htri ⊢
  linarith

lemma roundedCoefficients_bound {d : ℕ} (c : Fin d → ℝ) (Q Nc : ℕ)
    (hc : ∀ i, |c i| ≤ (Nc:ℝ)) (i : Fin d) :
    (roundedCoefficients c Q i).natAbs ≤ Q*Nc+1 := by
  have hh : |roundedCoefficients c Q i| ≤ ((Q*Nc+1:ℕ):ℤ) :=
    abs_le.mpr (Finset.mem_Icc.mp (round_mem_scalarGrid Q Nc (c i) (hc i)))
  rw [← Int.natCast_natAbs] at hh
  exact_mod_cast hh

theorem ridgeTerms_weight {d : ℕ} (c : Fin d → ℝ) (Q Nc Nx : ℕ)
    (hc : ∀ i, |c i| ≤ (Nc:ℝ)) :
    integerWeight (ridgeTerms c Q Nx) ≤
      (d*(2*(Q*Nx+1)+1))*((Q*Nc+1)*(Q*Nx+1)) := by
  simpa only [ridgeTerms, scalarGrid_card] using coordinateTerms_weight (roundedCoefficients c Q)
    (scalarNumerator Q Nx) (Q*Nc+1) (Q*Nx+1) (roundedCoefficients_bound c Q Nc hc)
    (scalarNumerator_bound Q Nx)

theorem roundedRidgeCircuit_depth {d : ℕ} (c : Fin d → ℝ) (a : ℝ) (Q Nx Qo : ℕ) :
    (roundedRidgeCircuit c a Q Nx Qo).depth ≤ 5 := roundedAffineCircuit_depth _ _ _ _ _

/-- Size is polynomial in total rounded affine weight and output precision,
while the independent theorem `ridgeTerms_weight` bounds that weight polynomially. -/
theorem roundedRidgeCircuit_size {d : ℕ} (c : Fin d → ℝ) (a : ℝ) (Q Nx Qo : ℕ) :
    let W := integerWeight (ridgeTerms c Q Nx)
    (roundedRidgeCircuit c a Q Nx Qo).size ≤
      (2*(Qo*W+1)+1)*((8*W+9)*(2*W+1)+1) := roundedAffineCircuit_size _ _ _ _ _

#print axioms roundedRidgeCircuit_error
#print axioms ridgeTerms_weight
#print axioms roundedRidgeCircuit_size
#print axioms roundedRidgeCircuit_depth
end ConditionalNonpolynomial.AnalyticLookup
