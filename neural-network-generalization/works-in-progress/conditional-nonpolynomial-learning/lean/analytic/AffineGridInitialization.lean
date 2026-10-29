import BooleanGridInput
import ValidGridIteration
import MatrixCoordinates
import CriticalMarginOccupation

noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic NeuralGeneralization.ConcreteModel
variable {ζ ι J : Type*} [Fintype ζ] [Fintype ι] [Fintype J]

 def baseVectorMap (A : J→EuclideanSpace ℝ ζ→L[ℝ]EuclideanSpace ℝ ι)
    (x : EuclideanSpace ℝ ζ) : EuclideanSpace ℝ (J×ι) := WithLp.toLp 2 (fun z=>A z.1 x z.2)

 def baseVectorCoefficients (A : J→EuclideanSpace ℝ ζ→L[ℝ]EuclideanSpace ℝ ι)
    (z : J×ι) (i : ζ) : ℝ := linearCoefficients (A z.1) z.2 i

 theorem baseVectorCoefficients_eval (A : J→EuclideanSpace ℝ ζ→L[ℝ]EuclideanSpace ℝ ι) :
    affineRealMap (baseVectorCoefficients A) (fun _=>0)=baseVectorMap A := by
  funext x
  apply WithLp.ofLp_injective 2
  funext z
  exact (zero_add _).trans (linearCoefficients_eval _ _ _)

 theorem baseVectorMap_norm (A : J→EuclideanSpace ℝ ζ→L[ℝ]EuclideanSpace ℝ ι)
    (hA : ∀j,‖A j‖≤1) (x : EuclideanSpace ℝ ζ) :
    ‖baseVectorMap A x‖≤((Fintype.card (J×ι):ℝ)+1)*‖x‖ := by
  apply euclidean_norm_of_coordinate_bounds _ (norm_nonneg _)
  intro z
  exact (PiLp.norm_apply_le _ z.2).trans ((A z.1).le_opNorm x |>.trans
    ((mul_le_mul_of_nonneg_right (hA z.1) (norm_nonneg x)).trans_eq (one_mul _)))

 def baseGridCircuit (A : J→EuclideanSpace ℝ ζ→L[ℝ]EuclideanSpace ℝ ι) (Q N V : ℕ) :=
  (affineGridCircuit (baseVectorCoefficients A) (fun _=>0) Q N V).then
    (recodeCoordinates Q V Q N)

 def baseGridError (ζ ι J : Type*) [Fintype ζ] [Fintype ι] [Fintype J] (Q N : ℕ) : ℝ :=
  ((Fintype.card (J×ι):ℝ)+1)*(((Fintype.card ζ:ℝ)*((N:ℝ)+1)+1)/(2*(Q:ℝ)))+
    ((Fintype.card (J×ι):ℝ)+1)/(2*(Q:ℝ))

 theorem baseGridCircuit_approximates (A : J→EuclideanSpace ℝ ζ→L[ℝ]EuclideanSpace ℝ ι)
    (hA : ∀j,‖A j‖≤1) (Q N V : ℕ) (hQ : 0<Q)
    (hV : 1+Fintype.card ζ*2*(N+1)≤V) (R : ℝ)
    (hN : ((Fintype.card (J×ι):ℝ)+1)*R+
      ((Fintype.card (J×ι):ℝ)+1)*(((Fintype.card ζ:ℝ)*((N:ℝ)+1)+1)/(2*(Q:ℝ)))≤N) :
    GridApproximatesOn Q N Q N (fun a=>‖decodeCoordinates Q N a‖≤R)
      (baseVectorMap A) (baseGridCircuit A Q N V) (baseGridError ζ ι J Q N) := by
  have hc : ∀z i,|baseVectorCoefficients A z i|≤((1:ℕ):ℝ) := by
    intro z i
    simpa only [Nat.cast_one,baseVectorCoefficients] using (linearCoefficients_bound (A z.1) z.2 i).trans (hA z.1)
  have hh:=affineGridCircuit_approximates (baseVectorCoefficients A) (fun _=>0) Q 1 N V hQ hc
    (fun _=>by norm_num) hV
  rw [baseVectorCoefficients_eval] at hh
  exact hh.restrict.recodeOutput hQ (fun a ha=>
    (baseVectorMap_norm A hA _).trans (mul_le_mul_of_nonneg_left ha (by positivity))) hN

 theorem baseGridCircuit_depth (A : J→EuclideanSpace ℝ ζ→L[ℝ]EuclideanSpace ℝ ι) (Q N V : ℕ) :
    (baseGridCircuit A Q N V).depth≤10 :=
  (CircuitMap.depth_then _ _).trans (Nat.add_le_add (affineGridCircuit_depth _ _ _ _ _)
    (recodeCoordinates_depth _ _ _ _))

 def normalizedCodes (d Q N : ℕ) (x : Input d) : Fin (d+1)→ScalarCode Q N :=
  fun i=>scalarEncode Q N (normalizedInputFeature d x i)

 theorem normalizedInput_norm_le (d : ℕ) (hd : 1≤d) (x : Input d) :
    ‖normalizedInputFeature d x‖≤2 := by
  have hh:=normalizedInputFeature_norm_sq_le_two hd x
  nlinarith [norm_nonneg (normalizedInputFeature d x)]

 theorem normalizedCodes_error (d Q N : ℕ) (hd : 1≤d) (hQ : 0<Q) (hN : 2≤N) (x : Input d) :
    ‖normalizedInputFeature d x-decodeCoordinates Q N (normalizedCodes d Q N x)‖≤((d:ℝ)+2)/(2*(Q:ℝ)) := by
  have hn : (2:ℝ)≤N := by exact_mod_cast hN
  have hh:=normalizedInputEncoding_error d Q N hQ
    (fun x i=>(PiLp.norm_apply_le _ i).trans ((normalizedInput_norm_le d hd x).trans hn)) x
  simp only [normalizedInputSources_eval] at hh
  exact hh

 theorem normalizedCodes_valid (d Q N : ℕ) (hd : 1≤d) (hQ : 0<Q) (hN : 2≤N)
    (hp : ((d:ℝ)+2)/(2*(Q:ℝ))≤1) (x : Input d) :
    ‖decodeCoordinates Q N (normalizedCodes d Q N x)‖≤3 := by
  have he:=(normalizedCodes_error d Q N hd hQ hN x).trans hp
  have ht:=norm_le_norm_sub_add (decodeCoordinates Q N (normalizedCodes d Q N x)) (normalizedInputFeature d x)
  rw [norm_sub_rev] at ht
  linarith [normalizedInput_norm_le d hd x]

 def booleanAffineInitializer {d : ℕ}
    (A : J→EuclideanSpace ℝ (Fin (d+1))→L[ℝ]EuclideanSpace ℝ ι) (Q N V : ℕ) :=
  let source:=booleanGridInput Q N (normalizedInputSources d)
  sumGridCircuits source (source.then (baseGridCircuit A Q N V))

 theorem booleanAffineInitializer_eval {d : ℕ}
    (A : J→EuclideanSpace ℝ (Fin (d+1))→L[ℝ]EuclideanSpace ℝ ι)
    (hA : ∀j,‖A j‖≤1) (Q N V : ℕ) (hd : 1≤d) (hQ : 0<Q) (hN0 : 2≤N)
    (hp : ((d:ℝ)+2)/(2*(Q:ℝ))≤1)
    (hV : 1+Fintype.card (Fin (d+1))*2*(N+1)≤V)
    (hN : ((Fintype.card (J×ι):ℝ)+1)*3+
      ((Fintype.card (J×ι):ℝ)+1)*(((Fintype.card (Fin (d+1)):ℝ)*((N:ℝ)+1)+1)/(2*(Q:ℝ)))≤N)
    (x : Input d) :
    ∃u:(J×ι)→ScalarCode Q N,
      (booleanAffineInitializer A Q N V).eval x=encodeCoordinateState Q N (Sum.elim (normalizedCodes d Q N x) u) ∧
      ‖baseVectorMap A (decodeCoordinates Q N (normalizedCodes d Q N x))-decodeCoordinates Q N u‖≤
        baseGridError (Fin (d+1)) ι J Q N := by
  obtain ⟨u,hu,he⟩:=baseGridCircuit_approximates A hA Q N V hQ hV 3 hN
    (normalizedCodes d Q N x) (normalizedCodes_valid d Q N hd hQ hN0 hp x)
  refine ⟨u,?_,he⟩
  apply sumGridCircuits_eval
  · simp only [booleanGridInput_eval,normalizedInputSources_eval]
    rfl
  · rw [CircuitMap.eval_then,booleanGridInput_eval]
    simp only [normalizedInputSources_eval]
    exact hu

 theorem booleanAffineInitializer_depth {d : ℕ}
    (A : J→EuclideanSpace ℝ (Fin (d+1))→L[ℝ]EuclideanSpace ℝ ι) (Q N V : ℕ) :
    (booleanAffineInitializer A Q N V).depth≤11 := by
  apply sumGridCircuits_depth _ _ 11
  · exact (booleanGridInput_depth _ _ _).trans (by norm_num)
  · exact (CircuitMap.depth_then _ _).trans
      (Nat.add_le_add (booleanGridInput_depth _ _ _) (baseGridCircuit_depth _ _ _ _))

#print axioms booleanAffineInitializer_eval
#print axioms booleanAffineInitializer_depth
end ConditionalNonpolynomial.AnalyticLookup
