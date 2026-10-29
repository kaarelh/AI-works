import CanonicalArithmeticProgram

/-! Actual finite threshold circuits for arithmetic layers with arbitrary finite
coordinate types. Encoding is coordinatewise; the full state is never used as
a lookup-table index. -/
noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic

variable {ι κ : Type*} [Fintype ι] [Fintype κ]

def coordinateCodes (Q N : ℕ) (a : ι → ScalarCode Q N) :
    Fin (Fintype.card ι) → ScalarCode Q N := fun i => a ((Fintype.equivFin ι).symm i)

def encodeCoordinateState (Q N : ℕ) (a : ι → ScalarCode Q N) :=
  oneHotState (coordinateCodes Q N a)

def compileArithmeticLayer (L : ArithmeticLayer ι κ) (Q Ni No : ℕ) :=
  quantizedLayer
    (fun j i => L.coefficients ((Fintype.equivFin κ).symm j) ((Fintype.equivFin ι).symm i))
    (fun j => (L.operations ((Fintype.equivFin κ).symm j)).eval) Q Ni No

def updateArithmeticLayer (L : ArithmeticLayer ι κ) (Q Ni No : ℕ)
    (a : ι → ScalarCode Q Ni) : κ → ScalarCode Q No :=
  fun j => scalarEncode Q No ((L.operations j).eval
    (∑ i, gridRound Q (L.coefficients j i)*scalarDecode Q Ni (a i)))

lemma sum_equivFin_symm (f : ι → ℝ) :
    (∑ i : Fin (Fintype.card ι), f ((Fintype.equivFin ι).symm i)) = ∑ i, f i :=
  Equiv.sum_comp (Fintype.equivFin ι).symm f

@[simp] theorem compileArithmeticLayer_eval (L : ArithmeticLayer ι κ) (Q Ni No : ℕ)
    (a : ι → ScalarCode Q Ni) :
    (compileArithmeticLayer L Q Ni No).eval (encodeCoordinateState Q Ni a) =
      encodeCoordinateState Q No (updateArithmeticLayer L Q Ni No a) := by
  rw [compileArithmeticLayer, encodeCoordinateState, quantizedLayer_eval]
  congr 1
  funext j
  simp only [quantizedUpdate, coordinateCodes, updateArithmeticLayer]
  rw [sum_equivFin_symm (fun i => gridRound Q (L.coefficients ((Fintype.equivFin κ).symm j) i)*scalarDecode Q Ni (a i))]

theorem compileArithmeticLayer_depth (L : ArithmeticLayer ι κ) (Q Ni No : ℕ) :
    (compileArithmeticLayer L Q Ni No).depth ≤ 5 := quantizedLayer_depth _ _ _ _ _

def arithmeticLayerSize (di do' Q B Ni No : ℕ) : ℕ :=
  let qi := 2*(Q*Ni+1)+1
  let qo := 2*(Q*No+1)+1
  let W := (di*qi)*((Q*B+1)*(Q*Ni+1))
  (do'*qo)*(qo*((8*W+9)*(2*W+1)+1))

theorem compileArithmeticLayer_size (L : ArithmeticLayer ι κ) (Q B Ni No : ℕ)
    (hc : ∀ j i, |L.coefficients j i| ≤ (B:ℝ)) :
    (compileArithmeticLayer L Q Ni No).size ≤
      arithmeticLayerSize (Fintype.card ι) (Fintype.card κ) Q B Ni No := by
  exact quantizedLayer_size _ _ Q B Ni No (fun j i => hc _ _)

theorem compileArithmeticLayer_accuracy (L : ArithmeticLayer ι κ)
    (Q B Ni No : ℕ) (hQ : 0<Q) (hc : ∀ j i, |L.coefficients j i| ≤ (B:ℝ))
    (x : ι → ℝ) (hx : ∀ i, |x i| ≤ (Ni:ℝ))
    (a : ι → ScalarCode Q Ni) (η : ℝ) (hη : 0≤η)
    (hprecision : 1/(2*(Q:ℝ))≤η)
    (hinput : ∀ i, |x i-scalarDecode Q Ni (a i)|≤η)
    (hNo : (Fintype.card ι*(B+1)*(Ni+1)+1)^2+1≤No) (j : κ) :
    |L.eval x j-scalarDecode Q No (updateArithmeticLayer L Q Ni No a j)| ≤
      arithmeticModulus ((Fintype.card ι*(B+1)*(Ni+1)+1:ℕ):ℝ)
        ((Fintype.card ι:ℝ)*η*((B:ℝ)+Ni+η))+1/(2*(Q:ℝ)) := by
  have hh := instructionLayer_accuracy
    (fun j i => L.coefficients ((Fintype.equivFin κ).symm j) ((Fintype.equivFin ι).symm i))
    (fun j => L.operations ((Fintype.equivFin κ).symm j)) Q B Ni No hQ
    (fun j i => hc _ _) (fun i => x ((Fintype.equivFin ι).symm i))
    (fun i => hx _) (coordinateCodes Q Ni a) η hη hprecision (fun i => hinput _)
    hNo (Fintype.equivFin κ j)
  simp only [Equiv.symm_apply_apply, quantizedUpdate, coordinateCodes] at hh
  rw [sum_equivFin_symm (fun i => L.coefficients j i*x i),
    sum_equivFin_symm (fun i => gridRound Q (L.coefficients j i)*scalarDecode Q Ni (a i))] at hh
  exact hh

#print axioms compileArithmeticLayer_accuracy
#print axioms compileArithmeticLayer_size
end ConditionalNonpolynomial.AnalyticLookup
