import ArithmeticReindex
import ArithmeticPrecision
import CircuitPipeline

/-! Actual finite arithmetic programs with compositional threshold compilers. -/
noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic

inductive ArithmeticProgram : ℕ→ℕ→Type
  | nil (d : ℕ) : ArithmeticProgram d d
  | cons {d m o : ℕ} (A : ArithmeticLayer (Fin d) (Fin m))
      (P : ArithmeticProgram m o) : ArithmeticProgram d o

namespace ArithmeticProgram
variable {d m o : ℕ}
def length : {d o : ℕ}→ArithmeticProgram d o→ℕ
  | _,_,.nil _=>0
  | _,_,.cons _ P=>P.length+1

def eval : {d o : ℕ}→ArithmeticProgram d o→(Fin d→ℝ)→(Fin o→ℝ)
  | _,_,.nil _,x=>x
  | _,_,.cons A P,x=>P.eval (A.eval x)

def append : {d m o : ℕ}→ArithmeticProgram d m→ArithmeticProgram m o→ArithmeticProgram d o
  | _,_,_,.nil _,R=>R
  | _,_,_,.cons A T,R=>.cons A (T.append R)

@[simp] theorem eval_then (P : ArithmeticProgram d m) (R : ArithmeticProgram m o) (x : Fin d→ℝ) :
    (P.append R).eval x=R.eval (P.eval x) := by
  induction P with
  | nil _=>rfl
  | cons A T ih=>exact ih R (A.eval x)

@[simp] theorem length_then (P : ArithmeticProgram d m) (R : ArithmeticProgram m o) :
    (P.append R).length=P.length+R.length := by
  induction P with
  | nil _=>simp [append,length]
  | cons A T ih=>simp [append,length,ih];omega

def bounded (B : ℕ) : {d o : ℕ}→ArithmeticProgram d o→Prop
  | _,_,.nil _=>True
  | _,_,.cons A P=>(∀j i,|A.coefficients j i|≤(B:ℝ)) ∧ P.bounded B

def outputRange : {d o : ℕ}→ArithmeticProgram d o→ℕ→ℕ→ℕ
  | _,_,.nil _,_,N=>N
  | d,_,.cons _ P,B,N=>P.outputRange B (layerNextRange d B N)

def compile : {d o : ℕ}→(P : ArithmeticProgram d o)→(Q B N : ℕ)→
    CircuitMap (d*Fintype.card (ScalarGrid Q N))
      (o*Fintype.card (ScalarGrid Q (P.outputRange B N)))
  | _,_,.nil _,_,_,_=>CircuitMap.identity _
  | d,_,.cons A T,Q,B,N=>(quantizedLayer A.coefficients (fun j=>(A.operations j).eval) Q N
      (layerNextRange d B N)).then (T.compile Q B (layerNextRange d B N))

def gridEval : {d o : ℕ}→(P : ArithmeticProgram d o)→(Q B N : ℕ)→
    (Fin d→ScalarCode Q N)→Fin o→ScalarCode Q (P.outputRange B N)
  | _,_,.nil _,_,_,_,a=>a
  | d,_,.cons A T,Q,B,N,a=>T.gridEval Q B (layerNextRange d B N)
      (quantizedUpdate A.coefficients (fun j=>(A.operations j).eval) Q N (layerNextRange d B N) a)

@[simp] theorem compile_eval (P : ArithmeticProgram d o) (Q B N : ℕ)
    (a : Fin d→ScalarCode Q N) :
    (P.compile Q B N).eval (oneHotState a)=oneHotState (P.gridEval Q B N a) := by
  induction P generalizing N with
  | nil _=>exact CircuitMap.eval_identity _ _
  | cons A T ih=>
    simp only [compile,gridEval,CircuitMap.eval_then,quantizedLayer_eval]
    exact ih _ _

theorem compile_depth (P : ArithmeticProgram d o) (Q B N : ℕ) :
    (P.compile Q B N).depth≤5*P.length := by
  induction P generalizing N with
  | nil _=>exact le_of_eq (CircuitMap.depth_identity _)
  | @cons di mi oi A T ih=>
    have hs:=CircuitMap.depth_then (quantizedLayer A.coefficients (fun j=>(A.operations j).eval) Q N
      (layerNextRange di B N)) (T.compile Q B (layerNextRange di B N))
    have ha:=quantizedLayer_depth A.coefficients (fun j=>(A.operations j).eval) Q N (layerNextRange di B N)
    have ht:=ih (layerNextRange di B N)
    exact hs.trans ((add_le_add ha ht).trans_eq (by simp only [length];omega))

def sizeBudget : {d o : ℕ}→ArithmeticProgram d o→ℕ→ℕ→ℕ→ℕ
  | _,_,.nil _,_,_,_=>0
  | d,_,@cons _ m _ _ T,Q,B,N=>arithmeticLayerSize d m Q B N (layerNextRange d B N)+
      T.sizeBudget Q B (layerNextRange d B N)

theorem compile_size (P : ArithmeticProgram d o) (Q B N : ℕ) (hP : P.bounded B) :
    (P.compile Q B N).size≤P.sizeBudget Q B N := by
  induction P generalizing N with
  | nil _=>exact le_of_eq (CircuitMap.size_identity _)
  | cons A T ih=>
    rw [compile,CircuitMap.size_then]
    exact add_le_add (quantizedLayer_size _ _ Q B N _ hP.1) (ih _ hP.2)

theorem eval_range (P : ArithmeticProgram d o) (B N : ℕ) (hP : P.bounded B)
    (x : Fin d→ℝ) (hx : ∀i,|x i|≤(N:ℝ)) : ∀j,|P.eval x j|≤(P.outputRange B N:ℝ) := by
  induction P generalizing N with
  | nil _=>exact hx
  | cons A T ih=>
    exact ih (layerNextRange _ B N) hP.2 _
      (finiteArithmeticLayer_range A B N _ hP.1 x hx le_rfl)

def error : {d o : ℕ}→ArithmeticProgram d o→ℕ→ℕ→ℕ→ℝ→ℝ
  | _,_,.nil _,_,_,_,η=>η
  | d,_,.cons _ T,Q,B,N,η=>T.error Q B (layerNextRange d B N) (layerError d Q B N η)

theorem accuracy (P : ArithmeticProgram d o) (Q B N : ℕ) (hQ : 0<Q) (hP : P.bounded B)
    (x : Fin d→ℝ) (hx : ∀i,|x i|≤(N:ℝ)) (a : Fin d→ScalarCode Q N) {η : ℝ}
    (hη : 0≤η) (hp : 1/(2*(Q:ℝ))≤η)
    (ha : ∀i,|x i-scalarDecode Q N (a i)|≤η) :
    ∀j,|P.eval x j-scalarDecode Q (P.outputRange B N) (P.gridEval Q B N a j)|≤P.error Q B N η := by
  induction P generalizing N η with
  | nil _=>exact ha
  | cons A T ih=>
    apply ih (layerNextRange _ B N) hP.2 (A.eval x)
      (finiteArithmeticLayer_range A B N _ hP.1 x hx le_rfl)
      (quantizedUpdate A.coefficients (fun j=>(A.operations j).eval) Q N _ a)
      (layerError_nonneg _ _ _ _ hη) (layerError_precision _ _ _ _ hη)
    exact instructionLayer_accuracy _ _ Q B N _ hQ hP.1 x hx a η hη hp ha le_rfl

end ArithmeticProgram
#print axioms ArithmeticProgram.accuracy
#print axioms ArithmeticProgram.compile_size
end ConditionalNonpolynomial.AnalyticLookup
