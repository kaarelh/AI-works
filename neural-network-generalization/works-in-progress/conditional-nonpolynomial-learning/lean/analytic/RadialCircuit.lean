import RadialArithmeticProgram

/-! The actual threshold DAG for radial clipping, of depth at most 30.
Its precision and size are independent of any Gaussian density description. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic

 def radialCoordinates (d : ℕ) : ℕ→Type
  | 0=>Fin d
  | 1=>Fin d⊕Fin d
  | 2=>Fin d⊕Unit
  | 3=>Fin d⊕Unit
  | 4=>Fin d⊕Fin d
  | 5=>Fin d⊕Fin d
  | _=>Fin d

instance radialCoordinates_fintype (d h : ℕ) : Fintype (radialCoordinates d h) := by
  unfold radialCoordinates
  split <;> infer_instance

instance radialCoordinates_decidableEq (d h : ℕ) : DecidableEq (radialCoordinates d h) := by
  unfold radialCoordinates
  split <;> infer_instance

 def radialLayers (d : ℕ) (s : ℝ) :
    (h : ℕ)→ArithmeticLayer (radialCoordinates d h) (radialCoordinates d (h+1))
  | 0=>ridgeSquareLayer d
  | 1=>radialNormLayer d
  | 2=>radialFactorLayer d s
  | 3=>radialProductInput d
  | 4=>squareArithmeticLayer (Fin d⊕Fin d)
  | 5=>radialProductOutput d
  | _+6=>identityArithmeticLayer (Fin d)

@[simp] theorem radialLayers_exact (d : ℕ) (s : ℝ) (x : Fin d→ℝ) :
    finiteExactRun (radialCoordinates d) (radialLayers d s) x 6=radialArithmeticProgram s x := rfl

 theorem radialLayers_coefficients (d : ℕ) (s : ℝ) (B : ℕ) (hB : 1≤B)
    (hsB : (s⁻¹)^2≤(B:ℝ)) :
    ∀h j i,|((radialLayers d s) h).coefficients j i|≤(B:ℝ) := by
  have hBreal : (1:ℝ)≤B := by exact_mod_cast hB
  intro h
  match h with
  | 0 => intro j i; exact (selectCoefficient_bound _ _).trans hBreal
  | 1 =>
    rintro (j | ⟨⟩) i
    · exact (selectCoefficient_bound _ _).trans hBreal
    · cases i <;> exact (by norm_num [radialLayers,radialNormLayer] : _≤(1:ℝ)).trans hBreal
  | 2 =>
    rintro (j | ⟨⟩) i
    · exact (selectCoefficient_bound _ _).trans hBreal
    · change |(s⁻¹)^2*selectCoefficient (.inr ()) i|≤(B:ℝ)
      unfold selectCoefficient
      split
      · simpa only [mul_one,abs_of_nonneg (sq_nonneg (s⁻¹))] using hsB
      · simp only [mul_zero,abs_zero]
        exact Nat.cast_nonneg _
  | 3 =>
    rintro (j | j) (i | ⟨⟩)
    · exact (selectCoefficient_bound _ _).trans hBreal
    · exact (by norm_num [radialLayers,radialProductInput] : _≤(1:ℝ)).trans hBreal
    · exact (selectCoefficient_bound _ _).trans hBreal
    · exact (by norm_num [radialLayers,radialProductInput] : _≤(1:ℝ)).trans hBreal
  | 4 => intro j i; exact (selectCoefficient_bound _ _).trans hBreal
  | 5 =>
    intro j i
    cases i <;> simp only [radialLayers,radialProductOutput,selectCoefficient] <;>
      split <;> norm_num <;> linarith
  | h+6 => intro j i; exact (selectCoefficient_bound _ _).trans hBreal

 def radialCircuit (d : ℕ) (s : ℝ) (Q : ℕ) (N : ℕ→ℕ) :=
  compileFiniteRun (radialCoordinates d) (radialLayers d s) Q N 6

 theorem radialCircuit_depth (d : ℕ) (s : ℝ) (Q : ℕ) (N : ℕ→ℕ) :
    (radialCircuit d s Q N).depth≤30 := compileFiniteRun_depth _ _ _ _ 6

 theorem radialCircuit_size (d : ℕ) (s : ℝ) (Q B : ℕ) (N : ℕ→ℕ)
    (hB : 1≤B) (hsB : (s⁻¹)^2≤(B:ℝ)) :
    (radialCircuit d s Q N).size≤∑j∈Finset.range 6,
      arithmeticLayerSize (Fintype.card (radialCoordinates d j))
        (Fintype.card (radialCoordinates d (j+1))) Q B (N j) (N (j+1)) :=
  compileArithmeticRun_size _ _ _ _ B (fun h j i=>radialLayers_coefficients d s B hB hsB h _ _) 6

 lemma precisionBudget_six (K ε : ℝ) : precisionBudget K ε 6=ε^64/K^126 := by
  simp only [precisionBudget]
  ring

 theorem sixLayer_polynomial_precision (d : ℕ→ℕ) (Q B : ℕ) (N : ℕ→ℕ)
    {K ε : ℝ} (hK : 1≤K) (hε : 0<ε) (hεone : ε≤1)
    (hamp : ∀j<6,(layerAmplification (d j) B (N j):ℝ)≤K)
    (hQ : K^126≤2*(Q:ℝ)*ε^64) : arithmeticRunError d Q N B 6≤ε := by
  apply arithmeticRunError_precision_bound d Q B N hK hε.le hεone 6 hamp
  rw [precisionBudget_six]
  have hKpos : 0<K := by linarith
  have hQpos : 0<(Q:ℝ) := by
    have hp : 0<K^126 := pow_pos hKpos _
    by_contra hn
    have hnon : (Q:ℝ)≤0 := le_of_not_gt hn
    have hmul := mul_nonpos_of_nonpos_of_nonneg (by linarith : 2*(Q:ℝ)≤0) (pow_nonneg hε.le 64)
    linarith
  apply (div_le_div_iff₀ (by positivity : 0<2*(Q:ℝ)) (pow_pos hKpos 126)).mpr
  nlinarith

/-- Actual encoded finite outputs of the depth-30 circuit approximate radial
clipping uniformly on the full cube, under an explicit polynomial mesh. -/
theorem radialCircuit_accuracy (d : ℕ) (s : ℝ) (hs : 0<s) (Q B U : ℕ) (hQ : 0<Q)
    (hB : 1≤B) (hsB : (s⁻¹)^2≤(B:ℝ)) {K ε : ℝ}
    (hK : 1≤K) (hε : 0<ε) (hεone : ε≤1)
    (hamp : ∀j<6,(layerAmplification (Fintype.card (radialCoordinates d j)) B
      (arithmeticRanges (fun j=>Fintype.card (radialCoordinates d j)) B U j):ℝ)≤K)
    (hmesh : K^126≤2*(Q:ℝ)*ε^64)
    (x : EuclideanSpace ℝ (Fin d)) (hx : ∀i,|x i|≤(U:ℝ)) :
    let N := arithmeticRanges (fun j=>Fintype.card (radialCoordinates d j)) B U
    ∃a:Fin d→ScalarCode Q (N 6),
      (radialCircuit d s Q N).eval (encodeCoordinateState Q U (fun i=>scalarEncode Q U (x i)))=
        encodeCoordinateState Q (N 6) a ∧
      ∀j,|(s/max s ‖x‖)*x j-scalarDecode Q (N 6) (a j)|≤ε := by
  dsimp only
  let dims := fun j=>Fintype.card (radialCoordinates d j)
  let N := arithmeticRanges dims B U
  refine ⟨finiteGridRun (radialCoordinates d) (radialLayers d s) Q N
    (fun i=>scalarEncode Q U (x i)) 6,?_,?_⟩
  · exact compileFiniteRun_eval _ _ _ _ _ _
  · intro j
    have he := finiteRun_accuracy (radialCoordinates d) (radialLayers d s) Q B N hQ
      (radialLayers_coefficients d s B hB hsB) (fun h=>le_rfl) (fun i=>x i) hx 6 j
    erw [radialLayers_exact,radialArithmeticProgram_is_projection s hs x j] at he
    exact he.trans (sixLayer_polynomial_precision dims Q B N hK hε hεone hamp hmesh)

#print axioms radialCircuit_depth
#print axioms radialCircuit_accuracy
end ConditionalNonpolynomial.AnalyticLookup
