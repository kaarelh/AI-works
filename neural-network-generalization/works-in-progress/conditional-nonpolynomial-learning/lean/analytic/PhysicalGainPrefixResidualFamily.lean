import PhysicalGainPrefixGridSystem
import UniformProgramGrid

noncomputable section
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
namespace ConditionalNonpolynomial.Analytic.PhysicalLong
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup PhysicalShort
namespace GainPrefixDynamics
variable {d H J : ℕ} {t : ℝ} {f : BooleanFunction d} {P : ControlledMarginPath d H t f}
variable {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

 def allResidualCoefficientBudget (M : GainPrefixDynamics P S states J) (j : Fin (J+1)) : ℕ :=
  if hj:j.val<J then M.residualCoefficientBudget ⟨j,hj⟩ else 1

 def allResidualDimensionBudget (M : GainPrefixDynamics P S states J) (j : Fin (J+1)) (τ : ℝ) : ℕ :=
  if hj:j.val<J then
    2*canonicalAmbientDimension states J+4*M.layerInputDimension ⟨j,hj⟩+
      2*M.quadratureCount ⟨j,hj⟩ τ+2*M.layerRank ⟨j,hj⟩+4
  else canonicalAmbientDimension states J

 theorem exists_allResidual_program (M : GainPrefixDynamics P S states J)
    (j : Fin (J+1)) {τ : ℝ} (hτ : 0<τ) (hτ1 : τ≤1) :
    ∃A : ArithmeticProgram (canonicalAmbientDimension states J) (canonicalAmbientDimension states J),
      A.length≤14 ∧ A.bounded (M.allResidualCoefficientBudget j) ∧
      A.maxDimension≤M.allResidualDimensionBudget j τ ∧
      ∀x:EuclideanSpace ℝ (CanonicalAmbientIndex states J),‖A.realMap x-M.allResidualCoordinates j x‖≤τ := by
  by_cases hj:j.val<J
  · obtain ⟨A,hlen,hbound,hdim,happrox⟩:=M.exists_residual_realMap_program ⟨j,hj⟩ hτ hτ1
    refine ⟨A,hlen.le,?_,?_,?_⟩
    · simpa only [allResidualCoefficientBudget,dif_pos hj] using hbound
    · simpa only [allResidualDimensionBudget,dif_pos hj] using hdim
    · exact happrox
  · have heq : j=Fin.last J := Fin.ext (by simp only [Fin.val_last];omega)
    let A:ArithmeticProgram (canonicalAmbientDimension states J) (canonicalAmbientDimension states J):=
      ArithmeticProgram.single (matrixArithmeticLayer (fun _ _=>0))
    refine ⟨A,by norm_num [A,ArithmeticProgram.single,ArithmeticProgram.length],?_,?_,?_⟩
    · simp only [allResidualCoefficientBudget,dif_neg hj]
      exact ⟨fun _ _=>by norm_num [matrixArithmeticLayer],trivial⟩
    · simp [allResidualDimensionBudget,dif_neg hj,A,ArithmeticProgram.single,ArithmeticProgram.maxDimension]
    · intro x
      have hz : A.realMap x=0 := by
        apply WithLp.ofLp_injective 2
        funext i
        simp [ArithmeticProgram.realMap,A,ArithmeticProgram.single,ArithmeticProgram.eval,
          matrixArithmeticLayer,ArithmeticLayer.eval,ScalarInstruction.eval]
      rw [hz,heq,M.allResidualCoordinates_last]
      simpa only [sub_zero,norm_zero] using hτ.le

 def chosenResidualProgram (M : GainPrefixDynamics P S states J)
    (τ : ℝ) (hτ : 0<τ) (hτ1 : τ≤1) (j : Fin (J+1)) :=
  Classical.choose (M.exists_allResidual_program j hτ hτ1)

 theorem chosenResidualProgram_spec (M : GainPrefixDynamics P S states J)
    (τ : ℝ) (hτ : 0<τ) (hτ1 : τ≤1) (j : Fin (J+1)) :
    (M.chosenResidualProgram τ hτ hτ1 j).length≤14 ∧
    (M.chosenResidualProgram τ hτ hτ1 j).bounded (M.allResidualCoefficientBudget j) ∧
    (M.chosenResidualProgram τ hτ hτ1 j).maxDimension≤M.allResidualDimensionBudget j τ ∧
    ∀x:EuclideanSpace ℝ (CanonicalAmbientIndex states J),
      ‖(M.chosenResidualProgram τ hτ hτ1 j).realMap x-M.allResidualCoordinates j x‖≤τ :=
  Classical.choose_spec (M.exists_allResidual_program j hτ hτ1)


#print axioms exists_allResidual_program
end GainPrefixDynamics
end ConditionalNonpolynomial.Analytic.PhysicalLong
