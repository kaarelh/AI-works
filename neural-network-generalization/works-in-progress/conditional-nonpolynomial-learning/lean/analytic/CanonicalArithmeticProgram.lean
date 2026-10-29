import ArithmeticPrimitives
import Mathlib.Algebra.BigOperators.Fin

/-! The selected-node canonical approximation is literally a five-layer
real arithmetic program using only the compiled scalar instructions. -/
noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic

structure ArithmeticLayer (ι κ : Type*) where
  coefficients : κ → ι → ℝ
  operations : κ → ScalarInstruction

def ArithmeticLayer.eval {ι κ : Type*} [Fintype ι] (a : ArithmeticLayer ι κ)
    (x : ι → ℝ) : κ → ℝ := fun j => (a.operations j).eval (∑ i, a.coefficients j i*x i)

def selectCoefficient {ι : Type*} [DecidableEq ι] (j i : ι) : ℝ := if i=j then 1 else 0

@[simp] theorem sum_selectCoefficient {ι : Type*} [Fintype ι] [DecidableEq ι]
    (j : ι) (x : ι → ℝ) : (∑ i, selectCoefficient j i*x i)=x j := by
  simp [selectCoefficient]

def ridgeArithmeticLayer {d n : ℕ} (w : Fin n → Fin d → ℝ) (scale : Fin n → ℝ) :
    ArithmeticLayer (Fin d) (Fin n) :=
  ⟨w, fun j => .normalizedTanh (scale j)⟩

def ridgeSquareLayer (n : ℕ) : ArithmeticLayer (Fin n) (Fin n ⊕ Fin n) where
  coefficients := fun j => selectCoefficient (Sum.elim id id j)
  operations := Sum.elim (fun _ => .identity) (fun _ => .square)

def projectionArithmeticLayer {n m : ℕ} (A : Fin m → Fin n → ℝ) (b : Fin n → ℝ) :
    ArithmeticLayer (Fin n ⊕ Fin n) (Fin m ⊕ Unit) where
  coefficients := fun j i => match j,i with
    | .inl l, .inl r => A l r
    | .inr _, .inr r => b r
    | _,_ => 0
  operations := fun _ => .identity

def projectionSquareLayer (m : ℕ) :
    ArithmeticLayer (Fin m ⊕ Unit) (Fin m ⊕ (Fin m ⊕ Unit)) where
  coefficients := fun j => selectCoefficient (match j with
    | .inl l => .inl l
    | .inr (.inl l) => .inl l
    | .inr (.inr u) => .inr u)
  operations := fun j => match j with
    | .inr (.inl _) => .square
    | _ => .identity

def completionArithmeticLayer (m : ℕ) :
    ArithmeticLayer (Fin m ⊕ (Fin m ⊕ Unit)) (Fin m ⊕ Unit) where
  coefficients := fun j i => match j with
    | .inl l => selectCoefficient (.inl l) i
    | .inr _ => match i with
      | .inl _ => 0
      | .inr (.inl _) => -1
      | .inr (.inr _) => 1
  operations := Sum.elim (fun _ => .identity) (fun _ => .clippedSqrt)

def canonicalArithmeticProgram {d n m : ℕ} (w : Fin n → Fin d → ℝ)
    (scale : Fin n → ℝ) (A : Fin m → Fin n → ℝ) (b : Fin n → ℝ)
    (v : Fin d → ℝ) : (Fin m ⊕ Unit) → ℝ :=
  (completionArithmeticLayer m).eval ((projectionSquareLayer m).eval
    ((projectionArithmeticLayer A b).eval ((ridgeSquareLayer n).eval
      ((ridgeArithmeticLayer w scale).eval v))))

def finiteRidgeValues {d n : ℕ} (w : Fin n → Fin d → ℝ) (scale : Fin n → ℝ)
    (v : Fin d → ℝ) : Fin n → ℝ := fun j => normalizedTanh (scale j) (∑ i, w j i*v i)

@[simp] theorem ridgeArithmeticLayer_eval {d n : ℕ} (w : Fin n → Fin d → ℝ)
    (scale : Fin n → ℝ) (v : Fin d → ℝ) :
    (ridgeArithmeticLayer w scale).eval v = finiteRidgeValues w scale v := rfl

@[simp] theorem ridgeSquareLayer_eval_left {n : ℕ} (x : Fin n → ℝ) (j : Fin n) :
    (ridgeSquareLayer n).eval x (.inl j) = x j := by
  simp [ArithmeticLayer.eval, ridgeSquareLayer, ScalarInstruction.eval]

@[simp] theorem ridgeSquareLayer_eval_right {n : ℕ} (x : Fin n → ℝ) (j : Fin n) :
    (ridgeSquareLayer n).eval x (.inr j) = (x j)^2 := by
  simp [ArithmeticLayer.eval, ridgeSquareLayer, ScalarInstruction.eval]

@[simp] theorem projectionArithmeticLayer_eval_left {n m : ℕ} (A : Fin m → Fin n → ℝ)
    (b : Fin n → ℝ) (x : (Fin n ⊕ Fin n) → ℝ) (j : Fin m) :
    (projectionArithmeticLayer A b).eval x (.inl j) = ∑ i, A j i*x (.inl i) := by
  simp [ArithmeticLayer.eval, projectionArithmeticLayer, ScalarInstruction.eval, Fintype.sum_sum_type]

@[simp] theorem projectionArithmeticLayer_eval_right {n m : ℕ} (A : Fin m → Fin n → ℝ)
    (b : Fin n → ℝ) (x : (Fin n ⊕ Fin n) → ℝ) :
    (projectionArithmeticLayer A b).eval x (.inr ()) = ∑ i, b i*x (.inr i) := by
  simp [ArithmeticLayer.eval, projectionArithmeticLayer, ScalarInstruction.eval, Fintype.sum_sum_type]

@[simp] theorem projectionSquareLayer_eval_left {m : ℕ} (x : (Fin m ⊕ Unit) → ℝ) (j : Fin m) :
    (projectionSquareLayer m).eval x (.inl j) = x (.inl j) := by
  simp [ArithmeticLayer.eval, projectionSquareLayer, ScalarInstruction.eval]

@[simp] theorem projectionSquareLayer_eval_square {m : ℕ} (x : (Fin m ⊕ Unit) → ℝ) (j : Fin m) :
    (projectionSquareLayer m).eval x (.inr (.inl j)) = (x (.inl j))^2 := by
  simp [ArithmeticLayer.eval, projectionSquareLayer, ScalarInstruction.eval]

@[simp] theorem projectionSquareLayer_eval_norm {m : ℕ} (x : (Fin m ⊕ Unit) → ℝ) :
    (projectionSquareLayer m).eval x (.inr (.inr ())) = x (.inr ()) := by
  simp [ArithmeticLayer.eval, projectionSquareLayer, ScalarInstruction.eval]

@[simp] theorem completionArithmeticLayer_eval_left {m : ℕ}
    (x : (Fin m ⊕ (Fin m ⊕ Unit)) → ℝ) (j : Fin m) :
    (completionArithmeticLayer m).eval x (.inl j) = x (.inl j) := by
  simp [ArithmeticLayer.eval, completionArithmeticLayer, ScalarInstruction.eval]

@[simp] theorem completionArithmeticLayer_eval_right {m : ℕ}
    (x : (Fin m ⊕ (Fin m ⊕ Unit)) → ℝ) :
    (completionArithmeticLayer m).eval x (.inr ()) =
      Real.sqrt (max 0 (x (.inr (.inr ()))-∑ i, x (.inr (.inl i)))) := by
  simp [ArithmeticLayer.eval, completionArithmeticLayer, ScalarInstruction.eval, Fintype.sum_sum_type,
    Finset.sum_neg_distrib, sub_eq_add_neg, add_comm]

/-- Exact projection coordinates of the finite quadrature program. -/
theorem canonicalArithmeticProgram_projection {d n m : ℕ} (w : Fin n → Fin d → ℝ)
    (scale : Fin n → ℝ) (A : Fin m → Fin n → ℝ) (b : Fin n → ℝ)
    (v : Fin d → ℝ) (j : Fin m) :
    canonicalArithmeticProgram w scale A b v (.inl j) =
      ∑ i, A j i*finiteRidgeValues w scale v i := by
  simp [canonicalArithmeticProgram]

/-- Exact clipped square-root coordinate of the finite quadrature program. -/
theorem canonicalArithmeticProgram_residual {d n m : ℕ} (w : Fin n → Fin d → ℝ)
    (scale : Fin n → ℝ) (A : Fin m → Fin n → ℝ) (b : Fin n → ℝ)
    (v : Fin d → ℝ) :
    canonicalArithmeticProgram w scale A b v (.inr ()) =
      Real.sqrt (max 0 ((∑ i, b i*(finiteRidgeValues w scale v i)^2)-
        ∑ j, (∑ i, A j i*finiteRidgeValues w scale v i)^2)) := by
  simp [canonicalArithmeticProgram]

#print axioms canonicalArithmeticProgram_projection
#print axioms canonicalArithmeticProgram_residual
end ConditionalNonpolynomial.Analytic
