import ArithmeticProgramEvaluator
import ParallelPicardResources

/-! An actual fixed-grid evaluator for a real arithmetic program approximating
an analytic map. Both input and output recoding are explicit finite DAGs. -/
noncomputable section
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic
variable {ι κ : Type*} [Fintype ι] [Fintype κ]

 def uniformProgramGrid (P : ArithmeticProgram (Fintype.card ι) (Fintype.card κ))
    (B U Q N : ℕ) (ε : ℝ) :
    CircuitMap (Fintype.card ι*Fintype.card (ScalarGrid Q N))
      (Fintype.card κ*Fintype.card (ScalarGrid Q N)) :=
  let Qp:=P.mesh B U ε
  ((recodeCoordinates (ι:=ι) Q N Qp U).then (P.compile Qp B U)).then
    (recodeCoordinates (ι:=κ) Qp (P.outputRange B U) Q N)

 theorem uniformProgramGrid_approximates
    (P : ArithmeticProgram (Fintype.card ι) (Fintype.card κ)) (B U Q N : ℕ)
    (hP : P.bounded B) (hQ : 0<Q) (hU : N+1≤U)
    (F : EuclideanSpace ℝ ι→EuclideanSpace ℝ κ) {ε τ R : ℝ}
    (hε : 0<ε) (hεone : ε≤1)
    (happrox : ∀x:EuclideanSpace ℝ ι,(∀i,|x i|≤(U:ℝ))→‖F x-P.realMap x‖≤τ)
    (hF : ∀a:ι→ScalarCode Q N,‖F (decodeCoordinates Q N a)‖≤R)
    (hN : R+(τ+((Fintype.card κ:ℝ)+1)*ε)≤(N:ℝ)) :
    GridApproximates Q N Q N F (uniformProgramGrid P B U Q N ε)
      (τ+((Fintype.card κ:ℝ)+1)*ε+((Fintype.card κ:ℝ)+1)/(2*(Q:ℝ))) := by
  have heval := P.finite_evaluator B U hP hε hεone
  let Qp:=P.mesh B U ε
  have hc : ∀x:EuclideanSpace ℝ ι,(∀i,|x i|≤(U:ℝ))→
      ∃b:κ→ScalarCode Qp (P.outputRange B U),
        (P.compile Qp B U).eval (encodeCoordinateState Qp U (fun i=>scalarEncode Qp U (x i)))=
          encodeCoordinateState Qp (P.outputRange B U) b ∧
        ‖F x-decodeCoordinates Qp (P.outputRange B U) b‖≤τ+((Fintype.card κ:ℝ)+1)*ε := by
    intro x hx
    obtain ⟨b,hb,he⟩:=heval x hx
    refine ⟨b,hb,?_⟩
    have ht:=dist_triangle (F x) (P.realMap x) (decodeCoordinates Qp (P.outputRange B U) b)
    simp only [dist_eq_norm] at ht
    exact ht.trans (add_le_add (happrox x hx) he)
  exact (gridApproximation_of_cube_evaluator hQ hU F (P.compile Qp B U) _ hc).recodeOutput hQ hF hN

 theorem uniformProgramGrid_depth
    (P : ArithmeticProgram (Fintype.card ι) (Fintype.card κ)) (B U Q N : ℕ) (ε : ℝ) :
    (uniformProgramGrid P B U Q N ε).depth≤5*P.length+10 := by
  apply (CircuitMap.depth_then _ _).trans
  exact (Nat.add_le_add ((CircuitMap.depth_then _ _).trans
    (Nat.add_le_add (recodeCoordinates_depth Q N (P.mesh B U ε) U)
      (P.compile_depth _ B U)))
    (recodeCoordinates_depth (P.mesh B U ε) (P.outputRange B U) Q N)).trans_eq (by omega)

 theorem uniformProgramGrid_size
    (P : ArithmeticProgram (Fintype.card ι) (Fintype.card κ)) (B U Q N : ℕ)
    (hP : P.bounded B) (ε : ℝ) :
    (uniformProgramGrid P B U Q N ε).size≤
      coordinateRecodeSize (Fintype.card ι) Q N (P.mesh B U ε) U+
      P.sizeBudget (P.mesh B U ε) B U+
      coordinateRecodeSize (Fintype.card κ) (P.mesh B U ε) (P.outputRange B U) Q N := by
  unfold uniformProgramGrid
  rw [CircuitMap.size_then,CircuitMap.size_then]
  exact add_le_add (add_le_add (coordinateRecodeSize_bound _ _ _ _) (P.compile_size _ B U hP))
    (coordinateRecodeSize_bound _ _ _ _)

#print axioms uniformProgramGrid_approximates
#print axioms uniformProgramGrid_size
end ConditionalNonpolynomial.AnalyticLookup
