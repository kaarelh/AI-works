import ArithmeticRunCompiler

noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic

variable {ι κ : Type*} [Fintype ι] [Fintype κ]

def realCoordinates (x : ι → ℝ) : Fin (Fintype.card ι) → ℝ :=
  fun i => x ((Fintype.equivFin ι).symm i)

def finArithmeticLayer (L : ArithmeticLayer ι κ) :
    ArithmeticLayer (Fin (Fintype.card ι)) (Fin (Fintype.card κ)) where
  coefficients := fun j i => L.coefficients ((Fintype.equivFin κ).symm j) ((Fintype.equivFin ι).symm i)
  operations := fun j => L.operations ((Fintype.equivFin κ).symm j)

@[simp] theorem finArithmeticLayer_eval (L : ArithmeticLayer ι κ) (x : ι → ℝ) :
    (finArithmeticLayer L).eval (realCoordinates x) = realCoordinates (L.eval x) := by
  funext j
  simp only [ArithmeticLayer.eval, finArithmeticLayer, realCoordinates]
  rw [sum_equivFin_symm (fun i => L.coefficients ((Fintype.equivFin κ).symm j) i*x i)]

@[simp] theorem finArithmeticLayer_update (L : ArithmeticLayer ι κ) (Q Ni No : ℕ)
    (a : ι → ScalarCode Q Ni) :
    quantizedUpdate (finArithmeticLayer L).coefficients
      (fun j => ((finArithmeticLayer L).operations j).eval) Q Ni No (coordinateCodes Q Ni a) =
      coordinateCodes Q No (updateArithmeticLayer L Q Ni No a) := by
  funext j
  simp only [quantizedUpdate,finArithmeticLayer,coordinateCodes,updateArithmeticLayer]
  rw [sum_equivFin_symm (fun i => gridRound Q (L.coefficients ((Fintype.equivFin κ).symm j) i)*scalarDecode Q Ni (a i))]

variable (X : ℕ → Type*) [∀ j, Fintype (X j)]
variable (A : ∀ j, ArithmeticLayer (X j) (X (j+1)))

def finiteExactRun (x : X 0 → ℝ) : (h : ℕ) → X h → ℝ
  | 0 => x
  | h+1 => (A h).eval (finiteExactRun x h)

def finiteGridRun (Q : ℕ) (N : ℕ → ℕ) (a : X 0 → ScalarCode Q (N 0)) :
    (h : ℕ) → X h → ScalarCode Q (N h)
  | 0 => a
  | h+1 => updateArithmeticLayer (A h) Q (N h) (N (h+1)) (finiteGridRun Q N a h)

@[simp] theorem finiteExactRun_toFin (x : X 0 → ℝ) (h : ℕ) :
    exactArithmeticRun (fun j=>Fintype.card (X j)) (fun j=>finArithmeticLayer (A j)) (realCoordinates x) h =
      realCoordinates (finiteExactRun X A x h) := by
  induction h with
  | zero => rfl
  | succ h ih => simp only [exactArithmeticRun,finiteExactRun,ih,finArithmeticLayer_eval]

@[simp] theorem finiteGridRun_toFin (Q : ℕ) (N : ℕ → ℕ)
    (a : X 0 → ScalarCode Q (N 0)) (h : ℕ) :
    gridArithmeticRun (fun j=>Fintype.card (X j)) (fun j=>finArithmeticLayer (A j)) Q N
      (coordinateCodes Q (N 0) a) h = coordinateCodes Q (N h) (finiteGridRun X A Q N a h) := by
  induction h with
  | zero => rfl
  | succ h ih => simp only [gridArithmeticRun,finiteGridRun,ih,finArithmeticLayer_update]

def compileFiniteRun (Q : ℕ) (N : ℕ → ℕ) (h : ℕ) :=
  compileArithmeticRun (fun j=>Fintype.card (X j)) (fun j=>finArithmeticLayer (A j)) Q N h

@[simp] theorem compileFiniteRun_eval (Q : ℕ) (N : ℕ → ℕ)
    (a : X 0 → ScalarCode Q (N 0)) (h : ℕ) :
    (compileFiniteRun X A Q N h).eval (encodeCoordinateState Q (N 0) a) =
      encodeCoordinateState Q (N h) (finiteGridRun X A Q N a h) := by
  simp only [compileFiniteRun,encodeCoordinateState,compileArithmeticRun_eval,finiteGridRun_toFin]

theorem compileFiniteRun_depth (Q : ℕ) (N : ℕ → ℕ) (h : ℕ) :
    (compileFiniteRun X A Q N h).depth≤5*h := compileArithmeticRun_depth _ _ _ _ _

theorem finiteRun_accuracy (Q B : ℕ) (N : ℕ → ℕ) (hQ : 0<Q)
    (hc : ∀ h j i, |(A h).coefficients j i| ≤ (B:ℝ))
    (hN : ∀ h, layerNextRange (Fintype.card (X h)) B (N h)≤N (h+1))
    (x : X 0 → ℝ) (hx : ∀i,|x i|≤(N 0:ℝ)) (h : ℕ) (j : X h) :
    |finiteExactRun X A x h j - scalarDecode Q (N h)
      (finiteGridRun X A Q N (fun i=>scalarEncode Q (N 0) (x i)) h j)| ≤
      arithmeticRunError (fun j=>Fintype.card (X j)) Q N B h := by
  have hh := arithmeticRun_accuracy (fun j=>Fintype.card (X j))
    (fun j=>finArithmeticLayer (A j)) Q N B hQ (fun h j i=>hc h _ _) hN
    (realCoordinates x) (fun i=>hx _) h (Fintype.equivFin (X h) j)
  change |exactArithmeticRun (fun j=>Fintype.card (X j)) (fun j=>finArithmeticLayer (A j)) (realCoordinates x) h (Fintype.equivFin (X h) j)-
    scalarDecode Q (N h) (gridArithmeticRun (fun j=>Fintype.card (X j)) (fun j=>finArithmeticLayer (A j)) Q N
      (coordinateCodes Q (N 0) (fun i=>scalarEncode Q (N 0) (x i))) h (Fintype.equivFin (X h) j))|≤_ at hh
  simpa only [finiteExactRun_toFin,finiteGridRun_toFin,realCoordinates,coordinateCodes,
    Equiv.symm_apply_apply] using hh

#print axioms finiteRun_accuracy
end ConditionalNonpolynomial.AnalyticLookup
