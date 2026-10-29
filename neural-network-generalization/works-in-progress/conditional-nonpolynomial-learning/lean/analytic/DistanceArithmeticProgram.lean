import ArithmeticProgramBlocks
import UniformProgramGrid

/-! A two-layer arithmetic program for squared distances to a polynomial-size
list of representatives. The last input coordinate supplies the affine bias. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic
variable {ι J : Type} [Fintype ι] [Fintype J] [DecidableEq ι] [DecidableEq J]

 def distanceSquareLayer (centers : J→EuclideanSpace ℝ ι) : ArithmeticLayer (ι⊕Unit) (J×ι) where
  coefficients:=fun z=>Sum.elim (selectCoefficient z.2) (fun _=>-centers z.1 z.2)
  operations:=fun _=>.square

 def distanceSumLayer : ArithmeticLayer (J×ι) J where
  coefficients:=fun j z=>if z.1=j then 1 else 0
  operations:=fun _=>.identity

 def distanceCoordinates : ℕ→Type
  | 0=>ι⊕Unit
  | 1=>J×ι
  | _=>J

 instance distanceCoordinates_fintype (h : ℕ) : Fintype (distanceCoordinates (ι:=ι) (J:=J) h) := by
  unfold distanceCoordinates
  split <;> infer_instance

 def distanceLayers (centers : J→EuclideanSpace ℝ ι) :
    (h : ℕ)→ArithmeticLayer (distanceCoordinates (ι:=ι) (J:=J) h) (distanceCoordinates (ι:=ι) (J:=J) (h+1))
  | 0=>distanceSquareLayer centers
  | 1=>distanceSumLayer
  | _+2=>identityArithmeticLayer J

 def distanceProgramBlock (centers : J→EuclideanSpace ℝ ι) :
    ArithmeticProgram (Fintype.card (ι⊕Unit)) (Fintype.card J) :=
  ArithmeticProgram.fromRun (distanceCoordinates (ι:=ι) (J:=J)) (distanceLayers centers) 2

 theorem distanceSquareLayer_eval (centers : J→EuclideanSpace ℝ ι)
    (x : EuclideanSpace ℝ ι) (t : ℝ) (z : J×ι) :
    (distanceSquareLayer centers).eval (Sum.elim (fun i=>x i) (fun _=>t)) z=(x z.2-t*centers z.1 z.2)^2 := by
  simp [distanceSquareLayer,ArithmeticLayer.eval,ScalarInstruction.eval,Fintype.sum_sum_type]
  ring

 theorem distanceSumLayer_eval (v : (J×ι)→ℝ) (j : J) :
    (distanceSumLayer (ι:=ι)).eval v j=∑i,v (j,i) := by
  simp only [distanceSumLayer,ArithmeticLayer.eval,ScalarInstruction.eval,Fintype.sum_prod_type,ite_mul,one_mul,zero_mul]
  rw [Finset.sum_comm]
  simp

 theorem distanceProgramBlock_eval (centers : J→EuclideanSpace ℝ ι)
    (x : EuclideanSpace ℝ ι) (t : ℝ) :
    (distanceProgramBlock centers).eval (realCoordinates (Sum.elim (fun i=>x i) (fun _=>t)))=
      realCoordinates (fun j=>‖x-t • centers j‖^2) := by
  unfold distanceProgramBlock
  erw [ArithmeticProgram.fromRun_eval]
  congr 1
  funext j
  change (distanceSumLayer (ι:=ι)).eval
    ((distanceSquareLayer centers).eval (Sum.elim (fun i=>x i) (fun _=>t))) j=‖x-t • centers j‖^2
  rw [distanceSumLayer_eval,EuclideanSpace.real_norm_sq_eq]
  apply Finset.sum_congr rfl
  intro i hi
  simpa only [PiLp.sub_apply,PiLp.smul_apply,smul_eq_mul] using distanceSquareLayer_eval centers x t (j,i)

 theorem distanceProgramBlock_length (centers : J→EuclideanSpace ℝ ι) :
    (distanceProgramBlock centers).length=2 := ArithmeticProgram.fromRun_length _ _ _

 theorem distanceProgramBlock_bounded (centers : J→EuclideanSpace ℝ ι) (B : ℕ) (hB : 1≤B)
    (hc : ∀j i,|centers j i|≤(B:ℝ)) : (distanceProgramBlock centers).bounded B := by
  apply ArithmeticProgram.fromRun_bounded
  intro h
  have hBr : (1:ℝ)≤B := by exact_mod_cast hB
  match h with
  | 0=>
    intro j i
    cases i with
    | inl i=>exact (selectCoefficient_bound _ _).trans hBr
    | inr _=>simpa only [distanceLayers,distanceSquareLayer,Sum.elim_inr,abs_neg] using hc j.1 j.2
  | 1=>
    intro j i
    change |if i.1=j then (1:ℝ) else 0|≤(B:ℝ)
    split_ifs <;> norm_num <;> linarith
  | _+2=>
    intro j i
    exact (selectCoefficient_bound _ _).trans hBr

#print axioms distanceProgramBlock_eval
#print axioms distanceProgramBlock_bounded
end ConditionalNonpolynomial.AnalyticLookup
