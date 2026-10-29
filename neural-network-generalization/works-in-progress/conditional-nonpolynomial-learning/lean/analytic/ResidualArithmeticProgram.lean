import ArithmeticCarry
import ArithmeticProgramBlocks

/-! The actual clipped canonical residual evaluator is a fixed-length
arithmetic program. The input is preserved during canonical evaluation so
that the linear residual can be subtracted afterwards. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic

def matrixArithmeticLayer {d m : ℕ} (C : Fin m→Fin d→ℝ) : ArithmeticLayer (Fin d) (Fin m) :=
  ⟨C,fun _=>.identity⟩

@[simp] theorem matrixArithmeticLayer_eval {d m : ℕ} (C : Fin m→Fin d→ℝ) (x : Fin d→ℝ) :
    (matrixArithmeticLayer C).eval x=fun j=>∑i,C j i*x i := rfl

def duplicateArithmeticLayer (d : ℕ) : ArithmeticLayer (Fin d) (Fin (d+d)) :=
  matrixArithmeticLayer (Fin.addCases selectCoefficient selectCoefficient)

@[simp] theorem duplicateArithmeticLayer_eval (d : ℕ) (x : Fin d→ℝ) :
    (duplicateArithmeticLayer d).eval x=Fin.addCases x x := by
  funext j
  refine Fin.addCases (fun j=>?_) (fun j=>?_) j <;>
    simp only [duplicateArithmeticLayer,matrixArithmeticLayer_eval,Fin.addCases_left,Fin.addCases_right,sum_selectCoefficient]

def residualArithmeticProgram {D d n m O : ℕ}
    (pre : Fin (Fintype.card (Fin d))→Fin D→ℝ) (s : ℝ)
    (w : Fin n→Fin d→ℝ) (a : Fin n→ℝ) (A : Fin m→Fin n→ℝ) (b : Fin n→ℝ)
    (post : Fin O→Fin (Fintype.card (Fin d)+Fintype.card (Fin m⊕Unit))→ℝ) :
    ArithmeticProgram D O :=
  (ArithmeticProgram.single (matrixArithmeticLayer pre)).append
    ((radialProgramBlock d s).append
      ((ArithmeticProgram.single (duplicateArithmeticLayer (Fintype.card (Fin d)))).append
        (((canonicalProgramBlock w a A b).carry (Fintype.card (Fin d))).append
          (ArithmeticProgram.single (matrixArithmeticLayer post)))))

theorem residualArithmeticProgram_length {D d n m O : ℕ}
    (pre : Fin (Fintype.card (Fin d))→Fin D→ℝ) (s : ℝ)
    (w : Fin n→Fin d→ℝ) (a : Fin n→ℝ) (A : Fin m→Fin n→ℝ) (b : Fin n→ℝ)
    (post : Fin O→Fin (Fintype.card (Fin d)+Fintype.card (Fin m⊕Unit))→ℝ) :
    (residualArithmeticProgram pre s w a A b post).length=14 := by
  have hr : (radialProgramBlock d s).length=6 := ArithmeticProgram.fromRun_length _ _ _
  have hc : (canonicalProgramBlock w a A b).length=5 := ArithmeticProgram.fromRun_length _ _ _
  have hcarry := ArithmeticProgram.carry_length (Fintype.card (Fin d)) (canonicalProgramBlock w a A b)
  have hlast := ArithmeticProgram.length_then ((canonicalProgramBlock w a A b).carry (Fintype.card (Fin d)))
    (ArithmeticProgram.single (matrixArithmeticLayer post))
  have hdup := ArithmeticProgram.length_then (ArithmeticProgram.single (duplicateArithmeticLayer (Fintype.card (Fin d))))
    (((canonicalProgramBlock w a A b).carry (Fintype.card (Fin d))).append
      (ArithmeticProgram.single (matrixArithmeticLayer post)))
  have hrad := ArithmeticProgram.length_then (radialProgramBlock d s)
    ((ArithmeticProgram.single (duplicateArithmeticLayer (Fintype.card (Fin d)))).append
      (((canonicalProgramBlock w a A b).carry (Fintype.card (Fin d))).append
        (ArithmeticProgram.single (matrixArithmeticLayer post))))
  have hall := ArithmeticProgram.length_then (ArithmeticProgram.single (matrixArithmeticLayer pre))
    ((radialProgramBlock d s).append
      ((ArithmeticProgram.single (duplicateArithmeticLayer (Fintype.card (Fin d)))).append
        (((canonicalProgramBlock w a A b).carry (Fintype.card (Fin d))).append
          (ArithmeticProgram.single (matrixArithmeticLayer post)))))
  simp only [ArithmeticProgram.single_length] at hlast hdup hall
  change _=14
  dsimp only [residualArithmeticProgram]
  omega

theorem residualArithmeticProgram_eval {D d n m O : ℕ}
    (pre : Fin (Fintype.card (Fin d))→Fin D→ℝ) (s : ℝ)
    (w : Fin n→Fin d→ℝ) (a : Fin n→ℝ) (A : Fin m→Fin n→ℝ) (b : Fin n→ℝ)
    (post : Fin O→Fin (Fintype.card (Fin d)+Fintype.card (Fin m⊕Unit))→ℝ)
    (x : Fin D→ℝ) (u : Fin d→ℝ) (hpre : (matrixArithmeticLayer pre).eval x=realCoordinates u) :
    (residualArithmeticProgram pre s w a A b post).eval x=
      (matrixArithmeticLayer post).eval
        (Fin.addCases (realCoordinates (radialArithmeticProgram s u))
          (realCoordinates (canonicalArithmeticProgram w a A b (radialArithmeticProgram s u)))) := by
  change ((ArithmeticProgram.single (matrixArithmeticLayer pre)).append _).eval x=_
  rw [ArithmeticProgram.eval_then]
  change ((radialProgramBlock d s).append _).eval ((matrixArithmeticLayer pre).eval x)=_
  rw [hpre]
  erw [ArithmeticProgram.eval_then (radialProgramBlock d s)]
  rw [radialProgramBlock_eval]
  erw [ArithmeticProgram.eval_then (ArithmeticProgram.single (duplicateArithmeticLayer (Fintype.card (Fin d))))]
  change (((canonicalProgramBlock w a A b).carry (Fintype.card (Fin d))).append _).eval
    ((duplicateArithmeticLayer (Fintype.card (Fin d))).eval (realCoordinates (radialArithmeticProgram s u)))=_
  rw [duplicateArithmeticLayer_eval]
  erw [ArithmeticProgram.eval_then ((canonicalProgramBlock w a A b).carry (Fintype.card (Fin d)))]
  erw [ArithmeticProgram.carry_eval (Fintype.card (Fin d)) (canonicalProgramBlock w a A b)]
  erw [canonicalProgramBlock_eval]
  rfl

theorem residualArithmeticProgram_bounded {D d n m O : ℕ}
    (pre : Fin (Fintype.card (Fin d))→Fin D→ℝ) (s : ℝ)
    (w : Fin n→Fin d→ℝ) (a : Fin n→ℝ) (A : Fin m→Fin n→ℝ) (b : Fin n→ℝ)
    (post : Fin O→Fin (Fintype.card (Fin d)+Fintype.card (Fin m⊕Unit))→ℝ)
    (B : ℕ) (hB : 1≤B) (hpre : ∀j i,|pre j i|≤(B:ℝ)) (hs : (s⁻¹)^2≤(B:ℝ))
    (hw : ∀j i,|w j i|≤(B:ℝ)) (hA : ∀j i,|A j i|≤(B:ℝ)) (hb : ∀i,|b i|≤(B:ℝ))
    (hpost : ∀j i,|post j i|≤(B:ℝ)) :
    (residualArithmeticProgram pre s w a A b post).bounded B := by
  unfold residualArithmeticProgram
  apply ArithmeticProgram.append_bounded
  · exact ⟨hpre,trivial⟩
  apply ArithmeticProgram.append_bounded
    (ArithmeticProgram.fromRun_bounded _ _ B (radialLayers_coefficients d s B hB hs) 6)
  apply ArithmeticProgram.append_bounded
  · refine ⟨?_,trivial⟩
    intro j i
    refine Fin.addCases (fun j=>?_) (fun j=>?_) j <;>
      simp only [duplicateArithmeticLayer,matrixArithmeticLayer,Fin.addCases_left,Fin.addCases_right] <;>
      exact (selectCoefficient_bound j i).trans (show (1:ℝ)≤B by exact_mod_cast hB)
  apply ArithmeticProgram.append_bounded
  · exact ArithmeticProgram.carry_bounded _ _ B hB
      (ArithmeticProgram.fromRun_bounded _ _ B
        (canonicalLayers_coefficients w a A b B hB hw hA hb) 5)
  · exact ⟨hpost,trivial⟩

theorem residualArithmeticProgram_depth {D d n m O : ℕ}
    (pre : Fin (Fintype.card (Fin d))→Fin D→ℝ) (s : ℝ)
    (w : Fin n→Fin d→ℝ) (a : Fin n→ℝ) (A : Fin m→Fin n→ℝ) (b : Fin n→ℝ)
    (post : Fin O→Fin (Fintype.card (Fin d)+Fintype.card (Fin m⊕Unit))→ℝ)
    (Q B U : ℕ) :
    ((residualArithmeticProgram pre s w a A b post).compile Q B U).depth≤70 := by
  simpa only [residualArithmeticProgram_length] using
    (residualArithmeticProgram pre s w a A b post).compile_depth Q B U

#print axioms residualArithmeticProgram_eval
#print axioms residualArithmeticProgram_depth
end ConditionalNonpolynomial.AnalyticLookup
