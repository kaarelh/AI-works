import ArithmeticPrograms
import CanonicalCircuit
import RadialCircuit

noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic
namespace ArithmeticProgram

def single {d m : ℕ} (A : ArithmeticLayer (Fin d) (Fin m)) : ArithmeticProgram d m :=
  .cons A (.nil m)

@[simp] theorem single_eval {d m : ℕ} (A : ArithmeticLayer (Fin d) (Fin m)) (x : Fin d→ℝ) :
    (single A).eval x=A.eval x := rfl
@[simp] theorem single_length {d m : ℕ} (A : ArithmeticLayer (Fin d) (Fin m)) :
    (single A).length=1 := rfl

theorem append_bounded {d m o B : ℕ} {P : ArithmeticProgram d m} {R : ArithmeticProgram m o}
    (hP : P.bounded B) (hR : R.bounded B) : (P.append R).bounded B := by
  induction P with
  | nil _=>exact hR
  | cons A T ih=>exact ⟨hP.1,ih hP.2 hR⟩

variable (X : ℕ→Type) [∀j,Fintype (X j)] (A : ∀j,ArithmeticLayer (X j) (X (j+1)))

def fromRun : (h : ℕ)→ArithmeticProgram (Fintype.card (X 0)) (Fintype.card (X h))
  | 0=>.nil _
  | h+1=>(fromRun h).append (single (finArithmeticLayer (A h)))

@[simp] theorem fromRun_length (h : ℕ) : (fromRun X A h).length=h := by
  induction h with
  | zero=>rfl
  | succ h ih=>simp only [fromRun,length_then,single_length,ih]

@[simp] theorem fromRun_eval (h : ℕ) (x : X 0→ℝ) :
    (fromRun X A h).eval (realCoordinates x)=realCoordinates (finiteExactRun X A x h) := by
  induction h with
  | zero=>rfl
  | succ h ih=>simp only [fromRun,eval_then,single_eval,ih,finArithmeticLayer_eval,finiteExactRun]

theorem fromRun_bounded (B : ℕ) (hc : ∀h j i,|(A h).coefficients j i|≤(B:ℝ)) (h : ℕ) :
    (fromRun X A h).bounded B := by
  induction h with
  | zero=>trivial
  | succ h ih=>exact append_bounded ih ⟨fun j i=>hc h _ _, trivial⟩

end ArithmeticProgram

def canonicalProgramBlock {d n m : ℕ} (w : Fin n→Fin d→ℝ) (a : Fin n→ℝ)
    (A : Fin m→Fin n→ℝ) (b : Fin n→ℝ) :=
  ArithmeticProgram.fromRun (canonicalCoordinates d n m) (canonicalLayers w a A b) 5

@[simp] theorem canonicalProgramBlock_eval {d n m : ℕ} (w : Fin n→Fin d→ℝ) (a : Fin n→ℝ)
    (A : Fin m→Fin n→ℝ) (b : Fin n→ℝ) (x : Fin d→ℝ) :
    (canonicalProgramBlock w a A b).eval (realCoordinates x)=
      realCoordinates (canonicalArithmeticProgram w a A b x) := by
  rw [canonicalProgramBlock,ArithmeticProgram.fromRun_eval,canonicalLayers_exact]
  rfl

def radialProgramBlock (d : ℕ) (s : ℝ) :=
  ArithmeticProgram.fromRun (radialCoordinates d) (radialLayers d s) 6

@[simp] theorem radialProgramBlock_eval (d : ℕ) (s : ℝ) (x : Fin d→ℝ) :
    (radialProgramBlock d s).eval (realCoordinates x)=realCoordinates (radialArithmeticProgram s x) := by
  rw [radialProgramBlock,ArithmeticProgram.fromRun_eval,radialLayers_exact]
  rfl

#print axioms canonicalProgramBlock_eval
#print axioms radialProgramBlock_eval
end ConditionalNonpolynomial.AnalyticLookup
