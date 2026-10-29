import PhysicalShortActualPicardGrid

noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic.PhysicalShort
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup
namespace FiniteCanonicalDynamics
variable {d H : ℕ} {t : ℝ} {f : BooleanFunction d} {P : ControlledMarginPath d H t f}
variable {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

 def residualGridSizeBudget (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    (τ : ℝ) (hτ : 0<τ) (hτ1 : τ≤1) (Q N U : ℕ) (ε : ℝ) (j : Fin (H+1)) : ℕ :=
  let A:=M.chosenResidualProgram hd τ hτ hτ1 j
  let B:=M.allResidualCoefficientBudget j
  let Qp:=A.mesh B U ε
  coordinateRecodeSize (canonicalAmbientDimension states H) Q N Qp U+
    A.sizeBudget Qp B U+
    coordinateRecodeSize (canonicalAmbientDimension states H) Qp (A.outputRange B U) Q N

 theorem chosenResidualGrid_size (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    (τ : ℝ) (hτ : 0<τ) (hτ1 : τ≤1) (Q N U : ℕ) (ε : ℝ) (j : Fin (H+1)) :
    (M.chosenResidualGrid hd τ hτ hτ1 Q N U ε j).size≤
      M.residualGridSizeBudget hd τ hτ hτ1 Q N U ε j :=
  uniformProgramGrid_size _ _ U Q N (M.chosenResidualProgram_spec hd τ hτ hτ1 j).2.1 ε

 theorem actualPicardGrid_size (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]CanonicalAmbient states H) (hT : ‖T‖≤1)
    (τ : ℝ) (hτ : 0<τ) (hτ1 : τ≤1) (Q N U V : ℕ) (ε : ℝ) :
    (M.actualPicardGrid hd T τ hτ hτ1 Q N U V ε).size≤
      (Fintype.card M.PicardInputIndex*Fintype.card (ScalarGrid Q N))*
        ((Fintype.card M.PicardStateIndex*Fintype.card (ScalarGrid Q N))*
          (∑j:Fin (H+1),M.residualGridSizeBudget hd τ hτ hτ1 Q N U ε j))+
      arithmeticLayerSize (Fintype.card M.PicardInputIndex) (Fintype.card M.PicardStateIndex) Q 1 N V+
      coordinateRecodeSize (Fintype.card M.PicardStateIndex) Q V Q N := by
  apply parallelPicardCircuit_size Q 1 N V _ _ _
    (by simpa only [Nat.cast_one] using M.picardCoefficientMatrix_bound T hT)
  intro j
  exact (M.chosenResidualGrid_size hd τ hτ hτ1 Q N U ε j).trans
    (Finset.single_le_sum (fun i _=>Nat.zero_le _) (Finset.mem_univ j))

#print axioms actualPicardGrid_size
end FiniteCanonicalDynamics
end ConditionalNonpolynomial.Analytic.PhysicalShort
