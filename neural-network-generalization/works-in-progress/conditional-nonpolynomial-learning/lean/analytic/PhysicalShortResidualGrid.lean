import PhysicalShortPicardCoordinates
import UniformProgramGrid

noncomputable section
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
namespace ConditionalNonpolynomial.Analytic.PhysicalShort
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup
namespace FiniteCanonicalDynamics
variable {d H : ℕ} {t : ℝ} {f : BooleanFunction d} {P : ControlledMarginPath d H t f}
variable {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

 def allResidualCoefficientBudget (M : FiniteCanonicalDynamics P S states) (j : Fin (H+1)) : ℕ :=
  if hj:j.val<H then M.residualCoefficientBudget ⟨j,hj⟩ else 1

 def allResidualDimensionBudget (M : FiniteCanonicalDynamics P S states) (j : Fin (H+1)) (τ : ℝ) : ℕ :=
  if hj:j.val<H then
    2*canonicalAmbientDimension states H+4*M.layerInputDimension ⟨j,hj⟩+
      2*M.quadratureCount ⟨j,hj⟩ τ+2*M.layerRank ⟨j,hj⟩+4
  else canonicalAmbientDimension states H

 theorem exists_allResidual_program (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    (j : Fin (H+1)) {τ : ℝ} (hτ : 0<τ) (hτ1 : τ≤1) :
    ∃A : ArithmeticProgram (canonicalAmbientDimension states H) (canonicalAmbientDimension states H),
      A.length≤14 ∧ A.bounded (M.allResidualCoefficientBudget j) ∧
      A.maxDimension≤M.allResidualDimensionBudget j τ ∧
      ∀x:EuclideanSpace ℝ (CanonicalAmbientIndex states H),‖A.realMap x-M.allResidualCoordinates j x‖≤τ := by
  by_cases hj:j.val<H
  · obtain ⟨A,hlen,hbound,hdim,happrox⟩:=M.exists_residual_realMap_program hd ⟨j,hj⟩ hτ hτ1
    refine ⟨A,hlen.le,?_,?_,?_⟩
    · simpa only [allResidualCoefficientBudget,dif_pos hj] using hbound
    · simpa only [allResidualDimensionBudget,dif_pos hj] using hdim
    · exact happrox
  · have heq : j=Fin.last H := Fin.ext (by simp only [Fin.val_last];omega)
    let A:ArithmeticProgram (canonicalAmbientDimension states H) (canonicalAmbientDimension states H):=
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

 theorem exists_allResidual_grid (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    (j : Fin (H+1)) (Q N U : ℕ) (hQ : 0<Q) (hU : N+1≤U)
    {τ ε : ℝ} (hτ : 0<τ) (hτ1 : τ≤1) (hε : 0<ε) (hε1 : ε≤1)
    (hN : M.residualRange (canonicalSignPrecision P) j+
      (τ+((canonicalAmbientDimension states H:ℝ)+1)*ε)≤N) :
    ∃A : ArithmeticProgram (canonicalAmbientDimension states H) (canonicalAmbientDimension states H),
      A.length≤14 ∧ A.bounded (M.allResidualCoefficientBudget j) ∧
      A.maxDimension≤M.allResidualDimensionBudget j τ ∧
      GridApproximates Q N Q N (M.allResidualCoordinates j)
        (uniformProgramGrid A (M.allResidualCoefficientBudget j) U Q N ε)
        (τ+((canonicalAmbientDimension states H:ℝ)+1)*ε+
          ((canonicalAmbientDimension states H:ℝ)+1)/(2*(Q:ℝ))) := by
  obtain ⟨A,hlen,hbound,hdim,happrox⟩:=M.exists_allResidual_program hd j hτ hτ1
  refine ⟨A,hlen,hbound,hdim,?_⟩
  apply uniformProgramGrid_approximates A (M.allResidualCoefficientBudget j) U Q N hbound hQ hU
    (M.allResidualCoordinates j) hε hε1
  · intro x hx
    rw [norm_sub_rev]
    exact happrox x
  · intro a
    exact M.allResidualCoordinates_range j _
  · exact hN

#print axioms exists_allResidual_grid
end FiniteCanonicalDynamics
end ConditionalNonpolynomial.Analytic.PhysicalShort
