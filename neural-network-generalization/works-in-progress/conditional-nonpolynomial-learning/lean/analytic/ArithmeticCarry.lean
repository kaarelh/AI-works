import ArithmeticPrograms

noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic

def carryArithmeticLayer (c : ℕ) {d m : ℕ} (A : ArithmeticLayer (Fin d) (Fin m)) :
    ArithmeticLayer (Fin (c+d)) (Fin (c+m)) where
  coefficients := Fin.addCases
    (fun j=>Fin.addCases (fun i=>if i=j then (1:ℝ) else 0) (fun _=>0))
    (fun j=>Fin.addCases (fun _=>0) (A.coefficients j))
  operations := Fin.addCases (fun _=>.identity) A.operations

@[simp] theorem carryArithmeticLayer_eval (c : ℕ) {d m : ℕ}
    (A : ArithmeticLayer (Fin d) (Fin m)) (v : Fin c→ℝ) (x : Fin d→ℝ) :
    (carryArithmeticLayer c A).eval (Fin.addCases v x)=Fin.addCases v (A.eval x) := by
  funext j
  refine Fin.addCases (fun j=>?_) (fun j=>?_) j
  · simp [ArithmeticLayer.eval,carryArithmeticLayer,Fin.sum_univ_add,ScalarInstruction.eval]
  · simp [ArithmeticLayer.eval,carryArithmeticLayer,Fin.sum_univ_add]

theorem carryArithmeticLayer_bounded (c : ℕ) {d m : ℕ}
    (A : ArithmeticLayer (Fin d) (Fin m)) (B : ℕ) (hB : 1≤B)
    (hA : ∀j i,|A.coefficients j i|≤(B:ℝ)) :
    ∀j i,|(carryArithmeticLayer c A).coefficients j i|≤(B:ℝ) := by
  intro j i
  refine Fin.addCases (fun j=>?_) (fun j=>?_) j <;>
    refine Fin.addCases (fun i=>?_) (fun i=>?_) i
  · simp only [carryArithmeticLayer,Fin.addCases_left]
    split_ifs <;> norm_num <;> exact_mod_cast hB
  · simp [carryArithmeticLayer]
  · simp [carryArithmeticLayer]
  · simpa only [carryArithmeticLayer,Fin.addCases_right] using hA j i

namespace ArithmeticProgram

def carry (c : ℕ) : {d o : ℕ}→ArithmeticProgram d o→ArithmeticProgram (c+d) (c+o)
  | _,_,.nil _=>.nil _
  | _,_,.cons A P=>.cons (carryArithmeticLayer c A) (P.carry c)

@[simp] theorem carry_eval (c : ℕ) {d o : ℕ} (P : ArithmeticProgram d o)
    (v : Fin c→ℝ) (x : Fin d→ℝ) :
    (P.carry c).eval (Fin.addCases v x)=Fin.addCases v (P.eval x) := by
  induction P with
  | nil _=>rfl
  | cons A T ih=>simp only [carry,eval,carryArithmeticLayer_eval,ih]

@[simp] theorem carry_length (c : ℕ) {d o : ℕ} (P : ArithmeticProgram d o) :
    (P.carry c).length=P.length := by
  induction P with
  | nil _=>rfl
  | cons A T ih=>simp [carry,length,ih]

theorem carry_bounded (c : ℕ) {d o : ℕ} (P : ArithmeticProgram d o)
    (B : ℕ) (hB : 1≤B) (hP : P.bounded B) : (P.carry c).bounded B := by
  induction P with
  | nil _=>trivial
  | cons A T ih=>exact ⟨carryArithmeticLayer_bounded c A B hB hP.1,ih hP.2⟩

end ArithmeticProgram
#print axioms ArithmeticProgram.carry_eval
end ConditionalNonpolynomial.AnalyticLookup
