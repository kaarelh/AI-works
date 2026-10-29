import CanonicalResidualGrid
import ParallelPicardResources

noncomputable section
set_option maxHeartbeats 1500000
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup
namespace FiniteCanonicalDynamics
variable {d H : ℕ} {f : BooleanFunction d} {P : ControlledMarginPath d H 1 f}
variable {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

 def chosenResidualProgram (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    (τ : ℝ) (hτ : 0<τ) (hτ1 : τ≤1) (j : Fin (H+1)) :=
  Classical.choose (M.exists_allResidual_program hd j hτ hτ1)

 theorem chosenResidualProgram_spec (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    (τ : ℝ) (hτ : 0<τ) (hτ1 : τ≤1) (j : Fin (H+1)) :
    (M.chosenResidualProgram hd τ hτ hτ1 j).length≤14 ∧
    (M.chosenResidualProgram hd τ hτ hτ1 j).bounded (M.allResidualCoefficientBudget j) ∧
    (M.chosenResidualProgram hd τ hτ hτ1 j).maxDimension≤M.allResidualDimensionBudget j τ ∧
    ∀x:EuclideanSpace ℝ (CanonicalAmbientIndex states H),
      ‖(M.chosenResidualProgram hd τ hτ hτ1 j).realMap x-M.allResidualCoordinates j x‖≤τ :=
  Classical.choose_spec (M.exists_allResidual_program hd j hτ hτ1)

 def chosenResidualGrid (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    (τ : ℝ) (hτ : 0<τ) (hτ1 : τ≤1) (Q N U : ℕ) (ε : ℝ) (j : Fin (H+1)) :=
  uniformProgramGrid (ι:=CanonicalAmbientIndex states H) (κ:=CanonicalAmbientIndex states H)
    (M.chosenResidualProgram hd τ hτ hτ1 j) (M.allResidualCoefficientBudget j) U Q N ε

 def residualGridError (_M : FiniteCanonicalDynamics P S states) (Q : ℕ) (τ ε : ℝ) : ℝ :=
  τ+((canonicalAmbientDimension states H:ℝ)+1)*ε+((canonicalAmbientDimension states H:ℝ)+1)/(2*(Q:ℝ))

 theorem chosenResidualGrid_approximates (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    (τ : ℝ) (hτ : 0<τ) (hτ1 : τ≤1) (Q N U : ℕ) (hQ : 0<Q) (hU : N+1≤U)
    (ε : ℝ) (hε : 0<ε) (hε1 : ε≤1) (j : Fin (H+1))
    (hN : M.residualRange (canonicalSignPrecision P) j+
      (τ+((canonicalAmbientDimension states H:ℝ)+1)*ε)≤N) :
    GridApproximates Q N Q N (M.allResidualCoordinates j)
      (M.chosenResidualGrid hd τ hτ hτ1 Q N U ε j) (M.residualGridError Q τ ε) := by
  apply uniformProgramGrid_approximates _ _ U Q N (M.chosenResidualProgram_spec hd τ hτ hτ1 j).2.1
    hQ hU (M.allResidualCoordinates j) hε hε1
  · intro x hx
    rw [norm_sub_rev]
    exact (M.chosenResidualProgram_spec hd τ hτ hτ1 j).2.2.2 x
  · intro a
    exact M.allResidualCoordinates_range j _
  · exact hN

 theorem chosenResidualGrid_depth (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    (τ : ℝ) (hτ : 0<τ) (hτ1 : τ≤1) (Q N U : ℕ) (ε : ℝ) (j : Fin (H+1)) :
    (M.chosenResidualGrid hd τ hτ hτ1 Q N U ε j).depth≤80 := by
  have hh:=uniformProgramGrid_depth (M.chosenResidualProgram hd τ hτ hτ1 j)
    (M.allResidualCoefficientBudget j) U Q N ε
  have hl:=(M.chosenResidualProgram_spec hd τ hτ hτ1 j).1
  exact hh.trans (by omega)

abbrev PicardStateIndex (_M : FiniteCanonicalDynamics P S states) :=
  Fin (H+1)×CanonicalAmbientIndex states H
abbrev PicardInputIndex (M : FiniteCanonicalDynamics P S states) := Fin (d+1)⊕M.PicardStateIndex

 def picardPreError (M : FiniteCanonicalDynamics P S states) (Q N : ℕ) (τ ε : ℝ) : ℝ :=
  (((Fintype.card M.PicardStateIndex:ℝ)+1)*(Fintype.card M.PicardInputIndex:ℝ))*
    (((Fintype.card M.PicardInputIndex:ℝ)+1)*(((Fintype.card M.PicardStateIndex:ℝ)+1)*M.residualGridError Q τ ε))+
  (((Fintype.card M.PicardStateIndex:ℝ)+1)*(((Fintype.card M.PicardInputIndex:ℝ)*((N:ℝ)+1)+1)/(2*(Q:ℝ))))

 def picardGridError (M : FiniteCanonicalDynamics P S states) (Q N : ℕ) (τ ε : ℝ) : ℝ :=
  M.picardPreError Q N τ ε+((Fintype.card M.PicardStateIndex:ℝ)+1)/(2*(Q:ℝ))

 def actualPicardGrid (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]CanonicalAmbient states H)
    (τ : ℝ) (hτ : 0<τ) (hτ1 : τ≤1) (Q N U V : ℕ) (ε : ℝ) :=
  parallelPicardCircuit Q 1 N V (M.chosenResidualGrid hd τ hτ hτ1 Q N U ε)
    (M.picardCoefficientMatrix T) (fun _=>0)

 theorem actualPicardGrid_depth (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]CanonicalAmbient states H)
    (τ : ℝ) (hτ : 0<τ) (hτ1 : τ≤1) (Q N U V : ℕ) (ε : ℝ) :
    (M.actualPicardGrid hd T τ hτ hτ1 Q N U V ε).depth≤90 :=
  parallelPicardCircuit_depth Q 1 N V _ _ _ 80 (M.chosenResidualGrid_depth hd τ hτ hτ1 Q N U ε)

 theorem actualPicardGrid_approximates (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]CanonicalAmbient states H) (hT : ‖T‖≤1)
    (τ : ℝ) (hτ : 0<τ) (hτ1 : τ≤1) (Q N U V : ℕ) (hQ : 0<Q) (hU : N+1≤U)
    (ε : ℝ) (hε : 0<ε) (hε1 : ε≤1) (R0 : ℝ)
    (hV : 1+Fintype.card M.PicardInputIndex*2*(N+1)≤V)
    (hres : ∀j:Fin (H+1),M.residualRange (canonicalSignPrecision P) j+
      (τ+((canonicalAmbientDimension states H:ℝ)+1)*ε)≤N)
    (hN : ((Fintype.card M.PicardStateIndex:ℝ)+1)*
      (R0+∑j:Fin (H+1),M.residualRange (canonicalSignPrecision P) j)+M.picardPreError Q N τ ε≤N) :
    GridApproximatesOn Q N Q N
      (fun a:M.PicardInputIndex→ScalarCode Q N=>‖decodeCoordinates Q N (fun i=>a (.inl i))‖≤R0)
      (M.picardCoordinateUpdate T) (M.actualPicardGrid hd T τ hτ hτ1 Q N U V ε)
      (M.picardGridError Q N τ ε) := by
  have herr : 0≤M.residualGridError Q τ ε := by unfold residualGridError;positivity
  have hmain:=parallelPicardCircuit_approximatesOn Q 1 N V hQ M.allResidualCoordinates
    (M.chosenResidualGrid hd τ hτ hτ1 Q N U ε) (M.picardCoefficientMatrix T) (fun _=>0)
    (by simpa only [Nat.cast_one] using M.picardCoefficientMatrix_bound T hT) (fun _=>by norm_num) hV herr
    (fun j=>M.chosenResidualGrid_approximates hd τ hτ hτ1 Q N U hQ hU ε hε hε1 j (hres j))
    (fun a:Fin (d+1)→ScalarCode Q N=>‖decodeCoordinates Q N a‖≤R0)
    (R:=((Fintype.card M.PicardStateIndex:ℝ)+1)*
      (R0+∑j:Fin (H+1),M.residualRange (canonicalSignPrecision P) j))
    (by
      intro a ha
      have hh:=M.picardCoordinateUpdate_range T hT (decodeCoordinates Q N (fun i=>a (.inl i)))
        (fun j=>decodeCoordinates Q N (fun i=>a (.inr (j,i)))) ha
      convert hh using 1
      congr 2)
    (by simpa only [Nat.cast_one,mul_one,picardPreError] using hN)
  simpa only [Nat.cast_one,mul_one,picardGridError,picardPreError,PicardInputIndex,PicardStateIndex,
    picardCoordinateUpdate,actualPicardGrid] using hmain

#print axioms actualPicardGrid_approximates
#print axioms actualPicardGrid_depth
end FiniteCanonicalDynamics
end ConditionalNonpolynomial.Analytic
